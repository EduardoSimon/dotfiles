export DOTFILES_PATH=$HOME/.dotfiles

source "$DOTFILES_PATH/shell/init.sh"
eval $($(brew --prefix)/bin/brew shellenv)
PATH=$(
  IFS=":"
  echo "${path[*]}"
)
export PATH

source "$DOTFILES_PATH/shell/bash/themes/codely.sh"
