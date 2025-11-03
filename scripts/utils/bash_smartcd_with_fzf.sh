#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

if [[ -n "$BASH_VERSION" ]]; then
    # Smartcd configuration
    export SMARTCD_HIST_SIZE=${SMARTCD_HIST_SIZE:-"100"}
    export SMARTCD_HIST_IGNORE=${SMARTCD_HIST_IGNORE:-".git"}
    export SMARTCD_CONFIG_FOLDER=${SMARTCD_CONFIG_FOLDER:-"$HOME/.config/smartcd"}
    export SMARTCD_HIST_FILE=${SMARTCD_HIST_FILE:-"path_history.db"}
    export SMARTCD_AUTOEXEC_FILE=${SMARTCD_AUTOEXEC_FILE:-"autoexec.db"}

    # Check dependencies
    if ! command -v fzf &> /dev/null; then
        echo "Can't use smartcd : missing fzf"
        return 1
    fi

    if ! command -v md5sum &> /dev/null; then
        echo "Can't use smartcd : missing md5sum"
        return 1
    fi

    # Smartcd functions
    function __smartcd::cd() {
        local fSearchResults=$(mktemp --tmpdir="/dev/shm/" -t smartcd_$$_XXXXX.tmp)
        local lookUpPath="${1:-$HOME}"
        local selectedEntry=""
        local fzfSelect1=""

        [[ ! -f "${SMARTCD_CONFIG_FOLDER}/${SMARTCD_HIST_FILE}" ]] && __smartcd::databaseReset

        # Remove surrounding quotes if present
        lookUpPath=$(echo "$lookUpPath" | sed -e 's/^"//' -e 's/"$//' -e "s/^'//" -e "s/'$//")

        if [[ "${lookUpPath}" = "-" ]] || [[ -d "${lookUpPath}" ]]; then
            selectedEntry="${lookUpPath}"
        elif [[ "${lookUpPath}" = "--" ]]; then
            __smartcd::databaseSearch > "${fSearchResults}"
            selectedEntry=$(__smartcd::choose "${fSearchResults}" "${fzfSelect1}")
        else
            __smartcd::databaseSearch "${lookUpPath}" > "${fSearchResults}"
            [[ $(wc -l < "${fSearchResults}") -gt 0 ]] && fzfSelect1="--select-1"
            __smartcd::filesystemSearch "${lookUpPath}" >> "${fSearchResults}"

            if [[ $(wc -l < "${fSearchResults}") -gt 0 ]]; then
                selectedEntry=$(__smartcd::choose "${fSearchResults}" "${fzfSelect1}")
            else
                selectedEntry="${lookUpPath}"
            fi
        fi

        rm -f "${fSearchResults}"
        __smartcd::enterPath "${selectedEntry}"
    }

    function __smartcd::choose() {
        local fOptions="${1}"
        local fzfSelect1="${2}"
        local fzfPreview=""
        local cmdPreview=$(command -v exa tree ls 2>/dev/null | awk 'NR==1 {print}')

        local errMessage="no such directory [ {} ]'\n\n'hint: run '\033[1m'smartcd --cleanup'\033[22m'"

        case "${cmdPreview}" in
            */exa)
                fzfPreview='[ -d {} ] && '${cmdPreview}' --tree --colour=always --icons --group-directories-first --all --level=1 {} || echo '"${errMessage}"''
                ;;
            */tree)
                fzfPreview='[ -d {} ] && '${cmdPreview}' --dirsfirst -a -x -C --filelimit 100 -L 1 {} || echo '"${errMessage}"''
                ;;
            *)
                fzfPreview='[ -d {} ] && echo [ {} ] ; '${cmdPreview}' --color=always --almost-all --group-directories-first {} || echo '"${errMessage}"''
                ;;
        esac

        awk '!seen[$0]++ && $0 != ""' "${fOptions}" | fzf ${fzfSelect1} --delimiter="\n" --layout="reverse" --height="40%" --preview="${fzfPreview}"
    }

    function __smartcd::enterPath() {
        local returnCode=0
        local directory="${1}"

        [[ "${PWD}" = "${directory}" ]] && return ${returnCode}

        if [[ -d "${directory}" ]] && [[ -r "${directory}" ]] || [[ "-" = "${directory}" ]]; then
            __smartcd::autoexecRun .on_leave.smartcd.sh
        fi

        builtin cd "${directory}"
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
        local fTmp=$(mktemp)
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
        # Simplified implementation - you can add the complete logic if needed
        if [[ -f "${fAutoexec}" ]] && [[ -r "${fAutoexec}" ]]; then
            source "${fAutoexec}"
        fi
    }

    # Key binding for Ctrl+g
    bind '"\C-g":"cd --\n"'

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

    # Aliases
    alias cd="__smartcd::cd"
	alias cd="__smartcd_wrapper"
    alias -- -="cd -"
    alias cd..="cd .."
    alias ..="cd .."
    alias ..2="cd ../.."
    alias ..3="cd ../../.."
fi
