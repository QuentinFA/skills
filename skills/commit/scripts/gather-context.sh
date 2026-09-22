#!/usr/bin/env bash
# Bundles the read-only checks /commit needs before staging anything.
# Emits a single JSON object so the caller can parse one tool result
# instead of issuing six separate git/gh calls.
#
# Requires: jq (used everywhere gh works, so already a safe assumption).

set -u

fail() {
  jq -n --arg msg "$1" '{error: $msg}'
  exit 0
}

command -v jq >/dev/null 2>&1 || { echo '{"error":"jq not installed"}'; exit 0; }

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  fail "not inside a git working tree"
fi

current_branch=$(git branch --show-current 2>/dev/null || echo "")

default_branch=""
if command -v gh >/dev/null 2>&1; then
  default_branch=$(gh repo view --json defaultBranchRef --jq .defaultBranchRef.name 2>/dev/null || true)
fi
if [ -z "$default_branch" ]; then
  for candidate in main master; do
    if git show-ref --verify --quiet "refs/heads/$candidate"; then
      default_branch="$candidate"
      break
    fi
  done
fi

on_default="false"
if [ -n "$default_branch" ] && [ "$current_branch" = "$default_branch" ]; then
  on_default="true"
fi

convention_file="docs/commit-conventions.md"
if [ -f "$convention_file" ]; then
  convention_arg=(--rawfile commit_convention "$convention_file")
else
  convention_arg=(--arg commit_convention "")
fi

# Capture command output into variables; use --arg/--rawfile to feed jq safely.
git_status=$(git status 2>&1 || true)
git_diff_staged=$(git diff --cached 2>&1 || true)
git_diff_unstaged=$(git diff 2>&1 || true)
recent_commits=$(git log --oneline -n 10 2>/dev/null || true)
untracked=$(git ls-files --others --exclude-standard 2>/dev/null || true)

jq -n \
  --arg current_branch     "$current_branch" \
  --arg default_branch     "$default_branch" \
  --argjson on_default     "$on_default" \
  "${convention_arg[@]}" \
  --arg git_status         "$git_status" \
  --arg git_diff_staged    "$git_diff_staged" \
  --arg git_diff_unstaged  "$git_diff_unstaged" \
  --arg recent_commits     "$recent_commits" \
  --arg untracked          "$untracked" \
  '{
    error: null,
    current_branch:    ($current_branch    | select(length > 0) // null),
    default_branch:    ($default_branch    | select(length > 0) // null),
    on_default_branch: $on_default,
    commit_convention: ($commit_convention | select(length > 0) // null),
    recent_commits:    ($recent_commits    | split("\n") | map(select(length > 0))),
    git_status:        $git_status,
    git_diff_staged:   ($git_diff_staged   | select(length > 0) // null),
    git_diff_unstaged: ($git_diff_unstaged | select(length > 0) // null),
    untracked_files:   ($untracked         | split("\n") | map(select(length > 0)))
  }'
