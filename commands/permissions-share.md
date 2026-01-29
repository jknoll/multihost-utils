# Permissions Share Skill

Analyzes local permissions and suggests safe ones to share with the team via the repository's settings.

## Scope

This command operates on the **current repository's** `.claude/` directory only:
- **Source:** `[repo]/.claude/settings.local.json` (your local permission approvals)
- **Target:** `[repo]/.claude/settings.json` (shared team permissions)

**Important:** This command never modifies user-level config (`~/.claude/`). It only works with repository-scoped settings.

## When to Use

Use `/permissions-share` when you want to:
- Share useful permission configurations with team members
- Standardize allowed/denied operations across the team
- Propagate security guardrails (deny rules) to the repository
- Review what local permissions could benefit the whole team

## Overview

This skill examines your local `settings.local.json` (where permission approvals/denies/asks you choose when Claude Code asks you are stored) and compares it against the repository's `.claude/settings.json`, identifying permissions that are:
- **Safe to share**: Common development tools and read-only operations
- **Potentially risky**: Broad wildcards or system-modifying commands (requires confirmation)
- **Deny rules**: Security guardrails that protect the team

## Instructions

When this skill is invoked:

1. **Locate Configuration Files**
   - Determine the current repository root (via `git rev-parse --show-toplevel`)
   - Find local settings: `[repo]/.claude/settings.local.json`
   - Find repository settings: `[repo]/.claude/settings.json`
   - If local settings don't exist, explain there are no local permissions to share
   - If repository settings don't exist, offer to create it with the selected permissions

2. **Parse and Compare Permissions**
   - Read both JSON files
   - Extract `permissions.allow`, `permissions.deny`, and `permissions.ask` arrays
   - Identify permissions in local that are not in repository settings

3. **Categorize Permissions by Safety**

   **Safe to Share (recommend syncing):**
   - Git commands: `Bash(git *)`
   - GitHub CLI: `Bash(gh *)`
   - Package managers: `Bash(npm *)`, `Bash(pip *)`, `Bash(cargo *)`, `Bash(go *)`
   - Test runners: `Bash(pytest:*)`, `Bash(jest:*)`, `Bash(cargo test:*)`
   - Build tools: `Bash(make:*)`, `Bash(npm run:*)`, `Bash(cargo build:*)`
   - Read-only utilities: `Bash(ls:*)`, `Bash(find:*)`, `Bash(wc:*)`, `Bash(grep:*)`
   - Language runtimes: `Bash(python:*)`, `Bash(python3:*)`, `Bash(node:*)`
   - Web tools: `WebSearch`, `WebFetch`
   - Docker (read/run): `Bash(docker ps:*)`, `Bash(docker logs:*)`, `Bash(docker run:*)`

   **Ask Before Sharing (potentially team-specific):**
   - File modification: `Bash(chmod:*)`, `Bash(mkdir:*)`
   - Network tools: `Bash(curl:*)`, `Bash(wget:*)`
   - Process tools: `Bash(lsof:*)`, `Bash(pgrep:*)`, `Bash(kill:*)`
   - Broad wildcards: Any pattern ending in just `*` without command prefix

   **Not Shareable (skip these):**
   - Path-specific permissions containing absolute paths (e.g., `/Users/...`, `/home/...`)
   - These are auto-approved during sessions but won't work on other machines
   - Often already covered by broader wildcard patterns in repo settings

   **Deny Rules (recommend sharing for security):**
   - All deny rules are generally good to share as they protect the team
   - Examples: preventing force push, blocking credential access, etc.

4. **Present Findings to User**
   Show a clear summary organized by category:
   ```
   Permissions found in your local settings but not in repository:

   ✓ SAFE TO SHARE (recommended):
     - Bash(npm run:*)     # Build scripts
     - Bash(jest:*)        # Test runner
     - Bash(docker run:*)  # Container execution

   ? ASK BEFORE SHARING (review these):
     - Bash(curl:*)        # Network requests - may expose internal URLs
     - Bash(chmod:*)       # File permissions - verify team needs this

   ⊘ NOT SHAREABLE (path-specific):
     - Bash(git -C /Users/alice/project status)
     (Already covered by Bash(git status:*))

   🛡 DENY RULES (security guardrails):
     - Bash(rm -rf /*)     # Prevent catastrophic deletion
     - Bash(git push --force origin main:*) # Protect main branch

   Already in repository settings:
     - Bash(git status:*)
     - Bash(python:*)
   ```

5. **Offer Simplification/Cleanup**
  If the .claude/settings.local.json contains redundant permissions (i.e. more specific permissions dominated by more general ones already present), explain these and offer to clean up the settings.local.json file before doing any sync to settings.json. Get permission, and show a diff for confirmation.

6. **Build Selection and Show Diff**
   After presenting the categorized permissions:
   - Ask the user which categories/permissions to include (safe, reviewed, deny rules)
   - Build the proposed changes based on their selection
   - **Always show the full diff** of what the updated settings.json will look like
   - Never apply changes without first showing exactly what will change

7. **Confirm and Apply Changes**
   After showing the diff:
   - Ask explicitly: "Apply these changes? [yes/no/modify]"
   - If "modify": let user adjust the selection and show a new diff
   - If "yes": apply the changes
   - If "no": cancel without changes

   When applying:
   - Read current `.claude/settings.json` (create if doesn't exist)
   - Merge selected permissions into the appropriate arrays
   - Preserve existing permissions and formatting
   - Write the updated file

8. **Remind About Committing**
   After making changes, remind the user:
   ```
   Changes written to .claude/settings.json

   To share with your team:
     git add .claude/settings.json
     git commit -m "chore: update shared Claude permissions"
     git push
   ```

9. ** AskUserQuestion about Adding New Permissions File **
  Next check the repository state with `git status`
  If the working copy is up to date, then offer to add, commit -m, and push for them.

## Example Output

```
Permission Share Analysis
=========================

Comparing:
  Local:      [repo]/.claude/settings.local.json
  Repository: [repo]/.claude/settings.json

✓ SAFE TO SHARE (5 permissions):
  1. Bash(npm run:*)      - Build/dev scripts
  2. Bash(jest:*)         - JavaScript testing
  3. Bash(docker build:*) - Container builds
  4. Bash(docker run:*)   - Container execution
  5. Bash(cargo test:*)   - Rust testing

? REVIEW BEFORE SHARING (2 permissions):
  1. Bash(curl:*)
     → Network requests - may expose internal API endpoints
     → Share? [y/n/skip]

  2. Bash(sudo apt:*)
     → System package installation - may not suit all team environments
     → Share? [y/n/skip]

⊘ NOT SHAREABLE (3 permissions):
  - Bash(git -C /Users/alice/project status)
  - Bash(git -C /Users/alice/project push)
  - Bash(git -C /Users/alice/project add ...)
  (These contain absolute paths and are already covered by Bash(git status:*), etc.)

🛡 DENY RULES TO SHARE (1 rule):
  1. Bash(git push --force:*)
     → Prevents force pushing (protects branch history)

Already synchronized (8 permissions):
  Bash(git status:*), Bash(python:*), Bash(ls:*), ...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Which permissions would you like to sync?
  [x] All safe (5)
  [ ] Reviewed items - select individually
  [x] Deny rules (1)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Proposed changes to .claude/settings.json:

```diff
 {
   "permissions": {
     "allow": [
       "Bash(git status:*)",
       "Bash(python:*)",
+      "Bash(npm run:*)",
+      "Bash(jest:*)",
+      "Bash(docker build:*)",
+      "Bash(docker run:*)",
+      "Bash(cargo test:*)"
     ],
-    "deny": []
+    "deny": [
+      "Bash(git push --force:*)"
+    ]
   }
 }
```

Apply these changes? [yes/no/modify]
```

## Notes

- Local settings (`settings.local.json`) are meant for personal/machine-specific config
- Repository settings (`.claude/settings.json`) are shared with everyone who clones the repo
- This skill never removes permissions from the repository settings
- Deny rules are especially valuable to share as they enforce security standards
- If `.claude/settings.json` doesn't exist, offer to create it with the selected permissions
- Always preserve any existing permissions in the repository settings
- The `permissions.ask` array can also be synced - these prompt for confirmation each time
- **Path-specific permissions** (containing absolute paths like `/Users/...`) should be flagged as non-shareable since they won't work on other machines
- This command never touches `~/.claude/` (user-level config) - it only operates on the current repository's `.claude/` directory
