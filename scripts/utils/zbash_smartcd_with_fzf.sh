#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'

SMARTCD - Intelligent Directory Navigation
=========================================

OVERVIEW:
smartcd is a smart directory changer that combines command history with
fuzzy file search for fast, intuitive navigation.

FEATURES:
• Fuzzy search through directory history and filesystem
• Interactive selection with fzf + preview (exa/tree/ls)
• Auto-execute .on_entry.smartcd.sh/.on_leave.smartcd.sh scripts
• Ignores directories from SMARTCD_HIST_IGNORE (e.g., .git)
• Maintains history database with size limit (SMARTCD_HIST_SIZE)

USAGE:
  smartcd [PATH]      # Change to PATH with fuzzy matching
  smartcd --          # Interactive mode from all history
  smartcd -           # Go to previous directory (cd -)
  smartcd --cleanup   # Remove non-existent dirs from history
  smartcd --reset     # Clear history database
  smartcd --help      # Show this help

EXAMPLES:
  smartcd dow         # Fuzzy search "dow" in history/filesystem
  smartcd /usr/sha    # Complete to /usr/share
  smartcd --          # Choose from all visited directories
  Ctrl+g              # Interactive mode (bash/zsh binding)

CONFIGURATION:
  SMARTCD_HIST_SIZE=100          # History entries to keep
  SMARTCD_HIST_IGNORE=".git|node_modules"  # Directories to ignore
  SMARTCD_CONFIG_FOLDER="$HOME/.config/smartcd"  # Config location
  SMARTCD_HIST_FILE="path_history.db"      # History database
  SMARTCD_AUTOEXEC_FILE="autoexec.db"      # Auto-exec scripts

AUTO-EXECUTION SCRIPTS:
  Create .on_entry.smartcd.sh or .on_leave.smartcd.sh in any directory
  to run commands automatically when entering/leaving that directory.

PERFORMANCE:
• Uses pipes instead of temp files for better reliability
• Combines database search with filesystem search
• Removes duplicates and empty lines automatically

TIPS:
• Use quotes for paths with spaces: smartcd "my folder"
• Clean history periodically: smartcd --cleanup
• The more you use it, the smarter it gets!

DOCUMENTATION

if [[ -n "$ZSH_VERSION" ]]; then
	smartcd() {
		local target
		
		# If no argument, go to HOME
		if [ $# -eq 0 ]; then
			builtin cd
			return $?
		fi
		
		# Join all arguments
		target="$*"
		
		# Remove external quotes
		target="${target%\"}"
		target="${target#\"}"
		target="${target%\'}"
		target="${target#\'}"
		
		# Try changing directory
		if builtin cd "$target" 2>/dev/null; then
			return 0
		else
			echo "Error: Directory '$target' does not exist" >&2
			return 1
		fi
	}

	alias cd='noglob smartcd'
    
elif [[ -n "$BASH_VERSION" ]]; then
    smartcd() {
        local dir="$*"

        # Expand ~ manually
        [[ $dir == "~"* ]] && dir="${dir/#\~/$HOME}"

        # Use printf '%q' to correctly escape spaces and special characters
        builtin cd "$(printf '%b' "$dir")" 2>/dev/null || builtin cd "$dir"
    }

    alias cd='smartcd'
fi

export SMARTCD_LOG=~/.smartcd.log

# Check dependencies
if ! command -v fzf &> /dev/null; then
	echo "Can't use smartcd : missing fzf" | tee "$SMARTCD_LOG" >/dev/null
	return #1
fi

if ! command -v md5sum &> /dev/null; then
	echo "Can't use smartcd : missing md5sum" | tee "$SMARTCD_LOG" >/dev/null
	return #1
fi

# Smartcd configuration
export SMARTCD_HIST_SIZE=${SMARTCD_HIST_SIZE:-"100"}
export SMARTCD_HIST_IGNORE=${SMARTCD_HIST_IGNORE:-".git"}
export SMARTCD_CONFIG_FOLDER=${SMARTCD_CONFIG_FOLDER:-"$HOME/.config/smartcd"}
export SMARTCD_HIST_FILE=${SMARTCD_HIST_FILE:-"path_history.db"}
export SMARTCD_AUTOEXEC_FILE=${SMARTCD_AUTOEXEC_FILE:-"autoexec.db"}

# Smartcd functions
function __smartcd::cd() {
    local original_stderr_setting="$-"
    set +x  # Disable debug if enabled
    
    local lookUpPath="${1:-$HOME}"
    local selectedEntry=""
    local fzfSelect1=""

    [[ ! -f "${SMARTCD_CONFIG_FOLDER}/${SMARTCD_HIST_FILE}" ]] && __smartcd::databaseReset

    # Remove surrounding quotes if present
    lookUpPath=$(echo "$lookUpPath" | sed -e 's/^"//' -e 's/"$//' -e "s/^'//" -e "s/'$//")

    if [[ "${lookUpPath}" = "-" ]] || [[ -d "${lookUpPath}" ]]; then
        selectedEntry="${lookUpPath}"
    elif [[ "${lookUpPath}" = "--" ]]; then
        selectedEntry=$(__smartcd::databaseSearch 2>/dev/null | __smartcd::choose_direct)
    else
        # Combine results without using temporary file
        local combined_results
        
        # Capture results from database
        local db_results
        db_results=$(__smartcd::databaseSearch "${lookUpPath}" 2>/dev/null)
        
        # Capture results from filesystem
        local fs_results
        fs_results=$(__smartcd::filesystemSearch "${lookUpPath}" 2>/dev/null)
        
        # Combine and remove duplicates
        combined_results=$(printf "%s\n%s" "$db_results" "$fs_results" | awk '!seen[$0]++ && $0 != ""')
        
        if [[ -n "$combined_results" ]]; then
            local line_count=$(echo "$combined_results" | wc -l)
            [[ $line_count -gt 0 ]] && fzfSelect1="--select-1"
            
            selectedEntry=$(echo "$combined_results" | __smartcd::choose_direct "$fzfSelect1")
        else
            selectedEntry="${lookUpPath}"
        fi
    fi
    
    # Restore stderr if it was redirected
    [[ "$original_stderr_setting" =~ x ]] && set -x
    
    # Only proceed if a directory was actually selected
    if [[ -n "${selectedEntry}" ]]; then
        __smartcd::enterPath "${selectedEntry}"
    fi
}

# New choose function that receives input via pipe
function __smartcd::choose_direct() {
    local fzfSelect1="${1}"
    local fzfPreview=""
    local cmdPreview=$(command -v exa tree ls 2>/dev/null | awk 'NR==1 {print}')
    
    local errMessage="no such directory [ {} ]'\n\n'hint: run '\033[1m'smartcd --cleanup'\033[22m'"
    
    case "${cmdPreview}" in
        */eza|*/exa)
            fzfPreview='[ -d {} ] && '${cmdPreview}' --tree --colour=always --icons --group-directories-first --all --level=1 {} || echo '"${errMessage}"''
            ;;
        */tree)
            fzfPreview='[ -d {} ] && '${cmdPreview}' --dirsfirst -a -x -C --filelimit 100 -L 1 {} || echo '"${errMessage}"''
            ;;
        *)
            fzfPreview='[ -d {} ] && echo [ {} ] ; '${cmdPreview}' --color=always --almost-all --group-directories-first {} || echo '"${errMessage}"''
            ;;
    esac
    
    # Read from stdin (pipe) instead of file
    fzf ${fzfSelect1} --delimiter="\n" --layout="reverse" --height="40%" \
        --preview="${fzfPreview}" 2>/dev/tty
}

function __smartcd::enterPath() {
	local returnCode=0
	local directory="${1}"

	[[ "${PWD}" = "${directory}" ]] && return ${returnCode}

	if [[ -d "${directory}" ]] && [[ -r "${directory}" ]] || [[ "-" = "${directory}" ]]; then
		__smartcd::autoexecRun .on_leave.smartcd.sh
	fi

	builtin cd "${directory}" 2>&1
	returnCode=$?

	if [[ ${returnCode} -eq 0 ]]; then
		__smartcd::databaseSavePath "${PWD}"
		__smartcd::autoexecRun .on_entry.smartcd.sh
	else
		__smartcd::databaseDeletePath "${directory}"
	fi

	return ${returnCode}
}

function __smartcd::filesystemSearch() {
	local searchPath=$(dirname -- "${1}")
	local searchString=$(basename -- "${1}")
	local cmdFinder=$(command -v fdfind fd find 2>/dev/null | awk 'NR==1 {print}')

	case "${cmdFinder}" in
		*/fd*)
			"${cmdFinder}" --hidden --no-ignore-vcs "${searchString}" --color=never --follow --min-depth=1 --max-depth=1 --type=directory --exclude ".git/" "${searchPath}" --exec realpath --no-symlinks 2>/dev/null
			;;
		*)
			find "${searchPath}" -follow -mindepth 1 -maxdepth 1 -type d ! -path '*\.git/*' -iname '*'"${searchString}"'*' -exec realpath --no-symlinks {} + 2>/dev/null
			;;
	esac
}

function __smartcd::databaseSearch() {
	local searchString=$(echo "${1}" | sed -e 's:\.:\\.:g' -e 's:/:.*/.*:g')
	grep -i -E "${searchString}"'[^/]*$' "${SMARTCD_CONFIG_FOLDER}/${SMARTCD_HIST_FILE}" 2>/dev/null
}

function __smartcd::databaseSavePath() {
	local directory="${1}"
	local iCounter=0
	local ignoreItem=""
	local ignoreItemFound=""

	[[ "${directory}" = "${HOME}" ]] || [[ "${directory}" = "/" ]] && return

	# Check ignore list
	while true; do
		((iCounter++))
		ignoreItem=$(echo "${SMARTCD_HIST_IGNORE}|" | cut -d'|' -f${iCounter})
		[[ -z "${ignoreItem}" ]] && break

		ignoreItemFound=$(echo "${directory}" | grep -E "/${ignoreItem}$|/${ignoreItem}/")
		if [[ -n "${ignoreItemFound}" ]]; then
			__smartcd::databaseDeletePath "${directory}"
			return
		fi
	done

	__smartcd::databaseDeletePath "${directory}"
	sed -i "1 s:^:${directory}\n:" "${SMARTCD_CONFIG_FOLDER}/${SMARTCD_HIST_FILE}"
	sed -i $((SMARTCD_HIST_SIZE + 1))',$ d' "${SMARTCD_CONFIG_FOLDER}/${SMARTCD_HIST_FILE}"
}

function __smartcd::databaseDeletePath() {
	local directory="${1}"
	sed -i "\:^${directory}$:d" "${SMARTCD_CONFIG_FOLDER}/${SMARTCD_HIST_FILE}" 2>/dev/null
}

function __smartcd::databaseCleanup() {
	local fTmp=$(mktemp 2>/dev/null)
	local line=""
	local iCounter=0
	local bIgnore="false"
	local ignoreItem=""
	local ignoreItemFound=""

	[[ ! -f "${SMARTCD_CONFIG_FOLDER}/${SMARTCD_HIST_FILE}" ]] && __smartcd::databaseReset

	while IFS= read -r line || [[ -n "${line}" ]]; do
		if [[ -d "${line}" ]]; then
			iCounter=0
			bIgnore="false"

			while true; do
				((iCounter++))
				ignoreItem=$(echo "${SMARTCD_HIST_IGNORE}|" | cut -d'|' -f${iCounter})
				[[ -z "${ignoreItem}" ]] && break

				ignoreItemFound=$(echo "${line}" | grep -E "/${ignoreItem}$|/${ignoreItem}/")
				if [[ -n "${ignoreItemFound}" ]]; then
					bIgnore="true"
					break
				fi
			done

			[[ "${bIgnore}" = "false" ]] && echo "${line}" >> "${fTmp}"
		fi
	done < "${SMARTCD_CONFIG_FOLDER}/${SMARTCD_HIST_FILE}"

	awk '!seen[$0]++' "${fTmp}" > "${SMARTCD_CONFIG_FOLDER}/${SMARTCD_HIST_FILE}"
	sed -i '/^[[:blank:]]*$/ d' "${SMARTCD_CONFIG_FOLDER}/${SMARTCD_HIST_FILE}"
	[[ $(wc -l < "${SMARTCD_CONFIG_FOLDER}/${SMARTCD_HIST_FILE}") -eq 0 ]] && __smartcd::databaseReset
	rm -f "${fTmp}"
}

function __smartcd::databaseReset() {
	mkdir -p "${SMARTCD_CONFIG_FOLDER}"
	echo "" > "${SMARTCD_CONFIG_FOLDER}/${SMARTCD_HIST_FILE}"
}

function __smartcd::autoexecRun() {
	local fAutoexec="${1}"
	if [[ -f "${fAutoexec}" ]] && [[ -r "${fAutoexec}" ]]; then
		source "${fAutoexec}"
	fi
}

# Key binding for Ctrl+g
[[ -n "$BASH_VERSION" ]] && bind '"\C-g":"smartcd --\n"'
[[ -n "$ZSH_VERSION" ]] && bindkey -s '^g' 'smartcd --\n'

# Simple wrapper that joins all arguments
function __smartcd_wrapper() {
	case $# in
		0)
			__smartcd::cd
			;;
		1)
			__smartcd::cd "$1"
			;;
		*)
			# Para múltiplos argumentos, junta-os mantendo os espaços
			local IFS=' '
			__smartcd::cd "$*"
			;;
	esac
}

# Main smartcd function - call this instead of overriding cd
function smartcd() {
	case "$1" in
		--help|-h)
			echo "Usage: smartcd [PATH]"
			echo "       smartcd --     (interactive mode)"
			echo "       smartcd -      (go to previous directory)"
			echo "       smartcd --cleanup (cleanup database)"
			echo "       smartcd --reset (reset database)"
			;;
		--cleanup)
			__smartcd::databaseCleanup
			;;
		--reset)
			__smartcd::databaseReset
			;;
		*)
			__smartcd_wrapper "$@"
			;;
	esac
}

# To complete smartcd in bash (optional)
if [[ -n "$BASH_VERSION" ]]; then
	complete -o dirnames -o nospace -F _cd smartcd 2>/dev/null || true
fi

# To complete smartcd in zsh (optional)
if [[ -n "$ZSH_VERSION" ]]; then
	compdef _cd smartcd 2>/dev/null || true
fi