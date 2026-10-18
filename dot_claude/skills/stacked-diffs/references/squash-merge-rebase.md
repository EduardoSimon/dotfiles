# Squash Merge Rebase — Detailed Reference

## The Problem

When GitHub squash-merges a PR, it creates a **single new commit** on main that contains all the changes from the branch. The original branch commits are NOT ancestors of this new commit.

This means child branches still point to the old (now orphaned) commits. A naive `git rebase main` on the child will try to replay the parent's commits too, causing duplicate changes and conflicts.

## Visual Example

### Before squash merge

```
main:    A---B
              \
branch-01:     C---D        (PR #1)
                    \
branch-02:           E---F  (PR #2)
                          \
branch-03:                 G  (PR #3)
```

### After squash merge of branch-01

GitHub creates squash commit `S` on main (contains C+D squashed):

```
main:    A---B---S
              \
branch-01:     C---D        (merged, but these commits are orphaned)
                    \
branch-02:           E---F  (still based on D, not S)
                          \
branch-03:                 G
```

### The fix: one `git rebase --onto` from the tip

```bash
git checkout branch-03
git rebase --onto origin/main <D> --update-refs
```

This says: "Take every commit after `D` that leads to the tip (E, F, G) and replay them onto origin/main." `--update-refs` moves `branch-02` along with its rewritten commits.

`<D>` is the child's recorded `stack-parent-sha` (the merged branch's tip when branch-02 was last based on it). Use `branch-01` itself only if no SHA is recorded.

### After the fix

```
main:    A---B---S
                  \
branch-02:         E'---F'  (clean, based on S)
                         \
branch-03:                G'
```

## Step by Step

1. **Fetch latest main:**
   ```bash
   git fetch origin main
   ```

2. **Rebase the whole remaining stack in one command, from the tip:**
   ```bash
   old_parent=$(git config --local branch.<child-branch>.stack-parent-sha)   # or <merged-branch>
   git checkout <tip-branch>
   git rebase --onto origin/main "$old_parent" --update-refs
   ```
   - `origin/main` = new base (where to put the commits)
   - `$old_parent` = old base (it and everything before it is skipped)
   - `--update-refs` = every branch between the boundary and the tip is moved too

   If the child is the tip, the same command works.

3. **Without `--update-refs` (git < 2.38)**, cascade manually and **save each branch's old tip before rebasing it**:
   ```bash
   old_child=$(git rev-parse <child-branch>)
   git rebase --onto origin/main "$old_parent" <child-branch>

   old_grandchild=$(git rev-parse <grandchild-branch>)
   git rebase --onto <child-branch> "$old_child" <grandchild-branch>
   # repeat for each subsequent branch, using the previous branch's saved old tip
   ```

4. **Force push every rebased branch:**
   ```bash
   git push --force-with-lease origin <child-branch>
   git push --force-with-lease origin <grandchild-branch>
   # ...every branch that was rewritten
   ```

5. **Update PR base on GitHub:**
   ```bash
   gh pr edit <child-pr-number> --base main
   ```

## Common Pitfalls

### Don't use plain `git rebase main`
This replays ALL commits from the fork point, including the parent's commits that were already squash-merged. You'll get duplicate changes and conflicts.

### Don't cascade with plain `git rebase <child-branch>`
After rebasing only the child, running `git rebase <child-branch>` from the tip **conflicts**: the tip still contains the squashed parent's original commits (C, D), and they get replayed onto the new base. Either rebase the whole stack in one `--onto ... --update-refs` command (step 2), or cascade with `--onto` and the saved old tips (step 3).

### Don't delete the merged branch before rebasing
If no `stack-parent-sha` is recorded, you need the merged branch ref as the `<upstream>` argument to `--onto`. Delete it after the rebase completes.

### Watch for amended commits
If branch-01 was amended *after* branch-02 was based on it, the local branch-01 ref no longer marks where branch-02's own commits start — the old, pre-amend commits are still in branch-02 and would be replayed. That's why the recorded `stack-parent-sha` is preferred over the branch ref. If no SHA is recorded, `git merge-base --fork-point branch-01 branch-02` can recover the old tip from branch-01's reflog.

## Verify Success

After rebasing, verify no duplicate commits exist:

```bash
# Check that each branch has only its own commits
git log --oneline origin/main..<child-branch>       # should show only E', F'
git log --oneline <child-branch>..<grandchild>      # should show only G'
```
