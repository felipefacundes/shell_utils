#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This Bash script converts an animation (GIF, WEBP, or video) into a sequence of images and displays them in the terminal 
using available image viewers. It ensures required commands are installed, handles temporary files, and allows frame navigation. 
The script runs in a loop, displaying images until the user presses a key to exit.
DOCUMENTATION

SCRIPT="${0##*/}"
TMPCACHE="${TMPCACHE:-${HOME}/.cache}"
TMP_DIR="${TMPCACHE}/${SCRIPT%.*}"
random_dir="${TMP_DIR}/$(date +%s)_$(echo -e $RANDOM)"

[[ -d "${TMP_DIR}" ]] && rm -rf "${TMP_DIR}"
[[ ! -d "${random_dir}" ]] && mkdir -p "${random_dir}"

cleanup() {
    rm -rf "$TMP_DIR"
}

trap 'cleanup; pkill -TERM -P $$; exit 1' INT TERM EXIT

cmd_check() {
    [[ "${#no_cmd[*]}" -gt 1 ]] && msg=$(echo "${no_cmd[*]}" | awk 'BEGIN {first=1} {for (i=1; i<=NF; i++) \
    {if (first) {printf "%s", $i; first=0} else {printf " or %s", $i}}} END {print ""}') || msg="${no_cmd[*]}"
    [[ "$1" == "-msg" ]] && echo "Install ${msg}" && no_cmd=() && exit 1
    ! command -v "$1" 1>/dev/null && no_cmd+=(\""$2"\") && return 1 || return 0
}

imgview() {
    cmd_check img2sixel libsixel && img2sixel "$1" && return 0 || cmd_check viu viu && viu "$1" && return 0 \
    || cmd_check catimg catimg && catimg "$1" && return 0 || cmd_check chafa chafa && chafa "$1" && return 0
    # shellcheck disable=SC2181
    [[ $? -ne 0 ]] && cmd_check -msg
}

convert_msg() {
    echo -e "Converting animation (video, gif, webp, etc.) to a sequence of images...\n"
}

anim_convert() {
    ext_test="${1##*.}"
    if [[ -f "$1" ]] && { [[ "${ext_test}" =~ ^([Gg][Ii][Ff])$ ]] || [[ "${ext_test}" =~ ^([Ww][Ee][Bb][Pp])$ ]]; }; then
        size=$(identify -format "%wx%h\n" "$1" | head -n1)
        cmd_check magick imagemagick && convert_msg && \
        magick "$1" -resize "${size}"! "${random_dir}"/frame_%04d.png && return 0 || cmd_check -msg
    elif [[ -f "$1" ]] && [[ "${ext_test}" =~ ^([MmAa][PpKkVv][4VvIi])$ ]]; then
        size=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 "$1" | sed 's/x/:/')
        cmd_check ffmpeg ffmpeg && convert_msg && \
        ffmpeg -i "$1" -vf "fps=10,scale=${size}" "${random_dir}"/video_%04d.png >/dev/null 2>&1 && return 0 || cmd_check -msg
    else
        echo -e "Not supported format $1"
        return 1
    fi
    return 0
}

anim_convert "$1" || exit 1

display_img() {
    # Get List of Frames Before Loop
    frames=("${random_dir}"/*.png)

    if [[ ${#frames[@]} -eq 0 ]]; then
        echo "No frames have been generated for display."
        exit 1
    fi

    # Terminal configuration for quick input
    stty -echo -icanon time 0 min 0 >/dev/null 2>&1

    while ! read -rsn1 -t 0.01 </dev/tty; do

        for i in "${frames[@]}"; do
            clear
            imgview "$i"

            if read -rsn1 -t 0.09 </dev/tty; then # Adjustment to control the speed of animation and closing
                cleanup
                stty sane >/dev/null 2>&1
                exit 0
            fi
        done
    done
}

display_img "$1" &
pid=$!
wait "$pid"