local awful = require("awful")

-- Set the function to open the jgmenu
function openJgmenu()
    awful.spawn("bash -c 'rm ~/.jgmenu-lockfile; jgmenu'")
end

-- Menu to bring the window to the current desktop
function bring_window_menu()
    local clients = {}
    for _, c in pairs(client.get()) do
        table.insert(clients, {
            c.name,
            function()
                if c:isvisible() then
                    c.minimized = not c.minimized
                else
                    c:move_to_tag(mouse.screen.selected_tag)
                    client.focus = c
                    c:raise()
                end
            end
        })
    end

    return awful.menu({ 
        items = clients, theme = { 
            width = 700, 
            height = 32, 
            icon_size = 32, 
        } 
    })
end

-- Função para filtrar clientes que não são painéis
function get_non_panel_clients()
	local filtered = {}
	for _, c in ipairs(client.get()) do
		-- Ajuste "tint2" ou "Polybar" conforme a classe do seu painel
		if c.class ~= "Tint2" and c.class ~= "Polybar" then
			table.insert(filtered, c)
		end
	end
	return filtered
end