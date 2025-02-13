waydroid_certificate_playstore() {
    cat <<'EOF'
# Waydroid tips - waydroid certificate playstore

1. Run command:

$ sudo waydroid shell

2. In waydroid shell, run command:

$ ANDROID_RUNTIME_ROOT=/apex/com.android.runtime ANDROID_DATA=/data ANDROID_TZDATA_ROOT=/apex/com.android.tzdata ANDROID_I18N_ROOT=/apex/com.android.i18n sqlite3 /data/data/com.google.android.gsf/databases/gservices.db "select * from main where name = \"android_id\";"

3. then access the link and use the number generated
https://www.google.com/android/uncertified/

EOF
}

waydroid_mount_share_folder() {
    cat <<'EOF'
# waydroid mount share folder

$ sudo mount --bind -o rw $HOME/.local/share/waydroid/data/media/0/Share $HOME/Android_Share
$ sudo chmod -R 777 $HOME/Android_Share
EOF
}

waydroid_fix_solutions() {
    cat <<'EOF'
# Solution for Waydroid's wi-fi network off

Found a solution after 30 minutes searching the web like crazy. I'm on Linux Cinnamon 21.1 5.6.8 and what I did was:
1. Stop Waydroid's session and container:

$ sudo waydroid session stop
$ sudo waydroid container stop

2. Allow Waydroid's DNS traffic:

$ sudo ufw allow 67
$ sudo ufw allow 53

3. Allow packet forwarding:

$ sudo ufw default allow FORWARD 
EOF
}