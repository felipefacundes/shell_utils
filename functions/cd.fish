function cd
    # Se nenhum argumento, vai para HOME
    if test (count $argv) -eq 0
        builtin cd ~
        return $status
    end
    
    # Junta todos os argumentos mantendo os escapes
    set target ""
    for arg in $argv
        set target "$target$arg "
    end
    set target (string trim "$target")
    
    # Expande o ~ se estiver no início
    if string match -q '~*' "$target"
        set target (string replace '~' "$HOME" "$target")
    end
    
    # Tenta mudar de diretório
    if builtin cd "$target" 2>/dev/null
        return 0
    else
        echo "Erro: Diretório '$target' não existe" >&2
        return 1
    end
end