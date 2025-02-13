#!/bin/bash

# https://www.youtube.com/watch?v=jc3PjDX-CGs&t=220s
# https://gitlab.com/risingprismtv/single-gpu-passthrough/-/wikis/3)-IOMMU-Groups
# https://forum.proxmox.com/threads/pci-passthrough-issues-with-pve-8-0-3.129992/

: <<'DOCUMENTATION'
This script lists all IOMMU groups on a Linux system, displaying the devices associated with each group. 
It utilizes the lspci command to provide detailed information about the devices in each group.
DOCUMENTATION

shopt -s nullglob
for g in /sys/kernel/iommu_groups/*; do
    echo "IOMMU Group ${g##*/}:"
    for d in $g/devices/*; do
        echo -e "\t$(lspci -nns ${d##*/})"
    done;
done;
