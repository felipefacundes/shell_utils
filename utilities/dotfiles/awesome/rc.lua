-- License: GPLv3
-- Credits: Felipe Facundes
-- awesome_mode: api-level=4:screen=on
-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")


-- {{{ Variable definitions 
------------------------------------------------------------------------------------
-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")

-- This is used later as the default terminal and editor to run.
terminal = "alacritty" -- "xterm"
editor = os.getenv("EDITOR") or "vim" -- "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
altkey = "Mod1"
modkey = "Mod4"
------------------------------------------------------------------------------------
-- }}} 

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
naughty.connect_signal("request::display_error", function(message, startup)
    naughty.notification {
        urgency = "critical",
        title   = "Oops, an error happened"..(startup and " during startup!" or "!"),
        message = message
    }
end)
-- }}}

-- {{{ Theme Manager
-- Themes define colours, icons, font and wallpapers.
require("themes")
-- beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
beautiful.init(gears.filesystem.get_configuration_dir() .. my_themes)
beautiful.gap_single_client = true -- Optional
beautiful.useless_gap = 5
-- }}}
-- {{{ Wallpaper
screen.connect_signal("request::wallpaper", function(s)
    local wallpaper = beautiful.wallpaper  -- Substitua isso pelo caminho para sua imagem de papel de parede
    gears.wallpaper.maximized(wallpaper, s, true)
end)
-- }}}

require("awful.autofocus")

-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- Autostart applications
require("autostart")
-- -- -- -- -- -- -- -- --
-- Functions
require("functions")
-- -- -- -- -- -- -- -- --
-- Custom layouts --
require("layouts")
--------------------
-- Custom widgets --
require("widgets")
--------------------

-- {{{ Key bindings
require("keys.custom")
-- General Awesome keys
require("keys.general")
-- }}}

-- {{{ Rules
-- Custom rules
-- require("rules.custom")
-- -- -- -- -- --
-- Aplication rules
require("rules.aplications")
-- -- -- -- -- --
-- General rules
require("rules.general")
-- -- -- -- -- -- -- --
-- }}}