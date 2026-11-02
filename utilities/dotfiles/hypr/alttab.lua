-- ~/.config/hypr/alttab.lua
-- Alt-Tab with previews for Hyprland (Lua config, Hyprland >= 0.55).
--
-- This module does NOT register the main binds. Define them in hyprland.lua
-- using the exported functions:
--
--   local alttab = require("alttab")
--   alttab.setup({})
--   hl.bind("ALT + Tab",           function() alttab.next() end,      { repeating = true })
--   hl.bind("ALT + SHIFT + Tab",   function() alttab.prev() end,      { repeating = true })
--   hl.bind("SUPER + Tab",         function() alttab.next("all") end, { repeating = true })
--   hl.bind("SUPER + SHIFT + Tab", function() alttab.prev("all") end, { repeating = true })
--   hl.bind("ALT + SHIFT + D",     function() alttab.toggle_debug() end)
--
-- Behavior:
--   next/prev          -> cycles through windows of the active workspace
--   next/prev("all")   -> cycles through windows of ALL workspaces
--                         (each thumbnail gets a colored "W-n" badge)
--   while the modifier (cfg.mod / cfg.all_mod) is held the session stays active:
--   cycle as many times as you want
--   release modifier   -> focuses the chosen window and hides the previews
--   ESC                -> cancels
--
-- IMPORTANT: use the same modifier as cfg.mod (scope "workspace") and
-- cfg.all_mod (scope "all") in your binds, because the session ends when
-- THAT modifier is released.
--
-- Debug is OFF by default (see toggle_debug()).
--
-- The end of the session is decided by the RAW keyboard event
-- ("input.keyboard.key"): only releasing the modifier ends it. No submap, no
-- release bind and no polling by default (those were sources of false "released").
--
-- The thumbnail drawing is done by the Quickshell overlay
-- (~/.config/quickshell/alttab_hypr/shell.qml), because Hyprland's Lua has
-- no drawing API.

local M = {}

local defaults = {
	mod = "ALT",                 -- modifier of the "workspace" scope (release ends the session)
	delay_ms = 150,              -- quick alt-tab (< delay) switches without showing previews -- default: 150 -- Tested baseline/Recommended: 300
	qs_cmd = "qs -c alttab_hypr",-- quickshell command with the overlay config
	autostart_overlay = true,
	transport = "both",          -- "both" | "ipc" | "file"
	events_file = '"${XDG_RUNTIME_DIR:-/tmp}/alttab.events"',

	-- How to detect that the modifier was released
	release_keycodes = nil,      -- evdev codes of `mod`; defaults by modifier (ALT = 56, 100)
	release_bind = false,        -- (optional) hyprland release bind
	poll_release = false,        -- (optional) hl.is_key_down polling
	poll_ms = 30,                -- default: 30 -- Tested baseline/Recommended: 400
	session_timeout_ms = 150000,  -- safety net: confirms the selection -- default: 15000 -- Tested baseline/Recommended: 100000

	-- "All workspaces" scope
	all_mod = "SUPER",           -- modifier of the "all" scope (release ends the session)
	all_release_keycodes = nil,  -- default by modifier (SUPER = 125, 126)
	include_special = false,     -- include windows from special workspaces (scratchpad)?
	badge_in_workspace_scope = false, -- show the W-n badge on the "workspace" scope too?

	debounce_ms = 15,            -- ignores the same trigger firing twice at the same instant -- default: 15 -- Tested baseline/Recommended: 100
	debug = false,               -- initial debug state (toggle at runtime with toggle_debug())
	debug_keys = false,          -- logs key code/state DURING the session (needs debug on)
}

local RELEASE_KEYS = {           -- keysyms (for release_bind / poll_release)
	ALT   = { "Alt_L", "Alt_R" },
	SUPER = { "Super_L", "Super_R" },
	CTRL  = { "Control_L", "Control_R" },
	SHIFT = { "Shift_L", "Shift_R" },
}

local RELEASE_KEYCODES = {       -- evdev codes (LeftAlt=56, RightAlt=100, ...)
	-- ALT also accepts the xkb format (evdev+8 = 64/108), in case Hyprland delivers it that way
	ALT   = { 56, 100, 64, 108 },
	SUPER = { 125, 126, 133, 134 },  -- (133/134 = xkb format)
	CTRL  = { 29, 97 },
	SHIFT = { 42, 54 },
}

local cfg = nil
local debug_on = false          -- runtime debug state (initialized from cfg.debug in setup)
local session_binds = {}
local codes_by_mod = {}         -- { ALT = {[56]=true,...}, SUPER = {...} }

local S = {
	active = false,
	list = {},          -- addresses ("0x...") in cycling order
	index = 1,
	shown = false,
	ws_id = nil,        -- workspace where the session started
	scope = "workspace",-- "workspace" or "all"
	mod = "ALT",        -- modifier that started the session
	codes = nil,        -- key codes that end THIS session
	ws_of = {},         -- address -> workspace id
	seen_down = false,  -- (poll) has the polling seen the modifier pressed?
	timers = {},
}

---------------------------------------------------------------------------
-- util
---------------------------------------------------------------------------

-- On-screen notification (hl.notification). Errors ALWAYS notify.
local function notify(text, icon, ms)
	pcall(function()
		hl.notification.create({ text = "alttab: " .. tostring(text), duration = ms or 5000, icon = icon or "info" })
	end)
end

-- Log to hyprland.log (see with: hyprctl rollinglog | grep alttab). Only with debug on.
local function log(msg)
	if debug_on then pcall(hl.print, "[alttab] " .. tostring(msg)) end
end

-- Toggles debug output at runtime. The feedback itself is always shown.
local function toggle_debug()
	debug_on = not debug_on
	pcall(hl.print, "[alttab] debug " .. (debug_on and "ON" or "OFF"))
	notify("debug " .. (debug_on and "ON" or "OFF"), "hint", 2500)
end

-- Talks to the overlay through two channels (cfg.transport = "both" | "ipc" | "file"):
--   ipc : `qs ipc call` (depends on the IpcHandler registering in Quickshell)
--   file: appends a line to $XDG_RUNTIME_DIR/alttab.events, which the overlay
--         reads with `tail -F` (does not depend on IPC). Idempotent messages.
-- Addresses are hex and comma-separated, so it is safe inside single quotes.
local function send(fn, ...)
	local args = { ... }

	if cfg.transport ~= "file" then
		local q = {}
		for _, a in ipairs(args) do q[#q + 1] = "'" .. tostring(a) .. "'" end
		local cmd = cfg.qs_cmd .. " ipc call alttab " .. fn .. " " .. table.concat(q, " ")
		log(cmd)
		hl.exec_cmd(cmd)
	end

	if cfg.transport ~= "ipc" then
		local parts = { fn }
		for _, a in ipairs(args) do parts[#parts + 1] = tostring(a) end
		local cmd = "printf '%s\\n' '" .. table.concat(parts, " ") .. "' >> " .. cfg.events_file
		log(cmd)
		hl.exec_cmd(cmd)
	end
end

local function history_rank(w)
	local v = w.focus_history_id
	if v == nil or v < 0 then return 1e9 end
	return v
end

-- All known windows. For "all" scope it merges hl.get_windows() with the
-- windows of each workspace (ws:get_windows()), in case the former does not
-- include those of non-visible workspaces.
local function enumerate(scope)
	local seen, out = {}, {}
	local function add(w)
		if w and w.address and not seen[w.address] then
			seen[w.address] = true
			out[#out + 1] = w
		end
	end

	for _, w in ipairs(hl.get_windows()) do add(w) end

	if scope == "all" then
		pcall(function()
			for _, ws in ipairs(hl.get_workspaces()) do
				local ok, list = pcall(function() return ws:get_windows() end)
				if ok and list then
					for _, w in ipairs(list) do add(w) end
				end
			end
		end)
	end
	return out
end

-- Windows of the active workspace (scope = "workspace") or of all (scope = "all"),
-- from most recently focused to oldest (equivalent to awesome's
-- awful.client.focus.history; focus_history_id is global).
-- Returns: list of addresses, active workspace id, address->workspace,
-- and statistics (for diagnostics).
local function collect(scope)
	local ws = hl.get_active_workspace()
	local stats = { total = 0, unmapped = 0, hidden = 0, special = 0, other_ws = 0, by_ws = {} }
	if not ws then return {}, nil, {}, stats end

	local wins = {}
	for _, w in ipairs(enumerate(scope)) do
		stats.total = stats.total + 1
		if not w.workspace then
			stats.unmapped = stats.unmapped + 1
		elseif not w.mapped then
			stats.unmapped = stats.unmapped + 1
		elseif w.hidden then
			stats.hidden = stats.hidden + 1
		else
			local include
			if scope == "all" then
				include = cfg.include_special or not w.workspace.special
				if not include then stats.special = stats.special + 1 end
			else
				include = w.workspace.id == ws.id
				if not include then stats.other_ws = stats.other_ws + 1 end
			end
			if include then wins[#wins + 1] = w end
		end
	end

	table.sort(wins, function(a, b)
		local ra, rb = history_rank(a), history_rank(b)
		if ra ~= rb then return ra < rb end
		return (a.stable_id or 0) < (b.stable_id or 0)
	end)

	local out, ws_of = {}, {}
	for _, w in ipairs(wins) do
		out[#out + 1] = w.address
		ws_of[w.address] = w.workspace.id
		stats.by_ws[w.workspace.id] = (stats.by_ws[w.workspace.id] or 0) + 1
	end
	return out, ws.id, ws_of, stats
end

-- "1:3 2:1 7:2" (workspace:count) for diagnostic messages
local function fmt_by_ws(by_ws)
	local ids = {}
	for id in pairs(by_ws) do ids[#ids + 1] = id end
	table.sort(ids)
	local parts = {}
	for _, id in ipairs(ids) do parts[#parts + 1] = id .. ":" .. by_ws[id] end
	return table.concat(parts, " ")
end

-- "0xaaa,0xbbb" ("workspace" scope) or "0xaaa:1,0xbbb:7" ("all" scope, with each
-- window's workspace so the overlay can draw the W-n badge).
local function encode_list()
	local with_ws = (S.scope == "all") or cfg.badge_in_workspace_scope
	local parts = {}
	for i, addr in ipairs(S.list) do
		if with_ws and S.ws_of[addr] then
			parts[i] = addr .. ":" .. tostring(S.ws_of[addr])
		else
			parts[i] = addr
		end
	end
	return table.concat(parts, ",")
end

local function cancel_timers()
	for i = #S.timers, 1, -1 do
		local t = S.timers[i]
		pcall(function() t:cancel() end)
		S.timers[i] = nil
	end
end

local function set_session_binds(enabled)
	for _, h in ipairs(session_binds) do
		pcall(function() h:set_enabled(enabled) end)
	end
end

---------------------------------------------------------------------------
-- session
---------------------------------------------------------------------------

-- `reason` is always logged; with debug on it also shows on screen.
local function finish(do_focus, reason)
	if not S.active then return end
	S.active = false          -- first: nothing below may leave the session "alive"
	cancel_timers()
	set_session_binds(false)

	reason = reason or "?"
	log("sessão encerrada: " .. reason .. (do_focus and " (focando)" or " (sem focar)"))
	if debug_on then notify("fim da sessão: " .. reason, "hint", 3500) end

	local was_shown = S.shown
	S.shown = false
	if was_shown then pcall(send, "hide") end

	if do_focus and S.index ~= 1 then
		local addr = S.list[S.index]
		local ok, err = pcall(function()
			if addr and hl.get_window("address:" .. addr) then
				hl.dispatch(hl.dsp.focus({ window = "address:" .. addr }))
			end
		end)
		if not ok then log("erro ao focar: " .. tostring(err)) end
	end
end

local function cycle(dir)
	if not S.active then return end

	S.index = S.index + dir
	if S.index > #S.list then
		S.index = 1
	elseif S.index < 1 then
		S.index = #S.list
	end

	log("seleção: " .. S.index .. "/" .. #S.list)
	if S.shown then send("select", S.index) end
end

local function mod_is_down()
	for _, k in ipairs(RELEASE_KEYS[S.mod] or {}) do
		local ok, down = pcall(hl.is_key_down, k)
		if ok and down then return true end
	end
	return false
end

local function start(dir, scope, mod)
	if S.active then
		-- session in progress: only the same scope cycles (the other is ignored)
		if S.scope == scope then cycle(dir) end
		return
	end

	log("bind disparou (" .. scope .. ")")
	local list, ws_id, ws_of, stats = collect(scope)
	log("janelas encontradas: " .. #list)
	if debug_on then
		notify(string.format("%s: %d janela(s) [ws %s] | vistas=%d, descartadas: sem-mapa=%d hidden=%d especial=%d fora-da-ws=%d",
			scope == "all" and "SUPER+TAB (todas)" or "ALT+TAB (workspace)",
			#list, fmt_by_ws(stats.by_ws), stats.total, stats.unmapped, stats.hidden, stats.special, stats.other_ws),
			"info", 6000)
	end
	if #list < 2 then
		if debug_on then
			notify("só achei " .. #list .. " janela(s) ("
				.. (scope == "all" and "todas as workspaces" or "workspace ativa") .. "); preciso de 2+", "warning")
		end
		return
	end

	S.active = true
	S.scope = scope
	S.mod = mod
	S.codes = codes_by_mod[mod]
	S.ws_of = ws_of
	S.list = list
	S.index = 1
	S.shown = false
	S.ws_id = ws_id
	S.seen_down = false
	set_session_binds(true)

	-- Shows the previews only after the delay (a quick alt-tab flashes nothing).
	S.timers[#S.timers + 1] = hl.timer(function()
		if S.active and not S.shown then
			S.shown = true
			send("show", encode_list(), S.index)
		end
	end, { timeout = cfg.delay_ms, type = "oneshot" })

	-- (optional) polling: only ends after having SEEN the modifier pressed
	if cfg.poll_release then
		S.timers[#S.timers + 1] = hl.timer(function()
			if not S.active then return end
			if mod_is_down() then
				S.seen_down = true
			elseif S.seen_down then
				finish(true, "polling: modificador solto")
			end
		end, { timeout = cfg.poll_ms, type = "repeat" })
	end

	-- safety net
	if cfg.session_timeout_ms and cfg.session_timeout_ms > 0 then
		S.timers[#S.timers + 1] = hl.timer(function()
			finish(true, "timeout de segurança (" .. cfg.session_timeout_ms .. " ms)")
		end, { timeout = cfg.session_timeout_ms, type = "oneshot" })
	end

	cycle(dir) -- same as awesome: starts at index 1 and already advances
end

-- Any error inside a callback ends the session instead of leaving it stuck.
-- `gen`: generation of the setup() that registered the callback. If setup() was
-- called more than once, only the callbacks from the LAST call act; the old
-- ones stay inert. (gen = nil skips this check.)
local function guarded(fn, gen)
	return function(...)
		if gen and gen ~= M._gen then return end
		local ok, err = pcall(fn, ...)
		if not ok then
			pcall(hl.print, "[alttab] erro: " .. tostring(err))
			notify("erro: " .. tostring(err), "error")
			pcall(finish, false, "erro: " .. tostring(err))
		end
	end
end

-- Ignores repeated triggers at the same instant (< debounce_ms), in case
-- Hyprland calls the same bind twice per keypress.
local cool = false
local function debounced(fn)
	return function(...)
		if cool then
			log("disparo duplicado ignorado")
			return
		end
		if cfg.debounce_ms and cfg.debounce_ms > 0 then
			local ok = pcall(function()
				cool = true
				hl.timer(function() cool = false end, { timeout = cfg.debounce_ms, type = "oneshot" })
			end)
			if not ok then cool = false end
		end
		return fn(...)
	end
end

---------------------------------------------------------------------------
-- public API (use these in the binds of hyprland.lua)
---------------------------------------------------------------------------

-- Same protection the internal binds used to have (guarded + debounced).
local function trigger(dir, scope)
	if not cfg then
		notify("chame require(\"alttab\").setup() antes de usar next/prev", "error")
		return
	end
	scope = (scope == "all") and "all" or "workspace"
	local m = (scope == "all") and cfg.all_mod or cfg.mod
	guarded(debounced(function() start(dir, scope, m) end))()
end

-- `scope`: "workspace" (default) or "all"
function M.next(scope) trigger(1, scope) end
function M.prev(scope) trigger(-1, scope) end

-- Toggles debug (notifications + log) at runtime.
function M.toggle_debug()
	guarded(toggle_debug)()
end

---------------------------------------------------------------------------
-- setup
---------------------------------------------------------------------------

M._gen = 0
M._setups = 0

function M.setup(opts)
	cfg = setmetatable(opts or {}, { __index = defaults })

	M._gen = M._gen + 1
	M._setups = M._setups + 1
	local gen = M._gen
	debug_on = cfg.debug and true or false
	cool = false
	local function G(fn) return guarded(fn, gen) end

	if M._setups > 1 and debug_on then
		notify("setup() chamado " .. M._setups .. "x neste estado Lua; só a última chamada vale. "
			.. "Se não recarregou a config, há linhas duplicadas de require(\"alttab\").setup.", "warning")
	end

	-- Key codes that count as "released the modifier", per modifier
	codes_by_mod = {}
	local function register_codes(m, override)
		local set = {}
		for _, c in ipairs(override or RELEASE_KEYCODES[m] or {}) do set[c] = true end
		codes_by_mod[m] = set
	end

	-- Binds that only exist DURING the session (born disabled)
	local function session_bind(keys, fn, o)
		local h = hl.bind(keys, G(fn), o)
		pcall(function() h:set_enabled(false) end)
		session_binds[#session_binds + 1] = h
	end

	-- Release codes and session binds for each modifier in use (no duplicates
	-- if mod == all_mod). The main binds live in hyprland.lua.
	local seen_mods = {}
	for _, e in ipairs({ { cfg.mod, cfg.release_keycodes }, { cfg.all_mod, cfg.all_release_keycodes } }) do
		local m, override = e[1], e[2]
		if not seen_mods[m] then
			seen_mods[m] = true
			register_codes(m, override)

			session_bind(m .. " + Escape", function() finish(false, "Esc") end)

			-- (optional) Hyprland release bind
			if cfg.release_bind then
				for _, rk in ipairs(RELEASE_KEYS[m] or {}) do
					session_bind(rk, function() finish(true, "bind de release (" .. rk .. ")") end,
						{ release = true, ignore_mods = true, transparent = true })
				end
			end
		end
	end

	session_bind("Escape", function() finish(false, "Esc") end)

	-- MAIN: raw keyboard event. Only releasing the SESSION's modifier ends it.
	hl.on("input.keyboard.key", G(function(keycode, _time_ms, state)
		if not S.active then return end
		if cfg.debug_keys then log(string.format("tecla %s estado %s", tostring(keycode), tostring(state))) end
		if state == 0 and S.codes and S.codes[keycode] then
			finish(true, "modificador solto (tecla " .. tostring(keycode) .. ")")
		end
	end))

	-- Keeps everything consistent if something changes under the session
	hl.on("window.close", G(function(w)
		if not S.active then return end
		for i, addr in ipairs(S.list) do
			if addr == w.address then
				table.remove(S.list, i)
				if i < S.index then S.index = S.index - 1 end
				break
			end
		end
		if S.index > #S.list then S.index = 1 end

		if #S.list < 2 then
			finish(false, "sobrou menos de 2 janelas")
		elseif S.shown then
			send("show", encode_list(), S.index)
		end
	end))

	-- Only cancels if it is ANOTHER workspace (the event is broad and may come from the same one)
	hl.on("workspace.active", G(function(ws)
		if not S.active then return end
		if ws and S.ws_id and ws.id == S.ws_id then
			log("workspace.active da própria workspace: ignorado")
			return
		end
		finish(false, "mudou de workspace")
	end))

	-- -n: does not open another instance if one already exists
	if cfg.autostart_overlay then
		hl.on("hyprland.start", function() hl.exec_cmd(cfg.qs_cmd .. " -n") end)
	end

	if debug_on then notify("módulo carregado (debug ligado)") end
end

-- Diagnostics: shows what the module "sees".
-- Bind it in hyprland.lua: hl.bind("CTRL + ALT + D", function() alttab.dump() end)
function M.dump()
	local ok, err = pcall(function()
		local ws = hl.get_active_workspace()
		local wins = hl.get_windows()
		pcall(hl.print, "[alttab] dump: workspace ativa = " .. tostring(ws and ws.id))
		for i, w in ipairs(wins) do
			pcall(hl.print, string.format("[alttab] dump: #%d addr=%s ws=%s special=%s mapped=%s hidden=%s hist=%s class=%s",
				i, tostring(w.address), tostring(w.workspace and w.workspace.id),
				tostring(w.workspace and w.workspace.special), tostring(w.mapped),
				tostring(w.hidden), tostring(w.focus_history_id), tostring(w.class)))
		end

		local lw, _, _, sw = collect("workspace")
		local la, _, _, sa = collect("all")
		notify(string.format("ws ativa=%s | get_windows=%d | ALT+TAB=%d | SUPER+TAB=%d [ws %s] | descartadas(all): sem-mapa=%d hidden=%d especial=%d",
			tostring(ws and ws.id), #wins, #lw, #la, fmt_by_ws(sa.by_ws), sa.unmapped, sa.hidden, sa.special),
			"info", 10000)
	end)
	if not ok then notify("dump falhou: " .. tostring(err), "error") end
end

-- Emergency exit: require("alttab").panic()
function M.panic()
	cool = false
	S.active = true
	finish(false, "panic()")
end

return M