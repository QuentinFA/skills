# Decisions — orca-review

Small ADRs: one per issue raised against this skill and settled. Before acting on an issue with
the skill, check here — if it has come up before, the answer and its reasoning are below. Add an
entry whenever an issue is settled, including when the answer is "leave it as is". Supersede
rather than delete.

## The debate is one batched message, not a thread per finding

*2026-09-22 · accepted*

**Issue:** the debate protocol sent one message per finding with `--thread-id <finding-id>`, but
the reviewer is told to report with `worker_done`, which settles its dispatch and closes those
channels. The threaded messages reached nobody, silently. Observed on a 37-finding review, where
the coordinator found the channel already closed and batched the round by hand.

**Decision:** the coordinator sends every verdict in one message, one line per finding id, and
the reviewer replies in the same shape. A missing id in the reply is the open finding, which
keeps the one thing threads were for: making an unanswered finding visible.

**Rejected:** per-finding threads — not merely worse but unavailable once `worker_done` fires.
Holding `worker_done` until the debate finishes to keep the threads open — it costs the
coordinator its completion signal and the report path, and leaves a dispatch open across an
exchange that may need the user.

## A settled reviewer is reached through a fresh dispatch, not the run inbox

*2026-09-24 · accepted*

**Issue:** step 3 prescribed `send --to run:<run_id> --dispatch-id <ctx>` for the debate round.
New evidence against it, from three debate rounds on one review: that form posts to the run's
shared inbox, so the coordinator received its own verdicts back as a reply while the reviewer's
transcript never moved. It had been written from a route that works in the other direction — a
settled worker replying to the coordinator. A first workaround, `dispatch` without `--inject`,
recorded the dispatch and delivered nothing; both sides waited.

**Decision:** create a task, dispatch it to the reviewer's terminal, and `send --to
dispatch:<new ctx>`. The `send` delivers; it woke the reviewer within a minute every time. The
earlier entry stands — the round is still one batched message; this changes only its address.

**Rejected:** `--inject` on the new dispatch — it fails while the terminal holds an active
dispatch, and the `send` recovers either way.

**Consequences:** acknowledge each batch with `check --ack`, or an old `worker_done` returns
from `check --wait` looking like a fresh reply.

## Closing the review means closing the reviewer's terminal

*2026-09-24 · accepted*

**Issue:** after the debate settled, the reviewer's terminal was still open. `worker-release`
releases the dispatch but leaves the worker retained, and the user expected the session gone
once the findings were agreed.

**Decision:** step 5 closes the terminal with `orca terminal close` and confirms it is absent
from `orca terminal list`. It stays open only when the user asks, e.g. to reflect on it.

**Rejected:** leaving teardown to the user — they have to notice it first, and a retained
worker is easy to miss.
