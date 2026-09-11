--[[
██████╗ ██╗   ██╗    ██████╗ ██╗   ██╗ ██████╗ █████╗ ██╗     
██╔══██╗╚██╗ ██╔╝    ██╔══██╗██║   ██║██╔════╝██╔══██╗██║     
██████╔╝ ╚████╔╝     ██║  ██║██║   ██║██║     ███████║██║     
██╔══██╗  ╚██╔╝      ██║  ██║██║   ██║██║     ██╔══██║██║     
██████╔╝   ██║       ██████╔╝╚██████╔╝╚██████╗██║  ██║███████╗
╚═════╝    ╚═╝       ╚═════╝  ╚═════╝  ╚═════╝╚═╝  ╚═╝╚══════╝
                                                              
-- Feito por ducalofc
-- Para Blox Strike
-- Esp open source
]]

local Players = game:GetService("Players")
local Chars = workspace:WaitForChild("Characters")
local LocalPlayer = Players.LocalPlayer
local InputService = game:GetService("UserInputService")

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
    }
}

local enabled = false

local function ehInimigoVivo(char)
    local player = Players:GetPlayerFromCharacter(char)
    if not player or player == LocalPlayer then
        return false
    end

    local meuTime = LocalPlayer:GetAttribute("Team")
    local timeDele = player:GetAttribute("Team")
    local morto = player:GetAttribute("Dead")

    if meuTime == nil or timeDele == nil then
        return false
    end

    return --[[(meuTime ~= timeDele) and ]](morto == false)
end

local function removerHighlight(char)
    local existente = char:FindFirstChild("Highlight")
    if existente then
        existente:Destroy()
    end
end

local function aplicarHighlight(char)
    if not char or not char:IsA("Model") then
        return
    end

    if not ehInimigoVivo(char) then
        removerHighlight(char)
        return
    end

    local player = Players:GetPlayerFromCharacter(char)

    if not player then
        return
    end

    local team = player:GetAttribute("Team")

    local config

    if team == "Terrorists" then
        config = CONFIG.Terrorist
    elseif team == "Counter-Terrorists" then
        config = CONFIG.Counter
    else
        config = CONFIG.Natural
    end

    local head = char:WaitForChild("Head", 10)

    if not head then
        return
    end

    removerHighlight(char)

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

local function monitorarChar(char)
    char.AncestryChanged:Connect(function(_, parent)
        if parent == Chars or (parent and parent:IsDescendantOf(Chars)) then
            task.spawn(aplicarHighlight, char)
        end
    end)

    local player = Players:GetPlayerFromCharacter(char)
    if player then
        player:GetAttributeChangedSignal("Team"):Connect(function()
            task.spawn(aplicarHighlight, char)
        end)

        player:GetAttributeChangedSignal("Dead"):Connect(function()
            task.spawn(aplicarHighlight, char)
        end)
    end
end

InputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.E then
        if enabled then
            enabled = false
            for _, char in ipairs(Chars:GetChildren()) do
                removerHighlight(char)
            end
        else
            enabled = true
            for _, char in ipairs(Chars:GetChildren()) do
                task.spawn(aplicarHighlight, char)
            end
        end
    end
end)

while true do
    if enabled == true then
        local ok, err = pcall(function()
            for _, char in ipairs(Chars:GetChildren()) do
                if char:IsA("Model") then
                    task.spawn(aplicarHighlight, char)
                end
            end
        end)

        if not ok then
            warn("[ESP] loop crashou e foi recuperado:", err)
        end
    end
    wait(0.5)
end
