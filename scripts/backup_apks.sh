#!/bin/bash
# Credits: https://stackoverflow.com/questions/4032960/how-do-i-get-an-apk-file-from-an-android-device

# Check the list of connected devices
if ! adb devices | grep -w "device"; then
    echo "No devices connected."
    exit 1
fi

mkdir 3_packages && cd 3_packages || exit
cd .. 
for package in $(adb shell pm list packages -3 | tr -d '\r' | sed 's/package://g'); do 
    apk=$(adb shell pm path "$package" | tr -d '\r' | sed 's/package://g'); 
    echo "Pulling $apk"; adb pull -p "$apk" "$package".apk; 
done

mkdir all_packages && cd all_packages || exit
cd ..
for i in $(adb shell pm list packages | awk -F':' '{print $2}'); do
    adb pull "$(adb shell pm path "$i" | awk -F':' '{print $2}')"
    mv base.apk "${i}.apk" &> /dev/null 
done
