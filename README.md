# skills

Personal Claude Code skills, installable as a plugin, with skills.sh, or by symlink.

```
.claude-plugin/   plugin + self-hosted marketplace manifests
skills/           one directory per skill: SKILL.md, DECISIONS.md, supporting files
install.sh        symlinks them into ~/.claude/skills
CLAUDE.md         instructions for sessions working in this repo
```

## Skills

| skill | what it does |
| --- | --- |
| `commit` | Stage and commit only the in-scope changes, on a feature branch, in the project's commit convention. |
| `pr` | Open a PR whose title and body follow the same format as a commit message. |
| `recap` | Recap session state on re-entry, verified against the repo rather than recalled. |
| `reflect` | Extract durable knowledge from a session into file-based memory, and prune what it disproved. |
| `review-angles` | Deep multi-angle adversarial review via reviewer subagents, dispatched in priority tiers. |
| `orca-review` | Review from a separate Orca session that never saw the code, then a bounded debate with the implementing session. |
| `triage-findings` | Put only the review findings that need the user in front of them, three lines each, then fix batch by batch with tests first. |

## Install

### Symlinks (live editing)

Each skill is symlinked into `~/.claude/skills`, so an edit in the repo takes effect in the next
session with no sync step, and skills keep their bare names (`/commit`, not `/qfa-skills:commit`).

```bash
./install.sh --dry-run   # show what would change
./install.sh             # link
```

It never clobbers a real file or directory, and re-points its own stale symlinks only with
`--force`.

### Plugin

```
/plugin marketplace add QuentinFA/skills
/plugin install qfa-skills@qfa-skills
```

Updates via `/plugin update`. Skills are namespaced under the plugin name
(`/qfa-skills:commit`).

### skills.sh

```bash
npx skills add QuentinFA/skills
```

Keeps bare names and works across other agent CLIs. The plugin layout here is deliberately
compatible with both readers.

Use one install method at a time; combining them loads each skill twice under different names.

## Adding a skill

Create `skills/<name>/SKILL.md` with `name` and `description` frontmatter, then run
`./install.sh`. The description is what the model matches on to decide when to fire, so write it
for triggering, not for documentation.

Reference bundled files relative to the skill's own directory rather than `~/.claude/skills/...`
— that path only exists under the symlink install, not under a plugin or skills.sh install.

## Decisions

Each skill carries a `DECISIONS.md` of small ADRs: one entry per issue raised against the skill
and settled. When something about a skill looks wrong, check its file first. If the issue has
come up before, the answer and its reasoning are there, and it doesn't need deciding again.

Write an entry when an issue is raised and judged — including when the answer is "leave it as
is", since those are the ones most likely to be raised again. Each entry states the **Issue**,
the **Decision**, what was **Rejected** and why, and any **Consequences**. Don't use the file to
describe the skill's design for its own sake; that belongs in `SKILL.md`, and an entry nobody
raised an issue about is just a second copy of it.

Supersede rather than delete: a reversal is only legible next to the reasoning it overturned.

These files cost nothing to keep: only a skill's frontmatter `description` is loaded every
session, and the rest of its directory is read only when something opens it.
