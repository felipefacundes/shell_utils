godot_restore_editor_theme() {
	clear
	cat <<-'EOF'
	# This tutorial teaches how to apply a vibrant and readable color theme to Godot's text editor, enhancing your development experience.

	EOF
    echo -e "1) English tutorial\n2) Portuguese tutorial\n"
    read -r option
    [[ ! "$option" =~ ^[1-2]$ ]] && echo "Only number 1 or 2" && exit 1
    case $option in
        1)
            markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/remove_extension.md
        ;;
        2)
            markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/godot_editor_theme_pt.md
        ;;
    esac
    clear
}

godot_animation_generate() {
	clear
	cat <<-'EOF'
	# AnimationGenerate is a utility script for Godot 4.2+ that allows creating animations programmatically from texture arrays, with support for saving animations as `.tres` files for later use.

	EOF
    echo -e "1) English tutorial\n2) Portuguese tutorial\n"
    read -r option
    [[ ! "$option" =~ ^[1-2]$ ]] && echo "Only number 1 or 2" && exit 1
    case $option in
        1)
            markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/animation_generate.md
        ;;
        2)
            markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/gerar_animacoes.md
        ;;
    esac
    clear
}