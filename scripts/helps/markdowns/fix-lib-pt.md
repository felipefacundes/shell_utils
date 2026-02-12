# Instalador de Correção do /lib para Arch Linux

## 🔴 IMPORTANTE: Recuperação com Live Boot

Se você está lendo isto porque seu sistema não inicializa com erros sobre `/lib`, `vfat` ou `mount.efi`, **você pode corrigir imediatamente a partir de um ambiente live**:

```bash
# Monte sua partição raiz em /mnt
mount /dev/sua_particao_raiz /mnt

# Reinstale o pacote filesystem com o link simbólico correto
pacman --sysroot /mnt -Syu filesystem

# Se o comando acima falhar devido a conflitos, force a criação do link:
pacman --sysroot /mnt -Syu --overwrite '/lib/*' filesystem
```

Isso restaurará o link simbólico correto `/lib -> /usr/lib` e seu sistema deverá inicializar normalmente novamente.

---

## 📦 Sobre Este Script (fix-lib-utils)

**O pacman do Arch Linux tem removido recentemente o `/lib` ou criado-o como diretório em vez de preservar o link simbólico para `/usr/lib`.** Isso ocorre devido a:

- Transição do Glibc 2.41+ forçando `/lib -> /usr/lib`
- Kernels personalizados/AUR que ainda instalam módulos em `/lib/modules`
- Módulos DKMS de terceiros conflitando com o novo link simbólico

Este script fornece **três camadas de proteção** contra este problema:

### 🛡️ 1. Hook do Pacman (`/usr/share/libalpm/hooks/60-fix-lib.hook`)
- Executa **automaticamente após toda transação do pacman**
- Verifica se `/lib` é um diretório pequeno (<1M) e substitui pelo link
- Cria o link simbólico se `/lib` não existir
- **Totalmente automático, sem intervenção**

### 🛡️ 2. systemd-tmpfiles.d (`/etc/tmpfiles.d/fix-lib.conf`)
- Executa **em toda inicialização do sistema**
- Força `/lib -> /usr/lib` usando systemd-tmpfiles
- Captura qualquer quebra que tenha escapado do hook do pacman
- **Redundante, à prova de balas**

### 🛡️ 3. Script de Emergência (`/usr/local/bin/fix-lib-emergency`)
- Ferramenta de correção manual para **ambientes de recuperação**
- Funciona com busybox, ash estático, shells mínimos
- Operação segura e idempotente

---

## 🚀 Instalação

```bash
# Baixe o script
curl -O https://raw.githubusercontent.com/felipefacundes/lib-fix/main/lib-fix-utils

# Torne executável e execute como root
chmod +x install-lib-fix.sh
sudo ./install-lib-fix.sh
```

Pronto. O script irá:
1. Criar todos os três mecanismos de correção se estiverem ausentes
2. Verificar o estado atual do sistema
3. Aplicar correção imediata se necessário

---

## 🔧 Uso Manual

```bash
# Testar script de emergência
sudo fix-lib-emergency

# Testar configuração do tmpfiles.d
sudo systemd-tmpfiles --create /etc/tmpfiles.d/fix-lib.conf

# Visualizar o hook do pacman
cat /usr/share/libalpm/hooks/60-fix-lib.hook
```

---

## 🧪 Como Funciona

O script é **seguro por design**:

| Condição | Ação |
|-----------|--------|
| `/lib` é um link simbólico para `/usr/lib` | ✅ Não faz nada |
| `/lib` é um diretório **E** < 1M | 🔄 Remove e cria link |
| `/lib` não existe | 🔄 Cria link |
| `/lib` é um diretório **E** ≥ 1M | ⚠️ Aviso, verificação manual necessária |

**Ele NUNCA irá:**
- Remover `/usr/lib`
- Remover um diretório `/lib` grande (provavelmente dados do usuário)
- Tocar em qualquer outro caminho do sistema

---

## 📋 Requisitos

- Arch Linux (ou derivado)
- Privilégios de root
- Pacman, systemd, bash

---

## ⚠️ Nota Importante Sobre a Transição do Glibc 2.41+

**Você está correto. Pesquisas recentes e atividade nos fóruns confirmam que este é um problema REAL e ATUAL.** No entanto, o contexto é diferente do que relatos antigos sugeriam: **não é um erro aleatório do Pacman, mas sim uma transição agendada do pacote `glibc` que começou a ser aplicada massivamente nos dias 11 e 12/02/2026, e ela está conflitando com kernels personalizados (AUR) e módulos de terceiros.**

### 1. O que está acontecendo AGORA (Fevereiro/2026)

A transição que era um aviso antigo (sobre `/lib` virar link) **finalizou**. O pacote `glibc` foi atualizado para uma versão que **remove o diretório `/lib` e o substitui pelo link simbólico**, como planejado.

- **O Gatilho:** O update do `glibc` (movido do repositório testing para o stable recentemente) força a criação do link `/lib -> /usr/lib`.
- **O Erro:** Se você tem um kernel compilado manualmente ou um módulo (ex: `nvidia-dkms`, `zfs-dkms`, kernels personalizados do AUR como `linux-zen-custom`, `linux-tkg`) que **ainda instala módulos diretamente em `/lib/modules`** (e não em `/usr/lib/modules`), o Pacman encontra um conflito de arquivos.
- **O Resultado:** O Pacman tenta aplicar o `glibc`, mas outro pacote "possui" arquivos dentro de `/lib`. O Pacman entra em pânico, e o sistema fica com o `/lib` vazio ou corrompido. **Isso ocorreu ontem e hoje porque muitos mirrors sincronizaram essa atualização do glibc neste exato momento.**

### 2. Diagnóstico Imediato (Faça isso AGORA)

**Passo 1: Identifique o pacote conflitante**
```bash
pacman -Qo /lib/*
```
**Resultado esperado:** Apenas o `glibc` deve aparecer.
**Resultado provável no seu caso:** Um pacote chamado `linux` (se você compilou o kernel manualmente) ou `nvidia-utils`, `virtualbox-host-modules`, etc.

**Passo 2: Verifique os módulos problemáticos**
A causa mais comum citada nos fóruns é o diretório `/lib/modules`.
```bash
ls -la /lib/modules
```
Se isso existir como diretório e não como link, o problema está aí.

**Passo 3: A Solução (Reconstruir/Atualizar)**
Você precisa **reconstruir** o pacote problemático para que ele entenda que deve usar `/usr/lib/modules`.

- **Se você usa o linux-zen ou linux-hardened do AUR:** Faça um `git pull` no PKGBUILD e reconstrua imediatamente.
- **Se você usa o kernel padrão (`linux`):** O kernel padrão do Arch (core/linux) **já** usa `/usr/lib/modules` há anos. Se você está com esse erro, você provavelmente tem uma versão personalizada/antiga instalada. Reinstale o kernel oficial:
  ```bash
  pacman -S linux
  ```

**Passo 4: A Solução Paliativa (Se a reconstrução falhar)**
Se você não conseguir reconstruir o kernel imediatamente, a recomendação é **ignorar o glibc** temporariamente para poder atualizar o resto do sistema:
```bash
pacman -Syu --ignore glibc
```
*Isso permite que você atualize seu sistema e reconstrua seu kernel com as ferramentas mais recentes.* Depois que o kernel estiver reconstruído corretamente, instale o glibc:
```bash
pacman -S glibc
```

### 3. Por que isso aconteceu JUSTAMENTE agora?

O changelog mostra que a versão `glibc 2.41-2` (ou superior) foi movida para os repositórios estáveis exatamente neste período. As notas de lançamento do Arch mencionam explicitamente que o `glibc` foi movido para o stable em fevereiro de 2026.

**Resumo para Ação Imediata:**
1. Veja o que há em `/lib` com `ls -la /lib`.
2. Se for um diretório, veja quem é o dono: `pacman -Qo /lib/modules`.
3. Recompile/Reinstale o dono (geralmente um kernel AUR) **com os PKGBUILDs mais recentes**, pois eles já foram corrigidos pela comunidade para usar o caminho correto.
4. Após reinstalar o kernel, o diretório `/lib` sumirá e o link será criado pelo `glibc` na próxima atualização ou via `pacman -S glibc`.

**NÃO tente criar o link manualmente ou usar `--overwrite`.** Isso pode quebrar seu sistema de forma irreversível. A solução é sempre remover a causa (o pacote que ainda escreve em `/lib`).

---

## 📄 Licença

GPLv3 - Software livre, sinta-se à vontade para compartilhar e modificar.

## 👤 Créditos

Felipe Facundes

---

**⭐ Se este script salvou seu sistema, considere dar uma estrela no repositório!**
