recent_files()
{
	local md=~/.shell_utils/scripts/markdown-reader
	cat <<-'EOF'
	# Recent Files. This guide presents efficient methods to locate and manage files created or modified recently in Linux systems, with special focus on files from the current day.
	EOF
    clear
	cat <<-'EOF' | "$md" -nl
	ls -lt --time-style=+%Y-%m-%d | grep "$(date +%Y-%m-%d)"
	
	| Command | Function | Example | Use Cases |
	|---------|----------|---------|-----------|
	| 'find -ctime -1' | Files created in last 24 hours | 'find /home/user/Docs -ctime -1' | Daily backup, new file monitoring |
	| 'find -cmin -X' | Files created in last X minutes | 'find . -type f -cmin -300' | Real-time monitoring, troubleshooting |
	| 'find -newermt "DATE"' | Files created since specific date | 'find . -newermt "2025-11-14"' | Period reports, auditing |
	| 'find -mtime -1' | Files modified in last 24h | 'find . -mtime -1' | Version control, detect changes |

	EOF
    echo -e "1) English tutorial\n2) Portuguese tutorial\n"
    read -r option
    [[ ! "$option" =~ ^[1-2]$ ]] && echo "Only number 1 or 2" && exit 1
    case $option in
        1)
            markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/list-files-from-current-date.md
        ;;
        2)
            markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/list-files-from-current-date-pt.md
        ;;
    esac
    clear
}