function platform::is_linux
    test (uname -s) = "Linux"
end

function platform::is_wsl
    grep -qEi "(Microsoft|WSL|microsoft)" /proc/version >/dev/null
end

function platform::is_macos
    test (uname -s) = "Darwin"
end

function cdd
    cd (ls -d -- */ | fzf) ^/dev/null; or echo "Invalid directory"
end

function abs_path
    echo (realpath $argv[1])
end

function jira
    open -a "Google Chrome" "$JIRA_PROJECT_URL/$argv[1]"
end

function force-push-monoenv
    if test (count $argv) -ne 1
        echo "usage: push-monoenv <environment>"
        return 1
    end

    set ENVIRONMENT $argv[1]
    set BRANCH (git rev-parse --abbrev-ref HEAD)

    git fetch -p
    and git branch -f $ENVIRONMENT HEAD
    and git checkout $ENVIRONMENT
    and git commit --allow-empty -m "[SKIP_MANUAL]"
    and git push --force origin $ENVIRONMENT
    and git checkout $BRANCH
end

# Function to merge the current branch into a specified environment branch
# after ensuring the environment branch matches its origin counterpart.
# Fails safely if the working directory has uncommitted changes.
function merge-to-monoenv
    # Check if exactly one argument (environment) is provided
    if test (count $argv) -ne 1
        echo "Usage: merge-to-monoenv <environment>"
        return 1
    end

    set -l ENVIRONMENT $argv[1]
    set -l BRANCH (git rev-parse --abbrev-ref HEAD)
    if test $status -ne 0
        echo "Error: Failed to get current branch name."
        return 1
    end

    echo "Attempting to merge branch '$BRANCH' into '$ENVIRONMENT'..."

    # --- Safety Check: Ensure working directory is clean ---
    set -l dirty_status (git status --porcelain)
    if test -n "$dirty_status" # Check if the output of git status --porcelain is not empty
        echo "Error: Working directory is not clean. Please commit, stash, or discard changes."
        # Show the status for clarity
        git status --short
        return 1
    end
    echo "✓ Working directory clean."

    # --- Prepare Environment Branch ---
    echo "Updating local '$ENVIRONMENT' branch..."
    # Fetch the latest changes from the remote
    if not git fetch origin
        echo "Error: Failed to fetch from origin."
        return 1
    end
    echo "✓ Fetched origin."

    # Checkout the target environment branch
    if not git checkout $ENVIRONMENT
        echo "Error: Failed to checkout branch '$ENVIRONMENT'."
        # Attempt to switch back to the original branch for safety
        git checkout $BRANCH >/dev/null 2>&1
        return 1
    end
    echo "✓ Checked out '$ENVIRONMENT'."

    # Reset the local environment branch to match the remote one
    # This is safe now because we checked for a clean working directory earlier.
    if not git reset --hard origin/$ENVIRONMENT
        echo "Error: Failed to reset '$ENVIRONMENT' to 'origin/$ENVIRONMENT'."
        # Attempt to switch back to the original branch for safety
        git checkout $BRANCH >/dev/null 2>&1
        return 1
    end
    echo "✓ Reset '$ENVIRONMENT' to match 'origin/$ENVIRONMENT'."

    # --- Merge and Push ---
    echo "Merging '$BRANCH' into '$ENVIRONMENT'..."
    # Merge the original branch into the environment branch
    if not git merge $BRANCH --no-edit
        echo "Error: Failed to merge '$BRANCH' into '$ENVIRONMENT'. Resolve conflicts and commit manually."
        # Leave the user on the ENVIRONMENT branch to resolve conflicts
        return 1
    end
    echo "✓ Merged '$BRANCH'."

    # Create the empty commit marker
    if not git commit --allow-empty -m "[SKIP_MANUAL]"
        echo "Error: Failed to create empty commit marker."
        # Attempt to switch back to the original branch for safety
        git checkout $BRANCH >/dev/null 2>&1
        return 1
    end
    echo "✓ Created skip commit."

    # Push the changes to the remote environment branch
    if not git push origin $ENVIRONMENT
        echo "Error: Failed to push '$ENVIRONMENT' to origin."
        # Attempt to switch back to the original branch for safety
        git checkout $BRANCH >/dev/null 2>&1
        return 1
    end
    echo "✓ Pushed '$ENVIRONMENT' to origin."

    # --- Cleanup ---
    echo "Switching back to branch '$BRANCH'..."
    # Checkout the original branch
    if not git checkout $BRANCH
        echo "Warning: Failed to switch back to branch '$BRANCH'. Please check manually."
        # Don't return error here, as the main goal was achieved, but warn the user.
    else
        echo "✓ Switched back to '$BRANCH'."
    end

    echo "Merge to '$ENVIRONMENT' completed successfully."
    return 0
end

function compare-branches
    "$DOTFILES_PATH/scripts/git/compare-branches.sh" $argv
end

function git-commit
    "$DOTFILES_PATH/scripts/git/commit-no-sign.sh" $argv
end

function pretty-diff
    "$DOTFILES_PATH/scripts/git/pretty-diff.sh"
end

function pretty-log
    "$DOTFILES_PATH/scripts/git/pretty-log.sh"
end

function generate-uuid
    set uuid (uuidgen | tr '[:upper:]' '[:lower:]')
    if platform::is_macos
        echo -n $uuid | pbcopy
        osascript -e "display notification \"$uuid\" with title \"UUID copied to the clipboard\""
    else if platform::is_wsl
        echo -n $uuid | clip.exe
    else
        echo -n $uuid | xclip -sel clipboard
        notify-send "UUID copied to the clipboard"
    end
end

function monoenv_git_refresh
    set MONOENVS apache tuculca rockola espiral spook barraca puzzle

    for MONOENV in $MONOENVS
        git checkout $MONOENV
        and git reset --hard origin/master
        and git commit --allow-empty -m "[SKIP_MANUAL]"
        and git push -f origin $MONOENV
    end
end

function timestamp-to-date
    "$DOTFILES_PATH/scripts/utils/timestamp_to_date.sh"
end

function command_exists
    type $argv[1] >/dev/null 2>&1
end

function jboard
    open "$JIRA_BOARD_URL"
end

function fpush-with-mr
  if test (count $argv) -eq 0
    echo "Usage: gpush <branch_name> [<labels>]"
    echo "  <branch_name>: The name of the branch to push."
    echo "  <labels>: Optional. A comma-separated list of labels for the merge request."
    return 1
  end

  set branch $argv[1]
  set default_labels "INEX::review"
  set labels $default_labels

  if set -q argv[2]
    set labels $argv[2]
  end

  git push -u -f origin $branch -o merge_request.create -o merge_request.label=$labels
end

function create-stack
  argparse 'no-merge-request' -- $argv

  if test (count $argv) -eq 0
    echo "Usage: create-stack [--no-merge-request] <stack_name>"
    echo "  <stack_name>: The name of the stack to append to the branch."
    echo "  --no-merge-request: Do not create a merge request."
    return 1
  end

  set current_branch (git rev-parse --abbrev-ref HEAD)
  set stack_name $argv[1]
  set new_branch_name "$current_branch-$stack_name"

  # Create the new branch
  git branch -f "$new_branch_name" HEAD

  echo "Created new branch: $new_branch_name"

  # Conditionally push and create a merge request
  if not set -q _flag_no_mr
    # Assuming fpush-with-mr takes the branch name as an argument
    fpush-with-mr "$new_branch_name"
  end
end

