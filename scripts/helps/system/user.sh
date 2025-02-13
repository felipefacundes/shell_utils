default_user() {
    cat <<'EOF'
# What is my default user
echo $USER
whoami
id -un

# It works even being root
getent passwd admin
getent passwd 1000
getent passwd 1000 | cut -d':' -f1
getent passwd | grep 1000 | cut -d':' -f1
getent passwd | awk -F: '$3 >= 1000 {print $1}'
getent passwd | awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}'
getent passwd | awk -F: '$3 >= 1000 && $1 != "nobody" {print $1; exit}' 
grep 1000 /etc/passwd | cut -d':' -f1
EOF
}