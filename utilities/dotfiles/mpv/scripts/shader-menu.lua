-- License: GPLv3
-- Credits: Felipe Facundes

-- shader-menu-paginated.lua
local mp = require 'mp'
local msg = require 'mp.msg'
local utils = require 'mp.utils'

local shader_manager = {
    shaders_dir = "~/.config/mpv/shaders/",
    shaders_list = {},
    current_shader = nil,
    menu_active = false,
    current_index = 0,  -- 0: remove, 1+: shader index
    current_page = 1,
    items_per_page = 10,
    menu_timer = nil,
    original_osd_size = nil  -- To restore font size if needed
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

-- Load shader list
function shader_manager:load_shaders()
    self.shaders_list = self:find_shaders(self.shaders_dir)
    table.sort(self.shaders_list, function(a, b) 
        return a.display_name:lower() < b.display_name:lower()
    end)
end

-- Calculate total pages
function shader_manager:get_total_pages()
    if #self.shaders_list == 0 then return 1 end
    return math.ceil(#self.shaders_list / self.items_per_page)
end

-- Get current page indices
function shader_manager:get_page_indices()
    local total_pages = self:get_total_pages()
    local start_idx = (self.current_page - 1) * self.items_per_page + 1
    local end_idx = math.min(start_idx + self.items_per_page - 1, #self.shaders_list)
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

-- Build menu text with pagination, highlight and ASS formatting for smaller font
function shader_manager:build_menu_text()
    local start_idx, end_idx, total_pages = self:get_page_indices()
    local menu_text = "🎨 SHADER MENU (" .. #self.shaders_list .. " found)\n\n"
    
    -- Remove shader option (always on top)
    local remove_highlight = (self.current_index == 0) and "➤ " or "  "
    menu_text = menu_text .. string.format("%s0. ❌ Remove current shader\n", remove_highlight)
    menu_text = menu_text .. "────────────────────────────\n"
    
    -- List shaders from current page with absolute numbering and highlight
    if end_idx >= start_idx then
        for i = start_idx, end_idx do
            local shader = self.shaders_list[i]
            local marker = (self.current_shader == shader.path) and "✓ " or "  "
            local highlight = (self.current_index == i) and "➤ " or "  "
            -- Truncate long names to fit better (optional: cut after 50 chars)
            local display_name = shader.display_name
            if #display_name > 50 then
                display_name = display_name:sub(1, 47) .. "..."
            end
            menu_text = menu_text .. string.format("%s%2d. %s%s\n", highlight, i, marker, display_name)
        end
    end
    
    -- Page info
    menu_text = menu_text .. string.format("\n📍 Page %d/%d (↑/↓ navigate, PGUP/PGDWN pages)\n", self.current_page, total_pages)
    menu_text = menu_text .. "ENTER to select | Numbers 0-9 for quick selection\n"
    menu_text = menu_text .. "ESC to cancel"
    
    return menu_text
end

-- Update menu display
function shader_manager:update_menu_display()
    if not self.menu_active then return end
    local menu_text = self:build_menu_text()
    mp.osd_message(menu_text, 180)  -- Increased time to 3min, timer controls actual duration
end

-- Move to next page and set index to first of new page
function shader_manager:next_page()
    local total_pages = self:get_total_pages()
    if self.current_page < total_pages then
        self.current_page = self.current_page + 1
        local start_idx = (self.current_page - 1) * self.items_per_page + 1
        self.current_index = start_idx
        self:update_menu_display()
        return true
    end
    return false
end

-- Move to previous page and set index to last of previous page
function shader_manager:prev_page()
    if self.current_page > 1 then
        self.current_page = self.current_page - 1
        local start_idx = (self.current_page - 1) * self.items_per_page + 1
        local end_idx = math.min(start_idx + self.items_per_page - 1, #self.shaders_list)
        self.current_index = end_idx  -- Go to last item of previous page
        self:update_menu_display()
        return true
    end
    return false
end

-- Reset inactivity timer
function shader_manager:reset_inactivity_timer()
    if self.menu_timer then
        self.menu_timer:kill()
    end
    self.menu_timer = mp.add_periodic_timer(150, function()  -- 150s = 2.5min, quintupled from 30s
        self:cleanup()
        mp.osd_message("❌ Shader menu expired (inactivity)", 2)
    end)
end

-- Clean up timer and bindings
function shader_manager:cleanup()
    if self.menu_timer then
        self.menu_timer:kill()
        self.menu_timer = nil
    end
    self:cleanup_temp_bindings()
end

-- Show interactive menu
function shader_manager:show_menu()
    if self.menu_active then return end
    
    self.menu_active = true
    self:load_shaders()
    self.current_index = 0  -- Start on remove option
    self.current_page = 1
    
    if #self.shaders_list == 0 then
        mp.osd_message("❌ No .glsl shaders found", 3)
        self:cleanup()
        return
    end
    
    self:update_menu_display()
    
    -- Auto-cancel timer after inactivity (150s now)
    self:reset_inactivity_timer()
    
    -- Bindings for ↑/↓ navigation (now with wrap to adjacent pages)
    mp.add_forced_key_binding("UP", "menu_up", function()
        local start_idx, end_idx = self:get_page_indices()
        if self.current_index == 0 then
            -- From remove, go to last item of current page
            self.current_index = end_idx
        else
            -- Inside shaders, move up one
            self.current_index = self.current_index - 1
            if self.current_index < start_idx then
                -- Beginning of page, go to previous page (last item) or remove
                if self.current_page > 1 then
                    self:prev_page()  -- Already sets to end_idx of prev
                else
                    self.current_index = 0  -- First page, back to remove
                end
            end
        end
        self:update_menu_display()
        self:reset_inactivity_timer()  -- Reset timer on each interaction
    end)
    
    mp.add_forced_key_binding("DOWN", "menu_down", function()
        local start_idx, end_idx = self:get_page_indices()
        if self.current_index == 0 then
            -- From remove, go to first item of page
            self.current_index = start_idx
        else
            -- Inside shaders, move down one
            self.current_index = self.current_index + 1
            if self.current_index > end_idx then
                -- End of page, go to next page (first item) or remove
                if self:next_page() then
                    -- Already sets to start of next
                else
                    self.current_index = 0  -- Last page, back to remove
                end
            end
        end
        self:update_menu_display()
        self:reset_inactivity_timer()  -- Reset timer on each interaction
    end)
    
    -- PAGEUP / PGDWN to change pages (now sets appropriate index)
    mp.add_forced_key_binding("PGUP", "menu_page_up", function()
        if self:prev_page() then
            -- Already updates display
        end
        self:reset_inactivity_timer()
    end)
    
    mp.add_forced_key_binding("PGDWN", "menu_page_down", function()
        if self:next_page() then
            -- Already updates display
        end
        self:reset_inactivity_timer()
    end)
    
    -- ENTER to select
    mp.add_forced_key_binding("ENTER", "menu_select", function()
        self:cleanup()
        if self.current_index == 0 then
            self:remove_shader()
        else
            local shader = self.shaders_list[self.current_index]
            if shader then
                self:apply_shader(shader.path)
            end
        end
    end)
    
    -- Bindings for direct numbers (0 for remove, 1-9 for first 9 shaders)
    mp.add_forced_key_binding("0", "menu_remove", function()
        self:cleanup()
        self:remove_shader()
    end)
    
    for i = 1, math.min(9, #self.shaders_list) do
        mp.add_forced_key_binding(tostring(i), "menu_shader_" .. i, function()
            self:cleanup()
            self:apply_shader(self.shaders_list[i].path)
        end)
    end
    
    -- ESC to cancel
    mp.add_forced_key_binding("ESC", "menu_cancel", function()
        self:cleanup()
        mp.osd_message("❌ Menu canceled", 2)
    end)
    
    -- Mouse wheel bindings (simulate ↑/↓)
    mp.add_forced_key_binding("WHEEL_UP", "menu_wheel_up", function()
        mp.command("script-message-to input wheel-up")
        self:reset_inactivity_timer()
    end)
    mp.add_forced_key_binding("WHEEL_DOWN", "menu_wheel_down", function()
        mp.command("script-message-to input wheel-down")
        self:reset_inactivity_timer()
    end)
end

-- Clean up temporary bindings
function shader_manager:cleanup_temp_bindings()
    local bindings_to_remove = {
        "menu_up", "menu_down", "menu_select", "menu_remove", "menu_cancel",
        "menu_page_up", "menu_page_down", "menu_wheel_up", "menu_wheel_down"
    }
    for i = 1, 9 do
        table.insert(bindings_to_remove, "menu_shader_" .. i)
    end
    
    for _, binding in ipairs(bindings_to_remove) do
        mp.remove_key_binding(binding)
    end
    self.menu_active = false
end

-- Initialize
function shader_manager:init()
    self:load_shaders()
    
    mp.add_key_binding("Ctrl+Shift+s", "shader-menu", function()
        self:show_menu()
    end)
    
    msg.info("Paginated shader menu loaded! Use Ctrl+Shift+s to open. " .. #self.shaders_list .. " shaders found (" .. self:get_total_pages() .. " pages).")
end

shader_manager:init()