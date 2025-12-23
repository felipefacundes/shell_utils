# Chmod Permissions Listing (Octal System)

## Table of Contents
- [Basic Permissions (0-7)](#basic-permissions-0-7)
- [Three-Digit Structure](#three-digit-structure)
- [Permissions: Files vs Directories](#permissions-files-vs-directories)
- [Common Combination Examples](#common-combination-examples)
- [Special Permissions (Additional First Digit)](#special-permissions-additional-first-digit)
- [Special Bits in Context](#special-bits-in-context)
- [Frequent Directory Combinations](#frequent-directory-combinations)
- [Permission Decision Flowchart](#permission-decision-flowchart)
- [Quick Reference](#quick-reference)
- [Permission and Ownership Configuration](#permission-and-ownership-configuration)
- [Allowing Program Write Access](#allowing-program-write-access)
- [Common Errors and Solutions](#common-errors-and-solutions)
- [Useful Tools](#useful-tools)
- [Security Verification](#security-verification)

## Basic Permissions (0-7)

**0** - No permission
- --- (no access)
- No operations allowed

**1** - Execute permission only
- --x (execute/access only)
- Allows executing files or accessing directories

**2** - Write permission only
- -w- (write only)
- Allows modifying/creating files

**3** - Write and execute (1+2)
- -wx (write and execute)
- Allows modifying and executing/accessing

**4** - Read permission only
- r-- (read only)
- Allows viewing content

**5** - Read and execute (4+1)
- r-x (read and execute)
- Allows reading and executing/accessing

**6** - Read and write (4+2)
- rw- (read and write)
- Allows reading and modifying

**7** - All permissions (4+2+1)
- rwx (read, write, execute)
- Full access

## Three-Digit Structure

**First digit** - Owner permissions
- 0-7 for the file owner user

**Second digit** - Group permissions
- 0-7 for file group members

**Third digit** - Others permissions
- 0-7 for all other users

## Permissions: Files vs Directories

### For **files**:
- `r` = read file content
- `w` = modify file content
- `x` = execute as program

### For **directories**:
- `r` = list contents (use `ls`)
- `w` = create/remove files in directory
- `x` = access directory (use `cd` or access files inside)

**Important**: To access a file inside a directory, you need `x` permission on the directory, regardless of the file's permissions!

## Common Combination Examples

**600** - Exclusive owner access
- User: rw- (6)
- Group: --- (0)
- Others: --- (0)

**644** - Owner can read/write, others only read
- User: rw- (6)
- Group: r-- (4)
- Others: r-- (4)

**755** - Owner has full, others read/execute
- User: rwx (7)
- Group: r-x (5)
- Others: r-x (5)

**777** - Full permission for all (dangerous!)
- User: rwx (7)
- Group: rwx (7)
- Others: rwx (7)

## Special Permissions (Additional First Digit)

**1000** - No special bits
- Normal permissions

**2000** - Sticky bit
- Only owner can delete files in shared directories

**4000** - Setuid bit
- File executes with owner's permissions

**6000** - Setuid + sticky
- Combination of special bits

## Special Bits in Context

**setuid (4xxx)** - When applied to executables
- Example: 4755 - File runs as owner, not as executor

**setgid (2xxx)** - When applied to directories
- Example: 2775 - Created files inherit directory's group

**sticky (1xxx)** - For shared directories
- Example: 1777 - Anyone can create, only owner deletes (e.g., /tmp)

## Frequent Directory Combinations

**700** - Private directory
- Only owner accesses

**755** - Public directory
- Owner controls, others read and access

**775** - Group shared directory
- Owner and group have full control

**1777** - Public temporary directory
- Everyone creates, only owner deletes

## Permission Decision Flowchart

```
Need to configure permissions?
    ├── Only you? → 700
    ├── You and your group? → 770
    ├── Public, but read-only? → 755
    ├── Public, with write? → 777 (avoid!)
    ├── Web uploads? → 755 (owner: www-data)
    └── Shared directory? → 2775 + setgid
```

## Quick Reference

0 = --- = No access

1 = --x = Execute/access only

2 = -w- = Write only

3 = -wx = Write + execute

4 = r-- = Read only

5 = r-x = Read + execute

6 = rw- = Read + write

7 = rwx = Read + write + execute

To configure permissions and ownership for a directory for a specific user in Linux, follow these steps:

## Permission and Ownership Configuration

### 1. **Permissions with `chmod`**

#### For personal user use (only they have access):
```bash
chmod 700 /path/to/directory
```
- **7** (user): read, write and execute (rwx)
- **0** (group): no permission
- **0** (others): no permission
- User can read, write and access directory, others cannot access

#### For sharing with specific group:
```bash
chmod 750 /path/to/directory
```
- **7** (user): read, write and execute (rwx)
- **5** (group): read and execute (r-x)
- **0** (others): no permission

#### For public access (read):
```bash
chmod 755 /path/to/directory
```
- **7** (user): read, write and execute (rwx)
- **5** (group): read and execute (r-x)
- **5** (others): read and execute (r-x)

### 2. **Ownership with `chown`**

#### To change user and group:
```bash
chown user:group /path/to/directory
```

#### Practical examples:

**Scenario 1:** Personal directory for user `john`
```bash
sudo chown john:john /home/john/my-documents
sudo chmod 700 /home/john/my-documents
```

**Scenario 2:** Directory shared among `dev` group members
```bash
sudo chown :dev /projects
sudo chmod 775 /projects
# Add users to 'dev' group
sudo usermod -a -G dev user1
sudo usermod -a -G dev user2
```

**Scenario 3:** Web directory (Apache/Nginx server)
```bash
sudo chown www-data:www-data /var/www/html
sudo chmod 755 /var/www/html
```

### 3. **Recommended order**

1. First change owner with `chown`
2. Then adjust permissions with `chmod`

```bash
sudo chown user:group directory
sudo chmod permissions directory
```

### 4. **Useful options**

- `-R`: Apply recursively (to subdirectories and files)
  ```bash
  sudo chown -R user:group directory
  sudo chmod -R permissions directory
  ```

**Warning:** Use `-R` carefully, especially in large directories or critical systems.

The most common directory permissions are `755` (public/read) and `750` or `700` (private). Choose based on needed access level.

To allow a program (process) to write to a directory, you need to consider **who runs the program** (which user/group) and adjust permissions accordingly.

## Allowing Program Write Access

### **Common scenarios:**

#### **1. Program executed by directory owner**
If the program runs with the same user who owns the directory:
```bash
# Directory belongs to user running program
chmod 755 /directory  # or 750, depending on case
```
With `755` or `750`, the owner (first 7) already has write permission.

#### **2. Program executed by different user**
You have several options:

##### **Option A: Add user to directory's group**
```bash
# 1. Change directory group to shared group
sudo chown user:shared_group /directory

# 2. Give write permission to group
sudo chmod 775 /directory

# 3. Add program user to group
sudo usermod -a -G shared_group program_user
```

##### **Option B: Give write permission to "others" (less secure)**
```bash
sudo chmod 777 /directory  # Any user can write
```
⚠️ **Not recommended** for production environments - very dangerous!

##### **Option C: Use ACLs (Access Control Lists) - more flexible**
```bash
# Install ACL utilities (if needed)
# sudo apt install acl  # Debian/Ubuntu
# sudo yum install acl  # RHEL/CentOS

# Add specific permission for a user
sudo setfacl -m u:program_user:rwx /directory

# Add permission for a group
sudo setfacl -m g:program_group:rwx /directory

# Check ACLs
getfacl /directory

# Remove specific ACL entry
sudo setfacl -x u:user /directory

# Remove all ACLs
sudo setfacl -b /directory

# Complete example with inheritance (uppercase X = execute only for directories)
sudo setfacl -R -m u:user:rwX,d:u:user:rwX /directory
```

### **Specific practical cases:**

#### **A. Web Server (Apache/Nginx) writing to directory**
```bash
# Website uploads directory
sudo chown -R www-data:www-data /var/www/html/uploads
sudo chmod -R 775 /var/www/html/uploads

# Or using www-data as group
sudo chown -R your_user:www-data /var/www/html/uploads
sudo chmod -R 775 /var/www/html/uploads
```

#### **B. System service writing to directory**
```bash
# Example: service running as 'mysql' user
sudo chown mysql:mysql /var/lib/mysql/data
sudo chmod 755 /var/lib/mysql/data
```

#### **C. Multiple services/programs need to write**
```bash
# Create specific group
sudo groupadd writers

# Add program users to group
sudo usermod -a -G writers user1
sudo usermod -a -G writers user2

# Configure directory
sudo chown root:writers /shared_directory
sudo chmod 2775 /shared_directory  # '2' activates setgid bit
```

### **Setgid bit (especially useful for shared directories)**
```bash
sudo chmod 2775 /directory
```
- **Setgid bit (2)**: Makes new files created in directory inherit directory's group
- Useful when multiple users need to share files

### **Complete example: PHP program writing uploads**
```bash
# Uploads directory
sudo mkdir -p /var/www/uploads

# Option 1: Web server user as owner
sudo chown www-data:www-data /var/www/uploads
sudo chmod 755 /var/www/uploads

# Option 2: Shared group (more flexible)
sudo groupadd webwriters
sudo usermod -a -G webwriters www-data
sudo usermod -a -G webwriters your_user
sudo chown your_user:webwriters /var/www/uploads
sudo chmod 2775 /var/www/uploads  # With setgid
```

### **Permission verification:**
```bash
# Check current user
whoami

# Check detailed permissions
ls -la /directory

# Check user's groups
groups program_user

# Test write access
sudo -u program_user touch /directory/test.txt
```

### **Important:**
1. **SELinux/AppArmor**: On systems with extra security, may block even with correct permissions
2. **Disk space**: Ensure there's available space
3. **Parent directory**: Check if parent directory also has adequate permissions

The safest approach is usually to use **groups** or **ACLs**, avoiding broad permissions like `777`.

## Common Errors and Solutions

### **Problem**: "Permission denied" even with apparently correct permissions
- **Cause**: Parent directory without execute (`x`) permission
- **Solution**: `chmod +x /parent/directory`

### **Problem**: Script doesn't execute even with `chmod +x`
- **Cause**: Incorrect shebang or Windows format file (CRLF)
- **Solution**: 
  ```bash
  # Convert line breaks
  dos2unix script.sh
  
  # Check shebang
  head -1 script.sh  # Should be something like #!/bin/bash
  
  # Check file format
  file script.sh
  ```

### **Problem**: Permissions reset after reboot
- **Cause**: Filesystem remounting or service restarting
- **Solution**: Check systemd unit files or initialization scripts

### **Problem**: Cannot delete file even as owner
- **Cause**: May have immutable attributes or be in use
- **Solution**:
  ```bash
  # Check if file is in use
  lsof /path/file
  
  # Check extended attributes
  lsattr /path/file
  
  # Remove immutable attribute (if applicable)
  chattr -i /path/file
  ```

### **Problem**: User cannot access directory even with `755` permission
- **Cause**: May be in system with specific namespace/mount
- **Solution**: Check mounts and namespaces
  ```bash
  mount | grep /directory
  findmnt /directory
  ```

## Useful Tools

### **Basic verification commands:**
- `stat file` - Shows permissions in octal and symbols, plus other information
  ```bash
  stat file.txt
  # Shows: Access: (0644/-rw-r--r--) Uid: ( 1000/ user) Gid: ( 1000/ user)
  ```

- `umask` - Shows default file creation mask
  ```bash
  umask  # Ex: 0022
  umask -S  # Ex: u=rwx,g=rx,o=rx
  ```

- `lsattr` / `chattr` - Extended filesystem attributes
  ```bash
  lsattr file
  chattr +i file  # Makes immutable
  chattr -i file  # Removes immutability
  ```

- `namei -l /full/path` - Shows permissions of entire hierarchy
  ```bash
  namei -l /home/user/documents/file.txt
  ```

### **Advanced tools:**
- `getfacl` / `setfacl` - For Access Control Lists
- `auditctl` / `ausearch` - For access auditing (SELinux contexts)
- `strace` - For system call tracing (useful for debugging)
  ```bash
  strace -e trace=file ls /directory  # Shows all file calls
  ```

## Security Verification

### **Commands to find potentially dangerous permissions:**

```bash
# Find files with 777 permissions (too permissive)
find / -type f -perm 777 2>/dev/null

# Find files with SUID (set user ID)
find / -type f -perm /4000 2>/dev/null

# Find files with SGID (set group ID)
find / -type f -perm /2000 2>/dev/null

# Find directories with sticky bit
find / -type d -perm /1000 2>/dev/null

# Find files/directories without owner (orphaned)
find / -nouser -o -nogroup 2>/dev/null

# Find executable files in world-writable directories
find / -type f -perm -o+w -executable 2>/dev/null

# Find world-writable directories
find / -type d -perm -o+w ! -path "/proc/*" ! -path "/sys/*" 2>/dev/null
```

### **Integrity verification:**
```bash
# Check important system files
sudo ls -la /etc/passwd /etc/shadow /etc/sudoers

# Should be:
# /etc/passwd: -rw-r--r-- (644)
# /etc/shadow: -rw-r----- (640) or more restricted
# /etc/sudoers: -r--r----- (440)
```

### **Change monitoring:**
```bash
# Use auditd to monitor changes in critical directories
sudo auditctl -w /etc/passwd -p wa -k passwd_changes
sudo auditctl -w /etc/shadow -p wa -k shadow_changes

# Check audit logs
sudo ausearch -k passwd_changes
```

### **Quick security check script:**
```bash
#!/bin/bash
echo "=== Security Permissions Check ==="
echo ""
echo "1. Dangerous SUID files:"
find / -type f -perm /4000 -ls 2>/dev/null | head -20

echo ""
echo "2. World-writable directories (excluding /tmp and /proc):"
find / -type d -perm -o+w ! -path "/tmp/*" ! -path "/proc/*" ! -path "/dev/*" 2>/dev/null | head -20

echo ""
echo "3. Important configuration files:"
for file in /etc/passwd /etc/shadow /etc/sudoers; do
    if [ -f "$file" ]; then
        echo "$file: $(stat -c '%A' "$file")"
    fi
done
```

Remember: **Always review the results of these commands** before taking any action, especially on production systems. Some SUID/SGID files are necessary for normal system operation (like `/usr/bin/passwd`).