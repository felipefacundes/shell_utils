# Complete Tutorial: Single-GPU Passthrough to Virtualization

**Remember**: Always back up your configurations before modifying the system! Use Timeshift!

## 📋 Introduction

This tutorial will guide you through the process of setting up **GPU Passthrough** for virtualization on Linux systems. This technique allows you to use your physical graphics card directly in a virtual machine, providing near-native performance.

### ⚠️ Prerequisites and Important Warnings

- **Backup**: Back up your important data before starting
- **Estimated time**: 2-4 hours for the entire process
- **Basic knowledge**: Familiarity with the Linux terminal is recommended
- **Risks**: System modifications can cause instability

---

## 🔍 Step 1: Hardware Verification

### 1.1 Check CPU Virtualization Support

```bash
# Check if the CPU supports virtualization
LC_ALL=c lscpu | grep -i "Virtualization"

# Expected output (one of the options):
# Virtualization: VT-x          # For Intel
# Virtualization: AMD-V         # For AMD
```

**Explanation**: This command checks if your processor has hardware virtualization support, which is essential for GPU passthrough.

### 1.2 Check IOMMU Support

```bash
# Check if IOMMU is enabled in the kernel
dmesg | grep -i "IOMMU"

# For Intel:
dmesg | grep -i "DMAR"

# For AMD:
dmesg | grep -i "IVRS"
```

**Explanation**: IOMMU (Input-Output Memory Management Unit) is required to isolate PCIe devices and allow them to be passed through to VMs.

---

## 🛠️ Step 2: Enable IOMMU at Boot

### 2.1 Edit GRUB Parameters

Open the GRUB configuration file:

```bash
sudo nano /etc/default/grub
```

Locate the line `GRUB_CMDLINE_LINUX_DEFAULT` and add the appropriate parameters:

```bash
# For Intel processors:
GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on iommu=pt"

# For AMD processors:
GRUB_CMDLINE_LINUX_DEFAULT="quiet amd_iommu=on iommu=pt"

# Complete example:
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash intel_iommu=on iommu=pt"
```

**Parameter explanation**:
- `intel_iommu=on` or `amd_iommu=on`: Enables IOMMU support
- `iommu=pt`: Enables "Passthrough" only for devices that will be used in VMs

### 2.2 Update GRUB Configuration

```bash
# Update GRUB configuration
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Reboot the system
sudo reboot
```

---

## 🔎 Step 3: Identify IOMMU Groups

### 3.1 Create IOMMU Verification Script

Create a file called `iommu-group`:

```bash
nano iommu-group
```

Paste the following content:

```bash
#!/usr/bin/env bash

shopt -s nullglob

for g in $(find /sys/kernel/iommu_groups/* -maxdepth 0 -type d | sort -V); do
    echo "IOMMU Group ${g##*/}:"
    for d in $g/devices/*; do
        echo -e "\t$(lspci -nns ${d##*/})"
    done;
done;
```

Make the script executable and run it:

```bash
chmod +x iommu-group
./iommu-group
```

### 3.2 Analyze the Output

**Example of PROBLEMATIC output**:
```
IOMMU Group 2:
    00:01.0 PCI bridge [0604]: Intel Corporation 6th-10th Gen Core Processor PCIe Controller (x16) [8086:1901] (rev 07)
    01:00.0 VGA compatible controller [0300]: NVIDIA Corporation GP107M [GeForce GTX 1050 Ti Mobile] [10de:1c8c] (rev a1)
    01:00.1 Audio device [0403]: NVIDIA Corporation GP107GL High Definition Audio Controller [10de:0fb9] (rev a1)
```

**Problem**: The GPU is in the same group as the PCI bridge, which prevents individual isolation.

**Ideal solution**: Each device should be in its own IOMMU group.

---

## 🆔 Step 4: Identify NVIDIA Devices

### 4.1 Identify GPU IDs

```bash
# Identify all NVIDIA cards
lspci -nn | grep -i "NVIDIA"

# Expected output:
01:00.0 VGA compatible controller [0300]: NVIDIA Corporation GP107M [GeForce GTX 1050 Ti Mobile] [10de:1c8c] (rev a1)
01:00.1 Audio device [0403]: NVIDIA Corporation GP107GL High Definition Audio Controller [10de:0fb9] (rev a1)
```

**Note the IDs**: `10de:1c8c` (GPU) and `10de:0fb9` (Audio)

### 4.2 Add IDs to GRUB

Edit `/etc/default/grub` again:

```bash
sudo nano /etc/default/grub
```

Add the IDs to the existing parameters:

```bash
# Add: vfio-pci.ids=10de:1c8c,10de:0fb9
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash intel_iommu=on iommu=pt vfio-pci.ids=10de:1c8c,10de:0fb9"
```

**Explanation**: This instructs the kernel to load devices with these IDs using the vfio-pci driver.

---

## ⚙️ Step 5: Configure Kernel Modules

### 5.1 Edit mkinitcpio.conf

```bash
sudo nano /etc/mkinitcpio.conf
```

Locate the line `MODULES=` and add:

```bash
MODULES=(vfio_pci vfio vfio_iommu_type1 vfio_virqfd)
```

**Module explanation**:
- `vfio_pci`: Driver for PCIe devices
- `vfio`: Framework for device passthrough
- `vfio_iommu_type1`: Type 1 IOMMU support
- `vfio_virqfd`: Interrupt handling

### 5.2 Additional VFIO Configuration

Create the VFIO configuration file:

```bash
sudo nano /etc/modprobe.d/vfio.conf
```

Add:

```bash
# Force loading NVIDIA devices with vfio-pci
options vfio-pci ids=10de:1c8c,10de:0fb9

# Dependency: load vfio-pci before nvidia
softdep nvidia pre: vfio-pci
softdep nvidia_drm pre: vfio-pci
softdep nvidia_uvm pre: vfio-pci
softdep nvidia_modeset pre: vfio-pci
```

---

## 🚫 Step 6: Block NVIDIA Drivers on Host

### 6.1 Blacklist NVIDIA Driver

Create the blacklist file:

```bash
sudo nano /etc/modprobe.d/blacklist_nvidia.conf
```

Add:

```bash
# Prevent loading NVIDIA drivers on host
blacklist nvidia
blacklist nvidia_drm
blacklist nvidia_modeset
blacklist nvidia_uvm
blacklist nouveau

# Disable modesetting
options nvidia modeset=0
options nvidia_drm modeset=0
```

### 6.2 Blacklist Nouveau (Open Source Driver)

```bash
sudo nano /etc/modprobe.d/blacklist_nouveau.conf
```

Add:

```bash
# Block Nouveau driver
blacklist nouveau
options nouveau modeset=0
```

---

## 🔄 Step 7: Apply Configurations and Reboot

### 7.1 Rebuild Initramfs and GRUB

```bash
# Rebuild initramfs image
sudo mkinitcpio -P

# Update GRUB configuration
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Reboot the system
sudo reboot
```

### 7.2 Verify Configuration After Reboot

```bash
# Check if devices are being managed by vfio-pci
lspci -k | grep -E "vfio-pci|NVIDIA"

# Check IOMMU groups again
./iommu-group

# Check if NVIDIA drivers are blocked
lsmod | grep -E "nvidia|nouveau"
```

---

## 🖥️ Step 8: Configure Virtual Machine

### 8.1 Install Dependencies

```bash
# Install virt-manager and dependencies
sudo pacman -S virt-manager qemu-desktop libvirt edk2-ovmf swtpm

# Enable services
sudo systemctl enable libvirtd
sudo systemctl start libvirtd
sudo systemctl enable virtnetworkd
sudo systemctl start virtnetworkd
```

### 8.2 Configure Network (Optional)

```bash
sudo nano /etc/libvirt/network.conf
```

Add:
```bash
firewall_backend = "iptables"
```

Restart services:
```bash
sudo systemctl restart libvirtd
sudo systemctl restart virtnetworkd

# Configure default network
sudo virsh net-info default
sudo virsh net-autostart default
sudo virsh net-start default
```

---

## 🎮 Step 9: Create Virtual Machine in Virt-Manager

### 9.1 Steps in Virt-Manager

1. **Open Virt-Manager**: `virt-manager`
2. **Create New VM**: Click "Create New Virtual Machine"
3. **Operating System**: Select "Windows 10/11"
4. **Memory**: Recommended 8GB+ for gaming
5. **CPU**: Configure correct topology (sockets/cores)

### 9.2 Special Settings

**Before starting the VM, edit the settings**:

#### Add TPM (For Windows 11):
- **Hardware → Add Hardware → TPM**
- Select "Emulated" and version 2.0

#### Add NVIDIA GPU:
- **Hardware → Add Hardware → PCI Host Device**
- Select both NVIDIA devices:
  - `01:00.0 VGA compatible controller`
  - `01:00.1 Audio device`

#### CPU Settings:
- **CPU → Configuration → Copy host CPU configuration**
- **Topology**: Configure according to your processor

#### Boot Settings:
- **Boot Options → Enable UEFI**
- **SATA Disk 1 → Boot priority**: 1

---

## 💿 Step 10: Windows Installation

### 10.1 VirtIO Drivers

Download VirtIO drivers:
```bash
wget https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso
```

**During Windows installation**:
- When prompted to select disk, click "Load Driver"
- Navigate to the VirtIO ISO and select:
  - `viostor\w11\amd64` (for storage)
  - `NetKVM\w11\amd64` (for network)
  - `vioserial\w11\amd64` (for serial)

### 10.2 Video Drivers and Enhancements

#### Mesa3D (OpenGL):
1. Download: https://github.com/pal1000/mesa-dist-win/releases
2. Extract and run the installer

#### NVIDIA Drivers:
1. Download drivers from NVIDIA official site
2. Install normally

#### WinFSP (File Sharing):
```bash
wget https://github.com/winfsp/winfsp/releases/download/v2.0/winfsp-2.0.23075.msi
```

Install on Windows to enable file sharing via SPICE.

---

## 🛠️ Step 11: Advanced QEMU Script (Alternative)

If you prefer using QEMU directly, create a script:

```bash
nano windows-vm.sh
```

```bash
#!/bin/bash

qemu-system-x86_64 \
  -enable-kvm \
  -machine q35,accel=kvm \
  -cpu host,kvm=on \
  -smp 8,cores=4,threads=2 \
  -m 16G \
  -vga none \
  -device vfio-pci,host=01:00.0,multifunction=on \
  -device vfio-pci,host=01:00.1 \
  -drive file=/path/to/windows.qcow2,format=qcow2 \
  -netdev user,id=net0 \
  -device virtio-net-pci,netdev=net0 \
  -rtc base=localtime \
  -usb -device usb-kbd -device usb-mouse
```

Make executable:
```bash
chmod +x windows-vm.sh
```

---

## 🔧 Step 12: Troubleshooting

### Common Problems:

#### GPU Not Appearing in VM:
```bash
# Check if vfio-pci is controlling the device
lspci -k | grep -A 2 "NVIDIA"

# Check dmesg for errors
dmesg | grep -i "vfio"
```

#### Poor Performance:
- Check if all CPU cores are being used
- Increase allocated memory
- Check if GPU is being utilized 100%

#### Audio Not Working:
- Make sure both devices (GPU and Audio) were passed through
- Install HD audio drivers in VM

### Useful Debug Commands:

```bash
# Check IOMMU status
dmesg | grep -i iommu

# Check IOMMU groups
find /sys/kernel/iommu_groups/ -type l | sort -V

# Check if VFIO is loaded
lsmod | grep vfio

# Monitor GPU performance
nvidia-smi    # On host (if available)
```

## 📚 Additional Resources

Here are some extra resources that may be useful:

### 🔧 **Useful Automated Scripts**

#### **Compatibility Check Script:**
```bash
#!/bin/bash
echo "=== GPU PASSTHROUGH COMPATIBILITY VERIFICATION ==="
echo "1. Checking CPU virtualization..."
egrep -c '(vmx|svm)' /proc/cpuinfo
echo "2. Checking IOMMU..."
dmesg | grep -e "DMAR" -e "IOMMU"
echo "3. Checking IOMMU groups..."
./iommu-group | grep -A 5 -B 5 "NVIDIA"
echo "4. Checking active drivers..."
lspci -k | grep -A 2 -E "(VGA|3D)"
```

#### **Configuration Backup Script:**
```bash
#!/bin/bash
# Backup important configurations
BACKUP_DIR="/home/$USER/gpu-passthrough-backup"
mkdir -p $BACKUP_DIR
sudo cp /etc/default/grub $BACKUP_DIR/
sudo cp /etc/mkinitcpio.conf $BACKUP_DIR/
sudo cp /etc/modprobe.d/* $BACKUP_DIR/
echo "Backup created at: $BACKUP_DIR"
```

### 🚀 **Advanced Optimization Tips**

#### **CPU Pinning (Better Performance):**
```bash
# In virt-manager, edit the VM XML and add:
<vcpu placement='static'>8</vcpu>
<cputune>
    <vcpupin vcpu='0' cpuset='0'/>
    <vcpupin vcpu='1' cpuset='1'/>
    <vcpupin vcpu='2' cpuset='2'/>
    <vcpupin vcpu='3' cpuset='3'/>
    <vcpupin vcpu='4' cpuset='4'/>
    <vcpupin vcpu='5' cpuset='5'/>
    <vcpupin vcpu='6' cpuset='6'/>
    <vcpupin vcpu='7' cpuset='7'/>
</cputune>
```

#### **Hugepages (Optimized Memory):**
```bash
# Add to /etc/default/grub:
GRUB_CMDLINE_LINUX_DEFAULT="... hugepages=2048"

# And execute:
echo 2048 | sudo tee /proc/sys/vm/nr_hugepages
```

### 🆘 **Quick Troubleshooting Guide**

#### **Problem: Black screen in VM**
**Solution:**
```bash
# Check if vfio-pci took control
lspci -k | grep -A 3 "NVIDIA"

# If not, check blacklist
lsmod | grep nvidia
```

#### **Problem: Audio not working**
**Solution:**
- Make sure you passed **both** devices:
  - Graphics card (VGA compatible controller)
  - Card audio (Audio device)

#### **Problem: VM won't start**
**Solution:**
```bash
# Check logs
sudo journalctl -u libvirtd -f

# Check if services are active
sudo systemctl status libvirtd virtnetworkd
```

### 📖 **Recommended Next Steps**

1. **Performance Test**: Run benchmarks like 3DMark or heavy games
2. **Optimize Settings**: Adjust memory and CPU as needed
3. **VM Backup**: Take snapshot of working VM
4. **Sharing**: Configure host↔VM file sharing

### 🎯 **Final Checklist**

- [ ] GPU controlled by vfio-pci
- [ ] NVIDIA drivers installed in VM
- [ ] Audio working
- [ ] Adequate performance
- [ ] Configuration backups
- [ ] Startup scripts (if using QEMU directly)

### 🤝 **Community and Support**

If you encounter problems:
- **Arch Wiki**: Most up-to-date documentation
- **Reddit r/VFIO**: Specialized community
- **Forums**: Level1Techs, Linus Tech Tips

---

## ✅ Conclusion

Congratulations! You have successfully configured single-GPU passthrough. Now you can:

- 🎮 **Play games** with near-native performance
- 🎬 **Edit videos** using GPU acceleration
- 🔬 **Run CUDA applications** in the VM

### Optional Next Steps:

1. **Configure file sharing** via Samba or SPICE
2. **Optimize performance** with CPU pinning
3. **Configure PCIe ACS override** if needed for group separation

### Additional Resources:

- [Arch Linux Wiki - PCI Passthrough](https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF)
- [r/VFIO on Reddit](https://www.reddit.com/r/VFIO/)