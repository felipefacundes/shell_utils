# Guia Completo do GNU Screen

## 📋 Índice
- [Introdução](#introdução)
- [Instalação](#instalação)
- [Conceitos Básicos](#conceitos-básicos)
- [Comandos Básicos](#comandos-básicos)
- [Gerenciamento de Sessões](#gerenciamento-de-sessões)
- [Gerenciamento de Janelas](#gerenciamento-de-janelas)
- [Divisão de Tela](#divisão-de-tela)
- [Atalhos Internos (Comandos Screen)](#atalhos-internos-comandos-screen)
- [Configuração Avançada](#configuração-avançada)
- [Casos de Uso Comuns](#casos-de-uso-comuns)
- [Dicas e Truques](#dicas-e-truques)
- [Troubleshooting](#troubleshooting)
- [Alternativas](#alternativas)

## Introdução

O **GNU Screen** é um multiplexador de terminal que permite executar múltiplas sessões de shell dentro de uma única janela de terminal. É uma ferramenta essencial para administradores de sistemas e desenvolvedores que trabalham com servidores remotos via SSH, pois permite:

- Manter processos rodando mesmo após desconexão
- Trabalhar com múltiplos terminais simultaneamente
- Compartilhar sessões entre usuários
- Criar ambientes de trabalho personalizados

### Por que usar o Screen?
- **Persistência**: Sessões sobrevivem a desconexões de rede
- **Produtividade**: Alternar rapidamente entre diferentes tarefas
- **Resiliência**: Proteção contra quedas de conexão SSH
- **Colaboração**: Múltiplos usuários podem ver/controlar a mesma sessão

## Instalação

### Linux (Debian/Ubuntu)
```bash
sudo apt update
sudo apt install screen
```

### Linux (RHEL/CentOS/Fedora)
```bash
sudo yum install screen
# ou
sudo dnf install screen
```

### macOS
```bash
brew install screen
```

### Verificar instalação
```bash
screen --version
```

## Conceitos Básicos

### 1. **Sessão (Session)**
Uma instância completa do screen que contém uma ou mais janelas. Cada sessão tem um nome único.

### 2. **Janela (Window)**
Cada shell dentro de uma sessão. Uma sessão pode conter múltiplas janelas.

### 3. **Região (Region)**
Quando a tela é dividida, cada parte é uma região mostrando uma janela diferente.

### 4. **Detach/Attach**
- **Detach**: Sair do screen mantendo a sessão rodando em background
- **Attach**: Reconectar a uma sessão existente

## Comandos Básicos

### Criar e Gerenciar Sessões

| Comando | Descrição | Exemplo |
|---------|-----------|---------|
| `screen` | Inicia nova sessão anônima | `screen` |
| `screen -S nome` | Cria sessão com nome específico | `screen -S desenvolvimento` |
| `screen -ls` | Lista todas as sessões ativas | `screen -ls` |
| `screen -r nome` | Reconecta à sessão especificada | `screen -r desenvolvimento` |
| `screen -rD nome` | Força reconexão (detach de outros lugares) | `screen -rD sessao1` |
| `screen -dmS nome` | Cria sessão em background (detached) | `screen -dmS servidor` |
| `screen -x nome` | Compartilha sessão existente | `screen -x sessao-compartilhada` |
| `screen -XS nome quit` | Encerra sessão completamente | `screen -XS sessao quit` |
| `screen -wipe` | Remove sessões terminadas | `screen -wipe` |

### Exemplos Práticos

```bash
# Cria uma sessão para desenvolvimento
screen -S dev

# Lista sessões ativas (mostra IDs e nomes)
screen -ls

# Reconecta à sessão após desconexão
screen -r dev

# Cria sessão que executa script automaticamente
screen -dmS backup bash -c "./backup.sh && echo 'Backup completo'"

# Compartilha sessão com colega (ele precisa ter acesso ao mesmo usuário)
screen -S colaboracao
# Em outro terminal:
screen -x colaboracao
```

## Gerenciamento de Sessões

### Trabalhando com Múltiplas Sessões

```bash
# Sessão 1: Servidor web
screen -S webserver
# Inicia servidor
python -m http.server 8080
# Ctrl+A d para detach

# Sessão 2: Monitoramento de logs
screen -S logs
# Monitora logs
tail -f /var/log/syslog
# Ctrl+A d para detach

# Sessão 3: Banco de dados
screen -S database
# Acessa MySQL
mysql -u root -p
# Ctrl+A d para detach

# Lista todas
screen -ls
# Há 3 sessões na lista

# Alterna entre elas
screen -r webserver
# Trabalha...
Ctrl+A d
screen -r logs
# Trabalha...
Ctrl+A d
```

### Sessões Persistêntes

```bash
# Cria sessão que sobrevive a logout
screen -S processo-long
./processo_que_leva_horas.sh
# Ctrl+A d
# Faz logout do SSH
exit

# Reconecta mais tarde
ssh usuario@servidor
screen -r processo-long
# Continua exatamente onde parou!
```

## Gerenciamento de Janelas

### Criar e Navegar entre Janelas

Dentro do screen (todos começam com **Ctrl+A**):

| Atalho | Descrição |
|--------|-----------|
| `Ctrl+A c` | Cria nova janela (shell) |
| `Ctrl+A n` | Vai para próxima janela |
| `Ctrl+A p` | Vai para janela anterior |
| `Ctrl+A 0-9` | Vai para janela específica (0-9) |
| `Ctrl+A '` | Solicita número/nome da janela para ir |
| `Ctrl+A "` | Lista todas as janelas disponíveis |
| `Ctrl+A A` | Renomeia janela atual |
| `Ctrl+A k` | Mata (kill) janela atual |
| `Ctrl+a .` | Renomeia a sessão atual |

### Exemplo de Fluxo de Trabalho

```bash
# Inicia screen
screen -S projeto

# Janela 0: Editor
vim arquivo.py
# Ctrl+A c (nova janela)

# Janela 1: Testes
python test_arquivo.py
# Ctrl+A c (nova janela)

# Janela 2: Logs
tail -f app.log
# Ctrl+A c (nova janela)

# Janela 3: Banco de dados
mysql -u usuario -p banco

# Para listar janelas: Ctrl+A "
# Para ir para janela 0: Ctrl+A 0
# Para ir para janela 1: Ctrl+A 1
# Para renomear janela atual: Ctrl+A A, digite "editor", Enter
```

## Divisão de Tela

### Layouts Avançados

| Atalho | Descrição |
|--------|-----------|
| `Ctrl+A S` | Divide tela horizontalmente |
| `Ctrl+A |` | Divide tela verticalmente |
| `Ctrl+A Tab` | Move entre regiões |
| `Ctrl+A X` | Fecha região atual |
| `Ctrl+A Q` | Fecha todas as regiões exceto a atual |
| `Ctrl+A :resize` | Redimensiona região atual |

### Exemplo de Tela Dividida

```bash
# Inicia screen
screen -S monitor

# Divide horizontalmente
Ctrl+A S
# Agora tem duas regiões

# Na região inferior, cria nova janela
Ctrl+A Tab (vai para região inferior)
Ctrl+A c (nova janela)
# Executa monitoramento
htop

# Volta para região superior
Ctrl+A Tab
# Trabalha normalmente

# Para fechar região inferior
Ctrl+A Tab (vai para inferior)
Ctrl+A X
```

## Atalhos Internos (Comandos Screen)

### Navegação e Controle

| Atalho | Descrição |
|--------|-----------|
| `Ctrl+A d` | Detach (sai do screen mantendo sessão) |
| `Ctrl+A ?` | Ajuda (mostra todos os comandos) |
| `Ctrl+A Ctrl+\` | Sai do screen (mata todas as janelas) |
| `Ctrl+A [` | Modo cópia/scroll (sair com Enter) |
| `Ctrl+A ]` | Cola texto copiado |
| `Ctrl+A Esc` | Alterna modo cópia (vi-style) |

### Monitoramento

| Atalho | Descrição |
|--------|-----------|
| `Ctrl+A M` | Monitora janela por atividade (fica alerta) |
| `Ctrl+A _` | Monitora janela por silêncio (fica alerta quando para) |
| `Ctrl+A t` | Mostra hora e carga do sistema |

### Logs e Captura

| Atalho | Descrição |
|--------|-----------|
| `Ctrl+A H` | Ativa/desativa log da sessão para arquivo |
| `Ctrl+A :hardcopy -h arquivo.log` | Salva buffer completo para arquivo |
| `Ctrl+A >` | Salva buffer de scroll para arquivo |

### Comandos por Linha de Comando

Dentro do screen, pressione `Ctrl+A :` para abrir prompt de comandos:

```bash
# Exemplos:
:split     # Divide tela
:resize 10 # Redimensiona região para 10 linhas
:kill      # Mata janela atual
:quit      # Sai do screen
:source ~/.screenrc # Recarrega configuração
```

## Configuração Avançada

### Arquivo de Configuração (~/.screenrc)

```bash
# ~/.screenrc - Configuração personalizada

# Habilita barra de status
hardstatus alwayslastline
hardstatus string '%{= kG}[ %{G}%H %{g}][%= %{= kw}%?%-Lw%?%{r}(%{W}%n*%f%t%?(%u)%?%{r})%{w}%?%+Lw%?%?%= %{g}][%{B} %d/%m %{W}%c %{g}]'

# Buffer de scroll maior
defscrollback 10000

# Desativa mensagem inicial
startup_message off

# Shell padrão
shell -$SHELL

# Teclas para dividir tela
bind S split
bind | split -v

# Atalhos personalizados
bindkey ^D detach
bindkey ^[^[ exit

# Cores para janelas
caption always "%{= kw}%-w%{= BW}%50>%n%f* %t%{-}%+w%<"

# Log automático
deflog on

# Habilita visualização de atividade na barra
activity "Atividade em %t(%n)"
```

### Configurações Úteis

```bash
# Para usar em projetos específicos
# ~/.screenrc_projeto

# Título da sessão
sessionname "Projeto-X"

# Inicia com 3 janelas
screen -t "editor" 0 vim
screen -t "shell" 1
screen -t "logs" 2 tail -f /var/log/projeto.log

# Layout específico
layout new tres
focus
split
focus down
select 1
split -v
select 2
select 0
```

### Usando Configuração Específica

```bash
screen -c ~/.screenrc_projeto
```

## Casos de Uso Comuns

### 1. Desenvolvimento Remoto

```bash
# Configura ambiente completo
screen -c ~/.screenrc_dev

# Arquivo ~/.screenrc_dev:
screen -t "code" 0 vim
screen -t "test" 1
screen -t "logs" 2
screen -t "db"   3 mysql -u dev -p
screen -t "git"  4
```

### 2. Administração de Servidores

```bash
# Monitoramento de múltiplos serviços
screen -S monitoramento
# Janela 0: System logs
tail -f /var/log/syslog
# Ctrl+A c
# Janela 1: Apache logs
tail -f /var/log/apache2/error.log
# Ctrl+A c
# Janela 2: MySQL monitor
mysqladmin -i 5 processlist
```

### 3. Processos Longos

```bash
# Backup que leva horas
screen -S backup-completo
./backup_script.sh
# Ctrl+A d (vai para background)
# Pode desconectar do SSH

# Verifica progresso
screen -r backup-completo
# Se terminou:
exit
```

### 4. Colaboração em Tempo Real

```bash
# Usuário 1 cria sessão compartilhável
screen -S troubleshooting
# Começa a diagnosticar problema

# Usuário 2 (no mesmo servidor, mesmo usuário)
screen -x troubleshooting
# Agora ambos veem e controlam a mesma sessão
```

## Dicas e Truques

### 1. Nomes Úteis para Sessões

```bash
screen -S dev_web        # Desenvolvimento web
screen -S db_maintenance # Manutenção de banco
screen -S deploy_prod    # Deploy produção
screen -S monitoring     # Monitoramento
screen -S batch_job      # Job em lote
```

### 2. Script para Limpeza Automática

```bash
#!/bin/bash
# cleanup_screens.sh

# Remove sessões com mais de 7 dias
screen -ls | grep -Eo '[0-9]+\.[^\s]+' | while read session; do
    if [[ $(stat -c %Y /tmp/screens/S-$session 2>/dev/null) -lt $(date -d '7 days ago' +%s) ]]; then
        screen -XS $session quit
    fi
done

# Remove arquivos de socket antigos
find /tmp/screens/ -name 'S-*' -mtime +7 -delete
```

### 3. Integração com SSH

```bash
# Conecta via SSH e inicia screen automaticamente
ssh -t usuario@servidor "screen -r -D"

# Ou cria se não existir
ssh -t usuario@servidor "screen -S trabalho -RD"
```

### 4. Backup de Configuração

```bash
# Salva layout atual
Ctrl+A :layout save meu_layout

# Lista layouts salvos
Ctrl+A :layout list

# Restaura layout
Ctrl+A :layout load meu_layout

# Exporta para arquivo
Ctrl+A :layout dump > layout.txt
```

### 5. Logs Automatizados

```bash
# Inicia screen com log automático
screen -L -S sessao_logada
# Tudo é logado em screenlog.0

# Com nome específico
screen -L -Logfile ~/logs/screen_$(date +%Y%m%d).log -S trabalho
```

## Troubleshooting

### Problemas Comuns e Soluções

#### 1. "There is no screen to be resumed"
```bash
# A sessão pode estar anexada em outro lugar
screen -rD nome_sessao  # Força detach e reconnect

# Ou verifique se realmente existe
screen -ls
```

#### 2. Sessão Travada
```bash
# Tente matar pelo PID
screen -ls
# Encontre o PID
kill -9 PID_DO_SCREEN

# Ou use wipe
screen -wipe
```

#### 3. Teclas Não Funcionam
```bash
# Screen pode estar em modo de comando
Pressione Ctrl+A q  # Libera teclas

# Ou verifique mapeamento
Ctrl+A :bind -d  # Remove binding problemático
```

#### 4. Problemas com Cores
```bash
# No .screenrc:
term screen-256color
# ou
term xterm-256color

# Forçar no comando:
screen -T xterm-256color -S sessao
```

#### 5. Scroll Não Funciona
```bash
# Ative modo cópia
Ctrl+A [  # Entra no modo
# Use PageUp/PageDown ou setas
Enter     # Sai do modo

# Aumente buffer
Ctrl+A :scrollback 10000
```

### Comandos de Diagnóstico

```bash
# Verifica status detalhado
screen -r nome_sessao -Q windows
screen -r nome_sessao -Q info

# Lista todas as sessões com detalhes
screen -list

# Verifica versão e recursos
screen -v
```

## Alternativas ao Screen

### 1. **tmux** (Recomendado para novos usuários)
- Mais moderno e ativamente desenvolvido
- Melhor suporte a painéis e scripts
- Sintaxe mais consistente

```bash
# Comandos básicos tmux
tmux new -s nome      # Cria sessão
Ctrl+b d              # Detach
tmux attach -t nome   # Reattach
```

### 2. **byobu**
- Interface amigável baseada em screen/tmux
- Barras de status ricas em informações
- Boa para iniciantes

### 3. **dtach**
- Mais simples, apenas detach/attach
- Menos recursos, mais leve

### 4. **zellij**
- Escrito em Rust
- Moderno com muitos recursos
- Bom para desenvolvimento

## Migração do Screen para Tmux

Se quiser migrar, aqui equivalências:

| Screen | Tmux | Descrição |
|--------|------|-----------|
| `Ctrl+A` | `Ctrl+B` | Prefixo |
| `Ctrl+A c` | `Ctrl+B c` | Nova janela |
| `Ctrl+A n` | `Ctrl+B n` | Próxima janela |
| `Ctrl+A d` | `Ctrl+B d` | Detach |
| `screen -ls` | `tmux ls` | Lista sessões |
| `screen -r` | `tmux attach` | Reattach |

## Recursos Adicionais

### Documentação Oficial
- `man screen` - Manual completo
- `Ctrl+A ?` - Ajuda interna
- [GNU Screen Website](https://www.gnu.org/software/screen/)

### Comunidade
- Stack Overflow - Tag `gnu-screen`
- Fóruns de administração Linux
- Repositórios de dotfiles no GitHub

### Livros e Tutoriais
- "GNU Screen: The Complete Reference"
- Tutoriais no Linux Journal
- Video tutorials no YouTube

---

## Conclusão

O GNU Screen é uma ferramenta poderosa que, uma vez dominada, se torna indispensável para qualquer pessoa que trabalhe com servidores remotos ou necessite de múltiplas sessões de terminal. Embora existam alternativas mais modernas como tmux, o screen continua sendo uma escolha sólida e amplamente disponível em praticamente todos os sistemas Unix-like.

**Dica Final**: Comece com os comandos básicos e gradualmente incorpore mais funcionalidades à sua rotina. Em pouco tempo, você não conseguirá imaginar trabalhar sem ele!

```
Pronto para começar? Execute: screen -S minha_primeira_sessao
```

*Este guia foi criado para ser referência completa. Salve-o e compartilhe com sua equipe!*