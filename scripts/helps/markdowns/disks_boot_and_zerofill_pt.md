# Comandos para USB Bootável e Gerenciamento de Discos

## Criar USB Bootável

### Comando dd básico
```bash
sudo dd if=DISTRO.iso of=/dev/sdX bs=70k oflag=direct conv=sync status=progress && sync
```
Escreve ISO no USB com blocos de 70k, mostra progresso e sincroniza dados.

### Comando dd alternativo
```bash
sudo dd if=DISTRO.iso of=/dev/sdX count=1 bs=4M oflag=direct,dsync status=progress && sync
```
Usa blocos de 4M para escrita única com sync direto para transferência mais rápida.

## Comandos de Limpeza de Disco

### Apagar MBR e partições
```bash
sudo dd if=/dev/zero of=/dev/sdX bs=512 count=1
```
Sobrescreve primeiros 512 bytes (MBR + tabela de partições) com zeros.

### Apagar apenas MBR
```bash
sudo dd if=/dev/zero of=/dev/sdX bs=446 count=1
```
Sobrescreve apenas o bootloader de 446 bytes, mantendo tabela de partições.

## Limpeza Completa de Disco

### Preenchimento com zeros e sync
```bash
sudo dd if=/dev/zero of=/dev/sdX oflag=direct,dsync conv=fsync bs=1M status=progress
```
Preenche todo disco com zeros usando I/O direto e sync completo.

### Preenchimento básico com zeros
```bash
sudo dd if=/dev/zero of=/dev/sdX bs=1M status=progress
```
Preenchimento simples com zeros usando blocos de 1M.

### Preenchimento otimizado
```bash
sudo dd if=/dev/zero of=/dev/sdX bs=4M status=progress oflag=direct
```
Blocos de 4M com flag direto para limpeza mais rápida.

### Preenchimento com dados aleatórios
```bash
sudo dd if=/dev/urandom of=/dev/sdX bs=1M status=progress
```
Preenche disco com dados aleatórios para apagamento mais seguro.

## Operações Avançadas de Disco

### Comandos BLKDISCARD
```bash
sudo blkdiscard /dev/sdX
```
Descarta todos blocos em storage suportado (SSD/NVMe).

```bash
sudo blkdiscard -f /dev/sdX
```
Força descarte mesmo em sistemas de arquivos montados.

### Shred seguro
```bash
sudo shred -n3 -z -v /dev/sdX
```
Três passes de sobrescrita aleatória mais passagem final com zeros.

## Comandos de Segurança de Drive

### Verificar status de segurança
```bash
sudo hdparm -I /dev/sdX | grep -i "supported\|enabled\|frozen"
```
Mostra recursos de segurança e status atual do drive.

### Definir senha do drive
```bash
sudo hdparm --user-master u --security-set-pass PASSOU /dev/sdX
```
Define senha de usuário para segurança do drive.

### Apagamento seguro
```bash
sudo hdparm --user-master u --security-erase PASSOU /dev/sdX
```
Executa apagamento seguro usando senha definida anteriormente.

## Comandos Específicos NVMe

### Sanitize NVMe
```bash
sudo nvme sanitize /dev/nvme0nX
```
Inicia operação de sanitize NVMe para remoção segura de dados.

### Formatação NVMe
```bash
sudo nvme format /dev/nvme0nX --ses=1
```
Formata drive NVMe com apagamento de dados do usuário (ses=1).

---
O comando `sudo shred -n1 -z -v /dev/sdX` é uma excelente escolha para fazer um *zerofill* na unidade. Ele combina velocidade e segurança ao realizar uma passagem de dados aleatórios seguida por uma sobrescrita final com zeros.

### 🔍 Comparação de Métodos para Zerofill

A tabela abaixo compara o comando `shred` com outras alternativas comuns, como o `dd`, para ajudar você a escolher o melhor método para sua necessidade.

**`sudo shred -n1 -z -v /dev/sdX`** | 1 passagem com dados aleatórios + **1 passagem final com zeros**. Segurança reforçada com aleatoriedade, mantendo rastreamento simples. Combina segurança com final "invisível". Escolha ideal.
**`sudo dd if=/dev/zero of=/dev/sdX bs=1M status=progress`** | **Uma única passagem**, preenchendo todo o disco com zeros. Situações onde velocidade é crucial e dados não são sensíveis. Rápido e simples, mas sem aleatoriedade.

### ⚠️ Limitações Importantes em SSDs

Os comandos `shred` e `dd` podem **não ser totalmente eficazes** em unidades de estado sólido (SSDs) devido à tecnologia de **nivelamento de desgaste** (wear leveling). O controlador do SSD pode redirecionar as escritas para áreas físicas diferentes, deixando os dados originais em outros blocos de memória.

Para SSDs, os métodos mais confiáveis são:
*   **Comando `nvme format`**: Para discos NVMe, use `sudo nvme format /dev/nvme0n1 --ses=1` para um apagamento seguro pelo hardware.
*   **Comando `blkdiscard`**: Para SSDs que suportam o comando TRIM, `sudo blkdiscard /dev/sdX` é a opção mais rápida, invalidando todos os dados.
*   **ATA Secure Erase**: Um comando de firmware que ordena que o drive se auto-apague por completo.

### ✅ Como Executar com Segurança

Siga estes passos para evitar acidentes:

1.  **Identifique o dispositivo corretamente**: Use `sudo fdisk -l` ou `lsblk` para listar todos os discos e encontrar o identificador correto (ex: `/dev/sdb`).
2.  **Desmonte as partições**: Se houver partições montadas no dispositivo, desmonte-as primeiro com `sudo umount /dev/sdX1` (substitua "1" pelo número da partição).
3.  **Execute o comando**: Digite o comando cuidadosamente, verificando se `sdX` está correto. Use `shred -v` para ver o progresso.

---

**Aviso:** Estes comandos causam a perda permanente de dados. Sempre verifique o dispositivo alvo (`/dev/sdX`) antes de executar.