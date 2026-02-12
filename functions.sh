function platform::is_linux() {
	[[ $(uname -s) == "Linux" ]]
}

function platform::is_wsl() {
	grep -qEi "(Microsoft|WSL|microsoft)" /proc/version &>/dev/null
}

function platform::is_macos() {
	[[ $(uname -s) == "Darwin" ]]
}

function cdd() {
  cd "$(ls -d -- */ | fzf)" || echo "Invalid directory"
}

function abs_path() {
    echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
}

function jira() {
  open -a "Google Chrome" "${JIRA_PROJECT_URL}/${1}"
}

function force-push-monoenv() { 
if [ $# -ne 1 ]; then
  echo "usage: push-monoenv <environment>"
  return 1
fi
ENVIRONMENT=$1
BRANCH=$(git rev-parse --abbrev-ref HEAD)
git fetch -p && git branch -f $ENVIRONMENT HEAD && git checkout $ENVIRONMENT &&
  git commit --allow-empty -m "[SKIP_MANUAL]" && git push --force origin
  $ENVIRONMENT && git checkout $BRANCH
}

function merge-to-monoenv() {
    if [ $# -ne 1 ]; then
        echo "Usage: merge-to-monoenv <environment>"
        return 1
    fi

    local ENVIRONMENT="$1"
    local BRANCH
    BRANCH=$(git rev-parse --abbrev-ref HEAD)
    if [ $? -ne 0 ]; then
        echo "Error: Failed to get current branch name."
        return 1
    fi

    echo "Attempting to merge branch '$BRANCH' into '$ENVIRONMENT'..."

    # Safety check: ensure working directory is clean
    local dirty_status
    dirty_status=$(git status --porcelain)
    if [ -n "$dirty_status" ]; then
        echo "Error: Working directory is not clean. Please commit, stash, or discard changes."
        git status --short
        return 1
    fi
    echo "Working directory clean."

    # Fetch latest
    if ! git fetch origin; then
        echo "Error: Failed to fetch from origin."
        return 1
    fi
    echo "Fetched origin."

    # Checkout environment branch
    if ! git checkout "$ENVIRONMENT"; then
        echo "Error: Failed to checkout branch '$ENVIRONMENT'."
        git checkout "$BRANCH" >/dev/null 2>&1
        return 1
    fi
    echo "Checked out '$ENVIRONMENT'."

    # Reset to match remote
    if ! git reset --hard "origin/$ENVIRONMENT"; then
        echo "Error: Failed to reset '$ENVIRONMENT' to 'origin/$ENVIRONMENT'."
        git checkout "$BRANCH" >/dev/null 2>&1
        return 1
    fi
    echo "Reset '$ENVIRONMENT' to match 'origin/$ENVIRONMENT'."

    # Merge
    if ! git merge "$BRANCH" --no-edit; then
        echo "Error: Failed to merge '$BRANCH' into '$ENVIRONMENT'. Resolve conflicts and commit manually."
        return 1
    fi
    echo "Merged '$BRANCH'."

    # Empty commit marker
    if ! git commit --allow-empty -m "[SKIP_MANUAL][RUN_CD]"; then
        echo "Error: Failed to create empty commit marker."
        git checkout "$BRANCH" >/dev/null 2>&1
        return 1
    fi
    echo "Created skip commit."

    # Push
    if ! git push origin "$ENVIRONMENT"; then
        echo "Error: Failed to push '$ENVIRONMENT' to origin."
        git checkout "$BRANCH" >/dev/null 2>&1
        return 1
    fi
    echo "Pushed '$ENVIRONMENT' to origin."

    # Switch back
    if ! git checkout "$BRANCH"; then
        echo "Warning: Failed to switch back to branch '$BRANCH'. Please check manually."
    else
        echo "Switched back to '$BRANCH'."
    fi

    echo "Merge to '$ENVIRONMENT' completed successfully."
    return 0
}

function compare-branches() {
  "$DOTFILES_PATH/scripts/git/compare-branches.sh" "$@"
}

function git-commit() {
  "$DOTFILES_PATH/scripts/git/commit-no-sign.sh" "$@"
}

function pretty-diff() {
  "$DOTFILES_PATH/scripts/git/pretty-diff.sh"
}

function pretty-log() {
  "$DOTFILES_PATH/scripts/git/pretty-log.sh"
}

function generate-uuid() {
uuid=$(uuidgen | tr '[:upper:]' '[:lower:]')
if platform::is_macos; then
	echo -n $uuid | pbcopy
	osascript -e 'display notification "'"$uuid"'" with title "UUID copied to the clipboard"'
elif platform::is_wsl; then
	echo -n $uuid | clip.exe
else
	echo -n $uuid | xclip -sel clipboard
	notify-send "UUID copied to the clipboard"
fi
}

function monoenv_git_refresh() {
  MONOENVS=( apache tuculca rockola espiral spook barraca puzzle )

  for MONOENV in "${MONOENVS[@]}"; do
    git checkout $MONOENV
    git reset --hard origin/master
    git commit --allow-empty -m "[SKIP_MANUAL]"
    git push -f origin $MONOENV
  done
}

function timestamp-to-date() {
  "$DOTFILES_PATH/scripts/utils/timestamp_to_date.sh"
}

function command_exists() {
	type "$1" >/dev/null 2>&1
}

function jboard() {
    open "$JIRA_BOARD_URL"
}

function fpush-with-mr() {
    if [ $# -eq 0 ]; then
        echo "Usage: fpush-with-mr <branch_name> [<labels>]"
        echo "  <branch_name>: The name of the branch to push."
        echo "  <labels>: Optional. A comma-separated list of labels for the merge request."
        return 1
    fi

    local branch="$1"
    local default_labels="PFX::review"
    local labels="${2:-$default_labels}"

    git push -u -f origin "$branch" -o merge_request.create -o "merge_request.label=$labels"
}

function create-stack() {
    local no_merge_request=false

    if [ "$1" = "--no-merge-request" ]; then
        no_merge_request=true
        shift
    fi

    if [ $# -eq 0 ]; then
        echo "Usage: create-stack [--no-merge-request] <stack_name>"
        echo "  <stack_name>: The name of the stack to append to the branch."
        echo "  --no-merge-request: Do not create a merge request."
        return 1
    fi

    local current_branch
    current_branch=$(git rev-parse --abbrev-ref HEAD)
    local stack_name="$1"
    local new_branch_name="${current_branch}-${stack_name}"

    git branch -f "$new_branch_name" HEAD
    echo "Created new branch: $new_branch_name"

    if [ "$no_merge_request" = false ]; then
        fpush-with-mr "$new_branch_name"
    fi
}

function list-stacks() {
    local current_branch
    current_branch=$(git rev-parse --abbrev-ref HEAD)
    if [ $? -ne 0 ]; then
        echo "Error: Failed to get current branch name."
        return 1
    fi

    local stack_branches
    stack_branches=$(git branch --format="%(refname:short)" | grep "^${current_branch}-")

    if [ -z "$stack_branches" ]; then
        echo "No stacks found for branch: $current_branch"
        return 0
    fi

    echo "Stacks for branch '$current_branch':"
    while IFS= read -r branch; do
        local stack_name="${branch#${current_branch}-}"
        echo "  - $stack_name ($branch)"
    done <<< "$stack_branches"
}

function cc() {
    claude --allow-dangerously-skip-permissions
}

function cc-resume() {
    claude --allow-dangerously-skip-permissions --resume
}

function dev-session() {
    local ticket="$1"

    if [ -z "$ticket" ]; then
        echo "Usage: dev-session <ticket-name>"
        return 1
    fi

    echo "Creating and switching to worktree: $ticket"
    wt switch --create "$ticket"

    if [ $? -ne 0 ]; then
        echo "Failed to create worktree"
        return 1
    fi

    local dir_name
    dir_name=$(basename "$PWD")
    local session_name="$dir_name"

    if tmux has-session -t "$session_name" 2>/dev/null; then
        echo "Attaching to existing session: $session_name"

        if command -v dev &>/dev/null; then
            echo "Authenticating with dev environment..."
            dev
        fi

        tmux attach-session -t "$session_name"
    else
        if command -v dev &>/dev/null; then
            echo "Authenticating with dev environment..."
            dev
        fi

        echo "Creating tmux session: $session_name"
        echo "Setting up 2-pane window layout..."
        echo "Starting Claude Code in first pane..."

        tmux new-session -s "$session_name" "cc" \; split-window -h
    fi
}

function wt-remove-all() {
    wt list --format json | jq -r '.[] | select(.branch == "main" | not) | .branch' | xargs -I {} wt remove {}
}