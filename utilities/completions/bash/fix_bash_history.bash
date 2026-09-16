#!/usr/bin/env bash
###############################################################################
# Manutenção do bash_history — v4 (rápida e silenciosa)
#
# O QUE MUDOU EM RELAÇÃO À v3
#
# 1. FORKS. A v3 abria um subshell `$( )` por comando do histórico, dentro do
#    parser, só para juntar as linhas de um bloco. Num histórico de 10 mil
#    comandos isso são 10 mil forks — era daí que vinha a lentidão. Agora a
#    junção é feita com `printf -v` (builtin, zero fork).
#
# 2. UMA PASSADA SÓ. `history_maintenance` fazia 4 travamentos, 4 leituras e
#    4 reescritas do arquivo. Agora tudo (formato zsh, timestamps órfãos,
#    timestamps faltando, duplicatas) acontece numa única leitura, uma única
#    reescrita, sob um único lock.
#
# 3. SEM grep/sed/mktemp/find/ls/tail/xargs. O prefixo do zsh é removido com
#    expansão do próprio bash; o temporário usa `$$.$RANDOM` em vez de
#    `mktemp`; a poda de backups sumiu junto com os backups datados. Numa
#    execução típica sobram 2 processos externos (`ln` e `mv`) — e zero se
#    não houver nada a corrigir.
#
# 4. BACKUP INSTANTÂNEO. Em vez de `cp -p` (cópia real do arquivo inteiro a
#    cada execução), o backup é um hard link: `ln -f histfile histfile.bak`.
#    Custa uma entrada de diretório, não copia byte nenhum. Como a gravação
#    final é `mv` (rename atômico, que cria um inode novo), o .bak continua
#    apontando para o conteúdo antigo. Segurança igual, custo ~zero.
#
# 5. GRAVAÇÃO ATÔMICA DE VERDADE. `mv` no mesmo filesystem é rename atômico:
#    ou o arquivo é o antigo, ou é o novo, nunca meio escrito. A v3 usava
#    `cat tmp > histfile`, que podia deixar o arquivo pela metade numa queda.
#
# 6. NÃO ESCREVE SE NADA MUDOU. Cada correção marca um flag; sem flag, o
#    arquivo não é tocado, não há backup, não há reload do histórico.
#
# 7. ATALHO DE ENTRADA. Se o histórico não foi modificado desde a última
#    manutenção (teste `-nt` contra um arquivo-carimbo, builtin), a função
#    retorna imediatamente sem nem abrir o arquivo. Custo: zero processos.
#
# 8. SILÊNCIO. Nenhuma saída em operação normal. Erros graves vão para stderr.
#    Lock ocupado = sai quieto (outro terminal já está cuidando disso), sem
#    travar o seu prompt esperando.
#
# CONFIGURAÇÃO (tudo opcional)
#   HISTMAINT_VERBOSE=1      mostra o relatório do que foi feito
#   HISTMAINT_LOCK_TIMEOUT   segundos de espera pelo lock (padrão 1)
#   HISTMAINT_LOCKFILE       caminho alternativo do lock
#   HISTMAINT_BACKUP=0       desliga o hard link de backup
#
# USO NO .bashrc
#   source ~/bash_history_maint.sh
#   history_maintenance          # seguro no startup: sai em ~0ms se nada mudou
# Ou, mais conservador, no ~/.bash_logout.
###############################################################################

: "${HISTMAINT_LOCK_TIMEOUT:=1}"
: "${HISTMAINT_BACKUP:=1}"

_hist_say() { [[ -n "${HISTMAINT_VERBOSE:-}" ]] && printf '%s\n' "$*"; return 0; }
_hist_err() { printf 'history: %s\n' "$*" >&2; }

_histfile_path()     { printf '%s' "${HISTFILE:-$HOME/.bash_history}"; }
_histfile_lockpath() { printf '%s' "${HISTMAINT_LOCKFILE:-${HISTFILE:-$HOME/.bash_history}.lock}"; }
_histfile_stamppath(){ printf '%s' "${HISTFILE:-$HOME/.bash_history}.stamp"; }

#------------------------------------------------------------------------------
# Lock: UM arquivo para todas as funções, de propósito — lock só exclui
# concorrência se todo mundo disputar o mesmo arquivo. Aberto com 9>>
# (append), que não trunca e não esbarra em `set -o noclobber`.
#   3 = não abriu o lock    4 = ocupado (sai quieto, sem travar o prompt)
#------------------------------------------------------------------------------
_histfile_with_lock() {
    local lock_file
    lock_file="$(_histfile_lockpath)"

    if ! command -v flock >/dev/null 2>&1; then
        ( set +C; "$@" )
        return $?
    fi

    (
        set +C
        exec 9>>"$lock_file" 2>/dev/null || exit 3
        flock -w "$HISTMAINT_LOCK_TIMEOUT" 9 || exit 4
        "$@"
    )
}

_histfile_reload() {
    [[ $- == *i* ]] || return 0
    history -c
    history -r "$(_histfile_path)"
}

_histfile_touch_stamp() {
    local stamp="$1" had_noclobber=0
    [[ -o noclobber ]] && { had_noclobber=1; set +C; }
    : > "$stamp" 2>/dev/null
    (( had_noclobber )) && set -C
    return 0
}

###############################################################################
# NÚCLEO: lê, corrige e grava — uma passada só, sob o lock.
#   $1 = 1 para deduplicar, 0 para não
# Sem saída, a não ser com HISTMAINT_VERBOSE.
###############################################################################
_hist_process() {
    local dedup="${1:-1}"
    local hist_file stamp tmp_file
    hist_file="$(_histfile_path)"
    stamp="$(_histfile_stamppath)"

    local lines=()
    mapfile -t lines < "$hist_file" 2>/dev/null || return 1
    local n=${#lines[@]}
    (( n == 0 )) && { _histfile_touch_stamp "$stamp"; return 0; }

    local changed=0
    local ts_list=() body_list=()
    local i=0 line ts body joined

    #--- passada única: tira prefixo zsh, agrupa blocos, descarta órfãos ------
    while (( i < n )); do
        ts=""
        if [[ "${lines[i]}" == '#'* && "${lines[i]}" =~ ^#[0-9]+$ ]]; then
            ts="${lines[i]}"
            ((i++))
        fi

        body=()
        while (( i < n )); do
            line="${lines[i]}"
            [[ "$line" == '#'* && "$line" =~ ^#[0-9]+$ ]] && break
            # prefixo EXTENDED_HISTORY do zsh: ": <epoch>:0;comando"
            if [[ "$line" == ': '* && "$line" =~ ^:\ [0-9]{10}:0\;(.*)$ ]]; then
                line="${BASH_REMATCH[1]}"
                changed=1
            fi
            body+=("$line")
            ((i++))
        done

        if (( ${#body[@]} == 0 )); then
            [[ -n "$ts" ]] && changed=1     # timestamp órfão descartado
            continue
        fi

        if (( ${#body[@]} == 1 )); then
            joined="${body[0]}"
        else
            printf -v joined '%s\n' "${body[@]}"
            joined="${joined%$'\n'}"
        fi

        ts_list+=("$ts")
        body_list+=("$joined")
    done

    local total=${#body_list[@]}
    (( total == 0 )) && { _histfile_touch_stamp "$stamp"; return 0; }

    #--- dedup por BLOCO, mantendo a ocorrência mais recente ------------------
    local keep_idx=()
    if (( dedup )); then
        local -A seen=()
        for (( i=total-1; i>=0; i-- )); do
            if [[ -z "${seen[${body_list[i]}]:-}" ]]; then
                seen["${body_list[i]}"]=1
                keep_idx+=("$i")
            fi
        done
        (( ${#keep_idx[@]} != total )) && changed=1
    else
        for (( i=total-1; i>=0; i-- )); do keep_idx+=("$i"); done
    fi

    #--- monta a saída, completando timestamps que faltam ---------------------
    local now out=() idx k=${#keep_idx[@]}
    printf -v now '%(%s)T' -1
    for (( i=k-1; i>=0; i-- )); do
        idx="${keep_idx[i]}"
        if [[ -n "${ts_list[idx]}" ]]; then
            out+=("${ts_list[idx]}")
        else
            out+=("#$now")
            changed=1
        fi
        out+=("${body_list[idx]}")
    done

    if (( ! changed )); then
        _histfile_touch_stamp "$stamp"
        _hist_say "Histórico já está limpo (${total} comandos)."
        return 2                      # 2 = nada a fazer, não precisa recarregar
    fi

    #--- grava: backup por hard link (instantâneo) + rename atômico -----------
    local had_noclobber=0
    [[ -o noclobber ]] && { had_noclobber=1; set +C; }

    tmp_file="${hist_file}.tmp.$$.$RANDOM"
    if ! printf '%s\n' "${out[@]}" > "$tmp_file" 2>/dev/null; then
        rm -f -- "$tmp_file" 2>/dev/null
        (( had_noclobber )) && set -C
        _hist_err "falha ao escrever o arquivo temporário"
        return 1
    fi

    (( HISTMAINT_BACKUP )) && ln -f -- "$hist_file" "${hist_file}.bak" 2>/dev/null

    chmod 600 -- "$tmp_file" 2>/dev/null
    if ! mv -f -- "$tmp_file" "$hist_file" 2>/dev/null; then
        rm -f -- "$tmp_file" 2>/dev/null
        (( had_noclobber )) && set -C
        _hist_err "falha ao substituir $hist_file (backup em ${hist_file}.bak)"
        return 1
    fi

    _histfile_touch_stamp "$stamp"
    (( had_noclobber )) && set -C

    _hist_say "Histórico: ${k} comandos mantidos, $(( total - k )) duplicatas removidas."
    return 0
}

###############################################################################
# Manutenção completa. Silenciosa. Sai em ~0 processos se nada mudou.
###############################################################################
history_maintenance() {
    local hist_file stamp rc
    hist_file="$(_histfile_path)"
    stamp="$(_histfile_stamppath)"

    [[ -f "$hist_file" ]] || return 0
    # atalho builtin: histórico não mexido desde a última manutenção
    [[ -f "$stamp" && ! "$hist_file" -nt "$stamp" ]] && return 0

    _histfile_with_lock _hist_process 1
    rc=$?
    case "$rc" in
        0) _histfile_reload; return 0 ;;   # mudou: recarrega
        2) return 0 ;;                     # nada a fazer: não recarrega
        4) return 0 ;;                     # lock ocupado: outro terminal cuida
        3) _hist_err "não consegui abrir o lock ($(_histfile_lockpath))"; return 3 ;;
        *) return "$rc" ;;
    esac
}

# Mesma coisa, mas sem deduplicar (só normaliza formato e timestamps).
history_normalize() {
    local rc
    [[ -f "$(_histfile_path)" ]] || return 0
    _histfile_with_lock _hist_process 0
    rc=$?
    case "$rc" in
        0) _histfile_reload; return 0 ;;
        2|4) return 0 ;;
        3) _hist_err "não consegui abrir o lock ($(_histfile_lockpath))"; return 3 ;;
        *) return "$rc" ;;
    esac
}

# Força a limpeza mesmo que o carimbo diga que nada mudou.
history_clean_duplicate_commands() {
    local rc
    [[ -f "$(_histfile_path)" ]] || { _hist_err "arquivo de histórico não encontrado"; return 1; }
    _histfile_with_lock _hist_process 1
    rc=$?
    case "$rc" in
        0) _histfile_reload; return 0 ;;
        2|4) return 0 ;;
        3) _hist_err "não consegui abrir o lock ($(_histfile_lockpath))"; return 3 ;;
        *) return "$rc" ;;
    esac
}

###############################################################################
# Restaura o backup (hard link da versão anterior).
###############################################################################
history_restore_last_backup() {
    local hist_file bak
    hist_file="$(_histfile_path)"
    bak="${hist_file}.bak"
    [[ -f "$bak" ]] || { _hist_err "nenhum backup encontrado ($bak)"; return 1; }
    cp -f -- "$bak" "$hist_file" || return 1
    rm -f -- "$(_histfile_stamppath)" 2>/dev/null
    _histfile_reload
    _hist_say "Histórico restaurado de $bak"
}

###############################################################################
# Compatibilidade com os nomes antigos — todos caem na passada única.
###############################################################################
history_strip_zsh_timestamps()     { history_normalize; }
history_remove_orphan_timestamps() { history_normalize; }
history_add_missing_timestamps()   { history_normalize; }
_remove_timestamp_in_single_line_format_from_bash_history() { history_normalize; }
_remove_unused_timestamps_from_bash_history()               { history_normalize; }
_include_timestamp_in_bash_history()                        { history_normalize; }