tmux_help() {
	local biblack_on_cyan='\033[90;1;46m'
	local bigreen_on_bblack='\033[92;1;40m'
	local nc='\033[0m'
	
	cat <<-EOF | { echo -e "$(cat)"; }
	# Tmux - Basic Quick Guide
	EOF
	clear
	if [[ "${LANG,,}" =~ pt_ ]]; then
		cat <<-EOF | { echo -e "$(cat)"; }
		# Tmux - Guia Básico Rápido

		Exemplos:

		${biblack_on_cyan}# Iniciar uma sessão tmux${nc}
		${bigreen_on_bblack}tmux${nc}
		${biblack_on_cyan}# Iniciar sessão com nome${nc}
		${bigreen_on_bblack}tmux new -s minha_sessao${nc}
		${biblack_on_cyan}# Fechar o terminal/pane atual${nc}
		${bigreen_on_bblack}exit${nc} ou ${bigreen_on_bblack}Ctrl+d${nc}
		
		${biblack_on_cyan}# Gerenciamento de Sessões:${nc}
		${biblack_on_cyan}# Listar todas as sessões${nc}
		${bigreen_on_bblack}tmux ls${nc}
		${biblack_on_cyan}# Reconectar à sessão 0${nc}
		${bigreen_on_bblack}tmux attach -t 0${nc}
		${biblack_on_cyan}# Criar sessão nomeada${nc}
		${bigreen_on_bblack}tmux new -s desenvolvimento${nc}
		${biblack_on_cyan}# Anexar a sessão específica${nc}
		${bigreen_on_bblack}tmux attach -t desenvolvimento${nc}
		${biblack_on_cyan}# Encerrar sessão específica${nc}
		${bigreen_on_bblack}tmux kill-session -t nome${nc}
		
		${biblack_on_cyan}# Atalhos de Teclado (Ctrl-b é o prefixo):${nc}
		${biblack_on_cyan}# Criar nova aba${nc}
		${bigreen_on_bblack}Ctrl-b c${nc}
		${biblack_on_cyan}# Próxima aba${nc}
		${bigreen_on_bblack}Ctrl-b n${nc}
		${biblack_on_cyan}# Aba anterior${nc}
		${bigreen_on_bblack}Ctrl-b p${nc}
		${biblack_on_cyan}# Ir para aba específica (0-9)${nc}
		${bigreen_on_bblack}Ctrl-b [número]${nc}
		${biblack_on_cyan}# Listar abas${nc}
		${bigreen_on_bblack}Ctrl-b w${nc}
		${biblack_on_cyan}# Renomear aba atual${nc}
		${bigreen_on_bblack}Ctrl-b ,${nc}
		${biblack_on_cyan}# Fechar aba atual${nc}
		${bigreen_on_bblack}Ctrl-b &${nc}
		
		${biblack_on_cyan}# Gerenciamento de Panes (divisões):${nc}
		${biblack_on_cyan}# Dividir verticalmente${nc}
		${bigreen_on_bblack}Ctrl-b %${nc}
		${biblack_on_cyan}# Dividir horizontalmente${nc}
		${bigreen_on_bblack}Ctrl-b " ${nc}
		${biblack_on_cyan}# Navegar entre panes${nc}
		${bigreen_on_bblack}Ctrl-b seta${nc}
		${biblack_on_cyan}# Fechar pane atual${nc}
		${bigreen_on_bblack}Ctrl-b x${nc}
		${biblack_on_cyan}# Zoom no pane (maximizar/restaurar)${nc}
		${bigreen_on_bblack}Ctrl-b z${nc}
		${biblack_on_cyan}# Próximo pane${nc}
		${bigreen_on_bblack}Ctrl-b o${nc}
		${biblack_on_cyan}# Alternar para último pane usado${nc}
		${bigreen_on_bblack}Ctrl-b ;${nc}
		
		${biblack_on_cyan}# Outros Comandos Úteis:${nc}
		${biblack_on_cyan}# Desconectar da sessão (deixa rodando)${nc}
		${bigreen_on_bblack}Ctrl-b d${nc}
		${biblack_on_cyan}# Renomear sessão atual${nc}
		${bigreen_on_bblack}Ctrl-b $${nc}
		${biblack_on_cyan}# Alternar entre sessões${nc}
		${bigreen_on_bblack}Ctrl-b s${nc}
		${biblack_on_cyan}# Abrir prompt de comandos do tmux${nc}
		${bigreen_on_bblack}Ctrl-b :${nc}
		${biblack_on_cyan}# Redimensionar pane${nc}
		${bigreen_on_bblack}Ctrl-b Ctrl+seta${nc}
		${biblack_on_cyan}# Alternar entre layouts pré-definidos${nc}
		${bigreen_on_bblack}Ctrl-b Espaço${nc}
		${biblack_on_cyan}# Executar comando em sessão existente${nc}
		${bigreen_on_bblack}tmux send-keys -t sessao 'comando' Enter${nc}
		${biblack_on_cyan}# Listar keybindings${nc}
		${bigreen_on_bblack}tmux list-keys${nc}
		${biblack_on_cyan}# Mostrar informações da sessão${nc}
		${bigreen_on_bblack}tmux info${nc}

		EOF

		read -s -n 1 -rp "Pressione qualquer tecla, para exibir o help completo" >/dev/tty
		markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/basico_de_tmux.md
	else
		cat <<-EOF | { echo -e "$(cat)"; }
		# Tmux - Quick Basic Guide

		Examples:

		${biblack_on_cyan}# Start a tmux session${nc}
		${bigreen_on_bblack}tmux${nc}
		${biblack_on_cyan}# Start session with name${nc}
		${bigreen_on_bblack}tmux new -s my_session${nc}
		${biblack_on_cyan}# Close current terminal/pane${nc}
		${bigreen_on_bblack}exit${nc} or ${bigreen_on_bblack}Ctrl+d${nc}
		
		${biblack_on_cyan}# Session Management:${nc}
		${biblack_on_cyan}# List all sessions${nc}
		${bigreen_on_bblack}tmux ls${nc}
		${biblack_on_cyan}# Reconnect to session 0${nc}
		${bigreen_on_bblack}tmux attach -t 0${nc}
		${biblack_on_cyan}# Create named session${nc}
		${bigreen_on_bblack}tmux new -s development${nc}
		${biblack_on_cyan}# Attach to specific session${nc}
		${bigreen_on_bblack}tmux attach -t development${nc}
		${biblack_on_cyan}# Kill specific session${nc}
		${bigreen_on_bblack}tmux kill-session -t name${nc}
		
		${biblack_on_cyan}# Keyboard Shortcuts (Ctrl-b is the prefix):${nc}
		${biblack_on_cyan}# Create new tab${nc}
		${bigreen_on_bblack}Ctrl-b c${nc}
		${biblack_on_cyan}# Next tab${nc}
		${bigreen_on_bblack}Ctrl-b n${nc}
		${biblack_on_cyan}# Previous tab${nc}
		${bigreen_on_bblack}Ctrl-b p${nc}
		${biblack_on_cyan}# Go to specific tab (0-9)${nc}
		${bigreen_on_bblack}Ctrl-b [number]${nc}
		${biblack_on_cyan}# List tabs${nc}
		${bigreen_on_bblack}Ctrl-b w${nc}
		${biblack_on_cyan}# Rename current tab${nc}
		${bigreen_on_bblack}Ctrl-b ,${nc}
		${biblack_on_cyan}# Close current tab${nc}
		${bigreen_on_bblack}Ctrl-b &${nc}
		
		${biblack_on_cyan}# Pane Management (splits):${nc}
		${biblack_on_cyan}# Split vertically${nc}
		${bigreen_on_bblack}Ctrl-b %${nc}
		${biblack_on_cyan}# Split horizontally${nc}
		${bigreen_on_bblack}Ctrl-b " ${nc}
		${biblack_on_cyan}# Navigate between panes${nc}
		${bigreen_on_bblack}Ctrl-b arrow${nc}
		${biblack_on_cyan}# Close current pane${nc}
		${bigreen_on_bblack}Ctrl-b x${nc}
		${biblack_on_cyan}# Zoom pane (maximize/restore)${nc}
		${bigreen_on_bblack}Ctrl-b z${nc}
		${biblack_on_cyan}# Next pane${nc}
		${bigreen_on_bblack}Ctrl-b o${nc}
		${biblack_on_cyan}# Switch to last used pane${nc}
		${bigreen_on_bblack}Ctrl-b ;${nc}
		
		${biblack_on_cyan}# Other Useful Commands:${nc}
		${biblack_on_cyan}# Detach from session (keep running)${nc}
		${bigreen_on_bblack}Ctrl-b d${nc}
		${biblack_on_cyan}# Rename current session${nc}
		${bigreen_on_bblack}Ctrl-b $${nc}
		${biblack_on_cyan}# Switch between sessions${nc}
		${bigreen_on_bblack}Ctrl-b s${nc}
		${biblack_on_cyan}# Open tmux command prompt${nc}
		${bigreen_on_bblack}Ctrl-b :${nc}
		${biblack_on_cyan}# Resize pane${nc}
		${bigreen_on_bblack}Ctrl-b Ctrl+arrow${nc}
		${biblack_on_cyan}# Toggle between predefined layouts${nc}
		${bigreen_on_bblack}Ctrl-b Space${nc}
		${biblack_on_cyan}# Execute command in existing session${nc}
		${bigreen_on_bblack}tmux send-keys -t session 'command' Enter${nc}
		${biblack_on_cyan}# List keybindings${nc}
		${bigreen_on_bblack}tmux list-keys${nc}
		${biblack_on_cyan}# Show session information${nc}
		${bigreen_on_bblack}tmux info${nc}

		EOF

		read -s -n 1 -rp "Press any key to display the full help" >/dev/tty
		markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/tmux_basic.md
	fi
}