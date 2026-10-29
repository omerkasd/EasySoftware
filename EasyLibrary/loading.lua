--[[
	EasyLibrary · loading.lua
	Standalone loading screen.

	local Loading = loadstring(game:HttpGet("https://raw.githubusercontent.com/<USER>/EasySoftware/main/EasyLibrary/loading.lua"))()

	local loader = Loading.new({
		Title = "EasyLibrary",
		Subtitle = "My Script",
		Logo = "rbxassetid://0000000000",   -- optional, a 512x512 icon works best
		Theme = "Dark",                      -- "Dark" | "Light" | custom theme table
		Accent = Color3.fromHex("7C5CFF"),
		Font = "Ubuntu",                     -- name, Enum.Font or Font
		Steps = { "Checking environment", "Loading modules", "Building interface", "Applying config" },
		Keybind = Enum.KeyCode.RightShift,   -- false hides the hint
	})

	-- Option A: run one function per step; each gets a sub-progress callback.
	loader:Run({
		function(progress) ... end,
		function(progress) for i = 1, 10 do progress(i / 10) end end,
		function() ... end,
		function() ... end,
	})

	-- Option B: drive it by hand.
	loader:SetStep(1)
	loader:SetProgress(0.1)
	loader:Finish()   -- marks everything done, fades out, destroys itself
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

--------------------------------------------------------------------------------
-- Constants
--------------------------------------------------------------------------------

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
	RightShift = "RShift", LeftShift = "LShift",
	RightControl = "RCtrl", LeftControl = "LCtrl",
	RightAlt = "RAlt", LeftAlt = "LAlt",
	Insert = "Ins", Delete = "Del", PageUp = "PgUp", PageDown = "PgDn",
}

local DEFAULT_STEPS = { "Checking environment", "Loading modules", "Building interface", "Applying config" }
local DEFAULT_ACCENT = Color3.fromHex("7C5CFF")
local DARK_TEXT = Color3.fromHex("111113")

local WIDTH = 380
local PAD_X, PAD_TOP, PAD_BOTTOM, GAP = 24, 28, 20, 22
local HEADER_H, PROGRESS_H, FOOTER_H = 44, 30, 37
local ROW_H, ROW_GAP, BOX_PAD_Y = 24, 2, 8

local EASE = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local OPEN = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local CLOSE = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local SPIN = TweenInfo.new(0.8, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1)

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------

-- Theme tokens: `tok.box` marks a property as themed so it can be recolored later.
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
local F_REG, F_MED, F_SEMI, F_BOLD = fontSpec("Regular"), fontSpec("Medium"), fontSpec("SemiBold"), fontSpec("Bold")
local F_MONO = fontSpec("Regular", true)

local function luminance(c)
	local function ch(v)
		return v <= 0.03928 and v / 12.92 or ((v + 0.055) / 1.055) ^ 2.4
	end
	return 0.2126 * ch(c.R) + 0.7152 * ch(c.G) + 0.0722 * ch(c.B)
end

local DARK_TEXT_LUM = luminance(DARK_TEXT)

-- Picks dark or white text, whichever reads better on the accent.
local function textOn(c)
	local l = luminance(c)
	local vsWhite = 1.05 / (l + 0.05)
	local vsDark = (l + 0.05) / (DARK_TEXT_LUM + 0.05)
	return vsDark >= vsWhite and DARK_TEXT or Color3.new(1, 1, 1)
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

-- Minimal signal so callers can wait on completion without an extra Instance.
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

--------------------------------------------------------------------------------
-- Loading
--------------------------------------------------------------------------------

local Loading = {}
Loading.__index = Loading
Loading.Themes = THEMES
Loading.Fonts = FONTS

function Loading.new(options)
	options = options or {}

	local self = setmetatable({}, Loading)
	self._opts = options
	self._theme = (type(options.Theme) == "table" and options.Theme) or THEMES[options.Theme or "Dark"] or THEMES.Dark
	self._accent = options.Accent or DEFAULT_ACCENT
	self._onAccent = textOn(self._accent)
	self._family = fontFamily(options.Font or "Ubuntu")
	self._monoFamily = Font.fromEnum(Enum.Font.RobotoMono).Family

	self._themed = {}   -- [Instance] = { [property] = token }
	self._fonted = {}   -- [Instance] = fontSpec
	self._conns = {}
	self._fades = {}    -- { instance, property, visibleValue }
	self._steps = {}
	self._current = 0
	self._progress = 0
	self._failed = false
	self._finished = false
	self._destroyed = false

	self.Finished = Signal.new()

	self:_build(options.Steps or DEFAULT_STEPS)
	self:_open()
	return self
end

-- Instance factory: resolves theme tokens and font specs, parents last.
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

function Loading:_bind(inst, prop, token)
	local map = self._themed[inst]
	if not map then
		map = {}
		self._themed[inst] = map
	end
	map[prop] = token
	inst[prop] = self:_color(token)
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

function Loading:_fade(inst, prop, visible)
	self._fades[#self._fades + 1] = { inst, prop, visible }
end

function Loading:_build(steps)
	local opts = self._opts
	local n = #steps
	local hasFooter = opts.Keybind ~= false
	local stepsH = BOX_PAD_Y * 2 + n * ROW_H + math.max(n - 1, 0) * ROW_GAP
	local height = PAD_TOP + HEADER_H + GAP + PROGRESS_H + GAP + stepsH
		+ (hasFooter and (GAP + FOOTER_H) or 0) + PAD_BOTTOM
	self._height = height

	local name = opts.Name or "EasyLibrary_Loading"
	local parent = opts.Parent or Players.LocalPlayer:WaitForChild("PlayerGui")
	if opts.ReplaceExisting ~= false then
		local old = parent:FindFirstChild(name)
		if old then
			old:Destroy()
		end
	end

	-- The whole tree is built unparented and attached once at the end.
	local gui = self:_new("ScreenGui", {
		Name = name,
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = opts.DisplayOrder or 1000,
	})
	self._gui = gui

	if opts.Dim ~= false then
		local dim = self:_frame({
			Name = "Dim",
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 1,
		}, gui)
		self:_fade(dim, "BackgroundTransparency", opts.DimTransparency or 0.45)
	end

	local holder = self:_frame({
		Name = "Holder",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(0, 0),
		BackgroundTransparency = 1,
	}, gui)
	self._fitScale = self:_new("UIScale", {}, holder)

	-- Two soft layers stand in for a drop shadow (no image asset needed).
	for i, spec in ipairs({ { 18, 14, 0.86 }, { 8, 8, 0.78 } }) do
		local grow, offsetY, alpha = spec[1], spec[2], spec[3]
		local shadow = self:_frame({
			Name = "Shadow" .. i,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(0, offsetY),
			Size = UDim2.fromOffset(WIDTH + grow, height + grow),
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 1,
		}, holder)
		self:_corner(shadow, UDim.new(0, 12 + grow / 2))
		self:_fade(shadow, "BackgroundTransparency", alpha)
	end

	-- CanvasGroup gives one clean fade for the whole card. Its background is the
	-- 1px border; the surface is inset by 1px on top of it.
	local card = self:_new("CanvasGroup", {
		Name = "Card",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.fromOffset(WIDTH, height),
		BackgroundColor3 = tok.line2,
		BorderSizePixel = 0,
		GroupTransparency = 1,
	}, holder)
	self:_corner(card, UDim.new(0, 12))
	self._card = card
	self._cardScale = self:_new("UIScale", { Scale = 0.96 }, card)
	self:_fade(card, "GroupTransparency", 0)

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

	-- Header ------------------------------------------------------------------
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

	-- Progress ----------------------------------------------------------------
	local progress = self:_frame({
		Name = "Progress",
		LayoutOrder = 2,
		Size = UDim2.new(1, 0, 0, PROGRESS_H),
		BackgroundTransparency = 1,
	}, surface)
	self._status = self:_label({
		Name = "Status",
		Size = UDim2.new(1, -56, 0, 16),
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

	-- One NumberValue drives both the bar and the percentage text, so a single
	-- tween animates everything and nothing runs while progress is idle.
	self._value = Instance.new("NumberValue")
	self._conns[#self._conns + 1] = self._value.Changed:Connect(function(v)
		self._fill.Size = UDim2.fromScale(v, 1)
		self._percent.Text = math.floor(v * 100 + 0.5) .. "%"
	end)

	-- Steps -------------------------------------------------------------------
	local box = self:_frame({
		Name = "Steps",
		LayoutOrder = 3,
		Size = UDim2.new(1, 0, 0, stepsH),
		BackgroundColor3 = tok.box,
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

	for i, text in ipairs(steps) do
		local row = self:_frame({
			Name = "Step" .. i,
			LayoutOrder = i,
			Size = UDim2.new(1, 0, 0, ROW_H),
			BackgroundTransparency = 1,
		}, box)
		local icon = self:_frame({
			Name = "Icon",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.fromOffset(14, 14),
			BackgroundTransparency = 1,
		}, row)

		local done = self:_frame({ Name = "Done", Size = UDim2.fromScale(1, 1), BackgroundColor3 = tok.accent, Visible = false }, icon)
		self:_corner(done)
		-- Check mark from two rotated bars (no font glyph or image needed).
		for _, leg in ipairs({ { 5, 8, 5, 45 }, { 8, 7, 8, -50 } }) do
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
		self:_label({
			Size = UDim2.fromScale(1, 1),
			Text = "!",
			TextSize = 11,
			FontFace = F_BOLD,
			TextColor3 = Color3.new(1, 1, 1),
			TextXAlignment = Enum.TextXAlignment.Center,
		}, fail)

		local label = self:_label({
			Name = "Label",
			Position = UDim2.fromOffset(24, 0),
			Size = UDim2.new(1, -24, 1, 0),
			Text = tostring(text),
			TextSize = 12,
			FontFace = F_REG,
			TextColor3 = tok.tx3,
			TextTruncate = Enum.TextTruncate.AtEnd,
		}, row)

		self._steps[i] = { name = tostring(text), icon = icon, done = done, todo = todo, fail = fail, label = label, state = "todo" }
	end

	-- A single spinner is moved to whichever step is active, so only one
	-- engine-side tween ever runs.
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
	local gradient = self:_new("UIGradient", {
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.499, 0),
			NumberSequenceKeypoint.new(0.5, 1),
			NumberSequenceKeypoint.new(1, 1),
		}),
	}, arcStroke)
	self._spinner = spinner
	self._spinTween = TweenService:Create(gradient, SPIN, { Rotation = 360 })

	-- Footer ------------------------------------------------------------------
	if hasFooter then
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
			Text = opts.HintPrefix or "Press",
			TextSize = 11,
			FontFace = F_REG,
			TextColor3 = tok.tx3,
		}, hint)
		local key = self:_new("TextLabel", {
			LayoutOrder = 2,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.fromOffset(0, 20),
			BackgroundColor3 = tok.el,
			BorderSizePixel = 0,
			Text = keyLabel(opts.Keybind or Enum.KeyCode.RightShift),
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
			Text = opts.HintText or "to show or hide the menu",
			TextSize = 11,
			FontFace = F_REG,
			TextColor3 = tok.tx3,
		}, hint)
	end

	self:SetTitle(opts.Title or "EasyLibrary")
	self:SetSubtitle(opts.Subtitle)
	self:SetLogo(opts.Logo)

	if opts.Blur then
		self._blur = self:_new("BlurEffect", { Name = name .. "_Blur", Size = 0 }, Lighting)
		self:_fade(self._blur, "Size", opts.BlurSize or 12)
	end

	gui.Parent = parent

	if opts.AutoScale ~= false then
		local function fit()
			local camera = Workspace.CurrentCamera
			if not camera then
				return
			end
			local vs = camera.ViewportSize
			local s = math.min(1, (vs.X - 32) / WIDTH, (vs.Y - 32) / height)
			self._fitScale.Scale = math.clamp(s, 0.5, 1) * (opts.Scale or 1)
		end
		fit()
		local camera = Workspace.CurrentCamera
		if camera then
			self._conns[#self._conns + 1] = camera:GetPropertyChangedSignal("ViewportSize"):Connect(fit)
		end
	else
		self._fitScale.Scale = opts.Scale or 1
	end
end

function Loading:_open()
	for _, f in ipairs(self._fades) do
		TweenService:Create(f[1], OPEN, { [f[2]] = f[3] }):Play()
	end
	TweenService:Create(self._cardScale, OPEN, { Scale = 1 }):Play()
end

function Loading:_close()
	for _, f in ipairs(self._fades) do
		local hidden = f[2] == "Size" and 0 or 1
		TweenService:Create(f[1], CLOSE, { [f[2]] = hidden }):Play()
	end
	TweenService:Create(self._cardScale, CLOSE, { Scale = 0.96 }):Play()
	task.wait(CLOSE.Time)
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

	local spinner = self._spinner
	if state == "now" then
		spinner.Parent = st.icon
		spinner.Visible = true
		self._spinTween:Play()
	elseif spinner.Parent == st.icon then
		spinner.Visible = false
		self._spinTween:Cancel()
	end

	local color = (state == "done" and "tx2") or (state == "now" and "tx") or (state == "fail" and "danger") or "tx3"
	self:_bind(st.label, "TextColor3", color)
end

--------------------------------------------------------------------------------
-- Public API (every setter returns self, so calls can be chained)
--------------------------------------------------------------------------------

function Loading:SetTitle(text)
	if self._destroyed then return self end
	text = tostring(text or "")
	self._title.Text = text
	if not self._logoImage.Visible then
		self._logoLetter.Text = string.upper(string.sub(text, 1, 1))
	end
	return self
end

function Loading:SetSubtitle(text)
	if self._destroyed then return self end
	local has = text ~= nil and text ~= ""
	self._subtitle.Visible = has
	self._subtitle.Text = has and tostring(text) or ""
	self._title.Position = UDim2.fromOffset(58, has and 3 or 11)
	return self
end

function Loading:SetLogo(image)
	if self._destroyed then return self end
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
	if self._destroyed then return self end
	self._status.Text = tostring(text or "")
	if not self._failed then
		self:_bind(self._status, "TextColor3", "tx2")
	end
	return self
end

function Loading:SetProgress(alpha, instant)
	if self._destroyed then return self end
	alpha = math.clamp(tonumber(alpha) or 0, 0, 1)
	self._progress = alpha
	if self._progressTween then
		self._progressTween:Cancel()
		self._progressTween = nil
	end
	if instant then
		self._value.Value = alpha
	else
		self._progressTween = TweenService:Create(self._value, EASE, { Value = alpha })
		self._progressTween:Play()
	end
	return self
end

function Loading:GetProgress()
	return self._progress
end

function Loading:SetStep(index)
	if self._destroyed or self._finished then return self end
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
		self:_setState(st, (i < index and "done") or (i == index and "now") or "todo")
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

-- Runs one job per step. A job is a function, or { "Name", function } / { Callback = function }.
-- Each job receives (progress, loader): call progress(0..1) for progress inside that step.
function Loading:Run(jobs)
	if self._destroyed then
		return false, "destroyed"
	end
	jobs = jobs or {}
	local n = #self._steps

	for i = 1, n do
		local job = jobs[i]
		local fn = (type(job) == "function" and job) or (type(job) == "table" and (job.Callback or job[2])) or nil

		self:SetStep(i)
		if fn then
			local function sub(alpha)
				if self._destroyed then return end
				self:SetProgress(((i - 1) + math.clamp(tonumber(alpha) or 0, 0, 1)) / n)
			end
			local ok, err = pcall(fn, sub, self)
			if not ok then
				self:Fail(tostring(err))
				return false, err
			end
		end
		if self._destroyed then
			return false, "destroyed"
		end
		self:SetProgress(i / n)
	end

	if self._opts.AutoFinish ~= false then
		self:Finish()
	end
	return true
end

function Loading:Fail(message)
	if self._destroyed then return self end
	self._failed = true
	local st = self._steps[self._current]
	if st then
		self:_setState(st, "fail")
	end
	self._status.Text = tostring(message or "Something went wrong")
	self:_bind(self._status, "TextColor3", "danger")
	self:_bind(self._fill, "BackgroundColor3", "danger")
	self:_bind(self._percent, "TextColor3", "danger")
	return self
end

-- Marks everything done, shows the ready state, fades out and destroys.
-- Yields until it is gone unless noYield is true.
function Loading:Finish(noYield)
	if self._destroyed or self._finished then return end
	self._finished = true

	for _, st in ipairs(self._steps) do
		self:_setState(st, "done")
	end
	self._status.Text = self._opts.ReadyText or "Ready"
	self:SetProgress(1)

	local function close()
		task.wait(self._opts.FinishDelay or 0.6)
		if self._destroyed then return end
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

function Loading:SetTheme(theme)
	if self._destroyed then return self end
	local t = (type(theme) == "table" and theme) or THEMES[theme]
	if not t then return self end
	self._theme = t
	self:_applyColors()
	return self
end

function Loading:SetAccent(color)
	if self._destroyed or typeof(color) ~= "Color3" then return self end
	self._accent = color
	self._onAccent = textOn(color)
	self:_applyColors()
	return self
end

function Loading:SetFont(font)
	if self._destroyed then return self end
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
	if self._destroyed then return end
	self._destroyed = true

	if self._progressTween then self._progressTween:Cancel() end
	if self._spinTween then self._spinTween:Cancel() end
	for _, conn in ipairs(self._conns) do
		conn:Disconnect()
	end
	if self._blur then self._blur:Destroy() end
	if self._value then self._value:Destroy() end
	if self._spinner then self._spinner:Destroy() end
	if self._gui then self._gui:Destroy() end

	table.clear(self._conns)
	table.clear(self._themed)
	table.clear(self._fonted)
	table.clear(self._fades)
end

return Loading
