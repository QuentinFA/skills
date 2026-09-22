# Decisions — review-angles

Small ADRs: one per issue raised against this skill and settled. Before acting on an issue with
the skill, check here — if it has come up before, the answer and its reasoning are below. Add an
entry whenever an issue is settled, including when the answer is "leave it as is". Supersede
rather than delete.

## Dispatch is by priority tier, not by cost-sized waves

*2026-09-22 · accepted*

**Issue:** the skill sized batches to a rate-limit budget ("never launch all angles at once,
default to 2 per wave"), on the premise that simultaneous ingestion was the cost spike. Three
full 14-at-once runs have since completed, and the one that was measured showed cost tracking
agent count, not diff size: a diff 45% smaller than an earlier run cost ~9% less. The premise
was false.

**Decision:** dispatch one `priority` tier at a time — 5 angles, then 5, then 4 — and say
nothing about token cost, rate limits or budget.

**Rejected:** budget-sized waves. Beyond resting on a false premise, they put the skill in the
business of predicting a limit it cannot see.

**Consequences:** tiers are the better unit regardless of cost — they ask three different
questions whose answers differ in what the reader must do (fix before merge, accept knowingly,
defer), so a review that stops after a tier stops somewhere meaningful. The skill no longer
warns anyone off a large parallel run; running all three tiers at once is a normal request. If
a run dies, `references/recovery.md` still gets the finished reports back.
