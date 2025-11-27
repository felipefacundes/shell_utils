remove_extension()
{
	clear
	cat <<-'EOF'
	# Remove extension tips - This guide presents professional techniques for file name manipulation in shell scripts, with special focus on removing file extensions. Each method includes practical examples with clearly demonstrated inputs and outputs.
	EOF
    clear
	cat <<-'EOF'
	# Remove extension

	Examples:

	SCRIPT_NAME="${0##*/}"

	filename="file.backup.tar.gz"
	echo "${filename%.*}"     # Output: file.backup.tar
	echo "${filename%%.*}"    # Output: file
	echo "${filename##*.}"    # Output: gz

	EOF
    echo -e "1) English tutorial\n2) Portuguese tutorial\n"
    read -r option
    [[ ! "$option" =~ ^[1-2]$ ]] && echo "Only number 1 or 2" && exit 1
    case $option in
        1)
            markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/remove_extension.md
        ;;
        2)
            markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/remove_extension_pt.md
        ;;
    esac
    clear
}