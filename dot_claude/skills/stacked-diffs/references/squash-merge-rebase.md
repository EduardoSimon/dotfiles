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
```

### After squash merge of branch-01

GitHub creates squash commit `S` on main (contains C+D squashed):

```
main:    A---B---S
              \
branch-01:     C---D        (merged, but these commits are orphaned)
                    \
branch-02:           E---F  (still based on D, not S)
```

### The fix: `git rebase --onto`

```bash
git rebase --onto origin/main branch-01 branch-02
```

This says: "Take the commits unique to branch-02 (E, F) — i.e., everything after branch-01 — and replay them onto origin/main."

### After the fix

```
main:    A---B---S
                  \
branch-02:         E'---F'  (clean, based on S)
```

## Step by Step

1. **Fetch latest main:**
   ```bash
   git fetch origin main
   ```

2. **Rebase child onto main, skipping merged parent:**
   ```bash
   git rebase --onto origin/main <merged-branch> <child-branch>
   ```
   - `origin/main` = new base (where to put the commits)
   - `<merged-branch>` = old base (commits to skip — everything up to and including this ref)
   - `<child-branch>` = branch to rebase (commits after `<merged-branch>` get replayed)

3. **If more branches exist above child, cascade:**
   ```bash
   # With --update-refs (git 2.38+):
   git checkout <tip-branch>
   git rebase --update-refs <child-branch>

   # Without --update-refs:
   git checkout <grandchild-branch>
   git rebase <child-branch>
   # repeat for each subsequent branch
   ```

4. **Force push rebased branches:**
   ```bash
   git push --force-with-lease origin <child-branch>
   # repeat for each rebased branch
   ```

5. **Update PR base on GitHub:**
   ```bash
   gh pr edit <child-pr-number> --base main
   ```

## Common Pitfalls

### Don't use plain `git rebase main`
This replays ALL commits from the fork point, including the parent's commits that were already squash-merged. You'll get duplicate changes and conflicts.

### Don't delete the merged branch before rebasing
You need the merged branch ref as the `<upstream>` argument to `--onto`. Delete it after the rebase completes.

### Watch for amended commits
If you amended commits in branch-01 before squash merging, the local branch-01 ref might not match what was merged. This is usually fine — `--onto` skips everything up to that ref regardless.

## Verify Success

After rebasing, verify no duplicate commits exist:

```bash
# Check that child branch has only its own commits
git log --oneline origin/main..<child-branch>

# Should show only E', F' — not C, D, E', F'
```
