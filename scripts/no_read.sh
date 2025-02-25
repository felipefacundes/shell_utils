#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
To capture a single character without needing to press "Enter", you can disable the terminal's canonical mode using "stty".  
This allows "head -c 1" to immediately capture the pressed key.  

🔹 Explanation:
- "stty -echo" → Prevents the key from being displayed on the screen
- "stty -icanon" → Disables canonical mode, allowing key capture without pressing "Enter"  
- "stty time 0 min 0" → Configures input to not wait for multiple characters
- "head -c 1 </dev/tty" or "dd bs=1 count=1 2>/dev/null </dev/tty" → Captures a single character directly from the keyboard
- "stty sane" → Restores the terminal to normal settings after reading  

✅ Advantages of this approach
✔️ Captures the key immediately without requiring "Enter"
✔️ Does not display the pressed key in the terminal  
✔️ Works on any terminal compatible with "stty"  
DOCUMENTATION

stty -echo -icanon time 0 min 1
#key=$(dd bs=1 count=1 2>/dev/null </dev/tty)
key=$(head -c 1 </dev/tty)
stty sane  # Restores the normal configuration of the terminal

echo "Pressed key: $key"