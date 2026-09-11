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
-- PAGES
--==================================================

local KeyPage = Venyx:addPage(
    "Key System",
    5012544693
)

local VisualPage = Venyx:addPage(
    "Visual",
    5012544693
)

local CombatPage = Venyx:addPage(
    "Combat",
    5012544693
)

--==================================================
-- KEY SYSTEM
--==================================================

local KeySection = KeyPage:addSection("Acesso")

local enteredKey = ""
local unlocked = false

KeySection:addTextbox(
    "Digite sua Key",
    "",
    function(value)
        enteredKey = tostring(value):gsub("^%s*(.-)%s*$", "%1")
    end
)

--==================================================
-- VISUAL MODULES
--==================================================

local ESP = loadModule("src/Visual/Esp.lua")
local Weapon = loadModule("src/Visual/Weapon.lua")
local WorldEffects = loadModule("src/Visual/WorldEffects.lua")

--==================================================
-- VISUAL
--==================================================

local ESPSection = VisualPage:addSection("ESP")

if ESP then

    if ESP.Init then
        ESP:Init()
    end

    ESPSection:addToggle(
        "ESP",
        false,
        function(value)
            if unlocked and ESP.SetEnabled then
                ESP:SetEnabled(value)
            end
        end
    )

    ESPSection:addKeybind(
        "ESP Keybind",
        Enum.KeyCode.E,
        function()
            if unlocked
                and ESP.IsEnabled
                and ESP.SetEnabled then

                ESP:SetEnabled(
                    not ESP:IsEnabled()
                )
            end
        end
    )

end

--==================================================
-- WEAPON
--==================================================

local WeaponSection = VisualPage:addSection("Weapon")

if Weapon then

    if Weapon.Init then
        Weapon:Init()
    end

    WeaponSection:addToggle(
        "Weapon",
        false,
        function(value)
            if unlocked then
                Weapon:SetSetting(
                    "enabled",
                    value
                )
            end
        end
    )

    WeaponSection:addKeybind(
        "Weapon Keybind",
        Enum.KeyCode.X,
        function()
            if unlocked then

                local current =
                    Weapon:GetSetting("enabled")

                Weapon:SetSetting(
                    "enabled",
                    not current
                )

            end
        end
    )

    WeaponSection:addColorPicker(
        "Weapon Color",
        Color3.fromRGB(85, 0, 255),
        function(color)
            if unlocked then
                Weapon:SetSetting(
                    "color",
                    color
                )
            end
        end
    )

end

--==================================================
-- WORLD EFFECTS
--==================================================

local WorldSection = VisualPage:addSection(
    "World Effects"
)

if WorldEffects then

    if WorldEffects.Init then
        WorldEffects:Init()
    end

    WorldSection:addToggle(
        "Anti Flash",
        false,
        function(value)
            if unlocked then
                WorldEffects:SetSetting(
                    "antiFlash",
                    value
                )
            end
        end
    )

    WorldSection:addToggle(
        "Anti Smoke",
        false,
        function(value)
            if unlocked then
                WorldEffects:SetSetting(
                    "antiSmoke",
                    value
                )
            end
        end
    )

end

--==================================================
-- COMBAT
--==================================================

local CombatSection = CombatPage:addSection(
    "Combat"
)

--==================================================
-- LIBERAR
--==================================================

KeySection:addButton(
    "Liberar",
    function()

        local key = enteredKey

        if key == SCRIPT_KEY then

            unlocked = true

            Venyx:Notify(
                "Zyrex Hub",
                "Key válida! Acesso liberado."
            )

            task.wait(0.3)

            -- Vai para Visual
            Venyx:SelectPage(
                VisualPage,
                true
            )

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
