---
name: review-angles
description: Run a deep multi-angle adversarial code review of a PR, branch, or diff using independent reviewer subagents, dispatched in priority tiers so the defects that bite in production land before the ones that merely tidy. Use this whenever the user wants a thorough, rigorous, or adversarial review — phrases like "review this PR properly", "deep review", "multi-angle review", "tear this apart", "what did we miss", "review before merge" — or asks for a depth ("quick pass", "just the correctness angles", "the full thing", "tier by tier"). Also use it when a previous review died partway and needs resuming or salvaging.
---

# Multi-angle review

A single reviewer reading a diff top-to-bottom finds the obvious things. A dozen reviewers
who each hunt one *specific class* of defect, and who cannot see each other's conclusions,
find far more — and where several independently land on the same line, that convergence is
a confidence signal no single pass can produce.

Independence is what makes that work, so it is the thing to protect: never tell an angle
what another one found, or what you expect it to find.

## Dispatch by tier

Every angle carries a `priority`. The three tiers ask three different questions, and their
answers differ in what the reader has to *do* about them:

| Tier | Angles | Question it answers | What the answer demands |
|---|---|---|---|
| 1 | 5 | Will this break in production? | Fix before merge. |
| 2 | 5 | Is it built right? | Fix, or accept knowingly. |
| 3 | 4 | Is it clean? | Batch, defer, or decline. |

The tiers are cumulative: tier 2 means 1+2, tier 3 means all of them.

**One tier at a time is the default**, because it keeps those three conversations apart. A
tier-1 list is short and every item on it is actionable now; the same findings mixed in with
naming nits and duplication cleanups read as a wall, and the data-loss bug loses its place in
it. It also means a review that stops early stops somewhere sensible.

Running several tiers at once is a normal request, not a hazard — honour it when asked. What
is worth avoiding is *interleaving* them in one undifferentiated report.

## Workflow

### 1. Establish the target

Resolve what's under review and write the diff to a scratch file every subagent will read:

```bash
git diff main...HEAD > "$SCRATCH/review.diff"   # or origin/main...HEAD, or a PR ref
wc -l "$SCRATCH/review.diff"; git diff --name-only main...HEAD
```

Use `$CLAUDE_JOB_DIR/tmp` if set, else a temp dir. Detect the stack now too (build files,
imports, `CLAUDE.md`) — several angles need it, and doing it once here saves every agent
repeating it.

Resolve base and head to explicit shas and hand those to the angles rather than branch
names. A local `main` is often stale, and a review of the wrong range is worse than none.

Note the size. Under ~500 changed lines, one careful pass is usually better value than a
fan-out; say so rather than running the ceremony anyway.

### 2. Select angles

Each angle is one file in `agents/`. List the directory and read the frontmatter — `name`,
`description` and `priority` are all you need to choose; read a full body only when you're
about to dispatch it.

Take the depth from the user if they give one ("quick pass", "the full thing", "tier 2").
Absent that, propose one from the change: tier 1 for a hotfix or a small targeted change,
tier 2 for most feature work, tier 3 when they want it exhaustive.

**Fit** then prunes within the chosen tiers. A pure refactor doesn't need the security
angle; a docs-only PR needs almost none of them. Six relevant angles beat fourteen run out
of completeness.

Two angles build their checklist at runtime rather than shipping one — they carry
`runtime-checklist: true` in frontmatter. Give them the detected stack and point them at
the repo's own convention docs; a generic version of either is close to worthless.

### 3. Propose the plan, then stop

Present the tiers and **wait for approval before running anything**.

```
14 angles, 3 tiers. Diff: 3,340 lines / 57 files.

  T1  breaks in production   line-by-line · silent-failure · cross-file ·
                             boundary-security · removed-behavior
  T2  built right            framework-pitfall · type-design · pr-test ·
                             comment · altitude
  T3  clean                  convention · efficiency · reuse · simplification

Run tier 1, or all three?
```

Offer both, and take whichever they choose. If they name a depth or a shape ("all at once",
"just the correctness ones"), honour it and re-present rather than re-litigating.

### 4. Run each tier

Dispatch a tier's angles **in a single message** so they run in parallel. For each agent,
pass its `agents/<name>.md` body as the prompt, plus the block from
`references/shared-contract.md` filled in with the target details.

After each tier, report what landed — substance, not raw JSON — then ask before the next.
Between tiers is also the moment to verify a finding or two against the source; it turns
candidates into confirmed defects while the list is still small enough to hold in view.

If the run dies, or the user stops it, go to `references/recovery.md`. A finished agent's
report survives on disk; never re-run an angle that already completed.

### 5. Merge, verify, report

- **Dedupe across angles**, recording how many independently found each item. Convergence is
  the strongest signal available — the orchestrator gets no vote, but six reviewers landing
  on one line means something.
- **Verify the top findings against the source yourself.** Angles are told to surface
  uncertain candidates, so some will be wrong. Mark each `CONFIRMED` (you read it) or
  `PLAUSIBLE` (specific but unverified), and name the step you did not verify.
- **Re-grep every `path:line` before it leaves your hands.** An angle that read the scratch
  diff can only cite the diff's own numbering, so a file that exists solely inside the diff —
  any new file — comes back at a plausible constant offset. The quoted code is correct, so
  nothing reads as wrong until someone opens the file at the stated line and finds unrelated
  code. Every angle reading the shared diff inherits the same offset, so convergence will not
  catch it either.
- **Say plainly what you dropped.** A disproved claim is as useful as a kept one, and it
  stops the next person re-raising it. Include your own: a claim the orchestrator originated
  and then disproved is the most useful kind to name.
- **Group by root cause, not by file.** Four routes to the same stranded flag is one fix,
  not four patches — and a reader working file-by-file will miss that.
- Report via `ReportFindings` if the host supports it, else a ranked markdown list.

Where the repo keeps decision records, check whether a finding is recorded as *deliberate*.
If it is, the code fix needs the record amended in the same change, or the next reviewer
reverts it. A decision record resting on a false premise is worse than wrong code, because
review protects it.

### 6. Prune and propose (briefly)

Once the findings are reported, you hold evidence about the angle set itself that exists
nowhere else. Spend two sentences on it, then move on.

**Retire first.** Name any angle that returned `[]` or produced only duplicates of another
angle's findings. This is the direction nobody ever takes, and it is the more valuable one:
an angle that finds nothing on a change it should have covered has not earned its slot. Two
runs of that is enough to suggest dropping it.

**Propose only from evidence.** The signal is a real finding that **you** turned up during
merge or verification which no angle was hunting for — if the orchestrator had to find it,
the set has a hole. A defect class you can imagine but did not hit is not evidence; neither
is a domain the change didn't touch.

Default to proposing nothing. Most runs should end "angle set held". When you do propose,
give the quarry in one line and check it against the three tests in `README.md` — a specific
quarry, a reason to read beyond the diff, a falsifiable output — then let the user decide.
Never write a new file into `agents/` unasked; the set is theirs, not yours.

## Handing off

**Every run ends with a standalone findings document.** Write it once the merged findings
are reported, without waiting to be asked — a pasted list loses the root-cause grouping, the
confidence markers and the dropped claims the moment it leaves the terminal, which is
exactly when someone else picks it up. See `references/handoff.md` for the structure.

Name it for the change under review, take a path from the invocation args if one was given
(`/review-angles tier 3 --md notes/review.md`), and say plainly whether it lands tracked or
ignored. Skip it only if the user says to.

## Adding an angle

Drop a new `.md` into `agents/` with `name`, `description` and `priority` frontmatter, and a
body written as instructions to the reviewer. It is picked up automatically; nothing else
needs editing. See `README.md` for what makes an angle earn its slot.

## Reference files

- `agents/*.md` — one file per angle. Read frontmatter in step 2, bodies at dispatch.
- `references/shared-contract.md` — the target/output block appended to every angle prompt,
  and why each constraint is there. Read before step 4.
- `references/recovery.md` — recovering reports from a run that died or was stopped. Read
  when that happens, not before.
- `references/handoff.md` — structure for the standalone findings document. Read before
  writing it, which is every run.
