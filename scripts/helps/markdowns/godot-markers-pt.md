No Godot 4, o editor de scripts destaca automaticamente diversas palavras-chave (chamadas de *e*) quando usadas dentro de comentários (`\#`). Essas palavras são divididas em três categorias de prioridade e cor:


🔴 Crítico (Geralmente Vermelho)

Utilizadas para alertas de segurança ou erros graves que precisam de atenção imediata:

- **ALERT**

- **ATTENTION**

- **CAUTION**

- **CRITICAL**

- **DANGER**

- **SECURITY** 

🟡 Aviso (Geralmente Amarelo/Laranja)

Utilizadas para tarefas pendentes, bugs conhecidos ou partes do código que precisam de revisão: 

- **BUG**

- **DEPRECATED**

- **FIXME**

- **HACK**

- **TASK**

- **TBD** (To Be Determined)

- **TODO**

- **WARNING** 

🔵 Informativo (Geralmente Azul/Verde)

Utilizadas para notas gerais, testes ou avisos menos urgentes:

- **INFO**

- **NOTE**

- **NOTICE**

- **TEST**

- **TESTING** 

Dicas Importantes:

- **Sensibilidade ao Caso**: Estas palavras são **case-sensitive**; elas só serão destacadas se estiverem em letras maiúsculas.

- **Apenas Comentários Simples**: O destaque funciona em comentários de linha única (`\#`). Ele geralmente não funciona em strings multilinhas (`"""`), que o Godot trata tecnicamente como strings e não como comentários puros.

- **Personalização**: Você pode encontrar e editar essas listas nas **Configurações do Editor** (Editor Settings) em `Text Editor \> Theme \> Highlighting \> Comment Markers`. 
