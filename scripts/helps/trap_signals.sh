trap_signals() {
    cat <<'EOF'
# Trap Signals - A Comprehensive Guide
EOF
    clear
    echo -e "1) English tutorial\n2) Portuguese tutorial\n"
    read -r option
    [[ ! "$option" =~ ^[1-2]$ ]] && echo "Only number 1 or 2" && exit 1
    case $option in
        1)
            markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/trap_signals.md
        ;;
        2)
            markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/trap_signals_pt.md
        ;;
    esac
    clear
}