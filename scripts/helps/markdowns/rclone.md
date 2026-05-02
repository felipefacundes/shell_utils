`rclone` is a command-line program specifically built to sync files with cloud storage. Many call it the "*rsync for cloud storage*". It is the standard and most reliable tool for this task.

Here is a step-by-step guide to set up and use `rclone` to sync a local folder with Google Drive on Linux.

---

## 1. Install rclone

On Ubuntu or Debian, use the following command:

```bash
sudo apt update && sudo apt install rclone
```

## 2. Configure the Connection to Google Drive

The configuration is interactive. Run the command below and follow the steps:

```bash
rclone config
```

1. Type `n` to create a new "remote" connection and press `Enter`.
2. **Name**: Give a name to the connection. For example, `googleDrive`. Remember it, as you will use it later.
3. **Storage**: In the list of storage types, type the number corresponding to `drive` (Google Drive) and press `Enter`.
4. For the following questions about `client_id`, `client_secret`, and `scope`, you can leave them blank and press `Enter` to use the default options (which is normally **1** for full access, then `Enter` for the rest).
5. **Auto config**: When asked `Use auto config?`, type `y` (yes). This will open a window in your browser for you to log in to your Google account and authorize `rclone`'s access.
6. After authorization, return to the terminal and press `Enter`. Type `n` when asked about configuring as a "Shared Drive".
7. Finally, type `q` to exit the configuration.

## 3. Sync Your Folder

Now you can use the `sync` command. It makes the destination folder **identical** to the source, meaning it copies new/modified files and **deletes** files that only exist in the destination.

**Caution:** Use the `--dry-run` option first (see below) to avoid accidental data loss.

The basic syntax is:

```bash
rclone sync /path/to/your/local/folder googleDrive:/path/in/the/cloud
```

- **`/path/to/your/local/folder`**: Replace with the path to the folder on your computer.
- **`googleDrive:`**: This is the name you gave to the remote in step 2.
- **`/path/in/the/cloud`**: This is the path inside your Google Drive.

**Practical example**:
To sync the local `Documents/Backup` folder with the `MyBackup` folder on Drive, use:

```bash
rclone sync ~/Documents/Backup googleDrive:/MyBackup
```

If the `MyBackup` folder doesn't exist on Drive, `rclone` will create it automatically.

## 4. Main Options and Recommendations

Here are the most useful options for safe and efficient usage:

| Option | Description |
| :--- | :--- |
| **`--dry-run`** | **Essential for testing.** Shows what would be copied or deleted, without making any changes. Always use this before an actual `sync`. Example: `rclone sync folder/ googleDrive:/folder --dry-run` . |
| **`--progress`** or `-P` | Shows real-time transfer progress, including speed and ETA. Example: `rclone sync folder/ googleDrive:/folder -P` . |
| **`--update`** | Copies only source files that are newer than the destination files. Useful to avoid overwriting newer files in the cloud. |
| **`--exclude-from`** | Allows you to ignore specific files or folders, such as `*.tmp` or `*.log`. Create a list file (one pattern per line) and reference it. Example: `rclone sync folder/ drive:backup --exclude-from ~/rclone-exclude.txt` . |
| **`--transfers=N`** | Increases speed by performing N parallel transfers. The default is 4. Example: `--transfers=16` . |
| **`--drive-use-trash=true`** | Moves deleted files during the `sync` to the Google Drive trash bin instead of permanently deleting them. This is safer. |

## 5. Automate and Simplify (Bonus)

- **Schedule a Sync**: To run automatically, like a daily backup, schedule the command in `cron`. Type `crontab -e` and add a line like:
    `0 23 * * * /usr/bin/rclone sync /home/your-username/Documents googleDrive:/Backup-Documents`
    This will run the sync every day at 11:00 PM.

- **Create a Shortcut**: To avoid typing the full command every time, create a script. Save the command in a `.sh` file, make it executable with `chmod +x script.sh`, and run it whenever you want.

---

## Summary and Alternative (rsync with Mounting)

If you **absolutely must** use the `rsync` command, you can take an alternative approach: mount Google Drive as if it were a folder on your computer using the `google-drive-ocamlfuse` tool, and then use the regular `rsync`.

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

However, **the official and most robust recommendation is to use `rclone`** .