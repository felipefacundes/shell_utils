-- alttab.lua - MRU Alt-Tab with live preview for Hyprland (Lua config, 0.55+).
--
-- Install:  ~/.config/hypr/alttab.lua
-- Load:     in hyprland.lua ->  require("alttab").setup()
--
-- Behaviour
--   ALT + Tab          cycle forward through windows, most recently used first
--   ALT + SHIFT + Tab  cycle backwards (from the first press: the least recently
--                      used window; during a cycle: back towards where you began)
--
-- Preview: every step really focuses and raises the candidate window (switching
-- workspace when needed), so you see the actual window, live, not a thumbnail.
-- The cycle commits when you stop pressing for `commit_ms`; the window you
-- landed on becomes the most recent one. Nothing is grabbed (no submap), so
-- keyboard input can never get stuck.
--
-- Windows on special workspaces (scratchpads, the hypr-dropdown terminal while
-- hidden) and windows matching `exclude_*` are skipped.

local M = {}

local defaults = {
    next_bind       = "SUPER + Tab",
    prev_bind       = "SUPER + SHIFT + Tab",
    cancel_bind     = false,            -- e.g. "ALT + Escape": abort and go back to the origin window
    commit_ms       = 900,              -- idle time that ends (commits) a cycle
    notify          = false,            -- show "[2/5] class - title" on every step
    exclude_titles  = { "^QuakeTerminal" },   -- Lua patterns, matched on title and initial title
    exclude_classes = {},                     -- Lua patterns, matched on class
    exclude         = nil,              -- optional function(window) -> true to skip a window
}

local opts = defaults
local mru = {}        -- window addresses, most recently used first
local session = nil   -- { list = {window...}, idx = n, gen = n, origin = window|nil }

-- Safe property access: window objects can go stale or lack a field.
local function prop(obj, key)
    if obj == nil then return nil end
    local ok, value = pcall(function() return obj[key] end)
    if ok then return value end
    return nil
end

local function matches_any(patterns, text)
    if type(text) ~= "string" then return false end
    for _, pat in ipairs(patterns) do
        if text:find(pat) then return true end
    end
    return false
end

local function excluded(w)
    if prop(w, "mapped") == false then return true end

    local ws = prop(w, "workspace")
    local ws_name = prop(ws, "name")
    if type(ws_name) == "string" and ws_name:match("^special:") then return true end

    if matches_any(opts.exclude_titles, prop(w, "title"))
        or matches_any(opts.exclude_titles, prop(w, "initial_title"))
        or matches_any(opts.exclude_classes, prop(w, "class")) then
        return true
    end

    if opts.exclude then
        local ok, skip = pcall(opts.exclude, w)
        if ok and skip then return true end
    end
    return false
end

-- ---------------------------------------------------------------- MRU list --
local function drop(addr)
    for i = #mru, 1, -1 do
        if mru[i] == addr then table.remove(mru, i) end
    end
end

local function touch(addr)
    if not addr then return end
    drop(addr)
    table.insert(mru, 1, addr)
end

-- Live, non-excluded windows ordered by recency (unknown windows go last).
local function snapshot()
    local live, order = {}, {}
    for _, w in pairs(hl.get_windows()) do
        if not excluded(w) then
            local addr = prop(w, "address")
            if addr then
                live[addr] = w
                order[#order + 1] = addr
            end
        end
    end

    local list, seen = {}, {}
    for _, addr in ipairs(mru) do
        if live[addr] and not seen[addr] then
            list[#list + 1] = live[addr]
            seen[addr] = true
        end
    end
    for _, addr in ipairs(order) do
        if not seen[addr] then
            list[#list + 1] = live[addr]
            seen[addr] = true
        end
    end
    return list
end

-- ------------------------------------------------------------ preview/focus --
local function show(w)
    pcall(function()
        hl.dispatch(hl.dsp.focus({ window = w }))
        hl.dispatch(hl.dsp.window.bring_to_top())
    end)
end

local function announce(idx, n, w)
    if not opts.notify then return end
    local text = string.format("[%d/%d] %s - %s", idx, n,
        tostring(prop(w, "class") or "?"), tostring(prop(w, "title") or ""))
    pcall(function() hl.notification.create({ text = text }) end)
end

-- ---------------------------------------------------------------- session --
local function finish()
    if not session then return end
    local w = session.list[session.idx]
    session = nil
    if w then touch(prop(w, "address")) end
end

function M.cancel()
    if not session then return end
    local origin = session.origin
    session = nil               -- clear first: our own focus event must not reorder the MRU
    if origin then show(origin) end
end

local function arm_timer()
    session.gen = session.gen + 1
    local gen = session.gen
    hl.timer(function()
        if session and session.gen == gen then finish() end
    end, { timeout = opts.commit_ms, type = "oneshot" })
end

local function begin_session()
    local list = snapshot()
    if #list == 0 then return nil end

    -- Put the currently focused window first, so "next" always means "the one before".
    local active = hl.get_active_window()
    local active_addr = prop(active, "address")
    local origin, idx = nil, 0
    if active_addr then
        for i, w in ipairs(list) do
            if prop(w, "address") == active_addr then
                table.remove(list, i)
                table.insert(list, 1, w)
                origin, idx = w, 1
                break
            end
        end
    end

    if #list < 2 and idx == 1 then return nil end   -- nothing to switch to
    return { list = list, idx = idx, gen = 0, origin = origin }
end

function M.step(dir)
    if not session then
        session = begin_session()
        if not session then return end
    end

    local n = #session.list
    if session.idx == 0 then
        session.idx = (dir > 0) and 1 or n
    else
        session.idx = (session.idx - 1 + dir) % n + 1
    end

    local w = session.list[session.idx]
    show(w)
    announce(session.idx, n, w)
    arm_timer()
end

-- ------------------------------------------------------------------- setup --
function M.setup(user_opts)
    opts = {}
    for k, v in pairs(defaults) do opts[k] = v end
    for k, v in pairs(user_opts or {}) do opts[k] = v end

    hl.on("window.active", function(w)
        if session or w == nil then return end   -- the cycle owns the order while it runs
        if not excluded(w) then touch(prop(w, "address")) end
    end)

    local function forget(w)
        local addr = prop(w, "address")
        if addr then drop(addr) end
    end
    hl.on("window.close", forget)
    hl.on("window.destroy", forget)

    -- Seed with the window that is focused right now.
    local active = hl.get_active_window()
    if active and not excluded(active) then touch(prop(active, "address")) end

    hl.bind(opts.next_bind, function() M.step(1) end)
    hl.bind(opts.prev_bind, function() M.step(-1) end)
    if opts.cancel_bind then hl.bind(opts.cancel_bind, M.cancel) end
end

return M