windows_to_go()
{
	local GREEN='\033[0;32m'
	local NC='\033[0m'

	cat <<-EOF | echo -e "$(cat)"
	# Install windows on a pendrive / ssd / or external hard drive with just 2 commands (windows to go)

	Examples:

	1) Install Windows on a VDI drive (best to generate a dynamic drive and take up less disk space)
	 
	2) After Windows is installed, run the command:

	    ${GREEN}$ VBoxManage internalcommands converttoraw Win10.vdi Win10.img${NC}

	3) Clone the image to your external drive, be it USB stick or external SSD, etc.

	    ${GREEN}$ sudo dd if=Win10.img of=/dev/sdX oflag=direct,dsync conv=fsync bs=1M status=progress${NC}

	4) Choose one of the options below for a more detailed tutorial.
	  

	EOF
    echo -e "1) English tutorial\n2) Portuguese tutorial\n"
    read -r option
    [[ ! "$option" =~ ^[1-2]$ ]] && echo "Only number 1 or 2" && exit 1
    case $option in
        1)
            markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/windows_to_go.md
        ;;
        2)
            markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/windows_to_go_pt.md
        ;;
    esac
    clear
}