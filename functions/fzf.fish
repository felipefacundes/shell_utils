function fzf_fish
    set file ~/.fzf.fish

    if not test -f $file; and command -v fzf &>/dev/null
        fzf --fish | tee $file &>/dev/null
    end

    if test -f $file
        source $file
    end
end

fzf_fish