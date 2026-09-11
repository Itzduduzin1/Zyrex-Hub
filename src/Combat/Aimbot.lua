local Aimbot = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Characters = workspace:WaitForChild("Characters")

local settings = {
    enabled = false,
    fov = 150,
    color = Color3.fromRGB(128, 0, 255),
    wallCheck = true
}

local running = false
local target = nil
local connection = nil

local circle

--==================================================
-- FOV
--==================================================

local function createFOV()
    if circle then
        return
    end

    circle = Drawing.new("Circle")

    circle.Radius = settings.fov
    circle.Thickness = 2
    circle.Filled = false
    circle.Color = settings.color
    circle.Visible = false
end

local function updateFOV()
    if not circle then
        return
    end

    Camera = workspace.CurrentCamera

    if not Camera then
        return
    end

    circle.Radius = settings.fov
    circle.Color = settings.color

    circle.Position = Vector2.new(
        Camera.ViewportSize.X / 2,
        Camera.ViewportSize.Y / 2
    )

    circle.Visible = settings.enabled
end

--==================================================
-- INIMIGO
--==================================================

local function isEnemyAlive(character)

    local targetPlayer =
        Players:GetPlayerFromCharacter(character)

    if not targetPlayer then
        return false
    end

    if targetPlayer == LocalPlayer then
        return false
    end

    local myTeam =
        LocalPlayer:GetAttribute("Team")

    local targetTeam =
        targetPlayer:GetAttribute("Team")

    local dead =
        targetPlayer:GetAttribute("Dead")

    if myTeam == nil or targetTeam == nil then
        return false
    end

    if dead == nil then
        return false
    end

    return myTeam ~= targetTeam and dead == false
end

--==================================================
-- WALL CHECK
--==================================================

local function wallCheck(character)

    if not settings.wallCheck then
        return true
    end

    local root =
        character:FindFirstChild("HumanoidRootPart")

    if not root then
        return false
    end

    Camera = workspace.CurrentCamera

    if not Camera then
        return false
    end

    local origin =
        Camera.CFrame.Position

    local direction =
        root.Position - origin

    local params =
        RaycastParams.new()

    params.FilterType =
        Enum.RaycastFilterType.Exclude

    params.FilterDescendantsInstances = {
        LocalPlayer.Character
    }

    local result =
        workspace:Raycast(
            origin,
            direction,
            params
        )

    if not result then
        return true
    end

    return result.Instance:IsDescendantOf(character)
end

--==================================================
-- TARGET
--==================================================

local function getTarget()

    Camera = workspace.CurrentCamera

    if not Camera then
        return nil
    end

    local closestCharacter
    local closestDistance = math.huge

    local center = Vector2.new(
        Camera.ViewportSize.X / 2,
        Camera.ViewportSize.Y / 2
    )

    for _, character in ipairs(
        Characters:GetChildren()
    ) do

        if isEnemyAlive(character) then

            local root =
                character:FindFirstChild(
                    "HumanoidRootPart"
                )

            if root then

                local screenPosition, onScreen =
                    Camera:WorldToViewportPoint(
                        root.Position
                    )

                if onScreen then

                    local screenPoint =
                        Vector2.new(
                            screenPosition.X,
                            screenPosition.Y
                        )

                    local distance =
                        (screenPoint - center).Magnitude

                    if distance <= settings.fov
                    and distance < closestDistance
                    and wallCheck(character) then

                        closestDistance = distance
                        closestCharacter = character

                    end
                end
            end
        end
    end

    return closestCharacter
end

--==================================================
-- AIM
--==================================================

local function aimAt(character)

    if not character then
        return
    end

    local targetPart =
        character:FindFirstChild("Head")

    if not targetPart then
        return
    end

    Camera = workspace.CurrentCamera

    if not Camera then
        return
    end

    Camera.CFrame = CFrame.lookAt(
        Camera.CFrame.Position,
        targetPart.Position
    )
end

--==================================================
-- SETTINGS
--==================================================

function Aimbot:SetSetting(key, value)

    if settings[key] == nil then
        return
    end

    settings[key] = value

    if key == "fov" or key == "color" then
        updateFOV()
    end

end

function Aimbot:GetSetting(key)
    return settings[key]
end

--==================================================
-- STATUS
--==================================================

function Aimbot:IsEnabled()
    return settings.enabled
end

--==================================================
-- INIT
--==================================================

function Aimbot:Init()

    if running then
        return
    end

    running = true

    createFOV()

    connection = RunService.RenderStepped:Connect(
        function()

            updateFOV()

            if not settings.enabled then
                target = nil
                return
            end

            target = getTarget()

            if target then
                aimAt(target)
            end

        end
    )

end

--==================================================
-- DESTROY
--==================================================

function Aimbot:Destroy()

    running = false

    if connection then
        connection:Disconnect()
        connection = nil
    end

    target = nil

    if circle then
        circle:Remove()
        circle = nil
    end

end

return Aimbot
