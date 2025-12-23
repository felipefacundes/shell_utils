# Tutorial: Criar um Tema Vibrante e Legível para o Editor da Godot

Este tutorial ensina como aplicar um tema de cores vibrantes e legíveis no editor de texto da Godot, melhorando sua experiência de desenvolvimento.

## 📋 Pré-requisitos

- Godot Engine 4.x instalada
- Conhecimento básico de navegação em arquivos
- Editor de texto para editar arquivos de configuração

## 🎨 Sobre o Tema

O tema proposto utiliza:
- **Fundo escuro** (#242630) para reduzir fadiga ocular
- **Cores vibrantes** para melhor contraste e legibilidade
- **Espaçamento entre linhas** aumentado (6px) para melhor leitura
- Paleta otimizada para GDScript com cores específicas para diferentes elementos

## 🛠️ Método Recomendado: Script @tool (Automático e Reutilizável)

Esta é a opção mais eficiente, especialmente se você quiser reutilizar o tema ou aplicá-lo em múltiplas instalações.

### Passo 1: Criar a Estrutura do Projeto

1. Crie uma nova pasta em qualquer local (ex: `godot_theme_restore`)
2. Dentro dela, crie um arquivo chamado `project.godot` com este conteúdo:

```godot
[application]
config_version=5
run/main_scene="res://main.tscn"
```

### Passo 2: Criar a Cena Principal

1. Dentro da mesma pasta, crie um arquivo chamado `main.tscn` com este conteúdo:

```xml
[gd_scene load_steps=2 format=3 uid="uid://d1tomwsuk1eof"]

[ext_resource type="Script" uid="uid://xpk1fyw1ncie" path="res://main.gd" id="1_ig7tw"]

[node name="main" type="Node"]
script = ExtResource("1_ig7tw")
```

2. Crie um arquivo chamado `main.gd` na mesma pasta

### Passo 3: Adicionar o Script de Configuração

Cole o seguinte código no arquivo `main.gd`:

```gdscript
@tool
extends Node

func _enter_tree() -> void:
	var editor_settings = EditorInterface.get_editor_settings()
	print("🔄 Aplicando tema personalizado...")

	# Configurar espaçamento entre linhas
	editor_settings.set_setting("text_editor/theme/line_spacing", 6)

	# Definir todas as cores do tema
	var color_settings = {
		# Cores básicas
		"text_editor/theme/highlighting/symbol_color": Color.html("#abc9ff"),
		"text_editor/theme/highlighting/keyword_color": Color.html("#ff79c6"),
		"text_editor/theme/highlighting/control_flow_keyword_color": Color.html("#ff8ccc"),
		"text_editor/theme/highlighting/base_type_color": Color.html("#bb9af7"),
		"text_editor/theme/highlighting/engine_type_color": Color.html("#cad4a2"),
		"text_editor/theme/highlighting/user_type_color": Color.html("#c7ff1a"),
		
		# Comentários
		"text_editor/theme/highlighting/comment_color": Color.html("#d18200"),
		"text_editor/theme/highlighting/doc_comment_color": Color.html("#8099b3"),
		
		# Strings e números
		"text_editor/theme/highlighting/string_color": Color.html("#ffed00"),
		"text_editor/theme/highlighting/number_color": Color.html("#ffc599"),
		
		# Fundo e interface
		"text_editor/theme/highlighting/background_color": Color.html("#242630"),
		"text_editor/theme/highlighting/text_color": Color.html("#ffffff"),
		"text_editor/theme/highlighting/current_line_color": Color.html("#ffffff12"),
		
		# Números de linha
		"text_editor/theme/highlighting/line_number_color": Color.html("#c9cacd80"),
		"text_editor/theme/highlighting/safe_line_number_color": Color.html("#c9f2cdbf"),
		
		# Seleção e cursor
		"text_editor/theme/highlighting/caret_color": Color.html("#ffffff"),
		"text_editor/theme/highlighting/caret_background_color": Color.html("#000000"),
		"text_editor/theme/highlighting/selection_color": Color.html("#bd93f935"),
		"text_editor/theme/highlighting/text_selected_color": Color.html("#0ee6d05c"),
		
		# Funções e membros
		"text_editor/theme/highlighting/function_color": Color.html("#57b3ff"),
		"text_editor/theme/highlighting/member_variable_color": Color.html("#bce0ff"),
		
		# Depuração
		"text_editor/theme/highlighting/breakpoint_color": Color.html("#ff786b"),
		"text_editor/theme/highlighting/executing_line_color": Color.html("#ffff00"),
		
		# Busca e marcações
		"text_editor/theme/highlighting/search_result_color": Color.html("#ffffff12"),
		"text_editor/theme/highlighting/search_result_border_color": Color.html("#699ce861"),
		"text_editor/theme/highlighting/mark_color": Color.html("#ff786b4d"),
		"text_editor/theme/highlighting/bookmark_color": Color.html("#147dfa"),
		
		# Cores específicas do GDScript
		"text_editor/theme/highlighting/gdscript/function_definition_color": Color.html("#00dcdc"),
		"text_editor/theme/highlighting/gdscript/global_function_color": Color.html("#43e37b"),
		"text_editor/theme/highlighting/gdscript/node_path_color": Color.html("#b8c47d"),
		"text_editor/theme/highlighting/gdscript/node_reference_color": Color.html("#00f200"),
		"text_editor/theme/highlighting/gdscript/annotation_color": Color.html("#ffb311"),
		"text_editor/theme/highlighting/gdscript/string_name_color": Color.html("#ffc2a6"),
		
		# Auto-completar
		"text_editor/theme/highlighting/completion_background_color": Color.html("#282a36"),
		"text_editor/theme/highlighting/completion_selected_color": Color.html("#ffffff3b"),
		"text_editor/theme/highlighting/completion_existing_color": Color.html("#00ffff4c"),
		"text_editor/theme/highlighting/completion_font_color": Color.html("#c9cacd"),
		
		# Marcadores de comentário
		"text_editor/theme/highlighting/comment_markers/critical_color": Color.html("#ff0542"),
		"text_editor/theme/highlighting/comment_markers/warning_color": Color.html("#b89c7a"),
		"text_editor/theme/highlighting/comment_markers/notice_color": Color.html("#8fab82")
	}
	
	# Aplicar todas as configurações
	for setting_name in color_settings:
		editor_settings.set_setting(setting_name, color_settings[setting_name])
	
	# Salvar alterações
	editor_settings.notify_changes()
	print("✅ Tema aplicado com sucesso!")
	print("⚠️  Feche a Godot para que as alterações tenham efeito.")
	
	# Fechar automaticamente (opcional - remova se quiser manter aberto)
	get_tree().quit()
```

### Passo 4: Executar o Script

1. Abra o terminal/command prompt
2. Navegue até a pasta do projeto
3. Execute o comando:

```bash
# Linux/Mac
godot --path /caminho/para/sua/pasta --editor

# Windows (PowerShell)
godot --path "C:\caminho\para\sua\pasta" --editor
```

**O que acontece:**
- A Godot abrirá em modo editor
- O script será executado automaticamente
- As configurações serão aplicadas
- A Godot fechará automaticamente (se você deixou `get_tree().quit()`)

### Passo 5: Verificar o Resultado

1. Abra a Godot normalmente em qualquer projeto
2. Vá para **Editor → Editor Settings → Theme → Text Editor**
3. Confirme que as cores foram aplicadas
4. Abra qualquer script GDScript para ver o tema em ação

## 🔄 Reutilizando o Tema

Para reaplicar o tema no futuro ou em outra instalação:

1. Mantenha a pasta do projeto em um local seguro
2. Sempre que quiser restaurar o tema, execute o projeto com `--editor`
3. Ou copie a pasta para outro computador e repita o processo

## ⚙️ Personalização do Tema

Para modificar as cores:

1. Abra o arquivo `main.gd`
2. Localize a seção `color_settings`
3. Altere os valores hexadecimais (`#RRGGBB`) conforme desejar
4. Execute novamente o script

**Dicas para cores:**
- Use cores escuras para fundos
- Use cores claras/vibrantes para texto
- Mantenho bom contraste para legibilidade
- Teste sempre com código real

## 📁 Estrutura Final do Projeto

Seu projeto deve ter esta estrutura:

```
godot_theme_restore/
├── project.godot
├── main.tscn
└── main.gd
```

## 🆘 Solução de Problemas

**Problema:** As cores não foram aplicadas
- Solução: Certifique-se de que está executando com `--editor`
- Verifique se há erros no terminal

**Problema:** Godot não fecha automaticamente
- Solução: Isso é normal se você removeu `get_tree().quit()`
- Apenas feche manualmente após ver "Tema aplicado"

**Problema:** Cores parecem diferentes
- Solução: Algumas configurações do sistema podem afetar cores
- Ajuste manualmente no Editor Settings se necessário

## ✅ Comparação de Métodos

| Característica | Script @tool (Recomendado) |
|----------------|----------------------------|
| Complexidade | Média (configuração única) |
| Reutilização | Excelente (executa quando quiser) |
| Portabilidade | Ótima (copie a pasta) |
| Manutenção | Fácil (edite um arquivo) |
| Segurança | Alta (apenas configurações padrão) |

## 🎯 Conclusão

Este tema proporciona uma experiência de codificação mais agradável e menos fatigante na Godot. O método com script @tool é recomendado por ser reutilizável, fácil de manter e portável entre diferentes instalações ou computadores.

**Dica extra:** Considere criar um atalho/batch file para executar o script rapidamente sempre que precisar restaurar o tema!

Divirta-se programando com cores vibrantes! 🚀