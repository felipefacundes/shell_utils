#!/bin/bash
#
# Developed by Fred Weinhaus 7/21/2018 .......... 7/21/2018
#
# ------------------------------------------------------------------------------
# 
# Licensing:
# 
# Copyright © Fred Weinhaus
# 
# My scripts are available free of charge for non-commercial use, ONLY.
# 
# For use of my scripts in commercial (for-profit) environments or 
# non-free applications, please contact me (Fred Weinhaus) for 
# licensing arrangements. My email address is fmw at alink dot net.
# 
# If you: 1) redistribute, 2) incorporate any of these scripts into other 
# free applications or 3) reprogram them in another scripting language, 
# then you must contact me for permission, especially if the result might 
# be used in a commercial or for-profit environment.
# 
# My scripts are also subject, in a subordinate manner, to the ImageMagick 
# license, which can be found at: http://www.imagemagick.org/script/license.php
# 
# ------------------------------------------------------------------------------
# 
####
#
# USAGE: wiggle [-f frames] [-d delay] [-w wavelengths] [-D direction] [-a amount] 
# infile outfile
# USAGE: wiggle [-h or -help]
#
# OPTIONS:
#
# -f     frames         number of frames to generate in the animation; integer>0; 
#                       default=25
# -d     delay          animation delay between frames; integer>0; default=5 
# -w     wavelengths    number of sinusoidal wavelengths to span the image dimension;
#                       float>0; default=0.5; (typically in half or integer values)
# -D     direction      direction of the scrolling wiggles; choices are: left, right, 
#                       up, down; default=right
# -a     amount         amount of wiggle distortion; integer>0; default=10
#
###
#
# NAME: WIGGLE 
# 
# PURPOSE: Creates a sinusoidal wiggling animation.
# 
# DESCRIPTION: WIGGLE creates a sinusoidal wiggling animation. The wiggling can be 
# either horizontal or vertical.
# 
# 
# OPTIONS: 
# 
# -f frames ... FRAMES are the number of frames to generate in the animation. Value 
# are integers>0. The default=15.
# 
# -d delay ... DELAY is animation delay between frames in ticks. Values are integers>0. 
# The default=5.
# 
# -w wavelengths ... WAVELENGTHS are the number of sinusoidal wavelengths to span 
# the image dimension. Values are floats>0. The default=0.5. (Typically values are 
# in half or integer amounts).
# 
# -D direction ... DIRECTION of the scrolling wiggles; choices are: left (l), right (r), 
# up (u), down (d). The default=right
# 
# -a amount ... AMOUNT of wiggle distortion. Values are integers>0. The default=10.
# 
# CAVEAT: No guarantee that this script will work on all platforms, 
# nor that trapping of inconsistent parameters is complete and 
# foolproof. Use At Your Own Risk. 
# 
######
#

# set default values
frames=15
delay=20
wavelengths=0.5
direction="right"
amount=10


# set directory for temporary files
dir="."    # suggestions are dir="." or dir="/tmp"

# set up functions to report Usage and Usage with Description
PROGNAME=`type $0 | awk '{print $3}'`  # search for executable on path
PROGDIR=`dirname $PROGNAME`            # extract directory of program
PROGNAME=`basename $PROGNAME`          # base name of program
usage1() 
	{
	echo >&2 ""
	echo >&2 "$PROGNAME:" "$@"
	sed >&2 -e '1,/^####/d;  /^###/g;  /^#/!q;  s/^#//;  s/^ //;  4,$p' "$PROGDIR/$PROGNAME"
	}
usage2() 
	{
	echo >&2 ""
	echo >&2 "$PROGNAME:" "$@"
	sed >&2 -e '1,/^####/d;  /^######/g;  /^#/!q;  s/^#*//;  s/^ //;  4,$p' "$PROGDIR/$PROGNAME"
	}


# function to report error messages
errMsg()
	{
	echo ""
	echo $1
	echo ""
	usage1
	exit 1
	}


# function to test for minus at start of value of second part of option 1 or 2
checkMinus()
	{
	test=`echo "$1" | grep -c '^-.*$'`   # returns 1 if match; 0 otherwise
    [ $test -eq 1 ] && errMsg "$errorMsg"
	}

# test for correct number of arguments and get values
if [ $# -eq 0 ]
	then
	# help information
   echo ""
   usage2
   exit 0
elif [ $# -gt 12 ]
	then
	errMsg "--- TOO MANY ARGUMENTS WERE PROVIDED ---"
else
	while [ $# -gt 0 ]
		do
			# get parameter values
			case "$1" in
		  -help|-h)    # help information
					   echo ""
					   usage2
					   exit 0
					   ;;
				-f)    # get frames
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID FRAMES SPECIFICATION ---"
					   checkMinus "$1"
					   frames=`expr "$1" : '\([0-9]*\)'`
					   [ "$frames" = "" ] && errMsg "--- FRAMES=$frames MUST BE A NON-NEGATIVE INTEGER (with no sign) ---"
					   test1=`echo "$frames == 0" | bc`
					   [ $test1 -eq 1 ] && errMsg "--- FRAMES=$frames MUST BE A POSITIVE INTEGER ---"
					   ;;
				-d)    # get delay
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID DELAY SPECIFICATION ---"
					   checkMinus "$1"
					   delay=`expr "$1" : '\([0-9]*\)'`
					   [ "$delay" = "" ] && errMsg "--- DELAY=$delay MUST BE A NON-NEGATIVE INTEGER (with no sign) ---"
					   test1=`echo "$delay == 0" | bc`
					   [ $test1 -eq 1 ] && errMsg "--- DELAY=$delay MUST BE A POSITIVE INTEGER ---"
					   ;;
				-w)    # get wavelengths
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID WAVELENGTHS SPECIFICATION ---"
					   checkMinus "$1"
					   wavelengths=`expr "$1" : '\([.0-9]*\)'`
					   [ "$wavelengths" = "" ] && errMsg "--- WAVELENGTHS=$wavelengths MUST BE A NON-NEGATIVE FLOAT (with no sign) ---"
					   test1=`echo "$wavelengths == 0" | bc`
					   [ $test1 -eq 1 ] && errMsg "--- WAVELENGTHS=$wavelengths MUST BE A POSITIVE FLOAT ---"
					   ;;
			   	-D)    # direction
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID DIRECTION SPECIFICATION ---"
					   checkMinus "$1"
					   direction=`echo "$1" | tr "[:upper:]" "[:lower:]"`
					   case "$direction" in
					   		left|l) direction="left" ;;
					   		right|r) direction="right" ;;
					   		up|u) direction="up" ;;
					   		down|d) direction="down" ;;
					   		*) errMsg "--- DIRECTION=$direction IS NOT A VALID CHOICE ---" ;;
					   esac
					   ;;
				-a)    # get amount
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID AMOUNT SPECIFICATION ---"
					   checkMinus "$1"
					   amount=`expr "$1" : '\([0-9]*\)'`
					   [ "$amount" = "" ] && errMsg "--- AMOUNT=$amount MUST BE A NON-NEGATIVE INTEGER (with no sign) ---"
					   test1=`echo "$amount == 0" | bc`
					   [ $test1 -eq 1 ] && errMsg "--- AMOUNT=$amount MUST BE A POSITIVE INTEGER ---"
					   ;;
			 	-)    # STDIN and end of arguments
					   break
					   ;;
				-*)    # any other - argument
					   errMsg "--- UNKNOWN OPTION ---"
					   ;;
		     	 *)    # end of arguments
					   break
					   ;;
			esac
			shift   # next option
	done
	#
	# get infile and outfile
	infile="$1"
	outfile="$2"
fi

# test that infile provided
[ "$infile" = "" ] && errMsg "NO INPUT FILE SPECIFIED"

# test that outfile provided
[ "$outfile" = "" ] && errMsg "NO OUTPUT FILE SPECIFIED"


# set up temporaries
tmp1A="$dir/wiggle_1_$$.mpc"
tmp1B="$dir/wiggle_1_$$.cache"
tmp2A="$dir/wiggle_2_$$.mpc"
tmp2B="$dir/wiggle_2_$$.cache"
trap "rm -f $tmp1A $tmp1B $tmp2A $tmp2B;" 0
trap "rm -f $tmp1A $tmp1B $tmp2A $tmp2B; exit 1" 1 2 3 15
#trap "rm -f $tmp1A $tmp1B; exit 1" ERR



# test input image
convert -quiet "$infile" +repage "$tmp1A" ||
	errMsg "--- FILE $infile DOES NOT EXIST OR IS NOT AN ORDINARY FILE, NOT READABLE OR HAS ZERO SIZE  ---"

# get image dimensions
WxH=`convert -ping $tmp1A -format "%wx%h" info:`
ww=`echo $WxH | cut -dx -f1`
hh=`echo $WxH | cut -dx -f2`
w1=$((ww-1))
h1=$((hh-1))

if [ "$direction" = "left" -o "$direction" = "right" ]; then
	gradvals="$w1,0"
	xamt=$amount
	yamt=0
else
	gradvals="0,$h1"
	xamt=0
	yamt=$amount
fi

if [ "$direction" = "right" -o "$direction" = "down" ]; then
	sgn="-"
else
	sgn="+"
fi

# do processing
# use subshell processing to avoid saving separate frames

incr=`convert xc: -format "%[fx:360/$frames)]" info:`
convert "$tmp1A" -sparse-color barycentric "0,0 black $gradvals white" $tmp2A
(
for ((k=0; k<frames; k++)); do
phase=`convert xc: -format "%[fx:${sgn}$k*$incr]" info:`
convert $tmp1A \( $tmp2A -function Sinusoid "$wavelengths,$phase,0.5,0.5" \) \
-define compose:args=$xamt,$yamt -compose displace -composite miff:- 
done
) | convert -delay $delay - -loop 0 "$outfile"

exit 0




