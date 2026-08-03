# Tutorial Completo e Atualizado: Como Criar um Compartilhamento Samba no Linux e Acessar pelo Windows

Este guia ensina como instalar e configurar o Samba no Linux para compartilhar pastas e impressoras com máquinas Windows, usando as práticas mais recentes para nomenclatura de serviços, regras de firewall e solução de problemas.

---

## Parte 1: Instalação e Configuração Inicial

### 1. Instalar o Samba
Execute o comando de acordo com sua distribuição Linux.

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install samba smbclient cifs-utils
```

**Fedora/RHEL:**
```bash
sudo dnf install samba samba-client cifs-utils
```

### 2. Configurar o Arquivo `smb.conf`
O arquivo de configuração principal está em `/etc/samba/smb.conf`. Use o bloco abaixo como base, que já inclui as seções para compartilhamento de pastas e impressoras. Substitua `foo` pelo seu nome de usuário.

```bash
sudo nano /etc/samba/smb.conf
```

```ini
[global]
workgroup = WORKGROUP
security = user
printing = cups
printcap name = cups
load printers = yes
cups options = raw

# ===== COMPARTILHAMENTO DE IMPRESSORAS =====

[printers]
comment = Todas as Impressoras
path = /var/tmp
printable = Yes
create mask = 0600
browseable = Yes
guest ok = yes

[print$]
comment = Drivers de Impressora
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

# ===== COMPARTILHAMENTO DE ARQUIVOS =====
[shared]
comment = Pasta Compartilhada
path = /home/foo/Shared
browseable = yes
read only = no
guest ok = no
valid users = foo
force user = foo
create mask = 0664
directory mask = 0775
```
> **Nota:** A configuração `[HP-LaserJet-P1005]` é um exemplo de declaração manual de uma impressora específica. Ajuste o nome para corresponder à sua impressora.

### 3. Criar e Preparar a Pasta Compartilhada
Crie a pasta (se ela não existir) e ajuste as permissões locais.

```bash
mkdir -p /home/foo/Shared
chmod 755 /home/foo
chmod 775 /home/foo/Shared
```
> **Ajuste fino:** As permissões `775` permitem que o grupo leia e escreva. Para um ambiente mais permissivo em testes, pode-se usar `777`.

### 4. Configurar Senha para o Usuário Samba
A configuração `[shared]` usa `valid users = foo`. Para que o acesso funcione, crie uma senha Samba para este usuário.
```bash
sudo smbpasswd -a foo
```

---

## Parte 2: Firewall, Serviços e Descoberta de Rede

### 1. Liberar as Portas Corretas no Firewall
O comando `sudo ufw allow Samba` não funciona em todas as distribuições. Utilize as regras exatas para abrir as portas e, em seguida, recarregue o `ufw`.

```bash
# Resolução de nomes NetBIOS
sudo ufw allow 137/udp comment 'NetBIOS Name Resolution'

# Serviço de datagrama NetBIOS (navegação)
sudo ufw allow 138/udp comment 'NetBIOS Datagram'

# Sessão NetBIOS (compartilhamento) - Atenção: TCP
sudo ufw allow 139/tcp comment 'NetBIOS Session (Samba)'

# SMB sobre TCP/IP - Atenção: TCP
sudo ufw allow 445/tcp comment 'SMB over TCP (Samba)'

# Recarregar e verificar
sudo ufw reload
sudo ufw status verbose
```

### 2. Habilitar o Avahi Daemon (Opcional, mas Recomendado)
O `avahi-daemon` (mDNS) pode auxiliar na descoberta de serviços na rede local, complementando o NetBIOS.

```bash
sudo systemctl enable --now avahi-daemon
```
Verifique os logs se necessário:
```bash
sudo journalctl -u avahi-daemon --since "5 minutes ago"
```

### 3. Gerenciar os Serviços Samba (Forma Atualizada)
**Importante:** Em versões recentes do Samba (a partir de 2025/2026), os serviços são gerenciados separadamente como `smb` e `nmb`. O comando `smbd` ou `nmbd` foi descontinuado.

```bash
# Reiniciar ambos os serviços
sudo systemctl restart smb nmb

# Habilitar para iniciar com o sistema
sudo systemctl enable smb nmb

# Verificar o status
sudo systemctl status smb nmb
```

---

## Parte 3: Testes, Diagnóstico e Acesso

### 1. Testar a Configuração Localmente
Antes de conectar de outra máquina, execute estes comandos no servidor Linux para garantir que tudo está funcionando.

**Verificar a sintaxe do arquivo de configuração:**
```bash
testparm
```

**Listar os compartilhamentos Samba no servidor local:**
```bash
smbclient -L //127.0.0.1
```
Se você configurou uma senha, adicione a flag `-U foo` e digite a senha quando solicitado.

### 2. Testar a Descoberta de Rede e Resolução de Nomes
Use estes comandos para diagnosticar a visibilidade do servidor na rede NetBIOS e SMB.

```bash
# Lista todos os recursos Samba na rede (pode pedir senha, use -N para ignorar)
smbtree -N

# Testa a resolução de nomes NetBIOS na rede
nmblookup -S _smb._tcp

# Testa a resolução específica do nome do seu servidor
nmblookup SEU-SERVIDOR
```

### 3. Verificar Logs em Caso de Problemas
Se algo falhar, os logs são a melhor fonte de informação.

```bash
# Logs do servidor SMB (compartilhamento de arquivos e impressoras)
sudo journalctl -u smb --since "5 minutes ago"

# Logs do servidor NMB (resolução de nomes e navegação NetBIOS)
sudo journalctl -u nmb --since "5 minutes ago"

# Logs do CUPS (sistema de impressão)
sudo journalctl -u cups --since "5 minutes ago"

# Logs do Avahi (descoberta mDNS/DNS-SD)
sudo journalctl -u avahi-daemon --since "5 minutes ago"
```

### 4. Acessar a Pasta e a Impressora no Windows
O método mais confiável de acesso é sempre usar o endereço IP do servidor Linux.

**Para acessar a pasta:**
1.  Pressione `Win + R`, digite o IP e o nome do compartilhamento e clique em OK:
    `\\192.168.x.x\shared`
2.  Insira o nome de usuário (`foo`) e a senha configurada com o `smbpasswd`.

**Para acessar a impressora:**
1.  Vá ao Painel de Controle > Dispositivos e Impressoras > Adicionar uma impressora.
2.  Selecione "A impressora que eu quero não está listada".
3.  Escolha "Selecionar uma impressora compartilhada por nome" e insira o caminho no formato:
    `\\192.168.x.x\HP-LaserJet-P1005`
    > Substitua `HP-LaserJet-P1005` pelo nome exato da seção da sua impressora no `smb.conf`.

---