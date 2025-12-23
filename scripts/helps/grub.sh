multiboot()
{
	cat <<-'EOF'
	# Creating a Multiboot USB Drive on ArchLinux with Administrative Tools, Various Linux Distributions, and Windows - handle 40_custom
	EOF
    clear
	cat <<-'EOF'
	sudo vim /etc/grub.d/40_custom

	submenu "MULTIBOOT (Distros and Tools) - ISO Images ->" {
        menuentry "Archlabs-2020.05.04.iso" --hotkey=l --class dvd {
            insmod part_gpt
            insmod search_fs_uuid
            set root=UUID=79041a97-c74a-4ede-b0f8-6588a17e0b6f
            set isofile="/ISOs/archlabs-2020.05.04.iso" root=UUID=79041a97-c74a-4ede-b0f8-6588a17e0b6f
            set dri="free"
            search --no-floppy -f --set=root $isofile
            probe -u $root --set=abc
            set pqr="/dev/disk/by-uuid/$abc"
            loopback loop $isofile
            linux (loop)/arch/boot/x86_64/vmlinuz img_dev=$pqr img_loop=$isofile driver=$dri
            initrd (loop)/arch/boot/x86_64/archiso.img
        }
	}

	EOF
    echo -e "1) English tutorial\n2) Portuguese tutorial\n"
    read -r option
    [[ ! "$option" =~ ^[1-2]$ ]] && echo "Only number 1 or 2" && exit 1
    case $option in
        1)
            markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/multiboot.md
        ;;
        2)
            markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/multiboot-pt.md
        ;;
    esac
    clear
}