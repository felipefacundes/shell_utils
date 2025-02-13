#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
Fix Linux time when dual booting with Windows
DOCUMENTATION

set -e

# Define messages in both English and Portuguese
declare -A MESSAGES

if [[ "${LANG,,}" =~ pt_ ]]; then
    MESSAGES=(
        [checking]="Verificando a configuração atual do RTC..."
        [using_utc]="O Linux está usando UTC para o relógio de hardware. Alterando para horário local..."
        [changed]="RTC agora está configurado para horário local para compatibilidade com o Windows."
        [already_set]="O RTC já está configurado para horário local. Nenhuma alteração necessária."
        [syncing]="Sincronizando o horário do sistema..."
        [restarting]="Reiniciando o serviço de sincronização de horário..."
        [configuring]="Configurando /etc/locale.conf para garantir compatibilidade..."
        [config_done]="Configuração de horário corrigida no /etc/locale.conf."
        [done]="Concluído! Seu sistema Linux agora deve ter o horário correto ao usar dual boot com o Windows."
    )
else
    MESSAGES=(
        [checking]="Checking current RTC time setting..."
        [using_utc]="Linux is using UTC for the hardware clock. Changing to local time..."
        [changed]="RTC is now set to local time for Windows compatibility."
        [already_set]="RTC is already set to local time. No changes needed."
        [syncing]="Synchronizing system time..."
        [restarting]="Restarting time synchronization service..."
        [configuring]="Configuring /etc/locale.conf to ensure compatibility..."
        [config_done]="Time settings fixed in /etc/locale.conf."
        [done]="Done! Your Linux system should now have the correct time when dual booting with Windows."
    )
fi

echo "${MESSAGES[checking]}"
CURRENT_SETTING=$(timedatectl show --property=LocalRTC --value)

if [[ "$CURRENT_SETTING" == "no" ]]; then
    echo "${MESSAGES[using_utc]}"
    sudo timedatectl set-local-rtc 1 --adjust-system-clock
    echo "${MESSAGES[changed]}"
else
    echo "${MESSAGES[already_set]}"
fi

echo "${MESSAGES[syncing]}"
sudo hwclock --systohc --localtime

echo "${MESSAGES[restarting]}"
sudo systemctl restart systemd-timesyncd

# Ensure /etc/locale.conf contains the correct settings
echo "${MESSAGES[configuring]}"
if ! grep -q '^UTC=no' /etc/locale.conf; then
    echo 'UTC=no' | sudo tee -a /etc/locale.conf > /dev/null
fi
if ! grep -q '^HARDWARECLOCK="localtime"' /etc/locale.conf; then
    echo 'HARDWARECLOCK="localtime"' | sudo tee -a /etc/locale.conf > /dev/null
fi
echo "${MESSAGES[config_done]}"

echo "${MESSAGES[done]}"
