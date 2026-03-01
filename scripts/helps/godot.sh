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

godot_comment_markers() {
	cat <<-'EOF'
	# Godot Comment Markers - This guide presents the special comment markers that Godot 4 highlights in the script editor. These markers help organize code, track tasks, and highlight important notices directly in comments.
	EOF
	clear
	if [[ "${LANG,,}" =~ pt_ ]]; then
		cat <<-'EOF'
		# Marcadores de Comentário do Godot - Este guia apresenta os marcadores especiais de comentário que o Godot 4 destaca no editor de scripts. 
		# Estes marcadores ajudam a organizar o código, acompanhar tarefas e destacar avisos importantes diretamente nos comentários.

		# O Godot destaca automaticamente palavras-chave específicas quando usadas dentro de comentários (#)

		Categorias de Prioridade:

		🔴 CRÍTICO (Vermelho) - Alertas de segurança ou erros graves:

		Exemplos:
		# ALERT: Verificar permissões de arquivo
		# ATTENTION: Esta função modifica dados salvos
		# CAUTION: Limite de iterações pode causar loop infinito
		# CRITICAL: Falha no sistema de salvamento
		# DANGER: Exclusão permanente de dados
		# SECURITY: Validar entrada do usuário antes de usar

		🟡 AVISO (Amarelo/Laranja) - Tarefas pendentes ou código que precisa revisão:

		Exemplos:
		# BUG: Objeto não é liberado da memória
		# DEPRECATED: Usar novo método process() em vez disso
		# FIXME: Corrigir cálculo de física em alta velocidade
		# HACK: Solução temporária até próxima atualização
		# TASK: Implementar sistema de partículas
		# TBD: Decidir entre Array ou Dictionary
		# TODO: Adicionar validação de entrada
		# WARNING: Performance pode degradar com muitos nós

		🔵 INFORMATIVO (Azul/Verde) - Notas gerais e informações úteis:

		Exemplos:
		# INFO: Carregando recursos da pasta /assets
		# NOTE: Esta função é chamada a cada frame
		# NOTICE: Requer Godot 4.0 ou superior
		# TEST: Verificar colisão com objetos em movimento
		# TESTING: Comportamento em diferentes resoluções de tela

		Dicas Importantes:

		• Case-sensitive: As palavras devem estar em MAIÚSCULAS
		  ✓ # TODO: Implementar função
		  ✗ # todo: Implementar função (não destacado)

		• Apenas comentários simples (#), não funciona em strings multilinhas (""")

		• Personalização: Editor Settings > Text Editor > Theme > Highlighting > Comment Markers

		EOF

		read -s -n 1 -rp "Pressione qualquer tecla para exibir o help completo" >/dev/tty
		markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/godot-markers-pt.md
	else
		cat <<-'EOF'
		# Godot Comment Markers - This guide presents the special comment markers that Godot 4 highlights in the script editor. These markers help organize code, track tasks, and highlight important notices directly in comments.

		# Godot automatically highlights specific keywords when used inside comments (#)

		Priority Categories:

		🔴 CRITICAL (Red) - Security alerts or critical errors needing immediate attention:

		Examples:
		# ALERT: Check file permissions
		# ATTENTION: This function modifies saved data
		# CAUTION: Iteration limit may cause infinite loop
		# CRITICAL: Save system failure
		# DANGER: Permanent data deletion
		# SECURITY: Validate user input before using

		🟡 WARNING (Yellow/Orange) - Pending tasks or code needing review:

		Examples:
		# BUG: Object not freed from memory
		# DEPRECATED: Use new process() method instead
		# FIXME: Fix physics calculation at high speed
		# HACK: Temporary solution until next update
		# TASK: Implement particle system
		# TBD: Decide between Array or Dictionary
		# TODO: Add input validation
		# WARNING: Performance may degrade with many nodes

		🔵 INFORMATIONAL (Blue/Green) - General notes and useful information:

		Examples:
		# INFO: Loading resources from /assets folder
		# NOTE: This function is called every frame
		# NOTICE: Requires Godot 4.0 or higher
		# TEST: Check collision with moving objects
		# TESTING: Behavior at different screen resolutions

		Important Tips:

		• Case-sensitive: Keywords must be in UPPERCASE
		  ✓ # TODO: Implement function
		  ✗ # todo: Implement function (not highlighted)

		• Only single-line comments (#), doesn't work in multiline strings (""")

		• Customization: Editor Settings > Text Editor > Theme > Highlighting > Comment Markers

		EOF
		read -s -n 1 -rp "Press any key to display the full help" >/dev/tty
		markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/godot-markers.md
    fi
}