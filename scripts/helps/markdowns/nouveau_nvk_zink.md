# Educational Tutorial: Configuration of Nouveau + NVK on Arch Linux

![Nouveau + NVK](https://via.placeholder.com/800x200/4A90E2/FFFFFF?text=Nouveau+%2B+NVK+-+Open+Source+Drivers+for+NVIDIA+on+Linux)

## 📚 Educational Index

1. [🎯 Conceptual Introduction](#-conceptual-introduction)
2. [🏗️ Driver Architecture](#️-driver-architecture)
3. [🔍 Prerequisites and Checks](#-prerequisites-and-checks)
4. [🛠️ Step-by-Step Configuration](#️-step-by-step-configuration)
5. [🧪 Testing and Validation](#-testing-and-validation)
6. [🐛 Educational Troubleshooting](#-educational-troubleshooting)
7. [📖 Concepts Glossary](#-concepts-glossary)

## 🎯 Conceptual Introduction

### What is This Driver Stack?

Imagine your NVIDIA video card is a **musical orchestra**:

- **Nouveau** = The **musicians** (controls the hardware directly)
- **NVK** = The **modern conductor** (Vulkan - manages resources efficiently)
- **Zink** = The **musical translator** (converts OpenGL to Vulkan)

### 🤔 Why Use This Stack?

| Scenario | Recommendation |
|---------|-------------|
| **Pure Free Software** | ✅ Ideal |
| **Development** | ✅ Excellent |
| **Modern games** | ⚠️ Limited (better on Turing+) |
| **Machine Learning** | ❌ Not recommended |
| **Study/Academic** | ✅ Perfect |

## 🏗️ Driver Architecture

### Conceptual Diagram

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   APPLICATION   │    │   MESA (NVK)    │    │    KERNEL       │
│                 │    │                 │    │                 │
│  ┌─────────────┐│    │  ┌─────────────┐│    │  ┌─────────────┐│
│  │   Vulkan    │├─────►│  NVK Driver  │├─────►│   Nouveau    ││
│  └─────────────┘│    │  └─────────────┘│    │  └─────────────┘│
│                 │    │                 │    │                 │
│  ┌─────────────┐│    │  ┌─────────────┐│    │                 │
│  │   OpenGL    │├─────►│   Zink       ││    │                 │
│  └─────────────┘│    │  └─────────────┘│    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Component Explanation

#### 1. **Nouveau** - The Kernel Driver
```bash
# What does it do?
# ↔️ Direct communication with GPU hardware
# 🖥️ Provides basic display support
# 🔧 Implemented as Linux kernel module

# Check if it's loaded:
lsmod | grep nouveau
```

#### 2. **NVK** - The Modern Vulkan Driver
```bash
# Main characteristics:
# ⚡ Vulkan 1.4 API (conformant)
# 🆓 Open source (developed by Collabora)
# 🔄 Runs on top of Nouveau

# Check support:
vulkaninfo | grep -i "deviceName"
```

#### 3. **Zink** - The OpenGL Translator
```bash
# Function: Converts OpenGL calls → Vulkan
# Why? Reuses NVK driver for OpenGL
# Advantage: Maintainability and performance

# Check operation:
glxinfo | grep "OpenGL renderer"
```

## 🔍 Prerequisites and Checks

### 1. ✅ Check Supported Hardware

```bash
# Find out which NVIDIA GPU you have
lspci | grep -i nvidia

# Example output:
# 01:00.0 VGA compatible controller: NVIDIA Corporation GA106 [GeForce RTX 3060]
```

**Compatibility Table:**

| Architecture | Series | NVK Support | Performance |
|-------------|-------|-------------|-------------|
| **Kepler** | GTX 600/700 | ✅ Good | ⚡ Good |
| **Maxwell** | GTX 900 | ✅ Regular | 🐢 Limited* |
| **Pascal** | GTX 1000 | ✅ Regular | 🐢 Limited* |
| **Turing** | GTX 16xx/RTX 20xx | ✅ Excellent | ⚡ Great |
| **Ampere** | RTX 30xx | ✅ Excellent | ⚡ Great |
| **Ada Lovelace** | RTX 40xx | ✅ Excellent | ⚡ Great |

> **💡 Educational Note**: *Maxwell and Pascal cards have limited performance due to lack of **reclocking** support in Nouveau. They only operate at minimum frequencies.

### 2. 🔄 Check Current Drivers

```bash
# Check if proprietary NVIDIA drivers are present
lsmod | grep nvidia

# Check installed NVIDIA packages
pacman -Qs nvidia

# Check if Nouveau is available
lsmod | grep nouveau
```

## 🛠️ Step-by-Step Configuration

### 📋 Pre-configuration Checklist

- [ ] Backup of important data
- [ ] Stable internet connection
- [ ] Estimated time: 15-30 minutes
- [ ] Terminal access as normal user (not root)

### 🚀 Step 1: Remove Conflicts (If Necessary)

```bash
# 💀 DANGER: This step is only necessary if you have NVIDIA drivers installed
# ❌ DO NOT run if you already use Nouveau or if you don't have NVIDIA drivers

# List NVIDIA packages to remove
pacman -Qs nvidia

# Remove proprietary NVIDIA drivers
sudo pacman -Rs nvidia nvidia-utils nvidia-settings nvidia-dkms

# Clean up any residual configuration files
sudo rm -f /etc/modprobe.d/nvidia*
```

### 🎯 Step 2: Configure NVIDIA Drivers Blacklist

```bash
# Create blacklist file to prevent conflicts
sudo nano /etc/modprobe.d/blacklist-nvidia.conf
```

**File content:**
```bash
# 🚫 BLACKLIST FOR NVIDIA DRIVERS
# Configured to allow Nouveau/NVK operation
# Educational file - understanding each line:

# "blacklist" = prevents automatic module loading
blacklist nvidia
blacklist nvidia_drm
blacklist nvidia_modeset
blacklist nvidia_uvm

# "alias" = defines aliases that disable the modules
alias nvidia off
alias nvidia_drm off
alias nvidia_modeset off
alias nvidia_uvm off

# 💡 Explanation: These commands ensure the kernel
# doesn't try to load NVIDIA drivers, preventing
# conflicts with Nouveau.
```

### 🔧 Step 3: Configure Nouveau Module in the Kernel

```bash
# Edit mkinitcpio configuration
sudo nano /etc/mkinitcpio.conf
```

**Locate the MODULES= line and modify:**
```bash
# 🔧 BEFORE (possibly):
# MODULES=()

# 🎯 AFTER (configure like this):
MODULES=(nouveau)

# 💡 Pedagogical explanation:
# mkinitcpio creates the initramfs image - a mini-system
# that is loaded during boot. By including "nouveau" in
# MODULES, we ensure the driver is loaded early in the
# boot process, even before the main system.
```

### 🏗️ Step 4: Rebuild Initramfs

```bash
# Rebuild the boot image
sudo mkinitcpio -P

# 💡 What's happening?
# 1. The system reads /etc/mkinitcpio.conf
# 2. Creates a new initramfs with the Nouveau module
# 3. Updates all available kernel images
```

### 📦 Step 5: Install Necessary Packages

```bash
# Update system first
sudo pacman -Syu

# Install open source graphics stack
sudo pacman -S --needed \
    mesa \             # Open source graphics drivers
    xf86-video-nouveau \ # Xorg driver for Nouveau
    vulkan-icd-loader \  # Vulkan loader
    lib32-mesa \       # 32-bit support (for compatibility)
    vulkan-tools \     # Tools to test Vulkan
    mesa-demos         # Tools to test OpenGL

# 💡 Educational note about each package:
# - mesa: Contains DRI (Direct Rendering Infrastructure) drivers
# - xf86-video-nouveau: 2D/X11 driver for Nouveau
# - vulkan-icd-loader: Allows multiple Vulkan drivers to coexist
# - lib32-mesa: 32-bit application support (important for games via Wine)
```

### 🔄 Step 6: Restart the System

```bash
# Restart to apply all changes
sudo reboot

# 💡 Why do we need to restart?
# 1. New kernel modules need to be loaded
# 2. Updated initramfs is only used on next boot
# 3. Xorg/Wayland server needs to reload with new configuration
```

## 🧪 Testing and Validation

### 1. ✅ Verify Loaded Modules

```bash
# Check if Nouveau is loaded correctly
lsmod | grep nouveau

# Expected output:
# nouveau              3399680  0
# mxm_wmi                16384  1 nouveau
# i2c_algo_bit           16384  1 nouveau
# drm_ttm_helper         16384  1 nouveau
# ttm                    86016  2 nouveau,drm_ttm_helper
# drm_display_helper    184320  1 nouveau
# drm_kms_helper        200704  2 nouveau,drm_display_helper
# drm                   589824  6 nouveau,drm_kms_helper,drm_display_helper,ttm,drm_ttm_helper
```

### 2. 🎯 Test Vulkan Support (NVK)

```bash
# Check available Vulkan devices
vulkaninfo --summary

# Look for "nvk" or "nouveau" in the output
# Example of successful output:
# ==========
# VULKANINFO
# ==========
# Vulkan Instance Version: 1.3.268
# ...
# GPU0:
#   apiVersion         = 1.4.285
#   driverVersion      = 1.0.0
#   vendorID           = 0x10de
#   deviceID           = 0x2684
#   deviceType         = PHYSICAL_DEVICE_TYPE_DISCRETE_GPU
#   deviceName         = NVIDIA GeForce RTX 3060 (NVK)
#   driverID           = DRIVER_ID_MESA_RADV
```

### 3. 🖥️ Test OpenGL Support (Zink)

```bash
# Check OpenGL renderer
glxinfo | grep -E "OpenGL vendor|OpenGL renderer"

# Expected output with Zink:
# OpenGL vendor string: Mesa
# OpenGL renderer string: AMD Radeon Graphics (RADV NAVI23) 
# 💡 Note: May show RADV because Zink uses the Vulkan backend
```

### 4. 🎮 Practical Test with Application

```bash
# Test with a simple Vulkan application
vkcube

# If a colored rotating 3D cube appears: 🎉 SUCCESS!
# This demonstrates that the entire stack is working:
# Nouveau (kernel) → NVK (Vulkan) → Mesa (userspace)
```

## 🐛 Educational Troubleshooting

### ❌ Problem: "Nouveau doesn't load after reboot"

**Symptoms:**
```bash
lsmod | grep nouveau  # Returns nothing
dmesg | grep nouveau  # Shows errors
```

**Possible solutions:**

1. **Check blacklist:**
```bash
# Check if Nouveau wasn't blacklisted by mistake
grep -r "blacklist nouveau" /etc/modprobe.d/
```

2. **Check modules in mkinitcpio:**
```bash
# Confirm Nouveau is in the modules list
grep "MODULES" /etc/mkinitcpio.conf
```

3. **Reload modules manually:**
```bash
# Try to load the module manually for debug
sudo modprobe nouveau
dmesg | tail -20  # Check kernel messages
```

### ❌ Problem: "NVK doesn't appear in vulkaninfo"

**Symptoms:**
```bash
vulkaninfo | grep -i nvk  # Finds nothing
```

**Solutions:**

1. **Check Mesa version:**
```bash
# NVK requires Mesa 23.3+ for basic support
pacman -Qi mesa | grep Version
```

2. **Check environment variables:**
```bash
# Sometimes it's necessary to force NVK
export MESA_LOADER_DRIVER_OVERRIDE=nvk
vulkaninfo --summary
```

### ❌ Problem: "Very low performance on old GPUs"

**Technical explanation:**
```bash
# Maxwell (GTX 900) and Pascal (GTX 1000) don't have
# reclocking support in Nouveau, operating at
# minimum frequencies (boot clocks)

# Check current frequency (if supported):
cat /sys/class/drm/card0/device/clock_gpus
```

**Limited solutions:**
```bash
# Some GPUs may accept manual frequency commands
echo "performance" | sudo tee /sys/class/drm/card0/device/power_dpm_force_performance_level

# 💡 Note: This is experimental and doesn't work on all GPUs
```

## 📖 Concepts Glossary

### 🏗️ Technical Architecture

| Term | Pedagogical Definition |
|-------|---------------------|
| **DRM** | Direct Rendering Manager - kernel subsystem for graphics |
| **KMS** | Kernel Mode Setting - video mode configuration in the kernel |
| **GBM** | Generic Buffer Management - graphics buffer management |
| **Vulkan** | Modern and efficient graphics API (OpenGL successor) |
| **ICD** | Installable Client Driver - how multiple Vulkan drivers coexist |

### 🔧 Specific Components

| Component | Function | Analogy |
|------------|--------|----------|
| **Nouveau** | Kernel driver for NVIDIA | 🚗 Car engine |
| **NVK** | Open source Vulkan driver | 🎮 Modern onboard computer |
| **Zink** | OpenGL layer on top of Vulkan | 🗣️ Simultaneous translator |
| **Mesa** | Open source implementation of graphics APIs | 🏭 Graphics factory |

### 🎯 Useful Diagnostic Commands

```bash
# Complete graphics stack diagnosis
lspci -k | grep -A 2 -i vga           # Hardware and drivers
lsmod | grep -e nouveau -e nvidia     # Loaded modules
dmesg | grep -i nouveau               # Driver logs
glxinfo | grep -i "opengl version"    # OpenGL version
vulkaninfo --summary                  # Vulkan summary
```

## 🎓 Educational Conclusion

### ✅ What We Learned:

1. **Graphics driver architecture** in Linux
2. **Difference between kernel space and user space**
3. **Relationship between Nouveau, NVK and Zink**
4. **Kernel module configuration process**
5. **Systematic troubleshooting techniques**

### 🔮 Next Steps for Learning:

- Explore graphics APIs (Vulkan vs OpenGL)
- Learn about GPGPU computing with open source
- Study Nouveau/NVK source code
- Contribute to open source graphics projects

### 📚 Additional Resources

- [Official Nouveau documentation](https://nouveau.freedesktop.org/)
- [NVK repository on GitLab](https://gitlab.freedesktop.org/nouveau/mesa/)
- [Arch Linux Wiki about Nouveau](https://wiki.archlinux.org/title/Nouveau)
- [Collabora blog about NVK](https://www.collabora.com/news-and-blog/blog/)

---

**🎉 Congratulations!** You not only configured an open source graphics stack, but also understood the concepts behind each component. This knowledge is fundamental to becoming an advanced Linux user!