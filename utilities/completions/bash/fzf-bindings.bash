### key-bindings.bash modified by Felipe Facundes ###
#     ____      ____
#    / __/___  / __/
#   / /_/_  / / /_
#  / __/ / /_/ __/
# /_/   /___/_/ key-bindings.bash
#
# - $FZF_TMUX_OPTS
# - $FZF_CTRL_T_COMMAND
# - $FZF_CTRL_T_OPTS
# - $FZF_CTRL_R_OPTS
# - $FZF_ALT_C_COMMAND
# - $FZF_ALT_C_OPTS

############################################################################
if ! command -v fzf &>/dev/null; then
    return
fi

if [[ $- =~ i ]]; then


# Key bindings
# ------------

__fzf_defaults() {
  # $1: Prepend to FZF_DEFAULT_OPTS_FILE and FZF_DEFAULT_OPTS
  # $2: Append to FZF_DEFAULT_OPTS_FILE and FZF_DEFAULT_OPTS
  echo "--height ${FZF_TMUX_HEIGHT:-40%} --bind=ctrl-z:ignore $1"
  command cat "${FZF_DEFAULT_OPTS_FILE-}" 2> /dev/null
  echo "${FZF_DEFAULT_OPTS-} $2"
}

__fzf_select__() {
  FZF_DEFAULT_COMMAND=${FZF_CTRL_T_COMMAND:-} \
  FZF_DEFAULT_OPTS=$(__fzf_defaults "--reverse --walker=file,dir,follow,hidden --scheme=path" "${FZF_CTRL_T_OPTS-} -m") \
  FZF_DEFAULT_OPTS_FILE='' $(__fzfcmd) "$@" |
    while read -r item; do
      printf '%q ' "$item"  # escape special chars
    done
}

__fzfcmd() {
  [[ -n "${TMUX_PANE-}" ]] && { [[ "${FZF_TMUX:-0}" != 0 ]] || [[ -n "${FZF_TMUX_OPTS-}" ]]; } &&
    echo "fzf-tmux ${FZF_TMUX_OPTS:--d${FZF_TMUX_HEIGHT:-40%}} -- " || echo "fzf"
}

fzf-file-widget() {
  local selected="$(__fzf_select__ "$@")"
  READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}$selected${READLINE_LINE:$READLINE_POINT}"
  READLINE_POINT=$(( READLINE_POINT + ${#selected} ))
}

# ALT-C: List built-ins, PATH commands, and aliases
__fzf_alt_c_commands__() {
  local paths commands
  
  # Get built-in commands
  {
    # List bash builtins
    compgen -b 2>/dev/null
  } | command sort -u
  
  # Get PATH commands using the fast find method
  IFS=':' read -ra paths <<< "$PATH"
  mapfile -t commands < <(
      find -L "${paths[@]}" -maxdepth 1 -type f -perm -u+x 2>/dev/null \
      -printf '%f\n' | sort -u
  )
  printf '%s\n' "${commands[@]}"
  
  # Get aliases
  alias 2>/dev/null | command sed -E 's/^alias ([^=]+)=.*/\1/' | command sort -u
}

# ALT-C handler: show and select from built-ins, PATH commands, and aliases
__fzf_alt_c_handler__() {
  local selected
  selected=$(
    __fzf_alt_c_commands__ | command sort -u |
    FZF_DEFAULT_OPTS=$(__fzf_defaults "--reverse --prompt='Command> ' --no-sort" "${FZF_ALT_C_OPTS-} +m") \
    FZF_DEFAULT_OPTS_FILE='' $(__fzfcmd)
  ) || return
  
  READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}$selected${READLINE_LINE:$READLINE_POINT}"
  READLINE_POINT=$(( READLINE_POINT + ${#selected} ))
}

if command -v perl > /dev/null; then
  __fzf_history__() {
    local output script history_number
    script='BEGIN { getc; $/ = "\n\t"; $HISTCOUNT = $ENV{last_hist} + 1 } s/^[ *]//; s/\n/\n\t/gm; print $HISTCOUNT - $. . "\t$_" if !$seen{$_}++'
    output=$(
      set +o pipefail
      builtin fc -lnr -2147483648 |
        last_hist=$(HISTTIMEFORMAT='' builtin history 1) command perl -n -l0 -e "$script" |
        FZF_DEFAULT_OPTS=$(__fzf_defaults "" "-n2..,.. --scheme=history --bind=ctrl-r:toggle-sort --wrap-sign '"$'\t'"↳ ' --highlight-line ${FZF_CTRL_R_OPTS-} +m --read0") \
        FZF_DEFAULT_OPTS_FILE='' $(__fzfcmd) --query "$READLINE_LINE"
    ) || return
    READLINE_LINE=$(command perl -pe 's/^\d*\t//' <<< "$output")
    if [[ -z "$READLINE_POINT" ]]; then
      echo "$READLINE_LINE"
    else
      READLINE_POINT=0x7fffffff
    fi
  }
else # awk - fallback for POSIX systems
  __fzf_history__() {
    local output script n x y z d
    if [[ -z $__fzf_awk ]]; then
      __fzf_awk=awk
      # choose the faster mawk if: it's installed && build date >= 20230322 && version >= 1.3.4
      IFS=' .' read n x y z d <<< $(command mawk -W version 2> /dev/null)
      [[ $n == mawk ]] && (( d >= 20230302 && (x *1000 +y) *1000 +z >= 1003004 )) && __fzf_awk=mawk
    fi
    [[ $(HISTTIMEFORMAT='' builtin history 1) =~ [[:digit:]]+ ]]    # how many history entries
    script='function P(b) { ++n; sub(/^[ *]/, "", b); if (!seen[b]++) { printf "%d\t%s%c", '$((BASH_REMATCH + 1))' - n, b, 0 } }
    NR==1 { b = substr($0, 2); next }
    /^\t/ { P(b); b = substr($0, 2); next }
    { b = b RS $0 }
    END { if (NR) P(b) }'
    output=$(
      set +o pipefail
      builtin fc -lnr -2147483648 2> /dev/null |   # ( $'\t '<lines>$'\n' )* ; <lines> ::= [^\n]* ( $'\n'<lines> )*
        command $__fzf_awk "$script"           |   # ( <counter>$'\t'<lines>$'\000' )*
        FZF_DEFAULT_OPTS=$(__fzf_defaults "" "-n2..,.. --scheme=history --bind=ctrl-r:toggle-sort --wrap-sign '"$'\t'"↳ ' --highlight-line ${FZF_CTRL_R_OPTS-} +m --read0") \
        FZF_DEFAULT_OPTS_FILE='' $(__fzfcmd) --query "$READLINE_LINE"
    ) || return
    READLINE_LINE=${output#*$'\t'}
    if [[ -z "$READLINE_POINT" ]]; then
      echo "$READLINE_LINE"
    else
      READLINE_POINT=0x7fffffff
    fi
  }
fi

# CTRL-R with delete capability (CTRL-DELETE to delete history entry)
__fzf_history_with_delete__() {
  local output cmd num

  output=$(
    history | tac | \
    FZF_DEFAULT_OPTS=$(__fzf_defaults "" "--scheme=history --bind=ctrl-r:toggle-sort --bind='ctrl-delete:become(echo __FZF_DELETE__ {})' ${FZF_CTRL_R_OPTS-} +m") \
    FZF_DEFAULT_OPTS_FILE='' \
    $(__fzfcmd) --query "$READLINE_LINE" --delimiter=' ' --with-nth=2..
  ) || return

  # Check if delete was requested
  if [[ "$output" == __FZF_DELETE__\ * ]]; then
    cmd="${output#__FZF_DELETE__ }"
    # Extract the command content (remove number prefix)
    cmd=$(echo "$cmd" | sed -E 's/^[[:space:]]*[0-9]+[[:space:]]+//')
    
    # Delete from history by content
    while history | grep -Fq "$cmd"; do
      num=$(history | grep -F "$cmd" | head -1 | awk '{print $1}')
      history -d "$num" 2>/dev/null
    done
    return
  fi

  # Normal selection: strip history number
  READLINE_LINE=$(echo "$output" | sed -E 's/^[[:space:]]*[0-9]+[[:space:]]+//')

  if [[ -z "$READLINE_POINT" ]]; then
    echo "$READLINE_LINE"
  else
    READLINE_POINT=0x7fffffff
  fi
}

# Required to refresh the prompt after fzf
bind -m emacs-standard '"\er": redraw-current-line'

bind -m vi-command '"\C-z": emacs-editing-mode'
bind -m vi-insert '"\C-z": emacs-editing-mode'
bind -m emacs-standard '"\C-z": vi-editing-mode'

if (( BASH_VERSINFO[0] < 4 )); then
  # CTRL-T - Paste the selected file path into the command line
  if [[ "${FZF_CTRL_T_COMMAND-x}" != "" ]]; then
    bind -m emacs-standard '"\C-t": " \C-b\C-k \C-u`__fzf_select__`\e\C-e\er\C-a\C-y\C-h\C-e\e \C-y\ey\C-x\C-x\C-f"'
    bind -m vi-command '"\C-t": "\C-z\C-t\C-z"'
    bind -m vi-insert '"\C-t": "\C-z\C-t\C-z"'
  fi

  # CTRL-R - Paste the selected command from history into the command line
  bind -m emacs-standard '"\C-r": "\C-e \C-u\C-y\ey\C-u`__fzf_history__`\e\C-e\er"'
  bind -m vi-command '"\C-r": "\C-z\C-r\C-z"'
  bind -m vi-insert '"\C-r": "\C-z\C-r\C-z"'
else
  # CTRL-T - Paste the selected file path into the command line
  if [[ "${FZF_CTRL_T_COMMAND-x}" != "" ]]; then
    bind -m emacs-standard -x '"\C-t": fzf-file-widget'
    bind -m vi-command -x '"\C-t": fzf-file-widget'
    bind -m vi-insert -x '"\C-t": fzf-file-widget'
  fi

  # CTRL-R - Paste the selected command from history into the command line
  # CTRL-DELETE in the fzf window to delete a history entry
  bind -m emacs-standard -x '"\C-r": __fzf_history_with_delete__'
  bind -m vi-command -x '"\C-r": __fzf_history_with_delete__'
  bind -m vi-insert -x '"\C-r": __fzf_history_with_delete__'
fi

# ALT-C - Show built-ins, PATH commands, and aliases
bind -m emacs-standard -x '"\ec": __fzf_alt_c_handler__'
bind -m vi-command -x '"\ec": __fzf_alt_c_handler__'
bind -m vi-insert -x '"\ec": __fzf_alt_c_handler__'

fi
### end: key-bindings.bash ###