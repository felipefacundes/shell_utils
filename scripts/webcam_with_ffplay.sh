#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
Uses FFmpeg to access Webcam
DOCUMENTATION

ffplay -f video4linux2 -framerate 10 \
    -vf "hflip,format=yuv420p" \
    -video_size hd720 /dev/video0