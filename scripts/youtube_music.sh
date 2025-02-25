#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This script is a frustrating attempt to make qutebrowser a client for YouTube Music, without ads.
It might serve as a basis to always make qutebrowser restore the session effectively from where it left off.
DOCUMENTATION

TMPDIR="${TMPDIR:-/tmp}"
ONE_SHOT=false
SCRIPT_NAME="${0##*/}" 
SCRIPT_NAME="${SCRIPT_NAME%.*}"
EDITOR_FAKE=~/.local/bin/qute_copy_temp_url
CONFIG_QUTE=~/.config/qutebrowser/config.py
LAST_URL_FILE="${HOME}/.${SCRIPT_NAME}.qutebrowser_last_url"

cleanup() {
    pkill -9 -P $$
    status=$?  # Stores the pkill output code
    while [ $status -ne 0 ] && ! pkill -9 "$(echo "${0##*/}" | cut -c1-15)" >/dev/null 2>&1; do
        return 1
    done
    return 0
}

# Capture Ctrl+C and end children processes
trap cleanup SIGINT SIGTERM SIGHUP SIGQUIT EXIT

if ! command -v qutebrowser 1>/dev/null; then
    echo 'Please! Install qutebrowser'
    exit 1
fi

[[ ! -d ~/.local/bin ]] && mkdir -p ~/.local/bin

if [[ ! -f "$EDITOR_FAKE" ]]; then
cat <<EOF | tee "$EDITOR_FAKE" >/dev/null 2>&1
#!/usr/bin/env bash
cp -f ${TMPDIR}/qutebrowser-editor-* ${TMPDIR}/qutebrowser_url && rm -f ${TMPDIR}/qutebrowser-editor-*
EOF
chmod +x "$EDITOR_FAKE"
fi

if [[ ! -f "$CONFIG_QUTE" ]]; then
cat <<EOF | tee "$CONFIG_QUTE" >/dev/null 2>&1
config.load_autoconfig()  
c.editor.command = ["$EDITOR_FAKE", "{file}"]
c.content.blocking.adblock.lists = [
    "https://filters.adtidy.org/extension/ublock/filters/122_optimized.txt",
    "https://easylist-downloads.adblockplus.org/easylist.txt",
    "https://easylist.to/easylist/easyprivacy.txt",
    "https://easylist.to/easylist/easylist.txt",
    "https://malware-filter.gitlab.io/malware-filter/urlhaus-filter.txt",
    "https://raw.githubusercontent.com/uBlockOrigin/uAssets/refs/heads/master/filters/filters-2025.txt"
]
EOF
fi

# 🎯 When a command like 'qutebrowser' is called directly in the script, it can become the foreground process, 
# making it harder for the 'trap' to control it. However, when the command is inside a function, 
# the script maintains the correct process hierarchy, allowing the 'trap' to control everything with 'pkill -P $$' or 'kill -- -$$'.
_qutebrowser() {
    qutebrowser "$@" &
    QUTE_PID=$!
    wait "$QUTE_PID"
}

# Function to capture the active URL
capture_url() {
    while pgrep -x qutebrowser > /dev/null; do
        URL=$(_qutebrowser --target window ':edit-url' 2>/dev/null && cat "${TMPDIR}/qutebrowser_url" 2>/dev/null)
        if [[ -n "$URL" ]]; then
            echo "$URL" > "$LAST_URL_FILE"
        fi
        if [[ "$ONE_SHOT" != true ]]; then
            curl -o "${TMPDIR}/easylist.txt" https://easylist.to/easylist/easylist.txt 2>/dev/null
            _qutebrowser --target window ':set content.blocking.enabled true' 2>/dev/null
            _qutebrowser --target window ":set content.blocking.hosts.lists ${TMPDIR}/easylist.txt" 2>/dev/null
            _qutebrowser --target window ':adblock-update' 2>/dev/null
            ONE_SHOT=true
        fi

        sleep 30
        rm -f "${TMPDIR}/qutebrowser_url" 2>/dev/null
    done
    cleanup &
    pid=$!
    wait $pid
    return 0
}

# Check if qutebrowser is already running
if pgrep -x qutebrowser > /dev/null; then
    _qutebrowser --target window 2>/dev/null
else
    if [[ -f "$LAST_URL_FILE" ]]; then
        LAST_URL=$(cat "$LAST_URL_FILE")
        _qutebrowser "$LAST_URL" 2>/dev/null &
    else
        _qutebrowser music.youtube.com 2>/dev/null &
    fi
fi

# Captures the URL continuously while qutebrowser is open
capture_url &
pid=$!
wait $pid
exit 0