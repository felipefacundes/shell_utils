#!/bin/bash
# Credits: https://askubuntu.com/a/1092835/307523

# NAME: flash-primary-screen.sh
# PATH: ~/bin
# DESC: Flashes primary screen colours to alert timer has ended.
# DATE: November 15, 2018

# NOTE: Written for: https://askubuntu.com/a/1092835/307523
#       I'm looking for a command to flash screens (if possible in colors)

# Change 6 variables below to control screen flashing levels
MaxBright="1.5"
MinBright=".5"
MaxRed="2.0"
MaxGreen="2.0"
MaxBlue="2.0"
MinGamma=".5"

declare aXrandr=()

# Next two functions lifted from: eyesome internet sunrise/sunset time screen
# brightness and gamma controller: https://github.com/WinEunuuchs2Unix/eyesome

InitXrandrArray () {

    # Array is used for each monitor and searched by name.
    # Save time to search on connected/disconnected, primary monitor,
    # brightness level, gamma level.

    mapfile -t aXrandr < <(xrandr --verbose --current)

} # InitXrandrArray

SearchXrandrArray () {

    # Parms: $MonXrandrName = xrandr monitor name to search for.

    # NOTE: Entries in array follow predicatble order from xrandr --verbose:

    #       <MONITOR-NAME> connected / disconnected (line 1 of monitor entry)
    #       Gamma:      0.99:0.99:0.99              (line 5 of entry)
    #       Brightness: 0.99                        (line 6 of entry)
    #       CRTC:       9                           (line 8 of entry)

    fNameFnd=false
    fBrightnessFnd=false
    fGammaFnd=false
    fCrtcFnd=false
    XrandrConnection=disconnected
    XrandrPrimary=false
    XrandrGamma=""
    XrandrBrightness=""
    XrandrCRTC=""           # Laptop lid open value=0, lid closed=blank

    for (( i=0; i<"${#aXrandr[*]}"; i++ )) ; do

        line="${aXrandr[$i]}"
        # Have we looped to next monitor and not found search string?
        if [[ "$line" =~ " connected " ]] && [[ $fNameFnd == true ]] ; then
            break
        fi

        if [[ "$line" =~ ^"$MonXrandrName connected" ]]; then
            fNameFnd=true
            XrandrConnection=connected
            [[ "$line" =~ "primary" ]] && XrandrPrimary=true
        fi

        if [[ $fNameFnd == true ]] && [[ $fGammaFnd == false ]] ; then
            if [[ "$line" =~ "Gamma: " ]]; then
                fGammaFnd=true
                XrandrGamma="${line##* }"
                # TODO: Use `xgamma` for accuracy
            fi
        fi

        if [[ $fGammaFnd == true ]] && [[ $fBrightnessFnd == false ]] ; then
            if [[ "$line" =~ "Brightness: " ]]; then
                fBrightnessFnd=true
                XrandrBrightness="${line##* }"
            fi
        fi

        if [[ $fBrightnessFnd == true ]] && [[ $fCrtcFnd == false ]] ; then
            if [[ "$line" =~ "CRTC: " ]]; then
                fCrtcFnd=true
                XrandrCRTC="${line##* }"
                break
            fi
        fi

    done

} # SearchXrandrArray

FlipBright () {

    if [[ $NewBrightness == "$MaxBright" ]] ; then
        NewBrightness="$MinBright"
    else
        NewBrightness="$MaxBright"
    fi

} # FlipBright

CleanUp() {

    xrandr --output "$MonXrandrName" --gamma "$SaveGamma" \
           --brightness "$SaveBrightness"MonXrandrName

    # Compensate for bug in Xrandr as of Nov 15, 2018 with second call
    InitXrandrArray
    SearchXrandrArray
    xrandr --output "$MonXrandrName" --gamma "$XrandrGamma"
    exit 0

} # CleanUp

Main () {

    trap CleanUp INT TERM

    # Get primary monitor current settings
    XrandrName=$(xrandr | awk '/ connected/ {print $1; exit}')
    MonXrandrName=$(xrandr | awk '/ connected/ {print $1; exit}')
    InitXrandrArray
    SearchXrandrArray

    # Did we find primary monitor ok?
    if [[ $fBrightnessFnd == false ]] || [[ $fGammaFnd == false ]] ; then
        echo "Internal Error: Could not find Primary Screen brightness or gamma"
        echo XrandrPrimary: "$XrandrPrimary"
        echo aXrandr[0]: "${aXrandr[0]}"
        echo Brightness: "$XrandrBrightness"
        echo Gamma: "$XrandrGamma"
        exit 2
    fi

    # Restore these values when CleanUping program
    SaveBrightness="$XrandrBrightness"
    SaveGamma="$XrandrGamma"

    # Wait for <Ctrl>+C or until parent kills us.
    while true ; do
        if [[ $Red == true ]] ; then
            Red=false
            Green=true
            NewGamma="$MaxRed:$MinGamma:$MinGamma"
            FlipBright
        elif [[ $Green == true ]] ; then
            Green=false
            NewGamma="$MinGamma:$MaxGreen:$MinGamma"
            FlipBright
        else
            Red=true
            NewGamma="$MinGamma:$MinGamma:$MaxBlue"
            FlipBright
        fi

        xrandr --output "$MonXrandrName" --gamma "$NewGamma" \
       --brightness "$NewBrightness"

        sleep .2

    done

} # Main

Main "$@"