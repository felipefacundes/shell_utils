#!/bin/bash
#
# Developed by Fred Weinhaus 9/6/2018 .......... revised 9/6/2018
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
# USAGE: woodbrand [-b blur] [-m motionblur ] [-n negate] [-B brighness] [-S saturation]
# [-H hue] infile bgfile1 [bgfile2] outfile
# 
# USAGE: woodbrand [-help]
# 
# OPTIONS:
# 
# -b     blur           inner blur amount; integer>=0; default=5
# -m     motionblur     motionblur amount; integer>=0; default=10
# -n     negate         negate (invert) the binary input image; yes or no; default=no
# -B     brightness     brightness amount; integer>=0; default=100 (no change)
# -S     Saturation     saturation amount; integer>=0; default=100 (no change)
# -h     hue            hue amount; integer>=0; default=100 (no change)
#
# infile is a binary image where white will produce the branding
# bgfile1 is the background wood grain image
# bgfile2 is an optional background wood grain image used in the branded area
# 
###
# 
# NAME: WOODBRAND 
# 
# PURPOSE: To create a branded effect in a wood grain image using a binary image as the 
# brand.
# 
# DESCRIPTION: WOODBRAND creates a branded effect in a wood grain image using a binary 
# image as the brand. The white part of the binary input image will be the branded 
# area in the wood grain bgfile1. An optional bgfile2 may be used for the branded 
# region. The blur provides a symmetric inner blur. The motion blur adds a directional 
# blur to add a lighting effect. The brighntess, saturation and hue modify the wood 
# grain bgfile1 to darken it for the brand. Alternately, an optional second, bgfile2, 
# may be used to change the texture and color in the branded area in place of the 
# brightness, saturation and hue.
# 
# ARGUMENTS: 
# 
# -b blur ... BLUR is the inner blur amount. Values are integers>=0. The default=5.
# 
# -m motionblur ... MOTIONBLUR amount. Values are integers>=0. The default=10.
# 
# -n negate ... NEGATE (invert) the binary input image. The choices are: yes (y) or 
# no (n). The default=no.
# 
# -B brightness ... BRIGHTNESS amount for the branded area. Values are integers>=0. 
# The default=35. A value of 100 is no change.
#
# -S Saturation ... Saturation amount for the branded area. Values are integers>=0. 
# The default=100 (no change).
# 
# -h hue ... Hue amount. Values are integers>=0. The default=100 (no change). Values 
# vary between 0 and 200 for a full 360 degree hue change. Values larger than 100 
# shift the hue towards green and values smaller than 100 shift the hue towards the 
# blue.
# 
# NOTE: This script is not designed for images with transparency.
# 
# CAVEAT: No guarantee that this script will work on all platforms, 
# nor that trapping of inconsistent parameters is complete and 
# foolproof. Use At Your Own Risk. 
# 
######
# 

# set default values
blur=5
motionblur=10
negate=no
brightness=35
saturation=100
hue=100

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
elif [ $# -gt 16 ]
	then
	errMsg "--- TOO MANY ARGUMENTS WERE PROVIDED ---"
else
	while [ $# -gt 0 ]
		do
			# get parameter values
			case "$1" in
		     -help)    # help information
					   echo ""
					   usage2
					   exit 0
					   ;;
				-b)    # get blur
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID BLUR SPECIFICATION ---"
					   checkMinus "$1"
					   blur=`expr "$1" : '\([0-9]*\)'`
					   [ "$blur" = "" ] && errMsg "--- BLUR=$blur MUST BE A NON-NEGATIVE INTEGER ---"
					   ;;
				-m)    # get motionblur
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID MOTIONBLUR SPECIFICATION ---"
					   checkMinus "$1"
					   motionblur=`expr "$1" : '\([0-9]*\)'`
					   [ "$motionblur" = "" ] && errMsg "--- MOTIONBLUR=$motionblur MUST BE A NON-NEGATIVE INTEGER ---"
					   ;;
				-n)    # get  negate
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID NEGATE SPECIFICATION ---"
					   checkMinus "$1"
					   negate=`echo "$1" | tr '[A-Z]' '[a-z]'`
					   case "$negate" in 
					   		yes|y) negate=yes ;;
					   		no|n) negate=no;;
					   		*) errMsg "--- NEGATE=$negate IS AN INVALID VALUE ---"  ;;
					   esac
					   ;;
				-B)    # get  brightness
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID BRIGHTNESS SPECIFICATION ---"
					   checkMinus "$1"
					   brightness=`expr "$1" : '\([0-9]*\)'`
					   [ "$brightness" = "" ] && errMsg "--- BRIGHTNESS=$brightness MUST BE A NON-NEGATIVE INTEGER VALUE (with no sign) ---"
					   ;;
				-S)    # get  saturation
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID SATURATION SPECIFICATION ---"
					   checkMinus "$1"
					   saturation=`expr "$1" : '\([0-9]*\)'`
					   [ "$saturation" = "" ] && errMsg "--- SATURATION=$saturation MUST BE A NON-NEGATIVE INTEGER VALUE (with no sign) ---"
					   ;;
				-H)    # get  hue
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID HUE SPECIFICATION ---"
					   checkMinus "$1"
					   hue=`expr "$1" : '\([0-9]*\)'`
					   [ "$hue" = "" ] && errMsg "--- HUE=$hue MUST BE A NON-NEGATIVE INTEGER VALUE (with no sign) ---"
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
	num=$#
	if [ $num -eq 2 ]; then
		infile="$1"
		outfile="$2"
	elif [ $num -eq 3 ]; then
		infile="$1"
		bgfile1="$2"
		outfile="$3"
	elif [ $num -eq 4 ]; then
		infile="$1"
		bgfile1="$2"
		bgfile2="$3"
		outfile="$4"
	else 
		errMsg "--- INCONSISTENT NUMBER OF IMAGES PROVIDED ---"
	fi
fi

# test that infile provided
[ "$infile" = "" ] && errMsg "NO INPUT FILE SPECIFIED"

# test that bgfile1 provided
[ "$bgfile1" = "" ] && errMsg "NO BACKGROUND1 FILE SPECIFIED"

# test that outfile provided
[ "$outfile" = "" ] && errMsg "NO OUTPUT FILE SPECIFIED"


# setup temporary images
tmpA1="$dir/woodbrand_1_$$.mpc"
tmpB1="$dir/woodbrand_1_$$.cache"
trap "rm -f $tmpA1 $tmpB1; exit 0" 0
trap "rm -f $tmpA1 $tmpB1; exit 1" 1 2 3 15

# read the input image into the temporary cached image and test if valid
convert -quiet "$infile" +repage $tmpA1 ||
	echo "--- FILE $infile DOES NOT EXIST OR IS NOT AN ORDINARY FILE, NOT READABLE OR HAS ZERO size  ---"

# get dimensions of infile
dims=`convert -ping $tmpA1 -format "%wx%h" info:`

# set up for negate
if [ "$negate" = "yes" ]; then
	negating="-negate"
else
	negating=""
fi

if [ "$bgfile2" = "" ]; then
	convert $tmpA1 $negating -write mpr:img \
		\( -clone 0 -blur 0x$blur -auto-level -level 50x100% -background black -motion-blur 0x${motionblur}-135 \) \
		\( -clone 0,1 -compose multiply -composite \) \
		-delete 1 \
		+swap -alpha off -compose copy_opacity -composite \
		\( "$bgfile1" -resize "$dims^<" +write mpr:back1 \
			-define modulate:colorspace=HSB -modulate $brightness,$saturation,$hue \) \
		-compose multiply -composite \
		mpr:img -alpha off -compose copy_opacity -composite \
		mpr:back1 +swap -gravity center -compose over -composite \
		"$outfile"

else
	convert $tmpA1 $negating -write mpr:img \
		\( -clone 0 -blur 0x$blur -auto-level -level 50x100% -background black -motion-blur 0x${motionblur}-135 \) \
		\( -clone 0,1 -compose multiply -composite \) \
		-delete 1 \
		+swap -alpha off -compose copy_opacity -composite \
		\( "$bgfile2" -resize "$dims^<" \
			-define modulate:colorspace=HSB -modulate $brightness,$saturation,$hue \) \
		-gravity center -compose multiply -composite \
		mpr:img -alpha off -compose over -compose copy_opacity -composite \
		"$bgfile1" +swap -gravity center -compose over -composite \
		"$outfile"
fi
	
exit 0



