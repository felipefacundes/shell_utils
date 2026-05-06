O `rclone` é um programa de linha de comando criado especificamente para sincronizar arquivos com a nuvem. Muitos o chamam de "*rsync for cloud storage*". Ele é a ferramenta padrão e mais confiável para essa tarefa.

Aqui está o guia passo a passo para configurar e usar o `rclone` para sincronizar uma pasta local com o Google Drive no Linux.

---

### 1. Instalar o rclone

No Ubuntu ou Debian, use o seguinte comando:
```bash
sudo apt update && sudo apt install rclone
```

---

### 2. Configurar a Conexão com o Google Drive

A configuração é interativa. Execute o comando abaixo e siga os passos:

```bash
rclone config
```

1.  Digite `n` para criar um novo "remote" (conexão remota) e pressione `Enter`.
2.  **Name**: Dê um nome para a conexão. Por exemplo, `googleDrive`. Anote-o, pois você usará depois.
3.  **Storage**: Na lista de tipos de armazenamento, digite o número correspondente a `drive` (Google Drive) e pressione `Enter`.
4.  Para as próximas perguntas sobre `client_id`, `client_secret` e `scope`, você pode deixar em branco e pressionar `Enter` para usar as opções padrão (que normalmente são **1** para acesso total e, em seguida, `Enter` para as demais).
5.  **Auto config**: Quando perguntar `Use auto config?`, digite `y` (sim). Isso abrirá uma janela no seu navegador para você fazer login na sua conta do Google e autorizar o acesso do `rclone`.
6.  Após a autorização, volte ao terminal e pressione `Enter`. Diga `n` quando perguntar sobre configurar como um "Shared Drive".
7.  Por fim, digite `q` para sair da configuração.

---

### 3. Solução de Problemas na Configuração

#### Erro: "can't make bucket without project number"

Se ao tentar sincronizar você encontrar um erro como:

```
ERROR : arquivo.txt: Failed to copy: can't make bucket without project number
```

Isso significa que o remoto foi configurado com o tipo errado: **Google Cloud Storage** em vez de **Google Drive**. O Google Cloud Storage é um serviço diferente (buckets na nuvem) e exige um número de projeto, enquanto o Google Drive comum não.

##### Como verificar o tipo do remoto

Liste os remotos configurados:
```bash
rclone listremotes
```
Isso mostrará algo como `googleDrive:` (ou o nome que você deu).

Confira o tipo do remoto:
```bash
rclone config show googleDrive:
```
Substitua `googleDrive` pelo nome do seu remoto. Procure a linha:
```
type = ???
```
Se estiver `type = google cloud storage`, está errado. O correto para o Google Drive é `type = drive`.

##### Como corrigir

Apague o remoto errado:
```bash
rclone config delete googleDrive
```

Crie um novo remoto com o tipo correto:
```bash
rclone config
```
- Escolha `n` (New remote)
- Nome: `googleDrive` (ou como preferir)
- **Tipo: escolha `drive`** (e não `google cloud storage`!)
- As próximas opções (`client_id`, `client_secret`, `scope`, `root_folder_id`, `service_account_file`) podem ser deixadas em branco — apenas pressione `Enter` em todas.
- Quando perguntar `Use web browser to authenticate?`, diga `y` e faça login no navegador.
- Diga `n` quando perguntar sobre configurar como um "Shared Drive" (a menos que esteja usando um).
- Confirme a configuração com `y` e depois digite `q` para sair.

Após isso, o comando de sincronização funcionará normalmente.

#### Sobre a opção `object_acl`

Em versões recentes do `rclone`, durante a configuração pode aparecer uma pergunta como:

```
Option object_acl.
Access Control List for new objects.
Choose a number from below, or type in your own value.
Press Enter to leave empty.
   / Object owner gets OWNER access.
 1 | All Authenticated Users get READER access.
   \ (authenticatedRead)
...
 4 | Default if left blank.
   \ (private)
...
```

A escolha mais segura e recomendada é a opção **4** (`private`), que torna os arquivos acessíveis apenas por você (o dono). Isso equivale ao comportamento padrão se você deixasse em branco. Digite `4` e pressione `Enter`.

---

### 4. Escolhendo o Comando Certo: `sync` vs `copy` vs `bisync`

Antes de sincronizar, é fundamental entender a diferença entre os comandos, especialmente se você planeja usar múltiplos dispositivos (PC e celular, por exemplo) enviando para a mesma pasta no Google Drive.

#### `rclone sync` — Espelho (Destrutivo)

O comando `sync` torna a pasta de destino **idêntica** à de origem. Isso significa que ele **apaga** qualquer arquivo no destino que não exista na origem.

**Cuidado:** Se você usar `sync` de dois dispositivos diferentes para a mesma pasta do Drive, o segundo dispositivo a executar o comando poderá apagar os arquivos enviados pelo primeiro.

#### `rclone copy` — Apenas Adiciona/Atualiza (Recomendado)

O comando `copy` **apenas adiciona** arquivos novos ou atualiza os existentes no destino, sem nunca apagar nada:

```bash
rclone copy ~/.prompts GoogleDrive:Notebooks/prompts
```

**Comportamento:**
- Copia arquivos que existem na origem mas não no destino
- Sobrescreve arquivos no destino **apenas se** o da origem for mais recente
- **Nunca apaga** nada no destino
- Ideal para usar no PC e no celular sem medo de perda de dados
- Seguro para múltiplos dispositivos enviando para a mesma pasta

#### `rclone bisync` — Sincronização Bidirecional

Para sincronização completa nos dois sentidos (alterações locais vão para nuvem e vice-versa):

```bash
rclone bisync ~/.prompts GoogleDrive:Notebooks/prompts
```

**Comportamento:**
- Sincroniza nos dois sentidos
- Arquivos novos em qualquer lado são copiados para o outro
- Arquivos apagados em um lado são apagados no outro
- Detecta conflitos (mesmo arquivo modificado nos dois lados)

**Cuidado:** Na primeira vez, sempre faça um backup ou use `--dry-run`:
```bash
rclone bisync ~/.prompts GoogleDrive:Notebooks/prompts --dry-run
```

Para manter arquivos deletados na lixeira do Google Drive em vez de excluir permanentemente:
```bash
rclone bisync ~/.prompts GoogleDrive:Notebooks/prompts --drive-use-trash
```

#### `rclone sync` com `--backup-dir` — Histórico de Alterações

Se quiser usar o `sync` mas manter um histórico do que foi apagado:

```bash
rclone sync ~/.prompts GoogleDrive:Notebooks/prompts --backup-dir GoogleDrive:Notebooks/backup_$(date +%Y%m%d)
```

Isso move os arquivos que seriam apagados para uma pasta de backup com a data atual, em vez de excluí-los definitivamente.

#### Resumo Comparativo

| Comando | Adiciona novos | Atualiza existentes | Apaga no destino | Bidirecional | Ideal para |
|:---|:---:|:---:|:---:|:---:|:---|
| `sync` | Sim | Sim | **Sim** | Não | Backup espelho único |
| `copy` | Sim | Sim | **Não** | Não | **Múltiplos dispositivos** |
| `bisync` | Sim | Sim | Sim | **Sim** | Sincronização completa |

**Recomendação para múltiplos dispositivos:** Use `rclone copy` tanto no PC quanto no celular (Termux) para enviar arquivos para a mesma pasta do Drive sem risco de um apagar os dados do outro:

```bash
# No PC (Arch Linux)
rclone copy ~/.prompts GoogleDrive:Notebooks/prompts --progress

# No Termux (Celular)
rclone copy ~/.prompts GoogleDrive:Notebooks/prompts --progress
```

---

### 5. Sincronizar Sua Pasta

Agora você pode usar o comando escolhido. A sintaxe básica é a mesma para todos:

```bash
rclone sync /caminho/para/sua/pasta/local googleDrive:caminho/na/nuvem
```
- **`/caminho/para/sua/pasta/local`**: Substitua pelo caminho da pasta no seu computador.
- **`googleDrive:`**: É o nome que você deu ao remote no passo 2.
- **`caminho/na/nuvem`**: É o caminho dentro do seu Google Drive.

**Importante sobre a sintaxe do caminho remoto:**
No rclone, a barra no início do caminho remoto **não** deve ser usada. A sintaxe correta é:

- **Certo:** `googleDrive:Notebooks/prompts`
- **Errado:** `googleDrive:/Notebooks/prompts`

Se você usar a barra, o rclone pode interpretar como um caminho absoluto na raiz, causando comportamentos inesperados. Use sempre o caminho relativo à raiz do Drive, sem barra inicial.

**Exemplo prático com `copy` (recomendado):**
Para enviar arquivos da pasta `Documentos/Backup` local para a pasta `MeuBackup` no Drive sem apagar nada:
```bash
rclone copy ~/Documentos/Backup googleDrive:MeuBackup
```

**Exemplo prático com `sync` (apenas se for um backup espelho único):**
```bash
rclone sync ~/Documentos/Backup googleDrive:MeuBackup
```
**Atenção:** Este comando apagará qualquer arquivo em `MeuBackup` que não exista em `~/Documentos/Backup`.

Se a pasta de destino não existir no Drive, o `rclone` a criará automaticamente.

---

### 6. Principais Opções e Recomendações

Aqui estão as opções mais úteis para um uso seguro e eficiente:

| Opção | Descrição |
| :--- | :--- |
| **`--dry-run`** | **Essencial para testes.** Mostra o que seria copiado ou deletado, sem fazer nenhuma alteração. Use sempre antes de um `sync` ou `bisync` real. Ex: `rclone sync pasta/ googleDrive:pasta --dry-run`. |
| **`--progress`** ou `-P` | Mostra o progresso da transferência em tempo real, com velocidade e ETA. Ex: `rclone copy pasta/ googleDrive:pasta -P`. |
| **`--update`** | Copia apenas arquivos da origem que são mais novos que os do destino. Útil para evitar sobrescrever arquivos mais recentes na nuvem. |
| **`--exclude-from`** | Permite ignorar arquivos ou pastas específicos, como `*.tmp` ou `*.log`. Você cria um arquivo de lista (um padrão por linha) e o referencia. Ex: `rclone copy pasta/ drive:backup --exclude-from ~/rclone-exclude.txt`. |
| **`--transfers=N`** | Aumenta a velocidade fazendo N transferências em paralelo. O padrão é 4. Ex: `--transfers=16`. |
| **`--drive-use-trash=true`** | Move os arquivos deletados durante o `sync` ou `bisync` para a lixeira do Google Drive, em vez de apagá-los definitivamente. É mais seguro. |

---

### 7. Automatizar e Simplificar (Bônus)

- **Agendar Sincronização**: Para rodar automaticamente, como um backup diário, agende o comando no `cron`. Digite `crontab -e` e adicione uma linha como:
    ```bash
    0 23 * * * /usr/bin/rclone copy /home/seu-usuario/Documentos googleDrive:Backup-Documentos
    ```
    Isso executará a cópia todos os dias às 23:00. (Note o uso de `copy` em vez de `sync` para evitar perda acidental de dados.)

- **Criar um Atalho**: Para não digitar o comando toda vez, crie um script. Salve o comando em um arquivo `.sh`, torne-o executável com `chmod +x script.sh` e execute-o quando quiser.

---

### Resumo e Alternativa (rsync com Montagem)

Se o seu objetivo é **absolutamente necessário** usar o comando `rsync`, você pode seguir um caminho alternativo: montar o Google Drive como se fosse uma pasta no seu computador usando a ferramenta `google-drive-ocamlfuse` e, em seguida, usar o `rsync` normal.

```bash
# Instalar e montar o Google Drive
sudo add-apt-repository ppa:alessandro-strada/ppa
sudo apt update && sudo apt install google-drive-ocamlfuse
google-drive-ocamlfuse ~/google-drive # Monta a pasta

# Usar o rsync normalmente
rsync -uvrt --progress ~/Documentos/Backup ~/google-drive/MeuBackup

# Desmontar quando terminar
fusermount -u ~/google-drive
```
No entanto, **a recomendação oficial e mais robusta é usar o `rclone`**.