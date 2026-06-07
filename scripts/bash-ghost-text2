#!/usr/bin/env bash
# Ghost completions — dynamic suggestions as you type

_ghost_history_data=""
_ghost_suggestion=""
_ghost_prompt_len=0

_ghost_init_history() {
    _ghost_history_data=$(
        fc -ln -2000 2>/dev/null | sed 's/^[[:space:]]*//' | tac | awk '!seen[$0]++'
    )
}

_ghost_update_prompt_len() {
    local plain
    # Expand PS1 and strip ANSI escapes and Readline non-printing markers
    plain=$(printf '%s' "${PS1@P}" \
        | sed -E $'s/\x1b\\[[0-9;?]*[a-zA-Z]//g; s/\x01|\x02//g')
    local last="${plain##*$'\n'}"
    _ghost_prompt_len=${#last}
}

_ghost_refresh() {
    history -a
    _ghost_init_history
    _ghost_update_prompt_len
}

_ghost_get_suggestion() {
    _ghost_suggestion=""
    [[ -z "$1" ]] && return
    while IFS= read -r line; do
        if [[ "$line" == "$1"* && "$line" != "$1" ]]; then
            _ghost_suggestion="${line#"$1"}"
            return
        fi
    done <<< "$_ghost_history_data"
}

# Accept full suggestion; otherwise normal cursor-right
_ghost_accept() {
    if [[ $READLINE_POINT -lt ${#READLINE_LINE} ]]; then
        READLINE_POINT=$(( READLINE_POINT + 1 ))
    elif [[ -n "$_ghost_suggestion" ]]; then
        READLINE_LINE+="$_ghost_suggestion"
        READLINE_POINT=${#READLINE_LINE}
        _ghost_suggestion=""
    fi
    _ghost_render
}

# Accept next word of suggestion only
_ghost_accept_word() {
    [[ -z "$_ghost_suggestion" ]] && return
    local word="${_ghost_suggestion%% *}"
    [[ "$_ghost_suggestion" == *' '* ]] && word+=' '
    READLINE_LINE+="$word"
    READLINE_POINT=${#READLINE_LINE}
    _ghost_suggestion="${_ghost_suggestion#"$word"}"
    _ghost_render
}

_ghost_render() {
    [[ $READLINE_POINT -eq ${#READLINE_LINE} ]] \
        && _ghost_get_suggestion "$READLINE_LINE" \
        || _ghost_suggestion=""

    local col=$(( _ghost_prompt_len + ${#READLINE_LINE} + 1 ))
    if [[ -n "$_ghost_suggestion" ]]; then
        printf '\e[s\e[%dG\e[38;5;244m%s\e[0m\e[u' "$col" "$_ghost_suggestion" >&2
    else
        printf '\e[s\e[%dG\e[K\e[u' "$col" >&2
    fi
}

_ghost_insert() {
    READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}$1${READLINE_LINE:$READLINE_POINT}"
    READLINE_POINT=$((READLINE_POINT + ${#1}))
    _ghost_render
}

_ghost_backspace() {
    if [[ $READLINE_POINT -gt 0 ]]; then
        READLINE_LINE="${READLINE_LINE:0:$((READLINE_POINT - 1))}${READLINE_LINE:$READLINE_POINT}"
        READLINE_POINT=$((READLINE_POINT - 1))
    fi
    _ghost_render
}

_ghost_init_history
_ghost_update_prompt_len

# Character loop for all printable ASCII
for i in {32..126}; do
    char=$(printf "\\$(printf '%03o' "$i")")
    case "$char" in
        '"') qchar='\"' ;;
        '\') qchar='\\' ;;
        *)   qchar="$char" ;;
    esac
    bind -x "\"$qchar\": _ghost_insert \"$qchar\""
done

bind -x '"\e[C":  _ghost_accept'           # right arrow
bind -x '"\e[D":  READLINE_POINT=$(( READLINE_POINT > 0 ? READLINE_POINT-1 : 0 )); _ghost_render' # left arrow
bind -x '"\ef":   _ghost_accept_word'      # Alt-f
bind -x '"\C-f":  _ghost_accept_word'      # Ctrl-f

bind -x '"\C-?":  _ghost_backspace'        # Backspace
bind -x '"\C-h":  _ghost_backspace'        # Ctrl-h (Backspace)
bind -x '"\C-u":  READLINE_LINE=""; READLINE_POINT=0; _ghost_render'
bind -x '"\C-l":  clear; _ghost_render'
bind -x '"\C-a":  READLINE_POINT=0; _ghost_render'
bind -x '"\C-e":  READLINE_POINT=${#READLINE_LINE}; _ghost_render'

# Clear ghost text on history browse
bind '"\e[A": "\e[s\e[1000G\e[K\e[u\e[A"'
bind '"\e[B": "\e[s\e[1000G\e[K\e[u\e[B"'

PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }_ghost_refresh"
