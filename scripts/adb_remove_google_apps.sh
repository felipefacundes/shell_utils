#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This Bash script is designed to uninstall a predefined list of Android applications from connected devices using the Android Debug Bridge (ADB). 
It first checks if any devices are connected; if not, it exits with a message. 
The script then iterates through an array of app package names, attempting to uninstall each one for the user with ID 0. 
After each uninstallation command, it waits for the process to complete before moving on to the next app. 
DOCUMENTATION

# com.asus.ia.asusapp (MyAsus) | com.asus.dm (FotaService)
apps=(
    com.netflix.mediaclient
    com.netflix.partner.activation
    com.asus.dm
    com.asus.ia.asusapp
    com.asus.weathertime
    com.asus.filemanager
    com.facebook.orca
    com.facebook.katana
    com.facebook.system
    com.facebook.services
    com.facebook.appmanager
    com.google.ar.lens
    com.android.chrome
    com.google.android.gm
    com.android.htmlviewer
    com.google.android.tts
    com.google.android.talk
    com.google.android.music
    com.google.android.videos
    com.google.android.youtube
    com.google.android.calendar
    com.android.bookmarkprovider
    com.google.android.apps.docs
    com.google.android.apps.maps
    com.google.android.apps.plus
    com.google.android.apps.turbo
    com.google.android.play.games
    com.google.android.apps.books
    com.google.android.apps.photos
    com.google.android.apps.tachyon
    com.google.android.apps.magazines
    com.google.android.apps.wellbeing
    com.google.android.marvin.talkback
    com.google.android.apps.walletnfcrel
    com.google.android.apps.youtube.music
    com.google.android.projection.gearhead
    com.google.android.googlequicksearchbox
    com.google.android.apps.googleassistant
)

    # com.android.egg
    # com.android.bips
    # de.telekom.tsc
    # com.motorola.demo
    # com.motorola.help
    # com.motorola.genie
    # com.motorola.brapps
    # com.motorola.ccc.ota
    # com.motorola.demo.env
    # com.motorola.ccc.notification
    # com.motorola.timeweatherwidget
    # com.google.android.apps.nbu.files
    # com.motorola.motosignature.app

# Check the list of connected devices
if ! adb devices | grep -w "device"; then
    echo "No devices connected."
    exit 1
fi

for i in "${apps[@]}"; do
    echo -e "\nIt has been removed ${i}?:"
    adb shell pm uninstall --user 0 "$i"
    uninstall_pid=$!
    wait $uninstall_pid
done