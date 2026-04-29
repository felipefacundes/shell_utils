-- License: GPLv3
-- Credits: Felipe Facundes
local mp = require 'mp'
local msg = require 'mp.msg'
local utils = require 'mp.utils'

local fuzzy = {
    playlist = {},
    filtered = {},
    search_string = "",
    current_index = 1,
    search_active = false,
    menu_timer = nil,
    items_per_page = 12,
    current_page = 1,
    vid_enabled = true,      -- initial video state
    shuffle_enabled = false
}

-- ====================== HELPER FUNCTIONS ======================

function fuzzy:expand_path(path)
    if path:sub(1,1) == "~" then
        local home = os.getenv("HOME") or os.getenv("USERPROFILE")
        return home .. path:sub(2)
    end
    return path
end

function fuzzy:get_playlist()
    self.playlist = mp.get_property_native("playlist") or {}
    -- Add readable title
    for i, entry in ipairs(self.playlist) do
        if not entry.title or entry.title == "" then
            local name = entry.filename:match("([^/\\]+)$") or entry.filename
            entry.title = name
        end
        entry.index = i - 1  -- 0-based index that mpv uses for playlist-pos
    end
end

function fuzzy:filter_playlist()
    local lower = self.search_string:lower()
    self.filtered = {}
    for _, entry in ipairs(self.playlist) do
        local title = (entry.title or entry.filename or ""):lower()
        if title:find(lower, 1, true) then
            table.insert(self.filtered, entry)
        end
    end
end

function fuzzy:get_page_start_end()
    local total = #self.filtered
    if total == 0 then return 1, 0 end
    local start_idx = (self.current_page - 1) * self.items_per_page + 1
    local end_idx = math.min(start_idx + self.items_per_page - 1, total)
    return start_idx, end_idx
end

-- ====================== FUZZY MENU ======================

function fuzzy:build_menu_text()
    self:filter_playlist()
    local start_idx, end_idx = self:get_page_start_end()
    local total = #self.filtered

    local text = "🔍 PLAYLIST SEARCH\n"
    text = text .. string.format("Search: %s  |  %d results\n\n", self.search_string, total)

    if total > 0 then
        for i = start_idx, end_idx do
            local entry = self.filtered[i]
            local marker = (entry.index == mp.get_property_number("playlist-pos", -1)) and "▶ " or "  "
            local highlight = (i == self.current_index) and "➤ " or "   "
            local display = entry.title
            if #display > 60 then display = display:sub(1,57) .. "..." end
            text = text .. string.format("%s%s%d. %s\n", highlight, marker, i, display)
        end
    else
        text = text .. "No results found.\n"
    end

    text = text .. string.format("\nPage %d/%d  |  ↑↓ Navigate  |  Enter Select  |  Esc Exit\n",
        self.current_page, math.ceil(total / self.items_per_page) or 1)
    text = text .. "Type to filter (fuzzy substring)"

    return text
end

function fuzzy:update_display()
    if not self.search_active then return end
    mp.osd_message(self:build_menu_text(), 180)
end

function fuzzy:append_char(c)
    self.search_string = self.search_string .. c
    self.current_page = 1
    self.current_index = 1
    self:update_display()
    self:reset_timer()
end

function fuzzy:backspace()
    if #self.search_string > 0 then
        self.search_string = self.search_string:sub(1, -2)
        self.current_page = 1
        self.current_index = 1
        self:update_display()
    end
    self:reset_timer()
end

function fuzzy:select_current()
    self:cleanup()
    if #self.filtered == 0 then return end

    local selected = self.filtered[self.current_index]
    if selected then
        mp.commandv("playlist-play-index", selected.index)
        mp.osd_message("▶ " .. (selected.title or "Selected item"), 2)
    end
end

function fuzzy:show_menu()
    if self.search_active then return end

    self.search_active = true
    self:get_playlist()
    self.search_string = ""
    self.current_page = 1
    self.current_index = 1

    if #self.playlist == 0 then
        mp.osd_message("❌ Empty playlist", 3)
        self.search_active = false
        return
    end

    self:update_display()
    self:reset_timer()
    self:setup_bindings()
end

function fuzzy:setup_bindings()
    -- Characters
    for i = 0x20, 0x7E do  -- space to ~
        local c = string.char(i)
        if c:match("[%w%s%p]") then
            mp.add_forced_key_binding(c, "fuzzy_append_"..i, function() self:append_char(c) end)
        end
    end

    mp.add_forced_key_binding("BS", "fuzzy_backspace", function() self:backspace() end)
    mp.add_forced_key_binding("ENTER", "fuzzy_select", function() self:select_current() end)
    mp.add_forced_key_binding("ESC", "fuzzy_cancel", function() self:cleanup() mp.osd_message("❌ Search cancelled", 1.5) end)

    mp.add_forced_key_binding("UP", "fuzzy_up", function()
        self.current_index = math.max(1, self.current_index - 1)
        if self.current_index < (self.current_page-1)*self.items_per_page + 1 then
            self.current_page = math.max(1, self.current_page - 1)
        end
        self:update_display()
        self:reset_timer()
    end)

    mp.add_forced_key_binding("DOWN", "fuzzy_down", function()
        self.current_index = math.min(#self.filtered, self.current_index + 1)
        local start = (self.current_page-1)*self.items_per_page + 1
        if self.current_index > start + self.items_per_page - 1 then
            self.current_page = self.current_page + 1
        end
        self:update_display()
        self:reset_timer()
    end)
end

function fuzzy:cleanup()
    if self.menu_timer then
        self.menu_timer:kill()
        self.menu_timer = nil
    end

    -- Remove bindings
    for i = 0x20, 0x7E do
        mp.remove_key_binding("fuzzy_append_"..i)
    end
    mp.remove_key_binding("fuzzy_backspace")
    mp.remove_key_binding("fuzzy_select")
    mp.remove_key_binding("fuzzy_cancel")
    mp.remove_key_binding("fuzzy_up")
    mp.remove_key_binding("fuzzy_down")

    self.search_active = false
    self.search_string = ""
end

function fuzzy:reset_timer()
    if self.menu_timer then self.menu_timer:kill() end
    self.menu_timer = mp.add_periodic_timer(120, function()
        self:cleanup()
        mp.osd_message("⏰ Search expired due to inactivity", 2)
    end)
end

-- ====================== BUTTONS AND TOGGLES ======================

function fuzzy:toggle_shuffle()
    self.shuffle_enabled = not self.shuffle_enabled
    mp.commandv("set", "shuffle", self.shuffle_enabled and "yes" or "no")
    mp.osd_message("🔀 Shuffle: " .. (self.shuffle_enabled and "ON" or "OFF"), 2)
end

function fuzzy:toggle_video()
    self.vid_enabled = not self.vid_enabled
    mp.commandv("set", "vid", self.vid_enabled and "auto" or "no")
    mp.osd_message("🎬 Video: " .. (self.vid_enabled and "ON" or "OFF"), 2)
end

-- Shows bottom bar with buttons (OSD)
function fuzzy:show_control_bar()
    local bar = "   "
    bar = bar .. "🔍 [Ctrl+F] Search   "
    bar = bar .. (self.shuffle_enabled and "🔀 [Ctrl+R] Shuffle ON" or "🔀 [Ctrl+R] Shuffle OFF") .. "   "
    bar = bar .. (self.vid_enabled and "🎬 [Ctrl+V] Video ON" or "🎬 [Ctrl+V] Video OFF") .. "   "
    mp.osd_message(bar, 4)
end

-- ====================== INITIALIZATION ======================

function fuzzy:init()
    -- Main shortcuts
    mp.add_key_binding("Ctrl+f", "playlist-fuzzy-search", function() self:show_menu() end)
    mp.add_key_binding("Ctrl+r", "toggle-shuffle", function() self:toggle_shuffle() end)
    mp.add_key_binding("Ctrl+v", "toggle-video", function() self:toggle_video() end)

    -- Visual button (press 'b' to show the control bar)
    mp.add_key_binding("b", "show-control-bar", function() self:show_control_bar() end)

    -- Watch for playlist changes to update internal state
    mp.observe_property("playlist", "native", function()
        self:get_playlist()
    end)

    msg.info("Playlist Fuzzy loaded! Use Ctrl+F for search, Ctrl+R shuffle, Ctrl+V video, B for bar.")
end

fuzzy:init()