# pi-jj

Pi extension for **Jujutsu**: automatic checkpoints with rewind, plus guided `jj` onboarding.

> 取自上游 `manojlds/pi-jj` v0.3.0，只保留 Checkpoints 与 Onboarding 两部分；
> 上游的 Stacked PR 流程（`/jj-stack-*`、`/jj-pr-*`、`jj_stack_pr_flow` 工具与
> `jj-stacked-pr` 技能）已移除。

## Features

- **Checkpoints**: automatic `jj` snapshots on every agent turn, with rewind support
- **Onboarding**: guided `jj git init --colocate`, user config copied from git, restore-mode selection

## Install

Managed by this repository: `programs/dev/pi/extensions/pi-jj` is linked into
`~/.pi/agent/extensions/pi-jj`, so it loads on pi start. Run `/reload` after a
rebuild instead of reinstalling.

## Onboarding

On the first prompt in a git repo that isn't yet a `jj` repo, the extension offers to initialize:

1. `jj git init --colocate` to set up `jj` alongside git
2. Checks `user.name` / `user.email` — if missing, offers to copy them from git config (`jj config set --repo`)
3. Prompts for restore mode preference (`file` or `operation`)

You can also run `/jj-init` manually. `/jj-deinit` removes `jj` metadata (`/jj-deinit full` also cleans `refs/jj/*`).

## Checkpoint system

**Capture**: on the first agent turn per prompt, the extension snapshots:

- `commit_id` (revision) — the exact file state
- `change_id` — stable identity across rewrites
- `operation_id` (pre-turn) — `jj` operation before the agent ran
- `operation_id` (post-turn) — `jj` operation after the agent finished

These are persisted as `jj-checkpoint` session custom entries and the user's chat entry is labeled `jj:<change-short>` for `/tree` navigation.

**Restore** (via `/fork`, `/tree`, or `/jj-checkpoints`): two modes, configurable via the `restoreMode` setting:

| Mode | Command | What it restores | Trade-offs |
|------|---------|-----------------|------------|
| `file` (default) | `jj restore --from <revision>` | File contents only | Safe, no side effects on bookmarks or op history |
| `operation` | `jj op restore <operationId>` + `jj git fetch --all-remotes` | Full repo state (working copy, bookmarks, visible heads) | More complete but rewinds operation history; auto-fetches to resync remotes |

When navigating to a **user message** in `/tree`, the pre-turn operation ID is used (state before the agent ran). When navigating to an **agent message**, the post-turn operation ID is used (state after the agent finished).

Undo always uses `jj op restore` back to the pre-restore operation, regardless of mode.

**Commands**:

- `/jj-checkpoints` — interactive picker with restore/copy/details actions
- `/jj-checkpoints plain` — text list

## Settings

Add a `piJj` object to `~/.pi/agent/settings.json`:

```json
{
  "piJj": {
    "silentCheckpoints": false,
    "maxCheckpoints": 200,
    "checkpointListLimit": 30,
    "promptForInit": true,
    "restoreMode": "file"
  }
}
```

`/jj-settings` opens a picker for the same values; `/jj-settings plain` prints them and `/jj-settings reload` re-reads the file.

## License

MIT — see [LICENSE](./LICENSE).
