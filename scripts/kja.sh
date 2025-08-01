#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
1. Busca bíblica em terminal da Bíblia King James Atualizada, com interface "dialog" e banco de dados SQLite.  
2. Navega por 66 livros, capítulos e versículos com histórico de última leitura.  
3. Busca global (toda a Bíblia) ou por livro específico.  
4. Destaque de termos com cores personalizáveis ("-d", "-w", "-b").  
5. Modos de busca: "I" alterna entre "case-sensitive" e "case-insensitive".  
6. Navegação rápida: teclas "w/s", "j/k" ou setas, "/" busca, "n/N" entre matches.  
7. Portável: verifica dependências ("sqlite3", "dialog") e valida o arquivo bíblico.  
DOCUMENTATION

NC="\033[0m"
RED="\033[1;31m"
FILE="kja.sqlite"
SCRIPT="${0##*/}"
CACHEDIR="${HOME}/.cache"
PATH1="/usr/share/kja/$FILE"
PATH2="$HOME/.shell_utils/database/kja/$FILE"
CACHE_KJA="${CACHEDIR}/${SCRIPT%.*}"
HISTORY_FILE="${CACHE_KJA}/KJA_HISTORY_FILE.db"
LAST_CHAPTER_FILE="${CACHE_KJA}/KJA_LAST_CHAPTER_FILE.db"
RANDOM_CHAPTER_FILE="${CACHE_KJA}/KJA_RANDOM_CHAPTER_FILE.db"

if [[ -f "$PATH1" ]]; then
	DB_FILE="$PATH1"
elif [[ -f "$PATH2" ]]; then
	DB_FILE="$PATH2"
elif [[ -f "$FILE" ]]; then
	DB_FILE="$FILE"
fi

[[ ! -d "${CACHE_KJA}" ]] && mkdir -p "${CACHE_KJA}"

[ -f "$DB_FILE" ] && {
	MD5SUM_DB_FILE=$(md5sum "$DB_FILE" | awk '{print $1}')

	if [[ $MD5SUM_DB_FILE != 8e2ff9c4ed9015cc3d049c12ae4395ca ]]; then
		echo "O arquivo ${DB_FILE##*/} não corresponde a Bília King James Atualizada."
		exit 1
	fi
}

# Verifica se o dialog está instalado
if ! command -v dialog &> /dev/null; then
    echo "O 'dialog' não está instalado. Por favor, instale-o."
    exit 1
fi

# Verifica se o sqlite3 está instalado
if ! command -v sqlite3 &> /dev/null; then
    echo "O SQLite3 não está instalado. Por favor, instale-o."
    exit 1
fi

# Verifica se o arquivo kja.sqlite existe
if [ ! -f "$DB_FILE" ]; then
    echo "O arquivo $DB_FILE não foi encontrado. Certifique-se de que ele está no mesmo diretório que este script."
    exit 1
fi

# Lista dos 66 livros da Bíblia cristã (em português), separando ID e nome
declare -a LIVROS=(
    "1" "Gênesis" "2" "Êxodo" "3" "Levítico" "4" "Números" "5" "Deuteronômio"
    "6" "Josué" "7" "Juízes" "8" "Rute" "9" "1 Samuel" "10" "2 Samuel"
    "11" "1 Reis" "12" "2 Reis" "13" "1 Crônicas" "14" "2 Crônicas" "15" "Esdras"
    "16" "Neemias" "17" "Ester" "18" "Jó" "19" "Salmos" "20" "Provérbios"
    "21" "Eclesiastes" "22" "Cantares" "23" "Isaías" "24" "Jeremias" "25" "Lamentações"
    "26" "Ezequiel" "27" "Daniel" "28" "Oseias" "29" "Joel" "30" "Amós"
    "31" "Obadias" "32" "Jonas" "33" "Miqueias" "34" "Naum" "35" "Habacuque"
    "36" "Sofonias" "37" "Ageu" "38" "Zacarias" "39" "Malaquias"
    "40" "Mateus" "41" "Marcos" "42" "Lucas" "43" "João" "44" "Atos"
    "45" "Romanos" "46" "1 Coríntios" "47" "2 Coríntios" "48" "Gálatas" "49" "Efésios"
    "50" "Filipenses" "51" "Colossenses" "52" "1 Tessalonicenses" "53" "2 Tessalonicenses"
    "54" "1 Timóteo" "55" "2 Timóteo" "56" "Tito" "57" "Filemom" "58" "Hebreus"
    "59" "Tiago" "60" "1 Pedro" "61" "2 Pedro" "62" "1 João" "63" "2 João"
    "64" "3 João" "65" "Judas" "66" "Apocalipse"
    "q" "Sair"
)

help() {
    cat <<-EOF | less -i
    ${SCRIPT} - Navegador da Bíblia King James Atualizada para terminal

    USO:
        ${SCRIPT} [OPÇÕES]

    OPÇÕES:
        -h, --help          Mostra esta ajuda
        -l, --livro         Buscar livro desejado pela inicial.
        -m, --margin        Define uma margem extra para todo texto.
        -d, --dark          Tema escuro (fundo preto, texto branco)
        -db,--dbrown        Tema marrom escuro (fundo preto, texto laranja)
        -w, --white         Tema claro (fundo branco, texto preto)
        -b, --blue          Tema azul (fundo azul escuro, texto ciano)
        -hi,--highlight     Tema alto contraste (fundo cinza, texto verde)
        -bb,--bbrown        Tema bege (fundo bege, texto marrom)

    VARIÁVEIS DE ESTILO (via linha de comando ou edição no script):
        STYLE               Controla cores do texto/fundo (códigos ANSI)
        HIGHLIGHT           Cor dos termos buscados (padrão: amarelo)
        KJA_MARGIN          Margem lateral do texto (padrão: 5)

    CONTROLES INTERATIVOS:
        Navegação:
        ↑/↓, w/s, j/k       Rolagem vertical
        ←/→, h/l            Capítulo anterior/próximo
        c                   Limpar os termos da busca e voltar ao topo do capítulo
        q                   Sair para seleção de livros

        Busca:
        /                   Buscar termos nos versículos
        n/N                 Navegar entre resultados da busca
        F                   Alternar busca sensível a maiúsculas

        Histórico e cópia:
        S                   Salvar capítulo no histórico
        Z                   Copiar capítulo para área de transferência
        D                   Deletar item do histórico (no gerenciador)

        Mouse:
        Scroll              Rolagem vertical
        Clique              Navegação em links (se aplicável)

    MENU PRINCIPAL:
        1. Buscar livro por número
        2. Buscar livro por inicial
        3. Buscar termo na Bíblia
        4. Buscar termo em um livro específico
        5. Último capítulo acessado
        6. Gerenciar histórico de capítulos

    EXEMPLOS:
        ${SCRIPT} --dark    # Executa com tema escuro
        ${SCRIPT} --blue    # Tema azul para melhor legibilidade

    ARQUIVO DE DADOS:
        Banco SQLite com o texto bíblico (${DB_FILE})
        Histórico de capítulos          (${HISTORY_FILE})
        Último capítulo lido            (${LAST_CHAPTER_FILE})

    DEPENDÊNCIAS:
        sqlite3, dialog     Necessários para busca e interface
        xclip/wl-copy/termux-clipboard-set  Para cópia para área de transferência

    RECURSOS AVANÇADOS:
        - Histórico de capítulos visitados (acessível pelo menu)
        - Copiar capítulos inteiros para área de transferência (tecla Z)
        - Navegação rápida entre capítulos (setas esquerda/direita)
        - Destaque de termos de busca com cores personalizáveis
        - Suporte a múltiplos ambientes (X11, Wayland, Termux)
EOF
    exit 0
}

# Verifica métodos para copiar para área de transferência
setup_clipboard() {
    # Termux (Android)
    if [[ -n "$TERMUX_VERSION" ]]; then
        if command -v termux-clipboard-set &> /dev/null; then
            clipboard_copy() {
                echo -ne "$1" | termux-clipboard-set
                notify_send "Bíblia KJA" "Capítulo copiado para área de transferência!"
            }
        else
            clipboard_copy() {
                dialog --title "Aviso" --msgbox "termux-clipboard-set não está disponível. Não é possível copiar para área de transferência." 8 50
            }
        fi
    
    # Wayland
    elif [[ ${XDG_SESSION_TYPE,,} == "wayland" ]]; then
        if command -v wl-copy &> /dev/null; then
            clipboard_copy() {
                echo -ne "$1" | wl-copy
                notify_send "Bíblia KJA" "Capítulo copiado para área de transferência!"
            }
        else
            clipboard_copy() {
                dialog --title "Aviso" --msgbox "wl-copy não está instalado. Não é possível copiar para área de transferência no Wayland." 8 50
            }
        fi
    
    # X11
    elif [[ ${XDG_SESSION_TYPE,,} == "x11" ]] || [[ -n "$DISPLAY" ]]; then
        if command -v xclip &> /dev/null; then
            clipboard_copy() {
                echo -ne "$1" | xclip -selection clipboard
                notify_send "Bíblia KJA" "Capítulo copiado para área de transferência!"
            }
        else
            clipboard_copy() {
                dialog --title "Aviso" --msgbox "xclip não está instalado. Não é possível copiar para área de transferência no X11." 8 50
            }
        fi
    
    # Outros ambientes (macOS, etc)
    else
        if command -v pbcopy &> /dev/null; then  # macOS
            clipboard_copy() {
                echo -ne "$1" | pbcopy
                notify_send "Bíblia KJA" "Capítulo copiado para área de transferência!"
            }
        else
            clipboard_copy() {
                dialog --title "Aviso" --msgbox "Nenhum método de cópia para área de transferência disponível para este ambiente." 8 50
            }
        fi
    fi
}

# Configura o clipboard apropriado para o ambiente
setup_clipboard

hide_cursor() { printf "\e[?25l"; }
show_cursor() { printf "\e[?25h"; }
hide_echo() { stty -echo -icanon </dev/tty >/dev/null 2>/dev/null; }
show_echo() { stty echo </dev/tty >/dev/null 2>/dev/null; }

prepare_terminal() {
	# Esconder o cursor
	hide_cursor

	# Desabilitar o echo das teclas pressionadas
	hide_echo
}

reset_terminal() {
	# Desabilita eventos do mouse
	echo -ne "\033[?1000l\033[?1006l"

	# Mostrar o cursor
	show_cursor

	# Habilitar o echo das teclas pressionadas
	show_echo
}

notify_send() {
	dialog --title "$1" --msgbox "$2" 8 40 >/dev/tty 2>&1
	[[ ${XDG_SESSION_TYPE,,} != tty ]] && [[ -z "$TERMUX_VERSION" ]] && 
	command -v notify-send >/dev/null && notify-send "$1" "$2"
}

gerenciar_historico() {
    if [ ! -f "$HISTORY_FILE" ] || [ ! -s "$HISTORY_FILE" ]; then
        dialog --title "Histórico" --msgbox "Nenhum capítulo no histórico ainda." 8 40 >/dev/tty 2>&1
        return
    fi

    # Ler o histórico e formatar para exibição
    declare -a historico_itens
    while IFS="|" read -r id nome cap; do
        historico_itens+=("$id|$nome|$cap" "$nome Capítulo $cap")
    done < "$HISTORY_FILE"

    while true; do
        escolha=$(dialog --title "Gerenciar Histórico" \
                         --menu "Selecione um capítulo (D para deletar):" \
                         40 80 40 "${historico_itens[@]}" \
                         2>&1 >/dev/tty)
        
        if [ -z "$escolha" ]; then
            break
        fi

        # Espera MUITO curto por uma tecla
        read -rsn1 -t 1 key </dev/tty >/dev/null 2>&1
        
        # Verificar se pressionou 'D' (case insensitive)
        if [[ "${key^^}" == "D" ]]; then  
            dialog --title "Histórico" \
                   --yesno "Pressione 'Sim' para deletar ou 'Não' para abrir o capítulo" \
                   8 40 >/dev/tty 2>&1

            if [ $? -eq 0 ]; then  # Sim - deletar
                # Remove a linha exata do arquivo
                grep -vF "$escolha" "$HISTORY_FILE" > "${HISTORY_FILE}.tmp"
                mv "${HISTORY_FILE}.tmp" "$HISTORY_FILE"
                
                # Atualiza a lista
                historico_itens=()
                while IFS="|" read -r id nome cap; do
                    historico_itens+=("$id|$nome|$cap" "$nome Capítulo $cap")
                done < "$HISTORY_FILE"
                
                dialog --title "Histórico" --msgbox "Item removido do histórico." 8 40
                continue  # Volta para o menu após deletar
            fi
        fi
        
        # Abre o capítulo
        IFS="|" read -r livro_id nome_livro cap <<< "$escolha"
        mostrar_versiculos "$livro_id" "$nome_livro" "$cap"
        return
    done
}

random_chapter() {
    TOTAL_CHAPTERS=1189  # Total de capítulos na Bíblia cristã
    
    # Se o arquivo não existir, cria um vazio
    [[ ! -f "$RANDOM_CHAPTER_FILE" ]] && touch "$RANDOM_CHAPTER_FILE"
    
    # Se o arquivo contiver todos os capítulos, reinicia
    if [[ $(wc -l < "$RANDOM_CHAPTER_FILE") -ge $TOTAL_CHAPTERS ]]; then
        rm "$RANDOM_CHAPTER_FILE"
        touch "$RANDOM_CHAPTER_FILE"
    fi
    
    while true; do
        # Gera um livro aleatório (1-66)
        livro_id=$((RANDOM % 66 + 1))
        
        # Obtém o nome do livro
        for ((i=0; i<${#LIVROS[@]}; i+=2)); do
            if [[ "${LIVROS[$i]}" == "$livro_id" ]]; then
                nome_livro="${LIVROS[$i+1]}"
                break
            fi
        done
        
        # Obtém o número máximo de capítulos para este livro
        max_capitulos=$(sqlite3 "$DB_FILE" "SELECT MAX(chapter) FROM verse WHERE book_id = $livro_id;")
        
        # Gera um capítulo aleatório para este livro
        capitulo=$((RANDOM % max_capitulos + 1))
        
        # Verifica se este capítulo já foi mostrado
        if ! grep -q "^${livro_id}|${nome_livro}|${capitulo}$" "$RANDOM_CHAPTER_FILE"; then
            # Adiciona ao histórico de capítulos mostrados
            echo "${livro_id}|${nome_livro}|${capitulo}" >> "$RANDOM_CHAPTER_FILE"
            
            # Mostra o capítulo selecionado
            mostrar_versiculos "$livro_id" "$nome_livro" "$capitulo"
            return
        fi
    done
}

show_random_stats() {
    [[ ! -f "$RANDOM_CHAPTER_FILE" ]] && {
        dialog --title "Estatísticas" --msgbox "Nenhum capítulo foi mostrado ainda." 7 40
        return
    }

    total_shown=$(wc -l < "$RANDOM_CHAPTER_FILE")
    remaining=$((1189 - total_shown))
    
    # Contagem por livro
    declare -A book_counts
    while IFS="|" read -r id _ _; do
        ((book_counts[$id]++))
    done < "$RANDOM_CHAPTER_FILE"

    # Prepara relatório
    stats_report="Capítulos mostrados: $total_shown\nRestantes: $remaining\n\nDistribuição por livro:\n"
    
    for id in "${!book_counts[@]}"; do
        for ((i=0; i<${#LIVROS[@]}; i+=2)); do
            [[ "${LIVROS[$i]}" == "$id" ]] && {
                stats_report+="${LIVROS[i+1]}: ${book_counts[$id]}\n"
                break
            }
        done
    done

    dialog --title "Estatísticas da Palavra do Dia" --msgbox "$stats_report" 20 60
}

buscar_livros() {
	if [ -z "$1" ]; then
		INICIAL=$(dialog --title "Bíblia KJA" --inputbox "Digite a inicial do livro:" 8 40 2>&1 >/dev/tty)
	else
		INICIAL="$1"
	fi

	if [ -n "$INICIAL" ]; then
		INICIAL="${INICIAL,,}"
		
		# Filtra os livros que começam com a inicial digitada
		declare -a LIVROS_FILTRADOS
		for ((i=0; i<${#LIVROS[@]}; i+=2)); do
			if [[ "${LIVROS[$i+1]}" == ${INICIAL^}* ]]; then
				LIVROS_FILTRADOS+=("${LIVROS[$i]}" "${LIVROS[$i+1]}")
			fi
		done

		if [ ${#LIVROS_FILTRADOS[@]} -eq 0 ]; then
			dialog --title "Erro" --msgbox "Nenhum livro encontrado com a inicial '$INICIAL'." 8 40
		else
			LIVRO=$(dialog --title "Bíblia KJA" --menu "Escolha um livro:" 40 60 40 "${LIVROS_FILTRADOS[@]}" 2>&1 >/dev/tty)
			if [ -n "$LIVRO" ]; then
				# Busca o nome do livro correspondente ao ID selecionado
				for ((i=0; i<${#LIVROS[@]}; i+=2)); do
					if [ "${LIVROS[$i]}" == "$LIVRO" ]; then
						NOME_LIVRO="${LIVROS[$i+1]}"
						mostrar_capitulos "$LIVRO" "$NOME_LIVRO"
						break
					fi
				done
			fi
		fi
	else
		dialog --title "Erro" --msgbox "Informe as iniciais de algum livro!" 8 40
	fi
	LIVROS_FILTRADOS=()
}

# Função para exibir o menu de livros
mostrar_livros() {
	prepare_terminal
    while true; do
		if [[ -f "$LAST_CHAPTER_FILE" ]]; then
			local ultimo_capitulo_option="Último capítulo acessado"
		else
			local ultimo_capitulo_option="Último capítulo acessado (não disponível)"
		fi

        OPCAO=$(dialog --title "Bíblia KJA" --menu "Escolha uma opção:" 20 60 15 \
            "1" "Buscar livro por número" \
            "2" "Buscar livro por inicial" \
            "3" "Buscar termo na Bíblia" \
            "4" "Buscar termo em um livro específico" \
			"5" "$ultimo_capitulo_option" \
			"6" "Gerenciar histórico de capítulos" \
			"7" "Palavra do dia" \
			"8" "Estatísticas da Palavra do Dia" \
            "q" "Sair" 2>&1 >/dev/tty)

        case $OPCAO in
            1)
                LIVRO=$(dialog --title "Bíblia KJA" --menu "Escolha um livro (ou 'Sair' para encerrar):" 40 60 40 "${LIVROS[@]}" 2>&1 >/dev/tty)
                if [ "$LIVRO" == "q" ]; then
                    clear
                    exit 0 # Sai do script ao selecionar "Sair"
                elif [ -n "$LIVRO" ]; then
                    # Busca o nome do livro correspondente ao ID selecionado
                    for ((i=0; i<${#LIVROS[@]}; i+=2)); do
                        if [ "${LIVROS[$i]}" == "$LIVRO" ]; then
                            NOME_LIVRO="${LIVROS[$i+1]}"
                            mostrar_capitulos "$LIVRO" "$NOME_LIVRO"
                            break
                        fi
                    done
                fi
                ;;
            2)
                buscar_livros
                ;;
            3)
                TERMO=$(dialog --title "Buscar termo na Bíblia" --inputbox "Digite o termo que deseja buscar:" 8 40 2>&1 >/dev/tty)
                if [ -n "$TERMO" ]; then
                    buscar_termo_na_biblia "$TERMO"
                fi
                ;;
            4)
                LIVRO=$(dialog --title "Bíblia KJA" --menu "Escolha um livro para buscar o termo:" 40 60 40 "${LIVROS[@]}" 2>&1 >/dev/tty)
                if [ "$LIVRO" == "q" ]; then
                    continue
                elif [ -n "$LIVRO" ]; then
                    TERMO=$(dialog --title "Buscar termo no livro" --inputbox "Digite o termo que deseja buscar:" 8 40 2>&1 >/dev/tty)
                    if [ -n "$TERMO" ]; then
                        buscar_termo_no_livro "$LIVRO" "$TERMO"
                    fi
                fi
                ;;
			5)
                if [[ -f "$LAST_CHAPTER_FILE" ]]; then
                    IFS="|" read -r livro_id nome_livro capitulo < "$LAST_CHAPTER_FILE"
                    mostrar_versiculos "$livro_id" "$nome_livro" "$capitulo"
                fi
                ;;
			6)
				gerenciar_historico
				;;
			7)
				random_chapter
				;;
			8)
				show_random_stats
				;;
            q)
                clear
				reset_terminal
                exit 0 # Sai do script ao selecionar "Sair"
                ;;
        esac
    done
}

# Função para buscar um termo em toda a Bíblia
buscar_termo_na_biblia() {
    local termo=$1
    RESULTADOS=$(sqlite3 -separator "|" "$DB_FILE" "SELECT b.id, b.name, v.chapter, v.verse, v.text FROM verse v JOIN book b ON v.book_id = b.id WHERE v.text LIKE '%$termo%' ORDER BY b.id, v.chapter, v.verse;")

    if [ -z "$RESULTADOS" ]; then
        dialog --title "Resultado da busca" --msgbox "Nenhum resultado encontrado para o termo '$termo'." 8 40
    else
        declare -a OPCOES_RESULTADOS
        while IFS="|" read -r id nome capitulo versiculo texto; do
            # Formata o texto para exibição (remove espaços extras e limita tamanho)
            texto_limpo=$(echo "$texto" | sed 's/^[ \t]*//;s/[ \t]*$//' | tr -s ' ')
            texto_exibicao=$(echo "$texto_limpo" | cut -c 1-360)
            OPCOES_RESULTADOS+=("$id,$capitulo,$versiculo" "$nome $capitulo:$versiculo - $texto_exibicao...")
        done <<< "$RESULTADOS"

        SELECAO=$(dialog --title "Resultado da busca" --menu "Escolha um versículo:" 40 160 40 "${OPCOES_RESULTADOS[@]}" 2>&1 >/dev/tty)
        
        if [ -n "$SELECAO" ]; then
            IFS="," read -r livro_id capitulo versiculo <<< "$SELECAO"
            for ((i=0; i<${#LIVROS[@]}; i+=2)); do
                if [ "${LIVROS[$i]}" == "$livro_id" ]; then
                    NOME_LIVRO="${LIVROS[$i+1]}"
                    mostrar_versiculos "$livro_id" "$NOME_LIVRO" "$capitulo"
                    break
                fi
            done
        fi
    fi
}
# Função para buscar um termo em um livro específico
buscar_termo_no_livro() {
    local livro_id=$1
    local termo=$2
    RESULTADOS=$(sqlite3 -separator " | " "$DB_FILE" "SELECT b.id, b.name, v.chapter, v.verse, v.text FROM verse v JOIN book b ON v.book_id = b.id WHERE v.book_id = $livro_id AND v.text LIKE '%$termo%';")

    if [ -z "$RESULTADOS" ]; then
        dialog --title "Resultado da busca" --msgbox "Nenhum resultado encontrado para o termo '$termo' no livro selecionado." 8 40
    else
        # Formata os resultados para exibição no menu
        declare -a OPCOES_RESULTADOS
        while IFS="|" read -r id nome capitulo versiculo texto; do
            OPCOES_RESULTADOS+=("$capitulo|$versiculo" "$nome $capitulo:$versiculo - $texto")
        done <<< "$RESULTADOS"

        SELECAO=$(dialog --title "Resultado da busca" --menu "Escolha um versículo para abrir:" 40 160 40 "${OPCOES_RESULTADOS[@]}" 2>&1 >/dev/tty)
        if [ -n "$SELECAO" ]; then
            IFS="|" read -r capitulo versiculo <<< "$SELECAO"
            for ((i=0; i<${#LIVROS[@]}; i+=2)); do
                if [ "${LIVROS[$i]}" == "$livro_id" ]; then
                    NOME_LIVRO="${LIVROS[$i+1]}"
                    mostrar_versiculos "$livro_id" "$NOME_LIVRO" "$capitulo"
                    break
                fi
            done
        fi
    fi
}

# Função para exibir os capítulos de um livro
mostrar_capitulos() {
    local livro_id=$1
    local nome_livro=$2

    # Consulta o número máximo de capítulos na tabela 'verse'
    CAPITULOS=$(sqlite3 "$DB_FILE" "SELECT MAX(chapter) FROM verse WHERE book_id = $livro_id;")

    if [ -z "$CAPITULOS" ]; then
        dialog --title "Erro" --msgbox "Não foram encontrados capítulos para $nome_livro." 8 40
        return
    fi

    # Cria um array de opções de capítulos
    declare -a OPCOES_CAPITULOS
    for ((i=1; i<=CAPITULOS; i++)); do
        OPCOES_CAPITULOS+=("$i" "Capítulo $i")
    done

    while true; do
        CAPITULO=$(dialog --title "$nome_livro" --menu "Escolha um capítulo (Esc para voltar):" 40 80 40 "${OPCOES_CAPITULOS[@]}" 2>&1 >/dev/tty)
        if [ $? -eq 0 ] && [ -n "$CAPITULO" ]; then
            mostrar_versiculos "$livro_id" "$nome_livro" "$CAPITULO"
        else
            break # Volta ao menu de livros se o usuário pressionar Esc
        fi
    done
}

next_chapter() {
	# Verifica se existe próximo capítulo
	next_chapter=$(sqlite3 "$DB_FILE" "SELECT MIN(chapter) FROM verse WHERE book_id = $livro_id AND chapter > $capitulo;")
	if [ -n "$next_chapter" ]; then
		mostrar_versiculos "$livro_id" "$nome_livro" "$next_chapter"
		return
	fi
}

prev_chapter() {
	# Verifica se existe capítulo anterior
	prev_chapter=$(sqlite3 "$DB_FILE" "SELECT MAX(chapter) FROM verse WHERE book_id = $livro_id AND chapter < $capitulo;")
	if [ -n "$prev_chapter" ]; then
		mostrar_versiculos "$livro_id" "$nome_livro" "$prev_chapter"
		return
	fi
}

prepare_clipboard() {
    # Pergunta ao usuário quais versículos deseja copiar
    versiculos_selecionados=$(dialog --title "Selecionar Versículos" \
        --inputbox "Digite os versículos desejados (ex: 1 3 5-7 10):" \
        10 50 2>&1 >/dev/tty)

    # Se o usuário cancelar ou deixar vazio, copia todo o capítulo
    if [[ -z "$versiculos_selecionados" ]]; then
        # Consulta todos os versículos do capítulo
        versiculos=$(sqlite3 -separator " " "$DB_FILE" "SELECT verse, text FROM verse WHERE book_id = $livro_id AND chapter = $capitulo ORDER BY verse;")
        
        # Formata o texto para copiar
        texto_para_copiar="$nome_livro $capitulo\n\n"
        while IFS= read -r linha; do
            # Remove tags HTML e formatação especial
            linha_limpa=$(echo "$linha" | sed -e 's/^[0-9]\+/\0./' -e 's/<[^>]*>//g' -e 's/^[ \t]*//')
            texto_para_copiar+="$linha_limpa\n"
        done <<< "$versiculos"
    else
        # Processa os versículos selecionados
        declare -a versiculos_array
        for item in $versiculos_selecionados; do
            if [[ $item == *-* ]]; then
                # Processa intervalo (ex: 5-10)
                inicio=${item%-*}
                fim=${item#*-}
                for ((v=inicio; v<=fim; v++)); do
                    versiculos_array+=("$v")
                done
            else
                # Adiciona versículo individual
                versiculos_array+=("$item")
            fi
        done

        # Consulta os versículos selecionados
        texto_para_copiar=""
        for v in "${versiculos_array[@]}"; do
            versiculo=$(sqlite3 -separator " " "$DB_FILE" "SELECT verse, text FROM verse WHERE book_id = $livro_id AND chapter = $capitulo AND verse = $v;")
            if [[ -n "$versiculo" ]]; then
                # Remove tags HTML e formatação especial
                versiculo_limpo=$(echo "$versiculo" | sed -e 's/^[0-9]\+/\0./' -e 's/<[^>]*>//g' -e 's/^[ \t]*//')
                texto_para_copiar+="$versiculo_limpo\n"
            fi
        done

        # Adiciona livro e capítulo no final
        texto_para_copiar+="(${nome_livro}, $capitulo)"
    fi

    # Copia para área de transferência
    clipboard_copy "$texto_para_copiar"
}

# Função para exibir os versículos de um capítulo
mostrar_versiculos() {
    local livro_id=$1
    local nome_livro=$2
    local capitulo=$3
	local all_screen="\033[2J"
	local bold="\033[1m"
	local reset="\033[0m"
	HIGHLIGHT="${HIGHLIGHT:-\033[33;1m}"
	STYLE="${STYLE:-\033[38;5;231;48;5;16m}"

	echo "$livro_id|$nome_livro|$capitulo" | tee "$LAST_CHAPTER_FILE" >/dev/null

    # Limpa a tela e aplica o tema
    clear
    echo -ne "${STYLE}${all_screen}"

    # Consulta os versículos
    VERSICULOS=$(sqlite3 -separator " " "$DB_FILE" "SELECT verse, text FROM verse WHERE book_id = $livro_id AND chapter = $capitulo ORDER BY verse;")

    if [ -z "$VERSICULOS" ]; then
        dialog --title "Erro" --msgbox "Não foram encontrados versículos para $nome_livro $capitulo." 8 40
        return
    fi

    # Processa e formata todos os versículos
    local formatted_text=""
    while IFS= read -r linha; do
		linha=$(echo "$linha" | sed -e 's/^[[:digit:]]\{1,\}/&./' \
								-e 's|<i>\([^<]*\)</i>|\\e[3m\1\\e[23m|g' \
								-e 's|<small>\([^<]*\)</small>|\L\1|g' \
								-e 's/<[^>]*>//g')
        formatted_text+="$linha"$'\n'
    done <<< "$VERSICULOS"

    # Divide o texto em linhas e configura paginação
    IFS=$'\n' read -d '' -r -a lines <<< "$(echo -e "$formatted_text" | fold -s -w $(($(tput cols) - ${KJA_MARGIN:-5})))"
    local total_lines=${#lines[@]}
	local header_and_footer_lines=10
    local lines_per_page=$(($(tput lines) - header_and_footer_lines))  # Reserva espaço para cabeçalho/rodapé
    local current_line=0
    local quit=0
    local search_pattern=""
    local search_matches=()
    local current_match=0
    local case_insensitive=1  # Busca case-insensitive por padrão

    # Função para encontrar todas as ocorrências do padrão
	find_matches() {
		search_matches=()
		local grep_flags=""
		[[ $case_insensitive -eq 1 ]] && grep_flags+="i"

		# Usa grep para encontrar linhas que correspondem ao padrão
		for ((i=0; i<total_lines; i++)); do
			if echo "${lines[i]}" | grep -qE$grep_flags "$search_pattern"; then
				search_matches+=($i)
			fi
		done
		current_match=0
	}

    # Função para exibir a página atual
	display_page() {
		clear
		echo -ne "${STYLE}${all_screen}"
		
		# Cabeçalho
		echo -e "${bold}$nome_livro $capitulo${reset}${STYLE}"
		[[ -n "$search_pattern" ]] && echo -e "\033[33mPadrão: /$search_pattern (${#search_matches[@]} matches)$reset"
		echo -e "${STYLE}--------------------------------------------------\n"
		
		# Conteúdo (com highlight das buscas)
		for ((i=current_line; i<current_line+lines_per_page && i<total_lines; i++)); do
			line="${lines[i]}"
			if [[ -n "$search_pattern" ]]; then
				# Destaca os matches
				flags=""
				[[ $case_insensitive -eq 1 ]] && flags+="I"
				line=$(awk -v search="$search_pattern" -v style="${STYLE}" \
				-v yellow="${HIGHLIGHT}" -v reset="$reset" -v ignore_case="$case_insensitive" \
					'BEGIN {
						if (ignore_case == 1) {
							IGNORECASE = 1
						}
					}
					{
						gsub(search, yellow "&" reset style);
						print
					}' <<< "${STYLE}${line}")
            fi
            echo -e "${STYLE}$line"
        done
        
        # Rodapé
        echo -e "\n--------------------------------------------------"
        if [[ ${#search_matches[@]} -gt 0 ]]; then
            echo -e "Match $((current_match + 1))/${#search_matches[@]} | "
        fi
        echo -e "${bold}${STYLE}Linha $((current_line + 1))-$((current_line + lines_per_page < total_lines ? current_line + lines_per_page : total_lines))/$total_lines"
		[[ -z "$TERMUX_VERSION" ]] && echo -e "${bold}Controles: [↑/↓ ou j/k para Navegar] [/ Procurar] [N Próximo] [S Salvar capítulo] [Z Copiar] [Q Sair]"
		[[ -n "$TERMUX_VERSION" ]] && echo -e "${bold}Controles:\n[↑/↓ ou j/k para Navegar] [/ Procurar]\n[N Próximo] [S Salvar capítulo] [Z Copiar] [Q Sair]"
    }

    # Loop principal de navegação
    while [[ $quit -eq 0 ]]; do
        display_page
		# Habilita relatórios estendidos do mouse
		echo -ne "\033[?1000h\033[?1006h"
        
        # Captura de tecla
        IFS= read -rsn1 key </dev/tty >/dev/null 2>/dev/null

		# Bloco de captura de teclas:
		if [[ $key == $'\033' ]]; then
			read -rsn2 -t 0.1 key2 </dev/tty >/dev/null 2>/dev/null
			case "$key2" in
				'[A') # Seta para cima
					((current_line = current_line > 0 ? current_line - 1 : 0))
					;;
				'[B') # Seta para baixo
					((current_line = current_line + lines_per_page < total_lines ? current_line + 1 : current_line))
					;;
				'[C') # Seta para direita - próximo capítulo
					next_chapter
					return
					;;
				'[D') # Seta para esquerda - capítulo anterior
					prev_chapter
					return
					;;
				'[<') # Evento de mouse no formato SGR
					# Ler o evento SGR até o 'M'
					mouse_event=""
					while IFS= read -rsn1 char </dev/tty >/dev/null 2>/dev/null; do
						mouse_event+="$char"
						[[ "$char" == "M" ]] && break
					done
					# Extrair o código do botão (antes do primeiro ';')
					button=$(echo "$mouse_event" | cut -d';' -f1)
					case $button in
						64) # Roda para cima (scroll up)
							((current_line = current_line > 0 ? current_line - 1 : 0))
							;;
						65) # Roda para baixo (scroll down)
							((current_line = current_line + lines_per_page < total_lines ? current_line + 1 : current_line))
							;;
					esac
					;;
			esac
		elif [[ $key == '/' ]]; then  # Iniciar busca
			reset_terminal
			echo -ne "\033[33m/"
			read -re search_pattern
			if [[ -n "$search_pattern" ]]; then
				find_matches
				if [[ ${#search_matches[@]} -gt 0 ]]; then
					current_line=${search_matches[0]}
				fi
			fi
		else
			case "$key" in
				'q'|'Q') # Tecla Q (sair)
					quit=1
					break
					;;
				'n'|'N') # Próximo match
					if [[ ${#search_matches[@]} -gt 0 ]]; then
						((current_match = (current_match + 1) % ${#search_matches[@]}))
						current_line=${search_matches[$current_match]}
					fi
					;;
				'k'|'K') # Tecla W (cima)
					((current_line = current_line > 0 ? current_line - 1 : 0))
					;;
				'j'|'J') # Tecla S (baixo)
					((current_line = current_line + lines_per_page < total_lines ? current_line + 1 : current_line))
					;;
				's'|'S') # Tecla S - salvar no histórico
					# Verifica se já existe no histórico
					if grep -q "^${livro_id}|${nome_livro}|${capitulo}$" "$HISTORY_FILE"; then
						notify_send "Bíblia KJA" "Capítulo $capitulo de $nome_livro já está no histórico!"
					else
						echo "${livro_id}|${nome_livro}|${capitulo}" | tee -a "$HISTORY_FILE" >/dev/null
						notify_send "Bíblia KJA" "Capítulo $capitulo de $nome_livro salvo no histórico!"
					fi
					;;
				'c'|'C')
					prepare_terminal
					search_pattern=""
					search_matches=()
					current_match=0
					current_line=0  # Volta ao topo do capítulo
					;;
				'z'|'Z') # Tecla Z - copiar capítulo para área de transferência
					prepare_clipboard
					;;
				'i'|'I') # Tecla I - para gerar imagem do versículo na área de transferência
					prepare_clipboard
					~/.shell_utils/scripts/cliptext2image.sh >/dev/null 2>&1
					;;
				'p'|'P') # Tecla P - para gerar PDF do capítulo na área de transferência
					prepare_clipboard
					~/.shell_utils/scripts/cliptext2pdf.sh >/dev/null 2>&1
					;;
				'l'|'L')
					next_chapter
					#return
					;;
				'h'|'H')
					prev_chapter
					#return
					;;
				'f'|'F') # Alternar case-sensitive
					((case_insensitive = !case_insensitive))
					if [[ -n "$search_pattern" ]]; then
						find_matches
					fi
					;;
			esac
		fi
	done

	# Restaura cores ao sair
	echo -ne "\033[0m"
	clear
}

while [ $# -gt 0 ]; do
	case $1 in
		-h|--help)
			help
		;;
		-d|--dark)
			shift
			STYLE='\033[38;5;231;48;5;16m'
		;;
		-db|--dbrown)
			shift
			STYLE='\033[38;5;209;48;5;16m'
		;;
		-w|--white)
			shift
			STYLE='\033[38;5;16;48;5;231m'
		;;
		-b|--blue)
			shift
			STYLE='\033[38;5;51;48;5;24m'
		;;
		-hi|--highlight)
			shift
			STYLE='\033[38;5;155;48;5;241m'
		;;
		-bb|--bbrown)
			shift
			STYLE='\033[38;5;94;48;5;187m'
		;;
		-m|--margin)
			{ [[ "$2" =~ ^[0-9]+$ ]] && KJA_MARGIN="$2"; } || { echo -e "${RED}São aceitos apenas números para margem!$NC" && exit 1; }
			shift 2
		;;
		-l|--livro)
			if [ -z "$2" ]; then  
				echo "Erro: --livro requer um nome." >&2
				exit 1
			fi
			prepare_terminal
			buscar_livros "$2"  
			shift 2             
			break
		;;
	esac
done

# Loop principal
mostrar_livros

reset_terminal