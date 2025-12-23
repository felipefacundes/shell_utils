# Removing Video Metadata Using **FFmpeg**. Here are the most effective methods:

## 1. **Remove ALL Metadata (Recommended)**
```bash
ffmpeg -i input.mp4 -map_metadata -1 -c:v copy -c:a copy output.mp4
```
- `-map_metadata -1`: Removes all metadata
- `-c:v copy -c:a copy`: Copies video and audio without recompression (fast processing)

## 2. **Remove Only Specific Metadata**
```bash
ffmpeg -i input.mp4 -metadata title="" -metadata artist="" -metadata copyright="" -c copy output.mp4
```

## 3. **For Other Formats**
```bash
# For MOV
ffmpeg -i input.mov -map_metadata -1 -c copy output.mov

# For MKV
ffmpeg -i input.mkv -map_metadata -1 -c copy output.mkv

# For AVI
ffmpeg -i input.avi -map_metadata -1 -c copy output.avi
```

## 4. **Verify Removed Metadata**
```bash
# Before
ffprobe input.mp4

# After
ffprobe output.mp4
```

## 5. **Alternatives**

### **Exiftool** (more powerful for metadata)
```bash
exiftool -all= input.mp4 -o output.mp4
```

### **Using Graphical Interfaces:**
- **Metacan** (Windows/Mac/Linux)
- **VLC** (Save without metadata)
- **HandBrake** (disable "Copy metadata" in settings)

## **Important Notes:**
- This only removes container metadata, not visible watermarks
- Some technical metadata required for playback is preserved
- Always backup the original file
- Some services/websites may add their own metadata