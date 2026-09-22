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
