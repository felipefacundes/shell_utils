#!/bin/env python
# License: GPLv3
# Credits: Felipe Facundes

"""
This Python script retrieves information about connected screens using the 'xrandr' command. 
It extracts the screen names, width, and height in millimeters, converting them to inches. 
The script then calculates the diagonal size of each screen and prints a formatted table 
displaying the screen name, width, height, and diagonal measurements. The output is rounded 
based on a specified factor, which can be adjusted by the user.
"""

import subprocess
# change the round factor if you like
r = 1

screens = [l.split() for l in subprocess.check_output(
    ["xrandr"]).decode("utf-8").strip().splitlines() if " connected" in l]

scr_data = []
for s in screens:
    try:
        scr_data.append((
            s[0],
            float(s[-3].replace("mm", "")),
            float(s[-1].replace("mm", ""))
            ))
    except ValueError:
        pass

print(("\t").join(["Screen", "width", "height", "diagonal\n"+32*"-"]))
for s in scr_data:
    scr = s[0]; w = s[1]/25.4; h = s[2]/25.4; d = ((w**2)+(h**2))**(0.5)
    print(("\t").join([scr]+[str(round(n, 1)) for n in [w, h, d]]))