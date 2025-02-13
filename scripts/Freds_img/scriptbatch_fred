#!/bin/bash
#
# Developed by Fred Weinhaus 10/27/2018 .......... revised 2/15/2019
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
# USAGE: scriptbatch -c command [-i inputfolder] [-o outputfolder]  [-f format] 
# [-s suffix] [-p path2imagemagick]
# USAGE: scriptbatch [-h or -help]
#
# OPTIONS:
#
# -c     command              path to the script file with all its argument, except the  
#                             input and output images; required; the whole command must 
#                             be enclosed in single or double quotes
# -i     inputfolder          path to the input image folder including the folder name; 
#                             default is the folder from which scriptbatch is called
# -o     outputfolder         path to the output image folder including the folder name; 
#                             default is the same as the input folder; if the folder 
#                             does not already exist, it will be created
# -f     format               format for filtering input images; space and/or comma 
#                             separate list; default is that all files in the 
#                             inputfolder will be processed; typical formats are 
#                             jpg, png, tiff (case insensitive).
# -s     suffix               suffix is the extension to add to the output images 
#                             without the period; default is the same suffix as the 
#                             input; typical suffixes are jpg, png, tiff
# -p     path2imagemagick     path to imagemagick convert/magick; default assumes it is 
#                             in your PATH environment variable.
#                       
#
###
#
# NAME: SCRIPTBATCH 
# 
# PURPOSE: To run another script over a folder of images.
# 
# DESCRIPTION: SCRIPTBATCH runs another script over a folder of images, but only those
# scripts that take one input and create one output and do not use arguments that need
# quoting.
# 
# OPTIONS: 
#
# -c command ... COMMAND is the path to the script script file with all its arguments 
# as specified by the script in question. Do not include the input and output images. 
# If an argument is a color definition, then it can only be a color name or a hex color 
# without quotes. Other color specifications do not work. Also the script cannot handle 
# any other arguments that require quoting. If the path to the script in in your PATH 
# environment variable, then the path to the script may be left off. Use the script[.sh] 
# as it is on your system. COMMAND is a required argument. Enclose it all in single or 
# double quotes. 
# 
# -i inputfolder ... INPUTFOLDER is the path to the the folder of input images and must 
# include the folder name. The default is folder from which scriptbatch is called.
# 
# -o outputfolder ... OUTPUTFOLDER is the path to the output image folder including the 
# folder name. The default is the same folder as the input folder. If the folder does 
# not already exist, it will be created.
#
# -f format ... FORMAT for filtering input images. Space and/or comma separate list. 
# The default is to process all files in the inputfolder. Typical formats are: 
# jpg, png, tiff (case insensitive). Example: "jpg,png" or "jpg png" or "jpg, png" 
# will only process jpg and png format images.
# 
# -s suffix ... SUFFIX is the extension to add to the output images without the period. 
# The default is the same suffix as the input. Typical suffixes are jpg, png, tiff.
# 
# -p path2imagemagick ... PATH2IMAGEMAGICK is the path to imagemagick convert/magick, 
# excluding convert or magick. The default assumes it is in your PATH environment 
# variable. Typical locations are: /usr/local/bin, /usr/bin, /opt/local/bin, etc.
# 
# NOTE: The scriptbatch script can use commands for scripts that take one input and 
# one output only, respectively and do not use arguments that need quoting such as a 
# list of control points or color specifications with parentheses, such as rgb(...). 
# The exception is that colors may be specified as color names or hex values without 
# quoting. The hex value must include the leading # symbol. Some scripts can use control 
# points specified via a text file. Those scripts will work when using the textfile.
# 
# EXAMPLES: All but the first (continued in the first 3 lines) assume that the 
# scriptbatch script is initiated from the current directory, the desktop, and which 
# has two folders, test1 and test2. All assume that the path2imagemagick is in the 
# PATH environment variable. Do not preface local directories with ./
# 
# /Users/fred/applications/ImageMagick-Scripts/bin/scriptbatch \
# -c "/Users/fred/applications/ImageMagick-Scripts/bin/2colorthresh" \
# -f png -s tiff -i /Users/fred/desktop/test1 -o /Users/fred/desktop/test2
# 
# scriptbatch -c "2colorthresh" -f png -s tiff -i test1 -o test2
# scriptbatch -c "textcleaner -g -e stretch -f 25 -o 20" -f tif -s jpg -i test1 -o test2
# scriptbatch -c "bordergrid -s 10 -t 2 -o 4 -d 1 -a 45 -b 0 -c #FFFFFF" -f png -s tiff -i ../desktop/test1 -o ../desktop/test2
# scriptbatch -c 'curves -c curve -f pointfile.txt' -f png -s tiff -i test1 -o test2
# 
# CAVEAT: No guarantee that this script will work on all platforms, 
# nor that trapping of inconsistent parameters is complete and 
# foolproof. Use At Your Own Risk. 
# 
######
#

# set default values
command=""
inputfolder=""
outputfolder=""
path2imagemagick=""
format=""
suffix=""

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
elif [ $# -gt 14 ]
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
				-c)    # get command
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID COMMAND SPECIFICATION ---"
					   checkMinus "$1"
					   command="$1"
					   [ "$command" = "" ] && errMsg "--- COMMAND=$command MUST NOT START WITH A MINUS SIGN ---"
					   ;;
				-i)    # get inputfolder
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID INPUTFOLDER SPECIFICATION ---"
					   checkMinus "$1"
					   inputfolder="$1"
					   [ "$inputfolder" = "" ] && errMsg "--- INPUTFOLDER=$inputfolder MUST NOT START WITH A MINUS SIGN ---"
					   ;;
				-o)    # get outputfolder
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID OUTPUTFOLDER SPECIFICATION ---"
					   checkMinus "$1"
					   outputfolder="$1"
					   [ "$outputfolder" = "" ] && errMsg "--- OUTPUTFOLDER=$outputfolder MUST NOT START WITH A MINUS SIGN ---"
					   ;;
				-p)    # get path2imagemagick
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID PATH2IMAGEMAGICK SPECIFICATION ---"
					   checkMinus "$1"
					   path2imagemagick="$1"
					   [ "$path2imagemagick" = "" ] && errMsg "--- PATH2IMAGEMAGICK=$commpath2imagemagickand MUST NOT START WITH A MINUS SIGN ---"
					   ;;
				-f)    # get format
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID FORMAT SPECIFICATION ---"
					   checkMinus "$1"
					   format="$1"
					   [ "$format" = "" ] && errMsg "--- FORMAT=$format MUST NOT START WITH A MINUS SIGN ---"
					   ;;
				-s)    # get suffix
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID SUFFIX SPECIFICATION ---"
					   checkMinus "$1"
					   suffix="$1"
					   [ "$suffix" = "" ] && errMsg "--- SUFFIX=$suffix MUST NOT START WITH A MINUS SIGN ---"
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
fi

# put path2imagemagick in PATH environment variable
# not sure this will filter down into the actual script that will be run
[ "$path2imagemagick" != "" ] && export "$path2imagemagick"

# test if command supplied
[ "$command" = "" ] && errMsg "--- NO COMMAND SUPPLIED ---"

# set up default inputfolder
if [ "$inputfolder" = "" ]; then
	inputfolder=`pwd`
fi
#echo "inputfolder=$inputfolder;"

# test existence of inputfolder
[ -d "$inputfolder" -a -r "$inputfolder" -a -s "$inputfolder" ] || errMsg "--- DIRECTORY $inputfolder DOES NOT EXIST OR IS NOT READABLE OR IS EMPTY ---"


# if outputfolder does not exist, then create it; else test if readable
[ "$outputfolder" = "" ] && outputfolder=$inputfolder
if [ ! -d "$outputfolder" ]; then
	mkdir "$outputfolder" || errMsg "--- FAILED TO CREATE DIRECTORY $outputfolder ---"
else
	[ -r "$outputfolder" ] || errMsg "--- DIRECTORY $outputfolder EXISTS BUT IS NOT READABLE ---"
fi
#echo "outputfolder=$outputfolder;"


for img in $inputfolder/*; do


# test input image for valid format
if [ "$format" != "" ]; then
	# change space and or commas to be replaced by "\|"
	# note must escape the \ twice so that it turns into "\|" without the quotes
	format=`echo "$format" | sed 's/[ ,][ ,]*/\\\|/g'`
	#echo "format=$format;"
	#echo "img=$img;"
	img=`echo "$img" | grep -i "$format"`
fi
[ "$img" = "" ] && continue
echo "img=$img;"


# get img name without suffix
imgname=`convert -ping "$img" -format "%t" info:`



# get default suffix from input image
if [ "$suffix" = "" ]; then
	suffix=`convert -ping "$img" -format "%e" info:`
fi
#echo "suffix=$suffix;"


# setup output image
outimage="${outputfolder}/${imgname}.$suffix"


# do command processing from selected script and argument

#echo "command=$command;"
#echo "img=$img;"
#echo "outimage=$outimage;"

bash $command $img $outimage

done

exit 0
