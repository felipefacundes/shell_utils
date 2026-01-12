# 📌 Tmux - Terminal Multiplexer

**What is Tmux?**
Tmux (Terminal Multiplexer) is a tool that allows you to manage multiple terminal sessions within a single window. It is especially useful for:
- Working with multiple terminals simultaneously
- Keeping processes running even after disconnecting from the server
- Customizing and increasing productivity in the terminal

## Basic tmux commands for tabs

### Start a tmux session:
```bash
tmux
tmux new -s sessionname    # Create a session with a specific name
```

### Create a new tab:
```
Ctrl-b c
```

### Navigate between tabs:
- **Next tab**: `Ctrl-b n`
- **Previous tab**: `Ctrl-b p`
- **Go to specific tab**: `Ctrl-b [number]` (0-9)
- **List tabs**: `Ctrl-b w`

### Rename the current tab:
```
Ctrl-b ,
```
Type the new name and press Enter.

# Rename current session from within tmux
```
Ctrl-b $
```

# Switch between sessions
```
Ctrl-b s
```

# Copy/paste (very important!)

# Copy mode
```
Ctrl-b [                    # Enter copy mode
Space                       # Start selection
Enter                       # Copy selection
Ctrl-b ]                    # Paste
```

# Use system clipboard (Linux/macOS)
# In .tmux.conf:
```
set -g set-clipboard on
bind-key -T copy-mode-vi y send-keys -X copy-pipe "pbcopy"  # macOS
bind-key -T copy-mode-vi y send-keys -X copy-pipe "xclip -i" # Linux
```

# Session groups

### Close current tab:
```
Ctrl-b &
```

## 3. Recommended configuration (~/.tmux.conf)

Create a configuration file to make usage easier:

```bash
# Create the configuration file
nano ~/.tmux.conf
```

Add these lines:
```
# Easier shortcuts for tabs
bind-key -n C-t new-window          # Ctrl-t creates new tab
bind-key -n C-Tab next-window       # Ctrl-Tab next tab
bind-key -n C-S-Tab previous-window # Ctrl-Shift-Tab previous tab

# Base index 1 (tabs start at 1)
set -g base-index 1
set-window-option -g pane-base-index 1

# Rename window with F2
bind-key F2 command-prompt "rename-window '%%'"

# Improved status bar
set -g status-interval 1
set -g status-left-length 20
set -g status-left '#[fg=green]#H #[fg=white]• #[fg=yellow,bright]#(uptime | cut -d" " -f 4-5 | cut -d"," -f1)#[default]'
set -g status-right '#[fg=cyan]#S:#I #[fg=white]• #[fg=yellow]%d/%m #[fg=white]• #[fg=cyan]%H:%M#[default]'

# Tab colors
set-window-option -g window-status-current-style bg=cyan,fg=black
set-window-option -g window-status-style bg=colour8,fg=white

# Mouse support (useful for resizing panels by dragging)
set -g mouse on

# Keep windows open after exiting (to restart tmux without losing layout)
set -g detach-on-destroy off
```

## 4. Custom shortcuts for 5 tabs

To quickly switch between 5 tabs, add to your `~/.tmux.conf`:

```
# Shortcuts to go directly to each tab
bind-key -n M-1 select-window -t 1  # Alt+1 goes to tab 1
bind-key -n M-2 select-window -t 2  # Alt+2 goes to tab 2
bind-key -n M-3 select-window -t 3  # Alt+3 goes to tab 3
bind-key -n M-4 select-window -t 4  # Alt+4 goes to tab 4
bind-key -n M-5 select-window -t 5  # Alt+5 goes to tab 5

# Reorganize tabs
bind-key r move-window -r          # Renumber tabs sequentially
```

## 5. Using tmux in your terminal

1. **To start automatically** with your terminal, add to your `~/.bashrc` or `~/.zshrc`:
```bash
# If not in an SSH session and no tmux session, start one
if [ -z "$TMUX" ] && [ -z "$SSH_CONNECTION" ]; then
    tmux attach || tmux new
fi
```

2. **To quickly create 5 tabs**:
```bash
tmux new-session -d
tmux new-window
tmux new-window
tmux new-window
tmux new-window
tmux attach
```

3. **Script to create tabs with specific commands**:
```bash
#!/bin/bash
tmux new-session -d -s myserver
tmux send-keys -t myserver:1 'ssh user@server1' C-m
tmux new-window -t myserver:2
tmux send-keys -t myserver:2 'ssh user@server2' C-m
tmux new-window -t myserver:3
tmux send-keys -t myserver:3 'htop' C-m
tmux attach -t myserver
```

## 6. Quick usage tips

- `Ctrl-b d` - Detach from tmux session (runs in background)
- `tmux attach` - Reconnect to session
- `tmux attach -t sessionname` - Connect to specific session
- `tmux ls` - List sessions
- `Ctrl-b "` - Split pane horizontally
- `Ctrl-b %` - Split pane vertically
- `Ctrl-b arrow` - Navigate between panes
- `Ctrl-b z` - Zoom/restore current pane (zoom toggle)
- `Ctrl-b Ctrl-arrow` - Resize current pane
- `Ctrl-b :` - Enter tmux command mode
- `Ctrl-b ?` - List all available shortcuts
- `Ctrl-b !` - Convert pane into separate window
- `tmux kill-session -t sessionname` - Terminate specific session
- `tmux kill-server` - Terminate all sessions

## 7. Useful commands outside tmux

```bash
# List all sessions
tmux list-sessions

# Create session with specific name
tmux new -s development

# Connect to specific session
tmux attach -t development

# Kill specific session
tmux kill-session -t development

# List available keybindings
tmux list-keys

# Reload configuration without disconnecting
tmux source-file ~/.tmux.conf
```

With this you'll have an efficient tab experience within the Terminal, being able to have multiple tabs and switch between them quickly!