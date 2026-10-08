# session-outputs

A Claude Code mod that records what a session **used** and **produced**, across every directory and
repository it touched, and shows it in a pane.

`/outputs` opens the pane and prints a short summary. `/outputs reset` clears the record. The status
line keeps a one-line count: `3 dirs · +120 −30 · 2 commits`.

## What it shows

At the top, the outputs that leave the machine or outlive the session:

- **GitHub** — PRs and issues created, commented on, closed or merged, with their URLs
- **Services** — MCP calls that wrote something (a draft, an event, a document); read-only calls and
  web searches fold under *services used*
- **Scheduled & running** — cron jobs, routines, worktrees and background commands, marked *done*
  once they finish

Then one group per directory — a git root, or a plain directory outside any repo — collapsed to a
summary line until opened:

- branches created, deleted locally (struck through) and deleted on the remote; pushes
- commits, each expandable to its files with `+/−` lines
- files changed, with `+/−` lines, new and deleted marked
- files read, and every command run there

**Expand all / Collapse all** opens every fold. **Copy all** puts the whole record on the clipboard
as markdown.

## Install

Mods are early access and load from a plugin folder. The repo's `install.sh` adds this one to
`env.CLAUDE_CODE_PLUGIN_DIRS` in `~/.claude/settings.json`, for every session. For one session:

```bash
claude --plugin-dir /path/to/skills/mods/session-outputs
```

A headless `claude -p` also needs `CLAUDE_CODE_ENABLE_FUNCTION_HOOKS=1`.

## Develop

```bash
claude plugin validate mods/session-outputs
claude plugin test mods/session-outputs
```

The tests stand in for the engine — the working directory, the file system, git, and the Bash
tool's results — so they run without a repository or a network. The engine writes the API's type
declarations into `.claude-plugin/types/` when it loads the mod (or run `/plugin-types`), and
`tsconfig.json` points an editor at them.

## Limits

- It records from the moment it loads; earlier work in the session is not in it.
- A shell command's edits are seen through the engine's diff, or, when there is none, through git
  around the command — so outside a repo they are only seen when the engine reports them.
- A command is filed under the directory its `cd`s and `git -C` lead to; a `cd` into a shell
  variable is not followed.
- The record lasts for the session, across reloads, and is not kept after it.
