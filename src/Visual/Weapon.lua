local Weapon = {}

local enabled = false
local connection

local CAMERA_NAME = "Camera"

local WEAPON_COLOR = Color3.fromHex("#5500FF")
local WEAPON_MATERIAL = Enum.Material.ForceField

local function applyWeapon()
    if not enabled then
        return
    end

    local camera = workspace:FindFirstChild(CAMERA_NAME)

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
            part.Material = WEAPON_MATERIAL
            part.MaterialVariant = ""

            local surface = part:FindFirstChildOfClass("SurfaceAppearance")

            if surface then
                surface:Destroy()
            end

            for _, obj in ipairs(part:GetChildren()) do
                if obj:IsA("Texture") or obj:IsA("Decal") then
                    obj:Destroy()
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
        self:Refresh()
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
    if connection then
        return
    end

    connection = task.spawn(function()
        while connection do
            if enabled then
                pcall(applyWeapon)
            end

            task.wait(0.2)
        end
    end)
end

function Weapon:Destroy()
    enabled = false
    connection = nil
end

return Weapon
