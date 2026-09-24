---
name: triage-findings
description: Work through a code review's findings with the user — put only the ones that need their decision in front of them, each in three lines, then fix batch by batch with tests first. Use after a review produces a findings document, or for "triage the findings", "go through the review", "what needs me from the review".
---

# Triage findings

A review hands back more findings than a person can hold at once. Most of them do not need the
user: they are plainly right, already fixed, or already answered somewhere in the codebase. The
few that do need them get lost among the rest, and the user ends up re-reading settled work to
find the one question actually addressed to them.

So this skill does two things: **ask only what is the user's to decide, and fix the rest
without asking.**

## 1. Sort the findings

Read them from the findings document itself, by id. For each one, before anything else,
**search the codebase for an existing answer**: a test that pins the behaviour, a decision
record, a comment explaining the shape, a helper that already does the right thing. A finding
the code already answers is usually either wrong or a one-line fix with a known shape.

Then put each finding in one of two piles:

- **Settled** — the fix is clear and changes nothing the user would care to choose: a bug with
  one reasonable fix, a missing test, dead code. These are not questions.
- **Needs the user** — the fix changes behaviour they own (a shipped feature, a UX choice, a
  product rule), or there is more than one defensible fix, or it grows the scope of the work.

Anything the user already ruled on, in this session or in the findings document, is settled.
Don't bring it back.

## 2. Ask, in three lines each

Only the "needs the user" pile, in batches of at most four:

```
F3  <the problem, in one sentence a newcomer to the code would follow>
    Already answered: <where — test, ADR, helper — or "no">
    Fix: <what you would do; name the alternative when there is a real one>
```

Keep it to that. The user can ask for the argument; they cannot un-read a wall of it. Say where
the findings come from once, at the top — the document and round — so nobody wonders.

If the batch holds nothing for them, don't format it as a question. Say it is settled, fix it,
and report it in a line.

When a ruling sets a rule that outlives this change — a reserved value, a behaviour that looks
like a bug but is intended — propose a decision record for it.

## 3. Fix, batch by batch

Once a batch is ruled on, implement it together with the settled findings it touches, then move
to the next batch without stopping to ask whether to continue.

For each fix:

1. **Write the test first** and watch it fail against the current code.
2. **Fix.**
3. **Mutation-check the test**: revert the fix, confirm the test fails, restore it. Judge by the
   exit code — a mutation that no longer compiles looks exactly like a pass.

A finding with no feasible test says so in its report line.

Record each outcome in the findings document — fixed with its commit, declined with the ruling —
so a later session cannot reopen it from the same arguments.

## 4. Report

One line per finding: id, what changed, the test that pins it. Then the open items, if any. Fixes
made in a batch reintroduce earlier defects often enough that a short re-review of the fix delta
is worth offering.
