-- License: GPLv3
-- Credits: Felipe Facundes
-- playlist-search.lua
-- Shortcuts: Ctrl+F (fuzzy-search playlist), Ctrl+R (shuffle), Ctrl+V (toggle video)
-- DOES NOT mess with OSC — keyboard logic only
-- Place in: ~/.config/mpv/scripts/playlist-search.lua

local mp  = require 'mp'
local msg = require 'mp.msg'

-- ─────────────────────────────────────────────
-- STATE
-- ─────────────────────────────────────────────
local state = {
    search_active   = false,
    search_string   = "",
    filtered_list   = {},   -- { index=N(0-based), title="...", current=bool }
    current_sel     = 1,
    current_page    = 1,
    items_per_page  = 12,
    search_timer    = nil,
    search_timeout  = 120,  -- inactivity seconds
    shuffle_on      = false,
    vid_on          = true,
}

-- ─────────────────────────────────────────────
-- UTILITIES
-- ─────────────────────────────────────────────

-- Fuzzy match: all characters of pattern appear in order in text
local function fuzzy_match(text, pattern)
    if pattern == "" then return true end
    local ti, pi = 1, 1
    local tl, pl = text:lower(), pattern:lower()
    while ti <= #tl and pi <= #pl do
        if tl:sub(ti, ti) == pl:sub(pi, pi) then pi = pi + 1 end
        ti = ti + 1
    end
    return pi > #pl
end

local function get_item_title(item, idx)
    if item.title and item.title ~= "" then return item.title end
    if item.filename then
        local name = item.filename:match("([^/\\]+)$") or item.filename
        return name:gsub("%.[^%.]+$", "")
    end
    return string.format("Track %d", idx)
end

local function trunc(s, max)
    if #s <= max then return s end
    return s:sub(1, max - 1) .. "…"
end

local function fmt_time(s)
    if not s or s < 0 then return "--:--" end
    s = math.floor(s)
    local h = math.floor(s / 3600)
    local m = math.floor((s % 3600) / 60)
    local sec = s % 60
    if h > 0 then return string.format("%d:%02d:%02d", h, m, sec) end
    return string.format("%d:%02d", m, sec)
end

-- ─────────────────────────────────────────────
-- BUILD FILTERED LIST
-- ─────────────────────────────────────────────
local function build_filtered()
    local pl_count = mp.get_property_number("playlist-count") or 0
    local pl_pos   = mp.get_property_number("playlist-pos")   or -1
    state.filtered_list = {}
    for i = 0, pl_count - 1 do
        local item  = mp.get_property_native(string.format("playlist/%d", i)) or {}
        local title = get_item_title(item, i + 1)
        if fuzzy_match(title, state.search_string) then
            table.insert(state.filtered_list, {
                index   = i,
                title   = title,
                current = (i == pl_pos),
            })
        end
    end
end

-- ─────────────────────────────────────────────
-- MENU DISPLAY VIA OSD
-- ─────────────────────────────────────────────
local function total_pages()
    return math.max(1, math.ceil(#state.filtered_list / state.items_per_page))
end

local function ensure_page()
    if #state.filtered_list == 0 then
        state.current_sel  = 1
        state.current_page = 1
        return
    end
    state.current_sel  = math.max(1, math.min(state.current_sel, #state.filtered_list))
    state.current_page = math.ceil(state.current_sel / state.items_per_page)
end

local function render_menu()
    if not state.search_active then return end

    local si = (state.current_page - 1) * state.items_per_page + 1
    local ei = math.min(si + state.items_per_page - 1, #state.filtered_list)

    local lines = {}
    table.insert(lines, "╔══════════════════════════════════════╗")
    table.insert(lines, string.format("║  🎵 PLAYLIST  ─  search: [%s]", state.search_string == "" and "…" or state.search_string))
    table.insert(lines, string.format("║  %d result(s)   Page %d/%d", #state.filtered_list, state.current_page, total_pages()))
    table.insert(lines, "╠══════════════════════════════════════╣")

    if #state.filtered_list == 0 then
        table.insert(lines, "║  (no results)")
    else
        for i = si, ei do
            local item   = state.filtered_list[i]
            local sel    = (i == state.current_sel) and "▶ " or "  "
            local cur    = item.current and "♪ " or "  "
            local name   = trunc(item.title, 36)
            table.insert(lines, string.format("║ %s%3d. %s%s", sel, item.index + 1, cur, name))
        end
    end

    table.insert(lines, "╠══════════════════════════════════════╣")
    table.insert(lines, "║  ↑↓ navigate  PGUP/DN page  ENTER ok")
    table.insert(lines, "║  Type to filter           ESC close")
    table.insert(lines, "╚══════════════════════════════════════╝")

    mp.osd_message(table.concat(lines, "\n"), 9999)
end

-- ─────────────────────────────────────────────
-- INACTIVITY TIMER
-- ─────────────────────────────────────────────
local function reset_timer()
    if state.search_timer then state.search_timer:kill() end
    state.search_timer = mp.add_timeout(state.search_timeout, function()
        -- close silently
        if state.search_active then
            -- call cleanup via flag
            state.search_active = false
            state.search_string = ""
            for i = 0x20, 0x7E do mp.remove_key_binding("ps_c"..i) end
            mp.remove_key_binding("ps_bs")
            mp.remove_key_binding("ps_up")
            mp.remove_key_binding("ps_dn")
            mp.remove_key_binding("ps_pu")
            mp.remove_key_binding("ps_pd")
            mp.remove_key_binding("ps_enter")
            mp.remove_key_binding("ps_esc")
            mp.osd_message("⏱ Playlist search closed due to inactivity", 2)
        end
    end)
end

-- ─────────────────────────────────────────────
-- OPEN / CLOSE MENU
-- ─────────────────────────────────────────────
local function close_search(notice)
    if state.search_timer then
        state.search_timer:kill()
        state.search_timer = nil
    end
    for i = 0x20, 0x7E do mp.remove_key_binding("ps_c"..i) end
    mp.remove_key_binding("ps_bs")
    mp.remove_key_binding("ps_up")
    mp.remove_key_binding("ps_dn")
    mp.remove_key_binding("ps_pu")
    mp.remove_key_binding("ps_pd")
    mp.remove_key_binding("ps_enter")
    mp.remove_key_binding("ps_esc")
    state.search_active = false
    state.search_string = ""
    if notice then
        mp.osd_message(notice, 2)
    else
        mp.osd_message("", 0)
    end
end

local function open_search_menu()
    if state.search_active then return end

    local pl_count = mp.get_property_number("playlist-count") or 0
    if pl_count < 2 then
        mp.osd_message("❌ Empty playlist or only 1 item", 2)
        return
    end

    state.search_active = true
    state.search_string = ""
    build_filtered()

    -- Preselect current track
    local pl_pos = mp.get_property_number("playlist-pos") or 0
    state.current_sel = 1
    for i, item in ipairs(state.filtered_list) do
        if item.index == pl_pos then state.current_sel = i; break end
    end
    ensure_page()
    render_menu()
    reset_timer()

    -- ── Temporary bindings ──────────────────

    -- Printable characters
    for i = 0x20, 0x7E do
        local c = string.char(i)
        -- Skip ENTER and ESC (they have their own bindings below via special names)
        mp.add_forced_key_binding(c, "ps_c"..i, function()
            state.search_string = state.search_string .. c
            build_filtered()
            state.current_sel  = 1
            state.current_page = 1
            render_menu()
            reset_timer()
        end)
    end

    mp.add_forced_key_binding("BS", "ps_bs", function()
        if #state.search_string > 0 then
            state.search_string = state.search_string:sub(1, -2)
            build_filtered()
            state.current_sel  = 1
            state.current_page = 1
        end
        render_menu()
        reset_timer()
    end)

    mp.add_forced_key_binding("UP", "ps_up", function()
        if #state.filtered_list == 0 then return end
        state.current_sel = state.current_sel - 1
        if state.current_sel < 1 then state.current_sel = #state.filtered_list end
        ensure_page()
        render_menu()
        reset_timer()
    end)

    mp.add_forced_key_binding("DOWN", "ps_dn", function()
        if #state.filtered_list == 0 then return end
        state.current_sel = state.current_sel + 1
        if state.current_sel > #state.filtered_list then state.current_sel = 1 end
        ensure_page()
        render_menu()
        reset_timer()
    end)

    mp.add_forced_key_binding("PGUP", "ps_pu", function()
        state.current_page = math.max(1, state.current_page - 1)
        state.current_sel  = (state.current_page - 1) * state.items_per_page + 1
        render_menu()
        reset_timer()
    end)

    mp.add_forced_key_binding("PGDWN", "ps_pd", function()
        state.current_page = math.min(total_pages(), state.current_page + 1)
        state.current_sel  = (state.current_page - 1) * state.items_per_page + 1
        render_menu()
        reset_timer()
    end)

    mp.add_forced_key_binding("ENTER", "ps_enter", function()
        local item = state.filtered_list[state.current_sel]
        close_search()
        if item then
            mp.set_property_number("playlist-pos", item.index)
            mp.osd_message("▶  " .. item.title, 2)
        end
    end)

    mp.add_forced_key_binding("ESC", "ps_esc", function()
        close_search("❌ Search cancelled")
    end)
end

-- ─────────────────────────────────────────────
-- TOGGLE SHUFFLE
-- ─────────────────────────────────────────────
local function toggle_shuffle()
    state.shuffle_on = not state.shuffle_on
    if state.shuffle_on then
        mp.commandv("playlist-shuffle")
        mp.osd_message("🔀 Shuffle: ON", 2)
    else
        mp.commandv("playlist-unshuffle")
        mp.osd_message("↕  Shuffle: OFF", 2)
    end
end

-- ─────────────────────────────────────────────
-- TOGGLE VIDEO
-- ─────────────────────────────────────────────
local function toggle_vid()
    state.vid_on = not state.vid_on
    if state.vid_on then
        mp.set_property("vid", "1")
        mp.osd_message("🎬 Video: ON", 2)
    else
        mp.set_property("vid", "no")
        mp.osd_message("🎵 Audio only (video disabled)", 2)
    end
end

-- ─────────────────────────────────────────────
-- EXPORT STATE TO OSC (via shared user-data)
-- ─────────────────────────────────────────────
-- osc-custom.lua reads mp.get_property("user-data/ps/shuffle")
--                and mp.get_property("user-data/ps/vid")
-- and calls the script commands below via mp.command("script-message ...")

mp.register_script_message("ps-open-search",    open_search_menu)
mp.register_script_message("ps-toggle-shuffle", toggle_shuffle)
mp.register_script_message("ps-toggle-vid",     toggle_vid)

-- Keep user-data synchronized for OSC to read
local function sync_user_data()
    mp.set_property("user-data/ps/shuffle", state.shuffle_on and "1" or "0")
    mp.set_property("user-data/ps/vid",     state.vid_on     and "1" or "0")
end

mp.observe_property("user-data/ps/shuffle", "string", function() end) -- force creation

-- ─────────────────────────────────────────────
-- GLOBAL SHORTCUTS
-- ─────────────────────────────────────────────
mp.add_key_binding("Ctrl+f", "playlist-search",   open_search_menu)
mp.add_key_binding("Ctrl+r", "playlist-shuffle",  toggle_shuffle)
mp.add_key_binding("Ctrl+v", "playlist-vid",      toggle_vid)

-- Initialize user-data
mp.register_event("start-file", function()
    sync_user_data()
end)

sync_user_data()

msg.info("playlist-search.lua loaded — Ctrl+F / Ctrl+R / Ctrl+V")