-- License: GPLv3
-- Credits: Felipe Facundes

-- shader-search.lua
local mp = require 'mp'
local msg = require 'mp.msg'
local utils = require 'mp.utils'

local shader_manager = {
    shaders_dir = "~/.config/mpv/shaders/",
    shaders_list = {},
    filtered_list = {},
    current_shader = nil,
    search_active = false,
    search_string = "",
    current_index = 0,  -- 0: remove, 1+: index in filtered_list
    current_page = 1,
    items_per_page = 10,
    menu_timer = nil
}

-- Expand path with ~
function shader_manager:expand_path(path)
    if path:sub(1, 1) == "~" then
        local home = os.getenv("HOME")
        return home .. path:sub(2)
    end
    return path
end

-- Find shaders recursively
function shader_manager:find_shaders(dir)
    local shaders = {}
    local expanded_dir = self:expand_path(dir)
    
    local function scan_directory(current_dir)
        local entries = utils.readdir(current_dir) or {}
        
        for _, entry in ipairs(entries) do
            if entry ~= "." and entry ~= ".." then
                local full_path = current_dir .. "/" .. entry
                local file_info = utils.file_info(full_path)
                
                if file_info then
                    if file_info.is_dir then
                        scan_directory(full_path)
                    elseif entry:match("%.glsl$") then
                        local relative_path = full_path:gsub(expanded_dir .. "/?", "")
                        table.insert(shaders, {
                            name = entry,
                            path = full_path,
                            display_name = relative_path
                        })
                    end
                end
            end
        end
    end
    
    scan_directory(expanded_dir)
    return shaders
end

-- Load full shader list
function shader_manager:load_shaders()
    self.shaders_list = self:find_shaders(self.shaders_dir)
    table.sort(self.shaders_list, function(a, b) 
        return a.display_name:lower() < b.display_name:lower()
    end)
end

-- Filter shaders based on search string (case-insensitive, substring)
function shader_manager:filter_shaders()
    local lower_search = self.search_string:lower()
    self.filtered_list = {}
    for _, shader in ipairs(self.shaders_list) do
        if shader.display_name:lower():find(lower_search, 1, true) then
            table.insert(self.filtered_list, shader)
        end
    end
    table.sort(self.filtered_list, function(a, b) 
        return a.display_name:lower() < b.display_name:lower()
    end)
end

-- Calculate total pages for filtered_list
function shader_manager:get_total_pages()
    if #self.filtered_list == 0 then return 1 end
    return math.ceil(#self.filtered_list / self.items_per_page)
end

-- Get current page indices for filtered_list
function shader_manager:get_page_indices()
    local total_pages = self:get_total_pages()
    local start_idx = (self.current_page - 1) * self.items_per_page + 1
    local end_idx = math.min(start_idx + self.items_per_page - 1, #self.filtered_list)
    return start_idx, end_idx, total_pages
end

-- Apply shader
function shader_manager:apply_shader(shader_path)
    if self.current_shader then
        mp.commandv("change-list", "glsl-shaders", "remove", self.current_shader)
    end
    
    mp.commandv("change-list", "glsl-shaders", "set", shader_path)
    self.current_shader = shader_path
    
    local shader_name = shader_path:match("([^/]+)$") or shader_path
    mp.osd_message("✅ Shader applied: " .. shader_name, 3)
end

-- Remove current shader
function shader_manager:remove_shader()
    if self.current_shader then
        mp.commandv("change-list", "glsl-shaders", "remove", self.current_shader)
        self.current_shader = nil
        mp.osd_message("✅ Shader removed", 2)
    else
        mp.osd_message("❌ No active shader", 2)
    end
end

-- Append character to search
function shader_manager:append_char(char)
    self.search_string = self.search_string .. char
    self:filter_shaders()
    self.current_index = 0
    self.current_page = 1
    self:update_search_display()
    self:reset_inactivity_timer()
end

-- Remove last character from search
function shader_manager:backspace()
    if #self.search_string > 0 then
        self.search_string = self.search_string:sub(1, -2)
        self:filter_shaders()
        self.current_index = 0
        self.current_page = 1
        self:update_search_display()
    end
    self:reset_inactivity_timer()
end

-- Build search menu text with pagination, highlight and ASS formatting
function shader_manager:build_search_text()
    local start_idx, end_idx, total_pages = self:get_page_indices()
    local menu_text = "🔍 SHADER SEARCH:\n"
    menu_text = menu_text .. string.format("Search: %s (%d results)\n\n", self.search_string, #self.filtered_list)
    
    -- Remove shader option (always on top)
    local remove_highlight = (self.current_index == 0) and "➤ " or "  "
    menu_text = menu_text .. string.format("%s0. ❌ Remove current shader\n", remove_highlight)
    menu_text = menu_text .. "────────────────────────────\n"
    
    -- List filtered shaders from current page with absolute numbering and highlight
    if end_idx >= start_idx then
        for i = start_idx, end_idx do
            local shader = self.filtered_list[i]
            local marker = (self.current_shader == shader.path) and "✓ " or "  "
            local highlight = (self.current_index == i) and "➤ " or "  "
            -- Truncate long names
            local display_name = shader.display_name
            if #display_name > 50 then
                display_name = display_name:sub(1, 47) .. "..."
            end
            menu_text = menu_text .. string.format("%s%2d. %s%s\n", highlight, i, marker, display_name)
        end
    end
    
    -- Page info and instructions
    menu_text = menu_text .. string.format("\n📍 Page %d/%d (↑/↓ navigate, PGUP/PGDWN pages)\n", self.current_page, total_pages)
    menu_text = menu_text .. "Type to filter | ENTER apply | ESC exit"
    
    return menu_text
end

-- Update search menu display
function shader_manager:update_search_display()
    if not self.search_active then return end
    local menu_text = self:build_search_text()
    mp.osd_message(menu_text, 180)
end

-- Move to next page
function shader_manager:next_page()
    local total_pages = self:get_total_pages()
    if self.current_page < total_pages then
        self.current_page = self.current_page + 1
        local start_idx = (self.current_page - 1) * self.items_per_page + 1
        self.current_index = start_idx
        self:update_search_display()
        return true
    end
    return false
end

-- Move to previous page
function shader_manager:prev_page()
    if self.current_page > 1 then
        self.current_page = self.current_page - 1
        local start_idx = (self.current_page - 1) * self.items_per_page + 1
        local end_idx = math.min(start_idx + self.items_per_page - 1, #self.filtered_list)
        self.current_index = end_idx
        self:update_search_display()
        return true
    end
    return false
end

-- Reset inactivity timer
function shader_manager:reset_inactivity_timer()
    if self.menu_timer then
        self.menu_timer:kill()
    end
    self.menu_timer = mp.add_periodic_timer(150, function()
        self:cleanup_search()
        mp.osd_message("❌ Shader search expired (inactivity)", 2)
    end)
end

-- Clean up timer and bindings
function shader_manager:cleanup_search()
    if self.menu_timer then
        self.menu_timer:kill()
        self.menu_timer = nil
    end
    self:cleanup_temp_bindings()
end

-- Show interactive search menu
function shader_manager:show_search_menu()
    if self.search_active then return end
    
    self.search_active = true
    self:load_shaders()
    self.search_string = ""
    self:filter_shaders()  -- Initial: all shaders
    self.current_index = 0
    self.current_page = 1
    
    if #self.shaders_list == 0 then
        mp.osd_message("❌ No .glsl shaders found", 3)
        self:cleanup_search()
        return
    end
    
    self:update_search_display()
    self:reset_inactivity_timer()
    
    -- Bindings for characters (a-z, 0-9)
    for i = 0x30, 0x39 do  -- 0-9
        local c = string.char(i)
        mp.add_forced_key_binding(c, "search_append_" .. c, function()
            self:append_char(c)
        end)
    end
    for i = 0x61, 0x7A do  -- a-z
        local c = string.char(i)
        mp.add_forced_key_binding(c, "search_append_" .. c, function()
            self:append_char(c)
        end)
    end
    
    -- Binding for underscore (_) - to resolve dilemma with video cycle
    mp.add_forced_key_binding("_", "search_append_", function()
        self:append_char("_")
    end)
    
    -- Binding for backspace
    mp.add_forced_key_binding("BS", "search_backspace", function()
        self:backspace()
    end)
    
    -- Bindings for ↑/↓ navigation
    mp.add_forced_key_binding("UP", "search_up", function()
        local start_idx, end_idx = self:get_page_indices()
        if self.current_index == 0 then
            self.current_index = end_idx
        else
            self.current_index = self.current_index - 1
            if self.current_index < start_idx then
                if self.current_page > 1 then
                    self:prev_page()
                else
                    self.current_index = 0
                end
            end
        end
        self:update_search_display()
        self:reset_inactivity_timer()
    end)
    
    mp.add_forced_key_binding("DOWN", "search_down", function()
        local start_idx, end_idx = self:get_page_indices()
        if self.current_index == 0 then
            self.current_index = start_idx
        else
            self.current_index = self.current_index + 1
            if self.current_index > end_idx then
                if self:next_page() then
                    -- Already set
                else
                    self.current_index = 0
                end
            end
        end
        self:update_search_display()
        self:reset_inactivity_timer()
    end)
    
    -- PAGEUP / PGDWN
    mp.add_forced_key_binding("PGUP", "search_page_up", function()
        self:prev_page()
        self:reset_inactivity_timer()
    end)
    
    mp.add_forced_key_binding("PGDWN", "search_page_down", function()
        self:next_page()
        self:reset_inactivity_timer()
    end)
    
    -- ENTER to select
    mp.add_forced_key_binding("ENTER", "search_select", function()
        self:cleanup_search()
        if self.current_index == 0 then
            self:remove_shader()
        else
            local shader = self.filtered_list[self.current_index]
            if shader then
                self:apply_shader(shader.path)
            end
        end
    end)
    
    -- ESC to cancel
    mp.add_forced_key_binding("ESC", "search_cancel", function()
        self:cleanup_search()
        mp.osd_message("❌ Search canceled", 2)
    end)
end

-- Clean up temporary search bindings
function shader_manager:cleanup_temp_bindings()
    -- Remove character bindings
    for i = 0x30, 0x39 do
        local c = string.char(i)
        mp.remove_key_binding("search_append_" .. c)
    end
    for i = 0x61, 0x7A do
        local c = string.char(i)
        mp.remove_key_binding("search_append_" .. c)
    end
    mp.remove_key_binding("search_append_")  -- For underscore
    mp.remove_key_binding("search_backspace")
    mp.remove_key_binding("search_up")
    mp.remove_key_binding("search_down")
    mp.remove_key_binding("search_select")
    mp.remove_key_binding("search_cancel")
    mp.remove_key_binding("search_page_up")
    mp.remove_key_binding("search_page_down")
    
    self.search_active = false
    self.search_string = ""
end

-- Initialize (includes binding for Ctrl+S and keeps original menu with Ctrl+9 if desired)
function shader_manager:init()
    self:load_shaders()
    
    -- Search with Ctrl+S
    mp.add_key_binding("Ctrl+s", "shader-search", function()
        self:show_search_menu()
    end)
    
    -- Original menu with Ctrl+9 (optional, to keep)
    mp.add_key_binding("Ctrl+9", "shader-menu", function()
        -- Here you can call show_menu from the previous script, but since it's a different script, implement if needed
        mp.osd_message("Use Ctrl+S to search! Paginated menu in another script.", 3)
    end)
    
    msg.info("Shader search loaded! Use Ctrl+S to search shaders. " .. #self.shaders_list .. " shaders found.")
end

shader_manager:init()