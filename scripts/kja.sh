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

FILE="kja.sqlite"
SCRIPT="${0##*/}"
CACHEDIR="${HOME}/.cache"
PATH1="/usr/share/kja/$FILE"
PATH2="$HOME/.shell_utils/database/kja/$FILE"
CACHEKJA="${CACHEDIR}/${SCRIPT%.*}"
LAST_CHAPTER_FILE="${CACHEKJA}/KJA_LAST_CHAPTER_FILE.db"

if [[ -f "$PATH1" ]]; then
	DB_FILE="$PATH1"
elif [[ -f "$PATH2" ]]; then
	DB_FILE="$PATH2"
elif [[ -f "$FILE" ]]; then
	DB_FILE="$FILE"
fi

[[ ! -d "${CACHEKJA}" ]] && mkdir -p "${CACHEKJA}"

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
	cat <<-EOF
	${SCRIPT} - Navegador da Bíblia King James Atualizada para terminal

	USO:
		${SCRIPT} [OPÇÕES]

	OPÇÕES:
		-h, --help          Mostra esta ajuda
		-d, --dark          Tema escuro (fundo preto, texto branco)
		-db,--dbrown        Tema marrom escuro (fundo preto, texto laranja)
		-w, --white         Tema claro (fundo branco, texto preto)
		-b, --blue          Tema azul (fundo azul escuro, texto ciano)
		-hig,--highlight    Tema alto contraste (fundo cinza, texto verde)
		-bb,--bbrown        Tema bege (fundo bege, texto marrom)

	VARIÁVEIS DE ESTILO (via linha de comando ou edição no script):
		STYLE               Controla cores do texto/fundo (códigos ANSI)
		HIGHLIGHT           Cor dos termos buscados (padrão: amarelo)
		KJA_MARGIN          Margem lateral do texto (padrão: 5)

	CONTROLES INTERATIVOS:
		/                   Buscar termos nos versículos
		n/N                 Navegar entre resultados da busca
		I                   Alternar busca sensível a maiúsculas
		w/s, ↑/↓, j/k       Rolagem vertical
		c                   Voltar ao topo do capítulo
		q                   Sair para seleção de livros

	EXEMPLOS:
		${SCRIPT} --dark    # Executa com tema escuro
		${SCRIPT} --blue    # Tema azul para melhor legibilidade

	ARQUIVO DE DADOS:
		${DB_FILE}          Banco SQLite com o texto bíblico
		${LAST_CHAPTER_FILE} Armazena último capítulo lido

	DEPENDÊNCIAS:
		sqlite3, dialog     Necessários para busca e interface
	EOF
}

prepare_terminal() {
	# Esconder o cursor
	printf '\e[?25l'

	# Desabilitar o echo das teclas pressionadas
	stty -echo </dev/tty >/dev/null 2>/dev/null
}

reset_terminal() {
	# Mostrar o cursor
	printf '\e[?25h'

	# Habilitar o echo das teclas pressionadas
	stty echo </dev/tty >/dev/null 2>/dev/null
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
                INICIAL=$(dialog --title "Bíblia KJA" --inputbox "Digite a inicial do livro:" 8 40 2>&1 >/dev/tty)
                if [ -n "$INICIAL" ]; then
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
                fi
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
        linha=$(echo "$linha" | sed -E -e 's|<i>([^<]*)</i>|\\e[3m\1\\e[23m|g' \
                                      -e 's|<small>([^<]*)</small>|\L\1|g')
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
        echo -e "${bold}Controles: [↑/↓ ou w/s ou j/k para Navegar] [/ Buscar termos] [N/n Próximo] [Q/q Sair]"
    }

    # Loop principal de navegação
    while [[ $quit -eq 0 ]]; do
        display_page
        
        # Captura de tecla
        IFS= read -rsn1 key </dev/tty >/dev/null 2>/dev/null
        if [[ $key == $'\033' ]]; then  # Tecla de escape (setas)
            read -rsn2 -t 0.1 key2 </dev/tty >/dev/null 2>/dev/null
            case "$key2" in
                '[A') # Seta para cima
                    ((current_line = current_line > 0 ? current_line - 1 : 0))
                    ;;
                '[B') # Seta para baixo
                    ((current_line = current_line + lines_per_page < total_lines ? current_line + 1 : current_line))
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
        elif [[ $key == 'n' || $key == 'N' ]]; then  # Próximo match
            if [[ ${#search_matches[@]} -gt 0 ]]; then
                ((current_match = (current_match + 1) % ${#search_matches[@]}))
                current_line=${search_matches[$current_match]}
            fi
        else
            case "$key" in
                'w'|'j'|'W'|'J') # Tecla W (cima)
                    ((current_line = current_line > 0 ? current_line - 1 : 0))
                    ;;
                's'|'k'|'S'|'K') # Tecla S (baixo)
                    ((current_line = current_line + lines_per_page < total_lines ? current_line + 1 : current_line))
                    ;;
				'c'|'l'|'C'|'L')
					prepare_terminal
					search_pattern=""
					search_matches=()
					current_match=0
					current_line=0  # Volta ao topo do capítulo
                    ;;
                'q'|'Q') # Tecla Q (sair)
                    quit=1
                    ;;
                'i'|'I') # Alternar case-sensitive
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

case $1 in
	-h|--help)
		help
	;;
	-d|--dark)
		STYLE='\033[38;5;231;48;5;16m'
	;;
	-db|--dbrown)
		STYLE='\033[38;5;209;48;5;16m'
	;;
	-w|--white)
		STYLE='\033[38;5;16;48;5;231m'
	;;
	-b|--blue)
		STYLE='\033[38;5;51;48;5;24m'
	;;
	-hig|--highlight)
		STYLE='\033[38;5;155;48;5;241m'
	;;
	-bb|--bbrown)
		STYLE='\033[38;5;94;48;5;187m'
	;;
esac

# Loop principal
mostrar_livros

reset_terminal