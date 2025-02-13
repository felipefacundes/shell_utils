#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes
# This is a simple script that automatically creates backups for your Godot projects and avoids accidents

: <<'DOCUMENTATION'
This script is designed to automate the backup process for Godot projects, ensuring that users can 
easily manage their project files and avoid accidental data loss. 

Key Features:
1. Automatic Backup Creation: The script creates backups of Godot projects in a specified directory, timestamped for easy identification.
2. Signal Handling: It captures termination signals to ensure that backup processes are properly managed and terminated.
3. Directory Management: It checks for the existence of necessary directories and creates them if they do not exist, ensuring a smooth backup process.
4. Size Management: The script monitors the size of the backup directory and automatically deletes the oldest backups when a specified size limit is reached.
5. Compatibility Checks: It includes checks for NVIDIA graphics drivers and Vulkan support, optimizing the environment for running Godot.

Overall, this script enhances the user experience by providing a reliable and efficient way to manage backups for Godot projects.
DOCUMENTATION

# Define a signal handler to capture SIGINT (Ctrl+C)
trap 'kill $(jobs -p)' SIGTERM #SIGHUP #SIGINT #SIGQUIT #SIGABRT #SIGKILL #SIGALRM #SIGINT

godot_file=~/.godot_dir.default

# Extract values from the configuration file
#default_dir="$(cat ${godot_file} | sed '/^$/d' | head -1 | tail -1 | cut -f2 -d'=' | sed 's#^[[:space:]]##g')"
#godot_dir="$(cat ${godot_file} | sed '/^$/d' | head -2 | tail -1 | cut -f2 -d'=' | sed 's#^[[:space:]]##g')"
read -r default_dir < <(awk -F '=' '/godot_subdir/ {gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}' "$godot_file")
read -r godot_dir < <(awk -F '=' '/godot_projects_dir/ {gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}' "$godot_file")

default_dir="$(eval echo "${default_dir}")"
godot_dir="$(eval echo "${godot_dir}")"

# Set default values if not present
dir="${dir:-$default_dir}"
bkp_tars="BKP_tars"
bkp="${godot_dir}_$(date +'%d-%m-%Y_%H-%M-%S').tar"
path_bin=~/.local/bin/
godot_latest_binary=$(ls -v "$path_bin"/Godot* | tail -n1)

# vsync
export vblank_mode=0
export __GL_SYNC_TO_VBLANK=0

run_godot() { 
    setsid "$godot_latest_binary" "$@" &
    godot_pid="$(echo $!)"; export godot_pid
}

if [[ ! -f "$godot_file" ]]; then
    echo 'godot_subdir = ' | tee "$godot_file"
    echo 'godot_projects_dir = ' | tee -a "$godot_file"
fi

if [[ -z "$dir" ]] || [[ -z "$godot_dir" ]]; then
    cat <<EOF

In the ~/.godot_dir.default file, enter the subdirectory, the main directory where your projects directory is located, example:

godot_subdir = ~/Documents

Then inform which directory will actually be subject to backups, example:

godot_projects_dir = My_Godot4_projects
EOF
    exit 1
fi

if [[ ! -d "${dir}/${godot_dir}" ]]; then
    echo 'Project directory not found'
    exit 1
fi

if [[ ! -d "${dir}/${godot_dir}" ]]; then
    mkdir -p "$bkp_tars"
    echo 'Backup directory created, restart the script, which will make backups of your projects, before starting Godot'
    exit 1
fi

declare -i max_size=31457280  # Maximum size allowed for backups

clear
declare -l args="$1"

if [[ -z "$args" ]] || [[ "$args" == nvidia ]] || [[ "$args" == n ]]; then
    if lspci | grep -i "VGA" | grep -qi "NVIDIA"; then
        if lsmod | grep -i nvidia >/dev/null 2>&1; then

            export __NV_PRIME_RENDER_OFFLOAD=1
            export __VK_LAYER_NV_optimus=NVIDIA_only
            export __GLX_VENDOR_LIBRARY_NAME=nvidia
            
            if ! glxinfo -B >/dev/null 2>&1; then 
                echo -e "Your computer does not run Vulkan at the moment,\nperhaps because it has been updated.\nRestart the system, to fix it!"
                exit 1
            fi

        fi
    fi
fi

if [[ ! -d "$default_dir" && ! -d "$godot_dir"  ]]; then
    echo "Define your projects directory and backup folder"
    exit 1
fi

cd "$dir" || exit

while true; do
    declare -i size_bkp_tars=$(du -s "$bkp_tars" | awk '{print $1}')
    if [ "${size_bkp_tars}" -gt "${max_size}" ]; then
        echo "Backup limit reached, deleting the oldest"
        
        # Remove the oldest tar file inside the backup folder
        oldest_tar=$(ls -t "${bkp_tars}"/*.tar | tail -n 1)  # ls -Art
        rm -f "$oldest_tar" > /dev/null 2>&1 &
        echo -e "\nremoved $oldest_tar file\n"
    else
        break
    fi
done

echo "Backup being created. Wait!"
tar -cf "${godot_dir}".tar "${godot_dir}"/
mv "${godot_dir}".tar "$bkp"
mv *.tar "$bkp_tars"/
du -hs "$bkp_tars"

echo -e "\nBackup $bkp created"
echo -e "Starting Godot\n"

optirun=$(command -v optirun)
if  [[ "$args" = no || "$args" = nouveau ]] && [[ "$optirun" ]]; then
    optirun glxinfo -B
    export NOUVEAU_USE_ZINK=1
    NOUVEAU_USE_ZINK=1 optirun run_godot --verbose "$@"
else
    run_godot --verbose "$@"
fi

declare godot_window

while [ -z "$godot_window" ]; do
    godot_window=$(wmctrl -l | awk "/Godot Engine/ {print \$1}" | head -n1); export godot_window
    sleep 1
done

echo "PID: $godot_pid"
echo "On X11, how to use: wmctrl -ic $godot_window"
trap 'kill "$godot_pid"; sleep 15 && kill -9 "$godot_pid"; exit 1' SIGINT # Kill process with control+c
wait "$godot_pid"               
