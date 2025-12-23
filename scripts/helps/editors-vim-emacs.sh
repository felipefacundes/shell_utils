# Function to remove unwanted spaces in Vim
vim_remove_space() {
    tput setaf 11
    if [[ -z "$1" ]]; then
        if [[ "${LANG,,}" =~ pt_ ]]; then
            cat <<'EOF'
# Simple commands to remove unwanted whitespace in vim
# Comandos simples para remover espaços em branco indesejados no vim
-----------------------------------------------------------
Em uma busca, \s encontra espaços em branco (um espaço ou uma tabulação), e \+ encontra uma ou mais ocorrências.

O comando a seguir remove qualquer espaço em branco no final de cada linha. 
Se não houver espaços em branco, nenhuma alteração ocorre, e a flag e significa que nenhum erro será exibido.
:%s/\s\+$//e

O comando a seguir remove qualquer espaço em branco no início de cada linha.
:%s/^\s\+//e

A mesma coisa (:%le = :left = alinha à esquerda dentro do intervalo; % = todas as linhas):
:%le

Com o mapeamento a seguir, um usuário pode pressionar F5 para deletar todos os espaços em branco no final das linhas. 
A variável _s é usada para salvar e restaurar o registro do último padrão de busca 
(para que, na próxima vez que o usuário pressionar n, continue sua última busca), e 
:nohl é usado para desativar o destaque da busca (para que os espaços finais não fiquem destacados enquanto o usuário digita). 
A flag e é usada no comando de substituição, então nenhum erro é exibido se nenhum espaço em branco no final for encontrado. 
Diferente de antes, o texto de substituição deve ser especificado para usar a flag necessária.
:nnoremap <silent> <F5> :let _s=@/ <Bar> :%s/\s\+$//e <Bar> :let @/=_s <Bar> :nohl <Bar> :unlet _s <CR>

Se você quiser remover todas as linhas em branco, use:
:g/^\s*$/d

Se você quiser substituir todos os espaços em branco contínuos (\s\+) por uma vírgula (,) em cada linha (%), use:
:%s/\s\+/,/g

Outra maneira de fazer isso:
:%s/\s\{1,}/,/gc

Ao converter um arquivo de texto com cabeçalhos e campos de texto separados por espaços, use:
:%s/\s\{2,}/,/g

Remova espaços dentro de uma linha e reduza a tabulação excessiva:
:%s/\(\S\+ \)\+/\1/g
EOF
        else
            cat <<'EOF'
# Simple commands to remove unwanted whitespace in vim
-----------------------------------------------------------
In a search, \s finds whitespace (a space or a tab), and \+ finds one or more occurrences.

The following command deletes any trailing whitespace at the end of each line. 
If no whitespace is found, no changes occur, and the e flag means no error is displayed.
:%s/\s\+$//e

The following deletes any leading whitespace at the beginning of each line.
:%s/^\s\+//e

Same thing (:%le = :left = left-align within range; % = all lines):
:%le

With the following mapping, a user can press F5 to delete all trailing whitespace. 
The _s variable is used to save and restore the last search pattern register 
(so that the next time the user presses n, it continues their last search), and 
:nohl is used to turn off search highlighting (so trailing spaces won't be highlighted while the user types). 
The e flag is used in the substitute command, so no error is shown if trailing whitespace is not found. 
Unlike before, the replacement text must be specified to use the required flag.
:nnoremap <silent> <F5> :let _s=@/ <Bar> :%s/\s\+$//e <Bar> :let @/=_s <Bar> :nohl <Bar> :unlet _s <CR>

If you want to remove all blank lines, use:
:g/^\s*$/d

If you want to replace all continuous whitespace (\s\+) with a comma (,) on each line (%), use:
:%s/\s\+/,/g

Another way to do this:
:%s/\s\{1,}/,/gc

When converting a text file with headers and space-separated text fields, use:
:%s/\s\{2,}/,/g

Remove spaces within a line, and reduce excessive tabulation:
:%s/\(\S\+ \)\+/\1/g
EOF
        fi
    # Remove unwanted spaces at the end of each line
    else
        vim -c '%s/\s\+$//e' -c 'wq' "$1"
    fi
}


