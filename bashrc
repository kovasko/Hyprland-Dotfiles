#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

kitten icat -n --place 30x30@0x0 --scale-up --align left $HOME/.config/fastfetch/GIF/arch.gif | fastfetch --logo-width 30 --raw -
