# Complete Tutorial: Single-GPU to Virtualization GPU Passthrough

**Remember**: Always backup your system before making changes! Use Timeshift!

## 📋 Introduction

This tutorial will guide you through the process of configuring **GPU Passthrough** for virtualization on Linux systems. This technique allows you to use your physical graphics card directly in a virtual machine, providing near-native performance.

### ⚠️ Prerequisites and Important Warnings

- **Backup**: Backup your important data before starting
- **Estimated time**: 2-4 hours for the entire process
- **Basic knowledge**: Familiarity with Linux terminal is recommended
- **Risks**: System modifications can cause instability
- **Hardware**: Two GPUs are recommended (one for host, one for VM)
- **System**: Tested on Arch Linux, Ubuntu 20.04+, Fedora 35+

---

## 🔍 Step 1: Hardware Verification

### 1.1 Check CPU Virtualization Support

```bash
# Check if CPU supports virtualization
LC_ALL=c lscpu | grep -i "Virtualization"

# Check virtualization extensions
egrep -c '(vmx|svm)' /proc/cpuinfo

# Expected output (should be > 0):
# 8
```

**Explanation**: VMX (Intel) and SVM (AMD) are the required hardware virtualization extensions.

### 1.2 Check IOMMU Support

```bash
# Check if IOMMU is enabled in the kernel
dmesg | grep -i "IOMMU"

# For Intel:
dmesg | grep -e "DMAR" -e "IOMMU"

# For AMD:
dmesg | grep -e "IVRS" -e "IOMMU"

# Check if IOMMU is active
sudo dmesg | grep -i "IOMMU enabled"
```

**Explanation**: IOMMU (Input-Output Memory Management Unit) is required for PCIe device isolation.

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

# With ACS override (if needed for IOMMU group separation):
GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on iommu=pt pcie_acs_override=downstream,multifunction"

# Complete example:
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash intel_iommu=on iommu=pt vfio-pci.ids=10de:1c8c,10de:0fb9"
```

**Parameter explanation**:
- `intel_iommu=on` or `amd_iommu=on`: Enables IOMMU support
- `iommu=pt`: Enables "Passthrough" only for devices that will be used in VMs
- `pcie_acs_override`: Forces IOMMU group separation (use with caution)

### 2.2 Update GRUB Configuration

```bash
# For systems with traditional GRUB:
sudo grub-mkconfig -o /boot/grub/grub.cfg

# For systems with systemd-boot (Arch Linux):
sudo bootctl update

# For systems with EFI Stub:
sudo update-grub

# Reboot the system
sudo reboot
```

---

## 🔎 Step 3: Identify IOMMU Groups

### 3.1 Advanced IOMMU Verification Script

Create a file called `iommu_groups.sh`:

```bash
nano iommu_groups.sh
```

Paste the following content:

```bash
#!/bin/bash
shopt -s nullglob
for g in $(find /sys/kernel/iommu_groups/* -maxdepth 0 -type d | sort -V); do
    echo "IOMMU Group ${g##*/}:"
    for d in $g/devices/*; do
        echo -e "\t$(lspci -nns ${d##*/})"
    done;
done;
```

### 3.2 Passthrough Compatibility Check Script

Also create `check_passthrough.sh`:

```bash
nano check_passthrough.sh
```

```bash
#!/bin/bash
echo "=== GPU PASSTHROUGH COMPATIBILITY VERIFICATION ==="
echo ""
echo "1. CPU Virtualization:"
egrep -c '(vmx|svm)' /proc/cpuinfo
echo ""
echo "2. IOMMU Support:"
dmesg | grep -e "DMAR" -e "IOMMU" | head -5
echo ""
echo "3. IOMMU Groups (only groups with important devices):"
./iommu_groups.sh | grep -E "(VGA|Audio|USB|NVMe)" -A 2 -B 2
echo ""
echo "4. Active GPU drivers:"
lspci -k | grep -A 2 -E "(VGA|3D)"
```

Make the scripts executable:
```bash
chmod +x iommu_groups.sh check_passthrough.sh
./check_passthrough.sh
```

---

## 🆔 Step 4: Identify NVIDIA Devices

### 4.1 Complete Device Identification

```bash
# Identify all NVIDIA cards
lspci -nn | grep -i "NVIDIA"

# Identify with more details
lspci -vnn | grep -A 10 -i "NVIDIA"

# Expected output:
01:00.0 VGA compatible controller [0300]: NVIDIA Corporation GP107M [GeForce GTX 1050 Ti Mobile] [10de:1c8c] (rev a1)
01:00.1 Audio device [0403]: NVIDIA Corporation GP107GL High Definition Audio Controller [10de:0fb9] (rev a1)
```

### 4.2 GPU ID Backup Script

```bash
nano backup_gpu_ids.sh
```

```bash
#!/bin/bash
echo "Backup of GPU IDs:"
lspci -nn | grep -i "NVIDIA" | tee gpu_ids_backup.txt
echo "IDs saved in gpu_ids_backup.txt"
```

---

## ⚙️ Step 5: Configure Kernel Modules

### 5.1 Advanced Initramfs Configuration

```bash
sudo nano /etc/mkinitcpio.conf
```

**Recommended configuration**:
```bash
MODULES=(vfio_pci vfio vfio_iommu_type1 vfio_virqfd)
BINARIES=()
FILES=()
HOOKS=(base systemd autodetect modconf kms keyboard sd-vconsole block filesystems fsck)
```

**For systems with early loading**:
```bash
# Add your specific GPU IDs to MODULES
MODULES=(vfio_pci vfio vfio_iommu_type1 vfio_virqfd nvidia nvidia_modeset nvidia_drm nvidia_uvm)
```

### 5.2 VFIO Configuration

Create multiple configuration files for better organization:

```bash
# Main VFIO configuration
sudo nano /etc/modprobe.d/vfio.conf
```
```bash
options vfio-pci ids=10de:1c8c,10de:0fb9
options vfio-pci disable_vga=1
```

```bash
# Dependency configuration
sudo nano /etc/modprobe.d/vfio_dependencies.conf
```
```bash
softdep nvidia pre: vfio-pci
softdep nvidia_drm pre: vfio-pci
softdep nvidia_modeset pre: vfio-pci
softdep nouveau pre: vfio-pci
```

---

## 🚫 Step 6: Block NVIDIA Drivers on Host

### 6.1 Complete Blacklist

```bash
sudo nano /etc/modprobe.d/blacklist_nvidia.conf
```

```bash
# Block proprietary NVIDIA drivers
blacklist nvidia
blacklist nvidia_drm
blacklist nvidia_modeset
blacklist nvidia_uvm
blacklist nvidia_current
blacklist nvidia_current_drm
blacklist nvidia_current_modeset

# Block Nouveau
blacklist nouveau
options nouveau modeset=0

# Disable modesetting
options nvidia modeset=0
options nvidia_drm modeset=0
options nvidia_modeset modeset=0
```

### 6.2 Xorg Configuration (if using X11)

```bash
sudo nano /etc/X11/xorg.conf.d/10-gpu-passthrough.conf
```

```bash
Section "Device"
    Identifier "IntelGPU"
    Driver "intel"  # or "amdgpu" for AMD
    BusID "PCI:0:2:0"  # Adjust according to your hardware
EndSection
```

---

## 🔄 Step 7: Apply Configuration and Reboot

### 7.1 Complete Update Procedure

```bash
# 1. Rebuild initramfs with verification
sudo mkinitcpio -P

# 2. Check if modules were included
lsinitcpio /boot/initramfs-linux.img | grep vfio

# 3. Update GRUB
sudo grub-mkconfig -o /boot/grub/grub.cfg

# 4. Update systemd-boot (if applicable)
sudo bootctl update

# 5. Reboot
sudo reboot
```

### 7.2 Post-Reboot Verification

```bash
# Post-reboot verification script
nano verify_passthrough.sh
```

```bash
#!/bin/bash
echo "=== POST-REBOOT VERIFICATION ==="
echo ""
echo "1. VFIO modules loaded:"
lsmod | grep vfio
echo ""
echo "2. Devices controlled by VFIO:"
lspci -k | grep -A 3 -E "(NVIDIA|AMD)" | grep -E "(Kernel driver in use|vfio-pci)"
echo ""
echo "3. Blocked NVIDIA drivers:"
lsmod | grep -E "(nvidia|nouveau)" || echo "No NVIDIA drivers loaded - OK"
echo ""
echo "4. IOMMU Groups:"
./iommu_groups.sh | grep -A 3 -B 1 "NVIDIA"
```

---

## 🖥️ Step 8: Configure Virtual Machine

### 8.1 Complete Dependency Installation

**For Arch Linux**:
```bash
sudo pacman -S virt-manager qemu-desktop libvirt edk2-ovmf swtpm dnsmasq ebtables
```

**For Ubuntu/Debian**:
```bash
sudo apt install qemu-kvm qemu-utils libvirt-daemon-system libvirt-clients bridge-utils virt-manager ovmf
```

**For Fedora**:
```bash
sudo dnf install @virtualization virt-manager edk2-ovmf swtpm-tools
```

### 8.2 Libvirt Configuration

```bash
# Add user to groups
sudo usermod -a -G libvirt $USER
sudo usermod -a -G kvm $USER

# Configure service
sudo systemctl enable libvirtd
sudo systemctl start libvirtd
sudo systemctl enable virtlogd.socket
sudo systemctl start virtlogd.socket

# Configure default network
sudo virsh net-autostart default
sudo virsh net-start default
```

### 8.3 Advanced Network Configuration

```bash
sudo nano /etc/libvirt/qemu.conf
```

Uncomment or add:
```bash
user = "your_username"
group = "libvirt"
security_driver = "none"
```

---

## 🎮 Step 9: Create Virtual Machine in Virt-Manager

### 9.1 Detailed Steps in Virt-Manager

1. **Open Virt-Manager**: `virt-manager`
2. **Create New VM**: Click "Create New Virtual Machine"
3. **Important**: Check "Customize configuration before install"
4. **Operating System**: Select "Windows 10/11"

### 9.2 Optimized Hardware Settings

**Before starting the VM, edit the settings**:

#### CPU (Crucial for Performance):
```xml
<cpu mode='host-passthrough' check='none'>
  <topology sockets='1' dies='1' cores='4' threads='2'/>
  <feature policy='require' name='topoext'/>
</cpu>
```

#### Memory:
- Allocate at least 8GB for gaming
- Check "Enable shared memory"

#### TPM (For Windows 11):
- **Hardware → Add Hardware → TPM**
- Type: Emulated
- Version: 2.0
- Model: crb

#### NVIDIA GPU:
- **Hardware → Add Hardware → PCI Host Device**
- Select both NVIDIA devices
- **Important**: Check "All functions" if available

#### Additional Settings:
```xml
<features>
  <acpi/>
  <apic/>
  <hyperv mode='custom'>
    <relaxed state='on'/>
    <vapic state='on'/>
    <spinlocks state='on' retries='8191'/>
    <vpindex state='on'/>
    <synic state='on'/>
    <stimer state='on'/>
    <reset state='on'/>
    <frequencies state='on'/>
  </hyperv>
  <vmport state='off'/>
  <ioapic driver='kvm'/>
</features>
```

---

## 💿 Step 10: Windows Installation

### 10.1 Optimized VirtIO Drivers

**Download latest drivers**:
```bash
# Method 1: Fedora (official)
wget https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso

# Method 2: GitHub (more updated)
wget https://github.com/virtio-win/virtio-win-pkg-scripts/blob/master/README.md
```

**Driver installation order**:
1. `viostor\w11\amd64` - Storage controllers
2. `NetKVM\w11\amd64` - Virtio network
3. `vioserial\w11\amd64` - Serial port
4. `viorng\w11\amd64` - Random number generator
5. `Balloon\w11\amd64` - Memory balloon

### 10.2 Windows Optimizations

#### Disable Unnecessary Services:
```powershell
# Run as Administrator
Disable-WindowsOptionalFeature -Online -FeatureName "WindowsMediaPlayer"
Disable-WindowsOptionalFeature -Online -FeatureName "WorkFolders-Client"
Disable-WindowsOptionalFeature -Online -FeatureName "Printing-PrintToPDFServices-Features"
```

#### Configure Power Plans:
```powershell
powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c  # High performance
```

#### Specific Drivers for NVIDIA in VM:
- Install GeForce drivers normally
- For professional cards (Quadro), use Studio drivers

---

## 🛠️ Step 11: Advanced QEMU Script (Alternative)

### 11.1 Complete QEMU Script

```bash
nano windows-vm-advanced.sh
```

```bash
#!/bin/bash

VM_NAME="Windows10-Gaming"
VM_PATH="/home/$USER/vm"
OVMF_CODE="/usr/share/edk2/x64/OVMF_CODE.fd"
OVMF_VARS="/usr/share/edk2/x64/OVMF_VARS.fd"

qemu-system-x86_64 \
  -name "$VM_NAME",process="$VM_NAME" \
  -enable-kvm \
  -machine type=q35,accel=kvm \
  -cpu host,kvm=on,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time,+invtsc \
  -smp 8,sockets=1,cores=4,threads=2 \
  -m 16G \
  -mem-prealloc \
  -overcommit mem-lock=on \
  -rtc base=localtime,driftfix=slew \
  -global kvm-pit.lost_tick_policy=delay \
  -no-hpet \
  \
  /* GPU Passthrough */
  -vga none \
  -nographic \
  -device vfio-pci,host=01:00.0,multifunction=on,x-vga=on \
  -device vfio-pci,host=01:00.1 \
  \
  /* Storage */
  -drive file="$VM_PATH/windows.qcow2",format=qcow2,if=virtio,aio=native,cache.direct=on \
  -drive file="$VM_PATH/virtio-win.iso",media=cdrom \
  \
  /* UEFI */
  -drive if=pflash,format=raw,readonly=on,file="$OVMF_CODE" \
  -drive if=pflash,format=raw,file="$VM_PATH/OVMF_VARS.fd" \
  \
  /* Input */
  -usb -device usb-kbd -device usb-tablet \
  \
  /* Network */
  -netdev user,id=net0 \
  -device virtio-net-pci,netdev=net0 \
  \
  /* Audio (virtual) */
  -device ac97 \
  \
  /* Monitoring */
  -monitor stdio
```

### 11.2 Systemd Startup Script

```bash
sudo nano /etc/systemd/system/windows-vm.service
```

```bash
[Unit]
Description=Windows 10 Gaming VM
After=network.target

[Service]
Type=simple
ExecStart=/home/%u/windows-vm-advanced.sh
TimeoutStopSec=30
User=%u
Group=%u

[Install]
WantedBy=multi-user.target
```

---

## 🔧 Step 12: Advanced Troubleshooting

### Common Problems and Solutions:

#### NVIDIA Error 43:
```bash
# Add to VM XML:
<kvm>
  <hidden state='on'/>
</kvm>
<vendor_id state='on' value='1234567890ab'/>
```

#### Poor Gaming Performance:
- Check CPU pinning
- Increase VM memory
- Use CPU `performance` governor
- Disable security mitigations if necessary

#### Crackling Audio:
```bash
# In Windows, adjust audio format to:
# 16 bit, 48000 Hz (DVD Quality)
```

#### VM Won't Start:
```bash
# Check detailed logs
sudo journalctl -u libvirtd -f
sudo dmesg | tail -50

# Check permissions
sudo chown $USER:libvirt /var/lib/libvirt/qemu/
```

### Advanced Debug Commands:

```bash
# Check CPU isolation
cat /proc/cmdline

# Monitor IRQs
cat /proc/interrupts | grep -E "(GPU|NVIDIA)"

# Check memory mapping
sudo cat /sys/kernel/iommu_groups/*/devices

# Performance monitoring
nvidia-smi -l 1  # In VM
sudo perf stat -e cpu-cycles,instructions,cache-references,cache-misses
```

## 📚 Expanded Additional Material

### 🔧 **Automation Scripts**

#### **Automated Setup:**
```bash
nano auto_passthrough_setup.sh
```

```bash
#!/bin/bash
# Automated configuration script - USE WITH CAUTION!

BACKUP_DIR="/home/$USER/gpu-passthrough-backup-$(date +%Y%m%d)"
mkdir -p $BACKUP_DIR

echo "=== STARTING AUTOMATED CONFIGURATION ==="

# Backup
sudo cp /etc/default/grub $BACKUP_DIR/
sudo cp /etc/mkinitcpio.conf $BACKUP_DIR/
sudo cp -r /etc/modprobe.d/ $BACKUP_DIR/

# Configure GRUB
sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on iommu=pt vfio-pci.ids=10de:1c8c,10de:0fb9"/' /etc/default/grub

# Configure modules
echo "MODULES=(vfio_pci vfio vfio_iommu_type1 vfio_virqfd)" | sudo tee -a /etc/mkinitcpio.conf

# Apply configurations
sudo mkinitcpio -P
sudo grub-mkconfig -o /boot/grub/grub.cfg

echo "Configuration applied. Reboot the system."
```

### 🚀 **Performance Optimizations**

#### **CPU Governor:**
```bash
# Set to performance
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Permanently:
sudo nano /etc/default/cpupower
```
```bash
governor='performance'
max_perf_pct=100
```

#### **HugePages:**
```bash
# Configure hugepages
echo 2048 | sudo tee /proc/sys/vm/nr_hugepages

# Permanently:
echo "vm.nr_hugepages = 2048" | sudo tee -a /etc/sysctl.d/99-hugepages.conf
```

#### **CPU Isolation:**
```bash
# Add to kernel parameters:
isolcpus=2-7,10-15  # Adjust according to your CPU
```

### 🆘 **Emergency Guide**

#### **Bootable System Recovery:**
```bash
# Boot with live USB and chroot
sudo mount /dev/sda2 /mnt  # Root partition
sudo mount /dev/sda1 /mnt/boot  # Boot partition
sudo arch-chroot /mnt

# Revert configurations
sudo nano /etc/default/grub  # Remove IOMMU parameters
sudo mkinitcpio -P
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

#### **Complete Reset:**
```bash
# Remove all configurations
sudo rm /etc/modprobe.d/vfio*
sudo rm /etc/modprobe.d/blacklist_nvidia*
sudo mkinitcpio -P
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

### 📖 **Additional Resources**

#### **Official Documentation:**
- [Arch Wiki PCI Passthrough](https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF)
- [QEMU Documentation](https://qemu-project.org/Documentation/)
- [Libvirt Documentation](https://libvirt.org/docs.html)

#### **Communities:**
- **Reddit**: r/VFIO, r/Virtualization
- **Forums**: Level1Techs, Linus Tech Tips
- **Discord**: VFIO & GPU Passthrough

#### **Useful Tools:**
- **Looking Glass**: Low-latency VM display
- **Scream**: Low-latency audio
- **Virgl**: Virtualized 3D acceleration for Linux VMs

---

## ✅ Expanded Conclusion

### **Final Verification Checklist:**

- [ ] IOMMU enabled and working
- [ ] IOMMU groups properly isolated
- [ ] VFIO-pci controlling the GPU
- [ ] NVIDIA drivers blocked on host
- [ ] VM configured with UEFI/OVMF
- [ ] TPM configured (for Windows 11)
- [ ] CPU topology optimized
- [ ] Sufficient memory allocated
- [ ] VirtIO drivers installed in VM
- [ ] NVIDIA drivers working in VM
- [ ] Audio working
- [ ] Adequate performance in benchmarks

### **Recommended Next Steps:**

1. **Benchmarks**: Run 3DMark, Unigine Heaven
2. **Test Games**: CS:GO, Cyberpunk 2077, Red Dead Redemption 2
3. **Optimizations**: Adjust CPU pinning, hugepages
4. **Backup**: Snapshot of working VM
5. **Looking Glass**: Configure for better visual experience

### **Maintenance:**
- Update GPU drivers regularly
- Keep configuration backups
- Test after kernel updates
- Monitor performance with appropriate tools

**You now have a complete GPU passthrough setup! 🎉**

Remember: This is an advanced configuration that may require fine-tuning specific to your hardware. Patience and testing are essential for success.