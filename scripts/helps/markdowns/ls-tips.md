# Complete `ls` Command Guide - Examples and Explanations

## Table of Contents
1. [Date Filters](#1-date-filters)
2. [File Counting and Filters](#2-file-counting-and-filters)
3. [Directory Listing](#3-directory-listing)
4. [Sorting by Extension](#4-sorting-by-extension)
5. [Sorting by Size](#5-sorting-by-size)
6. [Reverse Date Sorting](#6-reverse-date-sorting)
7. [SELinux Security Context](#7-selinux-security-context)
8. [Detailed Information with Inodes](#8-detailed-information-with-inodes)
9. [Recursive Directory Listing](#9-recursive-directory-listing)

---

## 1. Date Filters

### `ls -lt --time-style=+%Y-%m-%d | grep $(date +%Y-%m-%d)`

**Explanation:** This command combines `ls` with `grep` to filter only files modified on the current date.

- **`ls -lt`**: Lists files in long format (`-l`) sorted by modification date (`-t`), newest first
- **`--time-style=+%Y-%m-%d`**: Formats date as `year-month-day` (e.g., `2024-01-15`)
- **`grep $(date +%Y-%m-%d)`**: Filters only lines containing today's date

**Example:**
```bash
$ ls -lt --time-style=+%Y-%m-%d | grep $(date +%Y-%m-%d)
-rw-r--r-- 1 user group 1024 2024-01-15 document.txt
drwxr-xr-x 2 user group 4096 2024-01-15 new_folder/
```

**Related Commands:**

1. **Files modified today (different format):**
   ```bash
   ls -lt | grep "$(date '+%b %d')"
   ```

2. **Files modified in the last N days:**
   ```bash
   find . -type f -mtime -1 -ls  # Last day
   ```

---

## 2. File Counting and Filters

### a) Count files (excluding directories)
**Command:** `ls -p | grep -v / | wc -l`

**Explanation:**
- **`ls -p`**: Adds `/` to the end of directory names
- **`grep -v /`**: Inverts search (`-v`) to show only lines NOT containing `/`
- **`wc -l`**: Counts the number of lines

**Example:**
```bash
$ ls -p
document.txt  image.jpg  folder/  script.sh  README.md

$ ls -p | grep -v / | wc -l
4
```

**Related Commands:**

1. **Count only directories:**
   ```bash
   ls -p | grep / | wc -l
   ```

2. **Use `find` for more precision:**
   ```bash
   find . -maxdepth 1 -type f | wc -l
   ```

### b) Count all items (files + directories)
**Command:** `ls -p | wc -l`

**Explanation:** Counts all items in the current directory, including files and directories.

**Key difference:** `ls -p` adds `/` to directories, but `wc -l` counts all lines.

**Example:**
```bash
$ ls -p | wc -l
5  # Includes all 5 items from previous example
```

**Related Commands:**

1. **Count items including hidden ones:**
   ```bash
   ls -ap | wc -l
   ```

2. **List with numbering:**
   ```bash
   ls -p | nl -w 3 -s ') '
   ```

---

## 3. Directory Listing

### `ls -dF ~/example_folder_of_themes/*/ | xargs -n 1 basename`

**Explanation:** Lists only the names of subdirectories within a specific directory.

- **`ls -dF`**: 
  - `-d`: Lists directories as files (not their contents)
  - `-F`: Adds indicators (`/` for directories, `*` for executables)
- **`*/`**: Pattern that selects only directories
- **`xargs -n 1 basename`**: Removes full path, showing only folder name

**Example:**
```bash
$ ls -dF ~/themes/*/
/home/user/themes/dark/  /home/user/themes/light/  /home/user/themes/custom/

$ ls -dF ~/themes/*/ | xargs -n 1 basename
dark
light
custom
```

**Related Commands:**

1. **List directories with `find`:**
   ```bash
   find ~/themes -maxdepth 1 -type d -exec basename {} \;
   ```

2. **List directories in column:**
   ```bash
   ls -d */ | sed 's|/$||'
   ```

---

## 4. Sorting by Extension

### `ls -lQX`

**Enhanced Explanation:** Lists files with detailed information, quoted names, and organized by file type.

- **`-l`**: Long format (permissions, owner, group, size, date)
- **`-Q`**: Puts names in **double quotes** (useful for names with spaces)
- **`-X`**: Sorts alphabetically **by extension** (file suffix)

**Example:**
```bash
$ ls -lQX
total 24
-rw-r--r-- 1 user group 1024 Jan 15 10:30 "file.txt"
-rw-r--r-- 1 user group 2048 Jan 15 10:25 "document.pdf"
-rwxr-xr-x 1 user group 4096 Jan 15 10:20 "script.sh"
-rw-r--r-- 1 user group  512 Jan 15 10:15 "image.jpg"
```

**Related Commands:**

1. **Sort by extension (without quotes):**
   ```bash
   ls -lX
   ```

2. **Sort by extension in reverse order:**
   ```bash
   ls -lXr
   ```

---

## 5. Sorting by Size

### `ls -lhS`

**Enhanced Explanation:** Displays files in human-readable format sorted from largest to smallest.

- **`-l`**: Complete information (permissions, dates, etc.)
- **`-h`**: **Human-readable** - converts bytes to KB, MB, GB
- **`-S`**: Sorts by **Size** descending

**Example:**
```bash
$ ls -lhS
total 15M
-rw-r--r-- 1 user group  10M Jan 15 10:30 video.mp4
-rw-r--r-- 1 user group 4.2M Jan 15 10:25 image.png
-rw-r--r-- 1 user group 1.1M Jan 15 10:20 document.pdf
-rw-r--r-- 1 user group  15K Jan 15 10:15 script.py
```

**Related Commands:**

1. **Sort from smallest to largest:**
   ```bash
   ls -lhSr
   ```

2. **Show only the N largest files:**
   ```bash
   ls -lhS | head -10
   ```

---

## 6. Reverse Date Sorting

### `ls -ltar`

**Enhanced Explanation:** Complete listing (including hidden) in reverse chronological order.

- **`-l`**: Detailed format
- **`-t`**: Sorts by modification **time**
- **`-a`**: **All** - includes hidden files (start with `.`)
- **`-r`**: **Reverse** - inverts order (oldest first)

**Example:**
```bash
$ ls -ltar
total 48
-rw-r--r--  1 user group  512 Jan  1 09:00 .old_config
drwxr-xr-x  2 user group 4096 Jan 10 14:30 backup/
-rw-r--r--  1 user group 1024 Jan 12 11:20 file1.txt
-rw-r--r--  1 user group 2048 Jan 14 15:45 file2.txt
-rw-------  1 user group  256 Jan 15 10:00 .bash_history
```

**Related Commands:**

1. **See only the most recent:**
   ```bash
   ls -lt | head -5
   ```

2. **Files modified after certain date:**
   ```bash
   ls -lt --time-style=+%s | awk -v limit=$(date -d "7 days ago" +%s) '$6 < limit'
   ```

---

## 7. SELinux Security Context

### `ls -lZs`

**Enhanced Explanation:** Shows SELinux security information along with file system block size.

- **`-l`**: Detailed information
- **`-Z`**: **SELinux Context** - shows security labels
- **`-s`**: **Size in blocks** - allocated size in blocks (usually 512 bytes or 4KB)

**Use Case:** On systems with SELinux enabled (like RHEL, CentOS, Fedora), security context controls which processes can access which resources.

**Example:**
```bash
$ ls -lZs
total 8
4 -rw-r--r--. 1 user group unconfined_u:object_r:user_home_t:s0 1024 Jan 15 10:30 file.txt
4 drwxr-xr-x. 2 user group unconfined_u:object_r:user_home_t:s0 4096 Jan 15 10:25 folder/
```

**Interpretation:**
- `8` total: sum of blocks
- `4` before permissions: blocks allocated for each item
- `unconfined_u:object_r:user_home_t:s0`: SELinux context

**Related Commands:**

1. **See only SELinux context:**
   ```bash
   ls -Z
   ```

2. **Change SELinux context:**
   ```bash
   chcon -t httpd_sys_content_t file.html
   ```

---

## 8. Detailed Information with Inodes

### `ls -ali`

**Enhanced Explanation:** Shows the most complete representation possible, including file system metadata.

- **`-a`**: All files (including `.` and `..`)
- **`-l`**: Long format
- **`-i`**: **Inode number** - unique identifier in the file system
- **`-b`**: Shows **non-printable characters** with C escape (e.g., `\n`, `\t`)

**Use Cases:**
- Debugging files with strange names
- Finding duplicate files (same inode = hard links)
- Problems with special characters

**Example:**
```bash
$ ls -ali
total 32
   131073 drwxr-xr-x 3 user group 4096 Jan 15 10:30 .
       2 drwxr-xr-x 5 user group 4096 Jan 14 09:00 ..
   131074 -rw-r--r-- 2 user group 1024 Jan 15 10:25 file\nwith\012newline.txt
   131074 -rw-r--r-- 2 user group 1024 Jan 15 10:25 hardlink_to_file.txt
```

**Observations:**
- Same inode (131074) = hard link
- `\012` represents newline in filename

**Related Commands:**

1. **Find all hard links to an inode:**
   ```bash
   find /path -inum 131074
   ```

2. **See only inodes:**
   ```bash
   ls -i
   ```

---

## 9. Recursive Directory Listing

### `ls -lRsh --group-directories-first`

**Enhanced Explanation:** Recursive listing with intelligent directory grouping.

- **`-l`**: Long format
- **`-R`**: **Recursive** - shows subdirectories and their contents
- **`-s`**: Size in blocks
- **`-h`**: Human-readable format
- **`--group-directories-first`**: Directories appear first (useful for navigation)

**Example:**
```bash
$ ls -lRsh --group-directories-first
.:
total 20K
4.0K drwxr-xr-x 3 user group 4.0K Jan 15 10:30 documents/
4.0K drwxr-xr-x 2 user group 4.0K Jan 15 10:25 images/
8.0K -rw-r--r-- 1 user group 5.2K Jan 15 10:20 file.txt

./documents:
total 12K
4.0K drwxr-xr-x 2 user group 4.0K Jan 15 10:28 reports/
4.0K -rw-r--r-- 1 user group 2.1K Jan 15 10:25 contract.pdf
```

**Related Commands:**

1. **List only directories recursively:**
   ```bash
   find . -type d -exec ls -ld {} \;
   ```

2. **Show directory tree:**
   ```bash
   tree -h -L 3
   ```

---

## General Tips

### Combining Options
```bash
# List only the 5 largest files (including hidden)
ls -laSh | head -6

# Find files modified today with human-readable size
ls -lht --time-style=+%Y-%m-%d | grep $(date +%Y-%m-%d)
```

### Useful Shortcuts
```bash
# View file type with colors
ls -F --color=auto

# List in single column
ls -1

# Sort by access time (instead of modification)
ls -lu
```

### Customizing in `.bashrc`
```bash
# Useful aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias lsize='ls -lhS'
alias ldate='ls -lht'
alias ldir='ls -d */'
```

This README covers the main uses of the `ls` command with practical examples. Each section can be expanded according to specific needs.