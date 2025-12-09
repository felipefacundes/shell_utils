ls_tips() {
	clear
	cat <<-'EOF'
	# Complete ls Command Guide - Examples and Explanations

    $ ls -lt | head -5
    $ ls -lt --time-style=+%Y-%m-%d | grep $(date +%Y-%m-%d)
    $ ls -lht --time-style=+%Y-%m-%d | grep $(date +%Y-%m-%d)
    $ ls -lt --time-style=+%s | awk -v limit=$(date -d "7 days ago" +%s) '$6 < limit'

	EOF
    echo -e "1) English tutorial\n2) Portuguese tutorial\n"
    read -r option
    [[ ! "$option" =~ ^[1-2]$ ]] && echo "Only number 1 or 2" && exit 1
    case $option in
        1)
            markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/ls_tips.md
        ;;
        2)
            markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/ls_tips_pt.md
        ;;
    esac
    clear
}

ls_help() {
	clear
echo "
	# ls help

"
    clear
    if [[ "${LANG,,}" =~ pt_ ]]; then
        ls_help_em_portugues
    else
        ls --help
    fi

}

ls_list_precise_all_files() {
    echo '
# ls -p | wc -l
'
}

ls_list_without_folders() {
echo '
# ls -p | grep -v / | wc -l
'
}

ls_list_only_name_of_folders() {
echo '
# ls -dF ~/example_folder_of_themes/*/ | xargs -n 1 basename
'
}

ls_lhs_listar_arquivos_com_detalhes_completos_e_ordenados_por_tamanho() {
    cat <<'EOF'
# ls -lhS # Listar arquivos com detalhes completos e ordenados por tamanho
Explicação:

    -l: Exibe as informações dos arquivos em um formato de listagem longa (permissões, 
    número de links, proprietário, grupo, tamanho, data/hora e nome do arquivo).
    -h: Mostra os tamanhos de forma legível para humanos (por exemplo, 1K, 234M).
    -S: Ordena os arquivos pelo tamanho, do maior para o menor.
EOF
}

ls_lt_time_style_with_grep_date_para_listar_apenas_os_arquivos_e_diretorios_modificados_na_data_atual() {
    cat <<'EOF'
# ls -lt --time-style=+%Y-%m-%d | grep "$(date +%Y-%m-%d)" # Para listar apenas os arquivos e diretórios modificados na data atual
Explicação:

    ls -lt: Lista os arquivos em formato longo, ordenados pela data de modificação, com os mais recentes primeiro.
    --time-style=+%Y-%m-%d: Configura o formato de exibição da data como ano-mês-dia, facilitando a correspondência com a data atual.
    grep "$(date +%Y-%m-%d)": Filtra a saída para mostrar apenas as linhas que contêm a data atual, fornecida pelo comando date +%Y-%m-%d.
EOF
}

ls_ltar_listar_arquivos_incluindo_ocultos_em_ordem_reversa_por_data_de_modificacao() {
    cat <<'EOF'
# ls -ltar # Listar arquivos, incluindo ocultos, em ordem reversa por data de modificação
Explicação:

    -l: Formato de listagem longa.
    -t: Ordena pela data de modificação, mais recente primeiro.
    -a: Inclui todos os arquivos, mesmo os ocultos (arquivos que começam com .).
    -r: Inverte a ordem da listagem, mostrando os arquivos mais antigos primeiro.
EOF
}

ls_lRsh_group_directories_first_listar_diretorios_com_seu_tamanho_total_e_subdiretorios() {
    cat <<'EOF'
# ls -lRsh --group-directories-first # Listar diretórios com seu tamanho total e subdiretórios
Explicação:

    -l: Formato de listagem longa.
    -R: Lista subdiretórios de forma recursiva.
    -s: Mostra o tamanho alocado de cada arquivo em blocos.
    -h: Mostra tamanhos de forma legível para humanos.
    --group-directories-first: Agrupa diretórios antes dos arquivos na listagem.
EOF
}

ls_lQX_listar_arquivos_com_nomes_citados_e_ordenados_por_extensao() {
    cat <<'EOF'
# ls -lQX # Listar arquivos com nomes citados e ordenados por extensão
Explicação:

    -l: Formato de listagem longa.
    -Q: Coloca os nomes dos arquivos entre aspas duplas.
    -X: Ordena os arquivos por extensão.
EOF
}

ls_ali_Listar_arquivos_ocultos_com_suas_inodes_e_visualizando_caracteres_nao_graficos() {
    cat <<'EOF'
# ls -ali # Listar arquivos ocultos com suas inodes e visualizando caracteres não gráficos
Explicação:

    -a: Inclui todos os arquivos, mesmo os ocultos.
    -l: Formato de listagem longa.
    -i: Mostra o número do inode de cada arquivo.
    -b: Mostra caracteres não gráficos como escapes estilo C.
EOF
}

ls_lZs_Listar_arquivos_com_seus_contextos_de_seguranca_SELinux_e_tamanho_em_blocos() {
    cat <<'EOF'
# ls -lZs # Listar arquivos com seus contextos de segurança (SELinux) e tamanho em blocos
Explicação:

    -l: Formato de listagem longa.
    -Z: Exibe o contexto de segurança de cada arquivo.
    -s: Mostra o tamanho alocado de cada arquivo em blocos.
EOF
}

ls_help_em_portugues() {
    cat <<'EOF' | less -i -R
# ls --help em português.
Uso: ls [OPÇÃO]... [ARQUIVO]...
Liste informações sobre os ARQUIVOS (o diretório atual por padrão).
Ordene as entradas alfabeticamente se nenhuma das opções -cftuvSUX ou --sort for especificada.

Argumentos obrigatórios para opções longas também são obrigatórios para opções curtas.
  -a, --all                  não ignore entradas que começam com .
  -A, --almost-all           não liste as entradas implícitas . e ..
      --author               com -l, imprima o autor de cada arquivo
  -b, --escape               imprima sequências de escape estilo C para caracteres não gráficos
      --block-size=TAMANHO   com -l, escale os tamanhos por TAMANHO ao imprimi-los;
                             ex., '--block-size=M'; veja o formato TAMANHO abaixo

  -B, --ignore-backups       não liste as entradas implícitas que terminam com ~
  -c                         com -lt: ordene por, e mostre, ctime (hora da última
                             alteração das informações de status do arquivo);
                             com -l: mostre ctime e ordene por nome;
                             caso contrário: ordene por ctime, mais recente primeiro

  -C                         liste as entradas por colunas
      --color[=QUANDO]       colora a saída QUANDO; mais informações abaixo
  -d, --directory            liste os diretórios em si, não seus conteúdos
  -D, --dired                gere uma saída projetada para o modo dired do Emacs
  -f                         não ordene, habilite -aU, desabilite -ls --color
  -F, --classify[=QUANDO]    adicione indicador (um de */=>@|) às entradas QUANDO
      --file-type            igualmente, exceto que não adiciona '*'
      --format=PALAVRA       across -x, com vírgulas -m, horizontal -x, long -l,
                             single-column -1, verbose -l, vertical -C

      --full-time            como -l --time-style=full-iso
  -g                         como -l, mas não liste o proprietário
      --group-directories-first
                             agrupe diretórios antes dos arquivos;
                             pode ser complementado com uma opção --sort, mas qualquer
                             uso de --sort=none (-U) desativa o agrupamento

  -G, --no-group             em uma listagem longa, não imprima os nomes dos grupos
  -h, --human-readable       com -l e -s, imprima tamanhos como 1K 234M 2G etc.
      --si                   igualmente, mas use potências de 1000, não 1024
  -H, --dereference-command-line
                             siga links simbólicos listados na linha de comando
      --dereference-command-line-symlink-to-dir
                             siga cada link simbólico da linha de comando
                             que aponta para um diretório

      --hide=PADRÃO          não liste entradas implícitas que correspondem ao PADRÃO do shell
                             (substituído por -a ou -A)

      --hyperlink[=QUANDO]   hiperlink os nomes dos arquivos QUANDO
      --indicator-style=PALAVRA
                             adicione indicador com estilo PALAVRA aos nomes das entradas:
                             none (padrão), slash (-p),
                             file-type (--file-type), classify (-F)

  -i, --inode                imprima o número do índice de cada arquivo
  -I, --ignore=PADRÃO        não liste entradas implícitas que correspondem ao PADRÃO do shell
  -k, --kibibytes            padrão para blocos de 1024 bytes para uso do sistema de arquivos;
                             usado apenas com -s e totais por diretório

  -l                         use um formato de listagem longa
  -L, --dereference          ao mostrar informações de arquivo para um link simbólico,
                             mostre informações para o arquivo que o link referencia,
                             em vez do próprio link

  -m                         preencha a largura com uma lista de entradas separadas por vírgulas
  -n, --numeric-uid-gid      como -l, mas liste IDs numéricos de usuário e grupo
  -N, --literal              imprima nomes de entrada sem aspas
  -o                         como -l, mas não liste informações do grupo
  -p, --indicator-style=slash
                             adicione o indicador / a diretórios
  -q, --hide-control-chars   imprima ? em vez de caracteres não gráficos
      --show-control-chars   mostre caracteres não gráficos como estão (o padrão,
                             a menos que o programa seja 'ls' e a saída seja um terminal)

  -Q, --quote-name           coloque nomes de entrada entre aspas duplas
      --quoting-style=PALAVRA use o estilo de citação PALAVRA para nomes de entrada:
                             literal, locale, shell, shell-always,
                             shell-escape, shell-escape-always, c, escape
                             (substitui a variável de ambiente QUOTING_STYLE)

  -r, --reverse              inverta a ordem ao ordenar
  -R, --recursive            liste subdiretórios recursivamente
  -s, --size                 imprima o tamanho alocado de cada arquivo, em blocos
  -S                         ordene por tamanho do arquivo, do maior para o menor
      --sort=PALAVRA         ordene por PALAVRA em vez de nome: none (-U), tamanho (-S),
                             tempo (-t), versão (-v), extensão (-X), largura

      --time=PALAVRA         selecione qual carimbo de data/hora usar para exibir ou ordenar;
                               hora de acesso (-u): atime, access, use;
                               hora de alteração de metadados (-c): ctime, status;
                               hora de modificação (padrão): mtime, modification;
                               hora de criação: birth, creation;
                             com -l, PALAVRA determina qual hora mostrar;
                             com --sort=time, ordene por PALAVRA (mais recente primeiro)

      --time-style=ESTILO_TEMPO
                             formato de tempo/data com -l; veja ESTILO_TEMPO abaixo
  -t                         ordene por tempo, mais recente primeiro; veja --time
  -T, --tabsize=COLS         considere tabulações a cada COLS em vez de 8
  -u                         com -lt: ordene por, e mostre, hora de acesso;
                             com -l: mostre a hora de acesso e ordene por nome;
                             caso contrário: ordene por hora de acesso, mais recente primeiro

  -U                         não ordene; liste as entradas na ordem do diretório
  -v                         ordenação natural de números (versão) dentro do texto
  -w, --width=COLS           defina a largura da saída para COLS.  0 significa sem limite
  -x                         liste as entradas por linhas em vez de por colunas
  -X                         ordene alfabeticamente pela extensão da entrada
  -Z, --context              imprima qualquer contexto de segurança de cada arquivo
      --zero                 termine cada linha de saída com NUL, não nova linha
  -1                         liste um arquivo por linha
      --help        exibe esta ajuda e sai
      --version     exibe a informação de versão e sai

O argumento TAMANHO é um número inteiro e unidade opcional (exemplo: 10K é 10*1024).
As unidades são K,M,G,T,P,E,Z,Y,R,Q (potências de 1024) ou KB,MB,... (potências de 1000).
Prefixos binários também podem ser usados: KiB=K, MiB=M, e assim por diante.

O argumento ESTILO_TEMPO pode ser full-iso, long-iso, iso, locale, ou +FORMATO.
FORMATO é interpretado como em date(1). Se FORMATO for FORMAT1<newline>FORMAT2,
então FORMAT1 aplica-se a arquivos não recentes e FORMAT2 a arquivos recentes.
ESTILO_TEMPO prefixado com 'posix-' entra em vigor apenas fora da localidade POSIX.
Além disso, a variável de ambiente TIME_STYLE define o estilo padrão a ser usado.

O argumento QUANDO por padrão é 'always' e também pode ser 'auto' ou 'never'.

Usar cores para distinguir tipos de arquivo está desabilitado tanto por padrão quanto
com --color=never. Com --color=auto, ls emite códigos de cor apenas quando
a saída padrão está conectada a um terminal. A variável de ambiente LS_COLORS
pode alterar as configurações. Use o comando dircolors(1) para defini-la.

Status de saída:
 0  se OK,
 1  se problemas menores (ex.: não pode acessar subdiretório),
 2  se problemas graves (ex.: não pode acessar argumento da linha de comando).

Ajuda online do GNU coreutils: <https://www.gnu.org/software/coreutils/>
Relate quaisquer bugs de tradução para <https://translationproject.org/team/>
Documentação completa <https://www.gnu.org/software/coreutils/ls>
ou disponível localmente via: info '(coreutils) ls invocation'
EOF
}

ls_help_em_portugues_traducao_2() {
cat <<'EOF' | less -i -R
# ls --help em português 2ª tradução.

Uso: ls [OPÇÃO]... [ARQUIVO]...
Listar informações sobre os ARQUIVOS (diretório atual por padrão).
Ordenar entradas alfabeticamente se nenhuma das opções -cftuvSUX nem --sort for especificada.

Argumentos obrigatórios para opções longas também são obrigatórios para opções curtas.
  -a, --all                  não ignorar entradas começando com .
  -A, --almost-all           não listar . e ..
      --author               com -l, imprimir o autor de cada arquivo
  -b, --escape               imprimir escapes C para caracteres não gráficos
      --block-size=TAMANHO   com -l, escalar tamanhos por TAMANHO ao imprimi-los;
                             ex., '--block-size=M'; veja formato TAMANHO abaixo

  -B, --ignore-backups       não listar entradas implícitas terminando com ~
  -c                         com -lt: ordenar por e mostrar, ctime (hora da última
                             alteração das informações do status do arquivo);
                             com -l: mostrar ctime e ordenar por nome;
                             caso contrário: ordenar por ctime, o mais recente primeiro

  -C                         listar entradas em colunas
      --color[=QUANDO]       colorir a saída QUANDO; mais informações abaixo
  -d, --directory            listar apenas diretórios, não o conteúdo deles
  -D, --dired                gerar saída projetada para o modo dired do Emacs
  -f                         listar todas as entradas na ordem do diretório
  -F, --classify[=QUANDO]    anexar indicador (um dos */=>@|) às entradas QUANDO
      --file-type            similar ao anterior, exceto não anexar '*'
      --format=PALAVRA       através de -x, vírgulas -m, horizontal -x, longo -l,
                             coluna única -1, verbose -l, vertical -C

      --full-time            como -l --time-style=full-iso
  -g                         como -l, mas não listar proprietário
      --group-directories-first
                             agrupar diretórios antes de arquivos;
                             pode ser complementado com uma opção --sort, mas qualquer
                             uso de --sort=none (-U) desativa o agrupamento

  -G, --no-group             em uma listagem longa, não imprimir nomes de grupo
  -h, --human-readable       com -l e -s, imprimir tamanhos como 1K 234M 2G, etc.
      --si                   similar, mas usar potências de 1000, não 1024
  -H, --dereference-command-line
                             seguir links simbólicos listados na linha de comando
      --dereference-command-line-symlink-to-dir
                             seguir cada link simbólico da linha de comando
                             que aponta para um diretório

      --hide=PADRÃO          não listar entradas implícitas correspondentes ao PATTERN do shell
                             (anulado por -a ou -A)

      --hyperlink[=QUANDO]   hyperlink para nomes de arquivos QUANDO
      --indicator-style=PALAVRA
                             anexar indicador com estilo PALAVRA aos nomes de entrada:
                             nenhum (padrão), barra (-p),
                             tipo de arquivo (--file-type), classificar (-F)

  -i, --inode                imprimir o número de índice de cada arquivo
  -I, --ignore=PADRÃO        não listar entradas implícitas correspondentes ao PATTERN do shell
  -k, --kibibytes            padrão para blocos de 1024 bytes para uso do sistema de arquivos;
                             usado apenas com -s e totais por diretório

  -l                         usar formato de listagem longa
  -L, --dereference          ao mostrar informações de arquivo para um link simbólico,
                             mostrar informações para o arquivo ao qual o link
                             se refere, e não para o link em si

  -m                         preencher largura com uma lista de entradas separadas por vírgulas
  -n, --numeric-uid-gid      como -l, mas listar IDs de usuário e grupo numéricos
  -N, --literal              imprimir nomes de entrada sem aspas
  -o                         como -l, mas não listar informações do grupo
  -p, --indicator-style=barra
                             anexar / indicador a diretórios
  -q, --hide-control-chars   imprimir ? em vez de caracteres não gráficos
      --show-control-chars   mostrar caracteres não gráficos como estão (padrão,
                             a menos que o programa seja 'ls' e a saída seja um terminal)

  -Q, --quote-name           incluir nomes de entrada entre aspas duplas
      --quoting-style=PALAVRA use estilo de citação PALAVRA para nomes de entrada:
                             literal, local, shell, shell-always,
                             shell-escape, shell-escape-always, c, escape
                             (substitui a variável de ambiente QUOTING_STYLE)

  -r, --reverse              ordem inversa durante a ordenação
  -R, --recursive            listar subdiretórios recursivamente
  -s, --size                 imprimir o tamanho alocado de cada arquivo, em blocos
  -S                         ordenar por tamanho do arquivo, o maior primeiro
      --sort=PALAVRA          ordenar por PALAVRA em vez de nome: nenhum (-U), tamanho (-S),
                             tempo (-t), versão (-v), extensão (-X), largura

      --time=PALAVRA          selecionar qual timestamp usar para exibir ou ordenar;
                               tempo de acesso (-u): atime, access, use;
                               tempo de mudança de metadados (-c): ctime, status;
                               tempo modificado (padrão): mtime, modification;
                               tempo de criação: birth, creation;
                             com -l, PALAVRA determina qual tempo mostrar;
                             com --sort=time, ordenar por PALAVRA (o mais recente primeiro)

      --time-style=ESTILO_TEMPO
                             formato de data/hora com -l; veja ESTILO_TEMPO abaixo
  -t                         ordenar por tempo, o mais recente primeiro; veja --time
  -T, --tabsize=COLUNAS      assumir paradas de tabulação em cada COLUNAS em vez de 8
  -u                         com -lt: ordenar por e mostrar, tempo de acesso;
                             com -l: mostrar tempo de acesso e ordenar por nome;
                             caso contrário: ordenar por tempo de acesso, o mais recente primeiro

  -U                         não ordenar; listar entradas na ordem do diretório
  -v                         ordenação natural de números de versão dentro do texto
  -w, --width=COLS           definir largura de saída para COLS.  0 significa sem limite
  -x                         listar entradas por linhas em vez de colunas
  -X                         ordenar alfabeticamente pela extensão da entrada
  -Z, --context              imprimir qualquer contexto de segurança de cada arquivo
      --zero                 terminar cada linha de saída com NUL, não com nova linha
  -1                         listar um arquivo por linha
      --help        exibir esta ajuda e sair
      --version     exibir informações de versão e sair

O argumento SIZE é um inteiro e uma unidade opcional (exemplo: 10K é 10*1024).
As unidades são K,M,G,T,P,E,Z,Y,R,Q (potências de 1024) ou KB,MB,... (potências de 1000).
Prefixos binários também podem ser usados: KiB=K, MiB=M, e assim por diante.

O argumento TIME_STYLE pode ser full-iso, long-iso, iso, local ou +FORMATO.
FORMATO é interpretado como em date(1). Se FORMATO for FORMATO1<newline>FORMATO2,
então FORMATO1 se aplica a arquivos não recentes e FORMATO2 a arquivos recentes.
TIME_STYLE prefixado com 'posix-' só tem efeito fora da localidade POSIX.
Também a variável de ambiente TIME_STYLE define o estilo padrão a ser usado.

O argumento WHEN padrão é 'always' e também pode ser 'auto' ou 'never'.

O uso de cor para distinguir tipos de arquivo está desativado tanto por padrão quanto
com --color=never. Com --color=auto, ls emite códigos de cor apenas quando
a saída padrão está conectada a um terminal. A variável de ambiente LS_COLORS
pode alterar as configurações. Use o comando dircolors(1) para configurá-lo.

Status de saída:
 0  se OK,
 1  se problemas menores (por exemplo, não pode acessar subdiretório),
 2  se problemas sérios (por exemplo, não pode acessar argumento da linha de comando).

Ajuda online do GNU coreutils: <https://www.gnu.org/software/coreutils/>
Informe quaisquer erros de tradução para <https://translationproject.org/team/>
Documentação completa <https://www.gnu.org/software/coreutils/ls>
ou disponível localmente via: info '(coreutils) ls invocation'
EOF
}