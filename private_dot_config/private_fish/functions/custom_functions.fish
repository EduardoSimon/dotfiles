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

function merge-to-monoenv
    if test (count $argv) -ne 1
        echo "usage: merge-to-monoenv <environment>"
        return 1
    end

    set ENVIRONMENT $argv[1]
    set BRANCH (git rev-parse --abbrev-ref HEAD)

    git checkout $ENVIRONMENT
    and git reset --hard origin/$ENVIRONMENT
    and git merge $BRANCH --no-edit
    and git commit --allow-empty -m "[SKIP_MANUAL]"
    and git push origin $ENVIRONMENT
    and git checkout $BRANCH
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

