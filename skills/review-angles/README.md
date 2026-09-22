# review-angles

Multi-angle adversarial code review, dispatched in priority tiers so the defects that bite in
production land before the ones that merely tidy.

```
review-angles/
├── SKILL.md                     orchestration: select, plan, dispatch, merge
├── agents/                      one file per angle — drop in a new one to extend
│   ├── line-by-line-scanner.md
│   ├── cross-file-tracer.md
│   ├── silent-failure-hunter.md
│   ├── boundary-security-auditor.md
│   ├── framework-pitfall-hunter.md
│   ├── type-design-analyzer.md
│   ├── removed-behavior-auditor.md
│   ├── pr-test-analyzer.md
│   ├── altitude-analyzer.md
│   ├── comment-analyzer.md
│   ├── efficiency-analyzer.md
│   ├── reuse-analyzer.md
│   ├── simplification-analyzer.md
│   └── convention-compliance-checker.md
└── references/
    ├── shared-contract.md       target + output block appended to every angle
    ├── recovery.md              stopping a run, salvaging a dead one, resuming
    └── handoff.md               structure for a standalone findings document
```

The agent file format matches `anthropics/claude-code`'s `plugins/pr-review-toolkit`, so any
angle here can be promoted to a first-class agent or shipped as a plugin by copying the file
— no rewriting. They live inside the skill rather than in `~/.claude/agents/` deliberately:
agents in that directory are listed in every session in every project, and fourteen of them
is a permanent context cost for a tool used occasionally.

## Adding an angle

Create `agents/<name>.md`:

```markdown
---
name: my-new-angle
description: One sentence on what this angle hunts — used when selecting angles for a change.
model: inherit
color: blue
priority: 2
---

You are ... <instructions to the reviewer>
```

Add `runtime-checklist: true` if the angle must derive its checklist from the detected stack
or the repo's own docs rather than shipping a fixed one.

Nothing else needs editing — `SKILL.md` discovers the directory.

## Choosing a priority

`priority` is both the depth tier and the dispatch order, so placing a new angle correctly
matters more than it looks — it decides whether the angle runs in a quick pass at all, and
whether an early stop keeps its findings.

The tiers separate on **who gets bitten, and when**. Apply that test rather than a sense of
importance; every angle feels important to whoever wrote it.

| | Bites | Examples |
|---|---|---|
| **1** | A user or operator, now. Live defects. | correctness, integration seams, error handling, trust boundaries, behaviour silently removed |
| **2** | The next person to touch the code. Future defects. | weak invariants, wrong depth, docs that lie, tests that don't catch regressions, stack traps |
| **3** | Nobody directly. Debt. | cost, duplication, excess machinery, house style |

Two placement traps worth knowing:

- **Cost is not breakage.** An efficiency finding belongs at 3 even when the number is
  large — unless it degrades into an availability problem under normal load, which makes it
  a 1.
- **"Documentation" is not automatically 3.** A false premise recorded in a decision record
  protects a bug from future reviewers, which is why `comment-analyzer` sits at 2 rather
  than with house style.

Current spread is 5 / 5 / 4, which is also the dispatch shape: one tier per batch. If a tier
drifts much past six, it is worth asking whether two of its angles have converged.

## What makes an angle earn its slot

The angles that consistently pay for themselves share three properties.

**A specific quarry.** "Review this code" produces the same findings a general pass already
gets. "Find errors that get swallowed" produces things nothing else sees. If a new angle's
description could be swapped with an existing one without changing what it finds, it is a
duplicate.

**A reason to read beyond the diff.** The highest-yield angles all force the reviewer
somewhere the diff does not go — the full enclosing function, the callers, the schema, the
repo's own docs. An angle that only reads the hunks will mostly restate the line-by-line
scanner.

**A falsifiable output.** Requiring a concrete failure scenario — inputs and state producing
a wrong result — is what stops an angle generating plausible-sounding advice. If a new angle
cannot produce that shape, it is probably a style preference rather than a review angle.

Verify a new angle by running it alongside the existing set on a diff you already know. If it
returns only things another angle already found, it is worse than idle — a duplicate inflates
the convergence count, which is the one signal the merge actually depends on.

## Prior art

The angle-as-agent structure follows
[pr-review-toolkit](https://github.com/anthropics/claude-code/tree/main/plugins/pr-review-toolkit).
`silent-failure-hunter`, `type-design-analyzer` and `comment-analyzer` are adapted from its
agents of the same names; the rest are additions, and the tier dispatch and salvage
procedure are specific to this skill.
