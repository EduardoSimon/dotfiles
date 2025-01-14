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
    and git merge $BRANCH
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

