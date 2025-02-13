#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This Bash script grants specific permissions to two Android applications, "Nevo" and "Greenify," using the Android Debug Bridge (ADB). 
It first checks for connected devices and exits if none are found. The script then sets a logging property and grants various 
permissions to the specified apps, confirming successful permission grants at the end. 
DOCUMENTATION

# Check the list of connected devices
if ! adb devices | grep -w "device"; then
    echo "No devices connected."
    exit 1
fi

adb shell setprop persist.log.tag.NotificationService DEBUG
adb shell pm grant com.oasisfeng.nevo android.permission.READ_LOGS
adb shell pm grant com.oasisfeng.nevo android.permission.INTERACT_ACROSS_USERS
adb -d shell pm grant com.oasisfeng.greenify android.permission.DUMP
adb -d shell pm grant com.oasisfeng.greenify android.permission.WRITE_SECURE_SETTINGS
adb -d shell pm grant com.oasisfeng.greenify android.permission.READ_LOGS
echo 'Permissions granted for Oasis Feng, successfully'