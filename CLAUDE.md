# skills

Each skill in `skills/<name>/` carries a `DECISIONS.md` of small ADRs.

- **Before changing a skill, read its `DECISIONS.md`.** If the issue you are about to act on is
  already there, follow the recorded decision rather than deciding it again. Reopen an entry only
  with evidence it didn't have, and say what that evidence is.
- **Once an issue with a skill is settled, add an entry** — Issue, Decision, Rejected,
  Consequences — including when the answer is "leave it as is". Don't record design nobody raised
  an issue about; that belongs in `SKILL.md`.
- **Supersede, don't delete.** Mark the old entry `superseded` and point to the one replacing it.
- A new skill gets a `DECISIONS.md` with the standard header and no entries.

Reference a skill's bundled files relative to its own directory, never through
`~/.claude/skills/...` — that path only exists under the symlink install.

The repo is public. Nothing committed here should identify a local setup or another project: no
user- or machine-specific paths, no project names, no examples lifted from other codebases.
