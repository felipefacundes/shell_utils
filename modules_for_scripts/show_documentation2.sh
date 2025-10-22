# License: GPLv3
# Credits: Felipe Facundes

# Searches for content delimited by : <<'DOCUMENTATION' and DOCUMENTATION in the running script.
show_documentation() {
	sed -n '/^: <<DOCUMENTATION$/,/^DOCUMENTATION$/p' "${0}" | sed '1d;$d'
}