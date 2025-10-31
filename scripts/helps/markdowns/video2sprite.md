# Optimized Frame Extraction for Animation Sprites

## 📊 Frame Rate Control

### Controlled FPS Extraction
```bash
# 1 frame per second (ideal for sprites)
ffmpeg -i sprite.gif -vf "fps=1" -vsync 0 %08d.png

# Custom rate (ex: 15 FPS)
ffmpeg -i sprite.gif -r 15 %08d.png

# Frame every N seconds (ex: 1 frame every 3 seconds)
ffmpeg -i sprite.gif -r 1/3 %08d.png
```

### Limited Quantity Extraction
```bash
# Specific number of frames
ffmpeg -i animation.gif -frames:v 10 %08d.png

# Time-based extraction
ffmpeg -ss 00:00:01 -t 00:00:05 -i animation.gif %08d.png
```

## 🎨 Background Removal (Chroma Key)

### Basic Colorkey Method
```bash
ffmpeg -i input.gif -vf "colorkey=0x000000:0.1:0.5" -c:v png %08d.png
```

### Advanced Chromakey Method
```bash
ffmpeg -i input.gif -vf "chromakey=0x000000:0.05:0.1:0.2" -c:v png %08d.png
```

### Optimized Settings for Different Colors
```bash
# Black background
ffmpeg -i input.gif -vf "colorkey=black:0.1:0.3" -c:v png %08d.png

# White background  
ffmpeg -i input.gif -vf "colorkey=white:0.1:0.3" -c:v png %08d.png

# Specific color (ex: green #00FF00)
ffmpeg -i input.gif -vf "colorkey=0x00FF00:0.1:0.3" -c:v png %08d.png
```

## ⚡ Performance Optimization

### Frame Reduction
```bash
# Low frequency (2 FPS)
ffmpeg -i video.mp4 -vf "colorkey=0x000000:0.1:0.5" -r 2 -c:v png %08d.png

# Frame every 5 seconds
ffmpeg -i video.mp4 -vf "colorkey=0x000000:0.1:0.5" -r 1/5 -c:v png %08d.png

# Fixed number of frames
ffmpeg -i video.mp4 -vf "colorkey=0x000000:0.1:0.5" -vframes 30 -c:v png %08d.png
```

### Interval-based Extraction
```bash
# From 2s to 8s of the video
ffmpeg -ss 00:00:02 -to 00:00:08 -i video.mp4 -vf "colorkey=0x000000:0.1:0.5" %08d.png

# Every 10 frames
ffmpeg -i video.mp4 -vf "select=not(mod(n\,10)),colorkey=0x000000:0.1:0.5" -vsync 0 %08d.png
```

## 🛠️ Optimized Complete Commands

### For Sprites with Transparency
```bash
ffmpeg -i animation.gif \
       -vf "fps=10,colorkey=0x000000:0.1:0.3" \
       -vsync 0 \
       -compression_level 6 \
       -c:v png \
       sprite_%04d.png
```

### For Long Videos (Performance)
```bash
ffmpeg -i long_video.mp4 \
       -vf "fps=2,colorkey=black:0.1:0.4" \
       -vframes 60 \
       -c:v png \
       -compression_level 6 \
       frame_%04d.png
```

## 📝 Parameters Explained

### Color Filters
- **`colorkey=0x000000:0.1:0.5`**
  - `0x000000`: Color to remove (black)
  - `0.1`: Similarity (0.0-1.0)
  - `0.5`: Edge smoothing

### Frame Control
- **`-r 15`**: 15 frames per second
- **`-r 1/5`**: 1 frame every 5 seconds  
- **`-vframes N`**: N total frames
- **`-vsync 0`**: Disables synchronization

### PNG Quality
- **`-compression_level 6`**: Balance between size/speed
- **`%04d.png`**: 4-digit numbering

## 💡 Practical Tips

1. **Test first with few frames**: Use `-vframes 10` to validate
2. **Adjust similarity**: Start with `0.1` and increase if needed
3. **For sprites**: `fps=1-5` is usually sufficient
4. **Use organized names**: `sprite_%04d.png` for easy sorting
5. **Check source quality**: Avoid compressed sources for clean chroma key
6. **Batch processing**: Use scripts for multiple files

## 🔧 Advanced Scenarios

### Selective Frame Extraction
```bash
# Extract only keyframes
ffmpeg -i video.mp4 -vf "select=eq(pict_type\,I)" -vsync 0 %08d.png

# Extract frames with motion
ffmpeg -i video.mp4 -vf "select=gt(scene\,0.3)" -vsync 0 %08d.png
```

### Quality Optimization
```bash
# High quality preservation
ffmpeg -i input.gif -vf "colorkey=0x000000:0.1:0.5" -compression_level 0 %08d.png

# Size optimization
ffmpeg -i input.gif -vf "colorkey=0x000000:0.1:0.5" -compression_level 9 %08d.png
```

This guide provides from basic to advanced configurations for efficient animation sprite creation!