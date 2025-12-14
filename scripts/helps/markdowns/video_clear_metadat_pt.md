# Removendo metadados de vídeos usando o **FFmpeg**. Aqui estão as formas mais eficazes:

## 1. **Remover TODOS os metadados (recomendado)**
```bash
ffmpeg -i input.mp4 -map_metadata -1 -c:v copy -c:a copy output.mp4
```
- `-map_metadata -1`: Remove todos os metadados
- `-c:v copy -c:a copy`: Copia vídeo e áudio sem recompressão (processamento rápido)

## 2. **Remover apenas metadados específicos**
```bash
ffmpeg -i input.mp4 -metadata title="" -metadata artist="" -metadata copyright="" -c copy output.mp4
```

## 3. **Para outros formatos**
```bash
# Para MOV
ffmpeg -i input.mov -map_metadata -1 -c copy output.mov

# Para MKV
ffmpeg -i input.mkv -map_metadata -1 -c copy output.mkv

# Para AVI
ffmpeg -i input.avi -map_metadata -1 -c copy output.avi
```

## 4. **Verificar metadados removidos**
```bash
# Antes
ffprobe input.mp4

# Depois
ffprobe output.mp4
```

## 5. **Alternativas**

### **Exiftool** (mais poderoso para metadados)
```bash
exiftool -all= input.mp4 -o output.mp4
```

### **Usando interface gráfica:**
- **Metacan** (Windows/Mac/Linux)
- **VLC** (Salvar sem metadados)
- **HandBrake** (não copiar metadados nas configurações)

## **Importante:**
- Isso remove apenas metadados do container, não marca d'água visível
- Alguns metadados técnicos necessários para reprodução são preservados
- Sempre faça backup do arquivo original
- Alguns serviços/sites podem adicionar metadados próprios