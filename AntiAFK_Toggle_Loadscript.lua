--[[
Ultimate Utility Hub (PC + Mobile Friendly)
Floating GUI that appears automatically with FPS, Ping, Performance Mode, and Freecam
Made for Joniel
]]

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- CREATE GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UltimateUtilityHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(0, 300, 0, 400)
Panel.Position = UDim2.new(0.02, 0, 0.2, 0)
Panel.BackgroundColor3 = Color3.fromRGB(35,35,35)
Panel.BorderSizePixel = 0
Panel.Parent = ScreenGui

-- TITLE
local Title = Instance.new("TextLabel", Panel)
Title.Size = UDim2.new(1,0,0,40)
Title.Position = UDim2.new(0,0,0,0)
Title.BackgroundTransparency = 1
Title.Text = "Utility Hub"
Title.Font = Enum.Font.SourceSansBold
Title.TextScaled = true
Title.TextColor3 = Color3.fromRGB(255,255,255)

-- FUNCTION TO CREATE LABELS
local function addLabel(text, y)
    local lbl = Instance.new("TextLabel", Panel)
    lbl.Size = UDim2.new(0, 280, 0, 30)
    lbl.Position = UDim2.new(0,10,0,y)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(255,255,255)
    lbl.TextScaled = true
    lbl.Font = Enum.Font.SourceSansBold
    lbl.Text = text
    return lbl
end

-- FPS AND PING
local fpsLabel = addLabel("FPS: 0", 50)
local pingLabel = addLabel("Ping: 0ms", 90)

RunService.RenderStepped:Connect(function()
    fpsLabel.Text = "FPS: "..math.floor(1/RunService.RenderStepped:Wait())
    pingLabel.Text = "Ping: "..math.floor(LocalPlayer:GetNetworkPing()*1000).."ms"
end)

-- PERFORMANCE MODE (Low GFX)
local lowGFX = false
local function togglePerformance()
    lowGFX = not lowGFX
    for _,v in pairs(Workspace:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Enabled = not lowGFX
        elseif v:IsA("BasePart") then
            if lowGFX then
                v.Material = Enum.Material.Plastic
            else
                v.Material = Enum.Material.SmoothPlastic
            end
        end
    end
end

local perfLabel = addLabel("Performance Mode (toggle with function)", 130)

-- MANUAL FREECAM (MOBILE + PC)
local freecamActive = false
local cam = Workspace.CurrentCamera
local joystickFrame, joystickThumb
local inputVector = Vector3.new()

-- CREATE JOYSTICK FOR MOBILE
joystickFrame = Instance.new("Frame", ScreenGui)
joystickFrame.Size = UDim2.new(0,100,0,100)
joystickFrame.Position = UDim2.new(0,20,1,-120)
joystickFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
joystickFrame.Visible = false
joystickFrame.ZIndex = 2

joystickThumb = Instance.new("Frame", joystickFrame)
joystickThumb.Size = UDim2.new(0,40,0,40)
joystickThumb.Position = UDim2.new(0.5,-20,0.5,-20)
joystickThumb.BackgroundColor3 = Color3.fromRGB(200,200,200)

-- FUNCTION TO TOGGLE FREECAM
local function toggleFreecam()
    freecamActive = not freecamActive
    joystickFrame.Visible = freecamActive
    cam.CameraType = freecamActive and Enum.CameraType.Scriptable or Enum.CameraType.Custom
end

-- UPDATE CAMERA MOVEMENT
RunService.RenderStepped:Connect(function(delta)
    if freecamActive then
        local moveSpeed = 50*delta
        cam.CFrame = cam.CFrame + cam.CFrame.LookVector*inputVector.Z*moveSpeed + cam.CFrame.RightVector*inputVector.X*moveSpeed
    end
end)

-- MOBILE TOUCH INPUT
UserInputService.TouchMoved:Connect(function(input, gp)
    if freecamActive and joystickFrame.Visible and input.UserInputType == Enum.UserInputType.Touch then
        local pos = input.Position - joystickFrame.AbsolutePosition - Vector2.new(joystickFrame.AbsoluteSize.X/2, joystickFrame.AbsoluteSize.Y/2)
        inputVector = Vector3.new(pos.X,0,pos.Y).Unit
    end
end)

-- ENABLE GUI AUTOMATICALLY
ScreenGui.Enabled = true
