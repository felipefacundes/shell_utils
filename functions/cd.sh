cd() {
    local target
    
    # Se nenhum argumento, vai para HOME
    if [ $# -eq 0 ]; then
        builtin cd
        return $?
    fi
    
    # Junta todos os argumentos
    target="$*"
    
    # Remove aspas externas
    target="${target%\"}"
    target="${target#\"}"
    target="${target%\'}"
    target="${target#\'}"
    
    # Tenta mudar de diretório
    if builtin cd "$target" 2>/dev/null; then
        return 0
    else
        echo "Erro: Diretório '$target' não existe" >&2
        return 1
    fi
}