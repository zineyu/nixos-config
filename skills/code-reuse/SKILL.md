---
name: code-reuse
description: Decide whether to reuse code, to extract a shared module, or to keep the duplicate. Use when you write a new helper that may already exist, when the same logic appears in a second or a third file or service, when you copy code between modules, when you choose between composition and inheritance, when you add a shared package or SDK, and when you review a diff for duplicated logic.
---

# Code Reuse

Reuse adds coupling to the caller and to the reused module. Extract only when the evidence supports it.

The unit of reuse is the interface of a module, not a block of lines. Duplication that lets two contexts evolve on their own costs less than an abstraction that couples the two contexts.

## The decision

Follow the steps in order. Stop when the first step concludes that the duplicate stays.

**Step 1 — Search.**
Search for the concept, not for the wording. Check the domain noun, the verb of the operation, the directories `utils/`, `common/`, and `shared/`, the package manifests, the cross-language mirrors, and the neighboring services.
The step is done when you can name the candidate module, or when you write one line that explains why no existing implementation fits.

**Step 2 — Test the semantic identity.**
Ask one question. When this rule changes here, must it change there as well?
The step is done when you answer yes (reuse or merge) or no (keep the two apart), and you name the rule. "It looks similar" is not an answer.

**Step 3 — Apply the checks.**
Every check in the next section must pass before you extract anything that is shared.
The step is done when every check has a clear verdict.

**Step 4 — Choose the form.**
Choose one row in the forms table. When a check fails, change the form and keep the checks.
The step is done when the chosen form has a named consumer today.

**Step 5 — Record the decision.**
Write three facts into the change description or into the summary: what you searched, what you reused, and which mirrors you changed.
The step is done when the three facts are present and the mirrors are updated in the same change.

## The checks

| # | Check | Condition to pass |
|---|---|---|
| 1 | Coverage | An existing implementation covers 80 percent or more of the need. Extend it or call it. Do not rewrite it. |
| 2 | Repetition (Rule of Three) | The same knowledge appears in three stable and independent contexts. |
| 3 | Deletion test | Delete the module. When the complexity comes back to the callers, the module is real reuse. When the complexity disappears, the module is a pass-through (Lazy Class, Middle Man). |
| 4 | Net benefit | The complexity that is removed is larger than the coupling that is added. |
| 5 | Consumer (REP) | A consumer exists today, and the unit can be released on its own. |

Check 4 fails in three cases: the parameters always appear as a group, a paragraph of documentation is necessary before the unit is used, or each new variant requires an edit of the abstraction. These signals show that the seam sits in the wrong place.

Seam rule: one adapter is a hypothetical seam, and two adapters make the seam real. Introduce a seam only where something actually varies across it. The vocabulary for depth, seam, and adapter is defined in `codebase-design`.

## The thresholds

| Spread of the duplication | Action |
|---|---|
| Two or more occurrences in the same file | Extract a local function or method. |
| The same concept in three or more files | Evaluate a shared module. |
| Use in two or more services | Share a contract or an SDK. Copy and paste is rejected here. |
| Two different bounded contexts | Share the contract only. Do not share the domain type. |

## The forms

| Situation | Form | Basis |
|---|---|---|
| Duplication inside one module | A local function | DRY within the boundary of the module |
| Duplication across files, one concept | A shared module with a small interface | Deep module, information hiding (Parnas) |
| Behavior varies and is replaced at run time | An interface together with composition | Strategy, DIP, ISP |
| The variant set is closed and the substitution must hold | A sealed hierarchy, an ADT, or a trait with default methods | Use a subtype only when LSP holds |
| A capability across services | A package or a contract with a version | REP, CRP, SemVer |
| A concept across bounded contexts | A contract together with an ACL | DDD |
| Only fragments of behavior are shared | A higher-order function, a mixin, or a hook | Composition |
| Change arrives on two axes | One composition for each axis | CCP, Connascence |

## Composition over inheritance

GoF: favor object composition over class inheritance.

Composition reuses an interface. Inheritance reuses an implementation, binds at compile time, exposes `protected` state, and requires every subclass to satisfy LSP.

Inheritance holds only in these cases:
- A subtype that satisfies LSP, and the callers dispatch on the base type.
- A closed variant set that works with a visitor or with a sealed match.
- A controlled template method in the life cycle of a framework.
- An abstract base class for close variants that share one axis of change.
- Reuse of a pure interface: a marker, a protocol, or Go interface embedding.

Composition applies to cross-cutting behavior (Decorator, Proxy, Strategy, Chain of Responsibility, Pipeline), to replacement at run time, and to collaborators that evolve on their own.

Delete the middle layer (Middle Man) that pure delegation creates. Kotlin uses `by`, Go uses struct embedding, Rust uses trait default methods, and TypeScript uses a higher-order function.

## The duplicate stays

The decision ends here, and two implementations stay, in these cases:
- The meaning belongs to two different bounded contexts.
- The generalization has no current specification and no active issue (YAGNI).
- The extraction saves less than about ten lines of code.
- Only two implementations exist, and the pattern is not stable yet.
- There is one call site, with no separate seam for the tests and no new concept.
- The merge puts the persistence, the transport, and the domain behavior of one noun into one type.
- The only purpose of the abstraction is to lower the duplication metric.

The extraction also holds when it builds the seam that the tests need, or when it gives a name to a concept that the codebase already uses.

## Maintenance of the shared assets

- Adopt an existing shared module, or retire it explicitly. Keep no orphan SDK, and write no second equivalent beside it.
- Every shared package has one owner, and it has at least one consumer today.
- SemVer constrains the release. Every behavior that a consumer can observe is part of the contract (Hyrum's Law).
- Monorepo: converge on one version with a catalog or with overrides, and upgrade all importers atomically in the same change.
- Across repositories: provide a shim together with a deprecation path. Use directory versioning (`v1/`, `v2/`) during the transition, and delete the old directory afterwards.
- Update the cross-language mirrors in the same change, and name the correspondence of the mirrors in the change description.
- The dependency direction follows SDP, SAP, and ADP. Depend on the side that is more stable and more abstract, and keep the dependency graph free of cycles.

## Review checklist

- [ ] The change description states the result of the search.
- [ ] Check 1 is applied, or it is overridden with a stated reason.
- [ ] The spread of the duplication is named: one file, three files, or services.
- [ ] Checks 2 to 5 are verified for every new shared unit.
- [ ] The form comes from the forms table.
- [ ] Composition is used, or one condition for inheritance holds.
- [ ] The new shared unit has a consumer today.
- [ ] The mirrors, the SemVer change, and the importers are handled in the same change.
