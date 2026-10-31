local LIBRARY = "https://raw.githubusercontent.com/omerkasd/EasySoftware/refs/heads/main/EasyLibrary/"
local LOGO = "rbxassetid://72745420281903"
local info = shared.EasyAuth or {}

local Loading = loadstring(game:HttpGet(LIBRARY .. "loading.lua"))()
local Library

Loading.new({
	Title = "EasyCheatz",
	Subtitle = "Test Build",
	Logo = LOGO,
	Steps = { "Checking key", "Loading library", "Building interface", "Finishing up" },
}):Run({
	function(progress)
		for i = 1, 5 do
			task.wait(0.12)
			progress(i / 5)
		end
	end,
	function()
		Library = loadstring(game:HttpGet(LIBRARY .. "main.lua"))()
	end,
	function()
		task.wait(0.4)
	end,
	function()
		task.wait(0.3)
	end,
})

if not Library then
	return
end

local function remaining(iso)
	if not iso then
		return "Never, lifetime key"
	end
	local ok, at = pcall(DateTime.fromIsoDate, iso)
	if not ok or not at then
		return "Unknown"
	end
	local left = at.UnixTimestamp - os.time()
	if left <= 0 then
		return "Expired"
	end
	local days = math.floor(left / 86400)
	local hours = math.floor(left % 86400 / 3600)
	local minutes = math.floor(left % 3600 / 60)
	if days > 0 then
		return string.format("in %dd %dh", days, hours)
	end
	if hours > 0 then
		return string.format("in %dh %dm", hours, minutes)
	end
	return string.format("in %dm", math.max(minutes, 1))
end

local Window = Library:CreateWindow({
	Title = "EasyCheatz",
	Logo = LOGO,
})

local Home = Window:AddTab({ Name = "Home", Icon = "home" })

local KeyBox = Home:AddLeftGroupbox("Your Key")
KeyBox:AddParagraph({ Title = "Type", Content = info.kind == "free" and "Free key" or "Paid key" })
KeyBox:AddParagraph({ Title = "Plan", Content = info.plan or "Unknown" })
local expiry = KeyBox:AddLabel("Expires " .. remaining(info.expiresAt))
KeyBox:AddButton({
	Text = "Copy Key",
	Callback = function()
		local copy = setclipboard or toclipboard
		if copy and info.key then
			copy(info.key)
			Library:Notify({ Title = "Copied", Content = "Your key is on the clipboard.", Type = "Success", Duration = 3 })
		else
			Library:Notify({ Title = "Not supported", Content = "Your executor can't copy to the clipboard.", Type = "Warning", Duration = 3 })
		end
	end,
})

local TestBox = Home:AddRightGroupbox("Test Elements")
TestBox:AddToggle("TestToggle", {
	Text = "Test Toggle",
	Default = false,
	Callback = function(value)
		Library:Notify({ Title = "Toggle", Content = value and "Turned on" or "Turned off", Type = "Info", Duration = 2 })
	end,
})
TestBox:AddSlider("TestSlider", {
	Text = "Test Slider",
	Min = 0,
	Max = 100,
	Default = 50,
	Increment = 1,
	Suffix = "%",
})
TestBox:AddDropdown("TestDropdown", {
	Text = "Test Dropdown",
	Values = { "First", "Second", "Third" },
	Default = 1,
})
TestBox:AddButton({
	Text = "Send Notification",
	Variant = "Primary",
	Callback = function()
		Library:Notify({ Title = "It works", Content = "The script was delivered by the key server.", Type = "Success", Duration = 4 })
	end,
})

task.spawn(function()
	while not Library.Unloaded do
		task.wait(30)
		if Library.Unloaded then
			break
		end
		expiry:SetText("Expires " .. remaining(info.expiresAt))
	end
end)

Library:Notify({
	Title = "EasyCheatz loaded",
	Content = "Key accepted. Press RightShift to hide the menu.",
	Type = "Success",
	Duration = 5,
})
