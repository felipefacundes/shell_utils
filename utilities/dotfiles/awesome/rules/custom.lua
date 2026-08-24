local awful = require("awful")

-- Use o comando: 
-- xprop | grep WM_CLASS  ou  wmctrl -lx
-- Para identificar a classe da janela

awful.rules.rules = {
    -- ... Other rules ...

    -- Por enquanto aqui não tem regras
    -- E lá em rc.lua require("rules.custom") está comentado.

    -- ... Other rules ...
}
