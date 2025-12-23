my_current_terminal_is() {
    cat <<'EOF'
Use this commands:
    ps -o cmd= -p $(ps -o ppid= -p $$)
    ps -o ppid= -p $$ | xargs ps -o cmd= -p
EOF
}