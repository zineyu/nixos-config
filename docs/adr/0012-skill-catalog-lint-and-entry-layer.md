# Skill catalog lint and an explicit entry layer

## Status

Accepted

## Date

2026-11-05

## Context

`skills/` holds 88 skills, discovered by `modules/base/agent-skills` and linked
one directory each into `~/.agents/skills/<name>`. Three facts made the current
state insufficient:

1. **Layout was checked; content was not.** The module's Nix assertions cover
   exactly three layout rules: one directory per category, one `SKILL.md` per
   skill, unique names. A claim inside a `SKILL.md` - its frontmatter, its
   trigger phrase, whether the files it links to exist - had no check at all. The
   first run of the new linter found two real defects: a `SKILL.md` that opened
   with `----` instead of `---`, and a `name` that disagreed with its directory
   name. Both had been shipping.
2. **Layout was also understated in the documentation.** `README.md` and
   `docs/module-reference.md` described `skills/<name>/`, while the module reads
   `skills/<category>/<name>/`. The stated count (83) was one behind the
   directory count (84).
3. **No entry layer existed.** A skill is the *how*: it loads when the model or
   the user reaches it. `/skill:<name>` works, but a workflow that spans several
   skills and needs arguments, a human gate, and a stop condition had nowhere to
   live, so its protocol was re-derived from prose in every session. Pi loads
   entry points from `~/.pi/agent/prompts/*.md` as `/` commands, and this
   repository managed only `~/.pi/agent/extensions`.

## Decision

- **`scripts/lint-skills.py` owns skill content; the Nix assertions keep owning
  layout.** The split follows what each tool can read cheaply: Nix already walks
  the directory tree at evaluation, so the linter never re-checks layout beyond
  the name-to-directory match that needs the frontmatter anyway.
  - Errors: missing `SKILL.md`, an unopened or unclosed frontmatter, a missing
    `name` or `description`, `name` differing from the directory name, a name
    that is not lowercase-kebab-case, a description past 1024 characters, and a
    model-invoked skill whose description carries no positive trigger.
  - Warnings: a relative link whose target does not exist, a `SKILL.md` over the
    line budget, and a frontmatter key outside the Agent Skills specification.
  - The trigger check accepts `Use when ...`, `Use before/after/during ...` and
    the passive `should be used when ...`, and strips every negated clause first.
    A description built from exclusions is a routing hazard, not a trigger.
- **The linter runs in `checks.lint` and in `just lint-skills`.** `nix flake
  check` is the single gate; the recipe is the fast local loop. `python3` joins
  `devenv.nix` so the recipe runs in the standard environment rather than
  depending on the machine's PATH.
- **`programs/dev/pi/prompts/` is the entry-layer source directory**, linked to
  `~/.pi/agent/prompts` by the same `linkDir` helper the extensions use. The file
  name is the command name.
- **The skill directory is the command.** `skills/<command>/` holds the skills
  one `/command` routes to, so the layout answers "which skills does this step
  reach" instead of "what kind of thing is this skill". `principles/` and
  `tools/` stay outside the commands because they are reached from every step
  and from none: a judgement standard and a repository tool. The module links
  every skill flat into `~/.agents/skills` regardless of its directory, so the
  rearrangement changes no skill name and no trigger.
- **Each command declares the routing.** A command opens by naming the skill it
  runs by default and carries a table of the situations that send it elsewhere:
  an unsettled design goes to `codebase-design`, a test that will not pass to
  `diagnosing-bugs`, a state machine to `statechart`. The table is the command's
  own decision, kept there rather than in a skill, because it is about when to
  switch, not how to do the work. A skill that belongs to another command is
  still reachable from this one; the directory records the default owner, not a
  restriction.

- **Every command opens by naming the skills it invokes.** The command is the
  *when*: it decides which skills run, in which order, with which arguments,
  behind which gate. The skill is the *how* and keeps the procedure. A reader of
  the command learns what will happen; a reader of the skill learns how.
- **A command body carries only what the skills do not.** Ten commands ship,
  one per lifecycle step:
  - `/spec` adds the entry gate to `to-spec`: `interview-me` settles the intent
    before synthesis, because `to-spec` records decisions rather than making
    them. The gate is the confidence test - predict the user's reaction to the
    next three questions - not an exhausted design tree: the branches a spec
    cannot settle belong to `/plan` and `/build`. `domain-modeling` writes what
    crystallises into `CONTEXT.md` for terms and `docs/adr/` for trade-offs, so
    the repository keeps one glossary instead of two. `interview-me` replaced
    `grilling` outright: the three skills that drove an interview - `/spec`,
    `triage`, and `wayfinder` - now call it, and the design-tree frontier is gone
    from the catalogue.
  - `/plan` adds the source argument to `to-tickets`, and the guard against
    overwriting an incomplete plan.
  - `/test` runs after the code is written, and that is what separates it from
    `/build`. `principle-prove-it-works` supplies the artifact check and
    `blast-radius` supplies the reach beyond the diff, and a claim that could not
    be tested is reported as unverified rather than as passing.
  - `/build` adds sequencing to `implement`: the baseline check, the `auto`
    mode, the single approval gate, the stop conditions, and one change per
    ticket.
  - `/review` adds severity tiers and `file:line` to `code-review`, and stops at
    the findings.
  - `/code-simplify` adds the scope and the change boundary that
    `code-simplification` leaves open.
  - `/perf` adds the entry condition and the claim-first rule to
    `benchmark-checklist`.
  - `/refactor` declares twelve skills and adds eight dimensions to one report -
    layout, lint, CI, deployment, performance, abstraction, simplification, plus
    the architecture pass from `improve-codebase-architecture`, which also owns
    the report format. The abstraction pass enumerates every indirection and
    judges each with `codebase-design`'s deletion test, so a surviving
    abstraction becomes a recorded finding rather than a proposal.
    `code-reuse` guards the opposite error, `principle-laziness-protocol` keeps
    the survey to removals, `second-pass` reviews the list before hand-off, and
    `principle-subtract-before-you-add` fixes the order of what follows. A
    picked candidate goes to `/plan`, an inlining job to `/code-simplify`. The
    report itself is produced by `html-report`, extracted from
    `improve-codebase-architecture` and generalised: the page format - summary
    first, identical card fields, side-by-side diagrams, a stated
    recommendation - serves any set of findings, not only architecture ones.
  - `/gate` invokes `constraint-driven-development` and supplies the entry
    points and the landing places: `CONSTRAINTS.md` at the root, the pointer line
    in `CONTEXT.md`, one `just` recipe per rule, and the `check` / `guard` /
    `ratchet` sub-commands.
  - `/ship` invokes `shipping-and-launch` and supplies the deployment modes. It
    maps them onto what this repository has - `check` builds and verifies,
    activation switches or deploys - and requires the generation being replaced
    to be recorded before the one approval gate.

  Repeating a skill's own steps there would be duplication that drifts.
- **Skills stay general; the commands carry the local detail.** Four skills are
  imported from the same catalogue because no local equivalent existed:
  `shipping-and-launch` and `constraint-driven-development` for the deployment
  and quality-bar commands, and `security-and-hardening` with
  `ci-cd-and-automation` for the two gaps the comparison found. Each keeps a
  general procedure and names a tool by dimension rather than by product, so the
  skill travels to other projects. The local facts - the `just` recipes, the
  `CONSTRAINTS.md` landing in this root, the `CONTEXT.md` pointer - stay in
  `programs/dev/pi/prompts/`, where they belong: the command is the *when* for
  this repository, the skill is the *how* for any. Every imported skill carries
  its upstream URL and the MIT licence in its frontmatter.
- **A judgement rule earns independence only when two or more steps need it.**
  Independence buys a single source of truth and costs a name the human must
  remember. A principle cited by one skill is therefore folded into that skill:
  `attack-the-premise` into `diagnosing-bugs`, `experience-first` into
  `frontend-ui-engineering`, `migrate-callers-then-delete-legacy-apis` into
  `code-reuse`. Twenty-one principles remain, each cited by at least two steps.
  Three that were cited by none or by one gained a second pointer instead of
  being removed, because their content was sound and only the pointer was
  missing: `build-the-lever`, `never-block-on-the-human`,
  `make-operations-idempotent`. Nothing moved to `references/`: that directory
  is for lookup material, and every principle carries a rule that changes
  behaviour.
- **`html-report` is a shared presenter.** Ten skills hand their findings to it
  when the list is long enough to skim or when the comparison is the point:
  `code-review`, `arena`, `blast-radius`, `interrogate`, `swarm`,
  `security-and-hardening`, `second-pass`, `ci-cd-and-automation`, `retro`, and
  `reflect`. The reference is conditional on purpose. A review with three
  findings reads faster as text, and a page produced for it costs more than it
  returns. `html-report` sits in `tools/` because it is machinery, not a step.
- **Shared checklists live in `skills/references/`.** A checklist used by more
  than one skill sits outside every skill directory, reached by a relative path.
  The Agent Skills layout puts a skill two levels below the skills root, so
  `../../references/<name>.md` resolves from any category without a rewrite, and
  the whole `skills/` tree is linked as one store path per skill, so the target
  never goes missing.

## Alternatives Considered

### Put the content checks in Nix assertions

- Pros: one tool, no new runtime.
- Cons: parsing YAML frontmatter and resolving relative links in the Nix
  expression language is a worse implementation of a solved problem, and the
  error messages would be single strings.
- Rejected: Nix keeps the layout rules it expresses well; a script keeps the
  content rules readable and unit-editable.

### Make the section structure (Overview, When to Use, Rationalizations, Red
Flags, Verification) a required check

- Pros: those sections are the strongest anti-rationalization device in
  comparable catalogs, and 3 of 88 skills use them today.
- Cons: requiring them now fails 81 skills and invites empty boilerplate, which
  is a no-op that pays context load for nothing.
- Rejected: the structure is recommended when writing or rewriting a skill, not
  enforced by the linter.

### Ship a command per frequently used skill

- Pros: every workflow gets a short name.
- Cons: an entry point is spent cognitive load - the human is the index - and
  `/skill:<name>` already reaches any skill directly.
- Rejected: a command earns its place only when it adds arguments, ordering,
  a human gate, or a stop condition.

### Keep the directory grouped by what a skill acts on

- Pros: the four original categories (`code`, `workflow`, `tools`,
  `principles`) read as a description of each skill's subject matter.
- Cons: with a command layer in place, the reader arrives from a command and
  has to know that `implement` sits under `code` while `to-tickets` sits under
  `workflow`, though both belong to one step of the lifecycle. Subject matter
  and step of use are different axes, and the commands made the second one the
  useful one.
- Rejected: the directory now names the step. `principles/` and `tools/` keep
  their old meaning because they genuinely sit outside the lifecycle.

### Ship only the five commands with a large increment

- Pros: fewer entry points, and `/test` and `/code-simplify` add little to
  `tdd` and `code-simplification`.
- Cons: the lifecycle becomes uneven. A user who reaches `/build` finds no
  matching `/test`, and every reader rediscovers which steps carry a command and
  which do not.
- Rejected: an even lifecycle is worth four more entries, and each of the four
  carries a real increment listed above.

### Keep `/ship` as the close-out verdict

- Pros: one entry point that carries a review through to a GO or NO-GO verdict.
- Cons: it runs the same two axes as `/review`, so the verdict duplicated a flow
  that already existed.
- Rejected in that form. `/ship` now means deployment, which no other command
  covers, and the verdict stays with `/review` and a human decision.

### Keep the upstream names `/webperf` and `/simplify`

- Pros: a one-to-one mapping to the source catalogue.
- Cons: this repository builds NixOS and nix-darwin configurations, so a web
  performance audit has no target; the matching skill is
  `benchmark-checklist`, which vets any performance number. `/webperf` would
  name a scope the command does not have.
- Rejected: `/perf` names the actual scope. `/code-simplify` keeps the upstream
  stem because it reads as the verb of its skill.

## Consequences

- Adding a skill: write `skills/<category>/<name>/SKILL.md`, run `just
  lint-skills`. The linter names the file and the problem.
- Adding a command: put `<name>.md` in `programs/dev/pi/prompts/`; it becomes
  `/<name>` after `home-manager switch` and `/reload`.
- The three remaining warnings are real and accepted: `paths` in
  `typescript-best-practices` and `argument-hint` in `handoff` and `teach` are
  host-specific keys outside the specification. They stay as warnings so a
  strict host failing to package one of them is visible rather than silent.
- Renaming a skill directory is a breaking change: the link name under
  `~/.agents/skills` and the `/skill:<name>` command both follow it. The
  rename in this change affected no other file, and no other skill referenced
  it.
- Verified at introduction: `nix build .#checks.aarch64-darwin.lint` passes
  (nixfmt, deadnix, statix, skill lint), and
  `nix eval .#darwinConfigurations.macbook-air-01...home.file` lists all eight
  entries under `.pi/agent/prompts/`.
