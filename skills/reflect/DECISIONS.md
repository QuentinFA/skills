# Decisions — reflect

Small ADRs: one per issue raised against this skill and settled. Before acting on an issue with
the skill, check here — if it has come up before, the answer and its reasoning are below. Add an
entry whenever an issue is settled, including when the answer is "leave it as is". Supersede
rather than delete.

## Bundled files are referenced relative to the skill directory

*2026-09-21 · accepted*

**Issue:** `SKILL.md` told the subagent to read `~/.claude/skills/reflect/reflect-agent.md`, a
path that only exists under the symlink install.

**Decision:** pass `reflect-agent.md` as an absolute path resolved from the skill's own
directory.

**Rejected:** keeping the hardcoded path — under a plugin or skills.sh install the subagent would
be handed a path that doesn't exist. Same issue as the matching entry in `commit`.

## Routing comes before extracting, and memory is one home among several

*2026-09-22 · accepted*

**Issue:** a reflection pass over a 37-finding review filed two skill *defects* as `reference`
memories — a wrong instruction in `review-angles`' shared contract, and a self-contradiction in
`orca-review`'s debate protocol. As memory they help only if a future session happens to recall
them, while the skills stay broken for every run. Worse, once the skills were fixed the memories
turned false, and would send a future session to fix what is already fixed. The user had to ask
"no improvement to the skills?" to surface it.

**Decision:** the agent decides *where* each learning belongs — commonly a skill, a repo decision
record, the repo itself, or memory — before it applies the memory bars. Non-memory learnings are
reported under `BELONGS ELSEWHERE`; the agent never touches the repo itself. The listed homes are
not a closed set: when none fits, the agent names one and says why.

**Rejected:** memory as the only destination, which is what produced the mis-filing. A closed
set of homes — it force-fits into memory, the one home that accepts anything; in the same
session an SSRF-guard verification that belonged in a repo test landed under
`OFFERED, NOT SAVED`, where it read as declined. Letting the agent fix the skill itself — it is
spawned cold and read-only on the repo by design, and a cold agent editing a skill it has only
just met is a worse trade than one extra hop through the parent.

## Skill proposals come from operations, not from candidates

*2026-09-22 · accepted*

**Issue:** a session can work out a repeatable multi-step operation that no skill covers, and
reflection had no route for it other than memory.

**Decision:** the agent may propose **at most one** skill per pass, and never creates it. The bar
mirrors an angle's in `review-angles`: ran end-to-end, steps derived rather than recalled, and a
real cost to getting it wrong. `SKILL.md` asks the parent to name the operations it had to work
out for itself.

**Rejected:** inferring operations from the transcript alone — the agent sees steps being
performed but cannot tell improvisation from a skill being followed; only the parent knows.
Proposing freely — a skill proposed from one convenient occurrence is the over-saving failure the
memory bars exist to prevent, one level up. The default is none.

**Consequences:** tested on the session that prompted this entry, the rule proposed nothing and
routed its best candidate into `commit` as an addition rather than a new skill.
