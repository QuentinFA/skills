---
name: pr
description: Open a pull request to the repo's default branch (or a base specified via --base or natural language) with a title and body that follow the same format as a commit message — they become the squash-merge commit subject and body. If there are uncommitted changes or you're on the default branch, run /commit first to land them on a feature branch. Always invoke this skill whenever the user types /pr or asks to open a PR, create a pull request, or "pr this".
---

# /pr

Goal: ship a focused branch as a pull request whose title and body are commit-quality. Most repos squash-merge, so the PR title becomes the commit subject and the PR body becomes the commit message body — write them as you would a commit, not as a chat-style summary.

## Workflow

### 1. Make the branch and tree PR-ready

```bash
git branch --show-current
git status
```

If on the default branch (resolve via `gh repo view --json defaultBranchRef --jq .defaultBranchRef.name`, fall back to `main`/`master`), or if the working tree has uncommitted changes (staged or unstaged), run the **/commit** workflow first (steps 1–5 of the commit skill). That will:
- create a feature branch if needed (because /commit refuses to run on the default branch)
- commit the in-scope changes with a properly-formatted message

After /commit returns: the branch is a feature branch and the tree is clean. Continue.

If the branch was already a feature branch and the tree was already clean, skip directly to step 2.

### 2. Determine the base branch

Default base: the repo's default branch.

```bash
gh repo view --json defaultBranchRef --jq .defaultBranchRef.name
```

Override: if the invocation passes `--base <branch>` or the user said "PR to develop" / "open it against `staging`", use that. Verify the override actually exists on the remote:

```bash
git ls-remote --heads origin <branch>
```

If the override doesn't exist, stop and tell the user.

### 3. Push the branch if needed

```bash
git rev-parse --abbrev-ref --symbolic-full-name @{upstream} 2>/dev/null
```

- No upstream → `git push -u origin <branch>`.
- Upstream exists, branch is ahead → `git push`.
- Upstream exists, branch is behind → don't force-push; tell the user the remote has commits you don't and ask how to proceed.

Never force-push (`--force`, `--force-with-lease`).

### 4. Build the PR title and body from the full diff

The branch may contain multiple commits. Don't just copy the latest commit message — synthesize a fresh title and body that summarize the **cumulative state** of the branch.

```bash
git log <base>..HEAD --format=fuller       # all commits on the branch
git diff <base>...HEAD                     # full cumulative diff
```

Read the diff. Identify what the branch as a whole accomplishes. Write a single title + body covering all of it.

**Title** — same format as a commit subject:
- If `docs/commit-conventions.md` exists, follow it exactly.
- Otherwise: `<scope> (<type>): <short description>`, imperative, lowercase description, < 72 chars, no trailing period.

**Body** — same conventions as a commit body:
- Explain *why*, not what. Structure by section if the branch covers multiple thematic concerns.
- End with the issue trailer (`Closes #NNN` / `Refs #NNN`) — pulled from conversation context if known, ask the user if unclear, omit if no issue applies.
- Include the trailer:
  ```
  Co-Authored-By: Claude <model> <noreply@anthropic.com>
  ```
  using your active model name.

The PR title and body will be what shows up in `git log` after the squash merge. Write them at that quality.

### 5. Show, confirm, create

Show the planned title and body before running `gh pr create`. On the **first** /pr of a session, get explicit approval. Subsequent /pr calls in the same session can proceed without re-confirming unless the user has indicated otherwise.

```bash
gh pr create --base <base> --title "<title>" --body "$(cat <<'EOF'
<body>
EOF
)"
```

Return the PR URL.

## Don'ts

- Never push directly to the default branch.
- Never force-push (`--force`, `--force-with-lease`).
- Don't reuse a stale earlier draft of the PR body — the body must reflect the current cumulative state of the branch, not the state at first commit.
- Don't open a PR with a draft-quality body intending to "polish at merge time" — the body becomes the commit message; polish before opening.
