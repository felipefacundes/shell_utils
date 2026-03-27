#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

# ─────────────────────────────────────────────
# Progress bar helper (batch mode)
# ─────────────────────────────────────────────
# Usage: draw_progress <current> <total>
_draw_progress() {
    local current="$1" total="$2"
    local width=40
    local pct=$(( current * 100 / total ))
    local filled=$(( current * width / total ))
    local bar=""
    for ((i=0; i<filled; i++));  do bar+="█"; done
    for ((i=filled; i<width; i++)); do bar+="░"; done
    printf "\r  [%s] %3d%% (%d/%d)" "$bar" "$pct" "$current" "$total"
}

# Draw progress generic
draw_progress() {
    local current="$1" total="$2" width="${3:-40}"
    local pct=$(( current * 100 / total ))
    local filled=$(( current * width / total ))
    local bar=""
    for ((i=0; i<filled; i++));  do bar+="█"; done
    for ((i=filled; i<width; i++)); do bar+="░"; done
    printf "\r  [%s] %3d%% (%d/%d)" "$bar" "$pct" "$current" "$total"
}