# Complete GNU Screen Guide

## 📋 Table of Contents
- [Introduction](#introduction)
- [Installation](#installation)
- [Basic Concepts](#basic-concepts)
- [Basic Commands](#basic-commands)
- [Session Management](#session-management)
- [Window Management](#window-management)
- [Screen Splitting](#screen-splitting)
- [Internal Shortcuts (Screen Commands)](#internal-shortcuts-screen-commands)
- [Advanced Configuration](#advanced-configuration)
- [Common Use Cases](#common-use-cases)
- [Tips and Tricks](#tips-and-tricks)
- [Troubleshooting](#troubleshooting)
- [Alternatives](#alternatives)

## Introduction

**GNU Screen** is a terminal multiplexer that allows you to run multiple shell sessions within a single terminal window. It's an essential tool for system administrators and developers working with remote servers via SSH, as it enables:

- Keeping processes running even after disconnection
- Working with multiple terminals simultaneously
- Sharing sessions between users
- Creating personalized working environments

### Why Use Screen?
- **Persistence**: Sessions survive network disconnections
- **Productivity**: Quickly switch between different tasks
- **Resilience**: Protection against SSH connection drops
- **Collaboration**: Multiple users can view/control the same session

## Installation

### Linux (Debian/Ubuntu)
```bash
sudo apt update
sudo apt install screen
```

### Linux (RHEL/CentOS/Fedora)
```bash
sudo yum install screen
# or
sudo dnf install screen
```

### macOS
```bash
brew install screen
```

### Verify Installation
```bash
screen --version
```

## Basic Concepts

### 1. **Session**
A complete screen instance containing one or more windows. Each session has a unique name.

### 2. **Window**
Each shell within a session. A session can contain multiple windows.

### 3. **Region**
When the screen is split, each part is a region displaying a different window.

### 4. **Detach/Attach**
- **Detach**: Exit screen while keeping the session running in the background
- **Attach**: Reconnect to an existing session

## Basic Commands

### Create and Manage Sessions

| Command | Description | Example |
|---------|-----------|---------|
| `screen` | Starts new anonymous session | `screen` |
| `screen -S name` | Creates session with specific name | `screen -S development` |
| `screen -ls` | Lists all active sessions | `screen -ls` |
| `screen -r name` | Reconnects to specified session | `screen -r development` |
| `screen -rD name` | Forcefully reconnects (detaches from elsewhere) | `screen -rD session1` |
| `screen -dmS name` | Creates session in background (detached) | `screen -dmS server` |
| `screen -x name` | Shares existing session | `screen -x shared-session` |
| `screen -XS name quit` | Completely terminates session | `screen -XS session quit` |
| `screen -wipe` | Removes terminated sessions | `screen -wipe` |

### Practical Examples

```bash
# Creates a development session
screen -S dev

# Lists active sessions (shows IDs and names)
screen -ls

# Reconnects to session after disconnection
screen -r dev

# Creates session that automatically runs a script
screen -dmS backup bash -c "./backup.sh && echo 'Backup complete'"

# Shares session with colleague (they need access to the same user)
screen -S collaboration
# In another terminal:
screen -x collaboration
```

## Session Management

### Working with Multiple Sessions

```bash
# Session 1: Web server
screen -S webserver
# Starts server
python -m http.server 8080
# Ctrl+A d to detach

# Session 2: Log monitoring
screen -S logs
# Monitors logs
tail -f /var/log/syslog
# Ctrl+A d to detach

# Session 3: Database
screen -S database
# Accesses MySQL
mysql -u root -p
# Ctrl+A d to detach

# Lists all
screen -ls
# Shows 3 sessions in the list

# Switches between them
screen -r webserver
# Works...
Ctrl+A d
screen -r logs
# Works...
Ctrl+A d
```

### Persistent Sessions

```bash
# Creates session that survives logout
screen -S long-process
./process_that_takes_hours.sh
# Ctrl+A d
# Logs out of SSH
exit

# Reconnects later
ssh user@server
screen -r long-process
# Continues exactly where you left off!
```

## Window Management

### Create and Navigate Between Windows

Inside screen (all start with **Ctrl+A**):

| Shortcut | Description |
|--------|-----------|
| `Ctrl+A c` | Creates new window (shell) |
| `Ctrl+A n` | Goes to next window |
| `Ctrl+A p` | Goes to previous window |
| `Ctrl+A 0-9` | Goes to specific window (0-9) |
| `Ctrl+A '` | Prompts for window number/name to go to |
| `Ctrl+A "` | Lists all available windows |
| `Ctrl+A A` | Renames current window |
| `Ctrl+A k` | Kills current window |
| `Ctrl+a .` | Renames current session |

### Workflow Example

```bash
# Starts screen
screen -S project

# Window 0: Editor
vim file.py
# Ctrl+A c (new window)

# Window 1: Tests
python test_file.py
# Ctrl+A c (new window)

# Window 2: Logs
tail -f app.log
# Ctrl+A c (new window)

# Window 3: Database
mysql -u user -p database

# To list windows: Ctrl+A "
# To go to window 0: Ctrl+A 0
# To go to window 1: Ctrl+A 1
# To rename current window: Ctrl+A A, type "editor", Enter
```

## Screen Splitting

### Advanced Layouts

| Shortcut | Description |
|--------|-----------|
| `Ctrl+A S` | Splits screen horizontally |
| `Ctrl+A |` | Splits screen vertically |
| `Ctrl+A Tab` | Moves between regions |
| `Ctrl+A X` | Closes current region |
| `Ctrl+A Q` | Closes all regions except current |
| `Ctrl+A :resize` | Resizes current region |

### Split Screen Example

```bash
# Starts screen
screen -S monitor

# Splits horizontally
Ctrl+A S
# Now has two regions

# In bottom region, creates new window
Ctrl+A Tab (goes to bottom region)
Ctrl+A c (new window)
# Runs monitoring
htop

# Returns to top region
Ctrl+A Tab
# Works normally

# To close bottom region
Ctrl+A Tab (goes to bottom)
Ctrl+A X
```

## Internal Shortcuts (Screen Commands)

### Navigation and Control

| Shortcut | Description |
|--------|-----------|
| `Ctrl+A d` | Detach (exits screen keeping session) |
| `Ctrl+A ?` | Help (shows all commands) |
| `Ctrl+A Ctrl+\` | Exits screen (kills all windows) |
| `Ctrl+A [` | Copy/scroll mode (exit with Enter) |
| `Ctrl+A ]` | Pastes copied text |
| `Ctrl+A Esc` | Toggles copy mode (vi-style) |

### Monitoring

| Shortcut | Description |
|--------|-----------|
| `Ctrl+A M` | Monitors window for activity (alerts) |
| `Ctrl+A _` | Monitors window for silence (alerts when stops) |
| `Ctrl+A t` | Shows time and system load |

### Logs and Capture

| Shortcut | Description |
|--------|-----------|
| `Ctrl+A H` | Toggles session logging to file |
| `Ctrl+A :hardcopy -h file.log` | Saves complete buffer to file |
| `Ctrl+A >` | Saves scroll buffer to file |

### Command Line Commands

Inside screen, press `Ctrl+A :` to open command prompt:

```bash
# Examples:
:split     # Splits screen
:resize 10 # Resizes region to 10 lines
:kill      # Kills current window
:quit      # Exits screen
:source ~/.screenrc # Reloads configuration
```

## Advanced Configuration

### Configuration File (~/.screenrc)

```bash
# ~/.screenrc - Custom configuration

# Enables status bar
hardstatus alwayslastline
hardstatus string '%{= kG}[ %{G}%H %{g}][%= %{= kw}%?%-Lw%?%{r}(%{W}%n*%f%t%?(%u)%?%{r})%{w}%?%+Lw%?%?%= %{g}][%{B} %d/%m %{W}%c %{g}]'

# Larger scroll buffer
defscrollback 10000

# Disables startup message
startup_message off

# Default shell
shell -$SHELL

# Keys for splitting screen
bind S split
bind | split -v

# Custom shortcuts
bindkey ^D detach
bindkey ^[^[ exit

# Colors for windows
caption always "%{= kw}%-w%{= BW}%50>%n%f* %t%{-}%+w%<"

# Automatic logging
deflog on

# Enables activity display in bar
activity "Activity in %t(%n)"
```

### Useful Settings

```bash
# For specific projects
# ~/.screenrc_project

# Session title
sessionname "Project-X"

# Starts with 3 windows
screen -t "editor" 0 vim
screen -t "shell" 1
screen -t "logs" 2 tail -f /var/log/project.log

# Specific layout
layout new tres
focus
split
focus down
select 1
split -v
select 2
select 0
```

### Using Specific Configuration

```bash
screen -c ~/.screenrc_project
```

## Common Use Cases

### 1. Remote Development

```bash
# Sets up complete environment
screen -c ~/.screenrc_dev

# File ~/.screenrc_dev:
screen -t "code" 0 vim
screen -t "test" 1
screen -t "logs" 2
screen -t "db"   3 mysql -u dev -p
screen -t "git"  4
```

### 2. Server Administration

```bash
# Multiple service monitoring
screen -S monitoring
# Window 0: System logs
tail -f /var/log/syslog
# Ctrl+A c
# Window 1: Apache logs
tail -f /var/log/apache2/error.log
# Ctrl+A c
# Window 2: MySQL monitor
mysqladmin -i 5 processlist
```

### 3. Long-Running Processes

```bash
# Backup that takes hours
screen -S full-backup
./backup_script.sh
# Ctrl+A d (goes to background)
# Can disconnect from SSH

# Checks progress
screen -r full-backup
# If finished:
exit
```

### 4. Real-Time Collaboration

```bash
# User 1 creates shareable session
screen -S troubleshooting
# Begins diagnosing problem

# User 2 (on same server, same user)
screen -x troubleshooting
# Now both see and control the same session
```

## Tips and Tricks

### 1. Useful Session Names

```bash
screen -S dev_web        # Web development
screen -S db_maintenance # Database maintenance
screen -S deploy_prod    # Production deployment
screen -S monitoring     # Monitoring
screen -S batch_job      # Batch job
```

### 2. Automatic Cleanup Script

```bash
#!/bin/bash
# cleanup_screens.sh

# Removes sessions older than 7 days
screen -ls | grep -Eo '[0-9]+\.[^\s]+' | while read session; do
    if [[ $(stat -c %Y /tmp/screens/S-$session 2>/dev/null) -lt $(date -d '7 days ago' +%s) ]]; then
        screen -XS $session quit
    fi
done

# Removes old socket files
find /tmp/screens/ -name 'S-*' -mtime +7 -delete
```

### 3. SSH Integration

```bash
# Connects via SSH and starts screen automatically
ssh -t user@server "screen -r -D"

# Or creates if doesn't exist
ssh -t user@server "screen -S work -RD"
```

### 4. Configuration Backup

```bash
# Saves current layout
Ctrl+A :layout save my_layout

# Lists saved layouts
Ctrl+A :layout list

# Restores layout
Ctrl+A :layout load my_layout

# Exports to file
Ctrl+A :layout dump > layout.txt
```

### 5. Automated Logs

```bash
# Starts screen with automatic logging
screen -L -S logged_session
# Everything is logged to screenlog.0

# With specific name
screen -L -Logfile ~/logs/screen_$(date +%Y%m%d).log -S work
```

## Troubleshooting

### Common Problems and Solutions

#### 1. "There is no screen to be resumed"
```bash
# Session might be attached elsewhere
screen -rD session_name  # Forces detach and reconnect

# Or check if it really exists
screen -ls
```

#### 2. Frozen Session
```bash
# Try killing by PID
screen -ls
# Find the PID
kill -9 SCREEN_PID

# Or use wipe
screen -wipe
```

#### 3. Keys Not Working
```bash
# Screen might be in command mode
Press Ctrl+A q  # Releases keys

# Or check mapping
Ctrl+A :bind -d  # Removes problematic binding
```

#### 4. Color Problems
```bash
# In .screenrc:
term screen-256color
# or
term xterm-256color

# Force in command:
screen -T xterm-256color -S session
```

#### 5. Scroll Not Working
```bash
# Enable copy mode
Ctrl+A [  # Enters mode
# Use PageUp/PageDown or arrows
Enter     # Exits mode

# Increase buffer
Ctrl+A :scrollback 10000
```

### Diagnostic Commands

```bash
# Checks detailed status
screen -r session_name -Q windows
screen -r session_name -Q info

# Lists all sessions with details
screen -list

# Checks version and features
screen -v
```

## Alternatives to Screen

### 1. **tmux** (Recommended for new users)
- More modern and actively developed
- Better panel and scripting support
- More consistent syntax

```bash
# Basic tmux commands
tmux new -s name      # Creates session
Ctrl+b d              # Detach
tmux attach -t name   # Reattach
```

### 2. **byobu**
- User-friendly interface based on screen/tmux
- Information-rich status bars
- Good for beginners

### 3. **dtach**
- Simpler, only detach/attach
- Fewer features, lighter

### 4. **zellij**
- Written in Rust
- Modern with many features
- Good for development

## Migration from Screen to Tmux

If you want to migrate, here are equivalents:

| Screen | Tmux | Description |
|--------|------|-----------|
| `Ctrl+A` | `Ctrl+B` | Prefix |
| `Ctrl+A c` | `Ctrl+B c` | New window |
| `Ctrl+A n` | `Ctrl+B n` | Next window |
| `Ctrl+A d` | `Ctrl+B d` | Detach |
| `screen -ls` | `tmux ls` | List sessions |
| `screen -r` | `tmux attach` | Reattach |

## Additional Resources

### Official Documentation
- `man screen` - Complete manual
- `Ctrl+A ?` - Internal help
- [GNU Screen Website](https://www.gnu.org/software/screen/)

### Community
- Stack Overflow - Tag `gnu-screen`
- Linux administration forums
- Dotfiles repositories on GitHub

### Books and Tutorials
- "GNU Screen: The Complete Reference"
- Tutorials in Linux Journal
- Video tutorials on YouTube

---

## Conclusion

GNU Screen is a powerful tool that, once mastered, becomes indispensable for anyone working with remote servers or needing multiple terminal sessions. Although there are more modern alternatives like tmux, screen remains a solid choice and is widely available on virtually all Unix-like systems.

**Final Tip**: Start with basic commands and gradually incorporate more functionality into your routine. Soon, you won't be able to imagine working without it!

```
Ready to start? Execute: screen -S my_first_session
```

*This guide was created as a complete reference. Save it and share with your team!*