wipefs_with_dd() {
echo '
# wipefs with dd
'
    tput setaf 6
    echo -e "Command to delete MBR including all partitions
Open a terminal and type the following command command to delete everything:"
    tput setaf 11
    echo -e "sudo dd if=/dev/zero of=/dev/sdX bs=512 count=1\n
if=/dev/zero – Read data from /dev/zero and write it to /dev/sdX.
of=/dev/sdX – /dev/sdX is the USB drive to remove the MBR including all partitions.
bs=512 – Read from /dev/zero and write to /dev/sdX up to 512 BYTES bytes at a time.
count=1 – Copy only 1 BLOCK input blocks."
}

dd_help() {
echo '
# dd --help - Zero fill Pendrive/HD/SSD - Delete MBR - Create Bootable OS USB Sticks: BSDs and Linux Distros
'
    tput setaf 9
    echo -e "Attention!\n"
    tput setaf 6
    echo -e "Create Bootable OS USB Sticks: BSDs and Linux Distros\n"
    tput setaf 11
    echo -e "sudo dd if=DISTRO.iso of=/dev/sdX bs=70k oflag=direct conv=sync status=progress && sync"
    echo -e "Or:"
    echo -e "sudo dd if=DISTRO.iso of=/dev/sdX count=1 bs=4M oflag=direct,dsync status=progress && sync\n"
    wipefs_with_dd
    tput setaf 6
    echo -e "\nDelete MBR only"
    tput setaf 11
    echo -e "sudo dd if=/dev/zero of=/dev/sdX bs=446 count=1"
    tput setaf 6
    echo -e "\nZero fill Pendrive/HD/SSD:"
    tput setaf 11
    echo -e "sudo dd if=/dev/zero of=/dev/sdX oflag=direct,dsync conv=fsync bs=1M status=progress\n"
    tput sgr0
}

gpt_or_mbr() {

( cat <<'EOF'
# gpt or mbr

$ udevadm info -q property -n sdX | grep ID_PART_TABLE_TYPE
$ udevadm info -q property -n sdX | grep ID_PART_TABLE_TYPE | cut -f2 -d'='
$ disk_check_table
$ sudo partprobe -d -s /dev/sdX
$ sudo parted -l
$ sudo parted /dev/sdX print
$ sudo gdisk -l /dev/sdX
$ sudo gpart show
$ sudo fdisk -l 
$ sudo blkid /dev/sdX
$ sudo blkid -o export /dev/sdX

See:
    https://unix.stackexchange.com/questions/120221/gpt-or-mbr-how-do-i-know
EOF
) #| less -i
}

