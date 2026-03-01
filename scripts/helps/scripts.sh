auto_confirm_scripts() {
	cat <<-'EOF'
	# Auto-confirm Script Prompts - This guide presents techniques for automating yes/no confirmations in shell scripts. Learn how to use yes, printf, and expect to handle interactive prompts automatically.
	EOF
	clear
	if [[ "${LANG,,}" =~ pt_ ]]; then
		cat <<-'EOF'
		# Automatizando Confirmações em Scripts - Este guia apresenta técnicas para automatizar confirmações sim/não em scripts shell. 
		# Aprenda a usar yes, printf e expect para lidar com prompts interativos automaticamente.

		# Usando o comando 'yes' para automação básica

		O comando `yes` repete uma string indefinidamente, ideal para automatizar prompts de confirmação:

		Exemplos:

		# Envia "y" automaticamente para qualquer prompt
		$ yes | script.sh -option

		# Se o script espera especificamente "yes" ou "no"
		$ yes yes | script.sh -option
		$ yes no  | script.sh -option

		# Para múltiplas confirmações com respostas diferentes
		$ printf "yes\nno\nyes\n" | script.sh -option

		# Exemplo prático com apt-get (instalação automática)
		$ yes | sudo apt-get install pacote

		# Exemplo com múltiplas perguntas (respostas: sim, não, sim)
		$ printf "y\nn\ny\n" | ./script_interativo.sh

		# Usando 'expect' para automação avançada

		Para scripts com lógica mais complexa ou prompts específicos, use expect:

		```bash
		#!/usr/bin/expect
		# Auto-resposta para script com confirmação personalizada
		spawn ./script_instalacao.sh
		expect "Deseja continuar? (sim/nao)"
		send "sim\r"
		expect "Iniciar instalação? (s/N)"
		send "s\r"
		expect "Digite o caminho de instalação:"
		send "/opt/app\r"
		expect eof
		```

		Dicas Importantes:

		• O comando `yes` sem argumentos envia "y" (padrão)
		• Use `yes yes` para enviar exatamente a string "yes"
		• Para múltiplas respostas diferentes, `printf` é mais flexível
		• `expect` é ideal para scripts com prompts personalizados
		• Sempre teste em ambiente seguro antes de usar em produção

		Exemplos de erros comuns:

		❌ Errado: script.sh -option | yes
		❌ Errado: yes | script.sh -option > /dev/null (perde interação)
		✅ Correto: yes | script.sh -option

		EOF

		read -s -n 1 -rp "Pressione qualquer tecla para exibir o help completo" >/dev/tty
		markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/auto-confirm-pt.md
	else
		cat <<-'EOF'
		# Auto-confirm Script Prompts - This guide presents techniques for automating yes/no confirmations in shell scripts. Learn how to use yes, printf, and expect to handle interactive prompts automatically.

		# Using the 'yes' command for basic automation

		The `yes` command repeats a string indefinitely, perfect for automating confirmation prompts:

		Examples:

		# Automatically sends "y" to any prompt
		$ yes | script.sh -option

		# If script specifically expects "yes" or "no"
		$ yes yes | script.sh -option
		$ yes no  | script.sh -option

		# For multiple confirmations with different answers
		$ printf "yes\nno\nyes\n" | script.sh -option

		# Practical example with apt-get (automatic installation)
		$ yes | sudo apt-get install package

		# Example with multiple questions (answers: yes, no, yes)
		$ printf "y\nn\ny\n" | ./interactive_script.sh

		# Using 'expect' for advanced automation

		For scripts with complex logic or specific prompts, use expect:

		```bash
		#!/usr/bin/expect
		# Auto-response for script with custom confirmation
		spawn ./install_script.sh
		expect "Do you want to continue? (yes/no)"
		send "yes\r"
		expect "Start installation? (y/N)"
		send "y\r"
		expect "Enter installation path:"
		send "/opt/app\r"
		expect eof
		```

		Important Tips:

		• `yes` without arguments sends "y" (default)
		• Use `yes yes` to send exactly the string "yes"
		• For multiple different responses, `printf` is more flexible
		• `expect` is ideal for scripts with custom prompts
		• Always test in a safe environment before using in production

		Common errors examples:

		❌ Wrong: script.sh -option | yes
		❌ Wrong: yes | script.sh -option > /dev/null (loses interaction)
		✅ Correct: yes | script.sh -option

		EOF
		read -s -n 1 -rp "Press any key to display the full help" >/dev/tty
		markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/auto-confirm.md
    fi
}
