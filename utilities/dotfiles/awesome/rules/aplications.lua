local awful = require("awful")

-- Use o comando: 
-- xprop | grep WM_CLASS  ou  wmctrl -lx
-- Para identificar a classe da janela

awful.rules.rules = {
    -- Regras genéricas para todas as janelas
    { 
		rule = { },
		properties = { 
            border_width = 1, 
            focus = awful.client.focus.filter,
            maximized = false, 
            size_hints_honor = false,
            placement = awful.placement.centered
        },
        -- Esta linha desativa a barra de título[citation:4]
        callback = function(c)
            awful.titlebar.hide(c, "top") -- Esconde a barra superior[citation:5]
        end
	},

    -- Alacritty rules
    {
        rule = { class = "Alacritty", instance = "Alacritty" },
        properties = { maximized = false, size_hints_honor = false, placement = awful.placement.centered },
    },
    
    -- QuakeTerminal rules (terminal estilo dropdown)
    -- Esta regra cria um terminal flutuante que se comporta como o Quake console
    {
        rule = { name = "QuakeTerminal" },  -- Aplica apenas a janelas com título "QuakeTerminal"
        properties = {
            tag = "X",  -- Abre no workspace X (substitua X pelo número ou nome do workspace desejado)
            floating = true,  -- Torna a janela flutuante (não segue o layout padrão)
            ontop = true,  -- Mantém a janela sempre acima de outras (mesmo quando não está em foco)
            above = true,  -- Força a janela a ficar na camada superior (similar ao ontop, mas mais forte)
            border_width = 0,  -- Remove completamente as bordas da janela para um visual mais limpo
            sticky = true,  -- Faz a janela aparecer em todos os workspaces/tags
            skip_taskbar = true,  -- Remove da barra de tarefas e do Alt+Tab
            maximized_horizontal = true,  -- Maximiza horizontalmente (ocupa toda a largura da tela)
            hidden = false,  -- Garante que a janela não inicie minimizada/escondida
            placement = awful.placement.top  -- Posiciona automaticamente no topo da tela
            -- Nota: O awful.placement.top pode ser ajustado com parâmetros:
            -- awful.placement.top + awful.placement.maximize_horizontally
        }
    },

    -- XTerm rules
    {
        rule = { class = "XTerm" },
        properties = { size_hints_honor = false },
    },

    -- Força o Transmission a abrir na tag X (10)
    { 
		rule = { class = "transmission-gtk", instance = "transmission-gtk" },
		properties = { tag = "X" } 
	},

    -- Força o Transmission a abrir na tag X (10)
    { 
		rule = { class = "64gram-desktop", class = "64Gram"},
		properties = { tag = "X" } 
	},

    -- SMPlayer rules
    { 
		rule = { class = "smplayer", instance = "smplayer" },
		properties = { maximized = false, size_hints_honor = false, placement = awful.placement.centered } 
	},

    -- Nautilus rules
	{ 
		rule = { class = "org.gnome.Nautilus", instance = "org.gnome.Nautilus" },
		properties = { maximized = false, placement = awful.placement.centered } 
	},

	-- Regra para o Polybar
	{
		rule = { class = "polybar", instance = "Polybar" },  -- Verifique a classe exata com 'xprop'
		properties = {
			skip_taskbar = true,  -- Impede que apareça no Alt+Tab
			floating = true,      -- Geralmente é uma boa prática para painéis
			ontop = true,         -- Mantém o painel sempre visível
			border_width = 0,     -- Remove a borda, se desejar [citation:2]
			sticky = true,        -- Aparece em todas as tags/workspaces
		}
	},
	
	-- Regra para o Tint2
	{
		rule = { class = "tint2", instance = "Tint2" },  -- Verifique a classe exata com 'xprop'
		properties = {
			skip_taskbar = true,  -- Impede que apareça no Alt+Tab
			floating = true,      -- Geralmente é uma boa prática para painéis
			ontop = true,         -- Mantém o painel sempre visível
			border_width = 0,     -- Remove a borda, se desejar [citation:2]
			sticky = true,        -- Aparece em todas as tags/workspaces
		}
	},
}