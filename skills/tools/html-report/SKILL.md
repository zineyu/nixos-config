---
name: html-report
description: Build a single-file HTML report that a person reads and judges — candidates, findings, a comparison, or a decision. Use when the output is a set of options a human must weigh, when side-by-side diagrams say it faster than terminal text, or when a review must reach someone who was not in the session.
---

# HTML Report

A wall of terminal text is a transcript. A report is an argument a person can scan, compare, and decide from.

## When to Use

- a set of candidates or findings the user must choose between
- a comparison where two shapes side by side beat two paragraphs
- a review handed to someone who was not in the session
- any output the human will skim before reading

**When NOT to use:**

- a single short answer
- output another agent consumes rather than a person; that goes in a file, not a page
- anything that must live in the repository: this report is a temporary artifact

## The shape

| Part | Job |
|---|---|
| Header | what was reviewed, when, and the scope in one line |
| Summary | the three findings that matter, before anything else |
| Cards | one per candidate, identical fields, so a reader compares like with like |
| Comparison | a diagram or table for the one dimension that is hard to say in words |
| Recommendation | what you would do first, and why |

Same fields in the same order on every card. A reader who has read card one can read card nine.

## Writing for a person

- Lead with the verdict, then the evidence.
- One idea per line. A sentence that needs a second read is a sentence to cut.
- Name things by the name the project uses, not by an internal identifier.
- Show a number with its unit and its source, or leave the number out.
- Put a caveat next to what it applies to, not in a closing section nobody reaches.
- No decoration that carries no information.

## Build it

Read [GUIDE.md](GUIDE.md) for the scaffold, the diagram choices, and the styling that stays legible on a projector and in a terminal browser.

Constraints:

- one self-contained file, no build step, no local assets
- Tailwind and Mermaid from a CDN; hand-drawn divs and inline SVG where Mermaid looks generic
- write to the OS temp directory (`$TMPDIR`, falling back to `/tmp`), never into the repository
- open it for the user, and print the absolute path
- it renders with JavaScript disabled: diagrams fall back to text, nothing else breaks

## Verification

- [ ] the file opens in a browser, and degrades to readable text without JavaScript
- [ ] the summary states the three findings without scrolling
- [ ] every card carries the same fields in the same order
- [ ] every number has a unit and a source
- [ ] the absolute path was printed, and the file sits outside the repository
