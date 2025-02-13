find_term_in_files() {
echo '
# find term in files

find /path/directory -type f -name "*.extension" -exec grep -i "term" {} \;'
}