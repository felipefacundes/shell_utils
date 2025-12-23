#!/bin/env python
# License: GPLv3
# Credits: Felipe Facundes

"""
This script is a Python application that creates a system tray icon with notification capabilities. 
Its main purpose is to provide users with a simple way to display notifications from the system tray. 

Strengths:
1. User -Friendly Interface: The script utilizes the 'pystray' library to create a system tray icon, 
making it easy for users to interact with notifications.
2. Customizable Notifications: Users can specify the icon, title, message, and notification label 
through command-line arguments, allowing for personalized notifications.
3. Exit Option: The application includes a menu item to exit the program, enhancing user control.
4. Open Source: The script is licensed under GPLv3, promoting collaboration and sharing within the developer community.
5. Image Support: It uses the 'PIL' library to handle image files, ensuring compatibility with various image formats.

Capabilities:
- Displays a customizable system tray icon.
- Sends notifications with user-defined titles and messages.
- Provides a straightforward command-line interface for easy configuration.

Dependencies:
1. 'pystray' - Third-party library for system tray icon creation (install via pip).
2. 'PIL' (Pillow) - Third-party library for image processing (install via pip).
3. 'argparse' - Native library for command-line argument parsing (no installation needed).

Installation of Dependencies:
- Install 'pystray' and 'Pillow' using pip:

  pip install pystray Pillow
"""

import time
import pystray
from PIL import Image
import argparse

def on_quit(icon, item):
    icon.stop()

def main(icon_path, title, message, notification_label):
    image = Image.open(icon_path)

    def show_notification(icon, item):
        icon.notify(title, message)

    menu = (pystray.MenuItem(notification_label, show_notification), pystray.MenuItem("Exit", on_quit))
    icon = pystray.Icon("Systray icon", image, "Systray icon", menu)
    icon.run()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Displays a system tray icon with notification.")
    parser.add_argument("-i", "--icon", help="Icon image path")
    parser.add_argument("-t", "--title", help="Notification title")
    parser.add_argument("-m", "--message", help="Notification message")
    parser.add_argument("-n", "--notification_label", help="Label to show notification")

    args = parser.parse_args()

    if not args.icon or not args.title or not args.message or not args.notification_label:
        parser.print_help()
    else:
        main(args.icon, args.title, args.message, args.notification_label)
