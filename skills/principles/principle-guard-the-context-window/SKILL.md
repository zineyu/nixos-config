---
name: principle-guard-the-context-window
description: "Apply when context is filling up: large outputs, long files, repeated reads, fan-out planning. Route bulk to subagents; keep summaries in the main thread, not raw payloads."
disable-model-invocation: true
---

# Guard the Context Window

**Why:** Context overflow degrades reasoning quality, creates compression artifacts, and halts progress. The window is a budget you spend, not a limit you discover.

**Pattern:**

- **Size phases and cap scope.** Limit files per phase, set turn budgets, account for mechanism costs. A phase that needs the whole repository is several phases.
- **Route bulk to a subagent.** Long files, wide searches, build logs, and fan-out reading belong in a subagent. It reads the payload and returns a summary: the answer, the `file:line` that supports it, and what it could not read.
- **Keep summaries in the main thread.** The main thread holds the decision, the summary, and the pointer to the full material. Never paste a raw payload, a full log, or a whole file back into it.
- **Read the part you need.** Search first, then open the match by line range. A file read end to end is a decision to spend the window on that file.
- **Hand over before the window fills.** When the thread is past a third full and the next step is a different task, write the durable facts to a note or a handoff and start the next task clean.

You skipped this when a raw payload sits in the main thread, when a phase had no file or turn budget, or when the run continued past the point where you could still hold the whole task in view.
