truth_table()
{
echo "
# View truth table
"
    if ! ls /tmp/truth_table.jpg > /dev/null 2>&1; then
        base64 -i -d <(curl -s https://raw.githubusercontent.com/felipefacundes/dotfiles/master/config/truth_table.txt) > /tmp/truth_table.jpg
    fi
    feh /tmp/truth_table.jpg
    echo -e "${shell_color_palette[bcyan]}See more at:${shell_color_palette[color_off]}\n"
    echo 'https://pt.wikipedia.org/wiki/Tabela-verdade'
    echo 'https://en.wikipedia.org/wiki/List_of_logic_symbols'
}
