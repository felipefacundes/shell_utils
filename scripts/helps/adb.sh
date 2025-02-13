adb_help() {
    # https://android.stackexchange.com/questions/215313/how-to-reinstall-an-uninstalled-system-app-through-adb
    # https://android.stackexchange.com/questions/110927/how-to-mount-system-rewritable-or-read-only-rw-ro
    # https://dotjunior.blogspot.com/2019/08/remova-apps-com-o-adb.html
    cat <<'EOF' | less
# Comandos adb shell

# Execute o comando abaixo para garantir que seu dispositivo esteja conectado
$ adb devices

# Você pode listar todos os pacotes instalados no dispositivo com o comando:
$ adb shell pm list packages
$ adb shell pm list packages --user 0

# Ou, para procurar por um pacote específico, use grep ou egrep:
$ adb shell pm list packages | grep <parte-do-nome-do-pacote>
$ adb shell pm list packages -f | grep <parte-do-nome-do-pacote> # Essa é a melhor forma de ser achar um pacote, com -f

# Este código obterá o caminho dos pacotes de terceiros com o nome para que você possa identificar facilmente seu APK
$ adb shell pm list packages -f -3 | grep <parte-do-nome-do-pacote>

# Após identificar o nome completo do pacote que deseja remover, use o comando:
$ adb uninstall <package_name>
$ adb uninstall com.example.app

# Se o pacote for um aplicativo de sistema ou tiver sido instalado como administrador, pode ser necessário usar permissões root:
$ adb shell su
$ pm uninstall --user 0 <package_name>

# Outra forma de ter acesso root:
$ adb root

# As vezes não precisa ser root para desintalar apps do sistema:
# Tecnicamente, o comando: 
$ adb shell pm uninstall --user 0 <package_name> # Ou..
$ adb shell pm uninstall -k --user 0 <package_name> 
# não desinstala um aplicativo do dispositivo. Em vez disso, apenas o remove de um usuário.

# Existem algumas maneiras de devolver o aplicativo removido ao usuário: 
# uma maneira é por meio de um shell ADB com o comando:
$ adb shell cmd package install-existing <package_name>

# Para aquelas circunstâncias em que install-existing a solução não está disponível. 
# Há outra maneira mais fácil de procurar a localização do APK existente. No tipo de shell ADB: 

# Encontre o caminho onde o APK do aplicativo está armazenado no dispositivo:
$ adb shell pm path <package_name>

# Para Backup:
$ adb pull /data/app/<package_name_dir>/<package_name>.apk
# Então você pode selecionar um aplicativo, por exemplo o twitter:
$ adb backup -apk com.twitter.android
# Outra forma de Backup:
$ adb shell 'cat `pm path com.example.name | cut -d':' -f2`' > app.apk

# Ou encontre o caminho de todos:
$ adb shell pm list packages -f -u | grep <package name>

-f: Veja o arquivo associado.
-d: Filtre para mostrar apenas pacotes desabilitados.
-e: Filtre para mostrar apenas os pacotes habilitados.
-s: Filtre para mostrar apenas os pacotes do sistema.
-3: Filtre para mostrar apenas pacotes de terceiros.
-i: Consulte o instalador dos pacotes.
-u: Inclui também pacotes desinstalados.
--user <USER_ID>: O espaço do usuário a ser consultado.

# Caso o pacote tenha sido desinstalado para achar o caminho:
$ adb shell pm dump <package_name> | grep Path

# Para reinstalar pelo caminho:
$ adb shell pm install -r --user 0 /system/priv-app/<package_name>/<package_name>.apk

# Remonte a partição /system como gravável:
$ adb remount

# Instale o Aplicativo no Sistema
$ adb push example.apk /system/app/YourAppName/

# Defina as premissões corretas:
$ adb shell chmod 644 /system/app/YourAppName/example.apk

# Ou, se estiver em priv-app:
$ adb shell chmod 644 /system/priv-app/YourAppName/example.apk

# Para desativar um App como administrador de dispositivo, exemplo, o Greenify, você pode usar o seguinte comando:
$ adb shell dpm remove-active-admin com.oasisfeng.greenify/.DeviceAdminReceiver

# Para verificar os admins ativos:
$ adb shell dpm list active-admins

# Para listar apps desativados:
$ adb shell pm list packages -d

# Alguns pacotes que podem ser desintalados:

Google...

    Chrome ( com.android.chrome )
    YouTube ( com.google.android.youtube )
    Hangouts ( com.google.android.talk )
    Drive ( com.google.android.apps.docs )
    Plus ( com.google.android.apps.plus )
    Maps ( com.google.android.apps.maps )
    Play Banca ( com.google.android.apps.magazines )
    Play Filmes ( com.google.android.videos )
    Play Games ( com.google.android.play.games )
    Play Livros ( com.google.android.apps.books )
    Play Música ( com.google.android.music )

EOF
}

greenify_aggressive_doze_mode() {
    cat <<'EOF'
# To activate aggressive doze mode in greenify
# https://xdaforums.com/t/guide-aggressive-doze-new-experimental-feature-for-marshmallow-no-root-required.3223731/page-48

$ adb -d shell pm grant com.oasisfeng.greenify android.permission.DUMP
$ adb -d shell pm grant com.oasisfeng.greenify android.permission.WRITE_SECURE_SETTINGS
$ adb -d shell pm grant com.oasisfeng.greenify android.permission.READ_LOGS

# Revoke permissions:

$ adb shell pm revoke com.oasisfeng.greenify android.permission.DUMP
$ adb shell pm revoke com.oasisfeng.greenify android.permission.WRITE_SECURE_SETTINGS
$ adb shell pm revoke com.oasisfeng.greenify android.permission.READ_LOGS
EOF
}