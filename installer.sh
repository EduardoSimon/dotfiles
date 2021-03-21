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

_w "  ┌──────────────────────────────────────────┐"
_w "~ │ 🚀 Welcome to Eduardo Simon's ${green}dotfiles${normal} installer! │ ~"
_w "  └──────────────────────────────────────────┘"
_w
_q "Confirm to install dotfiles @(default ~/.dotfiles)" INSTALL_PATH
INSTALL_PATH=${INSTALL_PATH:-~/.dotfiles}
[ ! -d $INSTALL_PATH ] && git clone git@github.com:EduardoSimon/dotfiles.git $INSTALL_PATH
cd $INSTALL_PATH

_a "Initializing submodules"
git submodule update --init --recursive

_a "Initializing dotly"
DOTFILES_PATH="$INSTALL_PATH" DOTLY_PATH="$INSTALL_PATH/modules/dotly" "$INSTALL_PATH/modules/dotly/bin/dot" self install
_a "Initializing dotly"
DOTFILES_PATH="$INSTALL_PATH" DOTLY_PATH="$INSTALL_PATH/modules/dotly" "$INSTALL_PATH/modules/dotly/bin/dot" symlinks apply

_a "Initializing zim"
zsh $INSTALL_PATH/modules/dotly/modules/zimfw/zimfw.zsh install

_a "Installing packages..."
DOTFILES_PATH="$INSTALL_PATH" DOTLY_PATH="$INSTALL_PATH/modules/dotly" sudo "$INSTALL_PATH/modules/dotly/bin/dot" package import


_w "🎉 dotfiles installed correctly! 🎉"
_w "Please, restart your terminal to see the changes"
