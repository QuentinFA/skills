---
name: commit
description: Stage and commit only the changes that are in scope for the current logical change, on a feature branch (auto-create one if on the default branch), with a message that follows the project's commit convention if one exists. Always invoke this skill whenever the user types /commit or asks to commit, check in, save changes, or stage and commit — even for short asks like "commit this" or "save changes".
---

# /commit

Goal: produce a clean, scoped commit on a feature branch with a message that matches the project's convention. The output of /commit should look like something a careful human would have written by hand.

## Workflow

### 1. Gather context (one call)

Run the bundled gathering script — it replaces six separate read-only calls with one. It lives
next to this SKILL.md, so resolve `<skill-dir>` to the directory this file is in and call it by
absolute path (it is not on `PATH`):

```bash
<skill-dir>/scripts/gather-context.sh
```

It emits a single JSON object with these fields:

| field | meaning |
| --- | --- |
| `error` | non-null string if not in a git repo or `jq` is missing — stop and report |
| `current_branch` | branch name, or `null` if detached HEAD |
| `default_branch` | resolved via `gh`, falling back to `main`/`master` |
| `on_default_branch` | `true` means you must create a feature branch before committing |
| `commit_convention` | contents of `docs/commit-conventions.md`, or `null` if absent |
| `recent_commits` | last 10 subjects (array), useful for inferring tone and scope |
| `git_status` | `git status` output |
| `git_diff_staged` | staged diff, or `null` |
| `git_diff_unstaged` | unstaged diff, or `null` |
| `untracked_files` | list of untracked paths |

Drive steps 2–4 from this single result. Only fall back to ad-hoc `git` calls if you need something the script didn't surface (e.g. a per-file diff, a longer history window).

### 2. Branch check

If `on_default_branch` is `true`, you cannot commit on it — committing to `main`/`master` directly is almost always wrong. Create a feature branch first, using the convention:

```
<type>/<scope>-<topic>
```

Examples seen in practice: `refactor/search-index-batching`, `feat/payment-webhook`, `fix/null-pointer-on-cart`, `docs/onboarding-guide`.

Infer `<type>`, `<scope>`, and `<topic>` from the diff *and* the conversation context. The conversation usually pins down two of the three (e.g. user has been discussing a refactor of the auth module → `<type>=refactor`, `<scope>=auth`). Ask the user only when something is genuinely ambiguous; don't ask three questions when one will do.

Confirm the planned branch name before running `git checkout -b <name>`.

If already on a feature branch, skip this step.

### 3. Apply the commit convention

If `commit_convention` is non-null, it is authoritative — follow it exactly for format, allowed `<scope>` values, allowed `<type>` values, casing, and any examples. Cross-check against `recent_commits` for any unwritten conventions (subject casing, body style).

If it is null, use this default format:

```
<scope> (<type>): <short description>

<body explaining why, wrapped at ~72 chars>

<Closes #NNN if applicable>

Co-Authored-By: Claude <model> <noreply@anthropic.com>
```

Subject is imperative ("add X", "fix Y"), lowercase description, < 72 characters, no trailing period.

### 4. Identify what's in scope

Read `git_status`, `git_diff_staged`, `git_diff_unstaged`, and `untracked_files` together. Read the actual diff content, not just filenames — the goal is to commit one logical change, not "everything that's modified".

Three cases:

- **One coherent change**: the whole diff serves one purpose (one feature / one fix / one refactor across N files). Stage all of it by name.
- **Mixed concerns**: working tree has unrelated WIP from different threads. Pick the most coherent subset, stage only that, leave the rest unstaged. If it's not obvious which subset belongs together, briefly ask the user — don't guess.
- **Nothing changed**: tell the user there's nothing to commit, stop.

Stage specific files with `git add path/to/file ...` — **never** `git add .` or `git add -A`. Those bring in unrelated WIP and risk staging secrets.

### 5. Draft the commit message

**Subject** — per the convention from step 3.

**Body** — explain *why* the change was made, not what (the diff already shows what). One short paragraph for small changes, multi-paragraph or structured for substantial ones. Wrap around 72 chars.

**Issue trailer** — if the conversation context already names an issue we're working on, end the body with `Closes #NNN` (issue resolved by this commit) or `Refs #NNN` (partial progress). If no issue is known and the work seems issue-worthy, ask the user briefly — don't fabricate one.

**Co-Authored-By trailer** — always include:

```
Co-Authored-By: Claude <model> <noreply@anthropic.com>
```

Substitute your active model identifier (e.g. `Claude Opus 4.7`, `Claude Sonnet 4.6`).

### 6. Show, confirm, commit

Show the planned commit message (subject + body + trailers) before running `git commit`. On the **first** /commit of a session, get explicit approval from the user. Subsequent /commit calls in the same session can proceed without re-confirming, unless the user has indicated they want to review every one.

Use HEREDOC to preserve formatting:

```bash
git commit -m "$(cat <<'EOF'
<scope> (<type>): <short description>

<body>

Closes #NNN

Co-Authored-By: Claude <model> <noreply@anthropic.com>
EOF
)"
```

Run `git status` afterwards to verify the commit landed.

## Don'ts

- Never `--no-verify`. If a pre-commit hook fails, fix the underlying issue and create a NEW commit; don't bypass.
- Never `--amend` an already-pushed commit (rewrites history; project conventions usually forbid this).
- Never `git add .` or `git add -A`. Always stage by name.
- Never stage files that look like secrets (`.env`, `*.pem`, `credentials*`, `*.key`) even if the user is rushing — warn first.
- Never fabricate an issue number for the trailer. If you don't know, ask or omit.
