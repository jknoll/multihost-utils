# Handoff Skill

Prepares the current session state for pickup on another host or web session.

## When to Use

Use `/handoff` when you want to:
- End a Claude Code session on the current host
- Continue work on a different machine or in a web session
- Document the current state for future reference

## Why Stash

The handoff workflow uses `git stash` rather than WIP commits for uncommitted changes:

- **Clean history**: Stashes don't pollute the commit log with incomplete work. The git history remains meaningful and reviewable.
- **No rebase/squash needed**: WIP commits require cleanup later (interactive rebase, squash). Stashes simply pop back when you resume.
- **Branch flexibility**: Stashed changes can be applied to any branch. A WIP commit locks changes to the branch where it was made.
- **Clear intent**: A stash signals "work in progress, not ready for review." A commit—even labeled WIP—can be accidentally pushed, merged, or included in PRs.
- **Easy recovery**: `git stash list` shows all stashes with timestamps and descriptions. `/pickup` automatically finds and applies the right one.

## Instructions

When this skill is invoked:

1. **Save Uncommitted Changes**
   - Check `git status` for uncommitted changes
   - If changes exist, stash them with a descriptive name:
     ```bash
     git stash push -m "handoff-$(date +%Y%m%d-%H%M%S): [brief description]"
     ```

2. **Read Project Context**
   - Read `CLAUDE.md` for project guidelines
   - Check `git log` for recent commits

3. **Summarize Session Work**
   - What was accomplished in this session
   - Key findings or discoveries
   - Any issues encountered and how they were resolved

4. **Write HANDOFF.md**
   Create or update `HANDOFF.md` in the project root with:
   - **Date**: Current date and time
   - **Host**: Hostname where session ended
   - **Branch**: Current git branch
   - **Last Commit**: Most recent commit hash and message
   - **Stash**: If changes were stashed, the stash reference
   - **Session Summary**: Brief overview of what was done
   - **What Was Done**: Detailed list of completed work
   - **Key Findings**: Important discoveries or results
   - **Files Created/Modified**: List of changed files
   - **Next Steps**: Suggested follow-up work
   - **Resume Options**: Instructions for resuming (see below)

5. **Commit and Push**
   - Stage `HANDOFF.md`
   - Commit with message: "handoff: [brief description]"
   - Push to current branch

6. **Provide Resume Instructions**
   Display options for continuing work:

   **Option A: Resume on another terminal (same or different host)**
   ```
   cd /path/to/repo
   git pull
   claude
   # Then run /pickup
   ```

   **Option B: Continue in web session**
   ```
   # Start a new web session that continues the work:
   & Continue working on [task description from HANDOFF.md]
   ```

   **Option C: If you started a web session, teleport back later**
   ```
   claude --teleport
   ```

## Example Output

```
Handoff complete!

Committed: abc1234 - handoff: validation notebook implementation
Pushed to: main
Stashed uncommitted changes: stash@{0} "handoff-20260122-1430: WIP validation fixes"

To continue on another host:
  git pull && claude    # Then run /pickup

To continue in a web session:
  & Continue implementing the validation notebook from HANDOFF.md

To check web session progress later:
  /tasks
```
