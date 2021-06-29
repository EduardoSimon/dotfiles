# Enable aliases to be sudo’ed
alias sudo='sudo '

alias ..="cd .."
alias ...="cd ../.."
alias ll="ls -l"
alias la="ls -la"
alias ~="cd ~"

# Git
alias gaa="git add -A"
alias gc="$DOTLY_PATH/bin/dot git commit-no-sign"
alias gca="git add --all && git commit --amend --no-edit"
alias gco="git checkout"
alias gd="$DOTLY_PATH/bin/dot git pretty-diff"
alias gs="git status -sb"
alias gf="git fetch --all -p"
alias gps="git push"
alias gpsf="git push --force"
alias gpl="git pull --rebase --autostash"
alias gb="git branch"
alias gl="$DOTLY_PATH/bin/dot git pretty-log"
alias gacp="$DOTLY_PATH/bin/dot git commit-push"
alias nb="$DOTLY_PATH/bin/dot git new-branch-with-remote"

# Utils
alias k='kill -9'
alias i.='(idea $PWD &>/dev/null &)'
alias c.='(code $PWD &>/dev/null &)'
alias o.='open .'
alias php.='phpstorm .'
alias ws.='webstorm .'

alias cdgia="cd ~HOME/Documents/GreenAndIn/business-app"
alias cdgib="cd ~HOME/Documents/GreenAndIn/functions"
alias uuid="dot utils uuid_code"
alias fprev="fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'"

#docker
alias dockillc='docker container stop $(docker container ls -aq) && docker container rm $(docker container ls -aq)'
alias dockilli='docker image rm $(docker image ls -q)'
alias dockillv='docker volume rm $(docker volume ls -q)'
alias dockillall='dockillc && dockilli && dockillv'
