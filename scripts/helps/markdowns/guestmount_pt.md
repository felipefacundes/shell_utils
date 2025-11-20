# Montagem de Imagens QCOW2 no Arch Linux

Este guia descreve vários métodos para montar imagens no formato QCOW2 no Arch Linux, permitindo acesso aos sistemas de arquivos contidos nessas imagens.

## 📋 Pré-requisitos

### Instalação de Pacotes Necessários

```bash
# Pacotes básicos para manipulação de QCOW2
sudo pacman -S qemu libguestfs nbd

# Ferramentas adicionais úteis
sudo pacman -S fuse3 e2fsprogs dosfstools ntfs-3g
```

## 🔍 Identificação dos Sistemas de Arquivos

Antes de montar, é importante identificar as partições e sistemas de arquivos contidos na imagem:

```bash
# Listar partições e sistemas de arquivos
sudo virt-filesystems -a imagem.qcow2 -l

# Mostrar layout detalhado
sudo virt-filesystems -a imagem.qcow2 -lh

# Usando qemu-nbd para inspecionar
sudo qemu-nbd -c /dev/nbd0 imagem.qcow2
sudo fdisk -l /dev/nbd0
```

## 🚀 Método 1: Usando guestmount (Recomendado)

### Montagem

```bash
# Criar ponto de montagem
sudo mkdir -p /mnt/vm

# Mudar proprietário para o usuário atual
sudo chown -R $USER:$USER /mnt/vm

# Ou dar permissão de leitura/escrita ao grupo
sudo chmod -R 755 /mnt/vm

# Montar a imagem
guestmount -a imagem.qcow2 -i /mnt/vm

# Ou especificar a partição manualmente
guestmount -a imagem.qcow2 -m /dev/sda1 /mnt/vm

# Para imagens Windows
guestmount -a Win10.qcow2 -m /dev/sda2 /mnt/vm
guestmount -a Win10.qcow2 -m /dev/sda2 --ro /mnt/vm # Para somente leitura --ro
```


### Desmontagem

```bash
# Desmontar normalmente
cd ~ # Para sair do diretório de montagem se estiver lá
guestunmount /mnt/vm

# Forçar desmontagem se necessário
sudo fusermount -u /mnt/vm

# Se ainda não funcionar, force:
sudo guestunmount --no-retry /mnt/vm
```

## 🔧 Método 2: Usando NBD (Network Block Device)

### Carregar Módulo do Kernel

```bash
# Carregar módulo nbd
sudo modprobe nbd max_part=16

# Verificar se os dispositivos foram criados
ls /dev/nbd*
```

### Montagem com NBD

```bash
# Conectar imagem ao dispositivo nbd
sudo qemu-nbd -c /dev/nbd0 imagem.qcow2

# Verificar partições
sudo fdisk -l /dev/nbd0

# Montar partição específica
sudo mkdir -p /mnt/vm
sudo mount /dev/nbd0p1 /mnt/vm

# Para sistemas de arquivos específicos
sudo mount -t ntfs-3g /dev/nbd0p2 /mnt/vm  # Windows NTFS
sudo mount -t ext4 /dev/nbd0p1 /mnt/vm     # Linux EXT4
```

### Desmontagem NBD

```bash
# Desmontar partição
sudo umount /mnt/vm

# Desconectar dispositivo nbd
sudo qemu-nbd -d /dev/nbd0

# Remover módulo se necessário
sudo rmmod nbd
```

## 🛠️ Método 3: Usando qemu-nbd com Permissões de Usuário

### Configuração para uso sem root

```bash
# Adicionar usuário ao grupo disk
sudo usermod -a -G disk $USER

# Recarregar grupos (fazer logout/login ou executar)
newgrp disk
```

### Montagem como usuário regular

```bash
# Conectar com permissões de usuário
qemu-nbd --fork --persistent --format=qcow2 --socket=/tmp/nbd-socket /dev/nbd0 imagem.qcow2

# Montar
mkdir -p ~/mount/vm
sudo mount /dev/nbd0p1 ~/mount/vm
sudo chown -R $USER:$USER ~/mount/vm
```

## 🔍 Verificação e Solução de Problemas

### Verificar processos usando o ponto de montagem

```bash
# Verificar se há processos impedindo a desmontagem
sudo lsof +D /mnt/vm
# Ou use fuser
fuser -v /mnt/vm

# Ver processos FUSE específicos
ps aux | grep fuse
sudo lsof | grep fuse
```

### Verificar montagens ativas

```bash
# Listar montagens FUSE
mount | grep fuse

# Ver dispositivos nbd ativos
lsblk | grep nbd

# Ver conexões nbd ativas
cat /sys/block/nbd*/pid
```

## 🎯 Exemplos Práticos

### Imagem Linux (EXT4)

```bash
# Identificar
sudo virt-filesystems -a linux.qcow2 -lh

# Montar
sudo guestmount -a linux.qcow2 -i /mnt/vm
sudo chown -R $USER:$USER /mnt/vm

# Trabalhar com os arquivos
ls -la /mnt/vm/

# Desmontar
sudo guestunmount /mnt/vm
```

### Imagem Windows (NTFS)

```bash
# Identificar partições
sudo virt-filesystems -a windows.qcow2 -lh

# Montar partição do Windows (geralmente sda2 ou sda3)
sudo guestmount -a windows.qcow2 -m /dev/sda2 --ro /mnt/vm
sudo chown -R $USER:$USER /mnt/vm

# Desmontar
sudo guestunmount /mnt/vm
```

## ⚠️ Troubleshooting

### Erro de permissão

```bash
# Se encontrar erro de permissão com FUSE
sudo chmod +r /dev/fuse
```

### Dispositivo NBD ocupado

```bash
# Verificar e liberar dispositivos nbd ocupados
sudo qemu-nbd -d /dev/nbd0
sudo rmmod nbd
sudo modprobe nbd max_part=16
```

### Imagem corrompida

```bash
# Verificar integridade da imagem
qemu-img check imagem.qcow2

# Reparar se necessário
qemu-img check -r all imagem.qcow2
```

## 📝 Notas Importantes

1. **Sempre desmonte** antes de desconectar dispositivos NBD
2. **Use modo read-only** (`--ro`) com imagens críticas
3. **Verifique as permissões** após montagem
4. **Módulo NBD** precisa ser carregado com `max_part` para suporte a partições
5. **guestmount** geralmente é o método mais seguro e fácil

## 🔗 Links Úteis

- [Arch Wiki - QEMU](https://wiki.archlinux.org/title/QEMU)
- [Libguestfs Documentation](https://libguestfs.org/)
- [QEMU Documentation](https://qemu-project.org/Documentation/)

Este guia cobre os métodos principais para trabalhar com imagens QCOW2 no Arch Linux. Escolha o método que melhor se adequa às suas necessidades!