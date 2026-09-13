-- Aimbot Diagnostic
-- Não modifica CurrentCamera.CFrame
-- Não altera Constants
-- Não tenta contornar AIM_ASSIST_WHITELIST

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Settings = {
    Enabled = true,
    FOV = 150,
    MaxDistance = 125,
    TargetPart = "Head",
    WallCheck = true
}

local function getCharacter(player)
    return player.Character
        or Workspace:FindFirstChild("Characters")
            and Workspace.Characters:FindFirstChild(player.Name)
end

local function isAlive(character)
    if not character then
        return false
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if humanoid and humanoid.Health <= 0 then
        return false
    end

    return true
end

local function sameTeam(player)
    if player == LocalPlayer then
        return true
    end

    local myChar = getCharacter(LocalPlayer)
    local enemyChar = getCharacter(player)

    if not myChar or not enemyChar then
        return false
    end

    local myTeam = myChar:GetAttribute("Team")
    local enemyTeam = enemyChar:GetAttribute("Team")

    if myTeam and enemyTeam then
        return myTeam == enemyTeam
    end

    return player.Team ~= nil
        and LocalPlayer.Team ~= nil
        and player.Team == LocalPlayer.Team
end

local function visible(part)
    if not Settings.WallCheck then
        return true
    end

    local origin = Camera.CFrame.Position
    local direction = part.Position - origin

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {
        getCharacter(LocalPlayer)
    }

    local result = Workspace:Raycast(
        origin,
        direction,
        params
    )

    if not result then
        return true
    end

    return result.Instance:IsDescendantOf(part.Parent)
end

local function getBestTarget()
    local center = Camera.ViewportSize / 2

    local bestPlayer = nil
    local bestPart = nil
    local bestScore = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not sameTeam(player) then

            local character = getCharacter(player)

            if character and isAlive(character) then
                local part = character:FindFirstChild(Settings.TargetPart)

                if part then
                    local screenPos, onScreen =
                        Camera:WorldToViewportPoint(part.Position)

                    if onScreen and screenPos.Z > 0 then

                        local screenDistance =
                            (Vector2.new(
                                screenPos.X,
                                screenPos.Y
                            ) - center).Magnitude

                        if screenDistance <= Settings.FOV then

                            local worldDistance =
                                (part.Position - Camera.CFrame.Position).Magnitude

                            if worldDistance <= Settings.MaxDistance then

                                if visible(part) then
                                    if screenDistance < bestScore then
                                        bestScore = screenDistance
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

    return bestPlayer, bestPart, bestScore
end

-- Diagnóstico
RunService.RenderStepped:Connect(function()

    if not Settings.Enabled then
        return
    end

    local player, part, score = getBestTarget()

    if player and part then
        print(
            string.format(
                "[AIM] alvo=%s parte=%s FOV=%.1f",
                player.Name,
                part.Name,
                score
            )
        )
    end
end)

print("[AIM] Diagnostic iniciado")
