# Tutorial: Create a Vibrant and Readable Theme for Godot's Editor

This tutorial teaches how to apply a vibrant and readable color theme to Godot's text editor, enhancing your development experience.

## 📋 Prerequisites

- Godot Engine 4.x installed
- Basic knowledge of file navigation
- Text editor for editing configuration files

## 🎨 About the Theme

The proposed theme uses:
- **Dark background** (#242630) to reduce eye strain
- **Vibrant colors** for better contrast and readability
- **Increased line spacing** (6px) for improved reading
- Optimized palette for GDScript with specific colors for different elements

## 🛠️ Recommended Method: @tool Script (Automatic and Reusable)

This is the most efficient option, especially if you want to reuse the theme or apply it to multiple installations.

### Step 1: Create Project Structure

1. Create a new folder anywhere (e.g., `godot_theme_restore`)
2. Inside it, create a file called `project.godot` with this content:

```godot
[application]
config_version=5
run/main_scene="res://main.tscn"
```

### Step 2: Create Main Scene

1. Inside the same folder, create a file called `main.tscn` with this content:

```xml
[gd_scene load_steps=2 format=3 uid="uid://d1tomwsuk1eof"]

[ext_resource type="Script" uid="uid://xpk1fyw1ncie" path="res://main.gd" id="1_ig7tw"]

[node name="main" type="Node"]
script = ExtResource("1_ig7tw")
```

2. Create a file called `main.gd` in the same folder

### Step 3: Add Configuration Script

Paste the following code into the `main.gd` file:

```gdscript
@tool
extends Node

func _enter_tree() -> void:
	var editor_settings = EditorInterface.get_editor_settings()
	print("🔄 Applying custom theme...")

	# Configure line spacing
	editor_settings.set_setting("text_editor/theme/line_spacing", 6)

	# Define all theme colors
	var color_settings = {
		# Basic colors
		"text_editor/theme/highlighting/symbol_color": Color.html("#abc9ff"),
		"text_editor/theme/highlighting/keyword_color": Color.html("#ff79c6"),
		"text_editor/theme/highlighting/control_flow_keyword_color": Color.html("#ff8ccc"),
		"text_editor/theme/highlighting/base_type_color": Color.html("#bb9af7"),
		"text_editor/theme/highlighting/engine_type_color": Color.html("#cad4a2"),
		"text_editor/theme/highlighting/user_type_color": Color.html("#c7ff1a"),
		
		# Comments
		"text_editor/theme/highlighting/comment_color": Color.html("#d18200"),
		"text_editor/theme/highlighting/doc_comment_color": Color.html("#8099b3"),
		
		# Strings and numbers
		"text_editor/theme/highlighting/string_color": Color.html("#ffed00"),
		"text_editor/theme/highlighting/number_color": Color.html("#ffc599"),
		
		# Background and interface
		"text_editor/theme/highlighting/background_color": Color.html("#242630"),
		"text_editor/theme/highlighting/text_color": Color.html("#ffffff"),
		"text_editor/theme/highlighting/current_line_color": Color.html("#ffffff12"),
		
		# Line numbers
		"text_editor/theme/highlighting/line_number_color": Color.html("#c9cacd80"),
		"text_editor/theme/highlighting/safe_line_number_color": Color.html("#c9f2cdbf"),
		
		# Selection and cursor
		"text_editor/theme/highlighting/caret_color": Color.html("#ffffff"),
		"text_editor/theme/highlighting/caret_background_color": Color.html("#000000"),
		"text_editor/theme/highlighting/selection_color": Color.html("#bd93f935"),
		"text_editor/theme/highlighting/text_selected_color": Color.html("#0ee6d05c"),
		
		# Functions and members
		"text_editor/theme/highlighting/function_color": Color.html("#57b3ff"),
		"text_editor/theme/highlighting/member_variable_color": Color.html("#bce0ff"),
		
		# Debugging
		"text_editor/theme/highlighting/breakpoint_color": Color.html("#ff786b"),
		"text_editor/theme/highlighting/executing_line_color": Color.html("#ffff00"),
		
		# Search and markings
		"text_editor/theme/highlighting/search_result_color": Color.html("#ffffff12"),
		"text_editor/theme/highlighting/search_result_border_color": Color.html("#699ce861"),
		"text_editor/theme/highlighting/mark_color": Color.html("#ff786b4d"),
		"text_editor/theme/highlighting/bookmark_color": Color.html("#147dfa"),
		
		# GDScript-specific colors
		"text_editor/theme/highlighting/gdscript/function_definition_color": Color.html("#00dcdc"),
		"text_editor/theme/highlighting/gdscript/global_function_color": Color.html("#43e37b"),
		"text_editor/theme/highlighting/gdscript/node_path_color": Color.html("#b8c47d"),
		"text_editor/theme/highlighting/gdscript/node_reference_color": Color.html("#00f200"),
		"text_editor/theme/highlighting/gdscript/annotation_color": Color.html("#ffb311"),
		"text_editor/theme/highlighting/gdscript/string_name_color": Color.html("#ffc2a6"),
		
		# Auto-completion
		"text_editor/theme/highlighting/completion_background_color": Color.html("#282a36"),
		"text_editor/theme/highlighting/completion_selected_color": Color.html("#ffffff3b"),
		"text_editor/theme/highlighting/completion_existing_color": Color.html("#00ffff4c"),
		"text_editor/theme/highlighting/completion_font_color": Color.html("#c9cacd"),
		
		# Comment markers
		"text_editor/theme/highlighting/comment_markers/critical_color": Color.html("#ff0542"),
		"text_editor/theme/highlighting/comment_markers/warning_color": Color.html("#b89c7a"),
		"text_editor/theme/highlighting/comment_markers/notice_color": Color.html("#8fab82")
	}
	
	# Apply all settings
	for setting_name in color_settings:
		editor_settings.set_setting(setting_name, color_settings[setting_name])
	
	# Save changes
	editor_settings.notify_changes()
	print("✅ Theme applied successfully!")
	print("⚠️  Close Godot for changes to take effect.")
	
	# Close automatically (optional - remove if you want to keep it open)
	get_tree().quit()
```

### Step 4: Execute the Script

1. Open terminal/command prompt
2. Navigate to the project folder
3. Run the command:

```bash
# Linux/Mac
godot --path /path/to/your/folder --editor

# Windows (PowerShell)
godot --path "C:\path\to\your\folder" --editor
```

**What happens:**
- Godot will open in editor mode
- The script will run automatically
- Settings will be applied
- Godot will close automatically (if you kept `get_tree().quit()`)

### Step 5: Check the Result

1. Open Godot normally in any project
2. Go to **Editor → Editor Settings → Theme → Text Editor**
3. Confirm that colors were applied
4. Open any GDScript script to see the theme in action

## 🔄 Reusing the Theme

To reapply the theme in the future or on another installation:

1. Keep the project folder in a safe location
2. Whenever you want to restore the theme, run the project with `--editor`
3. Or copy the folder to another computer and repeat the process

## ⚙️ Theme Customization

To modify colors:

1. Open the `main.gd` file
2. Locate the `color_settings` section
3. Change hexadecimal values (`#RRGGBB`) as desired
4. Run the script again

**Color tips:**
- Use dark colors for backgrounds
- Use light/vibrant colors for text
- Maintain good contrast for readability
- Always test with real code

## 📁 Final Project Structure

Your project should have this structure:

```
godot_theme_restore/
├── project.godot
├── main.tscn
└── main.gd
```

## 🆘 Troubleshooting

**Problem:** Colors weren't applied
- Solution: Make sure you're running with `--editor`
- Check for errors in the terminal

**Problem:** Godot doesn't close automatically
- Solution: This is normal if you removed `get_tree().quit()`
- Just close manually after seeing "Theme applied"

**Problem:** Colors look different
- Solution: Some system settings can affect colors
- Adjust manually in Editor Settings if needed

## ✅ Method Comparison

| Feature | @tool Script (Recommended) |
|---------|----------------------------|
| Complexity | Medium (one-time setup) |
| Reusability | Excellent (run whenever you want) |
| Portability | Great (copy the folder) |
| Maintenance | Easy (edit one file) |
| Security | High (only default settings) |

## 🎯 Conclusion

This theme provides a more pleasant and less fatiguing coding experience in Godot. The @tool script method is recommended because it's reusable, easy to maintain, and portable between different installations or computers.

**Extra tip:** Consider creating a shortcut/batch file to run the script quickly whenever you need to restore the theme!

Happy coding with vibrant colors! 🚀