-- =========================================
-- Venyx
-- =========================================

local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/RegularVynixu/UI-Libraries/main/Venyx/Source.lua"
))()

local Venyx = Library.new("BloxStrike", 5013109572)

-- =========================================
-- Carregar módulos
-- =========================================

local ESP = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Itzduduzin1/Zyrex-Hub/refs/heads/main/src/Visual/Esp.lua"
))()

loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Itzduduzin1/Zyrex-Hub/refs/heads/main/src/Visual/Weapon.lua"
))()

ESP:Init()

-- =========================================
-- Página Visual
-- =========================================

local VisualPage = Venyx:addPage("Visual", 5012544693)

local ESPSection = VisualPage:addSection("ESP")

-- Toggle
ESPSection:addToggle("ESP", false, function(value)
    ESP:SetEnabled(value)
end)

-- Keybind configurável
ESPSection:addKeybind(
    "ESP Keybind",
    Enum.KeyCode.E,

    function()
        ESP:SetEnabled(not ESP:IsEnabled())
    end,

    function()
        print("Tecla do ESP alterada")
    end
)

-- =========================================
-- Tema
-- =========================================

local ThemePage = Venyx:addPage("Theme", 5012544693)
local Colors = ThemePage:addSection("Colors")

local Themes = {
    Background = Color3.fromRGB(24, 24, 24),
    Glow = Color3.fromRGB(0, 0, 0),
    Accent = Color3.fromRGB(10, 10, 10),
    LightContrast = Color3.fromRGB(20, 20, 20),
    DarkContrast = Color3.fromRGB(14, 14, 14),
    TextColor = Color3.fromRGB(255, 255, 255)
}

for name, color in pairs(Themes) do
    Colors:addColorPicker(name, color, function(newColor)
        Venyx:setTheme(name, newColor)
    end)
end

-- =========================================
-- Abrir
-- =========================================

Venyx:SelectPage(Venyx.pages[1], true)
