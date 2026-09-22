---
name: reflect
description: >-
  Extract durable knowledge from this session into your file-based memory, and prune
  memory the session proved wrong. Use when work wraps up, or when the user asks you to
  remember, save, record, note, or jot something down for next time — a preference or
  correction they've repeated, a decision they don't want to re-argue, a hard-won bug
  fix, or non-obvious knowledge of how a system works. Also fires on "anything worth
  saving?", "what did we learn?", "reflect on the session", "update memory from this
  session", "is what you remembered still right?", "clean up stale memories", or
  /reflect — and proactively when a session produced durable, non-obvious learnings.
  Writes to your private memory, not the repo: not README/docs, code comments,
  settings/config, commits, or throwaway standup/retro summaries.
---

# Reflect

Turn what this session taught you into memory that outlives it — and correct the memory
it proved wrong. This skill owns the *judgment* and the *delegation*. It does **not**
redefine the memory format: file layout, frontmatter, and memory types live in your
global memory instructions, which stay authoritative for mechanics.

## Delegate the whole pass — always

**Run the reflection in a fresh `general-purpose` agent. Never a fork, never inline.**

Reflection fires exactly when context is fullest — end of a long session — and it is
read-heavy: the transcript, the memory index, every memory file it touches. Doing that
in your own context is what triggers an unexpected compact, and a compact mid-reflection
loses the very details you were trying to save. A fork inherits your context and so
inherits the problem. A cold `general-purpose` agent pays the read cost from its own
budget and hands you back a short report.

The cold agent's one weakness is that it starts with no memory of the session. You close
that gap with the brief below — which costs you nothing new, since you already hold all
of it.

Launch exactly one agent and wait for its report. Don't start other work meanwhile.

### The brief

Pass all five. Items 3–5 are the ones only you can supply:

1. **Point it at its instructions.** Tell it to read `reflect-agent.md` — the file next to this
   SKILL.md, passed as an absolute path — first, and follow it exactly.
2. **The working directory** of this session, so it can find the transcript.
3. **The absolute path to the memory directory**, copied from your own memory
   instructions. Don't make it guess.
4. **The memory conventions, pasted verbatim** — the whole `# Memory` section of your
   system instructions, including the frontmatter template and the type definitions. A
   fresh agent may not receive them, and an agent inventing its own format writes files
   your next session can't use. Paste; don't paraphrase.
5. **A seed brief** — your own candidate learnings, in bullets:
   - Corrections the user made, **quoted verbatim**, and what they were correcting.
   - Decisions reached, and the reasoning that settled them.
   - Anything you noticed contradicting a memory that was recalled this session.
   - Which memory files were surfaced to you this session, by filename.
   - **Anything a subagent found that you never relayed.** What you passed on to the user
     is in the transcript; the rest of an agent's report isn't, and the raw copies in
     `/tmp` get cleared. Usually nothing — mention it only when a delegated finding
     mattered and you summarized it away.
   - **Operations you had to work out for yourself.** A multi-step procedure you derived
     rather than recalled from a skill. The agent reads a transcript and cannot tell those
     apart — it sees you performing the steps either way — so if you don't name them, the
     skill proposal it owes you has nothing to work from.
   - **The last turn or two, in full.** The transcript on disk lags the live session —
     a message the user sent moments ago is very likely not written yet, and you are the
     only source for it. Corrections arrive late; this is where they'll be.

   Frame these as candidates to verify and extend, not conclusions. The agent reads the
   transcript to confirm, expand, and — importantly — to catch what you overlooked.
   Don't pre-filter aggressively; the agent applies the bars.

Everything else — how to sweep, where a learning belongs, what clears the bar, how to
prune — lives in `reflect-agent.md`. Don't restate it in the brief.

### Fallback

If no transcript can be found for this session, the agent will say so in its report.
Only then run the pass inline yourself, following `reflect-agent.md`, working from your
own context — and tell the user the reflection ran without transcript backing.

## Relay the result

The agent's report never reaches the user on its own. Relay it, keeping its shape:
**Saved / Updated / Pruned / Corrected / Belongs-elsewhere / Skill-proposed /
Offered-not-saved**, one line each with the filename. Keep it short.

Three parts to surface rather than trim:

- **Belongs elsewhere** — the learnings whose home is a skill, a decision record, a test, a
  hook, or something the agent had to name for itself. These are the only ones the user can
  act on *today*, and the agent is barred from acting on them itself, so trimming this
  section strands the work. A skill defect left in memory keeps costing every future run.
- **Corrected and Pruned** — a session that contradicted stored memory is the most
  useful thing you can tell the user, and deletions are theirs to veto.
- **Offered, not saved** — the borderline candidates the agent declined, so the user can
  pull one back in. Don't save these unprompted; over-saving is the main failure mode.
