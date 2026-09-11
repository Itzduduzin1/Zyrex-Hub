--==================================================
-- ZYREX HUB - KEY SYSTEM
--==================================================

local SCRIPT_KEY = "ZYREX-2026"

local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/RegularVynixu/UI-Libraries/main/Venyx/Source.lua"
))()

local Venyx = Library.new(
    "Zyrex Hub",
    5013109572
)

--==================================================
-- KEY PAGE
--==================================================

local KeyPage = Venyx:addPage(
    "Key System",
    5012544693
)

local KeySection = KeyPage:addSection(
    "Acesso"
)

local enteredKey = ""
local unlocked = false

KeySection:addTextbox(
    "Digite sua Key",
    "",
    function(value)
        enteredKey = value
    end
)

KeySection:addButton(
    "Liberar",
    function()

        if enteredKey == SCRIPT_KEY then

            unlocked = true

            Venyx:Notify(
                "Zyrex Hub",
                "Key válida! Script liberado."
            )

            -- Aqui você libera/carrega as páginas
            -- do seu Hub.

        else

            Venyx:Notify(
                "Zyrex Hub",
                "Key inválida."
            )

        end

    end
)

--==================================================
-- SELECT KEY PAGE
--==================================================

Venyx:SelectPage(
    KeyPage,
    true
)
