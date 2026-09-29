# Architecture review

A decision record or design doc is reviewed before the code exists, which is when a wrong
premise is cheapest to fix. Most angles hunt defects in hunks and have nothing to read in
a design; the ones flagged `architecture: true` still bite, provided they judge the design
against **the code it will change**, not against itself.

## What changes from a code review

- **The target is the design and today's code.** Point each angle at the design's diff and
  tell it the claims are about the current codebase: every "the only writer", "runs inside
  the transaction", "seeded from", "a record is never…" is checked by grepping the repo.
- **A finding cites where it breaks.** `file` is the code path that contradicts the design
  when there is one, else the design doc at the claim's line. The failure scenario is the
  interleaving, record or lifecycle step that the design as written gets wrong.
- **Missing is a finding.** A design is judged as much by what it does not say: a writer it
  never mentions, a record state it has no rule for, a deploy step it assumes.

Append this block to the shared contract, after `TARGET`:

```
MODE: architecture review
The diff is a design (decision record or design doc), not code. Judge each claim it makes
against the current code in the repo — grep for every writer, caller and row it describes.
Report where the design, built as written, would break: cite the code that contradicts it,
or the design's own line when the problem is something it leaves out.
```

## Choosing it

Propose it when the change under review is a design: a new or amended decision record, or a
design doc, on its own. When a PR carries a design and its code together, run the
architecture tier on the design and the numbered tiers on the code, and keep the two
reports apart — a design flaw and a code bug demand different fixes from different people.
