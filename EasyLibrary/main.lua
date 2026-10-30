local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local Workspace = game:GetService("Workspace")

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
}

local Library = {
	Flags = {},
	Options = {},
	Toggles = {},
	Themes = THEMES,
	Fonts = FONTS,
	FontNames = FONT_NAMES,
	Unloaded = false,
	Device = "PC",
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
	conns = {},
	drags = {},
	unload = {},
	keybinds = {},
	mobile = false,
	animate = true,
	speed = 1,
	gui = nil,
}

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
	if (l + 0.05) / (DARK_TEXT_LUM + 0.05) >= 1.05 / (l + 0.05) then
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

local function pointer(input)
	local p = input.Position
	local inset = GuiService:GetGuiInset()
	return Vector2.new(p.X + inset.X, p.Y + inset.Y)
end

local function over(gui, pos)
	if not gui or not gui.Visible then
		return false
	end
	local a, s = gui.AbsolutePosition, gui.AbsoluteSize
	return pos.X >= a.X and pos.X <= a.X + s.X and pos.Y >= a.Y and pos.Y <= a.Y + s.Y
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

local Signal = {}
Signal.__index = Signal

function Signal.new()
	return setmetatable({ _fns = {}, _threads = {} }, Signal)
end

function Signal:Connect(f)
	local fns = self._fns
	fns[#fns + 1] = f
	return {
		Disconnect = function()
			local i = table.find(fns, f)
			if i then
				table.remove(fns, i)
			end
		end,
	}
end

function Signal:Wait()
	self._threads[#self._threads + 1] = coroutine.running()
	return coroutine.yield()
end

function Signal:Fire(...)
	for _, f in ipairs(table.clone(self._fns)) do
		task.spawn(f, ...)
	end
	local threads = self._threads
	self._threads = {}
	for _, th in ipairs(threads) do
		task.spawn(th, ...)
	end
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
	props.TextSize = props.TextSize or 13
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

Library.Icons = {}
for name in pairs(ICONS) do
	Library.Icons[#Library.Icons + 1] = name
end
table.sort(Library.Icons)

local LUCIDE_URL = "https://github.com/latte-soft/lucide-roblox/releases/download/0.1.3/lucide-roblox.luau"
local LUCIDE_CACHE = "EasyLibrary/cache/lucide-roblox-0.1.3.luau"

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

local function loadLucide()
	if S.lucide ~= nil then
		return S.lucide
	end
	S.lucide = false
	local source
	if api.isfile and api.readfile then
		local ok, exists = pcall(api.isfile, LUCIDE_CACHE)
		if ok and exists then
			local okRead, content = pcall(api.readfile, LUCIDE_CACHE)
			if okRead and type(content) == "string" and #content > 10000 then
				source = content
			end
		end
	end
	if not source then
		local ok, body = pcall(function()
			return game:HttpGet(LUCIDE_URL)
		end)
		if ok and type(body) == "string" and #body > 10000 then
			source = body
			if api.writefile then
				ensureFolder("EasyLibrary/cache")
				pcall(api.writefile, LUCIDE_CACHE, body)
			end
		end
	end
	if source and typeof(loadstring) == "function" then
		local okCompile, chunk = pcall(loadstring, source)
		if okCompile and type(chunk) == "function" then
			local okRun, module = pcall(chunk)
			if okRun and type(module) == "table" and type(module.GetAsset) == "function" then
				S.lucide = module
			end
		end
	end
	return S.lucide
end

local function lucideAsset(name)
	local lucide = S.lucide
	if not lucide then
		return nil
	end
	local key = LUCIDE_ALIAS[name] or name
	local cached = S.iconCache[key]
	if cached ~= nil then
		return cached or nil
	end
	local ok, asset = pcall(lucide.GetAsset, key, 48)
	if not ok or type(asset) ~= "table" then
		ok, asset = pcall(lucide.GetAsset, key)
	end
	S.iconCache[key] = (ok and type(asset) == "table") and asset or false
	return S.iconCache[key] or nil
end

local function isImage(name)
	return type(name) == "string" and (string.find(name, "rbxasset", 1, true) ~= nil or string.find(name, "^%d+$") ~= nil)
end

local function icon(name, parent, size, token)
	size = size or 16
	local holder = frame({ Size = UDim2.fromOffset(size, size) }, parent)
	local parts = {}
	local asset = (not isImage(name)) and type(name) == "string" and lucideAsset(name) or nil
	if asset then
		local img = new("ImageLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Image = asset.Url,
			ImageRectOffset = asset.ImageRectOffset,
			ImageRectSize = asset.ImageRectSize,
			ScaleType = Enum.ScaleType.Fit,
		}, holder)
		parts[1] = { img, "ImageColor3" }
	else
		if type(name) == "string" and BUILTIN_ALIAS[name] then
			name = BUILTIN_ALIAS[name]
		end
		if isImage(name) then
			local img = new("ImageLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				Image = string.find(name, "^%d+$") and ("rbxassetid://" .. name) or name,
				ScaleType = Enum.ScaleType.Fit,
			}, holder)
			parts[1] = { img, "ImageColor3" }
		elseif ICONS[name] then
			local inner = frame({
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(16, 16),
			}, holder)
			if size ~= 16 then
				new("UIScale", { Scale = size / 16 }, inner)
			end
			ICONS[name](parts, inner)
		end
	end
	local function set(t, animated)
		for _, part in ipairs(parts) do
			paint(part[1], part[2], t, animated)
		end
	end
	set(token or "tx3", false)
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
		Size = UDim2.fromOffset(0, 20),
		BackgroundColor3 = tok.el,
		BorderSizePixel = 0,
		Text = text,
		TextSize = 11,
		FontFace = F_MONO,
		TextColor3 = tok.tx2,
	}, parent)
	corner(cap, 5)
	local s = stroke(cap, "line2")
	pad(cap, 0, 7, 0, 7)
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

local function rootGui()
	if S.gui and S.gui.Parent then
		return S.gui
	end
	local parent = defaultParent()
	local old = parent:FindFirstChild("EasyLibrary")
	if old then
		old:Destroy()
	end
	S.gui = screenGui("EasyLibrary", 2147482900)
	S.gui.Parent = parent
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

local Window = {}
Window.__index = Window

local Tab = {}
Tab.__index = Tab

local HEADER_H, NAV_H = 44, 38
local SIDE_W, SIDE_COMPACT_W = 184, 52

local WINDOW_DEFAULTS = {
	Title = "EasyLibrary",
	Logo = nil,
	Theme = "Dark",
	Accent = SWATCHES[1],
	Font = "Ubuntu",
	Layout = "Sidebar",
	Size = Vector2.new(880, 584),
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
	Watermark = false,
	KeybindList = false,
	Animations = true,
	AnimationSpeed = 1,
	Icons = "Lucide",
}

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

function Library:CreateWindow(options)
	if self._window and not self.Unloaded then
		return self._window
	end
	if type(shared) == "table" and type(shared.EasyLibraryUnload) == "function" then
		pcall(shared.EasyLibraryUnload)
	end
	if type(shared) == "table" then
		shared.EasyLibraryUnload = function()
			Library:Unload()
		end
	end

	local opts = merge(WINDOW_DEFAULTS, options)
	if typeof(opts.Size) == "UDim2" then
		opts.Size = Vector2.new(opts.Size.X.Offset, opts.Size.Y.Offset)
	elseif typeof(opts.Size) ~= "Vector2" then
		opts.Size = WINDOW_DEFAULTS.Size
	end
	opts.Size = Vector2.new(math.max(opts.Size.X, 420), math.max(opts.Size.Y, 300))

	Library.Device = detectDevice(opts.Device)
	S.mobile = Library.Device == "Mobile"
	S.animate = opts.Animations ~= false
	S.speed = math.max(tonumber(opts.AnimationSpeed) or 1, 0.05)
	Library:SetTheme(opts.Theme)
	Library:SetAccent(typeof(opts.Accent) == "Color3" and opts.Accent or SWATCHES[1])
	Library:SetFont(opts.Font)
	Library.ConfigFolder = opts.ConfigFolder or ("EasyLibrary/" .. (sanitize(opts.Title) ~= "" and sanitize(opts.Title) or "Default"))
	if string.lower(tostring(opts.Icons)) ~= "builtin" then
		loadLucide()
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
		Library:SetWatermarkVisible(true)
	end
	if opts.KeybindList then
		Library:SetKeybindListVisible(true)
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
	corner(b, 6)
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
	corner(main, 10)
	stroke(main, "line2")
	self._main = main

	local header = frame({
		Name = "Header",
		Size = UDim2.new(1, 0, 0, HEADER_H),
		BackgroundColor3 = tok.side,
		Active = true,
	}, main)
	corner(header, 10)
	frame({ Position = UDim2.new(0, 0, 1, -10), Size = UDim2.new(1, 0, 0, 10), BackgroundColor3 = tok.side }, header)
	frame({ Position = UDim2.new(0, 0, 1, -1), Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = tok.line, ZIndex = 2 }, header)
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
	corner(box, 6)
	local st = stroke(box, "line")
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
	corner(clear, 5)
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
		TextSize = 12,
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
		bindTween(st, "Color", "line")
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
		Position = UDim2.fromOffset(0, HEADER_H),
		Size = UDim2.new(0, SIDE_W, 1, -HEADER_H),
		BackgroundColor3 = tok.side,
	}, main)
	corner(side, 10)
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
		BackgroundColor3 = tok.line,
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
	frame({ Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = tok.line }, block)
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
		TextSize = 12,
		FontFace = F_SEMI,
	}, row)
	local user = label({
		Position = UDim2.fromOffset(40, 16),
		Size = UDim2.new(1, -40, 0, 14),
		Text = "@" .. LocalPlayer.Name,
		TextSize = 11,
		TextColor3 = tok.tx3,
	}, row)
	self._profile = { row = row, texts = { name, user } }
end

function Window:_buildNav(main)
	local nav = frame({
		Name = "TopNav",
		Position = UDim2.fromOffset(0, HEADER_H),
		Size = UDim2.new(1, 0, 0, NAV_H),
		BackgroundColor3 = tok.side,
		Visible = false,
	}, main)
	frame({ Position = UDim2.new(0, 0, 1, -1), Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = tok.line, ZIndex = 3 }, nav)
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
	corner(pill, 10)
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
	corner(btn, 14)
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
	local compact = sidebar and w < 640
	local sideW = sidebar and (compact and SIDE_COMPACT_W or SIDE_W) or 0
	local navH = sidebar and 0 or NAV_H
	self._side.Visible = sidebar
	self._side.Size = UDim2.new(0, sideW, 1, -HEADER_H)
	self._nav.Visible = not sidebar
	self._content.Position = UDim2.fromOffset(sideW, HEADER_H + navH)
	self._content.Size = UDim2.new(1, -sideW, 1, -(HEADER_H + navH))

	if self._searchBox then
		self._searchBox.Size = UDim2.fromOffset(w < 560 and 120 or (S.mobile and 150 or 210), 28)
	end
	self._title.Visible = w >= 480

	local single = (w - sideW - 24) < 520
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

function Window:_transition(show)
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
		ScrollBarThickness = S.mobile and 4 or 3,
		ScrollBarImageColor3 = tok.line2,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(),
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Visible = false,
	}, self._content)
	pad(page, 12, 0, 12, 0)
	local cols = frame({
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(1, -24, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	}, page)
	tab._empty = label({
		Position = UDim2.fromOffset(12, 24),
		Size = UDim2.new(1, -24, 0, 40),
		Text = "",
		TextSize = 12,
		TextColor3 = tok.tx3,
		TextXAlignment = Enum.TextXAlignment.Center,
		Visible = false,
	}, page)
	tab._columnsLayout = list(cols, true, 12)
	tab._left = frame({ LayoutOrder = 1, Size = UDim2.new(0.5, -6, 0, 0), AutomaticSize = Enum.AutomaticSize.Y }, cols)
	list(tab._left, false, 12)
	tab._right = frame({ LayoutOrder = 2, Size = UDim2.new(0.5, -6, 0, 0), AutomaticSize = Enum.AutomaticSize.Y }, cols)
	list(tab._right, false, 12)
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
	local fade = tab._fade
	if not fade then
		fade = new("CanvasGroup", {
			Name = "Fade",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, -24, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Visible = false,
		}, tab._page)
		tab._fade = fade
	end
	tab._fadeId = (tab._fadeId or 0) + 1
	local id = tab._fadeId
	cols.Parent = fade
	cols.Position = UDim2.fromOffset(0, 0)
	cols.Size = UDim2.new(1, 0, 0, 0)
	fade.Visible = true
	fade.GroupTransparency = 1
	fade.Position = UDim2.fromOffset(12, 10)
	local duration = 0.35
	tween(fade, info(duration, Style.Quint, Direction.Out), { GroupTransparency = 0, Position = UDim2.fromOffset(12, 0) })
	task.delay(duration / S.speed, function()
		if tab._fadeId ~= id or Library.Unloaded then
			return
		end
		cols.Parent = tab._page
		cols.Position = UDim2.fromOffset(12, 0)
		cols.Size = UDim2.new(1, -24, 0, 0)
		fade.Visible = false
	end)
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
	self:_applySearch(true)
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
				local count = 0
				for _, el in ipairs(c._items) do
					local match = (not active) or matches(groupName .. " " .. string.lower(el._search or ""), tokens)
					el._match = match
					el:_applyVisible()
					if match and el._visible and not el._hiddenByDevice then
						any = true
						count = count + 1
					end
				end
				containerHits[ci] = count
				if active then
					hits = hits + count
				end
			end
			g.frame.Visible = (not active) or any
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
	corner(group, 6)
	local panel = frame({
		Position = UDim2.fromOffset(1, 1),
		Size = UDim2.new(1, -2, 1, -2),
		BackgroundColor3 = tok.box,
		Active = true,
	}, group)
	corner(panel, 5)
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
		local pos = pointer(input)
		if over(group, pos) then
			return
		end
		for _, g in ipairs(p.ignore) do
			if over(g, pos) then
				return
			end
		end
		self:_closePopup()
	end)
	local tab = self._current
	if tab then
		p.conns[#p.conns + 1] = tab._page:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
			self:_closePopup()
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
	if S.mobile or text == nil or text == "" then
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
	connect(target.MouseEnter, function()
		token = token + 1
		local mine = token
		task.delay(0.35, function()
			if mine ~= token or not target.Parent or self._pop or not self._visible then
				return
			end
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
				TextSize = 11,
				TextColor3 = tok.box,
				TextTruncate = Enum.TextTruncate.None,
				ZIndex = 40,
			}, self._overlay)
			corner(tip, 5)
			pad(tip, 6, 9, 6, 9)
			if S.animate then
				tip.BackgroundTransparency = 1
				tip.TextTransparency = 1
				tween(tip, info(0.18, Style.Quad, Direction.Out), { BackgroundTransparency = 0, TextTransparency = 0 })
			else
				tip.BackgroundTransparency = 0
			end
		end)
	end)
	connect(target.MouseLeave, hide)
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
	corner(b, 6)
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
		Size = UDim2.fromOffset(0, 18),
		BackgroundColor3 = tok.accent,
		Text = "",
		TextSize = 11,
		FontFace = F_MONO,
		TextColor3 = tok.tx,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextTruncate = Enum.TextTruncate.None,
		Visible = false,
	}, b)
	badge.BackgroundTransparency = 0.84
	corner(badge, 9)
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
		Size = UDim2.fromOffset(0, NAV_H),
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
		Size = UDim2.fromOffset(0, 18),
		BackgroundColor3 = tok.accent,
		Text = "",
		TextSize = 11,
		FontFace = F_MONO,
		TextColor3 = tok.tx,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextTruncate = Enum.TextTruncate.None,
		Visible = false,
	}, inner)
	badge.BackgroundTransparency = 0.84
	corner(badge, 9)
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
	local size = single and UDim2.new(1, 0, 0, 0) or UDim2.new(0.5, -6, 0, 0)
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
		for kb in pairs(S.keybinds) do
			if kb.Value == key then
				kb:_press()
			end
		end
	end)
	connect(UserInputService.InputEnded, function(input)
		local key = keyOf(input)
		for kb in pairs(S.keybinds) do
			if kb.Value == key then
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

local function rowHeight(desktop, mobile)
	return S.mobile and mobile or desktop
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

function Container.new(tab, group, body)
	return setmetatable({
		_tab = tab,
		_win = tab._win,
		_group = group,
		_body = body,
		_items = {},
		_order = 0,
	}, Container)
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
		Library.Options[flag] = el
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
	pad(body, 8, 12, 12, 12)
	list(body, false, 10)
	return body
end

function Tab:_groupFrame(side)
	local column = string.lower(tostring(side or "Left")) == "right" and self._right or self._left
	local box = frame({
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = tok.box,
		LayoutOrder = #self._groups + 1,
	}, column)
	corner(box, 8)
	stroke(box, "line")
	list(box, false, 0)
	local header = frame({ LayoutOrder = 1, Size = UDim2.new(1, 0, 0, 34) }, box)
	frame({ Position = UDim2.new(0, 0, 1, -1), Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = tok.line }, header)
	return box, header
end

function Tab:AddGroupbox(options)
	if type(options) == "string" then
		options = { Name = options }
	end
	options = options or {}
	local name = tostring(options.Name or options.Title or "")
	local box, header = self:_groupFrame(options.Side)
	label({
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(1, -24, 1, 0),
		Text = name,
		TextSize = 12,
		FontFace = F_SEMI,
	}, header)
	local body = self:_body(box, 2)
	local c = Container.new(self, box, body)
	self._groups[#self._groups + 1] = { frame = box, name = name, containers = { c } }
	return c
end

function Tab:AddLeftGroupbox(name)
	return self:AddGroupbox({ Name = name, Side = "Left" })
end

function Tab:AddRightGroupbox(name)
	return self:AddGroupbox({ Name = name, Side = "Right" })
end

local Tabbox = {}
Tabbox.__index = Tabbox

function Tab:AddTabbox(options)
	if type(options) == "string" then
		options = { Name = options }
	end
	options = options or {}
	local name = tostring(options.Name or options.Title or "")
	local box, header = self:_groupFrame(options.Side)
	if name ~= "" then
		label({
			Position = UDim2.fromOffset(12, 0),
			Size = UDim2.new(0.5, -12, 1, 0),
			Text = name,
			TextSize = 12,
			FontFace = F_SEMI,
		}, header)
	end
	local buttons = frame({
		AnchorPoint = Vector2.new(name ~= "" and 1 or 0, 0.5),
		Position = name ~= "" and UDim2.new(1, -8, 0.5, 0) or UDim2.new(0, 8, 0.5, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 24),
	}, header)
	list(buttons, true, 2, nil, Enum.VerticalAlignment.Center)
	local entry = { frame = box, name = name, containers = {} }
	self._groups[#self._groups + 1] = entry
	local tb = setmetatable({ _tab = self, _box = box, _buttons = buttons, _subs = {}, _entry = entry }, Tabbox)
	entry.tabbox = tb
	return tb
end

function Tab:AddLeftTabbox(name)
	return self:AddTabbox({ Name = name, Side = "Left" })
end

function Tab:AddRightTabbox(name)
	return self:AddTabbox({ Name = name, Side = "Right" })
end

function Tabbox:AddTab(name)
	local index = #self._subs + 1
	local body = self._tab:_body(self._box, index + 1)
	body.Visible = index == 1
	local c = Container.new(self._tab, self._box, body)
	local b = button({
		LayoutOrder = index,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, rowHeight(22, 26)),
		BackgroundColor3 = tok.el2,
		BackgroundTransparency = 1,
		Text = tostring(name or ("Tab " .. index)),
		TextSize = 11,
		FontFace = F_MED,
		TextColor3 = tok.tx3,
	}, self._buttons)
	corner(b, 4)
	pad(b, 0, 8, 0, 8)
	local sub = { body = body, button = b, container = c }
	self._subs[index] = sub
	self._entry.containers[#self._entry.containers + 1] = c
	connect(b.Activated, function()
		self:_select(sub)
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

function Container:_toggle(flag, options, style)
	local checkbox = style == "Checkbox"
	local h = checkbox and rowHeight(22, 28) or rowHeight(26, 30)
	local row = button({ Size = UDim2.new(1, 0, 0, h) }, self._body)
	list(row, true, checkbox and 10 or 8, nil, Enum.VerticalAlignment.Center)
	local el = self:_add(Toggle, style, flag, options, row)
	el._style = style
	if checkbox then
		local box = frame({ LayoutOrder = 1, Size = UDim2.fromOffset(16, 16), BackgroundColor3 = tok.el }, row)
		corner(box, 4)
		el._boxStroke = stroke(box, "line2")
		local mark = icon("check", box, 12, "onAccent")
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
	list(right, true, 8, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center)
	el._right = right
	if not checkbox then
		local sw = frame({ LayoutOrder = 10, Size = UDim2.fromOffset(32, 18), BackgroundColor3 = tok.el2 }, right)
		corner(sw)
		el._swStroke = stroke(sw, "line2")
		el._knob = frame({
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 4, 0.5, 0),
			Size = UDim2.fromOffset(10, 10),
			BackgroundColor3 = tok.knobOff,
		}, sw)
		corner(el._knob)
		el._switch = sw
	end
	el.Value = options.Default == true
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

function Container:AddToggle(flag, options)
	flag, options = args(flag, options)
	return self:_toggle(flag, options, "Toggle")
end

function Container:AddCheckbox(flag, options)
	flag, options = args(flag, options)
	return self:_toggle(flag, options, "Checkbox")
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
		local pos = UDim2.new(0, on and 18 or 4, 0.5, 0)
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
	return self
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

	local root = frame({ Size = UDim2.new(1, 0, 0, rowHeight(36, 42)) }, self._body)
	local el = self:_add(Slider, "Slider", flag, options, root)
	el.Min, el.Max, el._step = min, max, step
	el._suffix = tostring(options.Suffix or "")
	el._label = label({ Size = UDim2.new(1, -80, 0, 16), Text = el.Text }, root)
	el._valueLabel = label({
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.fromOffset(80, 16),
		TextXAlignment = Enum.TextXAlignment.Right,
		TextSize = 11,
		FontFace = F_MONO,
		TextColor3 = tok.tx2,
	}, root)
	local zone = button({ Position = UDim2.fromOffset(0, 20), Size = UDim2.new(1, 0, 1, -20) }, root)
	local trackFrame = frame({
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.new(1, 0, 0, 6),
		BackgroundColor3 = tok.el2,
	}, zone)
	corner(trackFrame, 3)
	el._fill = frame({ Size = UDim2.fromScale(0, 1), BackgroundColor3 = tok.accent }, trackFrame)
	corner(el._fill, 3)
	local thumb = rowHeight(14, 16)
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
	self._valueLabel.Text = formatNumber(self.Value, self._step) .. self._suffix
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
	local boxH = rowHeight(30, 34)
	local root = frame({ Size = UDim2.new(1, 0, 0, (hasText and 22 or 0) + boxH) }, self._body)
	local el = self:_add(Input, "Input", flag, options, root)
	if hasText then
		el._label = label({ Size = UDim2.new(1, 0, 0, 16), Text = el.Text, TextSize = 12, TextColor3 = tok.tx2 }, root)
	end
	local box = frame({
		Position = UDim2.fromOffset(0, hasText and 22 or 0),
		Size = UDim2.new(1, 0, 0, boxH),
		BackgroundColor3 = tok.el,
	}, root)
	corner(box, 6)
	local st = stroke(box, "line")
	local tb = new("TextBox", {
		Position = UDim2.fromOffset(10, 0),
		Size = UDim2.new(1, -20, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = tostring(options.Default or ""),
		PlaceholderText = tostring(options.Placeholder or ""),
		PlaceholderColor3 = tok.tx3,
		TextColor3 = tok.tx,
		TextSize = 13,
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
		bindTween(st, "Color", "line")
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
	local h = rowHeight(26, 30)
	local row = frame({ Size = UDim2.new(1, 0, 0, h) }, self._body)
	list(row, true, 8, nil, Enum.VerticalAlignment.Center)
	local el = self:_add(Stepper, "Stepper", flag, options, row)
	el.Min, el.Max, el._step = min, max, step
	el._label = label({ LayoutOrder = 1, Size = UDim2.new(0, 0, 1, 0), Text = el.Text }, row)
	fill(el._label)

	local ctrl = frame({ LayoutOrder = 2, Size = UDim2.fromOffset(h * 2 + 40, h), BackgroundColor3 = tok.el }, row)
	corner(ctrl, 6)
	stroke(ctrl, "line2")
	frame({ Position = UDim2.fromOffset(h, 0), Size = UDim2.fromOffset(1, h), BackgroundColor3 = tok.line }, ctrl)
	frame({ Position = UDim2.fromOffset(h + 39, 0), Size = UDim2.fromOffset(1, h), BackgroundColor3 = tok.line }, ctrl)
	el._valueLabel = label({
		Position = UDim2.fromOffset(h + 1, 0),
		Size = UDim2.fromOffset(38, h),
		TextXAlignment = Enum.TextXAlignment.Center,
		TextSize = 12,
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
	stepButton(h + 40, "plus", 1)

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
	local ctrlH = rowHeight(28, 32)
	local root = frame({ Size = UDim2.new(1, 0, 0, (hasText and 22 or 0) + ctrlH) }, self._body)
	local el = self:_add(Segmented, "Segmented", flag, options, root)
	el.Values = values
	if hasText then
		el._label = label({ Size = UDim2.new(1, 0, 0, 16), Text = el.Text, TextSize = 12, TextColor3 = tok.tx2 }, root)
	end
	local ctrl = frame({
		Position = UDim2.fromOffset(0, hasText and 22 or 0),
		Size = UDim2.new(1, 0, 0, ctrlH),
		BackgroundColor3 = tok.el,
	}, root)
	corner(ctrl, 7)
	stroke(ctrl, "line")
	pad(ctrl, 2, 2, 2, 2)
	el._indicator = frame({
		Size = UDim2.new(1 / n, -2 * (n - 1) / n, 1, 0),
		BackgroundColor3 = tok.segOn,
	}, ctrl)
	corner(el._indicator, 5)
	local holder = frame({ Size = UDim2.fromScale(1, 1), ZIndex = 2 }, ctrl)
	list(holder, true, 2)
	el._buttons = {}
	for i, v in ipairs(values) do
		local b = button({
			LayoutOrder = i,
			Size = UDim2.new(1 / n, -2 * (n - 1) / n, 1, 0),
			Text = v,
			TextSize = 12,
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
	corner(btn, 6)
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
	local btn = button({ Size = UDim2.new(1, 0, 0, rowHeight(30, 34)), BackgroundColor3 = tok.el }, self._body)
	local el = self:_add(Button, "Button", nil, options, btn)
	styleButton(el, btn, options)
	return el
end

local ButtonRow = class()

function Container:AddButtons(items)
	local n = #items
	local row = frame({ Size = UDim2.new(1, 0, 0, rowHeight(30, 34)) }, self._body)
	list(row, true, 8)
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
		TextSize = 12,
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
		local left = frame({ LayoutOrder = 1, Size = UDim2.new(0, 0, 0, 1), BackgroundColor3 = tok.line }, root)
		fill(left)
		label({
			LayoutOrder = 2,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.fromOffset(0, 14),
			Text = string.upper(text),
			TextSize = 10,
			FontFace = F_MED,
			TextColor3 = tok.tx3,
			TextTruncate = Enum.TextTruncate.None,
		}, root)
		local right = frame({ LayoutOrder = 3, Size = UDim2.new(0, 0, 0, 1), BackgroundColor3 = tok.line }, root)
		fill(right)
	else
		root = frame({ Size = UDim2.new(1, 0, 0, 5) }, self._body)
		frame({
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.new(1, 0, 0, 1),
			BackgroundColor3 = tok.line,
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
		TextSize = 11,
		FontFace = F_MONO,
		TextColor3 = tok.tx2,
	}, root)
	local trackFrame = frame({ Position = UDim2.fromOffset(0, 24), Size = UDim2.new(1, 0, 0, 6), BackgroundColor3 = tok.el2 }, root)
	corner(trackFrame, 3)
	el._fill = frame({ Size = UDim2.fromScale(0, 1), BackgroundColor3 = tok.accent }, trackFrame)
	corner(el._fill, 3)
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
	corner(root, 6)
	stroke(root, "line")
	local el = self:_add(ImageElement, "Image", nil, options, root)
	local image = tostring(options.Image or "")
	el._image = new("ImageLabel", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ScaleType = options.ScaleType or Enum.ScaleType.Fit,
		Image = string.find(image, "^%d+$") and ("rbxassetid://" .. image) or image,
	}, root)
	corner(el._image, 6)
	return el
end

function ImageElement:SetImage(image)
	image = tostring(image or "")
	self._image.Image = string.find(image, "^%d+$") and ("rbxassetid://" .. image) or image
	return self
end

local Dropdown = class()

local function optionRow(parent, order, height)
	local row = button({
		LayoutOrder = order,
		Size = UDim2.new(1, 0, 0, height),
		BackgroundColor3 = tok.el,
		BackgroundTransparency = 1,
	}, parent)
	corner(row, 4)
	return row
end

function Container:AddDropdown(flag, options)
	flag, options = args(flag, options)
	local hasText = tostring(options.Text or "") ~= ""
	local boxH = rowHeight(30, 34)
	local root = frame({ Size = UDim2.new(1, 0, 0, (hasText and 22 or 0) + boxH) }, self._body)
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
		el._label = label({ Size = UDim2.new(1, 0, 0, 16), Text = el.Text, TextSize = 12, TextColor3 = tok.tx2 }, root)
	end
	local box = button({
		Position = UDim2.fromOffset(0, hasText and 22 or 0),
		Size = UDim2.new(1, 0, 0, boxH),
		BackgroundColor3 = tok.el,
		BackgroundTransparency = 0,
	}, root)
	corner(box, 6)
	el._stroke = stroke(box, "line")
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
					TextSize = 11,
					TextTruncate = Enum.TextTruncate.None,
				}, self._chips)
				chip.BackgroundTransparency = 0.84
				corner(chip, 4)
				pad(chip, 0, 6, 0, 6)
			end
			if #selected > 2 then
				label({
					LayoutOrder = 3,
					AutomaticSize = Enum.AutomaticSize.X,
					Size = UDim2.fromOffset(0, 20),
					Text = "+" .. (#selected - 2),
					TextSize = 11,
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
end

function Dropdown:_openList()
	local win = self._win
	local values = self.Values
	local optH = rowHeight(28, 32)
	local searchable = #values > 8
	local shown = math.max(math.min(#values, 8), 1)
	local listH = shown * (optH + 2) - 2
	local height = 8 + (searchable and (optH + 4) or 0) + listH
	local width = self._box.AbsoluteSize.X / win._fit.Scale
	self._open = true
	tween(self._chev, quick(), { Rotation = 180 })
	bindTween(self._stroke, "Color", "accent")
	tween(self._stroke, quick(), { Transparency = 0.45 })

	win:_popup(self._box, width, height, function(panel)
		pad(panel, 4, 4, 4, 4)
		local rows = {}
		local function render(entry)
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
		local y = 0
		if searchable then
			local search = frame({ Size = UDim2.new(1, 0, 0, optH), BackgroundColor3 = tok.el }, panel)
			corner(search, 4)
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
				TextSize = 12,
				FontFace = F_REG,
				TextXAlignment = Enum.TextXAlignment.Left,
				ClearTextOnFocus = false,
			}, search)
			connect(tb:GetPropertyChangedSignal("Text"), function()
				local q = string.lower(trim(tb.Text))
				for _, entry in ipairs(rows) do
					entry.row.Visible = q == "" or string.find(string.lower(entry.value), q, 1, true) ~= nil
				end
			end)
			y = optH + 4
		end
		local scroll = new("ScrollingFrame", {
			Position = UDim2.fromOffset(0, y),
			Size = UDim2.new(1, 0, 1, -y),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = tok.line2,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			CanvasSize = UDim2.new(),
			ScrollingDirection = Enum.ScrollingDirection.Y,
		}, panel)
		list(scroll, false, 2)
		if #values == 0 then
			label({
				Size = UDim2.new(1, 0, 0, optH),
				Text = "No options",
				TextColor3 = tok.tx3,
				TextXAlignment = Enum.TextXAlignment.Center,
			}, scroll)
		end
		for i, v in ipairs(values) do
			local row = optionRow(scroll, i, optH)
			local text = label({
				Position = UDim2.fromOffset(8, 0),
				Size = UDim2.new(1, -34, 1, 0),
				Text = v,
				TextColor3 = tok.tx2,
			}, row)
			if self._fontPreview and FONTS[v] then
				S.fonted[text] = nil
				text.FontFace = Font.fromEnum(FONTS[v])
			end
			local check = icon("check", row, 14, "accent")
			check.AnchorPoint = Vector2.new(1, 0.5)
			check.Position = UDim2.new(1, -8, 0.5, 0)
			local entry = { row = row, text = text, check = check, value = v }
			rows[#rows + 1] = entry
			render(entry)
			hover(row, function(on)
				entry.hover = on
				render(entry)
			end)
			connect(row.Activated, function()
				self:_pick(v)
				if self.Multi then
					for _, e in ipairs(rows) do
						render(e)
					end
				else
					win:_closePopup()
				end
			end)
		end
		if not self.Multi and self.Value then
			local index = table.find(values, self.Value)
			if index and index > 8 then
				scroll.CanvasPosition = Vector2.new(0, (index - 1) * (optH + 2))
			end
		end
	end, function()
		self._open = false
		tween(self._chev, quick(), { Rotation = 0 })
		bindTween(self._stroke, "Color", "line")
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
			TextSize = 10,
			TextColor3 = tok.tx3,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextTruncate = Enum.TextTruncate.None,
		}, parent)
		corner(self._modeLabel, 4)
		stroke(self._modeLabel, "line")
		pad(self._modeLabel, 0, 6, 0, 6)
	end

	local chip = button({
		LayoutOrder = 5,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 20),
		BackgroundColor3 = tok.el,
		BackgroundTransparency = 0,
		TextSize = 11,
		FontFace = F_MONO,
		TextColor3 = tok.tx2,
		Text = keyLabel(self.Value),
	}, parent)
	corner(chip, 5)
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
	if S.mobile then
		chip.Visible = false
	end
end

function Container:AddKeybind(flag, options)
	flag, options = args(flag, options)
	local row = frame({ Size = UDim2.new(1, 0, 0, 26) }, self._body)
	list(row, true, 8, nil, Enum.VerticalAlignment.Center)
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
		Library.Options[flag] = kb
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
		if not over(self._chip, pointer(input)) then
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
				TextSize = 12,
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
	local inputH = rowHeight(28, 32)
	local alpha = state.alpha
	local height = 8 + svH + 10 + 10 + (alpha and 20 or 0) + 10 + inputH + 8

	return win:_popup(anchor, W, height, function(panel)
		pad(panel, 8, 8, 8, 8)
		local sv = button({
			Size = UDim2.new(1, 0, 0, svH),
			BackgroundColor3 = Color3.fromHSV(state.h, 1, 1),
			BackgroundTransparency = 0,
		}, panel)
		corner(sv, 4)
		local white = frame({ Size = UDim2.fromScale(1, 1), BackgroundColor3 = WHITE }, sv)
		corner(white, 4)
		new("UIGradient", { Transparency = NumberSequence.new(0, 1) }, white)
		local black = frame({ Size = UDim2.fromScale(1, 1), BackgroundColor3 = BLACK }, sv)
		corner(black, 4)
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
		corner(hue, 5)
		new("UIGradient", { Color = hueSequence() }, hue)
		local hueHandle = frame({
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(state.h, 0.5),
			Size = UDim2.fromOffset(6, 14),
			BackgroundColor3 = WHITE,
			ZIndex = 2,
		}, hue)
		corner(hueHandle, 3)
		new("UIStroke", { Color = BLACK, Transparency = 0.6, Thickness = 1 }, hueHandle)

		local alphaBar, alphaFill, alphaHandle
		if alpha then
			alphaBar = button({
				Position = UDim2.fromOffset(0, svH + 30),
				Size = UDim2.new(1, 0, 0, 10),
				BackgroundColor3 = tok.el2,
				BackgroundTransparency = 0,
			}, panel)
			corner(alphaBar, 5)
			alphaFill = frame({ Size = UDim2.fromScale(1, 1), BackgroundColor3 = WHITE }, alphaBar)
			corner(alphaFill, 5)
			new("UIGradient", { Transparency = NumberSequence.new(1, 0) }, alphaFill)
			alphaHandle = frame({
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.fromOffset(6, 14),
				BackgroundColor3 = WHITE,
				ZIndex = 2,
			}, alphaBar)
			corner(alphaHandle, 3)
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
			corner(f, 5)
			stroke(f, "line")
			label({
				Position = UDim2.fromOffset(8, 0),
				Size = UDim2.new(0, 28, 1, 0),
				Text = caption,
				TextSize = 11,
				TextColor3 = tok.tx3,
			}, f)
			local tb = new("TextBox", {
				Position = UDim2.fromOffset(caption == "HEX" and 36 or 20, 0),
				Size = UDim2.new(1, caption == "HEX" and -42 or -26, 1, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Text = "",
				TextColor3 = tok.tx,
				TextSize = 12,
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
		TextSize = 11,
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
	corner(sw, 4)
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
	local row = button({ Size = UDim2.new(1, 0, 0, rowHeight(22, 28)) }, self._body)
	list(row, true, 8, nil, Enum.VerticalAlignment.Center)
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
		Library.Options[flag] = cp
		Library.Flags[flag] = cp.Value
	end
	return cp
end

local Accent = class()

function Container:_addAccent(flag)
	local root = frame({ Size = UDim2.new(1, 0, 0, 46) }, self._body)
	local el = self:_add(Accent, "Accent", flag, { Text = "Accent" }, root)
	label({ Size = UDim2.new(1, -80, 0, 16), Text = "Accent", TextSize = 12, TextColor3 = tok.tx2 }, root)
	el._hex = label({
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.fromOffset(80, 16),
		TextXAlignment = Enum.TextXAlignment.Right,
		TextSize = 11,
		FontFace = F_MONO,
		TextColor3 = tok.tx3,
	}, root)
	local row = frame({ Position = UDim2.fromOffset(1, 22), Size = UDim2.new(1, -1, 0, 24) }, root)
	list(row, true, 8, nil, Enum.VerticalAlignment.Center)
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
		corner(wm, 6)
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
			TextSize = 12,
			FontFace = F_SEMI,
			TextTruncate = Enum.TextTruncate.None,
		}, wm)
		local function sep(order)
			frame({ LayoutOrder = order, Size = UDim2.fromOffset(1, 12), BackgroundColor3 = tok.line2 }, wm)
		end
		local function stat(order)
			return label({
				LayoutOrder = order,
				AutomaticSize = Enum.AutomaticSize.X,
				Size = UDim2.fromOffset(0, 16),
				Text = "--",
				TextSize = 11,
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
	if on and not S.wmConn then
		local frames, elapsed = 0, 0.5
		S.wmConn = RunService.Heartbeat:Connect(function(dt)
			frames = frames + 1
			elapsed = elapsed + dt
			if elapsed < 0.5 then
				return
			end
			S.wmFps.Text = math.floor(frames / elapsed + 0.5) .. " FPS"
			local ok, ping = pcall(function()
				return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
			end)
			if not ok then
				ok, ping = pcall(function()
					return LocalPlayer:GetNetworkPing() * 1000
				end)
			end
			S.wmPing.Text = ok and (math.floor(ping + 0.5) .. " ms") or "-- ms"
			S.wmTime.Text = os.date("%H:%M")
			frames, elapsed = 0, 0
		end)
	elseif not on and S.wmConn then
		S.wmConn:Disconnect()
		S.wmConn = nil
	end
	Library:_placeOverlays()
	return self
end

function Library:SetWatermark(text)
	if S.wmTitle then
		S.wmTitle.Text = tostring(text or "")
	end
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
		corner(panel, 8)
		draggable(panel, "kblMoved")
		stroke(panel, "line2")
		list(panel, false, 0)
		local header = frame({ LayoutOrder = 1, Size = UDim2.new(1, 0, 0, 32) }, panel)
		frame({ Position = UDim2.new(0, 0, 1, -1), Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = tok.line }, header)
		local ic = icon("keyboard", header, 14, "accent")
		ic.AnchorPoint = Vector2.new(0, 0.5)
		ic.Position = UDim2.new(0, 10, 0.5, 0)
		label({
			Position = UDim2.fromOffset(32, 0),
			Size = UDim2.new(1, -42, 1, 0),
			Text = "Keybinds",
			TextSize = 12,
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
		list(row, true, 8, nil, Enum.VerticalAlignment.Center)
		local dot = frame({ LayoutOrder = 1, Size = UDim2.fromOffset(6, 6), BackgroundColor3 = active and tok.accent or tok.line2 }, row)
		corner(dot)
		local name = label({
			LayoutOrder = 2,
			Size = UDim2.new(0, 0, 1, 0),
			Text = kb.Text ~= "" and kb.Text or keyLabel(kb.Value),
			TextSize = 12,
			TextColor3 = active and tok.tx or tok.tx2,
		}, row)
		fill(name)
		label({
			LayoutOrder = 3,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.fromOffset(0, 16),
			Text = string.lower(kb.Mode),
			TextSize = 10,
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
	corner(card, 8)
	pad(card, 1, 1, 1, 1)
	local surface = frame({
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = tok.box,
	}, card)
	corner(surface, 7)
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
			TextSize = 12,
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
	corner(card, 10)
	pad(card, 1, 1, 1, 1)
	local body = frame({
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = tok.box,
		Active = true,
	}, card)
	corner(body, 9)
	pad(body, 18, 18, 18, 18)
	list(body, false, 12)

	local badge = frame({ LayoutOrder = 1, Size = UDim2.fromOffset(34, 34), BackgroundColor3 = tok[colorToken] }, body)
	badge.BackgroundTransparency = 0.84
	corner(badge, 8)
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
		TextSize = 15,
		FontFace = F_SEMI,
	}, texts)
	if options.Content and options.Content ~= "" then
		label({
			LayoutOrder = 2,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Text = tostring(options.Content),
			TextWrapped = true,
			TextSize = 12,
			TextColor3 = tok.tx2,
			LineHeight = 1.15,
		}, texts)
	end

	local row = frame({ LayoutOrder = 3, Size = UDim2.new(1, 0, 0, rowHeight(30, 34)) }, body)
	list(row, true, 8, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center)

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
			Size = UDim2.fromOffset(0, rowHeight(30, 34)),
			BackgroundColor3 = tok.el,
			BackgroundTransparency = 0,
			Text = tostring(b.Text or ""),
			TextSize = 13,
			FontFace = variant == "Secondary" and F_REG or F_SEMI,
			TextColor3 = tok.tx,
		}, row)
		corner(btn, 6)
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
	local data = { version = 1, options = {} }
	for flag, el in pairs(Library.Options) do
		if not el._noSave and el._serialize then
			local ok, value = pcall(el._serialize, el)
			if ok and value ~= nil then
				data.options[flag] = { t = el.Type, v = value }
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
	for flag, entry in pairs(data.options) do
		local el = Library.Options[flag]
		if el and el._deserialize and not el._noSave and type(entry) == "table" then
			pcall(el._deserialize, el, entry.v)
		end
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
end

function Window:_buildConfigUI(box)
	if not canSave() then
		box:AddLabel("Your executor does not support saving files.", { Color = "tx3", Size = 12 })
		return
	end

	local selected
	local refresh

	local boxH = rowHeight(30, 34)
	local nameRoot = frame({ Size = UDim2.new(1, 0, 0, 22 + boxH) }, box._body)
	box:_add(Label, "ConfigName", nil, { Text = "Config name" }, nameRoot)
	label({ Size = UDim2.new(1, 0, 0, 16), Text = "Config name", TextSize = 12, TextColor3 = tok.tx2 }, nameRoot)
	local nameRow = frame({ Position = UDim2.fromOffset(0, 22), Size = UDim2.new(1, 0, 0, boxH) }, nameRoot)
	list(nameRow, true, 6)
	local field = frame({ LayoutOrder = 1, Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = tok.el }, nameRow)
	fill(field)
	corner(field, 6)
	local fieldStroke = stroke(field, "line")
	local nameBox = new("TextBox", {
		Position = UDim2.fromOffset(10, 0),
		Size = UDim2.new(1, -20, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = "",
		PlaceholderText = "my-config",
		PlaceholderColor3 = tok.tx3,
		TextColor3 = tok.tx,
		TextSize = 13,
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
		bindTween(fieldStroke, "Color", "line")
		tween(fieldStroke, quick(), { Transparency = 0 })
	end)
	local create = button({
		LayoutOrder = 2,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, boxH),
		BackgroundColor3 = tok.el,
		BackgroundTransparency = 0,
	}, nameRow)
	corner(create, 6)
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
	corner(listFrame, 6)
	stroke(listFrame, "line")
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
				TextSize = 12,
				TextColor3 = tok.tx3,
				TextXAlignment = Enum.TextXAlignment.Center,
			}, listFrame)
			return
		end
		for i, name in ipairs(names) do
			local on = name == selected
			local row = optionRow(listFrame, i, rowHeight(30, 34))
			if on then
				paint(row, "BackgroundColor3", "accent", false)
				row.BackgroundTransparency = 0.84
			end
			list(row, true, 8, nil, Enum.VerticalAlignment.Center)
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
					TextSize = 10,
					TextColor3 = tok.tx2,
					TextTruncate = Enum.TextTruncate.None,
				}, row)
				corner(badge, 4)
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
	table.clear(S.conns)
	table.clear(S.drags)
	table.clear(S.keybinds)
	S.listening = nil
	S.inputStarted = false
	S.wm, S.kbl, S.notifyHolder, S.dialog = nil, nil, nil, nil
	if type(shared) == "table" and shared.EasyLibraryUnload then
		shared.EasyLibraryUnload = nil
	end
end

return Library
