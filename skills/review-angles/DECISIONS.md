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

## Designs get an architecture tier, and two angles for what they get wrong

*2026-09-29 · accepted*

**Issue:** reviewing ADR 0011 (roast-rover #201/#202) showed the skill is diff-shaped: most
angles have nothing to hunt in a decision record. Two ad-hoc angles, concurrency-protocol
and migration-and-lifecycle, briefed to judge the design against the current code, found 14
gaps in one run, all accepted: a backfill seeding corrected values as raw ones, a sweep
split across two commits, a picture with no source to fall back to.

**Decision:** add both as angles, and an architecture tier that dispatches them with the
three existing angles that still bite on a design (comment, framework-pitfall,
removed-behavior), flagged `architecture: true`, with a brief telling them to check each
claim against the code (`references/architecture-review.md`). The two new angles sit at
priority 1 for code reviews too: a race or a data-losing migration bites as soon as it
ships.

**Rejected:** a fourth numbered tier. The numbered tiers are depths and cumulative; a design
review is a different target, and "tier 4 includes 1–3" would make no sense for it.

**Consequences:** tier 1 grows to 7, past the README's "ask whether two converged" line;
accepted because both new angles are fit-pruned away from any change without shared writers
or stored data. The angles are unproven on a code diff; the first two code runs that
include them should be checked for duplicates of cross-file-tracer and line-by-line.

