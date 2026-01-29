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
    and git commit --allow-empty -m "[SKIP_MANUAL][FULL_PIPELINE][RUN_CD]"
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
    if not git commit --allow-empty -m "[SKIP_MANUAL][RUN_CD]"
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
        and git commit --allow-empty -m "[SKIP_MANUAL][FULL_PIPELINE]"
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
  set default_labels "PFX::review"
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

function list-stacks
  set current_branch (git rev-parse --abbrev-ref HEAD)
  if test $status -ne 0
    echo "Error: Failed to get current branch name."
    return 1
  end

  # Get all branches that start with current branch name followed by a dash
  set stack_branches (git branch --format="%(refname:short)" | grep "^$current_branch-")

  if test (count $stack_branches) -eq 0
    echo "No stacks found for branch: $current_branch"
    return 0
  end

  echo "Stacks for branch '$current_branch':"
  for branch in $stack_branches
    # Extract the stack name (everything after the last dash of the current branch pattern)
    set stack_name (echo $branch | sed "s/^$current_branch-//")
    echo "  - $stack_name ($branch)"
  end
end

function cc
    claude --allow-dangerously-skip-permissions
end

function cc-resume
    claude --allow-dangerously-skip-permissions --resume
end

function dev-session
    set -l ticket $argv[1]

    if test -z "$ticket"
        echo "Usage: dev-session <ticket-name>"
        return 1
    end

    echo "🌳 Creating and switching to worktree: $ticket"
    # Create new worktree and switch to it
    wt switch --create $ticket

    if test $status -ne 0
        echo "❌ Failed to create worktree"
        return 1
    end

    # Get current directory name (after wt switch)
    set -l dir_name (basename $PWD)

    # Create session name (ticket already in workspace/dir name)
    set -l session_name "$dir_name"

    # Check if tmux session already exists
    if tmux has-session -t $session_name 2>/dev/null
        echo "📌 Attaching to existing session: $session_name"

        # Call dev to ensure authentication (only if defined)
        if type -q dev
            echo "🔐 Authenticating with dev environment..."
            dev
        end

        # Attach to existing session
        tmux attach-session -t $session_name
    else
        # Call dev to ensure authentication (only if defined)
        if type -q dev
            echo "🔐 Authenticating with dev environment..."
            dev
        end

        echo "📂 Creating tmux session: $session_name"
        echo "🪟 Setting up 2-pane window layout..."
        echo "🤖 Starting Claude Code in first pane..."

        # Create new tmux session and split into 2 panes
        # First pane runs cc command, second pane is empty
        tmux new-session -s $session_name "cc" \; split-window -h
    end
end

function wt-remove-all -d "Remove all worktrees except main"
    wt list --format json | jq -r '.[] | select(.branch == "main" | not) | .branch' | xargs -I {} wt remove {}
end

function dev-list
    echo "📋 Development Sessions:"
    echo ""

    # Get all worktrees
    set -l worktree_data (git worktree list --porcelain 2>/dev/null)

    if test $status -ne 0
        echo "❌ Not in a git repository"
        return 1
    end

    # Get all tmux sessions
    set -l tmux_sessions (tmux list-sessions -F "#{session_name}" 2>/dev/null)

    # Parse worktrees
    set -l worktree_path ""
    set -l branch_name ""
    set -l found_worktrees 0

    # Print header
    printf "%-30s %-35s %-15s\n" "Worktree" "Branch" "Tmux Session"
    printf "%-30s %-35s %-15s\n" "--------" "------" "------------"

    for line in $worktree_data
        if string match -q "worktree *" $line
            set worktree_path (string replace "worktree " "" $line)
        else if string match -q "branch *" $line
            set branch_name (string replace "branch refs/heads/" "" $line)

            # Extract session name from worktree path
            set -l session_name (basename $worktree_path)

            # Check if tmux session exists
            set -l session_status "✗"
            if contains $session_name $tmux_sessions
                set session_status "✓"
            end

            # Print the entry
            printf "%-30s %-35s %-15s\n" $session_name $branch_name $session_status
            set found_worktrees 1

            # Reset for next worktree
            set worktree_path ""
            set branch_name ""
        end
    end

    if test $found_worktrees -eq 0
        echo "No worktrees found"
    end
end

function dev-remove
    set -l ticket $argv[1]

    if test -z "$ticket"
        echo "Usage: dev-remove <ticket-name>"
        return 1
    end

    echo "🔍 Searching for worktree: $ticket"

    # Get all worktrees
    set -l worktree_data (git worktree list --porcelain 2>/dev/null)

    if test $status -ne 0
        echo "❌ Not in a git repository"
        return 1
    end

    # Find the worktree path matching the ticket
    set -l worktree_path ""
    set -l found 0

    for line in $worktree_data
        if string match -q "worktree *" $line
            set -l path (string replace "worktree " "" $line)
            set -l dir_name (basename $path)

            if test "$dir_name" = "$ticket"
                set worktree_path $path
                set found 1
                break
            end
        end
    end

    if test $found -eq 0
        echo "❌ Worktree not found: $ticket"
        return 1
    end

    echo "✓ Found worktree at: $worktree_path"

    # Extract session name (basename of worktree path)
    set -l session_name (basename $worktree_path)

    # Check if we're currently in the worktree being removed
    if string match -q "$worktree_path*" $PWD
        echo "⚠️  You are currently inside the worktree being removed"
        echo "Please switch to another directory first"
        return 1
    end

    # Check for uncommitted changes
    set -l current_dir $PWD
    cd $worktree_path
    set -l dirty_status (git status --porcelain)
    cd $current_dir

    if test -n "$dirty_status"
        echo "⚠️  Worktree has uncommitted changes:"
        cd $worktree_path
        git status --short
        cd $current_dir
        echo ""
        echo "Please commit or stash changes before removing"
        return 1
    end

    # Kill tmux session if it exists
    if tmux has-session -t $session_name 2>/dev/null
        echo "🔪 Killing tmux session: $session_name"
        tmux kill-session -t $session_name

        if test $status -ne 0
            echo "⚠️  Failed to kill tmux session"
        else
            echo "✓ Tmux session killed"
        end
    else
        echo "ℹ️  No active tmux session found"
    end

    # Remove worktree
    echo "🗑️  Removing worktree: $ticket"

    # Use git worktree remove directly (wt remove expects branch names)
    git worktree remove $worktree_path

    if test $status -ne 0
        echo "❌ Failed to remove worktree"
        return 1
    end

    # Prune worktree references
    git worktree prune

    echo "✓ Successfully removed dev session: $ticket"
end

