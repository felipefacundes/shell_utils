# 📌 Tmux - Terminal Multiplexer

**O que é Tmux?**
Tmux (Terminal Multiplexer) é uma ferramenta que permite gerenciar várias sessões de terminal dentro de uma única janela. É especialmente útil para:
- Trabalhar com múltiplos terminais simultaneamente
- Manter processos rodando mesmo após desconectar do servidor
- Personalizar e aumentar produtividade no terminal

## Comandos básicos do tmux para abas

### Iniciar uma sessão tmux:
```bash
tmux
tmux new -s nomedasessao    # Criar sessão com nome específico
```

### Criar uma nova aba:
```
Ctrl-b c
```

### Navegar entre abas:
- **Próxima aba**: `Ctrl-b n`
- **Aba anterior**: `Ctrl-b p`
- **Ir para aba específica**: `Ctrl-b [número]` (0-9)
- **Listar abas**: `Ctrl-b w`

### Renomear a aba atual:
```
Ctrl-b ,
```
Digite o novo nome e pressione Enter.

# Renomear sessão atual de dentro do tmux
```
Ctrl-b $
```

# Alternar entre sessões
```
Ctrl-b s
```

# Copiar/colar (muito importante!)

# Modo de cópia
```
Ctrl-b [                    # Entrar no modo de cópia
Espaço                      # Iniciar seleção
Enter                       # Copiar seleção
Ctrl-b ]                    # Colar
```

# Usar clipboard do sistema (Linux/macOS)
# No .tmux.conf:
```
set -g set-clipboard on
bind-key -T copy-mode-vi y send-keys -X copy-pipe "pbcopy"  # macOS
bind-key -T copy-mode-vi y send-keys -X copy-pipe "xclip -i" # Linux
```

# Sessões em grupo (session groups)

### Fechar aba atual:
```
Ctrl-b &
```

## 3. Configuração recomendada (~/.tmux.conf)

Crie um arquivo de configuração para facilitar o uso:

```bash
# Criar o arquivo de configuração
nano ~/.tmux.conf
```

Adicione estas linhas:
```
# Atalhos mais fáceis para abas
bind-key -n C-t new-window          # Ctrl-t cria nova aba
bind-key -n C-Tab next-window       # Ctrl-Tab próxima aba
bind-key -n C-S-Tab previous-window # Ctrl-Shift-Tab aba anterior

# Índice base 1 (abás começam em 1)
set -g base-index 1
set-window-option -g pane-base-index 1

# Renomear janela com F2
bind-key F2 command-prompt "rename-window '%%'"

# Status bar melhorada
set -g status-interval 1
set -g status-left-length 20
set -g status-left '#[fg=green]#H #[fg=white]• #[fg=yellow,bright]#(uptime | cut -d" " -f 4-5 | cut -d"," -f1)#[default]'
set -g status-right '#[fg=cyan]#S:#I #[fg=white]• #[fg=yellow]%d/%m #[fg=white]• #[fg=cyan]%H:%M#[default]'

# Cores das abas
set-window-option -g window-status-current-style bg=cyan,fg=black
set-window-option -g window-status-style bg=colour8,fg=white

# Mouse support (útil para redimensionar painéis com arrastar)
set -g mouse on

# Manter as janelas abertas após sair (para restartar tmux sem perder layout)
set -g detach-on-destroy off
```

## 4. Atalhos personalizados para 5 abas

Para alternar rapidamente entre 5 abas, adicione ao seu `~/.tmux.conf`:

```
# Atalhos para ir diretamente para cada aba
bind-key -n M-1 select-window -t 1  # Alt+1 vai para aba 1
bind-key -n M-2 select-window -t 2  # Alt+2 vai para aba 2
bind-key -n M-3 select-window -t 3  # Alt+3 vai para aba 3
bind-key -n M-4 select-window -t 4  # Alt+4 vai para aba 4
bind-key -n M-5 select-window -t 5  # Alt+5 vai para aba 5

# Reorganizar abas
bind-key r move-window -r          # Renumerar abas sequencialmente
```

## 5. Usando o tmux no seu terminal

1. **Para iniciar automaticamente** com o seu terminal, adicione ao seu `~/.bashrc` ou `~/.zshrc`:
```bash
# Se não estiver em uma sessão SSH e não tiver sessão tmux, inicia uma
if [ -z "$TMUX" ] && [ -z "$SSH_CONNECTION" ]; then
    tmux attach || tmux new
fi
```

2. **Para criar 5 abas rapidamente**:
```bash
tmux new-session -d
tmux new-window
tmux new-window
tmux new-window
tmux new-window
tmux attach
```

3. **Script para criar abas com comandos específicos**:
```bash
#!/bin/bash
tmux new-session -d -s meuservidor
tmux send-keys -t meuservidor:1 'ssh usuario@servidor1' C-m
tmux new-window -t meuservidor:2
tmux send-keys -t meuservidor:2 'ssh usuario@servidor2' C-m
tmux new-window -t meuservidor:3
tmux send-keys -t meuservidor:3 'htop' C-m
tmux attach -t meuservidor
```

## 6. Dicas rápidas de uso

- `Ctrl-b d` - Desanexar da sessão tmux (fica rodando em background)
- `tmux attach` - Reconectar à sessão
- `tmux attach -t nomedasessao` - Conectar a sessão específica
- `tmux ls` - Listar sessões
- `Ctrl-b "` - Dividir painel horizontalmente
- `Ctrl-b %` - Dividir painel verticalmente
- `Ctrl-b seta` - Navegar entre painéis
- `Ctrl-b z` - Ampliar/restaurar painel atual (zoom toggle)
- `Ctrl-b Ctrl-seta` - Redimensionar painel atual
- `Ctrl-b :` - Entrar no modo de comandos do tmux
- `Ctrl-b ?` - Listar todos os atalhos disponíveis
- `Ctrl-b !` - Converter painel em janela separada
- `tmux kill-session -t nomedasessao` - Encerrar sessão específica
- `tmux kill-server` - Encerrar todas as sessões

## 7. Comandos úteis fora do tmux

```bash
# Listar todas as sessões
tmux list-sessions

# Criar sessão com nome específico
tmux new -s desenvolvimento

# Conectar a sessão específica
tmux attach -t desenvolvimento

# Matar sessão específica
tmux kill-session -t desenvolvimento

# Listar keybindings disponíveis
tmux list-keys

# Recarregar configuração sem desconectar
tmux source-file ~/.tmux.conf
```

Com isso você terá uma experiência de abas eficiente dentro do Terminal, podendo ter múltiplas abas e alternar entre elas rapidamente!