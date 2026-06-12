function aliases
    eval $(alias | awk '{ print $2 }' | fzf)
end