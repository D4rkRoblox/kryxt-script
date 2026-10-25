local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

local repo = "https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/"

local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
Library.ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
Library.SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

Library.FontColor = Color3.fromHex("ffffff")
Library.MainColor = Color3.fromHex("131313")
Library.AccentColor = Color3.fromHex("a2cdff")
Library.AccentColorDark = Library:GetDarkerColor(Library.AccentColor)
Library.BackgroundColor = Color3.fromHex("151515")
Library.OutlineColor = Color3.fromHex("212121")
Library.RiskColor = Color3.fromHex("ff7425")

Library.ShowCustomCursor = false
Library.BlurEnabled = true
Library.BlurSize = 15
Library.BackColor = Color3.fromHex("000000")
Library.BackTransparency = 0.7
Library.CursorEnabled = true
Library.CursorColor = Color3.fromRGB(167, 71, 71)

local Blur = Instance.new("BlurEffect")
Blur.Name = "LibraryBlur"
Blur.Size = 0
Blur.Parent = Lighting

local DimGui = Instance.new("ScreenGui")
DimGui.Name = "LibraryDim"
DimGui.IgnoreGuiInset = true
DimGui.DisplayOrder = 0
DimGui.ResetOnSpawn = false
DimGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local Dim = Instance.new("Frame")
Dim.Size = UDim2.new(1, 0, 1, 0)
Dim.BorderSizePixel = 0
Dim.BackgroundColor3 = Library.BackColor
Dim.BackgroundTransparency = 1
Dim.Active = false
Dim.Parent = DimGui

local CursorGui = Instance.new("ScreenGui")
CursorGui.Name = "LibraryCursor"
CursorGui.IgnoreGuiInset = true
CursorGui.DisplayOrder = 999999
CursorGui.ResetOnSpawn = false
CursorGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
CursorGui.Enabled = false
CursorGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local Dot = Instance.new("Frame")
Dot.AnchorPoint = Vector2.new(0.5, 0.5)
Dot.Size = UDim2.new(0, 6, 0, 6)
Dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Dot.BorderSizePixel = 0
Dot.ZIndex = 2
Dot.Parent = CursorGui
Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

local Ring = Instance.new("Frame")
Ring.AnchorPoint = Vector2.new(0.5, 0.5)
Ring.Size = UDim2.new(0, 26, 0, 26)
Ring.BackgroundTransparency = 1
Ring.BorderSizePixel = 0
Ring.ZIndex = 1
Ring.Parent = CursorGui
Instance.new("UICorner", Ring).CornerRadius = UDim.new(1, 0)

local RingStroke = Instance.new("UIStroke", Ring)
RingStroke.Thickness = 1.6
RingStroke.Color = Library.CursorColor

local oldMouseIcon = UserInputService.MouseIconEnabled
local ringPos = UserInputService:GetMouseLocation()
local wasOpen = false

local loop = RunService.RenderStepped:Connect(function(dt)
	local open = Library.Toggled == true

	if open ~= wasOpen then
		wasOpen = open
		CursorGui.Enabled = open and Library.CursorEnabled
		if open then
			oldMouseIcon = UserInputService.MouseIconEnabled
		else
			UserInputService.MouseIconEnabled = oldMouseIcon
		end
		local blurOn = open and Library.BlurEnabled
		TweenService:Create(Blur, TweenInfo.new(0.4), {Size = blurOn and Library.BlurSize or 0}):Play()
		Dim.BackgroundColor3 = Library.BackColor
		TweenService:Create(Dim, TweenInfo.new(0.4), {BackgroundTransparency = blurOn and Library.BackTransparency or 1}):Play()
	end

	if not open or not Library.CursorEnabled then
		return
	end

	RingStroke.Color = Library.CursorColor
	UserInputService.MouseIconEnabled = false

	local m = UserInputService:GetMouseLocation()
	ringPos = ringPos:Lerp(m, math.clamp(dt * 14, 0, 1))
	Dot.Position = UDim2.new(0, m.X, 0, m.Y)
	Ring.Position = UDim2.new(0, ringPos.X, 0, ringPos.Y)

	local hovering = false
	for _, g in ipairs(Players.LocalPlayer.PlayerGui:GetGuiObjectsAtPosition(m.X, m.Y - 36)) do
		if g:IsA("TextButton") or g:IsA("TextBox") or g:IsA("ImageButton") then
			hovering = true
			break
		end
	end
	local size = hovering and 38 or 26
	Ring.Size = Ring.Size:Lerp(UDim2.new(0, size, 0, size), math.clamp(dt * 12, 0, 1))
end)

UserInputService.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 and CursorGui.Enabled then
		Ring.Size = UDim2.new(0, 14, 0, 14)
	end
end)

Library:OnUnload(function()
	loop:Disconnect()
	CursorGui:Destroy()
	Blur:Destroy()
	DimGui:Destroy()
	UserInputService.MouseIconEnabled = oldMouseIcon
end)

return Library
