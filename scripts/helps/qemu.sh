qemu_mounting_help()
{
	cat <<-'EOF'
	# QEMU - mounting images in QCOW2 format, allowing access to the file systems contained within these images.
	EOF
    clear
	cat <<-'EOF'
	sudo mkdir -p /mnt/vm
	sudo chmod 755 /mnt/vm
	sudo chown -R "$USER":"$USER" /mnt/vm
	chmod 755 /mnt/vm
	sudo virt-filesystems -a Win10.qcow2 -lh
	guestmount -a Win11.qcow2 -m /dev/sdX /mnt/vm
	guestunmount /mnt/vm

	EOF
    echo -e "1) English tutorial\n2) Portuguese tutorial\n"
    read -r option
    [[ ! "$option" =~ ^[1-2]$ ]] && echo "Only number 1 or 2" && exit 1
    case $option in
        1)
            markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/guestmount.md
        ;;
        2)
            markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/guestmount_pt.md
        ;;
    esac
    clear
}

qemu_gpu_passthrough_help()
{
	cat <<-'EOF'
	# QEMU - Complete Tutorial: Single-GPU Passthrough to Virtualization
	EOF
    echo -e "1) English tutorial 1\n2) Portuguese tutorial 1\n3) English tutorial 2\n4) Portuguese tutorial 2\n"
    read -r option
    [[ ! "$option" =~ ^[1-4]$ ]] && echo "Only number 1-4" && exit 1
    case $option in
        1)
            markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/gpuPassthrough.md
        ;;
        2)
            markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/gpuPassthrough_pt.md
        ;;
        3)
            markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/gpuPassthrough_tuto2.md
        ;;
        4)
            markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/gpuPassthrough_tuto2_pt.md
        ;;
    esac
    clear
}