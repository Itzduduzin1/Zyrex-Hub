--// Zyrex Hub - Aimbot1
--// Integração com o AimAssistController nativo do jogo
--// Não sobrescreve CurrentCamera.CFrame

local Aimbot = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local AimAssistController = require(
    ReplicatedStorage.Controllers.AimAssistController
)

local CharacterResolver = require(
    ReplicatedStorage.Components.Common.CharacterResolver
)

local Settings = {
    Enabled = false,

    -- Visual
    ShowFOV = true,
    FOV = 150,
    FOVThickness = 1.5,

    -- Target
    TargetPart = "Head",
    MaxDistance = 1000,

    -- Interface
    UseNativeAimAssist = true,

    -- Debug
    Debug = false
}

local FOVCircle
local RenderConnection
local Destroyed = false


--========================================================--
-- UTIL
--========================================================--

local function debugPrint(...)
    if Settings.Debug then
        print("[Zyrex Aimbot]", ...)
    end
end


local function getCamera()
    Camera = Workspace.CurrentCamera
    return Camera
end


local function getLocalCharacter()
    local character

    pcall(function()
        character = CharacterResolver.getLocalCharacter()
    end)

    if character then
        return character
    end

    return LocalPlayer.Character
end


local function getTargetPart(character)
    if not character then
        return nil
    end

    return character:FindFirstChild(Settings.TargetPart)
        or character:FindFirstChild("Head")
        or character.PrimaryPart
end


--========================================================--
-- FOV
--========================================================--

local function createFOV()
    if FOVCircle then
        return
    end

    if not Drawing then
        debugPrint("Drawing API não disponível.")
        return
    end

    FOVCircle = Drawing.new("Circle")

    FOVCircle.Visible = Settings.ShowFOV
    FOVCircle.Radius = Settings.FOV
    FOVCircle.Thickness = Settings.FOVThickness
    FOVCircle.Filled = false
    FOVCircle.Transparency = 1

    -- Roxo do Zyrex
    FOVCircle.Color = Color3.fromRGB(128, 0, 255)
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

    FOVCircle.Radius = Settings.FOV
    FOVCircle.Thickness = Settings.FOVThickness
    FOVCircle.Visible = Settings.ShowFOV and Settings.Enabled
end


--========================================================--
-- TARGET
--========================================================--

function Aimbot:GetBestTarget()
    if not Settings.Enabled then
        return nil
    end

    local target

    pcall(function()
        target = AimAssistController.GetBestTarget()
    end)

    if not target then
        return nil
    end

    local part = getTargetPart(target)

    if not part then
        return nil
    end

    local camera = getCamera()

    if not camera then
        return nil
    end

    local distance = (part.Position - camera.CFrame.Position).Magnitude

    if distance > Settings.MaxDistance then
        return nil
    end

    return target, part
end


--========================================================--
-- AIM ASSIST NATIVO
--========================================================--

local function enableNativeAimAssist()
    if not Settings.UseNativeAimAssist then
        return
    end

    local success, err = pcall(function()
        AimAssistController.SetEnabled(true)
    end)

    if success then
        debugPrint("AimAssistController ativado.")
    else
        warn("[Zyrex Aimbot] Falha ao ativar AimAssistController:", err)
    end
end


local function disableNativeAimAssist()
    pcall(function()
        AimAssistController.SetEnabled(false)
    end)

    debugPrint("AimAssistController desativado.")
end


--========================================================--
-- LOOP
--========================================================--

local function update()
    if Destroyed then
        return
    end

    updateFOV()

    if not Settings.Enabled then
        return
    end

    local target, part = Aimbot:GetBestTarget()

    if target and part then
        debugPrint(
            "Target:",
            target.Name,
            "Part:",
            part.Name
        )
    end
end


--========================================================--
-- API
--========================================================--

function Aimbot:SetEnabled(state)
    state = state == true

    Settings.Enabled = state

    if state then
        enableNativeAimAssist()
    else
        disableNativeAimAssist()
    end

    updateFOV()

    debugPrint("Enabled =", state)
end


function Aimbot:IsEnabled()
    return Settings.Enabled
end


function Aimbot:SetSetting(name, value)
    if Settings[name] == nil then
        warn("[Zyrex Aimbot] Setting inexistente:", name)
        return
    end

    Settings[name] = value

    if name == "FOV" then
        updateFOV()
    elseif name == "ShowFOV" then
        updateFOV()
    elseif name == "FOVThickness" then
        updateFOV()
    end
end


function Aimbot:GetSetting(name)
    return Settings[name]
end


function Aimbot:GetSettings()
    local copy = {}

    for key, value in pairs(Settings) do
        copy[key] = value
    end

    return copy
end


function Aimbot:GetTarget()
    local target, part = Aimbot:GetBestTarget()

    return target, part
end


function Aimbot:Destroy()
    if Destroyed then
        return
    end

    Destroyed = true

    Settings.Enabled = false

    disableNativeAimAssist()

    if RenderConnection then
        RenderConnection:Disconnect()
        RenderConnection = nil
    end

    if FOVCircle then
        pcall(function()
            FOVCircle:Remove()
        end)

        FOVCircle = nil
    end

    debugPrint("Aimbot destruído.")
end


--========================================================--
-- INIT
--========================================================--

createFOV()

RenderConnection = RunService.RenderStepped:Connect(update)

return Aimbot
