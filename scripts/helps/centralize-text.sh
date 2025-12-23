centralize_text()
{
cat <<'EOF'
# Centralize text tips
With Color:

red='\033[0;31m'
purple='\033[0;35m'

            printf "%*s\n" $(((`tput cols`)/2)) "$(echo -e ${shell_color_palette[red]}Hello World\!)"

            Or:

            echo -e "
            ${shell_color_palette[red]}Hello World!
            ${shell_color_palette[purple]}A big text, just to see how it looks
            " | sed  -e :a -e "s/^.\{1,$(tput cols)\}$/ & /;ta"

Without Color:
                printf "%*s\n" $(((`tput cols`)/2)) 'Hello World!'

In Script:

            https://bash.cyberciti.biz/guide/Display_centered_text_in_the_screen_in_reverse_video
EOF
}
