-- Giữ nguyên phần GUI và FOV của bạn, mình chỉ sửa phần LOOP và LOGIC thôi nhé!

-- SETTINGS MỚI (CHỈNH LẠI CHO MẠNH)
local FOV_RADIUS = 150
local AIM_SPEED = 0.5 -- Tăng tốc độ khóa tâm (Càng cao càng dính)
local TARGET_PART = "Head" -- Hoặc "HumanoidRootPart" nếu muốn bắn vào người

-- LOOP MỚI (THAY THẾ ĐOẠN RUNSERVICE CŨ)
RunService.RenderStepped:Connect(function()
    local center = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
    circle.Position = center

    if _G.Aimbot and holding then
        local target = getTarget()

        if target and target.Character and target.Character:FindFirstChild(TARGET_PART) then
            local targetPos = target.Character[TARGET_PART].Position
            
            -- FIX: Khóa trực tiếp CFrame không qua Bullet Bend hay Jitter
            local lookCF = CFrame.new(camera.CFrame.Position, targetPos)
            
            -- Dùng Lerp một lần duy nhất với tốc độ cực cao
            camera.CFrame = camera.CFrame:Lerp(lookCF, AIM_SPEED)

            -- LINE vẽ thẳng đến địch
            local pos, onScreen = camera:WorldToViewportPoint(targetPos)
            if onScreen then
                line.From = center
                line.To = Vector2.new(pos.X, pos.Y)
                line.Visible = true
            end
        else
            line.Visible = false
        end
    else
        line.Visible = false
    end
end)
