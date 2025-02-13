# USER
if command -v codium &>/dev/null; then
    alias code='codium'
fi

# ROOT
if command -v doas &>/dev/null; then 
    alias sudo='doas'
fi

# SYSTEM
if command -v advcp &>/dev/null; then
    alias cp="advcp -gi" # Advanced copy
else
    alias cp="cp -i" # Standard copy
fi