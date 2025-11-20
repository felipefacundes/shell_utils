# Mounting QCOW2 Images on Arch Linux

This guide describes various methods for mounting images in QCOW2 format on Arch Linux, allowing access to the file systems contained within these images.

## 📋 Prerequisites

### Installing Required Packages

```bash
# Basic packages for QCOW2 manipulation
sudo pacman -S qemu libguestfs nbd

# Additional useful tools
sudo pacman -S fuse3 e2fsprogs dosfstools ntfs-3g
```

## 🔍 Identifying File Systems

Before mounting, it's important to identify the partitions and file systems contained in the image:

```bash
# List partitions and file systems
sudo virt-filesystems -a image.qcow2 -l

# Show detailed layout
sudo virt-filesystems -a image.qcow2 -lh

# Using qemu-nbd to inspect
sudo qemu-nbd -c /dev/nbd0 image.qcow2
sudo fdisk -l /dev/nbd0
```

## 🚀 Method 1: Using guestmount (Recommended)

### Mounting

```bash
# Create mount point
sudo mkdir -p /mnt/vm

# Change ownership to current user
sudo chown -R $USER:$USER /mnt/vm

# Or give read/write permission to group
sudo chmod -R 755 /mnt/vm

# Mount the image
guestmount -a image.qcow2 -i /mnt/vm

# Or specify partition manually
guestmount -a image.qcow2 -m /dev/sda1 /mnt/vm

# For Windows images
guestmount -a Win10.qcow2 -m /dev/sda2 /mnt/vm
guestmount -a Win10.qcow2 -m /dev/sda2 --ro /mnt/vm # For read-only --ro
```

### Unmounting

```bash
# Unmount normally
cd ~ # To exit the mount directory if you're there
guestunmount /mnt/vm

# Force unmount if necessary
sudo fusermount -u /mnt/vm

# If still not working, force:
sudo guestunmount --no-retry /mnt/vm
```

## 🔧 Method 2: Using NBD (Network Block Device)

### Load Kernel Module

```bash
# Load nbd module
sudo modprobe nbd max_part=16

# Check if devices were created
ls /dev/nbd*
```

### Mounting with NBD

```bash
# Connect image to nbd device
sudo qemu-nbd -c /dev/nbd0 image.qcow2

# Check partitions
sudo fdisk -l /dev/nbd0

# Mount specific partition
sudo mkdir -p /mnt/vm
sudo mount /dev/nbd0p1 /mnt/vm

# For specific file systems
sudo mount -t ntfs-3g /dev/nbd0p2 /mnt/vm  # Windows NTFS
sudo mount -t ext4 /dev/nbd0p1 /mnt/vm     # Linux EXT4
```

### NBD Unmounting

```bash
# Unmount partition
sudo umount /mnt/vm

# Disconnect nbd device
sudo qemu-nbd -d /dev/nbd0

# Remove module if necessary
sudo rmmod nbd
```

## 🛠️ Method 3: Using qemu-nbd with User Permissions

### Setup for non-root usage

```bash
# Add user to disk group
sudo usermod -a -G disk $USER

# Reload groups (logout/login or execute)
newgrp disk
```

### Mounting as regular user

```bash
# Connect with user permissions
qemu-nbd --fork --persistent --format=qcow2 --socket=/tmp/nbd-socket /dev/nbd0 image.qcow2

# Mount
mkdir -p ~/mount/vm
sudo mount /dev/nbd0p1 ~/mount/vm
sudo chown -R $USER:$USER ~/mount/vm
```

## 🔍 Verification and Troubleshooting

### Check processes using the mount point

```bash
# Check if there are processes preventing unmounting
sudo lsof +D /mnt/vm
# Or use fuser
fuser -v /mnt/vm

# Check specific FUSE processes
ps aux | grep fuse
sudo lsof | grep fuse
```

### Check active mounts

```bash
# List FUSE mounts
mount | grep fuse

# Check active nbd devices
lsblk | grep nbd

# Check active nbd connections
cat /sys/block/nbd*/pid
```

## 🎯 Practical Examples

### Linux Image (EXT4)

```bash
# Identify
sudo virt-filesystems -a linux.qcow2 -lh

# Mount
sudo guestmount -a linux.qcow2 -i /mnt/vm
sudo chown -R $USER:$USER /mnt/vm

# Work with files
ls -la /mnt/vm/

# Unmount
sudo guestunmount /mnt/vm
```

### Windows Image (NTFS)

```bash
# Identify partitions
sudo virt-filesystems -a windows.qcow2 -lh

# Mount Windows partition (usually sda2 or sda3)
sudo guestmount -a windows.qcow2 -m /dev/sda2 --ro /mnt/vm
sudo chown -R $USER:$USER /mnt/vm

# Unmount
sudo guestunmount /mnt/vm
```

## ⚠️ Troubleshooting

### Permission error

```bash
# If encountering FUSE permission error
sudo chmod +r /dev/fuse
```

### NBD device busy

```bash
# Check and free occupied nbd devices
sudo qemu-nbd -d /dev/nbd0
sudo rmmod nbd
sudo modprobe nbd max_part=16
```

### Corrupted image

```bash
# Check image integrity
qemu-img check image.qcow2

# Repair if necessary
qemu-img check -r all image.qcow2
```

## 📝 Important Notes

1. **Always unmount** before disconnecting NBD devices
2. **Use read-only mode** (`--ro`) with critical images
3. **Check permissions** after mounting
4. **NBD module** needs to be loaded with `max_part` for partition support
5. **guestmount** is generally the safest and easiest method

## 🔗 Useful Links

- [Arch Wiki - QEMU](https://wiki.archlinux.org/title/QEMU)
- [Libguestfs Documentation](https://libguestfs.org/)
- [QEMU Documentation](https://qemu-project.org/Documentation/)

This guide covers the main methods for working with QCOW2 images on Arch Linux. Choose the method that best suits your needs!