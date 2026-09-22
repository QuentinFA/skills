# Handoff document

When the findings go to someone else — a dev agent, a colleague, a future session — a
pasted list is not enough. The reader has none of the context that made the findings
legible, and the two failure modes are predictable: they patch symptoms one file at a time,
and they re-derive things you already settled.

Structure the document to prevent both.

## Sections

**How this was produced, and how to read it.** Name the angles that ran, and define the
confidence markers in one line each. Say explicitly that convergence ("found by N angles")
means N reviewers who could not see each other landed on the same line.

**Ground rules.** The repo-specific constraints that change *how* fixes land, not what they
are: force-push and amend policy, commit and PR message format, whether decision records
must be amended alongside code, any standing preference about scope. These are the things a
fresh agent gets wrong first.

**Findings grouped by root cause.** Not by file. Where several findings share one fix, say
so and name the fix once — "four routes to the same stranded flag; one lease-shaped change,
not four patches". A reader working file-by-file will otherwise patch each symptom
separately and miss that they were one bug.

For each finding: location, confidence marker, angle count if more than one, what is wrong,
the concrete failure scenario, and a fix direction. Keep the failure scenario — it is what
lets the reader judge severity without redoing the analysis.

**Checked and cleared.** Things that look like defects and are not: verified non-gaps,
design choices that are actually justified, false alarms already investigated. This section
saves the reader from re-raising them, and it is the one most often omitted.

**Claims dropped during verification.** Anything a reviewer asserted that turned out to be
wrong, and why. Being explicit here matters more than it seems: reviewer output tends to
circulate, and an unretracted bad claim gets treated as fact later.

**Suggested order.** Sequence by severity and dependency, and call out work that needs
something extra — a schema migration, a config change, a test written before the fix.

## Tone

Write for a competent reader who lacks your context, not for someone who needs convincing.
State what is wrong and what it costs; skip the persuasion. Where you are uncertain, say
which specific step you did not verify and what would settle it — that is far more useful
than hedging the whole finding.

Flag anything that goes beyond fixing what is broken — a design improvement, a refactor —
as a suggestion rather than an instruction, and let the owner decide.

## Placement

Put it where it will survive. A file in the repo root is easy to lose to a clean checkout
and invisible to anyone who does not already know it exists; if the findings matter beyond
this session, commit it or say plainly that it is untracked and why that is a risk.
