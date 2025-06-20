#!/bin/bash

# Ativa globstar (para ** funcionar no Bash)
shopt -s globstar

# Processa todos os PNGs recursivamente
for file in **/*.png; do
    if [[ -f "$file" ]]; then
        echo "Otimizando: $file"
        
        # Cria um arquivo temporário
        temp_file="${file%.*}.temp.png"
        
        # Aplica otimização com magick
        magick "$file" \
            -strip \
            -define png:compression-level=9 \
            -define png:exclude-chunk=all \
            -colors 1000 \
            "$temp_file"
        
        # Substitui o original pelo otimizado (se o magick funcionou)
        if [[ -f "$temp_file" ]]; then
			rm "$file"
            mv "$temp_file" "$file"
			optipng -o7 -nc "$file"
            echo "✅ $file otimizado com sucesso."
        else
            echo "❌ Falha ao otimizar $file."
        fi
    fi
done

echo "Concluído!"