remove_extension()
{
    echo "$(cat <<'EOF'
# Remove extension tips

$ filename=file.txt
$ name="$(echo $filename | cut -f1 -d'.')"
$ echo $name

---------

$ echo 'info.tar.tbz2' | awk -F. '{print $NF}'
tbz2
$ echo 'info.tar.tbz2' | sed 's/.*\.//'
tbz2

---------
You can also use parameter expansion:

$ filename=file.txt
$ echo "${filename%.*}"
file

---------
$ basename base.wiki .wiki
base

---------
filename='file.txt'
$ echo $filename |sed 's/\(.*\)..../\1/'

---------
Usando apenas o built-in do POSIX:

#!/usr/bin/env sh
path=this.path/with.dots/in.path.name/filename.tar.gz

# Obtenha o basedir sem comando externo
# removendo a correspondência final mais curta de / seguida por qualquer coisa
dirname=${path%/*}

# Obtenha o nome base sem comando externo
# removendo a correspondência inicial mais longa de qualquer coisa seguida por /
basename=${path##*/}

# Tira apenas a extensão final superior
# removendo a correspondência final mais curta de ponto seguido por qualquer coisa
oneextless=${basename%.*}; echo "$oneextless"

# Tira todas as extensões
# eliminando a correspondência mais longa de ponto seguido por qualquer coisa
noext=${basename%%.*}; echo "$noext"

# Demonstração de impressão
printf %s\\n "$path" "$dirname" "$basename" "$oneextless" "$noext"

Saída na tela:

this.path/with.dots/in.path.name/filename.tar.gz
this.path/with.dots/in.path.name
filename.tar.gz
filename.tar
filename



See more:
https://stackoverflow.com/questions/12152626/how-can-i-remove-the-extension-of-a-filename-in-a-shell-script
https://www.delftstack.com/howto/linux/remove-file-extension-using-shell/
EOF
)" | less
}