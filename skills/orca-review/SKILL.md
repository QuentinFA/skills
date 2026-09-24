---
name: orca-review
description: Run a code review in a separate Orca session that never saw the code being written, then hold a bounded debate between that reviewer and the implementing session, with the user ruling on anything the two cannot settle. Use for "/orca-review <review-skill> [options]", or when a review needs to come from outside the session that did the work.
---

# Orca review

A session that wrote the code is the worst judge of it. It knows what every choice was
*for*, so it reads intent where a stranger reads a bug, and it will not re-derive a thing
it already believes. Dispatching a reviewer that has never seen the work removes that.

Removing it costs something, though: the blind reviewer is also missing everything the
implementer knows — the test that already pins the behaviour, the constraint that forced
the shape, the finding that was fixed an hour ago. A one-way handoff turns that gap into
confident wrong findings that then get implemented.

So this skill is two halves, and the second is the one that gets skipped: **dispatch a
blind reviewer, then make the two argue.**

**The review has three participants, not two.** The reviewer has no stake and no context;
you have both. Neither of you is a neutral judge of a disagreement between you, so where
evidence does not settle a finding, the user rules on it. That is a seat in the review, not
an escape hatch — expect to use it, and bring them something they can decide quickly.

## Invocation

```
/orca-review <review-skill> [options]
```

e.g. `/orca-review review-angles max all at once`

The named skill does the reviewing. This one owns isolation, the debate, and escalation.
Pass `[options]` through **verbatim** — they are the review skill's arguments, not yours.

You are the coordinator *and* the implementing side of the debate. That is deliberate: you
hold the branch and the context the reviewer lacks. It also means you are arguing a case
you are invested in, which is exactly why unresolved findings go to the user rather than to
your own judgement.

## What the review skill must provide

Check before dispatching, and say so plainly if it does not hold:

- **A findings document** at a path it can report back.
- **Individually addressable findings** — stable ids like `A1`, `B2`, or numbers. The
  debate is per finding; without ids there is nothing to argue about one at a time.

If the named skill produces only a chat summary, stop and say so. Running it anyway
produces a debate nobody can hold.

## 1. Prepare, and freeze

Resolve the target the way the review skill expects (branch, PR, diff range) and confirm
the reviewer will be able to see it.

**Freeze the tree.** The reviewer shares your worktree and reads it while you hold it. Do
not edit, rebase, or switch branches from dispatch until the debate closes — a reviewer
reading a moving target produces findings against code that no longer exists, and you will
not be able to tell those from real ones. Note the HEAD sha; the findings are *about* that
sha, and the document should say so.

If you must keep working, place the reviewer in its own worktree instead — see
`references/placement.md`.

## 2. Dispatch the blind reviewer

Confirm the runtime, bind one Run, start one worker:

```text
orca status --json
orca orchestration run-create --objective "blind review of <target> @ <sha>" --json
orca orchestration worker-start --spec "<spec>" --worktree current --agent claude --json
orca orchestration check --wait --types "worker_done,escalation,question" --timeout-ms 3600000 --json
```

**The spec is where isolation is won or lost.** It must name the target, the review skill
and its options, and the report path — and it must carry **none of your rationale**. Do not
explain why the code is shaped the way it is, which findings you expect, or what a previous
round said. Every sentence of justification you add is a sentence the reviewer will not
independently re-derive. Give it the diff and the skill; nothing else.

Set the timeout to match the review, not to a default — a multi-angle run over a large diff
takes tens of minutes. A timeout is a checkpoint, not a failure: keep waiting.

If the worker sits idle right after starting, a prompt in its shell (an update check, a
plugin notice) may have swallowed the first keystroke. Look at the terminal and resend.

## 3. Debate, one exchange per finding

Read the report, and count the findings from the document, not from the `worker_done`
summary — the summary is a paraphrase and drops ids. For each finding, answer with exactly one of:

- **accept** — it is right; it stands.
- **already-fixed** — name the commit. The reviewer read `<sha>`; if it moved, that is your
  bookkeeping error, not their finding.
- **refute** — it is wrong, *and here is the evidence*.

**A refutation must cite something executable.** A passing test by name with its result, a
command and its output, a query and its rows. Not an argument, not a reading of the source,
not "that cannot happen because". This is the one rule the whole round rests on: reviewers
reasoning from source converge on each other's blind spots, and the thing that settles it is
almost always a test that already exists. Prose against prose is not a refutation — it is a
deadlock, and it goes to the user.

**Send every verdict in one message, one line per finding id.** A per-finding `--thread-id`
exchange is not available here: the reviewer's `worker_done` settles its dispatch and closes
that channel with it, so threaded replies after the report lands reach nobody. Have the
reviewer answer in the same shape — an unanswered finding then shows up as an id missing from
the reply, which is what threads would otherwise have told you.

The reviewer's dispatch is settled, so open a fresh one to its terminal and send into that:

```text
orca orchestration task-create --spec "Debate round" --run <run_id> --json
orca orchestration dispatch --task <task_id> --to <reviewer_handle> --run <run_id> --json
orca orchestration send --to dispatch:<new_ctx_id> \
    --subject "Debate round: <n> findings, answer per id" --body "<verdicts>" --json
orca orchestration check --terminal <your_handle> --wait \
    --types "status,escalation,question" --timeout-ms 900000 --json
```

- **The `send` is what delivers.** `dispatch` without `--inject` only records the dispatch;
  the reviewer never sees it, and both sides wait on each other.
- **`--to run:<run_id>` does not reach the reviewer.** It posts to the run's shared inbox, and
  the coordinator reads its own verdicts back as if they were a reply.
- **Acknowledge what you have read** with `check --ack <deliveryId>`. `check --wait` returns
  the oldest unacknowledged batch, so an old `worker_done` otherwise comes back looking new.
  A run allows one waiter at a time.

`check` names its caller with `--terminal`; omit it inside your own Orca terminal. For anything
further, see `orca skills get orchestration`.

**One exchange per finding, then it settles or it deadlocks.** Do not run a third round.
Two models trading arguments converge on whoever spoke last, which feels like agreement and
is not.

Full protocol, including how the reviewer should answer and what a well-formed evidence
citation looks like: `references/debate-protocol.md`.

## 4. Take the open findings to the user

This is the third participant's turn, and an open finding is a normal result rather than a
failure of the round. Give them one compact block per finding: the claim, your evidence,
the reviewer's evidence, and what would settle it. Recommend where you have a view, and say
plainly that you are the invested party — they are reading a case you argued.

Keep it rulable. A user deciding six findings needs six short paragraphs, not the transcript
of the debate; the transcript is in the threads if they want it.

Record each ruling in the findings document. The user's decision settles the finding, and a
later session must not be able to reopen it from the same arguments.

Do not implement anything. A review round produces findings and decisions; acting on them is
separate work the user assigns.

## 5. Settle

Update the findings document in place so it reflects the debate — each finding marked
accepted, refuted with the evidence that refuted it, already-fixed with its commit, or
open-for-decision. A reader picking it up later needs the outcome, not just the claim.

Then release the worker, close its terminal, and report: findings count, accepted, refuted,
already-fixed, open.

```text
orca orchestration worker-release --dispatch <dispatch_id> --json
orca terminal close --terminal <reviewer_handle>
orca terminal list
```

`worker-release` leaves the terminal running; confirm it is gone from the list. Keep it open
only when the user asks — for instance to reflect on the review session before closing it.

**After the findings are fixed, re-review the fix delta.** Fixes made in a batch reintroduce
earlier defects often enough to plan for: a light pass over `<sha>..HEAD` catches them for
a fraction of the first round's cost. Offer it; the user decides.

## Reference files

- `references/debate-protocol.md` — the per-finding exchange format, what counts as
  executable evidence, and the reviewer-side obligations to put in the spec. Read before
  step 3.
- `references/placement.md` — running the reviewer in its own worktree when you cannot
  freeze the tree, and what that costs. Read only if step 1 says you need it.
- Orchestration mechanics — lifecycle, recovery, messaging — belong to the `orchestration`
  skill. Run `orca skills get orchestration` rather than restating them here.
