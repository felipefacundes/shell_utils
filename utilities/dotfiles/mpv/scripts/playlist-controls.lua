-- License: GPLv3
-- Credits: Felipe Facundes
-- playlist-controls.lua
-- Shortcuts: Ctrl+F (playlist search), Ctrl+R (shuffle), Ctrl+V (toggle video)
-- Does NOT render any bar — that is handled by osc-custom.lua

local mp      = require 'mp'
local msg     = require 'mp.msg'
local assdraw = require 'mp.assdraw'

-- ─────────────────────────────────────────────
-- STATE
-- ─────────────────────────────────────────────
local state = {
    search_active   = false,
    search_string   = "",
    filtered_list   = {},
    current_sel     = 1,
    current_page    = 1,
    items_per_page  = 12,
    search_timer    = nil,
    search_timeout  = 120,
    shuffle_on      = false,
    vid_on          = true,
}

-- Expose state to osc-custom.lua via shared-script-properties
local function publish_state()
    mp.set_property("user-data/pctrl/shuffle",        state.shuffle_on and "1" or "0")
    mp.set_property("user-data/pctrl/vid",            state.vid_on     and "1" or "0")
    mp.set_property("user-data/pctrl/search_active",  state.search_active and "1" or "0")
end

-- ─────────────────────────────────────────────
-- UTILITIES
-- ─────────────────────────────────────────────
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

local function get_title(pl_item, idx)
    if pl_item.title and pl_item.title ~= "" then return pl_item.title end
    if pl_item.filename then
        local name = pl_item.filename:match("([^/\\]+)$") or pl_item.filename
        return name:gsub("%.[^%.]+$", "")
    end
    return string.format("Track %d", idx)
end

local function trunc(s, max)
    if #s <= max then return s end
    return s:sub(1, max - 1) .. "…"
end

-- ─────────────────────────────────────────────
-- BUILD FILTERED LIST
-- ─────────────────────────────────────────────
local function build_filtered()
    local pl_count = mp.get_property_number("playlist-count") or 0
    state.filtered_list = {}
    for i = 0, pl_count - 1 do
        local item  = mp.get_property_native(string.format("playlist/%d", i)) or {}
        local title = get_title(item, i + 1)
        if fuzzy_match(title, state.search_string) then
            table.insert(state.filtered_list, {
                index   = i,
                title   = title,
                path    = item.filename or "",
                current = (mp.get_property_number("playlist-pos") == i),
            })
        end
    end
end

-- ─────────────────────────────────────────────
-- SEARCH MENU RENDERING
-- ─────────────────────────────────────────────
local function get_dims()
    local w = mp.get_property_number("osd-width")  or 1280
    local h = mp.get_property_number("osd-height") or 720
    return w, h
end

local function ass_color(r, g, b, a)
    a = a or 0
    return string.format("&H%02X%02X%02X%02X&", a, b, g, r)
end

local function render_search()
    if not state.search_active then
        mp.set_osd_ass(0, 0, "")
        return
    end

    local W, H = get_dims()
    local ass  = assdraw.ass_new()

    local pw  = math.min(W - 80, 720)
    local ph  = math.min(H - 80, 500)
    local px  = (W - pw) / 2
    local py  = (H - ph) / 2

    -- Dark overlay
    ass:new_event()
    ass:pos(0, 0)
    ass:append(string.format(
        "{\\an7\\bord0\\shad0\\1c%s\\1a&H88&\\p1}m 0 0 l %d 0 l %d %d l 0 %d{\\p0}",
        ass_color(0, 0, 0), W, W, H, H
    ))

    -- Panel background
    ass:new_event()
    ass:pos(0, 0)
    ass:append(string.format(
        "{\\an7\\bord0\\shad0\\1c%s\\1a&H10&\\p1}m %d %d l %d %d l %d %d l %d %d{\\p0}",
        ass_color(14, 14, 22),
        px, py, px+pw, py, px+pw, py+ph, px, py+ph
    ))

    -- Panel border
    ass:new_event()
    ass:pos(0, 0)
    ass:append(string.format(
        "{\\an7\\bord1.5\\shad0\\1c%s\\p1}m %d %d l %d %d l %d %d l %d %d l %d %d{\\p0}",
        ass_color(60, 90, 160),
        px, py, px+pw, py, px+pw, py+ph, px, py+ph, px, py
    ))

    -- Title
    ass:new_event()
    ass:pos(px + pw/2, py + 20)
    ass:append(string.format(
        "{\\an5\\fs15\\bord0\\shad0\\1c%s\\b1}PLAYLIST — QUICK SEARCH",
        ass_color(160, 190, 255)
    ))

    -- Search field
    local fy = py + 42
    local fx = px + 14

    ass:new_event()
    ass:pos(0, 0)
    ass:append(string.format(
        "{\\an7\\bord0\\shad0\\1c%s\\1a&H55&\\p1}m %d %d l %d %d l %d %d l %d %d{\\p0}",
        ass_color(22, 22, 36),
        fx, fy, px+pw-14, fy, px+pw-14, fy+28, fx, fy+28
    ))

    local sd = state.search_string == "" and "Type to filter..." or (state.search_string .. "|")
    local sc = state.search_string == "" and ass_color(80, 80, 110) or ass_color(230, 230, 255)
    ass:new_event()
    ass:pos(fx + 8, fy + 14)
    ass:append(string.format("{\\an4\\fs13\\bord0\\shad0\\1c%s}%s", sc, sd))

    -- Result count
    ass:new_event()
    ass:pos(px+pw-18, fy+14)
    ass:append(string.format(
        "{\\an6\\fs11\\bord0\\shad0\\1c%s}%d result(s)",
        ass_color(90, 90, 130), #state.filtered_list
    ))

    -- Divider
    local dy = fy + 36
    ass:new_event()
    ass:pos(0, 0)
    ass:append(string.format(
        "{\\an7\\bord0\\shad0\\1c%s\\p1}m %d %d l %d %d{\\p0}",
        ass_color(44, 50, 76), px+8, dy, px+pw-8, dy
    ))

    -- List
    local list_y      = dy + 6
    local item_h      = 27
    local total_pages = math.max(1, math.ceil(#state.filtered_list / state.items_per_page))
    local si = (state.current_page - 1) * state.items_per_page + 1
    local ei = math.min(si + state.items_per_page - 1, #state.filtered_list)

    if #state.filtered_list == 0 then
        ass:new_event()
        ass:pos(px+pw/2, list_y + item_h)
        ass:append(string.format(
            "{\\an5\\fs12\\bord0\\shad0\\1c%s}No results found.",
            ass_color(100, 100, 120)
        ))
    end

    for idx = si, ei do
        local item   = state.filtered_list[idx]
        local iy     = list_y + (idx - si) * item_h
        local is_sel = (idx == state.current_sel)

        if is_sel then
            ass:new_event()
            ass:pos(0, 0)
            ass:append(string.format(
                "{\\an7\\bord0\\shad0\\1c%s\\1a&H3A&\\p1}m %d %d l %d %d l %d %d l %d %d{\\p0}",
                ass_color(44, 90, 190),
                px+6, iy, px+pw-6, iy, px+pw-6, iy+item_h-2, px+6, iy+item_h-2
            ))
        end

        local marker = item.current and "> " or "  "
        local tc
        if is_sel then
            tc = ass_color(255, 255, 255)
        elseif item.current then
            tc = ass_color(120, 195, 255)
        else
            tc = ass_color(185, 185, 210)
        end

        local display = string.format("%s%3d.  %s", marker, item.index + 1, trunc(item.title, 60))
        ass:new_event()
        ass:pos(px+16, iy + item_h/2)
        ass:append(string.format("{\\an4\\fs12\\bord0\\shad0\\1c%s}%s", tc, display))
    end

    -- Footer
    local fy2 = py + ph - 24
    ass:new_event()
    ass:pos(0, 0)
    ass:append(string.format(
        "{\\an7\\bord0\\shad0\\1c%s\\p1}m %d %d l %d %d{\\p0}",
        ass_color(40, 45, 68), px+8, fy2-4, px+pw-8, fy2-4
    ))
    ass:new_event()
    ass:pos(px+pw/2, fy2+8)
    ass:append(string.format(
        "{\\an5\\fs11\\bord0\\shad0\\1c%s}Page %d/%d  |  up/down: navigate  |  PgUp/PgDn: page  |  Enter: select  |  Esc: close",
        ass_color(80, 85, 115), state.current_page, total_pages
    ))

    mp.set_osd_ass(W, H, ass.text)
end

-- ─────────────────────────────────────────────
-- NAVIGATION HELPERS
-- ─────────────────────────────────────────────
local function ensure_sel_in_page()
    local total = #state.filtered_list
    if total == 0 then state.current_sel = 1; state.current_page = 1; return end
    state.current_sel  = math.max(1, math.min(state.current_sel, total))
    state.current_page = math.ceil(state.current_sel / state.items_per_page)
end

local function reset_search_timer()
    if state.search_timer then state.search_timer:kill() end
    state.search_timer = mp.add_timeout(state.search_timeout, function()
        -- silently close due to inactivity
        state.search_active = false
        state.search_string = ""
        for i = 0x20, 0x7E do mp.remove_key_binding("ps_c"..i) end
        for _, b in ipairs({"ps_bs","ps_up","ps_dn","ps_pu","ps_pd","ps_en","ps_es"}) do
            mp.remove_key_binding(b)
        end
        publish_state()
        render_search()
        mp.osd_message("Search closed due to inactivity", 2)
    end)
end

-- ─────────────────────────────────────────────
-- OPEN / CLOSE SEARCH
-- ─────────────────────────────────────────────
local function close_search(txt)
    if state.search_timer then state.search_timer:kill(); state.search_timer = nil end
    for i = 0x20, 0x7E do mp.remove_key_binding("ps_c"..i) end
    for _, b in ipairs({"ps_bs","ps_up","ps_dn","ps_pu","ps_pd","ps_en","ps_es"}) do
        mp.remove_key_binding(b)
    end
    state.search_active = false
    state.search_string = ""
    publish_state()
    render_search()
    if txt then mp.osd_message(txt, 2) end
end

local function open_search_menu()
    if state.search_active then return end
    state.search_active = true
    state.search_string = ""
    build_filtered()

    local pl_pos = mp.get_property_number("playlist-pos") or 0
    state.current_sel = 1
    for i, item in ipairs(state.filtered_list) do
        if item.index == pl_pos then state.current_sel = i; break end
    end
    ensure_sel_in_page()
    publish_state()
    render_search()
    reset_search_timer()

    -- Printable characters
    for i = 0x20, 0x7E do
        local c = string.char(i)
        if c ~= "\r" and c ~= "\n" and c ~= "\27" then
            mp.add_forced_key_binding(c, "ps_c"..i, function()
                state.search_string = state.search_string .. c
                build_filtered()
                state.current_sel  = 1
                state.current_page = 1
                render_search()
                reset_search_timer()
            end)
        end
    end

    mp.add_forced_key_binding("BS", "ps_bs", function()
        if #state.search_string > 0 then
            state.search_string = state.search_string:sub(1, -2)
            build_filtered()
            state.current_sel  = 1
            state.current_page = 1
            render_search()
        end
        reset_search_timer()
    end)

    -- UP: repeatable so holding the key scrolls continuously
    mp.add_forced_key_binding("UP", "ps_up", function()
        if #state.filtered_list == 0 then return end
        state.current_sel = state.current_sel - 1
        if state.current_sel < 1 then state.current_sel = #state.filtered_list end
        ensure_sel_in_page()
        render_search()
        reset_search_timer()
    end, { repeatable = true })

    -- DOWN: repeatable so holding the key scrolls continuously
    mp.add_forced_key_binding("DOWN", "ps_dn", function()
        if #state.filtered_list == 0 then return end
        state.current_sel = state.current_sel + 1
        if state.current_sel > #state.filtered_list then state.current_sel = 1 end
        ensure_sel_in_page()
        render_search()
        reset_search_timer()
    end, { repeatable = true })

    -- PGUP: repeatable for fast scrolling through pages
    mp.add_forced_key_binding("PGUP", "ps_pu", function()
        state.current_page = math.max(1, state.current_page - 1)
        state.current_sel  = (state.current_page - 1) * state.items_per_page + 1
        render_search()
        reset_search_timer()
    end, { repeatable = true })

    -- PGDWN: repeatable for fast scrolling through pages
    mp.add_forced_key_binding("PGDWN", "ps_pd", function()
        local tp = math.max(1, math.ceil(#state.filtered_list / state.items_per_page))
        state.current_page = math.min(tp, state.current_page + 1)
        state.current_sel  = (state.current_page - 1) * state.items_per_page + 1
        render_search()
        reset_search_timer()
    end, { repeatable = true })

    mp.add_forced_key_binding("ENTER", "ps_en", function()
        local item = state.filtered_list[state.current_sel]
        close_search()
        if item then
            mp.set_property_number("playlist-pos", item.index)
            mp.osd_message("> " .. item.title, 2)
        end
    end)

    mp.add_forced_key_binding("ESC", "ps_es", function()
        close_search("Search cancelled")
    end)
end

-- ─────────────────────────────────────────────
-- CONTROLS EXPOSED TO osc-custom.lua
-- ─────────────────────────────────────────────
local function toggle_shuffle()
    state.shuffle_on = not state.shuffle_on
    if state.shuffle_on then
        mp.commandv("playlist-shuffle")
        mp.osd_message("Shuffle: ON", 2)
    else
        mp.commandv("playlist-unshuffle")
        mp.osd_message("Shuffle: OFF", 2)
    end
    publish_state()
end

local function toggle_vid()
    state.vid_on = not state.vid_on
    if state.vid_on then
        mp.set_property("vid", "1")
        mp.osd_message("Video: ON", 2)
    else
        mp.set_property("vid", "no")
        mp.osd_message("Audio only", 2)
    end
    publish_state()
end

-- Register functions as script-messages for osc-custom.lua to invoke
mp.register_script_message("playlist-search-open", open_search_menu)
mp.register_script_message("toggle-shuffle",        toggle_shuffle)
mp.register_script_message("toggle-vid",            toggle_vid)

-- Direct keyboard shortcuts
mp.add_key_binding("Ctrl+f", "playlist-search-open-kb", open_search_menu)
mp.add_key_binding("Ctrl+r", "shuffle-toggle-kb",       toggle_shuffle)
mp.add_key_binding("Ctrl+v", "vid-toggle-kb",           toggle_vid)

-- Publish initial state
publish_state()

mp.register_event("file-loaded", function() publish_state() end)

msg.info("playlist-controls.lua loaded")
msg.info("  Ctrl+F: fuzzy playlist search")
msg.info("  Ctrl+R: toggle shuffle")
msg.info("  Ctrl+V: toggle video")