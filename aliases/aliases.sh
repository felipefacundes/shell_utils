[[ -n $BASH_VERSION ]] && alias aliases='eval $(compgen -a | fzf)'
[[ -n $ZSH_VERSION ]] && alias aliases='eval $(print -l ${(k)aliases} | fzf)'