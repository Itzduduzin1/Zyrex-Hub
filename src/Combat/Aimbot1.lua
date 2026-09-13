local Aimbot = {}

--==================================================
-- SERVICES
--==================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Characters = workspace:WaitForChild("Characters")

--==================================================
-- SETTINGS
--==================================================

local settings = {
    enabled = false,

    fov = 150,

    color = Color3.fromRGB(
        128,
        0,
        255
    ),

    wallCheck = true,

    -- Parte que será utilizada como alvo
    targetPart = "Head",

    -- Distância máxima
    maxDistance = 2000,

    -- Se true, tenta usar o CameraCFrame
    useCharacterCamera = true,

    -- Suavização:
    -- 1 = instantâneo
    -- 0.1 = bem suave
    smoothness = 1
}

--==================================================
-- STATE
--==================================================

local running = false
local connection = nil
local circle = nil

--==================================================
-- LOCAL CHARACTER
--==================================================

local function getLocalCharacter()

    local character =
        Characters:FindFirstChild(
            LocalPlayer.Name
        )

    if character then
        return character
    end

    return LocalPlayer.Character
end

--==================================================
-- CAMERA CFRAME
--==================================================

local function getCameraCFrame()

    local character =
        getLocalCharacter()

    if settings.useCharacterCamera and character then

        local cameraCFrame =
            character:GetAttribute(
                "CameraCFrame"
            )

        if typeof(cameraCFrame) == "CFrame" then
            return cameraCFrame
        end
    end

    local Camera =
        workspace.CurrentCamera

    if Camera then
        return Camera.CFrame
    end

    return nil
end

--==================================================
-- CAMERA
--==================================================

local function getCamera()

    return workspace.CurrentCamera

end

--==================================================
-- FOV
--==================================================

local function createFOV()

    if circle then
        return
    end

    local success, result =
        pcall(function()

            local drawing =
                Drawing.new("Circle")

            drawing.Radius =
                settings.fov

            drawing.Thickness = 2

            drawing.Filled = false

            drawing.Color =
                settings.color

            drawing.Transparency = 1

            drawing.NumSides = 64

            drawing.Visible = false

            return drawing

        end)

    if success then

        circle = result

    else

        warn(
            "[Aimbot] Drawing não disponível."
        )

        warn(result)

    end
end

--==================================================
-- UPDATE FOV
--==================================================

local function updateFOV()

    if not circle then
        return
    end

    local Camera =
        getCamera()

    if not Camera then
        return
    end

    circle.Radius =
        settings.fov

    circle.Color =
        settings.color

    circle.Position =
        Vector2.new(
            Camera.ViewportSize.X / 2,
            Camera.ViewportSize.Y / 2
        )

    circle.Visible =
        settings.enabled

end

--==================================================
-- CHARACTER ALIVE
--==================================================

local function isAlive(character)

    if not character then
        return false
    end

    local player =
        Players:GetPlayerFromCharacter(
            character
        )

    if not player then
        return false
    end

    local dead =
        player:GetAttribute("Dead")

    if dead == true then
        return false
    end

    local humanoid =
        character:FindFirstChildOfClass(
            "Humanoid"
        )

    if humanoid then

        if humanoid.Health <= 0 then
            return false
        end

    end

    return true

end

--==================================================
-- ENEMY
--==================================================

local function isEnemy(character)

    if not character then
        return false
    end

    local targetPlayer =
        Players:GetPlayerFromCharacter(
            character
        )

    if not targetPlayer then
        return false
    end

    if targetPlayer == LocalPlayer then
        return false
    end

    local myTeam =
        LocalPlayer:GetAttribute(
            "Team"
        )

    local targetTeam =
        targetPlayer:GetAttribute(
            "Team"
        )

    if myTeam == nil
    or targetTeam == nil then

        return false

    end

    if myTeam == targetTeam then
        return false
    end

    return isAlive(character)

end

--==================================================
-- TARGET PART
--==================================================

local function getTargetPart(character)

    if not character then
        return nil
    end

    local preferred =
        character:FindFirstChild(
            settings.targetPart
        )

    if preferred then
        return preferred
    end

    local head =
        character:FindFirstChild("Head")

    if head then
        return head
    end

    return character:FindFirstChild(
        "HumanoidRootPart"
    )

end

--==================================================
-- WALL CHECK
--==================================================

local function canSee(character)

    if not settings.wallCheck then
        return true
    end

    local targetPart =
        getTargetPart(character)

    if not targetPart then
        return false
    end

    local cameraCFrame =
        getCameraCFrame()

    if not cameraCFrame then
        return false
    end

    local origin =
        cameraCFrame.Position

    local targetPosition =
        targetPart.Position

    local direction =
        targetPosition - origin

    if direction.Magnitude <= 0 then
        return true
    end

    local params =
        RaycastParams.new()

    params.FilterType =
        Enum.RaycastFilterType.Exclude

    local localCharacter =
        getLocalCharacter()

    params.FilterDescendantsInstances = {
        localCharacter
    }

    params.IgnoreWater = true

    local result =
        workspace:Raycast(
            origin,
            direction,
            params
        )

    if not result then
        return true
    end

    return result.Instance:IsDescendantOf(
        character
    )

end

--==================================================
-- SCREEN DISTANCE
--==================================================

local function getScreenDistance(
    Camera,
    position,
    center
)

    local screenPosition,
        visible =
        Camera:WorldToViewportPoint(
            position
        )

    if not visible then
        return nil
    end

    local point =
        Vector2.new(
            screenPosition.X,
            screenPosition.Y
        )

    return (
        point - center
    ).Magnitude

end

--==================================================
-- TARGET
--==================================================

local function getTarget()

    local Camera =
        getCamera()

    if not Camera then
        return nil
    end

    local cameraCFrame =
        getCameraCFrame()

    if not cameraCFrame then
        return nil
    end

    local center =
        Vector2.new(
            Camera.ViewportSize.X / 2,
            Camera.ViewportSize.Y / 2
        )

    local closest = nil

    local closestDistance =
        math.huge

    local cameraPosition =
        cameraCFrame.Position

    for _, character in ipairs(
        Characters:GetChildren()
    ) do

        if isEnemy(character) then

            local targetPart =
                getTargetPart(character)

            if targetPart then

                local distance3D =
                    (
                        targetPart.Position
                        - cameraPosition
                    ).Magnitude

                if distance3D <=
                    settings.maxDistance then

                    local screenDistance =
                        getScreenDistance(
                            Camera,
                            targetPart.Position,
                            center
                        )

                    if screenDistance then

                        if screenDistance <=
                            settings.fov then

                            if screenDistance <
                                closestDistance then

                                if canSee(
                                    character
                                ) then

                                    closest =
                                        character

                                    closestDistance =
                                        screenDistance

                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return closest

end

--==================================================
-- AIM CFRAME
--==================================================

local function getAimCFrame(
    character
)

    if not character then
        return nil
    end

    local targetPart =
        getTargetPart(character)

    if not targetPart then
        return nil
    end

    local cameraCFrame =
        getCameraCFrame()

    if not cameraCFrame then
        return nil
    end

    local position =
        cameraCFrame.Position

    return CFrame.lookAt(
        position,
        targetPart.Position
    )

end

--==================================================
-- APPLY AIM
--==================================================

local function aim(character)

    local desired =
        getAimCFrame(character)

    if not desired then
        return
    end

    local Camera =
        getCamera()

    if not Camera then
        return
    end

    local current =
        Camera.CFrame

    local alpha =
        math.clamp(
            settings.smoothness,
            0,
            1
        )

    local finalCFrame

    if alpha >= 1 then

        finalCFrame =
            desired

    else

        finalCFrame =
            current:Lerp(
                desired,
                alpha
            )

    end

    --==================================================
    -- 1. CÂMERA REAL
    --==================================================

    pcall(function()

        Camera.CFrame =
            finalCFrame

    end)

    --==================================================
    -- 2. CAMERA CFRAME DO CHARACTER
    --==================================================

    local localCharacter =
        getLocalCharacter()

    if localCharacter then

        pcall(function()

            localCharacter:SetAttribute(
                "CameraCFrame",
                finalCFrame
            )

        end)

    end

end

--==================================================
-- SETTINGS
--==================================================

function Aimbot:SetSetting(
    key,
    value
)

    if settings[key] == nil then
        return
    end

    settings[key] =
        value

    if key == "fov" then

        settings.fov =
            math.clamp(
                tonumber(value) or 150,
                1,
                2000
            )

        updateFOV()

    elseif key == "color" then

        updateFOV()

    elseif key == "smoothness" then

        settings.smoothness =
            math.clamp(
                tonumber(value) or 1,
                0,
                1
            )

    elseif key == "maxDistance" then

        settings.maxDistance =
            math.max(
                tonumber(value) or 2000,
                1
            )

    elseif key == "enabled" then

        settings.enabled =
            value == true

        if circle then
            circle.Visible =
                settings.enabled
        end

    end

end

--==================================================
-- GET SETTING
--==================================================

function Aimbot:GetSetting(key)

    return settings[key]

end

--==================================================
-- IS ENABLED
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

    connection =
        RunService.RenderStepped:Connect(
            function()

                if not running then
                    return
                end

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

        pcall(function()

            circle.Visible = false

            circle:Remove()

        end)

        circle = nil

    end

end

--==================================================
-- RETURN
--==================================================

return Aimbot
