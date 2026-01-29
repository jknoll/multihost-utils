# multihost-utils

Session handoff, pickup, and permission sharing utilities for multi-host Claude Code workflows. Alpha quality.

## `/handoff` and `/pickup`

Why would you need this plugin? Let's say you want to work on your local laptop environment on a Claude Code task, but then migrate it to a remote host so that it can continue to progress while you close your laptop and leave. For this purpose, you can use the `/handoff` command and the corresponding `/pickup` command on the remote host. Then ensure session persistence, for example by using `tmux`, and close your laptop while Claude Code continues to execute. 

## `permission-share` and `permission-share-user-level`

Why the permission sharing utilities? After you've been developing for some time in a local repo, you will have accumulated a large number of decisions about what permissions to allow, deny, or always ask for in your repo `.claude/settings.local.json` file.

If you later check out that repo in another location, or for example, migrate it to another host with the handoff and pickoff commands listed above, all of those local permission decisions will no longer be in effect.

Likewise, if one of your teammates checks out the repo, they will not have the benefit of your permission decisions, and vice versa.

The `/permission-share` command will look at your `[repository]/.claude/settings.local.json` file, identify permissions that it would recommend you port to the repo-level `[repository]/.claude/settings.json` file in order to add them to version control and enable sharing with other checked out copies of the repo.

Similarly, the `permission-share-user-level` command will inspect your repo's `settings.json` file and identify permissions that it recommends adding to your user-level `~/.claude/settings.json` file to be shared across repos.

## Installation

### Via Claude Code Plugin System

```bash
/plugin marketplace add jknoll/multihost-utils
/plugin install multihost-utils@multihost-utils
```

Or using the CLI:
```bash
claude plugin marketplace add jknoll/multihost-utils
claude plugin install multihost-utils@multihost-utils
```

### Manual Installation

```bash
git clone https://github.com/jknoll/multihost-utils.git ~/git/multihost-utils
cd ~/git/multihost-utils
./install.sh
```

### Via claude-code-dotfiles

If you use [claude-code-dotfiles](https://github.com/jknoll/claude-code-dotfiles)(note: currently a private repo, I may create an empty-config snapshot and make it public), multihost-utils is automatically cloned and installed when you run `./install.sh` or `./update.sh`. You can fork this repo and create your own set of `.claude/*` files and user-level `CLAUDE.md`.

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
