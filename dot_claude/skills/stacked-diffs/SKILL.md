---
name: stacked-diffs
description: |
  Manage stacked diffs (dependent PRs/branches) using pure git + gh CLI.
  Handles creation, navigation, syncing, landing (with squash-merge support), and PR submission.
  Use when the user mentions stacks, stacked diffs, stacked PRs, dependent branches or PRs,
  a chain of PRs/branches, or commands like "stack create", "stack add", "stack status",
  "stack up/down", "stack sync", "stack land" or "stack submit".
---

# Stacked Diffs Skill

## Overview

Stacked diffs are a series of dependent branches where each branch builds on the previous one. This allows large features to be split into small, reviewable PRs that land incrementally.

This skill uses **only git + gh CLI** — no external tools required.

### Shell

All snippets are **bash**. If your shell is fish (or any non-bash shell), run them through `bash -c '...'`.

### Metadata Storage

All stack metadata is stored in `.git/config` via `git config --local`:

```
# Per-branch metadata
branch.<name>.stack-name        = "feature-auth"
branch.<name>.stack-order       = "1"          # plain integer, never zero-padded
branch.<name>.stack-parent      = "main"
branch.<name>.stack-parent-sha  = "<sha>"      # parent's tip when this branch was last based on it

# Per-stack metadata
stack.<stack-name>.base    = "main"
stack.<stack-name>.size    = "3"
```

`stack-parent-sha` is what makes rebases safe: it marks exactly where this branch's own commits start, even after the parent has been amended, rebased or squash-merged. **Update it after every operation that moves a branch** (see "Refresh parent SHAs" below).

This survives rebases, requires no extra files, and is easy to query.

### Branch Naming Convention

Branches follow the pattern: `<stack-name>/<NN>-<description>` (NN is zero-padded in the name only).

Examples:
- `feature-auth/01-api-models`
- `feature-auth/02-endpoints`
- `feature-auth/03-tests`

Branch names are never renamed after creation (that would break open PRs), so after landing, a branch's name number may differ from its `stack-order`. Always navigate by `stack-order`, never by name.

### Helpers

Define these at the start of any snippet that needs them:

```bash
# Print "<order> <branch>" for every branch in a stack, sorted by order.
# The value pattern "^name$" matches the stack name exactly (so "auth" doesn't match "feature-auth").
stack_branches() {
  git config --local --get-regexp '^branch\..*\.stack-name$' "^$1\$" |
    sed -E 's/^branch\.(.*)\.stack-name .*/\1/' |
    while read -r b; do echo "$(git config --local "branch.$b.stack-order") $b"; done |
    sort -n
}

# Branch at a given order in a stack (empty if none).
branch_at() { stack_branches "$1" | awk -v o="$2" '$1 == o { print $2 }'; }

# Refresh parent SHAs: record each branch's current parent tip.
# Run after every create/add/sync/land.
refresh_parent_shas() {
  stack_branches "$1" | while read -r _ b; do
    parent=$(git config --local "branch.$b.stack-parent")
    git config --local "branch.$b.stack-parent-sha" "$(git rev-parse "$parent")"
  done
}
```

For the first branch, `stack-parent` is the base branch name (e.g. `main`); when refreshing, resolve it as `origin/<base>` if the local base branch is stale.

---

## Operations

### 1. `stack create <name>` — Start a New Stack

Creates a new stack starting from the base branch.

**Steps:**

1. Detect base branch (main or master) without a network call:
   ```bash
   base=$(git symbolic-ref --short refs/remotes/origin/HEAD | sed 's|^origin/||')
   ```
   If that fails (no `origin/HEAD`), run `git remote set-head origin --auto` and retry.

2. Fetch and create the first branch from the remote base:
   ```bash
   git fetch origin "$base"
   git checkout -b "<stack-name>/01-<description>" "origin/$base"
   ```

3. Store metadata:
   ```bash
   b="<stack-name>/01-<description>"
   git config --local "branch.$b.stack-name" "<stack-name>"
   git config --local "branch.$b.stack-order" "1"
   git config --local "branch.$b.stack-parent" "$base"
   git config --local "branch.$b.stack-parent-sha" "$(git rev-parse "origin/$base")"
   git config --local "stack.<stack-name>.base" "$base"
   git config --local "stack.<stack-name>.size" "1"
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
   stack_name=$(git config --local "branch.$current.stack-name")
   stack_order=$(git config --local "branch.$current.stack-order")
   ```

2. Validate we're on a stack branch (fail if no stack metadata found). If the current branch is not the tip of the stack, warn the user: the new branch will be inserted in the middle, and every branch above it must have its order incremented and its parent updated — confirm before continuing.

3. Calculate next order and the branch name:
   ```bash
   next_order=$((stack_order + 1))
   new_branch="$stack_name/$(printf '%02d' "$next_order")-<description>"
   ```

4. Create branch from current tip:
   ```bash
   git checkout -b "$new_branch"
   ```

5. Store metadata:
   ```bash
   git config --local "branch.$new_branch.stack-name" "$stack_name"
   git config --local "branch.$new_branch.stack-order" "$next_order"
   git config --local "branch.$new_branch.stack-parent" "$current"
   git config --local "branch.$new_branch.stack-parent-sha" "$(git rev-parse "$current")"
   size=$(git config --local "stack.$stack_name.size")
   git config --local "stack.$stack_name.size" "$((size + 1))"
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
   stack_name=$(git config --local "branch.$current.stack-name")
   base=$(git config --local "stack.$stack_name.base")
   ```

2. Enumerate all branches in the stack with `stack_branches "$stack_name"`.

3. For each branch, gather:
   - Order: `git config --local branch.<name>.stack-order`
   - Parent: `git config --local branch.<name>.stack-parent`
   - Commits ahead of parent: `git rev-list --count <parent>..<branch>` (use `origin/<base>` for the first branch)
   - PR status — `--state all` is required, otherwise merged and closed PRs are not listed:
     ```bash
     gh pr list --head <branch> --state all --json number,state --jq '.[0] | "#\(.number) \(.state | ascii_downcase)"'
     ```

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

Look up the neighbor **within the same stack** by order:

```bash
current=$(git branch --show-current)
stack_name=$(git config --local "branch.$current.stack-name")
order=$(git config --local "branch.$current.stack-order")

# stack up (next, higher order)
target=$(branch_at "$stack_name" "$((order + 1))")
# stack down (previous, lower order)
target=$(branch_at "$stack_name" "$((order - 1))")

[ -n "$target" ] && git checkout "$target"
```

If `target` is empty, the user is already at the top/bottom of the stack — tell them instead of running checkout.

---

### 5. `stack sync` — Rebase After Changes to an Earlier Branch

Rebases all branches above a changed branch (or the whole stack after the base moved). Uses `--update-refs` (git 2.38+) so one rebase moves every branch pointer.

**ASK FOR CONFIRMATION before running any rebase.**

**Why `--onto` with the recorded SHA:** if a lower branch was amended or rebased, the branches above still contain its *old* commits. A plain `git rebase <changed-branch>` would replay those old commits on top of the new ones and conflict. `git rebase --onto <new-parent> <old-parent-tip>` replays only each branch's own commits.

**Steps:**

1. Check git version for `--update-refs` support (2.38+):
   ```bash
   git version | awk '{split($3, v, "."); exit !(v[1] > 2 || (v[1] == 2 && v[2] >= 38))}' && echo supported
   ```

2. Enumerate the stack with `stack_branches`, and identify the changed branch (the "pivot") and its child (the branch at pivot order + 1). Every branch above the pivot needs rebasing.

3. Find the boundary — where the child's own commits start:
   ```bash
   old_parent=$(git config --local "branch.$child.stack-parent-sha")
   # Fallback if no SHA is recorded (older stacks): use the pivot's reflog
   [ -z "$old_parent" ] && old_parent=$(git merge-base --fork-point "$pivot" "$child")
   ```
   If both are empty, stop and ask the user which commit the child was based on — do not guess.

4. **If git >= 2.38 (preferred):** rebase the whole upper stack in one command from the tip:
   ```bash
   git checkout "$tip"
   git rebase --onto "$pivot" "$old_parent" --update-refs
   ```

   If the base branch itself moved (e.g. main was updated), the pivot is the base:
   ```bash
   git fetch origin "$base"
   old_parent=$(git config --local "branch.$first.stack-parent-sha")
   git checkout "$tip"
   git rebase --onto "origin/$base" "$old_parent" --update-refs
   ```

5. **If git < 2.38 (fallback):** cascade upward, saving each branch's old tip *before* rebasing it:
   ```bash
   # Repeat for each branch from pivot+1 to tip, in order:
   old_tip=$(git rev-parse "$child")
   git rebase --onto "$parent" "$old_parent" "$child"
   old_parent=$old_tip   # the next branch was based on this child's old tip
   ```

6. Run `refresh_parent_shas "$stack_name"`, then force-push every rebased branch (see "Force Push").

7. If conflicts occur:
   - Pause and inform the user
   - Show the conflicting files: `git diff --name-only --diff-filter=U`
   - After user resolves: `git add <files> && git rebase --continue`
   - If unresolvable: `git rebase --abort`

---

### 6. `stack land` — Handle Squash Merge Landing

After a PR is squash-merged on GitHub, the remaining branches must be rebased onto the new base, skipping the merged branch's commits.

**ASK FOR CONFIRMATION before running any destructive operation.**

See [references/squash-merge-rebase.md](references/squash-merge-rebase.md) for a detailed explanation.

**Steps:**

1. Identify the merged branch (user specifies, or check which stack PRs report `MERGED` in `stack status`):
   ```bash
   merged_branch="<stack-name>/01-<description>"
   stack_name=$(git config --local "branch.$merged_branch.stack-name")
   base=$(git config --local "stack.$stack_name.base")
   merged_order=$(git config --local "branch.$merged_branch.stack-order")
   child=$(branch_at "$stack_name" "$((merged_order + 1))")
   tip=$(stack_branches "$stack_name" | tail -1 | awk '{print $2}')
   ```

2. Fetch the latest base:
   ```bash
   git fetch origin "$base"
   ```

3. Find the boundary — where the child's own commits start. Prefer the recorded SHA over the merged branch ref: if the merged branch was amended after the child was based on it, only the recorded SHA is correct.
   ```bash
   old_parent=$(git config --local "branch.$child.stack-parent-sha")
   [ -z "$old_parent" ] && old_parent=$merged_branch
   ```

4. Rebase the entire remaining stack onto the base in one command (git 2.38+):
   ```bash
   git checkout "$tip"
   git rebase --onto "origin/$base" "$old_parent" --update-refs
   ```
   This replays only the commits unique to each remaining branch onto the base, discarding the now-squashed parent commits, and updates every intermediate branch ref. It also works when the child is the tip.

   **Fallback (git < 2.38):** cascade, saving each old tip before rebasing:
   ```bash
   old_tip=$(git rev-parse "$child")
   git rebase --onto "origin/$base" "$old_parent" "$child"
   # For each subsequent branch, rebase onto its new parent using the saved old tip:
   next_old=$(git rev-parse "$grandchild")
   git rebase --onto "$child" "$old_tip" "$grandchild"
   old_tip=$next_old
   # ...repeat up to the tip
   ```

5. Delete the merged branch locally (this also removes its `branch.<name>.*` config section):
   ```bash
   git branch -D "$merged_branch"
   ```
   Do not delete it before step 4 — the fallback boundary may need it.

6. Update the remaining branches' metadata:
   ```bash
   # Decrement every remaining order above the merged one
   stack_branches "$stack_name" | while read -r o b; do
     [ "$o" -gt "$merged_order" ] && git config --local "branch.$b.stack-order" "$((o - 1))"
   done
   # The child's parent becomes whatever the merged branch's parent was (usually the base)
   git config --local "branch.$child.stack-parent" "<merged branch's former parent>"
   size=$(git config --local "stack.$stack_name.size")
   git config --local "stack.$stack_name.size" "$((size - 1))"
   refresh_parent_shas "$stack_name"
   ```
   Branch names keep their original numbers — that's expected.

7. Force-push **every** remaining branch, since `--update-refs` rewrote all of them:
   ```bash
   stack_branches "$stack_name" | while read -r _ b; do
     git push --force-with-lease origin "$b"
   done
   ```

8. Retarget the child's PR to the base (after pushing, so its diff is correct immediately). GitHub may already have done this if the merged branch was auto-deleted; running it again is harmless:
   ```bash
   pr_number=$(gh pr list --head "$child" --json number --jq '.[0].number')
   [ -n "$pr_number" ] && gh pr edit "$pr_number" --base "$base"
   ```

9. Show updated stack status.

---

### 7. `stack submit` — Create or Update PRs

Pushes every branch and creates PRs for branches that don't have one, with correct base branches. Works in two passes, because the "Stack" section in each PR body needs every PR number.

**Pass 1 — push and create:**

For each branch in `stack_branches` order:

1. Check if an open PR exists:
   ```bash
   pr=$(gh pr list --head "$branch" --json number --jq '.[0].number')
   ```

2. Push:
   - Branch not yet on the remote: `git push -u origin "$branch"`
   - Branch already on the remote (it may have been rebased): `git push --force-with-lease origin "$branch"`

3. If no PR exists, create one. Its base is the base branch for order 1, otherwise the parent branch:
   ```bash
   gh pr create --head "$branch" --base "<base or parent-branch>" --title "<title>" --body "<body>"
   ```

**Pass 2 — stack section:**

Once every branch has a PR, update each PR body with a "Stack" section listing all PRs in order, marking the current one. Replace an existing section rather than appending a second one (wrap it in `<!-- stack -->` / `<!-- /stack -->` markers so it can be found):

```markdown
<!-- stack -->
## Stack
- #142
- #143 ← this PR
- #144
<!-- /stack -->
```

```bash
gh pr view "$pr" --json body --jq .body   # read current body, replace the marked section
gh pr edit "$pr" --body "<new body>"
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
After any rebase, every rewritten branch needs force-pushing:
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
If `.git/config` metadata is missing (e.g., after cloning), reconstruct it from branch names. See "Reconstruct Lost Metadata" in [references/stack-commands-reference.md](references/stack-commands-reference.md). Orders are stored as plain integers, parents are the previous branch (the base for the first), and `stack-parent-sha` is the merge-base with the parent.

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
