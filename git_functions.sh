# Git workflow functions (bash equivalents of fish plugin-git functions)

function gwip() {
    git add -A
    git rm $(git ls-files --deleted) 2>/dev/null
    git commit -m "--wip--" --no-verify
}

function gunwip() {
    git log -n 1 | grep -q -c "\-\-wip\-\-" && git reset HEAD~1
}

function gbda() {
    # Delete all branches merged in current HEAD, including squash-merged
    git branch --merged | \
        command grep -vE '^\*|^\+|^\s*(master|main|develop)\s*$' | \
        command xargs -r -n 1 git branch -d

    local default_branch
    default_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
    default_branch="${default_branch:-main}"

    git for-each-ref refs/heads/ "--format=%(refname:short)" | while read -r branch; do
        local merge_base
        merge_base=$(git merge-base "$default_branch" "$branch")
        if [[ $(git cherry "$default_branch" "$(git commit-tree "$(git rev-parse "${branch}^{tree}")" -p "$merge_base" -m _)") == -* ]]; then
            git branch -D "$branch"
        fi
    done
}

function grename() {
    if [ $# -ne 2 ]; then
        echo "Usage: grename old_branch new_branch"
        return 1
    fi
    git branch -m "$1" "$2"
    git push origin :"$1" && git push --set-upstream origin "$2"
}

function gbage() {
    git for-each-ref --sort=committerdate refs/heads/ \
        --format="%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(color:red)%(objectname:short)%(color:reset) - %(contents:subject) - %(authorname) (%(color:green)%(committerdate:relative)%(color:reset))"
}

function gdv() {
    git diff -w "$@" | view -
}

function gignored() {
    git ls-files -v | grep "^[[:lower:]]"
}

function git-fixup() {
    git log -n 50 --pretty=format:'%h %s' --no-merges | fzf | cut -c -7 | xargs -o git commit --fixup
}

function glp() {
    if [ -n "$1" ]; then
        git log --pretty="$1"
    fi
}

function grt() {
    cd "$(git rev-parse --show-toplevel || echo ".")" || return
}

function gtest() {
    # Test a command against git staged changes only
    git stash push -q --keep-index --include-untracked || return

    # Run test command against index changes only
    "$@"
    local cmdstatus=$?

    # Return working dir and index to original state
    git reset -q
    git restore .
    git stash pop -q --index || return $?

    return $cmdstatus
}

function gtl() {
    git tag --sort=-v:refname -n -l "${1}*"
}
