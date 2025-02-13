# License: GPLv3
# Credits: Felipe Facundes

# Displayed help with content of the first commented block with # 
# preceded by an empty line, that is, the first commented block delimited by empty lines
show_help() {
    script_name="${0##*/}"  # Nome do script sem o caminho
    awk -v script_name="$script_name" '
    BEGIN { inside_block = 0; found_block = 0 }

    {
        # Se linha vazia e já estamos dentro de um bloco, finalize o bloco
        if ($0 == "" && inside_block) {
            found_block = 1
            inside_block = 0
            next
        }

        # Começa o bloco ao encontrar linha vazia antes seguida de linha com #
        if (!found_block && $0 == "") {
            getline
            if ($0 ~ /^# /) {
                inside_block = 1
                sub(/^# /, "")  # Remove o prefixo #
                gsub("\\$0", script_name)  # Substitui $0 pelo nome do script
                print
            }
        } else if (inside_block) {
            # Processa linhas dentro do bloco
            if ($0 ~ /^# /) {
                sub(/^# /, "")  # Remove o prefixo #
                gsub("\\$0", script_name)  # Substitui $0 pelo nome do script
                print
            } else if ($0 == "") {
                found_block = 1
                inside_block = 0
            }
        }

        # Finaliza o processamento após encontrar o bloco válido
        if (found_block) exit
    }
    ' "$0"
}