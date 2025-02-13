#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This script demonstrates how heredoc can interpret escapes using echo -e or printf, 
showcasing its capabilities, including: 
1. color escape interpretation
2. tabulation escape interpretation
3. newline escape interpretation.
DOCUMENTATION

cat <<'EOF' | echo -e "$(cat)"
\033[0;31mThis is a red text.\033[0m
\033[0;32mThis is a green text.\033[0m
\nHere is a tab:\tAnd here is the text after the tab.
\nThis is a text with a new line.\n
And here is a tab:\tAnd here is the text after the tab.
EOF

cat <<'EXAMPLE'


########################

This script is like this:

#!/bin/bash
cat <<'EOF' | echo -e "$(cat)"
\033[0;31mThis is a red text.\033[0m
\033[0;32mThis is a green text.\033[0m
\nHere is a tab:\tAnd here is the text after the tab.
\nThis is a text with a new line.\n
And here is a tab:\tAnd here is the text after the tab.
EOF
EXAMPLE
