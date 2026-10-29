local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local THEMES = {
	Dark = {
		bg = Color3.fromHex("0C0C0E"),
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
		shadow = Color3.fromHex("000000"),
	},
	Light = {
		bg = Color3.fromHex("F4F4F2"),
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
		shadow = Color3.fromHex("14181F"),
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
}

local DEFAULTS = {
	Title = "EasyLibrary",
	Subtitle = nil,
	Logo = nil,
	Theme = "Dark",
	Accent = Color3.fromHex("7C5CFF"),
	Font = "Ubuntu",
	Mode = "Real",
	Steps = { "Checking environment", "Loading modules", "Building interface", "Applying config" },
	Keybind = Enum.KeyCode.RightShift,
	HintPrefix = "Press",
	HintText = "to show or hide the menu",
	ReadyText = "Ready",
	FailText = "Something went wrong",
	Width = 380,
	ShowSubtitle = true,
	ShowPercent = true,
	ShowSteps = true,
	ShowHint = true,
	Dim = true,
	DimTransparency = 0.45,
	Blur = false,
	BlurSize = 12,
	AutoScale = true,
	Scale = 1,
	Name = "EasyLibrary_Loading",
	Parent = nil,
	DisplayOrder = 1000,
	ReplaceExisting = true,
	AutoProgress = true,
	AutoFinish = true,
	FinishDelay = 0.6,
	Animations = true,
	AnimationSpeed = 1,
	Shimmer = true,
	OnFinished = nil,
	OnFailed = nil,
}

local FAKE_DEFAULTS = {
	AutoStart = true,
	StartDelay = 0.35,
	Duration = nil,
	StepDuration = 1.2,
	Jitter = 0.15,
	Style = "Smooth",
	Seed = nil,
}

local PAD_X, PAD_TOP, PAD_BOTTOM, GAP = 24, 28, 20, 22
local HEADER_H, PROGRESS_H, FOOTER_H = 44, 30, 37
local ROW_H, ROW_GAP, BOX_PAD_Y = 24, 2, 8
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

local function fontFamily(f)
	if typeof(f) == "Font" then
		return f.Family
	elseif typeof(f) == "EnumItem" then
		return Font.fromEnum(f).Family
	end
	return Font.fromEnum(FONTS[f] or Enum.Font.Ubuntu).Family
end

local function keyLabel(k)
	if typeof(k) == "EnumItem" then
		k = k.Name
	end
	return KEY_NAMES[k] or tostring(k)
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

local function normalizeSteps(list)
	local out = {}
	for i, s in ipairs(list or {}) do
		if type(s) == "table" then
			out[i] = {
				name = tostring(s.Name or s[1] or ("Step " .. i)),
				duration = tonumber(s.Duration),
				messages = type(s.Messages) == "table" and #s.Messages > 0 and s.Messages or nil,
				weight = math.max(tonumber(s.Weight) or 1, 0.01),
			}
		else
			out[i] = { name = tostring(s), weight = 1 }
		end
	end
	return out
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

local Loading = {}
Loading.__index = Loading
Loading.Themes = THEMES
Loading.Fonts = FONTS

function Loading.new(options)
	local opts = merge(DEFAULTS, options)
	if opts.Keybind == false then
		opts.ShowHint = false
	end

	local self = setmetatable({}, Loading)
	self._opts = opts
	self._fake = merge(FAKE_DEFAULTS, opts.Fake)
	self._theme = resolveTheme(opts.Theme)
	self._accent = typeof(opts.Accent) == "Color3" and opts.Accent or DEFAULTS.Accent
	self._onAccent = textOn(self._accent)
	self._family = fontFamily(opts.Font)
	self._monoFamily = Font.fromEnum(Enum.Font.RobotoMono).Family
	self._animate = opts.Animations ~= false
	self._speed = math.max(tonumber(opts.AnimationSpeed) or 1, 0.05)
	self._width = math.max(tonumber(opts.Width) or 380, 260)
	self._rng = Random.new(opts.Fake and opts.Fake.Seed or nil)

	self._themed = {}
	self._fonted = {}
	self._conns = {}
	self._loops = {}
	self._shadows = {}
	self._steps = {}
	self._current = 0
	self._progress = 0
	self._failed = false
	self._finished = false
	self._destroyed = false
	self._running = false

	self._pop = self:_info(0.42, Style.Back, Direction.Out)
	self._quick = self:_info(0.22, Style.Quad, Direction.Out)
	self._ease = self:_info(0.3, Style.Quint, Direction.Out)

	self.Finished = Signal.new()
	self.Failed = Signal.new()
	if type(opts.OnFinished) == "function" then
		self.Finished:Connect(opts.OnFinished)
	end
	if type(opts.OnFailed) == "function" then
		self.Failed:Connect(opts.OnFailed)
	end

	self:_build(normalizeSteps(opts.Steps))
	self:_open()

	if string.lower(tostring(opts.Mode)) == "fake" and self._fake.AutoStart ~= false then
		self:Start()
	end
	return self
end

function Loading:_info(time, style, direction, repeatCount, reverses, delay)
	return TweenInfo.new(
		time / (self._speed or 1),
		style or Style.Quint,
		direction or Direction.Out,
		repeatCount or 0,
		reverses or false,
		(delay or 0) / (self._speed or 1)
	)
end

function Loading:_tween(inst, info, goal)
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

function Loading:_loop(inst, info, goal)
	if not self._animate then
		return nil
	end
	local t = TweenService:Create(inst, info, goal)
	self._loops[#self._loops + 1] = t
	return t
end

function Loading:_new(class, props, parent)
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

function Loading:_frame(props, parent)
	props.BorderSizePixel = 0
	return self:_new("Frame", props, parent)
end

function Loading:_label(props, parent)
	props.BackgroundTransparency = 1
	props.BorderSizePixel = 0
	props.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
	props.TextYAlignment = props.TextYAlignment or Enum.TextYAlignment.Center
	return self:_new("TextLabel", props, parent)
end

function Loading:_corner(parent, radius)
	return self:_new("UICorner", { CornerRadius = radius or UDim.new(0.5, 0) }, parent)
end

function Loading:_record(inst, prop, token)
	local map = self._themed[inst]
	if not map then
		map = {}
		self._themed[inst] = map
	end
	map[prop] = token
end

function Loading:_bind(inst, prop, token)
	self:_record(inst, prop, token)
	inst[prop] = self:_color(token)
end

function Loading:_bindTween(inst, prop, token, info)
	self:_record(inst, prop, token)
	self:_tween(inst, info or self._quick, { [prop] = self:_color(token) })
end

function Loading:_color(token)
	if token == "accent" then
		return self._accent
	elseif token == "onAccent" then
		return self._onAccent
	end
	return self._theme[token] or THEMES.Dark[token]
end

function Loading:_fontFor(spec)
	return Font.new(spec.mono and self._monoFamily or self._family, Enum.FontWeight[spec.__font])
end

function Loading:_build(steps)
	local opts = self._opts
	local width = self._width
	local n = #steps
	local showSteps = opts.ShowSteps ~= false and n > 0
	local stepsH = BOX_PAD_Y * 2 + n * ROW_H + math.max(n - 1, 0) * ROW_GAP

	local height = PAD_TOP + HEADER_H + GAP + PROGRESS_H + PAD_BOTTOM
	if showSteps then
		height = height + GAP + stepsH
	end
	if opts.ShowHint then
		height = height + GAP + FOOTER_H
	end
	self._height = height

	local parent = opts.Parent or Players.LocalPlayer:WaitForChild("PlayerGui")
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
		}, gui)
	end

	local holder = self:_frame({
		Name = "Holder",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(0, 0),
		BackgroundTransparency = 1,
	}, gui)
	self._fitScale = self:_new("UIScale", {}, holder)

	local stack = self:_frame({
		Name = "Stack",
		Size = UDim2.fromOffset(0, 0),
		BackgroundTransparency = 1,
	}, holder)
	self._stack = stack

	local shadowSpecs = { { 22, 16, 0.88 }, { 10, 8, 0.8 } }
	for i, spec in ipairs(shadowSpecs) do
		local shadow = self:_frame({
			Name = "Shadow" .. i,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(0, spec[2]),
			Size = UDim2.fromOffset(width + spec[1], height + spec[1]),
			BackgroundColor3 = tok.shadow,
			BackgroundTransparency = 1,
		}, stack)
		self:_corner(shadow, UDim.new(0, 12 + math.floor(spec[1] / 2)))
		self._shadows[i] = { frame = shadow, alpha = spec[3] }
	end

	local card = self:_new("CanvasGroup", {
		Name = "Card",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(0, 0),
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
	}, card)
	self:_corner(surface, UDim.new(0, 11))
	self:_new("UIPadding", {
		PaddingTop = UDim.new(0, PAD_TOP - 1),
		PaddingBottom = UDim.new(0, PAD_BOTTOM - 1),
		PaddingLeft = UDim.new(0, PAD_X - 1),
		PaddingRight = UDim.new(0, PAD_X - 1),
	}, surface)
	self:_new("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, GAP),
	}, surface)

	self:_buildHeader(surface)
	self:_buildProgress(surface)
	self:_buildSteps(surface, steps, stepsH, showSteps)
	if opts.ShowHint then
		self:_buildHint(surface)
	end

	self:SetTitle(opts.Title)
	self:SetSubtitle(opts.ShowSubtitle ~= false and opts.Subtitle or nil)
	self:SetLogo(opts.Logo)

	if opts.Blur then
		self._blur = self:_new("BlurEffect", { Name = opts.Name .. "_Blur", Size = 0 }, Lighting)
	end

	gui.Parent = parent
	self:_bindViewport()
end

function Loading:_buildHeader(surface)
	local header = self:_frame({
		Name = "Header",
		LayoutOrder = 1,
		Size = UDim2.new(1, 0, 0, HEADER_H),
		BackgroundTransparency = 1,
	}, surface)

	local logo = self:_frame({
		Name = "Logo",
		Size = UDim2.fromOffset(44, 44),
		BackgroundColor3 = tok.accent,
	}, header)
	self:_corner(logo, UDim.new(0, 11))
	self._logo = logo
	self._logoScale = self:_new("UIScale", { Scale = self._animate and 0.82 or 1 }, logo)
	self._logoLetter = self:_label({
		Name = "Letter",
		Size = UDim2.fromScale(1, 1),
		Text = "",
		TextSize = 22,
		FontFace = F_BOLD,
		TextColor3 = tok.onAccent,
		TextXAlignment = Enum.TextXAlignment.Center,
	}, logo)
	self._logoImage = self:_new("ImageLabel", {
		Name = "Image",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ScaleType = Enum.ScaleType.Fit,
		Visible = false,
	}, logo)
	self:_corner(self._logoImage, UDim.new(0, 11))

	self._title = self:_label({
		Name = "Title",
		Position = UDim2.fromOffset(58, 3),
		Size = UDim2.new(1, -58, 0, 22),
		TextSize = 18,
		FontFace = F_SEMI,
		TextColor3 = tok.tx,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, header)
	self._subtitle = self:_label({
		Name = "Subtitle",
		Position = UDim2.fromOffset(58, 26),
		Size = UDim2.new(1, -58, 0, 15),
		TextSize = 12,
		FontFace = F_REG,
		TextColor3 = tok.tx3,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, header)
end

function Loading:_buildProgress(surface)
	local showPercent = self._opts.ShowPercent ~= false
	local progress = self:_frame({
		Name = "Progress",
		LayoutOrder = 2,
		Size = UDim2.new(1, 0, 0, PROGRESS_H),
		BackgroundTransparency = 1,
	}, surface)

	self._status = self:_label({
		Name = "Status",
		Size = showPercent and UDim2.new(1, -56, 0, 16) or UDim2.new(1, 0, 0, 16),
		Text = "",
		TextSize = 12,
		FontFace = F_REG,
		TextColor3 = tok.tx2,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, progress)

	self._percent = self:_label({
		Name = "Percent",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.fromOffset(52, 16),
		Text = "0%",
		TextSize = 11,
		FontFace = F_MONO,
		TextColor3 = tok.tx2,
		TextXAlignment = Enum.TextXAlignment.Right,
		Visible = showPercent,
	}, progress)

	local track = self:_frame({
		Name = "Track",
		Position = UDim2.fromOffset(0, 24),
		Size = UDim2.new(1, 0, 0, 6),
		BackgroundColor3 = tok.el2,
		ClipsDescendants = true,
	}, progress)
	self:_corner(track, UDim.new(0, 3))

	self._fill = self:_frame({
		Name = "Fill",
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = tok.accent,
	}, track)
	self:_corner(self._fill, UDim.new(0, 3))

	if self._opts.Shimmer ~= false and self._animate then
		local shimmer = self:_new("UIGradient", {
			Offset = Vector2.new(-1, 0),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.22),
				NumberSequenceKeypoint.new(0.38, 0.22),
				NumberSequenceKeypoint.new(0.5, 0),
				NumberSequenceKeypoint.new(0.62, 0.22),
				NumberSequenceKeypoint.new(1, 0.22),
			}),
		}, self._fill)
		self._shimmer = shimmer
		self._shimmerTween = self:_loop(shimmer, self:_info(1.5, Style.Sine, Direction.InOut, -1, false, 0.35), { Offset = Vector2.new(1, 0) })
	end

	self._value = Instance.new("NumberValue")
	self._conns[#self._conns + 1] = self._value.Changed:Connect(function(v)
		self._fill.Size = UDim2.fromScale(v, 1)
		self._percent.Text = math.floor(v * 100 + 0.5) .. "%"
	end)
end

function Loading:_buildSteps(surface, steps, stepsH, visible)
	local box = self:_frame({
		Name = "Steps",
		LayoutOrder = 3,
		Size = UDim2.new(1, 0, 0, stepsH),
		BackgroundColor3 = tok.box,
		Visible = visible,
	}, surface)
	self:_corner(box, UDim.new(0, 8))
	self:_new("UIStroke", { Color = tok.line, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, box)
	self:_new("UIPadding", {
		PaddingTop = UDim.new(0, BOX_PAD_Y),
		PaddingBottom = UDim.new(0, BOX_PAD_Y),
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
	}, box)
	self:_new("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, ROW_GAP),
	}, box)

	local animate = self._animate
	for i, data in ipairs(steps) do
		local row = self:_frame({
			Name = "Step" .. i,
			LayoutOrder = i,
			Size = UDim2.new(1, 0, 0, ROW_H),
			BackgroundTransparency = 1,
		}, box)
		local content = self:_frame({
			Name = "Content",
			Position = UDim2.fromOffset(animate and -10 or 0, 0),
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
		}, row)
		local icon = self:_frame({
			Name = "Icon",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.fromOffset(14, 14),
			BackgroundTransparency = 1,
		}, content)
		local iconScale = self:_new("UIScale", { Scale = animate and 0.5 or 1 }, icon)

		local done = self:_frame({ Name = "Done", Size = UDim2.fromScale(1, 1), BackgroundColor3 = tok.accent, Visible = false }, icon)
		self:_corner(done)
		local doneScale = self:_new("UIScale", {}, done)
		local legs = { { 5, 8, 5, 45 }, { 8, 7, 8, -50 } }
		for _, leg in ipairs(legs) do
			local bar = self:_frame({
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromOffset(leg[1], leg[2]),
				Size = UDim2.fromOffset(leg[3], 2),
				Rotation = leg[4],
				BackgroundColor3 = tok.onAccent,
			}, done)
			self:_corner(bar, UDim.new(0, 1))
		end

		local todo = self:_frame({
			Name = "Todo",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(6, 6),
			BackgroundColor3 = tok.line2,
		}, icon)
		self:_corner(todo)

		local fail = self:_frame({ Name = "Fail", Size = UDim2.fromScale(1, 1), BackgroundColor3 = tok.danger, Visible = false }, icon)
		self:_corner(fail)
		local failScale = self:_new("UIScale", {}, fail)
		self:_label({
			Size = UDim2.fromScale(1, 1),
			Text = "!",
			TextSize = 11,
			FontFace = F_BOLD,
			TextColor3 = WHITE,
			TextXAlignment = Enum.TextXAlignment.Center,
		}, fail)

		local label = self:_label({
			Name = "Label",
			Position = UDim2.fromOffset(24, 0),
			Size = UDim2.new(1, -24, 1, 0),
			Text = data.name,
			TextSize = 12,
			FontFace = F_REG,
			TextColor3 = tok.tx3,
			TextTransparency = animate and 1 or 0,
			TextTruncate = Enum.TextTruncate.AtEnd,
		}, content)

		data.content = content
		data.icon = icon
		data.iconScale = iconScale
		data.done = done
		data.doneScale = doneScale
		data.todo = todo
		data.fail = fail
		data.failScale = failScale
		data.label = label
		data.state = "todo"
		self._steps[i] = data
	end

	local spinner = self:_frame({
		Name = "Spinner",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(11, 11),
		BackgroundTransparency = 1,
		Visible = false,
	})
	self:_corner(spinner)
	self:_new("UIStroke", { Color = tok.el2, Thickness = 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, spinner)
	local arc = self:_frame({ Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1 }, spinner)
	self:_corner(arc)
	local arcStroke = self:_new("UIStroke", { Color = tok.accent, Thickness = 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, arc)
	local arcGradient = self:_new("UIGradient", {
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.32, 0),
			NumberSequenceKeypoint.new(0.62, 1),
			NumberSequenceKeypoint.new(1, 1),
		}),
	}, arcStroke)
	self._spinner = spinner
	self._spinnerScale = self:_new("UIScale", {}, spinner)
	self._spinTween = self:_loop(arcGradient, self:_info(0.75, Style.Linear, Direction.InOut, -1), { Rotation = 360 })
end

function Loading:_buildHint(surface)
	local opts = self._opts
	local footer = self:_frame({
		Name = "Footer",
		LayoutOrder = 4,
		Size = UDim2.new(1, 0, 0, FOOTER_H),
		BackgroundTransparency = 1,
	}, surface)
	self:_frame({ Name = "Divider", Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = tok.line }, footer)

	local hint = self:_frame({
		Name = "Hint",
		Position = UDim2.fromOffset(0, 15),
		Size = UDim2.new(1, 0, 0, 22),
		BackgroundTransparency = 1,
	}, footer)
	self:_new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 6),
	}, hint)

	self:_label({
		LayoutOrder = 1,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromScale(0, 1),
		Text = tostring(opts.HintPrefix or ""),
		TextSize = 11,
		FontFace = F_REG,
		TextColor3 = tok.tx3,
		Visible = opts.HintPrefix ~= nil and opts.HintPrefix ~= "",
	}, hint)

	local key = self:_new("TextLabel", {
		LayoutOrder = 2,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 20),
		BackgroundColor3 = tok.el,
		BorderSizePixel = 0,
		Text = keyLabel(opts.Keybind),
		TextSize = 11,
		FontFace = F_MONO,
		TextColor3 = tok.tx2,
	}, hint)
	self:_corner(key, UDim.new(0, 5))
	self:_new("UIStroke", { Color = tok.line2, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, key)
	self:_new("UIPadding", { PaddingLeft = UDim.new(0, 7), PaddingRight = UDim.new(0, 7) }, key)

	self:_label({
		LayoutOrder = 3,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromScale(0, 1),
		Text = tostring(opts.HintText or ""),
		TextSize = 11,
		FontFace = F_REG,
		TextColor3 = tok.tx3,
		Visible = opts.HintText ~= nil and opts.HintText ~= "",
	}, hint)
end

function Loading:_bindViewport()
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
		local s = math.min(1, (size.X - 32) / self._width, (size.Y - 32) / self._height)
		self._fitScale.Scale = math.clamp(s, 0.5, 1) * scale
	end
	fit()
	local camera = Workspace.CurrentCamera
	if camera then
		self._conns[#self._conns + 1] = camera:GetPropertyChangedSignal("ViewportSize"):Connect(fit)
	end
end

function Loading:_open()
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
	for _, sh in ipairs(self._shadows) do
		self:_tween(sh.frame, self:_info(0.5, Style.Quad, Direction.Out, 0, false, 0.05), { BackgroundTransparency = sh.alpha })
	end
	self:_tween(self._logoScale, self:_info(0.55, Style.Back, Direction.Out, 0, false, 0.06), { Scale = 1 })

	for i, st in ipairs(self._steps) do
		local delay = 0.16 + (i - 1) * 0.05
		self:_tween(st.content, self:_info(0.5, Style.Quint, Direction.Out, 0, false, delay), { Position = UDim2.fromOffset(0, 0) })
		self:_tween(st.label, self:_info(0.35, Style.Quad, Direction.Out, 0, false, delay), { TextTransparency = 0 })
		self:_tween(st.iconScale, self:_info(0.45, Style.Back, Direction.Out, 0, false, delay), { Scale = 1 })
	end

	if self._shimmerTween then
		self._shimmerTween:Play()
	end
end

function Loading:_close()
	local info = self:_info(0.28, Style.Quad, Direction.In)
	self:_tween(self._stack, info, { Position = UDim2.fromOffset(0, -12) })
	self:_tween(self._card, info, { GroupTransparency = 1 })
	for _, sh in ipairs(self._shadows) do
		self:_tween(sh.frame, info, { BackgroundTransparency = 1 })
	end
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

function Loading:_shake()
	if not self._animate then
		return
	end
	task.spawn(function()
		local offsets = { 7, -6, 4, -3, 1, 0 }
		local step = 0.045 / self._speed
		for _, x in ipairs(offsets) do
			if self._destroyed then
				return
			end
			TweenService:Create(self._stack, TweenInfo.new(step, Style.Quad, Direction.Out), { Position = UDim2.fromOffset(x, 0) }):Play()
			task.wait(step)
		end
	end)
end

function Loading:_stopLoops()
	for _, t in ipairs(self._loops) do
		t:Cancel()
	end
	if self._shimmer then
		self._shimmer.Enabled = false
	end
end

function Loading:_indexOf(name)
	for i, st in ipairs(self._steps) do
		if st.name == name then
			return i
		end
	end
	return nil
end

function Loading:_setState(st, state)
	if st.state == state then
		return
	end
	st.state = state
	st.done.Visible = state == "done"
	st.todo.Visible = state == "todo"
	st.fail.Visible = state == "fail"

	if state == "done" and self._animate then
		st.doneScale.Scale = 0.35
		self:_tween(st.doneScale, self._pop, { Scale = 1 })
	elseif state == "fail" and self._animate then
		st.failScale.Scale = 0.35
		self:_tween(st.failScale, self._pop, { Scale = 1 })
	end

	local spinner = self._spinner
	if state == "now" then
		spinner.Parent = st.icon
		spinner.Visible = true
		if self._animate then
			self._spinnerScale.Scale = 0.4
			self:_tween(self._spinnerScale, self._pop, { Scale = 1 })
		end
		if self._spinTween then
			self._spinTween:Play()
		end
	elseif spinner.Parent == st.icon then
		spinner.Visible = false
		if self._spinTween then
			self._spinTween:Cancel()
		end
	end

	local token = "tx3"
	if state == "done" then
		token = "tx2"
	elseif state == "now" then
		token = "tx"
	elseif state == "fail" then
		token = "danger"
	end
	self:_bindTween(st.label, "TextColor3", token)
end

function Loading:_tweenProgress(alpha, time, style)
	if self._destroyed then
		return
	end
	alpha = math.clamp(tonumber(alpha) or 0, 0, 1)
	self._progress = alpha
	if self._progressTween then
		self._progressTween:Cancel()
		self._progressTween = nil
	end
	if not time or time <= 0 or not self._animate then
		self._value.Value = alpha
		return
	end
	self._progressTween = TweenService:Create(self._value, TweenInfo.new(time, style or Style.Quint, Direction.Out), { Value = alpha })
	self._progressTween:Play()
end

function Loading:_alive()
	return not (self._destroyed or self._finished or self._failed)
end

function Loading:_fakeDuration(st, totalWeight)
	local fake = self._fake
	local d = st.duration
	if not d and tonumber(fake.Duration) then
		d = tonumber(fake.Duration) * st.weight / totalWeight
	end
	d = d or tonumber(fake.StepDuration) or 1.2
	local jitter = math.clamp(tonumber(fake.Jitter) or 0, 0, 0.9)
	if jitter > 0 then
		d = d * (1 + self._rng:NextNumber(-jitter, jitter))
	end
	return math.max(d, 0.05)
end

function Loading:_runFake()
	local fake = self._fake
	local stepped = string.lower(tostring(fake.Style)) == "stepped"
	local n = #self._steps
	local totalWeight = 0
	for _, st in ipairs(self._steps) do
		totalWeight = totalWeight + st.weight
	end

	task.wait(math.max(tonumber(fake.StartDelay) or 0, 0))

	for i, st in ipairs(self._steps) do
		if not self:_alive() then
			return
		end
		self:SetStep(i)

		local duration = self:_fakeDuration(st, totalWeight)
		local messages = st.messages
		local count = messages and #messages or 1
		if stepped then
			count = math.max(count, self._rng:NextInteger(3, 5))
		end

		local weights, sum = {}, 0
		for s = 1, count do
			local w = stepped and self._rng:NextNumber(0.5, 1.5) or 1
			weights[s] = w
			sum = sum + w
		end

		local from = (i - 1) / n
		local acc = 0
		for s = 1, count do
			if not self:_alive() then
				return
			end
			if messages then
				self:SetStatus(messages[math.floor((s - 1) / count * #messages) + 1])
			end
			acc = acc + weights[s]
			local target = from + (acc / sum) / n
			local segment = duration * weights[s] / sum
			if stepped then
				task.wait(segment * 0.65)
				if not self:_alive() then
					return
				end
				self:_tweenProgress(target, 0.2, Style.Quad)
				task.wait(segment * 0.35)
			else
				self:_tweenProgress(target, segment, Style.Linear)
				task.wait(segment)
			end
		end
	end

	if self:_alive() and self._opts.AutoFinish ~= false then
		self:Finish()
	end
end

function Loading:SetTitle(text)
	if self._destroyed then
		return self
	end
	text = tostring(text or "")
	self._title.Text = text
	if not self._logoImage.Visible then
		self._logoLetter.Text = string.upper(string.sub(text, 1, 1))
	end
	return self
end

function Loading:SetSubtitle(text)
	if self._destroyed then
		return self
	end
	local has = text ~= nil and text ~= ""
	self._subtitle.Visible = has
	self._subtitle.Text = has and tostring(text) or ""
	self._title.Position = UDim2.fromOffset(58, has and 3 or 11)
	return self
end

function Loading:SetLogo(image)
	if self._destroyed then
		return self
	end
	local has = image ~= nil and image ~= ""
	self._logoImage.Visible = has
	self._logoImage.Image = has and tostring(image) or ""
	self._logoLetter.Visible = not has
	self._logo.BackgroundTransparency = has and 1 or 0
	if not has then
		self._logoLetter.Text = string.upper(string.sub(self._title.Text, 1, 1))
	end
	return self
end

function Loading:SetStatus(text)
	if self._destroyed then
		return self
	end
	self._status.Text = tostring(text or "")
	if not self._failed then
		self:_bind(self._status, "TextColor3", "tx2")
	end
	return self
end

function Loading:SetProgress(alpha, instant)
	self:_tweenProgress(alpha, (not instant) and (0.3 / self._speed) or 0, Style.Quint)
	return self
end

function Loading:GetProgress()
	return self._progress
end

function Loading:SetStep(index)
	if not self:_alive() then
		return self
	end
	if type(index) == "string" then
		index = self:_indexOf(index)
	end
	local n = #self._steps
	if n == 0 or not index then
		return self
	end
	index = math.clamp(math.floor(index), 1, n)
	self._current = index

	for i, st in ipairs(self._steps) do
		local state = "todo"
		if i < index then
			state = "done"
		elseif i == index then
			state = "now"
		end
		self:_setState(st, state)
	end
	self:SetStatus(self._steps[index].name .. "...")

	if self._opts.AutoProgress ~= false then
		local target = (index - 1) / n
		if target > self._progress then
			self:SetProgress(target)
		end
	end
	return self
end

function Loading:Next()
	return self:SetStep(self._current + 1)
end

function Loading:Start()
	if self._running or not self:_alive() then
		return self
	end
	self._running = true
	task.spawn(function()
		self:_runFake()
		self._running = false
	end)
	return self
end

function Loading:Run(jobs)
	if not self:_alive() then
		return false, "inactive"
	end
	self._running = true
	jobs = jobs or {}
	local n = #self._steps

	for i = 1, n do
		local job = jobs[i]
		local fn = nil
		if type(job) == "function" then
			fn = job
		elseif type(job) == "table" then
			fn = job.Callback or job[2]
		end

		self:SetStep(i)
		if type(fn) == "function" then
			local function sub(alpha)
				if self:_alive() then
					self:SetProgress(((i - 1) + math.clamp(tonumber(alpha) or 0, 0, 1)) / n)
				end
			end
			local ok, err = pcall(fn, sub, self)
			if not ok then
				self._running = false
				self:Fail(tostring(err))
				return false, err
			end
		end
		if not self:_alive() then
			self._running = false
			return false, "inactive"
		end
		self:SetProgress(i / n)
	end

	self._running = false
	if self._opts.AutoFinish ~= false then
		self:Finish()
	end
	return true
end

function Loading:Fail(message)
	if self._destroyed or self._finished or self._failed then
		return self
	end
	self._failed = true
	self:_stopLoops()

	local st = self._steps[self._current]
	if st then
		self:_setState(st, "fail")
	end
	if self._spinner then
		self._spinner.Visible = false
	end

	self._status.Text = tostring(message or self._opts.FailText)
	self:_bindTween(self._status, "TextColor3", "danger")
	self:_bindTween(self._fill, "BackgroundColor3", "danger")
	self:_bindTween(self._percent, "TextColor3", "danger")
	self:_shake()
	self.Failed:Fire(self._status.Text)
	return self
end

function Loading:Finish(noYield)
	if self._destroyed or self._finished then
		return
	end
	self._finished = true
	self:_stopLoops()

	for _, st in ipairs(self._steps) do
		self:_setState(st, "done")
	end
	self._status.Text = tostring(self._opts.ReadyText or "")
	self:_bindTween(self._status, "TextColor3", "tx")
	self:_tweenProgress(1, 0.3 / self._speed, Style.Quint)

	local function close()
		task.wait(math.max(tonumber(self._opts.FinishDelay) or 0, 0))
		if self._destroyed then
			return
		end
		self:_close()
		self:Destroy()
		self.Finished:Fire()
	end

	if noYield then
		task.spawn(close)
	else
		close()
	end
end

function Loading:Wait()
	if self._destroyed then
		return
	end
	self.Finished:Wait()
end

function Loading:SetTheme(theme)
	if self._destroyed then
		return self
	end
	self._theme = resolveTheme(theme)
	self:_applyColors()
	return self
end

function Loading:SetAccent(color)
	if self._destroyed or typeof(color) ~= "Color3" then
		return self
	end
	self._accent = color
	self._onAccent = textOn(color)
	self:_applyColors()
	return self
end

function Loading:SetFont(font)
	if self._destroyed then
		return self
	end
	self._family = fontFamily(font)
	for inst, spec in pairs(self._fonted) do
		inst.FontFace = self:_fontFor(spec)
	end
	return self
end

function Loading:_applyColors()
	for inst, map in pairs(self._themed) do
		for prop, token in pairs(map) do
			inst[prop] = self:_color(token)
		end
	end
end

function Loading:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true

	if self._progressTween then
		self._progressTween:Cancel()
	end
	self:_stopLoops()
	for _, conn in ipairs(self._conns) do
		conn:Disconnect()
	end
	if self._blur then
		self._blur:Destroy()
	end
	if self._value then
		self._value:Destroy()
	end
	if self._spinner then
		self._spinner:Destroy()
	end
	if self._gui then
		self._gui:Destroy()
	end

	table.clear(self._conns)
	table.clear(self._loops)
	table.clear(self._themed)
	table.clear(self._fonted)
end

return Loading
