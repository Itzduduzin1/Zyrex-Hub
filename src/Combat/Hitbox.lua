local Hitbox = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Characters = workspace:WaitForChild("Characters")

local settings = {
    enabled = false,
    size = 5
}

local running = false
local connection = nil
local currentTarget = nil

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

    return myTeam ~= targetTeam
        and dead == false
end

--==================================================
-- TARGET
--==================================================

local function getTarget()

    local Camera =
        workspace.CurrentCamera

    if not Camera then
        return nil
    end

    local center = Vector2.new(
        Camera.ViewportSize.X / 2,
        Camera.ViewportSize.Y / 2
    )

    local closest = nil
    local closestDistance = math.huge

    local radius =
        settings.size * 20

    for _, character in ipairs(
        Characters:GetChildren()
    ) do

        if isEnemy(character) then

            local root =
                character:FindFirstChild(
                    "HumanoidRootPart"
                )

            if root then

                local position, onScreen =
                    Camera:WorldToViewportPoint(
                        root.Position
                    )

                if onScreen then

                    local screenPosition =
                        Vector2.new(
                            position.X,
                            position.Y
                        )

                    local distance =
                        (
                            screenPosition - center
                        ).Magnitude

                    if distance <= radius
                    and distance < closestDistance then

                        closest = Players:GetPlayerFromCharacter(
                            character
                        )

                        closestDistance = distance

                    end
                end
            end
        end
    end

    return closest
end

--==================================================
-- SETTINGS
--==================================================

function Hitbox:SetSetting(key, value)

    if settings[key] == nil then
        return
    end

    if key == "enabled" then
        settings[key] = value == true
        return
    end

    if key == "size" then
        settings[key] = math.clamp(
            tonumber(value) or 5,
            1,
            50
        )
        return
    end

    settings[key] = value
end

function Hitbox:GetSetting(key)
    return settings[key]
end

--==================================================
-- STATUS
--==================================================

function Hitbox:IsEnabled()
    return settings.enabled
end

function Hitbox:GetTarget()
    return currentTarget
end

--==================================================
-- INIT
--==================================================

function Hitbox:Init()

    if running then
        return
    end

    running = true

    connection = RunService.RenderStepped:Connect(
        function()

            if not settings.enabled then
                currentTarget = nil
                return
            end

            currentTarget = getTarget()

        end
    )

end

--==================================================
-- DESTROY
--==================================================

function Hitbox:Destroy()

    running = false

    currentTarget = nil

    if connection then
        connection:Disconnect()
        connection = nil
    end

end

return Hitbox
