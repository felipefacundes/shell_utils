# Tutorial Completo: Passagem de GPU Single-GPU para Virtualização

**Lembre-se**: Sempre faça backup das suas configurações antes de modificar o sistema! Use Timeshift!

## 📋 Introdução

Este tutorial irá guiá-lo através do processo de configuração de **GPU Passthrough** (passagem de GPU) para virtualização em sistemas Linux. Esta técnica permite que você utilize sua placa de vídeo física diretamente em uma máquina virtual, proporcionando desempenho próximo ao nativo.

### ⚠️ Pré-requisitos e Avisos Importantes

- **Backup**: Faça backup dos seus dados importantes antes de começar
- **Tempo estimado**: 2-4 horas para todo o processo
- **Conhecimento básico**: Familiaridade com terminal Linux é recomendada
- **Riscos**: Modificações no sistema podem causar instabilidade

---

## 🔍 Etapa 1: Verificação de Hardware

### 1.1 Verificar Suporte de Virtualização da CPU

```bash
# Verificar se a CPU suporta virtualização
LC_ALL=c lscpu | grep -i "Virtualization"

# Saída esperada (uma das opções):
# Virtualization: VT-x          # Para Intel
# Virtualization: AMD-V         # Para AMD
```

**Explicação**: Este comando verifica se seu processador possui suporte de hardware para virtualização, que é essencial para GPU passthrough.

### 1.2 Verificar Suporte IOMMU

```bash
# Verificar se IOMMU está habilitado no kernel
dmesg | grep -i "IOMMU"

# Para Intel:
dmesg | grep -i "DMAR"

# Para AMD:
dmesg | grep -i "IVRS"
```

**Explicação**: IOMMU (Input-Output Memory Management Unit) é necessário para isolar dispositivos PCIe e permitir que sejam passados para VMs.

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

# Exemplo completo:
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash intel_iommu=on iommu=pt"
```

**Explicação dos parâmetros**:
- `intel_iommu=on` ou `amd_iommu=on`: Habilita o suporte IOMMU
- `iommu=pt`: Habilita "Passthrough" apenas para dispositivos que serão utilizados em VMs

### 2.2 Atualizar Configuração do GRUB

```bash
# Atualizar configuração do GRUB
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Reinicie o sistema
sudo reboot
```

---

## 🔎 Etapa 3: Identificar Grupos IOMMU

### 3.1 Criar Script de Verificação IOMMU

Crie um arquivo chamado `iommu_group.sh`:

```bash
nano iommu_group.sh
```

Cole o seguinte conteúdo:

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

Torne o script executável e execute:

```bash
chmod +x iommu_group.sh
./iommu_group.sh
```

### 3.2 Analisar a Saída

**Exemplo de saída PROBLEMÁTICA**:
```
IOMMU Group 2:
    00:01.0 PCI bridge [0604]: Intel Corporation 6th-10th Gen Core Processor PCIe Controller (x16) [8086:1901] (rev 07)
    01:00.0 VGA compatible controller [0300]: NVIDIA Corporation GP107M [GeForce GTX 1050 Ti Mobile] [10de:1c8c] (rev a1)
    01:00.1 Audio device [0403]: NVIDIA Corporation GP107GL High Definition Audio Controller [10de:0fb9] (rev a1)
```

**Problema**: A GPU está no mesmo grupo que a ponte PCI, o que impede o isolamento individual.

**Solução ideal**: Cada dispositivo deve estar em seu próprio grupo IOMMU.

---

## 🆔 Etapa 4: Identificar Dispositivos NVIDIA

### 4.1 Identificar IDs da GPU

```bash
# Identificar todas as placas NVIDIA
lspci -nn | grep -i "NVIDIA"

# Saída esperada:
01:00.0 VGA compatible controller [0300]: NVIDIA Corporation GP107M [GeForce GTX 1050 Ti Mobile] [10de:1c8c] (rev a1)
01:00.1 Audio device [0403]: NVIDIA Corporation GP107GL High Definition Audio Controller [10de:0fb9] (rev a1)
```

**Anote os IDs**: `10de:1c8c` (GPU) e `10de:0fb9` (Áudio)

### 4.2 Adicionar IDs ao GRUB

Edite novamente `/etc/default/grub`:

```bash
sudo nano /etc/default/grub
```

Adicione os IDs aos parâmetros existentes:

```bash
# Adicione: vfio-pci.ids=10de:1c8c,10de:0fb9
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash intel_iommu=on iommu=pt vfio-pci.ids=10de:1c8c,10de:0fb9"
```

**Explicação**: Isso instrui o kernel a carregar os dispositivos com esses IDs usando o driver vfio-pci.

---

## ⚙️ Etapa 5: Configurar Módulos do Kernel

### 5.1 Editar mkinitcpio.conf

```bash
sudo nano /etc/mkinitcpio.conf
```

Localize a linha `MODULES=` e adicione:

```bash
MODULES=(vfio_pci vfio vfio_iommu_type1 vfio_virqfd)
```

**Explicação dos módulos**:
- `vfio_pci`: Driver para dispositivos PCIe
- `vfio`: Framework para passagem de dispositivos
- `vfio_iommu_type1`: Suporte IOMMU tipo 1
- `vfio_virqfd`: Manipulação de interrupções

### 5.2 Configurações Adicionais do VFIO

Crie o arquivo de configuração do VFIO:

```bash
sudo nano /etc/modprobe.d/vfio.conf
```

Adicione:

```bash
# Forçar carregamento dos dispositivos NVIDIA com vfio-pci
options vfio-pci ids=10de:1c8c,10de:0fb9

# Dependência: carregar vfio-pci antes do nvidia
softdep nvidia pre: vfio-pci
softdep nvidia-drm pre: vfio-pci
```

---

## 🚫 Etapa 6: Bloquear Drivers NVIDIA no Host

### 6.1 Blacklist Driver NVIDIA

Crie o arquivo de blacklist:

```bash
sudo nano /etc/modprobe.d/blacklist_nvidia.conf
```

Adicione:

```bash
# Impedir carregamento dos drivers NVIDIA no host
blacklist nvidia
blacklist nvidia_drm
blacklist nvidia_modeset
blacklist nvidia_uvm
blacklist nouveau

# Desabilitar modesetting
options nvidia modeset=0
options nvidia_drm modeset=0
```

### 6.2 Blacklist Nouveau (Driver Open Source)

```bash
sudo nano /etc/modprobe.d/blacklist_nouveau.conf
```

Adicione:

```bash
# Bloquear driver Nouveau
blacklist nouveau
options nouveau modeset=0
```

---

## 🔄 Etapa 7: Aplicar Configurações e Reiniciar

### 7.1 Reconstruir Initramfs e GRUB

```bash
# Reconstruir imagem initramfs
sudo mkinitcpio -P

# Atualizar configuração do GRUB
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Reiniciar o sistema
sudo reboot
```

### 7.2 Verificar Configuração Após Reinício

```bash
# Verificar se os dispositivos estão sendo gerenciados pelo vfio-pci
lspci -k | grep -E "vfio-pci|NVIDIA"

# Verificar grupos IOMMU novamente
./iommu_group.sh

# Verificar se drivers NVIDIA estão bloqueados
lsmod | grep -E "nvidia|nouveau"
```

---

## 🖥️ Etapa 8: Configurar Máquina Virtual

### 8.1 Instalar Dependências

```bash
# Instalar virt-manager e dependências
sudo pacman -S virt-manager qemu-desktop libvirt edk2-ovmf swtpm

# Habilitar serviços
sudo systemctl enable libvirtd
sudo systemctl start libvirtd
sudo systemctl enable virtnetworkd
sudo systemctl start virtnetworkd
```

### 8.2 Configurar Rede (Opcional)

```bash
sudo nano /etc/libvirt/network.conf
```

Adicione:
```bash
firewall_backend = "iptables"
```

Reinicie os serviços:
```bash
sudo systemctl restart libvirtd
sudo systemctl restart virtnetworkd

# Configurar rede padrão
sudo virsh net-info default
sudo virsh net-autostart default
sudo virsh net-start default
```

---

## 🎮 Etapa 9: Criar Máquina Virtual no Virt-Manager

### 9.1 Passos no Virt-Manager

1. **Abrir Virt-Manager**: `virt-manager`
2. **Criar Nova VM**: Clique em "Create New Virtual Machine"
3. **Sistema Operacional**: Selecione "Windows 10/11"
4. **Memória**: Recomendado 8GB+ para jogos
5. **CPU**: Configurar topologia correta (sockets/cores)

### 9.2 Configurações Especiais

**Antes de iniciar a VM, edite as configurações**:

#### Adicionar TPM (Para Windows 11):
- **Hardware → Add Hardware → TPM**
- Selecione "Emulated" e versão 2.0

#### Adicionar GPU NVIDIA:
- **Hardware → Add Hardware → PCI Host Device**
- Selecione ambos os dispositivos NVIDIA:
  - `01:00.0 VGA compatible controller`
  - `01:00.1 Audio device`

#### Configurações de CPU:
- **CPU → Configuration → Copy host CPU configuration**
- **Topology**: Configure de acordo com seu processador

#### Configurações de Boot:
- **Boot Options → Enable UEFI**
- **SATA Disk 1 → Boot priority**: 1

---

## 💿 Etapa 10: Instalação do Windows

### 10.1 Drivers VirtIO

Baixe os drivers VirtIO:
```bash
wget https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso
```

**Durante a instalação do Windows**:
- Quando pedir para selecionar disco, clique em "Load Driver"
- Navegue até a ISO do VirtIO e selecione:
  - `viostor\w11\amd64` (para storage)
  - `NetKVM\w11\amd64` (para rede)
  - `vioserial\w11\amd64` (para serial)

### 10.2 Drivers de Vídeo e Melhorias

#### Mesa3D (OpenGL):
1. Baixe: https://github.com/pal1000/mesa-dist-win/releases
2. Extraia e execute o instalador

#### Drivers NVIDIA:
1. Baixe drivers da NVIDIA site oficial
2. Instale normalmente

#### WinFSP (Compartilhamento de Arquivos):
```bash
wget https://github.com/winfsp/winfsp/releases/download/v2.0/winfsp-2.0.23075.msi
```

Instale no Windows para habilitar compartilhamento de arquivos via SPICE.

---

## 🛠️ Etapa 11: Script QEMU Avançado (Alternativa)

Se preferir usar QEMU diretamente, crie um script:

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

Torne executável:
```bash
chmod +x windows-vm.sh
```

---

## 🔧 Etapa 12: Solução de Problemas

### Problemas Comuns:

#### GPU Não Aparece na VM:
```bash
# Verificar se vfio-pci está controlando o dispositivo
lspci -k | grep -A 2 "NVIDIA"

# Verificar dmesg para erros
dmesg | grep -i "vfio"
```

#### Performance Ruim:
- Verifique se todos os cores da CPU estão sendo utilizados
- Aumente a memória alocada
- Verifique se a GPU está sendo utilizada 100%

#### Áudio Não Funciona:
- Certifique-se de que ambos dispositivos (GPU e Áudio) foram passados
- Instale drivers de áudio HD na VM

### Comandos Úteis para Debug:

```bash
# Verificar status IOMMU
dmesg | grep -i iommu

# Verificar grupos IOMMU
find /sys/kernel/iommu_groups/ -type l | sort -V

# Verificar se VFIO está carregado
lsmod | grep vfio

# Monitorar performance da GPU
nvidia-smi    # No host (se disponível)
```

## 📚 Material Complementar

Aqui estão alguns recursos extras que podem ser úteis:

### 🔧 **Scripts Automatizados Úteis**

#### **Script de Verificação de Compatibilidade:**
```bash
#!/bin/bash
echo "=== VERIFICAÇÃO DE COMPATIBILIDADE GPU PASSTHROUGH ==="
echo "1. Verificando virtualização da CPU..."
egrep -c '(vmx|svm)' /proc/cpuinfo
echo "2. Verificando IOMMU..."
dmesg | grep -e "DMAR" -e "IOMMU"
echo "3. Verificando grupos IOMMU..."
./iommu_group.sh | grep -A 5 -B 5 "NVIDIA"
echo "4. Verificando drivers ativos..."
lspci -k | grep -A 2 -E "(VGA|3D)"
```

#### **Script de Backup de Configurações:**
```bash
#!/bin/bash
# Backup das configurações importantes
BACKUP_DIR="/home/$USER/gpu-passthrough-backup"
mkdir -p $BACKUP_DIR
sudo cp /etc/default/grub $BACKUP_DIR/
sudo cp /etc/mkinitcpio.conf $BACKUP_DIR/
sudo cp /etc/modprobe.d/* $BACKUP_DIR/
echo "Backup criado em: $BACKUP_DIR"
```

### 🚀 **Dicas de Otimização Avançada**

#### **CPU Pinning (Melhor Performance):**
```bash
# No virt-manager, edite a XML da VM e adicione:
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

#### **Hugepages (Memória Otimizada):**
```bash
# Adicione ao /etc/default/grub:
GRUB_CMDLINE_LINUX_DEFAULT="... hugepages=2048"

# E execute:
echo 2048 | sudo tee /proc/sys/vm/nr_hugepages
```

### 🆘 **Guia Rápido de Troubleshooting**

#### **Problema: Tela preta na VM**
**Solução:**
```bash
# Verificar se o vfio-pci assumiu o controle
lspci -k | grep -A 3 "NVIDIA"

# Se não, verificar blacklist
lsmod | grep nvidia
```

#### **Problema: Áudio não funciona**
**Solução:**
- Certifique-se de que passou **ambos** dispositivos:
  - Placa de vídeo (VGA compatible controller)
  - Áudio da placa (Audio device)

#### **Problema: VM não inicia**
**Solução:**
```bash
# Verificar logs
sudo journalctl -u libvirtd -f

# Verificar se serviços estão ativos
sudo systemctl status libvirtd virtnetworkd
```

### 📖 **Próximos Passos Recomendados**

1. **Teste de Performance**: Rode benchmarks como 3DMark ou jogos pesados
2. **Otimize Configurações**: Ajuste memória e CPU conforme necessidade
3. **Backup da VM**: Faça snapshot da VM funcionando
4. **Compartilhamento**: Configure compartilhamento de arquivos host↔VM

### 🎯 **Checklist Final**

- [ ] GPU sendo controlada pelo vfio-pci
- [ ] Drivers NVIDIA instalados na VM
- [ ] Áudio funcionando
- [ ] Performance adequada
- [ ] Backup das configurações
- [ ] Scripts de inicialização (se usando QEMU direto)

### 🤝 **Comunidade e Suporte**

Se encontrar problemas:
- **Arch Wiki**: Documentação mais atualizada
- **Reddit r/VFIO**: Comunidade especializada
- **Fóruns**: Level1Techs, Linus Tech Tips

---

## ✅ Conclusão

Parabéns! Você configurou com sucesso a passagem de GPU single-GPU. Agora você pode:

- 🎮 **Jogar jogos** com performance próxima ao nativo
- 🎬 **Editar vídeos** usando aceleração de GPU
- 🔬 **Executar aplicações CUDA** na VM

### Próximos Passos Opcionais:

1. **Configurar compartilhamento de arquivos** via Samba ou SPICE
2. **Otimizar performance** com CPU pinning
3. **Configurar PCIe ACS override** se necessário para separação de grupos

### Recursos Adicionais:

- [Wiki Arch Linux - PCI Passthrough](https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF)
- [r/VFIO no Reddit](https://www.reddit.com/r/VFIO/)