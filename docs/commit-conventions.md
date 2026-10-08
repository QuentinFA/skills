# Commit conventions

Commits and pull request titles share one format. PRs are squash-merged, so a PR's title becomes
the commit subject and its body the commit body: write both to this standard.

## Format

```
<scope> (<type>): <description>

<body: why the change was made>

Co-Authored-By: <name> <email>
```

## Scopes

One scope per commit: the unit the change is about.

| Scope | Covers |
| --- | --- |
| `<skill>` | one skill under `skills/<skill>/`: `commit`, `pr`, `recap`, `reflect`, `review-angles`, `orca-review`, `triage-findings`, … |
| `<mod>` | one mod under `mods/<mod>/`: `session-outputs`, … |
| `repo` | what no single skill or mod owns: `README.md`, `CLAUDE.md`, `install.sh`, `.claude-plugin/`, `docs/` |

A change that spans several skills or mods is usually several commits. When it is one change — a
rule applied to every skill, a feature that touches a skill, a mod and the installer together —
use `repo` and name the parts in the body.

## Types

| Type | Use for |
| --- | --- |
| `feat` | a new skill or mod, or new behaviour in one |
| `fix` | behaviour that was wrong: an instruction a session misread, a step that failed, a mod that misrecorded |
| `refactor` | restructuring with no change in behaviour |
| `docs` | README, `DECISIONS.md` entries or wording only, with no change in what a session does |
| `test` | tests only |
| `build` | `install.sh`, plugin and marketplace manifests |

A skill's `SKILL.md` is behaviour, not documentation: an instruction that changes what a session
does is `feat` or `fix`, even though the file is markdown. Its `DECISIONS.md` entry rides in the
same commit.

## Description

- Imperative mood: "add", "fix", "route", not "added" or "adds"
- Lowercase, no trailing period
- Under 72 characters, scope and type included

## Body

Explain **why**: the problem, what made it visible, and why this fix over the alternatives. The diff
already shows what changed. Wrap at about 72 characters. Prose paragraphs; bullets when the change
is a list of parallel parts.

End with the `Co-Authored-By` trailer when an agent wrote the change, and `Closes #N` / `Refs #N`
when an issue applies. No "Generated with" line: the trailer is the whole attribution.

## Examples

```
pr (fix): forbid the generated-with-claude-code line
orca-review (fix): wait on the report file, submit an unsent spec
review-angles (feat): add an architecture tier and two angles for designs
orca-review (docs): document answering a reviewer's question
session-outputs (fix): record every commit a command makes
repo (build): list mods in CLAUDE_CODE_PLUGIN_DIRS
repo (feat): add mods, starting with session-outputs
```

With a body:

```
session-outputs (fix): record every commit a command makes

The engine's gitOperation reports one commit per Bash command, the
last, so a command that committed twice lost its first commit. When a
`git commit` command moves HEAD, every commit between the HEAD before
and after it is now recorded, the engine's report labelling the one it
names.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
```
