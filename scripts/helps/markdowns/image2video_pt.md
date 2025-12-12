# Guia FFmpeg: Transformar Imagens em Vídeo

Este guia explica diversos comandos FFmpeg para converter sequências de imagens em vídeo, com foco em diferentes cenários e necessidades.

## Índice
1. [Comandos Básicos](#comandos-básicos)
2. [Comandos com Hardware Acceleration](#comandos-com-hardware-acceleration)
3. [Comandos com Áudio](#comandos-com-áudio)
4. [Métodos Alternativos de Input](#métodos-alternativos-de-input)

---

## Comandos Básicos

### Meu comando principal
```bash
ffmpeg -init_hw_device vulkan -framerate 30 -pattern_type glob -i "frames/*.png" -i "stayathomedev_logo animation.ogg" \
-vf "scale=1920:1080" -c:v libsvtav1 -preset -2 -crf 15 -pix_fmt yuv420p -c:a aac -b:a 192k -movflags +faststart -shortest output.mp4
```

### 1. Sequência Numérica Simples
```bash
ffmpeg -framerate 1 -i picture%d.jpg -c:v libx264 -r 30 output.mp4
```

**Parâmetros:**
- `-framerate 1`: Define que 1 imagem será exibida por segundo no input
- `-i picture%d.jpg`: Padrão de arquivos (picture1.jpg, picture2.jpg, etc.)
- `-c:v libx264`: Codec de vídeo H.264
- `-r 30`: Define 30 frames por segundo no output
- `output.mp4`: Arquivo de saída

### 2. Com Formato de Pixel Específico
```bash
ffmpeg -framerate 1 -i pic%d.jpg -c:v libx264 -r 30 -pix_fmt yuv420p output.mp4
```

**Parâmetro adicional:**
- `-pix_fmt yuv420p`: Define o formato de pixel para compatibilidade universal (players antigos, navegadores)

### 3. Usando Glob Pattern
```bash
ffmpeg -framerate 1 -pattern_type glob -i '*.jpg' -c:v libx264 -r 30 -pix_fmt yuv420p output.mp4
```

**Parâmetros:**
- `-pattern_type glob`: Habilita padrões glob (wildcards)
- `-i '*.jpg'`: Todos os arquivos JPG no diretório atual (ordem alfabética)

---

## Comandos com Hardware Acceleration

### 4. Codificação AV1 com Vulkan
```bash
ffmpeg -init_hw_device vulkan -framerate 30 -i "frame_%04d.png" -c:v libsvtav1 -preset -2 -crf 15 -pix_fmt yuv420p -movflags +faststart output.mp4
```

**Parâmetros:**
- `-init_hw_device vulkan`: Inicializa aceleração por hardware Vulkan
- `-framerate 30`: 30 imagens por segundo no input
- `-i "frame_%04d.png"`: Padrão com 4 dígitos (frame_0001.png, frame_0002.png)
- `-c:v libsvtav1`: Codec AV1 moderno (melhor compressão)
- `-preset -2`: Velocidade de codificação (-2 a 13, onde -2 é mais lento/qualidade maior)
- `-crf 15`: Fator de qualidade (0-63, menor = melhor qualidade)
- `-movflags +faststart`: Move metadados para início do arquivo (streaming online)

---

## Comandos com Áudio

### 5. Vídeo com Áudio (Glob + Áudio)
```bash
ffmpeg -framerate 1 -pattern_type glob -i '*.jpg' -i freeflow.mp3 \
  -shortest -c:v libx264 -r 30 -pix_fmt yuv420p output6.mp4
```

**Parâmetros:**
- `-i freeflow.mp3`: Arquivo de áudio de entrada
- `-shortest`: Termina quando o input mais curto acabar (vídeo ou áudio)

### 6. Vídeo com Scaling e Áudio
```bash
ffmpeg -init_hw_device vulkan -framerate 30 -pattern_type glob -i "frames/*.png" \
    -i audio.ogg -vf "scale=1920:1080" -c:v libsvtav1 -preset -2 -crf 15 \
    -pix_fmt yuv420p -c:a aac -b:a 192k -movflags +faststart -shortest output.mp4
```

**Parâmetros adicionais:**
- `-vf "scale=1920:1080"`: Redimensiona vídeo para Full HD
- `-c:a aac`: Codec de áudio AAC
- `-b:a 192k`: Bitrate de áudio (192 kbps)

---

## Métodos Alternativos de Input

### 7. Usando Image2Pipe
```bash
cat *.jpg | ffmpeg -framerate 1 -f image2pipe -i - -c:v libx264 -r 30 -pix_fmt yuv420p output.mp4
```

**Parâmetros:**
- `cat *.jpg |`: Pipe de todas as imagens JPG
- `-f image2pipe`: Especifica formato de input via pipe
- `-i -`: Lê da entrada padrão (stdin)

### 8. Usando Arquivo de Concatenação
```bash
ffmpeg -f concat -i input.txt -c:v libx264 -r 30 -pix_fmt yuv420p output.mp4
```

**Parâmetros:**
- `-f concat`: Formato de concatenação
- `-i input.txt`: Arquivo com lista de arquivos (formato: `file 'imagem1.jpg'`)

---

## Comandos Adicionais Úteis

### 9. Ajuste de Duração por Imagem
```bash
ffmpeg -framerate 1/5 -i img%d.jpg -c:v libx264 -r 30 -pix_fmt yuv420p output.mp4
```
- `-framerate 1/5`: Cada imagem aparece por 5 segundos

### 10. Com Filtros Complexos
```bash
ffmpeg -framerate 30 -i frame_%04d.png -vf "fps=30,format=yuv420p" -c:v libx264 -preset slow -crf 18 output.mp4
```
- `-vf "fps=30,format=yuv420p"`: Filtro de vídeo para controlar FPS e formato

### 11. Para GIF Animado
```bash
ffmpeg -framerate 10 -i frame_%04d.png -vf "scale=640:-1" -c:v gif output.gif
```
- `-c:v gif`: Codec GIF
- `scale=640:-1`: Redimensiona para 640px de largura, altura proporcional

### 12. Com Overlay de Texto
```bash
ffmpeg -framerate 1 -i img%d.jpg -vf "drawtext=text='Meu Vídeo':fontsize=24:fontcolor=white:x=10:y=10" -c:v libx264 output.mp4
```

---

## Dicas Importantes

### Ordenação de Arquivos
- `img%d.jpg`: Ordem numérica (img1.jpg, img2.jpg...)
- `img%04d.jpg`: Com zeros à esquerda (img0001.jpg)
- `*.jpg`: Ordem alfabética (usar `-pattern_type glob`)

### Qualidade vs Tamanho
- **CRF (H.264/AV1)**: 18-23 (qualidade alta), 23-28 (balanceado), 28+ (compacto)
- **Preset**: `ultrafast` (mais rápido) ↔ `veryslow` (melhor compressão)

### Compatibilidade
- Use `-pix_fmt yuv420p` para máxima compatibilidade
- `-movflags +faststart` para streaming web
- H.264 tem melhor compatibilidade, AV1 tem melhor compressão

### Performance
- Para muitas imagens: use `-pattern_type glob` ou arquivos de lista
- Para máxima velocidade: `-preset ultrafast` (qualidade reduzida)
- Para melhor qualidade: `-preset veryslow -crf 18`

Este guia cobre os principais cenários para conversão de imagens em vídeo. Escolha o comando baseado em suas necessidades específicas de formato, qualidade e performance.