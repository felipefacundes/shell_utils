-- License: GPLv3
-- Credits: Felipe Facundes

local zoom_level = 1.0
local pan_x = 0.5  -- horizontal center (0.0 = left, 1.0 = right)
local pan_y = 0.5  -- vertical center (0.0 = top, 1.0 = bottom)

function zoom_in()
    zoom_level = zoom_level * 0.8
    if zoom_level < 0.1 then zoom_level = 0.1 end
    apply_zoom()
end

function zoom_out()
    zoom_level = zoom_level * 1.25
    if zoom_level > 1.0 then 
        zoom_level = 1.0
        pan_x = 0.5
        pan_y = 0.5
        mp.command("vf clr \"\"")
        mp.osd_message("Zoom: 1.0x")
        return
    end
    apply_zoom()
end

function pan_left()
    pan_x = pan_x - 0.05
    if pan_x < 0 then pan_x = 0 end
    apply_zoom()
end

function pan_right()
    pan_x = pan_x + 0.05
    if pan_x > 1 then pan_x = 1 end
    apply_zoom()
end

function pan_up()
    pan_y = pan_y - 0.05
    if pan_y < 0 then pan_y = 0 end
    apply_zoom()
end

function pan_down()
    pan_y = pan_y + 0.05
    if pan_y > 1 then pan_y = 1 end
    apply_zoom()
end

function apply_zoom()
    local w = zoom_level
    local h = zoom_level
    -- Calculate x,y position considering crop boundaries
    local max_x = 1 - zoom_level
    local max_y = 1 - zoom_level
    local x = pan_x * max_x
    local y = pan_y * max_y
    
    mp.command(string.format("vf set lavfi=[crop=iw*%f:ih*%f:iw*%f:ih*%f]", w, h, x, y))
    mp.osd_message(string.format("Zoom: %.2fx | Pan: %.2f, %.2f", 1/zoom_level, pan_x, pan_y))
end

function reset_zoom()
    zoom_level = 1.0
    pan_x = 0.5
    pan_y = 0.5
    mp.command("vf clr \"\"")
    mp.osd_message("Zoom reset")
end

-- Bindings
mp.add_key_binding("Alt+=", "zoom-in", zoom_in, {repeatable=true})
mp.add_key_binding("Alt+-", "zoom-out", zoom_out, {repeatable=true})
mp.add_key_binding("Alt+Left", "pan-left", pan_left, {repeatable=true})
mp.add_key_binding("Alt+Right", "pan-right", pan_right, {repeatable=true})
mp.add_key_binding("Alt+Up", "pan-up", pan_up, {repeatable=true})
mp.add_key_binding("Alt+Down", "pan-down", pan_down, {repeatable=true})
mp.add_key_binding("Alt+0", "zoom-reset", reset_zoom)