function abnt_tcc {
    bcyan='\033[1;36m'
    nc='\033[0m'
    cat <<EOF | echo -e $bcyan"$(cat)"$nc | less -R -i
# Padrão ABNT para TCC (Trabalhos de conclusão de curso) no LibreOffice

--------------------------------------------------------------------------------------------------------------------------------
$bcyan# CITAÇÕES$nc

Para citações diretas longas, ou seja, àquelas com mais de 3 linhas:

Você pode ir no LibreOffice, no $bcyan"menu estilos"$nc e ir em $bcyan"gerenciar estilos"$nc, depois vá em $bcyan"Todos os estilos"$nc e procurar por citação/citações > 
clicar com o botão direito do mouse > e ir em modificar.
Se não tiver o estilo $bcyan"citações"$nc ; selecione o texto referente a citação, vá para o menu $bcyan"estilos"$nc > $bcyan"Novo estilo a partir da citação"$nc >
defina o nome para $bcyan"citações"$nc . Vá novamente no menu $bcyan"estilos"$nc > $bcyan"editar estilo"$nc > Fonte. A fonte é $bcyan"Times New Roman"$nc ou $bcyan"Arial"$nc, 
estilo: Regular, tamanho: 10. Na guia $bcyan"Recuos e Espaçamento", em $bcyan"Antes do texto"$nc o recuo é de 4cm, o restante é 0cm. Já em $bcyan"Espaçamento"$nc, se preferir, é de 1,5cm, cada. 
e em entrelinhas é $bcyan"simples"$nc. Na guia $bcyan"Alinhamento"$nc > é $bcyan"Justificado"$nc.

Qualquer dúvida veja o vídeo: https://www.youtube.com/watch?v=yuXZo1zCHUw&t=142s
--------------------------------------------------------------------------------------------------------------------------------
                                          $bcyan# TÍTULOS e ESTILOS$nc
$bcyan# CORPO DO TEXTO$nc

Para o estilo $bcyan"Corpo de Texto"$nc, tanto você pode criar um novo ou editar o existente.
O estilo $bcyan"Corpo de Texto"$nc é para todo o texto comum que não seja título ou citação, a formatação para Fonte: $bcyan"Times New Roman"$nc,
Estilo: Regular, Tamanho: 12. Na aba $bcyan"Alinhamento"$nc > é $bcyan"Justificado"$nc. Na aba "Recuo e espaçamento" é 0cm, apenas o de $bcyan"Primeira linha"$nc que é 1,25.
O Espaçamento é 0cm. Já o "entrelinhas" é de 1,5.

$bcyan# TÍTULOS$nc

Para o "Título 1" a formatação para Fonte: $bcyan"Times New Roman"$nc, Estilo: Negrito, Tamanho: 12. Na aba $bcyan"Alinhamento"$nc > é $bcyan"Centralizado"$nc.
"Efeitos da Fonte" > "Caixa": MAIÚSCULAS. Em "Recuos e espaçamento" tudo 0cm, apenas em "Embaixo do parágrafo": 1,5. Entrelinhas: 1,5. 
Em "organizador" > "Próximo estilo" > "Corpo de texto". Em "fluxo do texto", inserir quebra de linha.

Qualquer dúvida veja o vídeo: https://www.youtube.com/watch?v=SvWMXt-CRLk
--------------------------------------------------------------------------------------------------------------------------------

$bcyan# SUMÁRIO$nc

Qualquer dúvida veja o vídeo: https://www.youtube.com/watch?app=desktop&v=QG_FcSgFGOs&t=0s
--------------------------------------------------------------------------------------------------------------------------------

Mais tutoriais: https://pprjbgbo.wordpress.com/2018/09/14/formatacao-de-trabalhos-academicos-no-libreoffice/
--------------------------------------------------------------------------------------------------------------------------------
Para formatar um documento no LibreOffice de acordo com as normas da ABNT, é necessário definir as margens, o espaçamento e a fonte. 
Margens 

    As margens superior e esquerda devem ser de 3 cm
    As margens inferior e direita devem ser de 2 cm 

Espaçamento 

    O espaçamento entre linhas deve ser de 1,5 para o texto
    O espaçamento deve ser simples para os elementos pré e pós-textuais 

Fonte

    A fonte recomendada é a Times New Roman ou Arial 

O tamanho da fonte deve ser de 12 para o corpo do texto 
O tamanho da fonte deve ser de 10 para citações diretas com mais de três linhas 
--------------------------------------------------------------------------------------------------------------------------------

EOF
}