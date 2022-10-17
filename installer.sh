#!/bin/bash
red='\033[0;31m'
green='\033[0;32m'
purple='\033[0;35m'
normal='\033[0m'

_w() {
  local -r text="${1:-}"
  echo -e "$text"
}
_a() { _w " > $1"; }
_e() { _a "${red}$1${normal}"; }
_s() { _a "${green}$1${normal}"; }
_q() { read -rp "🤔 $1: " "$2"; }

_a "Installing plugins"
# install zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# install zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# install zsh-fzf-history-search
git clone https://github.com/joshskidmore/zsh-fzf-history-search ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-fzf-history-search

#install  zsh-vi-mode
git clone https://github.com/jeffreytse/zsh-vi-mode \
  $ZSH_CUSTOM/plugins/zsh-vi-mode

#install zsh-completions
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions
