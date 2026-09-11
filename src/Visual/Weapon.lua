--==================================================
-- ZYREX HUB - WEAPON
--==================================================

local Weapon = {}

local Workspace = game:GetService("Workspace")

local settings = {
    enabled = false,
    color = Color3.fromRGB(85, 0, 255),
    material = Enum.Material.ForceField
}

local running = false

--==================================================
-- APPLY
--==================================================

local function applyWeapon(weapon)
    if not weapon or not weapon:IsA("Model") then
        return
    end

    for _, part in ipairs(weapon:GetDescendants()) do
        if part:IsA("BasePart") then

            part.Color = settings.color
            part.Material = settings.material
            part.MaterialVariant = ""

            local surface = part:FindFirstChildOfClass("SurfaceAppearance")

            if surface then
                surface:Destroy()
            end

            for _, object in ipairs(part:GetChildren()) do
                if object:IsA("Texture")
                    or object:IsA("Decal") then

                    object:Destroy()
                end
            end

            if part:IsA("MeshPart") then
                part.TextureID = ""
            end
        end
    end
end

--==================================================
-- SETTINGS
--==================================================

function Weapon:SetSetting(key, value)

    if settings[key] == nil then
        return
    end

    settings[key] = value
end

function Weapon:GetSetting(key)
    return settings[key]
end

--==================================================
-- INIT
--==================================================

function Weapon:Init()

    if running then
        return
    end

    running = true

    task.spawn(function()

        while running do

            task.wait(0.2)

            if settings.enabled then

                local camera = Workspace.CurrentCamera

                if camera then

                    local weapon = camera:FindFirstChildOfClass("Model")

                    if weapon then
                        applyWeapon(weapon)
                    end

                end
            end
        end

    end)
end

--==================================================
-- DESTROY
--==================================================

function Weapon:Destroy()

    running = false

end

return Weapon
