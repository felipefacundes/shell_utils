# Arch Linux Swap File Setup Guide

To activate a **swap** area in Arch Linux, you can create a swap file. This is a flexible solution that does not require disk partitioning.

Here are the main steps:

1.  **Create the file**: Use the `fallocate` command to create a file on the filesystem. For example, to create a **4 GB** file in the root directory (`/`):
    ```bash
    sudo fallocate -l 4G /swapfile
    ```
    *   If `fallocate` has issues, you can use the `dd` command as an alternative.

    ```bash
    sudo dd if=/dev/zero of=/swapfile bs=4M count=1024 oflag=direct,dsync status=progress && sync
    ```

2.  **Adjust permissions**: For security, restrict access to the file so that only the **root** user can read and write to it:
    ```bash
    sudo chmod 600 /swapfile
    ```

3.  **Format as swap**: Prepare the file to be used as a swap area:
    ```bash
    sudo mkswap /swapfile
    ```

4.  **Activate swap**: Make the swap file available for the system to use immediately:
    ```bash
    sudo swapon /swapfile
    ```

5.  **Make activation permanent**: To have swap activated automatically on every boot, add a line to the `/etc/fstab` file. Use a text editor like `nano` or `vim`:
    ```bash
    sudo nano /etc/fstab
    ```
    Add the following line at the end of the file:
    ```
    /swapfile none swap defaults 0 0
    ```
    Save and close the editor.

### How to verify if swap is active
After following the steps, verify if swap is working with one of these commands:
*   `swapon --show` (shows active swap devices)
*   `free -h` (shows memory and swap usage in a human-readable format)

### 💡 Important considerations
*   **Swap size**: A common size is equal to the amount of **RAM** in the system (e.g., 16 GB of RAM = 16 GB of swap). If you have a lot of RAM (e.g., 32 GB), you can use less.
*   **Hibernation (suspend-to-disk)**: If you plan to use **hibernation**, the swap file (or partition) must have a size **at least equal to your total RAM**. Configuring hibernation involves additional adjustments in the bootloader (like GRUB).
*   **Swap vs. RAM**: Swap is useful for preventing crashes when RAM is exhausted and for giving the kernel more flexibility in memory management. However, it is much slower than RAM. If your system constantly uses swap, the best solution is to increase physical memory.
*   **Disabling swap**: If necessary, you can deactivate everything with `sudo swapoff -a` and then remove the corresponding line from the `/etc/fstab` file.

### 🔍 What about other methods (zram, zswap)?
The search results mention modern alternatives:
*   **zram**: Creates a swap device **compressed in RAM itself**, increasing effective memory. It's a good option for systems with limited RAM, but **cannot be used for hibernation** as data is lost on shutdown.
*   **zswap**: Acts as a **compressed cache layer** for physical swap (file or partition). The kernel tries to compress memory pages before sending them to disk, which can improve performance. Generally, you do **not use zram and zswap at the same time**, as they are redundant.

Which method do you intend to use? If you tell me a bit about your configuration (amount of RAM and if you need hibernation), I can give more specific recommendations.

---

# Configure Swap to Activate Only as a Last Resort

To make **swap activate only as a last resort**, you need to adjust the **"swappiness" parameter**, which controls the kernel's willingness to use the swap area instead of RAM. In Arch Linux, the default value is `60` (on a scale of 0-100), meaning the kernel will start using swap when about **40% of RAM is free**.

## 🎯 Step 1: Check current swappiness
```bash
cat /proc/sys/vm/swappiness
```
If it shows `60`, the system is configured to use swap relatively early.

## 📉 Step 2: Reduce swappiness (recommended: 10-20)
A low value (e.g., `10`) makes the kernel use swap **only when really necessary**:
```bash
# Change temporarily (valid until restart)
sudo sysctl vm.swappiness=10

# Change permanently
echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.d/99-swappiness.conf
```
- **10-20**: Ideal for desktops/servers with sufficient RAM
- **1-5**: Only in extreme emergencies (may trigger OOM killer)
- **60**: Default for Arch/Ubuntu
- **80**: Database servers

## 🔄 Step 3: Also adjust file cache (vfs_cache_pressure)
Another important parameter that affects memory behavior:
```bash
# Reduce so the kernel retains more file cache (default=100)
sudo sysctl vm.vfs_cache_pressure=50
echo "vm.vfs_cache_pressure=50" | sudo tee -a /etc/sysctl.d/99-swappiness.conf
```
Lower value (50) = kernel keeps more cache in RAM = less need for swap.

## ✅ Step 4: Verify adjustments
```bash
# Reload configurations
sudo sysctl --system

# Check current values
cat /proc/sys/vm/swappiness
cat /proc/sys/vm/vfs_cache_pressure
```

## 📊 Step 5: Monitor real usage
After adjusting, monitor how the system behaves:
```bash
# Check memory/swap usage
free -h

# Monitor in real-time (Ctrl+C to exit)
watch -n 1 "free -h | grep -E 'total|Mem|Swap'"

# More detailed alternative
htop  # or top (press 'M' to sort by RAM usage)
```

## 🛠️ Additional considerations

### ⚡ **For SSD/NVMe systems**
If your swap is on an SSD, low swappiness is even more effective - fast swap doesn't degrade performance as much when used.

### 🌙 **Hibernation with low swappiness**
If you use hibernation (`suspend-to-disk`):
1. Low swappiness **does not interfere** with hibernation
2. The system will still copy all RAM to swap when hibernating
3. Just make sure the swap is **at least the size of your RAM**

### ⚠️ **Signs the value is too low**
If you start seeing:
- Applications closing abruptly (OOM killer)
- System freezing when RAM is full
- `out of memory` messages in logs (`journalctl -k`)

In this case, gradually increase to `15` or `20`.

### 🔄 **Practical test**
To test how your system responds:
1. Open several heavy applications (browser with many tabs, virtualization, etc.)
2. Use `free -h` or `htop` to see if swap is being used
3. With `swappiness=10`, swap should only appear when RAM is >90% used

**Do you already have swap configured as a file or partition?** If you want to check, run `swapon --show` - this helps me give more precise recommendations about the ideal size considering your usage.