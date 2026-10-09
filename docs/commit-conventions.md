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
| `repo` | what no single skill owns: `README.md`, `CLAUDE.md`, `install.sh`, `.claude-plugin/`, `docs/` |

A change that spans several skills is usually several commits. When it is one change — a rule
applied to every skill, a feature that touches a skill and the installer together — use `repo`
and name the parts in the body.

## Types

| Type | Use for |
| --- | --- |
| `feat` | a new skill, or new behaviour in one |
| `fix` | behaviour that was wrong: an instruction a session misread, a step that failed |
| `refactor` | restructuring with no change in behaviour |
| `docs` | README, `DECISIONS.md` entries or wording only, with no change in what a session does |
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
reflect (feat): route learnings to mods and allow proposing one
repo (docs): add commit conventions
```

With a body:

```
pr (fix): forbid the generated-with-claude-code line

A harness system-reminder instructs the model to end PR descriptions
with a "Generated with Claude Code" line, so the rule was being
overridden at the moment it applied. The skill is read before every
/pr, so the conflict is resolved where it arises.

A PR body becomes the squash commit message, so anything added there is
permanent in git log.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
```
