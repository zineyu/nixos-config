/**
 * Shared mutable state for the notebook and handoff primitives.
 *
 * Single source of truth that all modules read/write through.
 * Mutable by design — this is session-scoped imperative state.
 */

import type { NotebookTopicBoundaryHint } from "./notebook/topic.js";
import type { HandoffPayload } from "./handoff/format.js";

export interface SchematicState {
	/** Compact notebook pages keyed by kebab-case name */
	notebookPages: Map<string, string>;

	/** Names of pages whose latest accepted write was clipped by the write-size cap. */
	clippedPages: Set<string>;

	/** Notebook generation counter. 0 = no writes yet; 1 = first write; bumped on discard. */
	epoch: number;

	/** Current semantic frame for topic-aware handoff decisions. */
	activeNotebookTopic: string | null;

	/** Whether the current topic came from the human or the agent. */
	activeNotebookTopicSource: "human" | "agent" | null;

	/**
	 * Boundary cue consumed after a topic change. It stays queued while context
	 * usage is unavailable or below the handoff threshold so a later context hook
	 * can still nudge toward handoff.
	 */
	pendingTopicBoundaryHint: NotebookTopicBoundaryHint | null;

	/** Last context usage percent from getContextUsage() */
	lastContextPercent: number | null;

	/**
	 * Generation marker queued by the tool until the matching compaction hook consumes
	 * it. The successor message is built at tool-call time and carried by the
	 * completion callback, so no request payload belongs here.
	 */
	pendingHandoff: { generation: number } | null;

	/** Monotonically increasing identity used to ignore stale compaction callbacks. */
	handoffGeneration: number;

	/** Generation of the compaction currently in flight, if any. */
	handoffCompactionGeneration: number | null;

	/** Exact successor payload and its durable per-cut recovery key retained until direct completion finalizes. */
	pendingHandoffDelivery: { generation: number; payload: HandoffPayload; recoveryKey: string } | null;

	/**
	 * Successor delivery already requested by recovery in this process.
	 * Coalesces repeated recovery triggers for one persisted handoff cut while the
	 * delivery is pending; cleared when a run settles and reset on session_start.
	 * Deliberately not cleared on branch switch (invalidateHandoffState): the
	 * durable cut key lets a cut shared across `/tree` branches coalesce instead
	 * of double-sending. Entries carrying a v1 payload but no recovery key fall
	 * back to their persisted entry identity; legacy entries without a payload
	 * are never recovered (recovery.ts stops at the newest unreadable cut).
	 */
	recoveryRequestedMessage: { handoffEntryId: string | null; recoveryKey: string | null; message: string } | null;

	/** Prepared notebook discard awaiting the matching successful handoff callback. */
	pendingNotebookDiscard: { generation: number; nextEpoch: number; deleted: string[] } | null;

	/**
	 * High-water mark for discard epochs. Advanced in-memory by prepare;
	 * derived from the branch by reconstruction (max valid observed page/
	 * generation epoch). Survives failed attempts and restarts so retries
	 * cannot reuse a staged epoch and resurrect orphaned survivor entries.
	 */
	discardEpochWatermark: number;

	/**
	 * Required handoff request that stays alive until a real tool-driven compaction
	 * succeeds, is explicitly reset, or ages out via watchdog enforcement.
	 */
	pendingRequestedHandoff: {
		/** True only after the current session has actually called the handoff tool. */
		toolCalled: boolean;
		/** Turn counter for repeated "you still owe the user a handoff" nudges. */
		enforcementAttempts: number;
		/** Human `/handoff <direction>` instruction, or null when the model must supply one. */
		nextInstruction: string | null;
	} | null;

	/**
	 * Last context-percentage band at which the watchdog nudge was delivered.
	 * null = never delivered. Bands: null (<30), 0 (30-49), 1 (50-69), 2 (70+).
	 * Used to throttle nudges — only nudge when crossing into a higher band.
	 */
	lastWatchdogBand: number | null;
}

/** Create a fresh state instance. Call reset() on /new. */
export function createState(): SchematicState {
	return {
		notebookPages: new Map(),
		clippedPages: new Set(),
		epoch: 0,
		activeNotebookTopic: null,
		activeNotebookTopicSource: null,
		pendingTopicBoundaryHint: null,
		lastContextPercent: null,
		pendingHandoff: null,
		handoffGeneration: 0,
		handoffCompactionGeneration: null,
		pendingHandoffDelivery: null,
		recoveryRequestedMessage: null,
		pendingNotebookDiscard: null,
		discardEpochWatermark: 0,
		pendingRequestedHandoff: null,
		lastWatchdogBand: null,
	};
}

/** Reset all state. Used on /new or session reset. */
export function resetState(state: SchematicState): void {
	state.notebookPages.clear();
	state.clippedPages.clear();
	state.epoch = 0; // sentinel: 0 = not yet initialized; set to 1 on first write
	// /new abandons the previous session tree; the watermark dies with it. A
	// fresh session has no staged epochs, so derivation on its empty branch is 0.
	state.discardEpochWatermark = 0;
	state.activeNotebookTopic = null;
	state.activeNotebookTopicSource = null;
	state.lastContextPercent = null;
	invalidateHandoffState(state);
	// /new abandons the previous session completely; do not carry its in-flight
	// reservation into the fresh session.
	state.handoffCompactionGeneration = null;
	state.recoveryRequestedMessage = null;
}

/** Invalidate handoff work that belongs to a previous session-tree branch. */
export function invalidateHandoffState(state: SchematicState): void {
	state.handoffGeneration++;
	state.pendingHandoff = null;
	state.handoffCompactionGeneration = null;
	state.pendingHandoffDelivery = null;
	state.pendingNotebookDiscard = null;
	// The discard watermark is deliberately NOT reset here. A branch change is
	// immediately followed by reconstruction, which derives the watermark from
	// the newly active branch (staged survivor epochs included). Resetting early
	// would let a retry reuse a staged epoch and resurrect orphaned entries.
	//
	// An interrupted discard left staged survivors + a stray generation marker in
	// the branch; reconstruction ignores them (currentEpoch never advances), so
	// the orphaned entries are harmless.
	state.pendingRequestedHandoff = null;
	state.pendingTopicBoundaryHint = null;
	state.lastWatchdogBand = null;
	// A branch switch abandons the old compaction path completely. Release the
	// overlap guard now so the new branch cannot get stuck waiting on callbacks
	// from work that no longer belongs to the active session tree.
	// recoveryRequestedMessage is deliberately NOT reset here — see its state doc.
}
