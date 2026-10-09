# ~/.bashrc for the XaiBoot live user.

case "$-" in
  *i*) ;;
  *) return ;;
esac

HISTCONTROL=ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s checkwinsize

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
alias ls='ls --color=auto'

PS1='\u@\h:\w\$ '
