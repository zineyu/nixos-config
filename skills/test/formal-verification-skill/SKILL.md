---
name: formal-verification-skill
description: "Generate or re-sync the project-local skill that formally verifies the code where a bug costs the most and tests reach the least, in any language, with whichever verification tool fits. Use for \"model-check this race\", \"prove this invariant\", \"is the model still true to the code\", or when concurrency, retries, state machines, parsers, or unsafe code need more than tests."
disable-model-invocation: true
---

# Formal verification skill

A test checks the cases that someone thought to write. Formal verification checks every case in a stated scope: every order of steps in a model, every input up to a bound, or every input, depending on the tool. This skill finds the part of the repo where that matters most, verifies one property of it, and leaves a project-local skill that lets the next agent check a change against that property. Write that skill for an agent who reads it cold, mid-change, and has never seen your work. The user must be able to trust the result and act on it without learning the verification language.

| Mode | Entry | Output |
|---|---|---|
| **generate** | no formal check exists for the area that needs one | a new verify skill, proven against a break |
| **re-sync** | the check exists and the covered code changed under it | per check: `in sync`, `updated`, `bug`, or `blocked` |

## Mode: generate

### 1. Choose the target from the code

Answer from the codebase, and ask the user only what you cannot observe. If the user named an area or a bug, start there.

A good target is a promise the code makes, where a break harms users and tests rarely reach the case that breaks it. Choose the strongest such target in the repo, not the one that is easiest to verify.

### 2. Let the question choose the tool

Pick the tool that answers the question at the lowest cost: a model checker, a proof assistant, an SMT-backed verifier, or another tool. Whether events can happen in a bad order usually suits a model checker over a small model of the design, and TLA+ is the default for that in any language. Whether the code itself behaves for every input, as with memory safety, overflow, or a data-structure invariant, usually suits a verifier that runs on the code. If no verifier runs on this language, say so, and test the real code with generated inputs, not a hand model of the function. A property that must hold at every size, where a bound is not enough, can need a proof. Prefer a tool that the repo's developers can install and run, and tell the user why you chose it.

### 3. What makes it good

- **True to the code.** Every part of the model or proof points to code that a reviewer can open. What the verification treats as one indivisible step is one indivisible step in the code. Names come from this repo.
- **Able to fail.** A check that you have never seen fail proves nothing. Show each property failing on a broken variant of the code it guards, such as a removed check or a reordered step.
- **Findings stay findings.** When the current code breaks the property, report it with the counterexample in the code's terms. Do not weaken the property or the model until it passes, and do not change product code unless the user asks.
- **Honest about scope.** Say what is verified, under which bounds and assumptions, and what is left out. A pass covers the model or the bound, not the whole system.
- **Readable without the tool.** State the property and the harm in one plain sentence each. Tell a counterexample as a short sequence of steps in the code's words.
- **Cheap to rerun.** One command, a reproducible tool version, and a run short enough that the next agent will use it on every relevant change.
- **Kept in step with the code.** Record which files and functions each check covers, and the commit at which you last confirmed that the verification describes them. When the covered code changes after that commit, the next agent can see that the verification needs another look.

### 4. Generate the verify skill

Write a project-local skill with frontmatter that names the area and says when to use it. Without frontmatter, the skill never registers. From the skill alone, the next agent must be able to tell whether a change touches the verified code, run the check, tell a real bug from a modeling error, and update the verification when a change is intended. Put the coverage record and the sync commit in the skill, and tell the next agent to move the sync commit forward only after it confirms that the verification describes the code at the new commit. Use this repo's real commands, paths, and nouns, and leave no placeholders.

If the check is a TLA+ model, tell the next agent to read every result with the [`statechart`](../../build/statechart/SKILL.md) skill. It shows each invariant violation the checker finds as its shortest path in plain words. When the check passes, `statechart` draws a chart of how the system moves between states. Refer to it by name. Its commands, options, and file paths change between releases and machines, so copy none of them into the generated skill or its scripts.

### 5. Prove it before you hand off

Follow the generated skill once, as the next agent would, on a scratch change that breaks the property in the real code. It must catch the break. Then drop the scratch change and confirm that the check is back where it started: passing, or failing only on the findings you will report. A verify skill that was never run is a draft. If the skill misses the break or a step does not run, fix the skill or the verification, not the scratch change.

### 6. Hand off

Tell the user what you verified, which tool you used and why, the bounds, what the check found in plain words, how to run it, and what it does not cover. Suggest a second target only if you found a close one. Point at `re-sync` mode for bringing the verification back in line after changes that did not recheck it.

## Mode: re-sync

A formal check proves a property of what it describes. When the code changes and the verification does not, the check can keep passing while it describes code that no longer exists. That pass is the dangerous case, because it looks like a proof. The generated skill handles a change that an agent makes while it uses that skill. This mode handles the changes that skipped it: merges, edits made without the skill, and drift that builds up across many commits.

### Outcomes

Give each check one outcome, and say which:

- **in sync:** no change since the last sync alters what the check describes, and the check passes.
- **updated:** the code changed, the verification now describes the new code, and the check passes.
- **bug:** the verification describes the current code, and the code breaks the property. This is a finding about the code, not drift.
- **blocked:** the check could not be brought back in line or could not run. Say exactly why.

A check can be both updated and bug: the update makes the verification describe the code again, and then the property fails on it.

### 1. Find the checks

A verify skill has no fixed name, so find it by what it does: a project skill that runs a model checker, a prover, or another verifier against named code. Read each one you find, or the one the user named. For each check, collect the property, the code it covers, the bounds and assumptions, the command that runs it, and the commit where it was last confirmed to describe the code. If no verify skill exists, stop and point at `generate` mode. If the skill does not record a sync commit, use the last commit that changed the verification files, and say that you did.

### 2. Run it as it is

Run each check once before you change anything, and record the result. A pass here does not tell you that the code is correct; it tells you that the old description still holds. A failure here can be drift or a bug. Do not decide which until step 5.

### 3. Read every change to covered code

Diff the covered files from the sync commit to the current commit, and read each commit message. Also look for code that moved: a covered function that is renamed, split, or moved to another file is still covered code. Also look for new code that touches the state a check guards, such as a new function that writes the same fields. For each change, decide which of these it is:

- **No effect.** The change does not alter anything the verification describes, such as formatting, comments, or code paths that the verification does not cover. Check this against the model or harness, not against the commit message.
- **The verification no longer describes the code.** A step that was one indivisible action is now two, a branch was added or removed, a check moved, a new path reaches the guarded state, or a value now has a different range. The model or harness must change.
- **The promise changed on purpose.** The change alters what the code promises, and evidence in the change says that this is intended: the doc comment, the tests, the changelog, or the commit message. The property must change, and you must cite that evidence.
- **The promise may be broken.** The code changed, and no evidence says that the promise changed. Treat a failure that follows as a bug candidate.

### 4. Update from the code, not from the result

Change the model or harness so that each changed part again points to code that a reviewer can open, and keep one indivisible step in the code as one step in the verification. Write the update from the code before you rerun, and do not shape it by what makes the check pass. Change a property only for a promise that changed on purpose. Write down the old wording, the new wording, and the evidence. Keep the bounds unless the change makes them wrong. If you must reduce a bound, say so in the report.

### 5. Rerun and judge each result

- **Pass:** the check can now pass on a description that has lost the ability to fail. Break the new code the way the property guards against, such as removing a new check or reordering a new step, and confirm that the check catches it. Then drop the break.
- **Fail:** replay the counterexample against the real code, step by step. If a step cannot happen in the code, the verification is wrong: fix the verification, and say what was wrong. If every step can happen, it is a bug. Name the commit that introduced it, tell the counterexample as a sequence of steps in the code's own words, and state the harm in one sentence. If a cheap test or reproduction against the real code shows the bug, add it to the report as evidence. Do not commit it to the product code.

### 6. Update the verify skill

Update the code that each check covers, the commands, the bounds, the assumptions, and the sync commit. Set the sync commit to the commit that you checked. Do not move the sync commit for a blocked check, and say so in the report. Then follow the verify skill once as the next agent would, so that you know its steps still run.

### Report

Tell the user, for each check:

- the outcome, and the commits that you read;
- what changed in the verification and why, with a short reason for each change: the code changed shape, or the promise changed on purpose, with the evidence;
- the rerun result, and the break that you used to show the updated check can still fail;
- each bug, in plain words: the counterexample as steps in the code's words, the harm, and the commit that introduced it;
- what the verification still does not cover, including new code that it should cover and does not.

Say outright which failures were drift in the verification and which were bugs in the code. For a check that passed before you updated it and fails after, say that the old pass was on a stale description.

Put the verification updates in a change of their own, separate from any product fix.

## Edit scope, both modes

Edit only the verification: models, harnesses, property files, and the verify skill itself. Never edit product code during a run, unless the user asks you to. When a property fails on the current code, do not weaken the property or the model to make it pass. Report the failure.

## Related skills

[`verification-skill`](../verification-skill/SKILL.md) · [`statechart`](../../build/statechart/SKILL.md) · [`principle-prove-it-works`](../../principles/principle-prove-it-works/SKILL.md)
