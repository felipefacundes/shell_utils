# Shell Utils Framework 🐚

[![pt-BR](https://img.shields.io/badge/lang-pt--BR-green.svg)](./README_pt.md) [![es](https://img.shields.io/badge/lang-es-yellow.svg)](./README_es.md) [![en](https://img.shields.io/badge/lang-en-red.svg)](./README.md)

<div align="center">
  
![Shell Utils Logo](./icons/logo.png)

*Uma Coleção Dinâmica de Scripts Shell com Propósito Educacional*

![GitHub stars](https://img.shields.io/github/stars/felipefacundes/shell_utils?style=social)
![GitHub forks](https://img.shields.io/github/forks/felipefacundes/shell_utils?style=social)
![GitHub issues](https://img.shields.io/github/issues/felipefacundes/shell_utils)
![GitHub license](https://img.shields.io/github/license/felipefacundes/shell_utils)

</div>

## 🌟 Visão Geral

O Shell Utils é um framework educacional projetado para tornar a programação shell acessível e poderosa. É o resultado de um trabalho exaustivo de muitos anos, agora disponível no GitHub. Com mais de 400 scripts documentados, atende tanto iniciantes quanto usuários avançados. Seu grande diferencial é a capacidade de interagir com os principais shells: **Bash, Zsh e Fish**.

Este repositório tem como objetivo estender o shell e conter funções úteis e legíveis que ajudam os desenvolvedores a manter seus scripts de forma mais fácil e organizada.

✅ Inclui scripts de terceiros, como os do [Fred's Imagemagick](http://www.fmwconcepts.com/imagemagick/index.php) *(créditos mantidos nos scripts)*.

### ✨ Características Principais

- Reconhecimento dinâmico de scripts, funções, variáveis e aliases
- Documentação abrangente e menus de ajuda
- Compatibilidade entre shells (fish, zsh, bash)
- Rica coleção de scripts utilitários
- Recursos educacionais e tutoriais
- **Estrutura de pastas persistente** para customizações do usuário que não são afetadas pelas atualizações do framework

📌 O script `help_shell` lista funções como `docker_help` (para auxiliar no uso do docker), fornecendo tutoriais rápidos sobre comandos do Linux. Para criar uma função simples, basta criar um arquivo `função.sh` e armazená-lo em `~/.local/shell_utils/scripts/helps/`. O script `help_shell` será capaz de lê-los e mostrar uma lista completa de funções pedagógicas e muito mais.

## 📁 Estrutura de Diretórios

```bash
~/.shell_utils/
├── scripts/     # Scripts principais
│   ├── faqs/    # Scripts de tutorial e guias
│   └── helps/   # Funções auxiliares educacionais
├── functions/   # Funções personalizadas
├── variables/   # Variáveis de ambiente
└── aliases/     # Aliases do shell
```

## 🛡️ Estrutura Persistente para Usuários

Para garantir que suas customizações sejam preservadas durante as atualizações automáticas do framework, utilize a estrutura de diretórios persistente:

```bash
~/.local/share/shell_utils/
├── functions/   # Suas funções personalizadas (seguras contra atualizações)
├── variables/   # Suas variáveis de ambiente personalizadas
├── aliases/     # Seus aliases personalizados
├── priority/    # Scripts com prioridade de carregamento
└── scripts/
    ├── utils/   # Seus scripts utilitários
    └── helps/
        └── markdowns/  # Sua documentação personalizada
```

### 🔄 Como Funciona:
- **`~/.shell_utils/`** - Framework principal (atualizável via Git)
- **`~/.local/share/shell_utils/`** - Suas customizações (persistentes e seguras)
- **Ordem de Carregamento**: Primeiro o framework, depois suas customizações
- **Atualizações Automáticas**: Seus arquivos em `~/.local/shell_utils/` nunca são sobrescritos

### 💡 Para Adicionar Suas Customizações:
```bash
# Suas funções personalizadas
vim ~/.local/shell_utils/functions/minha_funcao.sh

# Seus aliases personalizados  
vim ~/.local/shell_utils/aliases/meus_aliases.sh

# Suas variáveis de ambiente
vim ~/.local/shell_utils/variaveis/minhas_variaveis.sh
```

## 🔧 Recursos e Ferramentas

- **Alarme**: Alarme multilíngue, com capacidade de executar comandos externos, função soneca e muito mais.
- **Leitor de Markdown**: Um leitor aprimorado de marcação combinando formatação limpa com destaque de sintaxe opcional.
- **Calendário**: Calendário completo com suporte a feriados
- **Ferramentas de Video**: Gravador de tela e gerenciadores de videos
- **Ferramentas de Áudio**: Gerar frequências de áudio e gerenciares de som
- **Ferramentas de Processamento de Imagem**: Converter, redimensionar e manipular imagens
- **Gerenciamento de Temas**:
  - Temas do GRUB
  - Temas do Terminal
  - Coleções de arte ASCII
- **Utilitários de Cores**:
  - Paleta de cores ANSI
  - Conversor de Hex para ANSI
- **Ferramentas para Gerenciadores de Janelas**: Suporte para i3, awesome, openbox e outros
- **Integração com Ferramentas de Terceiros**: Incluindo scripts do ["Fred's Imagemagick"](http://www.fmwconcepts.com/imagemagick/index.php)

## 🚀 Instalação

### Opção 1: Instalação em Uma Linha
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/felipefacundes/shell_utils/refs/heads/main/install.sh)"
```

### Opção 2: Instalação Manual
```bash
git clone https://github.com/felipefacundes/shell_utils ~/.shell_utils
bash ~/.shell_utils/install.sh
```

## 🔄 Dependências

O instalador detecta automaticamente seu shell (fish, zsh ou bash) e instala as dependências necessárias:
- Para usuários bash: oh-my-bash
- Para usuários zsh: oh-my-zsh

## 🤝 Contribuindo

Contribuições são bem-vindas! Sinta-se à vontade para enviar um Pull Request. Para mudanças importantes, por favor, abra uma issue primeiro para discutir o que você gostaria de mudar.

## 📜 Licença

Este projeto está licenciado sob a Licença GPLv3 - consulte o arquivo [LICENSE](LICENSE) para obter detalhes.

## 👏 Créditos

- Criador original: [Felipe Facundes](https://github.com/felipefacundes)
- Agradecimentos especiais a todos os contribuidores e ao [Fred's Imagemagick](http://www.fmwconcepts.com/imagemagick/index.php) por alguns scripts incluídos

---

<div align="center">
  
**Feito com ❤️ pela comunidade Shell Utils**

[Reportar Bug](https://github.com/felipefacundes/shell_utils/issues) · [Solicitar Recurso](https://github.com/felipefacundes/shell_utils/issues)

</div>