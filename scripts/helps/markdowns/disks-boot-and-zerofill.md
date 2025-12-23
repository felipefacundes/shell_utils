# Commands for Bootable USB and Disk Management

## Create Bootable USB

### Basic dd command
```bash
sudo dd if=DISTRO.iso of=/dev/sdX bs=70k oflag=direct conv=sync status=progress && sync
```
Writes ISO to USB with 70k blocks, shows progress, and syncs data.

### Alternative dd command
```bash
sudo dd if=DISTRO.iso of=/dev/sdX count=1 bs=4M oflag=direct,dsync status=progress && sync
```
Uses 4M blocks for single write with direct sync for faster transfer.

## Disk Cleaning Commands

### Erase MBR and partitions
```bash
sudo dd if=/dev/zero of=/dev/sdX bs=512 count=1
```
Overwrites first 512 bytes (MBR + partition table) with zeros.

### Erase MBR only
```bash
sudo dd if=/dev/zero of=/dev/sdX bs=446 count=1
```
Overwrites only the 446-byte bootloader, preserving partition table.

## Complete Disk Wiping

### Zero fill with sync
```bash
sudo dd if=/dev/zero of=/dev/sdX oflag=direct,dsync conv=fsync bs=1M status=progress
```
Fills entire disk with zeros using direct I/O and complete sync.

### Basic zero fill
```bash
sudo dd if=/dev/zero of=/dev/sdX bs=1M status=progress
```
Simple zero fill using 1M blocks.

### Optimized fill
```bash
sudo dd if=/dev/zero of=/dev/sdX bs=4M status=progress oflag=direct
```
4M blocks with direct flag for faster wiping.

### Random data fill
```bash
sudo dd if=/dev/urandom of=/dev/sdX bs=1M status=progress
```
Fills disk with random data for more secure erasure.

## Advanced Disk Operations

### BLKDISCARD commands
```bash
sudo blkdiscard /dev/sdX
```
Discards all blocks on supported storage (SSD/NVMe).

```bash
sudo blkdiscard -f /dev/sdX
```
Forces discard even on mounted filesystems.

### Secure shred
```bash
sudo shred -n3 -z -v /dev/sdX
```
Three random overwrite passes plus final zero pass.

## Drive Security Commands

### Check security status
```bash
sudo hdparm -I /dev/sdX | grep -i "supported\|enabled\|frozen"
```
Shows security features and current drive status.

### Set drive password
```bash
sudo hdparm --user-master u --security-set-pass PASSOU /dev/sdX
```
Sets user password for drive security.

### Secure erase
```bash
sudo hdparm --user-master u --security-erase PASSOU /dev/sdX
```
Performs secure erase using previously set password.

## NVMe Specific Commands

### NVMe sanitize
```bash
sudo nvme sanitize /dev/nvme0nX
```
Initiates NVMe sanitize operation for secure data removal.

### NVMe format
```bash
sudo nvme format /dev/nvme0nX --ses=1
```
Formats NVMe drive with user data erase (ses=1).

---
The command `sudo shred -n1 -z -v /dev/sdX` is an excellent choice for performing a *zerofill* on the drive. It combines speed and security by performing one pass with random data followed by a final overwrite with zeros.

### 🔍 Zerofill Methods Comparison

The table below compares the `shred` command with other common alternatives like `dd` to help you choose the best method for your needs.

**`sudo shred -n1 -z -v /dev/sdX`** | 1 pass with random data + **1 final pass with zeros**. Enhanced security with randomness, maintaining simple tracking. Combines security with "invisible" finish. Ideal choice.
**`sudo dd if=/dev/zero of=/dev/sdX bs=1M status=progress`** | **Single pass**, filling entire disk with zeros. Situations where speed is crucial and data isn't sensitive. Fast and simple, but without randomness.

### ⚠️ Important Limitations on SSDs

The `shred` and `dd` commands may **not be fully effective** on solid-state drives (SSDs) due to **wear leveling** technology. The SSD controller may redirect writes to different physical areas, leaving original data in other memory blocks.

For SSDs, the most reliable methods are:
*   **`nvme format` command**: For NVMe disks, use `sudo nvme format /dev/nvme0n1 --ses=1` for secure hardware erasure.
*   **`blkdiscard` command**: For SSDs supporting TRIM command, `sudo blkdiscard /dev/sdX` is the fastest option, invalidating all data.
*   **ATA Secure Erase**: A firmware command that orders the drive to self-erase completely.

### ✅ How to Execute Safely

Follow these steps to avoid accidents:

1.  **Correctly identify the device**: Use `sudo fdisk -l` or `lsblk` to list all disks and find the correct identifier (e.g., `/dev/sdb`).
2.  **Unmount partitions**: If there are mounted partitions on the device, unmount them first with `sudo umount /dev/sdX1` (replace "1" with the partition number).
3.  **Execute the command**: Type the command carefully, verifying that `sdX` is correct. Use `shred -v` to see progress.

---

**Warning:** These commands cause permanent data loss. Always verify the target device (`/dev/sdX`) before executing.