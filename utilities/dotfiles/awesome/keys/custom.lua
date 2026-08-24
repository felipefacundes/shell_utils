-- Dropdown alacritty terminal style quake
require("modules.quake-terminal")

local awful = require("awful")

-------- Custom Apps and Commands --------
awful.keyboard.append_global_keybindings({

	-- Shortcut to open terminal in Nautilus directory
	awful.key({ modkey, }, "F4", function() 
		awful.spawn("bash -c '~/.shell_utils/scripts/custom-terminal-for-nautilus'")
	end, {description = "Open terminal in Nautilus directory", group = "launcher"}),

    -- Accessibility
    awful.key( { modkey, "Shift" }, "z", function()
        awful.spawn("bash -c 'if ! pidof xzoom; then xzoom; else pkill -9 xzoom; fi'")
    end, {description = 'magnifying', group = 'accessibility'} ),

    awful.key( { modkey, altkey }, "z", function()
        awful.spawn("bash -c 'if ! pidof zoomx; then zoomx; else pkill -9 zoomx; fi'")
    end, {description = 'magnifying', group = 'accessibility'} ),

    -- Alacritty style Dropdown application
    awful.key( { modkey, }, "F12", function()
        _G.toggle_quake()
    end, {description = 'dropdown application', group = 'system'} ),

    -- PLayerCTL Play-Pause
    awful.key({ modkey, }, "F8", function()
        awful.spawn("bash -c 'playerctl play-pause &'")
    end, {description = "playerctl", group = "client"}),

	-- PLayerCTL STOP
    awful.key({ modkey, }, "F6", function()
        awful.spawn("bash -c 'playerctl stop &'")
    end, {description = "playerctl", group = "client"}),

    -- Lockscreen
    awful.key({ altkey, "Control", }, "l", function()
        awful.spawn("bash -c 'xscreensaver-command -lock &'")
    end, {description = "lockscreen", group = "client"}),

    -- Open video with MPV
    awful.key({ altkey, "Control", }, "m", function()
        awful.spawn("bash -c '~/.shell_utils/scripts/open-video-with-mpv &'")
    end, {description = "Open video with MPV", group = "client"}),
    -- Clipboard Manager
    awful.key({ altkey, "Control", }, "c", function()
        awful.spawn("rofi -modi 'clipboard:greenclip print' -show clipboard -run-command '{cmd}'")
    end, {description = "Clipboard Manager", group = "client"}),
    -- Print Screen
    awful.key({ }, "Print", function()
        awful.spawn("bash -c '~/.shell_utils/scripts/print-screen -p -msg &'")
    end, {description = "ScreenShot", group = "print"}),
    -- Print Screen with delay.
    awful.key({ altkey, }, "Print", function()
        awful.spawn("bash -c '~/.shell_utils/scripts/print-screen -ap -msg &'")
    end, {description = "ScreenShot with delay", group = "print"}),
    -- Print Screen: Interactively select a window or rectangle with the mouse.
    awful.key({ "Shift", }, "Print", function()
        awful.spawn("bash -c '~/.shell_utils/scripts/print-screen -sp -msg &'")
    end, {description = "ScreenShot Interactively select a window or rectangle with the mouse", group = "print"}),
    -- Print Screen of currently focused window.
    awful.key({ "Control", }, "Print", function()
        awful.spawn("bash -c '~/.shell_utils/scripts/print-screen -cp -msg &'")
    end, {description = "ScreenShot of currently focused window", group = "print"}),
    -- Print Screen: Interactively with gnome-screenshot
    awful.key({ altkey, "Shift" }, "Print", function()
        awful.spawn("bash -c 'gnome-screenshot -i &'")
    end, {description = "ScreenShot Interactively with gnome-screenshot", group = "print"}),
    -- View ScreenShot
    awful.key({ modkey, }, "v", function()
        awful.spawn("bash -c '~/.shell_utils/scripts/print-screen -d &'")
    end, {description = "View ScreenShot", group = "print"}),

    -- Launchers
    awful.key({ "Control", "Shift", }, "space", function()
        awful.spawn("bash -c 'synapse &'")
    end, {description = "synapse", group = "launcher"}),
    awful.key({ modkey, }, "z", function()
        awful.spawn("rofi -show drun -font 'Poppins 13'")
    end, {description = "rofi", group = "launcher"}),
    awful.key({ altkey, }, "w", function()
        awful.spawn("bash -c 'rofi-search &'")
    end, {description = "rofi", group = "launcher"}),
    awful.key({ altkey, }, "F2", function()
        awful.spawn("bash -c 'rofi -no-lazy-grab -show drun -modi drun -theme ~/.config/rofi/launchers/misc/row_dock.rasi &'")
    end, {description = "rofi", group = "launcher"}),
    awful.key({ altkey, }, "F3", function()
        awful.spawn("bash -c 'rofi -no-lazy-grab -show drun -modi drun -theme ~/.config/rofi/launchers/misc/appdrawer.rasi &'")
    end, {description = "rofi", group = "launcher"}),
    awful.key({ modkey, }, "F2", function()
        awful.spawn("bash -c 'rofi -no-lazy-grab -show drun -modi drun -theme ~/.config/rofi/launchers/misc/screen.rasi &'")
    end, {description = "rofi", group = "launcher"}),

    -- Help Shortcuts
    awful.key({ "Control", }, "F1", function()
        awful.spawn("alacritty -e bash -c 'ccat --color=always ~/.config/awesome/rc.lua | less -i -R -N --use-color --color=HBCEMNPRSWsu'")
    end, {description = "Help Shortcuts", group = "awesome"}),

    -- Awesome Theme Manager
    awful.key({ altkey, "Control", }, "t", function()
        awful.spawn("bash -c '~/.shell_utils/scripts/awesome-theme-select &'")
    end, {description = "Awesome Theme Manager", group = "awesome"}),

    -- Translate to Clipboard
    awful.key({ modkey, "Shift", }, "t", function()
        awful.spawn("bash -c '~/.shell_utils/scripts/translate-to-clipboard &'")
    end, {description = "Translate to Clipboard", group = "apps"}),

    -- Calculator
    awful.key({ }, "XF86Calculator", function()
        awful.spawn("bash -c 'mate-calc &'")
    end, {description = "Mate Calculator", group = "apps"}),

    -- Xpad (Postit) --
    awful.key({ modkey, altkey, }, "p", function()
        awful.spawn("bash -c 'xpad -t &'")
    end, {description = "Xpad Postit", group = "apps"}),

    -- Gromit-MPX (Annotate in Screen) --
    awful.key({ modkey, }, "g", function()
        awful.spawn("bash -c 'killall -SIGUSR1 gromit-mpx; gromit-mpx &'")
    end, {description = "Gromit", group = "apps"}),

    -- Telegram
    awful.key({ modkey, altkey, }, "t", function()
        awful.spawn("bash -c '64gram-desktop &'")
    end, {description = "Telegram Messenger", group = "apps"}),

    -- Bluetooth Menu
    awful.key({ modkey, }, "b", function()
        awful.spawn("bash -c '~/.shell_utils/scripts/rofi-bluetooth &'")
    end, {description = "Bluetooth Menu", group = "system"}),

    -- quickmark search
    awful.key( { altkey, "Shift" }, "q", function()
        awful.spawn("bash -c '~/.shell_utils/scripts/quickmarks -a &'")
    end,  {description = 'quickmark add', group = 'browser'} ),
    awful.key( { altkey, "Shift" }, "s", function()
        awful.spawn("bash -c '~/.shell_utils/scripts/quickmarks -s &'")
    end,  {description = 'quickmark search', group = 'browser'} ),

    -- File Browser
    awful.key({ }, "XF86HomePage", function()
        awful.spawn("bash -c 'xdg-open ~/ &'")
    end, {description = "File Browser", group = "browser"}),
    awful.key({ modkey, }, "n", function()
        awful.spawn("bash -c 'xdg-open ~/ &'")
    end, {description = "File Browser", group = "browser"}),

    -- Firefox
    awful.key({ modkey, "Control", }, "f", function()
        awful.spawn("bash -c 'firefox &'")
    end, {description = "Firefox", group = "browser"}),

    -- Chromium Browser
    awful.key({ }, "XF86Search", function()
        awful.spawn("bash -c 'chromium &'")
    end, {description = "Chromium", group = "browser"}),
    awful.key({ modkey, "Control", }, "c", function()
        awful.spawn("bash -c 'chromium &'")
    end, {description = "Chromium", group = "browser"}),

    -- Volume Control
    awful.key({ modkey, }, "p", function()
        awful.spawn("bash -c 'pavucontrol &'")
    end, {description = "Pulseaudio", group = "system"}),
    -- Mute
    awful.key({ }, "XF86AudioMute", function()
        awful.spawn("bash -c '~/.shell_utils/scripts/volume-with-osd -m &'")
    end, {description = "Pulseaudio", group = "system"}),
    awful.key({ modkey, "Shift" }, "m", function()
        awful.spawn("bash -c '~/.shell_utils/scripts/volume-with-osd -m &'")
    end, {description = "Pulseaudio", group = "system"}),
    -- Increase ...
    awful.key({ }, "XF86AudioRaiseVolume", function()
        awful.spawn("bash -c '~/.shell_utils/scripts/volume-with-osd -v +5% &'")
    end, {description = "Pulseaudio", group = "system"}),
    awful.key({ modkey, "Shift", }, "Up", function()
        awful.spawn("bash -c '~/.shell_utils/scripts/volume-with-osd -v +5% &'")
    end, {description = "Pulseaudio", group = "system"}),
    -- Decrease ...
    awful.key({ }, "XF86AudioLowerVolume", function()
        awful.spawn("bash -c '~/.shell_utils/scripts/volume-with-osd -v -5% &'")
    end, {description = "Pulseaudio", group = "system"}),
    awful.key({ modkey, "Shift", }, "Down", function()
        awful.spawn("bash -c '~/.shell_utils/scripts/volume-with-osd -v -5% &'")
    end, {description = "Pulseaudio", group = "system"}),

    -- Light Brightness
    awful.key({ modkey, "Shift", }, "Left", function()
        awful.spawn("bash -c 'xbacklight -dec +2 ; light -U 10 &'")
    end, {description = "Brightness decrease", group = "system"}),
    awful.key({ modkey, "Shift", }, "Right", function()
        awful.spawn("bash -c 'xbacklight -inc +2 ; light -A 10 &'")
    end, {description = "Brightness increase", group = "system"}),
    -- Light Brightness: all monitors
    awful.key({ altkey, "Shift", }, "Next", function()
        awful.spawn("bash -c '~/.shell_utils/scripts/all-bright - &'")
    end, {description = "Brightness decrease all monitors", group = "system"}),
    awful.key({ altkey, "Shift", }, "Prior", function()
        awful.spawn("bash -c '~/.shell_utils/scripts/all-bright + &'")
    end, {description = "Brightness increase all monitors", group = "system"}),

    --                 Mouse Emulation
    -- Mouse Scroll
    awful.key({ modkey, }, "w", function()
        awful.spawn("xdotool click 4")
    end, {description = "xdotool click 4", group = "system"}),

    awful.key({ modkey, }, "s", function()
        awful.spawn("xdotool click 5")
    end, {description = "xdotool click 5", group = "system"}),

    -- Mouse Click
    awful.key({ modkey, }, "Delete", function()
        awful.spawn("xdotool click 1")
    end, {description = "xdotool click 1", group = "system"}),
    awful.key({ modkey, }, "End", function()
        awful.spawn("xdotool click 2")
    end, {description = "xdotool click 2", group = "system"}),
    awful.key({ modkey, }, "Next", function()
        awful.spawn("xdotool click 3")
    end, {description = "xdotool click 3", group = "system"}),
    
    -- Mouse Hide
    awful.key({ modkey, }, "m", function()
        awful.spawn("unclutter -idle 0")
    end, {description = "Mouse hide", group = "system"}),
    
    -- Mouse Move UP
    awful.key({ modkey, }, "Up", function()
        awful.spawn("xdotool mousemove_relative -- 0 -10")
    end, {description = "xdotool mousemove_relative Up", group = "system"}),
    awful.key({ modkey, "Control", }, "Up", function()
        awful.spawn("xdotool mousemove_relative -- 0 -40")
    end, {description = "xdotool mousemove_relative Up", group = "system"}),
    -- Mouse Move Down
    awful.key({ modkey, }, "Down", function()
        awful.spawn("xdotool mousemove_relative -- 0 10")
    end, {description = "xdotool mousemove_relative Down", group = "system"}),
    awful.key({ modkey, "Control", }, "Down", function()
        awful.spawn("xdotool mousemove_relative -- 0 40")
    end, {description = "xdotool mousemove_relative Down", group = "system"}),
    -- Mouse Move Left
    awful.key({ modkey, }, "Left", function()
        awful.spawn("xdotool mousemove_relative -- -10 0")
    end, {description = "xdotool mousemove_relative Left", group = "system"}),
    awful.key({ modkey, "Control", }, "Left", function()
        awful.spawn("xdotool mousemove_relative -- -40 0")
    end, {description = "xdotool mousemove_relative Left", group = "system"}),
    -- Mouse Move Right
    awful.key({ modkey, }, "Right", function()
        awful.spawn("xdotool mousemove_relative -- 10 0")
    end, {description = "xdotool mousemove_relative Right", group = "system"}),
    awful.key({ modkey, "Control", }, "Right", function()
        awful.spawn("xdotool mousemove_relative -- 40 0")
    end, {description = "xdotool mousemove_relative Right", group = "system"}),

    -- Shutdown PowerOff
    awful.key({ altkey, "Control", }, "d", function()
        awful.spawn("bash -c '~/.shell_utils/scripts/rofi-power-menu-simple'")
    end, {description = "Shutdown", group = "system"}),
    awful.key({ modkey, "Control", }, "BackSpace", function()
        awful.spawn("bash -c '~/.shell_utils/scripts/shutdown-wait-pacman -r'")
    end, {description = "Reboot", group = "system"}),

    -- Enable sloppy focus, so that focus follows mouse.
    awful.key({ modkey, "Shift", "Control", }, "s", function()
        client.connect_signal("mouse::enter", function(c)
            c:emit_signal("request::activate", "mouse_enter", {raise = false})
        end)
    end, {description = "Enable sloppy focus", group = "client"}),

    -- ----------      End Custom Apps      ---------- --
})
