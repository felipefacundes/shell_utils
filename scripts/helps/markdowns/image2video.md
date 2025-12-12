# FFmpeg Guide: Transform Images into Video

This guide explains various FFmpeg commands for converting image sequences into video, focusing on different scenarios and needs.

## Table of Contents
1. [Basic Commands](#basic-commands)
2. [Hardware Acceleration Commands](#hardware-acceleration-commands)
3. [Commands with Audio](#commands-with-audio)
4. [Alternative Input Methods](#alternative-input-methods)

---

## Basic Commands

### My main command
```bash
ffmpeg -init_hw_device vulkan -framerate 30 -pattern_type glob -i "frames/*.png" -i "stayathomedev_logo animation.ogg" \
-vf "scale=1920:1080" -c:v libsvtav1 -preset -2 -crf 15 -pix_fmt yuv420p -c:a aac -b:a 192k -movflags +faststart -shortest output.mp4
```

### 1. Simple Numbered Sequence
```bash
ffmpeg -framerate 1 -i picture%d.jpg -c:v libx264 -r 30 output.mp4
```

**Parameters:**
- `-framerate 1`: Sets 1 image per second for input
- `-i picture%d.jpg`: File pattern (picture1.jpg, picture2.jpg, etc.)
- `-c:v libx264`: H.264 video codec
- `-r 30`: Sets 30 frames per second for output
- `output.mp4`: Output file

### 2. With Specific Pixel Format
```bash
ffmpeg -framerate 1 -i pic%d.jpg -c:v libx264 -r 30 -pix_fmt yuv420p output.mp4
```

**Additional parameter:**
- `-pix_fmt yuv420p`: Sets pixel format for universal compatibility (old players, browsers)

### 3. Using Glob Pattern
```bash
ffmpeg -framerate 1 -pattern_type glob -i '*.jpg' -c:v libx264 -r 30 -pix_fmt yuv420p output.mp4
```

**Parameters:**
- `-pattern_type glob`: Enables glob patterns (wildcards)
- `-i '*.jpg'`: All JPG files in current directory (alphabetical order)

---

## Hardware Acceleration Commands

### 4. AV1 Encoding with Vulkan
```bash
ffmpeg -init_hw_device vulkan -framerate 30 -i "frame_%04d.png" -c:v libsvtav1 -preset -2 -crf 15 -pix_fmt yuv420p -movflags +faststart output.mp4
```

**Parameters:**
- `-init_hw_device vulkan`: Initializes Vulkan hardware acceleration
- `-framerate 30`: 30 images per second for input
- `-i "frame_%04d.png"`: Pattern with 4 digits (frame_0001.png, frame_0002.png)
- `-c:v libsvtav1`: Modern AV1 codec (better compression)
- `-preset -2`: Encoding speed (-2 to 13, where -2 is slower/better quality)
- `-crf 15`: Quality factor (0-63, lower = better quality)
- `-movflags +faststart`: Moves metadata to file beginning (online streaming)

---

## Commands with Audio

### 5. Video with Audio (Glob + Audio)
```bash
ffmpeg -framerate 1 -pattern_type glob -i '*.jpg' -i freeflow.mp3 \
  -shortest -c:v libx264 -r 30 -pix_fmt yuv420p output6.mp4
```

**Parameters:**
- `-i freeflow.mp3`: Audio input file
- `-shortest`: Stops when shortest input ends (video or audio)

### 6. Video with Scaling and Audio
```bash
ffmpeg -init_hw_device vulkan -framerate 30 -pattern_type glob -i "frames/*.png" \
    -i audio.ogg -vf "scale=1920:1080" -c:v libsvtav1 -preset -2 -crf 15 \
    -pix_fmt yuv420p -c:a aac -b:a 192k -movflags +faststart -shortest output.mp4
```

**Additional parameters:**
- `-vf "scale=1920:1080"`: Resizes video to Full HD
- `-c:a aac`: AAC audio codec
- `-b:a 192k`: Audio bitrate (192 kbps)

---

## Alternative Input Methods

### 7. Using Image2Pipe
```bash
cat *.jpg | ffmpeg -framerate 1 -f image2pipe -i - -c:v libx264 -r 30 -pix_fmt yuv420p output.mp4
```

**Parameters:**
- `cat *.jpg |`: Pipe of all JPG images
- `-f image2pipe`: Specifies input format via pipe
- `-i -`: Reads from standard input (stdin)

### 8. Using Concatenation File
```bash
ffmpeg -f concat -i input.txt -c:v libx264 -r 30 -pix_fmt yuv420p output.mp4
```

**Parameters:**
- `-f concat`: Concatenation format
- `-i input.txt`: File with file list (format: `file 'image1.jpg'`)

---

## Additional Useful Commands

### 9. Adjusting Duration per Image
```bash
ffmpeg -framerate 1/5 -i img%d.jpg -c:v libx264 -r 30 -pix_fmt yuv420p output.mp4
```
- `-framerate 1/5`: Each image appears for 5 seconds

### 10. With Complex Filters
```bash
ffmpeg -framerate 30 -i frame_%04d.png -vf "fps=30,format=yuv420p" -c:v libx264 -preset slow -crf 18 output.mp4
```
- `-vf "fps=30,format=yuv420p"`: Video filter to control FPS and format

### 11. For Animated GIF
```bash
ffmpeg -framerate 10 -i frame_%04d.png -vf "scale=640:-1" -c:v gif output.gif
```
- `-c:v gif`: GIF codec
- `scale=640:-1`: Resizes to 640px width, proportional height

### 12. With Text Overlay
```bash
ffmpeg -framerate 1 -i img%d.jpg -vf "drawtext=text='My Video':fontsize=24:fontcolor=white:x=10:y=10" -c:v libx264 output.mp4
```

---

## Important Tips

### File Ordering
- `img%d.jpg`: Numerical order (img1.jpg, img2.jpg...)
- `img%04d.jpg`: With leading zeros (img0001.jpg)
- `*.jpg`: Alphabetical order (use `-pattern_type glob`)

### Quality vs Size
- **CRF (H.264/AV1)**: 18-23 (high quality), 23-28 (balanced), 28+ (compact)
- **Preset**: `ultrafast` (faster) ↔ `veryslow` (better compression)

### Compatibility
- Use `-pix_fmt yuv420p` for maximum compatibility
- `-movflags +faststart` for web streaming
- H.264 has better compatibility, AV1 has better compression

### Performance
- For many images: use `-pattern_type glob` or list files
- For maximum speed: `-preset ultrafast` (reduced quality)
- For best quality: `-preset veryslow -crf 18`

This guide covers the main scenarios for converting images to video. Choose the command based on your specific format, quality, and performance needs.