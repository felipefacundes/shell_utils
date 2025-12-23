# Redimensionamento Forçado de Imagens e Vídeos: ImageMagick vs FFmpeg

## 📌 Introdução

Este guia aborda como forçar o redimensionamento exato (ignorando a proporção original) usando **ImageMagick** e **FFmpeg**, destacando as diferenças de sintaxe e comportamento entre as duas ferramentas.

---

## 🖼️ ImageMagick

### Forçar Redimensionamento Exato
Por padrão, o ImageMagick mantém a proporção da imagem (aspect ratio). Para forçar o redimensionamento exato, use o caractere de exclamação (`!`) após as dimensões.

**Exemplo básico:**
```bash
magick imagem.jpg -resize 300x200! resultado.jpg
```

### ⚠️ Cuidados com o Terminal
O ponto de exclamação é um caractere especial em terminais (Bash, Zsh, etc.). Para evitar erros:

1. **Usar aspas:**
   ```bash
   magick imagem.jpg -resize "300x200!" resultado.jpg
   # ou
   magick imagem.jpg -resize '300x200!' resultado.jpg
   ```

2. **Usar escape (barra invertida):**
   ```bash
   magick imagem.jpg -resize 300x200\! resultado.jpg
   ```

### 🎯 Outros Sinalizadores de Redimensionamento

| Sinalizador | Descrição |
|------------|-----------|
| `^` (Circunflexo) | Redimensiona para preencher a área mínima, podendo sobrar imagem nas bordas (útil para cortes posteriores) |
| `>` (Maior que) | Redimensiona apenas se a imagem original for **maior** que as dimensões especificadas |
| `<` (Menor que) | Redimensiona apenas se a imagem original for **menor** que as dimensões especificadas |

---

## 🎬 FFmpeg

### Forçar Redimensionamento Exato
**Importante:** O FFmpeg **não utiliza** o símbolo `!` para forçar redimensionamento. O comportamento padrão ao definir ambas as dimensões já força o tamanho exato (com distorção, se necessário).

**Comando básico:**
```bash
ffmpeg -i entrada.mp4 -vf "scale=300:200" saída.mp4
```

### 🔧 Garantir Proporção de Pixel 1:1
Para garantir que os pixels fiquem exatamente no formato solicitado (evitando que players ajustem a proporção), adicione `setsar=1`:
```bash
ffmpeg -i entrada.mp4 -vf "scale=300:200,setsar=1" saída.mp4
```

### 📏 Preservar Proporção (Comportamento Equivalente ao ImageMagick sem `!`)
Use `-1` (ou `-2` para garantir número par, exigido por alguns codecs) para que o FFmpeg calcule uma das dimensões automaticamente:

**Exemplo (largura fixa em 300px, altura automática):**
```bash
ffmpeg -i entrada.mp4 -vf "scale=300:-1" saída.mp4
```

**Exemplo (altura fixa em 200px, largura automática):**
```bash
ffmpeg -i entrada.mp4 -vf "scale=-1:200" saída.mp4
```

---

## 📊 Resumo das Diferenças

### ImageMagick
| Comando | Comportamento |
|---------|---------------|
| `300x200` | Mantém proporção, encaixa dentro das dimensões |
| `300x200!` | **Força** dimensões exatas (distorce se necessário) |

### FFmpeg
| Comando | Comportamento |
|---------|---------------|
| `scale=300:-1` | Mantém proporção, calcula altura automaticamente |
| `scale=300:200` | **Força** dimensões exatas (distorce se necessário) |

---

## 🔗 Referências

- [ImageMagick: Command-line Basics - Resizing Images](https://imagemagick.org/script/command-line-processing.php)
- [ImageMagick Forums: How to force resize an image](https://imagemagick.org/discourse-server/)
- [FFmpeg Documentation: Scaling filter](https://ffmpeg.org/ffmpeg-filters.html#scale)

---

## 📝 Notas

- **ImageMagick:** Use `!` para forçar dimensões exatas, mas lembre-se de escapar o caractere no terminal
- **FFmpeg:** O comportamento padrão de `scale=LARGURA:ALTURA` já força o redimensionamento exato
- Para evitar problemas de compatibilidade com codecs, use valores pares no FFmpeg (ex: `scale=300:200` em vez de `scale=301:201`)

---

**Última atualização:** Documento baseado em pesquisas e documentação oficial das ferramentas.