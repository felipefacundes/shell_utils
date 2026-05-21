## 📋 Documentação: Métodos de Instanciação de Objetos no Godot

### Hierarquia de Exemplo
```
MainScene (Node2D) ← get_tree().current_scene
├── EnemyContainer (Node2D) ← get_parent() (se script está no Personagem)
│   ├── Marker1 (Marker2D)
│   ├── Marker2 (Marker2D)
│   └── Personagem (Node2D) ← self (onde o script está)
│       ├── Sprite2D
│       └── damage_to_player (Area2D)
│           └── punch (CollisionShape2D) ← marker usado para spawn
└── Outros nós...
```

---

### Método 1: `add_sibling(objeto)`
```gdscript
var objeto = OBJETO.instantiate()
objeto.global_position = marker.global_position
add_sibling(objeto)
```

**Onde instancia:** No mesmo nível hierárquico do nó que contém o script (self).

**Hierarquia resultante:**
```
MainScene
├── EnemyContainer
│   ├── Marker1
│   ├── Marker2
│   ├── Personagem ← self (script está aqui)
│   └── 🪨 Pedra ← instanciada aqui (irmã do Personagem)
└── ...
```

**Características:**
- A pedra fica dentro do mesmo contêiner que o personagem
- Se move junto com o `EnemyContainer` (herda transformações)
- Útil para objetos que precisam manter relação espacial com o grupo

**⚠️ Problema:** Se o `EnemyContainer` se mover, a pedra vai junto, mesmo após instanciada.

---

### Método 2: `get_tree().current_scene.add_child(objeto)`
```gdscript
var objeto = OBJETO.instantiate()
objeto.global_position = marker.global_position
get_tree().current_scene.add_child(objeto)
```

**Onde instancia:** Diretamente na cena principal (raiz da árvore).

**Hierarquia resultante:**
```
MainScene
├── EnemyContainer
│   ├── Marker1
│   ├── Marker2
│   └── Personagem
├── Outros nós...
└── 🪨 Pedra ← instanciada aqui (filha da cena principal)
```

**Características:**
- A pedra é completamente independente da hierarquia do inimigo
- `global_position` funciona perfeitamente
- Ideal para projéteis que devem existir no "mundo"
- Não herda transformações de nenhum contêiner intermediário
- ✅ **Recomendado para projéteis e efeitos que precisam de independência total**

---

### Método 3: `get_parent().add_sibling(objeto)`
```gdscript
var objeto = OBJETO.instantiate()
objeto.global_position = marker.global_position
get_parent().add_sibling(objeto)
```

**Onde instancia:** No mesmo nível do pai do nó que contém o script.

**Hierarquia resultante:**
```
MainScene
├── EnemyContainer ← get_parent() (pai do Personagem)
│   ├── Marker1
│   ├── Marker2
│   └── Personagem ← self
├── 🪨 Pedra ← instanciada aqui (irmã do EnemyContainer)
└── ...
```

**Características:**
- A pedra fica fora do `EnemyContainer`, mas ainda na cena principal
- Não herda movimentos do contêiner do inimigo
- Posição global funciona corretamente
- Útil quando você quer o objeto "fora" do grupo, mas ainda gerenciado pela cena

---

### Método 4: Conversão com `to_local()` na cena principal
```gdscript
var main_scene = get_tree().current_scene
var objeto = OBJETO.instantiate()
objeto.global_position = main_scene.to_local(marker.global_position)
main_scene.add_child(objeto)
```

**Onde instancia:** Na cena principal, com conversão explícita de coordenadas.

**Hierarquia resultante:**
```
MainScene
├── EnemyContainer
│   ├── Marker1
│   ├── Marker2
│   └── Personagem
├── Outros nós...
└── 🪨 Pedra ← instanciada aqui com posição convertida
```

**Características:**
- Mesmo local do Método 2, mas com abordagem diferente
- **Converte** a posição global para o sistema de coordenadas local da cena
- Útil quando a cena principal tem transformações (escala, rotação, offset)
- Mais verboso, mas dá controle explícito sobre coordenadas
- ⚠️ **Cuidado:** Se `main_scene` tiver escala/rotação, a posição é ajustada automaticamente

---

## 📊 Tabela Comparativa

| Método | Local de Instanciação | Herda Movimento do Contêiner | Independência | Uso Recomendado |
|--------|----------------------|------------------------------|---------------|-----------------|
| `add_sibling` | Irmão do script | ✅ Sim | Baixa | Objetos que devem seguir o grupo |
| `current_scene.add_child` | Raiz da cena | ❌ Não | Alta | Projéteis, efeitos independentes |
| `get_parent().add_sibling` | Irmão do pai | ❌ Não | Alta | Objetos fora do grupo, mas na cena |
| `to_local()` + add_child | Raiz da cena (convertido) | ❌ Não | Alta | Quando cena principal tem transformações |

---

## 🎯 Recomendação Final

Para **projéteis** (como pedras): Use o **Método 2** (`get_tree().current_scene.add_child`), pois:
- Independência total do movimento
- Coordenadas globais funcionam sem conversão
- Simples e direto
- O projétil não "viaja" junto se o inimigo for removido/ movido