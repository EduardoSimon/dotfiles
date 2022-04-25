# Uncomment for debuf with `zprof`
# zmodload zsh/zprof
typeset -U path cdpath fpath

# ZSH Ops
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FCNTL_LOCK
setopt auto_cd
set -o vi


cdpath=($HOME/dev $HOME)
# Start zim
source "$ZIM_HOME/init.zsh"

# # Async mode for autocompletion
ZSH_AUTOSUGGEST_USE_ASYNC=true
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_HIGHLIGHT_MAXLENGTH=300

source "$DOTFILES_PATH/shell/init.sh"

source "$DOTFILES_PATH/shell/zsh/key-bindings.zsh"
source "$DOTLY_PATH/shell/zsh/bindings/reverse_search.zsh"


# export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

. "${HOME}/z_script.sh"

if command -v direnv &> /dev/null
then
    eval "$(direnv hook zsh)"
fi

# if command -v jenv &> /dev/null
# then
#     eval "$(jenv init -)"
# fi

if command -v starship &> /dev/null
then
    eval "$(starship init zsh)"
fi

# The next line updates PATH for the Google Cloud SDK.
# if [ -f '/Users/eduardosimonpicon/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/eduardosimonpicon/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
# if [ -f '/Users/eduardosimonpicon/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/eduardosimonpicon/google-cloud-sdk/completion.zsh.inc'; fi
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
# export SDKMAN_DIR="$HOME/.sdkman"
# [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# eval "$(rbenv init - zsh)"

# eval $(thefuck --alias)
# zmodload zsh/zprof
