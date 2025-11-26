markers()
{
	clear
	cat <<-'EOF'
	# A complete and methodically categorized collection of ASCII format markers for documentation, accompanied by usage examples. (Marcadores para documetação).
	# Uma coletânea completa e metodicamente categorizada de marcadores no formato ASCII para documentação, acompanhada de exemplos de uso.

	EOF
    echo -e "1) English tutorial\n2) Portuguese tutorial\n"
    read -r option
    [[ ! "$option" =~ ^[1-2]$ ]] && echo "Only number 1 or 2" && exit 1
    case $option in
        1)
            markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/markers.md
        ;;
        2)
            markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/marcadores.md
        ;;
    esac
    clear
}