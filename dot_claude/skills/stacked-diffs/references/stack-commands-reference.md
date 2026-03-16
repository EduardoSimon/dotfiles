# Stack Commands — Quick Reference

## Metadata Queries

```bash
# Get current branch's stack name
git config --local branch.$(git branch --show-current).stack-name

# Get current branch's order in stack
git config --local branch.$(git branch --show-current).stack-order

# Get current branch's parent
git config --local branch.$(git branch --show-current).stack-parent

# Get stack base branch
git config --local stack.<stack-name>.base

# Get stack size
git config --local stack.<stack-name>.size

# List all branches in a stack
git config --get-regexp 'branch\..*\.stack-name' | grep '<stack-name>'

# List all stacks
git config --get-regexp 'stack\..*\.base'
```

## Stack Operations

### Create Stack
```bash
base=$(git remote show origin | sed -n '/HEAD branch/s/.*: //p')
git fetch origin $base
git checkout origin/$base -b <stack>/<01>-<desc>
git config --local branch.<stack>/<01>-<desc>.stack-name "<stack>"
git config --local branch.<stack>/<01>-<desc>.stack-order "01"
git config --local branch.<stack>/<01>-<desc>.stack-parent "$base"
git config --local stack.<stack>.base "$base"
git config --local stack.<stack>.size "1"
```

### Add Branch
```bash
git checkout -b <stack>/<NN>-<desc>
git config --local branch.<stack>/<NN>-<desc>.stack-name "<stack>"
git config --local branch.<stack>/<NN>-<desc>.stack-order "<N>"
git config --local branch.<stack>/<NN>-<desc>.stack-parent "<prev-branch>"
git config --local stack.<stack>.size "<new-size>"
```

### Navigate
```bash
# Up (next branch)
git checkout <stack>/<NN+1>-<desc>

# Down (previous branch)
git checkout <stack>/<NN-1>-<desc>
```

### Sync (rebase cascade)
```bash
# Preferred: git 2.38+
# Rebase onto the changed branch (updates all branches above it)
git checkout <tip-branch>
git rebase <changed-branch> --update-refs
# If base branch was updated:
# git rebase origin/<base> --update-refs

# Fallback: manual cascade
git checkout <branch-2> && git rebase <branch-1>
git checkout <branch-3> && git rebase <branch-2>
# ...
```

### Land (after squash merge)
```bash
git fetch origin <base>
# Single command: rebase entire remaining stack, --update-refs updates intermediate branches
git checkout <tip-branch>
git rebase --onto origin/<base> <merged-branch> --update-refs
# If only one branch remains (no tip above child):
# git rebase --onto origin/<base> <merged-branch> <child-branch>
git branch -D <merged-branch>
git push --force-with-lease origin <child-branch>
gh pr edit <child-pr> --base <base>
```

### Submit (create/update PRs)
```bash
# First branch
git push -u origin <branch>
gh pr create --head <branch> --base <base>

# Subsequent branches
git push -u origin <branch>
gh pr create --head <branch> --base <parent-branch>

# After force push
git push --force-with-lease origin <branch>
```

## Force Push Safety

Always use `--force-with-lease` instead of `--force`:
```bash
git push --force-with-lease origin <branch>
```

## Reconstruct Lost Metadata

```bash
# From branch naming convention <stack>/<NN>-<desc>
for branch in $(git branch --list '<stack>/*' --sort=refname --format='%(refname:short)'); do
  order=$(echo "$branch" | sed 's|.*/\([0-9]*\)-.*|\1|')
  git config --local branch.$branch.stack-name "<stack>"
  git config --local branch.$branch.stack-order "$((10#$order))"
done
```
