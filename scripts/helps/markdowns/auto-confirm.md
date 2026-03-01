# Automating Script Confirmations

A comprehensive guide to automating interactive confirmation prompts (yes/no) in shell scripts using `yes`, `printf`, and `expect`.

## 📋 Table of Contents

- [Introduction](#introduction)
- [The `yes` Command](#the-yes-command)
  - [Basic Usage](#basic-usage)
  - [Customizing Responses](#customizing-responses)
  - [Practical Examples](#practical-examples)
- [Multiple Responses with `printf`](#multiple-responses-with-printf)
- [Advanced Automation with `expect`](#advanced-automation-with-expect)
  - [Installing expect](#installing-expect)
  - [Basic Examples](#basic-examples)
  - [Complex Scripts](#complex-scripts)
- [Common Errors and Solutions](#common-errors-and-solutions)
- [Real-World Use Cases](#real-world-use-cases)
- [Best Practices](#best-practices)
- [References](#references)

## 🚀 Introduction

Many shell scripts and command-line programs require user interaction during execution, especially for confirmations of destructive actions or installations. In automated environments (such as deployment scripts, CI/CD pipelines, or batch installations), it's necessary to provide these responses automatically.

This guide presents the main techniques for automating confirmation prompts in shell scripts, from simple solutions with the `yes` command to complex automations with `expect`.

## 📦 The `yes` Command

The `yes` command is a simple but powerful Unix tool that repeats a string indefinitely until interrupted.

### Basic Usage

The most common way to use `yes` is to automatically respond "y" (yes) to all prompts:

```bash
# Automatically responds "y" to any prompt
$ yes | script.sh -option
```

**How it works:**
1. `yes` starts printing "y" infinitely
2. The pipe (`|`) redirects this output to the script
3. When the script requests input, it automatically receives "y"
4. The process continues until the script finishes

### Customizing Responses

`yes` accepts an optional argument to customize the response:

```bash
# Responds with "yes" instead of "y"
$ yes yes | script.sh -option

# Automatically responds "no"
$ yes no | script.sh -option

# Responds with custom text
$ yes "confirm" | script.sh -option
```

### Practical Examples

#### Automatic Installation with APT

```bash
# Install package without confirmation
$ yes | sudo apt-get install python3-pip

# For multiple packages
$ yes | sudo apt-get install nginx redis-server postgresql
```

#### Custom Installation Scripts

```bash
# Script that asks "Do you want to install? (y/n)"
$ yes | ./install.sh

# Script that expects explicit "yes"
$ yes yes | ./configure --prefix=/usr/local
```

#### Docker and Containers

```bash
# Remove all containers without confirmation
$ yes | docker system prune -a

# Clean up unused images
$ yes | docker image prune -a
```

## 🔄 Multiple Responses with `printf`

When a script asks several different questions or expects specific responses in sequence, `printf` offers more control:

### Basic Syntax

```bash
$ printf "response1\nresponse2\nresponse3\n" | script.sh
```

### Practical Examples

#### Script with Multiple Questions

```bash
# Script that asks:
# 1. Continue? (y/n)
# 2. Overwrite files? (y/n)
# 3. Send report? (y/n)

$ printf "y\nn\ny\n" | ./processing.sh
```

#### Installation with Configuration

```bash
# Installation script that asks:
# 1. Accept license? (yes/no)
# 2. Installation directory? (path)
# 3. Create shortcut? (y/n)

$ printf "yes\n/opt/app\nn\n" | ./installer.bin
```

#### Scripts with Multiple Options

```bash
# For scripts with interactive menus
$ printf "1\n/usr/local\nyes\n" | ./config_tool.sh
```

## 🎯 Advanced Automation with `expect`

For scripts with complex prompts, input validation, or when you need to respond based on the exact question content, `expect` is the ideal tool.

### Installing expect

```bash
# Debian/Ubuntu
$ sudo apt-get install expect

# RHEL/CentOS/Fedora
$ sudo yum install expect

# macOS
$ brew install expect
```

### Basic Examples

#### Simple Expect Script

Create a file `auto_response.exp`:

```expect
#!/usr/bin/expect

# Starts the script
spawn ./install_script.sh

# Waits for confirmation prompt
expect "Do you want to continue? (yes/no)"

# Sends the response
send "yes\r"

# Waits for the next prompt
expect "Enter installation directory:"
send "/opt/application\r"

# Waits for the script to finish
expect eof
```

Make it executable:

```bash
$ chmod +x auto_response.exp
$ ./auto_response.exp
```

#### Timeout Handling

```expect
#!/usr/bin/expect

set timeout 30
spawn ./long_script.sh

expect {
    "Continue?" { send "yes\r"; exp_continue }
    "Password:" { send "my_password\r" }
    timeout { puts "Timeout reached"; exit 1 }
    eof { puts "Script completed" }
}
```

### Complex Scripts

#### SSH with Expect

```expect
#!/usr/bin/expect

set host [lindex $argv 0]
set user [lindex $argv 1]
set password [lindex $argv 2]

spawn ssh $user@$host

expect {
    "password:" { 
        send "$password\r"
        exp_continue
    }
    "Yes/No" {
        send "Yes\r"
        exp_continue
    }
    "$ " {
        send "ls -la\r"
        expect "$ "
        send "exit\r"
    }
}

expect eof
```

#### Multi-Screen Installer

```expect
#!/usr/bin/expect

spawn ./guided_installer.sh

# Welcome screen
expect "Press Enter to continue"
send "\r"

# License
expect "Do you accept the terms? (yes/no)"
send "yes\r"

# Installation type
expect "Choose type (1-Basic, 2-Comprehensive):"
send "2\r"

# Final confirmation
expect "Start installation? (y/N)"
send "y\r"

# Wait for completion
expect "Installation complete!"
expect eof
```

## ❌ Common Errors and Solutions

### Error 1: Inverted Pipe

```bash
# ❌ WRONG
$ script.sh -option | yes

# ✅ CORRECT
$ yes | script.sh -option
```

### Error 2: Redirection Blocking Interaction

```bash
# ❌ WRONG - Redirects yes output, but also loses script output
$ yes | script.sh > /dev/null

# ✅ CORRECT - Keeps script output visible
$ yes | script.sh
```

### Error 3: Forgetting the Pipe

```bash
# ❌ WRONG - yes runs separately
$ yes
$ script.sh

# ✅ CORRECT - Connects yes to script
$ yes | script.sh
```

### Error 4: Case Sensitivity

```bash
# ❌ WRONG - Script expects "yes" but receives "y"
$ yes | ./script_that_expects_yes.sh

# ✅ CORRECT - Specifies exact response
$ yes yes | ./script_that_expects_yes.sh
```

### Error 5: Not Considering Multiple Prompts

```bash
# ❌ WRONG - First prompt gets "yes", second gets "yes" again
$ yes yes | ./script_with_two_prompts.sh

# ✅ CORRECT - Controls each response individually
$ printf "yes\nno\n" | ./script_with_two_prompts.sh
```

## 💡 Real-World Use Cases

### 1. Automated Deployment

```bash
#!/bin/bash
# deploy.sh

# Auto-response for destructive commands
yes | docker system prune -a
yes | ./clean_logs.sh
printf "production\nn\n" | ./configure_environment.sh
```

### 2. CI/CD Pipeline

```yaml
# .gitlab-ci.yml
deploy-job:
  script:
    - yes | ./install_dependencies.sh
    - printf "yes\n/dev/null\n" | ./configure --prefix=/app
    - make && make install
```

### 3. Automated Backup Script

```bash
#!/bin/bash
# auto_backup.sh

# Auto-response for overwriting old backups
yes | ./create_backup.sh --full

# Specific responses for different steps
printf "yes\n/backup/dir\nN\n" | ./backup_script.sh
```

### 4. Development Environment

```bash
#!/bin/bash
# setup_dev.sh

# Automatic environment configuration
yes | sudo apt-get update
yes | sudo apt-get install docker docker-compose

printf "development\nn\n" | ./init_project.sh

# Expect for database configuration
./config_db.exp
```

## 📝 Best Practices

### 1. **Always Test First**

```bash
# Test in a controlled environment
$ ./destructive_script.sh --dry-run
$ yes | ./destructive_script.sh
```

### 2. **Document Automations**

```bash
#!/bin/bash
# auto_install.sh - Script with documented automation

# AUTOMATION: Auto-responds "yes" for package installation
# Because: The package requires license confirmation
echo "Automatically installing package..."
yes yes | ./install_package.sh
```

### 3. **Use Variables for Responses**

```bash
#!/bin/bash

DEFAULT_RESPONSE="y"
LICENSE_RESPONSE="yes"
DIR_RESPONSE="/opt/app"

printf "%s\n%s\n%s\n" "$DEFAULT_RESPONSE" "$LICENSE_RESPONSE" "$DIR_RESPONSE" | ./config.sh
```

### 4. **Include Logging**

```bash
#!/bin/bash

exec > >(tee -a install.log) 2>&1

echo "Starting automated installation at $(date)"
yes | ./install.sh
echo "Installation completed at $(date)"
```

### 5. **Error Handling**

```bash
#!/bin/bash

if ! yes | ./script.sh; then
    echo "Error executing script"
    exit 1
fi
```

## 📚 References

### Manuals and Documentation

- `man yes` - Yes command manual
- `man printf` - Printf command manual
- `man expect` - Complete expect manual
- `man expect` (programming) - Expect programming guide

### Online Resources

- [GNU Coreutils: yes](https://www.gnu.org/software/coreutils/manual/html_node/yes-invocation.html)
- [Expect Project Page](https://core.tcl-lang.org/expect/index)
- [Tcl Expect Documentation](https://www.tcl.tk/man/expect/expect.1.html)

### Advanced Examples

- [Expect Scripts Repository](https://github.com/expect-scripts)
- [Auto-installation Examples](https://github.com/topics/auto-install)

## 🎉 Conclusion

Automating confirmations in scripts is an essential skill for system administrators and developers working with automation. The tools presented in this guide (`yes`, `printf`, and `expect`) offer solutions for different complexity levels:

- **`yes`** - Simple and straightforward for basic confirmations
- **`printf`** - Flexible for multiple sequential responses
- **`expect`** - Powerful for complex and customized interactions

Choose the appropriate tool for your use case and always test in safe environments before implementing in production.

---

**Contributions are welcome!** Found an error or have a suggestion? Open an issue or submit a pull request.