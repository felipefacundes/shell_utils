# Listagem de Permissões do Chmod (Sistema Octal)

## Índice
- [Permissões Básicas (0-7)](#permissões-básicas-0-7)
- [Estrutura de Três Dígitos](#estrutura-de-três-dígitos)
- [Permissões: Arquivos vs Diretórios](#permissões-arquivos-vs-diretórios)
- [Exemplos Comuns de Combinações](#exemplos-comuns-de-combinações)
- [Permissões Especiais (Primeiro Dígito Adicional)](#permissões-especiais-primeiro-dígito-adicional)
- [Bits Especiais no Contexto](#bits-especiais-no-contexto)
- [Combinações Frequentes para Diretórios](#combinações-frequentes-para-diretórios)
- [Fluxograma de Decisão para Permissões](#fluxograma-de-decisão-para-permissões)
- [Para Referência Rápida](#para-referência-rápida)
- [Configuração de Permissões e Propriedade](#configuração-de-permissões-e-propriedade)
- [Permitir Escrita por Programas](#permitir-escrita-por-programas)
- [Erros Comuns e Soluções](#erros-comuns-e-soluções)
- [Ferramentas Úteis](#ferramentas-úteis)
- [Verificação de Segurança](#verificação-de-segurança)

## Permissões Básicas (0-7)

**0** - Nenhuma permissão
- --- (nenhum acesso)
- Nenhuma operação permitida

**1** - Permissão de execução apenas
- --x (apenas execução/acesso)
- Permite executar arquivos ou acessar diretórios

**2** - Permissão de escrita apenas
- -w- (apenas escrita)
- Permite modificar/criar arquivos

**3** - Escrita e execução (1+2)
- -wx (escrita e execução)
- Permite modificar e executar/acessar

**4** - Permissão de leitura apenas
- r-- (apenas leitura)
- Permite visualizar conteúdo

**5** - Leitura e execução (4+1)
- r-x (leitura e execução)
- Permite ler e executar/acessar

**6** - Leitura e escrita (4+2)
- rw- (leitura e escrita)
- Permite ler e modificar

**7** - Todas as permissões (4+2+1)
- rwx (leitura, escrita, execução)
- Acesso completo

## Estrutura de Três Dígitos

**Primeiro dígito** - Permissões do proprietário (owner)
- 0-7 para o usuário dono do arquivo

**Segundo dígito** - Permissões do grupo
- 0-7 para membros do grupo do arquivo

**Terceiro dígito** - Permissões para outros
- 0-7 para todos os demais usuários

## Permissões: Arquivos vs Diretórios

### Para **arquivos**:
- `r` = ler conteúdo do arquivo
- `w` = modificar conteúdo do arquivo
- `x` = executar como programa

### Para **diretórios**:
- `r` = listar conteúdo (usar `ls`)
- `w` = criar/remover arquivos no diretório
- `x` = acessar o diretório (usar `cd` ou acessar arquivos dentro)

**Importante**: Para acessar um arquivo dentro de um diretório, você precisa de permissão `x` no diretório, independente das permissões do arquivo!

## Exemplos Comuns de Combinações

**600** - Acesso exclusivo do proprietário
- Usuário: rw- (6)
- Grupo: --- (0)
- Outros: --- (0)

**644** - Proprietário pode ler/escrever, outros só ler
- Usuário: rw- (6)
- Grupo: r-- (4)
- Outros: r-- (4)

**755** - Proprietário tem total, outros leem/executam
- Usuário: rwx (7)
- Grupo: r-x (5)
- Outros: r-x (5)

**777** - Permissão total para todos (perigoso!)
- Usuário: rwx (7)
- Grupo: rwx (7)
- Outros: rwx (7)

## Permissões Especiais (Primeiro Dígito Adicional)

**1000** - Sem bits especiais
- Permissões normais

**2000** - Bit sticky
- Apenas o dono pode deletar arquivos em diretórios compartilhados

**4000** - Bit setuid
- Arquivo é executado com permissões do dono

**6000** - Setuid + sticky
- Combinação de bits especiais

## Bits Especiais no Contexto

**setuid (4xxx)** - Quando aplicado a executáveis
- Exemplo: 4755 - Arquivo roda como dono, não como quem executa

**setgid (2xxx)** - Quando aplicado a diretórios
- Exemplo: 2775 - Arquivos criados herdam grupo do diretório

**sticky (1xxx)** - Para diretórios compartilhados
- Exemplo: 1777 - Qualquer um pode criar, só dono deleta (ex: /tmp)

## Combinações Frequentes para Diretórios

**700** - Diretório privado
- Apenas dono acessa

**755** - Diretório público
- Dono controla, outros leem e acessam

**775** - Diretório compartilhado em grupo
- Dono e grupo têm controle total

**1777** - Diretório temporário público
- Todos criam, só dono deleta

## Fluxograma de Decisão para Permissões

```
Precisa configurar permissões?
    ├── Apenas você? → 700
    ├── Você e seu grupo? → 770
    ├── Público, mas só leitura? → 755
    ├── Público, com escrita? → 777 (evitar!)
    ├── Uploads web? → 755 (dono: www-data)
    └── Diretório compartilhado? → 2775 + setgid
```

## Para Referência Rápida

0 = --- = Nenhum acesso

1 = --x = Apenas execução/acesso

2 = -w- = Apenas escrita

3 = -wx = Escrita + execução

4 = r-- = Apenas leitura

5 = r-x = Leitura + execução

6 = rw- = Leitura + escrita

7 = rwx = Leitura + escrita + execução

Para configurar permissões e propriedade de um diretório para um usuário específico no Linux, siga estes passos:

## Configuração de Permissões e Propriedade

### 1. **Permissões com `chmod`**

#### Para uso pessoal do usuário (apenas ele tem acesso):
```bash
chmod 700 /caminho/do/diretorio
```
- **7** (usuário): leitura, escrita e execução (rwx)
- **0** (grupo): nenhuma permissão
- **0** (outros): nenhuma permissão
- O usuário pode ler, gravar e acessar o diretório, outros não podem acessar

#### Para uso compartilhado com grupo específico:
```bash
chmod 750 /caminho/do/diretorio
```
- **7** (usuário): leitura, escrita e execução (rwx)
- **5** (grupo): leitura e execução (r-x)
- **0** (outros): nenhuma permissão

#### Para acesso público (leitura):
```bash
chmod 755 /caminho/do/diretorio
```
- **7** (usuário): leitura, escrita e execução (rwx)
- **5** (grupo): leitura e execução (r-x)
- **5** (outros): leitura e execução (r-x)

### 2. **Propriedade com `chown`**

#### Para mudar usuário e grupo:
```bash
chown usuario:grupo /caminho/do/diretorio
```

#### Exemplos práticos:

**Cenário 1:** Diretório pessoal para o usuário `joao`
```bash
sudo chown joao:joao /home/joao/meus-documentos
sudo chmod 700 /home/joao/meus-documentos
```

**Cenário 2:** Diretório compartilhado entre membros do grupo `dev`
```bash
sudo chown :dev /projetos
sudo chmod 775 /projetos
# Adiciona usuários ao grupo 'dev'
sudo usermod -a -G dev usuario1
sudo usermod -a -G dev usuario2
```

**Cenário 3:** Diretório web (servidor Apache/Nginx)
```bash
sudo chown www-data:www-data /var/www/html
sudo chmod 755 /var/www/html
```

### 3. **Ordem recomendada**

1. Primeiro mude o proprietário com `chown`
2. Depois ajuste as permissões com `chmod`

```bash
sudo chown usuario:grupo diretorio
sudo chmod permissoes diretorio
```

### 4. **Opções úteis**

- `-R`: Aplicar recursivamente (para subdiretórios e arquivos)
  ```bash
  sudo chown -R usuario:grupo diretorio
  sudo chmod -R permissoes diretorio
  ```

**Atenção:** Use `-R` com cuidado, especialmente em diretórios grandes ou sistemas críticos.

As permissões mais comuns para diretórios são `755` (público/leitura) e `750` ou `700` (privado). Escolha baseado no nível de acesso necessário.

Para permitir que um programa (processo) consiga escrever em um diretório, você precisa considerar **quem executa o programa** (qual usuário/grupo) e ajustar as permissões de acordo.

## Permitir Escrita por Programas

### **Cenários comuns:**

#### **1. Programa executado pelo proprietário do diretório**
Se o programa roda com o mesmo usuário que é dono do diretório:
```bash
# Diretório pertence ao usuário que executa o programa
chmod 755 /diretorio  # ou 750, dependendo do caso
```
Com `755` ou `750`, o proprietário (primeiro 7) já tem permissão de escrita.

#### **2. Programa executado por um usuário diferente**
Você tem várias opções:

##### **Opção A: Adicionar o usuário ao grupo do diretório**
```bash
# 1. Mudar grupo do diretório para um grupo compartilhado
sudo chown usuario:grupo_compartilhado /diretorio

# 2. Dar permissão de escrita ao grupo
sudo chmod 775 /diretorio

# 3. Adicionar o usuário do programa ao grupo
sudo usermod -a -G grupo_compartilhado usuario_do_programa
```

##### **Opção B: Dar permissão de escrita para "outros" (menos seguro)**
```bash
sudo chmod 777 /diretorio  # Qualquer usuário pode escrever
```
⚠️ **Não recomendado** para ambientes de produção - muito perigoso!

##### **Opção C: Usar ACLs (Access Control Lists) - mais flexível**
```bash
# Instalar utilitários ACL (se necessário)
# sudo apt install acl  # Debian/Ubuntu
# sudo yum install acl  # RHEL/CentOS

# Adicionar permissão específica para um usuário
sudo setfacl -m u:usuario_do_programa:rwx /diretorio

# Adicionar permissão para um grupo
sudo setfacl -m g:grupo_do_programa:rwx /diretorio

# Verificar ACLs
getfacl /diretorio

# Remover uma entrada ACL específica
sudo setfacl -x u:usuario /diretorio

# Remover todas as ACLs
sudo setfacl -b /diretorio

# Exemplo completo com herança (X maiúsculo = execução apenas para diretórios)
sudo setfacl -R -m u:usuario:rwX,d:u:usuario:rwX /diretorio
```

### **Casos práticos específicos:**

#### **A. Servidor Web (Apache/Nginx) escrevendo em diretório**
```bash
# Diretório de uploads de um site
sudo chown -R www-data:www-data /var/www/html/uploads
sudo chmod -R 775 /var/www/html/uploads

# Ou usando www-data como grupo
sudo chown -R seu_usuario:www-data /var/www/html/uploads
sudo chmod -R 775 /var/www/html/uploads
```

#### **B. Serviço do sistema escrevendo em diretório**
```bash
# Exemplo: serviço rodando como usuário 'mysql'
sudo chown mysql:mysql /var/lib/mysql/data
sudo chmod 755 /var/lib/mysql/data
```

#### **C. Múltiplos serviços/programas precisam escrever**
```bash
# Criar grupo específico
sudo groupadd escritores

# Adicionar usuários dos programas ao grupo
sudo usermod -a -G escritores usuario1
sudo usermod -a -G escritores usuario2

# Configurar diretório
sudo chown root:escritores /diretorio_compartilhado
sudo chmod 2775 /diretorio_compartilhado  # O '2' ativa o bit setgid
```

### **Bit setgid (especialmente útil para diretórios compartilhados)**
```bash
sudo chmod 2775 /diretorio
```
- **Bit setgid (2)**: Faz com que novos arquivos criados no diretório herdem o grupo do diretório
- Útil quando múltiplos usuários precisam compartilhar arquivos

### **Exemplo completo: Programa PHP escrevendo uploads**
```bash
# Diretório de uploads
sudo mkdir -p /var/www/uploads

# Opção 1: Usuário do servidor web como proprietário
sudo chown www-data:www-data /var/www/uploads
sudo chmod 755 /var/www/uploads

# Opção 2: Grupo compartilhado (mais flexível)
sudo groupadd webwriters
sudo usermod -a -G webwriters www-data
sudo usermod -a -G webwriters seu_usuario
sudo chown seu_usuario:webwriters /var/www/uploads
sudo chmod 2775 /var/www/uploads  # Com setgid
```

### **Verificação de permissões:**
```bash
# Ver usuário atual
whoami

# Ver permissões detalhadas
ls -la /diretorio

# Ver grupos de um usuário
groups usuario_do_programa

# Testar escrita
sudo -u usuario_do_programa touch /diretorio/teste.txt
```

### **Importante:**
1. **SELinux/AppArmor**: Em sistemas com segurança extra, pode bloquear mesmo com permissões corretas
2. **Espaço em disco**: Certifique-se de que há espaço disponível
3. **Diretório pai**: Verifique se o diretório pai também tem permissões adequadas

A abordagem mais segura geralmente é usar **grupos** ou **ACLs**, evitando permissões amplas como `777`.

## Erros Comuns e Soluções

### **Problema**: "Permissão negada" mesmo com permissões aparentemente corretas
- **Causa**: Diretório pai sem permissão de execução (`x`)
- **Solução**: `chmod +x /diretorio/pai`

### **Problema**: Script não executa mesmo com `chmod +x`
- **Causa**: Shebang incorreto ou arquivo em formato Windows (CRLF)
- **Solução**: 
  ```bash
  # Converter quebras de linha
  dos2unix script.sh
  
  # Verificar shebang
  head -1 script.sh  # Deve ser algo como #!/bin/bash
  
  # Verificar formato de arquivo
  file script.sh
  ```

### **Problema**: Permissões são redefinidas após reiniciar
- **Causa**: Sistema de arquivos remontando ou serviço reiniciando
- **Solução**: Verificar systemd unit files ou scripts de inicialização

### **Problema**: Não consegue deletar arquivo mesmo sendo dono
- **Causa**: Pode ter atributos imutáveis ou estar em uso
- **Solução**:
  ```bash
  # Verificar se arquivo está em uso
  lsof /caminho/arquivo
  
  # Verificar atributos estendidos
  lsattr /caminho/arquivo
  
  # Remover atributo imutável (se aplicável)
  chattr -i /caminho/arquivo
  ```

### **Problema**: Usuário não consegue acessar diretório mesmo com permissão `755`
- **Causa**: Pode estar em um sistema com namespace/mount específico
- **Solução**: Verificar montagens e namespaces
  ```bash
  mount | grep /diretorio
  findmnt /diretorio
  ```

## Ferramentas Úteis

### **Comandos básicos de verificação:**
- `stat arquivo` - Mostra permissões em octal e símbolos, além de outras informações
  ```bash
  stat arquivo.txt
  # Exibe: Acesso: (0644/-rw-r--r--) Uid: ( 1000/ usuario) Gid: ( 1000/ usuario)
  ```

- `umask` - Mostra máscara padrão de criação de arquivos
  ```bash
  umask  # Ex: 0022
  umask -S  # Ex: u=rwx,g=rx,o=rx
  ```

- `lsattr` / `chattr` - Atributos estendidos do sistema de arquivos
  ```bash
  lsattr arquivo
  chattr +i arquivo  # Torna imutável
  chattr -i arquivo  # Remove imutabilidade
  ```

- `namei -l /caminho/completo` - Mostra permissões de toda a hierarquia
  ```bash
  namei -l /home/usuario/documentos/arquivo.txt
  ```

### **Ferramentas avançadas:**
- `getfacl` / `setfacl` - Para Access Control Lists
- `auditctl` / `ausearch` - Para auditoria de acesso (SELinux contextos)
- `strace` - Para trace de chamadas do sistema (útil para debug)
  ```bash
  strace -e trace=file ls /diretorio  # Mostra todas as chamadas de arquivo
  ```

## Verificação de Segurança

### **Comandos para encontrar permissões potencialmente perigosas:**

```bash
# Encontrar arquivos com permissões 777 (muito permissivos)
find / -type f -perm 777 2>/dev/null

# Encontrar arquivos com SUID (set user ID)
find / -type f -perm /4000 2>/dev/null

# Encontrar arquivos com SGID (set group ID)
find / -type f -perm /2000 2>/dev/null

# Encontrar diretórios com sticky bit
find / -type d -perm /1000 2>/dev/null

# Encontrar arquivos/diretórios sem dono (orphaned)
find / -nouser -o -nogroup 2>/dev/null

# Encontrar arquivos executáveis em diretórios world-writable
find / -type f -perm -o+w -executable 2>/dev/null

# Encontrar diretórios world-writable
find / -type d -perm -o+w ! -path "/proc/*" ! -path "/sys/*" 2>/dev/null
```

### **Verificação de integridade:**
```bash
# Verificar arquivos de sistema importantes
sudo ls -la /etc/passwd /etc/shadow /etc/sudoers

# Deveriam ser:
# /etc/passwd: -rw-r--r-- (644)
# /etc/shadow: -rw-r----- (640) ou mais restrito
# /etc/sudoers: -r--r----- (440)
```

### **Monitoramento de mudanças:**
```bash
# Usar auditd para monitorar mudanças em diretórios críticos
sudo auditctl -w /etc/passwd -p wa -k passwd_changes
sudo auditctl -w /etc/shadow -p wa -k shadow_changes

# Ver logs de audit
sudo ausearch -k passwd_changes
```

### **Script de verificação rápida de segurança:**
```bash
#!/bin/bash
echo "=== Verificação de Permissões de Segurança ==="
echo ""
echo "1. Arquivos SUID perigosos:"
find / -type f -perm /4000 -ls 2>/dev/null | head -20

echo ""
echo "2. Diretórios world-writable (excluindo /tmp e /proc):"
find / -type d -perm -o+w ! -path "/tmp/*" ! -path "/proc/*" ! -path "/dev/*" 2>/dev/null | head -20

echo ""
echo "3. Arquivos de configuração importantes:"
for file in /etc/passwd /etc/shadow /etc/sudoers; do
    if [ -f "$file" ]; then
        echo "$file: $(stat -c '%A' "$file")"
    fi
done
```

Lembre-se: **Sempre revise os resultados desses comandos** antes de tomar qualquer ação, especialmente em sistemas de produção. Alguns arquivos SUID/SGID são necessários para o funcionamento normal do sistema (como `/usr/bin/passwd`).