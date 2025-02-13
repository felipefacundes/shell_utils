set_default_browser() {
    cat <<'EOF'
# Set Default Web Browser (Firefox/Chromium/etc)
export BROWSER=""
xdg-settings set default-web-browser chromium.desktop
xdg-settings get default-web-browser

Fonte: https://unix.stackexchange.com/questions/307641/cant-change-the-xdg-open-url-handler-to-firefox
EOF
}