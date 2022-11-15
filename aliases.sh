# Enable aliases to be sudo’ed
alias sudo='sudo '

alias ..="cd .."
alias ...="cd ../.."
alias ll="ls -l"
alias la="ls -la"
alias ~="cd ~"

# Git
alias gaa="git add -A"
alias gc="git-commit"
alias gca="git add --all && git commit --amend --no-edit"
alias gco="git checkout"
alias gd="pretty-diff"
alias gs="git status -sb"
alias gf="git fetch --all -p"
alias gps="git push"
alias gpsf="git push --force"
alias gpl="git fetch --all -p && git pull --rebase --autostash"
alias gb="git branch"
alias gr="git branch -r"
alias gl="pretty-log"
alias grh="git reset --hard"

# Utils
alias k='kill -9'
alias c.='(code $PWD &>/dev/null &)'
alias o.='open .'
alias v='nvim .'

alias uuid="generate-uuid"
alias fprev="fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'"

#docker
alias dockillc='docker container stop $(docker container ls -aq) && docker container rm $(docker container ls -aq)'
alias dockilli='docker image rm $(docker image ls -q)'
alias dockillv='docker volume rm $(docker volume ls -q)'
alias dockillall='dockillc && dockilli && dockillv'

alias oktaexec_sta="${OKTAEXEC}"
alias oktaexec_pro="${OKTAEXEC_PROD}"

alias audit_trivy="docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v $HOME/.trivycache/ aquasec/trivy --vuln-type     os --severity HIGH,CRITICAL"
alias dive="docker run --rm -it -e CI=true -v /var/run/docker.sock:/var/run/docker.sock wagoodman/dive:latest "
alias dive_panel="docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock wagoodman/dive:latest "

# aliases for recent direct dir stack access in zsh
alias d='dirs -v'
for index ({1..9}) alias "$index"="cd +${index}"; unset index
alias magelland="docker run --rm -it -e USER -e GITLAB_TOKEN -e AWS_PROFILE -v ${PWD}:/platform_app -v ~/.aws:/root/.aws -v /var/run/docker.sock:/var/run/docker.sock magellan_release"
