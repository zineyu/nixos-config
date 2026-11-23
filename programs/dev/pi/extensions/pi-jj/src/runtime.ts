import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";
import { rm } from "node:fs/promises";
import { join } from "node:path";
import { checkpointLine, formatAge } from "./format";
import { createSettingsStore } from "./settings";
import {
  CHECKPOINT_ENTRY_TYPE,
  DEFAULT_CHECKPOINT_LIST_LIMIT,
  DEFAULT_MAX_CHECKPOINTS,
  STATUS_KEY,
  type Checkpoint,
  type PendingCheckpoint,
  type PiJjSettings,
} from "./types";

type TurnEventLike = { turnIndex: number; timestamp: number };
type TurnEndEventLike = { turnIndex: number };
type ForkEventLike = { entryId: string };
type TreeEventLike = { preparation: { targetId: string } };

export class PiJjRuntime {
  private checkpoints = new Map<string, Checkpoint>();

  private isJjRepo = false;
  private isGitRepo = false;
  private sessionId: string | null = null;
  private pendingCheckpoint: PendingCheckpoint | null = null;
  private resumeCheckpointOperationId: string | null = null;
  private lastRestoreOperationId: string | null = null;
  private needsInitPrompt = false;
  private initPromptShown = false;
  private initInProgress = false;

  private readonly settingsStore = createSettingsStore();

  constructor(private readonly pi: ExtensionAPI) {}

  private loadSettings() {
    return this.settingsStore.getSettings();
  }

  private setStatus(ctx: ExtensionContext) {
    if (!ctx.hasUI) return;

    const settings = this.loadSettings();

    if (this.isJjRepo) {
      const status = settings.silentCheckpoints
        ? "pi-jj: ready"
        : `pi-jj: ${this.checkpoints.size} checkpoints`;
      ctx.ui.setStatus(STATUS_KEY, status);
      return;
    }

    if (!this.isGitRepo) {
      ctx.ui.setStatus(STATUS_KEY, "pi-jj: not a git repo");
      return;
    }

    if (!settings.promptForInit) {
      ctx.ui.setStatus(STATUS_KEY, "pi-jj: git repo (init prompt disabled, run /jj-init)");
      return;
    }

    ctx.ui.setStatus(STATUS_KEY, "pi-jj: not initialized (run /jj-init)");
  }

  private clearState() {
    this.checkpoints.clear();
    this.isGitRepo = false;
    this.pendingCheckpoint = null;
    this.resumeCheckpointOperationId = null;
    this.lastRestoreOperationId = null;
    this.needsInitPrompt = false;
    this.initPromptShown = false;
    this.initInProgress = false;
    this.settingsStore.clearCache();
  }

  private async execJj(args: string[]) {
    const result = await this.pi.exec("jj", args);
    if (result.code !== 0) {
      throw new Error(result.stderr?.trim() || `jj ${args.join(" ")} failed`);
    }
    return result;
  }

  private async detectJjRepo(): Promise<boolean> {
    const result = await this.pi.exec("jj", ["root"]);
    return result.code === 0;
  }

  private async detectGitRepo(): Promise<boolean> {
    const result = await this.pi.exec("git", ["rev-parse", "--is-inside-work-tree"]);
    return result.code === 0 && result.stdout.trim() === "true";
  }

  private async gitRepoRoot(): Promise<string | null> {
    const result = await this.pi.exec("git", ["rev-parse", "--show-toplevel"]);
    if (result.code !== 0) return null;
    return result.stdout.trim() || null;
  }

  private async getJjConfig(key: string): Promise<string | null> {
    const result = await this.pi.exec("jj", ["config", "list", key]);
    if (result.code !== 0) return null;
    const line = result.stdout.trim();
    if (!line) return null;
    const eqIdx = line.indexOf("=");
    if (eqIdx < 0) return null;
    return line.slice(eqIdx + 1).trim().replace(/^"|"$/g, "");
  }

  private async getGitConfig(key: string): Promise<string | null> {
    const result = await this.pi.exec("git", ["config", "--get", key]);
    if (result.code !== 0) return null;
    return result.stdout.trim() || null;
  }

  private async ensureJjUserConfig(ctx: ExtensionContext): Promise<void> {
    const jjName = await this.getJjConfig("user.name");
    const jjEmail = await this.getJjConfig("user.email");
    if (jjName && jjEmail) return;

    const gitName = await this.getGitConfig("user.name");
    const gitEmail = await this.getGitConfig("user.email");

    const missingFields: string[] = [];
    if (!jjName) missingFields.push("user.name");
    if (!jjEmail) missingFields.push("user.email");

    if (!ctx.hasUI) return;

    const defaultName = gitName || "";
    const defaultEmail = gitEmail || "";
    const defaults = [
      !jjName && defaultName ? `name: ${defaultName}` : null,
      !jjEmail && defaultEmail ? `email: ${defaultEmail}` : null,
    ]
      .filter(Boolean)
      .join(", ");

    const prompt = `jj ${missingFields.join(" and ")} not set.${defaults ? ` Use git defaults (${defaults})?` : ""}`;
    const choice = await ctx.ui.select(prompt, [
      ...(defaults ? [`Yes (use git: ${defaults})`] : []),
      "Skip (jj will warn on commit)",
    ]);

    if (!choice?.startsWith("Yes")) return;

    if (!jjName && defaultName) {
      await this.pi.exec("jj", ["config", "set", "--repo", "user.name", defaultName]);
    }
    if (!jjEmail && defaultEmail) {
      await this.pi.exec("jj", ["config", "set", "--repo", "user.email", defaultEmail]);
    }

    ctx.ui.notify("jj user config set from git defaults", "info");
  }

  private async initJjInGitRepo(ctx: ExtensionContext): Promise<boolean> {
    const root = await this.gitRepoRoot();
    if (!root) {
      if (ctx.hasUI) ctx.ui.notify("Could not determine git repo root", "error");
      return false;
    }

    const result = await this.pi.exec("jj", ["git", "init", "--colocate", root]);
    if (result.code !== 0) {
      if (ctx.hasUI) {
        const msg = result.stderr?.trim() || "jj git init failed";
        ctx.ui.notify(`Failed to initialize jj: ${msg}`, "error");
      }
      return false;
    }

    this.isGitRepo = true;
    this.isJjRepo = await this.detectJjRepo();
    if (this.isJjRepo) {
      await this.ensureJjUserConfig(ctx);
      await this.promptRestoreMode(ctx);
      if (ctx.hasUI) {
        ctx.ui.notify("Initialized jj repo (colocated with git)", "info");
      }
    }
    return this.isJjRepo;
  }

  private async promptRestoreMode(ctx: ExtensionContext): Promise<void> {
    if (!ctx.hasUI) return;

    const settings = this.loadSettings();
    const choice = await ctx.ui.select(
      "Checkpoint restore mode?",
      [
        "File restore (safer — restores file contents only via jj restore)",
        "Operation restore (full — restores entire repo state via jj op restore)",
      ],
    );

    if (!choice) return;

    const chosen = choice.startsWith("Operation") ? "operation" : "file";
    if (chosen === settings.restoreMode) return;

    this.settingsStore.updateSetting("restoreMode", chosen);
  }

  private async listJjRefs(): Promise<string[]> {
    const result = await this.pi.exec("git", ["for-each-ref", "--format=%(refname)", "refs/jj/"]);
    if (result.code !== 0) return [];

    return result.stdout
      .split("\n")
      .map((line) => line.trim())
      .filter(Boolean);
  }

  private async deinitJjRepo(ctx: ExtensionContext, removeRefs: boolean): Promise<boolean> {
    const root = await this.gitRepoRoot();
    if (!root) {
      if (ctx.hasUI) ctx.ui.notify("Could not determine git repo root", "error");
      return false;
    }

    const jjDir = join(root, ".jj");
    await rm(jjDir, { recursive: true, force: true });

    let removedRefs = 0;
    if (removeRefs) {
      const refs = await this.listJjRefs();
      for (const ref of refs) {
        await this.pi.exec("git", ["update-ref", "-d", ref]);
        removedRefs++;
      }
    }

    this.clearState();
    this.isGitRepo = true;
    this.isJjRepo = false;
    this.setStatus(ctx);

    if (ctx.hasUI) {
      if (removeRefs) {
        ctx.ui.notify(`jj deinitialized (removed .jj and ${removedRefs} refs/jj/* refs)`, "info");
      } else {
        ctx.ui.notify("jj deinitialized (removed .jj, kept refs/jj/*)", "info");
      }
    }

    return true;
  }

  private async ensureJjRepo(): Promise<boolean> {
    if (this.isJjRepo) {
      this.isGitRepo = true;
      return true;
    }
    this.isJjRepo = await this.detectJjRepo();
    if (this.isJjRepo) this.isGitRepo = true;
    return this.isJjRepo;
  }

  private async currentRevision(options?: { ignoreWorkingCopy?: boolean }): Promise<string> {
    const args = [
      ...(options?.ignoreWorkingCopy ? ["--ignore-working-copy"] : []),
      "log",
      "-r",
      "@",
      "--no-graph",
      "-T",
      "commit_id",
    ];
    const result = await this.execJj(args);
    const revision = result.stdout.trim().split("\n").pop()?.trim();
    if (!revision) throw new Error("Could not determine current jj revision");
    return revision;
  }

  private async currentChangeInfo(options?: { ignoreWorkingCopy?: boolean }): Promise<{ id: string; short: string }> {
    const args = [
      ...(options?.ignoreWorkingCopy ? ["--ignore-working-copy"] : []),
      "log",
      "-r",
      "@",
      "--no-graph",
      "-T",
      "change_id ++ \"\\n\" ++ change_id.short()",
    ];
    const result = await this.execJj(args);
    const lines = result.stdout
      .split("\n")
      .map((line) => line.trim())
      .filter(Boolean);

    const id = lines[0];
    const short = lines[1] ?? (id ? id.slice(0, 12) : undefined);
    if (!id || !short) throw new Error("Could not determine current jj change id");
    return { id, short };
  }

  private async currentOperationInfo(options?: { ignoreWorkingCopy?: boolean }): Promise<{ id: string; short: string }> {
    const args = [
      ...(options?.ignoreWorkingCopy ? ["--ignore-working-copy"] : []),
      "op",
      "log",
      "-n",
      "1",
      "--no-graph",
      "-T",
      "id ++ \"\\n\" ++ id.short()",
    ];
    const result = await this.execJj(args);
    const lines = result.stdout
      .split("\n")
      .map((line) => line.trim())
      .filter(Boolean);

    const id = lines[0];
    const short = lines[1] ?? (id ? id.slice(0, 12) : undefined);
    if (!id || !short) throw new Error("Could not determine current jj operation id");
    return { id, short };
  }

  private async restoreToOperation(operationId: string) {
    await this.execJj(["op", "restore", operationId]);
    await this.pi.exec("jj", ["git", "fetch", "--all-remotes"]);
  }

  private async restoreFilesFromRevision(revision: string) {
    await this.execJj(["restore", "--from", revision]);
  }

  private findLatestUserEntry(sessionManager: any): { id: string } | null {
    const leafId = sessionManager.getLeafId?.();
    if (!leafId) return null;

    const branch = sessionManager.getBranch?.(leafId) ?? [];
    for (let i = branch.length - 1; i >= 0; i--) {
      const entry = branch[i];
      if (entry?.type === "message" && entry.message?.role === "user") {
        return { id: entry.id };
      }
    }

    return null;
  }

  private rebuildCheckpointsFromSession(ctx: ExtensionContext) {
    this.checkpoints.clear();

    const entries = ctx.sessionManager.getEntries();
    for (const entry of entries) {
      if (entry.type !== "custom") continue;
      if (entry.customType !== CHECKPOINT_ENTRY_TYPE) continue;

      const data = entry.data as Partial<Checkpoint> & { sessionId?: string };
      if (!data?.entryId || !data?.revision || !data?.timestamp) continue;
      if (this.sessionId && data.sessionId && data.sessionId !== this.sessionId) continue;

      const existing = this.checkpoints.get(data.entryId);
      if (!existing || existing.timestamp < data.timestamp) {
        this.checkpoints.set(data.entryId, {
          entryId: data.entryId,
          revision: data.revision,
          timestamp: data.timestamp,
          changeId: data.changeId,
          changeIdShort: data.changeIdShort,
          operationId: data.operationId,
          operationIdShort: data.operationIdShort,
          postOperationId: data.postOperationId,
          postOperationIdShort: data.postOperationIdShort,
        });
      }
    }

    this.pruneCheckpoints();
  }

  private pruneCheckpoints() {
    const maxCheckpoints = this.loadSettings().maxCheckpoints;
    if (this.checkpoints.size <= maxCheckpoints) return;

    const ordered = [...this.checkpoints.values()].sort((a, b) => a.timestamp - b.timestamp);
    const toRemove = ordered.slice(0, ordered.length - maxCheckpoints);
    for (const checkpoint of toRemove) {
      this.checkpoints.delete(checkpoint.entryId);
    }
  }

  private resolveCheckpointRevision(targetId: string, ctx: ExtensionContext): string | null {
    const direct = this.checkpoints.get(targetId)?.revision;
    if (direct) return direct;

    const pathToTarget = ctx.sessionManager.getBranch?.(targetId) ?? [];
    for (let i = pathToTarget.length - 1; i >= 0; i--) {
      const checkpoint = this.checkpoints.get(pathToTarget[i]?.id);
      if (checkpoint?.revision) return checkpoint.revision;
    }

    return null;
  }

  private resolveCheckpointOperationId(targetId: string, ctx: ExtensionContext): string | null {
    const directCheckpoint = this.checkpoints.get(targetId);
    if (directCheckpoint?.operationId) return directCheckpoint.operationId;

    const pathToTarget = ctx.sessionManager.getBranch?.(targetId) ?? [];
    for (let i = pathToTarget.length - 1; i >= 0; i--) {
      const checkpoint = this.checkpoints.get(pathToTarget[i]?.id);
      if (!checkpoint) continue;
      return checkpoint.postOperationId ?? checkpoint.operationId ?? null;
    }

    return this.resumeCheckpointOperationId;
  }

  private resolveRestoreTarget(targetId: string, ctx: ExtensionContext): { mode: "file"; revision: string } | { mode: "operation"; operationId: string } | null {
    const settings = this.loadSettings();
    if (settings.restoreMode === "operation") {
      const opId = this.resolveCheckpointOperationId(targetId, ctx);
      if (opId) return { mode: "operation", operationId: opId };
      return null;
    }
    const rev = this.resolveCheckpointRevision(targetId, ctx);
    if (rev) return { mode: "file", revision: rev };
    return null;
  }

  private getOrderedCheckpoints(): Checkpoint[] {
    return [...this.checkpoints.values()].sort((a, b) => b.timestamp - a.timestamp);
  }

  private maybeLabelEntry(ctx: ExtensionContext, entryId: string, checkpoint: Checkpoint) {
    const label = `jj:${checkpoint.changeIdShort ?? checkpoint.revision.slice(0, 8)}`;

    const existing = ctx.sessionManager.getLabel?.(entryId);
    if (existing && !existing.startsWith("jj:")) return;

    this.pi.setLabel(entryId, label);
  }

  private async showCheckpointUi(ctx: ExtensionContext): Promise<void> {
    const ordered = this.getOrderedCheckpoints();
    if (ordered.length === 0) {
      ctx.ui.notify("No jj checkpoints yet", "info");
      return;
    }

    const settings = this.loadSettings();
    const visible = ordered.slice(0, settings.checkpointListLimit);
    const labels = visible.map(checkpointLine);

    const selected = await ctx.ui.select(`jj checkpoints (${ordered.length})`, labels);
    if (!selected) return;

    const index = labels.indexOf(selected);
    if (index < 0) return;
    const checkpoint = visible[index];

    const action = await ctx.ui.select("Checkpoint action", [
      "Restore files now",
      "Copy revision to editor",
      "Show details",
      "Cancel",
    ]);

    if (!action || action === "Cancel") return;

    if (action === "Restore files now") {
      if (!(await this.ensureJjRepo())) {
        ctx.ui.notify("Not a jj repo", "warning");
        return;
      }

      const settings = this.loadSettings();
      let target: { mode: "file"; revision: string } | { mode: "operation"; operationId: string };
      if (settings.restoreMode === "operation") {
        if (!checkpoint.operationId) {
          ctx.ui.notify("Checkpoint has no operation ID (created before op tracking)", "warning");
          return;
        }
        target = { mode: "operation", operationId: checkpoint.operationId };
      } else {
        target = { mode: "file", revision: checkpoint.revision };
      }

      const success = await this.restoreWithUndo(target, ctx);
      if (success) {
        const label = target.mode === "operation"
          ? `op ${checkpoint.operationIdShort ?? checkpoint.operationId!.slice(0, 12)}`
          : `rev ${checkpoint.revision.slice(0, 12)}`;
        ctx.ui.notify(`Restored from checkpoint (${label})`, "info");
      }
      return;
    }

    if (action === "Copy revision to editor") {
      ctx.ui.setEditorText(checkpoint.revision);
      ctx.ui.notify("Revision copied to editor", "info");
      return;
    }

    const details = [
      `entry: ${checkpoint.entryId}`,
      `revision: ${checkpoint.revision}`,
      `change: ${checkpoint.changeId ?? "-"}`,
      `changeShort: ${checkpoint.changeIdShort ?? "-"}`,
      `pre-turn op: ${checkpoint.operationId ?? "-"} (${checkpoint.operationIdShort ?? "-"})`,
      `post-turn op: ${checkpoint.postOperationId ?? "-"} (${checkpoint.postOperationIdShort ?? "-"})`,
      `timestamp: ${new Date(checkpoint.timestamp).toISOString()}`,
      `age: ${formatAge(checkpoint.timestamp)}`,
    ].join("\n");

    ctx.ui.notify(details, "info");
  }

  private async restoreWithUndo(target: { mode: "file"; revision: string } | { mode: "operation"; operationId: string }, ctx: ExtensionContext): Promise<boolean> {
    try {
      const beforeOp = await this.currentOperationInfo();
      if (target.mode === "operation") {
        await this.restoreToOperation(target.operationId);
      } else {
        await this.restoreFilesFromRevision(target.revision);
      }
      this.lastRestoreOperationId = beforeOp.id;
      return true;
    } catch (error) {
      ctx.ui.notify(`Failed to restore: ${String(error)}`, "error");
      return false;
    }
  }

  async handleSessionStart(ctx: ExtensionContext) {
    await this.initialize(ctx);
  }

  async handleSessionSwitch(ctx: ExtensionContext) {
    await this.initialize(ctx);
  }

  async handleBeforeAgentStart(ctx: ExtensionContext) {
    if (!ctx.hasUI) return;
    if (this.isJjRepo) return;
    if (!this.needsInitPrompt) return;
    if (this.initPromptShown || this.initInProgress) return;

    this.initPromptShown = true;
    const choice = await ctx.ui.select("Initialize this git repo for jj?", [
      "Yes (jj git init --colocate)",
      "Not now",
    ]);

    if (!choice?.startsWith("Yes")) return;

    this.initInProgress = true;
    try {
      const ok = await this.initJjInGitRepo(ctx);
      if (!ok) {
        this.setStatus(ctx);
        return;
      }

      this.rebuildCheckpointsFromSession(ctx);
      try {
        const op = await this.currentOperationInfo();
        this.resumeCheckpointOperationId = op.id;
      } catch {
        this.resumeCheckpointOperationId = null;
      }

      this.needsInitPrompt = false;
      this.setStatus(ctx);
    } finally {
      this.initInProgress = false;
    }
  }

  async handleTurnStart(event: TurnEventLike) {
    if (!(await this.ensureJjRepo())) return;
    if (event.turnIndex !== 0) return;

    try {
      const revision = await this.currentRevision();
      const change = await this.currentChangeInfo();
      const operation = await this.currentOperationInfo();

      this.pendingCheckpoint = {
        revision,
        timestamp: event.timestamp,
        changeId: change.id,
        changeIdShort: change.short,
        operationId: operation.id,
        operationIdShort: operation.short,
      };
    } catch {
      this.pendingCheckpoint = null;
    }
  }

  async handleTurnEnd(event: TurnEndEventLike, ctx: ExtensionContext) {
    if (!(await this.ensureJjRepo())) return;
    if (event.turnIndex !== 0) return;
    if (!this.pendingCheckpoint) return;

    const userEntry = this.findLatestUserEntry(ctx.sessionManager);
    if (!userEntry) {
      this.pendingCheckpoint = null;
      return;
    }

    let postOpId: string | undefined;
    let postOpShort: string | undefined;
    try {
      const postOp = await this.currentOperationInfo();
      postOpId = postOp.id;
      postOpShort = postOp.short;
    } catch {
      // pre-turn op will be used as fallback
    }

    const checkpoint: Checkpoint = {
      entryId: userEntry.id,
      revision: this.pendingCheckpoint.revision,
      timestamp: this.pendingCheckpoint.timestamp,
      changeId: this.pendingCheckpoint.changeId,
      changeIdShort: this.pendingCheckpoint.changeIdShort,
      operationId: this.pendingCheckpoint.operationId,
      operationIdShort: this.pendingCheckpoint.operationIdShort,
      postOperationId: postOpId,
      postOperationIdShort: postOpShort,
    };

    this.checkpoints.set(userEntry.id, checkpoint);
    this.pruneCheckpoints();

    this.pi.appendEntry(CHECKPOINT_ENTRY_TYPE, {
      ...checkpoint,
      sessionId: this.sessionId,
    });

    this.maybeLabelEntry(ctx, userEntry.id, checkpoint);

    this.pendingCheckpoint = null;
    this.setStatus(ctx);

    if (ctx.hasUI && !this.loadSettings().silentCheckpoints) {
      ctx.ui.notify(`jj checkpoint saved (${this.checkpoints.size})`, "info");
    }
  }

  async handleSessionBeforeFork(event: ForkEventLike, ctx: ExtensionContext) {
    if (!ctx.hasUI) return;
    if (!(await this.ensureJjRepo())) return;

    const restoreTarget = this.resolveRestoreTarget(event.entryId, ctx);
    const options = ["Conversation only (keep current files)"];

    if (restoreTarget) {
      options.push("Restore + conversation");
      options.push("Restore only (keep conversation)");
    }

    if (this.lastRestoreOperationId) {
      options.push("Undo last rewind");
    }

    const choice = await ctx.ui.select("jj rewind options", options);
    if (!choice) return { cancel: true };

    if (choice.startsWith("Conversation only")) {
      return;
    }

    if (choice === "Undo last rewind") {
      const undoOpId = this.lastRestoreOperationId;
      if (!undoOpId) return { cancel: true };

      const success = await this.restoreWithUndo({ mode: "operation", operationId: undoOpId }, ctx);
      if (success) {
        ctx.ui.notify("Rewind undone", "info");
      }
      return { cancel: true };
    }

    if (!restoreTarget) {
      ctx.ui.notify("No jj checkpoint found for that point", "warning");
      return { cancel: true };
    }

    const success = await this.restoreWithUndo(restoreTarget, ctx);
    if (!success) {
      return { cancel: true };
    }

    ctx.ui.notify("Restored to checkpoint", "info");

    if (choice === "Restore only (keep conversation)") {
      return { skipConversationRestore: true };
    }
  }

  async handleSessionBeforeTree(event: TreeEventLike, ctx: ExtensionContext) {
    if (!ctx.hasUI) return;
    if (!(await this.ensureJjRepo())) return;

    const targetId = event.preparation.targetId;
    const restoreTarget = this.resolveRestoreTarget(targetId, ctx);

    const options = ["Keep current files"];
    if (restoreTarget) options.push("Restore to selected point");
    if (this.lastRestoreOperationId) options.push("Undo last rewind");
    options.push("Cancel navigation");

    const choice = await ctx.ui.select("jj rewind options", options);
    if (!choice || choice === "Cancel navigation") {
      return { cancel: true };
    }

    if (choice === "Keep current files") {
      return;
    }

    if (choice === "Undo last rewind") {
      const undoOpId = this.lastRestoreOperationId;
      if (!undoOpId) return { cancel: true };

      const success = await this.restoreWithUndo({ mode: "operation", operationId: undoOpId }, ctx);
      if (success) {
        ctx.ui.notify("Rewind undone", "info");
      }
      return { cancel: true };
    }

    if (!restoreTarget) {
      ctx.ui.notify("No jj checkpoint found for that point", "warning");
      return { cancel: true };
    }

    const success = await this.restoreWithUndo(restoreTarget, ctx);
    if (!success) {
      return { cancel: true };
    }

    ctx.ui.notify("Restored to checkpoint", "info");
  }

  async commandJjInit(_args: string, ctx: ExtensionContext) {
    if (await this.ensureJjRepo()) {
      ctx.ui.notify("This repo is already initialized for jj", "info");
      this.setStatus(ctx);
      return;
    }

    const isGit = await this.detectGitRepo();
    this.isGitRepo = isGit;
    if (!isGit) {
      ctx.ui.notify("Current directory is not a git repo", "warning");
      return;
    }

    const ok = await this.initJjInGitRepo(ctx);
    if (!ok) return;

    this.needsInitPrompt = false;
    this.rebuildCheckpointsFromSession(ctx);
    try {
      const op = await this.currentOperationInfo();
      this.resumeCheckpointOperationId = op.id;
    } catch {
      this.resumeCheckpointOperationId = null;
    }

    this.setStatus(ctx);
  }

  async commandJjDeinit(args: string, ctx: ExtensionContext) {
    const isGit = await this.detectGitRepo();
    this.isGitRepo = isGit;
    if (!isGit) {
      ctx.ui.notify("Current directory is not a git repo", "warning");
      return;
    }

    const hasJj = await this.ensureJjRepo();
    if (!hasJj) {
      ctx.ui.notify("This repo is not initialized for jj", "info");
      this.setStatus(ctx);
      return;
    }

    let removeRefs = (args ?? "").trim().toLowerCase() === "full";

    if (!removeRefs && ctx.hasUI) {
      const choice = await ctx.ui.select("Deinitialize jj for this repo?", [
        "Remove .jj only (keep refs/jj/*)",
        "Full cleanup (.jj + refs/jj/*)",
        "Cancel",
      ]);

      if (!choice || choice === "Cancel") {
        ctx.ui.notify("jj deinit cancelled", "info");
        return;
      }

      removeRefs = choice.startsWith("Full cleanup");
    }

    if (ctx.hasUI) {
      const confirmed = await ctx.ui.confirm(
        "Confirm jj deinit",
        removeRefs
          ? "This will remove .jj and delete refs/jj/* in this git repo. Continue?"
          : "This will remove .jj in this git repo. Continue?",
      );

      if (!confirmed) {
        ctx.ui.notify("jj deinit cancelled", "info");
        return;
      }
    }

    await this.deinitJjRepo(ctx, removeRefs);
  }

  async commandJjCheckpoints(args: string, ctx: ExtensionContext) {
    const mode = (args ?? "").trim().toLowerCase();
    const ordered = this.getOrderedCheckpoints();
    if (ordered.length === 0) {
      ctx.ui.notify("No jj checkpoints yet", "info");
      return;
    }

    const settings = this.loadSettings();
    const visible = ordered.slice(0, settings.checkpointListLimit);

    if (mode === "plain" || !ctx.hasUI) {
      const lines = visible.map((checkpoint) => checkpointLine(checkpoint));
      ctx.ui.notify(`jj checkpoints (${ordered.length})\n${lines.join("\n")}`, "info");
      return;
    }

    await this.showCheckpointUi(ctx);
  }

  private settingsSummary(settings: PiJjSettings): string {
    return (
      `piJj settings\n` +
      `silentCheckpoints: ${settings.silentCheckpoints}\n` +
      `maxCheckpoints: ${settings.maxCheckpoints}\n` +
      `checkpointListLimit: ${settings.checkpointListLimit}\n` +
      `promptForInit: ${settings.promptForInit}\n` +
      `restoreMode: ${settings.restoreMode}\n` +
      `file: ${this.settingsStore.settingsFile}`
    );
  }

  private applySetting<K extends keyof PiJjSettings>(key: K, value: PiJjSettings[K], ctx: ExtensionContext) {
    this.settingsStore.updateSetting(key, value);
    const updated = this.loadSettings();

    if (!this.isJjRepo) {
      this.needsInitPrompt = updated.promptForInit && this.isGitRepo;
    }

    this.setStatus(ctx);
  }

  private clampSetting(value: number, min: number, max: number): number {
    return Math.max(min, Math.min(max, value));
  }

  private async adjustNumericSetting(
    key: "maxCheckpoints" | "checkpointListLimit",
    label: string,
    min: number,
    max: number,
    defaultValue: number,
    smallStep: number,
    largeStep: number,
    ctx: ExtensionContext,
  ) {
    const current = this.loadSettings()[key];
    const increaseSmall = this.clampSetting(current + smallStep, min, max);
    const decreaseSmall = this.clampSetting(current - smallStep, min, max);
    const increaseLarge = this.clampSetting(current + largeStep, min, max);
    const decreaseLarge = this.clampSetting(current - largeStep, min, max);

    const increaseSmallOption = `Increase by ${smallStep} → ${increaseSmall}`;
    const decreaseSmallOption = `Decrease by ${smallStep} → ${decreaseSmall}`;
    const increaseLargeOption = `Increase by ${largeStep} → ${increaseLarge}`;
    const decreaseLargeOption = `Decrease by ${largeStep} → ${decreaseLarge}`;
    const setDefaultOption = `Set default (${defaultValue})`;
    const setMinOption = `Set minimum (${min})`;
    const setMaxOption = `Set maximum (${max})`;
    const cancelOption = "Cancel";

    const choice = await ctx.ui.select(`Adjust ${label} (current ${current}, range ${min}..${max})`, [
      increaseSmallOption,
      decreaseSmallOption,
      increaseLargeOption,
      decreaseLargeOption,
      setDefaultOption,
      setMinOption,
      setMaxOption,
      cancelOption,
    ]);

    if (!choice || choice === cancelOption) return;

    let next = current;
    if (choice === increaseSmallOption) next = increaseSmall;
    if (choice === decreaseSmallOption) next = decreaseSmall;
    if (choice === increaseLargeOption) next = increaseLarge;
    if (choice === decreaseLargeOption) next = decreaseLarge;
    if (choice === setDefaultOption) next = defaultValue;
    if (choice === setMinOption) next = min;
    if (choice === setMaxOption) next = max;

    if (next === current) return;

    this.applySetting(key, next, ctx);
    ctx.ui.notify(`Updated ${key}: ${current} → ${next}`, "info");
  }

  private async openSettingsTui(ctx: ExtensionContext) {
    if (!ctx.hasUI) return;

    while (true) {
      const settings = this.loadSettings();

      const toggleSilent = `Toggle silentCheckpoints (currently ${settings.silentCheckpoints})`;
      const adjustMax = `Adjust maxCheckpoints (currently ${settings.maxCheckpoints})`;
      const adjustList = `Adjust checkpointListLimit (currently ${settings.checkpointListLimit})`;
      const togglePromptInit = `Toggle promptForInit (currently ${settings.promptForInit})`;
      const switchRestore = `Switch restoreMode (currently ${settings.restoreMode})`;
      const reloadOption = "Reload settings from file";
      const showSummaryOption = "Show current settings summary";
      const doneOption = "Done";

      const choice = await ctx.ui.select("pi-jj settings", [
        toggleSilent,
        adjustMax,
        adjustList,
        togglePromptInit,
        switchRestore,
        reloadOption,
        showSummaryOption,
        doneOption,
      ]);

      if (!choice || choice === doneOption) return;

      if (choice === toggleSilent) {
        this.applySetting("silentCheckpoints", !settings.silentCheckpoints, ctx);
        ctx.ui.notify(`Updated silentCheckpoints: ${!settings.silentCheckpoints}`, "info");
        continue;
      }

      if (choice === adjustMax) {
        await this.adjustNumericSetting("maxCheckpoints", "maxCheckpoints", 10, 5000, DEFAULT_MAX_CHECKPOINTS, 25, 100, ctx);
        continue;
      }

      if (choice === adjustList) {
        await this.adjustNumericSetting(
          "checkpointListLimit",
          "checkpointListLimit",
          5,
          200,
          DEFAULT_CHECKPOINT_LIST_LIMIT,
          5,
          25,
          ctx,
        );
        continue;
      }

      if (choice === togglePromptInit) {
        this.applySetting("promptForInit", !settings.promptForInit, ctx);
        ctx.ui.notify(`Updated promptForInit: ${!settings.promptForInit}`, "info");
        continue;
      }

      if (choice === switchRestore) {
        const modeChoice = await ctx.ui.select("Select restore mode", [
          "file (restore file contents only via jj restore)",
          "operation (restore full repo state via jj op restore)",
          "Cancel",
        ]);

        if (!modeChoice || modeChoice === "Cancel") continue;

        const next = modeChoice.startsWith("operation") ? "operation" : "file";
        if (next !== settings.restoreMode) {
          this.applySetting("restoreMode", next, ctx);
          ctx.ui.notify(`Updated restoreMode: ${next}`, "info");
        }
        continue;
      }

      if (choice === reloadOption) {
        this.settingsStore.clearCache();
        const reloaded = this.loadSettings();

        if (!this.isJjRepo) {
          this.needsInitPrompt = reloaded.promptForInit && (await this.detectGitRepo());
        }

        this.setStatus(ctx);
        ctx.ui.notify(
          `Reloaded piJj settings: silent=${reloaded.silentCheckpoints}, max=${reloaded.maxCheckpoints}, list=${reloaded.checkpointListLimit}, promptInit=${reloaded.promptForInit}, restore=${reloaded.restoreMode}`,
          "info",
        );
        continue;
      }

      if (choice === showSummaryOption) {
        ctx.ui.notify(this.settingsSummary(this.loadSettings()), "info");
      }
    }
  }

  async commandJjSettings(args: string, ctx: ExtensionContext) {
    const mode = (args ?? "").trim().toLowerCase();
    if (mode === "reload") {
      this.settingsStore.clearCache();
      const reloaded = this.loadSettings();

      if (!this.isJjRepo) {
        this.needsInitPrompt = reloaded.promptForInit && (await this.detectGitRepo());
      }

      this.setStatus(ctx);
      ctx.ui.notify(
        `Reloaded piJj settings: silent=${reloaded.silentCheckpoints}, max=${reloaded.maxCheckpoints}, list=${reloaded.checkpointListLimit}, promptInit=${reloaded.promptForInit}, restore=${reloaded.restoreMode}`,
        "info",
      );
      return;
    }

    if ((mode === "" || mode === "tui" || mode === "edit") && ctx.hasUI) {
      await this.openSettingsTui(ctx);
      return;
    }

    const settings = this.loadSettings();
    ctx.ui.notify(this.settingsSummary(settings), "info");
  }

  private async initialize(ctx: ExtensionContext) {
    this.clearState();
    this.sessionId = ctx.sessionManager.getSessionId();

    this.isJjRepo = await this.detectJjRepo();
    if (!this.isJjRepo) {
      this.isGitRepo = await this.detectGitRepo();
      const settings = this.loadSettings();
      this.needsInitPrompt = settings.promptForInit && this.isGitRepo;
      this.setStatus(ctx);
      return;
    }

    this.isGitRepo = true;

    this.rebuildCheckpointsFromSession(ctx);

    try {
      const op = await this.currentOperationInfo();
      this.resumeCheckpointOperationId = op.id;
    } catch {
      this.resumeCheckpointOperationId = null;
    }

    this.setStatus(ctx);
  }
}
