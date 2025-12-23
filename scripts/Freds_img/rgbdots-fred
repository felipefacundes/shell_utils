#!/bin/bash
#
# Developed by Fred Weinhaus 5/25/2018 .......... revised 5/25/2018
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
# USAGE: rgbdots [-c color] [-t threshold] infile outfile
# USAGE: rgbdots [-h or -help]
# 
# OPTIONS:
# 
# -c     color         color to use to fill spaces; any opaque IM color is allowed; 
#                      default=white
# -t     threshold     threshold value in percent; 0<=integer<=100; default=50
# 
###
# 
# NAME: RGBDOTS 
# 
# PURPOSE: To transform an image into dots in primary and secondary colors.
# 
# DESCRIPTION: RGBDOTS transforms an image into dots in primary and secondary colors. 
# The process uses a tiling of red, green1, blue pixels and thresholds the logical AND 
# combination of the tiled image with the original channel-by-channel.
# 
# 
# ARGUMENTS: 
# 
# -c color ... COLOR to use to fill spaces. Any opaque IM color is allowed. 
# The default=white
# 
# -t threshold ... THRESHOLD value in percent; 0<=integer<=100; default=50
# 
# CREDITS: Logical AND concept credited to Alan Gibson
# 
# CAVEAT: No guarantee that this script will work on all platforms, 
# nor that trapping of inconsistent parameters is complete and 
# foolproof. Use At Your Own Risk. 
# 
######
# 

# set default values
color="white"
threshold=50

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
elif [ $# -gt 6 ]
	then
	errMsg "--- TOO MANY ARGUMENTS WERE PROVIDED ---"
else
	while [ $# -gt 0 ]
		do
			# get parameter values
			case "$1" in
		  -h|-help)    # help information
					   echo ""
					   usage2
					   exit 0
					   ;;
				-c)    # get color
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID COLOR SPECIFICATION ---"
					   checkMinus "$1"
					   color="$1"
					   ;;
				-t)    # get threshold
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID THRESHOLD SPECIFICATION ---"
					   checkMinus "$1"
					   threshold=`expr "$1" : '\([0-9]*\)'`
					   [ "$threshold" = "" ] && errMsg "--- THRESHOLD=$threshold MUST BE A NON-NEGATIVE INTEGER VALUE (with no sign) ---"
					   testA=`echo "$threshold > 100" | bc`
					   [ $testA -eq 1 ] && errMsg "--- THRESHOLD=$threshold MUST BE AN INTEGER BETWEEN 0 AND 100 ---"
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


# setup temporary images
tmpA="$dir/isolatecolor_1_$$.miff"
trap "rm -f $tmpA;" 0
trap "rm -f $tmpA; exit 1" 1 2 3 15
#trap "rm -f $tmpA1; exit 1" ERR


# read the input image into the temporary cached image and test if valid
convert -quiet "$infile" +repage "$tmpA" ||
	errMsg "--- FILE $infile DOES NOT EXIST OR IS NOT AN ORDINARY FILE, NOT READABLE OR HAS ZERO size  ---"


convert $tmpA \
	\( \( -size 1x1 xc:red xc:green1 xc:blue -append \) \
		\( -size 3x1 xc:$color \) \
		-background white +append +write mpr:colors +delete \) \
	\( -clone 0 -tile mpr:colors -draw "color 0,0 reset" \) \
	-evaluate-sequence And \
	-channel RGB -threshold $threshold% +channel \
	"$outfile"
	
	
exit 0
