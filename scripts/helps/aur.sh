aur_new_package() {
    cat <<'EOF'
# Trap Signals - A Comprehensive Guide
EOF
    clear
    echo -e "1) English tutorial\n2) Portuguese tutorial\n3) Espanhol tutorial\n"
    read -r option
    [[ ! "$option" =~ ^[1-3]$ ]] && echo "Only number 1-3" && exit 1
    case $option in
        1)
            markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/AUR_NEW_PACKAGE.md
        ;;
        2)
            markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/AUR_NEW_PACKAGE-pt.md
        ;;
        3)
            markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/AUR_NEW_PACKAGE-es.md
        ;;
    esac
    clear
}