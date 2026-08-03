samba_share() {
	cat <<-'EOF'
	# Complete and Updated Tutorial: How to Create a Samba Share on Linux and Access it from Windows
	EOF
	clear
	if [[ "${LANG,,}" =~ pt_ ]]; then
		markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/samba-pt.md
	else
		markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/samba.md
    fi
}