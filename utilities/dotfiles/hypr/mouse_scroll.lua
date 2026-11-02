-- =============================================================================
-- scrollhold.lua
--
-- Hold-to-repeat scrolling for Hyprland: while Super+W (or Super+S) is held,
-- the scroll command keeps running, and it stops the instant either key is
-- released.
--
-- This module does NOT register any bind. It only exports functions that
-- launch scrollhold.sh; the binds are made in hyprland.lua:
--
--   local scroll = require("scrollhold")
--   scroll.config.device = "/dev/input/by-id/..."   -- see the note there
--   hl.bind(mainMod .. " + W", scroll.up)
--   hl.bind(mainMod .. " + S", scroll.down)
--
-- Why the loop is NOT in Lua
--   Hyprland does not reliably deliver key release events to Lua binds, and
--   the Lua environment cannot poll the keyboard state. So each bind just
--   launches scrollhold.sh, which loops and asks the kernel (evtest --query)
--   whether the keys are still physically down.
--
-- Exports
--   M.config            settings table (see below)
--   M.up, M.down        ready-to-bind functions (scroll -10 / +10)
--   M.hold(key, cmd)    builds a bind function for any evdev key and command:
--                         hl.bind(mainMod .. " + J",
--                                 scroll.hold("KEY_J", "wlrctl pointer scroll 0 10"))
--
-- Settings (M.config)
--   script     path to scrollhold.sh
--   device     evdev device that reports both the letter and the Super key
--              (REQUIRED; see the note above scroll.config.device in
--              hyprland.lua for how to find it)
--
-- HOW TO FIND THE RIGHT `device`
--   The device must be the evdev device that reports BOTH the letter keys and
--   the Super key. `ls -l /dev/input/by-id/` only lists names and CANNOT tell
--   which one is right: gaming/multimedia keyboards expose several interfaces
--   ("-event-kbd", "-if01-event-kbd", ...) and often only one reports the
--   typing keys. The full procedure, with the exact commands, is in the
--   comment above `scroll.config.device` in hyprland.lua. In short:
--     1. command -v evtest ; id | grep -o input   (evtest installed, in the
--        `input` group)
--     2. run the scan loop and hold Super+W: it prints every device where
--        KEY_W / KEY_LEFTMETA are DOWN (evtest --query exits with 10 when down)
--     3. take the device where BOTH show up (e.g. /dev/input/event9)
--     4. ls -l /dev/input/by-id/ | grep '/event9$'   to get the stable name
--     5. sleep 3; evtest --query <device> EV_KEY KEY_W; echo $?   prints 10
--        while W is held
--   Symptom of a wrong device: the scroll runs once per press and stops.
--
--   interval   seconds between each scroll execution (string, default "0.04")
--   debug      true to log to /tmp/scrollhold-lua.log (this module) and
--              /tmp/scrollhold-debug.log (the script)
--
-- Dependencies: evtest, wlrctl (see scrollhold.sh)
-- =============================================================================

local M = {}

M.config = {
    script   = os.getenv("HOME") .. "/.config/hypr/scrollhold.sh",
    -- e.g. "/dev/input/by-id/usb-SUNSONNY_GAMING_KEYBOARD-if01-event-kbd"
    device   = nil,
    interval = "0.04", -- seconds between executions
    debug    = false,  -- logs to /tmp/scrollhold-lua.log and /tmp/scrollhold-debug.log
}

-- Appends a timestamped line to /tmp/scrollhold-lua.log
local function lua_log(msg)
    local f = io.open("/tmp/scrollhold-lua.log", "a")
    if f then
        f:write(os.date("%H:%M:%S ") .. msg .. "\n")
        f:close()
    end
end

-- Builds the function that is handed to hl.bind.
-- `key` is the evdev name of the letter (KEY_W) and `cmd` is the shell command
-- repeated while the combo is held. The command line is assembled when the
-- bind fires (not when the module loads), so changes to M.config made in
-- hyprland.lua after require() are respected.
function M.hold(key, cmd)
    return function()
        if M.config.debug then lua_log("bind fired: " .. key) end

        -- Without a device the script cannot query the keys: do nothing
        if not M.config.device then
            if M.config.debug then lua_log("ERROR: device not set") end
            return
        end

        -- Resulting command line:
        --   SCROLLHOLD_INTERVAL=<i> [SCROLLHOLD_DEBUG=1] <script> '<device>' <key> <cmd>
        local full = string.format(
            "SCROLLHOLD_INTERVAL=%s %s%s '%s' %s %s",
            M.config.interval,
            M.config.debug and "SCROLLHOLD_DEBUG=1 " or "",
            M.config.script, M.config.device, key, cmd
        )
        if M.config.debug then
            -- send the script's output to the debug log as well
            full = full .. " >>/tmp/scrollhold-debug.log 2>&1"
            lua_log("exec: " .. full)
        end
        hl.exec_cmd(full)
    end
end

M.up   = M.hold("KEY_W", "wlrctl pointer scroll -10 0")
M.down = M.hold("KEY_S", "wlrctl pointer scroll 10 0")

return M