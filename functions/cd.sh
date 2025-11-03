if [[ -n "$ZSH_VERSION" ]]; then
	smartcd() {
		local target
		
		# If no argument, go to HOME
		if [ $# -eq 0 ]; then
			builtin cd
			return $?
		fi
		
		# Join all arguments
		target="$*"
		
		# Remove external quotes
		target="${target%\"}"
		target="${target#\"}"
		target="${target%\'}"
		target="${target#\'}"
		
		# Try changing directory
		if builtin cd "$target" 2>/dev/null; then
			return 0
		else
			echo "Error: Directory '$target' does not exist" >&2
			return 1
		fi
	}

	alias cd='noglob smartcd'
fi