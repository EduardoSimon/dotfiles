function cdd() {
  cd "$(ls -d -- */ | fzf)" || echo "Invalid directory"
}

function j() {
  fname=$(declare -f -F _z)

  [ -n "$fname" ] || source "$DOTLY_PATH/modules/z/z.sh"

  _z "$1"
}

function recent_dirs() {
  # This script depends on pushd. It works better with autopush enabled in ZSH
  escaped_home=$(echo $HOME | sed 's/\//\\\//g')
  selected=$(dirs -p | sort -u | fzf)

  cd "$(echo "$selected" | sed "s/\~/$escaped_home/")" || echo "Invalid directory"
}

reverse-search() {
  local selected num
  setopt localoptions noglobsubst noposixbuiltins pipefail HIST_FIND_NO_DUPS 2> /dev/null

  selected=( $(fc -rl 1 |
    FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} $FZF_DEFAULT_OPTS -n2..,.. --tiebreak=index --bind=ctrl-r:toggle-sort $FZF_CTRL_R_OPTS --query=${(qqq)LBUFFER} +m" fzf) )
  local ret=$?
  if [ -n "$selected" ]; then
    num=$selected[1]
    if [ -n "$num" ]; then
      zle vi-fetch-history -n $num
    fi
  fi
  zle redisplay
  typeset -f zle-line-init >/dev/null && zle zle-line-init
  return $ret
}

function abs_path() {
    echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
}

function jira() {
  open -a "Google Chrome" "${JIRA_PROJECT_URL}/${1}"
}

function push-monoenv() { 
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

function force-push-monoenv() {
if [ $# -ne 1 ]; then
    echo "usage: merge-to-monoenv <environment>"
    return -1
fi
ENVIRONMENT=$1
BRANCH=$(git rev-parse --abbrev-ref HEAD)
git checkout $ENVIRONMENT && git pull --rebase && git merge $BRANCH && git commit --allow-empty -m "[SKIP_MANUAL]" &&
 git push origin $ENVIRONMENT
git checkout $BRANCH
}

function load_nvm() {
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
}
