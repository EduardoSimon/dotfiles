#!/usr/bin/env bash
# Credits to rgomezcasas for this installer

set -euo pipefail

##? Setups the environment
#?? 1.0.0
##?
##? Usage:
##?    install

echo "🚀 Welcome to the EduardoSimon's dotfiles installer! 🤙"
echo "-------------------------------------------------"
echo
read -rp "🤔  Where do you want to clone the dotfiles? (default ~/.dotfiles): " DOTFILES_PATH
echo
#DOTFILES_PATH="${DOTFILES_PATH:-~/.dotfiles}"
export DOTFILES_PATH="$HOME/.dotfiles"
echo "👉  Cloning into: '$DOTFILES_PATH'"

git clone --recurse-submodules https://github.com/EduardoSimon/dotfiles.git "$DOTFILES_PATH"

"$DOTFILES_PATH/modules/dotly/bin/dot" self install
