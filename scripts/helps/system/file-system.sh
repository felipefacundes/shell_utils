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
