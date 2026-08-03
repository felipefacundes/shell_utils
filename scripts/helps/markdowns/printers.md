# Complete Tutorial: Printer Sharing via CUPS and Samba with UFW Firewall

---

## 📋 Table of Contents
1. [Sharing the Printer via CUPS](#1-sharing-the-printer-via-cups)
2. [Sharing the Printer via Samba](#2-sharing-the-printer-via-samba)
3. [Configuring the UFW Firewall](#3-configuring-the-ufw-firewall)
4. [Testing the Configuration](#4-testing-the-configuration)

---

## 1. Sharing the Printer via CUPS

CUPS (Common UNIX Printing System) is the default printing system on Linux. To share your printer on the network via IPP (Internet Printing Protocol), follow the steps below:

### 1.1 Identify the Printer

First, list all installed printers on the system:

```bash
lpstat -p
```

Example output:
```
printer HP-LaserJet-P1005 is idle. enabled since Thu 01 Jan 2026 10:00:00 AM -03
```

Note the exact name of your printer (in the example: `HP-LaserJet-P1005`).

### 1.2 Enable Printer Sharing

Enable printer sharing in CUPS:

```bash
cupsctl --share-printers
```

> **Note:** You will be prompted for your user password (the same one used for `sudo`).

### 1.3 Share the Specific Printer

Share the printer identified in the previous step:

```bash
lpadmin -p printer-name -o printer-is-shared=true
```

Replace `printer-name` with the name obtained from `lpstat -p`.

**Practical example:**
```bash
lpadmin -p HP-LaserJet-P1005 -o printer-is-shared=true
```

### ✅ Done!

Your printer is now shared via CUPS on the network using the IPP protocol. **No need** to modify the `/etc/cups/cupsd.conf` file for this to work.

---

## 2. Sharing the Printer via Samba

Samba allows you to share the printer using the SMB/CIFS protocol, making it accessible to Windows machines and other systems.

### 2.1 Configure the smb.conf File

Edit the Samba configuration file:

```bash
sudo nano /etc/samba/smb.conf
```

### 2.2 Complete smb.conf Template

Below is a functional `smb.conf` file that includes **printer sharing** and **file sharing** as a bonus:

```ini
[global]
workgroup = WORKGROUP
security = user
printing = cups
printcap name = cups
load printers = yes
cups options = raw

[printers]
comment = HP Laserjet P1005 in Network
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

# ===== FILE SHARING (BONUS) =====
# Replace "foo" with your username
[shared]
comment = Shared Folder
path = /home/foo/Shared
browseable = yes
read only = no
guest ok = no
create mask = 0664
force user = foo
valid users = foo
directory mask = 0775
```

### 2.3 Section Explanation

| Section | Description |
|---------|-------------|
| `[global]` | General Samba settings: workgroup, security, and CUPS integration |
| `[printers]` | Generic section for all shared printers |
| `[print$]` | Printer driver sharing (required for Windows clients) |
| `[HP-LaserJet-P1005]` | Specific section for your printer with detailed permissions |
| `[shared]` | (Bonus) Shared folder for files - replace `foo` with your username |

### 2.4 Restart Samba Services

With newer Samba versions, the services have been renamed. Restart the correct services:

```bash
sudo systemctl restart smb nmb
```

> **Note:** On older versions, the command was `sudo systemctl restart smbd nmbd`. The above command is for modern distributions.

### 2.5 Verify Services Are Running

```bash
sudo systemctl status smb nmb
```

Make sure both show status `active (running)`.

---

## 3. Configuring the UFW Firewall

With UFW active, the printer may not be found even with ports opened. Follow these exact rules that have been tested and work.

### 3.1 Open Ports for CUPS/IPP

```bash
# mDNS discovery (to find the printer on the network)
sudo ufw allow 5353/udp comment 'mDNS discovery'
sudo ufw allow in to 224.0.0.251 port 5353 proto udp comment 'Allow mDNS discovery'
sudo ufw allow out to 224.0.0.251 port 5353 proto udp comment 'Allow mDNS queries'

# IPP communication (job submission)
sudo ufw allow 631/tcp comment 'IPP printing'
sudo ufw allow 631/udp comment 'IPP legacy browsing'

# Inbound and outbound IPP rules
sudo ufw allow in to any port 631 proto tcp comment 'IPP responses (in)'
sudo ufw allow out to any port 631 proto tcp comment 'IPP printing (out)'
```

### 3.2 Open Ports for Samba

```bash
# NetBIOS name resolution
sudo ufw allow 137/udp comment 'NetBIOS Name Resolution'

# NetBIOS datagram service (browsing)
sudo ufw allow 138/udp comment 'NetBIOS Datagram'

# NetBIOS session (sharing) - ATTENTION: TCP, not UDP!
sudo ufw allow 139/tcp comment 'NetBIOS Session (Samba)'

# SMB over TCP/IP - ATTENTION: TCP, not UDP!
sudo ufw allow 445/tcp comment 'SMB over TCP (Samba)'
```

### 3.3 Apply Rules and Reload

```bash
sudo ufw reload
```

### 3.4 Verify Final Status

```bash
sudo ufw status verbose
```

### 📌 Expected Output Example

```
Status: active

To                         Action      From
--                         ------      ----
22                         ALLOW       Anywhere                  
5353/udp                   ALLOW       Anywhere                  
224.0.0.251 5353/udp       ALLOW       Anywhere                   # Allow mDNS discovery
224.0.0.251 5353/udp       ALLOW OUT   Anywhere                   # Allow mDNS queries
631/tcp                    ALLOW       Anywhere                   # IPP printing
631/udp                    ALLOW       Anywhere                   # IPP legacy browsing
631/tcp                    ALLOW IN    Anywhere                   # IPP responses (in)
631/tcp                    ALLOW OUT   Anywhere                   # IPP printing (out)
137/udp                    ALLOW       Anywhere                   # NetBIOS Name Resolution
138/udp                    ALLOW       Anywhere                   # NetBIOS Datagram
139/tcp                    ALLOW       Anywhere                   # NetBIOS Session (Samba)
445/tcp                    ALLOW       Anywhere                   # SMB over TCP (Samba)
```

> **Important:** Notice that ports **139** and **445** are configured as **TCP**. Configuring them as UDP prevents printer discovery.

---

## 4. Testing the Configuration

### 4.1 Test CUPS/IPP Discovery

```bash
# Check if the printer appears via mDNS
avahi-browse -rt _ipp._tcp
avahi-browse -rt _printer._tcp

# List available printers via network
lpinfo -v | grep "network socket"
```

### 4.2 Test Samba/NetBIOS Discovery

```bash
# List all Samba resources on the network
smbtree -N

# Test NetBIOS name resolution
nmblookup -S _smb._tcp

# Test specific resolution (replace with your server name)
nmblookup YOUR-SERVER
```

### 4.3 Check Logs in Case of Issues

```bash
# CUPS logs
sudo journalctl -u cups --since "5 minutes ago"

# Samba logs
sudo journalctl -u smb --since "5 minutes ago"
sudo journalctl -u nmb --since "5 minutes ago"

# Avahi logs (mDNS)
sudo journalctl -u avahi-daemon --since "5 minutes ago"
```

---

## 🎯 Summary of Essential Commands

### For CUPS Sharing:
```bash
lpstat -p                              # Identify printer
cupsctl --share-printers               # Enable sharing
lpadmin -p PRINTER-NAME -o printer-is-shared=true
```

### For Samba Sharing:
```bash
sudo nano /etc/samba/smb.conf          # Configure using template
sudo systemctl restart smb nmb        # Restart services (modern versions)
```

### For UFW Firewall Configuration:
```bash
# CUPS/IPP
sudo ufw allow 5353/udp
sudo ufw allow in to 224.0.0.251 port 5353 proto udp
sudo ufw allow out to 224.0.0.251 port 5353 proto udp
sudo ufw allow 631/tcp
sudo ufw allow 631/udp

# Samba (attention: TCP on ports 139 and 445)
sudo ufw allow 137/udp
sudo ufw allow 138/udp
sudo ufw allow 139/tcp
sudo ufw allow 445/tcp

sudo ufw reload
sudo ufw status verbose
```

### To Restart All Services:
```bash
sudo systemctl restart cups smb nmb avahi-daemon
```

---

## ⚠️ Final Notes

1. **No need** to modify the `/etc/cups/cupsd.conf` file for sharing to work
2. **No need** to modify the `/etc/ufw/before.rules` file - the default UFW rules are sufficient
3. Ports **139/tcp** and **445/tcp** are **TCP**, not UDP
4. The correct command to restart Samba is `sudo systemctl restart smb nmb` (not `smbd nmbd`)
5. File sharing via Samba is a bonus that does not interfere with printing

---

**Documentation based on a tested and functional configuration.** 🖨️