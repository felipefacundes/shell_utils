#!/bin/bash
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This script creates a configuration file for the X11 server to disable sleep and power-saving features by setting the blank, 
standby, suspend, and off times to zero. It also enables DRI3 and specifies that all GLX visuals should be used, 
ensuring optimal performance for graphical applications.
DOCUMENTATION

cat <<'EOF' | sudo tee /etc/X11/xorg.conf.d/xorg_no_sleep.conf
Section "ServerFlags"
    Option "BlankTime" "0"
    Option "StandbyTime" "0"
    Option "SuspendTime" "0"
    Option "OffTime" "0"
    Option "DRI3" "on"
    Option "GlxVisuals" "all"
EndSection
EOF