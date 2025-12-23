split_files() {
    cat <<EOF
    # Portugês:
# split -b 1800M Archive.tar.zst Archive.tar.zst.

$ split -d -b 1800M Archive.tar.zst Archive.tar.zst.
$ split -a 3 -d -b 1800M Archive.tar.zst Archive.tar.zst.

-d Coloca digitos ao final ao invés de .aa .ab .ac
-a define o número de digitos, exemplo: -a 3. Exibirá .000 .001 .002, ao invés de .00 .01 .02

Porém a melhor forma é
$ split -b 1800M Archive.tar.zst Archive.tar.zst.

Além de ser a forma padrão, o p7zip reconhece o .aa como arquivo split com seus respectivos volumes, 
o que é ótimo se enviar arquivos split (.aa .ab .ac) para usuários de Windows.
##############################################################################
    # Inglês:
$ split -b 1800M Archive.tar.zst Archive.tar.zst.

$ split -d -b 1800M Archive.tar.zst Archive.tar.zst.
$ split -a 3 -d -b 1800M Archive.tar.zst Archive.tar.zst.

-d Appends numeric digits at the end instead of .aa .ab .ac
-a Sets the number of digits, for example: -a 3. It will display .000 .001 .002, instead of .00 .01 .02

However, the best approach is
$ split -b 1800M Archive.tar.zst Archive.tar.zst.

Not only is this the standard method, but p7zip recognizes the .aa format as a split file with its respective volumes,
which is great when sending split files (.aa .ab .ac) to Windows users.
EOF
}

concatenate_split_files_on_windows() {
    cat <<'EOF'
# concatenate split files on windows

$ copy /b file.aa + file.ab + file.ac file.tar
$ copy /b * folder.tar
EOF
}