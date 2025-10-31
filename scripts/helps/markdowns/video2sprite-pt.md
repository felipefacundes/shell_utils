# Extração Otimizada de Quadros para Sprites de Animação

## 📊 Controle de Taxa de Quadros

### Extração com FPS Controlado
```bash
# 1 quadro por segundo (ideal para sprites)
ffmpeg -i sprite.gif -vf "fps=1" -vsync 0 %08d.png

# Taxa personalizada (ex: 15 FPS)
ffmpeg -i sprite.gif -r 15 %08d.png

# Quadro a cada N segundos (ex: 1 quadro a cada 3 segundos)
ffmpeg -i sprite.gif -r 1/3 %08d.png
```

### Extração com Quantidade Limitada
```bash
# Número específico de quadros
ffmpeg -i animation.gif -frames:v 10 %08d.png

# Extração baseada em tempo
ffmpeg -ss 00:00:01 -t 00:00:05 -i animation.gif %08d.png
```

## 🎨 Remoção de Fundo (Chroma Key)

### Método Básico com Colorkey
```bash
ffmpeg -i input.gif -vf "colorkey=0x000000:0.1:0.5" -c:v png %08d.png
```

### Método Avançado com Chromakey
```bash
ffmpeg -i input.gif -vf "chromakey=0x000000:0.05:0.1:0.2" -c:v png %08d.png
```

### Configurações Otimizadas para Diferentes Cores
```bash
# Fundo preto
ffmpeg -i input.gif -vf "colorkey=black:0.1:0.3" -c:v png %08d.png

# Fundo branco  
ffmpeg -i input.gif -vf "colorkey=white:0.1:0.3" -c:v png %08d.png

# Cor específica (ex: verde #00FF00)
ffmpeg -i input.gif -vf "colorkey=0x00FF00:0.1:0.3" -c:v png %08d.png
```

## ⚡ Otimização de Performance

### Redução de Quadros
```bash
# Baixa frequência (2 FPS)
ffmpeg -i video.mp4 -vf "colorkey=0x000000:0.1:0.5" -r 2 -c:v png %08d.png

# Quadro a cada 5 segundos
ffmpeg -i video.mp4 -vf "colorkey=0x000000:0.1:0.5" -r 1/5 -c:v png %08d.png

# Número fixo de quadros
ffmpeg -i video.mp4 -vf "colorkey=0x000000:0.1:0.5" -vframes 30 -c:v png %08d.png
```

### Extração Baseada em Intervalos
```bash
# Do 2º ao 8º segundo do vídeo
ffmpeg -ss 00:00:02 -to 00:00:08 -i video.mp4 -vf "colorkey=0x000000:0.1:0.5" %08d.png

# A cada 10 quadros
ffmpeg -i video.mp4 -vf "select=not(mod(n\,10)),colorkey=0x000000:0.1:0.5" -vsync 0 %08d.png
```

## 🛠️ Comandos Completos Otimizados

### Para Sprites com Transparência
```bash
ffmpeg -i animation.gif \
       -vf "fps=10,colorkey=0x000000:0.1:0.3" \
       -vsync 0 \
       -compression_level 6 \
       -c:v png \
       sprite_%04d.png
```

### Para Vídeos Longos (Performance)
```bash
ffmpeg -i long_video.mp4 \
       -vf "fps=2,colorkey=black:0.1:0.4" \
       -vframes 60 \
       -c:v png \
       -compression_level 6 \
       frame_%04d.png
```

## 📝 Explicação dos Parâmetros

### Filtros de Cor
- **`colorkey=0x000000:0.1:0.5`**
  - `0x000000`: Cor a ser removida (preto)
  - `0.1`: Similaridade (0.0-1.0)
  - `0.5`: Suavização das bordas

### Controle de Quadros
- **`-r 15`**: 15 quadros por segundo
- **`-r 1/5`**: 1 quadro a cada 5 segundos  
- **`-vframes N`**: N quadros no total
- **`-vsync 0`**: Desativa sincronização

### Qualidade PNG
- **`-compression_level 6`**: Equilíbrio entre tamanho/velocidade
- **`%04d.png`**: Numeração com 4 dígitos

## 💡 Dicas Práticas

1. **Teste primeiro com poucos quadros**: Use `-vframes 10` para validar
2. **Ajuste a similaridade**: Comece com `0.1` e aumente se necessário
3. **Para sprites**: `fps=1-5` geralmente é suficiente
4. **Use nomes organizados**: `sprite_%04d.png` para facilitar ordenação
5. **Verifique a qualidade da fonte**: Evite fontes comprimidas para chroma key limpo
6. **Processamento em lote**: Use scripts para múltiplos arquivos

## 🔧 Cenários Avançados

### Extração Seletiva de Quadros
```bash
# Extrai apenas quadros-chave
ffmpeg -i video.mp4 -vf "select=eq(pict_type\,I)" -vsync 0 %08d.png

# Extrai quadros com movimento
ffmpeg -i video.mp4 -vf "select=gt(scene\,0.3)" -vsync 0 %08d.png
```

### Otimização de Qualidade
```bash
# Preservação de alta qualidade
ffmpeg -i input.gif -vf "colorkey=0x000000:0.1:0.5" -compression_level 0 %08d.png

# Otimização de tamanho
ffmpeg -i input.gif -vf "colorkey=0x000000:0.1:0.5" -compression_level 9 %08d.png
```

Este guia fornece desde configurações básicas até avançadas para criação eficiente de sprites de animação!