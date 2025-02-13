get_mouse_pointer()
{
cat <<'EOF'
# echo $(xdotool getmouselocation | grep -oP "[0-9]+ y:[0-9]+" | sed 's/ y://' | tr -d '\n')
EOF
}