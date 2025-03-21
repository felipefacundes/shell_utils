######################################
############### System ###############
alias update-grub='sudo mkinitcpio -P && sudo grub-mkconfig -o /boot/grub/grub.cfg'
alias reboot='~/.shell_utils/scripts/shutdown_wait_pacman.sh -r'
alias shutdown="~/.shell_utils/scripts/shutdown_wait_pacman.sh -p"
alias desligar="shutdown"
alias des="shutdown"
alias poweroff="shutdown"
alias killX='setxkbmap -option "terminate:ctrl_alt_bksp"; xdotool key ctrl+alt+BackSpace'
#alias all_kill="pkill -9 -u $USER"
alias all_kill="killX"
alias kill_all="all_kill"
alias death_all="all_kill"
alias matar_tudo="all_kill"
alias my_current_terminal_is='help my_current_terminal_is'
alias my_terminal_is='my_current_terminal_is'
alias current_terminal_is='my_current_terminal_is'
alias b='cd ~/.local/bin'
alias bi='b'
alias bin='b'
alias del='echo "Use: rm"'
alias s='sudo'
alias sS='screen -S'
alias sr='screen -r'
alias sls='screen -ls'
alias suspend_log='cat /tmp/suspend_if_inert.log'
alias suspend_if_inert_log='suspend_log'
alias flush='~/.shell_utils/scripts/faqs/flush.sh'
alias clip="~/.shell_utils/scripts/faqs/clip.sh"
alias clipboard='clip' #for https://getclipboard.app Use: cb command
alias clipcopy='clip'
alias pbcopy='clip'
alias copy='clip'

alias c='clear'
alias list-gpu='~/.shell_utils/scripts/faqs/list-gpu.sh'
alias gpu-list='list-gpu'
alias INTEL='~/.shell_utils/scripts/faqs/intel-modesetting.sh'
alias NVIDIA='~/.shell_utils/scripts/faqs/nvidia-modesetting.sh'
alias kl='echo keyboard layout...'
alias keyboard_layout='kl'
alias diff="diff --color=auto"
alias less='less -R -i'
alias lessh='LESSOPEN="| pygmentize -O style=monokai %s" less -M -R '

alias mv='mv -v --backup=t'
alias aur="yay -S --nodiffmenu --noeditmenu --noupgrademenu --mflags --skipinteg --noconfirm"
alias cpi="cpupower frequency-info"
alias cpu="cpupower frequency-info; lscpu"
alias so="echo source ~/.zshrc; source ~/.zshrc"
alias lwine="rm -rf ~/.local/share/applications/*wine*"
alias remove_wine_desktop_shortcuts="lwine"
alias rwine="lwine"
alias limpawine="lwine"
alias ref='~/.shell_utils/scripts/faqs/reflector_help.sh'
alias mirror="ref"
alias listmonitor="xrandr --listmonitors ; echo --- ; echo xrandr --listmonitors"
alias monitorlist="listmonitor"
alias gamma="echo 'xrandr --output YOUR_MONITOR --gamma 1:1:1'"
alias gama="gamma"
alias mute="pactl set-sink-mute @DEFAULT_SINK@ toggle"
alias volume="echo 'pactl set-sink-volume 50'"
alias vol="volume"
alias ent='xdotool key Return'
alias enter='ent'
alias min='xdotool windowminimize $(xdotool getactivewindow)'
alias f='fff'
alias fir='firefox'
alias fp='export DISPLAY=":0" && unset HISTFILE && firefox --private-window'
alias firefox_private='fp'
alias private='fp'
alias ex='export'

alias bkp='~/.shell_utils/scripts/faqs/bkp.sh'
alias wine_list='bash <(curl -s https://raw.githubusercontent.com/felipefacundes/PS/master/other_scripts/wine_list.sh)'
alias vpn_wgcf_warp_cloudflare='~/.shell_utils/scripts/faqs/vpn_wgcf_warp_cloudflare.sh'
alias warp_vpn_cloudflare='vpn_wgcf_warp_cloudflare'
alias udisksctl_mount='echo "udisksctl mount -b /dev/sdX"'
alias udisksctl_unmount='echo "udisksctl unmount -b /dev/sdX"'

# Time Zone Info
alias timezone_info='~/.shell_utils/scripts/faqs/timezone_info.sh'
alias time_zone_info='timezone_info'
alias timezone_select='timezone_info'
alias time_zone_select='timezone_info'
alias fuso_horario_select='timezone_info'
alias fuso_horario_info='timezone_info'

# Commands with Help
alias scp='help scp_help; scp'
alias ssh2send="scp"
alias cget='~/.shell_utils/scripts/faqs/cget.sh'
alias curl_get='cget'
alias ftp='~/.shell_utils/scripts/faqs/ftp.sh'
alias ssh='~/.shell_utils/scripts/faqs/ssh.sh'
alias sftp='~/.shell_utils/scripts/faqs/sftp.sh'
alias wget='help wget_help; wget'
alias dd='help dd_help; dd'
alias rsync='help rsync_help; rsync'
alias rsync2ssh="help rsync_help"

# Smart command with chatgpt
alias ci='tgpt -s'
alias comando_inteligente='ci'
alias smart_command='ci'
alias sc='ci'
alias cli_ai='tgpt -s'