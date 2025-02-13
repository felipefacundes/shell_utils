resolutions () {
    cat <<'EOF'
# resolutions :
    
HD              = 1280x720
FullHD          = 1920x1080
2k              = 2560x1440
Ultrawide 2k    = 3440x1440
4k              = 3840x2160
8k fulldome     = 8192×8192 (67.1 megapixels)
EOF
}

xrandr_brightness() {
    cat <<'EOF'
# xrandr --output MONITOR --brightness 1.0

EOF
    connected="$(xrandr | awk '/ connected/ {print $1; exit}')"
    for display in $connected; do
        echo "xrandr --output $display --brightness 1.0"
    done
}