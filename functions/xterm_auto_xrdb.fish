if test -z "$XTERM_VERSION" -a -f ~/.Xresources
    if test ! -f ~/.xrdb_check.lock
        cp -f ~/.Xresources ~/.xrdb_check.lock
        xrdb -merge ~/.Xresources
    end

    set md5sum_xresources (md5sum ~/.Xresources | awk '{ print $1 }')
    set md5sum_xrdb_check (md5sum ~/.xrdb_check.lock | awk '{ print $1 }')

    if test "$md5sum_xresources" != "$md5sum_xrdb_check"
        cp -f ~/.Xresources ~/.xrdb_check.lock
        xrdb -merge ~/.Xresources
    end

    set -e md5sum_xresources
    set -e md5sum_xrdb_check
else if test -n "$XTERM_VERSION" -a -f ~/.Xresources
    xrdb -merge ~/.Xresources
end