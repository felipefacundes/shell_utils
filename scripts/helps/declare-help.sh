declare_help()
{
echo "$(cat <<'EOF'

# A help for command declare

NAME
    declare - Set variable values and attributes.

SYNOPSIS
    declare [-aAfFgilnrtux] [-p] [name[=value] ...]

DESCRIPTION
    Set variable values and attributes.

    Declare variables and give them attributes.  If no NAMEs are given,
    display the attributes and values of all variables.

    Options:
      -f	restrict action or display to function names and definitions
      -F	restrict display to function names only (plus line number and
    		source file when debugging)
      -g	create global variables when used in a shell function; otherwise
    		ignored
      -p	display the attributes and value of each NAME

    Options which set attributes:
      -a	to make NAMEs indexed arrays (if supported)
      -A	to make NAMEs associative arrays (if supported)
      -i	to make NAMEs have the `integer' attribute
      -l	to convert the value of each NAME to lower case on assignment
      -n	make NAME a reference to the variable named by its value
      -r	to make NAMEs readonly
      -t	to make NAMEs have the `trace' attribute
      -u	to convert the value of each NAME to upper case on assignment
      -x	to make NAMEs export

    Using `+' instead of `-' turns off the given attribute.

    Variables with the integer attribute have arithmetic evaluation (see
    the `let' command) performed when the variable is assigned a value.

    When used in a function, `declare' makes NAMEs local, as with the `local'
    command.  The `-g' option suppresses this behavior.

    Exit Status:
    Returns success unless an invalid option is supplied or a variable
    assignment error occurs.

##########################################################
There are two types of arrays that we can work with, in shell scripts.

    * Indexed Arrays - Store elements with an index starting from 0
    * Associative Arrays - Store elements in key-value pairs

The default array that’s created is an indexed array. If you specify the index names,
it becomes an associative array and the elements can be accessed using the index names instead of numbers.

Declaring Associative Arrays:

$ declare -A assoc_array
$ assoc_array[key_name]=value

$ declare -A mymap
$ mymap[washington]=george
$ mymap[lincoln]=abe

$ echo ${!mymap[*]}
washington lincoln

$ echo ${mymap[washington]}
george

$ echo ${mymap[lincoln]}
abe

OR Indexed Arrays:
$ declare -a indexed_array
$ indexed_array[0]=value1
$ indexed_array[1]=value2

Access All Elements of an Array:

$ echo ${assoc_array[@]}

Delete Individual Array Elements:

$ unset index_array[1]

SEE ALSO
    bash(1)

IMPLEMENTATION
    GNU bash, version 5.0.17(1)-release (x86_64-redhat-linux-gnu)
    Copyright (C) 2019 Free Software Foundation, Inc.
    License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>

EOF
)" | less

echo "$(cat <<'EOF'
NOME
     declare - Defina valores e atributos de variáveis.

 SINOPSE
     declare [-aAfFgilnrtux] [-p] [nome[=valor] ...]

 DESCRIÇÃO
     Defina valores e atributos de variáveis.

     Declare variáveis ​​e dê a elas atributos.  Se nenhum nome for fornecido,
     exibir os atributos e valores de todas as variáveis.

     Opções:
       -f restringe a ação ou exibição a nomes e definições de funções
       -F restringe a exibição apenas aos nomes das funções (mais o número da linha e
    		 arquivo de origem durante a depuração)
       -g cria variáveis ​​globais quando usado em uma função shell;  de outra forma
    		 ignorado
       -p exibe os atributos e o valor de cada NOME

     Opções que definem atributos:
       -a para fazer matrizes indexadas de NAMEs (se suportado)
       -A para fazer arrays associativos de NAMEs (se suportado)
       -i para fazer com que os NAMEs tenham o atributo `integer'
       -l para converter o valor de cada NOME para letras minúsculas na atribuição
       -n torna NAME uma referência à variável nomeada por seu valor
       -r para tornar NAMEs somente leitura
       -t para fazer com que os NAMEs tenham o atributo `trace'
       -u para converter o valor de cada NOME para maiúsculas na atribuição
       -x para fazer a exportação de NAMEs

     Usar `+' em vez de `-' desativa o atributo fornecido.

     Variáveis ​​com o atributo integer possuem avaliação aritmética (veja
     o comando `let') executado quando a variável recebe um valor.

     Quando usado em uma função, `declare' torna NAMEs locais, como acontece com o `local'
     comando.  A opção `-g' suprime esse comportamento.

     Estado de Saída:
     Retorna sucesso, a menos que uma opção inválida seja fornecida ou uma variável
     ocorre um erro de atribuição.

################################################### ########
Existem dois tipos de arrays com os quais podemos trabalhar, em shell scripts.

     * Arrays indexados - Armazena elementos com um índice começando em 0
     * Arrays associativos - Armazena elementos em pares chave-valor

A matriz padrão criada é uma matriz indexada. Se você especificar os nomes dos índices,
eles se tornarão uma matriz associativa e os elementos poderão ser acessados usando os nomes dos índices em vez de números.

Declarando Arrays Associativos:

$ declare -A assoc_array
$ assoc_array[key_name]=valor

$ declare -A mymap
$ mymap[washington]=george
$ mymap[lincoln]=abe

$ echo ${!mymap[*]}
Washington Lincoln

$ echo ${mymap[washington]}
jorge

$ echo ${mymap[lincoln]}
abe

OU matrizes indexadas:
$ declare -a indexed_array
$ indexed_array[0]=valor1
$ indexed_array[1]=valor2

Acesse todos os elementos de um array:

$ echo ${assoc_array[@]}

Excluir elementos individuais da matriz:

$ unset index_array[1]


 VEJA TAMBÉM
     bash(1)

 IMPLEMENTAÇÃO
     GNU bash, versão 5.0.17(1)-release (x86_64-redhat-linux-gnu)
     Copyright (C) 2019 Free Software Foundation, Inc.
     Licença GPLv3+: GNU GPL versão 3 ou posterior <http://gnu.org/licenses/gpl.html>
EOF
)" | less
}
alias declare_man='declare_help'
