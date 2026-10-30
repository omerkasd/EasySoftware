local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

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
	return Players.LocalPlayer:WaitForChild("PlayerGui")
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
		danger = Color3.fromHex("FF6B6B"),
		ok = Color3.fromHex("3DCB7A"),
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
		danger = Color3.fromHex("C93439"),
		ok = Color3.fromHex("1F9D57"),
	},
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

local TEXTS = {
	Note = "Keys last 24 hours",
	Label = "Key",
	Placeholder = "XXXX-XXXX-XXXX",
	Paste = "Paste",
	Idle = nil,
	IdleCaseInsensitive = "Keys are not case-sensitive.",
	IdleCaseSensitive = "Keys are case-sensitive.",
	Empty = "Enter a key first.",
	Checking = "Checking key...",
	Invalid = "Invalid or expired key.",
	Valid = "Key accepted. Loading {title}...",
	Error = "Could not verify the key. Try again.",
	SavedInvalid = "Your saved key has expired. Get a new one.",
	Locked = "Too many attempts. Try again in {time}s.",
	Attempts = "{n} tries left",
	Verify = "Verify Key",
	Verifying = "Checking",
	Divider = "no key yet?",
	CopyLink = "Copy Key Link",
	LinkCopied = "Link copied",
	Discord = "Join Discord",
	DiscordCopied = "Invite copied",
	CopyFallback = "Copy this link: {link}",
}

local DEFAULTS = {
	Title = "EasyLibrary",
	Subtitle = nil,
	Logo = nil,
	Theme = "Dark",
	Accent = Color3.fromHex("7C5CFF"),
	Font = "Ubuntu",
	KeyLink = nil,
	Discord = nil,
	Validate = nil,
	Keys = nil,
	CaseSensitive = false,
	MaxAttempts = 5,
	LockoutTime = 30,
	MinCheckTime = 0.45,
	SaveKey = true,
	FileName = "EasyLibrary/key.txt",
	AutoLoadSaved = true,
	ShowCloseButton = true,
	Draggable = true,
	AutoFocus = false,
	Texts = nil,
	Dim = true,
	DimTransparency = 0.45,
	Blur = false,
	BlurSize = 12,
	AutoScale = true,
	Scale = 1,
	Name = "EasyLibrary_Key",
	Parent = nil,
	DisplayOrder = 2147482999,
	ReplaceExisting = true,
	SuccessDelay = 1.2,
	Animations = true,
	AnimationSpeed = 1,
	OnSuccess = nil,
	OnFail = nil,
	OnClose = nil,
}

local FORM_W = 416
local DARK_TEXT = Color3.fromHex("111113")
local WHITE = Color3.new(1, 1, 1)

local Style = Enum.EasingStyle
local Direction = Enum.EasingDirection

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
local F_SEMI = fontSpec("SemiBold")
local F_BOLD = fontSpec("Bold")
local F_MONO = fontSpec("Regular", true)

local api = {
	isfile = typeof(isfile) == "function" and isfile or nil,
	readfile = typeof(readfile) == "function" and readfile or nil,
	writefile = typeof(writefile) == "function" and writefile or nil,
	delfile = typeof(delfile) == "function" and delfile or nil,
	isfolder = typeof(isfolder) == "function" and isfolder or nil,
	makefolder = typeof(makefolder) == "function" and makefolder or nil,
	setclipboard = (typeof(setclipboard) == "function" and setclipboard) or (typeof(toclipboard) == "function" and toclipboard) or nil,
	getclipboard = typeof(getclipboard) == "function" and getclipboard or nil,
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

local function fontFamily(f)
	if typeof(f) == "Font" then
		return f.Family
	elseif typeof(f) == "EnumItem" then
		return Font.fromEnum(f).Family
	end
	return Font.fromEnum(FONTS[f] or Enum.Font.Ubuntu).Family
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

local function resolveTheme(theme)
	if type(theme) == "table" then
		return merge(THEMES[theme.Base or "Dark"] or THEMES.Dark, theme)
	end
	return THEMES[theme] or THEMES.Dark
end

local function fmt(s, vars)
	return (string.gsub(tostring(s or ""), "{(%w+)}", function(k)
		local v = vars[k]
		if v == nil then
			return "{" .. k .. "}"
		end
		return tostring(v)
	end))
end

local function trim(s)
	return (string.gsub(string.gsub(tostring(s or ""), "^%s+", ""), "%s+$", ""))
end

local Signal = {}
Signal.__index = Signal

function Signal.new()
	return setmetatable({ _fns = {}, _threads = {} }, Signal)
end

function Signal:Connect(fn)
	local fns = self._fns
	fns[#fns + 1] = fn
	return {
		Disconnect = function()
			local i = table.find(fns, fn)
			if i then
				table.remove(fns, i)
			end
		end,
	}
end

function Signal:Once(fn)
	local conn
	conn = self:Connect(function(...)
		conn.Disconnect()
		fn(...)
	end)
	return conn
end

function Signal:Wait()
	self._threads[#self._threads + 1] = coroutine.running()
	return coroutine.yield()
end

function Signal:Fire(...)
	for _, fn in ipairs(table.clone(self._fns)) do
		task.spawn(fn, ...)
	end
	local threads = self._threads
	self._threads = {}
	for _, th in ipairs(threads) do
		task.spawn(th, ...)
	end
end

local KeyUI = {}
KeyUI.__index = KeyUI
KeyUI.Themes = THEMES
KeyUI.Fonts = FONTS

function KeyUI.new(options)
	local opts = merge(DEFAULTS, options)
	local self = setmetatable({}, KeyUI)
	self._opts = opts
	self._texts = merge(TEXTS, opts.Texts)
	self._theme = resolveTheme(opts.Theme)
	self._accent = typeof(opts.Accent) == "Color3" and opts.Accent or DEFAULTS.Accent
	self._onAccent = textOn(self._accent)
	self._family = fontFamily(opts.Font)
	self._monoFamily = Font.fromEnum(Enum.Font.RobotoMono).Family
	self._animate = opts.Animations ~= false
	self._speed = math.max(tonumber(opts.AnimationSpeed) or 1, 0.05)
	self._canSave = opts.SaveKey ~= false and api.writefile ~= nil and api.readfile ~= nil and api.isfile ~= nil

	self._themed = {}
	self._fonted = {}
	self._conns = {}
	self._loops = {}
	self._brandLabels = {}
	self._state = "idle"
	self._attempts = 0
	self._destroyed = false
	self._done = false
	self._result = nil

	self._pop = self:_info(0.42, Style.Back, Direction.Out)
	self._quick = self:_info(0.18, Style.Quad, Direction.Out)

	self.Succeeded = Signal.new()
	self.Failed = Signal.new()
	self.Closed = Signal.new()
	self.Done = Signal.new()
	if type(opts.OnSuccess) == "function" then
		self.Succeeded:Connect(opts.OnSuccess)
	end
	if type(opts.OnFail) == "function" then
		self.Failed:Connect(opts.OnFail)
	end
	if type(opts.OnClose) == "function" then
		self.Closed:Connect(opts.OnClose)
	end

	self:_build()
	self:_setStatus("idle")
	self:_open()

	local saved = self:_readSaved()
	if saved and opts.AutoLoadSaved ~= false then
		self._box.Text = saved
		task.delay(0.35 / self._speed, function()
			if not self._destroyed then
				self:Verify(saved, true)
			end
		end)
	elseif opts.AutoFocus then
		self._box:CaptureFocus()
	end
	return self
end

function KeyUI:_info(time, style, direction, repeatCount, reverses, delay)
	return TweenInfo.new(
		time / self._speed,
		style or Style.Quint,
		direction or Direction.Out,
		repeatCount or 0,
		reverses or false,
		(delay or 0) / self._speed
	)
end

function KeyUI:_tween(inst, info, goal)
	if not self._animate then
		for k, v in pairs(goal) do
			inst[k] = v
		end
		return nil
	end
	local t = TweenService:Create(inst, info, goal)
	t:Play()
	return t
end

function KeyUI:_loop(inst, info, goal)
	if not self._animate then
		return nil
	end
	local t = TweenService:Create(inst, info, goal)
	self._loops[#self._loops + 1] = t
	return t
end

function KeyUI:_connect(signal, fn)
	local c = signal:Connect(fn)
	self._conns[#self._conns + 1] = c
	return c
end

function KeyUI:_new(class, props, parent)
	local inst = Instance.new(class)
	for k, v in pairs(props) do
		if type(v) == "table" and v.__tok then
			self:_bind(inst, k, v.__tok)
		elseif type(v) == "table" and v.__font then
			self._fonted[inst] = v
			inst[k] = self:_fontFor(v)
		else
			inst[k] = v
		end
	end
	if parent then
		inst.Parent = parent
	end
	return inst
end

function KeyUI:_frame(props, parent)
	props.BorderSizePixel = 0
	return self:_new("Frame", props, parent)
end

function KeyUI:_label(props, parent)
	props.BackgroundTransparency = 1
	props.BorderSizePixel = 0
	props.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
	props.TextYAlignment = props.TextYAlignment or Enum.TextYAlignment.Center
	return self:_new("TextLabel", props, parent)
end

function KeyUI:_button(props, parent)
	props.BorderSizePixel = 0
	props.AutoButtonColor = false
	props.Text = ""
	return self:_new("TextButton", props, parent)
end

function KeyUI:_corner(parent, radius)
	return self:_new("UICorner", { CornerRadius = radius or UDim.new(0.5, 0) }, parent)
end

function KeyUI:_stroke(parent, token, thickness)
	return self:_new("UIStroke", {
		Color = tok[token],
		Thickness = thickness or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, parent)
end

function KeyUI:_record(inst, prop, token)
	local map = self._themed[inst]
	if not map then
		map = {}
		self._themed[inst] = map
	end
	map[prop] = token
end

function KeyUI:_bind(inst, prop, token)
	self:_record(inst, prop, token)
	inst[prop] = self:_color(token)
end

function KeyUI:_bindTween(inst, prop, token, info)
	self:_record(inst, prop, token)
	self:_tween(inst, info or self._quick, { [prop] = self:_color(token) })
end

function KeyUI:_color(token)
	if token == "accent" then
		return self._accent
	elseif token == "accentHover" then
		return self._accent:Lerp(WHITE, 0.12)
	elseif token == "onAccent" then
		return self._onAccent
	end
	return self._theme[token] or THEMES.Dark[token]
end

function KeyUI:_fontFor(spec)
	return Font.new(spec.mono and self._monoFamily or self._family, Enum.FontWeight[spec.__font])
end

function KeyUI:_iconBox(size, position, anchor, parent)
	return self:_frame({
		Size = UDim2.fromOffset(size, size),
		Position = position,
		AnchorPoint = anchor or Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
	}, parent)
end

function KeyUI:_bar(parent, x, y, w, h, rotation, color)
	local f = self:_frame({
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(x, y),
		Size = UDim2.fromOffset(w, h),
		Rotation = rotation or 0,
		BackgroundColor3 = tok[color],
	}, parent)
	self:_corner(f, UDim.new(0, math.max(math.floor(math.min(w, h) / 2), 1)))
	return f
end

function KeyUI:_ring(parent, x, y, w, h, thickness, color, radius)
	local f = self:_frame({
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(x, y),
		Size = UDim2.fromOffset(w, h),
		BackgroundTransparency = 1,
	}, parent)
	self:_corner(f, radius)
	self:_stroke(f, color, thickness)
	return f
end

function KeyUI:_iconCross(parent, length, color)
	self:_bar(parent, 7, 7, length, 2, 45, color)
	self:_bar(parent, 7, 7, length, 2, -45, color)
end

function KeyUI:_iconCheck(parent, color)
	self:_bar(parent, 5, 8, 5, 2, 45, color)
	self:_bar(parent, 8, 7, 8, 2, -50, color)
end

function KeyUI:_iconKey(parent, color)
	parent.Rotation = -45
	self:_ring(parent, 4, 7, 6, 6, 2, color)
	self:_bar(parent, 10, 7, 8, 2, 0, color)
	self:_bar(parent, 12, 9, 2, 3, 0, color)
end

function KeyUI:_iconLink(parent, color)
	parent.Rotation = -45
	self:_ring(parent, 4, 7, 8, 5, 1.5, color)
	self:_ring(parent, 10, 7, 8, 5, 1.5, color)
end

function KeyUI:_iconDiscord(parent, color, hole)
	local body = self:_frame({
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(7, 7),
		Size = UDim2.fromOffset(15, 10),
		BackgroundColor3 = tok[color],
	}, parent)
	self:_corner(body, UDim.new(0, 4))
	self:_bar(parent, 2.5, 11, 4, 4, 0, color)
	self:_bar(parent, 11.5, 11, 4, 4, 0, color)
	local eyes = {}
	for i, x in ipairs({ 4.6, 9.4 }) do
		local eye = self:_frame({
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(x, 7.4),
			Size = UDim2.fromOffset(3, 3.4),
			BackgroundColor3 = tok[hole],
			ZIndex = 2,
		}, parent)
		self:_corner(eye)
		eyes[i] = eye
	end
	return eyes
end

function KeyUI:_iconPaste(parent, color)
	self:_ring(parent, 7, 8, 9, 10, 1.5, color, UDim.new(0, 2))
	self:_bar(parent, 7, 3, 5, 3, 0, color)
end

function KeyUI:_iconClock(parent, color)
	self:_ring(parent, 7, 7, 11, 11, 1.5, color)
	self:_bar(parent, 7, 5, 2, 5, 0, color)
	self:_bar(parent, 9, 8, 4, 2, 30, color)
end

function KeyUI:_spinner(parent, size, track, arcColor, trackTransparency)
	local holder = self:_frame({
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(size, size),
		BackgroundTransparency = 1,
	}, parent)
	self:_corner(holder)
	local trackStroke = self:_stroke(holder, track, 2)
	trackStroke.Transparency = trackTransparency or 0
	local arc = self:_frame({ Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1 }, holder)
	self:_corner(arc)
	local gradient = self:_new("UIGradient", {
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.32, 0),
			NumberSequenceKeypoint.new(0.62, 1),
			NumberSequenceKeypoint.new(1, 1),
		}),
	}, self:_stroke(arc, arcColor, 2))
	return holder, self:_loop(gradient, self:_info(0.75, Style.Linear, Direction.InOut, -1), { Rotation = 360 })
end

function KeyUI:_press(button)
	local scale = self:_new("UIScale", {}, button)
	self:_connect(button.MouseButton1Down, function()
		self:_tween(scale, self._quick, { Scale = 0.97 })
	end)
	local function release()
		self:_tween(scale, self._quick, { Scale = 1 })
	end
	self:_connect(button.MouseButton1Up, release)
	self:_connect(button.MouseLeave, release)
	return scale
end

function KeyUI:_hover(button, onHover)
	self:_connect(button.MouseEnter, function()
		onHover(true)
	end)
	self:_connect(button.MouseLeave, function()
		onHover(false)
	end)
end

function KeyUI:_build()
	local opts = self._opts
	local texts = self._texts
	local hasLink = opts.KeyLink ~= nil and opts.KeyLink ~= ""
	local hasDiscord = opts.Discord ~= nil and opts.Discord ~= ""
	local hasButtons = hasLink or hasDiscord

	local x0 = 22
	local rw = FORM_W
	local width = x0 + rw + 24
	local innerH = hasButtons and 312 or 236
	local height = innerH + 2
	self._width, self._height = width, height

	local parent = opts.Parent or defaultParent()
	if opts.ReplaceExisting ~= false then
		local old = parent:FindFirstChild(opts.Name)
		if old then
			old:Destroy()
		end
	end

	local gui = self:_new("ScreenGui", {
		Name = opts.Name,
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = opts.DisplayOrder,
	})
	self._gui = gui

	if opts.Dim then
		self._dim = self:_frame({
			Name = "Dim",
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 1,
			Active = true,
		}, gui)
	end

	local holder = self:_frame({
		Name = "Holder",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(0, 0),
		BackgroundTransparency = 1,
	}, gui)
	self._holder = holder
	self._fitScale = self:_new("UIScale", {}, holder)

	local stack = self:_frame({ Name = "Stack", Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 1 }, holder)
	self._stack = stack


	local card = self:_new("CanvasGroup", {
		Name = "Card",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(width, height),
		BackgroundColor3 = tok.line2,
		BorderSizePixel = 0,
		GroupTransparency = 1,
	}, stack)
	self:_corner(card, UDim.new(0, 12))
	self._card = card

	local surface = self:_frame({
		Name = "Surface",
		Position = UDim2.fromOffset(1, 1),
		Size = UDim2.new(1, -2, 1, -2),
		BackgroundColor3 = tok.bg,
		Active = false,
	}, card)
	self:_corner(surface, UDim.new(0, 11))
	self._surface = surface

	self:_buildForm(surface, x0, rw, hasLink, hasDiscord)

	local strip = self:_frame({
		Name = "Strip",
		Position = UDim2.new(0, 0, 1, -3),
		Size = UDim2.new(1, 0, 0, 3),
		BackgroundColor3 = tok.el2,
		Visible = false,
		ZIndex = 5,
	}, card)
	self._strip = strip
	self._stripFill = self:_frame({ Size = UDim2.fromScale(0, 1), BackgroundColor3 = tok.ok, ZIndex = 5 }, strip)

	if opts.Blur then
		self._blur = self:_new("BlurEffect", { Name = opts.Name .. "_Blur", Size = 0 }, Lighting)
	end

	gui.Parent = parent
	self:_bindViewport()
	if opts.Draggable ~= false then
		self:_bindDrag(surface)
	end
end

function KeyUI:_buildLogo(parent, position, size, radius, letterSize)
	local opts = self._opts
	local logo = self:_frame({
		Name = "Logo",
		Position = position,
		Size = UDim2.fromOffset(size, size),
		BackgroundColor3 = tok.accent,
	}, parent)
	self:_corner(logo, UDim.new(0, radius))
	local scale = self:_new("UIScale", { Scale = self._animate and 0.82 or 1 }, logo)
	self._logoScales = self._logoScales or {}
	self._logoScales[#self._logoScales + 1] = scale

	local image = opts.Logo
	if image ~= nil and image ~= "" then
		logo.BackgroundTransparency = 1
		local img = self:_new("ImageLabel", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			ScaleType = Enum.ScaleType.Fit,
			Image = tostring(image),
		}, logo)
		self:_corner(img, UDim.new(0, radius))
	else
		self:_label({
			Size = UDim2.fromScale(1, 1),
			Text = string.upper(string.sub(tostring(opts.Title or ""), 1, 1)),
			TextSize = letterSize,
			FontFace = F_BOLD,
			TextColor3 = tok.onAccent,
			TextXAlignment = Enum.TextXAlignment.Center,
		}, logo)
	end
	return logo
end

function KeyUI:_buildForm(surface, x0, rw, hasLink, hasDiscord)
	local opts = self._opts
	local texts = self._texts
	local hasSubtitle = opts.Subtitle ~= nil and opts.Subtitle ~= ""
	local hidden = self._animate and 1 or 0
	local headX = x0 + 52
	local headW = rw - 52 - (opts.ShowCloseButton ~= false and 30 or 0)

	self:_buildLogo(surface, UDim2.fromOffset(x0, 20), 40, 10, 20)

	self._brandLabels[#self._brandLabels + 1] = self:_label({
		Name = "Title",
		Position = UDim2.fromOffset(headX, hasSubtitle and 21 or 29),
		Size = UDim2.fromOffset(headW, 22),
		Text = tostring(opts.Title or ""),
		TextSize = 17,
		FontFace = F_SEMI,
		TextColor3 = tok.tx,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextTransparency = hidden,
	}, surface)

	if hasSubtitle then
		self._brandLabels[#self._brandLabels + 1] = self:_label({
			Name = "Subtitle",
			Position = UDim2.fromOffset(headX, 43),
			Size = UDim2.fromOffset(headW, 16),
			Text = tostring(opts.Subtitle),
			TextSize = 12,
			FontFace = F_REG,
			TextColor3 = tok.tx3,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextTransparency = hidden,
		}, surface)
	end

	if opts.ShowCloseButton ~= false then
		local close = self:_button({
			Name = "Close",
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -12, 0, 12),
			Size = UDim2.fromOffset(28, 28),
			BackgroundColor3 = tok.el,
			BackgroundTransparency = 1,
		}, surface)
		self:_corner(close, UDim.new(0, 6))
		local icon = self:_iconBox(14, UDim2.fromScale(0.5, 0.5), Vector2.new(0.5, 0.5), close)
		self:_iconCross(icon, 11, "tx3")
		self:_hover(close, function(on)
			self:_tween(close, self._quick, { BackgroundTransparency = on and 0 or 1 })
		end)
		self:_press(close)
		self:_connect(close.Activated, function()
			self:Close()
		end)
	end

	self:_label({
		Name = "KeyLabel",
		Position = UDim2.fromOffset(x0, 78),
		Size = UDim2.fromOffset(rw, 16),
		Text = tostring(texts.Label or ""),
		TextSize = 12,
		FontFace = F_REG,
		TextColor3 = tok.tx2,
	}, surface)

	if texts.Note ~= nil and texts.Note ~= "" then
		local note = self:_frame({
			Name = "Note",
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.fromOffset(x0 + rw, 78),
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.fromOffset(0, 16),
			BackgroundTransparency = 1,
		}, surface)
		self:_new("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 6),
		}, note)
		local clock = self:_iconBox(14, UDim2.new(), Vector2.new(0, 0), note)
		clock.LayoutOrder = 1
		self:_iconClock(clock, "tx3")
		self:_label({
			LayoutOrder = 2,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.fromOffset(0, 16),
			Text = tostring(texts.Note),
			TextSize = 11,
			FontFace = F_REG,
			TextColor3 = tok.tx3,
		}, note)
	end

	self:_buildField(surface, x0, rw)
	self:_buildStatus(surface, x0, rw)
	self:_buildActions(surface, x0, rw)

	if hasLink or hasDiscord then
		local divider = self:_frame({
			Name = "Divider",
			Position = UDim2.fromOffset(x0, 230),
			Size = UDim2.fromOffset(rw, 14),
			BackgroundTransparency = 1,
		}, surface)
		local dividerText = self:_label({
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.fromOffset(0, 14),
			Text = tostring(texts.Divider or ""),
			TextSize = 11,
			FontFace = F_REG,
			TextColor3 = tok.tx3,
			TextXAlignment = Enum.TextXAlignment.Center,
		}, divider)
		local left = self:_frame({ Position = UDim2.fromOffset(0, 7), Size = UDim2.fromOffset(0, 1), BackgroundColor3 = tok.line }, divider)
		local right = self:_frame({
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, 0, 0, 7),
			Size = UDim2.fromOffset(0, 1),
			BackgroundColor3 = tok.line,
		}, divider)
		local function layoutDivider()
			local textWidth = dividerText.TextBounds.X
			local w = math.max(math.floor((rw - textWidth) / 2) - 12, 0)
			left.Size = UDim2.fromOffset(w, 1)
			right.Size = UDim2.fromOffset(w, 1)
		end
		layoutDivider()
		self:_connect(dividerText:GetPropertyChangedSignal("TextBounds"), layoutDivider)

		local both = hasLink and hasDiscord
		local bw = both and math.floor((rw - 8) / 2) or rw
		if hasLink then
			self._linkButton = self:_secondary(surface, UDim2.fromOffset(x0, 256), bw, "link", texts.CopyLink, function()
				self:_copy(opts.KeyLink, "link")
			end)
		end
		if hasDiscord then
			local x = both and (x0 + bw + 8) or x0
			self._discordButton = self:_secondary(surface, UDim2.fromOffset(x, 256), bw, "chat", texts.Discord, function()
				self:_copy(opts.Discord, "discord")
			end)
		end
	end
end

function KeyUI:_buildField(surface, x0, rw)
	local texts = self._texts
	local field = self:_frame({
		Name = "Field",
		Position = UDim2.fromOffset(x0, 100),
		Size = UDim2.fromOffset(rw, 40),
		BackgroundColor3 = tok.el,
	}, surface)
	self:_corner(field, UDim.new(0, 7))
	self._field = field
	self._fieldX = x0
	self._fieldStroke = self:_stroke(field, "line", 1)

	local keyIcon = self:_iconBox(14, UDim2.new(0, 12, 0.5, 0), nil, field)
	self:_iconKey(keyIcon, "tx3")

	local paste = self:_button({
		Name = "Paste",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -5, 0.5, 0),
		Size = UDim2.fromOffset(70, 30),
		BackgroundColor3 = tok.box,
	}, field)
	self:_corner(paste, UDim.new(0, 5))
	self:_stroke(paste, "line2", 1)
	local pasteInner = self:_frame({
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 14),
		BackgroundTransparency = 1,
	}, paste)
	self:_new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 6),
	}, pasteInner)
	local pasteIcon = self:_iconBox(14, UDim2.new(), Vector2.new(0, 0), pasteInner)
	pasteIcon.LayoutOrder = 1
	self:_iconPaste(pasteIcon, "tx2")
	self:_label({
		LayoutOrder = 2,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 14),
		Text = tostring(texts.Paste or ""),
		TextSize = 12,
		FontFace = F_REG,
		TextColor3 = tok.tx2,
	}, pasteInner)
	self:_hover(paste, function(on)
		self:_bindTween(paste, "BackgroundColor3", on and "el2" or "box")
	end)
	self:_press(paste)
	self:_connect(paste.Activated, function()
		self:_paste()
	end)

	local clear = self:_button({
		Name = "Clear",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -79, 0.5, 0),
		Size = UDim2.fromOffset(24, 24),
		BackgroundColor3 = tok.el2,
		BackgroundTransparency = 1,
		Visible = false,
	}, field)
	self:_corner(clear, UDim.new(0, 5))
	local clearIcon = self:_iconBox(14, UDim2.fromScale(0.5, 0.5), Vector2.new(0.5, 0.5), clear)
	self:_iconCross(clearIcon, 9, "tx3")
	self:_hover(clear, function(on)
		self:_tween(clear, self._quick, { BackgroundTransparency = on and 0 or 1 })
	end)
	self:_connect(clear.Activated, function()
		if self._state ~= "checking" and self._state ~= "valid" and self._state ~= "locked" then
			self._box.Text = ""
			self._box:CaptureFocus()
		end
	end)
	self._clear = clear

	local box = self:_new("TextBox", {
		Name = "Input",
		Position = UDim2.fromOffset(34, 0),
		Size = UDim2.new(1, -34 - 110, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClearTextOnFocus = false,
		Text = "",
		PlaceholderText = tostring(texts.Placeholder or ""),
		PlaceholderColor3 = tok.tx3,
		TextColor3 = tok.tx,
		TextSize = 13,
		FontFace = F_MONO,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClipsDescendants = true,
	}, field)
	self._box = box

	self:_connect(box.Focused, function()
		if self._state == "idle" or self._state == "empty" or self._state == "invalid" then
			self:_strokeTo("accent", 0.45)
		end
	end)
	self:_connect(box.FocusLost, function(enter)
		if self._state == "idle" or self._state == "empty" then
			self:_strokeTo("line", 0)
		end
		if enter then
			self:Verify()
		end
	end)
	self:_connect(box:GetPropertyChangedSignal("Text"), function()
		local has = box.Text ~= ""
		if clear.Visible ~= has then
			clear.Visible = has
		end
		if self._state == "invalid" or self._state == "empty" then
			self:_setStatus("idle")
			self:_strokeTo(box:IsFocused() and "accent" or "line", box:IsFocused() and 0.45 or 0)
		end
	end)
end

function KeyUI:_buildStatus(surface, x0, rw)
	local status = self:_frame({
		Name = "Status",
		Position = UDim2.fromOffset(x0, 146),
		Size = UDim2.fromOffset(rw, 18),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
	}, surface)
	local content = self:_frame({ Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1 }, status)
	self._statusContent = content

	local icon = self:_iconBox(14, UDim2.fromScale(0, 0.5), nil, content)
	self._statusIcon = icon

	local spinner, spinTween = self:_spinner(icon, 11, "el2", "accent")
	self._statusSpinner, self._statusSpinTween = spinner, spinTween

	local err = self:_frame({ Size = UDim2.fromScale(1, 1), BackgroundColor3 = tok.danger }, icon)
	self:_corner(err)
	self:_label({
		Size = UDim2.fromScale(1, 1),
		Text = "!",
		TextSize = 11,
		FontFace = F_BOLD,
		TextColor3 = WHITE,
		TextXAlignment = Enum.TextXAlignment.Center,
	}, err)
	self._statusErr = err

	local okIcon = self:_frame({ Size = UDim2.fromScale(1, 1), BackgroundColor3 = tok.ok }, icon)
	self:_corner(okIcon)
	self:_iconCheck(okIcon, "bg")
	self._statusOk = okIcon

	self._iconScale = self:_new("UIScale", {}, icon)

	self._statusText = self:_label({
		Size = UDim2.new(1, -90, 1, 0),
		Text = "",
		TextSize = 12,
		FontFace = F_REG,
		TextColor3 = tok.tx3,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, content)

	self._attemptsText = self:_label({
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.new(0, 90, 1, 0),
		Text = "",
		TextSize = 11,
		FontFace = F_MONO,
		TextColor3 = tok.tx3,
		TextXAlignment = Enum.TextXAlignment.Right,
		Visible = false,
	}, content)
end

function KeyUI:_buildActions(surface, x0, rw)
	local texts = self._texts

	local verify = self:_button({
		Name = "Verify",
		Position = UDim2.fromOffset(x0, 176),
		Size = UDim2.fromOffset(rw, 38),
		BackgroundColor3 = tok.accent,
	}, surface)
	self:_corner(verify, UDim.new(0, 7))
	self._verify = verify

	local inner = self:_frame({
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 16),
		BackgroundTransparency = 1,
	}, verify)
	self:_new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 8),
	}, inner)
	local spinHolder = self:_iconBox(14, UDim2.new(), Vector2.new(0, 0), inner)
	spinHolder.LayoutOrder = 1
	spinHolder.Visible = false
	local spinner, spinTween = self:_spinner(spinHolder, 11, "onAccent", "onAccent", 0.7)
	self._verifySpinner, self._verifySpinHolder, self._verifySpinTween = spinner, spinHolder, spinTween

	self._verifyText = self:_label({
		LayoutOrder = 2,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 16),
		Text = tostring(texts.Verify or ""),
		TextSize = 13,
		FontFace = F_SEMI,
		TextColor3 = tok.onAccent,
	}, inner)

	self:_hover(verify, function(on)
		if self._state == "idle" or self._state == "invalid" or self._state == "empty" then
			self:_bindTween(verify, "BackgroundColor3", on and "accentHover" or "accent")
		end
	end)
	self:_press(verify)
	self:_connect(verify.Activated, function()
		self:Verify()
	end)
end

function KeyUI:_secondary(surface, position, width, iconName, text, onClick)
	local button = self:_button({
		Position = position,
		Size = UDim2.fromOffset(width, 34),
		BackgroundColor3 = tok.el,
	}, surface)
	self:_corner(button, UDim.new(0, 7))
	local stroke = self:_stroke(button, "line2", 1)

	local inner = self:_frame({
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 14),
		BackgroundTransparency = 1,
	}, button)
	self:_new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 7),
	}, inner)

	local iconHolder = self:_iconBox(14, UDim2.new(), Vector2.new(0, 0), inner)
	iconHolder.LayoutOrder = 1
	local normal = self:_iconBox(14, UDim2.fromScale(0.5, 0.5), Vector2.new(0.5, 0.5), iconHolder)
	local holes = nil
	if iconName == "link" then
		self:_iconLink(normal, "tx3")
	else
		holes = self:_iconDiscord(normal, "tx3", "el")
	end
	local done = self:_iconBox(14, UDim2.fromScale(0.5, 0.5), Vector2.new(0.5, 0.5), iconHolder)
	done.Visible = false
	self:_iconCheck(done, "ok")
	local doneScale = self:_new("UIScale", {}, done)

	local label = self:_label({
		LayoutOrder = 2,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 14),
		Text = tostring(text or ""),
		TextSize = 13,
		FontFace = F_REG,
		TextColor3 = tok.tx,
	}, inner)

	self:_hover(button, function(on)
		local token = on and "el2" or "el"
		self:_bindTween(button, "BackgroundColor3", token)
		if holes then
			for _, h in ipairs(holes) do
				self:_bindTween(h, "BackgroundColor3", token)
			end
		end
	end)
	self:_press(button)
	self:_connect(button.Activated, onClick)

	return { button = button, stroke = stroke, normal = normal, done = done, doneScale = doneScale, label = label, text = text }
end

function KeyUI:_bindViewport()
	local opts = self._opts
	local scale = tonumber(opts.Scale) or 1
	if opts.AutoScale == false then
		self._fitScale.Scale = scale
		return
	end
	local function fit()
		local camera = Workspace.CurrentCamera
		if not camera then
			return
		end
		local size = camera.ViewportSize
		local s = math.min(1, (size.X - 24) / self._width, (size.Y - 24) / self._height)
		self._fitScale.Scale = math.clamp(s, 0.45, 1) * scale
	end
	fit()
	local camera = Workspace.CurrentCamera
	if camera then
		self:_connect(camera:GetPropertyChangedSignal("ViewportSize"), fit)
	end
end

function KeyUI:_bindDrag(handle)
	local dragging, startInput, startPos, moveConn = false, nil, nil, nil
	local function stop()
		dragging = false
		if moveConn then
			moveConn:Disconnect()
			moveConn = nil
		end
	end
	self:_connect(handle.InputBegan, function(input)
		local t = input.UserInputType
		if t ~= Enum.UserInputType.MouseButton1 and t ~= Enum.UserInputType.Touch then
			return
		end
		dragging = true
		startInput = input.Position
		startPos = self._holder.Position
		if moveConn then
			moveConn:Disconnect()
		end
		moveConn = UserInputService.InputChanged:Connect(function(change)
			if not dragging then
				return
			end
			local ct = change.UserInputType
			if ct == Enum.UserInputType.MouseMovement or ct == Enum.UserInputType.Touch then
				local d = change.Position - startInput
				self._holder.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
			end
		end)
	end)
	self:_connect(UserInputService.InputEnded, function(input)
		local t = input.UserInputType
		if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
			stop()
		end
	end)
	self._stopDrag = stop
end

function KeyUI:_open()
	local opts = self._opts
	if self._dim then
		self:_tween(self._dim, self:_info(0.4, Style.Quad, Direction.Out), { BackgroundTransparency = opts.DimTransparency })
	end
	if self._blur then
		self:_tween(self._blur, self:_info(0.4, Style.Quad, Direction.Out), { Size = opts.BlurSize })
	end
	if self._animate then
		self._stack.Position = UDim2.fromOffset(0, 16)
	end
	self:_tween(self._stack, self:_info(0.6, Style.Quint, Direction.Out), { Position = UDim2.fromOffset(0, 0) })
	self:_tween(self._card, self:_info(0.35, Style.Quad, Direction.Out), { GroupTransparency = 0 })
	for _, s in ipairs(self._logoScales or {}) do
		self:_tween(s, self:_info(0.55, Style.Back, Direction.Out, 0, false, 0.06), { Scale = 1 })
	end
	for i, label in ipairs(self._brandLabels) do
		self:_tween(label, self:_info(0.4, Style.Quad, Direction.Out, 0, false, 0.14 + (i - 1) * 0.06), { TextTransparency = 0 })
	end
end

function KeyUI:_close(direction)
	if self._stopDrag then
		self._stopDrag()
	end
	local info = self:_info(0.28, Style.Quad, Direction.In)
	self:_tween(self._stack, info, { Position = UDim2.fromOffset(0, direction == "up" and -12 or 12) })
	self:_tween(self._card, info, { GroupTransparency = 1 })
	if self._dim then
		self:_tween(self._dim, self:_info(0.32, Style.Quad, Direction.In), { BackgroundTransparency = 1 })
	end
	if self._blur then
		self:_tween(self._blur, self:_info(0.32, Style.Quad, Direction.In), { Size = 0 })
	end
	if self._animate then
		task.wait(0.32 / self._speed)
	end
end

function KeyUI:_strokeTo(token, transparency)
	self:_record(self._fieldStroke, "Color", token)
	self:_tween(self._fieldStroke, self._quick, { Color = self:_color(token), Transparency = transparency or 0 })
end

function KeyUI:_shakeField()
	if not self._animate then
		return
	end
	local field, x0 = self._field, self._fieldX
	task.spawn(function()
		local step = 0.045 / self._speed
		for _, x in ipairs({ 6, -5, 4, -2, 1, 0 }) do
			if self._destroyed then
				return
			end
			TweenService:Create(field, TweenInfo.new(step, Style.Quad, Direction.Out), { Position = UDim2.fromOffset(x0 + x, 100) }):Play()
			task.wait(step)
		end
	end)
end

function KeyUI:_idleText()
	local texts = self._texts
	if texts.Idle ~= nil then
		return texts.Idle
	end
	if self._opts.CaseSensitive then
		return texts.IdleCaseSensitive
	end
	return texts.IdleCaseInsensitive
end

function KeyUI:_setStatus(state, message)
	local texts = self._texts
	local vars = { title = tostring(self._opts.Title or ""), n = math.max((tonumber(self._opts.MaxAttempts) or 0) - self._attempts, 0), time = self._lockLeft or 0 }
	local changed = self._state ~= state or message ~= self._statusMessage
	self._state = state
	self._statusMessage = message

	local text, token, icon = "", "tx3", nil
	if state == "idle" then
		text = self:_idleText()
	elseif state == "empty" then
		text, token, icon = texts.Empty, "danger", "err"
	elseif state == "checking" then
		text, token, icon = texts.Checking, "tx2", "spin"
	elseif state == "invalid" then
		text, token, icon = message or texts.Invalid, "danger", "err"
	elseif state == "valid" then
		text, token, icon = texts.Valid, "ok", "ok"
	elseif state == "locked" then
		text, token, icon = texts.Locked, "danger", "err"
	elseif state == "info" then
		text, token = message or "", "tx2"
	end

	self._statusText.Text = fmt(text, vars)
	self:_bindTween(self._statusText, "TextColor3", token)

	self._statusSpinner.Visible = icon == "spin"
	self._statusErr.Visible = icon == "err"
	self._statusOk.Visible = icon == "ok"
	self._statusIcon.Visible = icon ~= nil
	self._statusText.Position = UDim2.fromOffset(icon and 21 or 0, 0)
	if self._statusSpinTween then
		if icon == "spin" then
			self._statusSpinTween:Play()
		else
			self._statusSpinTween:Cancel()
		end
	end

	local max = tonumber(self._opts.MaxAttempts) or 0
	local showAttempts = state == "invalid" and max > 0
	self._attemptsText.Visible = showAttempts
	if showAttempts then
		self._attemptsText.Text = fmt(texts.Attempts, vars)
	end

	if changed and self._animate then
		self._statusContent.Position = UDim2.fromOffset(0, 5)
		self._statusText.TextTransparency = 0.6
		self:_tween(self._statusContent, self:_info(0.3, Style.Quint, Direction.Out), { Position = UDim2.fromOffset(0, 0) })
		self:_tween(self._statusText, self:_info(0.22, Style.Quad, Direction.Out), { TextTransparency = 0 })
		if icon and icon ~= "spin" then
			self._iconScale.Scale = 0.4
			self:_tween(self._iconScale, self._pop, { Scale = 1 })
		else
			self._iconScale.Scale = 1
		end
	end

	self:_renderVerify()
end

function KeyUI:_renderVerify()
	local state = self._state
	local busy = state == "checking"
	local blocked = state == "locked" or state == "valid"
	self._verifySpinHolder.Visible = busy
	if self._verifySpinTween then
		if busy then
			self._verifySpinTween:Play()
		else
			self._verifySpinTween:Cancel()
		end
	end
	self._verifyText.Text = tostring(busy and self._texts.Verifying or self._texts.Verify)
	local dim = (busy or blocked) and 0.35 or 0
	self:_tween(self._verify, self._quick, { BackgroundTransparency = dim })
	self:_tween(self._verifyText, self._quick, { TextTransparency = dim })
	if not busy and not blocked then
		self:_bindTween(self._verify, "BackgroundColor3", "accent")
	end
	self._box.TextEditable = not (busy or blocked)
end

function KeyUI:_normalize(key)
	key = trim(key)
	if not self._opts.CaseSensitive then
		key = string.upper(key)
	end
	return key
end

function KeyUI:_check(key)
	local opts = self._opts
	if type(opts.Validate) == "function" then
		return opts.Validate(key)
	end
	if type(opts.Keys) == "table" then
		for _, k in ipairs(opts.Keys) do
			if self:_normalize(k) == key then
				return true
			end
		end
	end
	return false
end

function KeyUI:Verify(key, fromSaved)
	if self._destroyed or self._done then
		return
	end
	local state = self._state
	if state == "checking" or state == "locked" or state == "valid" then
		return
	end

	local raw = key or self._box.Text
	local normalized = self:_normalize(raw)
	if normalized == "" then
		self:_setStatus("empty")
		self:_strokeTo("danger", 0)
		self:_shakeField()
		return
	end

	self._box:ReleaseFocus()
	self:_setStatus("checking")
	self:_strokeTo("line", 0)

	task.spawn(function()
		local started = os.clock()
		local ok, valid, message = pcall(self._check, self, normalized)
		local remaining = (tonumber(self._opts.MinCheckTime) or 0) / self._speed - (os.clock() - started)
		if remaining > 0 then
			task.wait(remaining)
		end
		if self._destroyed or self._done then
			return
		end
		if not ok then
			valid, message = false, self._texts.Error
		end
		if valid == true then
			self:_succeed(trim(raw))
		else
			self:_reject(trim(raw), type(message) == "string" and message or nil, fromSaved)
		end
	end)
end

function KeyUI:_succeed(key)
	self:_setStatus("valid")
	self:_strokeTo("ok", 0)
	self:_writeSaved(key)

	local delay = math.max(tonumber(self._opts.SuccessDelay) or 0, 0)
	self._strip.Visible = true
	self._stripFill.Size = UDim2.fromScale(0, 1)
	if self._animate and delay > 0 then
		TweenService:Create(self._stripFill, TweenInfo.new(delay, Style.Quad, Direction.Out), { Size = UDim2.fromScale(1, 1) }):Play()
	else
		self._stripFill.Size = UDim2.fromScale(1, 1)
	end

	self.Succeeded:Fire(key)
	task.wait(delay)
	if self._destroyed then
		return
	end
	self:_finish(key, "up")
end

function KeyUI:_reject(key, message, fromSaved)
	if fromSaved then
		self:_deleteSaved()
		self:_setStatus("invalid", self._texts.SavedInvalid)
		self._attemptsText.Visible = false
	else
		self._attempts = self._attempts + 1
		self:_setStatus("invalid", message)
	end
	self:_strokeTo("danger", 0)
	self:_shakeField()
	self.Failed:Fire(key, message or self._texts.Invalid)

	local max = tonumber(self._opts.MaxAttempts) or 0
	if not fromSaved and max > 0 and self._attempts >= max then
		self:_lock()
	end
end

function KeyUI:_lock()
	local duration = math.max(math.floor(tonumber(self._opts.LockoutTime) or 0), 0)
	if duration <= 0 then
		self._attempts = 0
		return
	end
	self._lockLeft = duration
	self:_setStatus("locked")
	task.spawn(function()
		while self._lockLeft > 0 do
			task.wait(1)
			if self._destroyed or self._done then
				return
			end
			self._lockLeft = self._lockLeft - 1
			if self._lockLeft > 0 then
				self._statusText.Text = fmt(self._texts.Locked, { time = self._lockLeft })
			end
		end
		self._attempts = 0
		self._lockLeft = nil
		self:_setStatus("idle")
		self:_strokeTo("line", 0)
	end)
end

function KeyUI:_flash(entry, copiedText)
	if not entry then
		return
	end
	entry.normal.Visible = false
	entry.done.Visible = true
	entry.label.Text = tostring(copiedText or entry.text or "")
	self:_record(entry.stroke, "Color", "ok")
	self:_tween(entry.stroke, self._quick, { Color = self:_color("ok") })
	if self._animate then
		entry.doneScale.Scale = 0.4
		self:_tween(entry.doneScale, self._pop, { Scale = 1 })
	end
	entry.token = (entry.token or 0) + 1
	local current = entry.token
	task.delay(1.6, function()
		if self._destroyed or entry.token ~= current then
			return
		end
		entry.normal.Visible = true
		entry.done.Visible = false
		entry.label.Text = tostring(entry.text or "")
		self:_record(entry.stroke, "Color", "line2")
		self:_tween(entry.stroke, self._quick, { Color = self:_color("line2") })
	end)
end

function KeyUI:_copy(text, which)
	text = tostring(text or "")
	local entry = which == "link" and self._linkButton or self._discordButton
	local copied = which == "link" and self._texts.LinkCopied or self._texts.DiscordCopied
	if api.setclipboard and pcall(api.setclipboard, text) then
		self:_flash(entry, copied)
		return
	end
	if self._state ~= "checking" and self._state ~= "valid" and self._state ~= "locked" then
		self:_setStatus("info", fmt(self._texts.CopyFallback, { link = text }))
	end
end

function KeyUI:_paste()
	if self._state == "checking" or self._state == "valid" or self._state == "locked" then
		return
	end
	if api.getclipboard then
		local ok, value = pcall(api.getclipboard)
		if ok and type(value) == "string" and trim(value) ~= "" then
			self._box.Text = trim(value)
			return
		end
	end
	self._box:CaptureFocus()
end

function KeyUI:_folderOf(path)
	return string.match(path, "^(.*)/[^/]*$")
end

function KeyUI:_readSaved()
	if not self._canSave then
		return nil
	end
	local path = tostring(self._opts.FileName)
	local ok, exists = pcall(api.isfile, path)
	if not ok or not exists then
		return nil
	end
	local okRead, content = pcall(api.readfile, path)
	if okRead and type(content) == "string" then
		content = trim(content)
		if content ~= "" then
			return content
		end
	end
	return nil
end

function KeyUI:_writeSaved(key)
	if not self._canSave then
		return
	end
	local path = tostring(self._opts.FileName)
	local folder = self:_folderOf(path)
	if folder and api.isfolder and api.makefolder then
		local ok, exists = pcall(api.isfolder, folder)
		if ok and not exists then
			pcall(api.makefolder, folder)
		end
	end
	pcall(api.writefile, path, key)
end

function KeyUI:_deleteSaved()
	if not self._canSave then
		return
	end
	local path = tostring(self._opts.FileName)
	if api.delfile then
		pcall(api.delfile, path)
	else
		pcall(api.writefile, path, "")
	end
end

function KeyUI:_finish(key, direction)
	if self._done then
		return
	end
	self._done = true
	self._result = key
	self:_close(direction)
	self:Destroy()
	if key == nil then
		self.Closed:Fire()
	end
	self.Done:Fire(key)
end

function KeyUI:Close()
	if self._destroyed or self._done or self._state == "valid" then
		return
	end
	task.spawn(function()
		self:_finish(nil, "down")
	end)
end

function KeyUI:Wait()
	if self._done then
		return self._result
	end
	return self.Done:Wait()
end

function KeyUI:ClearSavedKey()
	self:_deleteSaved()
	return self
end

function KeyUI:SetTheme(theme)
	if self._destroyed then
		return self
	end
	self._theme = resolveTheme(theme)
	self:_applyColors()
	return self
end

function KeyUI:SetAccent(color)
	if self._destroyed or typeof(color) ~= "Color3" then
		return self
	end
	self._accent = color
	self._onAccent = textOn(color)
	self:_applyColors()
	return self
end

function KeyUI:SetFont(font)
	if self._destroyed then
		return self
	end
	self._family = fontFamily(font)
	for inst, spec in pairs(self._fonted) do
		inst.FontFace = self:_fontFor(spec)
	end
	return self
end

function KeyUI:_applyColors()
	for inst, map in pairs(self._themed) do
		for prop, token in pairs(map) do
			inst[prop] = self:_color(token)
		end
	end
end

function KeyUI:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true
	if self._stopDrag then
		self._stopDrag()
	end
	for _, t in ipairs(self._loops) do
		t:Cancel()
	end
	for _, c in ipairs(self._conns) do
		c:Disconnect()
	end
	if self._blur then
		self._blur:Destroy()
	end
	if self._gui then
		self._gui:Destroy()
	end
	table.clear(self._conns)
	table.clear(self._loops)
	table.clear(self._themed)
	table.clear(self._fonted)
	if not self._done then
		self._done = true
		self.Done:Fire(nil)
	end
end

return KeyUI
