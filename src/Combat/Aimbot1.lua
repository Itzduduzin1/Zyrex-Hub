--[[
    Zyrex Hub - Aimbot1.lua
    Versão compatível com:
        Aimbot:Init()
        Aimbot:SetSetting(name, value)
        Aimbot:GetSetting(name)
        Aimbot:IsEnabled()
        Aimbot:Destroy()

    IMPORTANTE:
    - Não modifica CurrentCamera.CFrame
    - Não altera AIM_ASSIST_WHITELIST
    - Não modifica Constants
    - Não tenta contornar o sistema de segurança do jogo
]]

local Aimbot = {}

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

--// Settings
local Settings = {
    enabled = false,

    fov = 150,
    color = Color3.fromRGB(128, 0, 255),
    thickness = 1.5,

    wallCheck = true,

    targetPart = "Head",
    maxDistance = 125,

    teamCheck = true,

    showFOV = true,
    debug = false,
}

--// Runtime
local Connection = nil
local FOVCircle = nil
local CurrentTarget = nil

--========================================================
-- Helpers
--========================================================

local function getCamera()
    return Workspace.CurrentCamera
end

local function getCharactersFolder()
    return Workspace:FindFirstChild("Characters")
end

local function getCharacter(player)
    if not player then
        return nil
    end

    local characters = getCharactersFolder()

    if characters then
        local character = characters:FindFirstChild(player.Name)

        if character then
            return character
        end
    end

    return player.Character
end

local function getHumanoid(character)
    if not character then
        return nil
    end

    return character:FindFirstChildOfClass("Humanoid")
end

local function isAlive(character)
    local humanoid = getHumanoid(character)

    if not humanoid then
        return false
    end

    if humanoid.Health <= 0 then
        return false
    end

    return true
end

local function getTargetPart(character)
    if not character then
        return nil
    end

    local part = character:FindFirstChild(Settings.targetPart)

    if part and part:IsA("BasePart") then
        return part
    end

    local fallback = character:FindFirstChild("Head")

    if fallback and fallback:IsA("BasePart") then
        return fallback
    end

    return character:FindFirstChild("HumanoidRootPart")
end

--========================================================
-- Team check
--========================================================

local function isSameTeam(player)
    if not Settings.teamCheck then
        return false
    end

    if not LocalPlayer then
        return false
    end

    -- Team padrão do Roblox
    if LocalPlayer.Team ~= nil and player.Team ~= nil then
        return LocalPlayer.Team == player.Team
    end

    -- Alguns jogos usam atributos
    local localCharacter = getCharacter(LocalPlayer)
    local enemyCharacter = getCharacter(player)

    if localCharacter and enemyCharacter then
        local localTeam =
            localCharacter:GetAttribute("Team")
            or localCharacter:GetAttribute("TeamName")

        local enemyTeam =
            enemyCharacter:GetAttribute("Team")
            or enemyCharacter:GetAttribute("TeamName")

        if localTeam ~= nil and enemyTeam ~= nil then
            return localTeam == enemyTeam
        end
    end

    return false
end

--========================================================
-- Wall Check
--========================================================

local function canSee(part)
    if not Settings.wallCheck then
        return true
    end

    local camera = getCamera()

    if not camera or not part then
        return false
    end

    local origin = camera.CFrame.Position
    local direction = part.Position - origin

    local params = RaycastParams.new()

    params.FilterType = Enum.RaycastFilterType.Exclude
    params.IgnoreWater = true

    local filter = {}

    if LocalPlayer.Character then
        table.insert(filter, LocalPlayer.Character)
    end

    local characters = getCharactersFolder()

    if characters then
        table.insert(filter, characters)
    end

    params.FilterDescendantsInstances = filter

    local result = Workspace:Raycast(
        origin,
        direction,
        params
    )

    if not result then
        return true
    end

    if result.Instance:IsDescendantOf(part.Parent) then
        return true
    end

    return false
end

--========================================================
-- Screen distance
--========================================================

local function getScreenDistance(position)
    local camera = getCamera()

    if not camera then
        return math.huge
    end

    local viewportPosition, visible =
        camera:WorldToViewportPoint(position)

    if not visible then
        return math.huge
    end

    local viewport = camera.ViewportSize

    local center = Vector2.new(
        viewport.X / 2,
        viewport.Y / 2
    )

    local screenPosition = Vector2.new(
        viewportPosition.X,
        viewportPosition.Y
    )

    return (screenPosition - center).Magnitude
end

--========================================================
-- Target selection
--========================================================

function Aimbot:GetBestTarget()
    local bestPlayer = nil
    local bestPart = nil
    local bestDistance = math.huge

    local camera = getCamera()

    if not camera then
        return nil
    end

    local localCharacter = getCharacter(LocalPlayer)

    if not localCharacter then
        return nil
    end

    local localRoot =
        localCharacter:FindFirstChild("HumanoidRootPart")

    if not localRoot then
        return nil
    end

    for _, player in ipairs(Players:GetPlayers()) do

        if player ~= LocalPlayer then

            local character = getCharacter(player)

            if character and isAlive(character) then

                if not isSameTeam(player) then

                    local part = getTargetPart(character)

                    if part then

                        local distance =
                            (part.Position - localRoot.Position).Magnitude

                        if distance <= Settings.maxDistance then

                            local screenDistance =
                                getScreenDistance(part.Position)

                            if screenDistance <= Settings.fov then

                                if canSee(part) then

                                    if screenDistance < bestDistance then
                                        bestDistance = screenDistance
                                        bestPlayer = player
                                        bestPart = part
                                    end

                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return bestPlayer, bestPart, bestDistance
end

--========================================================
-- FOV Drawing
--========================================================

local function createFOV()
    if FOVCircle then
        return
    end

    if typeof(Drawing) ~= "table" and typeof(Drawing) ~= "userdata" then
        return
    end

    local success, circle = pcall(function()
        return Drawing.new("Circle")
    end)

    if not success or not circle then
        return
    end

    FOVCircle = circle

    FOVCircle.Visible = false
    FOVCircle.Filled = false
    FOVCircle.Thickness = Settings.thickness
    FOVCircle.NumSides = 64
    FOVCircle.Radius = Settings.fov
    FOVCircle.Color = Settings.color
    FOVCircle.Transparency = 1
end

local function updateFOV()
    if not FOVCircle then
        return
    end

    local camera = getCamera()

    if not camera then
        FOVCircle.Visible = false
        return
    end

    local viewport = camera.ViewportSize

    FOVCircle.Position = Vector2.new(
        viewport.X / 2,
        viewport.Y / 2
    )

    FOVCircle.Radius = Settings.fov
    FOVCircle.Color = Settings.color
    FOVCircle.Thickness = Settings.thickness

    FOVCircle.Visible =
        Settings.showFOV and Settings.enabled
end

--========================================================
-- Debug
--========================================================

local function debugTarget(player, part, distance)
    if not Settings.debug then
        return
    end

    if player and part then
        print(
            string.format(
                "[Zyrex Aimbot] alvo=%s parte=%s distanciaFOV=%.1f",
                player.Name,
                part.Name,
                distance or 0
            )
        )
    else
        print("[Zyrex Aimbot] nenhum alvo")
    end
end

--========================================================
-- Update
--========================================================

local function update()
    updateFOV()

    if not Settings.enabled then
        CurrentTarget = nil
        return
    end

    local player, part, distance =
        Aimbot:GetBestTarget()

    CurrentTarget = player

    debugTarget(
        player,
        part,
        distance
    )

    -- Intencionalmente não altera CurrentCamera.CFrame.
    --
    -- O CameraController do jogo sobrescreve a câmera
    -- no RenderStep e possui proteção contra alterações
    -- externas.
end

--========================================================
-- Public API
--========================================================

function Aimbot:Init()

    if Connection then
        return
    end

    createFOV()

    Connection = RunService.RenderStepped:Connect(function()
        local success, err = pcall(update)

        if not success then
            warn(
                "[Zyrex Aimbot] Erro no update:",
                err
            )
        end
    end)

    print("[Zyrex Aimbot] Inicializado")
end

function Aimbot:SetSetting(name, value)

    if Settings[name] == nil then
        warn(
            "[Zyrex Aimbot] Configuração inexistente:",
            name
        )

        return
    end

    Settings[name] = value

    if name == "fov" then
        Settings.fov = math.clamp(
            tonumber(value) or 150,
            1,
            1000
        )
    end

    if name == "thickness" then
        Settings.thickness = math.clamp(
            tonumber(value) or 1.5,
            0.1,
            10
        )
    end

    if name == "maxDistance" then
        Settings.maxDistance = math.max(
            tonumber(value) or 125,
            1
        )
    end

    if name == "enabled" then
        Settings.enabled = value == true
    end

    if name == "showFOV" then
        Settings.showFOV = value == true
    end

    if name == "wallCheck" then
        Settings.wallCheck = value == true
    end

    if name == "teamCheck" then
        Settings.teamCheck = value == true
    end

    if name == "debug" then
        Settings.debug = value == true
    end

    if name == "color" then
        if typeof(value) == "Color3" then
            Settings.color = value
        end
    end

    updateFOV()
end

function Aimbot:GetSetting(name)
    return Settings[name]
end

function Aimbot:IsEnabled()
    return Settings.enabled
end

function Aimbot:GetCurrentTarget()
    return CurrentTarget
end

function Aimbot:Destroy()

    if Connection then
        Connection:Disconnect()
        Connection = nil
    end

    CurrentTarget = nil

    if FOVCircle then
        pcall(function()
            FOVCircle.Visible = false
            FOVCircle:Remove()
        end)

        FOVCircle = nil
    end

    print("[Zyrex Aimbot] Destruído")
end

--========================================================
-- Return obrigatório
--========================================================

return Aimbot
