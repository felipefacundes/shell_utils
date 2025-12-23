#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This script installs the GRUB bootloader for either EFI or i386 systems, checking for necessary conditions such as valid block devices 
and proper filesystem formats. It provides user feedback in both English and Portuguese, ensuring the script is executed as root and 
generating the GRUB configuration upon successful installation.
DOCUMENTATION

declare -A MESSAGES

if [[ "${LANG,,}" =~ pt_ ]]; then
    MESSAGES=(
        ["not_block"]="Erro: %s não é um dispositivo de bloco válido"
        ["not_block_en"]="Error: %s is not a valid block device"
        ["efi_not_mounted"]="Erro: /boot/EFI não está montado"
        ["efi_not_mounted_en"]="Error: /boot/EFI is not mounted"
        ["not_fat"]="Erro: /boot/EFI não está formatado como FAT (tipo atual: %s)"
        ["not_fat_en"]="Error: /boot/EFI is not formatted as FAT (current type: %s)"
        ["checking_efi"]="Verificando requisitos para instalação EFI..."
        ["checking_efi_en"]="Checking EFI installation requirements..."
        ["installing_efi"]="Instalando GRUB para EFI..."
        ["installing_efi_en"]="Installing GRUB for EFI..."
        ["grub_efi_error"]="Erro na instalação do GRUB EFI"
        ["grub_efi_error_en"]="Error installing GRUB EFI"
        ["no_block_device"]="Erro: Dispositivo de bloco não especificado para instalação i386"
        ["no_block_device_en"]="Error: Block device not specified for i386 installation"
        ["usage_i386"]="Uso: %s i386 /dev/sdX"
        ["usage_i386_en"]="Usage: %s i386 /dev/sdX"
        ["checking_block"]="Verificando dispositivo de bloco %s..."
        ["checking_block_en"]="Checking block device %s..."
        ["installing_i386"]="Instalando GRUB para i386-pc em %s..."
        ["installing_i386_en"]="Installing GRUB for i386-pc on %s..."
        ["grub_i386_error"]="Erro na instalação do GRUB i386"
        ["grub_i386_error_en"]="Error installing GRUB i386"
        ["usage"]="Uso: %s <efi|i386> [dispositivo]"
        ["usage_en"]="Usage: %s <efi|i386> [device]"
        ["examples"]="Exemplos:"
        ["examples_en"]="Examples:"
        ["generating_config"]="Gerando configuração do GRUB..."
        ["generating_config_en"]="Generating GRUB configuration..."
        ["config_error"]="Erro ao gerar configuração do GRUB"
        ["config_error_en"]="Error generating GRUB configuration"
        ["success"]="Instalação do GRUB concluída com sucesso!"
        ["success_en"]="GRUB installation completed successfully!"
        ["need_root"]="Este script precisa ser executado como root"
        ["need_root_en"]="This script needs to be run as root"
    )
else
    MESSAGES=(
        ["not_block"]="Error: %s is not a valid block device"
        ["not_block_en"]="Error: %s is not a valid block device"
        ["efi_not_mounted"]="Error: /boot/EFI is not mounted"
        ["efi_not_mounted_en"]="Error: /boot/EFI is not mounted"
        ["not_fat"]="Error: /boot/EFI is not formatted as FAT (current type: %s)"
        ["not_fat_en"]="Error: /boot/EFI is not formatted as FAT (current type: %s)"
        ["checking_efi"]="Checking EFI installation requirements..."
        ["checking_efi_en"]="Checking EFI installation requirements..."
        ["installing_efi"]="Installing GRUB for EFI..."
        ["installing_efi_en"]="Installing GRUB for EFI..."
        ["grub_efi_error"]="Error installing GRUB EFI"
        ["grub_efi_error_en"]="Error installing GRUB EFI"
        ["no_block_device"]="Error: Block device not specified for i386 installation"
        ["no_block_device_en"]="Error: Block device not specified for i386 installation"
        ["usage_i386"]="Usage: %s i386 /dev/sdX"
        ["usage_i386_en"]="Usage: %s i386 /dev/sdX"
        ["checking_block"]="Checking block device %s..."
        ["checking_block_en"]="Checking block device %s..."
        ["installing_i386"]="Installing GRUB for i386-pc on %s..."
        ["installing_i386_en"]="Installing GRUB for i386-pc on %s..."
        ["grub_i386_error"]="Error installing GRUB i386"
        ["grub_i386_error_en"]="Error installing GRUB i386"
        ["usage"]="Usage: %s <efi|i386> [device]"
        ["usage_en"]="Usage: %s <efi|i386> [device]"
        ["examples"]="Examples:"
        ["examples_en"]="Examples:"
        ["generating_config"]="Generating GRUB configuration..."
        ["generating_config_en"]="Generating GRUB configuration..."
        ["config_error"]="Error generating GRUB configuration"
        ["config_error_en"]="Error generating GRUB configuration"
        ["success"]="GRUB installation completed successfully!"
        ["success_en"]="GRUB installation completed successfully!"
        ["need_root"]="This script needs to be run as root"
        ["need_root_en"]="This script needs to be run as root"
    )
fi

# Function to display messages in both languages
show_message() {
    local msg_key="$1"
    shift
    printf "%s\n%s\n" "$(printf "${MESSAGES[$msg_key]}" "$@")"
}

# Function to check if it's a valid block device
check_block_device() {
    if [[ ! -b "$1" ]]; then
        show_message "not_block" "$1"
        exit 1
    fi
}

# Function to check if /boot/EFI is mounted and is FAT
check_efi_mount() {
    if ! mountpoint -q /boot/EFI; then
        show_message "efi_not_mounted"
        exit 1
    fi

    # Check if it's a FAT filesystem
    local fstype=$(df -T /boot/EFI | tail -n 1 | awk '{print $2}')
    if [[ ! "$fstype" =~ ^(vfat|fat|fat32)$ ]]; then
        show_message "not_fat" "$fstype"
        exit 1
    fi
}

# Main installation function
install_grub() {
    case "$1" in
        "efi")
            show_message "checking_efi"
            check_efi_mount
            show_message "installing_efi"
            # grub-install --target=x86_64-efi --efi-directory=/boot/EFI --bootloader-id=ARCH
            if ! grub-install --verbose --recheck --target=x86_64-efi --force --efi-directory=/boot/EFI --bootloader-id=ARCH --removable; then
                show_message "grub_efi_error"
                exit 1
            fi
            ;;
            
        "i386")
            if [ -z "$2" ]; then
                show_message "no_block_device"
                show_message "usage_i386" "${0##*/}"
                exit 1
            fi
            show_message "checking_block" "$2"
            check_block_device "$2"
            show_message "installing_i386" "$2"
            #grub-install --target=i386-pc "$2"
            if ! grub-install --verbose --recheck --target=i386-pc --force "$2"; then
                show_message "grub_i386_error"
                exit 1
            fi
            ;;
            
        *)
            show_message "usage" "${0##*/}"
            show_message "examples"
            echo "  ${0##*/} efi"
            echo "  ${0##*/} i386 /dev/sda"
            exit 1
            ;;
    esac

    show_message "generating_config"
    if ! grub-mkconfig -o /boot/grub/grub.cfg; then
        show_message "config_error"
        exit 1
    fi
    
    show_message "success"
}

# Check if running as root
if [ "$(id -u)" != "0" ]; then
    show_message "need_root"
    exit 1
fi

# Run main function
install_grub "$@"