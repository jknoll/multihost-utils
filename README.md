# multihost-utils

Session handoff, pickup, and permission sharing utilities for multi-host Claude Code workflows.

## Installation

### Via Claude Code Plugin System

```bash
claude plugin install github:jknoll/multihost-utils
```

### Manual Installation

```bash
git clone https://github.com/jknoll/multihost-utils.git ~/git/multihost-utils
cd ~/git/multihost-utils
./install.sh
```

### Via claude-code-dotfiles

If you use [claude-code-dotfiles](https://github.com/jknoll/claude-code-dotfiles), multihost-utils is automatically cloned and installed when you run `./install.sh` or `./update.sh`.

## Commands

### `/handoff`

Prepares the current session state for pickup on another host or web session.

**When to use:**
- End a Claude Code session on the current host
- Continue work on a different machine or in a web session
- Document the current state for future reference

**What it does:**
1. Stashes uncommitted changes with a descriptive name
2. Creates/updates `HANDOFF.md` with session state
3. Commits and pushes the handoff
4. Provides resume instructions

### `/pickup`

Restores session context from a previous handoff.

**When to use:**
- Continue work that was handed off from another machine
- Restore context from a previous Claude Code session
- Resume after teleporting from a web session

**What it does:**
1. Syncs the repository (fetch/pull)
2. Restores stashed changes if present
3. Reads handoff context from `HANDOFF.md`
4. Summarizes state and suggests next steps

### `/permissions-share`

Analyzes local permissions and suggests safe ones to share with the team via the repository's settings.

**Scope:** Repository-level only (`[repo]/.claude/settings.local.json` -> `[repo]/.claude/settings.json`)

**When to use:**
- Share useful permission configurations with team members
- Standardize allowed/denied operations across the team
- Propagate security guardrails (deny rules) to the repository

### `/permissions-share-user-level`

Analyzes repository permissions and suggests useful ones to promote to your user-level settings.

**Scope:** Repository -> User-level (`[repo]/.claude/settings.json` -> `~/.claude/settings.json`)

**When to use:**
- Adopt useful permissions from a well-configured project
- Build your personal permission set across multiple projects
- Avoid re-approving the same tools in every project

**Note:** Changes to `~/.claude/settings.json` are not version-controlled unless you use a dotfiles setup like [claude-code-dotfiles](https://github.com/jknoll/claude-code-dotfiles).

## Why Stash Instead of WIP Commits?

The handoff workflow uses `git stash` rather than WIP commits for uncommitted changes:

- **Clean history**: Stashes don't pollute the commit log with incomplete work
- **No rebase/squash needed**: Stashes simply pop back when you resume
- **Branch flexibility**: Stashed changes can be applied to any branch
- **Clear intent**: A stash signals "work in progress, not ready for review"
- **Easy recovery**: `git stash list` shows all stashes with timestamps and descriptions

## License

MIT
