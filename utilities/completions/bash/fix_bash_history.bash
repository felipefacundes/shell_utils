#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

###############################################################################
# bash_history maintenance - v4 (fast and quiet)
#
# WHAT CHANGED FROM v3
#
# 1. FORKS. v3 spawned a `$( )` subshell for every command in the history,
#    inside the parser, just to join the lines of a block. On a 10,000-command
#    history that is 10,000 forks - that was the source of the slowness. The
#    join is now done with `printf -v` (a builtin, zero forks).
#
# 2. SINGLE PASS. `history_maintenance` used to take 4 locks, do 4 reads and
#    4 rewrites of the file. Everything (zsh format, orphan timestamps,
#    missing timestamps, duplicates) now happens in one read and one rewrite,
#    under a single lock.
#
# 3. NO grep/sed/mktemp/find/ls/tail/xargs. The zsh prefix is stripped using
#    bash's own expansions; the temp file uses `$$.$RANDOM` instead of
#    `mktemp`; backup pruning is gone along with the dated backups. A typical
#    run leaves 2 external processes (`ln` and `mv`) - and zero when there is
#    nothing to fix.
#
# 4. INSTANT BACKUP. Instead of `cp -p` (a real copy of the whole file on
#    every run), the backup is a hard link: `ln -f histfile histfile.bak`.
#    It costs one directory entry and copies no data. Since the final write
#    is a `mv` (atomic rename, which creates a new inode), the .bak keeps
#    pointing at the old contents. Same safety, near-zero cost.
#
# 5. TRULY ATOMIC WRITE. `mv` within the same filesystem is an atomic rename:
#    the file is either the old one or the new one, never half-written. v3
#    used `cat tmp > histfile`, which could leave the file truncated on a
#    crash or power loss.
#
# 6. NO WRITE IF NOTHING CHANGED. Every fix sets a flag; with no flag the
#    file is not touched, no backup is made, and the history is not reloaded.
#
# 7. EARLY-EXIT SHORTCUT. If the history has not been modified since the last
#    maintenance run (a `-nt` test against a stamp file, builtin), the
#    function returns immediately without even opening the file. Cost: zero
#    processes.
#
# 8. QUIET. No output during normal operation. Real failures go to stderr.
#    A busy lock means another terminal is already handling it, so the
#    function exits quietly instead of stalling your prompt.
#
# CONFIGURATION (all optional)
#   HISTMAINT_VERBOSE=1      print a report of what was done
#   HISTMAINT_LOCK_TIMEOUT   seconds to wait for the lock (default 1)
#   HISTMAINT_LOCKFILE       alternate lock file path
#   HISTMAINT_BACKUP=0       disable the hard-link backup
#
# USAGE IN .bashrc
#   source ~/bash_history_maint.sh
#   history_maintenance          # safe at startup: exits in ~0ms if unchanged
# Or, more conservatively, from ~/.bash_logout.
###############################################################################

: "${HISTMAINT_LOCK_TIMEOUT:=1}"
: "${HISTMAINT_BACKUP:=1}"

_hist_say() { [[ -n "${HISTMAINT_VERBOSE:-}" ]] && printf '%s\n' "$*"; return 0; }
_hist_err() { printf 'history: %s\n' "$*" >&2; }

_histfile_path()     { printf '%s' "${HISTFILE:-$HOME/.bash_history}"; }
_histfile_lockpath() { printf '%s' "${HISTMAINT_LOCKFILE:-${HISTFILE:-$HOME/.bash_history}.lock}"; }
_histfile_stamppath(){ printf '%s' "${HISTFILE:-$HOME/.bash_history}.stamp"; }

#------------------------------------------------------------------------------
# Lock: ONE file shared by every function, on purpose - a lock only excludes
# concurrent access if everyone contends for the same file. Opened with 9>>
# (append), which does not truncate and does not trip `set -o noclobber`.
#   3 = could not open the lock    4 = busy (exit quietly, never stall the prompt)
#------------------------------------------------------------------------------
_histfile_with_lock() {
    local lock_file
    lock_file="$(_histfile_lockpath)"

    if ! command -v flock >/dev/null 2>&1; then
        ( set +C; "$@" )
        return $?
    fi

    (
        set +C
        exec 9>>"$lock_file" 2>/dev/null || exit 3
        flock -w "$HISTMAINT_LOCK_TIMEOUT" 9 || exit 4
        "$@"
    )
}

_histfile_reload() {
    [[ $- == *i* ]] || return 0
    history -c
    history -r "$(_histfile_path)"
}

_histfile_touch_stamp() {
    local stamp="$1" had_noclobber=0
    [[ -o noclobber ]] && { had_noclobber=1; set +C; }
    : > "$stamp" 2>/dev/null
    (( had_noclobber )) && set -C
    return 0
}

###############################################################################
# CORE: read, fix and write - a single pass, under the lock.
#   $1 = 1 to deduplicate, 0 to skip deduplication
# Silent unless HISTMAINT_VERBOSE is set.
###############################################################################
_hist_process() {
    local dedup="${1:-1}"
    local hist_file stamp tmp_file
    hist_file="$(_histfile_path)"
    stamp="$(_histfile_stamppath)"

    local lines=()
    mapfile -t lines < "$hist_file" 2>/dev/null || return 1
    local n=${#lines[@]}
    (( n == 0 )) && { _histfile_touch_stamp "$stamp"; return 0; }

    local changed=0
    local ts_list=() body_list=()
    local i=0 line ts body joined

    #--- single pass: strip zsh prefix, group blocks, drop orphans ------------
    while (( i < n )); do
        ts=""
        if [[ "${lines[i]}" == '#'* && "${lines[i]}" =~ ^#[0-9]+$ ]]; then
            ts="${lines[i]}"
            ((i++))
        fi

        body=()
        while (( i < n )); do
            line="${lines[i]}"
            [[ "$line" == '#'* && "$line" =~ ^#[0-9]+$ ]] && break
            # zsh EXTENDED_HISTORY prefix: ": <epoch>:0;command"
            if [[ "$line" == ': '* && "$line" =~ ^:\ [0-9]{10}:0\;(.*)$ ]]; then
                line="${BASH_REMATCH[1]}"
                changed=1
            fi
            body+=("$line")
            ((i++))
        done

        if (( ${#body[@]} == 0 )); then
            [[ -n "$ts" ]] && changed=1     # orphan timestamp discarded
            continue
        fi

        if (( ${#body[@]} == 1 )); then
            joined="${body[0]}"
        else
            printf -v joined '%s\n' "${body[@]}"
            joined="${joined%$'\n'}"
        fi

        ts_list+=("$ts")
        body_list+=("$joined")
    done

    local total=${#body_list[@]}
    (( total == 0 )) && { _histfile_touch_stamp "$stamp"; return 0; }

    #--- deduplicate by BLOCK, keeping the most recent occurrence -------------
    local keep_idx=()
    if (( dedup )); then
        local -A seen=()
        for (( i=total-1; i>=0; i-- )); do
            if [[ -z "${seen[${body_list[i]}]:-}" ]]; then
                seen["${body_list[i]}"]=1
                keep_idx+=("$i")
            fi
        done
        (( ${#keep_idx[@]} != total )) && changed=1
    else
        for (( i=total-1; i>=0; i-- )); do keep_idx+=("$i"); done
    fi

    #--- build the output, filling in any missing timestamps ------------------
    local now out=() idx k=${#keep_idx[@]}
    printf -v now '%(%s)T' -1
    for (( i=k-1; i>=0; i-- )); do
        idx="${keep_idx[i]}"
        if [[ -n "${ts_list[idx]}" ]]; then
            out+=("${ts_list[idx]}")
        else
            out+=("#$now")
            changed=1
        fi
        out+=("${body_list[idx]}")
    done

    if (( ! changed )); then
        _histfile_touch_stamp "$stamp"
        _hist_say "History is already clean (${total} commands)."
        return 2                      # 2 = nothing to do, no reload needed
    fi

    #--- write: hard-link backup (instant) + atomic rename --------------------
    local had_noclobber=0
    [[ -o noclobber ]] && { had_noclobber=1; set +C; }

    tmp_file="${hist_file}.tmp.$$.$RANDOM"
    if ! printf '%s\n' "${out[@]}" > "$tmp_file" 2>/dev/null; then
        rm -f -- "$tmp_file" 2>/dev/null
        (( had_noclobber )) && set -C
        _hist_err "failed to write the temporary file"
        return 1
    fi

    (( HISTMAINT_BACKUP )) && ln -f -- "$hist_file" "${hist_file}.bak" >/dev/null 2>&1

    chmod 600 -- "$tmp_file" 2>/dev/null
    if ! mv -f -- "$tmp_file" "$hist_file" >/dev/null 2>&1; then
        rm -f -- "$tmp_file" 2>/dev/null
        (( had_noclobber )) && set -C
        _hist_err "failed to replace $hist_file (backup at ${hist_file}.bak)"
        return 1
    fi

    _histfile_touch_stamp "$stamp"
    (( had_noclobber )) && set -C

    _hist_say "History: ${k} commands kept, $(( total - k )) duplicates removed."
    return 0
}

###############################################################################
# Full maintenance. Quiet. Exits with ~0 processes when nothing changed.
###############################################################################
history_maintenance() {
    local hist_file stamp rc
    hist_file="$(_histfile_path)"
    stamp="$(_histfile_stamppath)"

    [[ -f "$hist_file" ]] || return 0
    # builtin shortcut: history untouched since the last maintenance run
    [[ -f "$stamp" && ! "$hist_file" -nt "$stamp" ]] && return 0

    _histfile_with_lock _hist_process 1
    rc=$?
    case "$rc" in
        0) _histfile_reload; return 0 ;;   # changed: reload
        2) return 0 ;;                     # nothing to do: no reload
        4) return 0 ;;                     # lock busy: another terminal has it
        3) _hist_err "could not open the lock ($(_histfile_lockpath))"; return 3 ;;
        *) return "$rc" ;;
    esac
}

# Same thing, without deduplication (normalizes format and timestamps only).
history_normalize() {
    local rc
    [[ -f "$(_histfile_path)" ]] || return 0
    _histfile_with_lock _hist_process 0
    rc=$?
    case "$rc" in
        0) _histfile_reload; return 0 ;;
        2|4) return 0 ;;
        3) _hist_err "could not open the lock ($(_histfile_lockpath))"; return 3 ;;
        *) return "$rc" ;;
    esac
}

# Forces a cleanup even when the stamp says nothing has changed.
history_clean_duplicate_commands() {
    local rc
    [[ -f "$(_histfile_path)" ]] || { _hist_err "history file not found"; return 1; }
    _histfile_with_lock _hist_process 1
    rc=$?
    case "$rc" in
        0) _histfile_reload; return 0 ;;
        2|4) return 0 ;;
        3) _hist_err "could not open the lock ($(_histfile_lockpath))"; return 3 ;;
        *) return "$rc" ;;
    esac
}

###############################################################################
# Restores the backup (hard link to the previous version).
###############################################################################
history_restore_last_backup() {
    local hist_file bak
    hist_file="$(_histfile_path)"
    bak="${hist_file}.bak"
    [[ -f "$bak" ]] || { _hist_err "no backup found ($bak)"; return 1; }
    cp -f -- "$bak" "$hist_file" || return 1
    rm -f -- "$(_histfile_stamppath)" 2>/dev/null
    _histfile_reload
    _hist_say "History restored from $bak"
}

###############################################################################
# Backwards compatibility with the old names - all route to the single pass.
###############################################################################
history_strip_zsh_timestamps()     { history_normalize; }
history_remove_orphan_timestamps() { history_normalize; }
history_add_missing_timestamps()   { history_normalize; }
_remove_timestamp_in_single_line_format_from_bash_history() { history_normalize; }
_remove_unused_timestamps_from_bash_history()               { history_normalize; }
_include_timestamp_in_bash_history()                        { history_normalize; }