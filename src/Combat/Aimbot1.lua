local Aimbot = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Characters = workspace:WaitForChild("Characters")

local settings = {
    enabled = false,
    fov = 150,
    color = Color3.fromRGB(128, 0, 255),
    wallCheck = true
}

local running = false
local connection = nil
local circle = nil

--==================================================
-- CAMERA CFRAME
--==================================================

local function getCameraCFrame()
    local character = LocalPlayer.Character

    if not character then
        return nil
    end

    local cameraCFrame = character:GetAttribute("CameraCFrame")

    if typeof(cameraCFrame) == "CFrame" then
        return cameraCFrame
    end

    return nil
end

--==================================================
-- FOV
--==================================================

local function createFOV()

    if circle then
        return
    end

    local success, result = pcall(function()

        local drawing = Drawing.new("Circle")

        drawing.Radius = settings.fov
        drawing.Thickness = 2
        drawing.Filled = false
        drawing.Color = settings.color
        drawing.Transparency = 1
        drawing.Visible = false

        return drawing

    end)

    if success then
        circle = result
    else
        warn("[Aimbot] Drawing não disponível.")
        warn(result)
    end
end

local function updateFOV()

    if not circle then
        return
    end

    local Camera = workspace.CurrentCamera

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

local function isEnemy(character)

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

local function canSee(character)

    if not settings.wallCheck then
        return true
    end

    local root =
        character:FindFirstChild("HumanoidRootPart")

    if not root then
        return false
    end

    local cameraCFrame = getCameraCFrame()

    if not cameraCFrame then
        return false
    end

    local origin =
        cameraCFrame.Position

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

    local Camera = workspace.CurrentCamera

    if not Camera then
        return nil
    end

    local center = Vector2.new(
        Camera.ViewportSize.X / 2,
        Camera.ViewportSize.Y / 2
    )

    local closest = nil
    local closestDistance = math.huge

    for _, character in ipairs(
        Characters:GetChildren()
    ) do

        if isEnemy(character) then

            local head =
                character:FindFirstChild("Head")

            if head then

                local position, visible =
                    Camera:WorldToViewportPoint(
                        head.Position
                    )

                if visible then

                    local screenPosition =
                        Vector2.new(
                            position.X,
                            position.Y
                        )

                    local distance =
                        (screenPosition - center).Magnitude

                    if distance <= settings.fov
                    and distance < closestDistance
                    and canSee(character) then

                        closest = character
                        closestDistance = distance

                    end

                end
            end
        end
    end

    return closest
end

--==================================================
-- AIM
--==================================================

local function aim(character)

    if not character then
        return
    end

    local head =
        character:FindFirstChild("Head")

    if not head then
        return
    end

    local cameraCFrame = getCameraCFrame()

    if not cameraCFrame then
        return
    end

    local newCFrame =
        CFrame.lookAt(
            cameraCFrame.Position,
            head.Position
        )

    -- Atualiza o atributo CameraCFrame
    local localCharacter = LocalPlayer.Character

    if localCharacter then
        localCharacter:SetAttribute(
            "CameraCFrame",
            newCFrame
        )
    end

end

--==================================================
-- SETTINGS
--==================================================

function Aimbot:SetSetting(key, value)

    if settings[key] == nil then
        return
    end

    settings[key] = value

    if key == "fov" then
        updateFOV()
    end

    if key == "color" then
        updateFOV()
    end

end

function Aimbot:GetSetting(key)
    return settings[key]
end

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

    connection =
        RunService.RenderStepped:Connect(
            function()

                updateFOV()

                if not settings.enabled then
                    return
                end

                local target =
                    getTarget()

                if target then
                    aim(target)
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

    if circle then
        circle.Visible = false
        circle:Remove()
        circle = nil
    end

end

return Aimbot
