--==================================================
-- ZYREX HUB - MAIN
--==================================================

local BASE_URL =
    "https://raw.githubusercontent.com/Itzduduzin1/Zyrex-Hub/refs/heads/main/"

--==================================================
-- LOAD MODULE
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
-- VISION / VISUAL MODULES
--==================================================

local ESP = loadModule("src/Visual/Esp.lua")
local Weapon = loadModule("src/Visual/Weapon.lua")
local WorldEffects = loadModule("src/Visual/WorldEffects.lua")

--==================================================
-- UI
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

local VisualPage = Venyx:addPage(
    "Visual",
    5012544693
)

local CombatPage = Venyx:addPage(
    "Combat",
    5012544693
)

--==================================================
-- ESP
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
            if Weapon.SetSetting then
                Weapon:SetSetting(
                    "enabled",
                    value
                )
            end
        end
    )

    WeaponSection:addColorPicker(
        "Weapon Color",
        Color3.fromRGB(85, 0, 255),
        function(color)
            if Weapon.SetSetting then
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

--==================================================
-- OPEN UI
--==================================================

Venyx:SelectPage(
    Venyx.pages[1],
    true
)

Venyx:Notify(
    "Zyrex Hub",
    "Carregado com sucesso!"
)

print("[Zyrex Hub] Main carregado.")
