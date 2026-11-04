---
name: code-review
description: "Review the changes since a fixed point (commit, branch, tag, or merge-base) along two axes — Standards (does the code follow this repo's documented coding standards, and is it free of the baseline smells?) and Spec (does it match the originating issue or spec?) — and across five quality dimensions: correctness, readability, architecture, security, performance. Runs the axes as parallel sub-agents and reports them side by side. Use when reviewing a branch, a PR, work-in-progress changes, another agent's code, or when asked to \"review since X\"."
---

Two-axis review of the diff between `HEAD` and a fixed point the user supplies:

- **Standards**: does the code conform to this repo's documented coding standards, and is it free of the baseline smells?
- **Spec**: does it faithfully implement the originating issue / spec?

Underneath both axes sit five quality dimensions: correctness, readability, architecture, security, performance. Their judgement library, the structural remedies, and the smell baseline live in [`references/quality-axes.md`](references/quality-axes.md).

The two axes run as **parallel sub-agents** so they don't pollute each other's context, then this skill aggregates their findings.

**The approval standard.** Approve a change when it definitely improves overall code health, even if it isn't perfect. Don't block because it isn't how you would have written it: if it improves the codebase and follows the project's conventions, approve it.

The issue tracker should have been provided to you. If not, tell the user to run `/setup-skills`.

## Process

### 1. Pin the fixed point

Whatever the user said is the fixed point (a commit SHA, branch name, tag, `main`, `HEAD~5`, etc.). If they didn't specify one, ask for it.

Capture the diff command once: `git diff <fixed-point>...HEAD` (three-dot, so the comparison is against the merge-base). Also note the list of commits via `git log <fixed-point>..HEAD --oneline`.

Before going further, confirm the fixed point resolves (`git rev-parse <fixed-point>`) and the diff is non-empty. A bad ref or empty diff should fail here, not inside two parallel sub-agents.

If the change is a pasted diff or a working-tree change with no fixed point, review exactly what was given and say in the report that no base was compared.

### 2. Identify the spec source

Look for the originating spec, in this order:

1. Issue references in the commit messages (`#123`, `Closes #45`, GitLab `!67`, etc.), fetched via the workflow in the tracker doc.
2. A path the user passed as an argument.
3. A spec file under `docs/`, `specs/`, or `.scratch/` matching the branch name or feature.
4. If nothing is found, ask the user where the spec is. If they say there isn't one, the **Spec** sub-agent will skip and report "no spec available".

### 3. Identify the standards sources

Search the repo for every file that documents how code should be written. When `CODING_STANDARDS.md` or `CONTRIBUTING.md` exists, it must be on the list.

On top of whatever the repo documents, the Standards axis always carries the smell baseline in [`references/quality-axes.md`](references/quality-axes.md#smell-baseline): a fixed set of Fowler code smells that applies even when a repo documents nothing. A documented repo standard overrides the baseline, and every smell is a judgement call, never a hard violation. Skip anything tooling already enforces.

### 4. Spawn both sub-agents in parallel

Issue both sub-agent calls together, in the foreground, and aggregate the reports they return.

**Standards sub-agent prompt** should include:

- The full diff command and commit list.
- The list of standards-source files you found in step 3, plus the path to `references/quality-axes.md` so it can paste the smell baseline.
- The brief: "Report, per file/hunk where relevant, (a) every place the diff violates a documented standard: cite the standard (file + the rule); and (b) any baseline smell you spot: name it and quote the hunk. Judge the five quality dimensions as you go: correctness, readability, architecture, security, performance. Distinguish hard violations from judgement calls: documented-standard breaches can be hard, but baseline smells are always judgement calls, and a documented repo standard overrides the baseline. Skip anything tooling enforces. Under 400 words."

**Spec sub-agent prompt** should include:

- The diff command and commit list.
- The path or fetched contents of the spec.
- The brief: "Report: (a) requirements the spec asked for that are missing or partial; (b) behaviour in the diff that wasn't asked for (scope creep); (c) requirements that look implemented but where the implementation looks wrong. Quote the spec line for each finding. Under 400 words."

If the spec is missing, skip the Spec sub-agent and note this in the final report.

### 5. Review the tests before the implementation

Tests reveal intent and coverage. Ask whether they test behaviour rather than internals, whether the edge cases are covered, and whether the names describe the behaviour.

Answer "would the tests catch a regression?" by experiment, not by reading. Invert one condition the change adds (drop a negation, swap `&&` for `||`), run the suite, then restore the file from a copy. A mutation that stays green is a finding: name the test case that is missing. See [`references/quality-axes.md`](references/quality-axes.md).

### 6. Aggregate

Present the two reports under `## Standards` and `## Spec` headings, verbatim or lightly cleaned. Do **not** merge or rerank findings across axes, because the two axes are deliberately separate (see _Why two axes_).

Label every finding with its severity so the author knows what is required versus optional:

| Prefix | Meaning | Author action |
|---|---|---|
| *(no prefix)* | Required change | Must address before merge |
| **Critical:** | Blocks merge | Security vulnerability, data loss, broken functionality |
| **Nit:** | Minor, optional | Author may ignore |
| **Optional:** / **Consider:** | Suggestion | Worth considering |
| **FYI** | Informational | No action needed |

Lead with what matters: correctness and security first, then structural regressions and missed simplifications, then everything else. If there is one structural problem and ten nits, the structural problem *is* the review.

End with a one-line summary: total findings per axis, and the worst issue _within each axis_ (if any). Don't pick a single winner across axes: that's the reranking the separation exists to prevent.

### 7. Judge the change itself

Beyond the code, the change has to be reviewable:

- **Description.** First line imperative and standalone ("Delete the FizzBuzz RPC"), body explaining what and why, links to the issue or benchmark. See `pr` for the shape of a PR body.
- **Size.** A change too large to review in one sitting gets split rather than rubber-stamped. The bounds are in [`references/quality-axes.md`](references/quality-axes.md).
- **Dead code.** Removals the change makes redundant belong in the same change, not a follow-up. See `code-simplification` and `principle-subtract-before-you-add`.

## Why two axes

A change can pass one axis and fail the other:

- Code that follows every standard but implements the wrong thing → **Standards pass, Spec fail.**
- Code that does exactly what the issue asked but breaks the project's conventions → **Spec pass, Standards fail.**

Reporting them separately stops one axis from masking the other.

## Elsewhere

- A written report rather than a chat reply: [`references/report-template.md`](references/report-template.md).
- How fast to review, how to disagree, how to stay honest, and the failure modes: [`references/review-posture.md`](references/review-posture.md).
- Want the change attacked rather than checked: `interrogate`.
- Want to know what breaks outside the diff: `blast-radius`.
- Reviewing your own just-finished run: `second-pass`.

## Related skills

[`interrogate`](../interrogate/SKILL.md) · [`blast-radius`](../blast-radius/SKILL.md) · [`second-pass`](../second-pass/SKILL.md) · [`principle-test-behavior-not-implementation`](../../principles/principle-test-behavior-not-implementation/SKILL.md) · [`typescript-best-practices`](../typescript-best-practices/SKILL.md)
