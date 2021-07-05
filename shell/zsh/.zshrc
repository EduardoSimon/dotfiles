# Uncomment for debuf with `zprof`
# zmodload zsh/zprof
typeset -U path cdpath fpath

# ZSH Ops
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FCNTL_LOCK
setopt auto_cd	
# setopt autopushd


cdpath=($HOME/dev $HOME)
# Start zim
source "$ZIM_HOME/init.zsh"

# Async mode for autocompletion
ZSH_AUTOSUGGEST_USE_ASYNC=true
ZSH_HIGHLIGHT_MAXLENGTH=300

source "$DOTFILES_PATH/shell/init.sh"

fpath=("$DOTLY_PATH/shell/zsh/completions" $fpath)

autoload -Uz promptinit && promptinit

source "$DOTFILES_PATH/shell/zsh/key-bindings.zsh"
source "$DOTLY_PATH/shell/zsh/bindings/reverse_search.zsh"

export PATH="$PATH:/Users/eduardosimonpicon/.simple/bin"

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

. "${HOME}/z.sh"

if command -v direnv &> /dev/null
then
    eval "$(direnv hook zsh)"
fi

if command -v jenv &> /dev/null
then
    eval "$(jenv init -)"
fi

if command -v starship &> /dev/null
then
    eval "$(starship init zsh)"
fi


