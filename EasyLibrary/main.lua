local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

local function defaultParent()
	if typeof(gethui) == "function" then
		local ok, container = pcall(gethui)
		if ok and typeof(container) == "Instance" then
			return container
		end
	end
	local ok, core = pcall(function()
		local service = game:GetService("CoreGui")
		local probe = Instance.new("Folder")
		probe.Parent = service
		probe:Destroy()
		return service
	end)
	if ok and core then
		return core
	end
	return LocalPlayer:WaitForChild("PlayerGui")
end

local THEMES = {
	Dark = {
		bg = Color3.fromHex("0C0C0E"),
		side = Color3.fromHex("101013"),
		box = Color3.fromHex("17171B"),
		el = Color3.fromHex("1F1F24"),
		el2 = Color3.fromHex("29292F"),
		line = Color3.fromHex("24242A"),
		line2 = Color3.fromHex("34343C"),
		tx = Color3.fromHex("EDEDF0"),
		tx2 = Color3.fromHex("A6A6B0"),
		tx3 = Color3.fromHex("85858F"),
		segOn = Color3.fromHex("36363E"),
		knobOff = Color3.fromHex("85858F"),
		boxFlat = Color3.fromHex("121216"),
		lineStrong = Color3.fromHex("2A2A32"),
		danger = Color3.fromHex("FF6B6B"),
		ok = Color3.fromHex("3DCB7A"),
		info = Color3.fromHex("4C8DFF"),
		warn = Color3.fromHex("F5B941"),
	},
	Light = {
		bg = Color3.fromHex("F4F4F2"),
		side = Color3.fromHex("EDEDEA"),
		box = Color3.fromHex("FFFFFF"),
		el = Color3.fromHex("F1F1EE"),
		el2 = Color3.fromHex("E6E6E2"),
		line = Color3.fromHex("E3E3DF"),
		line2 = Color3.fromHex("D1D1CC"),
		tx = Color3.fromHex("16161A"),
		tx2 = Color3.fromHex("52525B"),
		tx3 = Color3.fromHex("686871"),
		segOn = Color3.fromHex("FFFFFF"),
		knobOff = Color3.fromHex("9A9AA2"),
		boxFlat = Color3.fromHex("F8F8F6"),
		lineStrong = Color3.fromHex("D5D5D0"),
		danger = Color3.fromHex("C93439"),
		ok = Color3.fromHex("1F9D57"),
		info = Color3.fromHex("2F6FE0"),
		warn = Color3.fromHex("B7791F"),
	},
}

local FONT_NAMES = {
	"Ubuntu",
	"Montserrat",
	"Roboto",
	"Nunito",
	"Oswald",
	"Josefin Sans",
	"Titillium Web",
	"Source Sans",
	"Arimo",
	"Jura",
	"Michroma",
	"Sarpanch",
	"Merriweather",
	"Roboto Mono",
	"Code",
	"Arcade",
	"Builder Sans",
	"Gotham",
}

local FONTS = {
	["Ubuntu"] = Enum.Font.Ubuntu,
	["Montserrat"] = Enum.Font.Montserrat,
	["Roboto"] = Enum.Font.Roboto,
	["Nunito"] = Enum.Font.Nunito,
	["Oswald"] = Enum.Font.Oswald,
	["Josefin Sans"] = Enum.Font.JosefinSans,
	["Titillium Web"] = Enum.Font.TitilliumWeb,
	["Source Sans"] = Enum.Font.SourceSans,
	["Arimo"] = Enum.Font.Arimo,
	["Jura"] = Enum.Font.Jura,
	["Michroma"] = Enum.Font.Michroma,
	["Sarpanch"] = Enum.Font.Sarpanch,
	["Merriweather"] = Enum.Font.Merriweather,
	["Roboto Mono"] = Enum.Font.RobotoMono,
	["Code"] = Enum.Font.Code,
	["Arcade"] = Enum.Font.Arcade,
	["Builder Sans"] = Enum.Font.BuilderSans,
	["Gotham"] = Enum.Font.Gotham,
}

local SWATCHES = {
	Color3.fromHex("7C5CFF"),
	Color3.fromHex("FF6B35"),
	Color3.fromHex("4C8DFF"),
	Color3.fromHex("2ED3A0"),
	Color3.fromHex("F5B941"),
	Color3.fromHex("FF5C8A"),
}

local KEY_NAMES = {
	RightShift = "RShift",
	LeftShift = "LShift",
	RightControl = "RCtrl",
	LeftControl = "LCtrl",
	RightAlt = "RAlt",
	LeftAlt = "LAlt",
	Insert = "Ins",
	Delete = "Del",
	PageUp = "PgUp",
	PageDown = "PgDn",
	Return = "Enter",
	Backspace = "Bksp",
	CapsLock = "Caps",
	Space = "Space",
	MouseButton2 = "MB2",
	MouseButton3 = "MB3",
}

local WHITE = Color3.new(1, 1, 1)
local BLACK = Color3.new(0, 0, 0)
local DARK_TEXT = Color3.fromHex("111113")

local Style = Enum.EasingStyle
local Direction = Enum.EasingDirection
local MB1 = Enum.UserInputType.MouseButton1
local TOUCH = Enum.UserInputType.Touch
local MOVE = Enum.UserInputType.MouseMovement

local api = {
	isfile = typeof(isfile) == "function" and isfile or nil,
	readfile = typeof(readfile) == "function" and readfile or nil,
	writefile = typeof(writefile) == "function" and writefile or nil,
	delfile = typeof(delfile) == "function" and delfile or nil,
	isfolder = typeof(isfolder) == "function" and isfolder or nil,
	makefolder = typeof(makefolder) == "function" and makefolder or nil,
	listfiles = typeof(listfiles) == "function" and listfiles or nil,
	setclipboard = (typeof(setclipboard) == "function" and setclipboard) or (typeof(toclipboard) == "function" and toclipboard) or nil,
	getclipboard = typeof(getclipboard) == "function" and getclipboard or nil,
}

local Library = {
	Version = "1.3.0",
	Flags = {},
	Options = {},
	Toggles = {},
	Conflicts = {},
	Themes = THEMES,
	Fonts = FONTS,
	FontNames = FONT_NAMES,
	Unloaded = false,
	Device = "PC",
	Density = "Comfortable",
	_order = {},
}

local S = {
	theme = THEMES.Dark,
	themeName = "Dark",
	accent = SWATCHES[1],
	onAccent = DARK_TEXT,
	fontName = "Ubuntu",
	family = Font.fromEnum(Enum.Font.Ubuntu).Family,
	mono = Font.fromEnum(Enum.Font.RobotoMono).Family,
	themed = {},
	fonted = {},
	records = 0,
	pruneQueued = false,
	lucide = nil,
	iconCache = {},
	iconWaiting = {},
	iconsEnabled = true,
	conns = {},
	drags = {},
	unload = {},
	keybinds = {},
	keyMap = {},
	settings = {},
	settingsDirty = {},
	hud = {},
	alCorner = "TopRight",
	wmStats = { fps = 0, ping = -1, time = "--:--" },
	persistSettings = true,
	mobile = false,
	animate = true,
	speed = 1,
	gui = nil,
}

local DENSITY = {
	Comfortable = {
		rWin = 10,
		rBox = 8,
		rCtrl = 6,
		rSmall = 5,
		rTiny = 4,
		rTrack = 3,
		rMobileBtn = 14,
		header = 44,
		nav = 38,
		sideW = 184,
		sideNarrow = 52,
		sideRow = 34,
		groupHeader = 42,
		section = 26,
		subTab = 22,
		toggleRow = 26,
		checkRow = 22,
		checkBox = 16,
		switchW = 32,
		switchH = 18,
		knob = 10,
		knobOn = 18,
		knobOff = 4,
		sliderRow = 36,
		sliderTop = 20,
		track = 6,
		thumb = 14,
		inputBox = 30,
		inputLabel = 22,
		stepperRow = 26,
		stepperValue = 38,
		segmented = 28,
		option = 28,
		button = 30,
		keycap = 20,
		keycapPad = 7,
		badge = 18,
		rBadge = 9,
		gap = 10,
		colGap = 12,
		pagePad = 12,
		padTop = 8,
		padX = 12,
		padBottom = 12,
		fBody = 13,
		fGroup = 14,
		fLabel = 12,
		fSmall = 11,
		fTiny = 10,
		iconSm = 12,
		iconMd = 14,
		iconLg = 16,
		scrollBar = 3,
		width = 880,
		height = 584,
		minW = 420,
		minH = 300,
		narrowAt = 640,
		singleAt = 520,
		hudRow = 18,
		rowGap = 8,
		iconScale = 1,
		boxToken = "box",
		lineToken = "line",
		toggleStyle = "Switch",
	},
	Compact = {
		rWin = 4,
		rBox = 4,
		rCtrl = 3,
		rSmall = 3,
		rTiny = 2,
		rTrack = 2,
		rMobileBtn = 10,
		header = 32,
		nav = 28,
		sideW = 148,
		sideNarrow = 44,
		sideRow = 24,
		groupHeader = 26,
		section = 18,
		subTab = 17,
		toggleRow = 20,
		checkRow = 18,
		checkBox = 13,
		switchW = 24,
		switchH = 13,
		knob = 9,
		knobOn = 13,
		knobOff = 2,
		sliderRow = 24,
		sliderTop = 14,
		track = 4,
		thumb = 9,
		inputBox = 22,
		inputLabel = 14,
		stepperRow = 20,
		stepperValue = 32,
		segmented = 20,
		option = 22,
		button = 22,
		keycap = 15,
		keycapPad = 4,
		badge = 14,
		rBadge = 7,
		gap = 5,
		colGap = 8,
		pagePad = 8,
		padTop = 6,
		padX = 8,
		padBottom = 7,
		fBody = 11,
		fGroup = 10,
		fLabel = 10,
		fSmall = 10,
		fTiny = 9,
		iconSm = 10,
		iconMd = 12,
		iconLg = 12,
		scrollBar = 3,
		width = 720,
		height = 520,
		minW = 360,
		minH = 260,
		narrowAt = 540,
		singleAt = 440,
		hudRow = 14,
		rowGap = 6,
		iconScale = 0.8,
		boxToken = "boxFlat",
		lineToken = "lineStrong",
		toggleStyle = "Checkbox",
	},
}

local MOBILE = {
	groupHeader = 46,
	section = 32,
	toggleRow = 30,
	checkRow = 28,
	checkBox = 18,
	subTab = 26,
	sliderRow = 42,
	thumb = 16,
	inputBox = 34,
	stepperRow = 30,
	segmented = 32,
	option = 32,
	button = 34,
	scrollBar = 4,
}

local D = DENSITY.Comfortable

local function densityName(value)
	local name = tostring(value or "Comfortable")
	if string.lower(name) == "compact" then
		return "Compact"
	end
	return "Comfortable"
end

local function applyDensity(value)
	local name = densityName(value)
	if S.mobile then
		name = "Comfortable"
	end
	local profile = DENSITY[name]
	local out = {}
	for key, v in pairs(profile) do
		out[key] = v
	end
	if S.mobile then
		for key, v in pairs(MOBILE) do
			out[key] = v
		end
	end
	D = out
	S.density = name
	Library.Density = name
end

local function luminance(c)
	local function ch(v)
		if v <= 0.03928 then
			return v / 12.92
		end
		return ((v + 0.055) / 1.055) ^ 2.4
	end
	return 0.2126 * ch(c.R) + 0.7152 * ch(c.G) + 0.0722 * ch(c.B)
end

local DARK_TEXT_LUM = luminance(DARK_TEXT)

local function textOn(c)
	local l = luminance(c)
	local vsWhite = 1.05 / (l + 0.05)
	local vsDark = (l + 0.05) / (DARK_TEXT_LUM + 0.05)
	if vsDark >= vsWhite then
		return DARK_TEXT
	end
	return WHITE
end

local function resolveFont(f)
	if typeof(f) == "Font" then
		return f.Family, "Custom"
	elseif typeof(f) == "EnumItem" then
		return Font.fromEnum(f).Family, f.Name
	end
	local item = FONTS[f]
	if item then
		return Font.fromEnum(item).Family, f
	end
	return Font.fromEnum(Enum.Font.Ubuntu).Family, "Ubuntu"
end

local function merge(base, over)
	local out = {}
	for k, v in pairs(base) do
		out[k] = v
	end
	if type(over) == "table" then
		for k, v in pairs(over) do
			out[k] = v
		end
	end
	return out
end

local function keyLabel(k)
	if k == nil then
		return "None"
	end
	local name = typeof(k) == "EnumItem" and k.Name or tostring(k)
	return KEY_NAMES[name] or name
end

local function keyFromName(name)
	if typeof(name) == "EnumItem" then
		return name
	end
	if type(name) ~= "string" or name == "" or name == "None" then
		return nil
	end
	local ok, key = pcall(function()
		return Enum.KeyCode[name]
	end)
	if ok and key then
		return key
	end
	local okType, inputType = pcall(function()
		return Enum.UserInputType[name]
	end)
	if okType and inputType then
		return inputType
	end
	return nil
end

local function detectDevice(preference)
	local p = string.lower(tostring(preference or "Auto"))
	if p == "mobile" then
		return "Mobile"
	elseif p == "pc" then
		return "PC"
	end
	if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not UserInputService.MouseEnabled then
		return "Mobile"
	end
	return "PC"
end

local function trim(s)
	return (string.gsub(string.gsub(tostring(s or ""), "^%s+", ""), "%s+$", ""))
end

local function template(str, vars)
	return (string.gsub(tostring(str or ""), "{(%w+)}", function(key)
		local value = vars[key]
		if value == nil then
			return "{" .. key .. "}"
		end
		return tostring(value)
	end))
end

local function decimals(step)
	local s = tostring(step)
	local dot = string.find(s, "%.")
	if not dot then
		return 0
	end
	return #s - dot
end

local function snap(value, min, max, step)
	value = math.clamp(value, min, max)
	if step and step > 0 then
		value = min + math.floor((value - min) / step + 0.5) * step
		value = math.clamp(value, min, max)
		local d = decimals(step)
		local m = 10 ^ d
		value = math.floor(value * m + 0.5) / m
	end
	return value
end

local MOUSE_TYPES = {
	[Enum.UserInputType.MouseButton1] = true,
	[Enum.UserInputType.MouseButton2] = true,
	[Enum.UserInputType.MouseButton3] = true,
	[Enum.UserInputType.MouseMovement] = true,
	[Enum.UserInputType.MouseWheel] = true,
}

local function pointer(input)
	local p = input.Position
	if MOUSE_TYPES[input.UserInputType] then
		local m = UserInputService:GetMouseLocation()
		S.pointerOffset = Vector2.new(m.X - p.X, m.Y - p.Y)
		return m
	end
	local off = S.pointerOffset or GuiService:GetGuiInset()
	return Vector2.new(p.X + off.X, p.Y + off.Y)
end

local function pointers(input)
	local p = input.Position
	local inset = GuiService:GetGuiInset()
	local out = { pointer(input), Vector2.new(p.X + inset.X, p.Y + inset.Y), Vector2.new(p.X, p.Y + 36), Vector2.new(p.X, p.Y) }
	return out
end

local function over(gui, pos)
	if not gui or not gui.Visible then
		return false
	end
	local a, s = gui.AbsolutePosition, gui.AbsoluteSize
	return pos.X >= a.X and pos.X <= a.X + s.X and pos.Y >= a.Y and pos.Y <= a.Y + s.Y
end

local function overAny(gui, list)
	for _, pos in ipairs(list) do
		if over(gui, pos) then
			return true
		end
	end
	return false
end

local function camera()
	return Workspace.CurrentCamera
end

local function viewport()
	local cam = camera()
	if cam then
		return cam.ViewportSize
	end
	return Vector2.new(1280, 720)
end

local tok = setmetatable({}, {
	__index = function(t, k)
		local v = { __tok = k }
		rawset(t, k, v)
		return v
	end,
})

local function fontSpec(weight, mono)
	return { __font = weight, mono = mono }
end

local F_REG = fontSpec("Regular")
local F_MED = fontSpec("Medium")
local F_SEMI = fontSpec("SemiBold")
local F_BOLD = fontSpec("Bold")
local F_MONO = fontSpec("Regular", true)

local function fontFor(spec)
	return Font.new(spec.mono and S.mono or S.family, Enum.FontWeight[spec.__font])
end

local function info(time, style, direction, repeatCount, reverses, delay)
	return TweenInfo.new(
		time / S.speed,
		style or Style.Quint,
		direction or Direction.Out,
		repeatCount or 0,
		reverses or false,
		(delay or 0) / S.speed
	)
end

local function quick()
	return info(0.16, Style.Quad, Direction.Out)
end

local function smooth()
	return info(0.3, Style.Quint, Direction.Out)
end

local function pop()
	return info(0.38, Style.Back, Direction.Out)
end

local function tween(inst, ti, goal)
	if not S.animate then
		for k, v in pairs(goal) do
			inst[k] = v
		end
		return nil
	end
	local t = TweenService:Create(inst, ti, goal)
	t:Play()
	return t
end

local function color(token)
	if token == "accent" then
		return S.accent
	elseif token == "accentHover" then
		return S.accent:Lerp(WHITE, 0.12)
	elseif token == "onAccent" then
		return S.onAccent
	elseif token == "white" then
		return WHITE
	elseif token == "black" then
		return BLACK
	end
	return S.theme[token] or THEMES.Dark[token] or WHITE
end

local function prune()
	S.pruneQueued = false
	for inst in pairs(S.themed) do
		if inst.Parent == nil then
			S.themed[inst] = nil
		end
	end
	for inst in pairs(S.fonted) do
		if inst.Parent == nil then
			S.fonted[inst] = nil
		end
	end
end

local function tally()
	S.records = S.records + 1
	if S.records % 1500 == 0 and not S.pruneQueued then
		S.pruneQueued = true
		task.defer(prune)
	end
end

local function record(inst, prop, token)
	local map = S.themed[inst]
	if not map then
		map = {}
		S.themed[inst] = map
		tally()
	end
	map[prop] = token
end

local function bind(inst, prop, token)
	record(inst, prop, token)
	inst[prop] = color(token)
end

local function bindTween(inst, prop, token, ti)
	record(inst, prop, token)
	return tween(inst, ti or quick(), { [prop] = color(token) })
end

local function paint(inst, prop, token, animated)
	if animated then
		bindTween(inst, prop, token)
	else
		bind(inst, prop, token)
	end
end

local function applyColors()
	for inst, map in pairs(S.themed) do
		for prop, token in pairs(map) do
			inst[prop] = color(token)
		end
	end
end

local function applyFonts()
	for inst, spec in pairs(S.fonted) do
		inst.FontFace = fontFor(spec)
	end
end

local function new(class, props, parent)
	local inst = Instance.new(class)
	for k, v in pairs(props) do
		if type(v) == "table" then
			if v.__tok then
				bind(inst, k, v.__tok)
			elseif v.__font then
				if not S.fonted[inst] then
					tally()
				end
				S.fonted[inst] = v
				inst[k] = fontFor(v)
			end
		else
			inst[k] = v
		end
	end
	if parent then
		inst.Parent = parent
	end
	return inst
end

local function frame(props, parent)
	props.BorderSizePixel = 0
	if props.BackgroundColor3 == nil and props.BackgroundTransparency == nil then
		props.BackgroundTransparency = 1
	end
	return new("Frame", props, parent)
end

local function label(props, parent)
	props.BackgroundTransparency = 1
	props.BorderSizePixel = 0
	props.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
	props.TextYAlignment = props.TextYAlignment or Enum.TextYAlignment.Center
	props.TextSize = props.TextSize or D.fBody
	props.FontFace = props.FontFace or F_REG
	props.TextColor3 = props.TextColor3 or tok.tx
	if props.TextTruncate == nil and not props.TextWrapped then
		props.TextTruncate = Enum.TextTruncate.AtEnd
	end
	return new("TextLabel", props, parent)
end

local function button(props, parent)
	props.BorderSizePixel = 0
	props.AutoButtonColor = false
	props.Text = props.Text or ""
	if props.BackgroundColor3 == nil and props.BackgroundTransparency == nil then
		props.BackgroundTransparency = 1
	end
	return new("TextButton", props, parent)
end

local function corner(parent, radius)
	if radius == nil then
		radius = UDim.new(0.5, 0)
	elseif type(radius) == "number" then
		radius = UDim.new(0, radius)
	end
	return new("UICorner", { CornerRadius = radius }, parent)
end

local function stroke(parent, token, thickness, transparency)
	return new("UIStroke", {
		Color = tok[token],
		Thickness = thickness or 1,
		Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, parent)
end

local function pad(parent, top, right, bottom, left)
	return new("UIPadding", {
		PaddingTop = UDim.new(0, top or 0),
		PaddingRight = UDim.new(0, right or top or 0),
		PaddingBottom = UDim.new(0, bottom or top or 0),
		PaddingLeft = UDim.new(0, left or right or top or 0),
	}, parent)
end

local function list(parent, horizontal, gap, hAlign, vAlign)
	return new("UIListLayout", {
		FillDirection = horizontal and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, gap or 0),
		HorizontalAlignment = hAlign or Enum.HorizontalAlignment.Left,
		VerticalAlignment = vAlign or Enum.VerticalAlignment.Top,
	}, parent)
end

local function fill(inst)
	return new("UIFlexItem", { FlexMode = Enum.UIFlexMode.Fill }, inst)
end

local function connect(signal, f)
	local c = signal:Connect(f)
	local bucket = S.collect or S.conns
	bucket[#bucket + 1] = c
	return c
end

local function hover(target, f)
	if S.mobile then
		if not target:IsA("GuiButton") then
			return
		end
		connect(target.MouseButton1Down, function()
			f(true)
		end)
		connect(target.MouseButton1Up, function()
			f(false)
		end)
		connect(target.MouseLeave, function()
			f(false)
		end)
		return
	end
	connect(target.MouseEnter, function()
		f(true)
	end)
	connect(target.MouseLeave, function()
		f(false)
	end)
end

local function press(target, amount)
	local scale = new("UIScale", {}, target)
	connect(target.MouseButton1Down, function()
		tween(scale, quick(), { Scale = amount or 0.97 })
	end)
	local function release()
		tween(scale, quick(), { Scale = 1 })
	end
	connect(target.MouseButton1Up, release)
	connect(target.MouseLeave, release)
	return scale
end

local function track(target, handlers)
	return connect(target.InputBegan, function(input)
		local t = input.UserInputType
		if t ~= MB1 and t ~= TOUCH then
			return
		end
		local start = pointer(input)
		if handlers.filter and not handlers.filter(start) then
			return
		end
		local entry = {}
		local function finish()
			if entry.done then
				return
			end
			entry.done = true
			if entry.move then
				entry.move:Disconnect()
			end
			if entry.state then
				entry.state:Disconnect()
			end
			S.drags[entry] = nil
			if handlers.stop then
				handlers.stop()
			end
		end
		entry.finish = finish
		entry.move = UserInputService.InputChanged:Connect(function(change)
			if change == input or (t == MB1 and change.UserInputType == MOVE) then
				if target.Parent == nil then
					finish()
					return
				end
				if handlers.move then
					handlers.move(pointer(change))
				end
			end
		end)
		entry.state = input.Changed:Connect(function()
			local st = input.UserInputState
			if st == Enum.UserInputState.End or st == Enum.UserInputState.Cancel then
				finish()
			end
		end)
		S.drags[entry] = true
		if handlers.start then
			handlers.start(start)
		end
	end)
end

local function iconLine(parts, parent, x1, y1, x2, y2, t)
	t = t or 1.75
	local dx, dy = x2 - x1, y2 - y1
	local f = frame({
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset((x1 + x2) / 2, (y1 + y2) / 2),
		Size = UDim2.fromOffset(math.sqrt(dx * dx + dy * dy) + t, t),
		Rotation = math.deg(math.atan2(dy, dx)),
		BackgroundColor3 = WHITE,
	}, parent)
	corner(f)
	parts[#parts + 1] = { f, "BackgroundColor3" }
	return f
end

local function iconDot(parts, parent, x, y, d)
	local f = frame({
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(x, y),
		Size = UDim2.fromOffset(d, d),
		BackgroundColor3 = WHITE,
	}, parent)
	corner(f)
	parts[#parts + 1] = { f, "BackgroundColor3" }
	return f
end

local function iconRing(parts, parent, x, y, w, h, radius, t)
	t = t or 1.75
	local f = frame({
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(x, y),
		Size = UDim2.fromOffset(w - t * 2, h - t * 2),
	}, parent)
	corner(f, radius)
	local s = new("UIStroke", { Thickness = t, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = WHITE }, f)
	parts[#parts + 1] = { s, "Color" }
	return f
end

local ICONS = {
	home = function(p, h)
		iconLine(p, h, 2, 7.5, 8, 2.5)
		iconLine(p, h, 8, 2.5, 14, 7.5)
		iconLine(p, h, 3.5, 7, 3.5, 13.5)
		iconLine(p, h, 12.5, 7, 12.5, 13.5)
		iconLine(p, h, 3.5, 13.5, 12.5, 13.5)
		iconLine(p, h, 8, 13.5, 8, 10)
	end,
	user = function(p, h)
		iconRing(p, h, 8, 5, 7.5, 7.5)
		local clip = frame({ Size = UDim2.fromOffset(16, 14.5), ClipsDescendants = true }, h)
		iconRing(p, clip, 8, 15.5, 13, 10)
	end,
	eye = function(p, h)
		iconRing(p, h, 8, 8, 15, 10)
		iconDot(p, h, 8, 8, 4.5)
	end,
	grid = function(p, h)
		iconRing(p, h, 4.5, 4.5, 6, 6, 1.5)
		iconRing(p, h, 11.5, 4.5, 6, 6, 1.5)
		iconRing(p, h, 4.5, 11.5, 6, 6, 1.5)
		iconRing(p, h, 11.5, 11.5, 6, 6, 1.5)
	end,
	settings = function(p, h)
		iconLine(p, h, 2, 4, 14, 4)
		iconLine(p, h, 2, 8, 14, 8)
		iconLine(p, h, 2, 12, 14, 12)
		iconDot(p, h, 10.5, 4, 4.5)
		iconDot(p, h, 5, 8, 4.5)
		iconDot(p, h, 11, 12, 4.5)
	end,
	target = function(p, h)
		iconRing(p, h, 8, 8, 12, 12)
		iconDot(p, h, 8, 8, 3.5)
		iconLine(p, h, 8, 0.5, 8, 2.5)
		iconLine(p, h, 8, 13.5, 8, 15.5)
		iconLine(p, h, 0.5, 8, 2.5, 8)
		iconLine(p, h, 13.5, 8, 15.5, 8)
	end,
	code = function(p, h)
		iconLine(p, h, 5.5, 4, 2, 8)
		iconLine(p, h, 2, 8, 5.5, 12)
		iconLine(p, h, 10.5, 4, 14, 8)
		iconLine(p, h, 14, 8, 10.5, 12)
	end,
	list = function(p, h)
		for _, y in ipairs({ 4, 8, 12 }) do
			iconDot(p, h, 2.5, y, 2.5)
			iconLine(p, h, 6, y, 14, y)
		end
	end,
	sword = function(p, h)
		iconLine(p, h, 5, 11, 13.5, 2.5)
		iconLine(p, h, 3, 9, 7, 13)
		iconLine(p, h, 2, 14, 4.5, 11.5)
	end,
	bolt = function(p, h)
		iconLine(p, h, 9.5, 1.5, 4.5, 8.5)
		iconLine(p, h, 4.5, 8.5, 11.5, 7.5)
		iconLine(p, h, 11.5, 7.5, 6.5, 14.5)
	end,
	info = function(p, h)
		iconRing(p, h, 8, 8, 14.5, 14.5)
		iconLine(p, h, 8, 7.5, 8, 11.5)
		iconDot(p, h, 8, 4.9, 2)
	end,
	box = function(p, h)
		iconRing(p, h, 8, 4.5, 15, 4.5, 1)
		iconRing(p, h, 8, 10.5, 13, 8.5, 1.5)
		iconLine(p, h, 6.5, 9, 9.5, 9)
	end,
	keyboard = function(p, h)
		iconRing(p, h, 8, 8, 15, 10.5, 2)
		iconDot(p, h, 4.5, 6.5, 1.8)
		iconDot(p, h, 8, 6.5, 1.8)
		iconDot(p, h, 11.5, 6.5, 1.8)
		iconLine(p, h, 5, 10.5, 11, 10.5)
	end,
	folder = function(p, h)
		iconRing(p, h, 8, 9, 14.5, 10.5, 2)
		iconLine(p, h, 2.5, 3.5, 6.5, 3.5)
	end,
	search = function(p, h)
		iconRing(p, h, 7, 7, 10.5, 10.5)
		iconLine(p, h, 10.5, 10.5, 14, 14)
	end,
	close = function(p, h)
		iconLine(p, h, 4, 4, 12, 12)
		iconLine(p, h, 12, 4, 4, 12)
	end,
	minimize = function(p, h)
		iconLine(p, h, 3.5, 8, 12.5, 8)
	end,
	chevron = function(p, h)
		iconLine(p, h, 4, 6, 8, 10)
		iconLine(p, h, 8, 10, 12, 6)
	end,
	check = function(p, h)
		iconLine(p, h, 3.5, 8.5, 6.5, 11.5, 2)
		iconLine(p, h, 6.5, 11.5, 12.5, 4.5, 2)
	end,
	plus = function(p, h)
		iconLine(p, h, 8, 3, 8, 13, 2)
		iconLine(p, h, 3, 8, 13, 8, 2)
	end,
	minus = function(p, h)
		iconLine(p, h, 3, 8, 13, 8, 2)
	end,
	file = function(p, h)
		iconRing(p, h, 8, 8, 11.5, 14.5, 2)
		iconLine(p, h, 5.75, 6, 10.25, 6)
		iconLine(p, h, 5.75, 9.5, 10.25, 9.5)
	end,
	clock = function(p, h)
		iconRing(p, h, 8, 8, 14.5, 14.5)
		iconLine(p, h, 8, 4.5, 8, 8)
		iconLine(p, h, 8, 8, 10.5, 9.5)
	end,
	alert = function(p, h)
		iconRing(p, h, 8, 8, 14.5, 14.5)
		iconLine(p, h, 8, 4.5, 8, 8.8)
		iconDot(p, h, 8, 11.3, 2)
	end,
	trash = function(p, h)
		iconRing(p, h, 8, 9.5, 10, 11.5, 1.5)
		iconLine(p, h, 2.5, 3.8, 13.5, 3.8)
		iconLine(p, h, 6, 1.8, 10, 1.8)
	end,
	image = function(p, h)
		iconRing(p, h, 8, 8, 15, 13, 2)
		iconDot(p, h, 5, 5.5, 2.5)
		iconLine(p, h, 3, 12, 6.5, 8.5)
		iconLine(p, h, 6.5, 8.5, 9, 11)
		iconLine(p, h, 9, 11, 11, 9)
		iconLine(p, h, 11, 9, 13.5, 11.5)
	end,
}

local function iconPlaceholder(parts, holder)
	iconRing(parts, holder, 8, 8, 11, 11, 3)
end

Library.Icons = {}
for name in pairs(ICONS) do
	Library.Icons[#Library.Icons + 1] = name
end
table.sort(Library.Icons)

local LUCIDE_URL = "https://github.com/latte-soft/lucide-roblox/releases/download/0.1.3/lucide-roblox.luau"
local ICON_CACHE = "EasyLibrary/cache/icons.json"

local LUCIDE_ALIAS = {
	grid = "layout-grid",
	target = "crosshair",
	sword = "swords",
	bolt = "zap",
	close = "x",
	minimize = "minus",
	chevron = "chevron-down",
	alert = "circle-alert",
	trash = "trash-2",
}

local BUILTIN_ALIAS = {
	["sliders-horizontal"] = "settings",
	["layout-grid"] = "grid",
	crosshair = "target",
	swords = "sword",
	zap = "bolt",
	x = "close",
	["chevron-down"] = "chevron",
	["circle-alert"] = "alert",
	["trash-2"] = "trash",
}

local function ensureFolder(path)
	if not api.isfolder or not api.makefolder then
		return
	end
	local current = ""
	for part in string.gmatch(path, "[^/]+") do
		current = current == "" and part or (current .. "/" .. part)
		local ok, exists = pcall(api.isfolder, current)
		if ok and not exists then
			pcall(api.makefolder, current)
		end
	end
end

local function readIconCache()
	if S.iconCacheRead then
		return
	end
	S.iconCacheRead = true
	if not api.isfile or not api.readfile then
		return
	end
	local ok, exists = pcall(api.isfile, ICON_CACHE)
	if not ok or not exists then
		return
	end
	local okRead, content = pcall(api.readfile, ICON_CACHE)
	if not okRead or type(content) ~= "string" then
		return
	end
	local okDecode, data = pcall(function()
		return HttpService:JSONDecode(content)
	end)
	if not okDecode or type(data) ~= "table" then
		return
	end
	for key, entry in pairs(data) do
		if type(entry) == "table" and type(entry.u) == "string" then
			S.iconCache[key] = {
				Url = entry.u,
				ImageRectOffset = Vector2.new(tonumber(entry.ox) or 0, tonumber(entry.oy) or 0),
				ImageRectSize = Vector2.new(tonumber(entry.sx) or 0, tonumber(entry.sy) or 0),
			}
		end
	end
end

local function queueIconCacheWrite()
	if S.iconWriteQueued or not api.writefile then
		return
	end
	S.iconWriteQueued = true
	task.delay(1, function()
		S.iconWriteQueued = false
		local out = {}
		for key, asset in pairs(S.iconCache) do
			if type(asset) == "table" and type(asset.Url) == "string" then
				out[key] = {
					u = asset.Url,
					ox = asset.ImageRectOffset.X,
					oy = asset.ImageRectOffset.Y,
					sx = asset.ImageRectSize.X,
					sy = asset.ImageRectSize.Y,
				}
			end
		end
		local ok, encoded = pcall(function()
			return HttpService:JSONEncode(out)
		end)
		if ok then
			ensureFolder("EasyLibrary/cache")
			pcall(api.writefile, ICON_CACHE, encoded)
		end
	end)
end

local function fetchLucide()
	if S.lucide ~= nil then
		return S.lucide
	end
	if S.lucideLoading then
		repeat
			task.wait(0.05)
		until S.lucide ~= nil or not S.lucideLoading
		return S.lucide
	end
	S.lucideLoading = true
	local module = false
	local ok, body = pcall(function()
		return game:HttpGet(LUCIDE_URL)
	end)
	if ok and type(body) == "string" and #body > 10000 and typeof(loadstring) == "function" then
		local okCompile, chunk = pcall(loadstring, body)
		if okCompile and type(chunk) == "function" then
			local okRun, result = pcall(chunk)
			if okRun and type(result) == "table" and type(result.GetAsset) == "function" then
				module = result
			end
		end
	end
	S.lucide = module
	S.lucideLoading = false
	return module
end

local function cachedAsset(name)
	local entry = S.iconCache[LUCIDE_ALIAS[name] or name]
	if type(entry) == "table" then
		return entry
	end
	return nil
end

local function requestAsset(name, apply)
	if not S.iconsEnabled then
		return
	end
	local key = LUCIDE_ALIAS[name] or name
	if S.iconCache[key] == false then
		return
	end
	local waiting = S.iconWaiting[key]
	if waiting then
		waiting[#waiting + 1] = apply
		return
	end
	S.iconWaiting[key] = { apply }
	task.spawn(function()
		local lucide = fetchLucide()
		local asset
		if lucide then
			local ok, out = pcall(lucide.GetAsset, key, 48)
			if not ok or type(out) ~= "table" then
				ok, out = pcall(lucide.GetAsset, key)
			end
			if ok and type(out) == "table" then
				asset = out
			end
		end
		S.iconCache[key] = asset or false
		local list = S.iconWaiting[key]
		S.iconWaiting[key] = nil
		if asset and list then
			queueIconCacheWrite()
			for _, fn in ipairs(list) do
				pcall(fn, asset)
			end
		end
	end)
end

local function isImage(name)
	return type(name) == "string" and (string.find(name, "rbxasset", 1, true) ~= nil or string.find(name, "^%d+$") ~= nil)
end

local function icon(name, parent, size, token)
	size = math.max(math.floor((size or 16) * D.iconScale + 0.5), 8)
	local holder = frame({ Size = UDim2.fromOffset(size, size) }, parent)
	local parts = {}
	local current = token or "tx3"
	local function set(t, animated)
		if t ~= nil then
			current = t
		end
		for _, part in ipairs(parts) do
			paint(part[1], part[2], current, animated)
		end
	end
	local function drawAsset(asset)
		local img = new("ImageLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Image = asset.Url,
			ImageRectOffset = asset.ImageRectOffset,
			ImageRectSize = asset.ImageRectSize,
			ScaleType = Enum.ScaleType.Fit,
		}, holder)
		parts[#parts + 1] = { img, "ImageColor3" }
	end
	local function drawBuiltin(drawer)
		local inner = frame({
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(16, 16),
		}, holder)
		if size ~= 16 then
			new("UIScale", { Scale = size / 16 }, inner)
		end
		drawer(parts, inner)
	end

	if type(name) ~= "string" or name == "" then
		return holder, set
	end
	if isImage(name) then
		local img = new("ImageLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Image = string.find(name, "^%d+$") and ("rbxassetid://" .. name) or name,
			ScaleType = Enum.ScaleType.Fit,
		}, holder)
		parts[1] = { img, "ImageColor3" }
		set(nil, false)
		return holder, set
	end

	local asset = cachedAsset(name)
	if asset then
		drawAsset(asset)
		set(nil, false)
		return holder, set
	end

	local builtin = ICONS[name] or ICONS[BUILTIN_ALIAS[name] or ""]
	drawBuiltin(builtin or iconPlaceholder)
	set(nil, false)

	requestAsset(name, function(resolved)
		if holder.Parent == nil then
			return
		end
		for _, child in ipairs(holder:GetChildren()) do
			child:Destroy()
		end
		table.clear(parts)
		drawAsset(resolved)
		set(nil, false)
	end)
	return holder, set
end

local function logoMark(parent, size, radius, logo, title)
	local box = frame({ Size = UDim2.fromOffset(size, size), BackgroundColor3 = tok.accent }, parent)
	corner(box, radius)
	if logo ~= nil and logo ~= "" then
		box.BackgroundTransparency = 1
		local img = new("ImageLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			ScaleType = Enum.ScaleType.Fit,
			Image = string.find(tostring(logo), "^%d+$") and ("rbxassetid://" .. tostring(logo)) or tostring(logo),
		}, box)
		corner(img, radius)
	else
		label({
			Size = UDim2.fromScale(1, 1),
			Text = string.upper(string.sub(tostring(title or ""), 1, 1)),
			TextSize = math.floor(size * 0.5),
			FontFace = F_BOLD,
			TextColor3 = tok.onAccent,
			TextXAlignment = Enum.TextXAlignment.Center,
		}, box)
	end
	return box
end

local function keycap(parent, text, order)
	local cap = new("TextLabel", {
		LayoutOrder = order or 0,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, D.keycap),
		BackgroundColor3 = tok.el,
		BorderSizePixel = 0,
		Text = text,
		TextSize = D.fSmall,
		FontFace = F_MONO,
		TextColor3 = tok.tx2,
	}, parent)
	corner(cap, D.rSmall)
	local s = stroke(cap, "line2")
	pad(cap, 0, D.keycapPad, 0, D.keycapPad)
	return cap, s
end

local function screenGui(name, order)
	local gui = new("ScreenGui", {
		Name = name,
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = order,
	})
	return gui
end

local RNG = Random.new()
local NAME_CHARS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

local function randomName(length)
	local out = {}
	for i = 1, length do
		local n = RNG:NextInteger(1, #NAME_CHARS)
		out[i] = string.sub(NAME_CHARS, n, n)
	end
	return table.concat(out)
end

local function rootGui()
	if S.gui and S.gui.Parent then
		return S.gui
	end
	S.gui = screenGui(randomName(12), 2147482900)
	S.gui.Parent = defaultParent()
	return S.gui
end

function Library:SetTheme(theme)
	if type(theme) == "table" then
		S.theme = merge(THEMES[theme.Base or "Dark"] or THEMES.Dark, theme)
		S.themeName = "Custom"
	elseif THEMES[theme] then
		S.theme = THEMES[theme]
		S.themeName = theme
	else
		return self
	end
	applyColors()
	return self
end

function Library:SetAccent(c)
	if typeof(c) ~= "Color3" then
		return self
	end
	S.accent = c
	S.onAccent = textOn(c)
	applyColors()
	return self
end

function Library:SetFont(f)
	S.family, S.fontName = resolveFont(f)
	applyFonts()
	return self
end

function Library:GetTheme()
	return S.themeName
end

function Library:GetAccent()
	return S.accent
end

function Library:GetFont()
	return S.fontName
end

function Library:OnUnload(f)
	S.unload[#S.unload + 1] = f
end

local function clearState()
	table.clear(Library.Flags)
	table.clear(Library.Options)
	table.clear(Library.Toggles)
	table.clear(Library.Conflicts)
	table.clear(Library._order)
	table.clear(S.themed)
	table.clear(S.fonted)
	table.clear(S.unload)
	table.clear(S.keybinds)
	table.clear(S.conns)
	table.clear(S.drags)
	S.keyMap = {}
	S.settings = {}
	S.settingsDirty = {}
	S.settingsLoading = false
	S.listening = nil
	S.iconWaiting = {}
	S.inputStarted = false
	S.records = 0
	S.pruneQueued = false
	S.pop = nil
	S.gui = nil
	S.wm, S.wmTitle, S.wmFps, S.wmPing, S.wmTime = nil, nil, nil, nil, nil
	S.kbl, S.kblRows = nil, nil
	table.clear(S.hud)
	S.al, S.alRows, S.alOn, S.alMoved, S.alPending = nil, nil, nil, nil, nil
	S.alCorner = "TopRight"
	S.blur = nil
	S.notifyHolder, S.notifs, S.notifyOrder = nil, nil, 0
	S.dialog = nil
	S.wmMoved, S.kblMoved = nil, nil
	S.wmSeps, S.wmText, S.wmFormat = nil, nil, nil
	S.wmStats = { fps = 0, ping = -1, time = "--:--" }
	S.settingsQueued = false
	D = DENSITY.Comfortable
	S.density = "Comfortable"
	Library.Density = "Comfortable"
	Library._window = nil
end

local function registerOption(flag, el)
	if Library.Options[flag] ~= nil then
		Library.Conflicts[#Library.Conflicts + 1] = flag
	else
		Library._order[#Library._order + 1] = flag
	end
	Library.Options[flag] = el
end

function Library:_reset()
	clearState()
	Library.Unloaded = false
	return self
end

local Window = {}
Window.__index = Window

local Tab = {}
Tab.__index = Tab

local WINDOW_DEFAULTS = {
	Title = "EasyLibrary",
	Logo = nil,
	Theme = "Dark",
	Accent = SWATCHES[1],
	Font = "Ubuntu",
	Layout = "Sidebar",
	Density = "Comfortable",
	Size = nil,
	Device = "Auto",
	Scale = 1,
	MobileScale = 1,
	Keybind = Enum.KeyCode.RightShift,
	AutoSettings = true,
	SettingsName = "Settings",
	Profile = true,
	Search = true,
	ShowCloseButton = true,
	ConfirmClose = true,
	ConfigFolder = nil,
	AutoLoadConfig = true,
	PersistSettings = true,
	SettingsFile = "EasyLibrary/settings.json",
	GlobalKey = "EasyLibraryUnload",
	Watermark = false,
	KeybindList = false,
	ArrayList = false,
	ArrayListCorner = "TopRight",
	Blur = false,
	BlurSize = 12,
	Animations = true,
	AnimationSpeed = 1,
	Icons = "Lucide",
}

local TYPE_ALIAS = { Checkbox = "Toggle" }

local function sameType(a, b)
	return (TYPE_ALIAS[a] or a) == (TYPE_ALIAS[b] or b)
end

local function sanitize(name)
	return trim((string.gsub(tostring(name or ""), "[^%w%-_ ]", "")))
end

local function parseLayout(value)
	local l = string.lower(tostring(value or ""))
	if l == "top" or l == "top tabs" or l == "toptabs" then
		return "Top"
	end
	return "Sidebar"
end

local function readSettingsValue(flag)
	if not S.persistSettings or not api.isfile or not api.readfile then
		return nil
	end
	local path = tostring(S.settingsFile or "EasyLibrary/settings.json")
	local okExists, exists = pcall(api.isfile, path)
	if not okExists or not exists then
		return nil
	end
	local okRead, content = pcall(api.readfile, path)
	if not okRead or type(content) ~= "string" then
		return nil
	end
	local okDecode, data = pcall(function()
		return HttpService:JSONDecode(content)
	end)
	if not okDecode or type(data) ~= "table" or type(data.options) ~= "table" then
		return nil
	end
	local entry = data.options[flag]
	if type(entry) == "table" then
		return entry.v
	end
	return nil
end

function Library:CreateWindow(options)
	if self._window and not self.Unloaded then
		return self._window
	end
	local opts = merge(WINDOW_DEFAULTS, options)
	local globalKey = tostring(opts.GlobalKey or "EasyLibraryUnload")
	if type(shared) == "table" and type(shared[globalKey]) == "function" then
		pcall(shared[globalKey])
	end
	Library:_reset()
	Library._globalKey = globalKey
	if type(shared) == "table" then
		shared[globalKey] = function()
			Library:Unload()
		end
	end

	Library.Device = detectDevice(opts.Device)
	S.mobile = Library.Device == "Mobile"
	S.persistSettings = opts.PersistSettings ~= false
	S.settingsFile = tostring(opts.SettingsFile or "EasyLibrary/settings.json")
	applyDensity(readSettingsValue("EasyLibrary_Density") or opts.Density)

	if typeof(opts.Size) == "UDim2" then
		opts.Size = Vector2.new(opts.Size.X.Offset, opts.Size.Y.Offset)
	elseif typeof(opts.Size) ~= "Vector2" then
		opts.Size = Vector2.new(D.width, D.height)
	end
	opts.Size = Vector2.new(math.max(opts.Size.X, D.minW), math.max(opts.Size.Y, D.minH))

	S.animate = opts.Animations ~= false
	S.speed = math.max(tonumber(opts.AnimationSpeed) or 1, 0.05)
	Library:SetTheme(opts.Theme)
	Library:SetAccent(typeof(opts.Accent) == "Color3" and opts.Accent or SWATCHES[1])
	Library:SetFont(opts.Font)
	Library.ConfigFolder = opts.ConfigFolder or ("EasyLibrary/" .. (sanitize(opts.Title) ~= "" and sanitize(opts.Title) or "Default"))
	S.iconsEnabled = string.lower(tostring(opts.Icons)) ~= "builtin"
	if S.iconsEnabled then
		readIconCache()
	end

	local win = setmetatable({
		_opts = opts,
		_tabs = {},
		_layout = parseLayout(opts.Layout),
		_userScale = 1,
		_visible = true,
		_query = "",
		_menuKey = keyFromName(opts.Keybind),
		_single = false,
		_compact = false,
	}, Window)
	self._window = win

	win:_build()
	Library:_startInput()
	if opts.AutoSettings ~= false then
		win:_buildSettings()
	end
	win:_relayout()
	win:_transition(true)

	if opts.Watermark then
		if type(opts.Watermark) == "string" then
			Library:SetWatermark(opts.Watermark)
		end
		Library:SetWatermarkVisible(true)
	end
	if opts.KeybindList then
		Library:SetKeybindListVisible(true)
	end
	if opts.ArrayList then
		Library:SetArrayListCorner(opts.ArrayListCorner)
		Library:SetArrayListVisible(true)
	end

	task.defer(function()
		if Library.Unloaded then
			return
		end
		if not win._current then
			for _, tab in ipairs(win._tabs) do
				if not tab._bottom then
					win:SelectTab(tab)
					break
				end
			end
			if not win._current and win._tabs[1] then
				win:SelectTab(win._tabs[1])
			end
		end
		if opts.AutoLoadConfig ~= false then
			Library:LoadAutoloadConfig()
		end
	end)

	return win
end

function Window:_iconButton(parent, name, size, order, onClick)
	local b = button({
		LayoutOrder = order,
		Size = UDim2.fromOffset(size, size),
		BackgroundColor3 = tok.el,
		BackgroundTransparency = 1,
	}, parent)
	corner(b, D.rCtrl)
	local ic, setIcon = icon(name, b, 15, "tx3")
	ic.AnchorPoint = Vector2.new(0.5, 0.5)
	ic.Position = UDim2.fromScale(0.5, 0.5)
	hover(b, function(on)
		tween(b, quick(), { BackgroundTransparency = on and 0 or 1 })
		setIcon(on and "tx" or "tx3", true)
	end)
	press(b, 0.92)
	connect(b.Activated, onClick)
	return b
end

function Window:_build()
	local opts = self._opts
	local gui = rootGui()
	self._gui = gui

	local holder = frame({
		Name = "Window",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(0, 0),
	}, gui)
	self._holder = holder
	self._fit = new("UIScale", {}, holder)

	local main = frame({
		Name = "Main",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(opts.Size.X, opts.Size.Y),
		BackgroundColor3 = tok.bg,
		Active = true,
	}, holder)
	corner(main, D.rWin)
	stroke(main, "line2")
	self._main = main

	local header = frame({
		Name = "Header",
		Size = UDim2.new(1, 0, 0, D.header),
		BackgroundColor3 = tok.side,
		Active = true,
	}, main)
	corner(header, D.rWin)
	frame({ Position = UDim2.new(0, 0, 1, -10), Size = UDim2.new(1, 0, 0, 10), BackgroundColor3 = tok.side }, header)
	frame({ Position = UDim2.new(0, 0, 1, -1), Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = tok[D.lineToken], ZIndex = 2 }, header)
	self._header = header

	local brand = frame({
		Position = UDim2.fromOffset(14, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 1, 0),
		ZIndex = 2,
	}, header)
	list(brand, true, 10, nil, Enum.VerticalAlignment.Center)
	logoMark(brand, 22, 6, opts.Logo, opts.Title)
	self._title = label({
		LayoutOrder = 1,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 18),
		Text = tostring(opts.Title or ""),
		FontFace = F_SEMI,
		TextTruncate = Enum.TextTruncate.None,
	}, brand)
	self._brand = brand

	local controls = frame({
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 34),
		ZIndex = 2,
	}, header)
	list(controls, true, 4, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center)
	self._controls = controls
	if opts.Search ~= false then
		self:_buildSearch(controls)
	end
	local size = S.mobile and 34 or 28
	self:_iconButton(controls, "minimize", size, 2, function()
		self:SetVisible(false)
	end)
	if opts.ShowCloseButton ~= false then
		self:_iconButton(controls, "close", size, 3, function()
			self:_requestClose()
		end)
	end

	self:_buildSidebar(main)
	self:_buildNav(main)

	self._content = frame({ Name = "Content", ClipsDescendants = true }, main)

	self._overlay = frame({
		Name = "Overlay",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = main.Size,
		ZIndex = 20,
	}, holder)

	local dragStart, startPos
	track(header, {
		filter = function(pos)
			return not over(self._controls, pos)
		end,
		start = function(pos)
			self:_closePopup()
			dragStart = pos
			startPos = holder.Position
		end,
		move = function(pos)
			local d = pos - dragStart
			self._moved = true
			holder.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end,
	})

	if S.mobile then
		self:_buildMobileButton()
	else
		self:_buildPill()
	end

	local function watchCamera()
		local cam = camera()
		if cam then
			connect(cam:GetPropertyChangedSignal("ViewportSize"), function()
				self:_relayout()
			end)
		end
	end
	watchCamera()
	connect(Workspace:GetPropertyChangedSignal("CurrentCamera"), function()
		watchCamera()
		self:_relayout()
	end)
end

function Window:_buildSearch(parent)
	local box = frame({
		LayoutOrder = 1,
		Size = UDim2.fromOffset(S.mobile and 150 or 210, 28),
		BackgroundColor3 = tok.el,
	}, parent)
	corner(box, D.rCtrl)
	local st = stroke(box, D.lineToken)
	local ic = icon("search", box, 14, "tx3")
	ic.AnchorPoint = Vector2.new(0, 0.5)
	ic.Position = UDim2.new(0, 9, 0.5, 0)
	local clear = button({
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -4, 0.5, 0),
		Size = UDim2.fromOffset(20, 20),
		BackgroundColor3 = tok.el2,
		BackgroundTransparency = 1,
		Visible = false,
	}, box)
	corner(clear, D.rSmall)
	local clearIcon, setClear = icon("close", clear, 12, "tx3")
	clearIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	clearIcon.Position = UDim2.fromScale(0.5, 0.5)
	hover(clear, function(on)
		tween(clear, quick(), { BackgroundTransparency = on and 0 or 1 })
		setClear(on and "tx" or "tx3", true)
	end)
	local input = new("TextBox", {
		Position = UDim2.fromOffset(30, 0),
		Size = UDim2.new(1, -56, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = "",
		PlaceholderText = "Search elements",
		PlaceholderColor3 = tok.tx3,
		TextColor3 = tok.tx,
		TextSize = D.fLabel,
		FontFace = F_REG,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		ClipsDescendants = true,
	}, box)
	connect(input.Focused, function()
		bindTween(st, "Color", "accent")
		tween(st, quick(), { Transparency = 0.45 })
	end)
	connect(input.FocusLost, function()
		bindTween(st, "Color", D.lineToken)
		tween(st, quick(), { Transparency = 0 })
	end)
	connect(input:GetPropertyChangedSignal("Text"), function()
		clear.Visible = input.Text ~= ""
		self:_search(input.Text)
	end)
	connect(clear.Activated, function()
		input.Text = ""
	end)
	self._searchBox = box
	self._searchInput = input
end

function Window:_buildSidebar(main)
	local opts = self._opts
	local side = frame({
		Name = "Sidebar",
		Position = UDim2.fromOffset(0, D.header),
		Size = UDim2.new(0, D.sideW, 1, -D.header),
		BackgroundColor3 = tok.side,
	}, main)
	corner(side, D.rWin)
	frame({ Size = UDim2.new(1, 0, 0, 10), BackgroundColor3 = tok.side }, side)
	frame({
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.new(0, 10, 1, 0),
		BackgroundColor3 = tok.side,
	}, side)
	frame({
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.new(0, 1, 1, 0),
		BackgroundColor3 = tok[D.lineToken],
		ZIndex = 2,
	}, side)
	self._side = side

	local hasSettings = opts.AutoSettings ~= false
	local hasProfile = opts.Profile ~= false
	local inner = (hasSettings and 34 or 0) + (hasProfile and 42 or 0) + ((hasSettings and hasProfile) and 6 or 0)
	local bottomH = inner > 0 and (inner + 14) or 0

	local tabList = new("ScrollingFrame", {
		Position = UDim2.fromOffset(8, 10),
		Size = UDim2.new(1, -16, 1, -(10 + bottomH)),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(),
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ZIndex = 2,
	}, side)
	list(tabList, false, 2)
	self._tabList = tabList

	local bottom = frame({
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 8, 1, -8),
		Size = UDim2.new(1, -16, 0, inner),
		ZIndex = 2,
		Visible = inner > 0,
	}, side)
	list(bottom, false, 6)
	self._sideBottom = bottom

	if hasProfile then
		self:_buildProfile(bottom)
	end
end

function Window:_buildProfile(parent)
	local block = frame({ LayoutOrder = 2, Size = UDim2.new(1, 0, 0, 42) }, parent)
	frame({ Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = tok[D.lineToken] }, block)
	local row = frame({ Position = UDim2.fromOffset(6, 11), Size = UDim2.new(1, -6, 0, 30) }, block)
	local avatar = new("ImageLabel", {
		Size = UDim2.fromOffset(30, 30),
		BackgroundColor3 = tok.el2,
		BorderSizePixel = 0,
		ScaleType = Enum.ScaleType.Crop,
	}, row)
	corner(avatar)
	task.spawn(function()
		local ok, image = pcall(function()
			return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
		end)
		if ok and avatar.Parent then
			avatar.Image = image
		end
	end)
	local name = label({
		Position = UDim2.fromOffset(40, 0),
		Size = UDim2.new(1, -40, 0, 16),
		Text = LocalPlayer.DisplayName,
		TextSize = D.fLabel,
		FontFace = F_SEMI,
	}, row)
	local user = label({
		Position = UDim2.fromOffset(40, 16),
		Size = UDim2.new(1, -40, 0, 14),
		Text = "@" .. LocalPlayer.Name,
		TextSize = D.fSmall,
		TextColor3 = tok.tx3,
	}, row)
	self._profile = { row = row, texts = { name, user } }
end

function Window:_buildNav(main)
	local nav = frame({
		Name = "TopNav",
		Position = UDim2.fromOffset(0, D.header),
		Size = UDim2.new(1, 0, 0, D.nav),
		BackgroundColor3 = tok.side,
		Visible = false,
	}, main)
	frame({ Position = UDim2.new(0, 0, 1, -1), Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = tok[D.lineToken], ZIndex = 3 }, nav)
	local right = frame({
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -8, 0, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 1, 0),
		ZIndex = 2,
	}, nav)
	list(right, true, 2, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Bottom)
	local tabs = new("ScrollingFrame", {
		Position = UDim2.fromOffset(8, 0),
		Size = UDim2.new(1, -16, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		AutomaticCanvasSize = Enum.AutomaticSize.X,
		CanvasSize = UDim2.new(),
		ScrollingDirection = Enum.ScrollingDirection.X,
		ZIndex = 2,
	}, nav)
	list(tabs, true, 2, nil, Enum.VerticalAlignment.Bottom)
	connect(right:GetPropertyChangedSignal("AbsoluteSize"), function()
		local scale = self._fit.Scale > 0 and self._fit.Scale or 1
		tabs.Size = UDim2.new(1, -16 - math.ceil(right.AbsoluteSize.X / scale) - 8, 1, 0)
	end)
	self._nav = nav
	self._navList = tabs
	self._navRight = right
end

function Window:_buildPill()
	local opts = self._opts
	local pill = button({
		Name = "Reopen",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, -80),
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 36),
		BackgroundColor3 = tok.bg,
		Visible = false,
		ZIndex = 30,
	}, self._gui)
	corner(pill, D.rWin)
	stroke(pill, "line2")
	pad(pill, 0, 12, 0, 8)
	list(pill, true, 10, nil, Enum.VerticalAlignment.Center)
	logoMark(pill, 22, 6, opts.Logo, opts.Title)
	label({
		LayoutOrder = 1,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 18),
		Text = tostring(opts.Title or ""),
		FontFace = F_SEMI,
		TextTruncate = Enum.TextTruncate.None,
	}, pill)
	frame({ LayoutOrder = 2, Size = UDim2.fromOffset(1, 14), BackgroundColor3 = tok.line2 }, pill)
	self._pillKey = keycap(pill, keyLabel(self._menuKey), 3)
	self._pillKey.Visible = self._menuKey ~= nil
	hover(pill, function(on)
		bindTween(pill, "BackgroundColor3", on and "el" or "bg")
	end)
	press(pill)
	connect(pill.Activated, function()
		self:SetVisible(true)
	end)
	self._pill = pill
end

function Window:_buildMobileButton()
	local opts = self._opts
	local btn = button({
		Name = "Toggle",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 14, 0.5, 0),
		Size = UDim2.fromOffset(48, 48),
		BackgroundColor3 = tok.bg,
		ZIndex = 30,
	}, self._gui)
	corner(btn, D.rMobileBtn)
	stroke(btn, "line2")
	local mark = logoMark(btn, 30, 8, opts.Logo, opts.Title)
	mark.AnchorPoint = Vector2.new(0.5, 0.5)
	mark.Position = UDim2.fromScale(0.5, 0.5)
	local scale = new("UIScale", {}, btn)
	local startPos, origin, moved
	track(btn, {
		start = function(pos)
			startPos = pos
			origin = btn.Position
			moved = false
			tween(scale, quick(), { Scale = 0.94 })
		end,
		move = function(pos)
			local d = pos - startPos
			if not moved and d.Magnitude > 8 then
				moved = true
			end
			if moved then
				btn.Position = UDim2.new(origin.X.Scale, origin.X.Offset + d.X, origin.Y.Scale, origin.Y.Offset + d.Y)
			end
		end,
		stop = function()
			tween(scale, quick(), { Scale = 1 })
			if not moved then
				self:Toggle()
			end
		end,
	})
	self._mobileButton = btn
end

function Window:_relayout()
	if Library.Unloaded then
		return
	end
	local opts = self._opts
	local vp = viewport()
	local top = GuiService:GetGuiInset().Y
	local margin = S.mobile and 10 or 24
	local availW = math.max(vp.X - margin * 2, 200)
	local availH = math.max(vp.Y - top - margin * 2, 160)
	local base = (S.mobile and (tonumber(opts.MobileScale) or 1) or (tonumber(opts.Scale) or 1)) * self._userScale
	local w, h, scale = opts.Size.X, opts.Size.Y, base
	if S.mobile then
		w = math.min(w, availW / base)
		h = math.min(h, availH / base)
	else
		scale = math.min(base, availW / w, availH / h)
	end
	scale = math.max(scale, 0.3)
	self._fit.Scale = scale
	self._size = Vector2.new(w, h)
	self._main.Size = UDim2.fromOffset(w, h)
	self._overlay.Size = self._main.Size
	if not self._moved then
		self._holder.Position = UDim2.new(0.5, 0, 0.5, math.floor(top / 2))
	end

	local sidebar = self._layout == "Sidebar"
	local compact = sidebar and w < D.narrowAt
	local sideW = sidebar and (compact and D.sideNarrow or D.sideW) or 0
	local navH = sidebar and 0 or D.nav
	self._side.Visible = sidebar
	self._side.Size = UDim2.new(0, sideW, 1, -D.header)
	self._nav.Visible = not sidebar
	self._content.Position = UDim2.fromOffset(sideW, D.header + navH)
	self._content.Size = UDim2.new(1, -sideW, 1, -(D.header + navH))

	if self._searchBox then
		self._searchBox.Size = UDim2.fromOffset(w < 560 and 120 or (S.mobile and 150 or 210), 28)
	end
	self._title.Visible = w >= 480

	local single = (w - sideW - D.pagePad * 2) < D.singleAt
	self._single = single
	self._compact = compact
	for _, tab in ipairs(self._tabs) do
		tab:_setColumns(single)
		tab:_setCompact(compact)
	end
	if self._profile then
		self._profile.row.Position = compact and UDim2.new(0.5, -15, 0, 11) or UDim2.fromOffset(6, 11)
		for _, t in ipairs(self._profile.texts) do
			t.Visible = not compact
		end
	end
	self:_closePopup()
end

local function setBlur(on)
	local win = Library._window
	local opts = win and win._opts or nil
	if not opts or not opts.Blur then
		return
	end
	if on then
		if not S.blur then
			S.blur = new("BlurEffect", { Name = randomName(10), Size = 0 }, Lighting)
		end
		tween(S.blur, info(0.3, Style.Quad, Direction.Out), { Size = math.max(tonumber(opts.BlurSize) or 12, 0) })
	elseif S.blur then
		tween(S.blur, info(0.24, Style.Quad, Direction.In), { Size = 0 })
	end
end

function Window:_transition(show)
	setBlur(show)
	self._transitionId = (self._transitionId or 0) + 1
	local id = self._transitionId
	local holder, main = self._holder, self._main
	if not S.animate then
		holder.Visible = show
		return
	end
	local fade = self._fade
	if not fade then
		fade = new("CanvasGroup", {
			Name = "Fade",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, holder)
		self._fade = fade
	end
	local size = self._size or self._opts.Size
	fade.Size = UDim2.fromOffset(size.X + 4, size.Y + 4)
	main.Position = UDim2.fromScale(0.5, 0.5)
	main.Parent = fade
	holder.Visible = true
	local duration = show and 0.5 or 0.24
	if show then
		fade.Position = UDim2.fromOffset(0, 16)
		fade.GroupTransparency = 1
		tween(fade, info(duration, Style.Quint, Direction.Out), { Position = UDim2.fromOffset(0, 0), GroupTransparency = 0 })
	else
		tween(fade, info(duration, Style.Quad, Direction.In), { Position = UDim2.fromOffset(0, 12), GroupTransparency = 1 })
	end
	task.delay(duration / S.speed, function()
		if id ~= self._transitionId or Library.Unloaded then
			return
		end
		main.Parent = holder
		main.Position = UDim2.fromOffset(0, 0)
		if not show then
			holder.Visible = false
		end
	end)
end

function Window:_showPill(on)
	local pill = self._pill
	if not pill then
		return
	end
	local top = GuiService:GetGuiInset().Y
	if on then
		pill.Visible = true
		pill.Position = UDim2.new(0.5, 0, 0, -80)
		tween(pill, pop(), { Position = UDim2.new(0.5, 0, 0, top + 10) })
	else
		tween(pill, info(0.18, Style.Quad, Direction.In), { Position = UDim2.new(0.5, 0, 0, -80) })
		task.delay(S.animate and 0.18 / S.speed or 0, function()
			if self._visible then
				pill.Visible = false
			end
		end)
	end
end

function Window:SetVisible(v)
	v = v ~= false
	if v == self._visible or Library.Unloaded then
		return self
	end
	self._visible = v
	self:_closePopup()
	self:_transition(v)
	self:_showPill(not v)
	return self
end

function Window:Toggle()
	return self:SetVisible(not self._visible)
end

function Window:IsVisible()
	return self._visible
end

function Window:SetLayout(layout)
	self._layout = parseLayout(layout)
	self:_relayout()
	return self
end

function Window:SetScale(scale)
	self._userScale = math.clamp(tonumber(scale) or 1, 0.5, 2)
	self:_relayout()
	return self
end

function Window:SetTitle(text)
	self._title.Text = tostring(text or "")
	return self
end

function Window:SetKeybind(key, fromSettings)
	self._menuKey = keyFromName(key)
	if self._pillKey then
		self._pillKey.Text = keyLabel(self._menuKey)
		self._pillKey.Visible = self._menuKey ~= nil
	end
	if not fromSettings and self._menuBind then
		self._menuBind:SetValue(self._menuKey)
	end
	return self
end

function Window:_requestClose()
	local title = tostring(self._opts.Title or "")
	if self._opts.ConfirmClose == false then
		Library:Unload()
		return
	end
	Library:Dialog({
		Title = "Unload " .. title .. "?",
		Content = "This closes the interface and stops the script.",
		Type = "Danger",
		Buttons = {
			{ Text = "Cancel" },
			{
				Text = "Unload",
				Variant = "Danger",
				Callback = function()
					Library:Unload()
				end,
			},
		},
	})
end

function Window:AddTab(options)
	if type(options) == "string" then
		options = { Name = options }
	end
	options = options or {}
	local tab = setmetatable({
		_win = self,
		Name = tostring(options.Name or options.Title or "Tab"),
		_icon = options.Icon,
		_bottom = options.Bottom == true,
		_groups = {},
	}, Tab)

	local page = new("ScrollingFrame", {
		Name = tab.Name,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = D.scrollBar,
		ScrollBarImageColor3 = tok.line2,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(),
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Visible = false,
	}, self._content)
	pad(page, D.pagePad, 0, D.pagePad, 0)
	local cols = frame({
		Position = UDim2.fromOffset(D.pagePad, 0),
		Size = UDim2.new(1, -D.pagePad * 2, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	}, page)
	tab._empty = label({
		Position = UDim2.fromOffset(12, 24),
		Size = UDim2.new(1, -24, 0, 40),
		Text = "",
		TextSize = D.fLabel,
		TextColor3 = tok.tx3,
		TextXAlignment = Enum.TextXAlignment.Center,
		Visible = false,
	}, page)
	tab._columnsLayout = list(cols, true, D.colGap)
	local colWidth = UDim2.new(0.5, -D.colGap / 2, 0, 0)
	tab._left = frame({ LayoutOrder = 1, Size = colWidth, AutomaticSize = Enum.AutomaticSize.Y }, cols)
	list(tab._left, false, D.colGap)
	tab._right = frame({ LayoutOrder = 2, Size = colWidth, AutomaticSize = Enum.AutomaticSize.Y }, cols)
	list(tab._right, false, D.colGap)
	tab._page = page
	tab._cols = cols

	self._tabs[#self._tabs + 1] = tab
	tab:_buildSideButton()
	tab:_buildTopButton()
	tab:_setColumns(self._single)
	tab:_setCompact(self._compact)

	if not tab._bottom and (not self._current or self._current._bottom) then
		self:SelectTab(tab)
	end
	return tab
end

function Window:SelectTab(tab)
	if type(tab) == "string" then
		for _, t in ipairs(self._tabs) do
			if t.Name == tab then
				tab = t
				break
			end
		end
	end
	if type(tab) ~= "table" or tab == self._current then
		return self
	end
	self:_closePopup()
	local prev = self._current
	self._current = tab
	if prev then
		prev:_setActive(false)
		prev._page.Visible = false
	end
	tab:_setActive(true)
	tab._page.Visible = true
	if prev then
		self:_animatePage(tab)
	end
	if tab._onSelect then
		task.spawn(tab._onSelect)
	end
	return self
end

function Window:_animatePage(tab)
	if not S.animate then
		return
	end
	local cols = tab._cols
	cols.Position = UDim2.fromOffset(D.pagePad, 10)
	tween(cols, info(0.3, Style.Quint, Direction.Out), { Position = UDim2.fromOffset(D.pagePad, 0) })
end

local function searchTokens(query)
	local tokens = {}
	for word in string.gmatch(string.lower(query), "%S+") do
		tokens[#tokens + 1] = word
	end
	return tokens
end

local function matches(haystack, tokens)
	for _, t in ipairs(tokens) do
		if not string.find(haystack, t, 1, true) then
			return false
		end
	end
	return true
end

function Window:_search(text)
	self._query = trim(text)
	self:_closePopup()
	self._searchToken = (self._searchToken or 0) + 1
	if self._query == "" then
		self:_applySearch(true)
		return
	end
	local token = self._searchToken
	task.delay(0.08, function()
		if token ~= self._searchToken or Library.Unloaded or not self._main or self._main.Parent == nil then
			return
		end
		self:_applySearch(true)
	end)
end

local function searchContainer(c, prefix, tokens, active)
	local count = 0
	for _, el in ipairs(c._items) do
		local match = (not active) or matches(prefix .. " " .. string.lower(el._search or ""), tokens)
		el._match = match
		el:_applyVisible()
		if match and el._visible and not el._hiddenByDevice then
			count = count + 1
		end
	end
	for _, s in ipairs(c._sections) do
		local n = searchContainer(s, prefix .. " " .. string.lower(s._name or ""), tokens, active)
		if s._root then
			s._root.Visible = s._visible and ((not active) or n > 0)
		end
		if s._owner and active and n > 0 then
			s._owner._match = true
			s._owner:_applyVisible()
		end
		if s._collapse then
			s._collapse.force(active and n > 0)
		end
		if s._visible then
			count = count + n
		end
	end
	return count
end

function Window:_applySearch(autoSwitch)
	local tokens = searchTokens(self._query or "")
	local active = #tokens > 0
	local firstHit
	for _, tab in ipairs(self._tabs) do
		local hits = 0
		for _, g in ipairs(tab._groups) do
			local groupName = string.lower(g.name or "")
			local any = false
			local containerHits = {}
			for ci, c in ipairs(g.containers) do
				local count = searchContainer(c, groupName, tokens, active)
				if count > 0 then
					any = true
				end
				containerHits[ci] = count
				if active then
					hits = hits + count
				end
			end
			g.frame.Visible = (not active) or any
			if g.collapse then
				g.collapse.force(active and any)
			end
			local tb = g.tabbox
			if active and tb and tb._active then
				local current = table.find(g.containers, tb._active.container)
				if current and containerHits[current] == 0 then
					for ci, count in ipairs(containerHits) do
						if count > 0 then
							tb:_select(tb._subs[ci])
							break
						end
					end
				end
			end
		end
		tab._hits = hits
		tab:_setBadge(active and hits or nil)
		tab._empty.Visible = active and hits == 0
		tab._empty.Text = active and ("No elements match \"" .. self._query .. "\"") or ""
		if active and hits > 0 and not firstHit then
			firstHit = tab
		end
	end
	local current = self._current
	if autoSwitch and active and current and current._hits == 0 and firstHit then
		self:SelectTab(firstHit)
	end
end

function Window:_popup(anchor, width, height, build, onClose, ignore)
	self:_closePopup()
	local group = new("CanvasGroup", {
		ZIndex = 2,
		BackgroundColor3 = tok.line2,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(width, height + 2),
		GroupTransparency = S.animate and 1 or 0,
	}, self._overlay)
	corner(group, D.rCtrl)
	local panel = frame({
		Position = UDim2.fromOffset(1, 1),
		Size = UDim2.new(1, -2, 1, -2),
		BackgroundColor3 = tok[D.boxToken],
		Active = true,
	}, group)
	corner(panel, D.rCtrl - 1)
	local p = {
		group = group,
		panel = panel,
		conns = {},
		onClose = onClose,
		anchor = anchor,
		ignore = ignore or { anchor },
		height = height + 2,
		width = width,
	}
	self._pop = p
	local previous = S.collect
	S.collect = p.conns
	local ok, err = pcall(build, panel, p)
	S.collect = previous
	if not ok then
		self:_closePopup()
		error(err, 0)
	end
	local below = self:_placePopup(p)
	p.conns[#p.conns + 1] = UserInputService.InputBegan:Connect(function(input)
		local t = input.UserInputType
		if t ~= MB1 and t ~= TOUCH and t ~= Enum.UserInputType.MouseButton2 then
			return
		end
		local pos = pointers(input)
		if overAny(group, pos) then
			return
		end
		for _, g in ipairs(p.ignore) do
			if overAny(g, pos) then
				return
			end
		end
		self:_closePopup()
	end)
	local tab = self._current
	if tab then
		local page = tab._page
		p.conns[#p.conns + 1] = page:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
			if self._pop ~= p then
				return
			end
			local a, s = anchor.AbsolutePosition, anchor.AbsoluteSize
			local pa, ps = page.AbsolutePosition, page.AbsoluteSize
			local cy = a.Y + s.Y / 2
			if not anchor.Parent or cy < pa.Y or cy > pa.Y + ps.Y then
				self:_closePopup()
				return
			end
			self:_placePopup(p)
		end)
	end
	if S.animate then
		local final = group.Position
		group.Position = UDim2.fromOffset(final.X.Offset, final.Y.Offset + (below and -6 or 6))
		tween(group, info(0.22, Style.Quint, Direction.Out), { Position = final, GroupTransparency = 0 })
	end
	return p
end

function Window:_placePopup(p)
	local width, height = p.width, p.height
	local scale = self._fit.Scale
	local o = self._overlay.AbsolutePosition
	local a, s = p.anchor.AbsolutePosition, p.anchor.AbsoluteSize
	local vp = viewport()
	local top = GuiService:GetGuiInset().Y
	local fitsBelow = a.Y + s.Y + (height + 4) * scale <= vp.Y - 8
	local fitsAbove = a.Y - (height + 4) * scale >= top + 8
	local below = fitsBelow or not fitsAbove
	local y
	if below then
		y = (a.Y + s.Y - o.Y) / scale + 4
	else
		y = (a.Y - o.Y) / scale - 4 - height
	end
	local x = (a.X - o.X) / scale
	local minX = (8 - o.X) / scale
	local maxX = (vp.X - 8 - o.X) / scale - width
	x = math.clamp(x, minX, math.max(minX, maxX))
	p.group.Position = UDim2.fromOffset(x, y)
	p.group.Size = UDim2.fromOffset(width, height)
	return below
end

function Window:_closePopup()
	local p = self._pop
	if not p then
		return
	end
	self._pop = nil
	for _, c in ipairs(p.conns) do
		c:Disconnect()
	end
	local group = p.group
	if S.animate and not Library.Unloaded then
		p.panel.Active = false
		tween(group, info(0.12, Style.Quad, Direction.In), { GroupTransparency = 1 })
		task.delay(0.12 / S.speed, function()
			group:Destroy()
		end)
	else
		group:Destroy()
	end
	if p.onClose then
		p.onClose()
	end
end

function Window:_tooltip(target, text)
	if text == nil or text == "" then
		return
	end
	local token = 0
	local tip
	local function hide()
		token = token + 1
		if tip then
			tip:Destroy()
			tip = nil
		end
	end
	local function show()
		local scale = self._fit.Scale
		local o = self._overlay.AbsolutePosition
		local a = target.AbsolutePosition
		tip = label({
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.fromOffset((a.X - o.X) / scale, (a.Y - o.Y) / scale - 6),
			AutomaticSize = Enum.AutomaticSize.XY,
			Size = UDim2.fromOffset(0, 0),
			BackgroundTransparency = 0,
			BackgroundColor3 = tok.tx,
			Text = tostring(text),
			TextSize = D.fSmall,
			TextColor3 = tok.box,
			TextTruncate = Enum.TextTruncate.None,
			ZIndex = 40,
		}, self._overlay)
		corner(tip, D.rSmall)
		pad(tip, 6, 9, 6, 9)
		if S.animate then
			tip.BackgroundTransparency = 1
			tip.TextTransparency = 1
			tween(tip, info(0.18, Style.Quad, Direction.Out), { BackgroundTransparency = 0, TextTransparency = 0 })
		else
			tip.BackgroundTransparency = 0
		end
	end
	local function schedule(delay)
		token = token + 1
		local mine = token
		task.delay(delay, function()
			if mine ~= token or not target.Parent or self._pop or not self._visible then
				return
			end
			show()
		end)
	end
	if S.mobile then
		connect(target.InputBegan, function(input)
			if input.UserInputType == TOUCH then
				schedule(0.45)
			end
		end)
		connect(target.InputEnded, function(input)
			if input.UserInputType == TOUCH then
				hide()
			end
		end)
	else
		connect(target.MouseEnter, function()
			schedule(0.35)
		end)
		connect(target.MouseLeave, hide)
	end
end

function Tab:_buildSideButton()
	local win = self._win
	local parent = self._bottom and win._sideBottom or win._tabList
	local b = button({
		LayoutOrder = self._bottom and 1 or #win._tabs,
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundColor3 = tok.el,
		BackgroundTransparency = 1,
	}, parent)
	corner(b, D.rCtrl)
	local ic, setIcon
	if self._icon then
		ic, setIcon = icon(self._icon, b, 16, "tx3")
		ic.AnchorPoint = Vector2.new(0, 0.5)
		ic.Position = UDim2.new(0, 10, 0.5, 0)
	end
	local text = label({
		Position = UDim2.fromOffset(self._icon and 36 or 12, 0),
		Size = UDim2.new(1, self._icon and -44 or -20, 1, 0),
		Text = self.Name,
		TextColor3 = tok.tx2,
	}, b)
	local letter = label({
		Size = UDim2.fromScale(1, 1),
		Text = string.upper(string.sub(self.Name, 1, 1)),
		TextXAlignment = Enum.TextXAlignment.Center,
		FontFace = F_SEMI,
		TextColor3 = tok.tx2,
		Visible = false,
	}, b)
	local badge = label({
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, D.badge),
		BackgroundColor3 = tok.accent,
		Text = "",
		TextSize = D.fSmall,
		FontFace = F_MONO,
		TextColor3 = tok.tx,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextTruncate = Enum.TextTruncate.None,
		Visible = false,
	}, b)
	badge.BackgroundTransparency = 0.84
	corner(badge, D.rBadge)
	pad(badge, 0, 6, 0, 6)
	hover(b, function(on)
		if win._current ~= self then
			tween(b, quick(), { BackgroundTransparency = on and 0.5 or 1 })
		end
	end)
	connect(b.Activated, function()
		win:SelectTab(self)
	end)
	self._sideUI = { button = b, icon = ic, setIcon = setIcon, text = text, letter = letter, badge = badge }
end

function Tab:_setBadge(count)
	self._badgeCount = count
	local s, t = self._sideUI, self._topUI
	local show = count ~= nil and count > 0
	local text = show and tostring(count) or ""
	s.badge.Text = text
	s.badge.Visible = show and not self._win._compact
	t.badge.Text = text
	t.badge.Visible = show
	local dim = count == 0 and 0.55 or 0
	tween(s.text, quick(), { TextTransparency = dim })
	tween(t.text, quick(), { TextTransparency = dim })
end

function Tab:_buildTopButton()
	local win = self._win
	local parent = self._bottom and win._navRight or win._navList
	local b = button({
		LayoutOrder = self._bottom and 100 or #win._tabs,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, D.nav),
	}, parent)
	local inner = frame({ AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromScale(0, 1) }, b)
	pad(inner, 0, 12, 0, 12)
	list(inner, true, 8, nil, Enum.VerticalAlignment.Center)
	local setIcon
	if self._icon then
		local ic
		ic, setIcon = icon(self._icon, inner, 15, "tx3")
		ic.LayoutOrder = 1
	end
	local text = label({
		LayoutOrder = 2,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 16),
		Text = self.Name,
		TextColor3 = tok.tx2,
		TextTruncate = Enum.TextTruncate.None,
	}, inner)
	local badge = label({
		LayoutOrder = 3,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, D.badge),
		BackgroundColor3 = tok.accent,
		Text = "",
		TextSize = D.fSmall,
		FontFace = F_MONO,
		TextColor3 = tok.tx,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextTruncate = Enum.TextTruncate.None,
		Visible = false,
	}, inner)
	badge.BackgroundTransparency = 0.84
	corner(badge, D.rBadge)
	pad(badge, 0, 6, 0, 6)
	local underline = frame({
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		Size = UDim2.new(1, 0, 0, 2),
		BackgroundColor3 = tok.accent,
		BackgroundTransparency = 1,
		ZIndex = 3,
	}, b)
	hover(b, function(on)
		if win._current ~= self then
			paint(text, "TextColor3", on and "tx" or "tx2", true)
		end
	end)
	connect(b.Activated, function()
		win:SelectTab(self)
	end)
	self._topUI = { button = b, setIcon = setIcon, text = text, underline = underline, badge = badge }
end

function Tab:_setActive(on)
	local s = self._sideUI
	tween(s.button, quick(), { BackgroundTransparency = on and 0 or 1 })
	paint(s.text, "TextColor3", on and "tx" or "tx2", true)
	paint(s.letter, "TextColor3", on and "accent" or "tx2", true)
	if s.setIcon then
		s.setIcon(on and "accent" or "tx3", true)
	end
	local t = self._topUI
	paint(t.text, "TextColor3", on and "tx" or "tx2", true)
	if t.setIcon then
		t.setIcon(on and "accent" or "tx3", true)
	end
	tween(t.underline, quick(), { BackgroundTransparency = on and 0 or 1 })
end

function Tab:_setColumns(single)
	self._columnsLayout.FillDirection = single and Enum.FillDirection.Vertical or Enum.FillDirection.Horizontal
	local size = single and UDim2.new(1, 0, 0, 0) or UDim2.new(0.5, -D.colGap / 2, 0, 0)
	self._left.Size = size
	self._right.Size = size
end

function Tab:_setCompact(compact)
	local s = self._sideUI
	s.text.Visible = not compact
	s.letter.Visible = compact and s.icon == nil
	s.badge.Visible = not compact and self._badgeCount ~= nil and self._badgeCount > 0
	if s.icon then
		s.icon.AnchorPoint = compact and Vector2.new(0.5, 0.5) or Vector2.new(0, 0.5)
		s.icon.Position = compact and UDim2.fromScale(0.5, 0.5) or UDim2.new(0, 10, 0.5, 0)
	end
end

function Tab:Select()
	self._win:SelectTab(self)
	return self
end

function Tab:Remove()
	if self._removed then
		return nil
	end
	self._removed = true
	local win = self._win
	for _, entry in ipairs(self._groups) do
		for _, container in ipairs(entry.containers) do
			container:Clear()
		end
	end
	table.clear(self._groups)
	local index = table.find(win._tabs, self)
	if index then
		table.remove(win._tabs, index)
	end
	if win._current == self then
		win._current = nil
		for _, other in ipairs(win._tabs) do
			if not other._bottom then
				win:SelectTab(other)
				break
			end
		end
	end
	win:_closePopup()
	if self._page then
		self._page:Destroy()
		self._page = nil
	end
	if self._sideUI and self._sideUI.button then
		self._sideUI.button:Destroy()
	end
	if self._topUI and self._topUI.button then
		self._topUI.button:Destroy()
	end
	return nil
end

Tab.Destroy = Tab.Remove

function Library:_startInput()
	if S.inputStarted then
		return
	end
	S.inputStarted = true
	local function keyOf(input)
		if input.UserInputType == Enum.UserInputType.Keyboard then
			return input.KeyCode
		end
		return input.UserInputType
	end
	connect(UserInputService.InputBegan, function(input, processed)
		local listening = S.listening
		if listening then
			listening:_capture(input)
			return
		end
		if processed then
			return
		end
		local key = keyOf(input)
		local win = Library._window
		if win and not S.mobile and win._menuKey and key == win._menuKey then
			win:Toggle()
		end
		local pressed = S.keyMap[key]
		if pressed then
			for _, kb in ipairs(table.clone(pressed)) do
				kb:_press()
			end
		end
	end)
	connect(UserInputService.InputEnded, function(input)
		local key = keyOf(input)
		local released = S.keyMap[key]
		if released then
			for _, kb in ipairs(table.clone(released)) do
				kb:_release()
			end
		end
	end)
end

local Container = {}
Container.__index = Container

local Element = {}
Element.__index = Element

local function class()
	local c = setmetatable({}, { __index = Element })
	c.__index = c
	return c
end

local function args(flag, options)
	if type(flag) == "table" then
		return flag.Flag or flag.Idx, flag
	end
	return flag, options or {}
end

function Element:_applyVisible()
	if self._root then
		self._root.Visible = self._visible and self._match and not self._hiddenByDevice
	end
end

function Element:SetVisible(v)
	self._visible = v ~= false
	self:_applyVisible()
	return self
end

function Element:OnChanged(f)
	self._changed[#self._changed + 1] = f
	return self
end

function Element:_emit(...)
	if self.Flag then
		Library.Flags[self.Flag] = self.Value
	end
	if self._callback then
		task.spawn(self._callback, ...)
	end
	for _, f in ipairs(self._changed) do
		task.spawn(f, ...)
	end
end

function Element:SetText(text)
	self.Text = tostring(text or "")
	self._search = self.Text
	if self._label then
		self._label.Text = self.Text
	end
	return self
end

function Element:GetValue()
	return self.Value
end

function Element:Destroy()
	if self._destroyed then
		return nil
	end
	self._destroyed = true
	local container = self._container
	if container then
		local index = table.find(container._items, self)
		if index then
			table.remove(container._items, index)
		end
	end
	local flag = self.Flag
	if flag then
		if Library.Options[flag] == self then
			Library.Options[flag] = nil
			local index = table.find(Library._order, flag)
			if index then
				table.remove(Library._order, index)
			end
			Library.Flags[flag] = nil
		end
		if Library.Toggles[flag] == self then
			Library.Toggles[flag] = nil
		end
	end
	if self._hud then
		local index = table.find(S.hud, self)
		if index then
			table.remove(S.hud, index)
		end
		self._hud = false
		Library:_refreshArrayList()
	end
	if self._root then
		self._root:Destroy()
		self._root = nil
	end
	return nil
end

local function makeCollapse(win, clip, measure, chevron, onShown)
	local c = { open = true, forced = false, id = 0 }
	local function shown()
		return c.open or c.forced
	end
	c.shown = shown
	function c.apply(animated)
		c.id = c.id + 1
		local id = c.id
		local on = shown()
		if chevron then
			if animated and S.animate then
				tween(chevron, info(0.25, Style.Quint, Direction.Out), { Rotation = on and 0 or -90 })
			else
				chevron.Rotation = on and 0 or -90
			end
		end
		if onShown then
			onShown(on, animated)
		end
		if not animated or not S.animate or not clip.Parent then
			clip.AutomaticSize = on and Enum.AutomaticSize.Y or Enum.AutomaticSize.None
			clip.Size = UDim2.new(1, 0, 0, 0)
			clip.Visible = on
			return
		end
		local scale = win._fit.Scale > 0 and win._fit.Scale or 1
		local current = clip.Visible and clip.AbsoluteSize.Y / scale or 0
		clip.AutomaticSize = Enum.AutomaticSize.None
		clip.Size = UDim2.new(1, 0, 0, current)
		clip.Visible = true
		local target = on and measure() / scale or 0
		if on and target <= 0 then
			clip.AutomaticSize = Enum.AutomaticSize.Y
			clip.Size = UDim2.new(1, 0, 0, 0)
			return
		end
		local duration = on and 0.3 or 0.22
		tween(clip, info(duration, Style.Quint, Direction.Out), { Size = UDim2.new(1, 0, 0, target) })
		task.delay(duration / S.speed, function()
			if c.id ~= id or not clip.Parent then
				return
			end
			if on then
				clip.AutomaticSize = Enum.AutomaticSize.Y
				clip.Size = UDim2.new(1, 0, 0, 0)
			else
				clip.Visible = false
			end
		end)
	end
	function c.set(v, animated)
		v = v ~= false
		if c.open == v then
			return
		end
		c.open = v
		c.apply(animated ~= false)
	end
	function c.force(v)
		v = v == true
		if c.forced == v then
			return
		end
		local before = shown()
		c.forced = v
		if shown() ~= before then
			c.apply(false)
		end
	end
	return c
end

function Container.new(tab, group, body, entry)
	return setmetatable({
		_tab = tab,
		_win = tab._win,
		_group = group,
		_body = body,
		_entry = entry,
		_items = {},
		_sections = {},
		_order = 0,
	}, Container)
end

function Container:SetCollapsed(v, animated)
	if self._collapse then
		self._collapse.set(v ~= true, animated)
	end
	return self
end

function Container:IsCollapsed()
	return self._collapse ~= nil and not self._collapse.open
end

function Container:ToggleCollapsed(animated)
	if self._collapse then
		self._collapse.set(not self._collapse.open, animated)
	end
	return self
end

function Container:AddModule(flag, options)
	flag, options = args(flag, options)
	local root = frame({
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = self:_next(),
	}, self._body)
	list(root, false, 0)

	local toggle = self:_toggle(flag, options, "Checkbox", root, options.Hud ~= false)
	toggle._root.LayoutOrder = 1

	local arrow = button({
		LayoutOrder = 0,
		Size = UDim2.fromOffset(D.checkBox, D.checkBox),
		ZIndex = 3,
	}, toggle._root)
	local chev, setChev = icon("chevron", arrow, D.iconSm / D.iconScale, "tx3")
	chev.AnchorPoint = Vector2.new(0.5, 0.5)
	chev.Position = UDim2.fromScale(0.5, 0.5)

	local settings = frame({
		LayoutOrder = 2,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	}, root)
	local clip = frame({
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ClipsDescendants = true,
	}, settings)
	frame({
		Position = UDim2.fromOffset(math.floor(D.checkBox / 2), 2),
		Size = UDim2.new(0, 1, 1, -4),
		BackgroundColor3 = tok[D.lineToken],
	}, clip)
	local body = frame({
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	}, clip)
	pad(body, 4, 0, 3, D.checkBox + D.rowGap)
	list(body, false, D.gap)

	local c = Container.new(self._tab, self._group, body, self._entry)
	c._name = toggle.Text
	c._root = settings
	c._parent = self
	c._owner = toggle
	c._visible = true
	c.Toggle = toggle
	self._sections[#self._sections + 1] = c
	toggle._module = c

	c._collapse = makeCollapse(self._win, clip, function()
		return body.AbsoluteSize.Y
	end, chev, nil)
	c._collapse.set(options.Open == true, false)
	hover(arrow, function(on)
		setChev(on and "tx" or "tx3", true)
	end)
	connect(arrow.Activated, function()
		c._collapse.set(not c._collapse.open, true)
	end)
	return c
end

function Container:AddSection(name, options)
	if type(name) == "table" then
		options = name
		name = options.Name or options.Title
	end
	options = options or {}
	name = tostring(name or "")
	local root = frame({
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = self:_next(),
	}, self._body)
	list(root, false, 0)
	local collapsible = options.Collapsible ~= false
	local headH = D.section
	local header = button({ LayoutOrder = 1, Size = UDim2.new(1, 0, 0, headH) }, root)
	local x = 0
	local chev
	if collapsible then
		chev = icon("chevron", header, 12, "tx3")
		chev.AnchorPoint = Vector2.new(0, 0.5)
		chev.Position = UDim2.new(0, 0, 0.5, 0)
		x = 18
	end
	local ic
	if options.Icon then
		ic = icon(options.Icon, header, 13, "tx2")
		ic.AnchorPoint = Vector2.new(0, 0.5)
		ic.Position = UDim2.new(0, x, 0.5, 0)
		x = x + 19
	end
	local title = label({
		Position = UDim2.fromOffset(x, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 1, 0),
		Text = name,
		TextSize = D.fLabel,
		FontFace = F_SEMI,
		TextColor3 = tok.tx2,
		TextTruncate = Enum.TextTruncate.None,
	}, header)
	local rule = frame({
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, x, 0.5, 0),
		Size = UDim2.new(1, -x, 0, 1),
		BackgroundColor3 = tok[D.lineToken],
	}, header)
	local function placeRule()
		local w = title.AbsoluteSize.X / (self._win._fit.Scale > 0 and self._win._fit.Scale or 1)
		local left = x + (name ~= "" and w + 10 or 0)
		rule.Position = UDim2.new(0, left, 0.5, 0)
		rule.Size = UDim2.new(1, -left, 0, 1)
	end
	connect(title:GetPropertyChangedSignal("AbsoluteSize"), placeRule)
	placeRule()
	local clip = frame({
		LayoutOrder = 2,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ClipsDescendants = true,
	}, root)
	frame({
		Position = UDim2.fromOffset(5, 6),
		Size = UDim2.new(0, 1, 1, -6),
		BackgroundColor3 = tok[D.lineToken],
	}, clip)
	local body = frame({
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	}, clip)
	pad(body, 6, 0, 2, 16)
	list(body, false, D.gap)
	local c = Container.new(self._tab, self._group, body, self._entry)
	c._name = name
	c._root = root
	c._parent = self
	c._visible = options.Visible ~= false
	root.Visible = c._visible
	self._sections[#self._sections + 1] = c
	if collapsible then
		c._collapse = makeCollapse(self._win, clip, function()
			return body.AbsoluteSize.Y
		end, chev, function(on)
			paint(title, "TextColor3", on and "tx2" or "tx3", true)
		end)
		hover(header, function(on)
			paint(title, "TextColor3", on and "tx" or (c._collapse.shown() and "tx2" or "tx3"), true)
		end)
		connect(header.Activated, function()
			c._collapse.set(not c._collapse.open, true)
		end)
		if options.Collapsed == true or options.Open == false then
			c._collapse.set(false, false)
		end
	end
	return c
end

function Container:SetSectionVisible(v)
	if self._root then
		self._visible = v ~= false
		self._root.Visible = self._visible
	end
	return self
end

function Container:Clear()
	for _, el in ipairs(table.clone(self._items)) do
		el:Destroy()
	end
	table.clear(self._items)
	for _, section in ipairs(table.clone(self._sections)) do
		section:Clear()
		if section._root then
			section._root:Destroy()
			section._root = nil
		end
	end
	table.clear(self._sections)
	self._order = 0
	return self
end

function Container:_next()
	self._order = self._order + 1
	return self._order
end

function Container:_add(cls, kind, flag, options, root)
	local text = options.Text or options.Title or ""
	local el = setmetatable({
		Type = kind,
		Flag = flag,
		Text = tostring(text),
		_container = self,
		_win = self._win,
		_root = root,
		_changed = {},
		_callback = options.Callback,
		_visible = options.Visible ~= false,
		_match = true,
		_noSave = options.NoSave == true,
		_search = tostring(text) .. " " .. tostring(options.Tooltip or ""),
	}, cls)
	root.LayoutOrder = self:_next()
	self._items[#self._items + 1] = el
	if flag then
		registerOption(flag, el)
	end
	if options.Tooltip then
		self._win:_tooltip(root, options.Tooltip)
	end
	el:_applyVisible()
	return el
end

function Tab:_body(parent, order)
	local body = frame({
		LayoutOrder = order,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	}, parent)
	pad(body, D.padTop, D.padX, D.padBottom, D.padX)
	list(body, false, D.gap)
	return body
end

function Tab:_groupFrame(side)
	local column = string.lower(tostring(side or "Left")) == "right" and self._right or self._left
	local box = frame({
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = tok[D.boxToken],
		LayoutOrder = #self._groups + 1,
	}, column)
	corner(box, D.rBox)
	stroke(box, D.lineToken)
	list(box, false, 0)
	local header = button({ LayoutOrder = 1, Size = UDim2.new(1, 0, 0, D.groupHeader) }, box)
	local divider = frame({ Position = UDim2.new(0, 0, 1, -1), Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = tok[D.lineToken] }, header)
	local clip = frame({
		LayoutOrder = 2,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ClipsDescendants = true,
	}, box)
	local layout = list(clip, false, 0)
	return box, header, clip, layout, divider
end

function Tab:_groupHeader(header, options, rightInset)
	local name = tostring(options.Name or options.Title or "")
	local x = 14
	local ic
	if options.Icon then
		ic = icon(options.Icon, header, 16, "accent")
		ic.AnchorPoint = Vector2.new(0, 0.5)
		ic.Position = UDim2.new(0, x, 0.5, 0)
		x = x + 24
	end
	local title
	if name ~= "" then
		title = label({
			Position = UDim2.fromOffset(x, 0),
			Size = UDim2.new(1, -(x + rightInset), 1, 0),
			Text = name,
			TextSize = D.fGroup,
			FontFace = F_SEMI,
		}, header)
	end
	local chev, chevSet
	if options.Collapsible ~= false then
		chev, chevSet = icon("chevron", header, 14, "tx3")
		chev.AnchorPoint = Vector2.new(1, 0.5)
		chev.Position = UDim2.new(1, -12, 0.5, 0)
	end
	return name, title, chev, chevSet
end

function Tab:_groupCollapse(c, options, header, clip, layout, divider, chev, chevSet, entry)
	if options.Collapsible == false then
		return
	end
	local col = makeCollapse(self._win, clip, function()
		return layout.AbsoluteContentSize.Y
	end, chev, function(on, animated)
		if animated and S.animate then
			tween(divider, quick(), { BackgroundTransparency = on and 0 or 1 })
		else
			divider.BackgroundTransparency = on and 0 or 1
		end
	end)
	entry.collapse = col
	if c then
		c._collapse = col
	end
	if chevSet then
		hover(header, function(on)
			chevSet(on and "tx" or "tx3", true)
		end)
	end
	connect(header.Activated, function()
		col.set(not col.open, true)
	end)
	if options.Collapsed == true or options.Open == false then
		col.set(false, false)
	end
	return col
end

function Tab:AddGroupbox(options)
	if type(options) == "string" then
		options = { Name = options }
	end
	options = options or {}
	local box, header, clip, layout, divider = self:_groupFrame(options.Side)
	local name, _, chev, chevSet = self:_groupHeader(header, options, options.Collapsible ~= false and (D.padX + 24) or D.padX)
	local body = self:_body(clip, 1)
	local entry = { frame = box, name = name, containers = {} }
	local c = Container.new(self, box, body, entry)
	entry.containers[1] = c
	self._groups[#self._groups + 1] = entry
	self:_groupCollapse(c, options, header, clip, layout, divider, chev, chevSet, entry)
	return c
end

function Tab:AddLeftGroupbox(name, options)
	if type(name) == "table" then
		options = name
	else
		options = options or {}
		options.Name = name
	end
	options.Side = "Left"
	return self:AddGroupbox(options)
end

function Tab:AddRightGroupbox(name, options)
	if type(name) == "table" then
		options = name
	else
		options = options or {}
		options.Name = name
	end
	options.Side = "Right"
	return self:AddGroupbox(options)
end

local Tabbox = {}
Tabbox.__index = Tabbox

function Tab:AddTabbox(options)
	if type(options) == "string" then
		options = { Name = options }
	end
	options = options or {}
	local box, header, clip, layout, divider = self:_groupFrame(options.Side)
	local collapsible = options.Collapsible ~= false
	local name, title, chev, chevSet = self:_groupHeader(header, options, 14)
	if title then
		title.Size = UDim2.new(0.45, -title.Position.X.Offset, 1, 0)
	end
	local right = collapsible and 34 or 10
	local buttons = frame({
		AnchorPoint = Vector2.new(name ~= "" and 1 or 0, 0.5),
		Position = name ~= "" and UDim2.new(1, -right, 0.5, 0) or UDim2.new(0, 10, 0.5, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 24),
	}, header)
	list(buttons, true, 2, nil, Enum.VerticalAlignment.Center)
	local entry = { frame = box, name = name, containers = {} }
	self._groups[#self._groups + 1] = entry
	local tb = setmetatable({ _tab = self, _box = box, _clip = clip, _buttons = buttons, _subs = {}, _entry = entry }, Tabbox)
	entry.tabbox = tb
	tb._collapse = self:_groupCollapse(nil, options, header, clip, layout, divider, chev, chevSet, entry)
	return tb
end

function Tab:AddLeftTabbox(name, options)
	if type(name) == "table" then
		options = name
	else
		options = options or {}
		options.Name = name
	end
	options.Side = "Left"
	return self:AddTabbox(options)
end

function Tab:AddRightTabbox(name, options)
	if type(name) == "table" then
		options = name
	else
		options = options or {}
		options.Name = name
	end
	options.Side = "Right"
	return self:AddTabbox(options)
end

function Tabbox:SetCollapsed(v, animated)
	if self._collapse then
		self._collapse.set(v ~= true, animated)
	end
	return self
end

function Tabbox:IsCollapsed()
	return self._collapse ~= nil and not self._collapse.open
end

function Tabbox:AddTab(name)
	local index = #self._subs + 1
	local body = self._tab:_body(self._clip, index)
	body.Visible = index == 1
	local c = Container.new(self._tab, self._box, body, self._entry)
	local b = button({
		LayoutOrder = index,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, D.subTab),
		BackgroundColor3 = tok.el2,
		BackgroundTransparency = 1,
		Text = tostring(name or ("Tab " .. index)),
		TextSize = D.fSmall,
		FontFace = F_MED,
		TextColor3 = tok.tx3,
	}, self._buttons)
	corner(b, D.rTiny)
	pad(b, 0, 8, 0, 8)
	local sub = { body = body, button = b, container = c }
	self._subs[index] = sub
	self._entry.containers[#self._entry.containers + 1] = c
	connect(b.Activated, function()
		self:_select(sub)
		if self._collapse and not self._collapse.open then
			self._collapse.set(true, true)
		end
	end)
	if index == 1 then
		self:_select(sub)
	end
	return c
end

function Tabbox:_select(sub)
	self._active = sub
	for _, s in ipairs(self._subs) do
		local on = s == sub
		s.body.Visible = on
		tween(s.button, quick(), { BackgroundTransparency = on and 0 or 1 })
		paint(s.button, "TextColor3", on and "tx" or "tx3", true)
	end
	self._tab._win:_closePopup()
end

local Toggle = class()

function Container:_toggle(flag, options, style, parent, hud)
	local checkbox = style == "Checkbox"
	local h = checkbox and D.checkRow or D.toggleRow
	local row = button({ Size = UDim2.new(1, 0, 0, h) }, parent or self._body)
	list(row, true, checkbox and 10 or 8, nil, Enum.VerticalAlignment.Center)
	local el = self:_add(Toggle, style, flag, options, row)
	el._style = style
	if checkbox then
		local box = frame({ LayoutOrder = 1, Size = UDim2.fromOffset(D.checkBox, D.checkBox), BackgroundColor3 = tok.el }, row)
		corner(box, D.rTiny)
		el._boxStroke = stroke(box, "line2")
		local mark = icon("check", box, math.floor(D.checkBox * 0.75 + 0.5) / D.iconScale, "onAccent")
		mark.AnchorPoint = Vector2.new(0.5, 0.5)
		mark.Position = UDim2.fromScale(0.5, 0.5)
		el._box = box
		el._mark = mark
		el._markScale = new("UIScale", {}, mark)
	end
	el._label = label({ LayoutOrder = 2, Size = UDim2.new(0, 0, 1, 0), Text = el.Text }, row)
	fill(el._label)
	local right = frame({
		LayoutOrder = 3,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, h),
	}, row)
	list(right, true, D.rowGap, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center)
	el._right = right
	if not checkbox then
		local sw = frame({ LayoutOrder = 10, Size = UDim2.fromOffset(D.switchW, D.switchH), BackgroundColor3 = tok.el2 }, right)
		corner(sw)
		el._swStroke = stroke(sw, "line2")
		el._knob = frame({
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, D.knobOff, 0.5, 0),
			Size = UDim2.fromOffset(D.knob, D.knob),
			BackgroundColor3 = tok.knobOff,
		}, sw)
		corner(el._knob)
		el._switch = sw
	end
	el.Value = options.Default == true
	el._hud = hud == true
	el._hudText = tostring(options.HudText or options.Text or "")
	if el._hud then
		S.hud[#S.hud + 1] = el
	end
	if flag then
		Library.Toggles[flag] = el
		Library.Flags[flag] = el.Value
	end
	el:_render(false)
	connect(row.Activated, function()
		el:SetValue(not el.Value)
	end)
	if options.Keybind ~= nil then
		el:AddKeybind(flag and (flag .. "_Keybind") or nil, {
			Default = options.Keybind,
			Mode = options.KeybindMode or "Toggle",
		})
	end
	return el
end

local function toggleStyle(options)
	local style = options.Style
	if style == nil then
		style = D.toggleStyle
	end
	if string.lower(tostring(style)) == "checkbox" then
		return "Checkbox"
	end
	return "Toggle"
end

function Container:AddToggle(flag, options)
	flag, options = args(flag, options)
	return self:_toggle(flag, options, toggleStyle(options), nil, options.Hud == true)
end

function Container:AddCheckbox(flag, options)
	flag, options = args(flag, options)
	return self:_toggle(flag, options, "Checkbox", nil, options.Hud == true)
end

function Toggle:_render(animated)
	local on = self.Value
	if self._style == "Checkbox" then
		paint(self._box, "BackgroundColor3", on and "accent" or "el", animated)
		paint(self._boxStroke, "Color", on and "accent" or "line2", animated)
		self._mark.Visible = on
		if on and animated and S.animate then
			self._markScale.Scale = 0.4
			tween(self._markScale, pop(), { Scale = 1 })
		end
	else
		paint(self._switch, "BackgroundColor3", on and "accent" or "el2", animated)
		paint(self._swStroke, "Color", on and "accent" or "line2", animated)
		paint(self._knob, "BackgroundColor3", on and "onAccent" or "knobOff", animated)
		local pos = UDim2.new(0, on and D.knobOn or D.knobOff, 0.5, 0)
		if animated then
			tween(self._knob, info(0.22, Style.Quint, Direction.Out), { Position = pos })
		else
			self._knob.Position = pos
		end
	end
end

function Toggle:SetValue(v, silent)
	v = v == true
	if v == self.Value then
		return self
	end
	self.Value = v
	self:_render(true)
	if silent then
		if self.Flag then
			Library.Flags[self.Flag] = v
		end
	else
		self:_emit(v)
	end
	Library:_refreshKeybinds()
	if self._hud then
		Library:_refreshArrayList()
	end
	return self
end

function Toggle:Destroy()
	if self._destroyed then
		return nil
	end
	if self._keybind then
		self._keybind:Destroy()
		self._keybind = nil
	end
	if self._picker then
		self._picker:Destroy()
		self._picker = nil
	end
	return Element.Destroy(self)
end

function Toggle:_serialize()
	return self.Value
end

function Toggle:_deserialize(v)
	self:SetValue(v == true)
end

local Slider = class()

local function formatNumber(value, step)
	local d = decimals(step)
	if d > 0 then
		return string.format("%." .. d .. "f", value)
	end
	return string.format("%.0f", value)
end

function Container:AddSlider(flag, options)
	flag, options = args(flag, options)
	local min, max = tonumber(options.Min) or 0, tonumber(options.Max) or 100
	if max < min then
		min, max = max, min
	end
	local step = tonumber(options.Increment)
	if not step and tonumber(options.Rounding) then
		step = 10 ^ -math.floor(tonumber(options.Rounding))
	end
	step = step or 1

	local root = frame({ Size = UDim2.new(1, 0, 0, D.sliderRow) }, self._body)
	local el = self:_add(Slider, "Slider", flag, options, root)
	el.Min, el.Max, el._step = min, max, step
	el._suffix = tostring(options.Suffix or "")
	el._label = label({ Size = UDim2.new(1, -80, 0, D.sliderTop - 4), Text = el.Text }, root)
	el._valueLabel = new("TextBox", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.fromOffset(80, D.sliderTop - 4),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = "",
		TextXAlignment = Enum.TextXAlignment.Right,
		TextSize = D.fSmall,
		FontFace = F_MONO,
		TextColor3 = tok.tx2,
		TextEditable = false,
		ClearTextOnFocus = false,
		ClipsDescendants = true,
	}, root)
	if options.Input ~= false then
		local edit = button({
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.fromScale(1, 0),
			Size = UDim2.fromOffset(80, D.sliderTop - 2),
		}, root)
		local function stopEdit(apply)
			if not el._editing then
				return
			end
			el._editing = false
			el._valueLabel.TextEditable = false
			edit.Visible = true
			if apply then
				local typed = tonumber((string.gsub(el._valueLabel.Text, "[^%d%.%-]", "")))
				if typed then
					el:_set(typed, true)
				end
			end
			el:_render(false)
		end
		connect(edit.Activated, function()
			if el._editing then
				return
			end
			el._editing = true
			edit.Visible = false
			el._valueLabel.TextEditable = true
			el._valueLabel.Text = formatNumber(el.Value, el._step)
			el._valueLabel:CaptureFocus()
		end)
		connect(el._valueLabel.FocusLost, function()
			stopEdit(true)
		end)
		el._stopEdit = stopEdit
	end
	local zone = button({ Position = UDim2.fromOffset(0, D.sliderTop), Size = UDim2.new(1, 0, 1, -D.sliderTop) }, root)
	local trackFrame = frame({
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.new(1, 0, 0, D.track),
		BackgroundColor3 = tok.el2,
	}, zone)
	corner(trackFrame, D.rTrack)
	el._fill = frame({ Size = UDim2.fromScale(0, 1), BackgroundColor3 = tok.accent }, trackFrame)
	corner(el._fill, D.rTrack)
	local thumb = D.thumb
	el._thumb = frame({
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromOffset(thumb, thumb),
		BackgroundColor3 = tok.white,
		ZIndex = 2,
	}, trackFrame)
	corner(el._thumb)
	stroke(el._thumb, "accent", 3, 0.7)
	el._thumbScale = new("UIScale", {}, el._thumb)
	el._track = trackFrame

	el.Value = snap(tonumber(options.Default) or min, min, max, step)
	if flag then
		Library.Flags[flag] = el.Value
	end
	el:_render(false)

	local page = self._tab._page
	local function setFrom(pos)
		local a, s = trackFrame.AbsolutePosition, trackFrame.AbsoluteSize
		if s.X <= 0 then
			return
		end
		local alpha = math.clamp((pos.X - a.X) / s.X, 0, 1)
		el:_set(min + alpha * (max - min), false)
	end
	track(zone, {
		start = function(pos)
			el._dragging = true
			page.ScrollingEnabled = false
			tween(el._thumbScale, quick(), { Scale = 1.15 })
			setFrom(pos)
		end,
		move = setFrom,
		stop = function()
			el._dragging = false
			page.ScrollingEnabled = true
			tween(el._thumbScale, quick(), { Scale = 1 })
		end,
	})
	return el
end

function Slider:_render(animated)
	local range = self.Max - self.Min
	local alpha = range > 0 and (self.Value - self.Min) / range or 0
	local fillSize = UDim2.fromScale(alpha, 1)
	local thumbPos = UDim2.fromScale(alpha, 0.5)
	if animated and not self._dragging then
		tween(self._fill, quick(), { Size = fillSize })
		tween(self._thumb, quick(), { Position = thumbPos })
	else
		self._fill.Size = fillSize
		self._thumb.Position = thumbPos
	end
	if not self._editing then
		self._valueLabel.Text = formatNumber(self.Value, self._step) .. self._suffix
	end
end

function Slider:_set(v, animated)
	v = snap(tonumber(v) or self.Value, self.Min, self.Max, self._step)
	if v == self.Value then
		return
	end
	self.Value = v
	self:_render(animated)
	self:_emit(v)
end

function Slider:SetValue(v)
	self:_set(v, true)
	return self
end

function Slider:SetMin(v)
	self.Min = tonumber(v) or self.Min
	self:_set(self.Value, true)
	self:_render(true)
	return self
end

function Slider:SetMax(v)
	self.Max = tonumber(v) or self.Max
	self:_set(self.Value, true)
	self:_render(true)
	return self
end

function Slider:_serialize()
	return self.Value
end

function Slider:_deserialize(v)
	self:SetValue(v)
end

local Input = class()

function Container:AddInput(flag, options)
	flag, options = args(flag, options)
	local hasText = tostring(options.Text or "") ~= ""
	local boxH = D.inputBox
	local root = frame({ Size = UDim2.new(1, 0, 0, (hasText and D.inputLabel or 0) + boxH) }, self._body)
	local el = self:_add(Input, "Input", flag, options, root)
	if hasText then
		el._label = label({ Size = UDim2.new(1, 0, 0, 16), Text = el.Text, TextSize = D.fLabel, TextColor3 = tok.tx2 }, root)
	end
	local box = frame({
		Position = UDim2.fromOffset(0, hasText and 22 or 0),
		Size = UDim2.new(1, 0, 0, boxH),
		BackgroundColor3 = tok.el,
	}, root)
	corner(box, D.rCtrl)
	local st = stroke(box, D.lineToken)
	local tb = new("TextBox", {
		Position = UDim2.fromOffset(10, 0),
		Size = UDim2.new(1, -20, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = tostring(options.Default or ""),
		PlaceholderText = tostring(options.Placeholder or ""),
		PlaceholderColor3 = tok.tx3,
		TextColor3 = tok.tx,
		TextSize = D.fBody,
		FontFace = F_REG,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = options.ClearTextOnFocus == true,
		ClipsDescendants = true,
	}, box)
	el._box = tb
	el._finished = options.Finished == true
	el._numeric = options.Numeric == true
	el._maxLength = tonumber(options.MaxLength)
	el.Value = tb.Text
	if flag then
		Library.Flags[flag] = el.Value
	end
	connect(tb.Focused, function()
		bindTween(st, "Color", "accent")
		tween(st, quick(), { Transparency = 0.45 })
	end)
	connect(tb.FocusLost, function()
		bindTween(st, "Color", D.lineToken)
		tween(st, quick(), { Transparency = 0 })
		if el._finished then
			el:_commit(tb.Text)
		end
	end)
	connect(tb:GetPropertyChangedSignal("Text"), function()
		local t = tb.Text
		if el._numeric then
			local cleaned = string.gsub(t, "[^%d%.%-]", "")
			if cleaned ~= t then
				tb.Text = cleaned
				return
			end
		end
		if el._maxLength and #t > el._maxLength then
			tb.Text = string.sub(t, 1, el._maxLength)
			return
		end
		if not el._finished then
			el:_commit(t)
		end
	end)
	return el
end

function Input:_commit(t)
	if t == self.Value then
		return
	end
	self.Value = t
	self:_emit(t)
end

function Input:SetValue(t)
	t = tostring(t or "")
	self._box.Text = t
	self:_commit(self._box.Text)
	return self
end

function Input:_serialize()
	return self.Value
end

function Input:_deserialize(v)
	self:SetValue(v)
end

local Stepper = class()

function Container:AddStepper(flag, options)
	flag, options = args(flag, options)
	local min, max = tonumber(options.Min) or 0, tonumber(options.Max) or 100
	if max < min then
		min, max = max, min
	end
	local step = tonumber(options.Step) or tonumber(options.Increment) or 1
	local h = D.stepperRow
	local row = frame({ Size = UDim2.new(1, 0, 0, h) }, self._body)
	list(row, true, D.rowGap, nil, Enum.VerticalAlignment.Center)
	local el = self:_add(Stepper, "Stepper", flag, options, row)
	el.Min, el.Max, el._step = min, max, step
	el._label = label({ LayoutOrder = 1, Size = UDim2.new(0, 0, 1, 0), Text = el.Text }, row)
	fill(el._label)

	local ctrl = frame({ LayoutOrder = 2, Size = UDim2.fromOffset(h * 2 + D.stepperValue + 2, h), BackgroundColor3 = tok.el }, row)
	corner(ctrl, D.rCtrl)
	stroke(ctrl, "line2")
	frame({ Position = UDim2.fromOffset(h, 0), Size = UDim2.fromOffset(1, h), BackgroundColor3 = tok[D.lineToken] }, ctrl)
	frame({ Position = UDim2.fromOffset(h + D.stepperValue + 1, 0), Size = UDim2.fromOffset(1, h), BackgroundColor3 = tok[D.lineToken] }, ctrl)
	el._valueLabel = label({
		Position = UDim2.fromOffset(h + 1, 0),
		Size = UDim2.fromOffset(D.stepperValue, h),
		TextXAlignment = Enum.TextXAlignment.Center,
		TextSize = D.fLabel,
		FontFace = F_MONO,
	}, ctrl)

	local function stepButton(x, iconName, dir)
		local b = button({ Position = UDim2.fromOffset(x, 0), Size = UDim2.fromOffset(h, h) }, ctrl)
		local ic, setIcon = icon(iconName, b, 12, "tx2")
		ic.AnchorPoint = Vector2.new(0.5, 0.5)
		ic.Position = UDim2.fromScale(0.5, 0.5)
		hover(b, function(on)
			setIcon(on and "tx" or "tx2", true)
		end)
		local holding = 0
		connect(b.MouseButton1Down, function()
			holding = holding + 1
			local mine = holding
			el:_set(el.Value + dir * el._step)
			task.delay(0.4, function()
				while holding == mine and el._root.Parent and not Library.Unloaded do
					local before = el.Value
					el:_set(el.Value + dir * el._step)
					if el.Value == before then
						break
					end
					task.wait(0.06)
				end
			end)
		end)
		local function release()
			holding = holding + 1
		end
		connect(b.MouseButton1Up, release)
		connect(b.MouseLeave, release)
	end
	stepButton(0, "minus", -1)
	stepButton(h + D.stepperValue + 2, "plus", 1)

	el.Value = snap(tonumber(options.Default) or min, min, max, step)
	if flag then
		Library.Flags[flag] = el.Value
	end
	el:_render()
	return el
end

function Stepper:_render()
	self._valueLabel.Text = formatNumber(self.Value, self._step)
end

function Stepper:_set(v)
	v = snap(tonumber(v) or self.Value, self.Min, self.Max, self._step)
	if v == self.Value then
		return
	end
	self.Value = v
	self:_render()
	self:_emit(v)
end

function Stepper:SetValue(v)
	self:_set(v)
	return self
end

function Stepper:_serialize()
	return self.Value
end

function Stepper:_deserialize(v)
	self:SetValue(v)
end

local Segmented = class()

function Container:AddSegmented(flag, options)
	flag, options = args(flag, options)
	local values = {}
	for _, v in ipairs(options.Values or {}) do
		values[#values + 1] = tostring(v)
	end
	local n = math.max(#values, 1)
	local hasText = tostring(options.Text or "") ~= ""
	local ctrlH = D.segmented
	local root = frame({ Size = UDim2.new(1, 0, 0, (hasText and D.inputLabel or 0) + ctrlH) }, self._body)
	local el = self:_add(Segmented, "Segmented", flag, options, root)
	el.Values = values
	if hasText then
		el._label = label({ Size = UDim2.new(1, 0, 0, 16), Text = el.Text, TextSize = D.fLabel, TextColor3 = tok.tx2 }, root)
	end
	local ctrl = frame({
		Position = UDim2.fromOffset(0, hasText and 22 or 0),
		Size = UDim2.new(1, 0, 0, ctrlH),
		BackgroundColor3 = tok.el,
	}, root)
	corner(ctrl, D.rCtrl)
	stroke(ctrl, D.lineToken)
	pad(ctrl, 2, 2, 2, 2)
	el._indicator = frame({
		Size = UDim2.new(1 / n, -2 * (n - 1) / n, 1, 0),
		BackgroundColor3 = tok.segOn,
	}, ctrl)
	corner(el._indicator, D.rSmall)
	local holder = frame({ Size = UDim2.fromScale(1, 1), ZIndex = 2 }, ctrl)
	list(holder, true, 2)
	el._buttons = {}
	for i, v in ipairs(values) do
		local b = button({
			LayoutOrder = i,
			Size = UDim2.new(1 / n, -2 * (n - 1) / n, 1, 0),
			Text = v,
			TextSize = D.fLabel,
			FontFace = F_MED,
			TextColor3 = tok.tx3,
		}, holder)
		el._buttons[i] = b
		connect(b.Activated, function()
			el:SetValue(v)
		end)
	end
	local default = options.Default
	if type(default) == "number" then
		default = values[default]
	end
	el.Value = table.find(values, tostring(default)) and tostring(default) or values[1]
	if flag then
		Library.Flags[flag] = el.Value
	end
	el:_render(false)
	return el
end

function Segmented:_render(animated)
	local n = math.max(#self.Values, 1)
	local i = table.find(self.Values, self.Value)
	self._indicator.Visible = i ~= nil
	if i then
		local pos = UDim2.new((i - 1) / n, (i - 1) * 2 / n, 0, 0)
		if animated then
			tween(self._indicator, info(0.25, Style.Quint, Direction.Out), { Position = pos })
		else
			self._indicator.Position = pos
		end
	end
	for index, b in ipairs(self._buttons) do
		paint(b, "TextColor3", index == i and "tx" or "tx3", animated)
	end
end

function Segmented:SetValue(v)
	v = tostring(v)
	if not table.find(self.Values, v) or v == self.Value then
		return self
	end
	self.Value = v
	self:_render(true)
	self:_emit(v)
	return self
end

function Segmented:_serialize()
	return self.Value
end

function Segmented:_deserialize(v)
	self:SetValue(v)
end

local Button = class()

function Button:_paint(animated)
	local v = self._variant
	local h = self._hover
	local bg, text, outline = "el", "tx", 0
	if v == "Primary" then
		bg, text, outline = h and "accentHover" or "accent", "onAccent", 1
	elseif v == "Danger" then
		bg, text = h and "el2" or "el", "danger"
	else
		bg = h and "el2" or "el"
	end
	paint(self._root, "BackgroundColor3", bg, animated)
	paint(self._label, "TextColor3", text, animated)
	self._stroke.Transparency = outline
end

function Button:_click()
	local options = self._options
	if options.DoubleClick and not self._armed then
		self._armed = true
		self._label.Text = tostring(options.ConfirmText or "Are you sure?")
		task.delay(2, function()
			if self._armed then
				self._armed = false
				self._label.Text = self.Text
			end
		end)
		return
	end
	self._armed = false
	self._label.Text = self.Text
	if self._callback then
		task.spawn(self._callback)
	end
	for _, f in ipairs(self._changed) do
		task.spawn(f)
	end
end

local function styleButton(el, btn, options)
	el._options = options
	el._variant = options.Variant or "Secondary"
	btn.BackgroundTransparency = 0
	corner(btn, D.rCtrl)
	el._stroke = stroke(btn, "line2")
	el._label = label({
		Size = UDim2.fromScale(1, 1),
		Text = el.Text,
		TextXAlignment = Enum.TextXAlignment.Center,
		FontFace = el._variant == "Primary" and F_SEMI or F_REG,
	}, btn)
	el:_paint(false)
	hover(btn, function(on)
		el._hover = on
		el:_paint(true)
	end)
	press(btn)
	connect(btn.Activated, function()
		el:_click()
	end)
end

function Container:AddButton(options, callback)
	if type(options) == "string" then
		options = { Text = options, Callback = callback }
	end
	options = options or {}
	local btn = button({ Size = UDim2.new(1, 0, 0, D.button), BackgroundColor3 = tok.el }, self._body)
	local el = self:_add(Button, "Button", nil, options, btn)
	styleButton(el, btn, options)
	return el
end

local ButtonRow = class()

function Container:AddButtons(items)
	local n = #items
	local row = frame({ Size = UDim2.new(1, 0, 0, D.button) }, self._body)
	list(row, true, D.rowGap)
	local texts = {}
	for _, o in ipairs(items) do
		texts[#texts + 1] = tostring(o.Text or "")
	end
	self:_add(ButtonRow, "Buttons", nil, { Text = table.concat(texts, " ") }, row)
	local out = {}
	for i, o in ipairs(items) do
		local btn = button({
			LayoutOrder = i,
			Size = UDim2.new(1 / n, -8 * (n - 1) / n, 1, 0),
			BackgroundColor3 = tok.el,
		}, row)
		local el = setmetatable({
			Type = "Button",
			Text = tostring(o.Text or ""),
			_container = self,
			_win = self._win,
			_root = btn,
			_changed = {},
			_callback = o.Callback,
			_visible = true,
			_match = true,
			_search = tostring(o.Text or ""),
		}, Button)
		styleButton(el, btn, o)
		out[i] = el
	end
	return out
end

function Button:SetText(text)
	self.Text = tostring(text or "")
	self._search = self.Text
	if not self._armed then
		self._label.Text = self.Text
	end
	return self
end

local Label = class()

function Container:AddLabel(text, options)
	if type(text) == "table" then
		options = text
		text = options.Text
	end
	options = options or {}
	local lbl = label({
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = tostring(text or ""),
		TextWrapped = true,
		RichText = options.RichText == true,
		TextColor3 = tok[options.Color or "tx"],
		TextSize = tonumber(options.Size) or 13,
	}, self._body)
	new("UISizeConstraint", { MinSize = Vector2.new(0, 18) }, lbl)
	local el = self:_add(Label, "Label", nil, { Text = text, Tooltip = options.Tooltip }, lbl)
	el._label = lbl
	return el
end

local Paragraph = class()

function Container:AddParagraph(options, content)
	if type(options) == "string" then
		options = { Title = options, Content = content }
	end
	options = options or {}
	local root = frame({ Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y }, self._body)
	list(root, false, 4)
	local title = tostring(options.Title or "")
	local body = tostring(options.Content or "")
	local el = self:_add(Paragraph, "Paragraph", nil, { Text = title .. " " .. body }, root)
	el._title = label({
		LayoutOrder = 1,
		Size = UDim2.new(1, 0, 0, 16),
		Text = title,
		FontFace = F_SEMI,
		Visible = title ~= "",
	}, root)
	el._content = label({
		LayoutOrder = 2,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = body,
		TextWrapped = true,
		TextSize = D.fLabel,
		TextColor3 = tok.tx2,
		LineHeight = 1.15,
	}, root)
	return el
end

function Paragraph:SetTitle(text)
	self._title.Text = tostring(text or "")
	self._title.Visible = self._title.Text ~= ""
	self._search = self._title.Text .. " " .. self._content.Text
	return self
end

function Paragraph:SetContent(text)
	self._content.Text = tostring(text or "")
	self._search = self._title.Text .. " " .. self._content.Text
	return self
end

local Divider = class()

function Container:AddDivider(text)
	if type(text) == "table" then
		text = text.Text
	end
	text = tostring(text or "")
	local root
	if text ~= "" then
		root = frame({ Size = UDim2.new(1, 0, 0, 14) }, self._body)
		list(root, true, 8, nil, Enum.VerticalAlignment.Center)
		local left = frame({ LayoutOrder = 1, Size = UDim2.new(0, 0, 0, 1), BackgroundColor3 = tok[D.lineToken] }, root)
		fill(left)
		label({
			LayoutOrder = 2,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.fromOffset(0, 14),
			Text = string.upper(text),
			TextSize = D.fTiny,
			FontFace = F_MED,
			TextColor3 = tok.tx3,
			TextTruncate = Enum.TextTruncate.None,
		}, root)
		local right = frame({ LayoutOrder = 3, Size = UDim2.new(0, 0, 0, 1), BackgroundColor3 = tok[D.lineToken] }, root)
		fill(right)
	else
		root = frame({ Size = UDim2.new(1, 0, 0, 5) }, self._body)
		frame({
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.new(1, 0, 0, 1),
			BackgroundColor3 = tok[D.lineToken],
		}, root)
	end
	return self:_add(Divider, "Divider", nil, { Text = text }, root)
end

local Progress = class()

function Container:AddProgress(flag, options)
	flag, options = args(flag, options)
	local root = frame({ Size = UDim2.new(1, 0, 0, 30) }, self._body)
	options.NoSave = options.NoSave ~= false
	local el = self:_add(Progress, "Progress", flag, options, root)
	el._label = label({ Size = UDim2.new(1, -50, 0, 16), Text = el.Text }, root)
	el._valueLabel = label({
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.fromOffset(50, 16),
		TextXAlignment = Enum.TextXAlignment.Right,
		TextSize = D.fSmall,
		FontFace = F_MONO,
		TextColor3 = tok.tx2,
	}, root)
	local trackFrame = frame({ Position = UDim2.fromOffset(0, 24), Size = UDim2.new(1, 0, 0, 6), BackgroundColor3 = tok.el2 }, root)
	corner(trackFrame, D.rTrack)
	el._fill = frame({ Size = UDim2.fromScale(0, 1), BackgroundColor3 = tok.accent }, trackFrame)
	corner(el._fill, D.rTrack)
	el.Value = math.clamp(tonumber(options.Default) or 0, 0, 1)
	el:_render(false)
	return el
end

function Progress:_render(animated)
	local size = UDim2.fromScale(self.Value, 1)
	if animated then
		tween(self._fill, smooth(), { Size = size })
	else
		self._fill.Size = size
	end
	self._valueLabel.Text = math.floor(self.Value * 100 + 0.5) .. "%"
end

function Progress:SetValue(v)
	self.Value = math.clamp(tonumber(v) or 0, 0, 1)
	self:_render(true)
	self:_emit(self.Value)
	return self
end

local ImageElement = class()

function Container:AddImage(options)
	if type(options) == "string" then
		options = { Image = options }
	end
	options = options or {}
	local root = frame({ Size = UDim2.new(1, 0, 0, tonumber(options.Height) or 110), BackgroundColor3 = tok.el }, self._body)
	corner(root, D.rCtrl)
	stroke(root, D.lineToken)
	local el = self:_add(ImageElement, "Image", nil, options, root)
	local image = tostring(options.Image or "")
	el._image = new("ImageLabel", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ScaleType = options.ScaleType or Enum.ScaleType.Fit,
		Image = string.find(image, "^%d+$") and ("rbxassetid://" .. image) or image,
	}, root)
	corner(el._image, D.rCtrl)
	return el
end

function ImageElement:SetImage(image)
	image = tostring(image or "")
	self._image.Image = string.find(image, "^%d+$") and ("rbxassetid://" .. image) or image
	return self
end

local Dropdown = class()
local DROPDOWN_ROWS = 8

local function optionRow(parent, order, height)
	local row = button({
		LayoutOrder = order,
		Size = UDim2.new(1, 0, 0, height),
		BackgroundColor3 = tok.el,
		BackgroundTransparency = 1,
	}, parent)
	corner(row, D.rTiny)
	return row
end

function Container:AddDropdown(flag, options)
	flag, options = args(flag, options)
	local hasText = tostring(options.Text or "") ~= ""
	local boxH = D.inputBox
	local root = frame({ Size = UDim2.new(1, 0, 0, (hasText and D.inputLabel or 0) + boxH) }, self._body)
	local el = self:_add(Dropdown, "Dropdown", flag, options, root)
	el.Multi = options.Multi == true
	el.Values = {}
	for _, v in ipairs(options.Values or {}) do
		el.Values[#el.Values + 1] = tostring(v)
	end
	el._allowNull = options.AllowNull == true
	el._fontPreview = options.FontPreview == true
	el._baseSearch = el._search
	el._search = el._baseSearch .. " " .. table.concat(el.Values, " ")
	el._placeholder = tostring(options.Placeholder or (el.Multi and "None" or "Select..."))
	if hasText then
		el._label = label({ Size = UDim2.new(1, 0, 0, 16), Text = el.Text, TextSize = D.fLabel, TextColor3 = tok.tx2 }, root)
	end
	local box = button({
		Position = UDim2.fromOffset(0, hasText and 22 or 0),
		Size = UDim2.new(1, 0, 0, boxH),
		BackgroundColor3 = tok.el,
		BackgroundTransparency = 0,
	}, root)
	corner(box, D.rCtrl)
	el._stroke = stroke(box, D.lineToken)
	el._box = box
	el._display = label({ Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -36, 1, 0), Text = "" }, box)
	el._chips = frame({
		Position = UDim2.fromOffset(8, 0),
		Size = UDim2.new(1, -34, 1, 0),
		ClipsDescendants = true,
		Visible = false,
	}, box)
	list(el._chips, true, 4, nil, Enum.VerticalAlignment.Center)
	local chev = icon("chevron", box, 14, "tx3")
	chev.AnchorPoint = Vector2.new(1, 0.5)
	chev.Position = UDim2.new(1, -10, 0.5, 0)
	el._chev = chev

	if el.Multi then
		el.Value = {}
		if type(options.Default) == "table" then
			for k, v in pairs(options.Default) do
				if type(k) == "number" then
					el.Value[tostring(v)] = true
				elseif v then
					el.Value[tostring(k)] = true
				end
			end
		end
	else
		local d = options.Default
		if type(d) == "number" and el.Values[d] then
			d = el.Values[d]
		end
		if d ~= nil and table.find(el.Values, tostring(d)) then
			el.Value = tostring(d)
		elseif not el._allowNull then
			el.Value = el.Values[1]
		end
	end
	if flag then
		Library.Flags[flag] = el.Value
	end
	el:_renderDisplay()

	hover(box, function(on)
		if not el._open then
			bindTween(el._stroke, "Color", on and "line2" or "line")
		end
	end)
	connect(box.Activated, function()
		if el._open then
			el._win:_closePopup()
		else
			el:_openList()
		end
	end)
	return el
end

function Dropdown:_selectedList()
	local out = {}
	if self.Multi then
		for _, v in ipairs(self.Values) do
			if self.Value[v] then
				out[#out + 1] = v
			end
		end
	elseif self.Value ~= nil then
		out[1] = self.Value
	end
	return out
end

function Dropdown:_isSelected(v)
	if self.Multi then
		return self.Value[v] == true
	end
	return self.Value == v
end

function Dropdown:_renderDisplay()
	if self.Multi then
		for _, child in ipairs(self._chips:GetChildren()) do
			if not child:IsA("UIListLayout") then
				child:Destroy()
			end
		end
		local selected = self:_selectedList()
		local empty = #selected == 0
		self._chips.Visible = not empty
		self._display.Visible = empty
		if empty then
			self._display.Text = self._placeholder
			bind(self._display, "TextColor3", "tx3")
		else
			for i = 1, math.min(#selected, 2) do
				local chip = label({
					LayoutOrder = i,
					AutomaticSize = Enum.AutomaticSize.X,
					Size = UDim2.fromOffset(0, 20),
					BackgroundTransparency = 0,
					BackgroundColor3 = tok.accent,
					Text = selected[i],
					TextSize = D.fSmall,
					TextTruncate = Enum.TextTruncate.None,
				}, self._chips)
				chip.BackgroundTransparency = 0.84
				corner(chip, D.rTiny)
				pad(chip, 0, 6, 0, 6)
			end
			if #selected > 2 then
				label({
					LayoutOrder = 3,
					AutomaticSize = Enum.AutomaticSize.X,
					Size = UDim2.fromOffset(0, 20),
					Text = "+" .. (#selected - 2),
					TextSize = D.fSmall,
					TextColor3 = tok.tx3,
					TextTruncate = Enum.TextTruncate.None,
				}, self._chips)
			end
		end
	else
		local has = self.Value ~= nil
		self._display.Text = has and self.Value or self._placeholder
		bind(self._display, "TextColor3", has and "tx" or "tx3")
	end
	if self._relist then
		self._relist()
	end
end

function Dropdown:_openList()
	local win = self._win
	local optH = D.option
	local step = optH + 2
	local total = #self.Values
	local searchable = total > DROPDOWN_ROWS
	local shown = math.max(math.min(total, DROPDOWN_ROWS), 1)
	local listH = shown * step - 2
	local height = 8 + (searchable and (optH + 4) or 0) + listH
	local width = self._box.AbsoluteSize.X / win._fit.Scale
	self._open = true
	tween(self._chev, quick(), { Rotation = 180 })
	bindTween(self._stroke, "Color", "accent")
	tween(self._stroke, quick(), { Transparency = 0.45 })

	win:_popup(self._box, width, height, function(panel)
		pad(panel, 4, 4, 4, 4)
		local filtered = table.clone(self.Values)
		local pool = {}
		local scroll
		local emptyLabel

		local function paintRow(entry)
			if entry.value == nil then
				return
			end
			local selected = self:_isSelected(entry.value)
			if selected then
				paint(entry.row, "BackgroundColor3", "accent", false)
				entry.row.BackgroundTransparency = 0.84
			else
				paint(entry.row, "BackgroundColor3", "el", false)
				entry.row.BackgroundTransparency = entry.hover and 0 or 1
			end
			paint(entry.text, "TextColor3", selected and "tx" or "tx2", false)
			entry.check.Visible = selected
		end

		local function bindRow(entry, index)
			local value = filtered[index]
			entry.value = value
			if value == nil then
				entry.row.Visible = false
				return
			end
			entry.row.Visible = true
			entry.row.Position = UDim2.fromOffset(0, (index - 1) * step)
			entry.text.Text = value
			if self._fontPreview then
				local preview = FONTS[value]
				if preview then
					S.fonted[entry.text] = nil
					entry.text.FontFace = Font.fromEnum(preview)
				else
					S.fonted[entry.text] = F_REG
					entry.text.FontFace = fontFor(F_REG)
				end
			end
			paintRow(entry)
		end

		local function layout()
			local count = #filtered
			scroll.CanvasSize = UDim2.fromOffset(0, math.max(count * step - 2, 0))
			local first = math.max(math.floor(scroll.CanvasPosition.Y / step), 0) + 1
			for i, entry in ipairs(pool) do
				bindRow(entry, first + i - 1)
			end
			if emptyLabel then
				emptyLabel.Visible = count == 0
			end
		end
		self._relist = layout

		local y = 0
		if searchable then
			local search = frame({ Size = UDim2.new(1, 0, 0, optH), BackgroundColor3 = tok.el }, panel)
			corner(search, D.rTiny)
			local ic = icon("search", search, 13, "tx3")
			ic.AnchorPoint = Vector2.new(0, 0.5)
			ic.Position = UDim2.new(0, 8, 0.5, 0)
			local tb = new("TextBox", {
				Position = UDim2.fromOffset(28, 0),
				Size = UDim2.new(1, -34, 1, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Text = "",
				PlaceholderText = "Search",
				PlaceholderColor3 = tok.tx3,
				TextColor3 = tok.tx,
				TextSize = D.fLabel,
				FontFace = F_REG,
				TextXAlignment = Enum.TextXAlignment.Left,
				ClearTextOnFocus = false,
			}, search)
			connect(tb:GetPropertyChangedSignal("Text"), function()
				local query = string.lower(trim(tb.Text))
				filtered = {}
				for _, value in ipairs(self.Values) do
					if query == "" or string.find(string.lower(value), query, 1, true) ~= nil then
						filtered[#filtered + 1] = value
					end
				end
				scroll.CanvasPosition = Vector2.new(0, 0)
				layout()
			end)
			y = optH + 4
		end

		scroll = new("ScrollingFrame", {
			Position = UDim2.fromOffset(0, y),
			Size = UDim2.new(1, 0, 1, -y),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = tok.line2,
			CanvasSize = UDim2.new(),
			ScrollingDirection = Enum.ScrollingDirection.Y,
			ClipsDescendants = true,
		}, panel)

		emptyLabel = label({
			Position = UDim2.fromOffset(0, y),
			Size = UDim2.new(1, 0, 0, optH),
			Text = "No options",
			TextColor3 = tok.tx3,
			TextXAlignment = Enum.TextXAlignment.Center,
			Visible = false,
		}, panel)

		for i = 1, math.min(shown + 2, DROPDOWN_ROWS + 2) do
			local row = optionRow(scroll, i, optH)
			row.Visible = false
			local text = label({
				Position = UDim2.fromOffset(8, 0),
				Size = UDim2.new(1, -34, 1, 0),
				Text = "",
				TextColor3 = tok.tx2,
			}, row)
			local check = icon("check", row, 14, "accent")
			check.AnchorPoint = Vector2.new(1, 0.5)
			check.Position = UDim2.new(1, -8, 0.5, 0)
			local entry = { row = row, text = text, check = check }
			pool[i] = entry
			hover(row, function(on)
				entry.hover = on
				paintRow(entry)
			end)
			connect(row.Activated, function()
				local value = entry.value
				if value == nil then
					return
				end
				self:_pick(value)
				if not self.Multi then
					win:_closePopup()
				end
			end)
		end

		connect(scroll:GetPropertyChangedSignal("CanvasPosition"), layout)

		if not self.Multi and self.Value then
			local index = table.find(filtered, self.Value)
			if index and index > shown then
				scroll.CanvasPosition = Vector2.new(0, math.min((index - 1) * step, math.max(#filtered * step - 2 - listH, 0)))
			end
		end
		layout()
	end, function()
		self._open = false
		self._relist = nil
		tween(self._chev, quick(), { Rotation = 0 })
		bindTween(self._stroke, "Color", D.lineToken)
		tween(self._stroke, quick(), { Transparency = 0 })
	end)
end

function Dropdown:_pick(v)
	if self.Multi then
		if self.Value[v] then
			self.Value[v] = nil
		else
			self.Value[v] = true
		end
	else
		if self.Value == v then
			if not self._allowNull then
				return
			end
			self.Value = nil
		else
			self.Value = v
		end
	end
	self:_renderDisplay()
	self:_emit(self.Value)
end

function Dropdown:SetValue(v)
	if self.Multi then
		local set = {}
		if type(v) == "table" then
			for k, item in pairs(v) do
				local key = type(k) == "number" and tostring(item) or (item and tostring(k) or nil)
				if key and table.find(self.Values, key) then
					set[key] = true
				end
			end
		end
		self.Value = set
	else
		if v ~= nil and table.find(self.Values, tostring(v)) then
			self.Value = tostring(v)
		elseif v == nil and self._allowNull then
			self.Value = nil
		else
			return self
		end
	end
	self:_renderDisplay()
	self:_emit(self.Value)
	return self
end

function Dropdown:SetValues(values)
	self.Values = {}
	for _, v in ipairs(values or {}) do
		self.Values[#self.Values + 1] = tostring(v)
	end
	self._search = (self._baseSearch or self.Text) .. " " .. table.concat(self.Values, " ")
	if self._open then
		self._win:_closePopup()
	end
	if self.Multi then
		for k in pairs(self.Value) do
			if not table.find(self.Values, k) then
				self.Value[k] = nil
			end
		end
	elseif self.Value ~= nil and not table.find(self.Values, self.Value) then
		self.Value = (not self._allowNull) and self.Values[1] or nil
	end
	self:_renderDisplay()
	return self
end

function Dropdown:Refresh(values)
	if values ~= nil then
		return self:SetValues(values)
	end
	self:_renderDisplay()
	return self
end

function Dropdown:AddValue(value)
	value = tostring(value)
	if table.find(self.Values, value) then
		return self
	end
	self.Values[#self.Values + 1] = value
	self._search = (self._baseSearch or self.Text) .. " " .. table.concat(self.Values, " ")
	if self._open then
		self._win:_closePopup()
	end
	self:_renderDisplay()
	return self
end

function Dropdown:RemoveValue(value)
	value = tostring(value)
	local index = table.find(self.Values, value)
	if not index then
		return self
	end
	table.remove(self.Values, index)
	self._search = (self._baseSearch or self.Text) .. " " .. table.concat(self.Values, " ")
	if self._open then
		self._win:_closePopup()
	end
	local changed = false
	if self.Multi then
		if self.Value[value] then
			self.Value[value] = nil
			changed = true
		end
	elseif self.Value == value then
		self.Value = (not self._allowNull) and self.Values[1] or nil
		changed = true
	end
	self:_renderDisplay()
	if changed then
		self:_emit(self.Value)
	end
	return self
end

function Dropdown:GetValues()
	return table.clone(self.Values)
end

function Dropdown:_serialize()
	if self.Multi then
		return self:_selectedList()
	end
	return self.Value
end

function Dropdown:_deserialize(v)
	self:SetValue(v)
end

local Keybind = class()
local MODES = { "Toggle", "Hold", "Always" }

local function unmapKeybind(kb)
	local key = kb._mapped
	if key == nil then
		return
	end
	kb._mapped = nil
	local list = S.keyMap[key]
	if not list then
		return
	end
	local i = table.find(list, kb)
	if i then
		table.remove(list, i)
	end
	if #list == 0 then
		S.keyMap[key] = nil
	end
end

local function mapKeybind(kb)
	unmapKeybind(kb)
	local key = kb.Value
	if key == nil then
		return
	end
	local list = S.keyMap[key]
	if not list then
		list = {}
		S.keyMap[key] = list
	end
	list[#list + 1] = kb
	kb._mapped = key
end

function Keybind:_init(parent, options, target)
	self.Value = keyFromName(options.Default)
	local mode = options.Mode
	self.Mode = (mode == "Press" or table.find(MODES, mode)) and mode or "Toggle"
	self._target = target
	self._modesLocked = options.Modes == false or self.Mode == "Press"
	self._changedKey = options.ChangedCallback
	self.Active = self.Mode == "Always"

	if not target and options.ShowMode ~= false and self.Mode ~= "Press" then
		self._modeLabel = label({
			LayoutOrder = 2,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.fromOffset(0, 18),
			Text = self.Mode,
			TextSize = D.fTiny,
			TextColor3 = tok.tx3,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextTruncate = Enum.TextTruncate.None,
		}, parent)
		corner(self._modeLabel, D.rTiny)
		stroke(self._modeLabel, D.lineToken)
		pad(self._modeLabel, 0, 6, 0, 6)
	end

	local chip = button({
		LayoutOrder = 5,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 20),
		BackgroundColor3 = tok.el,
		BackgroundTransparency = 0,
		TextSize = D.fSmall,
		FontFace = F_MONO,
		TextColor3 = tok.tx2,
		Text = keyLabel(self.Value),
	}, parent)
	corner(chip, D.rSmall)
	self._chipStroke = stroke(chip, "line2")
	pad(chip, 0, 7, 0, 7)
	self._chip = chip
	hover(chip, function(on)
		if S.listening ~= self then
			paint(chip, "TextColor3", on and "tx" or "tx2", true)
		end
	end)
	connect(chip.Activated, function()
		self:_listen()
	end)
	connect(chip.MouseButton2Click, function()
		if not self._modesLocked then
			self:_modeMenu()
		end
	end)
	S.keybinds[self] = true
	mapKeybind(self)
	if S.mobile then
		chip.Visible = false
	end
end

function Container:AddKeybind(flag, options)
	flag, options = args(flag, options)
	local row = frame({ Size = UDim2.new(1, 0, 0, 26) }, self._body)
	list(row, true, D.rowGap, nil, Enum.VerticalAlignment.Center)
	local el = self:_add(Keybind, "Keybind", flag, options, row)
	el._label = label({ LayoutOrder = 1, Size = UDim2.new(0, 0, 1, 0), Text = el.Text }, row)
	fill(el._label)
	el:_init(row, options, nil)
	if flag then
		Library.Flags[flag] = el.Value and el.Value.Name or "None"
	end
	if S.mobile then
		el._hiddenByDevice = true
		el:_applyVisible()
	end
	return el
end

function Toggle:AddKeybind(flag, options)
	flag, options = args(flag, options)
	if type(flag) ~= "string" then
		flag = nil
	end
	local kb = setmetatable({
		Type = "Keybind",
		Flag = flag,
		Text = self.Text,
		_container = self._container,
		_win = self._win,
		_changed = {},
		_callback = options.Callback,
		_visible = true,
		_match = true,
		_noSave = options.NoSave == true,
		_search = self.Text,
	}, Keybind)
	kb:_init(self._right, options, self)
	if flag then
		registerOption(flag, kb)
		Library.Flags[flag] = kb.Value and kb.Value.Name or "None"
	end
	self._keybind = kb
	return kb
end

function Keybind:_renderChip()
	if S.listening == self then
		self._chip.Text = "..."
	else
		self._chip.Text = keyLabel(self.Value)
	end
end

function Keybind:_listen()
	if S.listening == self then
		self:_stopListen()
		return
	end
	if S.listening then
		S.listening:_stopListen()
	end
	S.listening = self
	self:_renderChip()
	bindTween(self._chipStroke, "Color", "accent")
	paint(self._chip, "TextColor3", "tx", true)
end

function Keybind:_stopListen()
	if S.listening == self then
		S.listening = nil
	end
	self:_renderChip()
	bindTween(self._chipStroke, "Color", "line2")
	paint(self._chip, "TextColor3", "tx2", true)
end

function Keybind:_capture(input)
	local t = input.UserInputType
	if t == Enum.UserInputType.Keyboard then
		local k = input.KeyCode
		if k == Enum.KeyCode.Escape then
			self:_stopListen()
		elseif k == Enum.KeyCode.Backspace or k == Enum.KeyCode.Delete then
			self:SetValue(nil)
			self:_stopListen()
		else
			self:SetValue(k)
			self:_stopListen()
		end
	elseif t == Enum.UserInputType.MouseButton2 or t == Enum.UserInputType.MouseButton3 then
		self:SetValue(t)
		self:_stopListen()
	elseif t == MB1 or t == TOUCH then
		if not overAny(self._chip, pointers(input)) then
			self:_stopListen()
		end
	end
end

function Keybind:SetValue(key, mode)
	if typeof(key) == "table" then
		mode = key.Mode or key[2]
		key = key.Key or key[1]
	end
	self.Value = keyFromName(key)
	mapKeybind(self)
	if mode then
		self:SetMode(mode)
	end
	self:_renderChip()
	if self.Flag then
		Library.Flags[self.Flag] = self.Value and self.Value.Name or "None"
	end
	if self._changedKey then
		task.spawn(self._changedKey, self.Value)
	end
	for _, f in ipairs(self._changed) do
		task.spawn(f, self.Value)
	end
	Library:_refreshKeybinds()
	return self
end

function Keybind:SetMode(mode)
	if mode ~= "Press" and not table.find(MODES, mode) then
		return self
	end
	self.Mode = mode
	self.Active = mode == "Always"
	if self._modeLabel then
		self._modeLabel.Text = mode
	end
	if self._target and mode == "Always" then
		self._target:SetValue(true)
	end
	Library:_refreshKeybinds()
	return self
end

function Keybind:_fireState()
	if self._callback then
		task.spawn(self._callback, self.Active)
	end
end

function Keybind:_press()
	local mode = self.Mode
	if mode == "Always" then
		return
	elseif mode == "Press" then
		if self._callback then
			task.spawn(self._callback, true)
		end
		return
	elseif mode == "Toggle" then
		if self._target then
			self._target:SetValue(not self._target.Value)
		else
			self.Active = not self.Active
			self:_fireState()
		end
	elseif mode == "Hold" then
		if self._target then
			self._target:SetValue(true)
		else
			self.Active = true
			self:_fireState()
		end
	end
	Library:_refreshKeybinds()
end

function Keybind:_release()
	if self.Mode ~= "Hold" then
		return
	end
	if self._target then
		self._target:SetValue(false)
	else
		self.Active = false
		self:_fireState()
	end
	Library:_refreshKeybinds()
end

function Keybind:GetState()
	if self._target then
		return self._target.Value
	end
	if self.Mode == "Always" then
		return true
	end
	return self.Active == true
end

function Keybind:_modeMenu()
	local win = self._win
	local optH = 28
	win:_popup(self._chip, 120, 3 * (optH + 2) - 2 + 8, function(panel)
		pad(panel, 4, 4, 4, 4)
		list(panel, false, 2)
		for i, mode in ipairs(MODES) do
			local row = optionRow(panel, i, optH)
			local selected = self.Mode == mode
			if selected then
				paint(row, "BackgroundColor3", "accent", false)
				row.BackgroundTransparency = 0.84
			end
			label({
				Position = UDim2.fromOffset(8, 0),
				Size = UDim2.new(1, -16, 1, 0),
				Text = mode,
				TextSize = D.fLabel,
				TextColor3 = selected and tok.tx or tok.tx2,
			}, row)
			hover(row, function(on)
				if not selected then
					row.BackgroundTransparency = on and 0 or 1
				end
			end)
			connect(row.Activated, function()
				self:SetMode(mode)
				win:_closePopup()
			end)
		end
	end)
end

function Keybind:Destroy()
	if self._destroyed then
		return nil
	end
	unmapKeybind(self)
	S.keybinds[self] = nil
	if S.listening == self then
		S.listening = nil
	end
	if self._chip then
		self._chip:Destroy()
		self._chip = nil
	end
	if self._modeLabel then
		self._modeLabel:Destroy()
		self._modeLabel = nil
	end
	Element.Destroy(self)
	Library:_refreshKeybinds()
	return nil
end

function Keybind:_serialize()
	return { Key = self.Value and self.Value.Name or "None", Mode = self.Mode }
end

function Keybind:_deserialize(v)
	if typeof(v) == "table" then
		self:SetValue(v.Key, (not self._modesLocked) and v.Mode or nil)
	else
		self:SetValue(v)
	end
end

local function hueSequence()
	local points = {}
	for i = 0, 6 do
		points[#points + 1] = ColorSequenceKeypoint.new(i / 6, Color3.fromHSV((i / 6) % 1, 1, 1))
	end
	return ColorSequence.new(points)
end

local function openPicker(win, anchor, state, onChange, onClose, ignore)
	local W = 232
	local svH = 130
	local inputH = D.option
	local alpha = state.alpha
	local height = 8 + svH + 10 + 10 + (alpha and 20 or 0) + 10 + inputH + 8

	return win:_popup(anchor, W, height, function(panel)
		pad(panel, 8, 8, 8, 8)
		local sv = button({
			Size = UDim2.new(1, 0, 0, svH),
			BackgroundColor3 = Color3.fromHSV(state.h, 1, 1),
			BackgroundTransparency = 0,
		}, panel)
		corner(sv, D.rTiny)
		local white = frame({ Size = UDim2.fromScale(1, 1), BackgroundColor3 = WHITE }, sv)
		corner(white, D.rTiny)
		new("UIGradient", { Transparency = NumberSequence.new(0, 1) }, white)
		local black = frame({ Size = UDim2.fromScale(1, 1), BackgroundColor3 = BLACK }, sv)
		corner(black, D.rTiny)
		new("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(1, 0) }, black)
		local cursor = frame({
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromOffset(12, 12),
			ZIndex = 3,
		}, sv)
		corner(cursor)
		new("UIStroke", { Color = WHITE, Thickness = 2 }, cursor)

		local hue = button({
			Position = UDim2.fromOffset(0, svH + 10),
			Size = UDim2.new(1, 0, 0, 10),
			BackgroundColor3 = WHITE,
			BackgroundTransparency = 0,
		}, panel)
		corner(hue, D.rSmall)
		new("UIGradient", { Color = hueSequence() }, hue)
		local hueHandle = frame({
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(state.h, 0.5),
			Size = UDim2.fromOffset(6, 14),
			BackgroundColor3 = WHITE,
			ZIndex = 2,
		}, hue)
		corner(hueHandle, D.rTrack)
		new("UIStroke", { Color = BLACK, Transparency = 0.6, Thickness = 1 }, hueHandle)

		local alphaBar, alphaFill, alphaHandle
		if alpha then
			alphaBar = button({
				Position = UDim2.fromOffset(0, svH + 30),
				Size = UDim2.new(1, 0, 0, 10),
				BackgroundColor3 = tok.el2,
				BackgroundTransparency = 0,
			}, panel)
			corner(alphaBar, D.rSmall)
			alphaFill = frame({ Size = UDim2.fromScale(1, 1), BackgroundColor3 = WHITE }, alphaBar)
			corner(alphaFill, D.rSmall)
			new("UIGradient", { Transparency = NumberSequence.new(1, 0) }, alphaFill)
			alphaHandle = frame({
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.fromOffset(6, 14),
				BackgroundColor3 = WHITE,
				ZIndex = 2,
			}, alphaBar)
			corner(alphaHandle, D.rTrack)
			new("UIStroke", { Color = BLACK, Transparency = 0.6, Thickness = 1 }, alphaHandle)
		end

		local inputs = frame({
			Position = UDim2.fromOffset(0, svH + 30 + (alpha and 20 or 0)),
			Size = UDim2.new(1, 0, 0, inputH),
		}, panel)
		list(inputs, true, 6)
		local function field(order, caption, width)
			local f = frame({
				LayoutOrder = order,
				Size = UDim2.new(0, width or 0, 1, 0),
				BackgroundColor3 = tok.el,
			}, inputs)
			corner(f, D.rSmall)
			stroke(f, D.lineToken)
			label({
				Position = UDim2.fromOffset(8, 0),
				Size = UDim2.new(0, 28, 1, 0),
				Text = caption,
				TextSize = D.fSmall,
				TextColor3 = tok.tx3,
			}, f)
			local tb = new("TextBox", {
				Position = UDim2.fromOffset(caption == "HEX" and 36 or 20, 0),
				Size = UDim2.new(1, caption == "HEX" and -42 or -26, 1, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Text = "",
				TextColor3 = tok.tx,
				TextSize = D.fLabel,
				FontFace = F_MONO,
				TextXAlignment = Enum.TextXAlignment.Left,
				ClearTextOnFocus = false,
			}, f)
			return f, tb
		end
		local hexField, hexBox = field(1, "HEX")
		fill(hexField)
		local alphaBox
		if alpha then
			local _, box = field(2, "A", 84)
			alphaBox = box
		end

		local function render()
			sv.BackgroundColor3 = Color3.fromHSV(state.h, 1, 1)
			cursor.Position = UDim2.fromScale(state.s, 1 - state.v)
			hueHandle.Position = UDim2.fromScale(state.h, 0.5)
			local c = Color3.fromHSV(state.h, state.s, state.v)
			if alpha then
				alphaFill.BackgroundColor3 = c
				alphaHandle.Position = UDim2.fromScale(1 - (state.transparency or 0), 0.5)
				if not alphaBox:IsFocused() then
					alphaBox.Text = math.floor((1 - (state.transparency or 0)) * 100 + 0.5) .. "%"
				end
			end
			if not hexBox:IsFocused() then
				hexBox.Text = "#" .. string.upper(c:ToHex())
			end
		end
		state.render = render
		render()

		local function commit()
			render()
			onChange(state)
		end
		local function relative(gui, pos)
			local a, s = gui.AbsolutePosition, gui.AbsoluteSize
			return math.clamp((pos.X - a.X) / math.max(s.X, 1), 0, 1), math.clamp((pos.Y - a.Y) / math.max(s.Y, 1), 0, 1)
		end
		local function svMove(pos)
			local x, y = relative(sv, pos)
			state.s, state.v = x, 1 - y
			commit()
		end
		track(sv, { start = svMove, move = svMove })
		local function hueMove(pos)
			local x = relative(hue, pos)
			state.h = math.min(x, 0.9999)
			commit()
		end
		track(hue, { start = hueMove, move = hueMove })
		if alpha then
			local function alphaMove(pos)
				local x = relative(alphaBar, pos)
				state.transparency = 1 - x
				commit()
			end
			track(alphaBar, { start = alphaMove, move = alphaMove })
			connect(alphaBox.FocusLost, function()
				local n = tonumber((string.gsub(alphaBox.Text, "[^%d%.]", "")))
				if n then
					state.transparency = 1 - math.clamp(n, 0, 100) / 100
					commit()
				else
					render()
				end
			end)
		end
		connect(hexBox.FocusLost, function()
			local text = string.gsub(trim(hexBox.Text), "#", "")
			local ok, c = pcall(Color3.fromHex, text)
			if ok and c and #text == 6 then
				state.h, state.s, state.v = c:ToHSV()
				commit()
			else
				render()
			end
		end)
	end, function()
		state.render = nil
		if onClose then
			onClose()
		end
	end, ignore)
end

local ColorPicker = class()

local function parseColor(c)
	if typeof(c) == "Color3" then
		return c
	elseif type(c) == "string" then
		local ok, out = pcall(Color3.fromHex, (string.gsub(c, "#", "")))
		if ok then
			return out
		end
	elseif type(c) == "table" and #c >= 3 then
		return Color3.fromHSV(c[1], c[2], c[3])
	end
	return nil
end

function ColorPicker:_init(parent, options)
	self.Value = parseColor(options.Default) or WHITE
	self._alpha = options.Transparency ~= nil
	self.Transparency = self._alpha and math.clamp(tonumber(options.Transparency) or 0, 0, 1) or nil
	local h, s, v = self.Value:ToHSV()
	self._state = { h = h, s = s, v = v, transparency = self.Transparency, alpha = self._alpha }
	self._hex = label({
		LayoutOrder = 2,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 16),
		TextSize = D.fSmall,
		FontFace = F_MONO,
		TextColor3 = tok.tx3,
		TextTruncate = Enum.TextTruncate.None,
	}, parent)
	local sw = button({
		LayoutOrder = 4,
		Size = UDim2.fromOffset(26, 16),
		BackgroundColor3 = self.Value,
		BackgroundTransparency = 0,
	}, parent)
	corner(sw, D.rTiny)
	stroke(sw, "line2")
	self._swatch = sw
	connect(sw.Activated, function()
		self:_toggle()
	end)
	self:_renderSwatch()
end

function ColorPicker:_renderSwatch()
	self._swatch.BackgroundColor3 = self.Value
	self._swatch.BackgroundTransparency = self.Transparency or 0
	self._hex.Text = "#" .. string.upper(self.Value:ToHex())
end

function ColorPicker:_toggle()
	if self._open then
		self._win:_closePopup()
		return
	end
	self._open = true
	openPicker(self._win, self._swatch, self._state, function(state)
		self.Value = Color3.fromHSV(state.h, state.s, state.v)
		self.Transparency = self._alpha and state.transparency or nil
		self:_commit()
	end, function()
		self._open = false
	end, { self._swatch, self._root or self._swatch })
end

function ColorPicker:_commit()
	self:_renderSwatch()
	if self.Flag then
		Library.Flags[self.Flag] = self.Value
	end
	if self._callback then
		task.spawn(self._callback, self.Value, self.Transparency)
	end
	for _, f in ipairs(self._changed) do
		task.spawn(f, self.Value, self.Transparency)
	end
end

function ColorPicker:SetValueRGB(c, transparency)
	c = parseColor(c)
	if not c then
		return self
	end
	self.Value = c
	local st = self._state
	st.h, st.s, st.v = c:ToHSV()
	if self._alpha and transparency ~= nil then
		self.Transparency = math.clamp(tonumber(transparency) or 0, 0, 1)
		st.transparency = self.Transparency
	end
	if st.render then
		st.render()
	end
	self:_commit()
	return self
end

function ColorPicker:SetValue(c, transparency)
	return self:SetValueRGB(c, transparency)
end

function ColorPicker:Destroy()
	if self._destroyed then
		return nil
	end
	if self._open then
		self._win:_closePopup()
	end
	if self._hex then
		self._hex:Destroy()
		self._hex = nil
	end
	if self._swatch then
		self._swatch:Destroy()
		self._swatch = nil
	end
	return Element.Destroy(self)
end

function ColorPicker:_serialize()
	return { Hex = self.Value:ToHex(), Transparency = self.Transparency }
end

function ColorPicker:_deserialize(v)
	if type(v) == "table" then
		self:SetValueRGB(v.Hex, v.Transparency)
	else
		self:SetValueRGB(v)
	end
end

function Container:AddColorPicker(flag, options)
	flag, options = args(flag, options)
	local row = button({ Size = UDim2.new(1, 0, 0, D.checkRow) }, self._body)
	list(row, true, D.rowGap, nil, Enum.VerticalAlignment.Center)
	local el = self:_add(ColorPicker, "ColorPicker", flag, options, row)
	el._label = label({ LayoutOrder = 1, Size = UDim2.new(0, 0, 1, 0), Text = el.Text }, row)
	fill(el._label)
	el:_init(row, options)
	if flag then
		Library.Flags[flag] = el.Value
	end
	connect(row.Activated, function()
		el:_toggle()
	end)
	return el
end

function Toggle:AddColorPicker(flag, options)
	flag, options = args(flag, options)
	if type(flag) ~= "string" then
		flag = nil
	end
	local cp = setmetatable({
		Type = "ColorPicker",
		Flag = flag,
		Text = self.Text,
		_container = self._container,
		_win = self._win,
		_changed = {},
		_callback = options.Callback,
		_visible = true,
		_match = true,
		_noSave = options.NoSave == true,
		_search = self.Text,
	}, ColorPicker)
	cp:_init(self._right, options)
	cp._hex.Visible = false
	if flag then
		registerOption(flag, cp)
		Library.Flags[flag] = cp.Value
	end
	self._picker = cp
	return cp
end

local Accent = class()

function Container:_addAccent(flag)
	local root = frame({ Size = UDim2.new(1, 0, 0, 46) }, self._body)
	local el = self:_add(Accent, "Accent", flag, { Text = "Accent" }, root)
	label({ Size = UDim2.new(1, -80, 0, 16), Text = "Accent", TextSize = D.fLabel, TextColor3 = tok.tx2 }, root)
	el._hex = label({
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.fromOffset(80, 16),
		TextXAlignment = Enum.TextXAlignment.Right,
		TextSize = D.fSmall,
		FontFace = F_MONO,
		TextColor3 = tok.tx3,
	}, root)
	local row = frame({ Position = UDim2.fromOffset(1, 22), Size = UDim2.new(1, -1, 0, 24) }, root)
	list(row, true, D.rowGap, nil, Enum.VerticalAlignment.Center)
	el._swatches = {}
	for i, c in ipairs(SWATCHES) do
		local ring = button({ LayoutOrder = i, Size = UDim2.fromOffset(24, 24) }, row)
		corner(ring)
		local ringStroke = stroke(ring, "tx2", 2, 1)
		local dot = frame({
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(18, 18),
			BackgroundColor3 = c,
		}, ring)
		corner(dot)
		connect(ring.Activated, function()
			el:SetValue(c)
		end)
		el._swatches[i] = { color = c, stroke = ringStroke }
	end
	local custom = button({ LayoutOrder = 99, Size = UDim2.fromOffset(24, 24) }, row)
	corner(custom)
	stroke(custom, "line2")
	local plus = icon("plus", custom, 12, "tx3")
	plus.AnchorPoint = Vector2.new(0.5, 0.5)
	plus.Position = UDim2.fromScale(0.5, 0.5)
	connect(custom.Activated, function()
		local h, s, v = S.accent:ToHSV()
		local state = { h = h, s = s, v = v, alpha = false }
		openPicker(el._win, custom, state, function(st)
			el:SetValue(Color3.fromHSV(st.h, st.s, st.v))
		end)
	end)
	el.Value = S.accent
	if flag then
		Library.Flags[flag] = el.Value
	end
	el:_render()
	return el
end

function Accent:_render()
	local hex = string.upper(self.Value:ToHex())
	self._hex.Text = "#" .. hex
	for _, sw in ipairs(self._swatches) do
		tween(sw.stroke, quick(), { Transparency = string.upper(sw.color:ToHex()) == hex and 0 or 1 })
	end
end

function Accent:SetValue(c)
	c = parseColor(c)
	if not c then
		return self
	end
	self.Value = c
	Library:SetAccent(c)
	self:_render()
	self:_emit(c)
	return self
end

function Accent:_serialize()
	return self.Value:ToHex()
end

function Accent:_deserialize(v)
	self:SetValue(v)
end

local function overlayTop()
	return GuiService:GetGuiInset().Y + 10
end

function Library:_placeOverlays()
	local y = overlayTop()
	if S.wm and not S.wmMoved then
		S.wm.Position = UDim2.fromOffset(16, y)
		if S.wm.Visible then
			y = y + 38
		end
	end
	if S.kbl and not S.kblMoved then
		S.kbl.Position = UDim2.fromOffset(16, y)
	end
	if S.al and not S.alMoved then
		local vp = viewport()
		local size = S.al.Size
		local corner = S.alCorner or "TopRight"
		local left = corner == "TopLeft" or corner == "BottomLeft"
		local top = corner == "TopLeft" or corner == "TopRight"
		S.al.Position = UDim2.fromOffset(
			left and 16 or math.max(vp.X - 16 - size.X.Offset, 0),
			top and overlayTop() or math.max(vp.Y - 16 - size.Y.Offset, 0)
		)
	end
end

local function draggable(target, movedKey)
	local start, origin
	track(target, {
		start = function(pos)
			start = pos
			origin = target.Position
		end,
		move = function(pos)
			local d = pos - start
			if not S[movedKey] and d.Magnitude < 3 then
				return
			end
			S[movedKey] = true
			local vp = viewport()
			local size = target.AbsoluteSize
			target.Position = UDim2.fromOffset(
				math.clamp(origin.X.Offset + d.X, 0, math.max(vp.X - size.X, 0)),
				math.clamp(origin.Y.Offset + d.Y, 0, math.max(vp.Y - size.Y, 0))
			)
		end,
	})
end

local function applyWatermark()
	if not S.wm or not S.wmTitle then
		return
	end
	local stats = S.wmStats
	local win = Library._window
	local title = (win and tostring(win._opts.Title or "")) or "EasyLibrary"
	local plain = not S.wmFormat
	for _, line in ipairs(S.wmSeps or {}) do
		line.Visible = plain
	end
	S.wmFps.Visible = plain
	S.wmPing.Visible = plain
	S.wmTime.Visible = plain
	if plain then
		S.wmTitle.Text = S.wmText or title
		S.wmFps.Text = stats.fps .. " FPS"
		S.wmPing.Text = stats.ping >= 0 and (stats.ping .. " ms") or "-- ms"
		S.wmTime.Text = stats.time
		return
	end
	S.wmTitle.Text = template(S.wmText, {
		title = title,
		fps = stats.fps,
		ping = stats.ping >= 0 and stats.ping or "--",
		time = stats.time,
		user = LocalPlayer.Name,
		display = LocalPlayer.DisplayName,
	})
end

function Library:SetArrayListVisible(on)
	S.alOn = on == true
	Library:_refreshArrayList()
	return self
end

function Library:IsArrayListVisible()
	return S.alOn == true
end

function Library:SetArrayListCorner(corner)
	local name = tostring(corner or "TopRight")
	local valid = {
		TopRight = true,
		TopLeft = true,
		BottomRight = true,
		BottomLeft = true,
	}
	S.alCorner = valid[name] and name or "TopRight"
	Library:_placeOverlays()
	return self
end

function Library:_refreshArrayList()
	if S.alPending or Library.Unloaded then
		return
	end
	S.alPending = true
	task.defer(function()
		S.alPending = false
		if not Library.Unloaded then
			Library:_renderArrayList()
		end
	end)
end

function Library:_renderArrayList()
	if not S.alOn then
		if S.al then
			S.al.Visible = false
		end
		return
	end
	if not S.al then
		S.al = frame({
			Name = "ArrayList",
			Size = UDim2.fromOffset(240, 0),
			ZIndex = 38,
			Active = true,
		}, rootGui())
		draggable(S.al, "alMoved")
		S.alRows = {}
	end

	local names = {}
	for _, el in ipairs(S.hud) do
		if el._hud and el.Value == true and not el._destroyed then
			local text = el._hudText
			if text == nil or text == "" then
				text = el.Text
			end
			if text ~= "" then
				names[#names + 1] = text
			end
		end
	end
	table.sort(names, function(a, b)
		if #a ~= #b then
			return #a > #b
		end
		return a < b
	end)

	for _, row in ipairs(S.alRows) do
		row:Destroy()
	end
	table.clear(S.alRows)

	local step = D.hudRow + 2
	local left = S.alCorner == "TopLeft" or S.alCorner == "BottomLeft"
	for i, text in ipairs(names) do
		local row = frame({
			AnchorPoint = Vector2.new(left and 0 or 1, 0),
			Position = UDim2.new(left and 0 or 1, 0, 0, (i - 1) * step),
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.fromOffset(0, D.hudRow),
			BackgroundColor3 = tok.bg,
		}, S.al)
		row.BackgroundTransparency = 0.25
		pad(row, 0, 7, 0, 7)
		local text3 = label({
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.fromOffset(0, D.hudRow),
			Text = text,
			TextSize = D.fSmall,
			FontFace = F_MONO,
			TextColor3 = tok.accent,
			TextTruncate = Enum.TextTruncate.None,
		}, row)
		frame({
			AnchorPoint = Vector2.new(left and 0 or 1, 0),
			Position = UDim2.new(left and 0 or 1, 0, 0, 0),
			Size = UDim2.new(0, 2, 1, 0),
			BackgroundColor3 = tok.accent,
		}, row)
		S.alRows[i] = row
		if S.animate then
			row.BackgroundTransparency = 1
			text3.TextTransparency = 1
			tween(row, info(0.24, Style.Quint, Direction.Out), { BackgroundTransparency = 0.25 })
			tween(text3, info(0.24, Style.Quint, Direction.Out), { TextTransparency = 0 })
		end
	end

	S.al.Size = UDim2.fromOffset(240, math.max(#names * step - 2, 0))
	S.al.Visible = #names > 0
	Library:_placeOverlays()
end

function Library:SetWatermarkVisible(on)
	on = on == true
	S.watermarkOn = on
	if Library.Unloaded then
		return self
	end
	if on and not S.wm then
		local gui = rootGui()
		local win = Library._window
		local opts = win and win._opts or {}
		local wm = frame({
			Name = "Watermark",
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.fromOffset(0, 30),
			BackgroundColor3 = tok.bg,
			ZIndex = 40,
			Active = true,
		}, gui)
		corner(wm, D.rCtrl)
		draggable(wm, "wmMoved")
		stroke(wm, "line2")
		pad(wm, 0, 12, 0, 8)
		list(wm, true, 10, nil, Enum.VerticalAlignment.Center)
		logoMark(wm, 16, 4, opts.Logo, opts.Title or "EasyLibrary")
		S.wmTitle = label({
			LayoutOrder = 1,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.fromOffset(0, 16),
			Text = tostring(opts.Title or "EasyLibrary"),
			TextSize = D.fLabel,
			FontFace = F_SEMI,
			TextTruncate = Enum.TextTruncate.None,
		}, wm)
		S.wmSeps = {}
		local function sep(order)
			local line = frame({ LayoutOrder = order, Size = UDim2.fromOffset(1, 12), BackgroundColor3 = tok.line2 }, wm)
			S.wmSeps[#S.wmSeps + 1] = line
			return line
		end
		local function stat(order)
			return label({
				LayoutOrder = order,
				AutomaticSize = Enum.AutomaticSize.X,
				Size = UDim2.fromOffset(0, 16),
				Text = "--",
				TextSize = D.fSmall,
				FontFace = F_MONO,
				TextColor3 = tok.tx2,
				TextTruncate = Enum.TextTruncate.None,
			}, wm)
		end
		sep(2)
		S.wmFps = stat(3)
		sep(4)
		S.wmPing = stat(5)
		sep(6)
		S.wmTime = stat(7)
		S.wm = wm
	end
	if S.wm then
		S.wm.Visible = on
	end
	if on then
		applyWatermark()
	end
	if on and not S.wmConn then
		local frames, elapsed = 0, 0.5
		S.wmConn = RunService.Heartbeat:Connect(function(dt)
			frames = frames + 1
			elapsed = elapsed + dt
			if elapsed < 0.5 then
				return
			end
			local stats = S.wmStats
			stats.fps = math.floor(frames / elapsed + 0.5)
			local ok, ping = pcall(function()
				return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
			end)
			if not ok then
				ok, ping = pcall(function()
					return LocalPlayer:GetNetworkPing() * 1000
				end)
			end
			stats.ping = ok and math.floor(ping + 0.5) or -1
			stats.time = os.date("%H:%M")
			frames, elapsed = 0, 0
			applyWatermark()
		end)
	elseif not on and S.wmConn then
		S.wmConn:Disconnect()
		S.wmConn = nil
	end
	Library:_placeOverlays()
	return self
end

function Library:SetWatermark(text)
	S.wmText = text ~= nil and tostring(text) or nil
	S.wmFormat = S.wmText ~= nil and string.find(S.wmText, "{", 1, true) ~= nil
	applyWatermark()
	return self
end

function Library:SetKeybindListVisible(on)
	S.keybindListOn = on == true
	Library:_refreshKeybinds()
	return self
end

function Library:_refreshKeybinds()
	if S.kblPending or Library.Unloaded then
		return
	end
	S.kblPending = true
	task.defer(function()
		S.kblPending = false
		if not Library.Unloaded then
			Library:_renderKeybinds()
		end
	end)
end

function Library:_renderKeybinds()
	if not S.keybindListOn or S.mobile then
		if S.kbl then
			S.kbl.Visible = false
		end
		return
	end
	if not S.kbl then
		local gui = rootGui()
		local panel = frame({
			Name = "Keybinds",
			Size = UDim2.fromOffset(220, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = tok.bg,
			ZIndex = 40,
			Active = true,
		}, gui)
		corner(panel, D.rBox)
		draggable(panel, "kblMoved")
		stroke(panel, "line2")
		list(panel, false, 0)
		local header = frame({ LayoutOrder = 1, Size = UDim2.new(1, 0, 0, 32) }, panel)
		frame({ Position = UDim2.new(0, 0, 1, -1), Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = tok[D.lineToken] }, header)
		local ic = icon("keyboard", header, 14, "accent")
		ic.AnchorPoint = Vector2.new(0, 0.5)
		ic.Position = UDim2.new(0, 10, 0.5, 0)
		label({
			Position = UDim2.fromOffset(32, 0),
			Size = UDim2.new(1, -42, 1, 0),
			Text = "Keybinds",
			TextSize = D.fLabel,
			FontFace = F_SEMI,
		}, header)
		local rows = frame({ LayoutOrder = 2, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y }, panel)
		pad(rows, 6, 10, 8, 10)
		list(rows, false, 2)
		S.kbl = panel
		S.kblRows = rows
	end
	for _, child in ipairs(S.kblRows:GetChildren()) do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end
	local binds = {}
	for kb in pairs(S.keybinds) do
		if kb.Value and kb.Mode ~= "Press" and kb._chip and kb._chip.Parent then
			binds[#binds + 1] = kb
		end
	end
	table.sort(binds, function(a, b)
		return a.Text < b.Text
	end)
	S.kbl.Visible = #binds > 0
	for i, kb in ipairs(binds) do
		local active = kb:GetState()
		local row = frame({ LayoutOrder = i, Size = UDim2.new(1, 0, 0, 26) }, S.kblRows)
		list(row, true, D.rowGap, nil, Enum.VerticalAlignment.Center)
		local dot = frame({ LayoutOrder = 1, Size = UDim2.fromOffset(6, 6), BackgroundColor3 = active and tok.accent or tok.line2 }, row)
		corner(dot)
		local name = label({
			LayoutOrder = 2,
			Size = UDim2.new(0, 0, 1, 0),
			Text = kb.Text ~= "" and kb.Text or keyLabel(kb.Value),
			TextSize = D.fLabel,
			TextColor3 = active and tok.tx or tok.tx2,
		}, row)
		fill(name)
		label({
			LayoutOrder = 3,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.fromOffset(0, 16),
			Text = string.lower(kb.Mode),
			TextSize = D.fTiny,
			TextColor3 = tok.tx3,
			TextTruncate = Enum.TextTruncate.None,
		}, row)
		keycap(row, keyLabel(kb.Value), 4)
	end
	Library:_placeOverlays()
end

local NOTIFY_TYPES = {
	Info = { "info", "info" },
	Success = { "ok", "check" },
	Warning = { "warn", "alert" },
	Error = { "danger", "close" },
}

function Library:Notify(options, duration)
	if type(options) == "string" then
		options = { Title = options, Duration = duration }
	end
	options = options or {}
	if Library.Unloaded then
		return { Dismiss = function() end }
	end
	local gui = rootGui()
	local holder = S.notifyHolder
	if not holder or not holder.Parent then
		holder = frame({
			Name = "Notifications",
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -16, 1, -16),
			Size = UDim2.new(0, 300, 1, -32),
			ZIndex = 50,
		}, gui)
		list(holder, false, 8, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Bottom)
		S.notifyHolder = holder
		S.notifs = {}
	end
	holder.Size = UDim2.new(0, math.min(300, viewport().X - 24), 1, -32)

	local kind = NOTIFY_TYPES[options.Type] and options.Type or "Info"
	local colorToken, iconName = NOTIFY_TYPES[kind][1], NOTIFY_TYPES[kind][2]
	S.notifyOrder = (S.notifyOrder or 0) + 1

	local card = new("CanvasGroup", {
		LayoutOrder = S.notifyOrder,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = tok.line2,
		BorderSizePixel = 0,
		GroupTransparency = S.animate and 1 or 0,
	}, holder)
	corner(card, D.rBox)
	pad(card, 1, 1, 1, 1)
	local surface = frame({
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = tok.box,
	}, card)
	corner(surface, D.rBox - 1)
	pad(surface, 12, 10, 14, 12)
	list(surface, true, 10)
	local ic = icon(iconName, surface, 16, colorToken)
	ic.LayoutOrder = 1
	local texts = frame({ LayoutOrder = 2, Size = UDim2.new(0, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y }, surface)
	fill(texts)
	list(texts, false, 3)
	label({
		LayoutOrder = 1,
		Size = UDim2.new(1, 0, 0, 16),
		Text = tostring(options.Title or ""),
		FontFace = F_SEMI,
	}, texts)
	local content = options.Content or options.Description
	if content ~= nil and content ~= "" then
		label({
			LayoutOrder = 2,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Text = tostring(content),
			TextWrapped = true,
			TextSize = D.fLabel,
			TextColor3 = tok.tx2,
		}, texts)
	end
	local close = button({ LayoutOrder = 3, Size = UDim2.fromOffset(20, 20) }, surface)
	local closeIcon = icon("close", close, 12, "tx3")
	closeIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	closeIcon.Position = UDim2.fromScale(0.5, 0.5)
	local bar = frame({
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		Size = UDim2.new(1, 0, 0, 2),
		BackgroundColor3 = tok[colorToken],
		ZIndex = 2,
	}, card)

	local n = { dismissed = false }
	function n.Dismiss()
		if n.dismissed then
			return
		end
		n.dismissed = true
		local i = table.find(S.notifs, n)
		if i then
			table.remove(S.notifs, i)
		end
		if S.animate then
			local out = info(0.2, Style.Quad, Direction.In)
			TweenService:Create(card, out, { GroupTransparency = 1 }):Play()
			TweenService:Create(surface, out, { Position = UDim2.fromOffset(24, 0) }):Play()
			task.delay(0.2 / S.speed, function()
				card:Destroy()
			end)
		else
			card:Destroy()
		end
	end
	n.dismiss = n.Dismiss
	connect(close.Activated, n.Dismiss)

	S.notifs[#S.notifs + 1] = n
	while #S.notifs > 5 do
		S.notifs[1].Dismiss()
	end

	if S.animate then
		surface.Position = UDim2.fromOffset(24, 0)
		tween(surface, info(0.35, Style.Quint, Direction.Out), { Position = UDim2.fromOffset(0, 0) })
		tween(card, info(0.25, Style.Quad, Direction.Out), { GroupTransparency = 0 })
	end
	local life = math.max(tonumber(options.Duration) or 4, 0.5)
	if S.animate then
		TweenService:Create(bar, TweenInfo.new(life, Style.Linear), { Size = UDim2.new(0, 0, 0, 2) }):Play()
	else
		bar.Visible = false
	end
	task.delay(life, n.Dismiss)
	return n
end

function Library:Dialog(options)
	options = options or {}
	if Library.Unloaded then
		return { Close = function() end }
	end
	local gui = rootGui()
	local kind = NOTIFY_TYPES[options.Type] and options.Type or (options.Type == "Danger" and "Danger" or "Info")
	local colorToken, iconName
	if kind == "Danger" then
		colorToken, iconName = "danger", "trash"
	else
		colorToken, iconName = NOTIFY_TYPES[kind][1], NOTIFY_TYPES[kind][2]
	end
	if options.Icon then
		iconName = options.Icon
	end

	if S.dialog then
		S.dialog.Close()
	end

	local dim = button({
		Name = "Dialog",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = BLACK,
		BackgroundTransparency = 1,
		ZIndex = 60,
	}, gui)
	local top = GuiService:GetGuiInset().Y
	local center = UDim2.new(0.5, 0, 0.5, math.floor(top / 2))
	local card = new("CanvasGroup", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = S.animate and (center + UDim2.fromOffset(0, 16)) or center,
		Size = UDim2.fromOffset(math.min(340, viewport().X - 24), 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = tok.line2,
		BorderSizePixel = 0,
		GroupTransparency = S.animate and 1 or 0,
		ZIndex = 61,
	}, gui)
	corner(card, D.rWin)
	pad(card, 1, 1, 1, 1)
	local body = frame({
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = tok.box,
		Active = true,
	}, card)
	corner(body, D.rWin - 1)
	pad(body, 18, 18, 18, 18)
	list(body, false, 12)

	local badge = frame({ LayoutOrder = 1, Size = UDim2.fromOffset(34, 34), BackgroundColor3 = tok[colorToken] }, body)
	badge.BackgroundTransparency = 0.84
	corner(badge, D.rBox)
	local ic = icon(iconName, badge, 17, colorToken)
	ic.AnchorPoint = Vector2.new(0.5, 0.5)
	ic.Position = UDim2.fromScale(0.5, 0.5)

	local texts = frame({ LayoutOrder = 2, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y }, body)
	list(texts, false, 6)
	label({
		LayoutOrder = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = tostring(options.Title or ""),
		TextWrapped = true,
		TextSize = D.fGroup + 1,
		FontFace = F_SEMI,
	}, texts)
	if options.Content and options.Content ~= "" then
		label({
			LayoutOrder = 2,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Text = tostring(options.Content),
			TextWrapped = true,
			TextSize = D.fLabel,
			TextColor3 = tok.tx2,
			LineHeight = 1.15,
		}, texts)
	end

	local row = frame({ LayoutOrder = 3, Size = UDim2.new(1, 0, 0, D.button) }, body)
	list(row, true, D.rowGap, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center)

	local d = { closed = false }
	function d.Close()
		if d.closed then
			return
		end
		d.closed = true
		if S.dialog == d then
			S.dialog = nil
		end
		if S.animate then
			local out = info(0.2, Style.Quad, Direction.In)
			body.Active = false
			TweenService:Create(dim, out, { BackgroundTransparency = 1 }):Play()
			TweenService:Create(card, out, { GroupTransparency = 1, Position = center + UDim2.fromOffset(0, 12) }):Play()
			task.delay(0.2 / S.speed, function()
				dim:Destroy()
				card:Destroy()
			end)
		else
			dim:Destroy()
			card:Destroy()
		end
	end
	S.dialog = d

	local buttons = options.Buttons or { { Text = "OK", Variant = "Primary" } }
	for i, b in ipairs(buttons) do
		local variant = b.Variant or "Secondary"
		local btn = button({
			LayoutOrder = i,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.fromOffset(0, D.button),
			BackgroundColor3 = tok.el,
			BackgroundTransparency = 0,
			Text = tostring(b.Text or ""),
			TextSize = D.fBody,
			FontFace = variant == "Secondary" and F_REG or F_SEMI,
			TextColor3 = tok.tx,
		}, row)
		corner(btn, D.rCtrl)
		local st = stroke(btn, "line2")
		pad(btn, 0, 14, 0, 14)
		local base, text = "el", "tx"
		if variant == "Primary" then
			base, text = "accent", "onAccent"
			st.Transparency = 1
		elseif variant == "Danger" then
			base, text = "danger", "white"
			st.Transparency = 1
		end
		bind(btn, "BackgroundColor3", base)
		bind(btn, "TextColor3", text)
		hover(btn, function(on)
			if variant == "Secondary" then
				bindTween(btn, "BackgroundColor3", on and "el2" or "el")
			else
				tween(btn, quick(), { BackgroundTransparency = on and 0.12 or 0 })
			end
		end)
		press(btn)
		connect(btn.Activated, function()
			d.Close()
			if b.Callback then
				task.spawn(b.Callback)
			end
		end)
	end

	if S.animate then
		tween(dim, info(0.3, Style.Quad, Direction.Out), { BackgroundTransparency = 0.45 })
		tween(card, info(0.45, Style.Quint, Direction.Out), { GroupTransparency = 0, Position = center })
	else
		dim.BackgroundTransparency = 0.45
	end
	return d
end

local function canSave()
	return api.writefile ~= nil and api.readfile ~= nil and api.isfile ~= nil
end

local function configDir()
	return tostring(Library.ConfigFolder or "EasyLibrary/Default") .. "/configs"
end

local function configPath(name)
	return configDir() .. "/" .. name .. ".json"
end

function Library:CanSaveConfigs()
	return canSave()
end

function Library:SaveConfig(name)
	name = sanitize(name)
	if name == "" then
		return false, "Enter a config name."
	end
	if not canSave() then
		return false, "Your executor cannot save files."
	end
	ensureFolder(configDir())
	local data = { version = 1, options = {}, order = {} }
	for _, flag in ipairs(Library._order) do
		local el = Library.Options[flag]
		if el and not el._noSave and el._serialize then
			local ok, value = pcall(el._serialize, el)
			if ok and value ~= nil then
				data.options[flag] = { t = el.Type, v = value }
				data.order[#data.order + 1] = flag
			end
		end
	end
	local ok, encoded = pcall(function()
		return HttpService:JSONEncode(data)
	end)
	if not ok then
		return false, "Could not encode the config."
	end
	local written = pcall(api.writefile, configPath(name), encoded)
	if not written then
		return false, "Could not write the config file."
	end
	return true
end

function Library:LoadConfig(name)
	name = sanitize(name)
	if not canSave() then
		return false, "Your executor cannot read files."
	end
	local path = configPath(name)
	local okExists, exists = pcall(api.isfile, path)
	if not okExists or not exists then
		return false, "Config not found."
	end
	local okRead, content = pcall(api.readfile, path)
	if not okRead then
		return false, "Could not read the config file."
	end
	local okDecode, data = pcall(function()
		return HttpService:JSONDecode(content)
	end)
	if not okDecode or type(data) ~= "table" or type(data.options) ~= "table" then
		return false, "The config file is damaged."
	end
	local order = (type(data.order) == "table" and #data.order > 0) and data.order or Library._order
	local applied = {}
	local function apply(flag)
		if applied[flag] then
			return
		end
		applied[flag] = true
		local entry = data.options[flag]
		local el = Library.Options[flag]
		if type(entry) ~= "table" or not el or el._noSave or not el._deserialize then
			return
		end
		if entry.t ~= nil and not sameType(entry.t, el.Type) then
			return
		end
		pcall(el._deserialize, el, entry.v)
	end
	for _, flag in ipairs(order) do
		apply(flag)
	end
	for flag in pairs(data.options) do
		apply(flag)
	end
	return true
end

function Library:DeleteConfig(name)
	name = sanitize(name)
	if not canSave() or name == "" then
		return false
	end
	local path = configPath(name)
	if api.delfile then
		return (pcall(api.delfile, path))
	end
	return false
end

function Library:GetConfigs()
	local out = {}
	if not api.listfiles then
		return out
	end
	ensureFolder(configDir())
	local ok, files = pcall(api.listfiles, configDir())
	if not ok or type(files) ~= "table" then
		return out
	end
	for _, file in ipairs(files) do
		local name = string.match(tostring(file), "([^/\\]+)%.json$")
		if name then
			out[#out + 1] = name
		end
	end
	table.sort(out, function(a, b)
		return string.lower(a) < string.lower(b)
	end)
	return out
end

function Library:SetAutoload(name)
	if not canSave() then
		return false
	end
	ensureFolder(tostring(Library.ConfigFolder))
	return (pcall(api.writefile, tostring(Library.ConfigFolder) .. "/autoload.txt", name and sanitize(name) or ""))
end

function Library:GetAutoload()
	if not canSave() then
		return nil
	end
	local path = tostring(Library.ConfigFolder) .. "/autoload.txt"
	local ok, exists = pcall(api.isfile, path)
	if not ok or not exists then
		return nil
	end
	local okRead, content = pcall(api.readfile, path)
	if not okRead then
		return nil
	end
	content = trim(content)
	return content ~= "" and content or nil
end

function Library:LoadAutoloadConfig()
	local name = Library:GetAutoload()
	if not name then
		return false
	end
	local ok, err = Library:LoadConfig(name)
	if ok then
		Library:Notify({ Title = "Config loaded", Content = "\"" .. name .. "\" was applied.", Type = "Success", Duration = 3 })
	else
		Library:Notify({ Title = "Autoload failed", Content = tostring(err), Type = "Error" })
	end
	return ok
end

local function settingsPath()
	return tostring(S.settingsFile or "EasyLibrary/settings.json")
end

function Library:SaveSettings()
	if not canSave() or not S.persistSettings or #S.settings == 0 then
		return false
	end
	local data = { version = 1, options = {} }
	local any = false
	for _, flag in ipairs(S.settings) do
		local el = Library.Options[flag]
		if el and el._serialize and S.settingsDirty[flag] then
			local ok, value = pcall(el._serialize, el)
			if ok and value ~= nil then
				data.options[flag] = { t = el.Type, v = value }
				any = true
			end
		end
	end
	if not any then
		return false
	end
	local ok, encoded = pcall(function()
		return HttpService:JSONEncode(data)
	end)
	if not ok then
		return false
	end
	local path = settingsPath()
	local folder = string.match(path, "^(.*)/[^/]*$")
	if folder then
		ensureFolder(folder)
	end
	return (pcall(api.writefile, path, encoded))
end

function Library:LoadSettings()
	if not canSave() or not S.persistSettings or #S.settings == 0 then
		return false
	end
	local path = settingsPath()
	local okExists, exists = pcall(api.isfile, path)
	if not okExists or not exists then
		return false
	end
	local okRead, content = pcall(api.readfile, path)
	if not okRead then
		return false
	end
	local okDecode, data = pcall(function()
		return HttpService:JSONDecode(content)
	end)
	if not okDecode or type(data) ~= "table" or type(data.options) ~= "table" then
		return false
	end
	for _, flag in ipairs(S.settings) do
		local entry = data.options[flag]
		local el = Library.Options[flag]
		if el and el._deserialize and type(entry) == "table" and (entry.t == nil or sameType(entry.t, el.Type)) then
			pcall(el._deserialize, el, entry.v)
			S.settingsDirty[flag] = true
		end
	end
	return true
end

function Library:ResetSettings()
	table.clear(S.settingsDirty)
	if canSave() and api.delfile then
		pcall(api.delfile, settingsPath())
	end
	return self
end

function Library:_queueSettingsSave()
	if S.settingsQueued or Library.Unloaded then
		return
	end
	S.settingsQueued = true
	task.delay(0.4, function()
		S.settingsQueued = false
		if not Library.Unloaded then
			Library:SaveSettings()
		end
	end)
end

function Window:_buildSettings()
	local opts = self._opts
	local tab = self:AddTab({ Name = opts.SettingsName or "Settings", Icon = "sliders-horizontal", Bottom = true })
	self._settingsTab = tab

	local ui = tab:AddLeftGroupbox("Interface")
	ui:AddSegmented("EasyLibrary_Theme", {
		Text = "Theme",
		Values = { "Dark", "Light" },
		Default = THEMES[S.themeName] and S.themeName or "Dark",
		Callback = function(v)
			Library:SetTheme(v)
		end,
	})
	ui:AddSegmented("EasyLibrary_Layout", {
		Text = "Layout",
		Values = { "Sidebar", "Top Tabs" },
		Default = self._layout == "Top" and "Top Tabs" or "Sidebar",
		Callback = function(v)
			self:SetLayout(v)
		end,
	})
	if not S.mobile then
		ui:AddSegmented("EasyLibrary_Density", {
			Text = "Density",
			Values = { "Comfortable", "Compact" },
			Default = S.density,
			Tooltip = "Compact fits more rows in the same window",
			Callback = function(v)
				if densityName(v) == S.density then
					return
				end
				Library:Notify({
					Title = "Density saved",
					Content = "The interface opens at the new size next time the script runs.",
					Type = "Info",
					Duration = 6,
				})
			end,
		})
	end
	ui:_addAccent("EasyLibrary_Accent")
	ui:AddDropdown("EasyLibrary_Font", {
		Text = "Font",
		Values = FONT_NAMES,
		Default = table.find(FONT_NAMES, S.fontName) and S.fontName or "Ubuntu",
		FontPreview = true,
		Callback = function(v)
			Library:SetFont(v)
		end,
	})
	ui:AddSlider("EasyLibrary_Scale", {
		Text = "UI Scale",
		Min = 70,
		Max = 130,
		Increment = 5,
		Default = 100,
		Suffix = "%",
		Callback = function(v)
			self:SetScale(v / 100)
		end,
	})
	if not S.mobile then
		local kb = ui:AddKeybind("EasyLibrary_MenuKey", {
			Text = "Menu Keybind",
			Default = self._menuKey,
			Mode = "Press",
			ShowMode = false,
			ChangedCallback = function(key)
				self:SetKeybind(key, true)
			end,
		})
		self._menuBind = kb
	end

	self:_buildConfigUI(tab:AddRightGroupbox("Configs"))

	local extra = tab:AddRightGroupbox("Extras")
	extra:AddToggle("EasyLibrary_Watermark", {
		Text = "Watermark",
		Default = opts.Watermark == true,
		Callback = function(v)
			Library:SetWatermarkVisible(v)
		end,
	})
	if not S.mobile then
		extra:AddToggle("EasyLibrary_KeybindList", {
			Text = "Keybind List",
			Default = opts.KeybindList == true,
			Callback = function(v)
				Library:SetKeybindListVisible(v)
			end,
		})
	end
	extra:AddButton({
		Text = "Unload",
		Variant = "Danger",
		Callback = function()
			self:_requestClose()
		end,
	})

	S.settings = {
		"EasyLibrary_Theme",
		"EasyLibrary_Layout",
		"EasyLibrary_Density",
		"EasyLibrary_Accent",
		"EasyLibrary_Font",
		"EasyLibrary_Scale",
		"EasyLibrary_MenuKey",
		"EasyLibrary_Watermark",
		"EasyLibrary_KeybindList",
	}
	local present = {}
	for _, flag in ipairs(S.settings) do
		local el = Library.Options[flag]
		if el then
			el._noSave = true
			el:OnChanged(function()
				if S.settingsLoading then
					return
				end
				S.settingsDirty[flag] = true
				Library:_queueSettingsSave()
			end)
			present[#present + 1] = flag
		end
	end
	S.settings = present
	S.settingsLoading = true
	Library:LoadSettings()
	S.settingsLoading = false
end

function Window:_buildConfigUI(box)
	if not canSave() then
		box:AddLabel("Your executor does not support saving files.", { Color = "tx3", Size = 12 })
		return
	end

	local selected
	local refresh

	local boxH = D.inputBox
	local nameRoot = frame({ Size = UDim2.new(1, 0, 0, D.inputLabel + boxH) }, box._body)
	box:_add(Label, "ConfigName", nil, { Text = "Config name" }, nameRoot)
	label({ Size = UDim2.new(1, 0, 0, 16), Text = "Config name", TextSize = D.fLabel, TextColor3 = tok.tx2 }, nameRoot)
	local nameRow = frame({ Position = UDim2.fromOffset(0, 22), Size = UDim2.new(1, 0, 0, boxH) }, nameRoot)
	list(nameRow, true, 6)
	local field = frame({ LayoutOrder = 1, Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = tok.el }, nameRow)
	fill(field)
	corner(field, D.rCtrl)
	local fieldStroke = stroke(field, D.lineToken)
	local nameBox = new("TextBox", {
		Position = UDim2.fromOffset(10, 0),
		Size = UDim2.new(1, -20, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = "",
		PlaceholderText = "my-config",
		PlaceholderColor3 = tok.tx3,
		TextColor3 = tok.tx,
		TextSize = D.fBody,
		FontFace = F_REG,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		ClipsDescendants = true,
	}, field)
	connect(nameBox.Focused, function()
		bindTween(fieldStroke, "Color", "accent")
		tween(fieldStroke, quick(), { Transparency = 0.45 })
	end)
	connect(nameBox.FocusLost, function()
		bindTween(fieldStroke, "Color", D.lineToken)
		tween(fieldStroke, quick(), { Transparency = 0 })
	end)
	local create = button({
		LayoutOrder = 2,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, boxH),
		BackgroundColor3 = tok.el,
		BackgroundTransparency = 0,
	}, nameRow)
	corner(create, D.rCtrl)
	stroke(create, "line2")
	pad(create, 0, 12, 0, 10)
	list(create, true, 6, nil, Enum.VerticalAlignment.Center)
	local plus = icon("plus", create, 12, "tx2")
	plus.LayoutOrder = 1
	label({
		LayoutOrder = 2,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 16),
		Text = "Create",
		TextTruncate = Enum.TextTruncate.None,
	}, create)
	hover(create, function(on)
		bindTween(create, "BackgroundColor3", on and "el2" or "el")
	end)
	press(create)

	local listRoot = frame({ Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y }, box._body)
	box:_add(Label, "ConfigList", nil, { Text = "Configs" }, listRoot)
	local listFrame = frame({
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = tok.bg,
	}, listRoot)
	corner(listFrame, D.rCtrl)
	stroke(listFrame, D.lineToken)
	pad(listFrame, 4, 4, 4, 4)
	list(listFrame, false, 2)

	box:AddButtons({
		{
			Text = "Load",
			Variant = "Primary",
			Callback = function()
				if not selected then
					Library:Notify({ Title = "No config selected", Content = "Pick a config from the list first.", Type = "Warning" })
					return
				end
				local ok, err = Library:LoadConfig(selected)
				if ok then
					Library:Notify({ Title = "Config loaded", Content = "\"" .. selected .. "\" was applied.", Type = "Success", Duration = 3 })
				else
					Library:Notify({ Title = "Load failed", Content = tostring(err), Type = "Error" })
				end
			end,
		},
		{
			Text = "Overwrite",
			Callback = function()
				if not selected then
					Library:Notify({ Title = "No config selected", Content = "Pick a config from the list first.", Type = "Warning" })
					return
				end
				local ok, err = Library:SaveConfig(selected)
				if ok then
					Library:Notify({ Title = "Config saved", Content = "\"" .. selected .. "\" was overwritten.", Type = "Success", Duration = 3 })
				else
					Library:Notify({ Title = "Save failed", Content = tostring(err), Type = "Error" })
				end
			end,
		},
		{
			Text = "Delete",
			Variant = "Danger",
			Callback = function()
				if not selected then
					Library:Notify({ Title = "No config selected", Content = "Pick a config from the list first.", Type = "Warning" })
					return
				end
				local target = selected
				Library:Dialog({
					Title = "Delete config?",
					Content = "\"" .. target .. "\" will be removed from your configs folder. This can't be undone.",
					Type = "Danger",
					Buttons = {
						{ Text = "Cancel" },
						{
							Text = "Delete",
							Variant = "Danger",
							Callback = function()
								Library:DeleteConfig(target)
								if Library:GetAutoload() == target then
									Library:SetAutoload(nil)
								end
								if selected == target then
									selected = nil
								end
								refresh()
								Library:Notify({ Title = "Config deleted", Content = "\"" .. target .. "\" was removed.", Type = "Info", Duration = 3 })
							end,
						},
					},
				})
			end,
		},
	})
	local autoload = box:AddToggle(nil, {
		Text = "Autoload selected",
		NoSave = true,
		Callback = function(v)
			if v then
				if selected then
					Library:SetAutoload(selected)
				end
			elseif selected and Library:GetAutoload() == selected then
				Library:SetAutoload(nil)
			end
			refresh()
		end,
	})

	local function select(name)
		selected = name
		autoload:SetValue(name ~= nil and Library:GetAutoload() == name, true)
		refresh()
	end

	refresh = function()
		for _, child in ipairs(listFrame:GetChildren()) do
			if child:IsA("GuiObject") then
				child:Destroy()
			end
		end
		local names = Library:GetConfigs()
		local auto = Library:GetAutoload()
		if selected and not table.find(names, selected) then
			selected = nil
		end
		if #names == 0 then
			label({
				Size = UDim2.new(1, 0, 0, 30),
				Text = "No configs yet",
				TextSize = D.fLabel,
				TextColor3 = tok.tx3,
				TextXAlignment = Enum.TextXAlignment.Center,
			}, listFrame)
			return
		end
		for i, name in ipairs(names) do
			local on = name == selected
			local row = optionRow(listFrame, i, D.option)
			if on then
				paint(row, "BackgroundColor3", "accent", false)
				row.BackgroundTransparency = 0.84
			end
			list(row, true, D.rowGap, nil, Enum.VerticalAlignment.Center)
			pad(row, 0, 8, 0, 8)
			local ic = icon("file", row, 14, on and "tx" or "tx3")
			ic.LayoutOrder = 1
			local text = label({
				LayoutOrder = 2,
				Size = UDim2.new(0, 0, 1, 0),
				Text = name,
				TextColor3 = on and tok.tx or tok.tx2,
			}, row)
			fill(text)
			if name == auto then
				local badge = label({
					LayoutOrder = 3,
					AutomaticSize = Enum.AutomaticSize.X,
					Size = UDim2.fromOffset(0, 16),
					Text = "auto",
					TextSize = D.fTiny,
					TextColor3 = tok.tx2,
					TextTruncate = Enum.TextTruncate.None,
				}, row)
				corner(badge, D.rTiny)
				stroke(badge, "line2")
				pad(badge, 0, 5, 0, 5)
			end
			hover(row, function(h)
				if not on then
					row.BackgroundTransparency = h and 0 or 1
				end
			end)
			connect(row.Activated, function()
				select(on and nil or name)
			end)
		end
	end

	connect(create.Activated, function()
		local name = sanitize(nameBox.Text)
		if name == "" then
			Library:Notify({ Title = "Name required", Content = "Type a name for the new config.", Type = "Warning" })
			return
		end
		if table.find(Library:GetConfigs(), name) then
			Library:Notify({ Title = "Config exists", Content = "\"" .. name .. "\" already exists. Use Overwrite to replace it.", Type = "Warning" })
			return
		end
		local ok, err = Library:SaveConfig(name)
		if ok then
			nameBox.Text = ""
			select(name)
			Library:Notify({ Title = "Config created", Content = "\"" .. name .. "\" was saved.", Type = "Success", Duration = 3 })
		else
			Library:Notify({ Title = "Save failed", Content = tostring(err), Type = "Error" })
		end
	end)

	local tab = box._tab
	local previous = tab._onSelect
	tab._onSelect = function()
		if previous then
			previous()
		end
		refresh()
	end
	refresh()
end

function Library:Unload()
	if Library.Unloaded then
		return
	end
	pcall(Library.SaveSettings, Library)
	Library.Unloaded = true
	for _, f in ipairs(S.unload) do
		pcall(f)
	end
	for entry in pairs(S.drags) do
		entry.finish()
	end
	for _, c in ipairs(S.conns) do
		c:Disconnect()
	end
	if S.wmConn then
		S.wmConn:Disconnect()
		S.wmConn = nil
	end
	if S.gui then
		S.gui:Destroy()
		S.gui = nil
	end
	if S.blur then
		S.blur:Destroy()
		S.blur = nil
	end
	local key = Library._globalKey or "EasyLibraryUnload"
	if type(shared) == "table" and shared[key] then
		shared[key] = nil
	end
	clearState()
end

return Library
