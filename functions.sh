platform::is_linux() {
	[[ $(uname -s) == "Linux" ]]
}

platform::is_wsl() {
	grep -qEi "(Microsoft|WSL|microsoft)" /proc/version &>/dev/null
}

platform::is_macos() {
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

function pretty-diff() {
  "$DOTFILES_PATH/scripts/git/pretty-diff"
}

function pretty-log() {
  "$DOTFILES_PATH/scripts/git/pretty-log"
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
