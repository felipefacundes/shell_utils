## 📋 Documentation: Object Instantiation Methods in Godot

### Example Hierarchy
```
MainScene (Node2D) ← get_tree().current_scene
├── EnemyContainer (Node2D) ← get_parent() (if script is on Character)
│   ├── Marker1 (Marker2D)
│   ├── Marker2 (Marker2D)
│   └── Character (Node2D) ← self (where the script is)
│       ├── Sprite2D
│       └── damage_to_player (Area2D)
│           └── punch (CollisionShape2D) ← marker used for spawn
└── Other nodes...
```

---

### Method 1: `add_sibling(object)`
```gdscript
var object = OBJECT.instantiate()
object.global_position = marker.global_position
add_sibling(object)
```

**Where it instantiates:** At the same hierarchical level as the node containing the script (self).

**Resulting hierarchy:**
```
MainScene
├── EnemyContainer
│   ├── Marker1
│   ├── Marker2
│   ├── Character ← self (script is here)
│   └── 🪨 Stone ← instantiated here (sibling of Character)
└── ...
```

**Characteristics:**
- The stone stays inside the same container as the character
- Moves along with the `EnemyContainer` (inherits transformations)
- Useful for objects that need to maintain spatial relationship with the group

**⚠️ Issue:** If the `EnemyContainer` moves, the stone goes along with it, even after being instantiated.

---

### Method 2: `get_tree().current_scene.add_child(object)`
```gdscript
var object = OBJECT.instantiate()
object.global_position = marker.global_position
get_tree().current_scene.add_child(object)
```

**Where it instantiates:** Directly in the main scene (root of the tree).

**Resulting hierarchy:**
```
MainScene
├── EnemyContainer
│   ├── Marker1
│   ├── Marker2
│   └── Character
├── Other nodes...
└── 🪨 Stone ← instantiated here (child of main scene)
```

**Characteristics:**
- The stone is completely independent from the enemy's hierarchy
- `global_position` works perfectly
- Ideal for projectiles that should exist in the "world"
- Does not inherit transformations from any intermediate container
- ✅ **Recommended for projectiles and effects that need full independence**

---

### Method 3: `get_parent().add_sibling(object)`
```gdscript
var object = OBJECT.instantiate()
object.global_position = marker.global_position
get_parent().add_sibling(object)
```

**Where it instantiates:** At the same level as the parent of the node containing the script.

**Resulting hierarchy:**
```
MainScene
├── EnemyContainer ← get_parent() (parent of Character)
│   ├── Marker1
│   ├── Marker2
│   └── Character ← self
├── 🪨 Stone ← instantiated here (sibling of EnemyContainer)
└── ...
```

**Characteristics:**
- The stone stays outside the `EnemyContainer`, but still in the main scene
- Does not inherit movements from the enemy's container
- Global position works correctly
- Useful when you want the object "outside" the group, but still managed by the scene

---

### Method 4: Conversion with `to_local()` on the main scene
```gdscript
var main_scene = get_tree().current_scene
var object = OBJECT.instantiate()
object.global_position = main_scene.to_local(marker.global_position)
main_scene.add_child(object)
```

**Where it instantiates:** In the main scene, with explicit coordinate conversion.

**Resulting hierarchy:**
```
MainScene
├── EnemyContainer
│   ├── Marker1
│   ├── Marker2
│   └── Character
├── Other nodes...
└── 🪨 Stone ← instantiated here with converted position
```

**Characteristics:**
- Same location as Method 2, but with a different approach
- **Converts** the global position to the main scene's local coordinate system
- Useful when the main scene has transformations (scale, rotation, offset)
- More verbose, but gives explicit control over coordinates
- ⚠️ **Caution:** If `main_scene` has scale/rotation, the position is automatically adjusted

---

## 📊 Comparison Table

| Method | Instantiation Location | Inherits Container Movement | Independence | Recommended Use |
|--------|----------------------|------------------------------|---------------|-----------------|
| `add_sibling` | Sibling of script | ✅ Yes | Low | Objects that should follow the group |
| `current_scene.add_child` | Scene root | ❌ No | High | Projectiles, independent effects |
| `get_parent().add_sibling` | Sibling of parent | ❌ No | High | Objects outside group, but in scene |
| `to_local()` + add_child | Scene root (converted) | ❌ No | High | When main scene has transformations |

---

## 🎯 Final Recommendation

For **projectiles** (like stones): Use **Method 2** (`get_tree().current_scene.add_child`), because:
- Full movement independence
- Global coordinates work without conversion
- Simple and straightforward
- The projectile doesn't "travel along" if the enemy is removed/moved