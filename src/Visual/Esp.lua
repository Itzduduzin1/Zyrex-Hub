local ESP = {}

local Players = game:GetService("Players")
local Chars = workspace:WaitForChild("Characters")

local LocalPlayer = Players.LocalPlayer

local CONFIG = {
    Terrorist = {
        FillColor = Color3.fromRGB(255, 0, 0),
        OutlineColor = Color3.fromRGB(255, 255, 255),
        FillTransparency = 0.5,
        OutlineTransparency = 0,
        DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    },

    Counter = {
        FillColor = Color3.fromRGB(0, 0, 255),
        OutlineColor = Color3.fromRGB(255, 255, 255),
        FillTransparency = 0.5,
        OutlineTransparency = 0,
        DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    },

    Natural = {
        FillColor = Color3.fromRGB(255, 255, 255),
        OutlineColor = Color3.fromRGB(255, 255, 255),
        FillTransparency = 0.5,
        OutlineTransparency = 0,
        DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    }
}

local enabled = false
local connections = {}

local function removeHighlight(char)
    local highlight = char:FindFirstChild("Highlight")

    if highlight then
        highlight:Destroy()
    end
end

local function isValidCharacter(char)
    local player = Players:GetPlayerFromCharacter(char)

    if not player or player == LocalPlayer then
        return false
    end

    local team = player:GetAttribute("Team")
    local dead = player:GetAttribute("Dead")

    if team == nil or dead == nil then
        return false
    end

    return dead == false
end

local function applyHighlight(char)
    if not enabled then
        return
    end

    if not char or not char:IsA("Model") then
        return
    end

    if not isValidCharacter(char) then
        removeHighlight(char)
        return
    end

    local player = Players:GetPlayerFromCharacter(char)

    if not player then
        return
    end

    local team = player:GetAttribute("Team")

    local config = CONFIG.Natural

    if team == "Terrorists" then
        config = CONFIG.Terrorist
    elseif team == "Counter-Terrorists" then
        config = CONFIG.Counter
    end

    removeHighlight(char)

    local highlight = Instance.new("Highlight")

    highlight.Name = "Highlight"
    highlight.Adornee = char
    highlight.FillColor = config.FillColor
    highlight.OutlineColor = config.OutlineColor
    highlight.FillTransparency = config.FillTransparency
    highlight.OutlineTransparency = config.OutlineTransparency
    highlight.DepthMode = config.DepthMode
    highlight.Parent = char
end

function ESP:SetEnabled(value)
    enabled = value == true

    if not enabled then
        self:Clear()
        return
    end

    self:Refresh()
end

function ESP:IsEnabled()
    return enabled
end

function ESP:Refresh()
    if not enabled then
        return
    end

    for _, char in ipairs(Chars:GetChildren()) do
        if char:IsA("Model") then
            task.spawn(applyHighlight, char)
        end
    end
end

function ESP:Clear()
    for _, char in ipairs(Chars:GetChildren()) do
        removeHighlight(char)
    end
end

function ESP:Init()
    connections.characterAdded = Chars.ChildAdded:Connect(function(char)
        if enabled and char:IsA("Model") then
            task.spawn(applyHighlight, char)
        end
    end)

    connections.characterRemoved = Chars.ChildRemoved:Connect(function(char)
        removeHighlight(char)
    end)

    connections.refresh = task.spawn(function()
        while true do
            task.wait(0.5)

            if enabled then
                self:Refresh()
            end
        end
    end)
end

function ESP:Destroy()
    enabled = false

    self:Clear()

    for _, connection in pairs(connections) do
        if typeof(connection) == "RBXScriptConnection" then
            connection:Disconnect()
        end
    end

    table.clear(connections)
end

return ESP
