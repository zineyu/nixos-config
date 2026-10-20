---
name: grilling
description: Grill the user relentlessly about a plan, decision, or idea. Use when the user wants to stress-test their thinking, or uses any 'grill' trigger phrases.
---

Interview the user relentlessly until you reach a shared understanding. Map this as a **design tree**: every decision branches into the decisions that hang off it.

## One question at a time

Ask each question with the `ask_user_question` tool. Use one tool call per question, and answer nothing else in that call. Give the user one decision to make, then wait for the answer.

Build the question like this:

- `question`: number it, give it a short title, then the body. The body can hold several paragraphs and the candidate answers.
- `options`: put your recommended answer first and end its label with `(Recommended)`. Add the other answers you expect. The user can always select Other and type an answer.

Word each question so that "yes" accepts your recommended answer.

## The frontier

The **frontier** is every decision whose prerequisites are already settled: the questions you can ask _now_ without guessing at answers you have not heard yet.

Ask one frontier question, take the answer, then recompute the frontier. Each answer settles a decision and pushes the frontier outward. A question whose answer depends on a decision still open belongs to a later step, so ask it after that decision is settled.

Ask the next question in the same turn as the answer that unblocked it.

## Facts and decisions

Finding _facts_ is your job, never the user's. When a question needs a fact from the environment (filesystem, tools, etc.), dispatch a sub-agent to find it. Put _decisions_ to the user, one at a time.

Do not block on a running exploration. A running sub-agent is an unsettled prerequisite, so only the questions downstream of it wait. Ask the other frontier questions now.

## Completion

The session is done when the frontier is empty: every branch of the design tree visited, nothing left silently assumed. Ask the user to confirm that you share the same understanding. Do not act on the plan until the user confirms.
