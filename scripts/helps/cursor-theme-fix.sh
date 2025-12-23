cursor_theme_fix()
{
( cat <<'EOF'
# Cursor theme tips

Remove  Inherits="..."
from cursor.theme and index.theme

============================
Example:

Search all themes with the term 'Inherits='
$ grep -ri 'Inherits=' ~/.icons

Remove all at once:
$ find ~/.icons -name 'index.theme' -o -name 'cursor.theme' -exec sed -i 's/Inherits=.*//g' {} +
Or
$ find ~/.icons -name "index.theme" -o -name "cursor.theme" -exec sed -i 's/Inherits=.*//g' {} \;

# Tips 
Allowed cursor sizes: 24: Default. 32: Medium. 48: Large.
============================
Before (Antes): 

[Icon Theme]
Name = Night Diamond (Blue)
Inherits=core

After (Depois):

[Icon Theme]
Name = Night Diamond (Blue)

EOF
) | less -i -R
}