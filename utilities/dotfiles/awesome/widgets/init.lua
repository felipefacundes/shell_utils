-- License: GPLv3
-- Credits: Felipe Facundes
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
-- local menubar = require("menubar")

-- {{{ Menu
-- Create a custom menu button
local jgmenu_button = awful.button({ }, 1, function () openJgmenu() end)

-- Create an image widget with icon beautiful.awesome_icon and link the button to it
mylauncher = wibox.widget.imagebox(beautiful.awesome_icon)
mylauncher:buttons(jgmenu_button)
-- }}}


-- {{{ Custom Widgets
-- ------------------------- Volume info ------------------------- --
volume_widget = awful.widget.watch("bash -c '~/.shell_utils/scripts/system-info-for-panels -vol'", 0.1)
volume_widget:connect_signal("button::press", function(_, _, _, button)
    if button == 1 then
        awful.spawn("pavucontrol")
    elseif button == 3 then
        awful.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle")
    end
end)
-- Create tooltip
local volume_widget_tooltip = awful.tooltip({ objects = { volume_widget } })
-- Define tooltip text
volume_widget_tooltip:set_text("Volume Status")
volume_widget:connect_signal("mouse::enter", function()
    volume_widget_tooltip.visible = true
end)
volume_widget:connect_signal("mouse::leave", function()
    volume_widget_tooltip.visible = false
end)
---------------------------------------------------------------------

-- ------------------------- Memory info ------------------------- --
mem_widget = awful.widget.watch("bash -c '~/.shell_utils/scripts/system-info-for-panels -m'", 1)
mem_widget:connect_signal("button::press", function(_, _, _, button)
    if button == 1 then
        awful.spawn("alacritty -e htop")
    end
end)
-- Create tooltip
local mem_widget_tooltip = awful.tooltip({ objects = { mem_widget } })
-- Define tooltip text
mem_widget_tooltip:set_text("RAM memory status")
mem_widget:connect_signal("mouse::enter", function()
    mem_widget_tooltip.visible = true
end)
mem_widget:connect_signal("mouse::leave", function()
    mem_widget_tooltip.visible = false
end)
---------------------------------------------------------------------

-- -------------------------- CPU info -------------------------- --
cpu_widget = awful.widget.watch("bash -c '~/.shell_utils/scripts/system-info-for-panels -c'", 1)
cpu_widget:connect_signal("button::press", function(_, _, _, button)
    if button == 1 then
        awful.spawn("alacritty -e watch cpupower frequency-info")
    end
end)
-- Create tooltip
local cpu_widget_tooltip = awful.tooltip({ objects = { cpu_widget } })
-- Define tooltip text
cpu_widget_tooltip:set_text("CPU status")
cpu_widget:connect_signal("mouse::enter", function()
    cpu_widget_tooltip.visible = true
end)
cpu_widget:connect_signal("mouse::leave", function()
    cpu_widget_tooltip.visible = false
end)
---------------------------------------------------------------------

-- ------------------------- Pacman info ------------------------- --
pacman_widget = awful.widget.watch("bash -c '~/.shell_utils/scripts/system-info-for-panels -pac'", 1)
pacman_widget:connect_signal("button::press", function(_, _, _, button)
    if button == 1 then
        awful.spawn("alacritty -e bash -c '~/.shell_utils/scripts/upgrade-system'")
    end
end)
-- Create tooltip
local pacman_widget_tooltip = awful.tooltip({ objects = { pacman_widget } })
-- Define tooltip text
pacman_widget_tooltip:set_text("Pacman status")
pacman_widget:connect_signal("mouse::enter", function()
    pacman_widget_tooltip.visible = true
end)
pacman_widget:connect_signal("mouse::leave", function()
    pacman_widget_tooltip.visible = false
end)
---------------------------------------------------------------------

-- ------------------------- Uptime info ------------------------- --
uptime_widget = awful.widget.watch("bash -c '~/.shell_utils/scripts/system-info-for-panels -up'", 1)
uptime_widget:connect_signal("button::press", function(_, _, _, button)
    if button == 1 then
        awful.spawn("bash -c '~/.shell_utils/scripts/rofi-power-menu-simple'")
    end
end)
-- Create tooltip
local uptime_widget_tooltip = awful.tooltip({ objects = { uptime_widget } })
-- Define tooltip text
uptime_widget_tooltip:set_text("Uptime info")
uptime_widget:connect_signal("mouse::enter", function()
    uptime_widget_tooltip.visible = true
end)
uptime_widget:connect_signal("mouse::leave", function()
    uptime_widget_tooltip.visible = false
end)
---------------------------------------------------------------------

-- -------------------------- GPU info -------------------------- --
gpu_widget = awful.widget.watch("bash -c '~/.shell_utils/scripts/system-info-for-panels -gpu'", 1)
gpu_widget:connect_signal("button::press", function(_, _, _, button)
    if button == 1 then
        awful.spawn("alacritty -e watch glxinfo -B")
    end
end)
-- Create tooltip
local gpu_widget_tooltip = awful.tooltip({ objects = { gpu_widget } })
-- Define tooltip text
gpu_widget_tooltip:set_text("GPU info")
gpu_widget:connect_signal("mouse::enter", function()
    gpu_widget_tooltip.visible = true
end)
gpu_widget:connect_signal("mouse::leave", function()
    gpu_widget_tooltip.visible = false
end)
---------------------------------------------------------------------

-- ------------------ Create a textclock widget ------------------ --
mytextclock = wibox.widget.textclock()
mytextclock:connect_signal("button::press", function(_, _, _, button)
    if button == 1 then
        awful.spawn('gsimplecal')
    elseif button == 3 then
        awful.spawn('bash -c "~/.shell_utils/scripts/pyholidays-calendar"')
    end
end)
---------------------------------------------------------------------
-- }}}


-- {{{ Awesome defaults
-- ---------------------- Widgets Defaults ---------------------- --

-- Menubar configuration
-- menubar.utils.terminal = terminal -- Set the terminal for applications that require it

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()


screen.connect_signal("request::desktop_decoration", function(s)
    -- Each screen has its own tag table.
    awful.tag({ "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X" }, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()

    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox {
        screen  = s,
        buttons = {
            awful.button({ }, 1, function () awful.layout.inc( 1) end),
            awful.button({ }, 3, function () awful.layout.inc(-1) end),
            awful.button({ }, 4, function () awful.layout.inc(-1) end),
            awful.button({ }, 5, function () awful.layout.inc( 1) end),
        }
    }

    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = {
            awful.button({ }, 1, function(t) t:view_only() end),
            awful.button({ modkey, "Shift", }, 1, function(t)
                                            if client.focus then
                                                client.focus:move_to_tag(t)
                                            end
                                        end),
            awful.button({ }, 3, awful.tag.viewtoggle),
            awful.button({ modkey, "Shift", }, 3, function(t)
                                            if client.focus then
                                                client.focus:toggle_tag(t)
                                            end
                                        end),
            awful.button({ }, 4, function(t) awful.tag.viewprev(t.screen) end),
            awful.button({ }, 5, function(t) awful.tag.viewnext(t.screen) end),
        }
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = {
            awful.button({ }, 1, function (c)
                c:activate { context = "tasklist", action = "toggle_minimization" }
            end),
            awful.button({ }, 2, function (c) c:kill() end),
            awful.button({ }, 3, function() 
                awful.menu.client_list {
                    theme = {
                        width = 700, -- Largura da lista de clientes
                        height = 32, -- Altura da lista de clientes
                        icon_size = 32, -- Tamanho dos ícones
                    }
                }
            end),
            awful.button({ }, 4, function() awful.client.focus.byidx(-1) end),
            awful.button({ }, 5, function() awful.client.focus.byidx( 1) end),
        }
    }

    -- Create the wibox
    s.mywibox = awful.wibar {
        position = "top",
        screen   = s,
        widget   = {
            layout = wibox.layout.align.horizontal,
            { -- Left widgets
                layout = wibox.layout.fixed.horizontal,
                mylauncher,
            {
                widget = wibox.container.margin,
                top = 0,
                bottom = 0,
                right = 4, -- Adjust the margin to the right as needed
                left = 4,  -- Adjust the left margin as needed
                layout = wibox.container.margin,
            },
            s.mytaglist,
            {
                widget = wibox.container.margin,
                top = 0,
                bottom = 0,
                right = 6, -- Adjust the margin to the right as needed
                left = 6,  -- Adjust the left margin as needed
                layout = wibox.container.margin,
            },
                s.mypromptbox,
            },
            s.mytasklist, -- Middle widget
            { -- Right widgets
                layout = wibox.layout.fixed.horizontal,
                -- mykeyboardlayout,
                volume_widget,
                mem_widget,
                cpu_widget,
                pacman_widget,
                gpu_widget,
                uptime_widget,
                wibox.widget.systray(),
                mytextclock,
                s.mylayoutbox,
            },
        }
    }
end)

-- }}}
