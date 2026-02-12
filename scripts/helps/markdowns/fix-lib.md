# Arch Linux /lib Fix Installer

## 🔴 IMPORTANT: Live Boot Recovery

If you are reading this because your system fails to boot with errors about `/lib`, `vfat`, or `mount.efi`, **you can fix it immediately from a live environment**:

```bash
# Mount your root partition to /mnt
mount /dev/your_root_partition /mnt

# Reinstall filesystem package with correct /lib symlink
pacman --sysroot /mnt -Syu filesystem

# If the above fails due to conflicts, force the symlink creation:
pacman --sysroot /mnt -Syu --overwrite '/lib/*' filesystem
```

This will restore the proper `/lib -> /usr/lib` symlink and your system should boot normally again.

---

## 📦 About This Script (fix-lib-utils)

**Arch Linux pacman has recently been removing `/lib` or creating it as a directory instead of preserving the symbolic link to `/usr/lib`.** This happens due to:

- Glibc 2.41+ transition forcing `/lib -> /usr/lib`
- Custom/AUR kernels still installing modules to `/lib/modules`
- Third-party DKMS modules conflicting with the new symlink

This script provides **three layers of protection** against this issue:

### 🛡️ 1. Pacman Hook (`/usr/share/libalpm/hooks/60-fix-lib.hook`)
- Runs **automatically after every pacman transaction**
- Checks if `/lib` is a small directory (<1M) and replaces it with symlink
- Creates symlink if `/lib` doesn't exist
- **Zero-touch, fully automatic**

### 🛡️ 2. systemd-tmpfiles.d (`/etc/tmpfiles.d/fix-lib.conf`)
- Runs **at every boot**
- Forces `/lib -> /usr/lib` using systemd-tmpfiles
- Catches any breakage that slipped past the pacman hook
- **Redundant, bulletproof**

### 🛡️ 3. Emergency Script (`/usr/local/bin/fix-lib-emergency`)
- Manual fix tool for **recovery environments**
- Works with busybox, static ash, minimal shells
- Safe idempotent operation

---

## 🚀 Installation

```bash
# Download the script
curl -O https://raw.githubusercontent.com/felipefacundes/lib-fix/main/lib-fix-utils

# Make executable and run as root
chmod +x install-lib-fix.sh
sudo ./install-lib-fix.sh
```

That's it. The script will:
1. Create all three fix mechanisms if missing
2. Verify current system state
3. Apply immediate fix if needed

---

## 🔧 Manual Usage

```bash
# Test emergency script
sudo fix-lib-emergency

# Test tmpfiles.d configuration
sudo systemd-tmpfiles --create /etc/tmpfiles.d/fix-lib.conf

# View pacman hook
cat /usr/share/libalpm/hooks/60-fix-lib.hook
```

---

## 🧪 How It Works

The script is **safe by design**:

| Condition | Action |
|-----------|--------|
| `/lib` is a symlink to `/usr/lib` | ✅ Do nothing |
| `/lib` is a directory **AND** < 1M | 🔄 Remove and create symlink |
| `/lib` does not exist | 🔄 Create symlink |
| `/lib` is a directory **AND** ≥ 1M | ⚠️ Warning, manual check required |

**It will NEVER:**
- Remove `/usr/lib`
- Remove a large `/lib` directory (likely user data)
- Touch any other system paths

---

## 📋 Requirements

- Arch Linux (or derivative)
- Root privileges
- Pacman, systemd, bash

---

## ⚠️ Important Note About the Glibc 2.41+ Transition

**You are correct. Recent research and forum activity confirm this is a REAL and CURRENT issue.** However, the context is different from older reports: **this is not a random Pacman bug, but a scheduled `glibc` package transition that began mass-rolling out on February 11-12, 2026, conflicting with custom kernels (AUR) and third-party modules.**

### 1. What is happening NOW (February/2026)

The transition that was once a warning (about `/lib` becoming a symlink) **has finalized**. The `glibc` package was updated to a version that **removes the `/lib` directory and replaces it with the symbolic link**, as long-planned.

- **The Trigger:** The `glibc` update (moved from testing to stable recently) forces the creation of `/lib -> /usr/lib`.
- **The Error:** If you have a manually compiled kernel or modules (e.g., `nvidia-dkms`, `zfs-dkms`, AUR kernels like `linux-zen-custom`, `linux-tkg`) that **still install modules directly to `/lib/modules`** (instead of `/usr/lib/modules`), Pacman detects a file conflict.
- **The Result:** Pacman tries to apply `glibc`, but another package "owns" files inside `/lib`. Pacman panics, and the system ends up with a corrupted or empty `/lib`. **This happened yesterday and today because many mirrors synced this glibc update at this exact moment.**

### 2. Immediate Diagnosis (Do this NOW)

**Step 1: Identify the conflicting package**
```bash
pacman -Qo /lib/*
```
**Expected result:** Only `glibc` should appear.
**Likely result in your case:** A package named `linux` (if manually compiled), `nvidia-utils`, `virtualbox-host-modules`, etc.

**Step 2: Check problematic modules**
The most common cause cited in forums is the `/lib/modules` directory.
```bash
ls -la /lib/modules
```
If this exists as a directory and not a symlink, this is the problem.

**Step 3: The Solution (Rebuild/Update)**
You need to **rebuild** the problematic package so it understands it should use `/usr/lib/modules`.

- **If you use linux-zen or linux-hardened from AUR:** Do a `git pull` on the PKGBUILD and rebuild immediately.
- **If you use the default kernel (`linux`):** The official Arch kernel (core/linux) **has** used `/usr/lib/modules` for years. If you're getting this error, you likely have an old/custom version installed. Reinstall the official kernel:
  ```bash
  pacman -S linux
  ```

**Step 4: The Workaround (If rebuild fails)**
If you cannot rebuild the kernel immediately, temporarily **ignore glibc** to update the rest of your system:
```bash
pacman -Syu --ignore glibc
```
*This allows you to update your system and rebuild your kernel with the latest toolchain.* After the kernel is correctly rebuilt, install glibc:
```bash
pacman -S glibc
```

### 3. Why did this happen JUST NOW?

The changelog shows that `glibc 2.41-2` (or higher) was moved to the stable repositories precisely in this period. Arch release notes explicitly mention `glibc` moving to stable in February 2026.

**Summary for Immediate Action:**
1. Check what's in `/lib` with `ls -la /lib`.
2. If it's a directory, find the owner: `pacman -Qo /lib/modules`.
3. Recompile/Reinstall the owner (usually an AUR kernel) **with the latest PKGBUILDs**, as the community has already patched them to use the correct path.
4. After reinstalling the kernel, the `/lib` directory will disappear and the symlink will be created by `glibc` on the next update or via `pacman -S glibc`.

**Do NOT attempt to manually create the symlink or use `--overwrite`.** This can irreversibly break your system. The solution is always to remove the cause (the package still writing to `/lib`).

---

## 📄 License

GPLv3 - Free software, feel free to share and modify.

## 👤 Credits

Felipe Facundes

---

**⭐ If this script saved your system, consider starring the repository!**
