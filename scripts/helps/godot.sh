godot_restore_editor_theme() {
	cat <<-'EOF'
	# This tutorial teaches how to apply a vibrant and readable color theme to Godot's text editor, enhancing your development experience.
	EOF
	clear
	if [[ "${LANG,,}" =~ pt_ ]]; then
		markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/godot-editor-theme-pt.md
	else
		markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/remove-extension.md
	fi
}

godot_animation_generate() {
	cat <<-'EOF'
	# AnimationGenerate is a utility script for Godot 4.2+ that allows creating animations programmatically from texture arrays, with support for saving animations as `.tres` files for later use.
	EOF
	clear
	if [[ "${LANG,,}" =~ pt_ ]]; then
		markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/gerar-animacoes.md
    else
		markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/animation-generate.md
    fi
}