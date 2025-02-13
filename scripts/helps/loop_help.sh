loop_help()
{
echo '
# Dicas sobre laço de repetição
'
echo "$(cat <<'EOF'
1. Loops for, while e until

Nesta seção você encontrará loops for, while e until.

O loop for é um pouco diferente de outras linguagens de programação. Basicamente, permite iterar sobre
uma série de 'palavras' dentro de uma string.

O while executa um pedaço de código se a expressão de controle é verdadeiro, e só para quando é
falso (ou uma quebra explícita é encontrada dentro do código executado.

O until até é quase igual ao loop while, exceto que o código é executado enquanto a expressão de
controle é avaliada como falsa. Se você suspeita que while e until são muito parecidos, você está certo.

1.1 Para amostra for:

        #!/bin/bash
        for i in $( ls ); do
            echo item: $i
        done

Na segunda linha, declaramos i como a variável que vai levar diferentes valores contidos em $( ls ).
A terceira linha pode ser mais longa, se necessário, ou pode haver mais linhas antes do feito.
'done' indica que o código que usou o valor de $i foi terminado e $i pode assumir um novo valor.
Este script tem pouco sentido, mas uma maneira mais útil de usar o loop for seria usá-lo para
corresponder apenas a determinados arquivos.

1.2 for no estilo C

Fiesh sugeriu adicionar essa forma de loop. É um loop for mais semelhante ao C/perl...

Crescente:

    Exemplo 1:

        #!/bin/bash
        for i in `seq 1 10`;
        do
            echo $i
        done

    Exemplo 2:

        #!/bin/bash
        for ((i=0;i<=19;i++));
        do
            echo $i
        done

Decrescente:

    Exemplo 1:

        #!/bin/bash
        for i in `seq 10 -1 1`;
        do
            echo $i
        done

    Exemplo 2:

        #!/bin/bash
        for ((i=19;i>=0;i--));
        do
            echo $i
        done

Multiplos de 2:

        #!/bin/bash
        for ((i=10;i>0;i-=2));
            do echo -n "$i,"
        done

1.3 Amostra while:

         #!/bin/bash
         COUNTER=0
         while [  $COUNTER -lt 10 ]; do
             echo The counter is $COUNTER
             let COUNTER=COUNTER+1
         done

Este script 'emula' o conhecido (C, Pascal, perl, etc)  na estrutura 'for'.

1.4 Amostra until:

         #!/bin/bash
         COUNTER=20
         until [  $COUNTER -lt 10 ]; do
             echo COUNTER $COUNTER
             let COUNTER-=1
         done

Veja for com lista array em:
    https://stackoverflow.com/questions/12316167/does-linux-shell-support-list-data-structure
    https://stackoverflow.com/questions/11233825/multi-dimensional-arrays-in-bash
    https://linuxhint.com/simulate-bash-array-of-arrays/

EOF
)" | less
}
