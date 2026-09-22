# Shared prompt contract

Every angle agent gets its file's body **plus** this contract. The uniform output shape is
what makes merging a tier's independent reports possible.

## Append to every angle prompt

```
TARGET
  Repo:        <absolute repo root>
  Diff:        <absolute path to the pre-generated diff file> (<N> lines)
  Base..head:  <base>...<head>
  Module root: <package/module root, if the language has one>
  Stack:       <detected stack, one line>

Read the diff from the path above — do not run your own `git diff`.
`git diff <base>...<head> -- <path>` is available for reading a single file's changes.

OUTPUT
Return AT MOST 8 candidate findings as a JSON array, each with:
  file              absolute path
  line              int — the line number in the FILE, not in the diff. The diff is a
                    scratch file with its own numbering; a hunk's position in it is not
                    the position in the source. Confirm each one against the working
                    tree — grep for the line you are citing — before reporting it.
  summary           one sentence naming the defect
  failure_scenario  concrete inputs/state -> wrong output, crash, or cost.
                    Quote the offending line.

Prefer 3 real findings to 8 padded ones. If this angle genuinely finds nothing,
return []. Do NOT write any files. Return only the JSON in your final message.
```

## Why these constraints

**A pre-generated diff path.** A dozen agents each running `git diff` is a dozen redundant
subprocesses, and worse, they can disagree if the working tree moves under them.

**File line numbers, not diff line numbers.** This is the constraint agents break most
quietly, and the pre-generated diff is what causes it: reading that file makes its numbering
the only numbering an agent has seen. A file that exists *solely* inside the diff — any new
file — then comes back cited at a plausible-looking constant offset. Nothing reads as wrong,
because the quoted code is correct; it only surfaces when a reader opens the file at the
stated line and finds unrelated code. Every angle reading the shared diff inherits the same
offset, so the convergence check does not catch it, and neither does the orchestrator unless
it re-greps.

**The module root.** Without it agents grep the wrong namespace and waste turns — a
surprisingly large fraction of a run's cost.

**A cap of 8.** Without one, agents pad to look thorough and the merge drowns. Stating that
`[]` is an acceptable answer is what makes the cap real rather than a target.

**"Return only the JSON."** Prose around the array survives into the transcript and makes
programmatic extraction unreliable — which matters when recovering reports from a run that
died.

## What not to add

Do not tell an angle what the other angles found, or what you expect it to find. Seeding a
reviewer destroys the independence that makes convergence meaningful: two agents agreeing
because you told them the answer is worth nothing, while two agents agreeing
independently is the strongest signal the whole method produces.

The one exception is the stack line, which is shared fact rather than conclusion.
