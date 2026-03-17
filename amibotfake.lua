repeat task.wait() until game:IsLoaded()

local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- SETTINGS
local FOV_RADIUS = 120
local SMOOTHNESS = 0.18
local AIM_STRENGTH = 0.85
local BULLET_BEND = 0.25

_G.Aimbot = false
local holding = false

-- GUI
local gui = Instance.new("ScreenGui")
gui.Parent = game.CoreGui
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,160,0,90)
frame.Position = UDim2.new(0.1,0,0.4,0)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0.3,0)
title.Text = "TRONG DZ HUB"
title.BackgroundColor3 = Color3.fromRGB(0,170,255)
title.TextColor3 = Color3.new(1,1,1)

local btn = Instance.new("TextButton", frame)
btn.Size = UDim2.new(0.9,0,0.5,0)
btn.Position = UDim2.new(0.05,0,0.4,0)
btn.Text = "AIM: OFF"
btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
btn.TextColor3 = Color3.new(1,1,1)

btn.MouseButton1Click:Connect(function()
    _G.Aimbot = not _G.Aimbot
    btn.Text = "AIM: " .. (_G.Aimbot and "ON" or "OFF")
end)

-- FOV
local circle = Drawing.new("Circle")
circle.Radius = FOV_RADIUS
circle.Thickness = 2
circle.Filled = false
circle.Color = Color3.fromRGB(0,255,255)
circle.Visible = true

-- LINE
local line = Drawing.new("Line")
line.Thickness = 2
line.Color = Color3.fromRGB(255,0,0)
line.Visible = false

-- INPUT
UIS.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        holding = true
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        holding = false
    end
end)

-- TARGET
local function getTarget()
    local closest = nil
    local shortest = FOV_RADIUS
    local center = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)

    for _,v in pairs(game.Players:GetPlayers()) do
        if v ~= player and v.Character and v.Character:FindFirstChild("Head") then
            local pos, onScreen = camera:WorldToViewportPoint(v.Character.Head.Position)

            if onScreen then
                local dist = (Vector2.new(pos.X,pos.Y) - center).Magnitude
                if dist < shortest then
                    shortest = dist
                    closest = v
                end
            end
        end
    end

    return closest
end

-- FAKE SILENT AIM
local function getAimDirection(targetPos)
    local camPos = camera.CFrame.Position
    local original = camera.CFrame.LookVector
    local desired = (targetPos - camPos).Unit

    return original:Lerp(desired, BULLET_BEND)
end

-- LOOP
RunService.RenderStepped:Connect(function()

    local center = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
    circle.Position = center

    if _G.Aimbot and holding then
        
        local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")

        if tool then
            
            local target = getTarget()

            if target and target.Character then
                local head = target.Character:FindFirstChild("Head")

                if head then
                    local dir = getAimDirection(head.Position)

                    local camPos = camera.CFrame.Position
                    local newCF = CFrame.new(camPos, camPos + dir)

                    local smoothCF = camera.CFrame:Lerp(newCF, SMOOTHNESS)
                    camera.CFrame = camera.CFrame:Lerp(smoothCF, AIM_STRENGTH)

                    -- RANDOM (LEGIT)
                    local jitter = Vector3.new(
                        math.random(-2,2)/100,
                        math.random(-2,2)/100,
                        0
                    )
                    camera.CFrame = camera.CFrame * CFrame.new(jitter)

                    -- LINE
                    local pos, onScreen = camera:WorldToViewportPoint(head.Position)

                    if onScreen then
                        line.From = center
                        line.To = Vector2.new(pos.X,pos.Y)
                        line.Visible = true
                    else
                        line.Visible = false
                    end
                end
            else
                line.Visible = false
            end
        else
            line.Visible = false
        end
    else
        line.Visible = false
    end

end)
