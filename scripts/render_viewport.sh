#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

# Function to display help
show_help() {
    echo "Usage: ${0##*/} -f <file> -o <directory> -t <type> [-r <resolution>] [-m <lighting_mode>] [-x <anti-aliasing>] [-a <camera_angle>]"
    echo "Options:"
    echo "  -f <file>           Path to the input file (.blend, .glb, .gltf, .fbx, .stl)"
    echo "  -o <directory>      Output directory for rendered files"
    echo "  -t <type>           Output file type (jpg, png, tiff, exr, hdr)"
    echo "  -r <resolution>     Resolution in 'WxH' format (e.g., 854x480)"
    echo "  -m <lighting_mode>  Lighting mode (STUDIO, FLAT, MATCAP) (default: STUDIO)"
    echo "  -x <anti-aliasing>  Anti-aliasing method (OFF, FXAA, 5, 8, 11, 16, 32) (default: FXAA)"
    echo "  -a <camera_angle>   Camera angle (e.g., top, bottom, front, back, left, right)"
    echo "  -h                  Display this help"
    echo "Example: ${0##*/} -f model.glb -o /tmp -t png -r 854x480 -m MATCAP -x SMAA -a front"
    exit 1
}

# Function to open the rendered image
open_image() {
    local image_path="$1"
    if command -v img2sixel > /dev/null; then
        img2sixel "$image_path"
    elif command -v viu > /dev/null; then
        viu "$image_path"
    elif command -v feh > /dev/null; then
        feh "$image_path"
    else
        xdg-open "$image_path"
    fi
}

# Initialize default variables
INPUT_FILE=""
OUTPUT_DIR=""
FILE_TYPE="JPEG"
RESOLUTION=""
LIGHT_MODE="STUDIO"
ANTIALIASING="FXAA"
CAMERA_ANGLE="front"

# Process arguments with getopts
while getopts "f:o:t:r:m:x:a:h" opt; do
    case $opt in
        f) INPUT_FILE="$OPTARG" ;;
        o) OUTPUT_DIR="$OPTARG" ;;
        t) FILE_TYPE=$(echo "$OPTARG" | tr '[:lower:]' '[:upper:]') ;;
        r) RESOLUTION="$OPTARG" ;;
        m) LIGHT_MODE=$(echo "$OPTARG" | tr '[:lower:]' '[:upper:]') ;;
        x) ANTIALIASING=$(echo "$OPTARG" | tr '[:lower:]' '[:upper:]') ;;
        a) CAMERA_ANGLE="$OPTARG" ;;
        h) show_help ;;
        ?) show_help ;;
    esac
done

# Check if mandatory arguments were provided
if [ -z "$INPUT_FILE" ] || [ -z "$OUTPUT_DIR" ]; then
    echo "Error: The -f (file) and -o (directory) arguments are mandatory."
    show_help
fi

# Check if the input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: The file '$INPUT_FILE' does not exist."
    exit 1
fi

# Ensure the output directory exists
mkdir -p "$OUTPUT_DIR" || { echo "Error: Could not create '$OUTPUT_DIR'."; exit 1; }

# Extract file extension and name
FILE_EXT="${INPUT_FILE##*.}"
FILENAME=$(basename "$INPUT_FILE" ."$FILE_EXT")
OUTPUT_FILE="$OUTPUT_DIR/$FILENAME"

# Map file type to Blender format and define output extension
case "$FILE_TYPE" in
    JPG|JPEG) 
        BLENDER_FORMAT="JPEG"
        EXT="jpg"
        ;;
    PNG) 
        BLENDER_FORMAT="PNG"
        EXT="png"
        ;;
    TIFF) 
        BLENDER_FORMAT="TIFF"
        EXT="tiff"
        ;;
    EXR) 
        BLENDER_FORMAT="OPEN_EXR"
        EXT="exr"
        ;;
    HDR) 
        BLENDER_FORMAT="HDR"
        EXT="hdr"
        ;;
    *) 
        echo "Error: Type '$FILE_TYPE' not supported. Use jpg, png, tiff, exr, or hdr."
        exit 1 
        ;;
esac

# Process resolution if provided
if [ -n "$RESOLUTION" ]; then
    RES_X=$(echo "$RESOLUTION" | cut -d'x' -f1)
    RES_Y=$(echo "$RESOLUTION" | cut -d'x' -f2)
    if ! [[ "$RES_X" =~ ^[0-9]+$ ]] || ! [[ "$RES_Y" =~ ^[0-9]+$ ]]; then
        echo "Error: Invalid resolution '$RESOLUTION'. Use WxH format (e.g., 854x480)."
        exit 1
    fi
else
    RES_X=1920  # Default if not specified
    RES_Y=1080
fi

# Create a temporary Python script to import the model, add camera, lighting, and render
PYTHON_SCRIPT="/tmp/render_$$.py"
cat << EOF > "$PYTHON_SCRIPT"
import bpy
import math

# Clear the scene
bpy.ops.wm.read_factory_settings(use_empty=True)

# Import the model based on the extension
file_path = "$INPUT_FILE"
file_ext = "$FILE_EXT".lower()
if file_ext in ["glb", "gltf"]:
    bpy.ops.import_scene.gltf(filepath=file_path)
elif file_ext == "stl":
    bpy.ops.import_mesh.stl(filepath=file_path)
elif file_ext == "fbx":
    bpy.ops.import_scene.fbx(filepath=file_path)
elif file_ext == "blend":
    bpy.ops.wm.open_mainfile(filepath=file_path)
else:
    raise ValueError("Unsupported format: " + file_ext)

# Set resolution
bpy.context.scene.render.resolution_x = $RES_X
bpy.context.scene.render.resolution_y = $RES_Y

# Set output format
bpy.context.scene.render.image_settings.file_format = '$BLENDER_FORMAT'
bpy.context.scene.render.filepath = "$OUTPUT_FILE"

# Set render engine to Workbench
bpy.context.scene.render.engine = 'BLENDER_WORKBENCH'

# Configure Workbench render style
bpy.context.scene.display.shading.light = '$LIGHT_MODE'  # Lighting mode (STUDIO, FLAT, MATCAP)
bpy.context.scene.display.shading.color_type = 'TEXTURE'  # Use texture colors
bpy.context.scene.display.shading.show_shadows = True  # Show shadows
bpy.context.scene.display.shading.show_cavity = True  # Show cavity details

# Configure anti-aliasing
bpy.context.scene.display.render_aa = '$ANTIALIASING'  # Anti-aliasing (FXAA, OFF, SMAA)

# Add a camera based on the specified angle
camera_location = {
    "top": (0, 0, 10),
    "bottom": (0, 0, -10),
    "front": (0, -10, 5),
    "back": (0, 10, 5),
    "left": (-10, 0, 5),
    "right": (10, 0, 5),
}.get("$CAMERA_ANGLE", (0, -10, 5))

camera_rotation = {
    "top": (0, 0, 0),
    "bottom": (math.radians(180), 0, 0),
    "front": (math.radians(60), 0, 0),
    "back": (math.radians(60), 0, math.radians(180)),
    "left": (math.radians(60), 0, math.radians(90)),
    "right": (math.radians(60), 0, math.radians(-90)),
}.get("$CAMERA_ANGLE", (math.radians(60), 0, 0))

bpy.ops.object.camera_add(location=camera_location, rotation=camera_rotation)
camera = bpy.context.object
bpy.context.scene.camera = camera

# Adjust the camera to frame all objects
bpy.ops.object.select_all(action='DESELECT')
for obj in bpy.context.scene.objects:
    if obj.type == 'MESH':
        obj.select_set(True)
bpy.ops.view3d.camera_to_view_selected()

# Render
bpy.ops.render.render(write_still=True)
EOF

# Run Blender with the Python script
echo "Rendering '$INPUT_FILE' to '$OUTPUT_FILE' at $RES_X"x"$RES_Y..."
blender -b -P "$PYTHON_SCRIPT"

# Remove the temporary script
rm -f "$PYTHON_SCRIPT"

# Check for success
if [ $? -eq 0 ]; then
    echo "Rendering completed! File saved at: $OUTPUT_FILE.$EXT"
    open_image "$OUTPUT_FILE.$EXT"
else
    echo "Error during rendering."
    exit 1
fi