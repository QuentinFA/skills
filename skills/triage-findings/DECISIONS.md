# Decisions — triage-findings

Small ADRs: one per issue raised against this skill and settled. Before acting on an issue with
the skill, check here — if it has come up before, the answer and its reasoning are below. Add an
entry whenever an issue is settled, including when the answer is "leave it as is". Supersede
rather than delete.

## With no document named, look in the git common dir

*2026-10-15 · accepted*

**Issue:** review documents now go to `<git-common-dir>/reviews/<target>@<sha7>.md`, outside
the working tree, where nobody browses. A triage started without a path had nothing to find.

**Decision:** with no document named, step 1 takes the newest one for the current branch from
that directory, and updates the document where it is.

**Rejected:** requiring a path every time. The location is fixed, so asking for it adds nothing.
Searching the working tree as well: that would reward the stray copies the convention exists
to stop.
