#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

# =============================================================================
# scrollhold.sh <device> <key> <command...>
#
# Repeats <command> while <key> and a Super key are physically held.
# Set SCROLLHOLD_DEBUG=1 to log every step to /tmp/scrollhold-debug.log
#
# Why this exists
#   Hyprland does not reliably deliver the key *release* event to Lua binds
#   (especially when the modifier is released before the letter), so a
#   "start on press, stop on release" approach keeps running forever.
#   Instead, this script asks the kernel directly, on every iteration,
#   whether the keys are still down, and exits the moment one is not.
#
# Arguments
#   <device>   evdev device that reports BOTH the letter and the Super key.
#              See the note above `scroll.config.device` in hyprland.lua for
#              how to find the right one.
#
# HOW TO FIND THE RIGHT <device>
#   It must be the evdev device that reports BOTH the letter key and the Super
#   key. `ls -l /dev/input/by-id/` only lists names and CANNOT tell which one is
#   right: gaming/multimedia keyboards expose several interfaces
#   ("-event-kbd", "-if01-event-kbd", ...) and often only one reports the typing
#   keys. The full procedure, with the exact commands, is in the comment above
#   `scroll.config.device` in hyprland.lua. In short:
#     1. command -v evtest ; id | grep -o input   (evtest installed, in the
#        `input` group)
#     2. run the scan loop and hold Super+W: it prints every device where
#        KEY_W / KEY_LEFTMETA are DOWN (evtest --query exits with 10 when down)
#     3. take the device where BOTH show up (e.g. /dev/input/event9)
#     4. ls -l /dev/input/by-id/ | grep '/event9$'   to get the stable name
#     5. sleep 3; evtest --query <device> EV_KEY KEY_W; echo $?   prints 10
#        while W is held
#   Symptom of a wrong device: the scroll runs once per press and stops
#   (debug log: "exit: KEY_W released" right after the first execution).
#
#   <key>      evdev key name of the letter, e.g. KEY_W or KEY_S
#   <command>  command to repeat, e.g. wlrctl pointer scroll -10 0
#
# Environment variables
#   SCROLLHOLD_INTERVAL  seconds between executions      (default: 0.04)
#   SCROLLHOLD_MAX       failsafe, max seconds per hold  (default: 60)
#   SCROLLHOLD_DEBUG     set to 1 to log every step to /tmp/scrollhold-debug.log
#
# How it works
#   1. /tmp/scrollhold-<key>.active is the "running" flag. It holds the PID of
#      the loop. If the flag exists and that PID is alive, a new call exits
#      immediately (duplicated press). A stale flag left by a crash is
#      ignored because the PID check fails.
#   2. The flags of the other directions are removed, which makes their loops
#      stop (only one direction at a time, no jitter when switching W <-> S).
#   3. The command runs once immediately, then in a loop while:
#        - its own flag file still exists
#        - <key> is down        (evtest --query exits with 10 when down)
#        - KEY_LEFTMETA or KEY_RIGHTMETA is down
#        - the failsafe time has not been reached
#   4. On exit, for any reason, a trap removes the flag file.
#
# Dependencies
#   evtest   reads the physical key state    (pacman -S evtest)
#   wlrctl   or whatever <command> is        (pacman -S wlrctl)
#   The user must be in the `input` group to read /dev/input devices.
# =============================================================================

dev="$1"; key="$2"; shift 2
interval="${SCROLLHOLD_INTERVAL:-0.04}"
max_secs="${SCROLLHOLD_MAX:-60}"
state="/tmp/scrollhold-${key}.active"
dlog="/tmp/scrollhold-debug.log"

if ! command -v evtest >/dev/null 2>&1; then
    notify-send -i dialog-error "Missing dependency" "evtest is not installed. Please install it to continue."
    exit 1
fi

# Appends a timestamped line to the debug log, only when SCROLLHOLD_DEBUG is set
dbg() {
    [ -n "$SCROLLHOLD_DEBUG" ] && printf '%s %s\n' "$(date +%T.%3N)" "$*" >> "$dlog"
}

# Returns success while the given key is physically down.
# evtest --query exits with 10 while the key is down (0 when it is up).
# Its stderr is captured into $err so failures show up in the debug log.
held() {
    local err rc
    err=$(evtest --query "$dev" EV_KEY "$1" 2>&1 >/dev/null)
    rc=$?
    dbg "query $1 rc=$rc ${err:+err=$err}"
    [ "$rc" -eq 10 ]
}

# Success if either Super key is down
mod_held() { held KEY_LEFTMETA || held KEY_RIGHTMETA; }

dbg "CALLED pid=$$ dev=$dev key=$key cmd=$*"

# Single instance per key: if the flag exists and its PID is alive, this is a
# duplicated press, so exit and let the running loop continue
if [ -e "$state" ] && kill -0 "$(cat "$state" 2>/dev/null)" 2>/dev/null; then
    dbg "exit: already running (pid $(cat "$state"))"
    exit 0
fi

# Stop the other directions (their loops exit when their flag disappears),
# then register this loop; the trap removes the flag however the script ends
rm -f /tmp/scrollhold-*.active
echo $$ > "$state"
trap 'rm -f "$state"' EXIT

start=$SECONDS
"$@"   # first scroll happens immediately, whatever the checks say

# Main loop: keeps going only while every condition below is true
while :; do
    [ -e "$state" ]                  || { dbg "exit: state file removed"; break; }
    held "$key"                      || { dbg "exit: $key released";      break; }
    mod_held                         || { dbg "exit: super released";     break; }
    (( SECONDS - start < max_secs )) || { dbg "exit: failsafe";           break; }
    "$@"
    sleep "$interval"
done
dbg "END"