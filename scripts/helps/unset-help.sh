unset_help()
{
echo "$(cat <<'EOF'
# unset command tips

unset: unset [-f] [-v] [-n] [name ...]

Unset values and attributes of shell variables and functions.

For each NAME, remove the corresponding variable or function.

Options:
  -f    treat each NAME as a shell function
  -v    treat each NAME as a shell variable
  -n    treat each NAME as a name reference and unset the variable itself
    rather than the variable it references

Without options, unset first tries to unset a variable, and if that fails,
tries to unset a function.

Some variables cannot be unset; also see `readonly'.

Exit Status:
Returns success unless an invalid option is given or a NAME is read-only.
EOF
)"

echo "$(cat <<'EOF'
unset: unset [-f] [-v] [-n] [nome ...]

Valores e atributos não definidos de variáveis e funções do shell.

Para cada NOME, remova a variável ou função correspondente.

Opções:
   -f trata cada NOME como uma função shell
   -v trata cada NOME como uma variável de shell
   -n trata cada NAME como uma referência de nome e desativa a própria variável
     em vez da variável que ele referencia

Sem opções, unset primeiro tenta desarmar uma variável e, se isso falhar,
tenta desarmar uma função.

Algumas variáveis não podem ser desdefinidas; veja também 'somente leitura'.

Estado de Saída:
Retorna sucesso, a menos que uma opção inválida seja fornecida ou um NAME seja somente leitura.
EOF
)"
}
