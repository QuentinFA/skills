# Placement

By default the reviewer runs in your worktree (`--worktree current`). It reads; you hold
still. That is the cheapest arrangement and it keeps the reviewer looking at exactly the
tree you are asking about.

Isolation here is about **context, not filesystem**. A fresh session in your own worktree
has never seen the code being written and carries none of your reasoning — which is the
bias the skill exists to remove. A separate checkout adds nothing to that.

## When you need a separate worktree

Only one reason: **you cannot stop working while the review runs.**

A reviewer reading a tree you are editing produces findings against code that no longer
exists, and neither of you can tell those apart from real ones afterwards. If you are going
to keep committing, give the reviewer its own worktree pinned to the sha under review.

```text
orca worktree create --name review-<target> --agent claude --prompt "<spec>"
```

Then dispatch against that worktree rather than `current`. See
`orca skills get orchestration --reference references/placement-and-remote.md` for the
supervised form, and `orca skills get orca-cli` for worktree mechanics.

## What it costs

- **A second checkout**, and a second dev server if the reviewer needs to run
  anything — check what is already on the usual ports before starting one.
- **A shared database.** Two worktrees against one local database is the normal trap: a
  migration on one branch breaks boot on the other, and a background job run from one
  session writes rows the other is reading. If the reviewer needs to *run* the app rather
  than read it, give it a throwaway database rather than the shared one.
- **Divergence.** The reviewer's findings are about its sha. When you have moved on, every
  `already-fixed` response needs a commit named, or the debate turns into bookkeeping.

## The rule either way

Record the sha the review ran against, in the findings document and in the Run objective.
A finding is about a commit. Branches move; that is what makes stale findings look real.
