confirm() {
    # call with a prompt string or use a default
    read -r -p "${1:-Continue? [y/N]} " response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            true
            ;;
        *)
            false
            ;;
    esac
}

# make rm less dangerous
alias rm='rm -I --preserve-root=all'
alias tp='trash-put'

# colorize output
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

alias julian='julia --startup-file=no'

alias vim='vim --servername VIM'
alias config="/usr/bin/git --git-dir=/home/mark/.cfg/ --work-tree=$HOME"

alias lc='colorls'
