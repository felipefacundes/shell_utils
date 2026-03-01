# I'll detail the entire Bash completion system, including the parameters of the `complete` command, the `-o` options, and the most important native functions.

## 📋 **COMPLETE COMMAND - BASIC STRUCTURE**

```bash
complete [-abcdefgjksuv] [-o comp-option] [-A action] [-G globpat] [-W wordlist] [-P prefix] [-S suffix] [-X filterpat] [-F function] [-C command] name [name...]
```

## 🔧 **COMPLETION PARAMETERS BY TYPE**

| Parameter | Description | Example |
|-----------|-------------|---------|
| `-a` | Completes with aliases | `complete -a mycommand` |
| `-b` | Completes with shell builtins | `complete -b mycommand` |
| `-c` | Completes with commands | `complete -c mycommand` |
| `-d` | Completes only with directories | `complete -d mycommand` |
| `-f` | Completes with files | `complete -f mycommand` |
| `-g` | Completes with system groups | `complete -g mycommand` |
| `-j` | Completes with running jobs | `complete -j mycommand` |
| `-k` | Completes with reserved words | `complete -k mycommand` |
| `-s` | Completes with services | `complete -s mycommand` |
| `-u` | Completes with users | `complete -u mycommand` |
| `-v` | Completes with variables | `complete -v mycommand` |

## 🎯 **-A (ACTION) OPTIONS - SPECIFIC COMPLETIONS**

| Action | Description |
|------|-------------|
| `-A alias` | Alias names |
| `-A arrayvar` | Array variable names |
| `-A binding` | Readline key binding names |
| `-A builtin` | Shell builtin names |
| `-A command` | Command names |
| `-A directory` | Directory names |
| `-A disabled` | Disabled builtins |
| `-A enabled` | Enabled builtins |
| `-A export` | Exported variables |
| `-A file` | File names |
| `-A function` | Shell function names |
| `-A group` | Group names |
| `-A helptopic` | Help topics |
| `-A hostname` | Host names |
| `-A job` | Job names |
| `-A keyword` | Reserved words |
| `-A running` | Running jobs |
| `-A service` | Service names |
| `-A setopt` | Options for the `set` command |
| `-A shopt` | `shopt` options |
| `-A signal` | Signal names |
| `-A stopped` | Stopped jobs |
| `-A user` | User names |
| `-A variable` | All shell variables |

## ⚙️ **-O (COMP-OPTION) OPTIONS - BEHAVIOR CONTROL**

| Option | Description | Usage example |
|--------|-------------|----------------|
| `-o default` | Uses default Readline completion (files) if no match is found | `complete -o default mycommand` |
| `-o bashdefault` | Uses default Bash completions if no match is found (includes `~`, `$`, `@` expansion) | `complete -o bashdefault -o default mycommand` |
| `-o filenames` | **TREATS AS FILES** - Adds slash `/` to directories, escapes special characters, does not add space after directories | `complete -o filenames codium` ✅ *Your success case* |
| `-o dirnames` | Completes directories if no matches | `complete -o dirnames mycommand` |
| `-o nospace` | Does not add a space after completion | `complete -o nospace -W "start stop" service` |
| `-o plusdirs` | Adds directory completion after generated matches | `complete -o plusdirs -f mycommand` |
| `-o nosort` | Does not sort matches alphabetically | `complete -o nosort -W "zebra avocado" mycommand` |

## 📌 **SPECIAL CASES: -E, -D, -I**

| Option | Context | Description |
|--------|---------|-------------|
| `-E` | **Empty command** | Defines completion for when nothing has been typed (useful for aliases) | `complete -E` |
| `-D` | **Default command** | Defines completion for commands without their own definition | `complete -D` |
| `-I` | **Initial name** | Completion for initial file names | `complete -I` |

✅ *In your case, `code` (alias) needed `-E` because Bash treats aliases specially*

## 🧰 **NATIVE BASH-COMPLETION FUNCTIONS**

These functions are defined when the `bash-completion` package is installed:

### **`_filedir`** - Main function for files/directories

```bash
_filedir           # Completes files and directories
_filedir -d        # Completes only directories
_filedir "txt|pdf" # Completes only .txt or .pdf files (case insensitive)
```

**Behavior:**
- Uses `compgen -f` for files, `compgen -d` for directories
- Applies `compopt -o filenames` automatically
- Supports filter by extension with case insensitivity (`txt` and `TXT`)
- Variable `COMP_FILEDIR_FALLBACK` tries without filter if nothing is found

### **`_filedir_xspec`** - Files with specific patterns

```bash
_filedir_xspec "txt|pdf"  # Completes only .txt or .pdf files
```

**Difference from `_filedir`:**
- Uses Xspec patterns (eXtended SPECifications)
- Integrates with the file type completion system
- Ideal for commands that work with specific types (e.g., `grep` with text files)

✅ *In your case, it worked with `complete -o default -o bashdefault -F _filedir_xspec -E code`*

### **`_command`** - Completes commands

```bash
_command           # Completes commands available in PATH
_command_offset 0  # Completes commands starting from position 0
```

**Usage:** To complete command names (like the first argument of `sudo`)

### **`_command_offset`** - Commands at specific positions

```bash
_command_offset 1  # Completes commands starting from position 1
```

## 🔍 **OTHER USEFUL COMMANDS**

```bash
# List all defined completions
complete -p

# Remove completion for a specific command
complete -r command

# Remove ALL completions
complete -r

# Check completion for a command
complete -p command
```

## 🎨 **PRACTICAL EXAMPLES**

```bash
# 1. Only files (NO space after directories)
complete -o filenames codium  # ✅ Your case

# 2. Files + default Bash completion (~, $, @)
complete -o filenames -o bashdefault -o default myapp

# 3. First argument: fixed words, then: files
complete -F _myapp myapp
_myapp() {
    local cur prev
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    if [[ $COMP_CWORD -eq 1 ]]; then
        # First argument: specific options
        COMPREPLY=($(compgen -W "start stop restart status" -- "$cur"))
        [[ $COMPREPLY ]] && compopt -o nospace  # Don't add space
    else
        # Other arguments: files
        _filedir
    fi
}
complete -F _myapp myapp

# 4. Aliases need special treatment (like your code case)
alias code='codium'
complete -o default -o bashdefault -F _filedir_xspec -E code

# 5. Command that only accepts directories
complete -o filenames -A directory myapp

# 6. Command with fixed wordlist
complete -W "red green blue" colors

# 7. Complete usernames
complete -u mycommand

# 8. Complete environment variables
complete -v mycommand
```

## Custom completion function:

### 🔍 **Detailed explanation:**

```bash
_complete_only_commands() {
    mapfile -t COMPREPLY < <(compgen -c -- "$2")
    return 0
}

complete -F _complete_only_commands -E
complete -F _complete_only_commands -I
```

### **`_complete_only_commands()`** - Completion function

- **`mapfile -t COMPREPLY`**: Stores the command output in the `COMPREPLY` array (special variable that Bash reads to show completion options)
- **`compgen -c -- "$2"`**: Generates a list of **all available commands** in the system (`-c`) that match the partial text (`$2` - the second argument of the function, which is the current text being completed)
- **`< <(command)`**: Process substitution - executes the command and treats its output as a temporary file
- **`return 0`**: Returns success

### **`complete -F _complete_only_commands -E`**

- **`-F`**: Uses the specified function to generate completions
- **`-E`**: Applies this completion for **empty command** (when nothing has been typed yet)
- **Effect**: When pressing TAB with nothing typed, shows **only commands**, not files

### **`complete -F _complete_only_commands -I`**

- **`-I`**: Applies to **initial file names** (special context)
- Complements `-E` to cover more cases

## ⚠️ **Problem you faced:**

This configuration replaces the default file completion (like for `cat` and `codium`), causing only commands to be shown, not files.

## 💡 **IMPORTANT TIPS**

1. **`-o filenames` vs `_filedir`**: The `_filedir` function already calls `compopt -o filenames` automatically when needed

2. **Aliases need `-E`**: As you discovered, aliases often need the `-E` option for completion to work

3. **Order of options**: Order matters. `-o bashdefault -o default` tries bashdefault first, then default

4. **`compopt` inside functions**: Use `compopt -o filenames` inside functions to enable file behavior dynamically

5. **Case insensitive**: Bash-completion already handles extensions with case insensitivity (e.g., `_filedir "txt"` catches .txt and .TXT)

## 📚 **SUMMARY - WHEN TO USE EACH ONE**

| Situation | Solution |
|----------|---------|
| Common command that accepts files | `complete -o filenames command` |
| Command with specific arguments + files | Custom function with `_filedir` |
| Alias needs completion | `complete -o ... -E alias` |
| Want to keep `~` and `$` expansion | Add `-o bashdefault -o default` |
| Command that only accepts directories | `complete -o filenames -A directory command` |
| Command with fixed wordlist | `complete -W "options" command` |
| Remove problematic completion | `complete -r command` |

With this knowledge, you can create custom completions for any command on your system! 🚀