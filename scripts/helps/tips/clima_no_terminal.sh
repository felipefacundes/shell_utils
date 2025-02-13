clima()
{
(
cat <<'EOF'
=====================================================
# PREVISÃO DO TEMPO NA LINHA DE COMANDO - GNU+LINUX #
================ USANDO WTTR.IN E CURL ==============

== APRESENTAÇÃO E REQUISITOS ==

O Wttr.in é um serviço de previsão do tempo orientado para o console, que suporta vários métodos de representação de informações, como sequências ANSI orientadas ao terminal para clientes HTTP do console (curl), HTML para navegadores da web (httpie) ou PNG para visualizadores gráficos (wget).

O Wttr.in usa o pacote Wego do mesmo desenvolvedor para geração da visualização e acesso à várias fontes de dados para informações sobre previsão do tempo. Se você quiser opções adicionais, como por exemplo ver mais do que três dias de previsão do tempo, instale o pacote "wego". Depois você terá que criar um arquivo de configuração, fazer um cadastro em um site de previsão de tempo (forecast.io ou openweathermap) para conseguir uma chave de API... Um pouco complicado, porém pode te dar  um ótimo resultado se você precisa realmente de uma previsão do tempo extendida e com mais opções.

Como o desenvolvedor Chubin já oferece o site do Wttr.in com algumas funções do Wego,  vamos aderir ao método mais simples. O Curl é uma ferramenta para transferir dados de/para um servidor. Muito provavelmente, ele já foi instalado no seu computador. Opcionalmente, se você quiser poder baixar uma imagem PNG da previsão do tempo do Wttr.in, vai precisar de um outro pacote chamado "wget". Para instalá-los:

$ sudo pacman -S curl wget


== MODOS DE USO ==

= COM NOME DO LOCAL =
Em um terminal de linha de comando, digite o seguinte  mudando o nome do local para o da sua cidade (pode ser com letras minúsculas somente).
Se a cidade tiver nome composto, use um + no lugar do espaço; também *não* utilize acentos.

$  curl wttr.in/rio+de+janeiro\?lang=pt-br


Você poderá omitir "?lang=pt" e verificar se no seu sistema ele não vai automaticamente exibir a previsão do tempo em Português.
Se você omitir o nome do local, receberá a previsão do tempo da sua localização atual, com base no seu endereço IP. Tente:

$  curl wttr.in


A previsão do tempo é ao vivo, ou seja, é constantemente atualizada.

= COM SIGLA DOS AEROPORTOS =
Também poderá usar siglas de aeroportos de 3 letras para obter as informações sobre o tempo em um determinado aeroporto:

$ curl wttr.in/cwb\?n
(Aeroporto Internacional de Curitiba, Paraná)

$ curl wttr.in/mao
(Aeroporto Internacional de Manaus, Amazonas)

= COM PALAVRA CHAVE =
Se você quiser usar alguma localização geográfica (não apenas uma cidade) (por exemplo, pode ser um lugar em uma cidade, um nome de montanha, um local especial, etc.), você deve colocar ~ antes de nome. Isso significa que o nome do local deve vai ser pesquisado antes de retornar a previsão do tempo:

$ curl wttr.in/~Pacaembu\?n\&lang=pt-br

$ curl wttr.in/~Supremo+Tribunal+Federal\?nq\&lang=pt-br

$ curl wttr.in/~Vostok+Station

$ curl wttr.in/~Kilimanjaro

= VERIFICAR FASE LUNAR =
A fase da lua é igual para todos no globo terrestre (mais ou menos). A diferença é que no Sul ela cresce da esquerda para direita e no Norte da direita para esquerda, mas os nomes das fases lunares são iguais.

$ curl wttr.in/moon\?lang=pt-br

= BAIXAR UMA IMAGEM PNG COM A PREVISÃO =
Para baixar uma imagem no diretório de onde você se encontra no terminal, use o Wget e adicione ".png" depois do nome do lugar ou da sigla de aeroporto. Aqui, vamos até a pasta de Downloads e então baixar duas previsões do tempo:

$ cd /home/$USER/Downloads

$ wget wttr.in/rio+de+janeiro.png\?nq\&lang=pt

$ wget wttr.in/~Pacaembu.png

$ wget wttr.in/moon.png\?lang=pt

== DICA - ADICIONAR ATALHO NO BASHRC ==

Para você não ter que digitar a sintaxe toda vez, depois de definidas as suas preferências, faça atalhos/alias para usar no terminal e te economizar tempo e memória!

Abra o arquivo .bashrc dentro da sua pasta de usuário (ele estará oculto pois começa com um ponto) com um editor de texto de sua preferência. Por exemplo:

$ mousepad /home/$USER/.bashrc

No final do arquivo, adicionar o atalho (alias). Lembre-se de modificar o comando para ficar com as opções desejadas na sua preferência. Também poderá alterar o atalho que sugiro aqui como "ptempo" e um outro para verificar as fases da lua "faselunar":

alias ptempo='curl wttr.in\?nq\&lang=pt'
alias faselunar='curl wttr.in/moon\?lang=pt'

O alias acima vai sempre usar a sua localização atual do IP. Se você quiser verificar mais de um local, adicione atalhos específicos, por exemplo, uma atalho "tempoctba" e um outro atalho "temposp":

alias tempoctba='curl wttr.in/Curitiba\?nq\&lang=pt-br'
alias temposp='curl wttr.in/Sao+Paulo\?nq\&lang=pt-br'
alias temposp-png='wget wttr.in/Sao+Paulo\?nq\&lang=pt-br'

Faça log-out e log-in para ativar os atalhos ou rode o comando:

$ source /home/$USER/.bashrc

Assim, quando você digitar

$ temposp

O alias do seu .bashrc vai rodar o comando correspondente "curl wttr.in/Sao+Paulo\?nq\&lang=pt-br".

====================================================================================================

Está na hora de deixar isso aqui mais legal..

Somente se a fonte do seu terminal estiver configurado para usar Emoji
( do contrário vai sair uns blocos no lugar do emojis):

Algumas opções legais já pré-configuradas...

$ curl wttr.in/Sao_Paulo?format=1
⛅️ +17°C

$ curl wttr.in/Sao_Paulo?format=2
⛅️ ?️+17°C ?️↑13 km/h

$ curl wttr.in/Sao_Paulo?format=3
são paulo: ⛅️ +17°C

$ curl wttr.in/Sao_Paulo?format=4
são paulo: ⛅️ ?️+17°C ?️↑13 km/h

Pra customizar mais ainda, seguir esse exemplo:

$ curl wttr\.in/Paris?format='%l:+%c+%t,+%w+%m' 

Um pouco mais de opções..

$ curl wttr.in/Sao_Paulo?0pq
 
  são paulo  
    
      \  /       Partly cloudy  
    _ /"".-.     17 °C  
      \_(   ).   ↖ 13 km/h  
      /(___(__)  10 km  
                 0.0 mm  

Mostra somente o dia de hoje.
Para ficar mais minimalista

$ curl wttr.in/Sao_Paulo?0Q 


Para ver a fase da Lua (Global):

$ curl wttr.in/moon 


Ver diferença entre a previsão para duas cidades:

$ diff -Naur <(curl -s http://wttr.in/Sao_Paulo?n ) <(curl -s http://wttr.in/Curitiba?n ) 

Algumas opções:

$ curl wttr.in/Sao_Paulo?2pqn 

0, 1 ou 2 -- quantos dias de previsão; 0 -> hoje somente
p -- desenha uma borda ( pelo que pude ver, transparente, só ocupa mais espaço )
q -- versão quieta, sem "Wheather Report"
Q -- versão super-quieta, sem "Wheather Report" e sem o nome da cidade
n -- versão estreita, somente dia e noite
M -- mostra a velocidade do Vento em metros por segundo ( m/s )

Fução pro Bashrc recomendada oficialmente, pode ser chamada por "wttr"
( mudei para ficar em português e ventos para m/s ):

wttr()
{
    # mude curitiba para sua localização atual
    local request="wttr.in/${1-Curitiba}"
    [ "$COLUMNS" -lt 125 ] && request+='?nM'
    curl -H "Accept-Language: pt-br" --compressed "$request"
}


URLs Especiais:                                     

$ curl wttr.in/:help                      # ajuda  e opções                                   
$ curl wttr.in/:bash.function       # mostra a função de bash recomendada       
$ curl wttr.in/:translation           # info sobre traduções 

Refs:
https://twitter.com/igor_chubin

== REFERÊNCIAS ==

https://github.com/chubin/wttr.in

https://github.com/schachmat/wego
EOF
) | less -R -i
}
alias tempo='clima'