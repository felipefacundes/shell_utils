if test -z "$XTERM_VERSION"; and test -f ~/.Xresources
    if test ! -f ~/.xrdb_check.lock
        cp -f ~/.Xresources ~/.xrdb_check.lock >/dev/null 2>&1
        xrdb -merge ~/.Xresources >/dev/null 2>&1
    end

    set md5sum_xresources (md5sum ~/.Xresources | awk '{ print $1 }' 2>/dev/null)
    set md5sum_xrdb_check (md5sum ~/.xrdb_check.lock | awk '{ print $1 }' 2>/dev/null)

    if test "$md5sum_xresources" != "$md5sum_xrdb_check"
        cp -f ~/.Xresources ~/.xrdb_check.lock >/dev/null 2>&1
        xrdb -merge ~/.Xresources >/dev/null 2>&1
    end

    set -e md5sum_xresources
    set -e md5sum_xrdb_check
else if test -n "$XTERM_VERSION"; and test -f ~/.Xresources
    xrdb -merge ~/.Xresources >/dev/null 2>&1
end