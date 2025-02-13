#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This Bash script checks the clipboard for a URL and determines if it is a link to YouTube or Vimeo. 
If the link is valid, it opens the video using the MPV media player; otherwise, it displays a notification 
indicating that the link is unsupported. The script is compatible with both Wayland and X11 environments.
DOCUMENTATION

# Check if the clipboard contains a link
if [[ $XDG_SESSION_TYPE == wayland ]]; then
    clip_content=$(wl-paste); export clip_content
else
    clip_content=$(xclip -o -selection clipboard); export clip_content
fi

icon="/usr/share/icons/hicolor/128x128/apps/mpv.png"

# Check if the content is a YouTube or Vimeo link
if [[ $clip_content =~ ^(https?://)?(www\.)?(youtube\.com|youtu\.be|vimeo\.com) ]]; then
    mpv "$clip_content" # Open the link with MPV
else
    echo 'Unsupported Link! The provided link does not belong to YouTube or Vimeo.'
    notify-send -i "$icon" "Unsupported Link" "The provided link does not belong to YouTube or Vimeo."
fi
