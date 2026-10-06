# Decisions — pr

Small ADRs: one per issue raised against this skill and settled. Before acting on an issue with
the skill, check here — if it has come up before, the answer and its reasoning are below. Add an
entry whenever an issue is settled, including when the answer is "leave it as is". Supersede
rather than delete.

## The `Co-Authored-By` trailer is the only attribution

Raised after the `🤖 Generated with [Claude Code]` line reached PR bodies a third and fourth
time (roast-rover #210, then #223 and #226 in one session).

It keeps recurring because a harness system-reminder actively instructs it, so the model is
following a live instruction rather than forgetting a rule. Memory could not hold the line:
the rule was in the user's memory the whole time, but the index entry that gets loaded had
been compacted down to "keep PR bodies commit-quality" and the clause was lost.

Settled: the skill forbids it explicitly, at the trailer instruction, naming the reminder so
the conflict is resolved at the point of use. A PR body becomes the squash commit message, so
anything added there is permanent in `git log`.
