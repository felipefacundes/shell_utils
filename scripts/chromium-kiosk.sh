#!/bin/bash
## See https://obrienlabs.net/setup-raspberry-pi-kiosk-chromium/ for more information
## Add this one liner to the end of ~/.config/lxsession/LXDE-pi/autostart after downloading this script to /home/pi/kiosk.sh and making it executable:
## @/home/pi/kiosk.sh

WEBSITE='https://google.com' 
 
# Hide the mouse from the display
unclutter &
 
# If Chrome crashes (usually due to rebooting), clear the crash flag so we don't have the annoying warning bar
sed -i 's/"exited_cleanly":false/"exited_cleanly":true/' ${HOME}/.config/chromium/Default/Preferences
sed -i 's/"exit_type":"Crashed"/"exit_type":"Normal"/' ${HOME}/.config/chromium/Default/Preferences
 
# Run Chromium and open tabs
if ls /usr/bin/chromium-browser > /dev/null 2>&1; then
  /usr/bin/chromium-browser --kiosk "$WEBSITE" &
else
  /usr/bin/chromium --kiosk "$WEBSITE" &
fi
# Start the kiosk loop. This keystroke changes the Chromium tab
# To have just anti-idle, use this line instead:
# xdotool keydown ctrl; xdotool keyup ctrl;
# Otherwise, the ctrl+Tab is designed to switch tabs in Chrome
# #
while (true)
 do
  xdotool keydown ctrl+Tab; xdotool keyup ctrl+Tab;
  sleep 15
done

# Font:
# https://gist.github.com/heywoodlh/1997862f8948015d5d814f046f75271f