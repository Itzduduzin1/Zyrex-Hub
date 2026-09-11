--==================================================
-- ZYREX HUB
--==================================================

local SCRIPT_KEY = "ZYREX-2026"

local BASE_URL =
    "https://raw.githubusercontent.com/Itzduduzin1/Zyrex-Hub/refs/heads/main/"

--==================================================
-- LOADER
--==================================================

local function loadModule(path)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(BASE_URL .. path))()
    end)

    if not success then
        warn("[Zyrex Hub] Falha ao carregar: " .. path)
        warn(result)
        return nil
    end

    return result
end

--==================================================
-- VENYX
--==================================================

local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/RegularVynixu/UI-Libraries/main/Venyx/Source.lua"
))()

local Venyx = Library.new(
    "Zyrex Hub",
    5013109572
)

--==================================================
-- KEY SYSTEM
--==================================================

local KeyPage = Venyx:addPage(
    "Key System",
    5012544693
)

local KeySection = KeyPage:addSection(
    "Acesso"
)

local enteredKey = ""

KeySection:addTextbox(
    "Digite sua Key",
    "",
    function(value)
        enteredKey = value
    end
)

--==================================================
-- LOAD HUB
--==================================================

local function LoadHub()

    --==============================================
    -- MODULES
    --==============================================

    local ESP = loadModule("src/Visual/Esp.lua")
    local Weapon = loadModule("src/Visual/Weapon.lua")
    local WorldEffects = loadModule("src/Visual/WorldEffects.lua")

    --==============================================
    -- INIT
    --==============================================

    if ESP and ESP.Init then
        ESP:Init()
    end

    if Weapon and Weapon.Init then
        Weapon:Init()
    end

    if WorldEffects and WorldEffects.Init then
        WorldEffects:Init()
    end

    --==============================================
    -- PAGES
    --==============================================

    local VisualPage = Venyx:addPage(
        "Visual",
        5012544693
    )

    local CombatPage = Venyx:addPage(
        "Combat",
        5012544693
    )

    --==============================================
    -- VISUAL
    --==============================================

    local ESPSection = VisualPage:addSection("ESP")

    if ESP then

        ESPSection:addToggle(
            "ESP",
            false,
            function(value)
                if ESP.SetEnabled then
                    ESP:SetEnabled(value)
                end
            end
        )

        ESPSection:addKeybind(
            "ESP Keybind",
            Enum.KeyCode.E,
            function()
                if ESP.IsEnabled and ESP.SetEnabled then
                    ESP:SetEnabled(
                        not ESP:IsEnabled()
                    )
                end
            end
        )

    end

    --==============================================
    -- WEAPON
    --==============================================

    local WeaponSection = VisualPage:addSection(
        "Weapon"
    )

    if Weapon then

        WeaponSection:addToggle(
            "Weapon",
            false,
            function(value)
                Weapon:SetSetting(
                    "enabled",
                    value
                )
            end
        )

        WeaponSection:addKeybind(
            "Weapon Keybind",
            Enum.KeyCode.X,
            function()
                local current =
                    Weapon:GetSetting("enabled")

                Weapon:SetSetting(
                    "enabled",
                    not current
                )
            end
        )

        WeaponSection:addColorPicker(
            "Weapon Color",
            Color3.fromRGB(85, 0, 255),
            function(color)
                Weapon:SetSetting(
                    "color",
                    color
                )
            end
        )

    end

    --==============================================
    -- WORLD EFFECTS
    --==============================================

    local WorldSection = VisualPage:addSection(
        "World Effects"
    )

    if WorldEffects then

        WorldSection:addToggle(
            "Anti Flash",
            false,
            function(value)
                WorldEffects:SetSetting(
                    "antiFlash",
                    value
                )
            end
        )

        WorldSection:addToggle(
            "Anti Smoke",
            false,
            function(value)
                WorldEffects:SetSetting(
                    "antiSmoke",
                    value
                )
            end
        )

    end

    --==============================================
    -- COMBAT
    --==============================================

    local CombatSection = CombatPage:addSection(
        "Combat"
    )

    -- Coloque aqui seus módulos de Combat.
    -- Exemplo:
    --
    -- local Aimbot = loadModule("src/Combat/Aimbot.lua")
    -- etc.

    --==============================================
    -- SELECT VISUAL
    --==============================================

    Venyx:SelectPage(
        VisualPage,
        true
    )

    Venyx:Notify(
        "Zyrex Hub",
        "Hub liberado!"
    )

end

--==================================================
-- LIBERAR
--==================================================

KeySection:addButton(
    "Liberar",
    function()

        if enteredKey == SCRIPT_KEY then

            Venyx:Notify(
                "Zyrex Hub",
                "Key válida!"
            )

            task.wait(0.5)

            LoadHub()

            -- Vai para a página Visual
            -- depois que ela for criada.

        else

            Venyx:Notify(
                "Zyrex Hub",
                "Key inválida!"
            )

        end

    end
)

--==================================================
-- START
--==================================================

Venyx:SelectPage(
    KeyPage,
    true
)

print("[Zyrex Hub] Key System carregado.")
