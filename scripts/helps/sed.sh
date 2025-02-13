sed_help()
{
(
cat <<'EOF'
# Algumas ajudas com o comando sed
Você pode usar # como caracter delimitador, ao invés de | ou /
E se os parâmetros estiverem em aspas simples e você quer incluir algo,
igualmente, com aspas simples, como:  bash -c 'comando'
Basta por às aspas simples entre aspas duplas e depois simples novamente.
Exemplo:

sed -i 's#pipoca#bash -c '"'"'echo pipoca'"'"'#g' test

# Converte upper to lower case
$ sed -e 's/\(.*\)/\L\1/' input.txt > output.txt

# Converte lower to upper case
$ sed -e 's/\(.*\)/\U\1/' input.txt > output.txt

# Remova linhas em branco
$ sed -i '/^$/d' input_file.txt

# Remova tudo o que estiver antes do sinal de = e index com um número
# Ideal para indexar arrays.
$ for i in {1..3435}; do sed -i "${i} s#.*=#[${i}]=#g" ~/input_file

# Remova tudo que estiver depois da #
$ sed -i 's/#.*//g'

# Veja arquivos melhor formatados, terminados com ponto '.' na próxima linha.
$ cat text_test.txt | sed -e 's|\.|\.\n|g' | less
EOF
) | less -i -R
}

sed_man()
{
echo "
# Manual english/portuguese
"
case "${1}" in
    "1"|"en")
        man sed
    ;;

    "2"|"pt")
        cat ~/.shell_utils/scripts/helps/sed/man_sed.txt | less -R -i
    ;;

    *)
        echo '1) English'
        echo -e "2) Portuguese\n"
        echo 'Enter now: 1 or 2'
        echo 'Or usage:'
        echo 'sed_man 1'
        read option
        if [ "${option}" = 1 ]; then
            man sed
        elif [ "${option}" = 2 ]; then
            cat ~/.shell_utils/scripts/helps/sed/man_sed.txt | less -R -i
        else
            echo 'Wrong option!'
        fi
    ;;

esac
}

sed_info()
{
echo "
# Info english/portuguese
"
case "${1}" in
    "1"|"en")
        info sed
    ;;

    "2"|"pt")
        cat ~/.shell_utils/scripts/helps/sed/info_sed.txt | less -R -i
    ;;

    *)
        echo '1) English'
        echo -e "2) Portuguese\n"
        echo 'Enter now: 1 or 2'
        echo 'Or usage:'
        echo 'sed_info 1'
        read option
        if [ "${option}" = 1 ]; then
            info sed
        elif [ "${option}" = 2 ]; then
            cat ~/.shell_utils/scripts/helps/sed/info_sed.txt | less -R -i
        else
            echo 'Wrong option!'
        fi
    ;;

esac
}
