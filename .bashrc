# If not running interactively, don't do anything
[[ $- != *i* ]] && return

set -o vi

[[ $TERM == x*term ]] && return

# remove CTRL-S keybinding and disable Software Flow Control
# disable Software Flow Control (XON/XOFF) in interactive shells
[[ $- == *i* ]] && stty -ixon

# a command name that is the name of a directory is executed as if it were the argument to the cd
# command, this option is only used by interactive shells
shopt -s autocd

# minor errors in the spelling of a directory component in a cd command will be corrected, this
# option is only used by interactive shells
shopt -s cdspell
# bash attemps spelling correction on directory names during word completion if the directory name
# initially supplied does not exist
shopt -s dirspell

# append to the history file, don't overwrite it
shopt -s histappend

# see man bash
HISTCONTROL=ignoreboth:erasedups
HISTSIZE=1000

# only do pretty stuff if we are actually at a terminal
if [ -t 1 ]; then
    if [ -x "$(command -v dircolors)" ]; then
        eval "$(dircolors ${HOME}/.config/dircolors/solarized.ansi-dark)"
    fi

    # NEOFETCH
    if [ -x "$(command -v neofetch)" ]; then
        if [ "${TERM}" == "linux" ]; then
            # turning bold off fixes tty issues
            neofetch  --bold off --ascii_bold off --color_blocks on # | sed '/^[[:space:]]*$/d' # to remove blank lines
        else
            neofetch -color_blocks on # | sed '/^[[:space:]]*$/d'
        fi
    fi

    # POWERLINE
    if [ -x "$(command -v powerline-daemon)" ] && [ "${TERM}" != "linux" ]; then # to remove blank lines
        powerline-daemon -q
        POWERLINE_BASH_CONTINUATION=1
        POWERLINE_BASH_SELECT=1
        if [ -f /usr/lib/python3.9/site-packages/powerline/bindings/bash/powerline.sh ]; then
            source /usr/lib/python3.9/site-packages/powerline/bindings/bash/powerline.sh
        fi
    else
        txtgrn='\[\e[0;32m\]'
        txtcyn='\[\e[0;36m\]'
        txtrst='\[\e[0m\]'
        PS1="${txtcyn}$(pwd)\n${txtgrn}\u${txtrst}@\h:> \[$(tput sgr0)\]"
    fi

    if [ -f ~/.config/tty-solarized-dark.sh ] && [ "${TERM}" != "linux" ]; then
        source ~/.config/tty-solarized-dark.sh
    fi
fi

if [ -f ~/.bash_aliases ]; then
    source ~/.bash_aliases
fi

if [ -f /usr/share/doc/pkgfile/command-not-found.bash ]; then
    source /usr/share/doc/pkgfile/command-not-found.bash
fi

# a place to put things that I don't want to share
if [ -f ~/.personal ] && [ "$(stat -c %a ~/.personal)" == "600" ] ; then
    source ~/.personal
fi

if which ruby >/dev/null && which gem >/dev/null; then
    PATH="$(ruby -r rubygems -e 'puts Gem.user_dir')/bin:$PATH"
fi

export JULIA_NUM_THREADS=$(nproc)
