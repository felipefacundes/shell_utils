awk_help()
{
echo -e "
# Alguma ajuda sobre awk

${shell_color_palette[yellow]}Você quer achar um termo com awk em um texto:${shell_color_palette[color_off]}

${shell_color_palette[bwhite_on_black]} `cat <<'EOF'
awk '/24 bits/' text_file
EOF`

${shell_color_palette[yellow]}Você quer filtrar dois termos em um arquivo:${shell_color_palette[color_off]}

${shell_color_palette[bwhite_on_black]} `cat <<'EOF'
awk '/24 bits|Complete name/' text_file
EOF`

${shell_color_palette[yellow]}Você quer filtrar a saída de um comando, e achar dois termos.
${shell_color_palette[yellow]}Exemplo, achar o nome do arquivo .wav de 24 bits:${shell_color_palette[color_off]}

${shell_color_palette[bwhite_on_black]} `cat <<'EOF'
mediainfo *.wav | awk '/24 bits|Complete name/{print $4}'
EOF`

${shell_color_palette[yellow]}Você quer converter maiúsculas para minúsculas:${shell_color_palette[color_off]}

${shell_color_palette[bwhite_on_black]} `cat <<'EOF'
echo 'UPPER' | awk '{print tolower($0)}'
EOF`
" | less
}
