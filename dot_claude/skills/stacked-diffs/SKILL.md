---
name: stacked-diffs
description: |
  Manage stacked diffs (dependent PRs/branches) using pure git + gh CLI.
  Handles creation, navigation, syncing, landing (with squash-merge support), and PR submission.
triggers:
  - stack
  - stacked diffs
  - stacked PRs
  - dependent branches
  - dependent PRs
  - chain of PRs
  - PR chain
  - branch chain
  - stack create
  - stack add
  - stack sync
  - stack land
  - stack submit
  - stack status
---

# Stacked Diffs Skill

## Overview

Stacked diffs are a series of dependent branches where each branch builds on the previous one. This allows large features to be split into small, reviewable PRs that land incrementally.

This skill uses **only git + gh CLI** — no external tools required.

### Metadata Storage

All stack metadata is stored in `.git/config` via `git config --local`:

```
# Per-branch metadata
branch.<name>.stack-name   = "feature-auth"
branch.<name>.stack-order  = "1"
branch.<name>.stack-parent = "main"

# Per-stack metadata
stack.<stack-name>.base    = "main"
stack.<stack-name>.size    = "3"
```

This survives rebases, requires no extra files, and is easy to query.

### Branch Naming Convention

Branches follow the pattern: `<stack-name>/<NN>-<description>`

Examples:
- `feature-auth/01-api-models`
- `feature-auth/02-endpoints`
- `feature-auth/03-tests`

---

## Operations

### 1. `stack create <name>` — Start a New Stack

Creates a new stack starting from the base branch.

**Steps:**

1. Detect base branch (main or master):
   ```bash
   git remote show origin | sed -n '/HEAD branch/s/.*: //p'
   ```

2. Fetch and checkout base:
   ```bash
   git fetch origin <base>
   git checkout origin/<base> -b <stack-name>/01-<description>
   ```

3. Store metadata:
   ```bash
   git config --local branch.<stack-name>/01-<description>.stack-name "<stack-name>"
   git config --local branch.<stack-name>/01-<description>.stack-order "01"
   git config --local branch.<stack-name>/01-<description>.stack-parent "<base>"
   git config --local stack.<stack-name>.base "<base>"
   git config --local stack.<stack-name>.size "1"
   ```

4. Confirm to user:
   ```
   Created stack "<stack-name>" based on <base>.
   Now on: <stack-name>/01-<description>
   ```

---

### 2. `stack add <description>` — Add a Branch to the Stack

Adds a new branch on top of the current branch in the stack.

**Steps:**

1. Read current branch info:
   ```bash
   current=$(git branch --show-current)
   stack_name=$(git config --local branch.$current.stack-name)
   stack_order=$(git config --local branch.$current.stack-order)
   ```

2. Validate we're on a stack branch (fail if no stack metadata found).

3. Calculate next order:
   ```bash
   next_order=$(printf "%02d" $((10#$stack_order + 1)))
   ```

4. Create branch from current tip:
   ```bash
   new_branch="$stack_name/${next_order}-<description>"
   git checkout -b "$new_branch"
   ```

5. Store metadata:
   ```bash
   git config --local branch.$new_branch.stack-name "$stack_name"
   git config --local branch.$new_branch.stack-order "$next_order"
   git config --local branch.$new_branch.stack-parent "$current"
   size=$(git config --local stack.$stack_name.size)
   git config --local stack.$stack_name.size "$((size + 1))"
   ```

6. Confirm to user:
   ```
   Added branch #<next_order> to stack "<stack_name>".
   Now on: <new_branch>
   Parent: <current>
   ```

---

### 3. `stack status` — Show Stack Overview

Displays a table with all branches in the stack, their commit counts, and PR status.

**Steps:**

1. Determine current stack:
   ```bash
   current=$(git branch --show-current)
   stack_name=$(git config --local branch.$current.stack-name)
   base=$(git config --local stack.$stack_name.base)
   ```

2. Enumerate all branches in the stack:
   ```bash
   git config --get-regexp 'branch\..*\.stack-name' | grep "$stack_name"
   ```

3. For each branch, gather:
   - Order: `git config --local branch.<name>.stack-order`
   - Parent: `git config --local branch.<name>.stack-parent`
   - Commits ahead of parent: `git rev-list --count <parent>..<branch>`
   - PR status: `gh pr list --head <branch> --json number,state --jq '.[0] | "#\(.number) \(.state)"'`

4. Display formatted table:
   ```
   Stack: feature-auth (base: main)
   #  Branch                          Commits  PR
   1  feature-auth/01-api-models      3        #142 merged
   2  feature-auth/02-endpoints       2        #143 open      <-- you are here
   3  feature-auth/03-tests           1        (no PR)
   ```

   Mark the current branch with `<-- you are here`.

---

### 4. `stack up` / `stack down` — Navigate the Stack

**stack up** — move to the next branch (higher order):

```bash
current=$(git branch --show-current)
stack_name=$(git config --local branch.$current.stack-name)
current_order=$(git config --local branch.$current.stack-order)
next_order=$(printf "%02d" $((10#$current_order + 1)))
# Find branch with that order
next_branch=$(git config --get-regexp "branch\..*\.stack-order" | grep "^branch\.\S*\.stack-order $next_order$" | head -1 | sed 's/branch\.\(.*\)\.stack-order.*/\1/')
git checkout "$next_branch"
```

**stack down** — move to the previous branch (lower order):

```bash
current_order=$(git config --local branch.$current.stack-order)
prev_order=$(printf "%02d" $((10#$current_order - 1)))
# Find branch with that order in same stack
prev_branch=$(git config --get-regexp "branch\..*\.stack-order" | grep "^branch\.\S*\.stack-order $prev_order$" | head -1 | sed 's/branch\.\(.*\)\.stack-order.*/\1/')
git checkout "$prev_branch"
```

If at the top/bottom of the stack, inform the user.

---

### 5. `stack sync` — Rebase After Changes to an Earlier Branch

Rebases all branches in the stack after changes to an earlier branch. Uses `--update-refs` on git 2.38+.

**ASK FOR CONFIRMATION before running any rebase.**

**Steps:**

1. Check git version for `--update-refs` support:
   ```bash
   git_version=$(git --version | grep -oE '[0-9]+\.[0-9]+')
   ```

2. Enumerate all stack branches sorted by order.

3. Identify the branch that was changed (the "pivot"). All branches above it need rebasing.

4. **If git >= 2.38 (preferred):** Rebase from the tip of the stack with `--update-refs`:
   ```bash
   # Checkout the tip (highest order branch)
   git checkout <tip-branch>
   # Rebase onto the changed branch — --update-refs updates all intermediate branch pointers
   git rebase <changed-branch> --update-refs
   ```
   This rebases the entire stack above the changed branch in one command.

   If the change was to the base branch (e.g., main was updated), rebase onto `origin/<base>` instead:
   ```bash
   git checkout <tip-branch>
   git rebase origin/<base> --update-refs
   ```

5. **If git < 2.38 (fallback):** Cascade rebase manually from the changed branch upward:
   ```bash
   # For each branch from changed+1 to tip:
   git checkout <child-branch>
   git rebase <parent-branch>
   ```

6. If conflicts occur:
   - Pause and inform the user
   - Show the conflicting files: `git diff --name-only --diff-filter=U`
   - After user resolves: `git rebase --continue`
   - If unresolvable: `git rebase --abort`

---

### 6. `stack land` — Handle Squash Merge Landing

This is the most complex operation. After a PR is squash-merged on GitHub, the child branches need to be rebased onto the new main.

**ASK FOR CONFIRMATION before running any destructive operation.**

See [references/squash-merge-rebase.md](references/squash-merge-rebase.md) for detailed explanation.

**Steps:**

1. Identify the merged branch (user specifies or detect from current branch):
   ```bash
   merged_branch="<stack-name>/01-<description>"
   stack_name=$(git config --local branch.$merged_branch.stack-name)
   base=$(git config --local stack.$stack_name.base)
   ```

2. Fetch latest main:
   ```bash
   git fetch origin $base
   ```

3. Find the child branch (next in stack order):
   ```bash
   merged_order=$(git config --local branch.$merged_branch.stack-order)
   child_order=$(printf "%02d" $((10#$merged_order + 1)))
   # Find child branch by order + stack-name
   ```

4. Rebase the entire remaining stack onto main in one command, skipping the merged branch's commits.
   Use `--update-refs` (git 2.38+) to update all intermediate branch pointers automatically:
   ```bash
   # Checkout the tip (highest order branch in the stack)
   git checkout <tip-branch>
   git rebase --onto origin/$base $merged_branch --update-refs
   ```
   This replays only the commits unique to each remaining branch onto main, discarding the now-squashed parent commits. All intermediate branch refs are updated in one operation.

   If there is only one remaining branch (no branches above the child):
   ```bash
   git rebase --onto origin/$base $merged_branch $child_branch
   ```

   **Fallback (git < 2.38):** Save old branch tips before rebasing, then cascade manually:
   ```bash
   # Save old refs before any rebase
   old_child_tip=$(git rev-parse $child_branch)
   # Rebase child onto main, skipping merged branch
   git rebase --onto origin/$base $merged_branch $child_branch
   # For each subsequent branch, rebase onto its new parent using old ref
   git rebase --onto $child_branch $old_child_tip <grandchild-branch>
   ```

5. Delete merged branch (this also removes its config section automatically):
   ```bash
   git branch -D $merged_branch
   ```

6. Update remaining branches — decrement order numbers:
   ```bash
   # For each remaining branch, update stack-order
   # Update the child's parent to point to base instead of merged branch
   git config --local branch.$child_branch.stack-parent "$base"
   ```

7. Update stack size:
   ```bash
   size=$(git config --local stack.$stack_name.size)
   git config --local stack.$stack_name.size "$((size - 1))"
   ```

8. Update next PR's base branch on GitHub:
   ```bash
   pr_number=$(gh pr list --head $child_branch --json number --jq '.[0].number')
   gh pr edit $pr_number --base $base
   ```

9. Show updated stack status.

---

### 7. `stack submit` — Create or Update PRs

Creates PRs for all branches that don't have one, with correct base branches.

**Steps:**

1. Enumerate all stack branches sorted by order.

2. For each branch, check if PR exists:
   ```bash
   gh pr list --head <branch> --json number --jq '.[0].number'
   ```

3. Push branch to remote:
   ```bash
   git push -u origin <branch>
   ```

4. If no PR exists, create one:
   - First branch in stack (order 1):
     ```bash
     gh pr create --head <branch> --base <base> --title "<title>" --body "<body>"
     ```
   - Subsequent branches:
     ```bash
     gh pr create --head <branch> --base <parent-branch> --title "<title>" --body "<body>"
     ```

5. Add stack info to PR body. Include a "Stack" section:
   ```markdown
   ## Stack
   - #142 <-- base
   - #143 (this PR)
   - #144
   ```

6. If PR already exists, update it:
   ```bash
   git push origin <branch>
   ```

---

## UX Guidelines

### Read-Only Commands — Run Directly
These are safe to run without confirmation:
- `stack status`
- `stack up` / `stack down`
- Querying metadata (`git config --local --get ...`)
- `gh pr list`, `gh pr view`

### Destructive Commands — Show Plan First, Then Confirm
Always explain what will happen and ask for confirmation before:
- `stack sync` (rebases)
- `stack land` (rebase + branch deletion)
- Any `git rebase`, `git branch -D`, `git push --force-with-lease`

### Force Push
After any rebase, branches need force-pushing:
```bash
git push --force-with-lease origin <branch>
```
Always use `--force-with-lease` (never `--force`) to prevent overwriting others' work.

### Stack Status After Mutations
Always show `stack status` after any operation that modifies the stack.

---

## Error Recovery

### Conflict During Rebase
1. Show conflicting files
2. Let user resolve
3. `git add <resolved-files> && git rebase --continue`
4. If stuck: `git rebase --abort` to return to pre-rebase state

### Lost Metadata
If `.git/config` metadata is missing (e.g., after cloning), reconstruct from branch names:

```bash
# List branches matching stack pattern
git branch --list '<stack-name>/*' --sort=refname

# Reconstruct metadata from branch naming convention
# Parse <stack-name>/<NN>-<description> to restore order and parent info
```

### Detached HEAD
```bash
# Find where you were
git reflog --no-abbrev -5

# Return to the branch
git checkout <branch-name>
```

### Rebase Gone Wrong
```bash
# Find the pre-rebase state
git reflog

# Reset to before the rebase
git reset --hard <ref-before-rebase>
```
**Always confirm with user before `git reset --hard`.**
