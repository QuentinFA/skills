# Recovery

How to handle a run that was stopped or died, and how to get the finished work back.

## When the user stops the run

"Stop", "pause the agents", or a bare status number means **stop now**. Kill running agents in
the same turn, before finishing any analysis or writing a summary. Then salvage.

Stopping is reversible — a killed angle can be re-run later — so there is no reason to let a
tier finish out of tidiness once the user has asked for it to end.

## Salvaging a dead run

Agents that **finished** still have their full reports on disk, even if the run as a whole
died. Always recover before re-running anything — this routinely rescues most of a review.

Transcripts live one JSONL file per agent at:

```
/tmp/claude-<uid>/<project-slug>/<session-uuid>/tasks/<agentId>.output
```

`<uid>` is `id -u`; on macOS `/tmp` resolves to `/private/tmp`.

An agent's report is the **last assistant text block in its own file**:

```python
import json, glob
for f in sorted(glob.glob('a*.output')):
    last = None
    for line in open(f, errors='replace'):
        try: r = json.loads(line)
        except: continue
        m = r.get('message') or {}
        if m.get('role') == 'assistant':
            c = m.get('content')
            if isinstance(c, list):
                t = ' '.join(b.get('text','') for b in c if b.get('type')=='text').strip()
                if t: last = t
    print('###', f); print((last or '(none)')[:300])
```

A dead agent's last assistant text is the error string itself, which is how to tell finished
from dead at a glance.

Three traps worth knowing before you go looking:

- **The parent's transcript does not contain its children's reports.** Searching it for
  `Task` tool-use blocks returns nothing — children are separate files in the same
  directory. Read each child.
- **Do not grep for finding-shaped strings** (`CONFIRMED`, `ReportFindings`, `summary`) to
  detect real output. Those appear in the prompt embedded on line 1 of every transcript, so
  every file matches. Match on the last assistant message instead.
- **Never `Read` or `cat` a raw transcript.** They run to megabytes of JSONL and will
  overflow context. Extract programmatically.

A finished agent's report can also lag its completion notification, so if a just-finished
agent looks empty, wait and re-read before concluding it died.

The original prompts are recoverable the same way — the first `user` message longer than
~200 characters — which lets you re-run exactly the angles that died rather than
reconstructing them from memory.

## Resuming

After salvage, report the state plainly before proposing anything:

```
10 of 14 angles complete (8 recovered from the dead run, 2 re-run).
Missing: framework pitfalls, type design, comment accuracy, altitude.
```

Then propose only what is missing. Re-running a completed angle produces near-duplicate
findings that make the merge harder, not better — and it inflates the convergence count,
which is the one signal the merge actually depends on.
