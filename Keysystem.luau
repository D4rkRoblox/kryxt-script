local env = (getgenv and getgenv()) or _G

if type(env.KeysystemCleanup) == "function" then
	pcall(env.KeysystemCleanup)
	env.KeysystemCleanup = nil
end

do
	local lighting = game:GetService("Lighting")
	for _, name in ipairs({"Blur", "KeyColor", "KeyBloom", "KeyDof", "KeyRays"}) do
		for _, obj in ipairs(lighting:GetChildren()) do
			if obj.Name == name then
				obj:Destroy()
			end
		end
	end
	local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	for _, name in ipairs({"Keysystem", "KeysystemCursor"}) do
		for _, obj in ipairs(playerGui:GetChildren()) do
			if obj.Name == name then
				obj:Destroy()
			end
		end
	end
end

local Key = nil
local KEY_LINK = "https://discord.gg/WQexVWYMk"
local SERVER_URL = "femboy.com lol"

local LOCAL_ADMIN_KEYS = {
	["kryxt-admin-5321-8732-7411"] = true,
	["kryxt-owner-6532-6935-7425"] = true
}

local Blur = Instance.new("BlurEffect")
Blur.Name = "Blur"
Blur.Size = 12
Blur.Enabled = true
Blur.Parent = game:GetService("Lighting")

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera

local ColorFx = Instance.new("ColorCorrectionEffect")
ColorFx.Name = "KeyColor"
ColorFx.Brightness = -0.05
ColorFx.Contrast = 0.15
ColorFx.Saturation = -0.3
ColorFx.TintColor = Color3.fromRGB(255, 200, 200)
ColorFx.Parent = Lighting

local Bloom = Instance.new("BloomEffect")
Bloom.Name = "KeyBloom"
Bloom.Intensity = 0.6
Bloom.Size = 30
Bloom.Threshold = 0.8
Bloom.Parent = Lighting

local Dof = Instance.new("DepthOfFieldEffect")
Dof.Name = "KeyDof"
Dof.FarIntensity = 0.5
Dof.FocusDistance = 0
Dof.InFocusRadius = 0
Dof.NearIntensity = 0.5
Dof.Parent = Lighting

local Rays = Instance.new("SunRaysEffect")
Rays.Name = "KeyRays"
Rays.Intensity = 0.15
Rays.Spread = 0.8
Rays.Parent = Lighting

local oldFov = Camera.FieldOfView
TweenService:Create(Camera, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {FieldOfView = oldFov + 12}):Play()
TweenService:Create(Blur, TweenInfo.new(1.5), {Size = 20}):Play()

local pulse = TweenService:Create(Bloom, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Intensity = 1.2})
pulse:Play()

local hue = 0
local rainbow = RunService.RenderStepped:Connect(function(dt)
	hue = (hue + dt * 0.1) % 1
	ColorFx.TintColor = Color3.fromHSV(hue, 0.25, 1)
end)

local UserInputService = game:GetService("UserInputService")
local oldMouseIcon = UserInputService.MouseIconEnabled
UserInputService.MouseIconEnabled = false

local CursorGui = Instance.new("ScreenGui")
CursorGui.Name = "KeysystemCursor"
CursorGui.IgnoreGuiInset = true
CursorGui.DisplayOrder = 999999
CursorGui.ResetOnSpawn = false
CursorGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
CursorGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

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
RingStroke.Color = Color3.fromRGB(167, 71, 71)

local ringPos = UserInputService:GetMouseLocation()
local cursorLoop = RunService.RenderStepped:Connect(function(dt)
	local m = UserInputService:GetMouseLocation()
	UserInputService.MouseIconEnabled = false
	ringPos = ringPos:Lerp(m, math.clamp(dt * 14, 0, 1))
	Dot.Position = UDim2.new(0, m.X, 0, m.Y)
	Ring.Position = UDim2.new(0, ringPos.X, 0, ringPos.Y)
	local hovering = false
	for _, g in ipairs(game:GetService("Players").LocalPlayer.PlayerGui:GetGuiObjectsAtPosition(m.X, m.Y - 36)) do
		if g:IsA("TextButton") or g:IsA("TextBox") then
			hovering = true
			break
		end
	end
	local size = hovering and 38 or 26
	Ring.Size = Ring.Size:Lerp(UDim2.new(0, size, 0, size), math.clamp(dt * 12, 0, 1))
end)

UserInputService.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 and Ring.Parent then
		Ring.Size = UDim2.new(0, 14, 0, 14)
	end
end)

local function clearEffects()
	cursorLoop:Disconnect()
	CursorGui:Destroy()
	UserInputService.MouseIconEnabled = oldMouseIcon
	rainbow:Disconnect()
	pulse:Cancel()
	TweenService:Create(Camera, TweenInfo.new(0.8), {FieldOfView = oldFov}):Play()
	for _, fx in ipairs({Blur, ColorFx, Bloom, Dof, Rays}) do
		if fx and fx.Parent then
			fx:Destroy()
		end
	end
end

local UI = {}

UI["1"] = Instance.new("ScreenGui", game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"))
UI["1"]["Name"] = [[Keysystem]]
UI["1"]["ZIndexBehavior"] = Enum.ZIndexBehavior.Sibling

UI["2"] = Instance.new("Frame", UI["1"])
UI["2"]["BorderSizePixel"] = 4
UI["2"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
UI["2"]["Size"] = UDim2.new(0, 300, 0, 142)
UI["2"]["Position"] = UDim2.new(0.41359, 0, 0.43632, 0)
UI["2"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)

UI["3"] = Instance.new("TextLabel", UI["2"])
UI["3"]["BorderSizePixel"] = 0
UI["3"]["TextSize"] = 18
UI["3"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
UI["3"]["TextColor3"] = Color3.fromRGB(153, 153, 153)
UI["3"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal)
UI["3"]["Size"] = UDim2.new(0, 78, 0, 19)
UI["3"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
UI["3"]["Text"] = [[Keysystem]]
UI["3"]["Position"] = UDim2.new(0.367, 0, 0.037, 0)

UI["4"] = Instance.new("UIStroke", UI["2"])
UI["4"]["Thickness"] = 1.4
UI["4"]["Color"] = Color3.fromRGB(167, 71, 71)
UI["4"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border

UI["5"] = Instance.new("UICorner", UI["2"])
UI["5"]["BottomRightRadius"] = UDim.new(0, 1)
UI["5"]["BottomLeftRadius"] = UDim.new(0, 1)
UI["5"]["TopRightRadius"] = UDim.new(0, 1)
UI["5"]["TopLeftRadius"] = UDim.new(0, 1)
UI["5"]["CornerRadius"] = UDim.new(0, 1)

UI["6"] = Instance.new("Frame", UI["1"])
UI["6"]["BorderSizePixel"] = 0
UI["6"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
UI["6"]["Size"] = UDim2.new(0, 282, 0, 100)
UI["6"]["Position"] = UDim2.new(0.42013, 0, 0.47415, 0)
UI["6"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)

UI["7"] = Instance.new("TextBox", UI["6"])
UI["7"]["CursorPosition"] = -1
UI["7"]["PlaceholderColor3"] = Color3.fromRGB(153, 153, 153)
UI["7"]["BorderSizePixel"] = 0
UI["7"]["TextSize"] = 14
UI["7"]["TextColor3"] = Color3.fromRGB(153, 153, 153)
UI["7"]["BackgroundColor3"] = Color3.fromRGB(39, 39, 39)
UI["7"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal)
UI["7"]["PlaceholderText"] = [[Insert Key]]
UI["7"]["Size"] = UDim2.new(0, 263, 0, 30)
UI["7"]["Position"] = UDim2.new(0.03191, 0, 0.19, 0)
UI["7"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
UI["7"]["Text"] = [[]]
UI["7"]["ClearTextOnFocus"] = false

UI["8"] = Instance.new("UICorner", UI["7"])
UI["8"]["BottomRightRadius"] = UDim.new(0, 1)
UI["8"]["BottomLeftRadius"] = UDim.new(0, 1)
UI["8"]["TopRightRadius"] = UDim.new(0, 1)
UI["8"]["TopLeftRadius"] = UDim.new(0, 1)
UI["8"]["CornerRadius"] = UDim.new(0, 1)

UI["9"] = Instance.new("TextButton", UI["6"])
UI["9"]["BorderSizePixel"] = 0
UI["9"]["TextSize"] = 14
UI["9"]["TextColor3"] = Color3.fromRGB(153, 153, 153)
UI["9"]["BackgroundColor3"] = Color3.fromRGB(39, 39, 39)
UI["9"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal)
UI["9"]["Size"] = UDim2.new(0, 151, 0, 23)
UI["9"]["BorderColor3"] = Color3.fromRGB(236, 236, 236)
UI["9"]["Text"] = [[Get Key]]
UI["9"]["Position"] = UDim2.new(0.2305, 0, 0.67, 0)

UI["a"] = Instance.new("UICorner", UI["9"])
UI["a"]["BottomRightRadius"] = UDim.new(0, 1)
UI["a"]["BottomLeftRadius"] = UDim.new(0, 1)
UI["a"]["TopRightRadius"] = UDim.new(0, 1)
UI["a"]["TopLeftRadius"] = UDim.new(0, 1)
UI["a"]["CornerRadius"] = UDim.new(0, 1)

UI["b"] = Instance.new("UIStroke", UI["6"])
UI["b"]["Thickness"] = 1.4
UI["b"]["Color"] = Color3.fromRGB(35, 35, 35)

UI["c"] = Instance.new("UICorner", UI["6"])
UI["c"]["BottomRightRadius"] = UDim.new(0, 1)
UI["c"]["BottomLeftRadius"] = UDim.new(0, 1)
UI["c"]["TopRightRadius"] = UDim.new(0, 1)
UI["c"]["TopLeftRadius"] = UDim.new(0, 1)
UI["c"]["CornerRadius"] = UDim.new(0, 1)

local function closeAll()
	pcall(function()
		UI["1"]:Destroy()
	end)
	pcall(clearEffects)
	env.KeysystemCleanup = nil
end

env.KeysystemCleanup = closeAll

local function showError(text)
	UI["7"].Text = ""
	UI["7"].PlaceholderText = text
	task.wait(1.5)
	if UI["7"] and UI["7"].Parent then
		UI["7"].PlaceholderText = "Insert Key"
	end
end

local function hasHttpGet()
	local ok, fn = pcall(function()
		return game.HttpGet
	end)
	return ok and type(fn) == "function"
end

UI["7"].FocusLost:Connect(function(enterPressed)
	if not enterPressed then return end

	local entered = UI["7"].Text:gsub("^%s+", ""):gsub("%s+$", "")
	local HttpService = game:GetService("HttpService")

	if type(loadstring) ~= "function" then
		showError("Executor not supported!")
		return
	end

	if LOCAL_ADMIN_KEYS[entered] then
		if not hasHttpGet() then
			showError("Executor not supported!")
			return
		end
		Key = entered
		closeAll()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/D4rkRoblox/kryxt-script/refs/heads/main/main.luau"))()
		return
	end

	local req = (syn and syn.request) or (http and http.request) or request
	if not req then
		showError("Executor not supported!")
		return
	end

	local success, response = pcall(function()
		return req({
			Url = SERVER_URL,
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json"
			},
			Body = HttpService:JSONEncode({
				key = entered
			})
		})
	end)

	if success and response.StatusCode == 200 then
		local dataSuccess, data = pcall(function()
			return HttpService:JSONDecode(response.Body)
		end)
		
		if dataSuccess and data.success == true then
			Key = entered
			closeAll()

			local mainScript = loadstring(data.script)
			mainScript()
			return
		end
	end

	showError("Wrong Key!")
end)

UI["9"].MouseButton1Click:Connect(function()
	if setclipboard then
		setclipboard(KEY_LINK)
		UI["9"].Text = "Link copied!"
	else
		UI["9"].Text = KEY_LINK
	end
	task.wait(2)
	if UI["9"] and UI["9"].Parent then
		UI["9"].Text = "Get Key"
	end
end)

return UI["1"], require;
