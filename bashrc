#!/usr/bin/env bash
#################################
###### Xterm Transparency #######
[[ "$XTERM_VERSION" ]] && command -v transset-df >/dev/null 2>&1 && transset-df -x 0.7 -m 0.7 --id "$WINDOWID" >/dev/null
# Using bash’s shopt builtin to manage Linux shell behavior
# The shopt builtin offers 53 settings that can alter how bash behaves. 
# Read this post and then refer to bash's man page to follow up on how these settings might work for you.
# https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html
# https://www.networkworld.com/article/3574960/using-bashs-shopt-builtin-to-manage-linux-shell-behavior.html

# set -x # Debug trace
# The set -o pipefail option is used in Bash to handle pipeline failures (chaining commands using the "|" operator) more accurately. Typically, 
# a pipeline returns the exit code of the last command executed in the pipeline. However, if an intermediate command fails, 
# theexit code is usually ignored and the pipeline is considered successful.
# Enabling set -o pipefail changes the default behavior. In this mode, the pipeline will return the exit code of the last command that failed 
# within the pipeline, instead of returning the exit code of the last executed command. This can be useful for detecting failuresin complex pipelines, 
# especially when dealing with data processing or task automation.
# set -o pipefail # Will cause the pipeline to return the exit code of the last failed command within the pipeline.
# set -e # Debug (Errors: exit) mode 'exit-on-error' or 'errexit'. Terminates execution immediately if any command returns a non-zero error code.
# set -u # Enables 'nounset' or 'unbound variables' mode. Generates an error if an uninitialized variable is referenced.
# set -f # Disable globstar. Disables wildcard expansion (globbing).
# set -efu
# set -eo pipefail

#################################
######### SHELL UTILS ###########
# shellcheck source=/dev/null
[[ -f ~/.shell_utils/shell_utils.sh ]] && . ~/.shell_utils/shell_utils.sh
#################################

# Enable the subsequent settings only in interactive sessions
case $- in
  *i*) ;;
    *) return;;
esac

# ble.sh configuration - syntax highlighting and autosuggest for bash
BLE_CONF="$HOME/.shell_utils_configs/ble_bash.conf"
BLE_PATH="$HOME/.local/share/blesh/ble.sh"
BLE_REPO="$HOME/.ble.sh"

_ble_comment() {
    echo "# If BLE_BASH_ENABLED is set to 0, it disables; if set to 1, it enables ble.sh from akinomyoga's GitHub repository;" | tee "$BLE_CONF" &>/dev/null
    echo "# and if set to 2, it enables an alternative, simple but functional version of ble." | tee -a "$BLE_CONF" &>/dev/null
}

if [[ ! -f "$BLE_CONF" ]] && [[ -n $TERMUX_VERSION ]]; then
    _ble_comment
elif [[ ! -f "$BLE_CONF" ]]; then
    # We use BLE disabled by default even though it is not termux, 
    # because BLE, no matter how excellent it is, can cause crashes and slowdowns
    _ble_comment
fi

if [[ -f "$BLE_CONF" ]]; then
    # shellcheck source=/dev/null
    source "$BLE_CONF"
fi

# Oh My Bash Config
###################
# Themes available for Oh-My-Bash:
#"agnoster" #"pure" #"rr" #"mairan" #"rjorgenson" #"brainy" #"iterate" #"standard" #"demula" #"powerline-naked" #"powerline-multiline" #"90210" #"clean" #"dulcie" 
#"brunton" #"binaryanomaly" #"random" #"font" #"powerline" #"duru" #"vscode" #"candy" #"hawaii50" #"emperor" #"tylenol" #"morris" #"pzq" #"zitron" #"kitsune"
if [[ "$BLE_BASH_ENABLED" != 2 ]]; then 
    OMB_THEME=demula 

    # shellcheck source=/dev/null
    OMBC=~/.shell_utils/frameworks/oh-my-bash-config.sh && [[ -f "$OMBC" ]] && . "$OMBC" && unset OMBC
    if [[ "$OMB_THEME" == "agnoster" ]]; then
        prompt_theme_agnoster
    fi
else
    PS1='\[\e[1;35m\]\u\[\e[0m\] at \[\e[1;36m\]\H\[\e[0m\] in \[\e[1;34m\]\w\[\e[0m\]\n\$ '
fi

# Remove all existing completions
complete -r

# shellcheck source=/dev/null
if [[ "$BLE_BASH_ENABLED" == 0 ]] && [[ "$OMB_THEME" == "demula" ]]; then
    source ~/.shell_utils/scripts/bash-ghost-text2
elif [[ "$BLE_BASH_ENABLED" == 0 ]]; then
    source ~/.shell_utils/scripts/bash-ghost-text
fi

# Bash-it
# shellcheck source=/dev/null
[[ "$BLE_BASH_ENABLED" != 2 ]] && [[ -f /usr/lib/bash-it-git/bash_it.sh ]] && . /usr/lib/bash-it-git/bash_it.sh

##### STARTUP
##### INPUTRC
if [ ! -f ~/.inputrc ]; then
    cat <<'EOF' | tee ~/.inputrc &>/dev/null
$include /etc/inputrc
set completion-ignore-case On
set show-all-if-ambiguous On
set show-all-if-unmodified On
set bell-style On
set colored-stats On
set colored-completion-prefix On
set menu-complete-display-prefix On
set mark-symlinked-directories On
set visible-stats On
set completion-query-items 50
set history-preserve-point On
EOF
fi

# Force prompt to write history after every command.

shopt -s histappend
shopt -s checkwinsize

# Undocumented feature which sets the size to "unlimited".
# http://stackoverflow.com/questions/9457233/unlimited-bash-history
###export HISTFILESIZE === 100000
###export HISTSIZE === 100000
# ---------------------
# Eternal bash history.
export HISTFILESIZE=
export HISTSIZE=
#export HISTIGNORE="&:?:*:ERR"
# Remove leading and trailing whitespace from history entries.
export HISTIGNORE=' *'
### ignoreboth:erasedups:ignorespace:ignoredups
export HISTCONTROL="ignoreboth:erasedups:cmdfail"
export HISTTIMEFORMAT="[%F %T] "
#export HISTTIMEFORMAT=
# Change the file location because certain bash sessions truncate .bash_history file upon close.
# http://superuser.com/questions/575479/bash-history-truncated-to-500-lines-on-each-login
export HISTFILE=~/.bash_history

bash_shortcuts() {
    cat <<'EOF'
Ctrl+A: Moves the cursor to the beginning of the line.
Ctrl+E: Moves the cursor to the end of the line.
Ctrl+U: Clears the line before the cursor.
Ctrl+K: Clears the line after the cursor.
Ctrl+W: Deletes the previous word.
Ctrl+L: Clears the screen.
EOF
    return 0
}

remove_timestamp_in_single_line_format_from_bash_history() {
    [[ ! -f "$HISTFILE" ]] && touch "$HISTFILE"
    [[ -f "$HISTFILE" ]] && sed -i 's/^:[[:space:]][0-9]\{10\}:0;//g' "$HISTFILE" >/dev/null 2>&1
    return 0
}

# https://www.baeldung.com/linux/history-remove-avoid-duplicates
remove_duplicate_commands_from_bash_history() {
    [[ ! -f "$HISTFILE" ]] && touch "$HISTFILE"
    local history_file="${HISTFILE}"
    local temp_file="${HISTFILE}.tmp"
    [[ -f "${temp_file}" ]] && rm -f "${temp_file}"

    # Filter duplicate commads
    awk '!a[$0]++' "$history_file" > "$temp_file"

    # Replace history
    mv -f "$temp_file" "$history_file" >/dev/null 2>&1
    return 0
}

remove_unused_timestamps_from_bash_history() {
    [[ ! -f "$HISTFILE" ]] && touch "$HISTFILE"
    local history_file="${HISTFILE}"
    local temp_file="${HISTFILE}.tmp"
    [[ -f "${temp_file}" ]] && rm -f "${temp_file}"

    # Filter history lines with timestamps and associated commands
    awk '/^#[0-9]+$/ { if (getline c && c !~ /^#[0-9]+$/) { print $0 ORS c } } !/^#[0-9]+$/ { print }' "$history_file" > "$temp_file"

    # Replace history
    mv -f "$temp_file" "$history_file" >/dev/null 2>&1
    return 0
}

include_timestamp_in_bash_history() {
    [[ ! -f "$HISTFILE" ]] && touch "$HISTFILE"
    local history_file="${HISTFILE}"
    local temp_file="${HISTFILE}.tmp"
    [[ -f "${temp_file}" ]] && rm -f "${temp_file}"

    # Filter history lines with timestamps and associated commands
    awk '/^#[0-9]+$/ { if (getline c && c !~ /^#[0-9]+$/) { print $0 ORS c } } !/^#[0-9]+$/ { print strftime("#%s") ORS $0 }' "$history_file" > "$temp_file"

    # Replace history
    mv -f "$temp_file" "$history_file" >/dev/null 2>&1
    return 0
}

# Fix several known issues of bash history, and amazingly, it is able to convert .zsh_history to standard .bash_history structure
fix_bash_history() {
    remove_timestamp_in_single_line_format_from_bash_history
    remove_unused_timestamps_from_bash_history
    include_timestamp_in_bash_history
    return 0
}

# Configure navigation keys
bind '"\t":complete'
#bind '"\t":menu-complete'            # TAB
bind '"\e[Z":menu-complete-backward' # Shift + TAB

# jump to next/previous word in a commandline by pressing SHIFT+RIGHT and SHIFT+LEFT
bind '"\e[1;2C":menu-complete'          # Shift + Right
bind '"\e[1;2D":menu-complete-backward' # Shift + Left

bind '"\e[1;5A":forward-word'   # Ctrl + Up
bind '"\e[1;5B":backward-word'  # Ctrl + Down

complete -abcdefgjksuv sudo
complete -abcdefgjksuv doas

# Configure command prompt

notifications() {
	local exit_status=$?
	[[ "$BEEP" == 1 ]] && beep_sound
	[[ "$NOTIFY" == 1 ]] && notify-send "Command finished" "Status: $exit_status"
}

_prompt_command() {
    notifications
    "$@"
    fix_bash_history
}

PROMPT_COMMAND="_prompt_command $PROMPT_COMMAND"

############################################################################

fzf_bash() {
    file=~/.fzf.bash
    if ! test -f "$file" && command -v fzf &>/dev/null; then
        fzf --bash | tee "$file" &>/dev/null
    fi
    # shellcheck source=/dev/null
    test -f "$file" && source "$file"
    return 0
}

fzf_bash

# >>> mamba initialize >>>
# !! Contents within this block are managed by 'mamba init' !!
# mamba_setup # Uncomment this line

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
# conda_setup # Uncomment this line 

# Bash SmartCD 
# shellcheck source=/dev/null
source ~/.shell_utils/scripts/utils/zbash-smartcd-with-fzf

# Load local bash completions from user directory
# This allows installing shell completions without sudo/root access
# (typical location for pip/pipx, cargo, and other language package managers)
if [ -d ~/.local/share/bash-completion/completions/ ]; then
    for completion in ~/.local/share/bash-completion/completions/*; do
        # shellcheck source=/dev/null
        [ -f "$completion" ] && source "$completion"
    done
fi
if [ -d ~/.shell_utils/utilities/completions/bash/ ]; then
    for completion in ~/.shell_utils/utilities/completions/bash/*.bash; do
        # shellcheck source=/dev/null
        [ -f "$completion" ] && source "$completion"
    done
fi

# Install ble.sh only if it doesn't exist
if [[ ! -f "$BLE_PATH" && ! -d "$BLE_REPO" ]] && [[ "$BLE_BASH_ENABLED" == 1 ]]; then
    echo "📦 Installing ble.sh..."
    git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git "$BLE_REPO"
    
    if [[ -d "$BLE_REPO" ]]; then
        make -C "$BLE_REPO" install PREFIX="$HOME/.local"
        echo "✅ ble.sh successfully installed!"
    else
        echo "❌ Failed to clone ble.sh"
    fi
fi

# Load ble.sh if it exists
if [[ -f "$BLE_PATH" ]] && [[ "$BLE_BASH_ENABLED" == 1 ]]; then
    # shellcheck source=/dev/null
    source -- "$BLE_PATH"
    
    # Optional ble.sh settings
    bleopt complete_auto_history=1  # History-based autosuggest
    bleopt highlight_syntax=1       # Syntax highlighting
    bleopt highlight_filename=1     # Filename highlighting (existing/broken)
    
    # Tests to avoid crashes, by reducing timeout time: if it doesn't autocomplete quickly, simply don't complete it.
    # bleopt complete_limit_auto=100
    # bleopt complete_timeout_auto=100
    # bleopt highlight_timeout_async=100

    # ==============================================================================
    # ble.sh (Bash Line Editor) Configuration
    # Source: https://github.com/akinomyoga/ble.sh
    #
    # Optimized for performance and responsiveness. Limits are set to prevent
    # freezing and excessive delays during complex operations (globbing, large
    # directories, etc.).
    # ==============================================================================

    # --- Performance & Responsiveness Core ---
    # These settings directly impact how quickly ble.sh responds to keystrokes.
    bleopt complete_auto_delay=300           # Wait 300ms before starting auto-complete [citation:4]
    bleopt complete_polling_cycle=20          # Check for more completion candidates more frequently (lower = more responsive but more CPU)
    bleopt idle_interval=15                    # Check for terminal resize/etc more often [citation:original]
    bleopt input_encoding=UTF-8                 # Keep UTF-8

    # --- Completion System Limits (Safety First) ---
    # These are crucial for preventing freezes in directories with many files [citation:4][citation:5]
    bleopt complete_limit=500                   # Hard limit for number of completion candidates (fallback)
    bleopt complete_limit_auto=100               # YOUR VALUE: Stop auto-completion generation if > 100 candidates [citation:3][citation:4]
    bleopt complete_limit_auto_menu=100           # YOUR VALUE: Stop menu generation if > 100 candidates
    bleopt complete_timeout_auto=200              # Stop auto-completion generation if it takes > 200ms [citation:3]
    bleopt complete_timeout_compvar=150            # Timeout for external completer functions (like from bash-completion) [citation:3]

    # --- History & Line Limits ---
    # Prevents large history or long lines from slowing down the editor [citation:6]
    bleopt history_limit_length=5000            # Max number of history entries to load into memory (adjust as needed)
    bleopt line_limit_length=5000                # Max line length to process for highlighting/editing

    # --- Syntax & File Highlighting Limits ---
    # These limit the work done for complex commands and path expansions [citation:8]
    bleopt highlight_eval_word_limit=100          # Limit expansion (e.g., {1..1000}) for highlighting to 100 words [citation:8]
    light_timeout_async=80                         # Timeout for async (background) highlighting
    bleopt highlight_timeout_sync=40                # Timeout for sync (foreground) highlighting (lower = more responsive typing)
    bleopt filename_ls_colors=                       # Use LS_COLORS but without extra underlines (cleaner/faster) [citation:2]

    # --- Optional: Disable or Reduce Heavy Features for Max Speed ---
    # Uncomment these lines if you still experience lag. They disable non-essential features. [citation:2][citation:10]
    # bleopt highlight_syntax=                        # Disable syntax coloring
    # bleopt highlight_filename=                      # Disable file existence checks for paths
    # bleopt highlight_variable=                       # Disable variable type highlighting
    # bleopt complete_ambiguous=                        # Disable ambiguous completion (e.g., completing from middle of word)
    # bleopt complete_menu_complete=                    # Disable cycling through menu with TAB
    # bleopt complete_menu_filter=                      # Disable incremental filtering in the completion menu

    # --- Visual Polish (Keep but can be disabled for speed) ---
    bleopt prompt_eol_mark='[ble: EOF]'              # Marker for end-of-file (keep for clarity)
    bleopt exec_errexit_mark='[ble: exit %d]'         # Marker for command errors
    bleopt exec_exit_mark='[ble: exit]'               # Marker for shell exit
    bleopt edit_marker='[ble: %s]'                    # General ble.sh status messages
    bleopt edit_marker_error='[ble: %s]'               # Error messages

    # --- Key Bindings & Misc ---
    bleopt default_keymap=auto
    bleopt decode_abort_char=28                        # C-^ (usually C-/ or C-_) to abort
    bleopt term_bracketed_paste_mode=on                # Essential for pasting

    # --- Face Customization (Optional) ---
    # Example: Make auto-suggestions more subtle [citation:10]
    # ble-face auto_complete='fg=240,italic'

    # --- Dynamic Configuration Example (Advanced) ---
    # Disable auto-complete completely when in system directories with many files [citation:4]
    # function blehook_chpwd_update_completion {
    #   case $PWD in
    #     /bin|/sbin|/usr/bin|/usr/sbin|/lib|/usr/lib)
    #       bleopt complete_auto_complete= ;;
    #     *)
    #       bleopt complete_auto_complete=1 ;;
    #   esac
    # }
    # blehook CHPWD!=blehook_chpwd_update_completion
    # blehook_chpwd_update_completion # run once on load

elif [[ "$BLE_BASH_ENABLED" == 1 ]]; then
    echo "⚠️  ble.sh not found at $BLE_PATH"
fi

unset -f _ble_comment
unset BLE_PATH BLE_REPO BLE_CONF


# shopt | column
#
## By enabling the globstar option, you can glob all matching files in this directory and all subdirectories:
## Example: for i in **/*.sh; do echo ${i}; done
## For allowing the Bash shell to expand globes (wildcards) across all matching files in directories and subdirectories
#########################################################################################################################
## Habilita a opção globstar, permitindo que o shell Bash expanda globos (wildcards) em todos os arquivos correspondentes 
## nos diretórios e subdiretórios.
shopt -s globstar

## If set, the extended pattern matching features described above (see Pattern Matching) are enabled.
#####################################################################################################
## Habilita a opção extglob, que permite o uso de recursos avançados de correspondência de padrões, 
## como padrões de correspondência estendidos.
shopt -s extglob

## If set, minor errors in the spelling of a directory component in a cd command will be corrected. 
## The errors checked for are transposed characters, a missing character, and a character too many. 
## If a correction is found, the corrected path is printed, and the command proceeds. This option is only used by interactive shells.
###############################################################################################################################
## Habilita a opção cdspell, que corrige erros menores na digitação de nomes de diretórios ao usar o comando cd. 
## Por exemplo, se você digitar um diretório com caracteres transpostos, ausentes ou extras, o Bash tentará corrigi-lo 
## e executar o comando cd para o diretório corrigido.
shopt -s cdspell

## If set, Bash replaces directory names with the results of word expansion when performing filename completion.
## This changes the contents of the Readline editing buffer. If not set, Bash attempts to preserve what the user typed.
###############################################################################################################################
## Habilita a opção direxpand, que substitui nomes de diretórios pelos resultados da expansão de palavras durante 
## a conclusão de nomes de arquivos. Isso significa que, ao usar a conclusão de tabulação, o Bash substituirá nomes 
## de diretórios pelos caminhos completos correspondentes.
shopt -s direxpand

## If set, Bash attempts spelling correction on directory names during word completion if the directory name initially supplied does not exist.
###############################################################################################################################
## Habilita a opção dirspell, que realiza correção ortográfica em nomes de diretórios durante a conclusão de tabulação, caso o nome do diretório 
## fornecido inicialmente não exista. O Bash tentará corrigir o nome do diretório e completá-lo corretamente.
shopt -s dirspell

## If set, a command name that is the name of a directory is executed as if it were the argument to the cd command. 
## This option is only used by interactive shells.
###############################################################################################################################
## Habilita a opção autocd, permitindo que um nome de comando que corresponda a um diretório seja executado como se fosse o argumento 
## para o comando cd. Isso é útil para navegar diretamente para um diretório digitando seu nome no prompt de comando, em vez de precisar digitar 
## explicitamente o comando cd.
shopt -s autocd

## With this option enabled, matching wildcards will not be case sensitive. For example, *.txt will match files with a .txt extension, 
## regardless of case.
###############################################################################################################################
## Com essa opção habilitada, a correspondência de globos (wildcards) não será sensível a maiúsculas e minúsculas. Por exemplo, *.txt
## corresponderá a arquivos com extensão .txt, independentemente do uso de letras maiúsculas ou minúsculas.
shopt -s nocaseglob

# Enable history reediting and verification.
shopt -s histreedit

## This option causes the history to be displayed before each command is executed. After displaying the command history, 
## you have the option to edit or confirm the execution. This can help to avoid errors when running old commands from history.
###############################################################################################################################
## Essa opção faz com que o histórico seja exibido antes da execução de cada comando. Após exibir o comando do histórico, você tem a opção 
## de editar ou confirmar a execução. Isso pode ajudar a evitar erros ao executar comandos antigos do histórico.
shopt -s histverify 

## With this option enabled, the history will be stored in single-line format instead of the default multi-line format. This makes it easy 
## to search and manipulate history using tools like grep or scripts.
###############################################################################################################################
## Com essa opção ativada, o histórico será armazenado no formato de linha única, em vez do formato de várias linhas padrão. 
## Isso facilita a pesquisa e manipulação do histórico usando ferramentas como grep ou scripts.
shopt -s lithist

## By enabling this option, the history will not store duplicate consecutive commands. This can help reduce the history size and preventrepeated 
## commands from taking up unnecessary space.
###############################################################################################################################
## Habilitando essa opção, o histórico não armazenará comandos consecutivos duplicados. 
## Isso pode ajudar a reduzir o tamanho do histórico e evitar que comandos repetidos ocupem espaço desnecessário.
shopt -s cmdhist

## If set, the programmable completion facilities are enabled. This allows
## dynamic completion of command arguments based on context. When a user hits
## TAB, Bash can execute custom completion functions that provide context-
## sensitive suggestions (e.g., completing git branches for 'git checkout',
## or package names for 'apt install'). This option is enabled by default in
## interactive shells.
###############################################################################################################################
## Habilita a opção progcomp, que ativa os recursos de completação programável no Bash.
## Isso permite a completação dinâmica de argumentos de comandos baseada no contexto.
## Quando o usuário pressiona TAB, o Bash pode executar funções de completação personalizadas
## que fornecem sugestões sensíveis ao contexto (ex.: completar branches do git para 'git checkout',
## ou nomes de pacotes para 'apt install'). Esta opção está habilitada por padrão em shells interativos.
shopt -s progcomp

## If set, aliases are expanded separately for shell completion purposes.
## This allows completion functions to work with aliased commands by treating
## the alias as if it were the original command. Without this option, you must
## manually configure completions for each alias using the complete command.
###############################################################################################################################
## Habilita a opção progcomp_alias, que expande aliases separadamente para fins de conclusão (completion) no shell.
## Isso permite que as funções de completação funcionem com comandos alias, tratando o alias como se fosse o comando original.
## Sem esta opção, é necessário configurar manualmente as completações para cada alias usando o comando complete.

## With this option enabled, Bash will not complete empty commands when pressing the Tab key twice. This prevents Bash from listing 
## all available commands when no commands have been entered.
###############################################################################################################################
## Com essa opção ativada, o Bash não completará comandos vazios ao pressionar a tecla Tab duas vezes. 
## Isso evita que o Bash liste todos os comandos disponíveis quando nenhum comando foi digitado
shopt -s no_empty_cmd_completion

# Tests
#shopt -s progcomp_alias
#shopt -u interactive_comments
#shopt -u no_empty_cmd_completion
#shopt -s bash_source_fullpath

#complete -o default -o bashdefault -F _filedir_xspec -E code
complete -o default -o bashdefault -F _filedir_xspec -E 
complete -o default -o filenames codium

if [[ "$BLE_BASH_ENABLED" == 2 ]]; then
    echo
    # shellcheck source=/dev/null
    source ~/.shell_utils/scripts/ble-simple
    #source ~/.shell_utils/scripts/bash-ghost-text
    #source ~/.shell_utils/scripts/bash-command-indicator
    #source ~/.shell_utils/scripts/bash-sintax-highlight
fi