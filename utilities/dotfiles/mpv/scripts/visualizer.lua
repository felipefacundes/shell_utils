-- License: GPLv3
-- Credits: Felipe Facundes

-- ============================================================
--  MPV Audio Visualizer Script — Extended Edition v3
--  Cycle with: k  |  Toggle mode: K
-- ============================================================
local opts = {
    mode = "novideo",
    -- off | noalbumart | novideo | force
    name = "showcqt",
    quality = "medium",
    -- verylow | low | medium | high | veryhigh
    height = 6,
    -- [4 .. 12]
    forcewindow = true,
}

local cycle_key       = "k"
local toggle_mode_key = "K"

if not (mp.get_property("options/lavfi-complex", "") == "") then
    return
end

-- ============================================================
--  Persistence: save/load last chosen visualization
-- ============================================================
local state_dir  = (os.getenv("HOME") or os.getenv("USERPROFILE") or ".") ..
                   "/.config/mpv/mpv-state"
os.execute("mkdir -p " .. state_dir)
local state_file = state_dir .. "/visualizer_state.txt"

local function save_state()
    local f = io.open(state_file, "w")
    if f then
        f:write(opts.name .. "\n")
        f:write(opts.mode .. "\n")
        f:close()
    end
end

local function load_state()
    local f = io.open(state_file, "r")
    if f then
        local name = f:read("*l")
        local mode = f:read("*l")
        f:close()
        if name and name ~= "" then opts.name = name end
        if mode and mode ~= "" then opts.mode = mode end
    end
end

load_state()

-- ============================================================
--  List of available visualizations
-- ============================================================
local visualizer_name_list = {
    "off",
    -- Classic
    "showcqt",
    "showcqtbar",
    "avectorscope",
    "showspectrum",
    "showwaves",
    "showvolume",
    -- VU Meter / CAVA style
    "vumeter",
    "vumeter_stereo",
    "cava_bars",
    "cava_bars2",
    "cava_mirror",
    "cava_mirror2",
    "plasma_wave",
    "plasma_wave2",
    -- Modern spectral
    "spectrum_fire",
    "spectrum_rainbow",
    "spectrum_ice",
    "spectrum_mono",
    -- Oscilloscope / Waveform
    "waveform_center",
    "waveform_center2",
    "waveform_rgb",
    "waveform_rgb2",
    "waveform_born",
    "waveform_glow",
    "showwaves2",
    "waveform_glow2",
    -- Styled vectorscope
    "vectorscope_color",
    "vectorscope_lissajous",
    -- Music clip style
    "musicviz_bars",
    "musicviz_bars2",
    "musicviz_circle",
    "musicviz_circle2",
    -- 3D spectrogram / waterfall
    "waterfall",
    "waterfall_hot",
    -- Cyberpunk
    "cyberpunk",
    -- New
    "nebula_drift",
    "prism_scope",
    "lava_mirror",
    "lava_mirror2",
}

-- ============================================================
--  Options module and logger
-- ============================================================
local options = require 'mp.options'
local msg     = require 'mp.msg'

-- ============================================================
--  Helper: dimensions
-- ============================================================
local function get_dims(quality)
    local w, fps
    if     quality == "verylow"  then w = 640;  fps = 30
    elseif quality == "low"      then w = 960;  fps = 30
    elseif quality == "medium"   then w = 1280; fps = 60
    elseif quality == "high"     then w = 1920; fps = 60
    elseif quality == "veryhigh" then w = 2560; fps = 60
    else
        msg.log("error", "invalid quality"); return nil
    end
    local h = math.floor(w * opts.height / 16)
    return w, h, fps
end

-- ============================================================
--  lavfi filter generator
-- ============================================================
local function get_visualizer(name, quality, vtrack)
    local w, h, fps = get_dims(quality)
    if not w then return "" end

    -- ── Classic ──────────────────────────────────────────────

    if name == "showcqt" then
        local count = math.ceil(w * 180 / 1920 / fps)
        return "[aid1] asplit [ao]," ..
            "aformat=channel_layouts=stereo," ..
            "firequalizer=" ..
                "gain='1.4884e8*f*f*f/(f*f+424.36)/(f*f+1.4884e8)/sqrt(f*f+25122.25)':" ..
                "scale=linlin:wfunc=tukey:zero_phase=on:fft2=on," ..
            "showcqt=" ..
                "fps=" .. fps .. ":size=" .. w .. "x" .. h ..
                ":count=" .. count ..
                ":csp=bt709:bar_g=2:sono_g=4:bar_v=9:sono_v=17" ..
                ":font='Nimbus Mono L,Courier New,mono|bold'" ..
                ":fontcolor='st(0,(midi(f)-53.5)/12);st(1,0.5-0.5*cos(PI*ld(0)));r(1-ld(1))+b(ld(1))'" ..
                ":tc=0.33:attack=0.033" ..
                ":tlength='st(0,0.17);384*tc/(384/ld(0)+tc*f/(1-ld(0)))+384*tc/(tc*f/ld(0)+384/(1-ld(0)))'," ..
            "format=yuv420p [vo]"

    elseif name == "showcqtbar" then
        local axis_h = math.ceil(w * 12 / 1920) * 4
        return "[aid1] asplit [ao]," ..
            "aformat=channel_layouts=stereo," ..
            "firequalizer=" ..
                "gain='1.4884e8*f*f*f/(f*f+424.36)/(f*f+1.4884e8)/sqrt(f*f+25122.25)':" ..
                "scale=linlin:wfunc=tukey:zero_phase=on:fft2=on," ..
            "showcqt=" ..
                "fps=" .. fps .. ":size=" .. w .. "x" .. math.floor((h+axis_h)/2) ..
                ":count=1:csp=bt709:bar_g=2:sono_g=4:bar_v=9:sono_v=17:sono_h=0" ..
                ":axis_h=" .. axis_h ..
                ":font='Nimbus Mono L,Courier New,mono|bold'" ..
                ":fontcolor='st(0,(midi(f)-53.5)/12);st(1,0.5-0.5*cos(PI*ld(0)));r(1-ld(1))+b(ld(1))'" ..
                ":tc=0.33:attack=0.033" ..
                ":tlength='st(0,0.17);384*tc/(384/ld(0)+tc*f/(1-ld(0)))+384*tc/(tc*f/ld(0)+384/(1-ld(0)))'," ..
            "format=yuv420p," ..
            "split [v0]," ..
            "crop=h=" .. math.floor((h-axis_h)/2) .. ":y=0," ..
            "vflip [v1];" ..
            "[v0][v1] vstack [vo]"

    elseif name == "avectorscope" then
        return "[aid1] asplit [ao]," ..
            "aformat=sample_rates=192000," ..
            "avectorscope=size=" .. w .. "x" .. h .. ":r=" .. fps .. "," ..
            "format=rgb0 [vo]"

    elseif name == "showspectrum" then
        return "[aid1] asplit [ao]," ..
            "showspectrum=size=" .. w .. "x" .. h .. ":win_func=blackman [vo]"

    elseif name == "showwaves" then
        return "[aid1] asplit [ao]," ..
            "showwaves=size=" .. w .. "x" .. h ..
                ":r=" .. fps .. ":mode=p2p," ..
            "format=rgb0 [vo]"

    elseif name == "showvolume" then
        return "[aid1] asplit [ao]," ..
            "showvolume=" ..
                "w=" .. math.floor(w/2) ..
                ":h=" .. math.floor(h/8) ..
                ":r=10:m=p:t=false:f=0.8:ds=log:dm=1," ..
            "format=rgb0 [vo]"

    -- ── VU Meter / CAVA style ─────────────────────────────────

    elseif name == "vumeter" then
        return "[aid1] asplit [ao]," ..
            "showvolume=" ..
                "w=" .. w ..
                ":h=" .. h ..
                ":r=" .. fps ..
                ":m=p" ..
                ":t=false" ..
                ":f=0.95" ..
                ":ds=log" ..
                ":dm=3" ..
                ":dmc=0xFF2200," ..
            "format=rgb0 [vo]"

    elseif name == "vumeter_stereo" then
        local bh = math.floor(h / 2)
        return "[aid1] asplit [ao]," ..
            "channelsplit=channel_layout=stereo [cL][cR];" ..
            "[cL] showvolume=w=" .. w .. ":h=" .. bh ..
                ":r=" .. fps .. ":m=p:t=false:f=0.9:ds=log:dm=2:dmc=0x00FF88 [vL];" ..
            "[cR] showvolume=w=" .. w .. ":h=" .. bh ..
                ":r=" .. fps .. ":m=p:t=false:f=0.9:ds=log:dm=2:dmc=0xFF4400 [vR];" ..
            "[vL][vR] vstack [vo]"

    elseif name == "cava_bars" then
        return "[aid1] asplit [ao]," ..
            "showfreqs=" ..
                "size=" .. w .. "x" .. h ..
                ":mode=bar" ..
                ":ascale=log" ..
                ":fscale=log" ..
                ":win_size=2048" ..
                ":win_func=hanning" ..
                ":averaging=1" ..
                ":colors=0x00FFFF," ..
            "format=yuv420p [vo]"

    -- cava_bars2: neon lime green
    elseif name == "cava_bars2" then
        return "[aid1] asplit [ao]," ..
            "showfreqs=" ..
                "size=" .. w .. "x" .. h ..
                ":mode=bar:ascale=log:fscale=log" ..
                ":win_size=2048:win_func=hanning:averaging=1" ..
                ":colors=0x39FF14," ..
            "format=yuv420p [vo]"

    elseif name == "cava_mirror" then
        local hh = math.floor(h / 2)
        return "[aid1] asplit [ao]," ..
            "showfreqs=" ..
                "size=" .. w .. "x" .. hh ..
                ":mode=bar" ..
                ":ascale=log" ..
                ":fscale=log" ..
                ":win_size=2048" ..
                ":win_func=hanning" ..
                ":averaging=1" ..
                ":colors=0x00FFCC," ..
            "format=yuv420p," ..
            "split [f0][f0b];" ..
            "[f0b] vflip [f1];" ..
            "[f0][f1] vstack [vo]"

    -- plasma_wave: 3 frequency bands in symmetric cline waveforms (vertical mirror)
    -- Bass=magenta, Mids=orange-gold, Highs=cyan — each band mirrored
    -- Result: 6 symmetric wave strips flowing = hypnotic plasma effect
    -- cava_mirror2: neon orange mirrored
    elseif name == "cava_mirror2" then
        local hh = math.floor(h / 2)
        return "[aid1] asplit [ao]," ..
            "showfreqs=" ..
                "size=" .. w .. "x" .. hh ..
                ":mode=bar:ascale=log:fscale=log" ..
                ":win_size=2048:win_func=hanning:averaging=1" ..
                ":colors=0xFF6200," ..
            "format=yuv420p," ..
            "split [f0][f0b];" ..
            "[f0b] vflip [f1];" ..
            "[f0][f1] vstack [vo]"

    elseif name == "plasma_wave" then
        local slice = math.floor(h / 6)
        local slice2 = h - slice * 5  -- adjustment for exact sum
        return "[aid1] asplit=4 [ao][pw1][pw2][pw3];" ..

            -- BASS → hot magenta
            "[pw1] lowpass=f=250," ..
            "showwaves=" ..
                "size=" .. w .. "x" .. slice ..
                ":r=" .. fps ..
                ":mode=cline" ..
                ":colors=0xFF1493," ..
            "format=yuv420p," ..
            "split [g0][g1];" ..
            "[g1] vflip [g1f];" ..

            -- MIDS → amber/gold
            "[pw2] bandpass=f=1800:width_type=o:w=4," ..
            "showwaves=" ..
                "size=" .. w .. "x" .. slice ..
                ":r=" .. fps ..
                ":mode=cline" ..
                ":colors=0xFFAA00," ..
            "format=yuv420p," ..
            "split [m0][m1];" ..
            "[m1] vflip [m1f];" ..

            -- HIGHS → electric cyan
            "[pw3] highpass=f=5000," ..
            "showwaves=" ..
                "size=" .. w .. "x" .. slice2 ..
                ":r=" .. fps ..
                ":mode=cline" ..
                ":colors=0x00FFEE," ..
            "format=yuv420p," ..
            "split [a0][a1];" ..
            "[a1] vflip [a1f];" ..

            -- Stack: high-mirror / mid-mirror / bass-mirror / bass / mid / high
            "[a1f][m1f][g1f][g0][m0][a0] vstack=inputs=6," ..
            "format=yuv420p [vo]"


    -- plasma_wave2: Bass=lime green, Mids=electric violet, Highs=neon orange
    elseif name == "plasma_wave2" then
        local slice = math.floor(h / 6)
        local slice2 = h - slice * 5
        return "[aid1] asplit=4 [ao][pw1][pw2][pw3];" ..
            "[pw1] lowpass=f=250," ..
            "showwaves=" ..
                "size=" .. w .. "x" .. slice ..
                ":r=" .. fps .. ":mode=cline:colors=0x39FF14," ..
            "format=yuv420p," ..
            "split [g0][g1];" ..
            "[g1] vflip [g1f];" ..
            "[pw2] bandpass=f=1800:width_type=o:w=4," ..
            "showwaves=" ..
                "size=" .. w .. "x" .. slice ..
                ":r=" .. fps .. ":mode=cline:colors=0xBF00FF," ..
            "format=yuv420p," ..
            "split [m0][m1];" ..
            "[m1] vflip [m1f];" ..
            "[pw3] highpass=f=5000," ..
            "showwaves=" ..
                "size=" .. w .. "x" .. slice2 ..
                ":r=" .. fps .. ":mode=cline:colors=0xFF6200," ..
            "format=yuv420p," ..
            "split [a0][a1];" ..
            "[a1] vflip [a1f];" ..
            "[a1f][m1f][g1f][g0][m0][a0] vstack=inputs=6," ..
            "format=yuv420p [vo]"

    -- ── Modern spectral ───────────────────────────────────────

    elseif name == "spectrum_fire" then
        return "[aid1] asplit [ao]," ..
            "showspectrum=" ..
                "size=" .. w .. "x" .. h ..
                ":mode=combined" ..
                ":color=fire" ..
                ":scale=log" ..
                ":saturation=1" ..
                ":win_func=blackman" ..
                ":orientation=vertical [vo]"

    elseif name == "spectrum_rainbow" then
        return "[aid1] asplit [ao]," ..
            "showspectrum=" ..
                "size=" .. w .. "x" .. h ..
                ":mode=combined" ..
                ":color=rainbow" ..
                ":scale=log" ..
                ":saturation=2" ..
                ":win_func=hanning" ..
                ":orientation=vertical [vo]"

    elseif name == "spectrum_ice" then
        return "[aid1] asplit [ao]," ..
            "showspectrum=" ..
                "size=" .. w .. "x" .. h ..
                ":mode=combined" ..
                ":color=cool" ..
                ":scale=log" ..
                ":saturation=1" ..
                ":win_func=blackman" ..
                ":orientation=vertical [vo]"

    elseif name == "spectrum_mono" then
        return "[aid1] asplit [ao]," ..
            "showspectrum=" ..
                "size=" .. w .. "x" .. h ..
                ":mode=separate" ..
                ":color=green" ..
                ":scale=log" ..
                ":saturation=1" ..
                ":win_func=flattop" ..
                ":orientation=vertical [vo]"

    -- ── Modern waveforms ──────────────────────────────────────

    elseif name == "waveform_center" then
        return "[aid1] asplit [ao]," ..
            "showwaves=" ..
                "size=" .. w .. "x" .. h ..
                ":r=" .. fps ..
                ":mode=cline" ..
                ":colors=0x00FF88," ..
            "format=rgb0 [vo]"

    elseif name == "waveform_rgb" then
        local hh = math.floor(h / 2)
        return "[aid1] asplit [ao]," ..
            "channelsplit=channel_layout=stereo [wL][wR];" ..
            "[wL] showwaves=size=" .. w .. "x" .. hh ..
                ":r=" .. fps .. ":mode=cline:colors=0x00FFFF," ..
            "format=yuv420p [vwL];" ..
            "[wR] showwaves=size=" .. w .. "x" .. hh ..
                ":r=" .. fps .. ":mode=cline:colors=0xFF00AA," ..
            "format=yuv420p [vwR];" ..
            "[vwL][vwR] vstack [vo]"

    -- FIXED: orange (0xFF6600) → pink (0xFF1493)
    elseif name == "waveform_born" then
        local hh = math.floor(h / 3)
        local hh2 = h - hh * 2
        return "[aid1] asplit=4 [ao][b1][b2][b3];" ..
            "[b1] lowpass=f=300," ..
            "showwaves=size=" .. w .. "x" .. hh ..
                ":r=" .. fps .. ":mode=cline:colors=0xFFFF00," ..
            "format=yuv420p [born1];" ..
            "[b2] bandpass=f=2000:width_type=o:w=3," ..
            "showwaves=size=" .. w .. "x" .. hh ..
                ":r=" .. fps .. ":mode=cline:colors=0xAA00FF," ..
            "format=yuv420p [born2];" ..
            "[b3] highpass=f=6000," ..
            "showwaves=size=" .. w .. "x" .. hh2 ..
                ":r=" .. fps .. ":mode=cline:colors=0xFF1493," ..
            "format=yuv420p [born3];" ..
            "[born1][born2][born3] vstack=inputs=3 [vo]"

    elseif name == "waveform_glow" then
        return "[aid1] asplit [ao]," ..
            "showwaves=" ..
                "size=" .. w .. "x" .. h ..
                ":r=" .. fps ..
                ":mode=p2p" ..
                ":colors=0xFF8800|0xFFFF00," ..
            "format=rgb0 [vo]"


    -- waveform_center2: neon orange
    elseif name == "waveform_center2" then
        return "[aid1] asplit [ao]," ..
            "showwaves=" ..
                "size=" .. w .. "x" .. h ..
                ":r=" .. fps ..
                ":mode=cline" ..
                ":colors=0xFF6200," ..
            "format=rgb0 [vo]"

    -- waveform_rgb2: lime green (L) + violet (R)
    elseif name == "waveform_rgb2" then
        local hh = math.floor(h / 2)
        return "[aid1] asplit [ao]," ..
            "channelsplit=channel_layout=stereo [wL][wR];" ..
            "[wL] showwaves=size=" .. w .. "x" .. hh ..
                ":r=" .. fps .. ":mode=cline:colors=0x39FF14," ..
            "format=yuv420p [vwL];" ..
            "[wR] showwaves=size=" .. w .. "x" .. hh ..
                ":r=" .. fps .. ":mode=cline:colors=0xBF00FF," ..
            "format=yuv420p [vwR];" ..
            "[vwL][vwR] vstack [vo]"

    -- showwaves2: electric blue (L) + neon yellow (R)
    elseif name == "showwaves2" then
        local hh = math.floor(h / 2)
        return "[aid1] asplit [ao]," ..
            "channelsplit=channel_layout=stereo [wL][wR];" ..
            "[wL] showwaves=size=" .. w .. "x" .. hh ..
                ":r=" .. fps .. ":mode=p2p:colors=0x00AAFF," ..
            "format=rgb0 [vwL];" ..
            "[wR] showwaves=size=" .. w .. "x" .. hh ..
                ":r=" .. fps .. ":mode=p2p:colors=0xFFFF00," ..
            "format=rgb0 [vwR];" ..
            "[vwL][vwR] vstack [vo]"

    -- waveform_glow2: electric cyan + violet (p2p)
    elseif name == "waveform_glow2" then
        return "[aid1] asplit [ao]," ..
            "showwaves=" ..
                "size=" .. w .. "x" .. h ..
                ":r=" .. fps ..
                ":mode=p2p" ..
                ":colors=0x00FFFF|0xBF00FF," ..
            "format=rgb0 [vo]"

    -- ── Styled vectorscope ────────────────────────────────────

    elseif name == "vectorscope_color" then
        local sq = math.min(w, h)
        return "[aid1] asplit [ao]," ..
            "aformat=sample_rates=96000," ..
            "avectorscope=" ..
                "size=" .. sq .. "x" .. sq ..
                ":r=" .. fps ..
                ":zoom=1.3" ..
                ":draw=dot" ..
                ":bc=5:gc=175:rc=5:ac=255," ..
            "scale=w=" .. w .. ":h=" .. h .. "," ..
            "format=yuv420p [vo]"

    elseif name == "vectorscope_lissajous" then
        local sq = math.min(w, h)
        return "[aid1] asplit [ao]," ..
            "aformat=sample_rates=48000," ..
            "avectorscope=" ..
                "size=" .. sq .. "x" .. sq ..
                ":r=" .. fps ..
                ":zoom=1.0" ..
                ":draw=dot" ..
                ":bc=0:gc=200:rc=200:ac=255," ..
            "scale=w=" .. w .. ":h=" .. h .. "," ..
            "format=rgb0 [vo]"

    -- ── Music clip style ──────────────────────────────────────

    elseif name == "musicviz_bars" then
        return "[aid1] asplit [ao]," ..
            "showfreqs=" ..
                "size=" .. w .. "x" .. h ..
                ":mode=bar" ..
                ":ascale=log" ..
                ":fscale=log" ..
                ":win_size=8192" ..
                ":win_func=blackman" ..
                ":averaging=3" ..
                ":colors=0xFF0055," ..
            "format=yuv420p [vo]"

    -- musicviz_bars2: electric violet
    elseif name == "musicviz_bars2" then
        return "[aid1] asplit [ao]," ..
            "showfreqs=" ..
                "size=" .. w .. "x" .. h ..
                ":mode=bar:ascale=log:fscale=log" ..
                ":win_size=8192:win_func=blackman:averaging=3" ..
                ":colors=0xBF00FF," ..
            "format=yuv420p [vo]"

    elseif name == "musicviz_circle" then
        return "[aid1] asplit [ao]," ..
            "showfreqs=" ..
                "size=" .. w .. "x" .. h ..
                ":mode=line" ..
                ":ascale=sqrt" ..
                ":fscale=log" ..
                ":win_size=4096" ..
                ":win_func=hanning" ..
                ":averaging=2" ..
                ":colors=0xFF00FF," ..
            "format=yuv420p [vo]"

    -- musicviz_circle2: neon yellow
    elseif name == "musicviz_circle2" then
        return "[aid1] asplit [ao]," ..
            "showfreqs=" ..
                "size=" .. w .. "x" .. h ..
                ":mode=line:ascale=sqrt:fscale=log" ..
                ":win_size=4096:win_func=hanning:averaging=2" ..
                ":colors=0xFFFF00," ..
            "format=yuv420p [vo]"

    -- ── Waterfall / spectrogram ───────────────────────────────

    elseif name == "waterfall" then
        return "[aid1] asplit [ao]," ..
            "showspectrum=" ..
                "size=" .. w .. "x" .. h ..
                ":slide=scroll" ..
                ":mode=combined" ..
                ":color=rainbow" ..
                ":scale=log" ..
                ":saturation=1" ..
                ":win_func=blackman [vo]"

    elseif name == "waterfall_hot" then
        return "[aid1] asplit [ao]," ..
            "showspectrum=" ..
                "size=" .. w .. "x" .. h ..
                ":slide=scroll" ..
                ":mode=combined" ..
                ":color=fire" ..
                ":scale=log" ..
                ":saturation=1" ..
                ":win_func=blackman [vo]"

    -- ── CYBERPUNK ─────────────────────────────────────────────

    elseif name == "cyberpunk" then
        local top_h  = math.floor(h * 0.40)
        local half_b = math.floor((h - top_h) / 2)
        local bot_h  = h - top_h - half_b

        return "[aid1] asplit [ao]," ..
            "asplit [a1][a2];" ..

            "[a1] showspectrum=" ..
                "size=" .. w .. "x" .. top_h ..
                ":slide=scroll" ..
                ":mode=separate" ..
                ":color=channel" ..
                ":scale=log" ..
                ":saturation=3" ..
                ":win_func=blackman" ..
                ":orientation=vertical" ..
                " [top];" ..

            "[a2] channelsplit=channel_layout=stereo [bL][bR];" ..
            "[bL] showfreqs=" ..
                "size=" .. w .. "x" .. half_b ..
                ":mode=bar:ascale=log:fscale=log" ..
                ":win_size=4096:win_func=blackman:averaging=1" ..
                ":colors=0x00FFFF," ..
            "format=yuv420p [bars_L];" ..
            "[bR] showfreqs=" ..
                "size=" .. w .. "x" .. bot_h ..
                ":mode=bar:ascale=log:fscale=log" ..
                ":win_size=4096:win_func=blackman:averaging=1" ..
                ":colors=0xFF00FF," ..
            "format=yuv420p," ..
            "vflip [bars_R];" ..
            "[bars_R][bars_L] vstack [bot];" ..

            "[top][bot] vstack," ..
            "format=yuv420p [vo]"

    -- ── Nebula Drift ──────────────────────────────────────────
    --
    --  TOP 55%: showspectrum waterfall "intensity" — warm spectrogram
    --           scrolling vertically, resembles a moving galactic nebula.
    --  BOT 45%: stereo cline waveform mirrored (vflip) in pink/cyan —
    --           symmetric waves pulsing below the spectrogram.
    --  Result: fluid and cohesive visual, no repetition.

    elseif name == "nebula_drift" then
        local top_h = math.floor(h * 0.55)
        local bot_h = h - top_h
        local hbot  = math.floor(bot_h / 2)
        return "[aid1] asplit=3 [ao][nd1][nd2];" ..

            -- TOP: intensity waterfall spectrogram
            "[nd1] showspectrum=" ..
                "size=" .. w .. "x" .. top_h ..
                ":slide=scroll" ..
                ":mode=combined" ..
                ":color=intensity" ..
                ":scale=log" ..
                ":saturation=2" ..
                ":win_func=blackman" ..
                ":orientation=vertical," ..
            "format=yuv420p [nd_top];" ..

            -- BOT: vertically mirrored cline waveform
            "[nd2] channelsplit=channel_layout=stereo [ndL][ndR];" ..
            "[ndL] showwaves=" ..
                "size=" .. w .. "x" .. hbot ..
                ":r=" .. fps .. ":mode=cline:colors=0x00FFCC," ..
            "format=yuv420p [nd_wL];" ..
            "[ndR] showwaves=" ..
                "size=" .. w .. "x" .. (bot_h - hbot) ..
                ":r=" .. fps .. ":mode=cline:colors=0xFF1493," ..
            "format=yuv420p," ..
            "vflip [nd_wR];" ..
            "[nd_wL][nd_wR] vstack [nd_bot];" ..

            "[nd_top][nd_bot] vstack," ..
            "format=yuv420p [vo]"

    -- ── Prism Scope ───────────────────────────────────────────
    --
    --  Thin showfreqs line strip (cyan) at the top.
    --  avectorscope dot zoom=1.5 (cyan-green) in the center.
    --  Thin showfreqs line strip (magenta) at the bottom.
    --  Explicit aresample isolates the vectorscope branch — prevents heap
    --  corruption when the file is not natively at 96kHz.

    -- prism_scope: LINEAR pipeline — zero splits, zero parallel branches
    -- Generates a tall frame (h*3) with showspectrum separate scroll,
    -- then crops into 3 strips and vstacks — stable at any sample rate.
    --
    --  TOP  crop: L channel spectrum — color=cool (blue-cyan)
    --  MID  crop: combined spectrum — color=rainbow
    --  BOT  crop: R channel spectrum — color=cool (hflip inverted)

    elseif name == "prism_scope" then
        local fh = h * 3   -- total height of generated frame
        local y1 = 0
        local y2 = h
        local y3 = h * 2
        return "[aid1] asplit [ao]," ..
            "showspectrum=" ..
                "size=" .. w .. "x" .. fh ..
                ":slide=scroll" ..
                ":mode=separate" ..
                ":color=cool" ..
                ":scale=log" ..
                ":saturation=2" ..
                ":win_func=blackman" ..
                ":orientation=vertical," ..
            "format=yuv420p," ..
            "split=3 [pA][pB][pC];" ..
            "[pA] crop=w=" .. w .. ":h=" .. h .. ":x=0:y=" .. y1 .. " [p_top];" ..
            "[pB] crop=w=" .. w .. ":h=" .. h .. ":x=0:y=" .. y2 .. " [p_mid];" ..
            "[pC] crop=w=" .. w .. ":h=" .. h .. ":x=0:y=" .. y3 .. ",hflip [p_bot];" ..
            "[p_top][p_mid][p_bot] vstack=inputs=3," ..
            "format=yuv420p [vo]"

    -- ── Lava Mirror ───────────────────────────────────────────
    --
    --  3 frequency bands in bar mode (bass=red, mids=orange, highs=yellow).
    --  Each band is mirrored with hflip and joined side by side via hstack →
    --  bars grow from the center outward like erupting lava.
    --  The 3 pairs are stacked vertically.

    elseif name == "lava_mirror" then
        local slice  = math.floor(h / 3)
        local slice3 = h - slice * 2
        local hw     = math.floor(w / 2)
        return "[aid1] asplit=4 [ao][lv1][lv2][lv3];" ..

            -- BASS → red
            "[lv1] lowpass=f=300," ..
            "showfreqs=" ..
                "size=" .. hw .. "x" .. slice ..
                ":mode=bar:ascale=log:fscale=log" ..
                ":win_size=4096:win_func=blackman:averaging=1" ..
                ":colors=0xFF1111," ..
            "format=yuv420p," ..
            "split [r0][r1];" ..
            "[r1] hflip [r1f];" ..
            "[r1f][r0] hstack [lava_low];" ..

            -- MIDS → orange
            "[lv2] bandpass=f=2000:width_type=o:w=4," ..
            "showfreqs=" ..
                "size=" .. hw .. "x" .. slice ..
                ":mode=bar:ascale=log:fscale=log" ..
                ":win_size=4096:win_func=blackman:averaging=1" ..
                ":colors=0xFF6600," ..
            "format=yuv420p," ..
            "split [o0][o1];" ..
            "[o1] hflip [o1f];" ..
            "[o1f][o0] hstack [lava_mid];" ..

            -- HIGHS → yellow
            "[lv3] highpass=f=5000," ..
            "showfreqs=" ..
                "size=" .. hw .. "x" .. slice3 ..
                ":mode=bar:ascale=log:fscale=log" ..
                ":win_size=4096:win_func=blackman:averaging=1" ..
                ":colors=0xFFDD00," ..
            "format=yuv420p," ..
            "split [y0][y1];" ..
            "[y1] hflip [y1f];" ..
            "[y1f][y0] hstack [lava_hi];" ..

            "[lava_low][lava_mid][lava_hi] vstack=inputs=3," ..
            "format=yuv420p [vo]"

    -- lava_mirror2: electric blue / cyan / lime green
    elseif name == "lava_mirror2" then
        local slice  = math.floor(h / 3)
        local slice3 = h - slice * 2
        local hw     = math.floor(w / 2)
        return "[aid1] asplit=4 [ao][lv1][lv2][lv3];" ..
            "[lv1] lowpass=f=300," ..
            "showfreqs=" ..
                "size=" .. hw .. "x" .. slice ..
                ":mode=bar:ascale=log:fscale=log" ..
                ":win_size=4096:win_func=blackman:averaging=1" ..
                ":colors=0x0055FF," ..
            "format=yuv420p," ..
            "split [r0][r1];" ..
            "[r1] hflip [r1f];" ..
            "[r1f][r0] hstack [lava2_low];" ..
            "[lv2] bandpass=f=2000:width_type=o:w=4," ..
            "showfreqs=" ..
                "size=" .. hw .. "x" .. slice ..
                ":mode=bar:ascale=log:fscale=log" ..
                ":win_size=4096:win_func=blackman:averaging=1" ..
                ":colors=0x00FFFF," ..
            "format=yuv420p," ..
            "split [o0][o1];" ..
            "[o1] hflip [o1f];" ..
            "[o1f][o0] hstack [lava2_mid];" ..
            "[lv3] highpass=f=5000," ..
            "showfreqs=" ..
                "size=" .. hw .. "x" .. slice3 ..
                ":mode=bar:ascale=log:fscale=log" ..
                ":win_size=4096:win_func=blackman:averaging=1" ..
                ":colors=0x39FF14," ..
            "format=yuv420p," ..
            "split [y0][y1];" ..
            "[y1] hflip [y1f];" ..
            "[y1f][y0] hstack [lava2_hi];" ..
            "[lava2_low][lava2_mid][lava2_hi] vstack=inputs=3," ..
            "format=yuv420p [vo]"

    -- ── Off ───────────────────────────────────────────────────

    elseif name == "off" then
        local hasvideo = false
        for _, track in ipairs(mp.get_property_native("track-list")) do
            if track.type == "video" then hasvideo = true; break end
        end
        if hasvideo then
            return "[aid1] asetpts=PTS [ao]; [vid1] setpts=PTS [vo]"
        else
            return "[aid1] asetpts=PTS [ao];" ..
                "color=c=Black:s=" .. w .. "x" .. h .. "," ..
                "format=yuv420p [vo]"
        end
    end

    msg.log("error", "invalid visualization name: " .. tostring(name))
    return ""
end

-- ============================================================
--  Mode-based selection
-- ============================================================
local function select_visualizer(vtrack, atrack)
    if atrack == nil or opts.mode == "off" then
        return ""
    elseif opts.mode == "force" then
        return get_visualizer(opts.name, opts.quality, vtrack)
    elseif opts.mode == "noalbumart" then
        if vtrack == nil then
            return get_visualizer(opts.name, opts.quality, vtrack)
        end
        return ""
    elseif opts.mode == "novideo" then
        if vtrack == nil or vtrack.albumart then
            return get_visualizer(opts.name, opts.quality, vtrack)
        end
        return ""
    end
    msg.log("error", "invalid mode: " .. tostring(opts.mode))
    return ""
end

-- ============================================================
--  Main hook
-- ============================================================
local function visualizer_hook()
    local count = mp.get_property_number("track-list/count", -1)
    if count <= 0 then return end

    local atrack = mp.get_property_native("current-tracks/audio")
    local vtrack = mp.get_property_native("current-tracks/video")

    if atrack == nil and vtrack == nil then
        for _, track in ipairs(mp.get_property_native("track-list")) do
            if track.type == "video" and (vtrack == nil or vtrack.albumart == true)
               and mp.get_property("vid") ~= "no" then
                vtrack = track
            elseif track.type == "audio" then
                atrack = track
            end
        end
    end

    local lavfi = select_visualizer(vtrack, atrack)
    if lavfi ~= "" and lavfi ~= mp.get_property("lavfi-complex", "") then
        mp.set_property("file-local-options/lavfi-complex", lavfi)
    end
end

-- ============================================================
--  Options initialization and clamping
-- ============================================================
options.read_options(opts, nil, visualizer_hook)
opts.height = math.min(12, math.max(4, math.floor(opts.height)))

if not opts.forcewindow and mp.get_property('force-window') == "no" then
    return
end

mp.add_hook("on_preloaded", 50, visualizer_hook)
mp.observe_property("current-tracks/audio", "native", visualizer_hook)
mp.observe_property("current-tracks/video", "native", visualizer_hook)

-- ============================================================
--  Key bindings
-- ============================================================
local function cycle_visualizer()
    local index = 1
    for i = 1, #visualizer_name_list do
        if visualizer_name_list[i] == opts.name then
            index = (i % #visualizer_name_list) + 1
            break
        end
    end
    opts.name = visualizer_name_list[index]
    mp.osd_message("Visualizer: " .. opts.name, 2)
    save_state()
    visualizer_hook()
end

local function toggle_mode()
    local modes = { "novideo", "noalbumart", "force", "off" }
    local index = 1
    for i = 1, #modes do
        if modes[i] == opts.mode then
            index = (i % #modes) + 1
            break
        end
    end
    opts.mode = modes[index]
    mp.osd_message("Mode: " .. opts.mode, 2)
    save_state()
    visualizer_hook()
end

mp.add_key_binding(cycle_key,       "cycle-visualizer", cycle_visualizer)
mp.add_key_binding(toggle_mode_key, "toggle-viz-mode",  toggle_mode)