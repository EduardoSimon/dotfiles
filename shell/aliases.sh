# Enable aliases to be sudo’ed
alias sudo='sudo '

alias ..="cd .."
alias ...="cd ../.."
alias ll="ls -l"
alias la="ls -la"
alias ~="cd ~"

# Git
alias gaa="git add -A"
alias gc="$DOTLY_PATH/bin/dot git commit"
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

#EC
alias styles="echo \"Ejecutando less_compile\" && curl -s \"http://eventscase.loc/tools/less_compile\""
alias regendb="echo \"Ejecutando regenerate_db\" && curl -s \"http://eventscase.loc/tools/regenerate_db\""
alias chdb="$DOTLY_PATH/bin/dot ec change-db"
alias showdbs="$DOTLY_PATH/bin/dot mysql show_dbs 192.168.33.66 root"
alias ec-tests="vagrant ssh -c '/usr/bin/php /media/websites/platform/vendor/phpunit/phpunit/phpunit --configuration /media/websites/platform/phpunit.xml;'"

#Vagrant
alias vr="vagrant reload"
alias vre="vagrant suspend && vagrant resume"
alias cdgia="cd ~HOME/Documents/GreenAndIn/business-app"
alias cdgib="cd ~HOME/Documents/GreenAndIn/functions"

#utils
alias uuid="dot utils uuid_code"