#!/bin/bash
#normal_background_color=
#normal_foreground_color=
#selected_background_color=a4bd00

exe=`dmenu_path | dmenu -b -nb '#151617' -nf '#d8d8d8' -sb '#a4bd00' -sf '#151617'` && eval "exec $exe"
