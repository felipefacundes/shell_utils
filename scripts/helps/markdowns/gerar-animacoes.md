# Créditos: Felipe Facundes
# AnimationGenerate - Gerador de Animações para Godot 4.2+

**AnimationGenerate** é um script utilitário para Godot 4.2+ que permite criar animações programaticamente a partir de arrays de texturas, com suporte para salvar as animações como arquivos `.tres` para uso posterior.

## 📋 Recursos

- ✅ Cria animações a partir de arrays de texturas
- ✅ Compatível com Godot 4.2+ (AnimationLibrary)
- ✅ Salva animações como arquivos `.tres` reutilizáveis
- ✅ Suporte para diferentes tipos de nós (Sprite2D, TextureRect, AnimatedSprite2D)
- ✅ Configuração de duração, velocidade e snap
- ✅ Carregamento automático de texturas de diretórios

## 🚀 Instalação

1. **Copie o script** `animation_generate.gd` para seu projeto (ex: `res://scripts/singletons/`)
2. **Importe** no seu script principal:

```gdscript
const AnimationGenerate = preload("res://scripts/singletons/animation_generate.gd")
```

## 📖 Uso Básico

### Exemplo Simples

```gdscript
func _ready() -> void:
    # Instancia o helper
    var helper = AnimationGenerate.new()
    
    # Carrega texturas de um diretório
    var minhas_texturas = helper.carregar_texturas_do_diretorio("res://assets/animations/explosion")
    
    # Cria e salva a animação
    helper.criar_e_salvar_animacao(
        $AnimationPlayer,           # Seu AnimationPlayer
        minhas_texturas,            # Array de texturas
        "Explosion",                # Nome da animação
        3.5,                        # Duração total (segundos)
        1.2,                        # Velocidade (1.0 = normal)
        0.062222,                   # Snap (precisão dos keyframes)
        $Sprite2D,                  # Nó alvo (onde as texturas serão aplicadas)
        true                        # Salvar como arquivo .tres?
    )
    
    # Libera a memória
    helper.queue_free()
```

### Carregamento Manual de Texturas

```gdscript
func _ready() -> void:
    var helper = AnimationGenerate.new()
    
    # Array manual de texturas
    var texturas_manuais = [
        preload("res://sprites/frame_0001.png"),
        preload("res://sprites/frame_0002.png"),
        preload("res://sprites/frame_0003.png"),
        preload("res://sprites/frame_0004.png")
    ]
    
    helper.criar_e_salvar_animacao(
        $AnimationPlayer,
        texturas_manuais,
        "WalkCycle",
        0.8,       # 0.8 segundos para ciclo completo
        1.0,       # Velocidade normal
        0.0333,    # Snap padrão (30fps)
        $Character/Sprite2D,
        true
    )
    
    helper.queue_free()
```

## 🔧 Funções Principais

### `criar_e_salvar_animacao()`
Função principal que cria a animação no AnimationPlayer e salva como arquivo `.tres`.

**Parâmetros:**
- `animation_player`: AnimationPlayer - Nó AnimationPlayer de destino
- `texturas_array`: Array - Array de texturas (Texture2D)
- `nome_animacao`: String - Nome da animação (obrigatório)
- `tempo_animacao`: float = 1.0 - Duração total em segundos
- `velocidade`: float = 1.0 - Velocidade de reprodução (1.0 = normal)
- `snap`: float = 0.0333 - Precisão dos keyframes (0.0333 = 30fps)
- `no_alvo`: Node = null - Nó onde as texturas serão aplicadas
- `salvar_arquivo`: bool = true - Se deve salvar como arquivo `.tres`

### `carregar_texturas_do_diretorio()`
Carrega automaticamente todas as texturas PNG de um diretório.

```gdscript
var texturas = helper.carregar_texturas_do_diretorio("res://assets/effects/fire")
```

### `criar_animacao_rapida()`
Versão simplificada com valores padrão.

```gdscript
helper.criar_animacao_rapida(
    $AnimationPlayer,
    minhas_texturas,
    "Idle",
    $Sprite2D
)
```

### `reproduzir_com_velocidade()`
Reproduz uma animação com velocidade personalizada.

```gdscript
helper.reproduzir_com_velocidade($AnimationPlayer, "Explosion")
```

## 📁 Estrutura de Pastas

Recomenda-se organizar assim:
```
res://
├── assets/
│   ├── animations/          # Texturas para animações
│   │   ├── explosion/
│   │   │   ├── frame_0001.png
│   │   │   ├── frame_0002.png
│   │   │   └── ...
│   │   └── walk/
│   │       └── ...
│   └── sprites/
├── animations/              # Arquivos .tres gerados
│   ├── Explosion.tres
│   ├── WalkCycle.tres
│   └── ...
└── scripts/
    └── singletons/
        └── animation_generate.gd
```

## 🎯 Estrutura de Cena Recomendada

Para que os arquivos `.tres` funcionem corretamente (igual ao editor), organize sua cena assim:

```gdscript
# ESTRUTURA IDEAL:
MainScene (Node2D ou Control)
├── AnimationPlayer
└── Sprite2D  # ou TextureRect - DEVE SER IRMÃO do AnimationPlayer!
```

**Importante:** O nó alvo (Sprite2D/TextureRect) deve ser **irmão** do AnimationPlayer (mesmo nó pai) para que o caminho salvo no arquivo `.tres` seja apenas o nome do nó.

## 🔄 Fluxo de Trabalho

### 1. Desenvolvimento (Geração Dinâmica)
```gdscript
# Durante o desenvolvimento, gere dinamicamente
func _ready():
    var helper = AnimationGenerate.new()
    var texturas = helper.carregar_texturas_do_diretorio("res://assets/explosion")
    
    helper.criar_e_salvar_animacao(
        $AnimationPlayer, texturas, "Explosion", 3.5, 1.0, 0.062222, $Sprite2D, true
    )
    
    helper.queue_free()
```

### 2. Importação Manual
Após testar e ajustar os parâmetros:
1. Navegue até `res://animations/`
2. Arraste o arquivo `.tres` para o AnimationPlayer no editor
3. Configure manualmente se necessário

### 3. Produção (Código Limpo)
```gdscript
# Após importar, remova o código de geração
func _ready():
    # Apenas reproduza a animação já importada
    $AnimationPlayer.play("Explosion")
```

## ⚙️ Parâmetros Detalhados

### Snap (Precisão)
O snap define a precisão dos keyframes no tempo:
- `0.0333` = 30 FPS (padrão)
- `0.062222` = 16 FPS
- `0.016666` = 60 FPS

### Velocidade
- `1.0` = velocidade normal
- `1.5` = 50% mais rápido
- `0.75` = 25% mais lento

### Caminhos Relativos
Para diferentes estruturas de cena:

| Estrutura | Caminho Relativo Recomendado |
|-----------|-----------------------------|
| Irmãos: `AnimationPlayer` e `Sprite2D` | `"Sprite2D"` |
| AnimationPlayer é filho: `Container/AnimationPlayer` e `Sprite2D` | `"../Sprite2D"` |
| Sprite2D é filho: `AnimationPlayer` e `Container/Sprite2D` | `"Container/Sprite2D"` |

## 🐛 Solução de Problemas

### Erro: "couldn't resolve track"
**Sintoma:** Aviso no console sobre track não resolvido.
**Solução:** Verifique se o nó alvo existe e se o caminho está correto.

### Erro: Arquivo .tres com caminho absoluto
**Sintoma:** O arquivo salvo tem caminho como `root/Cena/Sprite2D:texture`
**Solução:** Use a função `criar_e_salvar_animacao()` que converte para nome simples.

### Animação não aparece no AnimationPlayer
**Solução:** Verifique se a AnimationLibrary foi criada:
```gdscript
# Após criar, liste as animações
helper.listar_animacoes($AnimationPlayer)
```

## 📝 Exemplos Completos

### Exemplo 1: Animação de Efeito
```gdscript
func criar_animacao_explosao():
    var helper = AnimationGenerate.new()
    
    # Carrega 12 frames de explosão
    var frames_explosao = []
    for i in range(1, 13):
        var frame = load("res://effects/explosion/explosion_%04d.png" % i)
        if frame:
            frames_explosao.append(frame)
    
    helper.criar_e_salvar_animacao(
        $Effects/AnimationPlayer,
        frames_explosao,
        "BigExplosion",
        1.5,        # 1.5 segundos de duração
        1.0,        # Velocidade normal
        0.041667,   # 24 FPS
        $Effects/ExplosionSprite,
        true
    )
    
    helper.queue_free()
```

### Exemplo 2: UI Animation
```gdscript
func criar_animacao_ui():
    var helper = AnimationGenerate.new()
    
    var frames_loading = helper.carregar_texturas_do_diretorio("res://ui/loading")
    
    helper.criar_e_salvar_animacao(
        $UI/AnimationPlayer,
        frames_loading,
        "LoadingSpinner",
        2.0,        # 2 segundos por rotação
        1.0,
        0.0333,
        $UI/LoadingIcon,
        true
    )
    
    helper.queue_free()
```

## 🎮 Reprodução e Controle

```gdscript
# Reproduzir animação
$AnimationPlayer.play("Explosion")

# Reproduzir com velocidade personalizada
var helper = AnimationGenerate.new()
helper.reproduzir_com_velocidade($AnimationPlayer, "Explosion")
helper.queue_free()

# Verificar se animação existe
if helper.verificar_animacao($AnimationPlayer, "Explosion"):
    print("Animação pronta!")
```

## 💡 Dicas

1. **Durante desenvolvimento:** Use `salvar_arquivo = true` para gerar arquivos `.tres`
2. **Na versão final:** Importe os `.tres` e remova o código de geração
3. **Para performance:** Pré-carregue texturas se forem muitas
4. **Organização:** Use nomes consistentes para animações e arquivos
5. **Backup:** Mantenha as texturas originais na pasta `assets/`

## 📄 Licença

Este script é de domínio público. Sinta-se livre para modificar e distribuir.

---

**Nota:** Este script foi otimizado para Godot 4.2+ usando o novo sistema de AnimationLibrary. Para versões anteriores do Godot 4, ajustes podem ser necessários.

```gdscript
#!/bin/python # Esse shebang está sendo usado apenas para gerar syntax hightlight no markdown-reader
extends Node
# Script utilitário para gerar animações - SEM class_name

# Como usar, no script em que vai gerar animação instancie esse script assim:
"""
const AnimationGenerate = preload("res://scripts/singletons/gerar_animacoes.gd")
		
func _ready() -> void:
	var helper = AnimationGenerate.new()
	var minhas_texturas = helper.carregar_texturas_do_diretorio("res://assets/intro_video/Animation Intro")
	
	# Apenas uma chamada é necessária agora
	helper.criar_e_salvar_animacao(
		anim,                  # Seu AnimationPlayer
		minhas_texturas,       # Array de texturas
		"Animation",           # Nome da animação
		14,                    # Tempo total: 14 segundos
		1.2,                   # Velocidade: 1.2x
		0.062222,              # Snap personalizado
		$TextureRect           # Nó alvo DIRETO (Sprite2D, TextureRect, etc.)
	)
"""

func criar_animacao_sprite(
	animation_player: AnimationPlayer,
	texturas_array: Array,
	nome_animacao: String,
	tempo_animacao: float = 1.0,
	velocidade: float = 1.0,
	snap: float = 0.0333,
	caminho_sprite: String = "../Sprite2D"
) -> void:

	# 1. Obter ou criar a AnimationLibrary principal
	var biblioteca: AnimationLibrary
	# Tenta obter a biblioteca global (chave vazia "")
	biblioteca = animation_player.get_animation_library("")
	# Se não existir, cria uma nova
	if biblioteca == null:
		biblioteca = AnimationLibrary.new()
		# Adiciona a nova biblioteca ao AnimationPlayer com uma chave vazia
		var resultado = animation_player.add_animation_library("", biblioteca)
		if resultado != OK:
			push_error("Falha ao criar AnimationLibrary!")
			return

	# 2. Criar a animação (seu código existente)
	var animacao = Animation.new()
	animacao.length = tempo_animacao

	var track_idx = animacao.add_track(Animation.TYPE_VALUE)
	animacao.track_set_path(track_idx, caminho_sprite + ":texture")
	animacao.value_track_set_update_mode(track_idx, Animation.UPDATE_DISCRETE)

	var tempo_por_frame = tempo_animacao / texturas_array.size()
	
	for i in range(texturas_array.size()):
		var tempo_frame = i * tempo_por_frame
		if snap > 0:
			tempo_frame = snapped(tempo_frame, snap)
		animacao.track_insert_key(track_idx, tempo_frame, texturas_array[i])
	
	animacao.set_step(snap)

	# 3. Adicionar a animação à BIBLIOTECA, não diretamente ao player[citation:3][citation:8]
	biblioteca.add_animation(nome_animacao, animacao)

	# 4. Armazenar velocidade (seu código existente)
	if velocidade != 1.0:
		animacao.set_meta("velocidade_personalizada", velocidade)

	print("✅ Animação '%s' criada na biblioteca principal." % nome_animacao)

func criar_animacao_sprite_facil(
	animation_player: AnimationPlayer,
	texturas_array: Array,
	nome_animacao: String,
	tempo_animacao: float = 1.0,
	velocidade: float = 1.0,
	snap: float = 0.0333,
	no_alvo: Node = null
) -> void:
	"""
	Versão corrigida para Godot 4.2+
	"""
	
	if not no_alvo:
		push_error("Nó alvo não fornecido!")
		return
	
	# 1. Obtém o caminho absoluto do nó alvo
	var caminho_absoluto = no_alvo.get_path()
	
	# 2. Obtém o caminho do AnimationPlayer
	var caminho_player = animation_player.get_path()
	
	# 3. Converte caminho absoluto para relativo ao player
	var caminho_relativo = str(caminho_absoluto).replace(str(caminho_player) + "/", "")
	
	print("Debug - Caminho calculado:")
	print("  Absoluto: ", caminho_absoluto)
	print("  Player: ", caminho_player)
	print("  Relativo: ", caminho_relativo)
	
	# 4. Chama a função de criação
	criar_animacao_sprite(
		animation_player,
		texturas_array,
		nome_animacao,
		tempo_animacao,
		velocidade,
		snap,
		caminho_relativo
	)

# Funções auxiliares
func criar_animacao_rapida(
	animation_player: AnimationPlayer,
	texturas: Array,
	nome: String,
	no_alvo: Node
) -> void:
	"""Versão simplificada com defaults"""
	criar_animacao_sprite_facil(
		animation_player,
		texturas,
		nome,
		1.0,      # tempo padrão
		1.0,      # velocidade padrão
		0.0333,   # snap padrão
		no_alvo
	)

func carregar_texturas_do_diretorio(diretorio: String) -> Array:
	"""
	Carrega texturas de um diretório
	"""
	var texturas: Array = []
	var dir = DirAccess.open(diretorio)
	
	if not dir:
		push_error("Diretório não encontrado: " + diretorio)
		return texturas
	
	# Lista arquivos PNG
	var arquivos: PackedStringArray = []
	dir.list_dir_begin()
	var nome_arquivo = dir.get_next()
	
	while nome_arquivo != "":
		if nome_arquivo.ends_with(".png") and not nome_arquivo.begins_with("."):
			arquivos.append(nome_arquivo)
		nome_arquivo = dir.get_next()
	
	dir.list_dir_end()
	
	# Ordena
	arquivos.sort()
	
	# Carrega as texturas
	for arquivo in arquivos:
		var caminho_completo = diretorio + "/" + arquivo
		var textura = load(caminho_completo)
		if textura and textura is Texture2D:
			texturas.append(textura)
		else:
			print("⚠️  Não pôde carregar: " + caminho_completo)
	
	print("📁 Carregadas %d texturas de %s" % [texturas.size(), diretorio])
	return texturas

func reproduzir_com_velocidade(
	animation_player: AnimationPlayer,
	nome_animacao: String
) -> void:
	"""
	Reproduz animação com velocidade personalizada
	"""
	if not animation_player.has_animation(nome_animacao):
		push_error("Animação '%s' não encontrada!" % nome_animacao)
		return
	
	var animacao = animation_player.get_animation(nome_animacao)
	if animacao and animacao.has_meta("velocidade_personalizada"):
		var velocidade = animacao.get_meta("velocidade_personalizada")
		animation_player.playback_speed = velocidade
		print("🎬 Reproduzindo '%s' com velocidade %.2fx" % [nome_animacao, velocidade])
	else:
		animation_player.playback_speed = 1.0
		print("🎬 Reproduzindo '%s' com velocidade normal" % nome_animacao)
	
	animation_player.play(nome_animacao)

# Função extra para verificar se animação existe
func verificar_animacao(animation_player: AnimationPlayer, nome_animacao: String) -> bool:
	"""Verifica se uma animação existe"""
	var existe = animation_player.has_animation(nome_animacao)
	print("❓ Animação '%s' existe? %s" % [nome_animacao, "✅ Sim" if existe else "❌ Não"])
	return existe

# Função para listar todas as animações
func listar_animacoes(animation_player: AnimationPlayer) -> void:
	"""Lista todas as animações no AnimationPlayer"""
	print("📋 Animações disponíveis:")
	var animacoes = animation_player.get_animation_list()
	for anim in animacoes:
		print("  - " + anim)

#region Salvar as animações

func salvar_animacao_em_arquivo(
	texturas_array: Array,
	nome_animacao: String,
	tempo_animacao: float = 1.0,
	snap: float = 0.0333,
	caminho_relativo: String = "../Sprite2D",  # AGORA: caminho relativo
	pasta_destino: String = "res://animations/"
) -> bool:
	"""
	Salva animação com caminho RELATIVO para ser reutilizável
	"""
	
	if texturas_array.size() == 0:
		push_error("Array de texturas vazio!")
		return false
	
	# Cria a animação
	var animacao = Animation.new()
	animacao.length = tempo_animacao
	
	# IMPORTANTE: Usa caminho relativo fornecido
	var track_idx = animacao.add_track(Animation.TYPE_VALUE)
	animacao.track_set_path(track_idx, caminho_relativo + ":texture")
	animacao.value_track_set_update_mode(track_idx, Animation.UPDATE_DISCRETE)
	
	# Adiciona keyframes
	var tempo_por_frame = tempo_animacao / texturas_array.size()
	
	for i in range(texturas_array.size()):
		var tempo_frame = i * tempo_por_frame
		if snap > 0:
			tempo_frame = snapped(tempo_frame, snap)
		animacao.track_insert_key(track_idx, tempo_frame, texturas_array[i])
	
	animacao.set_step(snap)
	
	# Cria pasta se não existir
	var dir = DirAccess.open(pasta_destino)
	if not dir:
		DirAccess.make_dir_absolute(pasta_destino)
	
	# Salva
	var caminho_arquivo = pasta_destino + nome_animacao + ".tres"
	var resultado = ResourceSaver.save(animacao, caminho_arquivo)
	
	if resultado == OK:
		print("💾 Animação salva: " + caminho_arquivo)
		print("   Caminho track: " + caminho_relativo + ":texture")
		return true
	else:
		push_error("Erro ao salvar! Código: " + str(resultado))
		return false

func criar_e_salvar_animacao(
	animation_player: AnimationPlayer,
	texturas_array: Array,
	nome_animacao: String,
	tempo_animacao: float = 1.0,
	velocidade: float = 1.0,
	snap: float = 0.0333,
	no_alvo: Node = null,
	salvar_arquivo: bool = true
) -> void:
	"""
	SOLUÇÃO DEFINITIVA: Salva com caminho igual ao editor
	"""
	
	if not no_alvo:
		push_error("Nó alvo não fornecido!")
		return
	
	# 1. Obtém o nome SIMPLES do nó alvo
	var nome_no_alvo = no_alvo.name
	
	print("🔍 Debug - Nome do nó alvo: " + nome_no_alvo)
	
	# 2. Cria animação no AnimationPlayer (para funcionar agora)
	#    Primeiro, precisamos do caminho relativo para funcionar na execução
	var caminho_para_execucao = calcular_caminho_relativo_simples(animation_player, no_alvo)
	
	print("🔍 Debug - Caminho para execução: " + caminho_para_execucao)
	
	criar_animacao_sprite(
		animation_player,
		texturas_array,
		nome_animacao,
		tempo_animacao,
		velocidade,
		snap,
		caminho_para_execucao
	)
	
	# 3. Salva como arquivo APENAS COM O NOME DO NÓ (igual ao editor)
	if salvar_arquivo:
		# IMPORTANTE: Para o arquivo .tres, usa APENAS o nome do nó
		salvar_animacao_com_nome_simples(
			texturas_array,
			nome_animacao,
			tempo_animacao,
			snap,
			nome_no_alvo  # APENAS O NOME, sem caminho
		)

func calcular_caminho_relativo_simples(animation_player: AnimationPlayer, no_alvo: Node) -> String:
	"""
	Calcula caminho relativo SIMPLES: apenas o nome ou ../nome
	VERSÃO CORRIGIDA - sem get_nameslice
	"""
	
	# Verifica se estão no mesmo nível (irmãos)
	if animation_player.get_parent() == no_alvo.get_parent():
		# São irmãos - usa apenas o nome
		return no_alvo.name
	else:
		# Usa uma abordagem mais simples
		var caminho_relativo = animation_player.get_path_to(no_alvo)
		var caminho_str = str(caminho_relativo)
		
		# Se já começar com ../, está correto
		if caminho_str.begins_with("../"):
			return caminho_str
		
		# Se não começar com ../, mas tiver "/", converte
		if caminho_str.contains("/") and not caminho_str.begins_with("/"):
			# Já é um caminho relativo (mas não começa com ../)
			# Pode ser algo como "pai/filho"
			return caminho_str
		
		# Para caminhos absolutos, converte para relativo manualmente
		if caminho_str.begins_with("/"):
			return converter_caminho_absoluto_para_relativo(animation_player, no_alvo)
		
		return caminho_str

func converter_caminho_absoluto_para_relativo(animation_player: AnimationPlayer, no_alvo: Node) -> String:
	"""
	Converte caminho absoluto para relativo manualmente
	"""
	var caminho_player = str(animation_player.get_path())
	var caminho_alvo = str(no_alvo.get_path())
	
	# Divide os caminhos em partes
	var partes_player = caminho_player.split("/")
	var partes_alvo = caminho_alvo.split("/")
	
	# Remove elementos vazios
	partes_player = partes_player.filter(func(p): return p != "")
	partes_alvo = partes_alvo.filter(func(p): return p != "")
	
	# Encontra o ponto em que os caminhos divergem
	var i = 0
	while i < min(partes_player.size(), partes_alvo.size()):
		if partes_player[i] != partes_alvo[i]:
			break
		i += 1
	
	# Constrói o caminho relativo
	var resultado = ""
	
	# Quantos níveis precisa subir
	var niveis_subir = partes_player.size() - i
	for j in range(niveis_subir):
		resultado += "../"
	
	# Adiciona o caminho para descer
	for j in range(i, partes_alvo.size()):
		resultado += partes_alvo[j]
		if j < partes_alvo.size() - 1:
			resultado += "/"
	
	return resultado

func salvar_animacao_com_nome_simples(
	texturas_array: Array,
	nome_animacao: String,
	tempo_animacao: float = 1.0,
	snap: float = 0.0333,
	nome_no_alvo: String = "Sprite2D",  # AGORA: APENAS O NOME
	pasta_destino: String = "res://animations/"
) -> bool:
	"""
	Salva animação usando APENAS o nome do nó (igual ao editor)
	"""
	
	if texturas_array.size() == 0:
		push_error("Array de texturas vazio!")
		return false
	
	# Cria a animação
	var animacao = Animation.new()
	animacao.length = tempo_animacao
	
	# IMPORTANTE: Usa APENAS o nome do nó
	var track_idx = animacao.add_track(Animation.TYPE_VALUE)
	animacao.track_set_path(track_idx, nome_no_alvo + ":texture")
	animacao.value_track_set_update_mode(track_idx, Animation.UPDATE_DISCRETE)
	
	# Adiciona keyframes
	var tempo_por_frame = tempo_animacao / texturas_array.size()
	
	for i in range(texturas_array.size()):
		var tempo_frame = i * tempo_por_frame
		if snap > 0:
			tempo_frame = snapped(tempo_frame, snap)
		animacao.track_insert_key(track_idx, tempo_frame, texturas_array[i])
	
	animacao.set_step(snap)
	
	# Cria pasta
	var dir = DirAccess.open(pasta_destino)
	if not dir:
		DirAccess.make_dir_absolute(pasta_destino)
	
	# Salva
	var caminho_arquivo = pasta_destino + nome_animacao + ".tres"
	var resultado = ResourceSaver.save(animacao, caminho_arquivo)
	
	if resultado == OK:
		print("✅ ARQUIVO SALVO COM SUCESSO!")
		print("   Caminho: " + caminho_arquivo)
		print("   Track: " + nome_no_alvo + ":texture  ← IGUAL AO EDITOR!")
		return true
	else:
		push_error("Erro ao salvar!")
		return false

```