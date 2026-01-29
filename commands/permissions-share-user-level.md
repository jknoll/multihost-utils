# Permissions Share User Level Skill

Analyzes repository permissions and suggests useful ones to promote to your user-level settings.

## Scope

This command promotes permissions from repository settings to user-level settings:
- **Source:** `[repo]/.claude/settings.json` (repository's shared permissions)
- **Target:** `~/.claude/settings.json` (your user-level permissions, apply to all projects)

**Important:** This command helps you build up your personal permission set by learning from project configurations. It's the inverse of `/permissions-share`.

## When to Use

Use `/permissions-share-user-level` when you want to:
- Adopt useful permissions from a well-configured project
- Build your personal permission set across multiple projects
- Avoid re-approving the same tools in every project
- Learn what permissions a project uses that you might want globally

## Overview

This skill examines the repository's `.claude/settings.json` and compares it against your `~/.claude/settings.json`, identifying permissions that:
- **Good for user-level**: General development tools you'd use across many projects
- **Keep at repo-level**: Project-specific tools, scripts, or configurations
- **Already have**: Permissions you've already configured at user level

## Instructions

When this skill is invoked:

1. **Locate Configuration Files**
   - Determine the current repository root (via `git rev-parse --show-toplevel`)
   - Find repository settings: `[repo]/.claude/settings.json`
   - Find user settings: `~/.claude/settings.json`
   - If repository settings don't exist, explain there are no permissions to review
   - If user settings don't exist, offer to create it with the selected permissions

2. **Analyze User-Level Patterns**
   Before categorizing, examine what's already in `~/.claude/settings.json` to understand the user's patterns:
   - What package managers are already permitted? (npm, pip, cargo, go)
   - What language runtimes are permitted? (python, node, ruby)
   - What tools are already there? (git, gh, docker)

   Use these patterns to make smarter recommendations. For example:
   - If user has `Bash(npm install:*)`, suggest related npm commands like `Bash(npm run:*)`
   - If user has multiple Python permissions, suggest Python-related tools from the repo

3. **Parse and Compare Permissions**
   - Read both JSON files
   - Extract `permissions.allow`, `permissions.deny`, and `permissions.ask` arrays
   - Identify permissions in repository that are not in user settings

4. **Categorize Permissions for User-Level Promotion**

   **Recommended for User-Level (general development tools):**
   - Git commands: `Bash(git *)` - version control is universal
   - GitHub CLI: `Bash(gh *)` - if user works with GitHub
   - Package managers: `Bash(npm *)`, `Bash(pip *)`, `Bash(cargo *)`, `Bash(go *)`
   - Test runners: `Bash(pytest:*)`, `Bash(jest:*)`, `Bash(cargo test:*)`
   - Language runtimes: `Bash(python:*)`, `Bash(python3:*)`, `Bash(node:*)`
   - Read-only utilities: `Bash(ls:*)`, `Bash(find:*)`, `Bash(wc:*)`, `Bash(grep:*)`
   - Web tools: `WebSearch`, `WebFetch`, `WebFetch(domain:*)`
   - Process inspection: `Bash(lsof:*)`, `Bash(pgrep:*)`
   - Network tools: `Bash(curl:*)` - common for API work
   - File utilities: `Bash(mkdir:*)`, `Bash(chmod:*)`

   **Review Before Promoting (may be project-specific):**
   - Build tools with project names: `Bash(npm run build:*)` might be generic, but check
   - Docker commands: Useful if user works with containers across projects
   - Database tools: `Bash(psql:*)`, `Bash(mysql:*)` - depends on user's work
   - Cloud CLIs: `Bash(aws:*)`, `Bash(gcloud:*)`, `Bash(az:*)` - if user uses these platforms

   **Keep at Repo-Level (project-specific):**
   - Project scripts: `Bash(./install.sh)`, `Bash(./build.sh)`, `Bash(./scripts/*)`
   - Project-specific tools: Commands that only make sense for this codebase
   - Path-specific permissions: Anything with absolute paths
   - Niche tools: Uncommon utilities specific to the project's tech stack

   **Deny Rules (consider carefully):**
   - Security guardrails from the repo might be good to have globally
   - But some deny rules might be project-specific policies
   - Ask the user about each deny rule

5. **Present Findings to User**
   Show a clear summary with context about why each permission is categorized:
   ```
   Permissions in [repo] that could be added to your user-level config:

   ✓ RECOMMENDED FOR USER-LEVEL (5 permissions):
     Your ~/.claude/settings.json already has npm permissions, so these fit your patterns:
     - Bash(npm run:*)      # You have npm install, this adds run scripts
     - Bash(npm test:*)     # Consistent with your npm usage

     General development tools:
     - Bash(pytest:*)       # Python testing - works across projects
     - Bash(docker ps:*)    # Container inspection
     - WebFetch(domain:api.github.com)  # GitHub API access

   ? REVIEW BEFORE PROMOTING (2 permissions):
     - Bash(make:*)
       → Build tool - useful if you use Makefiles across projects
       → Promote to user-level? [y/n/skip]

     - Bash(redis-cli:*)
       → Redis client - only if you use Redis in multiple projects
       → Promote to user-level? [y/n/skip]

   ⊘ KEEP AT REPO-LEVEL (3 permissions):
     - Bash(./install.sh)           # Project-specific script
     - Bash(./scripts/deploy.sh)    # Project-specific deployment
     - Bash(bundle exec:*)          # Ruby - not in your current toolset

   🛡 DENY RULES TO CONSIDER (1 rule):
     - Bash(rm -rf /*)
       → Catastrophic deletion protection
       → Add to user-level? [y/n/skip]

   Already in your user-level settings (8 permissions):
     Bash(git *), Bash(npm install:*), Bash(python:*), ...
   ```

6. **Highlight Pattern Matches**
   When presenting recommendations, explicitly note when a permission matches existing user patterns:
   - "You already have `Bash(pip install:*)`, so `Bash(pip show:*)` would complement it"
   - "You have several git commands; this repo adds `Bash(git stash:*)` which you're missing"
   - "No Node.js permissions in your config - skip `Bash(node:*)` unless you want to add Node support"

7. **Build Selection and Show Diff**
   After presenting the categorized permissions:
   - Ask the user which categories/permissions to include (recommended, reviewed, deny rules)
   - Build the proposed changes based on their selection
   - **Always show the full diff** of what the updated ~/.claude/settings.json will look like
   - Never apply changes without first showing exactly what will change

8. **Confirm and Apply Changes**
   After showing the diff:
   - Ask explicitly: "Apply these changes? [yes/no/modify]"
   - If "modify": let user adjust the selection and show a new diff
   - If "yes": apply the changes
   - If "no": cancel without changes

   When applying:
   - Read current `~/.claude/settings.json`
   - Merge selected permissions into the appropriate arrays
   - Preserve existing permissions and formatting
   - Write the updated file

9. **Note About Dotfiles Sync**
   After making changes, if the user is in a dotfiles repository (or appears to manage their ~/.claude/ via dotfiles), remind them:
   ```
   Changes written to ~/.claude/settings.json

   If you manage your Claude config via dotfiles, remember to:
   - Check if ~/.claude/settings.json is symlinked to your dotfiles repo
   - Commit changes in your dotfiles repo to preserve them
   ```

## Example Output

```
Permission Share User-Level Analysis
====================================

Comparing:
  Repository: /Users/alice/projects/webapp/.claude/settings.json
  User-level: ~/.claude/settings.json

Analyzing your existing user-level patterns...
  ✓ npm ecosystem: npm install, npm i
  ✓ Python ecosystem: python, python3, pip install
  ✓ Git workflow: git status, add, commit, push, pull, fetch, checkout
  ✓ GitHub CLI: gh pr, gh issue

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ RECOMMENDED FOR USER-LEVEL (4 permissions):

  Matches your npm pattern:
  1. Bash(npm run:*)       - Run package.json scripts
  2. Bash(npm test:*)      - Run tests via npm

  General development tools:
  3. Bash(docker ps:*)     - List containers (read-only)
  4. Bash(docker logs:*)   - View container logs (read-only)

? REVIEW BEFORE PROMOTING (2 permissions):

  1. Bash(cargo:*)
     → Rust package manager - add if you work with Rust
     → Promote? [y/n/skip]

  2. Bash(kubectl:*)
     → Kubernetes CLI - add if you use K8s across projects
     → Promote? [y/n/skip]

⊘ KEEP AT REPO-LEVEL (4 permissions):
  - Bash(./install.sh)           # Project script
  - Bash(./scripts/seed-db.sh)   # Project script
  - Bash(rails:*)                # Ruby/Rails - not in your toolset
  - Bash(bundle:*)               # Ruby bundler - not in your toolset

🛡 DENY RULES TO CONSIDER (1 rule):
  1. Bash(git push --force origin main:*)
     → Protects main branch from force push
     → This is a good safety rule for any project
     → Add to user-level? [y/n/skip]

Already in user-level (12 permissions):
  Bash(git status:*), Bash(npm install:*), Bash(python:*), ...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Which permissions would you like to promote to user-level?
  [x] All recommended (4)
  [ ] Reviewed items - select individually
  [x] Deny rules (1)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Proposed changes to ~/.claude/settings.json:

```diff
 {
   "permissions": {
     "allow": [
       "Bash(git status:*)",
       "Bash(npm install:*)",
       "Bash(python:*)",
+      "Bash(npm run:*)",
+      "Bash(npm test:*)",
+      "Bash(docker ps:*)",
+      "Bash(docker logs:*)"
     ],
-    "deny": []
+    "deny": [
+      "Bash(git push --force origin main:*)"
+    ]
   }
 }
```

Apply these changes? [yes/no/modify]
```

## Pattern Matching Logic

When analyzing user patterns, group permissions by ecosystem:

| Ecosystem | Indicators in user config | Related permissions to suggest |
|-----------|--------------------------|-------------------------------|
| Node.js/npm | `npm *`, `node *`, `npx *` | `npm run`, `npm test`, `jest`, `node` |
| Python | `python *`, `pip *`, `pytest *` | `pip install`, `pip show`, `pytest`, `python3` |
| Rust | `cargo *`, `rustc *` | `cargo build`, `cargo test`, `cargo run` |
| Go | `go *` | `go build`, `go test`, `go run` |
| Ruby | `ruby *`, `bundle *`, `rails *` | `bundle exec`, `rails`, `rake` |
| Docker | `docker *` | `docker ps`, `docker logs`, `docker run`, `docker build` |
| Kubernetes | `kubectl *`, `helm *` | `kubectl get`, `kubectl describe`, `helm` |
| Git | `git *` | All git subcommands |
| GitHub | `gh *` | `gh pr`, `gh issue`, `gh api` |

## Notes

- User-level settings (`~/.claude/settings.json`) apply to ALL projects
- Only promote permissions you'll genuinely use across multiple projects
- Project-specific scripts and tools should stay at repo-level
- This skill never removes permissions from user-level settings
- Consider the "blast radius" - user-level permissions affect every project
- Deny rules at user-level provide consistent safety across all work
- If you're unsure, keep it at repo-level - you can always promote later
- This command reads from `[repo]/.claude/settings.json`, NOT `settings.local.json`
