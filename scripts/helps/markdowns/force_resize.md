# Forced Resizing of Images and Videos: ImageMagick vs FFmpeg

## 📌 Introduction

This guide covers how to force exact resizing (ignoring the original aspect ratio) using **ImageMagick** and **FFmpeg**, highlighting the syntax and behavioral differences between the two tools.

---

## 🖼️ ImageMagick

### Forcing Exact Resizing
By default, ImageMagick maintains the image's aspect ratio. To force exact resizing, use the exclamation mark (`!`) after the dimensions.

**Basic example:**
```bash
magick imagem.jpg -resize 300x200! resultado.jpg
```

### ⚠️ Terminal Considerations
The exclamation mark is a special character in terminals (Bash, Zsh, etc.). To avoid errors:

1. **Use quotes:**
   ```bash
   magick imagem.jpg -resize "300x200!" resultado.jpg
   # or
   magick imagem.jpg -resize '300x200!' resultado.jpg
   ```

2. **Use escape (backslash):**
   ```bash
   magick imagem.jpg -resize 300x200\! resultado.jpg
   ```

### 🎯 Other Resizing Flags

| Flag | Description |
|------|-------------|
| `^` (Caret) | Resizes to fill the minimum area, potentially leaving image overflow on edges (useful for subsequent crops) |
| `>` (Greater than) | Resizes only if the original image is **larger** than the specified dimensions |
| `<` (Less than) | Resizes only if the original image is **smaller** than the specified dimensions |

---

## 🎬 FFmpeg

### Forcing Exact Resizing
**Important:** FFmpeg **does not use** the `!` symbol to force resizing. The default behavior when setting both dimensions already forces the exact size (with distortion if necessary).

**Basic command:**
```bash
ffmpeg -i entrada.mp4 -vf "scale=300:200" saída.mp4
```

### 🔧 Ensuring 1:1 Pixel Aspect Ratio
To ensure pixels remain exactly in the requested format (preventing players from adjusting the aspect ratio), add `setsar=1`:
```bash
ffmpeg -i entrada.mp4 -vf "scale=300:200,setsar=1" saída.mp4
```

### 📏 Preserving Aspect Ratio (Equivalent to ImageMagick without `!`)
Use `-1` (or `-2` to ensure an even number, required by some codecs) for FFmpeg to automatically calculate one dimension:

**Example (fixed width of 300px, automatic height):**
```bash
ffmpeg -i entrada.mp4 -vf "scale=300:-1" saída.mp4
```

**Example (fixed height of 200px, automatic width):**
```bash
ffmpeg -i entrada.mp4 -vf "scale=-1:200" saída.mp4
```

---

## 📊 Summary of Differences

### ImageMagick
| Command | Behavior |
|---------|----------|
| `300x200` | Maintains aspect ratio, fits within dimensions |
| `300x200!` | **Forces** exact dimensions (distorts if necessary) |

### FFmpeg
| Command | Behavior |
|---------|----------|
| `scale=300:-1` | Maintains aspect ratio, calculates height automatically |
| `scale=300:200` | **Forces** exact dimensions (distorts if necessary) |

---

## 🔗 References

- [ImageMagick: Command-line Basics - Resizing Images](https://imagemagick.org/script/command-line-processing.php)
- [ImageMagick Forums: How to force resize an image](https://imagemagick.org/discourse-server/)
- [FFmpeg Documentation: Scaling filter](https://ffmpeg.org/ffmpeg-filters.html#scale)

---

## 📝 Notes

- **ImageMagick:** Use `!` to force exact dimensions, but remember to escape the character in the terminal
- **FFmpeg:** The default behavior of `scale=WIDTH:HEIGHT` already forces exact resizing
- To avoid codec compatibility issues, use even values in FFmpeg (e.g., `scale=300:200` instead of `scale=301:201`)

---

**Last updated:** Document based on research and official tool documentation.