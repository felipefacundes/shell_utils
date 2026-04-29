-- Atalho para alternar entre proporções de tela
function toggleVideoAspect()
    local aspect_ratios = {"16:9", "4:3", "1.85:1", "2.35:1"}
    local current_aspect = mp.get_property("video-aspect")
    for i, aspect in ipairs(aspect_ratios) do
        if aspect == current_aspect then
            local next_index = (i % #aspect_ratios) + 1
            mp.set_property("video-aspect", aspect_ratios[next_index])
            break
        end
    end
end

mp.add_key_binding(nil, "toggle-aspect", toggleVideoAspect)

-- Atalho para alternar entre as cores das legendas
function toggleSubtitleColor()
    local subtitle_colors = {"White", "Yellow", "Green", "Cyan", "Blue", "Magenta", "Red"}
    local current_color = mp.get_property("sub-ass-color")
    for i, color in ipairs(subtitle_colors) do
        if color == current_color then
            local next_index = (i % #subtitle_colors) + 1
            mp.set_property("sub-ass-color", subtitle_colors[next_index])
            break
        end
    end
end

mp.add_key_binding(nil, "toggle-subtitle-color", toggleSubtitleColor)
