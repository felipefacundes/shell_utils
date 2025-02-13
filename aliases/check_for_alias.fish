# USER
if command -v codium > /dev/null
    alias code='codium'
end

# ROOT
if command -v doas > /dev/null
    alias sudo='doas'
end

# SYSTEM
if command -v advcp > /dev/null
    alias cp="advcp -gi" # Advanced copy
else
    alias cp="cp -i" # Standard copy
end