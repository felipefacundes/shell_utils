# Tutorial Completo: Passagem de GPU Single-GPU para Virtualização

**Lembre-se**: Sempre faça backup das suas configurações antes de modificar o sistema! Use Timeshift!

## 📋 Introdução

Este tutorial irá guiá-lo através do processo de configuração de **GPU Passthrough** (passagem de GPU) para virtualização em sistemas Linux. Esta técnica permite que você utilize sua placa de vídeo física diretamente em uma máquina virtual, proporcionando desempenho próximo ao nativo.

### ⚠️ Pré-requisitos e Avisos Importantes

- **Backup**: Faça backup dos seus dados importantes antes de começar
- **Tempo estimado**: 2-4 horas para todo o processo
- **Conhecimento básico**: Familiaridade com terminal Linux é recomendada
- **Riscos**: Modificações no sistema podem causar instabilidade
- **Hardware**: Duas GPUs são recomendadas (uma para host, outra para VM)
- **Sistema**: Testado em Arch Linux, Ubuntu 20.04+, Fedora 35+

---

## 🔍 Etapa 1: Verificação de Hardware

### 1.1 Verificar Suporte de Virtualização da CPU

```bash
# Verificar se a CPU suporta virtualização
LC_ALL=c lscpu | grep -i "Virtualization"

# Verificar extensões de virtualização
egrep -c '(vmx|svm)' /proc/cpuinfo

# Saída esperada (deve ser > 0):
# 8
```

**Explicação**: VMX (Intel) e SVM (AMD) são as extensões de virtualização de hardware necessárias.

### 1.2 Verificar Suporte IOMMU

```bash
# Verificar se IOMMU está habilitado no kernel
dmesg | grep -i "IOMMU"

# Para Intel:
dmesg | grep -e "DMAR" -e "IOMMU"

# Para AMD:
dmesg | grep -e "IVRS" -e "IOMMU"

# Verificar se IOMMU está ativo
sudo dmesg | grep -i "IOMMU enabled"
```

**Explicação**: IOMMU (Input-Output Memory Management Unit) é necessário para isolar dispositivos PCIe.

---

## 🛠️ Etapa 2: Habilitar IOMMU no Boot

### 2.1 Editar Parâmetros do GRUB

Abra o arquivo de configuração do GRUB:

```bash
sudo nano /etc/default/grub
```

Localize a linha `GRUB_CMDLINE_LINUX_DEFAULT` e adicione os parâmetros apropriados:

```bash
# Para processadores Intel:
GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on iommu=pt"

# Para processadores AMD:
GRUB_CMDLINE_LINUX_DEFAULT="quiet amd_iommu=on iommu=pt"

# Com ACS override (se necessário para separar grupos IOMMU):
GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on iommu=pt pcie_acs_override=downstream,multifunction"

# Exemplo completo:
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash intel_iommu=on iommu=pt vfio-pci.ids=10de:1c8c,10de:0fb9"
```

**Explicação dos parâmetros**:
- `intel_iommu=on` ou `amd_iommu=on`: Habilita o suporte IOMMU
- `iommu=pt`: Habilita "Passthrough" apenas para dispositivos que serão utilizados em VMs
- `pcie_acs_override`: Força separação de grupos IOMMU (use com cautela)

### 2.2 Atualizar Configuração do GRUB

```bash
# Para sistemas com GRUB tradicional:
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Para sistemas com systemd-boot (Arch Linux):
sudo bootctl update

# Para sistemas com EFI Stub:
sudo update-grub

# Reinicie o sistema
sudo reboot
```

---

## 🔎 Etapa 3: Identificar Grupos IOMMU

### 3.1 Script Avançado de Verificação IOMMU

Crie um arquivo chamado `iommu_groups.sh`:

```bash
nano iommu_groups.sh
```

Cole o seguinte conteúdo:

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

### 3.2 Script de Verificação de Compatibilidade

Crie também `check_passthrough.sh`:

```bash
nano check_passthrough.sh
```

```bash
#!/bin/bash
echo "=== VERIFICAÇÃO DE COMPATIBILIDADE GPU PASSTHROUGH ==="
echo ""
echo "1. Virtualização da CPU:"
egrep -c '(vmx|svm)' /proc/cpuinfo
echo ""
echo "2. Suporte IOMMU:"
dmesg | grep -e "DMAR" -e "IOMMU" | head -5
echo ""
echo "3. Grupos IOMMU (apenas grupos com dispositivos importantes):"
./iommu_groups.sh | grep -E "(VGA|Audio|USB|NVMe)" -A 2 -B 2
echo ""
echo "4. Drivers ativos das GPUs:"
lspci -k | grep -A 2 -E "(VGA|3D)"
```

Torne os scripts executáveis:
```bash
chmod +x iommu_groups.sh check_passthrough.sh
./check_passthrough.sh
```

---

## 🆔 Etapa 4: Identificar Dispositivos NVIDIA

### 4.1 Identificação Completa dos Dispositivos

```bash
# Identificar todas as placas NVIDIA
lspci -nn | grep -i "NVIDIA"

# Identificar com mais detalhes
lspci -vnn | grep -A 10 -i "NVIDIA"

# Saída esperada:
01:00.0 VGA compatible controller [0300]: NVIDIA Corporation GP107M [GeForce GTX 1050 Ti Mobile] [10de:1c8c] (rev a1)
01:00.1 Audio device [0403]: NVIDIA Corporation GP107GL High Definition Audio Controller [10de:0fb9] (rev a1)
```

### 4.2 Script de Backup de IDs

```bash
nano backup_gpu_ids.sh
```

```bash
#!/bin/bash
echo "Backup dos IDs da GPU:"
lspci -nn | grep -i "NVIDIA" | tee gpu_ids_backup.txt
echo "IDs salvos em gpu_ids_backup.txt"
```

---

## ⚙️ Etapa 5: Configurar Módulos do Kernel

### 5.1 Configuração Avançada do Initramfs

```bash
sudo nano /etc/mkinitcpio.conf
```

**Configuração recomendada**:
```bash
MODULES=(vfio_pci vfio vfio_iommu_type1 vfio_virqfd)
BINARIES=()
FILES=()
HOOKS=(base systemd autodetect modconf kms keyboard sd-vconsole block filesystems fsck)
```

**Para sistemas com early loading**:
```bash
# Adicione no MODULES os IDs específicos da sua GPU
MODULES=(vfio_pci vfio vfio_iommu_type1 vfio_virqfd nvidia nvidia_modeset nvidia_drm nvidia_uvm)
```

### 5.2 Configurações do VFIO

Crie múltiplos arquivos de configuração para melhor organização:

```bash
# Configuração principal do VFIO
sudo nano /etc/modprobe.d/vfio.conf
```
```bash
options vfio-pci ids=10de:1c8c,10de:0fb9
options vfio-pci disable_vga=1
```

```bash
# Configuração de dependências
sudo nano /etc/modprobe.d/vfio_dependencies.conf
```
```bash
softdep nvidia pre: vfio-pci
softdep nvidia_drm pre: vfio-pci
softdep nvidia_modeset pre: vfio-pci
softdep nouveau pre: vfio-pci
```

---

## 🚫 Etapa 6: Bloquear Drivers NVIDIA no Host

### 6.1 Blacklist Completo

```bash
sudo nano /etc/modprobe.d/blacklist_nvidia.conf
```

```bash
# Bloquear drivers NVIDIA proprietários
blacklist nvidia
blacklist nvidia_drm
blacklist nvidia_modeset
blacklist nvidia_uvm
blacklist nvidia_current
blacklist nvidia_current_drm
blacklist nvidia_current_modeset

# Bloquear Nouveau
blacklist nouveau
options nouveau modeset=0

# Desabilitar modesetting
options nvidia modeset=0
options nvidia_drm modeset=0
options nvidia_modeset modeset=0
```

### 6.2 Configuração do Xorg (se usar X11)

```bash
sudo nano /etc/X11/xorg.conf.d/10-gpu-passthrough.conf
```

```bash
Section "Device"
    Identifier "IntelGPU"
    Driver "intel"  # ou "amdgpu" para AMD
    BusID "PCI:0:2:0"  # Altere conforme seu hardware
EndSection
```

---

## 🔄 Etapa 7: Aplicar Configurações e Reiniciar

### 7.1 Procedimento Completo de Atualização

```bash
# 1. Reconstruir initramfs com verificação
sudo mkinitcpio -P

# 2. Verificar se os módulos foram incluídos
lsinitcpio /boot/initramfs-linux.img | grep vfio

# 3. Atualizar GRUB
sudo grub-mkconfig -o /boot/grub/grub.cfg

# 4. Atualizar systemd-boot (se aplicável)
sudo bootctl update

# 5. Reiniciar
sudo reboot
```

### 7.2 Verificação Pós-Reinício

```bash
# Script de verificação pós-reinício
nano verify_passthrough.sh
```

```bash
#!/bin/bash
echo "=== VERIFICAÇÃO PÓS-REINÍCIO ==="
echo ""
echo "1. Módulos VFIO carregados:"
lsmod | grep vfio
echo ""
echo "2. Dispositivos controlados pelo VFIO:"
lspci -k | grep -A 3 -E "(NVIDIA|AMD)" | grep -E "(Kernel driver in use|vfio-pci)"
echo ""
echo "3. Drivers NVIDIA bloqueados:"
lsmod | grep -E "(nvidia|nouveau)" || echo "Nenhum driver NVIDIA carregado - OK"
echo ""
echo "4. Grupos IOMMU:"
./iommu_groups.sh | grep -A 3 -B 1 "NVIDIA"
```

---

## 🖥️ Etapa 8: Configurar Máquina Virtual

### 8.1 Instalação Completa de Dependências

**Para Arch Linux**:
```bash
sudo pacman -S virt-manager qemu-desktop libvirt edk2-ovmf swtpm dnsmasq ebtables
```

**Para Ubuntu/Debian**:
```bash
sudo apt install qemu-kvm qemu-utils libvirt-daemon-system libvirt-clients bridge-utils virt-manager ovmf
```

**Para Fedora**:
```bash
sudo dnf install @virtualization virt-manager edk2-ovmf swtpm-tools
```

### 8.2 Configuração do Libvirt

```bash
# Adicionar usuário aos grupos
sudo usermod -a -G libvirt $USER
sudo usermod -a -G kvm $USER

# Configurar serviço
sudo systemctl enable libvirtd
sudo systemctl start libvirtd
sudo systemctl enable virtlogd.socket
sudo systemctl start virtlogd.socket

# Configurar rede padrão
sudo virsh net-autostart default
sudo virsh net-start default
```

### 8.3 Configuração Avançada de Rede

```bash
sudo nano /etc/libvirt/qemu.conf
```

Descomente ou adicione:
```bash
user = "seu_usuario"
group = "libvirt"
security_driver = "none"
```

---

## 🎮 Etapa 9: Criar Máquina Virtual no Virt-Manager

### 9.1 Passos Detalhados no Virt-Manager

1. **Abrir Virt-Manager**: `virt-manager`
2. **Criar Nova VM**: Clique em "Create New Virtual Machine"
3. **Importante**: Marque "Customize configuration before install"
4. **Sistema Operacional**: Selecione "Windows 10/11"

### 9.2 Configurações de Hardware Otimizadas

**Antes de iniciar a VM, edite as configurações**:

#### CPU (Crucial para Performance):
```xml
<cpu mode='host-passthrough' check='none'>
  <topology sockets='1' dies='1' cores='4' threads='2'/>
  <feature policy='require' name='topoext'/>
</cpu>
```

#### Memória:
- Aloque pelo menos 8GB para jogos
- Marque "Enable shared memory"

#### TPM (Para Windows 11):
- **Hardware → Add Hardware → TPM**
- Tipo: Emulated
- Versão: 2.0
- Modelo: crb

#### GPU NVIDIA:
- **Hardware → Add Hardware → PCI Host Device**
- Selecione ambos os dispositivos NVIDIA
- **Importante**: Marque "All functions" se disponível

#### Configurações Adicionais:
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

## 💿 Etapa 10: Instalação do Windows

### 10.1 Drivers VirtIO Otimizados

**Download dos drivers mais recentes**:
```bash
# Método 1: Fedora (oficial)
wget https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso

# Método 2: GitHub (mais atualizado)
wget https://github.com/virtio-win/virtio-win-pkg-scripts/blob/master/README.md
```

**Ordem de instalação dos drivers**:
1. `viostor\w11\amd64` - Controladores de armazenamento
2. `NetKVM\w11\amd64` - Rede virtio
3. `vioserial\w11\amd64` - Porta serial
4. `viorng\w11\amd64` - Gerador de números aleatórios
5. `Balloon\w11\amd64` - Balão de memória

### 10.2 Otimizações do Windows

#### Desativar Serviços Desnecessários:
```powershell
# Executar como Administrador
Disable-WindowsOptionalFeature -Online -FeatureName "WindowsMediaPlayer"
Disable-WindowsOptionalFeature -Online -FeatureName "WorkFolders-Client"
Disable-WindowsOptionalFeature -Online -FeatureName "Printing-PrintToPDFServices-Features"
```

#### Configurar Planos de Energia:
```powershell
powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c  # Alto desempenho
```

#### Drivers Específicos para NVIDIA na VM:
- Instale drivers GeForce normalmente
- Para placas profissionais (Quadro), use drivers Studio

---

## 🛠️ Etapa 11: Script QEMU Avançado (Alternativa)

### 11.1 Script Completo QEMU

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

### 11.2 Script de Inicialização com Systemd

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

## 🔧 Etapa 12: Solução de Problemas Avançada

### Problemas Comuns e Soluções:

#### Error 43 NVIDIA:
```bash
# Adicione ao XML da VM:
<kvm>
  <hidden state='on'/>
</kvm>
<vendor_id state='on' value='1234567890ab'/>
```

#### Performance Ruim em Jogos:
- Verifique CPU pinning
- Aumente memória da VM
- Use `performance` governor da CPU
- Desative mitigações de segurança se necessário

#### Áudio Estourado:
```bash
# No Windows, ajuste formatação de áudio para:
# 16 bit, 48000 Hz (DVD Quality)
```

#### VM Não Inicia:
```bash
# Verificar logs detalhados
sudo journalctl -u libvirtd -f
sudo dmesg | tail -50

# Verificar permissões
sudo chown $USER:libvirt /var/lib/libvirt/qemu/
```

### Comandos de Debug Avançados:

```bash
# Verificar isolamento de CPU
cat /proc/cmdline

# Monitorar IRQs
cat /proc/interrupts | grep -E "(GPU|NVIDIA)"

# Verificar memory mapping
sudo cat /sys/kernel/iommu_groups/*/devices

# Performance monitoring
nvidia-smi -l 1  # Na VM
sudo perf stat -e cpu-cycles,instructions,cache-references,cache-misses
```

## 📚 Material Complementar Expandido

### 🔧 **Scripts de Automação**

#### **Setup Automatizado:**
```bash
nano auto_passthrough_setup.sh
```

```bash
#!/bin/bash
# Script de configuração automática - USE COM CAUTELA!

BACKUP_DIR="/home/$USER/gpu-passthrough-backup-$(date +%Y%m%d)"
mkdir -p $BACKUP_DIR

echo "=== INICIANDO CONFIGURAÇÃO AUTOMÁTICA ==="

# Backup
sudo cp /etc/default/grub $BACKUP_DIR/
sudo cp /etc/mkinitcpio.conf $BACKUP_DIR/
sudo cp -r /etc/modprobe.d/ $BACKUP_DIR/

# Configurar GRUB
sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on iommu=pt vfio-pci.ids=10de:1c8c,10de:0fb9"/' /etc/default/grub

# Configurar módulos
echo "MODULES=(vfio_pci vfio vfio_iommu_type1 vfio_virqfd)" | sudo tee -a /etc/mkinitcpio.conf

# Aplicar configurações
sudo mkinitcpio -P
sudo grub-mkconfig -o /boot/grub/grub.cfg

echo "Configuração aplicada. Reinicie o sistema."
```

### 🚀 **Otimizações de Performance**

#### **CPU Governor:**
```bash
# Configurar para performance
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Permanentemente:
sudo nano /etc/default/cpupower
```
```bash
governor='performance'
max_perf_pct=100
```

#### **HugePages:**
```bash
# Configurar hugepages
echo 2048 | sudo tee /proc/sys/vm/nr_hugepages

# Permanentemente:
echo "vm.nr_hugepages = 2048" | sudo tee -a /etc/sysctl.d/99-hugepages.conf
```

#### **Isolamento de CPU:**
```bash
# Adicionar ao kernel parameters:
isolcpus=2-7,10-15  # Ajuste conforme sua CPU
```

### 🆘 **Guia de Emergência**

#### **Recuperação de Sistema Inicializável:**
```bash
# Boot com USB live e chroot
sudo mount /dev/sda2 /mnt  # Partição raiz
sudo mount /dev/sda1 /mnt/boot  # Boot
sudo arch-chroot /mnt

# Reverter configurações
sudo nano /etc/default/grub  # Remover parâmetros IOMMU
sudo mkinitcpio -P
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

#### **Reset Completo:**
```bash
# Remover todas as configurações
sudo rm /etc/modprobe.d/vfio*
sudo rm /etc/modprobe.d/blacklist_nvidia*
sudo mkinitcpio -P
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

### 📖 **Recursos Adicionais**

#### **Documentação Oficial:**
- [Arch Wiki PCI Passthrough](https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF)
- [QEMU Documentation](https://qemu-project.org/Documentation/)
- [Libvirt Documentation](https://libvirt.org/docs.html)

#### **Comunidades:**
- **Reddit**: r/VFIO, r/Virtualization
- **Fóruns**: Level1Techs, Linus Tech Tips
- **Discord**: VFIO & GPU Passthrough

#### **Ferramentas Úteis:**
- **Looking Glass**: Baixa latência para visualização da VM
- **Scream**: Áudio de baixa latência
- **Virgl**: Aceleração 3D virtualizada para Linux VMs

---

## ✅ Conclusão Expandida

### **Checklist Final de Verificação:**

- [ ] IOMMU habilitado e funcionando
- [ ] Grupos IOMMU adequadamente isolados
- [ ] VFIO-pci controlando a GPU
- [ ] Drivers NVIDIA bloqueados no host
- [ ] VM configurada com UEFI/OVMF
- [ ] TPM configurado (para Windows 11)
- [ ] CPU topology otimizada
- [ ] Memória suficiente alocada
- [ ] Drivers VirtIO instalados na VM
- [ ] Drivers NVIDIA funcionando na VM
- [ ] Áudio funcionando
- [ ] Performance adequada em benchmarks

### **Próximos Passos Recomendados:**

1. **Benchmarks**: Rode 3DMark, Unigine Heaven
2. **Jogos Teste**: CS:GO, Cyberpunk 2077, Red Dead Redemption 2
3. **Otimizações**: Ajuste CPU pinning, hugepages
4. **Backup**: Snapshot da VM funcionando
5. **Looking Glass**: Configure para melhor experiência visual

### **Manutenção:**
- Atualize drivers da GPU regularmente
- Mantenha backup das configurações
- Teste após atualizações do kernel
- Monitore performance com ferramentas apropriadas

**Agora você tem uma configuração completa de GPU passthrough! 🎉**

Lembre-se: Esta é uma configuração avançada que pode requerer ajustes finos específicos para seu hardware. Paciência e testes são essenciais para o sucesso.