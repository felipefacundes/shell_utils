split_with_7z() {
cat <<'EOF' | less -R -i
# To split a large file into smaller parts without compression using 7z, you can use the following command:
-----------------------------------------------------------------------------------------------------------
# Para dividir um arquivo grande em partes menores sem compressão usando o 7z, você pode usar o seguinte comando:

Without compression:
---------------
Sem compressão:

$ 7z a -ttar -v1700m FILE_FOLDER
--------------------------------
$ 7z a -ttar -v1700m PASTA_DO_ARQUIVO

With simple, fast, and effective compression:
---------------------------------------------
Com compressão simples, rápida e eficaz:

$ 7z a -t7z -mx=1 -m0=LZMA2 -md=256k -mfb=32 -ms=32m -mmt=4 -v1700m FILE_FOLDER
-------------------------------------------------------------------------------
$ 7z a -t7z -mx=1 -m0=LZMA2 -md=256k -mfb=32 -ms=32m -mmt=4 -v1700m PASTA_DO_ARQUIVO

1. 7z: Is the main command of 7-Zip for file manipulation.
----------------------------------------------------------
1. 7z: É o comando principal do 7-Zip para manipular arquivos.

2. a: This is the command to "add" files to a target archive.
-------------------------------------------------------------
2. a: Este é o comando para "adicionar" arquivos a um arquivo de destino.

3. -t7z: Specifies the file type as 7z. Thus, the resulting file will be a .7z file.
------------------------------------------------------------------------------------
3. -t7z: Especifica o tipo de arquivo como 7z. Portanto, o arquivo resultante será um arquivo .7z.

4. -mx=1: Sets the compression level to 1. In 7-Zip, compression levels range from 1 to 9, where 1 is the fastest and 
9 is the slowest/best compression. Using 1 sets the compression level to the fastest.
-------------------------------------------------------------------------------------
4. -mx=1: Define o nível de compressão para 1. No 7-Zip, os níveis de compressão variam de 1 a 9, onde 1 é o mais rápido
e 9 é o mais lento/melhor compressão. Ao usar 1, você está definindo o nível de compressão para o mais rápido.

5. -m0=LZMA2: Specifies the compression method as LZMA2. LZMA2 is an enhanced version of the LZMA algorithm 
used for compression in 7-Zip.
------------------------------
5. -m0=LZMA2: Especifica o método de compressão como LZMA2. LZMA2 é uma versão melhorada do algoritmo LZMA 
usado para compressão no 7-Zip.

6. -md=256k: Sets the dictionary size to 256 KB. The dictionary is a crucial part of the compression algorithm 
that stores matching strings for better compression.
----------------------------------------------------
6. -md=256k: Define o tamanho do dicionário para 256 KB. O dicionário é uma parte crucial do algoritmo de compressão que 
armazena strings correspondentes para melhor compressão.

7. -mfb=32: Sets the number of bits for look-ahead to 32. Look-ahead is used to determine string matches in the dictionary.
---------------------------------------------------------------------------------------------------------------------
7. -mfb=32: Define o número de bits para o look-ahead para 32. O look-ahead é usado para determinar a correspondência 
de strings no dicionário.

8. -ms=32m: Sets the solid block size to 32 MB. In 7-Zip, compression is done in blocks, and setting a larger 
solid block size can improve compression.
-----------------------------------------
8. -ms=32m: Define o tamanho do bloco sólido para 32 MB. No 7-Zip, a compressão é realizada em blocos, e definir um 
tamanho maior para o bloco sólido pode melhorar a compressão.

9. -mmt=4: Enables multithreaded compression with 4 threads. This means compression will run in parallel 
using 4 threads to enhance speed.
---------------------------------
9. -mmt=4: Ativa a compressão multithread com 4 threads. Isso significa que a compressão será executada em paralelo 
usando 4 threads para melhorar a velocidade.

10. -v1700m: Specifies that the resulting file should be split into volumes of 1700 MB. This means if the 
resulting file is larger than 1700 MB, it will be split into smaller files of 1700 MB each.
-------------------------------------------------------------------------------------------
10. -v1700m: Especifica que o arquivo resultante deve ser dividido em volumes de 1700 MB. Isso significa que se o 
arquivo resultante for maior do que 1700 MB, ele será dividido em arquivos menores de 1700 MB cada.

11. FILE_FOLDER: Is the name of the file or directory you wish to compress.
---------------------------------------------------------------------------
11. PASTA_DO_ARQUIVO: É o nome do arquivo ou diretório que você deseja compactar.

In summary, this command creates a .7z file with the name FILE_FOLDER, using the LZMA2 compression method 
with various settings optimized for speed and splitting the resulting file into 1700 MB volumes.
------------------------------------------------------------------------------------------------
Resumindo, este comando está criando um arquivo .7z com o nome PASTA_DO_ARQUIVO, usando o método de compressão LZMA2 
com várias configurações otimizadas para a velocidade e dividindo o arquivo resultante em volumes de 1700 MB.
EOF
}

7z_help_pt_br() {
cat <<'EOF' | less -R -i
7-Zip (z) 23.01 (x64) : Direitos autorais (c) 1999-2023 Igor Pavlov : 2023-06-20
64-bit locale=pt_BR.UTF-8 Threads:12 OPEN_MAX:1048576, ASM

Uso: 7zz <comando> [<opções>...] <nome_do_arquivo> [<nomes_dos_arquivos>...] [@lista_de_arquivos]

<Comandos>
  a : Adicionar arquivos ao arquivo compactado
  b : Benchmark
  d : Excluir arquivos do arquivo compactado
  e : Extrair arquivos do arquivo compactado (sem usar nomes de diretório)
  h : Calcular valores hash para arquivos
  i : Mostrar informações sobre formatos suportados
  l : Listar conteúdo do arquivo compactado
  rn : Renomear arquivos no arquivo compactado
  t : Testar integridade do arquivo compactado
  u : Atualizar arquivos no arquivo compactado
  x : Extrair arquivos com caminhos completos

<Opções>
  -- : Parar de interpretar opções e lista de arquivos
  -ai[r[-|0]]{@lista_de_arquivos|!comodin} : Incluir arquivos compactados
  -ax[r[-|0]]{@lista_de_arquivos|!comodin} : Excluir arquivos compactados
  -ao{a|s|t|u} : definir modo de sobrescrever
  -an : desativar campo nome_do_arquivo
  -bb[0-3] : definir nível de log de saída
  -bd : desativar indicador de progresso
  -bs{o|e|p}{0|1|2} : definir fluxo de saída para linha de saída/erro/progresso
  -bt : mostrar estatísticas de tempo de execução
  -i[r[-|0]]{@lista_de_arquivos|!comodin} : Incluir nomes de arquivos
  -m{Parâmetros} : definir método de compressão
    -mmt[N] : definir número de threads da CPU
    -mx[N] : definir nível de compressão: -mx1 (mais rápido) ... -mx9 (ultra)
  -o{Diretório} : definir diretório de saída
  -p{Senha} : definir Senha
  -r[-|0] : Recursivamente procurar subdiretórios pelo nome
  -sa{a|e|s} : definir modo de nome do arquivo compactado
  -scc{UTF-8|WIN|DOS} : definir conjunto de caracteres para entrada/saída de console
  -scs{UTF-8|UTF-16LE|UTF-16BE|WIN|DOS|{id}} : definir conjunto de caracteres para listagem de arquivos
  -scrc[CRC32|CRC64|SHA1|SHA256|*] : definir função hash para comandos x, e, h
  -sdel : excluir arquivos após compressão
  -seml[.] : enviar arquivo por e-mail
  -sfx[{nome}] : Criar arquivo compactado SFX
  -si[{nome}] : ler dados da entrada padrão
  -slp : definir modo de Páginas Grandes
  -slt : mostrar informações técnicas para o comando l (Listar)
  -snh : armazenar links rígidos como links
  -snl : armazenar links simbólicos como links
  -sni : armazenar informações de segurança NT
  -sns[-] : armazenar fluxos alternativos NTFS
  -so : escrever dados na saída padrão
  -spd : desativar correspondência com curinga para nomes de arquivos
  -spe : eliminar duplicação de pasta raiz para o comando de extração
  -spf[2] : usar caminhos de arquivo totalmente qualificados
  -ssc[-] : definir modo de caixa sensível
  -sse : parar de criar arquivo compactado, se não conseguir abrir algum arquivo de entrada
  -ssp : não alterar a Hora de Acesso dos arquivos de origem durante a compactação
  -ssw : comprimir arquivos compartilhados
  -stl : definir carimbo de data/hora do arquivo a partir do arquivo modificado mais recentemente
  -stm{MáscaraHex} : definir máscara de afinidade de thread da CPU (número hexadecimal)
  -stx{Tipo} : excluir tipo de arquivo compactado
  -t{Tipo} : Definir tipo de arquivo compactado
  -u[-][p#][q#][r#][x#][y#][z#][!novoNomeDoArquivo] : Opções de atualização
  -v{Tamanho}[b|k|m|g] : Criar volumes
  -w[{caminho}] : atribuir diretório de trabalho. Caminho vazio significa um diretório temporário
  -x[r[-|0]]{@lista_de_arquivos|!comodin} : Excluir nomes de arquivos
  -y : assumir Sim para todas as consultas
EOF
}