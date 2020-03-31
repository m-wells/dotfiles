# If not running interactively, don't do anything
[[ $- != *i* ]] && return

set -o vi

[[ $TERM == x*term ]] && return

# remove CTRL-S keybinding and disable Software Flow Control
# disable Software Flow Control (XON/XOFF) in interactive shells
[[ $- == *i* ]] && stty -ixon


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

    # POWERLINE
    if [ -x "$(command -v powerline-daemon)" ]; then
        powerline-daemon -q
        POWERLINE_BASH_CONTINUATION=1
        POWERLINE_BASH_SELECT=1
        if [ -f /usr/lib/python3.8/site-packages/powerline/bindings/bash/powerline.sh ]; then
            source /usr/lib/python3.8/site-packages/powerline/bindings/bash/powerline.sh
        fi
    else
        PS1='$(pwd)\n\u@\h:> \[$(tput sgr0)\]'
    fi

    # NEOFETCH
    if [ -x "$(command -v neofetch)" ]; then
        neofetch --color_blocks on
    fi
fi

export MANPAGER="/bin/sh -c \"col -b | vim -c 'set ft=man ts=8 nomod nolist nonu noma' -\""

export EDITOR=vim

export BROWSER=vivaldi-stable

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
