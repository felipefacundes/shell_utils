# Automatizando Confirmações em Scripts Shell

Um guia completo para automatizar prompts interativos de confirmação (yes/no) em scripts shell usando `yes`, `printf` e `expect`.

## 📋 Índice

- [Introdução](#introdução)
- [O Comando `yes`](#o-comando-yes)
  - [Uso Básico](#uso-básico)
  - [Personalizando a Resposta](#personalizando-a-resposta)
  - [Exemplos Práticos](#exemplos-práticos)
- [Múltiplas Respostas com `printf`](#múltiplas-respostas-com-printf)
- [Automação Avançada com `expect`](#automação-avançada-com-expect)
  - [Instalação do expect](#instalação-do-expect)
  - [Exemplos Básicos](#exemplos-básicos)
  - [Scripts Complexos](#scripts-complexos)
- [Erros Comuns e Soluções](#erros-comuns-e-soluções)
- [Casos de Uso Reais](#casos-de-uso-reais)
- [Boas Práticas](#boas-práticas)
- [Referências](#referências)

## 🚀 Introdução

Muitos scripts shell e programas de linha de comando exigem interação do usuário durante a execução, especialmente para confirmações de ações destrutivas ou instalações. Em ambientes automatizados (como scripts de deploy, CI/CD ou instalações em lote), é necessário fornecer essas respostas automaticamente.

Este guia apresenta as principais técnicas para automatizar prompts de confirmação em scripts shell, desde soluções simples com o comando `yes` até automações complexas com `expect`.

## 📦 O Comando `yes`

O comando `yes` é uma ferramenta Unix simples mas poderosa que repete uma string indefinidamente até ser interrompido.

### Uso Básico

A forma mais comum de usar o `yes` é para responder automaticamente "y" (sim) a todos os prompts:

```bash
# Responde "y" automaticamente para qualquer prompt
$ yes | script.sh -option
```

**Como funciona:**
1. `yes` começa a imprimir "y" infinitamente
2. O pipe (`|`) redireciona essa saída para o script
3. Quando o script solicita entrada, ele recebe "y" automaticamente
4. O processo continua até o script terminar

### Personalizando a Resposta

O `yes` aceita um argumento opcional para personalizar a resposta:

```bash
# Responde "yes" em vez de "y"
$ yes yes | script.sh -option

# Responde "no" automaticamente
$ yes no | script.sh -option

# Responde com texto personalizado
$ yes "confirmar" | script.sh -option
```

### Exemplos Práticos

#### Instalação Automática com APT

```bash
# Instalar pacote sem confirmação
$ yes | sudo apt-get install python3-pip

# Ou para múltiplos pacotes
$ yes | sudo apt-get install nginx redis-server postgresql
```

#### Scripts de Instalação Personalizados

```bash
# Script que pergunta "Deseja instalar? (y/n)"
$ yes | ./install.sh

# Script que espera "yes" explicitamente
$ yes yes | ./configure --prefix=/usr/local
```

#### Docker e Containers

```bash
# Remover todos os containers sem confirmação
$ yes | docker system prune -a

# Limpar imagens não utilizadas
$ yes | docker image prune -a
```

## 🔄 Múltiplas Respostas com `printf`

Quando um script faz várias perguntas diferentes ou espera respostas específicas em sequência, o `printf` oferece mais controle:

### Sintaxe Básica

```bash
$ printf "resposta1\nresposta2\nresposta3\n" | script.sh
```

### Exemplos Práticos

#### Script com Múltiplas Perguntas

```bash
# Script que pergunta:
# 1. Continuar? (y/n)
# 2. Sobrescrever arquivos? (y/n)
# 3. Enviar relatório? (y/n)

$ printf "y\nn\ny\n" | ./processamento.sh
```

#### Instalação com Configuração

```bash
# Script de instalação que pergunta:
# 1. Aceita a licença? (yes/no)
# 2. Diretório de instalação? (caminho)
# 3. Criar atalho? (y/n)

$ printf "yes\n/opt/app\nn\n" | ./instalador.bin
```

#### Scripts com Opções Múltiplas

```bash
# Para scripts com menus interativos
$ printf "1\n/usr/local\nyes\n" | ./config_tool.sh
```

## 🎯 Automação Avançada com `expect`

Para scripts com prompts complexos, validação de entrada, ou quando você precisa responder baseado no conteúdo exato da pergunta, o `expect` é a ferramenta ideal.

### Instalação do expect

```bash
# Debian/Ubuntu
$ sudo apt-get install expect

# RHEL/CentOS/Fedora
$ sudo yum install expect

# macOS
$ brew install expect
```

### Exemplos Básicos

#### Script Simples de Expect

Crie um arquivo `auto_resposta.exp`:

```expect
#!/usr/bin/expect

# Inicia o script
spawn ./script_instalacao.sh

# Espera pelo prompt de confirmação
expect "Deseja continuar? (yes/no)"

# Envia a resposta
send "yes\r"

# Espera pelo próximo prompt
expect "Digite o diretório de instalação:"
send "/opt/aplicacao\r"

# Aguarda o término do script
expect eof
```

Torne-o executável:

```bash
$ chmod +x auto_resposta.exp
$ ./auto_resposta.exp
```

#### Tratamento de Timeout

```expect
#!/usr/bin/expect

set timeout 30
spawn ./script_demorado.sh

expect {
    "Continuar?" { send "yes\r"; exp_continue }
    "Senha:" { send "minha_senha\r" }
    timeout { puts "Timeout atingido"; exit 1 }
    eof { puts "Script concluído" }
}
```

### Scripts Complexos

#### SSH com Expect

```expect
#!/usr/bin/expect

set host [lindex $argv 0]
set user [lindex $argv 1]
set password [lindex $argv 2]

spawn ssh $user@$host

expect {
    "password:" { 
        send "$password\r"
        exp_continue
    }
    "Yes/No" {
        send "Yes\r"
        exp_continue
    }
    "$ " {
        send "ls -la\r"
        expect "$ "
        send "exit\r"
    }
}

expect eof
```

#### Instalador com Múltiplas Telas

```expect
#!/usr/bin/expect

spawn ./instalador_guiado.sh

# Tela de boas-vindas
expect "Pressione Enter para continuar"
send "\r"

# Licença
expect "Você aceita os termos? (yes/no)"
send "yes\r"

# Tipo de instalação
expect "Escolha o tipo (1-Básica, 2-Completa):"
send "2\r"

# Confirmação final
expect "Iniciar instalação? (s/N)"
send "s\r"

# Aguarda conclusão
expect "Instalação concluída!"
expect eof
```

## ❌ Erros Comuns e Soluções

### Erro 1: Pipe Invertido

```bash
# ❌ ERRADO
$ script.sh -option | yes

# ✅ CORRETO
$ yes | script.sh -option
```

### Erro 2: Redirecionamento que Bloqueia Interação

```bash
# ❌ ERRADO - Redireciona a saída do yes, mas também perde a saída do script
$ yes | script.sh > /dev/null

# ✅ CORRETO - Mantém a saída do script visível
$ yes | script.sh
```

### Erro 3: Esquecer o Pipe

```bash
# ❌ ERRADO - yes executa separadamente
$ yes
$ script.sh

# ✅ CORRETO - Conecta yes ao script
$ yes | script.sh
```

### Erro 4: Case Sensitivity

```bash
# ❌ ERRADO - Script espera "yes" mas recebe "y"
$ yes | ./script_que_espera_yes.sh

# ✅ CORRETO - Especifica a resposta exata
$ yes yes | ./script_que_espera_yes.sh
```

### Erro 5: Não Considerar Múltiplos Prompts

```bash
# ❌ ERRADO - Primeiro prompt recebe "yes", segundo recebe "yes" novamente
$ yes yes | ./script_com_dois_prompts.sh

# ✅ CORRETO - Controla cada resposta individualmente
$ printf "yes\nno\n" | ./script_com_dois_prompts.sh
```

## 💡 Casos de Uso Reais

### 1. Deploy Automatizado

```bash
#!/bin/bash
# deploy.sh

# Auto-resposta para comandos destrutivos
yes | docker system prune -a
yes | ./limpar_logs.sh
printf "production\nn\n" | ./configurar_ambiente.sh
```

### 2. CI/CD Pipeline

```yaml
# .gitlab-ci.yml
deploy-job:
  script:
    - yes | ./install_dependencies.sh
    - printf "yes\n/dev/null\n" | ./configure --prefix=/app
    - make && make install
```

### 3. Script de Backup Automático

```bash
#!/bin/bash
# backup_auto.sh

# Auto-resposta para sobrescrever backups antigos
yes | ./criar_backup.sh --full

# Respostas específicas para diferentes etapas
printf "yes\n/backup/dir\nN\n" | ./backup_script.sh
```

### 4. Ambiente de Desenvolvimento

```bash
#!/bin/bash
# setup_dev.sh

# Configuração automática do ambiente
yes | sudo apt-get update
yes | sudo apt-get install docker docker-compose

printf "development\nn\n" | ./init_project.sh

# Expect para configuração do banco de dados
./config_db.exp
```

## 📝 Boas Práticas

### 1. **Sempre Testar Primeiro**

```bash
# Teste em um ambiente controlado
$ ./script_destrutivo.sh --dry-run
$ yes | ./script_destrutivo.sh
```

### 2. **Documentar Automações**

```bash
#!/bin/bash
# auto_install.sh - Script com automação documentada

# AUTOMATION: Auto-responde "yes" para instalação do pacote
# Porque: O pacote requer confirmação da licença
echo "Instalando pacote automaticamente..."
yes yes | ./install_package.sh
```

### 3. **Usar Variáveis para Respostas**

```bash
#!/bin/bash

RESPOSTA_PADRAO="y"
RESPOSTA_LICENCA="yes"
RESPOSTA_DIR="/opt/app"

printf "%s\n%s\n%s\n" "$RESPOSTA_PADRAO" "$RESPOSTA_LICENCA" "$RESPOSTA_DIR" | ./config.sh
```

### 4. **Incluir Logging**

```bash
#!/bin/bash

exec > >(tee -a install.log) 2>&1

echo "Iniciando instalação automatizada em $(date)"
yes | ./install.sh
echo "Instalação concluída em $(date)"
```

### 5. **Tratamento de Erros**

```bash
#!/bin/bash

if ! yes | ./script.sh; then
    echo "Erro na execução do script"
    exit 1
fi
```

## 📚 Referências

### Manuais e Documentação

- `man yes` - Manual do comando yes
- `man printf` - Manual do comando printf
- `man expect` - Manual completo do expect
- `man expect` (programação) - Guia de programação expect

### Recursos Online

- [GNU Coreutils: yes](https://www.gnu.org/software/coreutils/manual/html_node/yes-invocation.html)
- [Expect Project Page](https://core.tcl-lang.org/expect/index)
- [Tcl Expect Documentation](https://www.tcl.tk/man/expect/expect.1.html)

### Exemplos Avançados

- [Expect Scripts Repository](https://github.com/expect-scripts)
- [Auto-installation Examples](https://github.com/topics/auto-install)

## 🎉 Conclusão

Automatizar confirmações em scripts é uma habilidade essencial para administradores de sistemas e desenvolvedores que trabalham com automação. As ferramentas apresentadas neste guia (`yes`, `printf` e `expect`) oferecem soluções para diferentes níveis de complexidade:

- **`yes`** - Simples e direto para confirmações básicas
- **`printf`** - Flexível para múltiplas respostas em sequência
- **`expect`** - Poderoso para interações complexas e personalizadas

Escolha a ferramenta adequada para seu caso de uso e sempre teste em ambientes seguros antes de implementar em produção.

---

**Contribuições são bem-vindas!** Encontrou um erro ou tem uma sugestão? Abra uma issue ou envie um pull request.