# Pickup Skill

Restores session context from a previous handoff or web session.

## When to Use

Use `/pickup` when you want to:
- Continue work that was handed off from another machine
- Restore context from a previous Claude Code session
- Resume after teleporting from a web session

## Instructions

When this skill is invoked:

1. **Check for Web Sessions**
   - Inform user they can check for teleportable web sessions:
     ```
     To resume a web session instead: claude --teleport
     ```

2. **Sync Repository**
   - Run `git fetch` to get latest remote state
   - Check current branch vs remote status
   - If behind, run `git pull`
   - Check for merge conflicts

3. **Restore Stashed Changes**
   - Check for handoff stashes: `git stash list | grep "handoff-"`
   - If found, ask user if they want to apply:
     ```bash
     git stash pop  # or git stash apply to keep the stash
     ```

4. **Read Handoff Context**
   - Read `HANDOFF.md` for previous session state
   - Note the date, host, and branch of the handoff
   - Check if on the same branch as handoff

5. **Read Project Guidelines**
   - Read `CLAUDE.md` for project-specific instructions
   - Note any environment setup requirements

6. **Summarize State to User**
   Present a clear summary:
   - When and where the handoff occurred
   - What was accomplished in the previous session
   - Key findings or important context
   - Whether stashed changes were found/applied
   - Suggested next steps
   - Current git status

7. **Environment Check**
   - Check if required dependencies are available
   - Note any environment differences from the handoff
   - Suggest setup steps if needed

8. **Ask for Direction**
   - Present the suggested next steps from HANDOFF.md
   - Ask the user what they'd like to work on

## Example Output

```
Pickup from handoff on 2026-01-22 14:30 (from hostname: macbook-pro)

Previous session on branch: feature/validation

Found stashed changes from handoff:
  stash@{0}: handoff-20260122-1430: WIP validation fixes
Apply stashed changes? (Recommended if continuing the same work)

Last session accomplished:
- Created validation notebook for multi-task BEiT model
- Discovered 25% accuracy drop vs stock baseline at species level
- Generated HTML report and visualizations

Key findings:
- Species accuracy: 45.43% (vs 70.2% baseline)
- Amanita phalloides detection needs improvement

Suggested next steps:
1. Investigate training logs
2. Try different loss weighting
3. Evaluate on test set

Current status: On branch feature/validation, up to date with origin

What would you like to work on?
```

## Notes

- If `HANDOFF.md` doesn't exist, inform the user and offer to read `CLAUDE.md` instead
- If there are local uncommitted changes, warn before pulling
- If a handoff stash exists, recommend applying it for continuity
- The pickup doesn't need to be committed - it's a read-only operation
- For web session resume, recommend `claude --teleport` instead
