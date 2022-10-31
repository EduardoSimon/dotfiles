# Enables profiling in zsh
[[ -n $PROFILE_ZSH ]] && zmodload zsh/zprof

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# move to the folder if it exists using the name of the folder as a command
setopt auto_cd

setopt AUTO_PUSHD           # Push the current directory visited on the stack.
setopt PUSHD_IGNORE_DUPS    # Do not store duplicates in the stack.
setopt PUSHD_SILENT         # Do not print the directory stack after pushd or popd.

# allow to use absolute path from anywhere on the system to the following locations
cdpath=($HOME/dev $HOME)

# enable vi mode
set -o vi

# Enabled completions
# The autoload command load a file containing shell commands. To find this file, Zsh will look in the directories of the Zsh file search path, defined in the variable $fpath, and search a file called compinit.
# When compinit is found, its content will be loaded as a function. The function name will be the name of the file. You can then call this function like any other shell function.
# The -U prevents from expanding aliases
autoload -U compinit; compinit
_comp_options+=(globdots) # With hidden files
source $DOTFILES_PATH/shell/zsh/completions/base.zsh

# Enable plugins
plugins=(git zsh-vi-mode zsh-syntax-highlighting zsh-autosuggestions zsh-fzf-history-search)

ZSH_DISABLE_COMPFIX=true
source $ZSH/oh-my-zsh.sh

# Import aliases, functions and custom exports
source $DOTFILES_PATH/shell/init.sh

# TODO move to asdf
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"

# load z/rupa script
. "${DOTFILES_PATH}/shell/zsh/plugins/z_script.sh"

if command -v direnv &> /dev/null
then
    eval "$(direnv hook zsh)"
fi

if command -v starship &> /dev/null
then
    eval "$(starship init zsh)"
fi

# Default escape key <ESC> for insert mode
ZVM_VI_INSERT_ESCAPE_BINDKEY='^['

# The plugin will auto execute this zvm_after_init function
function zvm_after_init() {
  zvm_bindkey viins 'jk' zvm_exit_insert_mode
  zvm_bindkey viins 'kj' zvm_exit_insert_mode
  echo "Installed"
}

[[ -n $PROFILE_ZSH ]] && zprof

