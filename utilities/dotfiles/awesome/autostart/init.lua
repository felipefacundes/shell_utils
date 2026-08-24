local awful = require("awful")

awful.spawn("bash -c '! pgrep -x greenclip && greenclip daemon &'")
awful.spawn("bash -c '! pgrep -x xpad && xpad -h &'")
-- awful.spawn("bash -c '! pgrep -x xcompmgr && xcompmgr &'")
awful.spawn("bash -c '! pgrep -x picom && delay=10 ~/.shell_utils/scripts/persistent-pid /usr/bin/picom &'")