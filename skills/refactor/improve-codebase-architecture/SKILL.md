---
name: improve-codebase-architecture
description: Scan a codebase for deepening opportunities and present them as a visual HTML report. Stop at the report; the chosen candidate goes to the step that will do the work.
disable-model-invocation: true
---

# Improve Codebase Architecture

Surface architectural friction and propose **deepening opportunities**: refactors that turn shallow modules into deep ones. The aim is testability and AI-navigability.

This skill is _informed_ by the project's domain model and built on a shared design vocabulary:

- Read the `codebase-design` skill for the architecture vocabulary (**module**, **interface**, **depth**, **seam**, **adapter**, **leverage**, **locality**) and its principles (the deletion test, "the interface is the test surface", "one adapter = hypothetical seam, two = real"). Use these terms exactly in every suggestion, and don't drift into "component," "service," "API," or "boundary."
- The project's domain language gives names to good seams; its ADRs record decisions this skill should not re-litigate.

This skill stops at candidates. It does not design interfaces and does not interview.

## Process

### 1. Explore

**Scope before you scan: YAGNI.** Deepening a module pays off by making future changes to it easier, so put extra weight on the parts of the codebase that have recently changed. Decide *where* to look before you look:

- If the user named a direction (a module, a subsystem, a pain point), take it, and skip the inference below.
- Otherwise, walk back a good stretch of the commit history (`git log --oneline`) to find the codebase's hot spots, the files and areas that keep coming up, and let those paths pull your attention first. If the changes are scattered with no clear hot spot, widen the net.

Read the project's domain glossary (`GLOSSARY.md`) and any ADRs in the area you're touching first.

Then spawn a sub-agent to walk the codebase. Don't follow rigid heuristics; explore organically and note where you experience friction:

- Where does understanding one concept require bouncing between many small modules?
- Where are modules **shallow**, with an interface nearly as complex as the implementation?
- Where have pure functions been extracted just for testability, but the real bugs hide in how they're called (no **locality**)?
- Where do tightly-coupled modules leak across their seams?
- Which parts of the codebase are untested, or hard to test through their current interface?

Apply the **deletion test** to anything you suspect is shallow: would deleting it concentrate complexity, or just move it? A "yes, concentrates" is the signal you want.

### 2. Present candidates as an HTML report

Invoke the `html-report` skill. It owns the page: the scaffold, the diagram patterns, the styling,
and the rules for writing to a person.

What this skill adds to the page is the architecture content:

- **Files**: which modules are involved
- **Before / After**: the centrepiece, side by side
- **Problem**: one sentence on the friction the current shape causes
- **Solution**: one sentence on what would change
- **Benefits**: stated as locality and leverage, and how the tests would improve
- **Recommendation strength**: `Strong`, `Worth exploring`, or `Speculative`

End the page with a **Top recommendation**: the candidate you would tackle first, and why.

**Use the project's domain vocabulary for the subject, and the `codebase-design` vocabulary for the architecture.** If the glossary defines "Order," write "the Order intake module," not "the FooBarHandler," and not "the Order service."

**ADR conflicts**: if a candidate contradicts an existing ADR, surface it only when the friction is real enough to warrant revisiting the ADR. Mark it on that candidate's card, as a caveat: _"contradicts ADR-0007, but worth reopening because…"_. Do not list every theoretical refactor an ADR forbids.

### 3. Hand off the pick

The report is the deliverable. Turning a candidate into a decision belongs to the step that will do
the work, not here.

When the user picks a candidate, state it in four lines and stop:

- the seam being deepened
- the friction the report proved
- the files it touches
- what the deepening would make easier to test or navigate

Then hand off. Most candidates continue at the spec step, which settles the decisions and writes
them down. One small enough to state in a single line continues at the build step instead.

Do not design the interface, do not run an interview, and do not edit the glossary or the ADRs.
Those belong to the step that owns the decision.

## Related skills

[`how`](../../build/how/SKILL.md) · [`architect`](../../build/architect/SKILL.md) · [`principle-redesign-from-first-principles`](../../principles/principle-redesign-from-first-principles/SKILL.md)
