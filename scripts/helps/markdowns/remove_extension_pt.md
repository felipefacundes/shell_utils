# Manipulação de Nomes de Arquivo em Shell Script

Este guia apresenta técnicas profissionais para manipulação de nomes de arquivo em shell scripts, com foco especial na remoção de extensões de arquivo. Cada método inclui exemplos práticos com entradas e saídas claramente demonstradas.

## 📋 Sumário

- [Visão Geral](#visão-geral)
- [Métodos de Remoção de Extensão](#métodos-de-remoção-de-extensão)
  - [Usando Parameter Expansion](#1-usando-parameter-expansion-recomendado)
  - [Usando comando `cut`](#2-usando-comando-cut)
  - [Usando comando `awk`](#3-usando-comando-awk)
  - [Usando comando `sed`](#4-usando-comando-sed)
  - [Usando comando `basename`](#5-usando-comando-basename)
- [Manipulação Avançada com Parameter Expansion](#manipulação-avançada-com-parameter-expansion)
- [Comparação de Métodos](#comparação-de-métodos)
- [Boas Práticas](#boas-práticas)
- [Referências](#referências)

## Visão Geral

Em shell scripting, frequentemente precisamos extrair diferentes partes de um nome de arquivo - seja o nome base sem extensão, apenas a extensão, ou manipular caminhos completos. Este documento compila as principais técnicas disponíveis com exemplos práticos.

## Métodos de Remoção de Extensão

### 1. Usando Parameter Expansion (Recomendado)

**Vantagens:** Nativo do shell, mais rápido, não depende de executáveis externos

```bash
#!/usr/bin/env bash

# Exemplo 1: Arquivo simples
filename="documento.txt"

# Remove a última extensão (remove o padrão mais curto a partir do final)
name="${filename%.*}"
echo "$name"  # Output: documento

# Remove todas as extensões (remove o padrão mais longo a partir do final)  
name="${filename%%.*}"
echo "$name"  # Output: documento

# Obter apenas a extensão (remove o padrão mais longo a partir do início)
extension="${filename##*.}"
echo "$extension"  # Output: txt

# Exemplo 2: Arquivo com múltiplas extensões
filename="arquivo.backup.tar.gz"

echo "${filename%.*}"     # Output: arquivo.backup.tar
echo "${filename%%.*}"    # Output: arquivo  
echo "${filename##*.}"    # Output: gz
```

### 2. Usando comando `cut`

```bash
#!/usr/bin/env bash

# Exemplo 1: Arquivo simples
filename="relatorio.pdf"

# Remove extensão usando delimitador ponto (primeiro campo)
name=$(echo "$filename" | cut -f1 -d'.')
echo "$name"  # Output: relatorio

# Exemplo 2: Arquivo com múltiplos pontos
filename="projeto.v1.backup.zip"

name=$(echo "$filename" | cut -f1 -d'.')
echo "$name"  # Output: projeto (apenas o primeiro campo!)
```

**⚠️ Atenção:** Este método pode ter problemas com arquivos que contêm múltiplos pontos, pois sempre retorna apenas o primeiro campo.

### 3. Usando comando `awk`

```bash
#!/usr/bin/env bash

# Exemplo 1: Extrair última extensão
filename="dados.tar.bz2"

# Obter a última extensão (último campo)
extension=$(echo "$filename" | awk -F. '{print $NF}')
echo "$extension"  # Output: bz2

# Exemplo 2: Extrair nome sem extensão
filename="config.backup.conf"

# Obter todos os campos exceto o último
name=$(echo "$filename" | awk -F. '{
    if (NF > 1) {
        for(i=1; i<NF; i++) {
            if (i > 1) printf "."
            printf $i
        }
        printf "\n"
    } else {
        print $0
    }
}')
echo "$name"  # Output: config.backup
```

### 4. Usando comando `sed`

```bash
#!/usr/bin/env bash

# Exemplo 1: Extrair extensão
filename="imagem.png"

# Extrair apenas a extensão (tudo após o último ponto)
extension=$(echo "$filename" | sed 's/.*\.//')
echo "$extension"  # Output: png

# Exemplo 2: Remover extensão específica
filename="arquivo.txt"

# Remover extensão de 3 caracteres (menos preciso)
name=$(echo "$filename" | sed 's/\(.*\).../\1/')
echo "$name"  # Output: arquivo

# Método mais robusto para remover extensão
name=$(echo "$filename" | sed 's/\.[^.]*$//')
echo "$name"  # Output: arquivo
```

### 5. Usando comando `basename`

```bash
#!/usr/bin/env bash

# Exemplo 1: Extensão conhecida
filename="site.html"

# Remove extensão específica
name=$(basename "$filename" .html)
echo "$name"  # Output: site

# Exemplo 2: Extensão dinâmica
filename="documento.docx"

# Para extensões dinâmicas (menos comum)
name=$(basename "$filename" ".${filename##*.}")
echo "$name"  # Output: documento

# Exemplo 3: Obter nome do arquivo de um caminho completo
path="/home/usuario/documentos/arquivo.txt"
name=$(basename "$path")
echo "$name"  # Output: arquivo.txt
```

## Manipulação Avançada com Parameter Expansion

Aqui está um exemplo completo demonstrando o poder da parameter expansion nativa do shell:

```bash
#!/usr/bin/env bash

# Vamos analisar este caminho complexo
path="this.path/with.dots/in.path.name/filename.tar.gz"

echo "=== ANÁLISE DO CAMINHO COMPLETO ==="

# 1. Obter diretório (remove a parte do arquivo)
# Remove a correspondência final mais curta de / seguido por qualquer coisa
dirname="${path%/*}"
echo "Diretório: $dirname"
# Output: this.path/with.dots/in.path.name

# 2. Obter nome base (remove todos os diretórios)
# Remove a correspondência inicial mais longa de qualquer coisa seguida por /
basename="${path##*/}"
echo "Nome do arquivo: $basename"
# Output: filename.tar.gz

# 3. Remover apenas a última extensão
# Remove a correspondência final mais curta de ponto seguido por qualquer coisa
oneextless="${basename%.*}"
echo "Sem última extensão: $oneextless"
# Output: filename.tar

# 4. Remover todas as extensões
# Remove a correspondência final mais longa de ponto seguido por qualquer coisa
noext="${basename%%.*}"
echo "Sem nenhuma extensão: $noext"
# Output: filename

# 5. Obter apenas a extensão principal
extension="${basename##*.}"
echo "Extensão principal: $extension"
# Output: gz

echo "===================================="
```

**Saída completa do exemplo:**
```
=== ANÁLISE DO CAMINHO COMPLETO ===
Diretório: this.path/with.dots/in.path.name
Nome do arquivo: filename.tar.gz
Sem última extensão: filename.tar
Sem nenhuma extensão: filename
Extensão principal: gz
====================================
```

### 📚 Explicação Detalhada dos Operadores

| Operador | Significado | Exemplo | Resultado |
|----------|-------------|---------|-----------|
| `${var%pattern}` | Remove o **padrão mais curto** do **final** | `"file.txt" %.*` | `"file"` |
| `${var%%pattern}` | Remove o **padrão mais longo** do **final** | `"file.tar.gz" %%.*` | `"file"` |
| `${var#pattern}` | Remove o **padrão mais curto** do **início** | `"path/file" #*/` | `"file"` |
| `${var##pattern}` | Remove o **padrão mais longo** do **início** | `"/path/to/file" ##*/` | `"file"` |

## Comparação de Métodos

| Método | Velocidade | Portabilidade | Complexidade | Casos Especiais | Exemplo de Uso |
|--------|------------|---------------|--------------|-----------------|----------------|
| **Parameter Expansion** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ | Lida bem com múltiplos pontos | `${name%.*}` |
| `cut` | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐ | Problemas com múltiplos pontos | `cut -f1 -d'.'` |
| `awk` | ⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | Flexível mas complexo | `awk -F. '{print $NF}'` |
| `sed` | ⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | Regex pode ser complexa | `sed 's/.*\.//'` |
| `basename` | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐ | Apenas para extensões conhecidas | `basename file.txt .txt` |

## 📝 Casos de Uso Práticos

### Caso 1: Processamento de Arquivos em Lote
```bash
#!/usr/bin/env bash

# Processar todos os arquivos .jpg em um diretório
for file in *.jpg; do
    # Remove extensão para criar nome base
    base_name="${file%.jpg}"
    
    # Cria versão miniatura
    convert "$file" -resize 50% "${base_name}_thumb.jpg"
    
    echo "Processado: $file -> ${base_name}_thumb.jpg"
    # Input: foto.jpg → Output: foto_thumb.jpg
done
```

### Caso 2: Backup com Timestamp
```bash
#!/usr/bin/env bash

# Backup de arquivo de configuração
config_file="application.conf"
timestamp=$(date +%Y%m%d_%H%M%S)

# Remove extensão e adiciona timestamp
backup_name="${config_file%.conf}_backup_${timestamp}.conf"

cp "$config_file" "$backup_name"
echo "Backup criado: $backup_name"
# Input: application.conf → Output: application_backup_20231201_143022.conf
```

### Caso 3: Organização de Downloads
```bash
#!/usr/bin/env bash

# Classificar arquivo por extensão
filename="documento_fiscal.pdf"

# Extrair extensão
extension="${filename##*.}"

# Mover para diretório correspondente
mkdir -p "$extension"
mv "$filename" "$extension/"
echo "Movido $filename para diretório $extension/"
```

## Boas Práticas

1. **Prefira Parameter Expansion:** É a solução mais eficiente e portável
2. **Use aspas com variáveis:** Sempre use `"$filename"` em vez de `$filename`
3. **Considere casos extremos:** Arquivos sem extensão, múltiplos pontos, pontos no diretório
4. **Teste seus scripts:** Verifique com diferentes padrões de nomes de arquivo

```bash
#!/usr/bin/env bash

# Função robusta para uso geral
get_filename_without_extension() {
    local filepath="$1"
    local filename="${filepath##*/}"
    echo "${filename%%.*}"
}

# Teste com vários casos
get_filename_without_extension "/path/to/arquivo.tar.gz"        # Output: arquivo
get_filename_without_extension "documento.txt"                  # Output: documento  
get_filename_without_extension "config.backup.conf"             # Output: config
get_filename_without_extension "arquivo_sem_extensao"           # Output: arquivo_sem_extensao
```

## Referências

- [Stack Overflow: Remove File Extension](https://stackoverflow.com/questions/12152626/how-can-i-remove-the-extension-of-a-filename-in-a-shell-script)
- [DelftStack: Remove File Extension Using Shell](https://www.delftstack.com/howto/linux/remove-file-extension-using-shell/)
- [Bash Parameter Expansion Documentation](https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html)

---

**💡 Dica Profissional:** Para máxima portabilidade e performance, recomenda-se o uso de **Parameter Expansion** sempre que possível, pois é uma funcionalidade built-in do shell e não depende de executáveis externos.