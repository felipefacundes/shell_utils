--[[
License: GPLv3
Credits: Felipe Facundes

modern-osc.lua
OSC moderno para mpv com barra violeta e botões completos.

Recursos:
  - Barra de progresso violeta
  - Botão shuffle (aleatorizar playlist)
  - Botão subtítulos (cicla idiomas)
  - Botão áudio (cicla idiomas)
  - Botão mute + barra de volume violeta
  - Botão vid= (ativa/desativa vídeo)
  - Botão loop A-B
  - Botão loop all
  - Controle de velocidade
  - Botão fullscreen, on-top, menu
]]

local assdraw = require "mp.assdraw"
local msg = require "mp.msg"
local opt = require "mp.options"
local utils = require "mp.utils"
mp.set_property("osc", "no")

-- ── Opções do usuário ────────────────────────────────────────────────────────
local user_opts = {
    idlescreen                  = true,
    audioonlyscreen             = false,
    osc_on_start                = false,
    osc_on_seek                 = false,
    keeponpause                 = true,
    hidetimeout                 = 1500,
    fadein                      = true,
    fadeduration                = 200,
    minmousemove                = 0,

    title = "${?demuxer-via-network==yes:${media-title}}${?demuxer-via-network==no:${filename/no-ext}}",

    timecurrent                 = true,
    timems                      = false,

    window_top_bar              = "auto",
    window_title                = false,

    seekrange                   = true,
    seekbarkeyframes            = false,
    automatickeyframemode       = true,
    automatickeyframelimit      = 600,

    persistent_progress         = false,
    persistent_buffer           = false,

    layout                      = "bottombar",
    box_width                   = 0.6,
    box_alpha                   = 80,

    accent_color                = "#9B59B6",   -- violet

    visibility                  = "auto",
    visibility_modes            = "never_auto_always",
    greenandgrumpy              = false,
    tick_delay                  = 1 / 60,
    tick_delay_follow_display_fps = false,

    -- Comandos de mouse
    title_mbtn_left_command     = "script-binding stats/display-page-5-toggle",
    title_mbtn_mid_command      = "show-text ${path}",
    title_mbtn_right_command    = "",

    chapter_title_mbtn_left_command  = "script-binding select/select-chapter",
    chapter_title_mbtn_right_command = "",

    play_pause_mbtn_mid_command  = "cycle-values loop-playlist inf no",
    play_pause_mbtn_right_command= "cycle-values loop-file inf no",

    playlist_prev_mbtn_left_command = "playlist-prev",
    playlist_prev_mbtn_right_command= "",

    playlist_next_mbtn_left_command = "playlist-next",
    playlist_next_mbtn_right_command= "",

    vol_ctrl_mbtn_left_command   = "no-osd cycle mute",
    vol_ctrl_wheel_down_command  = "no-osd add volume -5",
    vol_ctrl_wheel_up_command    = "no-osd add volume 5",

    volumebar_wheel_down_command = "osd-msg add volume -5",
    volumebar_wheel_up_command   = "osd-msg add volume 5",

    menu_mbtn_left_command       = "script-binding select/menu",
    fullscreen_mbtn_left_command = "cycle fullscreen",

    close_mbtn_left_command      = "quit",
    maximize_mbtn_left_command   = "cycle ${?fullscreen==yes:fullscreen}${!fullscreen==yes:window-maximized}",
    minimize_mbtn_left_command   = "cycle window-minimized",
}

-- ── Parâmetros OSC ───────────────────────────────────────────────────────────
local osc_param = {
    playresy = 0,
    playresx = 0,
    display_aspect = 1,
    areas = {},
    video_margins = { l = 0, r = 0, t = 0, b = 0 },
}

-- ── Fonte de ícones (Material Symbols / Nerd Font fallback) ──────────────────
-- Usamos sequências UTF-8 de ícones Unicode amplamente suportados
-- A fonte padrão do mpv (sans-serif) renderiza vários desses via fallback
-- Para melhor resultado, instale a fonte "Material Symbols Rounded" ou "mpv-osd-symbols"

local icon_font = "mpv-osd-symbols"  -- troque por outra se necessário

-- Caracteres de texto simples como ícones (funcionam sem fonte especial)
local icons = {
    play            = "▶",
    pause           = "⏸",
    replay          = "↺",
    previous        = "⏮",
    next            = "⏭",
    mute            = "🔇",
    volume          = {"🔈", "🔉", "🔊", "🔊"},

    shuffle_on      = "⇄",   -- shuffle ativo
    shuffle_off     = "⇄",   -- shuffle inativo (alpha diferente via código)

    loop_ab_off     = "⇆",   -- A-B loop desligado
    loop_ab_a       = "⇆A",  -- ponto A marcado
    loop_ab_on      = "⇆AB", -- loop A-B ativo

    loop_all_on     = "🔁",
    loop_all_off    = "🔁",  -- alpha diferente

    vid_on          = "📺",
    vid_off         = "📺",  -- alpha diferente

    subtitle        = "💬",
    audio           = "🎵",

    speed           = "⚡",

    menu            = "☰",
    fullscreen      = "⛶",
    fullscreen_exit = "⊡",
    ontop_on        = "⊞",
    ontop_off       = "⊟",

    window = {
        minimize    = "─",
        maximize    = "□",
        unmaximize  = "❐",
        close       = "✕",
    }
}

-- ── Thumbfast ────────────────────────────────────────────────────────────────
local thumbfast = { width = 0, height = 0, disabled = true, available = false }

local tick_delay = 1 / 60
local is_december = os.date("*t").month == 12

-- ── Helpers de cor ──────────────────────────────────────────────────────────
local function osc_color_convert(color)
    -- #RRGGBB → BGR para ASS
    return color:sub(6,7) .. color:sub(4,5) .. color:sub(2,3)
end

local osc_styles
local FONT_SIZE_LG = 22
local FONT_SIZE_MD = 16

local function set_osc_styles()
    local acc = osc_color_convert(user_opts.accent_color)
    osc_styles = {
        titlebar_bg  = "{\\blur80\\bord100\\1c&H0&\\3c&H000000&}",
        bottombar_bg = "{\\blur80\\bord120\\1c&H0&\\3c&H000000&}",
        hover_bg     = "{\\bord0\\1c&HFAFAFA&}",
        tooltip_bg   = "{\\bord0\\1c&H000000&\\1a&H80&}",

        seekbar_bg   = "{\\bord0\\1c&HD9D9D9&}",
        seekbar_fg   = "{\\bord0\\1c&H" .. acc .. "&}",
        volumebar_bg = "{\\bord0\\1c&HD9D9D9&}",
        volumebar_fg = "{\\bord0\\1c&H" .. acc .. "&}",

        window_title = "{\\bord0\\1c&HFFFFFF&\\fs" .. FONT_SIZE_LG .. "\\q2}",
        title        = "{\\bord0\\1c&HFFFFFF&\\fs" .. FONT_SIZE_LG .. "\\q2}",
        chapter_title= "{\\bord0\\1c&HD9D9D9&\\1a&H66&\\fs" .. FONT_SIZE_MD .. "}",
        time         = "{\\bord0\\1c&HFFFFFF&\\fs" .. FONT_SIZE_MD .. "}",
        tooltip      = "{\\bord0\\1c&HFFFFFF&\\fs" .. FONT_SIZE_MD .. "}",

        window_control= "{\\bord0\\1c&HFFFFFF&\\fs10}",
        -- botões principais: fonte um pouco maior para emojis legíveis
        buttons      = "{\\bord0\\1c&HFFFFFF&\\fs20}",
        buttons_sm   = "{\\bord0\\1c&HFFFFFF&\\fs14}",

        thumbnail    = "{\\bord0\\1c&HFFFFFF&}",
    }
end

-- ── Estado interno ───────────────────────────────────────────────────────────
local state = {
    show_time = nil,
    touch_time = nil,
    touch_points = {},
    osc_visible = false,
    wc_visible = false,
    ani_start = nil,
    ani_type = nil,
    animation = nil,
    active_element = nil,
    active_event_source = nil,
    tc_left_rem = not user_opts.timecurrent,
    tc_ms = user_opts.timems,
    screen_size_x = nil, screen_size_y = nil,
    init_req = false,
    margins_req = false,
    last_mouse_x = nil, last_mouse_y = nil,
    last_touch_x = -1, last_touch_y = -1,
    mouse_in_window = false,
    fullscreen = false,
    tick_timer = nil,
    tick_last_time = 0,
    hide_timer = nil,
    demuxer_cache_state = nil,
    idle_active = false,
    audio_track_count = 0,
    sub_track_count = 0,
    no_video = false,
    playlist_count = 0,
    playlist_pos_1 = 0,
    duration = nil,
    pause = false,
    volume = 0,
    mute = false,
    osd_dimensions = { w = 0, h = 0, aspect = 0 },
    osd_scale_by_window = false,
    file_loaded = false,
    enabled = true,
    input_enabled = true,
    showhide_enabled = false,
    windowcontrols_buttons = false,
    border = true,
    window_maximized = false,
    osd = mp.create_osd_overlay("ass-events"),
    logo_osd = mp.create_osd_overlay("ass-events"),
    temp_visibility_mode = nil,
    chapter_list = {},
    chapter = -1,
    visibility_modes = {},
    eof_reached = false,
    ontop = false,
    speed = 1,
    file_loop = false,
    slider_pos = 0,
    initial_border = mp.get_property("border"),
    initial_title_bar = mp.get_property("title-bar"),
    playing_and_seeking = false,
    playtime_hour_force_init = false,
    persistent_seekbar_element = nil,
    persistent_progress_toggle = user_opts.persistent_progress,

    -- estados extras
    shuffle = false,       -- playlist-shuffle
    ab_loop = "off",       -- "off" | "a" | "ab"
    loop_all = false,      -- loop-playlist
    vid_active = true,     -- vídeo ativado
}

-- ── Save Volume State ────────────────────────────────────────────────────────
local vol_state_file = os.getenv("HOME") .. "/.config/mpv/vol_state"
local vol_ignore_observer = false

local function save_vol_state()
    local f = io.open(vol_state_file, "w")
    if f then
        local val = tostring(math.floor((state.volume or 100) + 0.5))
        f:write(val)
        f:close()
        msg.debug("vol state saved: " .. val)
    else
        msg.warn("could not open vol state file for writing: " .. vol_state_file)
    end
end

local function load_vol_state()
    local f = io.open(vol_state_file, "r")
    if f then
        local val = f:read("*l")
        f:close()
        local n = tonumber(val)
        msg.debug("vol state loaded: '" .. tostring(val) .. "'")
        if n and n >= 0 and n <= 200 then return n end
    end
    msg.debug("vol state file not found, defaulting to 100")
    return 100
end

-- ── Save Video State ─────────────────────────────────────────────────────────
local vid_state_file = os.getenv("HOME") .. "/.config/mpv/vid_state"
 
local function save_vid_state()
    local f = io.open(vid_state_file, "w")
    if f then
        local val = state.vid_active and "1" or "0"
        f:write(val)
        f:close()
        msg.debug("vid state saved: " .. val .. " to " .. vid_state_file)
    else
        msg.warn("could not open vid state file for writing: " .. vid_state_file)
    end
end
 
local function load_vid_state()
    msg.debug("vid_state_file path: " .. vid_state_file)
    local f = io.open(vid_state_file, "r")
    if f then
        local val = f:read("*l")
        f:close()
        msg.debug("vid state loaded: '" .. tostring(val) .. "'")
        return val ~= "0"   -- qualquer coisa diferente de "0" mantém vídeo ativo
    end
    msg.debug("vid state file not found, defaulting to video ON")
    return true  -- padrão: vídeo ativo
end

-- ── Save Shuffle State ───────────────────────────────────────────────────────
local shuffle_state_file = os.getenv("HOME") .. "/.config/mpv/shuffle_state"

local function save_shuffle_state()
    local f = io.open(shuffle_state_file, "w")
    if f then
        local val = state.shuffle and "1" or "0"
        f:write(val)
        f:close()
        msg.debug("shuffle state saved: " .. val .. " to " .. shuffle_state_file)
    else
        msg.warn("could not open shuffle state file for writing: " .. shuffle_state_file)
    end
end

local function load_shuffle_state()
    msg.debug("shuffle_state_file path: " .. shuffle_state_file)
    local f = io.open(shuffle_state_file, "r")
    if f then
        local val = f:read("*l")
        f:close()
        msg.debug("shuffle state loaded: '" .. tostring(val) .. "'")
        return val == "1"
    end
    msg.debug("shuffle state file not found")
    return false
end

-- ── Logos mpv (idle) ─────────────────────────────────────────────────────────
local logo_lines = {
    "{\\c&HE5E5E5&\\p6}m 895 10 b 401 10 0 410 0 905 0 1399 401 1800 895 1800 1390 1800 1790 1399 1790 905 1790 410 1390 10 895 10 {\\p0}",
    "{\\c&H682167&\\p6}m 925 42 b 463 42 87 418 87 880 87 1343 463 1718 925 1718 1388 1718 1763 1343 1763 880 1763 418 1388 42 925 42{\\p0}",
    "{\\c&H430142&\\p6}m 1605 828 b 1605 1175 1324 1456 977 1456 631 1456 349 1175 349 828 349 482 631 200 977 200 1324 200 1605 482 1605 828{\\p0}",
    "{\\c&HDDDBDD&\\p6}m 1296 910 b 1296 1131 1117 1310 897 1310 676 1310 497 1131 497 910 497 689 676 511 897 511 1117 511 1296 689 1296 910{\\p0}",
    "{\\c&H691F69&\\p6}m 762 1113 l 762 708 b 881 776 1000 843 1119 911 1000 978 881 1046 762 1113{\\p0}",
}

-- ── Helpers gerais ───────────────────────────────────────────────────────────
local function observe_cached(property, callback)
    mp.observe_property(property, "native", function(_, value)
        state[property:gsub("-", "_")] = value
        callback()
    end)
end

local function format_time(seconds)
    if seconds == nil then return "" end
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = math.floor(seconds % 60)
    local time_str
    if h > 0 then
        time_str = string.format("%d:%02d:%02d", h, m, s)
    else
        time_str = string.format("%d:%02d", m, s)
    end
    if state.tc_ms then
        local ms = math.floor((seconds % 1) * 1000)
        time_str = time_str .. string.format(".%03d", ms)
    end
    return time_str
end

local function kill_animation()
    state.ani_start = nil
    state.animation = nil
    state.ani_type = nil
end

local function set_osd(osd, res_x, res_y, text, z)
    if osd.res_x == res_x and osd.res_y == res_y and osd.data == text then return end
    osd.res_x = res_x
    osd.res_y = res_y
    osd.data = text
    osd.z = z
    osd:update()
end

local function set_time_styles(timecurrent_changed, timems_changed)
    if timecurrent_changed then state.tc_left_rem = not user_opts.timecurrent end
    if timems_changed then state.tc_ms = user_opts.timems end
end

local function get_virt_scale_factor()
    if state.osd_dimensions.w == 0 or state.osd_dimensions.h == 0 then return 0, 0 end
    return osc_param.playresx / state.osd_dimensions.w,
           osc_param.playresy / state.osd_dimensions.h
end

local function recently_touched()
    if state.touch_time == nil then return false end
    return state.touch_time + 1 >= mp.get_time()
end

local function get_virt_mouse_pos()
    if recently_touched() then
        local sx, sy = get_virt_scale_factor()
        return state.last_touch_x * sx, state.last_touch_y * sy
    elseif state.mouse_in_window then
        local sx, sy = get_virt_scale_factor()
        local x, y = mp.get_mouse_pos()
        return x * sx, y * sy
    else
        return -1, -1
    end
end

local function set_virt_mouse_area(x0, y0, x1, y1, name)
    local sx, sy = get_virt_scale_factor()
    mp.set_mouse_area(x0 / sx, y0 / sy, x1 / sx, y1 / sy, name)
end

local function scale_value(x0, x1, y0, y1, val)
    local m = (y1 - y0) / (x1 - x0)
    local b = y0 - (m * x0)
    return (m * val) + b
end

local tooltip_osd = mp.create_osd_overlay and mp.create_osd_overlay("ass-events") or nil
if tooltip_osd then
    tooltip_osd.hidden = true
    tooltip_osd.compute_bounds = true
end

local text_width_cache = {}
local function estimate_text_width(text, style)
    if text == nil then return 0 end
    text = tostring(text)
    if #text == 0 then return 0 end
    local measure_text = text:gsub("%d", "0")
    local cache_key = measure_text .. (style or "")
    if text_width_cache[cache_key] then return text_width_cache[cache_key] end
    local width = 0
    if tooltip_osd and tooltip_osd.update then
        tooltip_osd.res_x = osc_param.playresx
        tooltip_osd.res_y = osc_param.playresy
        tooltip_osd.data = (style or "") .. measure_text
        local bounds = tooltip_osd:update()
        if bounds and bounds.x1 and bounds.x0 then
            width = bounds.x1 - bounds.x0
        end
    end
    text_width_cache[cache_key] = width
    return width
end

local function get_hitbox_coords(x, y, an, w, h)
    local alignments = {
        [1] = function() return x, y-h, x+w, y end,
        [2] = function() return x-(w/2), y-h, x+(w/2), y end,
        [3] = function() return x-w, y-h, x, y end,
        [4] = function() return x, y-(h/2), x+w, y+(h/2) end,
        [5] = function() return x-(w/2), y-(h/2), x+(w/2), y+(h/2) end,
        [6] = function() return x-w, y-(h/2), x, y+(h/2) end,
        [7] = function() return x, y, x+w, y+h end,
        [8] = function() return x-(w/2), y, x+(w/2), y+h end,
        [9] = function() return x-w, y, x, y+h end,
    }
    return alignments[an]()
end

local function get_element_hitbox(element)
    return element.hitbox.x1, element.hitbox.y1, element.hitbox.x2, element.hitbox.y2
end

local function mouse_hit_coords(b_x1, b_y1, b_x2, b_y2)
    local m_x, m_y = get_virt_mouse_pos()
    return (m_x >= b_x1 and m_x <= b_x2 and m_y >= b_y1 and m_y <= b_y2)
end

local function mouse_hit(element)
    return mouse_hit_coords(get_element_hitbox(element))
end

-- ── Seekbar por segmentos (capítulos) ────────────────────────────────────────
local seekbar_segments_cache = { w = nil, result = {} }

local function get_seekbar_segments(w)
    if seekbar_segments_cache.w == w then return seekbar_segments_cache.result end
    if (state.duration or 0) <= 0 or not state.chapter_list[1] then
        local result = {{ x = 0, w = w, start_p = 0, end_p = 100 }}
        seekbar_segments_cache.w = w
        seekbar_segments_cache.result = result
        return result
    end
    local times = {0}
    for _, c in ipairs(state.chapter_list) do
        if c.time > 0 and c.time < state.duration then
            table.insert(times, c.time)
        end
    end
    table.insert(times, state.duration)
    local gap = 4
    local num_segs = #times - 1
    local avail_w = w - (num_segs - 1) * gap
    local segments = {}
    local current_x = 0
    for i = 1, num_segs do
        local t_start = times[i]
        local t_end = times[i+1]
        local seg_w = ((t_end - t_start) / state.duration) * avail_w
        table.insert(segments, {
            x = current_x, w = seg_w,
            start_p = (t_start / state.duration) * 100,
            end_p = (t_end / state.duration) * 100
        })
        current_x = current_x + seg_w + gap
    end
    seekbar_segments_cache.w = w
    seekbar_segments_cache.result = segments
    return segments
end

local function get_slider_ele_pos_for(element, val)
    if element.name ~= "seekbar" and element.name ~= "persistent_seekbar" then
        local ele_pos = scale_value(element.slider.min.value, element.slider.max.value, element.slider.min.ele_pos, element.slider.max.ele_pos, val)
        return math.min(element.slider.max.ele_pos, math.max(element.slider.min.ele_pos, ele_pos))
    end
    local segments = get_seekbar_segments(element.layout.geometry.w)
    for _, seg in ipairs(segments) do
        if val >= seg.start_p and val <= seg.end_p then
            local ratio = (seg.end_p == seg.start_p) and 0 or (val - seg.start_p) / (seg.end_p - seg.start_p)
            return seg.x + ratio * seg.w
        end
    end
    return val < segments[1].start_p and segments[1].x or (segments[#segments].x + segments[#segments].w)
end

local function get_slider_value_at(element, glob_pos)
    if not element then return 0 end
    if element.name ~= "seekbar" and element.name ~= "persistent_seekbar" then
        local val = scale_value(element.slider.min.glob_pos, element.slider.max.glob_pos, element.slider.min.value, element.slider.max.value, glob_pos)
        return math.min(element.slider.max.value, math.max(element.slider.min.value, val))
    end
    local local_x = glob_pos - element.hitbox.x1
    local segments = get_seekbar_segments(element.layout.geometry.w)
    for i, seg in ipairs(segments) do
        if local_x >= seg.x and local_x <= seg.x + seg.w then
            local ratio = (seg.w == 0) and 0 or (local_x - seg.x) / seg.w
            return seg.start_p + ratio * (seg.end_p - seg.start_p)
        end
        if i < #segments and local_x > seg.x + seg.w and local_x < segments[i+1].x then
            return (local_x - (seg.x + seg.w)) < (segments[i+1].x - local_x) and seg.end_p or segments[i+1].start_p
        end
    end
    return local_x < segments[1].x and segments[1].start_p or segments[#segments].end_p
end

local function get_slider_value(element)
    return get_slider_value_at(element, get_virt_mouse_pos())
end

local function mult_alpha(alpha_a, alpha_b)
    return 255 - (255 - alpha_a) * (255 - alpha_b) / 255
end

local function add_area(name, x1, y1, x2, y2)
    if osc_param.areas[name] == nil then osc_param.areas[name] = {} end
    table.insert(osc_param.areas[name], {x1=x1, y1=y1, x2=x2, y2=y2})
end

local function ass_append_alpha(ass, alpha, modifier, inverse)
    local ar = {}
    for ai, av in ipairs(alpha) do
        av = mult_alpha(av, modifier)
        if state.animation then
            local animpos = state.animation
            if inverse then animpos = 255 - animpos end
            av = mult_alpha(av, animpos)
        end
        ar[ai] = av
    end
    ass:append(string.format("{\\1a&H%X&\\2a&H%X&\\3a&H%X&\\4a&H%X&}", ar[1], ar[2], ar[3], ar[4]))
end

local function get_hidetimeout()
    if user_opts.visibility == "always" then return -1 end
    return user_opts.hidetimeout
end

local function get_touchtimeout()
    if state.touch_time == nil then return 0 end
    return state.touch_time + (get_hidetimeout() / 1000) - mp.get_time()
end

local function cache_enabled()
    return state.demuxer_cache_state and #state.demuxer_cache_state["seekable-ranges"] > 0
end

local function update_margins()
    local margins = osc_param.video_margins
    if not state.osc_visible or get_hidetimeout() >= 0 then
        margins = {l = 0, r = 0, t = 0, b = 0}
    end
    mp.set_property_native("user-data/osc/margins", margins)
end

local tick
local function request_tick()
    if state.tick_timer == nil then
        state.tick_timer = mp.add_timeout(0, tick)
    end
    if not state.tick_timer:is_enabled() then
        local now = mp.get_time()
        local timeout = tick_delay - (now - state.tick_last_time)
        if timeout < 0 then timeout = 0 end
        state.tick_timer.timeout = timeout
        state.tick_timer:resume()
    end
end

local function request_init()
    state.init_req = true
    request_tick()
end

local function request_init_resize()
    request_init()
    state.tick_timer:kill()
    state.tick_timer.timeout = 0
    state.tick_timer:resume()
end

local function render_wipe(osd)
    osd.data = ""
    osd:remove()
end

local function update_tracklist(_, track_list)
    state.audio_track_count = 0
    state.sub_track_count = 0
    state.no_video = true
    for _, track in ipairs(track_list) do
        if track.type == "audio" then
            state.audio_track_count = state.audio_track_count + 1
        elseif track.type == "sub" then
            state.sub_track_count = state.sub_track_count + 1
        elseif track.type == "video" and track.selected then
            state.no_video = false
        end
    end
    request_init()
end

local function window_controls_enabled()
    local val = user_opts.window_top_bar
    if state.fullscreen then return false end
    if val == "auto" then
        return not state.border or not state.title_bar
    else
        return val ~= "no"
    end
end

-- ── Gestão de elementos ──────────────────────────────────────────────────────
local elements = {}

local function draw_rect(ass, x1, y1, x2, y2, r_left, r_right, r)
    local w = x2 - x1
    if w <= 0.05 then return end
    r = r or 0
    local current_r = r
    if w < current_r * 2 then current_r = w / 2 end
    if current_r > 0 and (r_left or r_right) then
        ass:round_rect_cw(x1, y1, x2, y2, current_r)
        if not r_left then ass:rect_cw(x1, y1, x1 + current_r, y2) end
        if not r_right then ass:rect_cw(x2 - current_r, y1, x2, y2) end
    else
        ass:rect_cw(x1, y1, x2, y2)
    end
end

local function prepare_elements()
    local elements2 = {}
    for _, element in pairs(elements) do
        if element.layout ~= nil and element.visible then
            table.insert(elements2, element)
        end
    end
    elements = elements2
    table.sort(elements, function(a, b) return a.layout.layer < b.layout.layer end)
    seekbar_segments_cache.w = nil

    for _, element in pairs(elements) do
        local elem_geo = element.layout.geometry
        local hitbox_w = elem_geo.w
        if (element.name == "title" or element.name == "chapter_title") and type(element.content) == "function" then
            local text_w = estimate_text_width(element.content(), osc_styles[element.name])
            if text_w > 0 then hitbox_w = math.min(text_w, elem_geo.w) end
        end
        local b_x1, b_y1, b_x2, b_y2 = get_hitbox_coords(elem_geo.x, elem_geo.y, elem_geo.an, hitbox_w, elem_geo.h)
        element.hitbox = {x1 = b_x1, y1 = b_y1, x2 = b_x2, y2 = b_y2}

        local style_ass = assdraw.ass_new()
        style_ass:append("{}")
        style_ass:new_event()
        style_ass:pos(elem_geo.x, elem_geo.y)
        style_ass:an(elem_geo.an)
        style_ass:append(element.layout.style)
        element.style_ass = style_ass

        local static_ass = assdraw.ass_new()
        if element.type == "box" then
            static_ass:draw_start()
            if element.name == "seekbarbg" then
                local segments = get_seekbar_segments(elem_geo.w)
                local r = element.layout.box.radius
                for i, seg in ipairs(segments) do
                    draw_rect(static_ass, seg.x, 0, seg.x + seg.w, elem_geo.h, (i == 1), (i == #segments), r)
                end
            elseif element.layout.box.hexagon then
                static_ass:hexagon_cw(0, 0, elem_geo.w, elem_geo.h, element.layout.box.radius, 0)
            else
                static_ass:round_rect_cw(0, 0, elem_geo.w, elem_geo.h, element.layout.box.radius)
            end
            static_ass:draw_stop()
        elseif element.type == "slider" then
            local slider_lo = element.layout.slider
            element.slider.min.ele_pos = slider_lo.border
            element.slider.max.ele_pos = elem_geo.w - element.slider.min.ele_pos
            element.slider.min.glob_pos = element.hitbox.x1 + element.slider.min.ele_pos
            element.slider.max.glob_pos = element.hitbox.x1 + element.slider.max.ele_pos
            static_ass:draw_start()
            static_ass:rect_cw(0, 0, elem_geo.w, elem_geo.h)
            static_ass:rect_ccw(0, 0, elem_geo.w, elem_geo.h)
        end
        element.static_ass = static_ass

        if not element.enabled then
            element.layout.alpha[1] = 215
            if not (element.name == "sub_track" or element.name == "audio_track") then
                element.eventresponder = nil
            end
        end
        if element.off then
            element.layout.alpha[1] = 120
        end
    end
end

-- ── Rendering de seekbar/progress ────────────────────────────────────────────
local function get_chapter(possec)
    local cl = state.chapter_list
    for n = #cl, 1, -1 do
        if possec >= cl[n].time then return cl[n] end
    end
end

local function draw_seekbar_ranges(element, elem_ass, inverse)
    local slider_lo = element.layout.slider
    local elem_geo = element.layout.geometry
    local seek_ranges = element.slider.seek_ranges_f()
    if not seek_ranges then return end
    elem_ass:draw_stop()
    elem_ass:merge(element.style_ass)
    elem_ass:append(osc_styles.seekbar_bg)
    ass_append_alpha(elem_ass, element.layout.alpha, 153, inverse)
    elem_ass:merge(element.static_ass)
    local radius = slider_lo.radius or 0
    local y1, y2 = slider_lo.gap, elem_geo.h - slider_lo.gap
    local function draw_range(p1, p2, r_left, r_right)
        if p2 > p1 then draw_rect(elem_ass, p1, y1, p2, y2, r_left, r_right, radius) end
    end
    if element.name ~= "seekbar" and element.name ~= "persistent_seekbar" then
        for _, range in pairs(seek_ranges) do
            local pstart = math.max(0, get_slider_ele_pos_for(element, range["start"]) - slider_lo.gap)
            local pend = math.min(elem_geo.w, get_slider_ele_pos_for(element, range["end"]) + slider_lo.gap)
            draw_range(pstart, pend, (pstart <= element.slider.min.ele_pos + 1), (pend >= element.slider.max.ele_pos - 1))
        end
        return
    end
    local segments = get_seekbar_segments(elem_geo.w)
    for _, range in pairs(seek_ranges) do
        local r_start, r_end = range["start"], range["end"]
        for i, seg in ipairs(segments) do
            if r_end > seg.start_p and r_start < seg.end_p then
                local draw_s = math.max(r_start, seg.start_p)
                local draw_e = math.min(r_end, seg.end_p)
                local s_ratio = (seg.end_p == seg.start_p) and 0 or (draw_s - seg.start_p) / (seg.end_p - seg.start_p)
                local e_ratio = (seg.end_p == seg.start_p) and 1 or (draw_e - seg.start_p) / (seg.end_p - seg.start_p)
                draw_range(seg.x + s_ratio * seg.w, seg.x + e_ratio * seg.w,
                    (draw_s <= seg.start_p and i == 1), (draw_e >= seg.end_p and i == #segments))
            end
        end
    end
end

local function draw_seekbar_progress(element, elem_ass, inverse)
    local pos = element.slider.pos_f()
    if not pos then return end
    local slider_lo = element.layout.slider
    local elem_geo = element.layout.geometry
    local radius = slider_lo.radius or 0
    local y1, y2 = slider_lo.gap, elem_geo.h - slider_lo.gap
    elem_ass:draw_stop()
    elem_ass:merge(element.style_ass)
    elem_ass:append(osc_styles.seekbar_fg)
    ass_append_alpha(elem_ass, element.layout.alpha, 0, inverse)
    elem_ass:merge(element.static_ass)
    if element.name ~= "seekbar" and element.name ~= "persistent_seekbar" then
        local xp = get_slider_ele_pos_for(element, pos)
        local r_right = (elem_geo.w - xp < radius)
        draw_rect(elem_ass, 0, y1, r_right and elem_geo.w or xp, y2, true, r_right, radius)
        return
    end
    local segments = get_seekbar_segments(elem_geo.w)
    for i, seg in ipairs(segments) do
        if pos > seg.start_p then
            local is_partial = (pos < seg.end_p)
            local draw_w = is_partial and ((pos - seg.start_p) / (seg.end_p - seg.start_p)) * seg.w or seg.w
            local r_right = (i == #segments and not is_partial)
            if i == #segments and is_partial and (seg.w - draw_w < radius) then
                draw_w, r_right = seg.w, true
            end
            if draw_w > 0 then
                draw_rect(elem_ass, seg.x, y1, seg.x + draw_w, y2, (i == 1), r_right, radius)
            end
        end
    end
end

local function draw_seekbar_hover(element, elem_ass)
    if not mouse_hit(element) or element.state.mbtnleft then return end
    local pos = element.slider.pos_f()
    if not pos then return end
    local hover_pos = get_slider_value(element)
    if not hover_pos or hover_pos <= pos then return end
    local slider_lo = element.layout.slider
    local elem_geo = element.layout.geometry
    local radius = slider_lo.radius or 0
    local y1, y2 = slider_lo.gap, elem_geo.h - slider_lo.gap
    elem_ass:draw_stop()
    elem_ass:merge(element.style_ass)
    elem_ass:append(osc_styles.seekbar_bg)
    ass_append_alpha(elem_ass, element.layout.alpha, 153, false)
    elem_ass:merge(element.static_ass)
    if element.name ~= "seekbar" and element.name ~= "persistent_seekbar" then
        local x1 = get_slider_ele_pos_for(element, pos)
        local x2 = get_slider_ele_pos_for(element, hover_pos)
        draw_rect(elem_ass, x1, y1, x2, y2, (x1 <= element.slider.min.ele_pos + 1), (x2 >= element.slider.max.ele_pos - 1), radius)
        return
    end
    local segments = get_seekbar_segments(elem_geo.w)
    for i, seg in ipairs(segments) do
        if hover_pos > seg.start_p and pos < seg.end_p then
            local s = math.max(pos, seg.start_p)
            local e = math.min(hover_pos, seg.end_p)
            local s_ratio = (seg.end_p == seg.start_p) and 0 or (s - seg.start_p) / (seg.end_p - seg.start_p)
            local e_ratio = (seg.end_p == seg.start_p) and 1 or (e - seg.start_p) / (seg.end_p - seg.start_p)
            local x1 = seg.x + s_ratio * seg.w
            local x2 = seg.x + e_ratio * seg.w
            if x2 > x1 then
                draw_rect(elem_ass, x1, y1, x2, y2,
                    (s <= seg.start_p and i == 1), (e >= seg.end_p and i == #segments), radius)
            end
        end
    end
end

-- ── Render de todos os elementos ─────────────────────────────────────────────
local function render_elements(master_ass)
    local function render_element(n)
        local element = elements[n]
        if element.is_wc then
            if not state.wc_visible then return end
        else
            if not state.osc_visible then return end
        end

        local style_ass = assdraw.ass_new()
        style_ass:merge(element.style_ass)
        ass_append_alpha(style_ass, element.layout.alpha, 0)

        if element.eventresponder and (state.active_element == n) then
            if element.eventresponder.render ~= nil then
                element.eventresponder.render(element)
            end
        end

        local elem_ass = assdraw.ass_new()

        -- Hover background
        if element.type == "button" and element.hover_effect then
            local is_clickable = element.eventresponder and (
                element.eventresponder["mbtn_left_down"] ~= nil or
                element.eventresponder["mbtn_left_up"] ~= nil
            )
            if mouse_hit(element) and is_clickable and element.enabled then
                local hx1, hy1, hx2, hy2 = get_element_hitbox(element)
                local is_held = state.active_element == n and mouse_hit(element)
                elem_ass:append("{}")
                elem_ass:new_event()
                elem_ass:pos(0, 0)
                elem_ass:an(7)
                local bg_color = osc_styles.hover_bg
                local override_color = (is_held and element.held_color) or element.hover_color
                if override_color then
                    bg_color = "{\\blur0\\bord0\\1c&H" .. osc_color_convert(override_color) .. "&}"
                end
                ass_append_alpha(elem_ass, {[1] = element.hover_alpha or 0xCC, [2] = 255, [3] = 255, [4] = 255}, element.layout.alpha[1])
                elem_ass:append(bg_color)
                local pad = element.hover_pad or (element.is_wc and 0 or 10)
                local hover_radius = element.hover_radius or (element.is_wc and 0 or 5)
                local shrink = (is_held and not element.is_wc) and 0.5 or 0
                elem_ass:draw_start()
                elem_ass:round_rect_cw(hx1 - pad + shrink, hy1 - pad + shrink, hx2 + pad - shrink, hy2 + pad - shrink, hover_radius)
                elem_ass:draw_stop()
            end
        end
        elem_ass:merge(style_ass)

        if element.type ~= "button" then
            elem_ass:merge(element.static_ass)
        end

        if element.type == "slider" then
            if element.name ~= "persistent_seekbar" then
                local slider_lo = element.layout.slider
                local elem_geo = element.layout.geometry
                draw_seekbar_ranges(element, elem_ass, false)
                draw_seekbar_hover(element, elem_ass)
                draw_seekbar_progress(element, elem_ass, false)
                elem_ass:draw_stop()

                if element.slider.tooltip_f ~= nil and element.enabled then
                    local force_seek_tooltip = element.name == "seekbar"
                        and element.eventresponder["mbtn_left_down"]
                        and element.state.mbtnleft
                        and state.playing_and_seeking

                    if mouse_hit(element) or force_seek_tooltip then
                        local slider_pos = get_slider_value(element)
                        local tooltiplabel = element.slider.tooltip_f(slider_pos)
                        local an = slider_lo.tooltip_an
                        local ty = element.hitbox.y1 - 8
                        if an ~= 2 then ty = ty + elem_geo.h / 2 end
                        local tx = get_virt_mouse_pos()
                        local r_w, r_h = get_virt_scale_factor()
                        local tooltip_width = estimate_text_width(tooltiplabel, slider_lo.tooltip_style)
                        local chapter_text = nil
                        local chapter_width = 0

                        if state.osd_dimensions.w and r_w > 0 then
                            if element.name == "seekbar" and state.duration then
                                local ch = get_chapter(slider_pos * state.duration / 100)
                                if ch and ch.title and ch.title ~= "" then
                                    chapter_text = ch.title
                                    chapter_width = estimate_text_width(chapter_text, slider_lo.tooltip_style)
                                end
                            end
                            if slider_lo.adjust_tooltip or (element.name == "seekbar" and not thumbfast.disabled) then
                                local max_text_width = math.max(tooltip_width, chapter_width)
                                local margin = 10 * r_w
                                local half_width = max_text_width / 2
                                tx = math.min(osc_param.playresx - margin - half_width, math.max(margin + half_width, tx))
                            end
                        end

                        if element.name == "seekbar" then state.slider_pos = slider_pos end

                        local pad_h, pad_v = 4, 4
                        local fs = FONT_SIZE_MD
                        local gap = 5
                        local current_y = ty - fs - pad_v - gap

                        if element.name == "seekbar" and not thumbfast.disabled and state.osd_dimensions.w then
                            local border = 2
                            local hover_sec = (state.duration or 0) * (slider_pos / 100)
                            local thumb_margin_x = 18 / r_w
                            local thumb_x = math.min(state.osd_dimensions.w - thumbfast.width - thumb_margin_x,
                                math.max(thumb_margin_x, tx / r_w - thumbfast.width / 2))
                            thumb_x = math.floor(thumb_x + 0.5)
                            local thumb_y = current_y - border - (thumbfast.height * r_h)
                            if state.ani_type == nil then
                                elem_ass:new_event()
                                elem_ass:pos(thumb_x * r_w, thumb_y)
                                elem_ass:an(7)
                                elem_ass:append(osc_styles.thumbnail)
                                elem_ass:draw_start()
                                elem_ass:round_rect_cw(-border, -border, (thumbfast.width * r_w) + border, (thumbfast.height * r_h) + border, 4)
                                elem_ass:draw_stop()
                                mp.commandv("script-message-to", "thumbfast", "thumb", hover_sec, thumb_x, math.floor(thumb_y / r_h + 0.5))
                            end
                            tx = (thumb_x + thumbfast.width / 2) * r_w
                            an = 2
                            current_y = thumb_y - border - gap
                        end

                        local chapter_tooltip_y = current_y - pad_v
                        if chapter_text and state.osd_dimensions.w and r_w > 0 then
                            elem_ass:new_event()
                            elem_ass:pos(tx - chapter_width / 2 - pad_h, chapter_tooltip_y - fs - pad_v)
                            elem_ass:an(7)
                            elem_ass:append(osc_styles.tooltip_bg)
                            elem_ass:draw_start()
                            elem_ass:round_rect_cw(0, 0, chapter_width + 2 * pad_h, fs + 2 * pad_v, 4)
                            elem_ass:draw_stop()
                            elem_ass:new_event()
                            elem_ass:pos(tx, chapter_tooltip_y)
                            elem_ass:an(2)
                            elem_ass:append(slider_lo.tooltip_style)
                            ass_append_alpha(elem_ass, slider_lo.alpha, 0)
                            elem_ass:append(chapter_text)
                        end

                        if element.name == "seekbar" then
                            elem_ass:new_event()
                            elem_ass:pos(tx - tooltip_width / 2 - pad_h, ty - fs - pad_v)
                            elem_ass:an(7)
                            elem_ass:append(osc_styles.tooltip_bg)
                            elem_ass:draw_start()
                            elem_ass:round_rect_cw(0, 0, tooltip_width + 2 * pad_h, fs + 2 * pad_v, 4)
                            elem_ass:draw_stop()
                        end

                        elem_ass:new_event()
                        elem_ass:pos(tx, ty)
                        elem_ass:an(an)
                        elem_ass:append(slider_lo.tooltip_style)
                        ass_append_alpha(elem_ass, slider_lo.alpha, 0)
                        elem_ass:append(tooltiplabel)
                    elseif element.name == "seekbar" and thumbfast.available then
                        mp.commandv("script-message-to", "thumbfast", "clear")
                    end
                end
            end
        elseif element.type == "button" then
            local buttontext
            if type(element.content) == "function" then
                buttontext = element.content()
            elseif element.content ~= nil then
                buttontext = element.content
            end

            local maxchars = element.layout.button.maxchars
            if maxchars ~= nil and #buttontext > maxchars then
                local limit = math.max(0, math.floor(maxchars * 1.25) - 3)
                if #buttontext > limit then
                    while (#buttontext > limit) do
                        buttontext = buttontext:gsub(".[\128-\191]*$", "")
                    end
                    buttontext = buttontext .. "..."
                end
                buttontext = string.format("{\\fscx%f}", (maxchars/#buttontext)*100) .. buttontext
            end

            local is_held = state.active_element == n and mouse_hit(element)
            if is_held and not element.hover_effect then
                buttontext = "{\\alpha&H80&}" .. buttontext
            end
            elem_ass:append(buttontext)

            if element.tooltip_f ~= nil and mouse_hit(element) then
                local tooltiplabel
                if element.enabled then
                    if type(element.tooltip_f) == "function" then
                        tooltiplabel = element.tooltip_f()
                    else
                        tooltiplabel = element.tooltip_f
                    end
                else
                    tooltiplabel = element.nothingavailable
                end
                local pad = element.hover_pad or 10
                local an = 2
                local ty = element.hitbox.y1 - pad
                local tx = (element.hitbox.x1 + element.hitbox.x2) / 2
                if ty < osc_param.playresy / 2 then
                    ty = element.hitbox.y2 + pad
                    an = 8
                end
                local r_w = get_virt_scale_factor()
                if state.osd_dimensions.w and r_w > 0 then
                    local tooltip_width = estimate_text_width(tooltiplabel, element.tooltip_style)
                    local margin = 10 * r_w
                    tx = math.min(osc_param.playresx - margin - tooltip_width/2, math.max(margin + tooltip_width/2, tx))
                end
                elem_ass:new_event()
                elem_ass:append("{\\rDefault}")
                elem_ass:pos(tx, ty)
                elem_ass:an(an)
                elem_ass:append(element.tooltip_style)
                elem_ass:append(tooltiplabel)
            end
        end
        master_ass:merge(elem_ass)
    end
    for n = 1, #elements do render_element(n) end
end

local function render_persistent_progress(master_ass)
    local element = state.persistent_seekbar_element
    if not element then return end
    local style_ass = assdraw.ass_new()
    style_ass:merge(element.style_ass)
    if state.animation or not state.osc_visible then
        ass_append_alpha(style_ass, element.layout.alpha, 0, true)
        local elem_ass = assdraw.ass_new()
        elem_ass:merge(style_ass)
        elem_ass:merge(element.static_ass)
        if user_opts.persistent_buffer then draw_seekbar_ranges(element, elem_ass, true) end
        draw_seekbar_progress(element, elem_ass, true)
        elem_ass:draw_stop()
        master_ass:merge(elem_ass)
    end
end

-- ── Criação de elementos ─────────────────────────────────────────────────────
local function new_element(name, type)
    elements[name] = {}
    elements[name].type = type
    elements[name].name = name
    elements[name].eventresponder = {}
    elements[name].visible = true
    elements[name].enabled = true
    elements[name].hover_effect = false
    elements[name].state = {}
    elements[name].is_wc = false
    if type == "slider" then
        elements[name].slider = {min = {value = 0}, max = {value = 100}}
    end
    return elements[name]
end

local function add_layout(name)
    if elements[name] ~= nil then
        elements[name].layout = {}
        elements[name].layout.layer = 50
        elements[name].layout.alpha = {[1] = 0, [2] = 255, [3] = 255, [4] = 255}
        if elements[name].type == "button" then
            elements[name].layout.button = {maxchars = nil}
        elseif elements[name].type == "slider" then
            elements[name].layout.slider = {
                border = 1, gap = 1, radius = 0,
                adjust_tooltip = true,
                tooltip_style = "",
                tooltip_an = 2,
                alpha = {[1] = 0, [2] = 255, [3] = 88, [4] = 255},
            }
        elseif elements[name].type == "box" then
            elements[name].layout.box = {radius = 0, hexagon = false}
        end
        return elements[name].layout
    else
        msg.error("add_layout: element '" .. name .. "' not found.")
    end
end

-- ── Window titlebar ──────────────────────────────────────────────────────────
local function window_titlebar()
    local geo = {x = 0, y = 30, an = 1, w = osc_param.playresx, h = 30}
    local controls_w = 150
    local controls_x = geo.w - controls_w
    local title_x = geo.x + 15
    local title_w = controls_x - title_x
    local button_y = geo.y - (geo.h / 2)

    local layout = add_layout("minimize")
    layout.geometry = {x = controls_x + 25, y = button_y, an = 5, w = 50, h = geo.h}
    layout.style = osc_styles.window_control

    layout = add_layout("maximize")
    layout.geometry = {x = controls_x + 75, y = button_y, an = 5, w = 50, h = geo.h}
    layout.style = osc_styles.window_control

    layout = add_layout("close")
    layout.geometry = {x = controls_x + 125, y = button_y, an = 5, w = 50, h = geo.h}
    layout.style = osc_styles.window_control

    add_area("window-controls", get_hitbox_coords(controls_x, geo.y, geo.an, controls_w, geo.h))

    if user_opts.window_title then
        layout = add_layout("window_title")
        layout.geometry = {x = title_x, y = button_y + 14, an = 1, w = title_w, h = geo.h}
        layout.style = string.format("%s{\\clip(%f,%f,%f,%f)}",
            osc_styles.window_title, 0, 0, controls_x, geo.y + geo.h)
    end
end

-- ── Layout principal ─────────────────────────────────────────────────────────
local function layout_default()
    local chapter_index = (state.chapter or -1) >= 0

    local is_box = user_opts.layout == "box"
    local osc_w = is_box
        and math.floor(osc_param.playresx * math.max(0.3, math.min(1.0, user_opts.box_width)))
        or osc_param.playresx

    -- altura extra para segunda linha de botões
    local osc_geo = {
        w = osc_w,
        h = 165
    }

    osc_param.video_margins.b = is_box and 0 or (165 / osc_param.playresy)

    local pos_x = is_box and math.floor((osc_param.playresx - osc_w) / 2) or 0
    local pos_y = osc_param.playresy

    osc_param.areas = {}
add_area("input", get_hitbox_coords(pos_x, pos_y, 1, osc_geo.w, osc_geo.h))
    add_area("showhide", 0, 0, osc_param.playresx, osc_param.playresy)

    local lo

-- Fundo do painel inferior
    new_element("bottombar_bg", "box")
    lo = add_layout("bottombar_bg")
    lo.geometry = {x = pos_x, y = pos_y, an = 7, w = osc_geo.w, h = 1}
    lo.style = osc_styles.bottombar_bg
    lo.layer = 10
    lo.alpha[3] = is_box and user_opts.box_alpha or 50
    if is_box then lo.box.radius = 8 end

    if window_controls_enabled() then
        new_element("window_bar_alpha_bg", "box")
        lo = add_layout("window_bar_alpha_bg")
        lo.geometry = {x = pos_x, y = -100, an = 7, w = osc_w, h = -1}
        lo.style = osc_styles.titlebar_bg
        lo.layer = 10
        lo.alpha[3] = 0
    end

    local ref_x = pos_x + osc_geo.w / 2
    local ref_y = pos_y

    -- ── Seekbar ──────────────────────────────────────────────────────────────
    new_element("seekbarbg", "box")
    lo = add_layout("seekbarbg")
    local seekbar_bg_h = 4
    lo.geometry = {x = ref_x, y = ref_y - 100, an = 5, w = osc_geo.w - 45, h = seekbar_bg_h}
    lo.layer = 13
    lo.style = osc_styles.seekbar_bg
    lo.box.radius = 2
    lo.alpha[1] = 152
    lo.alpha[3] = 128

    lo = add_layout("seekbar")
    local seekbar_h = 18
    lo.geometry = {x = ref_x, y = ref_y - 100, an = 5, w = osc_geo.w - 45, h = seekbar_h}
    lo.layer = 51
    lo.style = osc_styles.seekbar_fg
    lo.slider.gap = (seekbar_h - seekbar_bg_h) / 2.0
    lo.slider.radius = 2
    lo.slider.tooltip_style = osc_styles.tooltip
    lo.slider.tooltip_an = 2

    if user_opts.persistent_progress or state.persistent_progress_toggle then
        lo = add_layout("persistent_seekbar")
        lo.geometry = {x = ref_x, y = ref_y, an = 5, w = osc_geo.w, h = 18}
        lo.style = osc_styles.seekbar_fg
        lo.slider.gap = (seekbar_h - seekbar_bg_h) / 2.0
        lo.slider.tooltip_an = 0
    end

    -- ── Timecodes ─────────────────────────────────────────────────────────────
    local playback_time = mp.get_property_number("playback-time", 0)
    local show_hours = (state.tc_left_rem and state.duration or 0 or playback_time) >= 3600
    local show_durhours = (state.duration or 0) >= 3600
    local time_codes_width = 90 + (state.tc_ms and 60 or 0) + (state.tc_left_rem and 15 or 0)
        + (show_hours and 20 or 0) + (show_durhours and 20 or 0)

    -- ── Título ────────────────────────────────────────────────────────────────
    local title_w = chapter_index and (osc_geo.w - 50) or (osc_geo.w - 50 - time_codes_width)
    if title_w < 0 then title_w = 0 end
    local geo = {x = pos_x + 25, y = ref_y - (chapter_index and 142 or 120), an = 1, w = title_w, h = FONT_SIZE_LG}
    lo = add_layout("title")
    lo.geometry = geo
    lo.style = string.format("%s{\\clip(%f,%f,%f,%f)}", osc_styles.title, geo.x, geo.y - geo.h, geo.x + geo.w, geo.y + geo.h)
    lo.alpha[3] = 0

    -- ── Chapter title ─────────────────────────────────────────────────────────
    local chapter_geo = {x = pos_x + 25, y = ref_y - 118, an = 1, w = osc_geo.w / 2, h = FONT_SIZE_MD}
    lo = add_layout("chapter_title")
    lo.geometry = chapter_geo
    lo.style = string.format("%s{\\clip(%f,%f,%f,%f)}", osc_styles.chapter_title,
        chapter_geo.x, chapter_geo.y - chapter_geo.h, chapter_geo.x + chapter_geo.w, chapter_geo.y + chapter_geo.h)

    -- ── Timecodes (canto direito, acima da seekbar) ────────────────────────────
    lo = add_layout("time_codes")
    lo.geometry = {x = pos_x + osc_geo.w - 25, y = ref_y - 126, an = 6, w = time_codes_width, h = FONT_SIZE_MD}
    lo.style = osc_styles.time

    -- ─────────────────────────────────────────────────────────────────────────
    -- LINHA SUPERIOR DE BOTÕES (y = ref_y - 60)
    -- esquerda: play/pause, prev, next, vol_ctrl + volumebar
    -- direita: fullscreen, ontop, sub, audio, vid, menu
    -- ─────────────────────────────────────────────────────────────────────────
    local btn_y_top = ref_y - 60
    local start_x = pos_x + 25

    lo = add_layout("play_pause")
    lo.geometry = {x = start_x, y = btn_y_top, an = 4, w = 24, h = 24}
    lo.style = osc_styles.buttons
    start_x = start_x + 40

    if elements.playlist_prev.visible then
        lo = add_layout("playlist_prev")
        lo.geometry = {x = start_x, y = btn_y_top, an = 4, w = 24, h = 24}
        lo.style = osc_styles.buttons
        start_x = start_x + 36
    end

    if elements.playlist_next.visible then
        lo = add_layout("playlist_next")
        lo.geometry = {x = start_x, y = btn_y_top, an = 4, w = 24, h = 24}
        lo.style = osc_styles.buttons
        start_x = start_x + 36
    end

    -- Volume: ícone + barra
    if state.audio_track_count > 0 then
        lo = add_layout("vol_ctrl")
        lo.geometry = {x = start_x, y = btn_y_top, an = 4, w = 24, h = 24}
        lo.style = osc_styles.buttons
        start_x = start_x + 28

        new_element("volumebarbg", "box")
        elements.volumebar.visible = osc_geo.w >= 650
        elements.volumebarbg.visible = elements.volumebar.visible
        if elements.volumebar.visible then
            lo = add_layout("volumebarbg")
            lo.geometry = {x = start_x, y = btn_y_top, an = 4, w = 80, h = 2}
            lo.layer = 13
            lo.alpha[1] = 128
            lo.style = osc_styles.volumebar_bg
            lo.box.radius = 1

            lo = add_layout("volumebar")
            lo.geometry = {x = start_x, y = btn_y_top, an = 4, w = 80, h = 8}
            lo.style = osc_styles.volumebar_fg
            lo.slider.gap = 3
            lo.slider.radius = 1
            lo.slider.tooltip_style = osc_styles.tooltip
            lo.slider.tooltip_an = 2
            start_x = start_x + 65
        end
    end

    -- Direita
    local end_x = pos_x + osc_geo.w - 25

    lo = add_layout("fullscreen")
    lo.geometry = {x = end_x, y = btn_y_top, an = 6, w = 24, h = 24}
    lo.style = osc_styles.buttons
    end_x = end_x - 36

    elements.tog_ontop.visible = osc_geo.w >= 500
    if elements.tog_ontop.visible then
        lo = add_layout("tog_ontop")
        lo.geometry = {x = end_x, y = btn_y_top, an = 6, w = 24, h = 24}
        lo.style = osc_styles.buttons
        end_x = end_x - 36
    end

    elements.sub_track.visible = osc_geo.w >= 500
    if elements.sub_track.visible then
        lo = add_layout("sub_track")
        lo.geometry = {x = end_x, y = btn_y_top, an = 6, w = 24, h = 24}
        lo.style = osc_styles.buttons
        end_x = end_x - 36
    end

    elements.audio_track.visible = osc_geo.w >= 600
    if elements.audio_track.visible then
        lo = add_layout("audio_track")
        lo.geometry = {x = end_x, y = btn_y_top, an = 6, w = 24, h = 24}
        lo.style = osc_styles.buttons
        end_x = end_x - 36
    end

    lo = add_layout("menu")
    lo.geometry = {x = end_x, y = btn_y_top, an = 6, w = 24, h = 24}
    lo.style = osc_styles.buttons

    -- ─────────────────────────────────────────────────────────────────────────
    -- LINHA INFERIOR DE BOTÕES (y = ref_y - 26)
    -- shuffle | loop_ab | loop_all | vid_toggle | speed (texto)
    -- ─────────────────────────────────────────────────────────────────────────
    local btn_y_bot = ref_y - 26
    local bx = pos_x + 25

    lo = add_layout("shuffle")
    lo.geometry = {x = bx, y = btn_y_bot, an = 4, w = 24, h = 18}
    lo.style = osc_styles.buttons
    bx = bx + 46

    lo = add_layout("loop_ab")
    lo.geometry = {x = bx, y = btn_y_bot, an = 4, w = 36, h = 18}
    lo.style = osc_styles.buttons_sm
    bx = bx + 56

    lo = add_layout("loop_all")
    lo.geometry = {x = bx, y = btn_y_bot, an = 4, w = 24, h = 18}
    lo.style = osc_styles.buttons
    bx = bx + 46

    lo = add_layout("vid_toggle")
    lo.geometry = {x = bx, y = btn_y_bot, an = 4, w = 24, h = 18}
    lo.style = osc_styles.buttons
    bx = bx + 46

    lo = add_layout("playlist_search")
    lo.geometry = {x = bx, y = btn_y_bot, an = 4, w = 24, h = 18}
    lo.style = osc_styles.buttons
    bx = bx + 46

    lo = add_layout("speed")
    lo.geometry = {x = bx, y = btn_y_bot, an = 4, w = 60, h = 18}
    lo.style = osc_styles.buttons_sm
end

-- ── Visibilidade OSC ─────────────────────────────────────────────────────────
local function osc_visible(visible)
    if state.osc_visible ~= visible then
        state.osc_visible = visible
        update_margins()
    end
    request_tick()
end

-- ── bind_mouse_buttons helper ─────────────────────────────────────────────────
local function bind_mouse_buttons(element_name)
    for _, button in ipairs({"mbtn_left", "mbtn_right"}) do
        local command = user_opts[element_name .. "_" .. button .. "_command"]
        if command ~= nil and command ~= "" and command ~= "ignore" then
            elements[element_name].eventresponder[button .. "_up"] = function() mp.command(command) end
        end
    end
    local command = user_opts[element_name .. "_mbtn_mid_command"]
    if command ~= nil and command ~= "" and command ~= "ignore" then
        elements[element_name].eventresponder["mbtn_mid_up"] = function() mp.command(command) end
    end
    for _, button in ipairs({"wheel_up", "wheel_down"}) do
        local command = user_opts[element_name .. "_" .. button .. "_command"]
        if command ~= nil and command ~= "" and command ~= "ignore" then
            elements[element_name].eventresponder[button .. "_press"] = function() mp.command(command) end
        end
    end
end

local function build_cache_seek_ranges()
    if not user_opts.seekrange or not cache_enabled() then return nil end
    if not state.duration or state.duration <= 0 then return nil end
    local nranges = {}
    for _, range in ipairs(state.demuxer_cache_state["seekable-ranges"]) do
        nranges[#nranges + 1] = {
            ["start"] = 100 * range["start"] / state.duration,
            ["end"]   = 100 * range["end"]   / state.duration,
        }
    end
    return nranges
end

local function setup_canvas()
    local dimensions = state.osd_dimensions
    osc_param.playresy = dimensions.h > 0 and dimensions.h or 720
    if dimensions.aspect > 0 then osc_param.display_aspect = dimensions.aspect end
    osc_param.playresx = osc_param.playresy * osc_param.display_aspect
end

-- ── create_elements: define todos os botões ──────────────────────────────────
local function create_elements()
    state.active_element = nil
    elements = {}

    local ne

    -- ── Window controls ───────────────────────────────────────────────────────
    ne = new_element("close", "button")
    ne.is_wc = true; ne.hover_effect = true
    ne.hover_color = "#E81123"; ne.held_color = "#E63A48"; ne.hover_alpha = 0
    ne.content = icons.window.close
    bind_mouse_buttons("close")

    ne = new_element("maximize", "button")
    ne.is_wc = true; ne.hover_effect = true
    ne.hover_color = "#FFFFFF"; ne.held_color = "#D9D9D9"
    ne.content = (state.window_maximized or state.fullscreen) and icons.window.unmaximize or icons.window.maximize
    bind_mouse_buttons("maximize")

    ne = new_element("minimize", "button")
    ne.is_wc = true; ne.hover_effect = true
    ne.hover_color = "#FFFFFF"; ne.held_color = "#D9D9D9"
    ne.content = icons.window.minimize
    bind_mouse_buttons("minimize")

    ne = new_element("window_title", "button")
    ne.is_wc = true
    ne.content = function()
        local title = mp.command_native({"expand-text", mp.get_property("title")})
        title = title:gsub("\n", " ")
        return title ~= "" and mp.command_native({"escape-ass", title}) or "mpv"
    end

    -- ── Título ────────────────────────────────────────────────────────────────
    ne = new_element("title", "button")
    ne.content = function()
        local title = mp.command_native({"expand-text", user_opts.title})
        title = title:gsub("\n", " ")
        return title ~= "" and mp.command_native({"escape-ass", title}) or "mpv"
    end
    bind_mouse_buttons("title")

    -- ── Chapter title ─────────────────────────────────────────────────────────
    ne = new_element("chapter_title", "button")
    ne.visible = (state.chapter or -1) >= 0
    ne.content = function()
        local chapter_index = (state.chapter or -1)
        if chapter_index < 0 then return "" end
        local chapters = state.chapter_list
        local chapter_data = chapters[chapter_index + 1]
        local chapter_title = chapter_data and chapter_data.title ~= "" and chapter_data.title
            or string.format("Chapter: %d/%d", chapter_index + 1, #chapters)
        return mp.command_native({"escape-ass", chapter_title})
    end
    bind_mouse_buttons("chapter_title")

    -- ── Menu ──────────────────────────────────────────────────────────────────
    ne = new_element("menu", "button")
    ne.hover_effect = true
    ne.content = icons.menu
    ne.tooltip_style = osc_styles.tooltip
    ne.tooltip_f = "Menu"
    bind_mouse_buttons("menu")

    -- ── Playlist prev/next ────────────────────────────────────────────────────
    ne = new_element("playlist_prev", "button")
    ne.hover_effect = true
    ne.visible = state.playlist_pos_1 > 1
    ne.content = icons.previous
    ne.tooltip_style = osc_styles.tooltip
    ne.tooltip_f = "Previous"
    bind_mouse_buttons("playlist_prev")

    ne = new_element("playlist_next", "button")
    ne.hover_effect = true
    ne.visible = state.playlist_count > 1 and (state.playlist_pos_1 < state.playlist_count)
    ne.content = icons.next
    ne.tooltip_style = osc_styles.tooltip
    ne.tooltip_f = "Next"
    bind_mouse_buttons("playlist_next")

    -- ── Play/Pause ────────────────────────────────────────────────────────────
    ne = new_element("play_pause", "button")
    ne.hover_effect = true
    ne.content = function()
        if state.eof_reached then return icons.replay end
        return state.pause and icons.play or icons.pause
    end
    ne.eventresponder["mbtn_left_up"] = function()
        if state.eof_reached then
            mp.commandv("seek", 0, "absolute-percent")
            mp.commandv("set", "pause", "no")
        else
            mp.commandv("cycle", "pause")
        end
    end
    bind_mouse_buttons("play_pause")

    -- ── Audio track ───────────────────────────────────────────────────────────
    ne = new_element("audio_track", "button")
    ne.hover_effect = true
    ne.enabled = state.audio_track_count > 0
    ne.off = state.audio_track_count == 0 or not mp.get_property_native("aid")
    ne.content = icons.audio
    ne.tooltip_style = osc_styles.tooltip
    ne.tooltip_f = function()
        local aid = mp.get_property_native("aid")
        if not aid then return "Audio (off) [-/" .. state.audio_track_count .. "]" end
        local lang = mp.get_property("current-tracks/audio/lang") or "unknown"
        return "Audio (" .. lang .. ") [" .. aid .. "/" .. state.audio_track_count .. "]"
    end 
    ne.nothingavailable = "No audio tracks"
    ne.eventresponder["mbtn_left_up"] = function()
        mp.commandv("osd-msg", "cycle", "audio")
    end
        ne.eventresponder["mbtn_right_up"] = function()
        mp.commandv("no-osd", "cycle", "mute")
    end
    ne.eventresponder["wheel_up_press"]   = function() mp.commandv("osd-msg", "cycle", "audio", "down") end
    ne.eventresponder["wheel_down_press"] = function() mp.commandv("osd-msg", "cycle", "audio") end

    -- ── Sub track ─────────────────────────────────────────────────────────────
    ne = new_element("sub_track", "button")
    ne.hover_effect = true
    ne.enabled = state.sub_track_count > 0
    ne.off = state.sub_track_count == 0 or not mp.get_property_native("sid")
    ne.content = icons.subtitle
    ne.tooltip_style = osc_styles.tooltip
    ne.tooltip_f = function()
        local sid = mp.get_property_native("sid")
        if not sid then return "Subtitles (off) [-/" .. state.sub_track_count .. "]" end
        local lang = mp.get_property("current-tracks/sub/lang") or "unknown"
        return "Subtitles (" .. lang .. ") [" .. sid .. "/" .. state.sub_track_count .. "]"
    end
    ne.nothingavailable = "No subtitles"
    ne.eventresponder["mbtn_left_up"] = function()
        mp.commandv("osd-msg", "cycle", "sub")
    end
    ne.eventresponder["mbtn_mid_up"]  = function() mp.commandv("osd-msg", "cycle", "sub-visibility") end
    ne.eventresponder["mbtn_right_up"]= function() mp.commandv("osd-msg", "cycle", "sub-visibility") end
    ne.eventresponder["wheel_up_press"]   = function() mp.commandv("osd-msg", "cycle", "sub", "down") end
    ne.eventresponder["wheel_down_press"] = function() mp.commandv("osd-msg", "cycle", "sub") end

    -- ── Volume control (ícone mute) ───────────────────────────────────────────
    ne = new_element("vol_ctrl", "button")
    ne.hover_effect = true
    ne.enabled = state.audio_track_count > 0
    ne.off = state.audio_track_count == 0
    ne.content = function()
        local volume = state.volume or 0
        if state.mute then return icons.mute end
        local icon_index = math.min(4, math.ceil((volume / 100) * 3) + 1)
        return icons.volume[icon_index]
    end
    ne.tooltip_style = osc_styles.tooltip
    ne.tooltip_f = function()
        return string.format("Volume: %.0f%%", math.floor((state.volume or 0) + 0.5))
    end
    bind_mouse_buttons("vol_ctrl")

    -- ── Volume bar ────────────────────────────────────────────────────────────
    local volume_max = (mp.get_property_number("volume-max") or 0)
    if volume_max <= 0 then volume_max = 100 end
    ne = new_element("volumebar", "slider")
    ne.enabled = state.audio_track_count > 0
    ne.slider = {min = {value = 0}, max = {value = volume_max}}
    ne.slider.seek_ranges_f = function() return nil end
    ne.slider.pos_f = function() return state.volume end
    ne.slider.tooltip_f = function(pos)
        return (state.audio_track_count > 0) and math.floor(pos) .. "%" or ""
    end
    ne.eventresponder["mouse_move"] = function(element)
        local pos = get_slider_value(element)
        local setvol = math.floor(pos)
        if element.state.lastseek == nil or element.state.lastseek ~= setvol then
            mp.commandv("osd-msg", "set", "volume", setvol)
            element.state.lastseek = setvol
        end
    end
    ne.eventresponder["mbtn_left_down"] = function(element)
        mp.commandv("osd-msg", "set", "volume", math.floor(get_slider_value(element)))
    end
    ne.eventresponder["reset"] = function(element) element.state.lastseek = nil end
    bind_mouse_buttons("volumebar")

    -- ── Fullscreen ────────────────────────────────────────────────────────────
    ne = new_element("fullscreen", "button")
    ne.hover_effect = true
    ne.content = function() return state.fullscreen and icons.fullscreen_exit or icons.fullscreen end
    ne.tooltip_style = osc_styles.tooltip
    ne.tooltip_f = function() return state.fullscreen and "Exit fullscreen" or "Fullscreen" end
    bind_mouse_buttons("fullscreen")

    -- ── On-top ────────────────────────────────────────────────────────────────
    ne = new_element("tog_ontop", "button")
    ne.hover_effect = true
    ne.content = function() return not state.ontop and icons.ontop_on or icons.ontop_off end
    ne.tooltip_style = osc_styles.tooltip
    ne.tooltip_f = function() return state.ontop and "Always on top: on" or "Always on top: off" end
    ne.eventresponder["mbtn_left_up"] = function()
        local was_ontop = state.ontop
        mp.commandv("cycle", "ontop")
        if state.initial_border == "yes" and state.initial_title_bar == "yes" then
            mp.commandv("set", "title-bar", was_ontop and "yes" or "no")
        end
    end

    -- ── Seekbar ───────────────────────────────────────────────────────────────
    ne = new_element("seekbar", "slider")
    ne.enabled = mp.get_property("percent-pos") ~= nil
    ne.slider.pos_f = function()
        if state.eof_reached then return 100 end
        return mp.get_property_number("percent-pos")
    end
    ne.slider.tooltip_f = function(pos)
        if state.duration and pos then return format_time(state.duration * (pos / 100)) end
        return ""
    end
    ne.slider.seek_ranges_f = build_cache_seek_ranges

    local function seekbar_pause(element)
        element.state.was_paused = state.pause
        if not state.pause then
            mp.commandv("cycle", "pause")
            state.playing_and_seeking = true
        end
    end
    local function seekbar_unpause(element)
        if state.playing_and_seeking then
            if not element.state.was_paused and not state.eof_reached then
                mp.commandv("cycle", "pause")
            end
            state.playing_and_seeking = false
        end
    end
    ne.eventresponder["mouse_move"] = function(element)
        if not element.state.mbtnleft then return end
        local seekto = get_slider_value(element)
        if element.state.lastseek == nil or element.state.lastseek ~= seekto then
            local flags = "absolute-percent" .. (user_opts.seekbarkeyframes and "" or "+exact")
            mp.commandv("seek", seekto, flags)
            element.state.lastseek = seekto
        end
    end
    ne.eventresponder["mbtn_left_down"] = function(element)
        element.state.mbtnleft = true
        seekbar_pause(element)
        mp.commandv("seek", get_slider_value(element), "absolute-percent+exact")
    end
    ne.eventresponder["shift+mbtn_left_down"] = function(element)
        element.state.mbtnleft = true
        seekbar_pause(element)
        mp.commandv("seek", get_slider_value(element), "absolute-percent")
    end
    ne.eventresponder["mbtn_left_up"] = function(element)
        element.state.mbtnleft = false
        seekbar_unpause(element)
    end
    ne.eventresponder["mbtn_right_down"] = function(element)
        if not state.chapter_list or state.duration <= 0 then return end
        local target = (get_slider_value(element) / 100) * state.duration
        local best_idx, min_diff = 1, math.huge
        for i, c in ipairs(state.chapter_list) do
            local diff = math.abs(target - c.time)
            if diff >= min_diff then break end
            min_diff, best_idx = diff, i
        end
        mp.set_property("chapter", best_idx - 1)
    end
    ne.eventresponder["reset"] = function(element)
        element.state.lastseek = nil
        if element.state.mbtnleft then
            element.state.mbtnleft = false
            seekbar_unpause(element)
        end
    end

    -- ── Persistent seekbar ────────────────────────────────────────────────────
    ne = new_element("persistent_seekbar", "slider")
    ne.enabled = mp.get_property("percent-pos") ~= nil
    ne.slider.pos_f = function()
        if state.eof_reached then return 100 end
        return mp.get_property_number("percent-pos")
    end
    ne.slider.tooltip_f = function() return "" end
    ne.slider.seek_ranges_f = function()
        if user_opts.persistent_buffer then return build_cache_seek_ranges() end
        return nil
    end

    -- ── Time codes ────────────────────────────────────────────────────────────
    ne = new_element("time_codes", "button")
    ne.visible = state.duration ~= nil
    ne.content = function()
        local playback_time = mp.get_property_number("playback-time", 0)
        local duration = state.duration
        if duration <= 0 then return "--:--" end
        local hour_or_more = playback_time >= 3600
        if hour_or_more ~= state.playtime_hour_force_init then
            request_init()
            state.playtime_hour_force_init = hour_or_more
        end
        if state.tc_left_rem then
            return "-" .. format_time(math.max(0, duration - playback_time)) .. " / " .. format_time(duration)
        end
        return format_time(playback_time) .. " / " .. format_time(duration)
    end
    ne.eventresponder["mbtn_left_up"] = function() state.tc_left_rem = not state.tc_left_rem end
    ne.eventresponder["mbtn_right_up"] = function() state.tc_ms = not state.tc_ms; request_init() end

    -- ════════════════════════════════════════════════════════════════════════
    -- BOTÕES EXTRAS (linha inferior)
    -- ════════════════════════════════════════════════════════════════════════

    -- ── Shuffle ───────────────────────────────────────────────────────────────
    ne = new_element("shuffle", "button")
    ne.hover_effect = true
    ne.content = function()
        return icons.shuffle_on
    end
    ne.off = not state.shuffle
    ne.tooltip_style = osc_styles.tooltip
    ne.tooltip_f = function() return state.shuffle and "Shuffle: on" or "Shuffle: off" end
    local function do_shuffle_toggle()
        state.shuffle = not state.shuffle
        if state.shuffle then
            mp.osd_message("Shuffle: on")
        else
            mp.osd_message("Shuffle: off")
        end
        save_shuffle_state()
        request_init()
    end
    ne.eventresponder["mbtn_left_up"] = do_shuffle_toggle
    mp.add_key_binding("ctrl+r", "shuffle-toggle", do_shuffle_toggle)

    -- ── Loop A-B ──────────────────────────────────────────────────────────────
    ne = new_element("loop_ab", "button")
    ne.hover_effect = true
    ne.content = function()
        local ab = state.ab_loop
        if ab == "off" then return "A-B" end
        if ab == "a"   then return "A-B▸" end
        return "A-B●"
    end
    ne.tooltip_style = osc_styles.tooltip
    ne.tooltip_f = function()
        local a = mp.get_property_number("ab-loop-a")
        local b = mp.get_property_number("ab-loop-b")
        if a == nil and b == nil then return "A-B loop: off" end
        if b == nil then return "A-B loop: point A set (" .. format_time(a) .. ")" end
        return "A-B loop: " .. format_time(a) .. " - " .. format_time(b)
    end
    ne.eventresponder["mbtn_left_up"] = function()
        mp.commandv("ab-loop")
        local a = mp.get_property_number("ab-loop-a")
        local b = mp.get_property_number("ab-loop-b")
        if a == nil and b == nil then
            mp.commandv("show-text", "A-B loop cleared")
        elseif b == nil then
            mp.commandv("show-text", "A-B loop start " .. format_time(a))
        else
            mp.commandv("show-text", "A-B loop: " .. format_time(a) .. " - " .. format_time(b))
        end
        request_tick()
    end
    ne.eventresponder["mbtn_right_up"] = function()
        mp.set_property("ab-loop-a", "no")
        mp.set_property("ab-loop-b", "no")
        state.ab_loop = "off"
        mp.commandv("show-text", "A-B loop cleared")
        request_tick()
    end

    -- ── Loop all ─────────────────────────────────────────────────────────────
    ne = new_element("loop_all", "button")
    ne.hover_effect = true
    ne.content = function()
        return icons.loop_all_on
    end
    ne.off = not state.loop_all
    ne.tooltip_style = osc_styles.tooltip
    ne.tooltip_f = function() return state.loop_all and "Loop playlist: on" or "Loop playlist: off" end
    ne.eventresponder["mbtn_left_up"] = function()
        -- L (maiúsculo) é o atalho do mpv
        local cur = mp.get_property("loop-playlist")
        if cur == "inf" or cur == "yes" then
            mp.set_property("loop-playlist", "no")
            state.loop_all = false
            mp.osd_message("Loop playlist: off")
        else
            mp.set_property("loop-playlist", "inf")
            state.loop_all = true
            mp.osd_message("Loop playlist: on")
        end
        request_init()
    end
    ne.eventresponder["mbtn_right_up"] = function()
        local cur = mp.get_property("loop-file")
        if cur == "inf" or cur == "yes" then
            mp.set_property("loop-file", "no")
            mp.osd_message("Loop file: off")
        else
            mp.set_property("loop-file", "inf")
            mp.osd_message("Loop file: on")
        end
    end

    -- ── Video toggle (--vid=) ─────────────────────────────────────────────────
    ne = new_element("vid_toggle", "button")
    ne.hover_effect = true
    ne.content = function()
        return icons.vid_on
    end
    ne.off = not state.vid_active
    ne.tooltip_style = osc_styles.tooltip
    ne.tooltip_f = function() return state.vid_active and "Video: on" or "Video: off" end
    local function do_vid_toggle()
        if state.vid_active then
            mp.set_property("vid", "no")
            state.vid_active = false
            mp.osd_message("Video: off")
            save_vid_state()
            request_init()
        else
            local pos = mp.get_property_number("playback-time") or 0
            local was_paused = mp.get_property_native("pause")
            local track_list = mp.get_property_native("track-list") or {}
            local first_aid = nil
            local first_sid = nil
            for _, track in ipairs(track_list) do
                if track.type == "audio" and first_aid == nil then
                    first_aid = track.id
                end
                if track.type == "sub" and first_sid == nil then
                    first_sid = track.id
                end
            end
            local options = "start=" .. tostring(pos) .. ",vid=auto"
            if first_aid then
                options = options .. ",aid=" .. tostring(first_aid)
            end
            if was_paused then
                options = options .. ",pause=yes"
            end
            mp.commandv("loadfile", mp.get_property("path"), "replace", 0, options)
            state.vid_active = true
            mp.osd_message("Video: on (reloading...)")
            save_vid_state()
            request_init()
        end
    end
    ne.eventresponder["mbtn_left_up"] = do_vid_toggle
    mp.add_key_binding("ctrl+v", "vid-toggle", do_vid_toggle)


    -- ── Playlist search ───────────────────────────────────────────────────────
    ne = new_element("playlist_search", "button")
    ne.hover_effect = true
    ne.content = "🔍"
    ne.tooltip_style = osc_styles.tooltip
    ne.tooltip_f = "Search playlist"
    ne.eventresponder["mbtn_left_up"] = function()
        mp.commandv("script-binding", "playlist-search-open-kb")
    end
    -- ── Speed control ─────────────────────────────────────────────────────────
    ne = new_element("speed", "button")
    ne.hover_effect = true
    ne.content = function()
        local spd = state.speed or 1
        return string.format("x%g", spd)
    end
    ne.tooltip_style = osc_styles.tooltip
    ne.tooltip_f = function()
        return "Speed: " .. string.format("%.2fx", state.speed or 1)
            .. "\nLeft: +0.25 | Right: -0.25 | Middle: 1x | Wheel: fine adjust (max 10x)"
    end
    local function adjust_speed(delta)
        local new_speed = math.max(0.10, math.min(10.0, (state.speed or 1) + delta))
        -- arredonda para 2 casas para evitar floating point drift
        new_speed = math.floor(new_speed * 100 + 0.5) / 100
        mp.set_property("speed", new_speed)
    end
    ne.eventresponder["mbtn_left_up"]   = function() adjust_speed(0.25) end
    ne.eventresponder["mbtn_right_up"]  = function() adjust_speed(-0.25) end
    ne.eventresponder["mbtn_mid_up"]    = function() mp.set_property("speed", 1) end
    ne.eventresponder["wheel_up_press"] = function() adjust_speed(0.05) end
    ne.eventresponder["wheel_down_press"] = function() adjust_speed(-0.05) end
end

-- ── OSC init ─────────────────────────────────────────────────────────────────
local function osc_init()
    msg.debug("osc_init")
    text_width_cache = {}
    setup_canvas()
    create_elements()
    layout_default()
    if window_controls_enabled() then window_titlebar() end
    state.persistent_seekbar_element = elements["persistent_seekbar"]
    prepare_elements()
    update_margins()
end

-- ── show/hide ────────────────────────────────────────────────────────────────
local function show_osc()
    if not state.enabled then return end
    if state.idle_active then return end
    state.show_time = mp.get_time()
    if user_opts.fadeduration <= 0 then
        osc_visible(true)
    elseif user_opts.fadein then
        if not state.osc_visible then
            state.ani_type = "in"
            request_tick()
        end
    else
        osc_visible(true)
        state.ani_type = nil
    end
end

local function hide_osc()
    if thumbfast.width ~= 0 and thumbfast.height ~= 0 then
        mp.commandv("script-message-to", "thumbfast", "clear")
    end
    if not state.enabled then
        state.osc_visible = false
        render_wipe(state.osd)
    elseif user_opts.fadeduration > 0 then
        if state.osc_visible then
            state.ani_type = "out"
            request_tick()
        end
    else
        osc_visible(false)
    end
end

local function mouse_leave()
    if get_hidetimeout() >= 0 and get_touchtimeout() <= 0 then hide_osc() end
    state.last_mouse_x, state.last_mouse_y = nil, nil
    state.mouse_in_window = false
end

local function handle_touch(_, touch_points)
    if touch_points then
        state.touch_points = touch_points
        if #touch_points > 0 then
            state.touch_time = mp.get_time()
            state.last_touch_x = touch_points[1].x
            state.last_touch_y = touch_points[1].y
        end
    end
end

-- ── Event handling ────────────────────────────────────────────────────────────
local function reset_timeout()
    state.show_time = mp.get_time()
end

local function element_has_action(element, action)
    return element and element.eventresponder and element.eventresponder[action]
end

local function process_event(source, what)
    local action = string.format("%s%s", source, what and ("_" .. what) or "")

    if what == "down" or what == "press" then
        reset_timeout()
        for n = 1, #elements do
            if mouse_hit(elements[n]) and elements[n].eventresponder and
               (elements[n].eventresponder[source .. "_up"] or elements[n].eventresponder[action]) then
                if what == "down" then
                    state.active_element = n
                    state.active_event_source = source
                end
                if element_has_action(elements[n], action) then
                    elements[n].eventresponder[action](elements[n])
                end
            end
        end
    elseif what == "up" then
        if elements[state.active_element] then
            local n = state.active_element
            if n ~= 0 and element_has_action(elements[n], action) and mouse_hit(elements[n]) then
                elements[n].eventresponder[action](elements[n])
            end
            if element_has_action(elements[n], "reset") then
                elements[n].eventresponder["reset"](elements[n])
            end
        end
        state.active_element = nil
    elseif source == "mouse_move" then
        state.mouse_in_window = true
        local mouse_x, mouse_y = get_virt_mouse_pos()
        if state.last_mouse_x == nil then
            state.last_mouse_x, state.last_mouse_y = mouse_x, mouse_y
        end
        if user_opts.minmousemove == 0 or
           math.abs(mouse_x - state.last_mouse_x) >= user_opts.minmousemove or
           math.abs(mouse_y - state.last_mouse_y) >= user_opts.minmousemove then
            state.last_mouse_x, state.last_mouse_y = mouse_x, mouse_y
            show_osc()
        end
        local n = state.active_element
        if element_has_action(elements[n], action) then
            elements[n].eventresponder[action](elements[n])
        end
    end
    request_tick()
end

local function do_enable_keybindings()
    if state.enabled then
        if not state.showhide_enabled then
            mp.enable_key_bindings("showhide", "allow-vo-dragging+allow-hide-cursor")
            mp.enable_key_bindings("showhide_wc", "allow-vo-dragging+allow-hide-cursor")
        end
        state.showhide_enabled = true
    end
end

local function enable_osc(enable)
    state.enabled = enable
    if enable then
        do_enable_keybindings()
    else
        hide_osc()
        if state.showhide_enabled then
            mp.disable_key_bindings("showhide")
            mp.disable_key_bindings("showhide_wc")
        end
        state.showhide_enabled = false
    end
end

-- ── Render principal ──────────────────────────────────────────────────────────
local function render()
    local mouse_x, mouse_y = get_virt_mouse_pos()
    local now = mp.get_time()

    if state.screen_size_x ~= state.osd_dimensions.w or state.screen_size_y ~= state.osd_dimensions.h then
        request_init_resize()
        state.screen_size_x = state.osd_dimensions.w
        state.screen_size_y = state.osd_dimensions.h
    end

    if state.active_element then
        request_tick()
    elseif state.init_req then
        osc_init()
        state.init_req = false
        if (state.last_mouse_x == nil or state.last_mouse_y == nil) and
           not (mouse_x == nil or mouse_y == nil or mouse_x == -1 or mouse_y == -1) then
            state.last_mouse_x, state.last_mouse_y = mouse_x, mouse_y
        end
    end

    -- Fade animation
    if state.ani_type ~= nil then
        if state.ani_start == nil then state.ani_start = now end
        if now < state.ani_start + (user_opts.fadeduration / 1000) then
            if state.ani_type == "in" then
                osc_visible(true)
                state.animation = scale_value(state.ani_start, state.ani_start + user_opts.fadeduration/1000, 255, 0, now)
            elseif state.ani_type == "out" then
                state.animation = scale_value(state.ani_start, state.ani_start + user_opts.fadeduration/1000, 0, 255, now)
            end
        else
            if state.ani_type == "out" then osc_visible(false) end
            kill_animation()
        end
    else
        kill_animation()
    end

    for _, cords in pairs(osc_param.areas["showhide"]) do
        set_virt_mouse_area(cords.x1, cords.y1, cords.x2, cords.y2, "showhide")
    end
    if osc_param.areas["showhide_wc"] then
        for _, cords in pairs(osc_param.areas["showhide_wc"]) do
            set_virt_mouse_area(cords.x1, cords.y1, cords.x2, cords.y2, "showhide_wc")
        end
    else
        set_virt_mouse_area(0, 0, 0, 0, "showhide_wc")
    end
    do_enable_keybindings()

    local mouse_over_osc = false
    local function update_area(area_name, visible, enabled_key, enable_fn)
        if not osc_param.areas[area_name] then return end
        for _, cords in ipairs(osc_param.areas[area_name]) do
            if visible then
                set_virt_mouse_area(cords.x1, cords.y1, cords.x2, cords.y2, area_name)
            end
            if visible ~= state[enabled_key] then
                if visible then enable_fn() else mp.disable_key_bindings(area_name) end
                state[enabled_key] = visible
            end
            if mouse_hit_coords(cords.x1, cords.y1, cords.x2, cords.y2) then
                mouse_over_osc = true
            end
        end
    end
    update_area("input", state.osc_visible, "input_enabled", function() mp.enable_key_bindings("input") end)
    update_area("window-controls", state.wc_visible, "windowcontrols_buttons", function() mp.enable_key_bindings("window-controls") end)
    update_area("window-controls-title", state.wc_visible, "windowcontrols_title", function() mp.enable_key_bindings("window-controls-title", "allow-vo-dragging") end)

    if state.show_time ~= nil and get_hidetimeout() >= 0 then
        if state.hide_timer then state.hide_timer.timeout = math.huge end
        local timeout = state.show_time + (get_hidetimeout() / 1000) - now
        if timeout <= 0 and get_touchtimeout() <= 0 then
            if state.active_element == nil and not mouse_over_osc then
                hide_osc()
            end
        else
            if not state.hide_timer then
                state.hide_timer = mp.add_timeout(0, tick)
            end
            if timeout < state.hide_timer.timeout then
                state.hide_timer.timeout = timeout
                state.hide_timer:kill()
                state.hide_timer:resume()
            end
        end
    end

    local ass = assdraw.ass_new()
    if state.osc_visible or state.wc_visible then
        render_elements(ass)
    end
    if user_opts.persistent_progress or state.persistent_progress_toggle then
        render_persistent_progress(ass)
    end
    set_osd(state.osd, osc_param.playresy * osc_param.display_aspect, osc_param.playresy, ass.text, 1000)
end

-- ── Logo idle ─────────────────────────────────────────────────────────────────
local function render_logo()
    if state.osd_dimensions.aspect == 0 then return end
    local display_h = 360
    local display_w = display_h * state.osd_dimensions.aspect
    local icon_x = (display_w - 1800 / 32) / 2
    local icon_y = (display_h - 1800 / 32) / 2
    local line_prefix = ("{\\rDefault\\an7\\1a&H00&\\bord0\\shad0\\pos(%f,%f)}"):format(icon_x, icon_y)
    local ass = assdraw.ass_new()
    for _, line in ipairs(logo_lines) do
        ass:new_event()
        ass:append(line_prefix .. line)
    end
    if user_opts.idlescreen then
        ass:new_event()
        ass:pos(display_w / 2, icon_y + 65)
        ass:an(8)
        ass:append("Drop files or URLs here to play")
    end
    set_osd(state.logo_osd, display_w, display_h, ass.text, -1000)
end

-- ── Tick ──────────────────────────────────────────────────────────────────────
tick = function()
    if state.margins_req then
        update_margins()
        state.margins_req = false
    end
    if not state.enabled then return end

    if state.idle_active then
        if user_opts.idlescreen then render_logo() end
        if state.osc_visible then osc_visible(false) end
        if window_controls_enabled() then
            state.wc_visible = true
            render()
        else
            render_wipe(state.osd)
            if state.showhide_enabled then
                mp.disable_key_bindings("showhide")
                mp.disable_key_bindings("showhide_wc")
                state.showhide_enabled = false
            end
        end
    else
        if state.no_video and state.file_loaded and user_opts.audioonlyscreen then
            render_logo()
        else
            render_wipe(state.logo_osd)
        end
        state.wc_visible = state.osc_visible
        render()
    end

    state.tick_last_time = mp.get_time()

    if state.ani_type ~= nil then
        local allow_idle = state.ani_type == "out"
        if (allow_idle or not state.idle_active) and
           (not state.ani_start or mp.get_time() < 1 + state.ani_start + user_opts.fadeduration/1000)
        then
            request_tick()
        else
            kill_animation()
        end
    end
end

-- ── set_tick_delay ────────────────────────────────────────────────────────────
local function set_tick_delay(_, display_fps)
    if not display_fps or not user_opts.tick_delay_follow_display_fps then
        tick_delay = user_opts.tick_delay
        return
    end
    tick_delay = 1 / display_fps
end

-- ── Observar estado do loop A-B ───────────────────────────────────────────────
mp.observe_property("ab-loop-a", "native", function(_, val_a)
    local val_b = mp.get_property_native("ab-loop-b")
    if val_a == nil or val_a == false then
        state.ab_loop = "off"
    elseif val_b == nil or val_b == false then
        state.ab_loop = "a"
    else
        state.ab_loop = "ab"
    end
    request_tick()
end)
mp.observe_property("ab-loop-b", "native", function(_, val_b)
    local val_a = mp.get_property_native("ab-loop-a")
    if val_a == nil or val_a == false then
        state.ab_loop = "off"
    elseif val_b == nil or val_b == false then
        state.ab_loop = "a"
    else
        state.ab_loop = "ab"
    end
    request_tick()
end)

-- Observar loop-playlist
mp.observe_property("loop-playlist", "native", function(_, val)
    state.loop_all = (val == "inf" or val == "yes" or val == true)
    request_tick()
end)

-- Observar vid (vídeo ativo)
-- Não atualiza state.vid_active aqui para não sobrescrever o estado salvo em disco.
-- state.vid_active é fonte de verdade; o observer só pede redraw.
mp.observe_property("vid", "native", function(_, val)
    request_tick()
end)

-- ── Eventos mpv ───────────────────────────────────────────────────────────────
mp.register_event("file-loaded", function()
    state.file_loaded = true
    state.no_video = mp.get_property_native("current-tracks/video") == nil
    request_tick()
    if user_opts.automatickeyframemode then
        user_opts.seekbarkeyframes = (state.duration or 0) > user_opts.automatickeyframelimit
    end
    if user_opts.osc_on_start then show_osc() end

    -- Aplica o estado de vídeo salvo. Usa timer curto para garantir que
    -- os observers do mpv já dispararam antes de nossa intervenção.
    mp.add_timeout(0.1, function()
        if not state.vid_active then
            mp.set_property("vid", "no")
            msg.debug("vid state restored: off")
        else
            if mp.get_property("vid") == "no" then
                mp.set_property("vid", "auto")
                msg.debug("vid state restored: on")
            end
        end
    end)
end)

mp.register_event("start-file", request_init)
mp.observe_property("track-list", "native", update_tracklist)
observe_cached("playlist-count", request_init)
observe_cached("playlist-pos-1", request_init)
observe_cached("chapter-list", function()
    table.sort(state.chapter_list, function(a, b) return a.time < b.time end)
    request_init()
end)
mp.register_event("seek", function()
    if state.file_loaded then
        state.file_loaded = false
        return
    end
    if user_opts.osc_on_seek then show_osc() end
end)
observe_cached("duration", function()
    if state.chapter_list[1] then request_init() end
end)
mp.observe_property("seeking", "native", function() reset_timeout() end)
observe_cached("fullscreen", function()
    state.margins_req = true
    request_init_resize()
end)
observe_cached("border", request_init_resize)
observe_cached("title-bar", request_init_resize)
observe_cached("window-maximized", request_init_resize)
observe_cached("idle-active", request_tick)

mp.add_hook("on_unload", 50, function()
    state.file_loaded = false
    request_tick()
end)

mp.register_event("shutdown", function()
    local vol = mp.get_property_number("volume")
    if vol then
        state.volume = vol
        save_vol_state()
        msg.debug("vol state saved on shutdown: " .. tostring(vol))
    end
end)

mp.observe_property("volume", "number", function(_, val)
    if val then
        local prev = state.volume
        state.volume = val
        if not vol_ignore_observer then
            save_vol_state()
            if prev ~= nil and math.abs(val - prev) > 0.01 then
                mp.osd_message(string.format("Volume: %d%%", math.floor(val + 0.5)))
            end
        else
            msg.debug("vol observer ignored (startup): " .. tostring(val))
        end
    end
    request_tick()
end)
mp.observe_property("display-fps", "number", set_tick_delay)
observe_cached("pause", request_tick)
observe_cached("speed", request_tick)
observe_cached("mute", request_tick)
observe_cached("chapter", request_tick)
observe_cached("ontop", request_tick)
observe_cached("eof-reached", request_tick)
observe_cached("demuxer-cache-state", request_tick)
mp.observe_property("vo-configured", "bool", request_tick)
mp.observe_property("playback-time", "number", request_tick)
observe_cached("osd-dimensions", request_init_resize)
observe_cached("osd-scale-by-window", request_init_resize)
mp.observe_property("touch-pos", "native", handle_touch)

-- ── Key bindings ──────────────────────────────────────────────────────────────
mp.set_key_bindings({
    {"mouse_move",  function() process_event("mouse_move", nil) end},
    {"mouse_leave", mouse_leave},
}, "showhide", "force")
mp.set_key_bindings({
    {"mouse_move",  function() process_event("mouse_move", nil) end},
    {"mouse_leave", mouse_leave},
}, "showhide_wc", "force")
do_enable_keybindings()

mp.set_key_bindings({
    {"mbtn_left",           function() process_event("mbtn_left", "up") end,
                            function() process_event("mbtn_left", "down") end},
    {"mbtn_mid",            function() process_event("mbtn_mid", "up") end,
                            function() process_event("mbtn_mid", "down") end},
    {"mbtn_right",          function() process_event("mbtn_right", "up") end,
                            function() process_event("mbtn_right", "down") end},
    {"shift+mbtn_right",    function() process_event("shift+mbtn_right", "up") end,
                            function() process_event("shift+mbtn_right", "down") end},
    {"shift+mbtn_left",     function() process_event("mbtn_mid", "up") end,
                            function() process_event("mbtn_mid", "down") end},
    {"wheel_up",            function() process_event("wheel_up", "press") end},
    {"wheel_down",          function() process_event("wheel_down", "press") end},
    {"mbtn_left_dbl",       "ignore"},
    {"shift+mbtn_left_dbl", "ignore"},
    {"mbtn_right_dbl",      "ignore"},
}, "input", "force")
mp.enable_key_bindings("input")

mp.set_key_bindings({
    {"mbtn_left", function() process_event("mbtn_left", "up") end,
                  function() process_event("mbtn_left", "down") end},
}, "window-controls", "force")
mp.enable_key_bindings("window-controls")

-- ── Visibility mode ───────────────────────────────────────────────────────────
local function always_on(val)
    if state.enabled then
        if val then show_osc() else hide_osc() end
    end
end

local function visibility_mode(mode, no_osd)
    if mode == "cycle" then
        for i, allowed_mode in ipairs(state.visibility_modes) do
            if i == #state.visibility_modes then
                mode = state.visibility_modes[1]; break
            elseif user_opts.visibility == allowed_mode then
                mode = state.visibility_modes[i + 1]; break
            end
        end
    end
    if mode == "auto" then
        always_on(false); enable_osc(true)
    elseif mode == "always" then
        enable_osc(true); always_on(true)
    elseif mode == "never" then
        enable_osc(false)
    else
        msg.warn("Unknown mode: " .. mode); return
    end
    user_opts.visibility = mode
    mp.set_property_native("user-data/osc/visibility", mode)
    if not no_osd and tonumber(mp.get_property("osd-level")) >= 1 then
        mp.osd_message("OSC visibility: " .. mode)
    end
    mp.disable_key_bindings("input")
    mp.disable_key_bindings("window-controls")
    mp.disable_key_bindings("window-controls-title")
    state.input_enabled = false
    state.windowcontrols_buttons = false
    state.windowcontrols_title = false
    state.wc_visible = false
    update_margins()
    request_tick()
end

local function idlescreen_visibility(mode, no_osd)
    if mode == "cycle" then mode = user_opts.idlescreen and "no" or "yes" end
    user_opts.idlescreen = (mode == "yes")
    mp.set_property_native("user-data/osc/idlescreen", user_opts.idlescreen)
    if not no_osd and tonumber(mp.get_property("osd-level")) >= 1 then
        mp.osd_message("OSC logo: " .. tostring(mode))
    end
    request_tick()
end

observe_cached("pause", function()
    request_tick()
    if user_opts.visibility ~= "never" then
        state.enabled = state.pause
        if state.pause then
            if user_opts.keeponpause then
                if not state.temp_visibility_mode and user_opts.visibility ~= "always" then
                    state.temp_visibility_mode = user_opts.visibility
                end
                visibility_mode("always", true)
            end
        else
            if state.temp_visibility_mode then
                visibility_mode(state.temp_visibility_mode, true)
                state.temp_visibility_mode = nil
            else
                visibility_mode(user_opts.visibility, true)
            end
        end
    end
end)

mp.register_script_message("osc-visibility", visibility_mode)
mp.register_script_message("osc-show", show_osc)
mp.register_script_message("osc-hide", function()
    if user_opts.visibility == "auto" then hide_osc() end
end)
mp.add_key_binding(nil, "visibility", function() visibility_mode("cycle") end)
mp.add_key_binding(nil, "progress-toggle", function()
    user_opts.persistent_progress = not user_opts.persistent_progress
    state.persistent_progress_toggle = user_opts.persistent_progress
    request_init()
end)
mp.register_script_message("osc-idlescreen", idlescreen_visibility)
mp.register_script_message("thumbfast-info", function(json)
    local data = utils.parse_json(json)
    if type(data) ~= "table" or not data.width or not data.height then
        msg.error("thumbfast-info: invalid JSON")
    else
        thumbfast = data
    end
end)

-- ── Validação e inicialização ─────────────────────────────────────────────────
local function validate_user_opts()
    if user_opts.window_top_bar ~= "auto" and
       user_opts.window_top_bar ~= "yes" and
       user_opts.window_top_bar ~= "no" then
        msg.warn("Invalid window_top_bar value, using 'auto'")
        user_opts.window_top_bar = "auto"
    end
    user_opts.layout = user_opts.layout:gsub("%s+", "")
    if user_opts.layout ~= "box" and user_opts.layout ~= "bottombar" then
        msg.warn("Invalid layout value, using 'bottombar'")
        user_opts.layout = "bottombar"
    end
    if user_opts.accent_color:find("^#%x%x%x%x%x%x$") == nil then
        msg.warn("Invalid accent_color value, using #9B59B6")
        user_opts.accent_color = "#9B59B6"
    end
    for str in string.gmatch(user_opts.visibility_modes, "([^_]+)") do
        if str == "auto" or str == "always" or str == "never" then
            table.insert(state.visibility_modes, str)
        else
            msg.warn("Unknown visibility mode: " .. str)
        end
    end
end

opt.read_options(user_opts, "modern-osc", function(changed)
    validate_user_opts()
    set_osc_styles()
    set_time_styles(changed.timecurrent, changed.timems)
    if changed.tick_delay or changed.tick_delay_follow_display_fps then
        set_tick_delay("display_fps", mp.get_property_number("display_fps"))
    end
    request_tick()
    visibility_mode(user_opts.visibility, true)
    request_init()
end)

validate_user_opts()
set_osc_styles()
set_time_styles(true, true)
set_tick_delay()
visibility_mode(user_opts.visibility, true)
state.shuffle = load_shuffle_state()
state.vid_active = load_vid_state()

vol_ignore_observer = true
mp.add_timeout(0.5, function()
    local saved_vol = load_vol_state()
    mp.set_property("volume", saved_vol)
    msg.debug("vol restored after resume: " .. tostring(saved_vol))
    vol_ignore_observer = false
end)

math.randomseed(os.time())

mp.register_event("end-file", function(event)
    msg.debug("end-file fired, reason: " .. tostring(event.reason) .. ", shuffle: " .. tostring(state.shuffle))
    if not state.shuffle then return end
    if event.reason ~= "eof" and event.reason ~= "redirect" then return end
    local count = mp.get_property_number("playlist-count") or 0
    if count <= 1 then return end
    local current = mp.get_property_number("playlist-pos") or 0
    local next_pos
    repeat
        next_pos = math.random(0, count - 1)
    until next_pos ~= current
    msg.debug("next random pos: " .. tostring(next_pos))
    mp.commandv("playlist-play-index", tostring(next_pos))
end)

set_virt_mouse_area(0, 0, 0, 0, "input")
set_virt_mouse_area(0, 0, 0, 0, "window-controls")
set_virt_mouse_area(0, 0, 0, 0, "window-controls-title")