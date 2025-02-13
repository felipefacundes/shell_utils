#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This Bash script sets up and manages the PipeWire audio server, enabling necessary services and handling potential 
failures by restarting PulseAudio if it becomes unresponsive.
DOCUMENTATION

# Define a signal handler to capture SIGINT (Ctrl+C)
trap 'kill $(jobs -p)' SIGTERM #SIGHUP #SIGINT #SIGQUIT #SIGABRT #SIGKILL #SIGALRM #SIGTERM

delay=10
loop=2

# Check pipewire
#aplay -lL
#pactl list cards
#pactl list sinks
#sudo fuser -v /dev/snd/*
#wpctl status
#systemctl --user status pipewire pipewire-media-session pipewire-pulse wireplumber

#systemctl --user mask pipewire pipewire-pulse
systemctl --user enable --now pipewire.service
systemctl --user enable --now wireplumber.service
systemctl --user enable --now pipewire-media-session.service
systemctl --user enable --now pipewire-pulse
#systemctl --user mask wireplumber pipewire pipewire-pulse
#systemctl --user mask wireplumber pipewire pipewire-alsa
#systemctl --user mask wireplumber pipewire pipewire-jack

pactl load-module module-equalizer-sink
pactl load-module module-dbus-protocol

# FIX PULSEAUDIO
while true;
do sleep "$delay"
    if ! pactl stat; then
        systemctl --user stop pulseaudio.service pulseaudio.socket;
        sleep "$loop";
        pulseaudio --kill;
        sleep "$loop";
        pulseaudio --start;
        sleep "$loop";
        if ! pactl stat; then
            systemctl --user restart pulseaudio.service;
            sleep "$loop";
            systemctl --user reset-failed pulseaudio.service
        fi
    fi
done

# Wait for all child processes to finish
wait