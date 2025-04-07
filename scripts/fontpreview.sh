#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

# Verifica se o fzf e o ImageMagick estão instalados
if ! command -v fzf magick &> /dev/null; then
    echo "❌ Erro: Este script requer 'fzf' e 'ImageMagick' instalados."
    exit 1
fi

# Gera uma lista de fontes disponíveis no sistema
font_list=$(magick -list font | grep "Font:" | awk '{print $2}' | sort -u)

# Usa fzf para seleção interativa com pré-visualização via Sixel
selected_font=$(echo "$font_list" | fzf \
    --prompt="🔍 Selecione uma fonte: " \
    --preview="magick -size 600x200 -background white -fill black -font '{}' -pointsize 36 label:'Preview: {}' -geometry 600x200 sixel:-" \
    --preview-window="right:60%:border-left" \
    --height=40%)

# Se uma fonte foi selecionada, exibe confirmação
if [[ -n "$selected_font" ]]; then
    echo "✅ Fonte selecionada: $selected_font"
else
    echo "🚫 Nenhuma fonte selecionada."
fi