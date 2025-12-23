#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This Bash script demonstrates an efficient approach to window transparency management in Linux environments. 
Its key strengths include:

1. Automated Window Detection: The script utilizes xdotool to automatically identify all active XTerm windows 
in the current session, eliminating the need for manual window selection.

2. Consistent Transparency Level: Implements a fixed transparency setting (0.9) across all XTerm windows, 
ensuring a uniform and professional appearance throughout the desktop environment.

3. Error Handling: The script includes output redirection to /dev/null, preventing unnecessary error messages 
from cluttering the terminal output.

4. Modular Design: The implementation features a well-structured function (apply_transparency) that can be easily 
modified or reused in other scripts, demonstrating good programming practices.

5. Tool Integration: Successfully combines multiple Linux utilities (transset-df and xdotool) to achieve its functionality, 
showcasing effective tool integration.

The script is particularly useful for users who prefer a semi-transparent terminal interface for better desktop integration 
while maintaining readability.
DOCUMENTATION

# Function to apply transparency to XTERM with the specified ID
apply_transparency() {
    local window_id="$1"
    transset-df -x 0.9 -m 0.9 --id "$window_id" >/dev/null
}

# Get the Xterm Window IDS list open
xterm_ids=$(xdotool search --class xterm)

# Applies transparency to all xterm windows found
for id in $xterm_ids; do
    apply_transparency "$id"
done
