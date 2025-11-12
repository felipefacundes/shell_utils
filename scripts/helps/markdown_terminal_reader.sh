markdown_terminal_reader() {
    bgreen_on_blue="\033[32;1;44m"
    nc="\033[0m"

    clear
    
	cat <<EOF | { echo -e "$(cat)"; }
# MARKDOWN READER FOR TERMINAL

1. bat (with markdown support)
    - BAT is an advanced replacement for CAT, supported by the highlight of syntax:
        $ ${bgreen_on_blue}bat file.md${nc}
2. mdcat (best for formatted display)
    - MDCAT renders Markdown with terminal formatting:
        $ ${bgreen_on_blue}mdcat file.md${nc}
3. glow (great look)
    - Glow is an interactive Markdown reader, which displays the hands -style files:
        $ ${bgreen_on_blue}glow file.md${nc}
4. Using less with MDless
    - MDless improves Markdown's display on Less:
    - Install:
        $ ${bgreen_on_blue}gem install mdless${nc}
    - Run:
        $ ${bgreen_on_blue}mdless file.md${nc}
EOF
}