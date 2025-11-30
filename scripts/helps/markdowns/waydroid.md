# Waydroid Help: Complete Setup and Usage Guide

This guide covers everything from basic installation on Arch Linux to advanced topics such as ARM app compatibility, root with Magisk, file sharing, and troubleshooting.

## ⚙️ Prerequisites and Installation on Arch Linux

### Checking and Installing Kernel Modules

Waydroid requires the `binder_linux` and `ashmem_linux` kernel modules. Many popular kernels already include them by default:

*   **`linux-zen`** (default kernel for Garuda Linux)
*   **`linux-cachyos`** (available in chaotic-aur)
*   **`linux-xanmod`** (available in chaotic-aur)

To check if your kernel already has the modules, run:
```bash
sudo modprobe -a binder_linux
```
If the command returns without errors, the modules are present. Otherwise, you can install them via DKMS:
```bash
sudo pacman -S binder_linux-dkms
```

### Waydroid Installation

Waydroid is available in **chaotic-aur**. After configuring the repository, install the package:
```bash
sudo pacman -Syu waydroid
```

## 🚀 Initialization and First Steps

1.  **Initialize Waydroid**. For an experience with the Google Play Store, use the `-s GAPPS` flag:
    ```bash
    sudo waydroid init -s GAPPS
    ```
    *This will download the Android system images. In some regions, using a VPN to a European country may speed up the download.*

2.  **Enable and start the container service**:
    ```bash
    sudo systemctl enable --now waydroid-container
    ```

3.  **Start the session** (without using `sudo`):
    ```bash
    waydroid session start
    ```

4.  **Open the full interface** of Android or start applications from your desktop's application menu:
    ```bash
    waydroid show-full-ui
    ```

## 📁 File Sharing between Host and Android

Set up a shared directory to transfer files between your Arch system and the Android environment:

```bash
# Create directories
sudo mkdir -p /var/lib/waydroid/data/media/0/Share
mkdir -p ~/Public/Android

# Mount share
sudo mount --bind -o rw /var/lib/waydroid/data/media/0/Share ~/Public/Android
```

### Automated Startup Script

To automate the startup and sharing process, you can use a script like this:

```bash
#!/bin/bash

# Directory configurations
waydroid_share="$HOME/.local/share/waydroid/data/media/0/Share"
waydroid_mount="$HOME/Public/Android"

# Check if Waydroid container is running
waydroid_container=$(pgrep -f waydroid)
waydroid_process=$(pidof waydroid)

# Manage Waydroid service
if [[ -n "${waydroid_container}" ]]; then 
    echo -n "Waydroid service detected. Restart? (y/n): "    
    read -r response
    if [[ "${response}" =~ ^[Yy]$ ]]; then 
        sudo systemctl stop waydroid-container.service
        clear
    fi
fi

# Waydroid initialization
if [ -z "${waydroid_container}" ]; then 
    echo "Starting Waydroid initialization..."
    sudo waydroid init -s GAPPS -f & disown
fi

# First-time setup
if [ -z "${waydroid_process}" ]; then 
    echo "Running first-time setup..."
    waydroid first-launch 2>/dev/null & disown
fi

# File sharing configuration
echo "Configuring file sharing..."
if ! sudo ls "${waydroid_share}" >/dev/null 2>&1; then
    sudo mkdir -p "${waydroid_share}"
    # Change ownership of the share directory to the current user
	sudo chmod -R 755 "${waydroid_share}"
    sudo chown -R "${USER}" "${waydroid_share}"
fi

if [[ ! -d "${waydroid_mount}" ]]; then
    mkdir -p "${waydroid_mount}"
fi

# Mount shared directory
sudo mount --bind -o rw "${waydroid_share}" "${waydroid_mount}"
sudo chown -R "${USER}" "${waydroid_mount}"

echo "Waydroid setup completed successfully!"
```

## 🔧 Advanced Features with `waydroid-script-git`

`waydroid-extras` (installable via `waydroid-script-git`) is an essential tool for extending Waydroid's capabilities.

### Script Installation

Install the package from the AUR using a helper like `yay`:
```bash
yay -S waydroid-script-git
```
After installation, run the script with administrative privileges:
```bash
sudo waydroid-extras
```

### Main Features of waydroid-extras

#### ARM Translation Libraries (`libhoudini` and `libndk`)

To run applications compiled exclusively for ARM on x86_64 processors:

| Library | Description | Recommended Performance |
| :--- | :--- | :--- |
| **libhoudini** | Intel's translation library for Intel/AMD x86 CPUs | Best performance on **Intel** CPUs |
| **libndk** | Google's translation from Chromium OS | Best performance on **AMD** CPUs |

**Important**: Install only one library at a time, as they are mutually exclusive.

#### Google Play Store and Google Services

The script allows you to install or reinstall Google Services (GApps) if you initialized Waydroid without the GAPPS flag.

#### Root with Magisk

To gain root access in the Waydroid environment:
```bash
sudo waydroid-extras
```
Select the Magisk option from the menu. Note that some advanced modules may not work due to the limitations of the containerized environment.

#### Widevine for Streaming

Enable DRM support to watch content on services like Netflix, Amazon Prime Video, and Disney+ directly in Waydroid's Android browser.

## 📱 Application Management

### Main Waydroid Commands

- **Install application**:
  ```bash
  waydroid app install path/to/app.apk
  ```

- **List installed applications**:
  ```bash
  waydroid app list
  ```

- **Start application** (knowing the package name):
  ```bash
  waydroid app launch com.package.app
  ```

- **Remove application**:
  ```bash
  waydroid app remove com.package.app
  ```

### Get Android ID for Google Play Store

To register your Waydroid device with the Google Play Store:

```bash
sudo waydroid shell -- sh -c "sqlite3 /data/data/com.google.android.gsf/databases/gservices.db 'select * from main where name = \"android_id\";'"
```

Or alternatively:
```bash
sudo waydroid shell
# Inside the Waydroid shell:
ANDROID_RUNTIME_ROOT=/apex/com.android.runtime ANDROID_DATA=/data ANDROID_TZDATA_ROOT=/apex/com.android.tzdata ANDROID_I18N_ROOT=/apex/com.android.i18n sqlite3 /data/data/com.google.android.gsf/databases/gservices.db "select * from main where name = \"android_id\";"
```

Visit https://www.google.com/android/uncertified/ and register the generated number.

## 🛠️ Common Problem Solving

### Wi-Fi Network Problem

If Waydroid shows Wi-Fi network disabled:

```bash
# Stop Waydroid
sudo waydroid session stop
sudo waydroid container stop

# Configure firewall to allow DNS traffic
sudo ufw allow 67
sudo ufw allow 53
sudo ufw default allow FORWARD

# Restart Waydroid
sudo systemctl restart waydroid-container
```

### Problems with Nvidia and Virtual Machines

*   **Nvidia GPUs (except Tegra)**: May require software rendering
*   **Virtual machines**: Check if nested virtualization is enabled

### Videos Don't Play (Black Screen)

Known issue on Nvidia cards. Possible solutions:
- Switch to the `xorg` driver
- Remove custom configurations
- Wait for future updates that fix the audio callback

### Complete Reinstallation

If you encounter serious problems:

```bash
# Stop services
waydroid session stop
sudo waydroid container stop

# Remove package
sudo pacman -R waydroid

# Clean residual data
sudo rm -rf /var/lib/waydroid /home/.waydroid ~/waydroid ~/.share/waydroid ~/.local/share/applications/*aydroid* ~/.local/share/waydroid

# Reboot and reinstall
sudo reboot
```

## 💡 Useful Commands and Tips

### System Update
```bash
waydroid upgrade  # Updates the Android image
```

### Multi-window Mode
To run apps in individual resizable windows:
```bash
waydroid prop set persist.waydroid.multi_windows true
waydroid session stop
# Restart the Waydroid session after
```

### Android Shell
Access the Android terminal directly:
```bash
waydroid shell
```

### Fast Container Restart
```bash
sudo systemctl restart waydroid-container
```

## 📚 Additional Resources

*   **Official Documentation**: [docs.waydro.id](https://docs.waydro.id/)
*   **GitHub**: [github.com/waydroid/waydroid](https://github.com/waydroid/waydroid)
*   **Arch Wiki**: [wiki.archlinux.org/title/Waydroid](https://wiki.archlinux.org/title/Waydroid)

---

*This guide incorporates best practices for Arch Linux, including file sharing configurations, using waydroid-script-git for advanced features, and solutions for common problems encountered by the community.*