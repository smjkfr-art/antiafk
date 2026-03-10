--[[
Ultimate Utility Hub (PC + Mobile Friendly) 
Floating Mini-Panel + FPS, Ping, Auto-Rejoin, Server Hop, Performance Mode, Crosshair Styles, Hide UI, Mobile Freecam Hybrid Controls for Rivals
Made for Joniel
]]

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- UI
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "UltimateUtilityHub"
ScreenGui.ResetOnSpawn = false

-- Mini-Panel
local Panel = Instance.new("Frame", ScreenGui)
Panel.Size = UDim2.new(0, 200, 0, 50)
Panel.Position = UDim2.new(0.02, 0, 0.2, 0)
Panel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Panel.BorderSizePixel = 0
Panel.Active = true
Panel.Draggable = true

local Title = Instance.new("TextLabel", Panel)
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "Utility Hub"
Title.TextScaled = true
Title.Font = Enum.Font.SourceSansBold
Title.TextColor3 = Color3.fromRGB(255,255,255)

-- Expandable Frame
local ExpandedFrame = Instance.new("Frame", Panel)
ExpandedFrame.Size = UDim2.new(0, 300, 0, 400)
ExpandedFrame.Position = UDim2.new(1, 10, 0, 0)
ExpandedFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ExpandedFrame.Visible = false
ExpandedFrame.BorderSizePixel = 0

local function TogglePanel()
	ExpandedFrame.Visible = not ExpandedFrame.Visible
end

Panel.MouseButton1Click:Connect(TogglePanel) -- toggle on click

-- BUTTON CREATOR FUNCTION
local function CreateButton(parent, text, callback)
	local btn = Instance.new("TextButton", parent)
	btn.Size = UDim2.new(0, 280, 0, 40)
	btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
	btn.TextColor3 = Color3.fromRGB(255,255,255)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextScaled = true
	btn.Text = text
	btn.Position = UDim2.new(0,10,0,#parent:GetChildren()*45-45)
	btn.MouseButton1Click:Connect(callback)
	return btn
end

-- FPS Counter
local fpsLabel = Instance.new("TextLabel", ExpandedFrame)
fpsLabel.Size = UDim2.new(0, 280, 0, 30)
fpsLabel.Position = UDim2.new(0,10,0,10)
fpsLabel.TextColor3 = Color3.fromRGB(0,255,0)
fpsLabel.TextScaled = true
fpsLabel.BackgroundTransparency = 1
fpsLabel.Text = "FPS: 0"

local lastTime = tick()
local frameCount = 0
RunService.RenderStepped:Connect(function()
	frameCount = frameCount + 1
	if tick() - lastTime >= 1 then
		fpsLabel.Text = "FPS: "..frameCount
		frameCount = 0
		lastTime = tick()
	end
end)

-- Ping Display
local pingLabel = Instance.new("TextLabel", ExpandedFrame)
pingLabel.Size = UDim2.new(0, 280, 0, 30)
pingLabel.Position = UDim2.new(0,10,0,50)
pingLabel.TextColor3 = Color3.fromRGB(0,200,255)
pingLabel.TextScaled = true
pingLabel.BackgroundTransparency = 1
pingLabel.Text = "Ping: 0ms"

RunService.RenderStepped:Connect(function()
	local ping = math.floor(LocalPlayer:GetNetworkPing()*1000)
	pingLabel.Text = "Ping: "..ping.."ms"
end)

-- Auto Rejoin
CreateButton(ExpandedFrame, "Auto-Rejoin", function()
	TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)

-- Server Hop
CreateButton(ExpandedFrame, "Server Hop", function()
	local success, servers = pcall(function()
		return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
	end)
	if success and servers.data then
		for _, server in pairs(servers.data) do
			if server.id ~= game.JobId and server.playing < server.maxPlayers then
				TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
				break
			end
		end
	end
end)

-- Performance Mode (Low-GFX)
local lowGFX = false
CreateButton(ExpandedFrame, "Toggle Performance Mode", function()
	lowGFX = not lowGFX
	for _, v in pairs(workspace:GetDescendants()) do
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
end)

-- Crosshair Styles
local crosshair = Instance.new("TextLabel", ExpandedFrame)
crosshair.Size = UDim2.new(0, 280, 0, 30)
crosshair.Position = UDim2.new(0,10,0, 250)
crosshair.BackgroundTransparency = 1
crosshair.TextColor3 = Color3.fromRGB(255,255,0)
crosshair.TextScaled = true
crosshair.Text = "+"

local crosshairStyles = {"+","x","•","+"}
local crosshairIndex = 1
CreateButton(ExpandedFrame,"Change Crosshair",function()
	crosshairIndex = crosshairIndex + 1
	if crosshairIndex > #crosshairStyles then crosshairIndex = 1 end
	crosshair.Text = crosshairStyles[crosshairIndex]
end)

-- Hide UI
CreateButton(ExpandedFrame,"Hide UI",function()
	ScreenGui.Enabled = not ScreenGui.Enabled
end)

-- Mobile Freecam Hybrid Controls
local freecamActive = false
local joystickFrame, joystickThumb
local cam = workspace.CurrentCamera

-- Create Joystick
local function CreateJoystick()
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
end

CreateJoystick()

local inputVector = Vector3.new()

UserInputService.TouchMoved:Connect(function(input, gameProcessed)
	if freecamActive and joystickFrame.Visible and input.UserInputType == Enum.UserInputType.Touch then
		local pos = input.Position - joystickFrame.AbsolutePosition - Vector2.new(joystickFrame.AbsoluteSize.X/2, joystickFrame.AbsoluteSize.Y/2)
		inputVector = Vector3.new(pos.X,0,pos.Y).Unit
	end
end)

-- Freecam Toggle Button
CreateButton(ExpandedFrame,"Toggle Freecam",function()
	freecamActive = not freecamActive
	joystickFrame.Visible = freecamActive
	cam.CameraType = freecamActive and Enum.CameraType.Scriptable or Enum.CameraType.Custom
end)

-- Update camera movement
RunService.RenderStepped:Connect(function(delta)
	if freecamActive then
		local moveSpeed = 50*delta
		local camCFrame = cam.CFrame
		cam.CFrame = camCFrame + camCFrame.LookVector*inputVector.Z*moveSpeed + camCFrame.RightVector*inputVector.X*moveSpeed
	end
end)
