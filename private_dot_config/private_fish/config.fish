# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ll="ls -l"
alias la="ls -la"

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
alias v='nvim'

alias uuid="generate-uuid"
alias fprev="fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'"

# Docker
alias dockillc='docker container stop (docker container ls -aq) && docker container rm (docker container ls -aq)'
alias dockilli='docker image rm (docker image ls -q)'
alias dockillv='docker volume rm (docker volume ls -q)'
alias dockillall='dockillc && dockilli && dockillv'

alias audit_trivy="docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v $HOME/.trivycache/ aquasec/trivy --vuln-type os --severity HIGH,CRITICAL"
alias dive="docker run --rm -it -e CI=true -v /var/run/docker.sock:/var/run/docker.sock wagoodman/dive:latest"
alias dive_panel="docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock wagoodman/dive:latest"

alias magelland="docker run --rm -it -e USER -e GITLAB_TOKEN -e AWS_PROFILE -v $PWD:/platform_app -v ~/.aws:/root/.aws -v /var/run/docker.sock:/var/run/docker.sock magellan_release"

# Allow relative cd
set -gx CDPATH $CDPATH . ~ $HOME/work $HOME/personal

# Set environment variables
set -Ux DOTFILES_PATH "$HOME"
set -Ux GOPATH "$HOME/.go"
set -Ux GEM_HOME "$HOME/gems"

# Default editor environment variables
set -Ux EDITOR nvim
set -Ux VISUAL nvim

# History settings (Fish uses a single history file by default)
# The following are not directly applicable in Fish but can be adjusted if needed:
# - `HISTSIZE` and `SAVEHIST` do not exist in Fish, as it manages history differently.

# Default fzf config
set -Ux FZF_DEFAULT_COMMAND 'rg --files --hidden --glob "!.git"'
set -Ux FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"

# Custom FZF colors
set -Ux FZF_COLORS "bg+:-1,fg:gray,fg+:white,border:black,spinner:0,hl:yellow,header:blue,info:green,pointer:red,marker:red,prompt:gray,hl+:red"

set -Ux FZF_DEFAULT_OPTS "--height 60% \
--border sharp \
--color='$FZF_COLORS' \
--prompt '∷ ' \
--pointer ▶ \
--marker ⇒"

set -Ux FZF_ALT_C_OPTS "--preview 'tree -C {} | head -n 10'"

# Additional FZF color options
set -Ux FZF_DEFAULT_OPTS "
  --color=pointer:#ebdbb2,bg+:#3c3836,fg:#ebdbb2,fg+:#fbf1c7,hl:#8ec07c,info:#928374,header:#fb4934
  --reverse
"

source ~/.config/fish/functions/custom_functions.fish
source ~/private_aliases.fish

fish_add_path "$HOME/gems/bin"
fish_add_path "$JAVA_HOME/bin"
fish_add_path "$GOPATH/bin"
fish_add_path "$HOME/.cargo/bin"
fish_add_path "$HOME/.jenv/bin"
fish_add_path /usr/local/opt/python/libexec/bin
fish_add_path /usr/local/bin
fish_add_path /usr/local/sbin
fish_add_path /mnt/c/Windows/system32
fish_add_path "$HOME/.local/bin"
fish_add_path "$HOME/.npm-global/bin"
fish_add_path "$HOME/.deno/bin"
fish_add_path /opt/homebrew/bin
fish_add_path "$ASDF_DIR/bin"

starship init fish | source
mise activate fish | source
direnv hook fish | source

fish_vi_key_bindings
