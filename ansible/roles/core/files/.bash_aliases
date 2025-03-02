#!/usr/bin/env bash

source /usr/share/bash-completion/bash_completion

# HOSTNAME="$(hostname --alias)"
# readonly HOSTNAME
# PS1='\e[1;32m[\u@$HOSTNAME \W]\$ \e[0m'

function up() {
    for nb in $(seq "$1"); do
        cd ../
    done
}

alias sudo='sudo -E'
alias aa-log='sudo aa-log'
alias aa-status='sudo aa-status'
alias c='clear'
alias l='ll -h'
alias ll='ls -alFh'
alias p="ps auxZ | grep -v '\[.*\]'"
alias pf="ps auxfZ | grep -v '\[.*\]'"
alias pu="ps auxZ | grep -v '\[.*\]' | grep unconfined"
alias u='up 1'
alias uu='up 2'
alias uuu='up 3'
alias uuuu='up 4'
alias uuuuu='up 5'
