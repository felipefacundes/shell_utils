#!/bin/bash

cat <<'EOF' | echo -e "$(cat)"
\033[0;32mxclip -selection clipboard -i < input_file\033[0m

\033[0;33mOr:\033[0m

\033[0;32mxclip -sel c < input_file\033[0m

\033[0;32mcommand | xclip -o\033[0m
\033[0;32mcommand | xsel -b\033[0m
EOF