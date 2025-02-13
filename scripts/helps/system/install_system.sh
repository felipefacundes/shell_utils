install_system()
{
cat <<'EOF'
# Para saber a última instalação do sistema:

ls -lct / | tail -1 | awk '{print $6, $7, $8}'

Ou:
ls -lact --full-time / | tail -1 | awk '{print $6, $7}'

Ou:
stat -c %w /

EOF
}

system_version()
{
cat <<'EOF'
# Para saber a versão da Distribuição Linux instalado:

cat /etc/os-release
lsb_release -a
EOF
}
