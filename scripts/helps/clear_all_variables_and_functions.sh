clear_all_variables_and_functions() {
    cat <<'EOF'
# clear all variables and functions
    unset -f function
    unset variable
    
    for VAR in $(grep -E '[a-zA-Z0-9"'\''\[\]]*=' "${file}" | grep -v '^#' | cut -d'=' -f1 | awk '{print $1}'); do
        eval unset "\${VAR}"
    done
EOF
}