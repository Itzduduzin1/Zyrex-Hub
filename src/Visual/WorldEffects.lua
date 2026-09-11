local WorldEffects = {}

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local settings = {
    antiFlash = false,
    antiSmoke = false
}

local running = true

function WorldEffects:SetSetting(key, value)
    if settings[key] ~= nil then
        settings[key] = value
    end
end

function WorldEffects:GetSetting(key)
    return settings[key]
end

function WorldEffects:Init()
    task.spawn(function()
        while running do
            task.wait(0.1)

            if settings.antiFlash then
                local player = Players.LocalPlayer
                local playerGui = player and player:FindFirstChild("PlayerGui")

                local flash = playerGui and playerGui:FindFirstChild("FlashbangEffect")
                local effect = Lighting:FindFirstChild("FlashbangColorCorrection")

                if flash then
                    flash:Destroy()
                end

                if effect then
                    effect:Destroy()
                end
            end
        end
    end)

    task.spawn(function()
        while running do
            task.wait(0.1)

            if settings.antiSmoke then
                local debris = Workspace:FindFirstChild("Debris")

                if debris then
                    for _, object in ipairs(debris:GetChildren()) do
                        if string.match(object.Name, "Voxel") then
                            object:ClearAllChildren()
                            object:Destroy()
                        end
                    end
                end
            end
        end
    end)
end

function WorldEffects:Destroy()
    running = false
end

return WorldEffects
