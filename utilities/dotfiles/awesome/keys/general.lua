local awful = require("awful")
local switcher = require("modules.awesome-switcher")
local hotkeys_popup = require("awful.hotkeys_popup")
local naughty = require("naughty")
local menubar = require("menubar")

-- {{{ Mouse bindings
awful.mouse.append_global_mousebindings({
    awful.button({ }, 3, function () openJgmenu() end),
    awful.button({ }, 4, awful.tag.viewprev),
    awful.button({ }, 5, awful.tag.viewnext),
})
-- }}}

-- Default Awesome keybinds shortcuts
awful.keyboard.append_global_keybindings({
    awful.key({ modkey,           }, "F1",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ altkey,           }, "F1", function () openJgmenu() end,
              {description = "show main menu", group = "awesome"}),
    awful.key({ modkey, "Control", }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift", }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),
    awful.key({ modkey,           }, "t", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "system"}),
    awful.key({ modkey, "Shift", },            "r",     function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),
    awful.key({ modkey }, "F3", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"}),
})

-- Tags related keybindings
awful.keyboard.append_global_keybindings({
    awful.key({ altkey, "Control", }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ altkey, "Control", }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,            }, "'", awful.tag.history.restore,
              {description = "go back", group = "tag"}),
})
    
-- Focus related keybindings
awful.keyboard.append_global_keybindings({

    -- Setting to maximize a window with "Super + a" (Toggle Maximize)
    awful.key({ modkey, }, "a",
    function ()
        local c = client.focus
        if c then
            c.maximized = not c.maximized
            c:raise()
        end
    end,
    {description = "Toggle Maximize", group = "client"}
    ),

    -- Show Desktop (hide all windows)
    awful.key({ modkey, "Shift", }, "d",
    function ()
        for s in screen do
            s.selected_tag = s.tags[1] 
            for _, c in pairs(s.clients) do
                c.minimized = true 
            end
        end
    end,
    {description = "Show Desktop", group = "client"}
    ),


	-- Toggle showing the desktop
	awful.key({ modkey, }, "d",
	function()
		if show_desktop then
			for _, c in ipairs(get_non_panel_clients()) do
				c:emit_signal(
					"request::activate", "key.unminimize", {raise = true}
				)
			end
			show_desktop = false
		else
			for _, c in ipairs(get_non_panel_clients()) do
				c.minimized = true
			end
			show_desktop = true
		end
	end,
	{description = "toggle showing the desktop", group = "client"}),

    -- toggle clients visibility
    awful.key({ modkey, "Control" }, "t", function ()
        local t = awful.screen.focused().selected_tag
        if t then
            for _, c in ipairs(t:clients()) do
                c.hidden = not c.hidden
            end
        end
    end,
    { description = "toggle clients visibility", group = "client" }
    ),        
    -- Menu to bring the window to the current desktop
    awful.key({ modkey, "Control", }, "s", function ()
        bring_window_menu():show()
        end,
        {description = "bring window to the current desktop", group = "client"}
    ),
    -- Check if you have open windows
    awful.key({ modkey, "Shift", }, "s", function ()
        awful.menu.client_list {
            theme = {
                width = 700, -- Largura da lista de clientes
                height = 32, -- Altura da lista de clientes
                icon_size = 32, -- Tamanho dos ícones
            }
        }
    end,
    {description = "Open windows", group = "client"}
    ),

    ---------------- awesome-switcher ---------------
    awful.key({ altkey,           }, "Tab",
        function ()
            switcher.switch( 1, "Mod1", "Alt_L", "Shift", "Tab")
        end,
        {description = "focus next by index", group = "client"}
    ),
    
    awful.key({ altkey, "Shift"   }, "Tab",
        function ()
            switcher.switch(-1, "Mod1", "Alt_L", "Shift", "Tab")
        end,
        {description = "focus previous by index", group = "client"}
    ),
    -------------------------------------------------
    awful.key({ modkey,           }, "Tab", 
        function () awful.util.spawn("bash -c ~/.shell_utils/scripts/switch-windows &") 
    end),
    -------------------------------------------------
    awful.key({ altkey, }, "Escape",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ altkey, "Shift" }, "Escape",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    -------------------------------------------------
    awful.key({ altkey, modkey, }, "k", function()
        awful.client.focus.bydirection("up")
        if client.focus then client.focus:raise() end
    end,
    { description = "Select Up", group = "client" }),
    --
    awful.key({ altkey, modkey }, "j", function()
        awful.client.focus.bydirection("down")
        if client.focus then client.focus:raise() end
    end,
    { description = "Select Down", group = "client" }),
    --
    awful.key({ altkey, modkey,  }, "h", function()
        awful.client.focus.bydirection("left")
        if client.focus then client.focus:raise() end
    end,
    { description = "Select Left", group = "client" }),
    --
    awful.key({ altkey, modkey,  }, "l", function()
        awful.client.focus.bydirection("right")
        if client.focus then client.focus:raise() end
    end,
    { description = "Select Right", group = "client" }),
    -------------------------------------------------
    -------------------------------------------------
    awful.key({ modkey,           }, "Escape",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                    c:activate { raise = true, context = "key.unminimize" }
                  end
              end,
              {description = "restore minimized", group = "client"}),
})

-- Layout related keybindings
awful.keyboard.append_global_keybindings({
    -- Layout manipulation
    awful.key({ modkey, "Shift"  }, "-", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"  }, "=", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    --
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    -- resize window up
    awful.key({ modkey,           }, "k",     function() awful.client.incwfact(-0.05)         end,
              { description = "Redimensionar para baixo", group = "layout" }),
    -- resize window down
    awful.key({ modkey,           }, "j",     function() awful.client.incwfact(0.05)          end,
              { description = "Redimensionar para cima", group = "layout" }),
    -- resize window to right
    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    -- resize window to left
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),
})

awful.keyboard.append_global_keybindings({
    awful.key {
        modifiers   = { modkey },
        keygroup    = "numrow",
        description = "only view tag",
        group       = "tag",
        on_press    = function (index)
            local screen = awful.screen.focused()
            local tag = screen.tags[index]
            if tag then
                tag:view_only()
            end
        end,
    },
    awful.key {
        modifiers   = { modkey, "Control" },
        keygroup    = "numrow",
        description = "toggle tag",
        group       = "tag",
        on_press    = function (index)
            local screen = awful.screen.focused()
            local tag = screen.tags[index]
            if tag then
                awful.tag.viewtoggle(tag)
            end
        end,
    },
    awful.key {
        modifiers = { modkey, "Shift" },
        keygroup    = "numrow",
        description = "move focused client to tag",
        group       = "tag",
        on_press    = function (index)
            if client.focus then
                local tag = client.focus.screen.tags[index]
                if tag then
                    client.focus:move_to_tag(tag)
                end
            end
        end,
    },
    awful.key {
        modifiers   = { modkey, "Control", "Shift" },
        keygroup    = "numrow",
        description = "toggle focused client on tag",
        group       = "tag",
        on_press    = function (index)
            if client.focus then
                local tag = client.focus.screen.tags[index]
                if tag then
                    client.focus:toggle_tag(tag)
                end
            end
        end,
    },
    awful.key {
        modifiers   = { modkey },
        keygroup    = "numpad",
        description = "select layout directly",
        group       = "layout",
        on_press    = function (index)
            local t = awful.screen.focused().selected_tag
            if t then
                t.layout = t.layouts[index] or t.layout
            end
        end,
    }
})

client.connect_signal("request::default_mousebindings", function()
    awful.mouse.append_client_mousebindings({
        awful.button({ }, 1, function (c)
            c:activate { context = "mouse_click" }
        end),
        awful.button({ modkey }, 1, function (c)
            c:activate { context = "mouse_click", action = "mouse_move"  }
        end),
        awful.button({ modkey }, 3, function (c)
            c:activate { context = "mouse_click", action = "mouse_resize"}
        end),
    })
end)

client.connect_signal("request::default_keybindings", function()
    awful.keyboard.append_client_keybindings({
        awful.key({ altkey,           }, "F11",
            function (c)
                c.fullscreen = not c.fullscreen
                c:raise()
            end,
            {description = "toggle fullscreen", group = "client"}),
        -- Kill Window
        awful.key({ altkey, "Control", }, "Escape", function ()
            os.execute("xkill")
        end,
        { description = "kill window", group = "client" }),
        -- Closed Window
        awful.key({ altkey, }, "F4", function ()
            local focused_client = client.focus
            if focused_client then
                focused_client:kill()
            end
        end,
        {description = "Closed Window", group = "client"}),
        --
        awful.key({ modkey, "Shift",  }, "q",      function (c) c:kill()                         end,
                {description = "close", group = "client"}),
        awful.key({ modkey,           }, "f",  awful.client.floating.toggle                     ,
                {description = "toggle floating", group = "client"}),
        awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
                {description = "move to master", group = "client"}),
        awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
                {description = "move to screen", group = "client"}),
        awful.key({ altkey, "Control", }, "t",      function (c) c.ontop = not c.ontop            end,
                {description = "toggle keep on top", group = "client"}),
        

        awful.key({ altkey, "Control",  }, "m",
            function (c)
                -- The client currently has the input focus, so it cannot be
                -- minimized, since minimized clients can't have the focus.
                c.minimized = true
            end ,
            {description = "minimize", group = "client"}),
        awful.key({ modkey, altkey,  }, "m",
            function (c)
                c.maximized = not c.maximized
                c:raise()
            end ,
            {description = "(un)maximize", group = "client"}),
        awful.key({ modkey, "Control" }, "m",
            function (c)
                c.maximized_vertical = not c.maximized_vertical
                c:raise()
            end ,
            {description = "(un)maximize vertically", group = "client"}),
        awful.key({ modkey, "Shift"   }, "m",
            function (c)
                c.maximized_horizontal = not c.maximized_horizontal
                c:raise()
            end ,
            {description = "(un)maximize horizontally", group = "client"}),
    })
end)