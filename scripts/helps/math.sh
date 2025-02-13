math_tips()
{
echo -e "${shell_color_palette[bcyan]}Ways to calculate using AWK and PERL:${shell_color_palette[color_off]}\n"
cat <<'EOF'
# Math / calc tips
echo $(perl -e 'print 4/9')
perl -e 'printf("%.2f\n", 4/9)'
awk 'BEGIN {print 4/9}'
awk 'BEGIN {printf "%.2f\n", 4/9}'
EOF
}

divisor()
{
echo -e "
# Divisor e dividendo - numerador, denominador e dividendo

${shell_color_palette[bold]}  Divisor e dividendo

Antes de falar sobre divisão de números decimais é necessário saber o que é divisor e dividendo:

    Dividendo é o número que será dividido. 
    Divisor é o número que irá dividir o dividendo.

${shell_color_palette[bold]}  Numerador e denominador

Já quando a divisão é escrita na forma de fração, é comum aparecerem os termos numerador e denominador:

    numerador é o número que está na parte superior da fração
    O numerador será dividido pelo denominador, que está na parte de baixo da fração.

${shell_color_palette[bold]}Exemplos:

1) Na divisão de 5 por 3 (5÷3), 5 é o dividendo e 3 é o divisor.

2) Na fração −9÷2, -9 é o numerador e 2 é o denominador.

" | less
}
