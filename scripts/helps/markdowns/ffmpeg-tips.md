# Complete and Pedagogical FFmpeg Guide

## Table of Contents
1. [Codecs and Encoders](#codecs-and-encoders)
2. [AV1 Codec and libsvtav1](#av1-codec-and-libsvtav1)
3. [Quality Parameters](#quality-parameters)
4. [Advanced Practical Examples](#advanced-practical-examples)
5. [Bitrate and Quality Control](#bitrate-and-quality-control)
6. [Detailed Technical Parameters](#detailed-technical-parameters)
7. [Audio: Codecs and Settings](#audio-codecs-and-settings)
8. [Conclusion](#conclusion)

---

## Codecs and Encoders

### Listing Available Codecs
FFmpeg supports hundreds of codecs. To see them all:

```bash
ffmpeg -codecs
```

To filter by specific codec:

```bash
# General syntax
ffmpeg -codecs | grep -i "codec name"

# Example for AV1
ffmpeg -codecs | grep -i av1
```

### What are Encoders?
Encoders are the specific implementations that **encode** video using a particular codec. The same codec can have multiple encoders:

- **Software encoders**: Use CPU (ex: libx264, libsvtav1)
- **Hardware encoders**: Use GPU (ex: h264_nvenc, hevc_vaapi)

To list encoders:

```bash
ffmpeg -encoders | grep -i "encoder name"

# Example for AV1
ffmpeg -encoders | grep -i av1
```

---

## AV1 Codec and libsvtav1

### AV1 Encoders Comparison

#### **libsvtav1** - The Most Efficient
Developed by Intel, currently **the fastest and most efficient AV1 encoder**:

- **15x faster than libaom-av1** with comparable quality
- **Better than librav1e** in speed/quality ratio
- **Superior compression**: 30-50% smaller files than H.265 with same quality
- **Exceptional visual quality**, especially at low bitrates
- **10-bit and HDR support**

#### **libaom-av1** - The Slowest
- Reference quality, but **extremely slow**
- 50-100x slower than H.264
- **Only for professional encoding** where time doesn't matter
- Best absolute compression, but marginal difference compared to SVT-AV1

#### **librav1e**
- Faster than libaom, but slower than svtav1
- Less active development currently
- Good quality, but generally inferior to SVT-AV1

### Why use libsvtav1?
```bash
# Advantages:
# 1. Speed: 10-15x faster than libaom
# 2. Quality: Almost equal to libaom (imperceptible difference)
# 3. Compression: 30% better than H.265
# 4. Royalty-free: No licensing costs
# 5. Universal support: YouTube, Netflix, Disney+ already use AV1
```

---

## Quality Parameters

### **`-crf` (Constant Rate Factor)**
**Usage:** Software codecs (libx264, libx265, libsvtav1)

**What it is:** Controls quality consistently. **Lower values = better quality**.

**Typical range:**
- H.264: 18-28 (23 is default)
- H.265/AV1: 20-32 (28 is common for AV1)

```bash
# Syntax
-crf <value>

# Examples
ffmpeg -i input.mp4 -c:v libx264 -crf 23 output.mp4
ffmpeg -i input.mp4 -c:v libsvtav1 -crf 28 output.mkv
```

### **`-cq` (Constant Quality)**
**Usage:** Hardware codecs (NVENC, VAAPI, QSV)

**What it is:** Similar to CRF, but for hardware encoders.

**Range:** 0-51 (0 = best quality)
```bash
# NVENC (NVIDIA)
-cq 23

# VAAPI (Intel/AMD)
-qp 23

# QSV (Intel)
-global_quality 23
```

### **`-bf` (B-Frames)**
**What they are:** Bidirectional Frames - use information from previous AND future frames for compression.

**Impact:**
- More B-frames = better compression
- More B-frames = slower encoding
- May cause compatibility issues

```bash
# Syntax
-bf <number>

# Examples
-bf 2    # Default (good compatibility)
-bf 4    # Better compression
-bf 8    # Maximum compression (may have issues)
```

### **`-refs` (Reference Frames)**
**What they are:** Maximum number of previous frames that can be used as reference.

**Balance:**
- More refs = better compression (5-20% smaller file)
- More refs = more memory required
- More refs = issues with old players

```bash
# Recommendations:
-refs 1    # Maximum compatibility (old players)
-refs 3    # Modern web/streaming (YouTube, Twitch)
-refs 6    # Optimized quality (local files)
-refs 12   # Maximum compression (slow encoding!)
```

### **libsvtav1 Specific Parameters**

#### **`-preset` (Speed vs Quality)**
Range: 0-13
- **0-4**: Slower, better compression
- **5-8**: Balanced (recommended)
- **9-13**: Faster, worse compression

```bash
-preset 4    # Maximum quality (slow)
-preset 6    # Good balance (recommended)
-preset 8    # Fast, for streaming
```

#### **`-svtav1-params` (Advanced Parameters)**
```bash
# Complete example:
-svtav1-params "tune=0:film-grain=8:film-grain-denoise=0:enable-tf=1"

# Important parameters:
# tune=0        # General optimization
# tune=1        # PSNR optimization (objective quality)
# tune=2        # VMAF optimization (perceptual quality)

# film-grain=0-16      # Adds/removes synthetic grain
# film-grain-denoise=0 # Preserves natural grain
# enable-tf=1          # Enables temporal filtering
# scd=1                # Scene detection
```

#### **`-g` (GOP Size)**
Group of Pictures size. Smaller values = more I-frames = more quality, but larger files.

```bash
-g 240    # Recommended default (10s at 24fps)
-g 120    # For content with many scene changes
-g 600    # For movies/long duration
```

---

## Advanced Practical Examples

### Example 1: Upscaling with Vulkan + libplacebo + SVT-AV1
```bash
ffmpeg -i "input.mp4" \
  -init_hw_device vulkan \
  -vf "format=yuv420p10,hwupload,libplacebo=w=iw*2:h=ih*2:upscaler=ewa_lanczos:tonemapping=auto:color_primaries=bt2020:color_trc=smpte2084:colorspace=bt2020nc,hwdownload,format=yuv420p10" \
  -c:v libsvtav1 \
  -preset 4 \
  -crf 18 \
  -pix_fmt yuv420p10le \
  -c:a libopus \
  -b:a 128k \
  -ar 48000 \
  -movflags +faststart \
  -vf "scale=3840:-2:flags=lanczos" \
  -sws_flags lanczos+accurate_rnd+full_chroma_int+full_chroma_inp \
  "output_premium.mkv"
```

**Detailed explanation:**
1. **`-init_hw_device vulkan`**: Initializes Vulkan acceleration
2. **Complex filter**: 2x upscaling with EWA Lanczos + HDR tone mapping
3. **`-c:v libsvtav1`**: Uses the best AV1 encoder
4. **`-preset 4 -crf 18`**: Near-lossless quality
5. **`-pix_fmt yuv420p10le`**: 10-bit for HDR
6. **`-c:a libopus -b:a 128k`**: High quality audio
7. **`-movflags +faststart`**: Optimized for streaming

### Example 2: With Custom Shader
```bash
ffmpeg -i "INPUT.mp4" \
  -init_hw_device vulkan \
  -vf "format=p010,hwupload,libplacebo=w=iw*2:h=ih*2:upscaler=ewa_lanczos:antiringing=1:peak_detect=1:color_management=1:gamut_mapping=1:tonemapping=auto:inverse_tonemapping=1:custom_shader_path='$HOME/.config/mpv/shaders/FSRCNNX_x2_16-0-4-1.glsl',hwdownload,format=p010" \
  -c:v libsvtav1 \
  -preset 3 \
  -crf 16 \
  -g 240 \
  -pix_fmt yuv420p10le \
  -svtav1-params "tune=0:film-grain=8:film-grain-denoise=0" \
  -c:a libopus \
  -b:a 128k \
  -ar 48000 \
  -ac 2 \
  -movflags +faststart \
  -strict experimental \
  -y \
  "OUTPUT_PREMIUM.mkv"
```

**Special features:**
1. **Custom shader**: FSRCNNX for AI-based upscaling
2. **Anti-ringing**: Removes artificial halos
3. **Peak detect**: Detects brightness peaks for HDR
4. **Complete color management**: BT.2020 color space
5. **Film grain**: Preserves natural film texture

---

## Bitrate and Quality Control

### **Important: Bitrate is NOT "the lower the better"**

### What is `-b:v` (Video Bitrate)?
Constant bitrate (CBR) or maximum bitrate (VBR). Measured in bits per second.

```bash
# Syntax
-b:v 2000k    # 2000 kbps
-b:v 5M       # 5 Mbps
```

### Bitrate vs Quality: Direct Relationship

#### **HIGH Bitrate:**
✅ **Advantages:**
- Visibly better quality
- Fewer compression artifacts
- Better for complex content (action, dark scenes)

❌ **Disadvantages:**
- MUCH larger files
- May exceed streaming limits
- Wasteful for simple content

#### **LOW Bitrate:**
✅ **Advantages:**
- Small files
- Efficient streaming
- Storage savings

❌ **Disadvantages:**
- Poor quality (blocks, artifacts)
- Noise in dark scenes
- Loss of details

### Reference Values (H.264/AVC)

| Resolution | FPS | Recommended Bitrate | Use |
|-----------|-----|-------------------|-----|
| **480p** (SD) | 30 | 500-1000 kbps | Basic |
| **720p** (HD) | 30 | 1500-3000 kbps | Web/YouTube |
| **1080p** (FHD) | 30 | 3000-6000 kbps | Streaming |
| **1080p** (FHD) | 60 | 4500-9000 kbps | Gaming |
| **1440p** (2K) | 30 | 6000-12000 kbps | High quality |
| **2160p** (4K) | 30 | 12000-25000 kbps | 4K UHD |

**For AV1**: Use 30-50% less than H.264 for same quality!

### `-crf` vs `-b:v` - When to use?

#### **Use `-b:v` when:**
1. Specific size limit
2. Streaming with limited bandwidth
3. Compatibility with devices

```bash
# Example: 5-minute video with maximum 100MB
# Calculation: 100MB * 8 bits = 800Mb / 300s ≈ 2700 kbps
ffmpeg -i input.mp4 -b:v 2700k -t 300 output.mp4
```

#### **Use `-crf` when:**
1. Consistent quality is priority
2. Archiving/backup
3. Final size doesn't matter

```bash
# Constant quality with variable size
ffmpeg -i input.mp4 -crf 23 output.mp4
```

### **NEVER mix `-crf` and `-cq`!**
They are for different codecs and cause conflicts:

```bash
# ❌ WRONG
ffmpeg -i input -c:v h264_nvenc -crf 23 -cq 20 output.mp4

# ✅ Software encoding
ffmpeg -i input -c:v libx264 -crf 23 output.mp4

# ✅ Hardware encoding
ffmpeg -i input -c:v h264_nvenc -cq 23 output.mp4
```

---

## Detailed Technical Parameters

### Minimum Quality Values

#### **`-cq` minimum per codec:**
- **NVENC (NVIDIA)**: 0 (range 0-51)
- **VAAPI (Intel/AMD)**: 1 (range 1-51) - uses `-qp`
- **QSV (Intel)**: 1 (range 1-51) - uses `-global_quality`
- **AMF (AMD)**: 0 (range 0-51)

**In practice:** Use 15-20 for excellent quality with reasonable size.

### `-refs` Optimization
**Rule of thumb:**
- `-refs 1-2`: Full compatibility (old players)
- `-refs 3-4`: Modern web/streaming
- `-refs 5-6`: Optimized quality
- `-refs 8-12`: Maximum compression (slow!)

**Important:** H.264 level limits:
- Level 4.0: maximum 4 refs for 1080p
- Specify level to ensure compatibility:
```bash
ffmpeg -i input -c:v libx264 -level 4.0 -refs 4 output.mp4
```

### Additional Important Parameters

#### **`-profile:v` (Codec Profile)**
```bash
# H.264
-profile:v high -level 4.1

# H.265/HEVC
-profile:v main10 -level 5.1

# AV1
-profile:v main  # 8-bit
-profile:v high  # 10-bit
```

#### **`-pix_fmt` (Pixel Format)**
```bash
yuv420p      # 8-bit standard (best compatibility)
yuv420p10le  # 10-bit HDR (better quality)
yuv422p10le  # 10-bit 4:2:2 (pro)
yuv444p10le  # 10-bit 4:4:4 (lossless)
```

#### **`-x264-params` / `-x265-params`**
Advanced parameters for specific codecs:

```bash
# Advanced H.264
-x264-params "keyint=240:min-keyint=24:no-scenecut=0"

# Advanced H.265
-x265-params "aq-mode=3:rd=4:psy-rd=2.0"
```

---

## Audio: Codecs and Settings

### Most Used Audio Codecs

#### **1. Opus (`libopus`)**
**Best for:** Streaming, YouTube, Discord, VoIP
**Advantages:**
- Excellent quality at low bitrates
- Very low latency
- Supports 5.1, 7.1, ambisonics

```bash
# Recommended configuration:
-c:a libopus -b:a 128k -vbr on -compression_level 10

# For music (high quality):
-c:a libopus -b:a 192k -vbr on

# For voice (low bitrate):
-c:a libopus -b:a 64k -vbr on -application voip
```

#### **2. AAC (`aac` or `libfdk_aac`)**
**Best for:** Universal compatibility, Apple devices
**Advantages:**
- Universal support
- Good quality at moderate bitrates

```bash
# FFmpeg native AAC (good quality):
-c:a aac -b:a 192k

# libfdk_aac (better quality - needs FFmpeg compilation):
-c:a libfdk_aac -b:a 256k -vbr 4
```

#### **3. FLAC (`flac`)**
**Best for:** Archiving, lossless
**Advantages:**
- Lossless (original quality)
- ~50% compression

```bash
-c:a flac -compression_level 8
```

#### **4. MP3 (`libmp3lame`)**
**Best for:** Maximum compatibility
**Advantages:**
- Every device plays MP3
- Good quality at 192k+

```bash
-c:a libmp3lame -b:a 192k -q:a 0
```

### Important Audio Parameters

#### **Bitrate (`-b:a`)**
```bash
# Voice:
-b:a 64k      # Telephony
-b:a 96k      # Podcast
-b:a 128k     # Clear voice

# Music:
-b:a 160k     # Acceptable music
-b:a 192k     # Good music
-b:a 256k     # Excellent music
-b:a 320k     # Transparent music (MP3)
```

#### **Sampling Rate (`-ar`)**
```bash
-ar 44100     # CD quality (default)
-ar 48000     # DVD/Blu-ray (recommended)
-ar 96000     # High resolution
-ar 192000    # Maximum resolution
```

#### **Channels (`-ac`)**
```bash
-ac 1         # Mono
-ac 2         # Stereo (default)
-ac 6         # 5.1 surround
-ac 8         # 7.1 surround
```

### Platform-Specific Settings

#### **YouTube:**
```bash
# Recommended audio:
-c:a libopus -b:a 128k -ar 48000

# Or if preferring AAC:
-c:a aac -b:a 192k -ar 44100

# For music (YouTube Music):
-c:a libopus -b:a 160k -ar 48000
```

#### **Spotify/Music Streaming:**
- **Upload**: FLAC, WAV, AIFF (lossless)
- **Streaming**: Ogg Vorbis 320k (Spotify), AAC 256k (Apple Music)
- **Production recommendation:** Export at 24-bit/48kHz

#### **Twitch:**
```bash
# Limit: 160k for audio
-c:a aac -b:a 160k -ar 48000
```

#### **Netflix (professional standards):**
```bash
# For 5.1 surround:
-c:a eac3 -b:a 640k  # Dolby Digital Plus

# For stereo:
-c:a aac -b:a 192k

# Requirements:
- Minimum 192k for stereo
- 5.1: 384-640k
- Atmos: 768k+
```

### Complete Examples with Audio

#### **Example 1: Video for YouTube**
```bash
ffmpeg -i input.mp4 \
  -c:v libsvtav1 -preset 6 -crf 28 \
  -c:a libopus -b:a 128k -ar 48000 \
  -movflags +faststart \
  output_yt.mkv
```

#### **Example 2: Master File (high quality)**
```bash
ffmpeg -i input.mov \
  -c:v libsvtav1 -preset 4 -crf 18 -pix_fmt yuv420p10le \
  -c:a flac -compression_level 8 \
  output_master.mkv
```

#### **Example 3: Streaming (Twitch/OBS)**
```bash
ffmpeg -i input \
  -c:v h264_nvenc -cq 23 -preset p6 \
  -c:a aac -b:a 160k -ar 48000 \
  -f flv rtmp://twitch.tv/...
```

### Advanced Audio Tips

#### **Volume Normalization (Loudness)**
```bash
# Normalize to -14 LUFS (streaming standard)
ffmpeg -i input.mp4 -af "loudnorm=I=-14:TP=-1.5:LRA=11" output.mp4

# Measure current loudness:
ffmpeg -i input.mp4 -af "ebur128=peak=true" -f null -
```

#### **Noise Removal**
```bash
# Gentle noise reduction
ffmpeg -i input.mp4 -af "afftdn=nf=-20" output.mp4

# Aggressive noise reduction
ffmpeg -i input.mp4 -af "arnndn=m=./model.rnnn" output.mp4
```

#### **Extract audio only**
```bash
# For music
ffmpeg -i video.mp4 -vn -c:a libopus -b:a 192k audio.opus

# For editing
ffmpeg -i video.mp4 -vn -c:a pcm_s16le audio.wav
```

---

## Conclusion

### Summary of Recommendations:

#### **For general use (best cost-benefit):**
```bash
ffmpeg -i input.mp4 \
  -c:v libsvtav1 -preset 6 -crf 28 \
  -c:a libopus -b:a 128k -ar 48000 \
  output.mkv
```

#### **For maximum quality (archiving):**
```bash
ffmpeg -i input.mp4 \
  -c:v libsvtav1 -preset 4 -crf 18 -pix_fmt yuv420p10le \
  -c:a flac -compression_level 8 \
  output_master.mkv
```

#### **For maximum compatibility:**
```bash
ffmpeg -i input.mp4 \
  -c:v libx264 -crf 23 -preset medium -profile:v high -level 4.1 \
  -c:a aac -b:a 192k \
  -movflags +faststart \
  output.mp4
```

### Quick Cheat Sheet:

| Parameter | Where to use | Typical values |
|-----------|-----------|-----------------|
| **`-crf`** | Software encoding | 18-28 (lower = better) |
| **`-cq`** | Hardware encoding | 15-25 (lower = better) |
| **`-preset`** | Speed | 0-13 (0=slow, 13=fast) |
| **`-b:a`** | Audio bitrate | 64k-320k |
| **`-b:v`** | Video bitrate | See table by resolution |
| **`-refs`** | Compression | 1-12 (more = better compression) |
| **`-bf`** | B-frames | 2-8 (more = better compression) |

### Resources to Learn More:

1. **Official documentation:** `ffmpeg -h full`
2. **Specific help:** `ffmpeg -h encoder=libsvtav1`
3. **Quality testing:** Always test with short clips
4. **Use two-pass when possible:** For constant bitrate

**Remember:** The best encoder is the one that balances quality, speed, and compatibility for your specific case. Start with the recommended settings and adjust according to your needs.