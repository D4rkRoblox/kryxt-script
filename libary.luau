local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local CoreGui = game:GetService("CoreGui")

local repo = "https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/"

local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
Library.ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
Library.SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

Library.FontColor = Color3.fromHex("ffffff")
Library.MainColor = Color3.fromHex("1a1012")
Library.AccentColor = Color3.fromHex("e03a4a")
Library.AccentColorDark = Library:GetDarkerColor(Library.AccentColor)
Library.BackgroundColor = Color3.fromHex("140b0d")
Library.OutlineColor = Color3.fromHex("3a1a20")
Library.RiskColor = Color3.fromHex("ff7425")
Library.CursorColor = Color3.fromHex("e03a4a")

Library.ShowCustomCursor = false
Library.BlurEnabled = true
Library.BlurSize = 15
Library.BackColor = Color3.fromHex("000000")
Library.BackTransparency = 0.7
Library.CursorEnabled = true

local function getGuiParent()
	local ok, parent = pcall(function()
		if gethui then
			return gethui()
		end
		return CoreGui
	end)
	if ok and parent then
		return parent
	end
	return Players.LocalPlayer:WaitForChild("PlayerGui")
end

local function protect(gui)
	if syn and syn.protect_gui then
		pcall(syn.protect_gui, gui)
	elseif protect_gui then
		pcall(protect_gui, gui)
	end
end

local function isMenuOpen()
	if Library.Toggled == true then
		return true
	end
	local gui = Library.ScreenGui
	if not gui then
		return false
	end
	for _, child in ipairs(gui:GetChildren()) do
		if child:IsA("Frame") and child.Visible and child.AbsoluteSize.X >= 300 and child.AbsoluteSize.Y >= 200 then
			return true
		end
	end
	return false
end

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
protect(CursorGui)
CursorGui.Parent = getGuiParent()

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
	local open = isMenuOpen()

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
	local inset = GuiService:GetGuiInset()
	local ok, objects = pcall(function()
		return Library.ScreenGui.Parent:GetGuiObjectsAtPosition(m.X - inset.X, m.Y - inset.Y)
	end)
	if ok then
		for _, g in ipairs(objects) do
			if g:IsDescendantOf(Library.ScreenGui) and (g:IsA("TextButton") or g:IsA("TextBox") or g:IsA("ImageButton")) then
				hovering = true
				break
			end
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

local accentGradients = {}
local gradientSpeed = 25

local function near(a, b)
	return math.abs(a.R - b.R) + math.abs(a.G - b.G) + math.abs(a.B - b.B) < 0.02
end

local function decorate(obj)
	if not obj or not obj.Parent or not obj:IsA("Frame") then
		return
	end
	if obj.BackgroundTransparency >= 1 or obj:FindFirstChildOfClass("UIGradient") then
		return
	end
	local c = obj.BackgroundColor3
	if near(c, Library.AccentColor) then
		local g = Instance.new("UIGradient")
		g.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(210, 120, 130)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
		})
		g.Parent = obj
		accentGradients[g] = true
	elseif near(c, Library.MainColor) or near(c, Library.BackgroundColor) then
		local g = Instance.new("UIGradient")
		g.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 100, 108))
		})
		g.Rotation = 90
		g.Parent = obj
	end
end

local function hook(gui)
	if not gui then
		return
	end
	for _, d in ipairs(gui:GetDescendants()) do
		decorate(d)
	end
	gui.DescendantAdded:Connect(function(d)
		task.defer(decorate, d)
	end)
end

hook(Library.ScreenGui)

local gradLoop = RunService.RenderStepped:Connect(function(dt)
	for g in pairs(accentGradients) do
		if g.Parent then
			g.Rotation = (g.Rotation + dt * gradientSpeed) % 360
		else
			accentGradients[g] = nil
		end
	end
end)

local baseCreateWindow = Library.CreateWindow
function Library:CreateWindow(...)
	local window = baseCreateWindow(self, ...)
	task.defer(function()
		hook(Library.ScreenGui)
	end)
	return window
end

Library:OnUnload(function()
	loop:Disconnect()
	gradLoop:Disconnect()
	CursorGui:Destroy()
	Blur:Destroy()
	DimGui:Destroy()
	UserInputService.MouseIconEnabled = oldMouseIcon
end)

return Library
