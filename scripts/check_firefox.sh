#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This Bash script automates the process of managing a Firefox profile and clearing its cache. 
It first checks if a default profile exists in the specified directory; if not, it creates one. 
The script then clears the Firefox cache by navigating to the privacy settings using 'xdotool' to simulate keyboard input. 
After clearing the cache, it opens Firefox with the created profile. The script includes sleep commands to ensure that Firefox 
has enough time to initialize properly before proceeding. Overall, it provides a streamlined way to set up and manage a 
Firefox profile while maintaining privacy.
DOCUMENTATION

# Settings
PROFILE_DIR="$HOME/.mozilla/firefox/"
CHANGE_HERE_FIREFOX_DIR_OR_BIN="/usr/bin/firefox"
FIREFOX_BIN="$(eval $CHANGE_HERE_FIREFOX_DIR_OR_BIN)"

# Check if the profile exists, if not, create it
if [ ! -d "$PROFILE_DIR" ]; then
    echo "Creating new profile in $PROFILE_DIR"
    nohup "$FIREFOX_BIN" -CreateProfile default
fi

# Clear Firefox cache
echo "Clearing Firefox cache"
nohup "$FIREFOX_BIN" -P "default" -url "about:preferences#privacy" &>/dev/null
sleep 2
xdotool key Tab Tab Tab Tab Return
sleep 2

# Open Firefox with the created profile
echo "Opening Firefox"
nohup "$FIREFOX_BIN" -P "default" &

# Wait a few seconds for Firefox to fully initialize
sleep 10

# Add other commands or settings as needed

echo "Firefox successfully started"
