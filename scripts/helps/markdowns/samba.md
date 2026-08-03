# Complete and Updated Tutorial: How to Create a Samba Share on Linux and Access it from Windows

This guide teaches you how to install and configure Samba on Linux to share folders and printers with Windows machines, using the latest practices for service naming, firewall rules, and troubleshooting.

---

## Part 1: Installation and Initial Setup

### 1. Install Samba
Run the command according to your Linux distribution.

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install samba smbclient cifs-utils
```

**Fedora/RHEL:**
```bash
sudo dnf install samba samba-client cifs-utils
```

### 2. Configure the `smb.conf` File
The main configuration file is located at `/etc/samba/smb.conf`. Use the block below as a base, which already includes sections for sharing folders and printers. Replace `foo` with your username.

```bash
sudo nano /etc/samba/smb.conf
```

```ini
[global]
workgroup = WORKGROUP
security = user
printing = cups
printcap name = cups
load printers = yes
cups options = raw

# ===== PRINTER SHARING =====

[printers]
comment = All Printers
path = /var/tmp
printable = Yes
create mask = 0600
browseable = Yes
guest ok = yes

[print$]
comment = Printer Drivers
path = /var/lib/samba/drivers
write list = root, @printadmin
force group = @printadmin
create mask = 0664
directory mask = 0775

[HP-LaserJet-P1005]
comment = HP LaserJet P1005
path = /var/tmp
printable = yes
guest ok = yes
browseable = yes
create mask = 0600

# ===== FILE SHARING =====
[shared]
comment = Shared Folder
path = /home/foo/Shared
browseable = yes
read only = no
guest ok = no
valid users = foo
force user = foo
create mask = 0664
directory mask = 0775
```
> **Note:** The `[HP-LaserJet-P1005]` configuration is an example of manually declaring a specific printer. Adjust the name to match your printer.

### 3. Create and Prepare the Shared Folder
Create the folder (if it doesn't exist) and adjust local permissions.

```bash
mkdir -p /home/foo/Shared
chmod 755 /home/foo
chmod 775 /home/foo/Shared
```
> **Fine-tuning:** The `775` permissions allow the group to read and write. For a more permissive testing environment, you can use `777`.

### 4. Set a Password for the Samba User
The `[shared]` configuration uses `valid users = foo`. For access to work, create a Samba password for this user.
```bash
sudo smbpasswd -a foo
```

---

## Part 2: Firewall, Services, and Network Discovery

### 1. Open the Correct Ports on the Firewall
The command `sudo ufw allow Samba` does not work on all distributions. Use the exact rules to open the ports, then reload `ufw`.

```bash
# NetBIOS Name Resolution
sudo ufw allow 137/udp comment 'NetBIOS Name Resolution'

# NetBIOS Datagram Service (browsing)
sudo ufw allow 138/udp comment 'NetBIOS Datagram'

# NetBIOS Session (sharing) - Note: TCP
sudo ufw allow 139/tcp comment 'NetBIOS Session (Samba)'

# SMB over TCP/IP - Note: TCP
sudo ufw allow 445/tcp comment 'SMB over TCP (Samba)'

# Reload and verify
sudo ufw reload
sudo ufw status verbose
```

### 2. Enable Avahi Daemon (Optional, but Recommended)
The `avahi-daemon` (mDNS) can assist in discovering services on the local network, complementing NetBIOS.

```bash
sudo systemctl enable --now avahi-daemon
```
Check logs if needed:
```bash
sudo journalctl -u avahi-daemon --since "5 minutes ago"
```

### 3. Manage Samba Services (Updated Method)
**Important:** In recent versions of Samba (starting from 2025/2026), services are managed separately as `smb` and `nmb`. The `smbd` or `nmbd` command has been discontinued.

```bash
# Restart both services
sudo systemctl restart smb nmb

# Enable to start with the system
sudo systemctl enable smb nmb

# Check status
sudo systemctl status smb nmb
```

---

## Part 3: Testing, Diagnostics, and Access

### 1. Test Configuration Locally
Before connecting from another machine, run these commands on the Linux server to ensure everything is working.

**Check the configuration file syntax:**
```bash
testparm
```

**List Samba shares on the local server:**
```bash
smbclient -L //127.0.0.1
```
If you have set a password, add the `-U foo` flag and enter the password when prompted.

### 2. Test Network Discovery and Name Resolution
Use these commands to diagnose the server's visibility on the NetBIOS and SMB network.

```bash
# Lists all Samba resources on the network (may ask for a password, use -N to skip)
smbtree -N

# Tests NetBIOS name resolution on the network
nmblookup -S _smb._tcp

# Tests the specific name resolution of your server
nmblookup YOUR-SERVER
```

### 3. Check Logs in Case of Problems
If something fails, logs are the best source of information.

```bash
# SMB server logs (file and printer sharing)
sudo journalctl -u smb --since "5 minutes ago"

# NMB server logs (NetBIOS name resolution and browsing)
sudo journalctl -u nmb --since "5 minutes ago"

# CUPS logs (printing system)
sudo journalctl -u cups --since "5 minutes ago"

# Avahi logs (mDNS/DNS-SD discovery)
sudo journalctl -u avahi-daemon --since "5 minutes ago"
```

### 4. Access the Folder and Printer from Windows
The most reliable access method is to always use the Linux server's IP address.

**To access the folder:**
1.  Press `Win + R`, type the IP and share name, and click OK:
    `\\192.168.x.x\shared`
2.  Enter the username (`foo`) and the password configured with `smbpasswd`.

**To access the printer:**
1.  Go to Control Panel > Devices and Printers > Add a printer.
2.  Select "The printer that I want isn't listed".
3.  Choose "Select a shared printer by name" and enter the path in the format:
    `\\192.168.x.x\HP-LaserJet-P1005`
    > Replace `HP-LaserJet-P1005` with the exact name of your printer section in `smb.conf`.

---