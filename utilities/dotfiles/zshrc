#!/bin/zsh
#################################
###### Xterm Transparency #######
[[ "$XTERM_VERSION" ]] && command -v transset-df >/dev/null 2>&1 && transset-df -x 0.7 -m 0.7 --id "$WINDOWID" >/dev/null
#################################
######### SHELL UTILS ###########
[[ -f ~/.shell_utils/shell_utils.sh ]] && . ~/.shell_utils/shell_utils.sh
#################################
############# GRML ############## 
# Is Optional
#. ~/.shell_utils/grml/grml.sh
#. ~/.shell_utils/grml/keephack.sh
#################################
# https://zsh.sourceforge.io/Intro/intro_16.html
autoload -Uz compinit
compinit
zstyle ':completion:*' file-sort modification reverse
_comp_options+=(globdots)
setopt globdots
## with globsubst enabled, the shell will attempt to perform wildcard expansion (globs) and replace values in strings, 
## including the escape sequence, which can lead to unwanted results.
##setopt globsubst # Conflicts with this framework
setopt correct # effect grml: correct the command
#setopt correctall
setopt histignoredups
setopt histignorespace

PROMPT_ESC=true
setopt extendedglob
setopt prompt_subst

#setopt XTRACE # Debug
setopt AUTO_CD # No cd needed to change directories
setopt BANG_HIST # Treat the ‘!’ character specially during expansion.
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST # Expire duplicate entries first when trimming history.
setopt HIST_FIND_NO_DUPS #

# autoload -Uz add-zsh-hook
# add-zsh-hook precmd delete-failed-history
# If you want that it deletes only commands that have exit status exactly, then change to .1(( ? ))(( ? == 1 ))

setopt HIST_IGNORE_ALL_DUPS # Delete old recorded entry if new entry is a duplicate.
setopt HIST_IGNORE_DUPS # Don’t record an entry that was just recorded again.
setopt HIST_IGNORE_SPACE # Don’t record an entry starting with a space.
setopt HIST_REDUCE_BLANKS # Remove superfluous blanks before recording entry.
setopt HIST_SAVE_NO_DUPS # Don’t write duplicate entries in the history file.
setopt INC_APPEND_HISTORY # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY # Share history between all sessions.

#NOCLOBBER prevents you from accidentally overwriting an existing file.
setopt noclobber

# Oh My ZSH Config
ZSH_THEME="dstufft" # set by `omz`
OM_ZSHC=~/.shell_utils/frameworks/oh-my-zsh-config.sh && [[ -f "$OM_ZSHC" ]] && . "$OM_ZSHC"

############################################################################

fzf_zsh() {
    file=~/.fzf.zsh
    if ! test -f "$file" && command -v fzf &>/dev/null; then
        fzf --zsh | tee "$file" &>/dev/null
    fi
    test -f "$file" && source "$file"
    return 0
}

fzf_zsh

# >>> mamba initialize >>>
# !! Contents within this block are managed by 'mamba init' !!
# mamba_setup # Uncomment this line

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
# conda_setup # Uncomment this line

if [ -d ~/.local/share/zsh/site-functions/ ]; then
    for completion in ~/.local/share/zsh/site-functions/*.zsh; do
        [ -f "$completion" ] && source "$completion"
    done
fi

