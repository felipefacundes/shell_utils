# Guia Completo e Pedagógico do FFmpeg

## Índice
1. [Codecs e Encoders](#codecs-e-encoders)
2. [Codec AV1 e libsvtav1](#codec-av1-e-libsvtav1)
3. [Parâmetros de Qualidade](#parâmetros-de-qualidade)
4. [Exemplos Práticos Avançados](#exemplos-práticos-avançados)
5. [Controle de Bitrate e Qualidade](#controle-de-bitrate-e-qualidade)
6. [Parâmetros Técnicos Detalhados](#parâmetros-técnicos-detalhados)
7. [Áudio: Codecs e Configurações](#áudio-codecs-e-configurações)
8. [Conclusão](#conclusão)

---

## Codecs e Encoders

### Listando Codecs Disponíveis
O FFmpeg suporta centenas de codecs. Para ver todos:

```bash
ffmpeg -codecs
```

Para filtrar por codec específico:

```bash
# Sintaxe geral
ffmpeg -codecs | grep -i "nome do codec"

# Exemplo para AV1
ffmpeg -codecs | grep -i av1
```

### O que são Encoders?
Encoders são as implementações específicas que **codificam** o vídeo usando um determinado codec. Um mesmo codec pode ter múltiplos encoders:

- **Software encoders**: Usam CPU (ex: libx264, libsvtav1)
- **Hardware encoders**: Usam GPU (ex: h264_nvenc, hevc_vaapi)

Para listar encoders:

```bash
ffmpeg -encoders | grep -i "nome do encoder"

# Exemplo para AV1
ffmpeg -encoders | grep -i av1
```

---

## Codec AV1 e libsvtav1

### Comparação de Encoders AV1

#### **libsvtav1** - O Mais Eficiente
Desenvolvido pela Intel, é atualmente **o encoder AV1 mais rápido e eficiente**:

- **15x mais rápido que libaom-av1** com qualidade comparável
- **Melhor que librav1e** em velocidade/qualidade
- **Compactação superior**: arquivos 30-50% menores que H.265 com mesma qualidade
- **Qualidade visual excepcional**, especialmente em bitrates baixos
- **Suporte a 10-bit e HDR**

#### **libaom-av1** - O Mais Lento
- Qualidade de referência, mas **extremamente lento**
- 50-100x mais lento que H.264
- **Apenas para encodificação profissional** onde tempo não importa
- Melhor compressão absoluta, mas diferença marginal frente ao SVT-AV1

#### **librav1e**
- Mais rápido que libaom, mas mais lento que svtav1
- Desenvolvimento menos ativo atualmente
- Boa qualidade, mas geralmente inferior ao SVT-AV1

### Por que usar libsvtav1?
```bash
# Vantagens:
# 1. Velocidade: 10-15x mais rápido que libaom
# 2. Qualidade: Quase igual ao libaom (diferença imperceptível)
# 3. Compactação: 30% melhor que H.265
# 4. Royalty-free: Sem custos de licenciamento
# 5. Suporte universal: YouTube, Netflix, Disney+ já usam AV1
```

---

## Parâmetros de Qualidade

### **`-crf` (Constant Rate Factor)**
**Uso:** Codecs de software (libx264, libx265, libsvtav1)

**O que é:** Controla qualidade de forma constante. **Valores mais baixos = melhor qualidade**.

**Range típico:**
- H.264: 18-28 (23 é padrão)
- H.265/AV1: 20-32 (28 é comum para AV1)

```bash
# Sintaxe
-crf <valor>

# Exemplos
ffmpeg -i input.mp4 -c:v libx264 -crf 23 output.mp4
ffmpeg -i input.mp4 -c:v libsvtav1 -crf 28 output.mkv
```

### **`-cq` (Constant Quality)**
**Uso:** Codecs de hardware (NVENC, VAAPI, QSV)

**O que é:** Similar ao CRF, mas para encoders de hardware.

**Range:** 0-51 (0 = melhor qualidade)
```bash
# NVENC (NVIDIA)
-cq 23

# VAAPI (Intel/AMD)
-qp 23

# QSV (Intel)
-global_quality 23
```

### **`-bf` (B-Frames)**
**O que são:** Quadros Bidirecionais - usam informações de quadros anteriores E futuros para compressão.

**Impacto:**
- Mais B-frames = melhor compressão
- Mais B-frames = encoding mais lento
- Pode causar problemas de compatibilidade

```bash
# Sintaxe
-bf <número>

# Exemplos
-bf 2    # Padrão (boa compatibilidade)
-bf 4    # Melhor compressão
-bf 8    # Máxima compressão (pode ter problemas)
```

### **`-refs` (Reference Frames)**
**O que são:** Número máximo de quadros anteriores que podem ser usados como referência.

**Balanceamento:**
- Mais refs = melhor compressão (5-20% menor arquivo)
- Mais refs = mais memória necessária
- Mais refs = problemas com players antigos

```bash
# Recomendações:
-refs 1    # Compatibilidade máxima (players antigos)
-refs 3    # Web/streaming moderno (YouTube, Twitch)
-refs 6    # Qualidade otimizada (arquivos locais)
-refs 12   # Máxima compressão (encoding lento!)
```

### **Parâmetros Específicos do libsvtav1**

#### **`-preset` (Velocidade vs Qualidade)**
Range: 0-13
- **0-4**: Mais lento, melhor compressão
- **5-8**: Balanceado (recomendado)
- **9-13**: Mais rápido, compressão pior

```bash
-preset 4    # Qualidade máxima (lento)
-preset 6    # Bom balanço (recomendado)
-preset 8    # Rápido, para streaming
```

#### **`-svtav1-params` (Parâmetros Avançados)**
```bash
# Exemplo completo:
-svtav1-params "tune=0:film-grain=8:film-grain-denoise=0:enable-tf=1"

# Parâmetros importantes:
# tune=0        # Otimização geral
# tune=1        # Otimização para PSNR (qualidade objetiva)
# tune=2        # Otimização para VMAF (qualidade perceptual)

# film-grain=0-16      # Adiciona/remove grain sintético
# film-grain-denoise=0 # Preserva grain natural
# enable-tf=1          # Ativa temporal filtering
# scd=1                # Detecção de cena
```

#### **`-g` (GOP Size)**
Tamanho do Grupo de Quadros (GOP). Valores menores = mais I-frames = mais qualidade, mas arquivos maiores.

```bash
-g 240    # Padrão recomendado (10s a 24fps)
-g 120    # Para conteúdo com muitas mudanças de cena
-g 600    # Para filmes/longa duração
```

---

## Exemplos Práticos Avançados

### Exemplo 1: Upscaling com Vulkan + libplacebo + SVT-AV1
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

**Explicação detalhada:**
1. **`-init_hw_device vulkan`**: Inicializa aceleração Vulkan
2. **Filtro complexo**: Upscaling 2x com EWA Lanczos + tone mapping HDR
3. **`-c:v libsvtav1`**: Usa o melhor encoder AV1
4. **`-preset 4 -crf 18`**: Qualidade quase lossless
5. **`-pix_fmt yuv420p10le`**: 10-bit para HDR
6. **`-c:a libopus -b:a 128k`**: Áudio de alta qualidade
7. **`-movflags +faststart`**: Otimizado para streaming

### Exemplo 2: Com Shader Personalizado
```bash
ffmpeg -i "ENTRADA.mp4" \
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
  "SAIDA_PREMIUM.mkv"
```

**Características especiais:**
1. **Shader personalizado**: FSRCNNX para upscaling AI-based
2. **Anti-ringing**: Remove halos artificiais
3. **Peak detect**: Detecta picos de brilho para HDR
4. **Color management completo**: Espaço de cores BT.2020
5. **Film grain**: Preserva textura natural do filme

---

## Controle de Bitrate e Qualidade

### **Importante: Bitrate NÃO é "quanto menor melhor"**

### O que é `-b:v` (Video Bitrate)?
Taxa de bits constante (CBR) ou máxima (VBR). Medido em bits por segundo.

```bash
# Sintaxe
-b:v 2000k    # 2000 kbps
-b:v 5M       # 5 Mbps
```

### Bitrate vs Qualidade: Relação Direta

#### **Bitrate ALTO:**
✅ **Vantagens:**
- Qualidade visivelmente melhor
- Menos artefatos de compressão
- Melhor para conteúdo complexo (ação, cenas escuras)

❌ **Desvantagens:**
- Arquivos MUITO maiores
- Pode exceder limites de streaming
- Desperdício para conteúdo simples

#### **Bitrate BAIXO:**
✅ **Vantagens:**
- Arquivos pequenos
- Streaming eficiente
- Economia de armazenamento

❌ **Desvantagens:**
- Qualidade ruim (blocos, artefatos)
- Ruído em cenas escuras
- Perda de detalhes

### Valores de Referência (H.264/AVC)

| Resolução | FPS | Bitrate Recomendado | Uso |
|-----------|-----|-------------------|-----|
| **480p** (SD) | 30 | 500-1000 kbps | Básico |
| **720p** (HD) | 30 | 1500-3000 kbps | Web/YouTube |
| **1080p** (FHD) | 30 | 3000-6000 kbps | Streaming |
| **1080p** (FHD) | 60 | 4500-9000 kbps | Gaming |
| **1440p** (2K) | 30 | 6000-12000 kbps | Alta qualidade |
| **2160p** (4K) | 30 | 12000-25000 kbps | 4K UHD |

**Para AV1**: Use 30-50% menos que H.264 para mesma qualidade!

### `-crf` vs `-b:v` - Quando usar?

#### **Use `-b:v` quando:**
1. Limite de tamanho específico
2. Streaming com banda limitada
3. Compatibilidade com dispositivos

```bash
# Exemplo: Vídeo de 5 minutos com máximo 100MB
# Cálculo: 100MB * 8 bits = 800Mb / 300s ≈ 2700 kbps
ffmpeg -i input.mp4 -b:v 2700k -t 300 output.mp4
```

#### **Use `-crf` quando:**
1. Qualidade consistente é prioridade
2. Arquivamento/backup
3. Não importa tamanho final

```bash
# Qualidade constante com tamanho variável
ffmpeg -i input.mp4 -crf 23 output.mp4
```

### **NUNCA misture `-crf` e `-cq`!**
São para codecs diferentes e causam conflito:

```bash
# ❌ ERRADO
ffmpeg -i input -c:v h264_nvenc -crf 23 -cq 20 output.mp4

# ✅ Software encoding
ffmpeg -i input -c:v libx264 -crf 23 output.mp4

# ✅ Hardware encoding
ffmpeg -i input -c:v h264_nvenc -cq 23 output.mp4
```

---

## Parâmetros Técnicos Detalhados

### Valores Mínimos de Qualidade

#### **`-cq` mínimo por codec:**
- **NVENC (NVIDIA)**: 0 (range 0-51)
- **VAAPI (Intel/AMD)**: 1 (range 1-51) - usa `-qp`
- **QSV (Intel)**: 1 (range 1-51) - usa `-global_quality`
- **AMF (AMD)**: 0 (range 0-51)

**Na prática:** Use 15-20 para qualidade excelente com tamanho razoável.

### Otimização de `-refs`
**Regra prática:**
- `-refs 1-2`: Compatibilidade total (players antigos)
- `-refs 3-4`: Web/streaming moderno
- `-refs 5-6`: Qualidade otimizada
- `-refs 8-12`: Máxima compressão (lento!)

**Importante:** Limites por nível H.264:
- Nível 4.0: máximo 4 refs para 1080p
- Especifique nível para garantir compatibilidade:
```bash
ffmpeg -i input -c:v libx264 -level 4.0 -refs 4 output.mp4
```

### Parâmetros Adicionais Importantes

#### **`-profile:v` (Perfil do Codec)**
```bash
# H.264
-profile:v high -level 4.1

# H.265/HEVC
-profile:v main10 -level 5.1

# AV1
-profile:v main  # 8-bit
-profile:v high  # 10-bit
```

#### **`-pix_fmt` (Formato de Pixel)**
```bash
yuv420p      # 8-bit padrão (maior compatibilidade)
yuv420p10le  # 10-bit HDR (melhor qualidade)
yuv422p10le  # 10-bit 4:2:2 (pro)
yuv444p10le  # 10-bit 4:4:4 (lossless)
```

#### **`-x264-params` / `-x265-params`**
Parâmetros avançados para codecs específicos:

```bash
# H.264 avançado
-x264-params "keyint=240:min-keyint=24:no-scenecut=0"

# H.265 avançado
-x265-params "aq-mode=3:rd=4:psy-rd=2.0"
```

---

## Áudio: Codecs e Configurações

### Codecs de Áudio Mais Usados

#### **1. Opus (`libopus`)**
**Melhor para:** Streaming, YouTube, Discord, VoIP
**Vantagens:**
- Qualidade excelente em baixos bitrates
- Latência muito baixa
- Suporte a 5.1, 7.1, ambisonics

```bash
# Configuração recomendada:
-c:a libopus -b:a 128k -vbr on -compression_level 10

# Para música (alta qualidade):
-c:a libopus -b:a 192k -vbr on

# Para voz (baixo bitrate):
-c:a libopus -b:a 64k -vbr on -application voip
```

#### **2. AAC (`aac` ou `libfdk_aac`)**
**Melhor para:** Compatibilidade universal, Apple devices
**Vantagens:**
- Suporte universal
- Boa qualidade a bitrates moderados

```bash
# FFmpeg native AAC (boa qualidade):
-c:a aac -b:a 192k

# libfdk_aac (melhor qualidade - precisa compilar FFmpeg):
-c:a libfdk_aac -b:a 256k -vbr 4
```

#### **3. FLAC (`flac`)**
**Melhor para:** Arquivamento, lossless
**Vantagens:**
- Lossless (qualidade original)
- Compactação ~50%

```bash
-c:a flac -compression_level 8
```

#### **4. MP3 (`libmp3lame`)**
**Melhor para:** Compatibilidade máxima
**Vantagens:**
- Todo dispositivo toca MP3
- Boa qualidade a 192k+

```bash
-c:a libmp3lame -b:a 192k -q:a 0
```

### Parâmetros de Áudio Importantes

#### **Bitrate (`-b:a`)**
```bash
# Voz:
-b:a 64k      # Telefonia
-b:a 96k      # Podcast
-b:a 128k     # Voz clara

# Música:
-b:a 160k     # Música aceitável
-b:a 192k     # Música boa
-b:a 256k     # Música excelente
-b:a 320k     # Música transparente (MP3)
```

#### **Taxa de Amostragem (`-ar`)**
```bash
-ar 44100     # CD quality (padrão)
-ar 48000     # DVD/Blu-ray (recomendado)
-ar 96000     # Alta resolução
-ar 192000    # Máxima resolução
```

#### **Canais (`-ac`)**
```bash
-ac 1         # Mono
-ac 2         # Estéreo (padrão)
-ac 6         # 5.1 surround
-ac 8         # 7.1 surround
```

### Configurações por Plataforma

#### **YouTube:**
```bash
# Áudio recomendado:
-c:a libopus -b:a 128k -ar 48000

# Ou se preferir AAC:
-c:a aac -b:a 192k -ar 44100

# Para música (YouTube Music):
-c:a libopus -b:a 160k -ar 48000
```

#### **Spotify/Streaming de Música:**
- **Upload**: FLAC, WAV, AIFF (lossless)
- **Streaming**: Ogg Vorbis 320k (Spotify), AAC 256k (Apple Music)
- **Recomendação para produção:** Exportar em 24-bit/48kHz

#### **Twitch:**
```bash
# Limite: 160k para áudio
-c:a aac -b:a 160k -ar 48000
```

#### **Netflix (padrões profissionais):**
```bash
# Para 5.1 surround:
-c:a eac3 -b:a 640k  # Dolby Digital Plus

# Para estéreo:
-c:a aac -b:a 192k

# Requisitos:
- Mínimo 192k para estéreo
- 5.1: 384-640k
- Atmos: 768k+
```

### Exemplos Completos com Áudio

#### **Exemplo 1: Vídeo para YouTube**
```bash
ffmpeg -i input.mp4 \
  -c:v libsvtav1 -preset 6 -crf 28 \
  -c:a libopus -b:a 128k -ar 48000 \
  -movflags +faststart \
  output_yt.mkv
```

#### **Exemplo 2: Arquivo Master (alta qualidade)**
```bash
ffmpeg -i input.mov \
  -c:v libsvtav1 -preset 4 -crf 18 -pix_fmt yuv420p10le \
  -c:a flac -compression_level 8 \
  output_master.mkv
```

#### **Exemplo 3: Streaming (Twitch/OBS)**
```bash
ffmpeg -i input \
  -c:v h264_nvenc -cq 23 -preset p6 \
  -c:a aac -b:a 160k -ar 48000 \
  -f flv rtmp://twitch.tv/...
```

### Dicas Avançadas de Áudio

#### **Normalização de Volume (Loudness)**
```bash
# Normalizar para -14 LUFS (padrão streaming)
ffmpeg -i input.mp4 -af "loudnorm=I=-14:TP=-1.5:LRA=11" output.mp4

# Medir loudness atual:
ffmpeg -i input.mp4 -af "ebur128=peak=true" -f null -
```

#### **Remover Ruído**
```bash
# Redução de ruído suave
ffmpeg -i input.mp4 -af "afftdn=nf=-20" output.mp4

# Redução de ruído agressiva
ffmpeg -i input.mp4 -af "arnndn=m=./model.rnnn" output.mp4
```

#### **Extrair apenas áudio**
```bash
# Para música
ffmpeg -i video.mp4 -vn -c:a libopus -b:a 192k audio.opus

# Para edição
ffmpeg -i video.mp4 -vn -c:a pcm_s16le audio.wav
```

---

## Conclusão

### Resumo das Recomendações:

#### **Para uso geral (melhor custo-benefício):**
```bash
ffmpeg -i input.mp4 \
  -c:v libsvtav1 -preset 6 -crf 28 \
  -c:a libopus -b:a 128k -ar 48000 \
  output.mkv
```

#### **Para máxima qualidade (arquivamento):**
```bash
ffmpeg -i input.mp4 \
  -c:v libsvtav1 -preset 4 -crf 18 -pix_fmt yuv420p10le \
  -c:a flac -compression_level 8 \
  output_master.mkv
```

#### **Para compatibilidade máxima:**
```bash
ffmpeg -i input.mp4 \
  -c:v libx264 -crf 23 -preset medium -profile:v high -level 4.1 \
  -c:a aac -b:a 192k \
  -movflags +faststart \
  output.mp4
```

### Cheat Sheet Rápido:

| Parâmetro | Onde usar | Valores típicos |
|-----------|-----------|-----------------|
| **`-crf`** | Software encoding | 18-28 (menor = melhor) |
| **`-cq`** | Hardware encoding | 15-25 (menor = melhor) |
| **`-preset`** | Velocidade | 0-13 (0=lento, 13=rápido) |
| **`-b:a`** | Bitrate áudio | 64k-320k |
| **`-b:v`** | Bitrate vídeo | Ver tabela por resolução |
| **`-refs`** | Compressão | 1-12 (mais = melhor compressão) |
| **`-bf`** | B-frames | 2-8 (mais = melhor compressão) |

### Recursos para Aprender Mais:

1. **Documentação oficial:** `ffmpeg -h full`
2. **Help específico:** `ffmpeg -h encoder=libsvtav1`
3. **Teste de qualidade:** Sempre faça testes com clipes curtos
4. **Use two-pass quando possível:** Para bitrate constante

**Lembre-se:** O melhor encoder é aquele que equilibra qualidade, velocidade e compatibilidade para seu caso específico. Comece com as configurações recomendadas e ajuste conforme suas necessidades.