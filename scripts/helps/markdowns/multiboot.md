##### Creating a Multiboot USB Drive on ArchLinux with Administrative Tools, Various Linux Distributions, and Windows
<br/>
<br/>

###### We will use both the UEFI system for BOOT and MBR (for older systems).

----

###### First, format the USB drive with a small `40M` `FAT32` partition to use as `EFI`. The partition table doesn't need to be GPT; we will use the `DOS` table. The GPT table is superior to the DOS table - mainly due to size; GPT can have partitions up to 9.4ZB while DOS is only up to 2T. However, with the GPT table, GRUB does not write to the MBR.

----

##### Install some tools on your system before managing the USB drive:
`sudo pacman -S arch-install-scripts exfatprogs mtools dosfstools libisoburn`

----

##### Detecting which drive is the USB drive:
`sudo fdisk -l`

----

##### Creating the partition table on the USB drive:
`sudo cfdisk -z /dev/sdX` # Where X is the letter corresponding to your USB drive.

----

###### When choosing the DOS table, create the first partition as `40M`, the second one with the full remaining size, and if you want to have the Windows Installer on the USB drive, create a third partition as `FAT32`. However, this partition must be the exact size of the ISO image. For example, for a Windows 8.1 image, this partition will need to be 4.5G.

----

###### Do not create more than three partitions, as from the 4th partition onwards the USB drive will become slow. So, only create 3 partitions. Use the first as `FAT32`/EFI. The second will be the largest partition as `EXT4`, and the third for the Windows Installer as `FAT32`.

----

##### Assuming your USB drive is the second disk drive with the letter `B` (remember to first detect the drive using `sudo fdisk -l`), format it as follows:
```
sudo mkfs.vfat -F32 -n EFI /dev/sdX1
sudo mkfs.ext4 /dev/sdX2
sudo mkfs.vfat -F32 -n WIN_INSTALL /dev/sdX3
```

----

##### Mounting the units - replace the letter `B` with the letter corresponding to your USB drive:
```
sudo mount /dev/sdX2 /mnt
sudo mkdir -p /mnt/boot/EFI
sudo mkdir -p /mnt/WIN_INSTALL
sudo mkdir -p /mnt/ISOs
sudo mount /dev/sdX1 /mnt/boot/EFI
sudo mount /dev/sdX3 /mnt/WIN_INSTALL
sudo chown -R "$USER":users /mnt/
```

----

##### Install the basics on the USB drive. Do NOT install the kernel.
`sudo pacstrap -i /mnt coreutils efibootmgr exfatprogs grub dosfstools libisoburn mtools sed`

----

###### Download the ISO images you want the USB drive to have available for BOOT.

----

###### For Windows, do the following:
```
mkdir ~/WIN
sudo modprobe loop
sudo mount -o loop Windows-Installer.iso ~/WIN

cp -rf ~/WIN/* /mnt/WIN_INSTALL/ && sync

sudo umount -R ~/WIN && rm -rf ~/WIN
```

----

###### If you are going to have an image of a Linux distribution on the USB drive, copy it to the ISOs folder on the USB drive.
`cp -f linux-distribution-image.iso /mnt/ISOs/`

----

###### Editing the GRUB `40_custom` file to have multiple boots on the USB drive. Use your preferred text editor; in this example, we'll use `vim`.

`sudo vim /mnt/etc/grub.d/40_custom`

----

##### Example of a `40_custom` file with the Windows Installer on the USB drive partition and ArchLinux ISO. Remember that you can have any Linux distribution on the USB drive, but the ISO parameters are different for each Linux distribution:

###### First of all, check the UUID of each partition on the USB drive using the command: `sudo blkid` and replace `1234-5678` with the corresponding UUID of the partition where the ISOs are and the Windows Installer partition.
```markdown
menuentry "Recovery: ArchLinux-2022.03.iso" --hotkey=0 --class dvd {
      	insmod part_gpt
      	insmod search_fs_uuid
      	set root=UUID=d3c602bf-4a10-4948-b4c4-13f7d3fa0bc2
      	set isofile="/archlinux-2022.03.01-x86_64.iso"
      	set dri="free"
      	search --no-floppy -f --set=root $isofile
      	probe -u $root --set=abc
      	set pqr="/dev/disk/by-uuid/$abc"
      	loopback loop $isofile
      	linux (loop)/arch/boot/x86_64/vmlinuz-linux img_dev=$pqr img_loop=$isofile driver=$dri
      	initrd (loop)/arch/boot/intel-ucode.img (loop)/arch/boot/amd-ucode.img (loop)/arch/boot/x86_64/initramfs-linux.img
}

menuentry "ArchLinux-2020.iso" --class dvd {
      insmod part_msdos
      insmod search_fs_uuid
      set root=UUID=1234-5678
      set isofile="/ISOs/ArchLinux-2020.iso" root=UUID=1234-5678
      set dri="free"
      search --no-floppy -f --set=root $isofile
      probe -u $root --set=abc
      set pqr="/dev/disk/by-uuid/$abc"
      loopback loop $isofile
      linux (loop)/arch/boot/x86_64/vmlinuz img_dev=$pqr img_loop=$isofile driver=$dri
      initrd (loop)/arch/boot/x86_64/archiso.img
}

menuentry "Windows 10 Installer Partition" --class windows --class os {
        insmod part_msdos
        insmod chain
        insmod exfat
        insmod fat
        insmod search_fs_uuid
        set root=UUID=1234-5678
        search --no-floppy --fs-uuid --set=root 1234-5678
        chainloader /efi/boot/bootx64.efi root=UUID=1234-5678
}

menuentry "Android (Phoenix-OS)" --hotkey=a --class android-x86 {
	insmod part_gpt
	insmod search_fs_uuid
	set root=UUID=5cbd2559-e23e-4696-9645-08580d8e3fb7
	search --file --no-floppy --set=root /PhoenixOS/system.img
        linux /PhoenixOS/kernel root=/dev/ram0 androidboot.hardware=android_x86_64 androidboot.selinux=permissive quiet SRC=/PhoenixOS Data=/data vga=788
	initrd /PhoenixOS/initrd.img
}

menuentry "Android (BlissOS-v11.13)" --hotkey=1 --class android-x86 {
	insmod part_gpt
	insmod search_fs_uuid
	set root=UUID=5cbd2559-e23e-4696-9645-08580d8e3fb7
	search --file --no-floppy --set=root /BlissOS-v11.13/system.img
        linux /BlissOS-v11.13/kernel root=/dev/ram0 androidboot.hardware=android_x86_64 androidboot.selinux=permissive quiet SRC=/BlissOS-v11.13 Data=/data vga=788
	initrd /BlissOS-v11.13/initrd.img
}
```

----

##### After making the necessary modifications to the `40_custom` file - remember to adjust it according to your case - enter the USB drive and update GRUB:
##### Now enter the mini arch system and let's manage GRUB:
```
sudo arch-chroot /mnt

grub-install --target=i386-pc --recheck /dev/sdX   #This command installs GRUB to the MBR

grub-install --verbose --recheck --force --target=x86_64-efi --efi-directory=/boot/EFI --bootloader-id=MULTIBOOT --removable

grub-mkconfig -o /boot/grub/grub.cfg

exit    #Or control + D - to exit chroot

sudo umount -R /mnt
```

----

##### USB drive ready. Just restart the system and boot from the USB drive. Don't forget to read this article carefully to do everything correctly ;)

----

###### Here are some examples of `40_custom`:
[Example 1](https://github.com/felipefacundes/MultiBoot/blob/main/examples/40_custom_2022)

[Example 2](https://github.com/felipefacundes/MultiBoot/blob/main/examples/40_custom)

[Example 3](https://github.com/felipefacundes/MultiBoot/blob/main/examples/40_custom.example.2)

[Example 4](https://github.com/felipefacundes/MultiBoot/blob/main/examples/40_custom.example.several)