local Weapon = {}

local enabled = false
local running = false

local WEAPON_COLOR = Color3.fromRGB(85, 0, 255)

local function applyWeapon()
    local camera = workspace.CurrentCamera

    if not camera then
        return
    end

    local weapon = camera:FindFirstChildOfClass("Model")

    if not weapon then
        return
    end

    for _, part in ipairs(weapon:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Color = WEAPON_COLOR
            part.Material = Enum.Material.ForceField
            part.MaterialVariant = ""

            local surface = part:FindFirstChildOfClass("SurfaceAppearance")

            if surface then
                surface:Destroy()
            end

            for _, object in ipairs(part:GetChildren()) do
                if object:IsA("Texture") or object:IsA("Decal") then
                    object:Destroy()
                end
            end

            if part:IsA("MeshPart") then
                part.TextureID = ""
            end
        end
    end
end

function Weapon:SetEnabled(value)
    enabled = value == true

    if enabled then
        applyWeapon()
    end
end

function Weapon:IsEnabled()
    return enabled
end

function Weapon:Refresh()
    if enabled then
        applyWeapon()
    end
end

function Weapon:Init()
    if running then
        return
    end

    running = true

    task.spawn(function()
        while running do
            if enabled then
                pcall(applyWeapon)
            end

            task.wait(0.2)
        end
    end)
end

function Weapon:Destroy()
    enabled = false
    running = false
end

return Weapon
