#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
Script de configuração de associações MIME dinâmico com interface whiptail                                                           

1. Interface interativa via Whiptail para configurar apps padrão por extensão/tipo MIME  
2. Detecta dinamicamente tipos MIME analisando arquivos .desktop do sistema  
3. Opção 1: Filtra por extensão (WAV, PDF, etc.) e sugere apps compatíveis  
4. Opção 2: Configura por arquivo específico (arrastar/inserir caminho)  
5. Opção 3: Lista completa de todos os tipos MIME e apps associados  
6. Suporta aplicativos do sistema (/usr) e do usuário (~/.local)  
7. Atualiza automaticamente o banco de dados MIME após alterações  
8. 100% dinâmico - sem listas estáticas de tipos ou aplicativos  

Uso: Execute e siga o menu interativo. 
Opção 1 para extensões específicas, 3 para navegação completa.
DOCUMENTATION

# Cores
RED='\033[1;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

dependencies=(
    "whiptail:libnewt"
    "update-mime-database:shared-mime-info"
    "file:file"
    "xdg-mime:xdg-utils"
)

missing_deps=()
for dep in "${dependencies[@]}"; do
    cmd=${dep%%:*}
    pkg=${dep#*:}
    if ! command -v "$cmd" &>/dev/null; then
        missing_deps+=("$pkg")
    fi
done

if [ ${#missing_deps[@]} -gt 0 ]; then
    echo -e "${RED}Erro: Dependências faltando:${NC} ${missing_deps[*]}"
    echo "Instale com:"
    echo "sudo pacman -S ${missing_deps[*]}  #(ArchLinux)" 
    echo "sudo apt install ${missing_deps[*]}  #(Debian/Mint/Ubuntu)"
    exit 1
fi

# Função para exibir mensagem de erro
error_msg() {
    whiptail --title "Erro" --msgbox "$1" 8 50
}

# Função para obter o tipo MIME de um arquivo
get_mime_type() {
    local file="$1"
    if [ -f "$file" ]; then
        file --brief --mime-type "$file"
    else
        echo ""
    fi
}

# Função para obter o tipo MIME de uma extensão
get_mime_type_from_extension() {
    local extension="$1"
    local temp_file=$(mktemp --suffix=".$extension")
    local mime_type=$(get_mime_type "$temp_file")
    rm -f "$temp_file"
    echo "$mime_type"
}

# Função para listar aplicativos disponíveis para um tipo MIME
list_apps_for_mime() {
    local mime_type="$1"
    local apps=()
    
    # Buscar em /usr/share/applications e ~/.local/share/applications
    local search_paths=(
        "/usr/share/applications"
        "$HOME/.local/share/applications"
    )
    
    for path in "${search_paths[@]}"; do
        if [ -d "$path" ]; then
            while IFS= read -r desktop_file; do
                if grep -q "MimeType=.*$mime_type" "$desktop_file"; then
                    app_name=$(grep -m1 "^Name=" "$desktop_file" | cut -d= -f2)
                    desktop_filename=$(basename "$desktop_file")
                    apps+=("$desktop_file" "$app_name")
                fi
            done < <(find "$path" -name "*.desktop" 2>/dev/null)
        fi
    done
    
    echo "${apps[@]}"
}

# Função para configurar associação padrão
set_default_app() {
    local mime_type="$1"
    local desktop_file="$2"
    
    # Extrair apenas o nome do arquivo .desktop (sem caminho)
    local desktop_filename=$(basename "$desktop_file")
    
    echo -e "${GREEN}Configurando $desktop_filename como padrão para $mime_type${NC}"
    xdg-mime default "$desktop_filename" "$mime_type"
    
    # Atualizar banco de dados MIME
    update-mime-database ~/.local/share/mime >/dev/null 2>&1
    
    whiptail --title "Sucesso" --msgbox "Associação configurada com sucesso!\n\n$desktop_filename agora é o aplicativo padrão para $mime_type" 10 60
}

# Função principal para configurar associação por extensão (filtro dinâmico)
configure_by_extension() {
    while true; do
        extension=$(whiptail --inputbox "Digite a extensão do arquivo (sem o ponto):" 8 50 \
        --title "Configurar Associação" 3>&1 1>&2 2>&3)
        
        if [ $? -ne 0 ]; then
            return 1 # Usuário cancelou
        fi
        
        # Remover qualquer ponto que o usuário possa ter digitado
        extension=${extension#.}
        extension=${extension,,} # Converter para minúsculas
        
        if [ -z "$extension" ]; then
            error_msg "Por favor, digite uma extensão válida."
            continue
        fi

        # Carregar todos os mime types e seus padrões de extensão
        declare -A mime_patterns
        while IFS= read -r desktop_file; do
            if grep -q "^MimeType=" "$desktop_file"; then
                mime_types=$(grep "^MimeType=" "$desktop_file" | cut -d= -f2 | tr ";" " ")
                for mime in $mime_types; do
                    # Extrair padrões de extensão do mime type (se existirem)
                    if [[ $mime == */* ]]; then
                        mime_base=${mime%%/*}
                        mime_subtype=${mime#*/}
                        # Verificar se o subtype contém a extensão
                        if [[ $mime_subtype == *$extension* ]]; then
                            mime_patterns["$mime"]=1
                        fi
                    fi
                done
            fi
        done < <(find /usr/share/applications ~/.local/share/applications -name "*.desktop" 2>/dev/null)

        # Se nenhum match foi encontrado, tentar com o tipo MIME genérico
        if [ ${#mime_patterns[@]} -eq 0 ]; then
            # Criar arquivo temporário para detecção
            temp_file=$(mktemp --suffix=".$extension")
            mime_type=$(file --brief --mime-type "$temp_file" 2>/dev/null)
            rm -f "$temp_file"
            
            if [ -z "$mime_type" ] || [[ "$mime_type" == */*unknown* ]] || [[ "$mime_type" == */*empty* ]]; then
                error_msg "Nenhum tipo MIME encontrado para a extensão .$extension\n\nUse a opção 3 para navegar manualmente."
                continue
            fi
            mime_patterns["$mime_type"]=1
        fi

        # Se apenas um tipo MIME foi encontrado
        if [ ${#mime_patterns[@]} -eq 1 ]; then
            mime_type="${!mime_patterns[@]}"
            if list_all_mime_types "$mime_type"; then
                return 0
            else
                error_msg "Nenhum aplicativo válido encontrado para $mime_type"
                continue
            fi
        fi

        # Se múltiplos tipos MIME foram encontrados
        menu_items=()
        for mime in "${!mime_patterns[@]}"; do
            menu_items+=("$mime" "Tipo MIME para .$extension")
        done

        choice=$(whiptail --title "Seleção de Tipo MIME" \
        --menu "Múltiplos tipos MIME encontrados para .$extension\nSelecione o apropriado:" \
        20 80 10 "${menu_items[@]}" 3>&1 1>&2 2>&3)

        if [ $? -ne 0 ] || [ -z "$choice" ]; then
            continue
        fi

        if list_all_mime_types "$choice"; then
            return 0
        else
            error_msg "Nenhum aplicativo válido encontrado para $choice"
        fi
    done
}

# Função principal para configurar associação por arquivo
configure_by_file() {
    while true; do
        file_path=$(whiptail --inputbox "Digite o caminho completo do arquivo ou arraste o arquivo para este terminal:" 8 70 \
        --title "Configurar Associação por Arquivo" 3>&1 1>&2 2>&3)
        
        if [ $? -ne 0 ]; then
            return 1 # Usuário cancelou
        fi
        
        # Remover aspas se o usuário arrastou o arquivo (comum em alguns terminais)
        file_path=${file_path//\'/}
        file_path=${file_path//\"/}
        
        if [ ! -f "$file_path" ]; then
            error_msg "Arquivo não encontrado: $file_path"
            continue
        fi
        
        mime_type=$(get_mime_type "$file_path")
        extension="${file_path##*.}"
        extension=${extension,,} # Converter para minúsculas
        
        if [ -z "$mime_type" ]; then
            error_msg "Não foi possível determinar o tipo MIME do arquivo."
            continue
        fi
        
        echo -e "${BLUE}Arquivo: $file_path | Extensão: .$extension | Tipo MIME: $mime_type${NC}"
        
        # Listar aplicativos disponíveis para este tipo MIME
        apps=($(list_apps_for_mime "$mime_type"))
        
        if [ ${#apps[@]} -eq 0 ]; then
            error_msg "Nenhum aplicativo encontrado que suporte $mime_type"
            continue
        fi
        
        # Mostrar menu para selecionar aplicativo
        choice=$(whiptail --title "Selecione o Aplicativo Padrão" \
        --menu "Escolha o aplicativo padrão para $mime_type (.$extension):" \
        20 60 10 "${apps[@]}" 3>&1 1>&2 2>&3)
        
        if [ $? -ne 0 ]; then
            continue # Usuário cancelou, voltar para entrada de arquivo
        fi
        
        set_default_app "$mime_type" "$choice"
        return 0
    done
}

# Função para listar todos os tipos MIME conhecidos e seus aplicativos (com suporte a filtro)
list_all_mime_types() {
    local preset_mime="$1"
    declare -A mime_apps
    
    # Buscar em /usr/share/applications e ~/.local/share/applications
    local search_paths=(
        "/usr/share/applications"
        "$HOME/.local/share/applications"
    )
    
    for path in "${search_paths[@]}"; do
        if [ -d "$path" ]; then
            while IFS= read -r desktop_file; do
                if grep -q "^MimeType=" "$desktop_file"; then
                    app_name=$(grep -m1 "^Name=" "$desktop_file" | cut -d= -f2)
                    desktop_filename=$(basename "$desktop_file")
                    mime_types=$(grep "^MimeType=" "$desktop_file" | cut -d= -f2 | tr ";" " " | tr "," " ")
                    
                    for mime in $mime_types; do
                        if [ -n "$mime" ]; then
                            mime_apps["$mime"]+="$desktop_filename|$app_name,"
                        fi
                    done
                fi
            done < <(find "$path" -name "*.desktop" 2>/dev/null)
        fi
    done
    
    # Se foi passado um tipo MIME como parâmetro (filtro da opção 1)
    if [ -n "$preset_mime" ]; then
        # Verifica se o tipo MIME existe
        if [ -z "${mime_apps[$preset_mime]}" ]; then
            return 1 # Tipo MIME não encontrado
        fi
        choice="$preset_mime"
    else
        # Ordenar os tipos MIME para exibição
        sorted_mimes=$(printf "%s\n" "${!mime_apps[@]}" | sort)
        
        # Criar array para o whiptail
        local menu_items=()
        for mime in $sorted_mimes; do
            menu_items+=("$mime" "Aplicativos: $(echo "${mime_apps[$mime]}" | tr "," " " | sed 's/|/ (/g; s/,$//; s/,/), /g')")
        done
        
        # Mostrar menu de seleção
        choice=$(whiptail --title "Tipos MIME e Aplicativos" \
        --menu "Selecione um tipo MIME para configurar:" \
        25 90 15 "${menu_items[@]}" 3>&1 1>&2 2>&3)
        
        if [ $? -ne 0 ] || [ -z "$choice" ]; then
            return 1 # Usuário cancelou
        fi
    fi
    
    # Extrair aplicativos para este MIME
    local apps_list=()
    IFS=',' read -ra apps <<< "${mime_apps[$choice]}"
    for app in "${apps[@]}"; do
        if [ -n "$app" ]; then
            IFS='|' read -ra parts <<< "$app"
            desktop_file=$(find "${search_paths[@]}" -name "${parts[0]}" 2>/dev/null | head -n1)
            if [ -n "$desktop_file" ]; then
                apps_list+=("$desktop_file" "${parts[1]}")
            fi
        fi
    done
    
    if [ ${#apps_list[@]} -eq 0 ]; then
        error_msg "Nenhum aplicativo válido encontrado para $choice"
        return 1
    fi
    
    # Mostrar menu para selecionar aplicativo
    app_choice=$(whiptail --title "Selecione o Aplicativo Padrão" \
    --menu "Escolha o aplicativo padrão para $choice:" \
    20 60 10 "${apps_list[@]}" 3>&1 1>&2 2>&3)
    
    if [ $? -ne 0 ]; then
        return 1 # Usuário cancelou
    fi
    
    set_default_app "$choice" "$app_choice"
}

# Menu principal
while true; do
    choice=$(whiptail --title "Configurador de Associações de Arquivos" \
    --menu "Escolha uma opção:" 15 60 5 \
    "1" "Configurar por extensão de arquivo" \
    "2" "Configurar por arquivo específico" \
    "3" "Listar todos os tipos MIME e aplicativos" \
    "4" "Sair" 3>&1 1>&2 2>&3)
    
    case $choice in
        1) configure_by_extension ;;
        2) configure_by_file ;;
        3) list_all_mime_types ;;
        4) break ;;
        *) break ;;
    esac
done

echo -e "${GREEN}Configuração concluída.${NC}"
exit 0