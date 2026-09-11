while true do
    local camera = workspace:FindFirstChild("Camera")

    if camera then
        local weapon = camera:FindFirstChildOfClass("Model")

        if weapon then
            for _, part in ipairs(weapon:GetDescendants()) do
                if part:IsA("BasePart") then

                    -- Cor e material
                    part.Color = Color3.fromHex("#5500FF")
                    part.Material = Enum.Material.ForceField
                    part.MaterialVariant = ""

                    -- Remove SurfaceAppearance
                    local surface = part:FindFirstChildOfClass("SurfaceAppearance")
                    if surface then
                        surface:Destroy()
                    end

                    -- Remove texturas/decals
                    for _, obj in ipairs(part:GetChildren()) do
                        if obj:IsA("Texture") or obj:IsA("Decal") then
                            obj:Destroy()
                        end
                    end

                    -- Para MeshPart
                    if part:IsA("MeshPart") then
                        part.TextureID = ""
                    end
                end
            end
        end
    end

    task.wait(0.2)
end
