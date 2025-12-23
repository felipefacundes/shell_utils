# Credits: Felipe Facundes
# AnimationGenerate - Animation Generator for Godot 4.2+

**AnimationGenerate** is a utility script for Godot 4.2+ that allows creating animations programmatically from texture arrays, with support for saving animations as `.tres` files for later use.

## 📋 Features

- ✅ Creates animations from texture arrays
- ✅ Compatible with Godot 4.2+ (AnimationLibrary)
- ✅ Saves animations as reusable `.tres` files
- ✅ Support for different node types (Sprite2D, TextureRect, AnimatedSprite2D)
- ✅ Duration, speed, and snap configuration
- ✅ Automatic texture loading from directories

## 🚀 Installation

1. **Copy the script** `animation_generate.gd` to your project (ex: `res://scripts/singletons/`)
2. **Import** it in your main script:

```gdscript
const AnimationGenerate = preload("res://scripts/singletons/animation_generate.gd")
```

## 📖 Basic Usage

### Simple Example

```gdscript
func _ready() -> void:
    # Instantiate the helper
    var helper = AnimationGenerate.new()
    
    # Load textures from a directory
    var my_textures = helper.load_textures_from_directory("res://assets/animations/explosion")
    
    # Create and save the animation
    helper.create_and_save_animation(
        $AnimationPlayer,           # Your AnimationPlayer
        my_textures,                # Array of textures
        "Explosion",                # Animation name
        3.5,                        # Total duration (seconds)
        1.2,                        # Speed (1.0 = normal)
        0.062222,                   # Snap (keyframe precision)
        $Sprite2D,                  # Target node (where textures will be applied)
        true                        # Save as .tres file?
    )
    
    # Free memory
    helper.queue_free()
```

### Manual Texture Loading

```gdscript
func _ready() -> void:
    var helper = AnimationGenerate.new()
    
    # Manual texture array
    var manual_textures = [
        preload("res://sprites/frame_0001.png"),
        preload("res://sprites/frame_0002.png"),
        preload("res://sprites/frame_0003.png"),
        preload("res://sprites/frame_0004.png")
    ]
    
    helper.create_and_save_animation(
        $AnimationPlayer,
        manual_textures,
        "WalkCycle",
        0.8,       # 0.8 seconds for complete cycle
        1.0,       # Normal speed
        0.0333,    # Default snap (30fps)
        $Character/Sprite2D,
        true
    )
    
    helper.queue_free()
```

## 🔧 Main Functions

### `create_and_save_animation()`
Main function that creates the animation in the AnimationPlayer and saves it as a `.tres` file.

**Parameters:**
- `animation_player`: AnimationPlayer - Target AnimationPlayer node
- `textures_array`: Array - Array of textures (Texture2D)
- `animation_name`: String - Animation name (required)
- `animation_time`: float = 1.0 - Total duration in seconds
- `speed`: float = 1.0 - Playback speed (1.0 = normal)
- `snap`: float = 0.0333 - Keyframe precision (0.0333 = 30fps)
- `target_node`: Node = null - Node where textures will be applied
- `save_file`: bool = true - Whether to save as `.tres` file

### `load_textures_from_directory()`
Automatically loads all PNG textures from a directory.

```gdscript
var textures = helper.load_textures_from_directory("res://assets/effects/fire")
```

### `create_quick_animation()`
Simplified version with default values.

```gdscript
helper.create_quick_animation(
    $AnimationPlayer,
    my_textures,
    "Idle",
    $Sprite2D
)
```

### `play_with_speed()`
Plays an animation with custom speed.

```gdscript
helper.play_with_speed($AnimationPlayer, "Explosion")
```

## 📁 Folder Structure

Recommended organization:
```
res://
├── assets/
│   ├── animations/          # Textures for animations
│   │   ├── explosion/
│   │   │   ├── frame_0001.png
│   │   │   ├── frame_0002.png
│   │   │   └── ...
│   │   └── walk/
│   │       └── ...
│   └── sprites/
├── animations/              # Generated .tres files
│   ├── Explosion.tres
│   ├── WalkCycle.tres
│   └── ...
└── scripts/
    └── singletons/
        └── animation_generate.gd
```

## 🎯 Recommended Scene Structure

For `.tres` files to work correctly (same as the editor), organize your scene like this:

```gdscript
# IDEAL STRUCTURE:
MainScene (Node2D or Control)
├── AnimationPlayer
└── Sprite2D  # or TextureRect - MUST BE SIBLING of AnimationPlayer!
```

**Important:** The target node (Sprite2D/TextureRect) must be a **sibling** of the AnimationPlayer (same parent node) so that the path saved in the `.tres` file is just the node name.

## 🔄 Workflow

### 1. Development (Dynamic Generation)
```gdscript
# During development, generate dynamically
func _ready():
    var helper = AnimationGenerate.new()
    var textures = helper.load_textures_from_directory("res://assets/explosion")
    
    helper.create_and_save_animation(
        $AnimationPlayer, textures, "Explosion", 3.5, 1.0, 0.062222, $Sprite2D, true
    )
    
    helper.queue_free()
```

### 2. Manual Import
After testing and adjusting parameters:
1. Navigate to `res://animations/`
2. Drag the `.tres` file to the AnimationPlayer in the editor
3. Configure manually if needed

### 3. Production (Clean Code)
```gdscript
# After importing, remove the generation code
func _ready():
    # Just play the already imported animation
    $AnimationPlayer.play("Explosion")
```

## ⚙️ Detailed Parameters

### Snap (Precision)
Snap defines keyframe precision in time:
- `0.0333` = 30 FPS (default)
- `0.062222` = 16 FPS
- `0.016666` = 60 FPS

### Speed
- `1.0` = normal speed
- `1.5` = 50% faster
- `0.75` = 25% slower

### Relative Paths
For different scene structures:

| Structure | Recommended Relative Path |
|-----------|---------------------------|
| Siblings: `AnimationPlayer` and `Sprite2D` | `"Sprite2D"` |
| AnimationPlayer is child: `Container/AnimationPlayer` and `Sprite2D` | `"../Sprite2D"` |
| Sprite2D is child: `AnimationPlayer` and `Container/Sprite2D` | `"Container/Sprite2D"` |

## 🐛 Troubleshooting

### Error: "couldn't resolve track"
**Symptom:** Console warning about unresolved track.
**Solution:** Check if the target node exists and if the path is correct.

### Error: .tres file with absolute path
**Symptom:** The saved file has a path like `root/Scene/Sprite2D:texture`
**Solution:** Use the `create_and_save_animation()` function that converts to simple name.

### Animation doesn't appear in AnimationPlayer
**Solution:** Check if the AnimationLibrary was created:
```gdscript
# After creating, list animations
helper.list_animations($AnimationPlayer)
```

## 📝 Complete Examples

### Example 1: Effect Animation
```gdscript
func create_explosion_animation():
    var helper = AnimationGenerate.new()
    
    # Load 12 explosion frames
    var explosion_frames = []
    for i in range(1, 13):
        var frame = load("res://effects/explosion/explosion_%04d.png" % i)
        if frame:
            explosion_frames.append(frame)
    
    helper.create_and_save_animation(
        $Effects/AnimationPlayer,
        explosion_frames,
        "BigExplosion",
        1.5,        # 1.5 seconds duration
        1.0,        # Normal speed
        0.041667,   # 24 FPS
        $Effects/ExplosionSprite,
        true
    )
    
    helper.queue_free()
```

### Example 2: UI Animation
```gdscript
func create_ui_animation():
    var helper = AnimationGenerate.new()
    
    var loading_frames = helper.load_textures_from_directory("res://ui/loading")
    
    helper.create_and_save_animation(
        $UI/AnimationPlayer,
        loading_frames,
        "LoadingSpinner",
        2.0,        # 2 seconds per rotation
        1.0,
        0.0333,
        $UI/LoadingIcon,
        true
    )
    
    helper.queue_free()
```

## 🎮 Playback and Control

```gdscript
# Play animation
$AnimationPlayer.play("Explosion")

# Play with custom speed
var helper = AnimationGenerate.new()
helper.play_with_speed($AnimationPlayer, "Explosion")
helper.queue_free()

# Check if animation exists
if helper.check_animation($AnimationPlayer, "Explosion"):
    print("Animation ready!")
```

## 💡 Tips

1. **During development:** Use `save_file = true` to generate `.tres` files
2. **In final version:** Import `.tres` files and remove generation code
3. **For performance:** Preload textures if there are many
4. **Organization:** Use consistent names for animations and files
5. **Backup:** Keep original textures in the `assets/` folder

## 📄 License

This script is public domain. Feel free to modify and distribute.

---

**Note:** This script has been optimized for Godot 4.2+ using the new AnimationLibrary system. For earlier versions of Godot 4, adjustments may be necessary.

```gdscript
#!/bin/python # This shebang is only being used to generate hightlight syntax in markdown-reader
extends Node
# Utility script for generating animations - WITHOUT class_name

# How to use, in the script where you will generate animation, instance this script like this:
"""
const AnimationGenerate = preload("res://scripts/singletons/animation_generate.gd")
		
func _ready() -> void:
	var helper = AnimationGenerate.new()
	var my_textures = helper.load_textures_from_directory("res://assets/intro_video/Animation Intro")
	
	# Only one call is needed now
	helper.create_and_save_animation(
		anim,                  # Your AnimationPlayer
		my_textures,           # Array of textures
		"Animation",           # Animation name
		14,                    # Total time: 14 seconds
		1.2,                   # Speed: 1.2x
		0.062222,              # Custom snap
		$TextureRect           # DIRECT target node (Sprite2D, TextureRect, etc.)
	)
"""

func create_sprite_animation(
	animation_player: AnimationPlayer,
	textures_array: Array,
	animation_name: String,
	animation_time: float = 1.0,
	speed: float = 1.0,
	snap: float = 0.0333,
	sprite_path: String = "../Sprite2D"
) -> void:

	# ... (initial validations remain the same) ...

	# 1. Get or create the main AnimationLibrary
	var library: AnimationLibrary
	# Try to get the global library (empty key "")
	library = animation_player.get_animation_library("")
	# If it doesn't exist, create a new one
	if library == null:
		library = AnimationLibrary.new()
		# Add the new library to AnimationPlayer with an empty key
		var result = animation_player.add_animation_library("", library)
		if result != OK:
			push_error("Failed to create AnimationLibrary!")
			return

	# 2. Create the animation (your existing code)
	var animation = Animation.new()
	animation.length = animation_time

	var track_idx = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_idx, sprite_path + ":texture")
	animation.value_track_set_update_mode(track_idx, Animation.UPDATE_DISCRETE)

	var time_per_frame = animation_time / textures_array.size()
	
	for i in range(textures_array.size()):
		var frame_time = i * time_per_frame
		if snap > 0:
			frame_time = snapped(frame_time, snap)
		animation.track_insert_key(track_idx, frame_time, textures_array[i])
	
	animation.set_step(snap)

	# 3. Add the animation to the LIBRARY, not directly to the player
	library.add_animation(animation_name, animation)

	# 4. Store speed (your existing code)
	if speed != 1.0:
		animation.set_meta("custom_speed", speed)

	print("✅ Animation '%s' created in main library." % animation_name)

func create_sprite_animation_easy(
	animation_player: AnimationPlayer,
	textures_array: Array,
	animation_name: String,
	animation_time: float = 1.0,
	speed: float = 1.0,
	snap: float = 0.0333,
	target_node: Node = null
) -> void:
	"""
	Fixed version for Godot 4.2+
	"""
	
	if not target_node:
		push_error("Target node not provided!")
		return
	
	# 1. Get the absolute path of the target node
	var absolute_path = target_node.get_path()
	
	# 2. Get the AnimationPlayer path
	var player_path = animation_player.get_path()
	
	# 3. Convert absolute path to relative to player
	var relative_path = str(absolute_path).replace(str(player_path) + "/", "")
	
	print("Debug - Calculated path:")
	print("  Absolute: ", absolute_path)
	print("  Player: ", player_path)
	print("  Relative: ", relative_path)
	
	# 4. Call the creation function
	create_sprite_animation(
		animation_player,
		textures_array,
		animation_name,
		animation_time,
		speed,
		snap,
		relative_path
	)

# Helper functions
func create_quick_animation(
	animation_player: AnimationPlayer,
	textures: Array,
	name: String,
	target_node: Node
) -> void:
	"""Simplified version with defaults"""
	create_sprite_animation_easy(
		animation_player,
		textures,
		name,
		1.0,      # default time
		1.0,      # default speed
		0.0333,   # default snap
		target_node
	)

func load_textures_from_directory(directory: String) -> Array:
	"""
	Loads textures from a directory
	"""
	var textures: Array = []
	var dir = DirAccess.open(directory)
	
	if not dir:
		push_error("Directory not found: " + directory)
		return textures
	
	# List PNG files
	var files: PackedStringArray = []
	dir.list_dir_begin()
	var filename = dir.get_next()
	
	while filename != "":
		if filename.ends_with(".png") and not filename.begins_with("."):
			files.append(filename)
		filename = dir.get_next()
	
	dir.list_dir_end()
	
	# Sort
	files.sort()
	
	# Load textures
	for file in files:
		var full_path = directory + "/" + file
		var texture = load(full_path)
		if texture and texture is Texture2D:
			textures.append(texture)
		else:
			print("⚠️  Could not load: " + full_path)
	
	print("📁 Loaded %d textures from %s" % [textures.size(), directory])
	return textures

func play_with_speed(
	animation_player: AnimationPlayer,
	animation_name: String
) -> void:
	"""
	Plays animation with custom speed
	"""
	if not animation_player.has_animation(animation_name):
		push_error("Animation '%s' not found!" % animation_name)
		return
	
	var animation = animation_player.get_animation(animation_name)
	if animation and animation.has_meta("custom_speed"):
		var speed = animation.get_meta("custom_speed")
		animation_player.playback_speed = speed
		print("🎬 Playing '%s' with speed %.2fx" % [animation_name, speed])
	else:
		animation_player.playback_speed = 1.0
		print("🎬 Playing '%s' with normal speed" % animation_name)
	
	animation_player.play(animation_name)

# Extra function to check if animation exists
func check_animation(animation_player: AnimationPlayer, animation_name: String) -> bool:
	"""Checks if an animation exists"""
	var exists = animation_player.has_animation(animation_name)
	print("❓ Animation '%s' exists? %s" % [animation_name, "✅ Yes" if exists else "❌ No"])
	return exists

# Function to list all animations
func list_animations(animation_player: AnimationPlayer) -> void:
	"""Lists all animations in the AnimationPlayer"""
	print("📋 Available animations:")
	var animations = animation_player.get_animation_list()
	for anim in animations:
		print("  - " + anim)

#region Save animations

func save_animation_to_file(
	textures_array: Array,
	animation_name: String,
	animation_time: float = 1.0,
	snap: float = 0.0333,
	relative_path: String = "../Sprite2D",  # NOW: relative path
	destination_folder: String = "res://animations/"
) -> bool:
	"""
	Saves animation with RELATIVE path to be reusable
	"""
	
	if textures_array.size() == 0:
		push_error("Texture array is empty!")
		return false
	
	# Create the animation
	var animation = Animation.new()
	animation.length = animation_time
	
	# IMPORTANT: Use provided relative path
	var track_idx = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_idx, relative_path + ":texture")
	animation.value_track_set_update_mode(track_idx, Animation.UPDATE_DISCRETE)
	
	# Add keyframes
	var time_per_frame = animation_time / textures_array.size()
	
	for i in range(textures_array.size()):
		var frame_time = i * time_per_frame
		if snap > 0:
			frame_time = snapped(frame_time, snap)
		animation.track_insert_key(track_idx, frame_time, textures_array[i])
	
	animation.set_step(snap)
	
	# Create folder if it doesn't exist
	var dir = DirAccess.open(destination_folder)
	if not dir:
		DirAccess.make_dir_absolute(destination_folder)
	
	# Save
	var file_path = destination_folder + animation_name + ".tres"
	var result = ResourceSaver.save(animation, file_path)
	
	if result == OK:
		print("💾 Animation saved: " + file_path)
		print("   Track path: " + relative_path + ":texture")
		return true
	else:
		push_error("Error saving! Code: " + str(result))
		return false

func create_and_save_animation(
	animation_player: AnimationPlayer,
	textures_array: Array,
	animation_name: String,
	animation_time: float = 1.0,
	speed: float = 1.0,
	snap: float = 0.0333,
	target_node: Node = null,
	save_file: bool = true
) -> void:
	"""
	DEFINITIVE SOLUTION: Saves with same path as editor
	"""
	
	if not target_node:
		push_error("Target node not provided!")
		return
	
	# 1. Get the SIMPLE name of the target node
	var target_node_name = target_node.name
	
	print("🔍 Debug - Target node name: " + target_node_name)
	
	# 2. Create animation in AnimationPlayer (to work now)
	#    First, we need the relative path to work during execution
	var path_for_execution = calculate_simple_relative_path(animation_player, target_node)
	
	print("🔍 Debug - Path for execution: " + path_for_execution)
	
	create_sprite_animation(
		animation_player,
		textures_array,
		animation_name,
		animation_time,
		speed,
		snap,
		path_for_execution
	)
	
	# 3. Save as file ONLY WITH THE NODE NAME (same as editor)
	if save_file:
		# IMPORTANT: For the .tres file, use ONLY the node name
		save_animation_with_simple_name(
			textures_array,
			animation_name,
			animation_time,
			snap,
			target_node_name  # ONLY THE NAME, no path
		)

func calculate_simple_relative_path(animation_player: AnimationPlayer, target_node: Node) -> String:
	"""
	Calculates SIMPLE relative path: just the name or ../name
	FIXED VERSION - without get_nameslice
	"""
	
	# Check if they are at the same level (siblings)
	if animation_player.get_parent() == target_node.get_parent():
		# They are siblings - use just the name
		return target_node.name
	else:
		# Use a simpler approach
		var relative_path = animation_player.get_path_to(target_node)
		var path_str = str(relative_path)
		
		# If already starts with ../, it's correct
		if path_str.begins_with("../"):
			return path_str
		
		# If doesn't start with ../, but has "/", convert
		if path_str.contains("/") and not path_str.begins_with("/"):
			# Already a relative path (but doesn't start with ../)
			# Could be something like "parent/child"
			return path_str
		
		# For absolute paths, convert to relative manually
		if path_str.begins_with("/"):
			return convert_absolute_path_to_relative(animation_player, target_node)
		
		return path_str

func convert_absolute_path_to_relative(animation_player: AnimationPlayer, target_node: Node) -> String:
	"""
	Converts absolute path to relative manually
	"""
	var player_path = str(animation_player.get_path())
	var target_path = str(target_node.get_path())
	
	# Split paths into parts
	var player_parts = player_path.split("/")
	var target_parts = target_path.split("/")
	
	# Remove empty elements
	player_parts = player_parts.filter(func(p): return p != "")
	target_parts = target_parts.filter(func(p): return p != "")
	
	# Find the point where paths diverge
	var i = 0
	while i < min(player_parts.size(), target_parts.size()):
		if player_parts[i] != target_parts[i]:
			break
		i += 1
	
	# Build the relative path
	var result = ""
	
	# How many levels to go up
	var levels_up = player_parts.size() - i
	for j in range(levels_up):
		result += "../"
	
	# Add the path to go down
	for j in range(i, target_parts.size()):
		result += target_parts[j]
		if j < target_parts.size() - 1:
			result += "/"
	
	return result

func save_animation_with_simple_name(
	textures_array: Array,
	animation_name: String,
	animation_time: float = 1.0,
	snap: float = 0.0333,
	target_node_name: String = "Sprite2D",  # NOW: ONLY THE NAME
	destination_folder: String = "res://animations/"
) -> bool:
	"""
	Saves animation using ONLY the node name (same as editor)
	"""
	
	if textures_array.size() == 0:
		push_error("Texture array is empty!")
		return false
	
	# Create the animation
	var animation = Animation.new()
	animation.length = animation_time
	
	# IMPORTANT: Use ONLY the node name
	var track_idx = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_idx, target_node_name + ":texture")
	animation.value_track_set_update_mode(track_idx, Animation.UPDATE_DISCRETE)
	
	# Add keyframes
	var time_per_frame = animation_time / textures_array.size()
	
	for i in range(textures_array.size()):
		var frame_time = i * time_per_frame
		if snap > 0:
			frame_time = snapped(frame_time, snap)
		animation.track_insert_key(track_idx, frame_time, textures_array[i])
	
	animation.set_step(snap)
	
	# Create folder
	var dir = DirAccess.open(destination_folder)
	if not dir:
		DirAccess.make_dir_absolute(destination_folder)
	
	# Save
	var file_path = destination_folder + animation_name + ".tres"
	var result = ResourceSaver.save(animation, file_path)
	
	if result == OK:
		print("✅ FILE SAVED SUCCESSFULLY!")
		print("   Path: " + file_path)
		print("   Track: " + target_node_name + ":texture  ← SAME AS EDITOR!")
		return true
	else:
		push_error("Error saving!")
		return false
```