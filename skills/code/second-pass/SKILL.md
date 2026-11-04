---
name: second-pass
description: "Review the work you just finished: find the better implementation, and the steps the run wasted."
disable-model-invocation: true
---

You have just finished a piece of work. This is the **second pass**: read your own run the way a reviewer would hand it back, and find the better implementation inside it.

A second pass improves the work and the run that produced it. It does not improve the environment: lint rules, hooks, `AGENTS.md` and tooling belong to `retro`.

## Steps

### 1. Collect the record

The record is the run, not your memory of it. Read the changes (`jj log`, `jj diff`, `git log`), the gate output, the review reports, and the notes you kept for this work.

Write one row per event, in the order it happened: the action, and the state of the tree at that moment.

**Done when** every phase has a row: setup, each slice, each gate, each review, each fix, the commit.

### 2. Score the flow

For each row, ask what it cost. Keep the rows that have a cost.

- A gate that ran twice, because the code changed after the first run.
- A rewrite that followed a check you ran at the end instead of at the first slice.
- A test rewritten because an interface changed after the test was written.
- A step the loaded skill asked for and you skipped, and the risk you took instead.
- A change too large to revert alone, or one change serving two reasons.

**Done when** every phase has a verdict: kept, or this cost.

### 3. Hunt the better shape

Read the code you shipped and the tests that guard it. These shapes pay:

- **A guarantee held only in prose.** "External code cannot construct this", "the write happens first", "this is never copied" are claims a compiler or a test can decide. A silent guarantee is a guarantee waiting to break.
- **A fixture more forgiving than the system under test.** A fake that writes before it is awaited, that never fails where the real thing fails, or that hides a timeout.
- **A constraint in the wrong place.** A bound that lands on every caller, while the type that owns the data is its honest home.
- **A state the types allow and the domain forbids.** A parameter that accepts a value with no meaning at that call site.
- **An input every implementer must ignore.** A trait parameter that no branch reads.
- **A name that describes something else.** Keep names the specification fixed, and report the mismatch.
- **Duplication whose removal adds a middle layer.** Keep it, and say why.

**Done when** each suspect is named with the line it lives on.

### 4. Rank by what can be proved

Sort the findings by how firmly the improvement can be shown to be better. A test that fails now and passes after the change ranks above a taste argument, and a taste argument ranks above a rewrite with no check. Prefer the change that turns a silent failure into a loud one.

Write down the findings you rejected, and the reason. The rejection is what keeps the next agent from raising them again.

### 5. Classify, then ask

Give each finding a class:

- **Test or document only** — safe to apply now.
- **Implementation detail** — safe to apply, and the interface it changes is internal.
- **Contract** — a signature, a type or a behaviour that another ticket builds on. It cannot change silently: it needs a decision from whoever owns the next ticket.

Present one ranked table: the fact, the cost, the better shape with a short code sketch, and the class. Then ask which findings to apply.

### 6. Apply what was approved

Apply the safe findings as their own atomic changes, each with its own reason. Run the fast gate between them, and the full gate once at the end.

When a contract finding is accepted, record it where the next ticket will read it: in the ticket, or in the architecture decision that covers it.

**Done when** the tree is clean, the full gate is green, and every accepted finding is a change or a written decision.

## Reference

- **Evidence first.** No finding without a quote from the diff, the gate output or the review.
- **No rewrite you cannot check.** When an improvement has no test, say how it will be observed instead.
- **No abstraction the specification did not ask for.** A smell that the specification fixes in place is a rejected finding, and it is worth writing down.
- **The two axes stay apart.** The flow and the code are scored separately. A clean implementation behind a wasteful run passes one and fails the other, and that difference is the information.
