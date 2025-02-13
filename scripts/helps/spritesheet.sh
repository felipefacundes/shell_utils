spritesheet_generator_with_imagemagick() {
    cat <<'EOF'
# montage - spritesheet generator with imagemagick - sheet of sprites - How to concatenate icons into a single image with ImageMagick? - Create a spritesheet quick and easy with imagemagick

$ montage -background transparent -geometry +4+4 *.png sprite.gif
$ montage walking/*.png -background none -tile x2 -geometry 512x512+0+0 walking.png

$ magick convert roguelikeSheet_transparent.png -crop 57x31-1-1@ +repage +adjoin spaced-1_%d.png

Fonts:
    How to concatenate icons into a single image with ImageMagick?
    https://stackoverflow.com/questions/88711/how-to-concatenate-icons-into-a-single-image-with-imagemagick

    Create a spritesheet quick and easy with imagemagick
    https://vollnixx.wordpress.com/2012/08/25/create-a-spritesheet-quick-and-easy-with-imagemagick/

    Cutting a Sprite Sheet with ImageMagick
    https://samclane.dev/cutting-a-kenney-sprite-sheet-with-imagemagick/
EOF
}