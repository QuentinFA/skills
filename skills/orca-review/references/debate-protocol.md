# Debate protocol

The debate exists because the two sides are wrong in different ways. The blind reviewer
lacks the implementer's context and will assert things the codebase already disproves. The
implementer knows why every line is there and will defend choices that are genuinely
wrong. Neither is a reliable judge alone; the exchange is what separates them.

## Reviewer obligations — put these in the dispatch spec

The reviewer is a dispatched worker and must be told, in its spec:

- Produce findings with **stable ids** and a **document at the report path**.
- Report with `worker_done --outcome succeeded --report-path <file>`, not by printing.
- Mark each finding **CONFIRMED** (read the source and reproduced the reasoning) or
  **PLAUSIBLE** (specific but with a named unverified step). A finding whose unverified
  step is "I did not run it" is the one most likely to lose the debate.
- Expect one message carrying a verdict for every finding, and answer every id in the same
  one-line-per-id shape: **ok** (the response settles it), **hold** (with new evidence), or
  **withdraw** (the refutation settles it). Do not wait for a message per finding — see
  *Response format* for why there isn't one.
- Do not fix anything. The reviewer reviews.

Do not tell the reviewer what you expect it to find, what a previous round concluded, or
why the code is shaped as it is. That is the isolation the whole skill is for.

## Response format

**One message, every finding, one line per id.** Threading the exchange per finding does not
work: the reviewer reports with `worker_done`, which settles its dispatch and closes the
per-finding channel along with it, so a `--thread-id` message sent afterwards reaches nobody.
Batch the verdicts and have the reviewer reply in the same shape — a finding nobody answered is
then visible as an id missing from the reply, which is the affordance threads would have given.

```
A1  accept
A2  already-fixed — 1daeec3
B1  refute — ImageBackfillServiceTest.retriesFourTimes passes unmodified on this sha;
             it asserts exactly 4 requests. Ran: ./gradlew test --tests '*ImageBackfill*'
B4  refute — prose only, no test covers this           ← NOT a refutation; this is a deadlock
```

The reviewer answers in the same shape: `A1 ok`, `B1 withdraw`, `B4 hold — <new evidence>`.

## What counts as executable evidence

It has to be something that *ran*, with its result:

- A test by name, whether it passes or fails, and the command that ran it.
- A command and its actual output — a query and its rows, a `grep -c` and its number, a
  `curl -i` and its status line.
- A measurement, with how it was taken.

What does not count, however confident it sounds:

- A reading of the source. Both sides can read; that is how the disagreement started.
- "That branch is unreachable" / "that cannot be null" without something that demonstrates
  it. These are exactly the claims that turn out to be wrong.
- Convergence — "four reviewers agreed". Reviewers who all read rather than execute share
  a blind spot, so agreement among them is not independent evidence.

**Worked example of why this rule exists.** A multi-angle review reported that a retry
annotation could never fire, because the body wrapped every failure in a type its retry
condition could not match. Four independent angles converged; it was marked CONFIRMED; it was
implemented. An existing integration test asserting an exact request count of 4 had been
passing unmodified the whole time, and the "fix" made it 16. The test was right and every
reviewer was wrong, because all of them reasoned from source and none of them ran it.

If neither side can produce something executable, the finding is **open-for-decision**. Say
so rather than letting the more fluent argument win.

## Bounding the round

One exchange per finding: your response, the reviewer's reply, done. Each finding lands as
accepted, refuted, already-fixed, or open-for-decision.

Do not open a third round to "resolve the remaining disagreements". Two models arguing past
the evidence converge on the last thing said, which reads as consensus and carries none of
its value. An open finding escalated to the user is a better outcome than a settled one
nobody can justify.

## Marking up the findings document

The document is the durable artifact; the debate is worthless if it only exists in a
terminal. Annotate each finding in place:

- `ACCEPTED` — stands as written.
- `REFUTED — <the evidence>` — keep the original claim visible. A disproved finding is as
  useful as a kept one; it stops the next reviewer raising it again.
- `ALREADY-FIXED — <sha>`.
- `OPEN — <both positions, what would settle it>` while it is with the user.
- `DECIDED — <the user's ruling>` once they have ruled. Keep both positions above it: the
  ruling is the outcome, the disagreement is why it needed one, and a later session reading
  only the verdict will reopen the same argument.

Record the sha the review was performed against at the top. Findings are about a commit,
not about a branch, and the branch moves.
