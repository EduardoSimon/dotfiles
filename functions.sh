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
  echo "usage: merge-to-monoenv <environment>"
  return -1
fi
ENVIRONMENT=$1
BRANCH=$(git rev-parse --abbrev-ref HEAD)
git checkout $ENVIRONMENT && git reset --hard origin/$ENVIRONMENT  && git merge $BRANCH && git commit --allow-empty -m "[SKIP_MANUAL]" && git push origin $ENVIRONMENT
git checkout $BRANCH
}

function compare-branches() {
  "$DOTFILES_PATH/scripts/git/compare-branches" "$@"
}

function git-commit() {
  "$DOTFILES_PATH/scripts/git/commit-no-sign" "$@"
}