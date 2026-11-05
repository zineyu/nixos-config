---
name: verification-skill
description: "Generate or re-sync the project-local skill that drives the app the way a user does, in any language, framework, or platform. Use for \"make a control skill for this repo\", \"audit the verify skill\", \"what did this break in the app\", or when a project has no scripted way to prove UI/CLI/service behavior, and again when that skill has drifted from the code."
disable-model-invocation: true
---

# Verification skill

Every serious project needs a scripted way to drive the real app and prove behavior: launch it, exercise a feature the way a user would, and capture evidence. One project-local skill holds that: `<skills>/verify-<app>/`, where `<skills>` is the project's skill folder (`.agents/skills/` in pi and most harnesses, `.pi/skills/` when the repo uses that; if the repo already keeps skills somewhere else, use that). Write it for the next agent, not for a human: it will be read cold, mid-task, by an agent that has never seen the app.

This skill builds that artifact (`generate`) and brings it back in line with the code (`re-sync`).

| Mode | Entry | Output |
|---|---|---|
| **generate** | no verification skill exists, or the repo has no way to drive itself | a new `verify-<app>/` skill, proven end to end |
| **re-sync** | the skill exists but the app changed under it | one of `clean`, `changed` (one PR of proven corrections), `blocked` |

## Mode: generate

### 1. Interview the repo, not the user

Answer these from the codebase and only ask the user what you cannot observe:

- **Surface:** what does a user actually touch? A web UI, a CLI/TUI, a desktop app, an API, a mobile app, a library? A repo can have several; pick the primary one and note the rest.
- **Run:** how does the app start locally? Prefer the repo's own documented dev command (package scripts, Makefile, README quickstart). Note ports, env vars, seed data, auth.
- **Drive:** how can an agent interact with it programmatically? Existing harnesses first: Playwright/Cypress specs, expect scripts, PTY helpers, curl-able endpoints, a debug port. Only then pick a generic recipe: browser/CDP for web and Electron, a tmux/PTY harness for CLI/TUI, plain HTTP for services.
- **Observe:** what evidence can be captured? Screenshots, terminal transcripts, response bodies, logs, exit codes, DB state.
- **Isolate:** can two instances run side by side (ports, data dirs, profiles)? If not, say so in the generated skill: refusing to double-drive a shared instance beats corrupting the user's session.

If the checkout doesn't build or start as-is, fix that first (or report it precisely) before generating; a skill written against a broken base teaches wrong steps. When an irrelevant missing asset blocks startup (a static dir the API never serves, a sample config), the generated skill may create it, clearly marked as verification scaffolding, and remove it in cleanup.

### 2. Generate the skill

Write `<skills>/verify-<app>/SKILL.md` with YAML frontmatter (`name: verify-<app>` and a `description` that names the app, the surface, and when to reach for it, because without frontmatter the skill never registers) and these sections, each grounded in what the interview actually found (no placeholders left):

- **Launch:** the exact command that starts the app for verification, and how to tell it's ready (a log line, a prompt). Launch must reach a usable state from an empty data dir, including any migrations and seed data. Ready means usable, not just that a process answers; a database health check can pass while its init scripts are still running. Include teardown. For a short-lived CLI or TUI there is no server to keep alive: launch means build the binary (or install deps) once, then start each drive in its own isolated PTY or tmux session.
- **Doctor:** one read-only check that answers "is this instance worth driving?" Process up, right version and build, port owned by us, auth valid. An agent runs this first whenever anything looks off.
- **Drive:** the harness recipe with real selectors and commands from this repo, not examples. Prefer stable handles (ARIA labels, data attributes, prompt strings, route paths) over coordinates and tab order.
- **Evidence:** what to capture for a proof and where it goes. State the proof standards: exercise the real user path, not internal setters or test-only endpoints; capture the action and the resulting state, not just the final screen; verify side effects (files written, rows inserted, messages sent) alongside what's visible; mocks only where a production boundary already isolates the external system. When the safe path is a dry-run or test mode, verify what it actually skips by observing (files, network, git refs) rather than trusting its name: some dry-runs still touch the network or open a browser.
- **Cleanup:** how to tear down instances the run created. Never kill by process name; kill what you started. Cleanup removes instances and scratch state, never the evidence: proof artifacts survive teardown, in a location the skill names.
- **Helpers:** any script the skill ships is executable and its invocation is shown in the skill body. A helper the reader has to reverse-engineer is not a helper.

### 3. Seed the feature map

Create `<skills>/verify-<app>/features/README.md` plus one file per user-facing feature you can identify (aim for the top 3 to 5 to start, from routes, commands, menus, or docs). Follow the shape in [`references/feature-map-example/`](references/feature-map-example/), with a README index and one file per feature. Each file answers, from the user's point of view: what the feature is, how to reach it, how to drive it with the harness, and what observable end state proves it works. The four H2s are `Sub-features`, `How to get to it (user POV)`, `Driving it with <harness>`, and `Gotchas`. If the seed data lacks a precondition that a journey needs, the journey reports a failure and the reason goes in that feature's `Gotchas`. Never weaken the journey to make it pass. The map is the repo's maintained verification source; a proof that drives one convenient entry point is incomplete when the map lists others.

### 4. Prove the generated skill before handing it over

Run its own instructions end to end once: launch, doctor, drive ONE mapped feature (one is enough; the map exists so later runs can cover the rest), capture evidence, clean up. After cleanup, confirm the evidence still exists at the named location: a cleanup that eats the proof fails this step. Fix what fails, and run the generated cleanup after every failed iteration too, so broken attempts don't strand processes and ports. A generated skill that was never executed is a draft, not a deliverable. If you proved it in a stand-in for the real target (a container in place of a fresh VM, a local stack in place of a remote one), list every setup step the stand-in did that the target will not. Those steps stay unverified until a run on the real target covers them.

### 5. Hand over

Tell the user where the skill lives, what it proved, and what it does not cover. Point at `re-sync` mode for keeping the map honest as the app changes; suggest a cadence only if they ask.

## Mode: re-sync

A feature map rots the moment the app changes. This mode is the upkeep loop for a skill built by `generate`, or for any project-local verification skill with a feature map. The unit of rigor is the feature, not every sentence: cover every feature file from source and exercise every feature live, without terminalising every bullet.

### Outcomes

Pick one, and say which:

- **clean:** every feature got source and live coverage; nothing worth shipping. No branch, no PR.
- **changed:** one PR ships proven doc, harness, or map corrections.
- **blocked:** coverage could not finish, or a proven fix could not ship safely. Say exactly what blocked it.

### 0. Locate the target

Find the verification skill to maintain: the project-local skill whose body has launch and drive sections and a feature map (usually `verify-*/` in the project's skill folder: `.cursor/skills/`, `.claude/skills/`, `.pi/skills/`, or `.agents/skills/`). Several candidates: ask which one. None: stop and point at `generate` mode instead of inventing a target.

### 1. Index hygiene

Read the feature map README and glob its sibling files. Fix missing, extra, duplicate, or dead entries. Lightweight; no generated inventory.

### 2. Source wave

One read-only subagent per feature file, launched concurrently. Each explains "how does this user-facing feature work?" from source, flags likely doc drift with citations, and returns one concise live-verification recipe. Children never drive the app and never edit files. Return shape: feature summary / source entry points / likely drift or none / one recipe.

### 3. Reconcile

Every feature file has a returned summary. Merge overlapping recipes into as few app states as practical. Spot-check cited drift; don't re-prove clean claims. Sweep recent churn for user-facing surfaces missing from the map: require a concrete source path before calling one missing.

### 4. Live pass

Required even when source looks clean. The coordinator owns all driving. Follow the verification skill's own launch model: one long-lived instance driven serially for servers and UIs, or a fresh isolated session per drive for short-lived CLIs (the skill's Launch section decides, not this one). Exercise every feature at least once, and hold three invariants the whole pass, whatever the failure:

1. Never drive an instance you haven't health-checked since it last did something surprising. Doctor before the first drive, doctor on each fresh session where sessions are the unit, doctor again after any failed drive, and where doctor can't see the failure (a wedged UI state on a healthy process), reset to a known state or relaunch rather than hoping.
2. Evidence captured so far survives every cleanup, checked at its named location, not assumed.
3. Nothing a drive started outlives that drive's usefulness. Failed-iteration residue is cleaned whether the session is stuck, exited, or shared; for a shared instance, clean the residue, not the instance.

A doctor failure caused by skill drift is drift: fix it under the edit scope and retry once, restarting whatever the fix invalidated and nothing more, before calling the pass `blocked`. A feature that can't be reached is `verified-unreachable` only with the concrete prerequisite (auth, entitlement, OS, external state) and the route attempted; if the map omits that prerequisite, that's drift. Any harness fix from triage gets re-driven live before it ships. Final teardown happens after the last drive of the run, including those re-proofs, so nothing outlives the run. Evidence stays, per the skill.

### 5. Triage

Wrong or missing user-POV description: doc drift, fix it. Working behavior the harness can't drive: harness gap, fix it, and a harness fix follows the same helpers rule as generation. App behavior that's actually broken: product gap; record it for the user, keep it out of this PR.

### 6. Ship or stop

For `changed`: one PR of proven corrections, re-read every changed file first. For `clean` or `blocked`: no PR, report the outcome and the coverage honestly.

Keep concise run notes (features covered, unreachable prerequisites, confirmed drift, outcome) in a scratch location; don't commit them.

## Edit scope, both modes

Only edit the verification skill's own directory: its `SKILL.md`, `features/`, and any harness scripts it owns. Never edit product code during a run. A behavior the map describes that the app no longer does is either doc drift (fix the map) or a product regression (report it, do not paper over it in docs).

## Related skills

[`formal-verification-skill`](../formal-verification-skill/SKILL.md) · [`blast-radius`](../blast-radius/SKILL.md) · [`principle-prove-it-works`](../../principles/principle-prove-it-works/SKILL.md)
