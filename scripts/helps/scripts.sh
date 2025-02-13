auto_confirm_scripts() {
    cat <<'EOF' | less -R
# Automatizando autoconfirmação / autoconfirm em scripts y/yes
Para automatizar a confirmação "yes" em um script que pede confirmação, você pode usar o comando `yes`. 
No entanto, o modo como você tentou (`script.sh -option | yes yes`) está incorreto. Em vez disso, você 
deve redirecionar a saída de `yes` para o script.

Forma correta:

$ yes | script.sh -option

O comando `yes` repetirá a string "y" indefinidamente, que será usada como entrada para qualquer prompt de confirmação no script.

Se o seu script especificamente pede "yes" ou "no" (em vez de apenas "y" ou "n"), você pode fazer o seguinte:

$ yes yes | script.sh -option

Caso o seu script peça por múltiplas confirmações em pontos diferentes ou precise de valores diferentes de entrada, você pode usar o 
`printf` para fornecer uma sequência específica de entradas:

$ printf "yes\nno\n" | script.sh -option

Neste exemplo, o comando `printf` envia "yes" seguido por "no" (com uma nova linha após cada um) para o script.

Se você precisar de mais controle ou se o script tiver uma lógica mais complexa, você pode usar o `expect`, que é uma ferramenta mais 
poderosa para automação de interações com scripts que requerem entrada do usuário.

Aqui está um exemplo básico de um script `expect` para responder "yes" a um prompt:

```
#!/usr/bin/expect
spawn script.sh -option
expect "Are you sure you want to proceed? (yes/no)"
send "yes\r"
expect eof
```

Salve este código em um arquivo, torne-o executável e execute-o para automatizar as respostas.
EOF
}