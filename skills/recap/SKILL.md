---
name: recap
description: Recap the current state of a session for the user on re-entry — what needs their decision, what is running, and where to resume — verified against the repo rather than recalled from the conversation. Use for "/recap", or when the user returns after a break or switches between sessions and needs to get oriented fast.
---

# Recap

A recap is read by someone who has been away — overnight, or in another session. Their
first question is not "what happened here" but **"what needs me, and can I carry on?"**
Answer that, in one screen, and stop.

This is not a summary of the conversation. A chronology of what was discussed is the thing
they came back hoping not to read.

## Verify before reporting

State goes stale while nobody is watching it. Another session merges the PR, moves the
branch, or edits a shared file; CI finishes; a background job dies quietly. None of that is
visible from inside this conversation, and a break is exactly when it accumulates.

So check rather than recall:

- the branch, and whether the working tree is clean
- the PR, its mergeability, and its checks
- anything launched in the background — still running, finished, or dead
- whether another session has moved what you are about to describe
- that artifacts you are about to mention still exist, and still say what you think

**A recap that states a stale fact confidently is worse than no recap**, because the user
acts on it. Where a check is not worth the time, say the fact is unverified rather than
dropping the caveat.

## The shape

Always these sections, always this order:

```
▸ <branch> — <tree state> — <what is being worked on>

NEEDS YOU
  1  <decision, phrased as a question>
  2  <decision, phrased as a question>

IN FLIGHT
  <what is running, and what it will do>

DONE HERE
  <what changed outside the conversation>

NEXT  <one line — the single action that resumes work>
```

The order carries the point: position, then what is blocked on them, and only then what was
done. They returned to act, not to be briefed.

- **Number the decisions.** They will reply "1 yes, 2 drop", and numbering is what makes
  that possible.
- **Phrase each as a question with a default.** "Delete the stale review doc?" beats "the
  review doc is stale" — the second makes them work out what is being asked.
- **Omit any empty section** — except `NEEDS YOU`. When nothing is blocked, write
  `NEEDS YOU  nothing — free to continue`. Silence there reads as "forgot to check", which
  is the one ambiguity that costs them a question.
- **Cap NEEDS YOU at four.** More than that is a backlog, not a recap: name the top three
  and say how many remain.

## What earns a line

- A question whose answer changes what happens next.
- Something running that could finish, block, or fail while they are away.
- A change on disk, in git, or in the issue tracker — an artifact that now exists.
- **A belief that turned out wrong**, if they would otherwise act on it. Corrections are
  high value on re-entry, because the user's mental model is the stale one.

## What to cut

Most of the session. Specifically:

- Chronology. How you arrived somewhere is never the recap.
- Anything they already decided here — they know; repeating it implies they might not.
- Work that produced no artifact and changed no decision.
- Alternatives considered and dropped, unless one is still live.
- Restating the content of files you changed. Name the file and what it now does.
- Reasoning. The recap carries conclusions; they will ask if they want the argument.

When a line survives all of that and still feels long, it is usually two facts pretending
to be one. Split it or drop the weaker half.

## Length

One screen, no scrolling — roughly fifteen lines. If it does not fit, the cut was too
generous, not the format too small.

Resist the pull to be thorough. Completeness is what makes a recap unreadable, and an
unread recap helps nobody get oriented. Anything omitted is one question away, and they
have you right there to ask.
