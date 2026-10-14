/**
 * Shared singleton container for the notebook write lock.
 *
 * Allows tests to replace the module-level write lock with one atomic swap via
 * __setSingletons(), instead of patching each singleton individually.
 */

import { AsyncLocalStorage } from "node:async_hooks";

// ── Types ─────────────────────────────────────────────────────────────

export interface RuntimeWriteLock {
	pending: number;
	tail: Promise<void>;
}

export interface RuntimeSingletons {
	writeLock: RuntimeWriteLock;
	writeContext: AsyncLocalStorage<true>;
}

export function createWriteLock(): RuntimeWriteLock {
	return {
		pending: 0,
		tail: Promise.resolve(),
	};
}

// ── State ─────────────────────────────────────────────────────────────

let current: RuntimeSingletons = {
	writeLock: createWriteLock(),
	writeContext: new AsyncLocalStorage<true>(),
};

// ── Public API ────────────────────────────────────────────────────────

/** Atomically replace all singletons. */
export function __setSingletons(
	s: RuntimeSingletons,
	options?: { forceWriteLock?: boolean },
): void {
	if (!options?.forceWriteLock && current.writeLock.pending > 0) {
		console.warn(
			"[runtime-singletons] writeLock has %d pending operation(s) — " +
				"preserving existing lock chain to avoid breaking in-flight writes. " +
				"Use { forceWriteLock: true } to override.",
			current.writeLock.pending,
		);
		// Preserve both lock and ALS context together. Swapping only the context
		// breaks reentrancy detection for writers already running inside the old lock.
		current = {
			...s,
			writeLock: current.writeLock,
			writeContext: current.writeContext,
		};
		return;
	}
	current = s;
}

/** Read the current singleton container. */
export function getSingletons(): RuntimeSingletons {
	return current;
}
