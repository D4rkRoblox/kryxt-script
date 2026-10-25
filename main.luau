local LIB_URL = "https://raw.githubusercontent.com/D4rkRoblox/kryxt-script/refs/heads/main/libary.luau"

local Library = loadstring(game:HttpGet(LIB_URL))()
local ThemeManager = Library.ThemeManager
local SaveManager = Library.SaveManager

local Window = Library:CreateWindow({
	Title = "My Hub",
	Center = true,
	AutoShow = true,
	TabPadding = 8,
	MenuFadeTime = 0.2
})

local Tabs = {
	Main = Window:AddTab("Main"),
	Settings = Window:AddTab("Settings")
}

local Box = Tabs.Main:AddLeftGroupbox("Features")

Box:AddToggle("MyToggle", {
	Text = "Toggle",
	Default = false,
	Callback = function(value)
		print(value)
	end
})

Box:AddSlider("MySlider", {
	Text = "Slider",
	Default = 16,
	Min = 0,
	Max = 100,
	Rounding = 0,
	Callback = function(value)
		print(value)
	end
})

Box:AddDropdown("MyDropdown", {
	Values = {"One", "Two", "Three"},
	Default = 1,
	Multi = false,
	Text = "Dropdown",
	Callback = function(value)
		print(value)
	end
})

Box:AddButton({
	Text = "Button",
	Func = function()
		Library:Notify("Clicked", 3)
	end
})

Box:AddLabel("Keybind"):AddKeyPicker("MyKey", {
	Default = "RightShift",
	Mode = "Toggle",
	Text = "Menu key",
	NoUI = false
})

Box:AddLabel("Color"):AddColorPicker("MyColor", {
	Default = Color3.fromRGB(255, 0, 0),
	Title = "Color"
})

local MenuBox = Tabs.Settings:AddLeftGroupbox("Menu")

MenuBox:AddButton("Unload", function()
	Library:Unload()
end)

MenuBox:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {
	Default = "End",
	NoUI = true,
	Text = "Menu keybind"
})

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({"MenuKeybind"})
ThemeManager:SetFolder("MyHub")
SaveManager:SetFolder("MyHub/configs")
SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)
SaveManager:LoadAutoloadConfig()
