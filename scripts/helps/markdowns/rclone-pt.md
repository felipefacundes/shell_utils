O `rclone` é um programa de linha de comando criado especificamente para sincronizar arquivos com a nuvem. Muitos o chamam de "*rsync for cloud storage*" . Ele é a ferramenta padrão e mais confiável para essa tarefa.

Aqui está o guia passo a passo para configurar e usar o `rclone` para sincronizar uma pasta local com o Google Drive no Linux.

---

### 1. Instalar o rclone

No Ubuntu ou Debian, use o seguinte comando:
```bash
sudo apt update && sudo apt install rclone
```


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


### 3. Sincronizar Sua Pasta

Agora você pode usar o comando `sync`. Ele torna a pasta de destino **idêntica** à de origem, ou seja, copia arquivos novos/modificados e **apaga** os que existem apenas no destino.

**Cuidado:** Use a opção `--dry-run` primeiro (veja abaixo) para evitar perda acidental de dados .

A sintaxe básica é:
```bash
rclone sync /caminho/para/sua/pasta/local googleDrive:/caminho/na/nuvem
```
- **`/caminho/para/sua/pasta/local`**: Substitua pelo caminho da pasta no seu computador.
- **`googleDrive:`**: É o nome que você deu ao remote no passo 2.
- **`/caminho/na/nuvem`**: É o caminho dentro do seu Google Drive.

**Exemplo prático**:
Para sincronizar a pasta `Documentos/Backup` local com a pasta `MeuBackup` no Drive, use:
```bash
rclone sync ~/Documentos/Backup googleDrive:/MeuBackup
```
Se a pasta `MeuBackup` não existir no Drive, o `rclone` a criará automaticamente .

### 4. Principais Opções e Recomendações

Aqui estão as opções mais úteis para um uso seguro e eficiente:

| Opção | Descrição |
| :--- | :--- |
| **`--dry-run`** | **Essencial para testes.** Mostra o que seria copiado ou deletado, sem fazer nenhuma alteração. Use sempre antes de um `sync` real. Ex: `rclone sync pasta/ googleDrive:/pasta --dry-run` . |
| **`--progress`** ou `-P` | Mostra o progresso da transferência em tempo real, com velocidade e ETA. Ex: `rclone sync pasta/ googleDrive:/pasta -P` . |
| **`--update`** | Copia apenas arquivos da origem que são mais novos que os do destino. Útil para evitar sobrescrever arquivos mais recentes na nuvem . |
| **`--exclude-from`** | Permite ignorar arquivos ou pastas específicos, como `*.tmp` ou `*.log`. Você cria um arquivo de lista (um padrão por linha) e o referencia. Ex: `rclone sync pasta/ drive:backup --exclude-from ~/rclone-exclude.txt` . |
| **`--transfers=N`** | Aumenta a velocidade fazendo N transferências em paralelo. O padrão é 4. Ex: `--transfers=16` . |
| **`--drive-use-trash=true`** | Move os arquivos deletados durante o `sync` para a lixeira do Google Drive, em vez de apagá-los definitivamente. É mais seguro. |

### 5. Automatizar e Simplificar (Bônus)

- **Agendar Sincronização**: Para rodar automaticamente, como um backup diário, agende o comando no `cron`. Digite `crontab -e` e adicione uma linha como:
    `0 23 * * * /usr/bin/rclone sync /home/seu-usuario/Documentos googleDrive:/Backup-Documentos`
    Isso executará a sincronização todos os dias às 23:00 .

- **Criar um Atalho**: Para não digitar o comando toda vez, crie um script. Salve o comando em um arquivo `.sh`, torne-o executável com `chmod +x script.sh` e execute-o quando quiser .

---

### Resumo e Alternativa (rsync com Montagem)

Se o seu objetivo é **absolutamente necessário** usar o comando `rsync`, você pode seguir um caminho alternativo: montar o Google Drive como se fosse uma pasta no seu computador usando a ferramenta `google-drive-ocamlfuse` e, em seguida, usar o `rsync` normal .

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
No entanto, **a recomendação oficial e mais robusta é usar o `rclone`** .