im_options() {
echo "
# An educational aid that provides a list of useful examples for manipulating images using ImageMagick's convert command. | Uma ajuda educativa que fornece uma lista de exemplos úteis para manipulação de imagens utilizando o comando convert do ImageMagick
"

# Regular Colors
green='\033[0;32m'        # Green
yellow='\033[0;33m'       # Yellow
bold='\033[1m'            # Only Bold
color_off='\033[0m'       # Text Reset

clear
# Exibe as informações
echo -e "${bold}${yellow}\nSee more options, with:${color_off}"
echo -e "${green}magick --help\n${color_off}"
echo -e "${bold}${yellow}Look at the examples below:${color_off}"
echo -e "${green}magick -channel RGB -contrast-stretch 1x1%${color_off}"
echo -e "${green}magick -level 25%,75%${color_off}"
echo -e "${green}magick +level 0x120%${color_off}"
echo -e "${green}magick -sharpen  0x4${color_off}"
echo -e "${green}magick -contrast -contrast -contrast${color_off}"
echo -e "${green}magick -fx \"u*125/102\" +repage${color_off}"
echo -e "${green}magick -channel green -fx \"u*42/255\" +repage${color_off}"
echo -e "${green}magick -function Polynomial \"-3.786,5.767,-1.543,0.562,0\"${color_off}"
echo -e "${green}magick -sigmoidal-contrast 2,0%${color_off}"
echo -e "${green}magick -sigmoidal-contrast 15x30%${color_off}"
echo -e "${green}magick -normalize -unsharp 12x25 (To increase sharpness)${color_off}"
echo -e "${green}magick image.jpg -colors 5 palette.jpg\n${color_off}"
echo -e "${bold}${yellow}To extract dominant colors and then improve the image with Gimp:" 
echo -e "${green}Duplicate layer > menu - inverter color > and in layers > extract grains.\n${color_off}"
echo -e "${bold}${yellow}Visit:${color_off}"
echo -e "https://legacy.imagemagick.org/Usage/color_mods/"
echo -e "https://im.snibgo.com/ckbkClut.htm"
echo -e "https://www.imagemagick.org/Usage/mapping/"
echo -e "https://www.imagemagick.org/Usage/thumbnails/"
echo -e "https://legacy.imagemagick.org/Usage/transform/"
echo -e "https://www.imagemagick.org/discourse-server/viewtopic.php?t=35836"
echo -e "https://legacy.imagemagick.org/Usage/photos/"
echo -e "https://stackoverflow.com/questions/26889358/generate-color-palette-from-image-with-imagemagic\n"
}