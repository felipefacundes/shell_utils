nouveau_nvk_zink()
{
	clear
	cat <<-'EOF'
	# Educational Tutorial: Configuration of Nouveau + NVK on Arch Linux
	
	EOF

    echo -e "1) English tutorial\n2) Portuguese tutorial\n"
    read -r option
    [[ ! "$option" =~ ^[1-2]$ ]] && echo "Only number 1 or 2" && exit 1
    case $option in
        1)
            markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/nouveau_nvk_zink.md
        ;;
        2)
            markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/nouveau_nvk_zink_pt.md
        ;;
    esac
    clear
}