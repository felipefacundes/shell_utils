# Tutorial Completo: Compartilhamento de Impressora via CUPS e Samba com Firewall UFW

---

## 📋 Sumário
1. [Compartilhando a Impressora via CUPS](#1-compartilhando-a-impressora-via-cups)
2. [Compartilhando a Impressora via Samba](#2-compartilhando-a-impressora-via-samba)
3. [Configurando o Firewall UFW](#3-configurando-o-firewall-ufw)
4. [Testando a Configuração](#4-testando-a-configuração)

---

## 1. Compartilhando a Impressora via CUPS

O CUPS (Common UNIX Printing System) é o sistema de impressão padrão no Linux. Para compartilhar sua impressora na rede via IPP (Internet Printing Protocol), siga os passos abaixo:

### 1.1 Identificar a Impressora

Primeiro, liste todas as impressoras instaladas no sistema:

```bash
lpstat -p
```

Exemplo de saída:
```
printer HP-LaserJet-P1005 is idle. enabled since Thu 01 Jan 2026 10:00:00 AM -03
```

Anote o nome exato da sua impressora (no exemplo: `HP-LaserJet-P1005`).

### 1.2 Habilitar o Compartilhamento de Impressoras

Ative o compartilhamento de impressoras no CUPS:

```bash
cupsctl --share-printers
```

> **Nota:** Será solicitada a senha do usuário (a mesma usada para o `sudo`).

### 1.3 Compartilhar a Impressora Específica

Compartilhe a impressora identificada no passo anterior:

```bash
lpadmin -p nome-da-impressora -o printer-is-shared=true
```

Substitua `nome-da-impressora` pelo nome obtido com `lpstat -p`.

**Exemplo prático:**
```bash
lpadmin -p HP-LaserJet-P1005 -o printer-is-shared=true
```

### ✅ Pronto!

Sua impressora já está compartilhada via CUPS na rede usando o protocolo IPP. **Não é necessário** alterar o arquivo `/etc/cups/cupsd.conf` para que isso funcione.

---

## 2. Compartilhando a Impressora via Samba

O Samba permite compartilhar a impressora usando o protocolo SMB/CIFS, tornando-a acessível para máquinas Windows e outros sistemas.

### 2.1 Configurar o Arquivo smb.conf

Edite o arquivo de configuração do Samba:

```bash
sudo nano /etc/samba/smb.conf
```

### 2.2 Modelo Completo de smb.conf

Abaixo está um arquivo `smb.conf` funcional que inclui **compartilhamento de impressora** e **compartilhamento de arquivos** como bônus:

```ini
[global]
workgroup = WORKGROUP
security = user
printing = cups
printcap name = cups
load printers = yes
cups options = raw

[printers]
comment = HP Laserjet P1005 in Network
path = /var/tmp
printable = Yes
create mask = 0600
browseable = Yes
guest ok = yes

[print$]
comment = Printer Drivers
path = /var/lib/samba/drivers
write list = root, @printadmin
force group = @printadmin
create mask = 0664
directory mask = 0775

[HP-LaserJet-P1005]
comment = HP LaserJet P1005
path = /var/tmp
printable = yes
guest ok = yes
browseable = yes
create mask = 0600

# ===== COMPARTILHAMENTO DE ARQUIVOS (BÔNUS) =====
# Substitua "foo" pelo seu nome de usuário
[shared]
comment = Shared Folder
path = /home/foo/Shared
browseable = yes
read only = no
guest ok = no
create mask = 0664
force user = foo
valid users = foo
directory mask = 0775
```

### 2.3 Explicação das Seções

| Seção | Descrição |
|-------|-----------|
| `[global]` | Configurações gerais do Samba: grupo de trabalho, segurança e integração com CUPS |
| `[printers]` | Seção genérica para todas as impressoras compartilhadas |
| `[print$]` | Compartilhamento para drivers de impressora (necessário para clientes Windows) |
| `[HP-LaserJet-P1005]` | Seção específica da sua impressora com permissões detalhadas |
| `[shared]` | (Bônus) Pasta compartilhada para arquivos - substitua `foo` pelo seu usuário |

### 2.4 Reiniciar os Serviços Samba

Com as novas versões do Samba, os serviços foram renomeados. Reinicie os serviços corretos:

```bash
sudo systemctl restart smb nmb
```

> **Nota:** Em versões mais antigas, o comando era `sudo systemctl restart smbd nmbd`. O comando acima é para distribuições modernas.

### 2.5 Verificar se os Serviços Estão Rodando

```bash
sudo systemctl status smb nmb
```

Certifique-se de que ambos estão com status `active (running)`.

---

## 3. Configurando o Firewall UFW

Com o UFW ativo, a impressora pode não ser encontrada mesmo com as portas liberadas. Siga estas regras exatas que foram testadas e funcionam.

### 3.1 Liberar Portas para CUPS/IPP

```bash
# Descoberta mDNS (para encontrar a impressora na rede)
sudo ufw allow 5353/udp comment 'mDNS discovery'
sudo ufw allow in to 224.0.0.251 port 5353 proto udp comment 'Allow mDNS discovery'
sudo ufw allow out to 224.0.0.251 port 5353 proto udp comment 'Allow mDNS queries'

# Comunicação IPP (envio de trabalhos)
sudo ufw allow 631/tcp comment 'IPP printing'
sudo ufw allow 631/udp comment 'IPP legacy browsing'

# Regras de entrada e saída para IPP
sudo ufw allow in to any port 631 proto tcp comment 'IPP responses (in)'
sudo ufw allow out to any port 631 proto tcp comment 'IPP printing (out)'
```

### 3.2 Liberar Portas para Samba

```bash
# Resolução de nomes NetBIOS
sudo ufw allow 137/udp comment 'NetBIOS Name Resolution'

# Serviço de datagrama NetBIOS (navegação)
sudo ufw allow 138/udp comment 'NetBIOS Datagram'

# Sessão NetBIOS (compartilhamento) - ATENÇÃO: TCP, não UDP!
sudo ufw allow 139/tcp comment 'NetBIOS Session (Samba)'

# SMB sobre TCP/IP - ATENÇÃO: TCP, não UDP!
sudo ufw allow 445/tcp comment 'SMB over TCP (Samba)'
```

### 3.3 Aplicar as Regras e Recarregar

```bash
sudo ufw reload
```

### 3.4 Verificar o Status Final

```bash
sudo ufw status verbose
```

### 📌 Exemplo de Saída Esperada

```
Status: active

To                         Action      From
--                         ------      ----
22                         ALLOW       Anywhere                  
5353/udp                   ALLOW       Anywhere                  
224.0.0.251 5353/udp       ALLOW       Anywhere                   # Allow mDNS discovery
224.0.0.251 5353/udp       ALLOW OUT   Anywhere                   # Allow mDNS queries
631/tcp                    ALLOW       Anywhere                   # IPP printing
631/udp                    ALLOW       Anywhere                   # IPP legacy browsing
631/tcp                    ALLOW IN    Anywhere                   # IPP responses (in)
631/tcp                    ALLOW OUT   Anywhere                   # IPP printing (out)
137/udp                    ALLOW       Anywhere                   # NetBIOS Name Resolution
138/udp                    ALLOW       Anywhere                   # NetBIOS Datagram
139/tcp                    ALLOW       Anywhere                   # NetBIOS Session (Samba)
445/tcp                    ALLOW       Anywhere                   # SMB over TCP (Samba)
```

> **Importante:** Observe que as portas **139** e **445** estão configuradas como **TCP**. Configurá-las como UDP impede a descoberta da impressora.

---

## 4. Testando a Configuração

### 4.1 Testar Descoberta CUPS/IPP

```bash
# Verifica se a impressora aparece via mDNS
avahi-browse -rt _ipp._tcp
avahi-browse -rt _printer._tcp

# Lista impressoras disponíveis via rede
lpinfo -v | grep "network socket"
```

### 4.2 Testar Descoberta Samba/NetBIOS

```bash
# Lista todos os recursos Samba na rede
smbtree -N

# Testa a resolução de nomes NetBIOS
nmblookup -S _smb._tcp

# Testa resolução específica (substitua pelo nome do servidor)
nmblookup SEU-SERVIDOR
```

### 4.3 Verificar Logs em Caso de Problemas

```bash
# Logs do CUPS
sudo journalctl -u cups --since "5 minutes ago"

# Logs do Samba
sudo journalctl -u smb --since "5 minutes ago"
sudo journalctl -u nmb --since "5 minutes ago"

# Logs do Avahi (mDNS)
sudo journalctl -u avahi-daemon --since "5 minutes ago"
```

---

## 🎯 Resumo dos Comandos Essenciais

### Para Compartilhar via CUPS:
```bash
lpstat -p                              # Identificar impressora
cupsctl --share-printers               # Habilitar compartilhamento
lpadmin -p NOME-DA-IMPRESSORA -o printer-is-shared=true
```

### Para Compartilhar via Samba:
```bash
sudo nano /etc/samba/smb.conf          # Configurar conforme modelo
sudo systemctl restart smb nmb        # Reiniciar serviços (versões modernas)
```

### Para Configurar Firewall UFW:
```bash
# CUPS/IPP
sudo ufw allow 5353/udp
sudo ufw allow in to 224.0.0.251 port 5353 proto udp
sudo ufw allow out to 224.0.0.251 port 5353 proto udp
sudo ufw allow 631/tcp
sudo ufw allow 631/udp

# Samba (atenção: TCP nas portas 139 e 445)
sudo ufw allow 137/udp
sudo ufw allow 138/udp
sudo ufw allow 139/tcp
sudo ufw allow 445/tcp

sudo ufw reload
sudo ufw status verbose
```

### Para Reiniciar Todos os Serviços:
```bash
sudo systemctl restart cups smb nmb avahi-daemon
```

---

## ⚠️ Observações Finais

1. **Não é necessário** alterar o arquivo `/etc/cups/cupsd.conf` para o compartilhamento funcionar
2. **Não é necessário** alterar o arquivo `/etc/ufw/before.rules` - as regras padrão do UFW são suficientes
3. As portas **139/tcp** e **445/tcp** são **TCP**, não UDP
4. O comando correto para reiniciar o Samba é `sudo systemctl restart smb nmb` (não `smbd nmbd`)
5. O compartilhamento de arquivos via Samba é um bônus que não interfere na impressão

---

**Documentação elaborada com base em configuração testada e funcional.** 🖨️