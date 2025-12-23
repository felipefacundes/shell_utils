# 🚀 Tutorial: Create Windows To Go from VirtualBox on Linux

This tutorial uses your exact commands that worked, explaining each step to ensure other users have the same success.

## 📋 Prerequisites

- VirtualBox installed (tested on version 7.2.4)
- Windows VM installed and configured (tested with "Win10_22H2...x64")
- Pendrive/external SSD with capacity larger than the VM size
- Linux installed on the host computer

## 🔍 Step 1: Identify the Destination Unit

**EXTREME CAUTION:** This command will show ALL system disks. Choosing the wrong unit can ERASE YOUR OPERATING SYSTEM.

```bash
sudo fdisk -l
```

**How to identify your pendrive:**
- Observe the device size (ex: 64G, 128G, 1T)
- Check the model/manufacturer
- Normally appears as `/dev/sdX` (where X is a letter like b, c, d)
- **SAFE EXAMPLE:** If your system is on `/dev/sda`, the pendrive will be `/dev/sdb` or `/dev/sdc`

## 💽 Step 2: Convert VDI to IMG

Enter the folder where your `.vdi` file is located and execute:

```bash
VBoxManage internalcommands converttoraw Win10.vdi Win10.img
```

**Why without sudo?**
- VirtualBox already has the necessary permissions
- Therefore there's no need to use sudo (for root permissions)
- Avoids file ownership problems
- Keeps the `.img` file accessible for your user

## ⚡ Step 3: Cloning with Maximum Optimization

Use the command:

```bash
sudo dd if=Win10.img of=/dev/sdX oflag=direct,dsync conv=fsync bs=1M status=progress
```

## 🔧 Detailed Explanation of dd Command Flags

### **`oflag=direct,dsync`**
- **`direct`**: Ignores system cache, writing DIRECTLY to the device
- **`dsync`**: Synchronizes each I/O operation - guarantees data was physically written

### **`conv=fsync`**
- Synchronizes filesystem metadata after transfer
- Guarantees partition table and critical structures are committed

### **`bs=1M`**
- **Block Size = 1 Megabyte**: Optimizes transfer using larger blocks
- More efficient than default (512 bytes or 4K)

### **`status=progress`**
- Shows progress in real time
- Displays transfer speed and elapsed time

## 🎯 Why This Combination Works Better?

**For USB/external SSD devices:**
- `direct` + `dsync` prevents corruption from poorly managed cache
- `bs=1M` is ideal for high-speed devices
- The combination guarantees **total data integrity**

## ⏱️ Expected Time

Depending on image size and USB speed:
- USB 3.0: 10-30 minutes for 32GB
- External SSD: 5-15 minutes for 32GB

## ✅ Post-Processing

After completion:
1. **Wait for the prompt to return** - don't disconnect before!
2. **Execute sync to guarantee:** `sync`
3. **Safely eject:** `sudo eject /dev/sdX`

## 🚨 Additional Security Tips

1. **Disconnect other USBs** before starting
2. **Verify 3x** the `/dev/sdX` device
3. **Have backup** of important data
4. **Use `lsblk`** for additional device confirmation