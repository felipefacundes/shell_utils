complete_bash() {
    cat <<-'EOF'
	# Bash Completion System - Complete reference guide for the bash completion system, 
	# including built-in functions, options, and practical examples for creating custom completions.
	EOF
    
    clear
    if [[ "${LANG,,}" =~ pt_ ]]; then
        cat <<-'EOF'
        # Sistema de Completion do Bash - Guia completo de referência para o sistema de completion do bash,
        # incluindo funções nativas, opções e exemplos práticos para criar completações personalizadas.

        ## COMANDO COMPLETE - ESTRUTURA BÁSICA
        complete [-abcdefgjksuv] [-o opção] [-A ação] [-G padrão] [-W lista] [-P prefixo] [-S sufixo] [-X filtro] [-F função] [-C comando] nome [nome...]

        ## PARÂMETROS DE COMPLETATION POR TIPO
        -a  Completa com aliases
        -b  Completa com builtins do shell
        -c  Completa com comandos
        -d  Completa apenas com diretórios
        -f  Completa com arquivos
        -g  Completa com grupos do sistema
        -j  Completa com jobs em execução
        -k  Completa com palavras reservadas
        -s  Completa com serviços
        -u  Completa com usuários
        -v  Completa com variáveis

        ## OPÇÕES -A (ACTION) - COMPLETAÇÕES ESPECÍFICAS
        -A alias     Nomes de aliases
        -A arrayvar  Nomes de variáveis array
        -A builtin   Nomes de builtins do shell
        -A command   Nomes de comandos
        -A directory Nomes de diretórios
        -A export    Variáveis exportadas
        -A file      Nomes de arquivos
        -A function  Nomes de funções shell
        -A group     Nomes de grupos
        -A hostname  Nomes de host
        -A job       Nomes de jobs
        -A keyword   Palavras reservadas
        -A running   Jobs em execução
        -A service   Nomes de serviços
        -A signal    Nomes de sinais
        -A stopped   Jobs parados
        -A user      Nomes de usuários
        -A variable  Todas as variáveis shell

        ## OPÇÕES -O (COMP-OPTION) - CONTROLE DE COMPORTAMENTO
        -o default      Usa completação padrão do Readline se nenhuma correspondência for encontrada
        -o bashdefault  Usa completações padrão do Bash se nenhuma correspondência for encontrada
        -o filenames    TRATA COMO ARQUIVOS - Adiciona / em diretórios, faz escaping, não adiciona espaço após diretórios
        -o dirnames     Completa diretórios se não houver correspondências
        -o nospace      Não adiciona espaço após a completação
        -o plusdirs     Adiciona completação de diretórios após as correspondências geradas
        -o nosort       Não ordena alfabeticamente as correspondências

        ## CASOS ESPECIAIS: -E, -D, -I
        -E  Comando vazio - Define completação para quando nada foi digitado (útil para aliases)
        -D  Comando padrão - Define completação para comandos sem definição própria
        -I  Nome inicial - Completation para nomes de arquivos iniciais

        ## FUNÇÕES NATIVAS DO BASH-COMPLETION
        _filedir           Completa arquivos e diretórios
        _filedir -d        Completa apenas diretórios
        _filedir "txt|pdf" Completa apenas arquivos .txt ou .pdf
        _filedir_xspec     Arquivos com padrões específicos
        _command           Completa comandos disponíveis no PATH
        _command_offset n  Completa comandos a partir da posição n

        ## COMANDOS ÚTEIS
        complete -p           Listar todas as completações definidas
        complete -r comando   Remover completação de um comando específico
        complete -r           Remover TODAS as completações
        complete -p comando   Verificar completação de um comando

        ## EXEMPLOS PRÁTICOS
        # 1. Apenas arquivos (SEM espaço após diretórios)
        complete -o filenames codium

        # 2. Arquivos + completação padrão do Bash (~, $, @)
        complete -o filenames -o bashdefault -o default meuapp

        # 3. Aliases precisam de tratamento especial
        alias code='codium'
        complete -o default -o bashdefault -F _filedir_xspec -E code

        # 4. Comando que só aceita diretórios
        complete -o filenames -A directory meuapp

        # 5. Comando com wordlist fixa
        complete -W "vermelho verde azul" cores

        # 6. Completar nomes de usuários
        complete -u meucomando

        # 7. Completar variáveis de ambiente
        complete -v meucomando

        # 8. Função personalizada (mostra apenas comandos)
        _complete_only_commands() {
            mapfile -t COMPREPLY < <(compgen -c -- "$2")
            return 0
        }
        complete -F _complete_only_commands -E
        complete -F _complete_only_commands -I

        ## RESUMO - QUANDO USAR CADA UM
        Comando comum que aceita arquivos: complete -o filenames comando
        Comando com argumentos específicos + arquivos: Função personalizada com _filedir
        Alias precisa de completação: complete -o ... -E alias
        Quer manter expansão de ~ e $: Adicione -o bashdefault -o default
        Comando que só aceita diretórios: complete -o filenames -A directory comando
        Comando com wordlist fixa: complete -W "opcoes" comando
        Remover completação problemática: complete -r comando
        ----------------------------------------------------

		EOF

        read -s -n 1 -rp "Pressione qualquer tecla para exibir o help completo" >/dev/tty
        markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/complete_bash_pt.md
    else
        cat <<-'EOF'
        # Bash Completion System - Complete reference guide for the bash completion system,
        # including built-in functions, options, and practical examples for creating custom completions.

        ## COMPLETE COMMAND - BASIC STRUCTURE
        complete [-abcdefgjksuv] [-o option] [-A action] [-G pattern] [-W wordlist] [-P prefix] [-S suffix] [-X filter] [-F function] [-C command] name [name...]

        ## COMPLETION PARAMETERS BY TYPE
        -a  Complete with aliases
        -b  Complete with shell builtins
        -c  Complete with commands
        -d  Complete only directories
        -f  Complete with files
        -g  Complete with system groups
        -j  Complete with running jobs
        -k  Complete with reserved words
        -s  Complete with services
        -u  Complete with users
        -v  Complete with variables

        ## -A (ACTION) OPTIONS - SPECIFIC COMPLETIONS
        -A alias     Alias names
        -A arrayvar  Array variable names
        -A builtin   Shell builtin names
        -A command   Command names
        -A directory Directory names
        -A export    Exported variables
        -A file      File names
        -A function  Shell function names
        -A group     Group names
        -A hostname  Host names
        -A job       Job names
        -A keyword   Reserved words
        -A running   Running jobs
        -A service   Service names
        -A signal    Signal names
        -A stopped   Stopped jobs
        -A user      User names
        -A variable  All shell variables

        ## -O (COMP-OPTION) OPTIONS - BEHAVIOR CONTROL
        -o default      Use default Readline completion if no matches found
        -o bashdefault  Use default Bash completions if no matches found
        -o filenames    TREAT AS FILES - Add / to directories, escaping, no space after directories
        -o dirnames     Complete directories if no matches
        -o nospace      Do not add space after completion
        -o plusdirs     Add directory completion after generated matches
        -o nosort       Do not sort matches alphabetically

        ## SPECIAL CASES: -E, -D, -I
        -E  Empty command - Define completion for when nothing is typed (useful for aliases)
        -D  Default command - Define completion for commands without their own definition
        -I  Initial name - Completion for initial filenames

        ## NATIVE BASH-COMPLETION FUNCTIONS
        _filedir           Complete files and directories
        _filedir -d        Complete only directories
        _filedir "txt|pdf" Complete only .txt or .pdf files
        _filedir_xspec     Files with specific patterns
        _command           Complete commands available in PATH
        _command_offset n  Complete commands starting at position n

        ## USEFUL COMMANDS
        complete -p           List all defined completions
        complete -r command   Remove completion for a specific command
        complete -r           Remove ALL completions
        complete -p command   Check completion for a command

        ## PRACTICAL EXAMPLES
        # 1. Only files (NO space after directories)
        complete -o filenames codium

        # 2. Files + default Bash completion (~, $, @)
        complete -o filenames -o bashdefault -o default myapp

        # 3. Aliases need special treatment
        alias code='codium'
        complete -o default -o bashdefault -F _filedir_xspec -E code

        # 4. Command that only accepts directories
        complete -o filenames -A directory myapp

        # 5. Command with fixed wordlist
        complete -W "red green blue" colors

        # 6. Complete usernames
        complete -u mycommand

        # 7. Complete environment variables
        complete -v mycommand

        # 8. Custom function (shows only commands)
        _complete_only_commands() {
            mapfile -t COMPREPLY < <(compgen -c -- "$2")
            return 0
        }
        complete -F _complete_only_commands -E
        complete -F _complete_only_commands -I

        ## SUMMARY - WHEN TO USE EACH
        Common command that accepts files: complete -o filenames command
        Command with specific args + files: Custom function with _filedir
        Alias needs completion: complete -o ... -E alias
        Want to keep ~ and $ expansion: Add -o bashdefault -o default
        Command that only accepts directories: complete -o filenames -A directory command
        Command with fixed wordlist: complete -W "options" command
        Remove problematic completion: complete -r command
        ----------------------------------------------------
        
		EOF

        read -s -n 1 -rp "Press any key to display the full help" >/dev/tty
        markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/complete_bash.md
    fi
}