`rclone` is a command-line program specifically created for synchronizing files with the cloud. Many call it "*rsync for cloud storage*". It is the standard and most reliable tool for this task.

Here is a step-by-step guide to configure and use `rclone` to sync a local folder with Google Drive on Linux.

---

### 1. Install rclone

On Ubuntu or Debian, use the following command:
```bash
sudo apt update && sudo apt install rclone
```

---

### 2. Configure the Connection to Google Drive

The configuration is interactive. Run the command below and follow the steps:

```bash
rclone config
```

1.  Type `n` to create a new "remote" and press `Enter`.
2.  **Name**: Give a name to the connection. For example, `googleDrive`. Note it down, as you will use it later.
3.  **Storage**: In the list of storage types, type the number corresponding to `drive` (Google Drive) and press `Enter`.
4.  For the next questions about `client_id`, `client_secret`, and `scope`, you can leave them blank and press `Enter` to use the default options (which are typically **1** for full access, then `Enter` for the others).
5.  **Auto config**: When asked `Use auto config?`, type `y` (yes). This will open a window in your browser for you to log into your Google account and authorize `rclone` access.
6.  After authorization, return to the terminal and press `Enter`. Say `n` when asked about configuring as a "Shared Drive".
7.  Finally, type `q` to exit the configuration.

---

### 3. Configuration Troubleshooting

#### Error: "can't make bucket without project number"

If when trying to sync you encounter an error like:

```
ERROR : file.txt: Failed to copy: can't make bucket without project number
```

This means the remote was configured with the wrong type: **Google Cloud Storage** instead of **Google Drive**. Google Cloud Storage is a different service (cloud buckets) and requires a project number, while regular Google Drive does not.

##### How to check the remote type

List the configured remotes:
```bash
rclone listremotes
```
This will show something like `googleDrive:` (or the name you gave).

Check the remote type:
```bash
rclone config show googleDrive:
```
Replace `googleDrive` with your remote's name. Look for the line:
```
type = ???
```
If it shows `type = google cloud storage`, it is wrong. The correct type for Google Drive is `type = drive`.

##### How to fix it

Delete the wrong remote:
```bash
rclone config delete googleDrive
```

Create a new remote with the correct type:
```bash
rclone config
```
- Choose `n` (New remote)
- Name: `googleDrive` (or whatever you prefer)
- **Type: choose `drive`** (and not `google cloud storage`!)
- The next options (`client_id`, `client_secret`, `scope`, `root_folder_id`, `service_account_file`) can be left blank — just press `Enter` on each.
- When asked `Use web browser to authenticate?`, say `y` and log in via the browser.
- Say `n` when asked about configuring as a "Shared Drive" (unless you are using one).
- Confirm the configuration with `y` and then type `q` to exit.

After this, the sync command will work normally.

#### About the `object_acl` option

In recent versions of `rclone`, a question may appear during configuration like:

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

The safest and recommended choice is option **4** (`private`), which makes files accessible only to you (the owner). This is equivalent to the default behavior if you left it blank. Type `4` and press `Enter`.

---

### 4. Choosing the Right Command: `sync` vs `copy` vs `bisync`

Before syncing, it is essential to understand the difference between the commands, especially if you plan to use multiple devices (PC and phone, for example) sending to the same folder on Google Drive.

#### `rclone sync` — Mirror (Destructive)

The `sync` command makes the destination folder **identical** to the source. This means it **deletes** any file in the destination that does not exist in the source.

**Caution:** If you use `sync` from two different devices to the same Drive folder, the second device to run the command may delete the files sent by the first.

#### `rclone copy` — Only Adds/Updates (Recommended)

The `copy` command **only adds** new files or updates existing ones in the destination, never deleting anything:

```bash
rclone copy ~/.prompts GoogleDrive:Notebooks/prompts
```

**Behavior:**
- Copies files that exist in the source but not in the destination
- Overwrites files in the destination **only if** the source file is newer
- **Never deletes** anything in the destination
- Ideal for using on PC and phone without fear of data loss
- Safe for multiple devices sending to the same folder

#### `rclone bisync` — Bidirectional Synchronization

For two-way synchronization (local changes go to cloud and vice versa):

```bash
rclone bisync ~/.prompts GoogleDrive:Notebooks/prompts
```

**Behavior:**
- Syncs in both directions
- New files on either side are copied to the other side
- Deleted files on one side are deleted on the other side
- Detects conflicts (same file modified on both sides)

**Caution:** The first time, always make a backup or use `--dry-run`:
```bash
rclone bisync ~/.prompts GoogleDrive:Notebooks/prompts --dry-run
```

To keep deleted files in the Google Drive trash instead of permanently deleting them:
```bash
rclone bisync ~/.prompts GoogleDrive:Notebooks/prompts --drive-use-trash
```

#### `rclone sync` with `--backup-dir` — Change History

If you want to use `sync` but keep a history of what was deleted:

```bash
rclone sync ~/.prompts GoogleDrive:Notebooks/prompts --backup-dir GoogleDrive:Notebooks/backup_$(date +%Y%m%d)
```

This moves files that would be deleted to a backup folder with the current date, instead of permanently deleting them.

#### Comparative Summary

| Command | Adds new | Updates existing | Deletes in destination | Bidirectional | Ideal for |
|:---|:---:|:---:|:---:|:---:|:---|
| `sync` | Yes | Yes | **Yes** | No | Single mirror backup |
| `copy` | Yes | Yes | **No** | No | **Multiple devices** |
| `bisync` | Yes | Yes | Yes | **Yes** | Full synchronization |

**Recommendation for multiple devices:** Use `rclone copy` on both PC and phone (Termux) to send files to the same Drive folder without risk of one deleting the other's data:

```bash
# On PC (Arch Linux)
rclone copy ~/.prompts GoogleDrive:Notebooks/prompts --progress

# On Termux (Phone)
rclone copy ~/.prompts GoogleDrive:Notebooks/prompts --progress
```

---

### 5. Sync Your Folder

Now you can use the chosen command. The basic syntax is the same for all:

```bash
rclone sync /path/to/your/local/folder googleDrive:path/in/the/cloud
```
- **`/path/to/your/local/folder`**: Replace with the path to the folder on your computer.
- **`googleDrive:`**: This is the name you gave to the remote in step 2.
- **`path/in/the/cloud`**: This is the path inside your Google Drive.

**Important about remote path syntax:**
In rclone, the slash at the beginning of the remote path should **not** be used. The correct syntax is:

- **Correct:** `googleDrive:Notebooks/prompts`
- **Incorrect:** `googleDrive:/Notebooks/prompts`

If you use the slash, rclone may interpret it as an absolute path at the root, causing unexpected behavior. Always use the path relative to the Drive root, without a leading slash.

**Practical example with `copy` (recommended):**
To send files from the local `Documents/Backup` folder to the `MyBackup` folder on Drive without deleting anything:
```bash
rclone copy ~/Documents/Backup googleDrive:MyBackup
```

**Practical example with `sync` (only if this is a single mirror backup):**
```bash
rclone sync ~/Documents/Backup googleDrive:MyBackup
```
**Warning:** This command will delete any file in `MyBackup` that does not exist in `~/Documents/Backup`.

If the destination folder does not exist on Drive, `rclone` will create it automatically.

---

### 6. Main Options and Recommendations

Here are the most useful options for safe and efficient usage:

| Option | Description |
| :--- | :--- |
| **`--dry-run`** | **Essential for testing.** Shows what would be copied or deleted, without making any changes. Always use before an actual `sync` or `bisync`. Ex: `rclone sync folder/ googleDrive:folder --dry-run`. |
| **`--progress`** or `-P` | Shows real-time transfer progress, with speed and ETA. Ex: `rclone copy folder/ googleDrive:folder -P`. |
| **`--update`** | Copies only source files that are newer than the destination files. Useful to avoid overwriting newer files in the cloud. |
| **`--exclude-from`** | Allows you to ignore specific files or folders, like `*.tmp` or `*.log`. Create a list file (one pattern per line) and reference it. Ex: `rclone copy folder/ drive:backup --exclude-from ~/rclone-exclude.txt`. |
| **`--transfers=N`** | Increases speed by doing N transfers in parallel. The default is 4. Ex: `--transfers=16`. |
| **`--drive-use-trash=true`** | Moves files deleted during `sync` or `bisync` to the Google Drive trash instead of permanently deleting them. This is safer. |

---

### 7. Automate and Simplify (Bonus)

- **Schedule Synchronization**: To run automatically, like a daily backup, schedule the command in `cron`. Type `crontab -e` and add a line like:
    ```bash
    0 23 * * * /usr/bin/rclone copy /home/your-username/Documents googleDrive:Backup-Documents
    ```
    This will run the copy every day at 11:00 PM. (Note the use of `copy` instead of `sync` to avoid accidental data loss.)

- **Create a Shortcut**: To avoid typing the command every time, create a script. Save the command in a `.sh` file, make it executable with `chmod +x script.sh`, and run it whenever you want.

---

### Summary and Alternative (rsync with Mounting)

If your goal is **absolutely necessary** to use the `rsync` command, you can follow an alternative path: mount Google Drive as if it were a folder on your computer using the `google-drive-ocamlfuse` tool, and then use regular `rsync`.

```bash
# Install and mount Google Drive
sudo add-apt-repository ppa:alessandro-strada/ppa
sudo apt update && sudo apt install google-drive-ocamlfuse
google-drive-ocamlfuse ~/google-drive # Mount the folder

# Use rsync normally
rsync -uvrt --progress ~/Documents/Backup ~/google-drive/MyBackup

# Unmount when finished
fusermount -u ~/google-drive
```
However, **the official and most robust recommendation is to use `rclone`**.