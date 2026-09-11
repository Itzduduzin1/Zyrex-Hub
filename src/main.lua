local SCRIPT_KEY = "zyrex"

local BASE_URL =
    "https://raw.githubusercontent.com/Itzduduzin1/Zyrex-Hub/refs/heads/main/"

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
-- VENYX - KEY
--==================================================

local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/RegularVynixu/UI-Libraries/main/Venyx/Source.lua"
))()

local Venyx = Library.new(
    "Zyrex Hub",
    5013109572
)

local KeyPage = Venyx:addPage(
    "Key System",
    5012544693
)

local KeySection = KeyPage:addSection("Acesso")

local enteredKey = ""

KeySection:addTextbox(
    "Digite sua Key",
    "",
    function(value)
        enteredKey = tostring(value):gsub("^%s*(.-)%s*$", "%1")
    end
)

local function RemoveKeyPage()
    -- Remove o botão da lateral
    if KeyPage.button then
        KeyPage.button:Destroy()
    end

    -- Remove o conteúdo da página
    if KeyPage.container then
        KeyPage.container:Destroy()
    end

    -- Remove a página da lista interna do Venyx
    for i, page in ipairs(Venyx.pages) do
        if page == KeyPage then
            table.remove(Venyx.pages, i)
            break
        end
    end

    -- Impede que ela continue sendo considerada a página selecionada
    if Venyx.focusedPage == KeyPage then
        Venyx.focusedPage = nil
    end

    print("[Zyrex Hub] Key System removido.")
end

--==================================================
-- HUB
--==================================================

local function OpenHub()

    local VisualPage = Venyx:addPage(
        "Visual",
        5012544693
    )

    local CombatPage = Venyx:addPage(
        "Combat",
        5012544693
    )

    --==============================
    -- MODULES
    --==============================

    local ESP = loadModule("src/Visual/Esp.lua")
    local Weapon = loadModule("src/Visual/Weapon.lua")
    local WorldEffects = loadModule("src/Visual/WorldEffects.lua")

    if ESP and ESP.Init then
        ESP:Init()
    end

    if Weapon and Weapon.Init then
        Weapon:Init()
    end

    if WorldEffects and WorldEffects.Init then
        WorldEffects:Init()
    end

    --==============================
    -- ESP
    --==============================

    local ESPSection = VisualPage:addSection("ESP")

    if ESP then

        ESPSection:addToggle(
            "ESP",
            false,
            function(value)
                ESP:SetEnabled(value)
            end
        )

        ESPSection:addKeybind(
            "ESP Keybind",
            Enum.KeyCode.E,
            function()
                if ESP.IsEnabled then
                    ESP:SetEnabled(
                        not ESP:IsEnabled()
                    )
                end
            end
        )

    end

    --==============================
    -- WEAPON
    --==============================

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

    --==============================
    -- WORLD
    --==============================

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

    --==============================
    -- COMBAT
    --==============================

    local CombatSection = CombatPage:addSection(
        "Combat"
    )

    -- Seus módulos de Combat entram aqui.

    Venyx:Notify(
    "Zyrex Hub",
    "Acesso liberado!"
)

task.wait(0.2)

-- Vai para Visual primeiro
Venyx:SelectPage(
    VisualPage,
    true
)

task.wait(0.1)

-- Exclui completamente a Key System da interface
RemoveKeyPage()
end

--==================================================
-- BUTTON
--==================================================

KeySection:addButton(
    "Liberar",
    function()

        if enteredKey == SCRIPT_KEY then

            OpenHub()

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

print("[Zyrex Hub] Aguardando Key...")
