# Decisions — commit

Small ADRs: one per issue raised against this skill and settled. Before acting on an issue with
the skill, check here — if it has come up before, the answer and its reasoning are below. Add an
entry whenever an issue is settled, including when the answer is "leave it as is". Supersede
rather than delete.

## Bundled files are referenced relative to the skill directory

*2026-09-21 · accepted*

**Issue:** `SKILL.md` called its script as `~/.claude/skills/commit/scripts/gather-context.sh`,
a path that only exists under the symlink install.

**Decision:** reference it as `<skill-dir>/scripts/gather-context.sh`, resolved to the directory
containing `SKILL.md`.

**Rejected:** keeping the hardcoded path. Under a plugin install the skill lives in
`~/.claude/plugins/cache/...`, under skills.sh in `~/.agents/skills/...`, so the script would be
silently unreachable under either.

## A root commit goes to the default branch

*2026-09-22 · accepted, not yet in `SKILL.md`*

**Issue:** on a repo with no commits, step 2's rule — always branch off the default branch —
leaves the default branch unborn.

**Decision:** a root commit is made directly on the default branch; branching applies from the
second commit on.

**Rejected:** branching uniformly. A zero-commit default branch gives a future PR no base to
diff against.

**Consequences:** step 2 still reads as unconditional. The context script only avoids it by
accident: with no remote, `default_branch` resolves to `null`, so `on_default_branch` comes back
`false`. With a remote configured, the skill will branch.
