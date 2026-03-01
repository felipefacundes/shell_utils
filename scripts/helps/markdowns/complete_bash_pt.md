# Vou detalhar todo o sistema de completion do Bash, incluindo os parâmetros do comando `complete`, as opções `-o` e as funções nativas mais importantes.

## 📋 **COMANDO COMPLETE - ESTRUTURA BÁSICA**

```bash
complete [-abcdefgjksuv] [-o comp-option] [-A action] [-G globpat] [-W wordlist] [-P prefix] [-S suffix] [-X filterpat] [-F function] [-C command] nome [nome...]
```

## 🔧 **PARÂMETROS DE COMPLETATION POR TIPO** 

| Parâmetro | Descrição | Exemplo |
|-----------|-----------|---------|
| `-a` | Completa com aliases | `complete -a meucomando` |
| `-b` | Completa com builtins do shell | `complete -b meucomando` |
| `-c` | Completa com comandos | `complete -c meucomando` |
| `-d` | Completa apenas com diretórios | `complete -d meucomando` |
| `-f` | Completa com arquivos | `complete -f meucomando` |
| `-g` | Completa com grupos do sistema | `complete -g meucomando` |
| `-j` | Completa com jobs em execução | `complete -j meucomando` |
| `-k` | Completa com palavras reservadas | `complete -k meucomando` |
| `-s` | Completa com serviços | `complete -s meucomando` |
| `-u` | Completa com usuários | `complete -u meucomando` |
| `-v` | Completa com variáveis | `complete -v meucomando` |

## 🎯 **OPÇÕES -A (ACTION) - COMPLETAÇÕES ESPECÍFICAS** 

| Ação | Descrição |
|------|-----------|
| `-A alias` | Nomes de aliases |
| `-A arrayvar` | Nomes de variáveis array |
| `-A binding` | Nomes de key bindings do Readline |
| `-A builtin` | Nomes de builtins do shell |
| `-A command` | Nomes de comandos |
| `-A directory` | Nomes de diretórios |
| `-A disabled` | Builtins desabilitados |
| `-A enabled` | Builtins habilitados |
| `-A export` | Variáveis exportadas |
| `-A file` | Nomes de arquivos |
| `-A function` | Nomes de funções shell |
| `-A group` | Nomes de grupos |
| `-A helptopic` | Tópicos de ajuda |
| `-A hostname` | Nomes de host |
| `-A job` | Nomes de jobs |
| `-A keyword` | Palavras reservadas |
| `-A running` | Jobs em execução |
| `-A service` | Nomes de serviços |
| `-A setopt` | Opções do comando `set` |
| `-A shopt` | Opções do `shopt` |
| `-A signal` | Nomes de sinais |
| `-A stopped` | Jobs parados |
| `-A user` | Nomes de usuários |
| `-A variable` | Todas as variáveis shell |

## ⚙️ **OPÇÕES -O (COMP-OPTION) - CONTROLE DE COMPORTAMENTO** 

| Opção | Descrição | Exemplo de uso |
|-------|-----------|----------------|
| `-o default` | Usa a completação padrão do Readline (arquivos) se nenhuma correspondência for encontrada  | `complete -o default meucomando` |
| `-o bashdefault` | Usa as completações padrão do Bash se nenhuma correspondência for encontrada (inclui expansão de `~`, `$`, `@`)  | `complete -o bashdefault -o default meucomando` |
| `-o filenames` | **TRATA COMO ARQUIVOS** - Adiciona barra `/` em diretórios, faz escaping de caracteres especiais, não adiciona espaço após diretórios  | `complete -o filenames codium` ✅ *Seu caso de sucesso* |
| `-o dirnames` | Completa diretórios se não houver correspondências | `complete -o dirnames meucomando` |
| `-o nospace` | Não adiciona espaço após a completação  | `complete -o nospace -W "start stop" serviço` |
| `-o plusdirs` | Adiciona completação de diretórios após as correspondências geradas  | `complete -o plusdirs -f meucomando` |
| `-o nosort` | Não ordena alfabeticamente as correspondências  | `complete -o nosort -W "zebra abacate" meucomando` |

## 📌 **CASOS ESPECIAIS: -E, -D, -I** 

| Opção | Contexto | Descrição |
|-------|----------|-----------|
| `-E` | **Comando vazio** | Define completação para quando nada foi digitado (útil para aliases)  | `complete -E` |
| `-D` | **Comando padrão** | Define completação para comandos sem definição própria | `complete -D` |
| `-I` | **Nome inicial** | Completation para nomes de arquivos iniciais | `complete -I` |

✅ *No seu caso, `code` (alias) precisou de `-E` porque o Bash trata aliases de forma especial*

## 🧰 **FUNÇÕES NATIVAS DO BASH-COMPLETION**

Estas funções são definidas quando o pacote `bash-completion` está instalado:

### **`_filedir`** - Função principal para arquivos/diretórios 

```bash
_filedir           # Completa arquivos e diretórios
_filedir -d        # Completa apenas diretórios
_filedir "txt|pdf" # Completa apenas arquivos .txt ou .pdf (case insensitive)
```

**Comportamento:** 
- Usa `compgen -f` para arquivos, `compgen -d` para diretórios
- Aplica `compopt -o filenames` automaticamente
- Suporta filtro por extensão com case insensitive (`txt` e `TXT`)
- Variável `COMP_FILEDIR_FALLBACK` tenta sem filtro se não achar nada

### **`_filedir_xspec`** - Arquivos com padrões específicos

```bash
_filedir_xspec "txt|pdf"  # Completa apenas arquivos .txt ou .pdf
```

**Diferença para `_filedir`:** 
- Usa padrões Xspec (eXtended SPECifications)
- Integra com o sistema de completação de tipos de arquivo
- Ideal para comandos que trabalham com tipos específicos (ex: `grep` com arquivos de texto)

✅ *No seu caso, funcionou com `complete -o default -o bashdefault -F _filedir_xspec -E code`*

### **`_command`** - Completa comandos 

```bash
_command           # Completa comandos disponíveis no PATH
_command_offset 0  # Completa comandos a partir da posição 0
```

**Uso:** Para completar nomes de comandos (como no primeiro argumento do `sudo`)

### **`_command_offset`** - Comandos em posições específicas

```bash
_command_offset 1  # Completa comandos a partir da posição 1
```

## 🔍 **OUTROS COMANDOS ÚTEIS**

```bash
# Listar todas as completações definidas
complete -p

# Remover completação de um comando específico
complete -r comando

# Remover TODAS as completações
complete -r

# Verificar completação de um comando
complete -p comando
```

## 🎨 **EXEMPLOS PRÁTICOS**

```bash
# 1. Apenas arquivos (SEM espaço após diretórios)
complete -o filenames codium  # ✅ Seu caso

# 2. Arquivos + completação padrão do Bash (~, $, @)
complete -o filenames -o bashdefault -o default meuapp

# 3. Primeiro argumento: palavras fixas, depois: arquivos
complete -F _meuapp meuapp
_meuapp() {
    local cur prev
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    if [[ $COMP_CWORD -eq 1 ]]; then
        # Primeiro argumento: opções específicas
        COMPREPLY=($(compgen -W "start stop restart status" -- "$cur"))
        [[ $COMPREPLY ]] && compopt -o nospace  # Não adicionar espaço
    else
        # Demais argumentos: arquivos
        _filedir
    fi
}
complete -F _meuapp meuapp

# 4. Aliases precisam de tratamento especial (como seu case code)
alias code='codium'
complete -o default -o bashdefault -F _filedir_xspec -E code

# 5. Comando que só aceita diretórios
complete -o filenames -A directory meuapp

# 6. Comando com wordlist fixa
complete -W "vermelho verde azul" cores

# 7. Completar nomes de usuários
complete -u meucomando

# 8. Completar variáveis de ambiente
complete -v meucomando
```

## Função de completação personalizada:

### 🔍 **Explicação detalhada:**

```bash
_complete_only_commands() {
    mapfile -t COMPREPLY < <(compgen -c -- "$2")
    return 0
}

complete -F _complete_only_commands -E
complete -F _complete_only_commands -I
```

### **`_complete_only_commands()`** - Função de completação

- **`mapfile -t COMPREPLY`**: Armazena a saída do comando no array `COMPREPLY` (variável especial que o Bash lê para mostrar as opções de completação)
- **`compgen -c -- "$2"`**: Gera lista de **todos os comandos disponíveis** no sistema (`-c`) que correspondem ao texto parcial (`$2` - segundo argumento da função, que é o texto atual sendo completado)
- **`< <(comando)`**: Process substitution - executa o comando e trata sua saída como um arquivo temporário
- **`return 0`**: Retorna sucesso

### **`complete -F _complete_only_commands -E`**

- **`-F`**: Usa a função especificada para gerar as completações
- **`-E`**: Aplica esta completação para **comando vazio** (quando nada foi digitado ainda)
- **Efeito**: Ao pressionar TAB sem nada digitado, mostra **apenas comandos**, não arquivos

### **`complete -F _complete_only_commands -I`**

- **`-I`**: Aplica para **nomes iniciais de arquivos** (contexto especial)
- Complementa o `-E` para cobrir mais casos

## ⚠️ **Problema que você enfrentou:**

Esta configuração substitui a completação padrão de arquivos (como para `cat` e `codium`), fazendo com que apenas comandos fossem mostrados, não arquivos.


## 💡 **DICAS IMPORTANTES** 

1. **`-o filenames` vs `_filedir`**: A função `_filedir` já chama `compopt -o filenames` automaticamente quando necessário 

2. **Aliases precisam de `-E`**: Como você descobriu, aliases muitas vezes precisam da opção `-E` para completação funcionar

3. **Ordem das opções**: A ordem importa. `-o bashdefault -o default` tenta primeiro bashdefault, depois default 

4. **`compopt` dentro de funções**: Use `compopt -o filenames` dentro de funções para ativar comportamento de arquivos dinamicamente 

5. **Case insensitive**: O bash-completion já trata extensões com case insensitive (ex: `_filedir "txt"` pega .txt e .TXT) 

## 📚 **RESUMO - QUANDO USAR CADA UM**

| Situação | Solução |
|----------|---------|
| Comando comum que aceita arquivos | `complete -o filenames comando` |
| Comando com argumentos específicos + arquivos | Função personalizada com `_filedir` |
| Alias precisa de completação | `complete -o ... -E alias` |
| Quer manter expansão de `~` e `$` | Adicione `-o bashdefault -o default` |
| Comando que só aceita diretórios | `complete -o filenames -A directory comando` |
| Comando com wordlist fixa | `complete -W "opcoes" comando` |
| Remover completação problemática | `complete -r comando` |

Com esse conhecimento, você pode criar completações personalizadas para qualquer comando no seu sistema! 🚀