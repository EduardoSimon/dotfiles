# Stack Commands — Quick Reference

All snippets are bash. From fish, run them through `bash -c '...'`. `stack_branches`, `branch_at` and `refresh_parent_shas` are defined in SKILL.md under "Helpers".

## Metadata Queries

```bash
# Get current branch's stack name
git config --local "branch.$(git branch --show-current).stack-name"

# Get current branch's order in stack (plain integer)
git config --local "branch.$(git branch --show-current).stack-order"

# Get current branch's parent, and the parent tip it was based on
git config --local "branch.$(git branch --show-current).stack-parent"
git config --local "branch.$(git branch --show-current).stack-parent-sha"

# Get stack base branch
git config --local stack.<stack-name>.base

# Get stack size
git config --local stack.<stack-name>.size

# List all branches in a stack, sorted by order (exact stack-name match)
stack_branches <stack-name>

# List all stacks
git config --local --get-regexp '^stack\..*\.base$'
```

## Stack Operations

### Create Stack
```bash
base=$(git symbolic-ref --short refs/remotes/origin/HEAD | sed 's|^origin/||')
git fetch origin "$base"
b="<stack>/01-<desc>"
git checkout -b "$b" "origin/$base"
git config --local "branch.$b.stack-name" "<stack>"
git config --local "branch.$b.stack-order" "1"
git config --local "branch.$b.stack-parent" "$base"
git config --local "branch.$b.stack-parent-sha" "$(git rev-parse "origin/$base")"
git config --local "stack.<stack>.base" "$base"
git config --local "stack.<stack>.size" "1"
```

### Add Branch
```bash
prev=$(git branch --show-current)
n=$(( $(git config --local "branch.$prev.stack-order") + 1 ))
b="<stack>/$(printf '%02d' "$n")-<desc>"
git checkout -b "$b"
git config --local "branch.$b.stack-name" "<stack>"
git config --local "branch.$b.stack-order" "$n"
git config --local "branch.$b.stack-parent" "$prev"
git config --local "branch.$b.stack-parent-sha" "$(git rev-parse "$prev")"
git config --local "stack.<stack>.size" "<new-size>"
```

### Navigate
```bash
order=$(git config --local "branch.$(git branch --show-current).stack-order")
# Up (next branch)
git checkout "$(branch_at <stack> "$((order + 1))")"
# Down (previous branch)
git checkout "$(branch_at <stack> "$((order - 1))")"
```
Check the result of `branch_at` is non-empty first — empty means top/bottom of the stack.

### Sync (after a lower branch changed)
```bash
# Preferred: git 2.38+ — replay only each branch's own commits
old_parent=$(git config --local "branch.<child-of-changed>.stack-parent-sha")
# fallback: old_parent=$(git merge-base --fork-point <changed-branch> <child-of-changed>)
git checkout <tip-branch>
git rebase --onto <changed-branch> "$old_parent" --update-refs

# If the base branch was updated:
# old_parent=$(git config --local "branch.<first-branch>.stack-parent-sha")
# git rebase --onto origin/<base> "$old_parent" --update-refs

refresh_parent_shas <stack>

# Fallback (git < 2.38): cascade, saving each old tip before rebasing it
old_tip=$(git rev-parse <branch-2>)
git rebase --onto <branch-1> "$old_parent" <branch-2>
next_old=$(git rev-parse <branch-3>)
git rebase --onto <branch-2> "$old_tip" <branch-3>
# ...
```

### Land (after squash merge)
```bash
git fetch origin <base>
old_parent=$(git config --local "branch.<child-branch>.stack-parent-sha")   # or <merged-branch>
git checkout <tip-branch>
git rebase --onto "origin/<base>" "$old_parent" --update-refs   # also works if child is the tip
git branch -D <merged-branch>
# decrement remaining orders, set child's parent to the base, size - 1, refresh_parent_shas
for b in <every remaining branch>; do git push --force-with-lease origin "$b"; done
gh pr edit <child-pr> --base <base>
```

### Submit (create/update PRs)
```bash
# Pass 1, for each branch in order:
git push -u origin <branch>                     # branch not on the remote yet
git push --force-with-lease origin <branch>     # branch already on the remote
gh pr create --head <branch> --base <base>            # first branch, if no PR
gh pr create --head <branch> --base <parent-branch>   # later branches, if no PR

# Pass 2: once every PR exists, replace the <!-- stack --> section in each body
gh pr edit <pr> --body "<body with updated stack section>"
```

## Force Push Safety

Always use `--force-with-lease` instead of `--force`:
```bash
git push --force-with-lease origin <branch>
```

## Reconstruct Lost Metadata

```bash
# From branch naming convention <stack>/<NN>-<desc>
stack=<stack>
base=$(git symbolic-ref --short refs/remotes/origin/HEAD | sed 's|^origin/||')
parent=$base
n=0
for branch in $(git branch --list "$stack/*" --sort=refname --format='%(refname:short)'); do
  n=$((n + 1))
  git config --local "branch.$branch.stack-name" "$stack"
  git config --local "branch.$branch.stack-order" "$n"
  git config --local "branch.$branch.stack-parent" "$parent"
  if [ "$parent" = "$base" ]; then ref="origin/$base"; else ref=$parent; fi
  git config --local "branch.$branch.stack-parent-sha" "$(git merge-base "$ref" "$branch")"
  parent=$branch
done
git config --local "stack.$stack.base" "$base"
git config --local "stack.$stack.size" "$n"
```
Orders are numbered 1..n in name order (not parsed from the names), so gaps left by landed branches are closed.
