rar_help_pt-br() {
    cat <<'EOF'
RAR 6.24 Direitos de autor (c) 1993-2023 Alexander Roshal 3 de outubro de 2023
Versão de teste Digite 'rar -?' para obter ajuda

Uso: rar <comando> -<comando 1> -<comando N> <arquivo> <arquivos...>
               <@listfiles...> <path_to_extract/>

<Comandos>
  a Adicionar ficheiros ao arquivo
  c Adicionar comentário de arquivo
  ch Alterar parâmetros de arquivo
  cw Escrever comentário de arquivo no ficheiro
  d Eliminar ficheiros do arquivo
  e Extrair ficheiros sem caminhos arquivados
  f Atualizar ficheiros no arquivo
  i[par]=<str> Procurar cadeia de caracteres nos arquivos
  k Arquivo de bloqueio
  l[t[a],b]     Listar o conteúdo do arquivo [technical[all], bare]
  m[f] Mover para o arquivo [apenas ficheiros]
  p Imprimir ficheiro para stdout
  r Arquivo de reparação
  rc Reconstruir volumes em falta
  rn Mudar o nome dos ficheiros arquivados
  rr[N] Adicionar o registo de recuperação de dados
  rv[N] Criar volumes de recuperação
  s[nome|-] Converter arquivo de ou para SFX
  t Testar ficheiros de arquivo
  u Atualizar ficheiros no arquivo
  v[t[a],b]     Lista detalhada do conteúdo do arquivo [technical[all],bare]
  x Extrair ficheiros com o caminho completo

<Switches>
  - Parar a leitura dos interruptores
  @[+] Desativar [ativar] listas de ficheiros
  ad[1,2] Trajeto alternativo de destino
  ag[formato] Gerar o nome do arquivo utilizando a data atual
  ai Ignorar atributos do ficheiro
  am[s,r] Nome e hora do arquivo [guardar, restaurar]
  ap<path> Definir caminho dentro do arquivo
  como Sincronizar o conteúdo do arquivo
  c- Desativar a apresentação de comentários
  cfg- Desativar a configuração de leitura
  cl Converter nomes em minúsculas
  cu Converter nomes em maiúsculas
  df Eliminar ficheiros após o arquivamento
  dh Abrir ficheiros partilhados
  ds Desativar a ordenação de nomes para o arquivo sólido
  dw Limpar ficheiros após o arquivamento
  e[+]<attr> Definir atributos de exclusão e inclusão de ficheiros
  ed Não adicionar directórios vazios
  ep Excluir caminhos dos nomes
  ep1 Excluir o diretório base dos nomes
  ep3 Expandir os caminhos até ao fim, incluindo a letra da unidade
  ep4<path> Excluir o prefixo do caminho dos nomes
  f Limpar ficheiros
  hp[password] Encriptar tanto os dados como os cabeçalhos dos ficheiros
  ht[b|c] Selecionar o tipo de hash [BLAKE2,CRC32] para a soma de verificação do ficheiro
  id[c,d,n,p,q] Apresentar ou desativar mensagens
  ierr Envia todas as mensagens para stderr
  ilog[nome] Registar erros num ficheiro
  inul Desativar todas as mensagens
  isnd[-] Controlar os sons de notificação
  iver Mostrar o número da versão
  k Arquivo de bloqueio
  kb Manter ficheiros extraídos partidos
  log[f][=nome] Escreve nomes no ficheiro de registo
  m<0...5> Definir o nível de compressão (0-store...3-default...5-maximal)
  ma[4|5] Especificar uma versão do formato de arquivo
  mc<par> Definir parâmetros avançados de compressão
  md<n>[k,m,g] Tamanho do dicionário em KB, MB ou GB
  me[par] Definir parâmetros de encriptação
  ms[ext;ext] Especificar os tipos de ficheiros a armazenar
  mt<threads> Definir o número de threads
  n<file> Filtrar adicionalmente os ficheiros incluídos
  n@ Ler máscaras de filtro adicionais a partir de stdin
  n@<lista> Ler máscaras de filtro adicionais do ficheiro de lista
  o[+|-] Definir o modo de substituição
  oh Guardar ligações rígidas como a ligação em vez do ficheiro
  oi[0-4][:min] Guardar ficheiros idênticos como referências
  ol[a] Processar ligações simbólicas como a ligação [caminhos absolutos]
  op<path> Definir o caminho de saída para os ficheiros extraídos
  ou Mudar automaticamente o nome dos ficheiros
  ow Guardar ou restaurar o proprietário e o grupo do ficheiro
  p[password] Definir palavra-passe
  qo[-|+] Adicionar informação de abertura rápida [nenhum|força]
  r Recursar subdirectórios
  r- Desativar a recursão
  r0 Recursar subdirectórios apenas para nomes curinga
  rr[N] Adicionar registo de recuperação de dados
  rv[N] Criar volumes de recuperação
  s[<N>,v[-],e] Criar um arquivo sólido
  s- Desativar o arquivamento sólido
  sc<chr>[obj] Especificar o conjunto de caracteres
  sfx[nome] Criar arquivo SFX
  si[nome] Ler dados da entrada padrão (stdin)
  sl<size> Processa ficheiros com tamanho inferior ao especificado
  sm<size> Processa ficheiros com tamanho superior ao especificado
  t Testar ficheiros após o arquivamento
  ta[mcao]<d> Ficheiros de processo modificados após <d> data AAAAMMDDHHMMSS
  tb[mcao]<d> Ficheiros de processo modificados antes de <d> data AAAAMMDDHHMMSS
  tk Manter a hora de arquivo original
  tl Definir a hora do arquivo para o ficheiro mais recente
  tn[mcao]<t> Processar ficheiros mais recentes do que <t> tempo
  to[mcao]<t> Processar ficheiros mais antigos do que <t> tempo
  ts[m,c,a,p] Guardar ou restaurar o tempo (modificação, criação, acesso, preservação)
  u Atualizar ficheiros
  v<size>[k,b] Criar volumes com tamanho=<size>*1000 [*1024, *1]
  ver[n] Controlo da versão do ficheiro
  vn Utilizar o esquema de nomenclatura de volumes de estilo antigo
  vp Pausa antes de cada volume
  w<path> Atribuir diretório de trabalho
  x<file> Excluir o ficheiro especificado
  x@ Ler nomes de ficheiros a excluir de stdin
  x@<list> Excluir ficheiros listados no ficheiro de lista especificado
  y Assumir que sim em todas as perguntas
  z[ficheiro] Ler o comentário do arquivo a partir do ficheiro
EOF
}