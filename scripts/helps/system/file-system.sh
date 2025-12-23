permissions() {
	cat <<-'EOF'
	# chmod Permissions Listing (Octal System). Three-Digit Structure and Permissions: Files vs Directories
	EOF
	clear
	if [[ "${LANG,,}" =~ pt_ ]]; then
        markdown-reader -nl ~/.shell_utils/scripts/helps/markdowns/permissions_pt.md | head -n 51 | tail -n 33
        echo
        read -s -n 1 -rp "Pressione qualquer tecla, para exibir o help completo" >/dev/tty
        markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/permissions_pt.md
	else
        markdown-reader -nl ~/.shell_utils/scripts/helps/markdowns/permissions.md | head -n 51 | tail -n 33
        echo
        read -s -n 1 -rp "Press any key to display the full help" >/dev/tty
        markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/permissions.md
	fi
}

filesystem_help()
{
echo -e "
# filesystem help

$ lsblk -f
$ lsblk -dno uuid /dev/sdc1

Using -T directive with df command you can print file system type of all the mounted file systems.
$ df -Th

$ findmnt -t xfs
$ findmnt --fstab -t xfs

For example to list and check file system type for ext4 FS:
$ blkid -t TYPE=xfs
$ blkid

$ file -s /dev/sda1

$ udevadm info --query=property  /dev/sda1 | egrep 'DEVNAME|ID_FS_TYPE'

See More:
https://www.golinuxcloud.com/commands-linux-mounted-check-file-system-type/
"
}
