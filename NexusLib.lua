--!strict
--[[
	Nexus / NexusLib Unified Engine
	Lucian UX/UI Prompt #040 (Collapsible Rail) + #041 (Notched Bottom Tab Bar)
	100% Compatible with Nexus_noguard_legit_test.lua & Nexus Hub ecosystem.
	MIT License (c) 2026 Seokwoooo & Ngmankhoi
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LucianUI = {
	_windows = {},
}
LucianUI.__index = LucianUI

-- ==============================================================================
-- DESIGN TOKENS (Lucian UX/UI Light & Dark Themes)
-- ==============================================================================
LucianUI.Tokens = {
	Light = {
		Page = Color3.fromRGB(244, 242, 238),           -- #F4F2EE
		Surface = Color3.fromRGB(255, 255, 255),        -- #FFFFFF
		Surface2 = Color3.fromRGB(245, 243, 239),       -- #F5F3EF
		Surface3 = Color3.fromRGB(234, 231, 225),       -- #EAE7E1
		Ink = Color3.fromRGB(22, 21, 27),               -- #16151B
		Ink2 = Color3.fromRGB(87, 83, 95),              -- #57535F
		Ink3 = Color3.fromRGB(142, 138, 151),           -- #8E8A97
		Line = Color3.fromRGB(22, 21, 27),
		LineTransparency = 0.91,
		Line2Transparency = 0.83,
		Accent = Color3.fromRGB(106, 87, 242),          -- #6A57F2
		Accent2 = Color3.fromRGB(47, 143, 224),         -- #2F8FE0
		AccentSoft = Color3.fromRGB(106, 87, 242),
		AccentInk = Color3.fromRGB(255, 255, 255),
		Mint = Color3.fromRGB(17, 156, 114),            -- #119C72
		Warn = Color3.fromRGB(214, 115, 30),            -- #D6731E
		Danger = Color3.fromRGB(217, 58, 85),           -- #D93A55
		Shadow = Color3.fromRGB(40, 30, 80),
		Gradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(123, 97, 255)),
			ColorSequenceKeypoint.new(0.55, Color3.fromRGB(61, 139, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(31, 184, 154))
		}),
		BlockGradients = {
			ColorSequence.new(Color3.fromRGB(139, 108, 255), Color3.fromRGB(91, 140, 255)),
			ColorSequence.new(Color3.fromRGB(255, 181, 71), Color3.fromRGB(255, 122, 69)),
			ColorSequence.new(Color3.fromRGB(34, 195, 166), Color3.fromRGB(14, 165, 233)),
			ColorSequence.new(Color3.fromRGB(255, 122, 147), Color3.fromRGB(176, 79, 208))
		}
	},
	Dark = {
		Page = Color3.fromRGB(7, 8, 13),                -- #07080D
		Surface = Color3.fromRGB(19, 20, 28),           -- #13141C
		Surface2 = Color3.fromRGB(26, 27, 37),          -- #1A1B25
		Surface3 = Color3.fromRGB(37, 38, 50),          -- #252632
		Ink = Color3.fromRGB(244, 240, 232),            -- #F4F0E8
		Ink2 = Color3.fromRGB(244, 240, 232),
		Ink3 = Color3.fromRGB(142, 138, 151),
		Line = Color3.fromRGB(255, 255, 255),
		LineTransparency = 0.92,
		Line2Transparency = 0.84,
		Accent = Color3.fromRGB(183, 164, 255),         -- #B7A4FF
		Accent2 = Color3.fromRGB(125, 180, 255),        -- #7DB4FF
		AccentSoft = Color3.fromRGB(183, 164, 255),
		AccentInk = Color3.fromRGB(11, 12, 18),
		Mint = Color3.fromRGB(126, 232, 192),
		Warn = Color3.fromRGB(255, 178, 107),
		Danger = Color3.fromRGB(255, 125, 140),
		Shadow = Color3.fromRGB(0, 0, 0),
		Gradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(183, 164, 255)),
			ColorSequenceKeypoint.new(0.55, Color3.fromRGB(125, 180, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(165, 242, 211))
		}),
		BlockGradients = {
			ColorSequence.new(Color3.fromRGB(139, 108, 255), Color3.fromRGB(91, 140, 255)),
			ColorSequence.new(Color3.fromRGB(255, 181, 71), Color3.fromRGB(255, 122, 69)),
			ColorSequence.new(Color3.fromRGB(34, 195, 166), Color3.fromRGB(14, 165, 233)),
			ColorSequence.new(Color3.fromRGB(255, 122, 147), Color3.fromRGB(176, 79, 208))
		}
	}
}

-- Universal High-Precision Typography System
local FONT_REGULAR = pcall(function() return Enum.Font.BuilderSans end) and Enum.Font.BuilderSans or Enum.Font.SourceSans
local FONT_MEDIUM = pcall(function() return Enum.Font.BuilderSansMedium end) and Enum.Font.BuilderSansMedium or Enum.Font.SourceSansSemibold
local FONT_BOLD = pcall(function() return Enum.Font.BuilderSansBold end) and Enum.Font.BuilderSansBold or Enum.Font.SourceSansBold

local function getUIFont(weight: "Regular" | "Medium" | "Bold" | "SemiBold"): Enum.Font
	if weight == "Bold" or weight == "SemiBold" then
		return FONT_BOLD
	elseif weight == "Medium" then
		return FONT_MEDIUM
	else
		return FONT_REGULAR
	end
end

-- Exact 1:1 Icons from File Gop (Nexus_combined_loader.lua)
LucianUI.Icons = {
	Home = "rbxassetid://98755624629571",           -- Lucide house
	Dashboard = "rbxassetid://139929981863901",     -- Lucide layout-dashboard
	Activity = "rbxassetid://94212016861936",       -- Lucide activity
	Fishing = "rbxassetid://71754848048049",        -- Lucide fishing-rod
	Fish = "rbxassetid://124360663785796",          -- Lucide fish
	Bot = "rbxassetid://80451686744860",            -- Lucide bot
	Combat = "rbxassetid://81872698913435",         -- Lucide swords
	Sword = "rbxassetid://124448418211665",         -- Lucide sword
	Play = "rbxassetid://135609604299893",          -- Lucide play
	Shop = "rbxassetid://128420521375441",          -- Lucide shopping-cart
	Store = "rbxassetid://90338129673705",          -- Lucide store
	Bag = "rbxassetid://71885477293226",            -- Lucide shopping-bag
	Exchange = "rbxassetid://131324733048447",      -- Lucide arrow-left-right
	Refresh = "rbxassetid://138133190015277",       -- Lucide refresh-cw
	Repeat = "rbxassetid://121886242955173",        -- Lucide repeat
	Coins = "rbxassetid://116510979641930",         -- Lucide coins
	Gem = "rbxassetid://112904952151156",           -- Lucide gem
	Quests = "rbxassetid://92649798577170",         -- Lucide clipboard-check
	Scroll = "rbxassetid://74072101474951",         -- Lucide scroll
	TodoList = "rbxassetid://132980603752108",      -- Lucide list-todo
	Upgrade = "rbxassetid://81819858538839",        -- Lucide trending-up
	Zap = "rbxassetid://130551565616516",           -- Lucide zap
	Sparkles = "rbxassetid://138635884129147",      -- Lucide sparkles
	Teleport = "rbxassetid://84279202219901",       -- Lucide map-pin
	Compass = "rbxassetid://115123411028382",       -- Lucide compass
	Navigation = "rbxassetid://79308213542922",     -- Lucide navigation
	Send = "rbxassetid://127751956873796",          -- Lucide send
	Settings = "rbxassetid://80758916183665",       -- Lucide settings gear
	Sliders = "rbxassetid://85538382643347",        -- Lucide sliders-horizontal
	Server = "rbxassetid://92188766517878",         -- Lucide server
	Globe = "rbxassetid://114238209622913",         -- Lucide globe
	Radio = "rbxassetid://85611589536956",          -- Lucide radio
	Layers = "rbxassetid://81973586053257",         -- Lucide layers
	User = "rbxassetid://81589895647169",           -- Lucide user
	Profile = "rbxassetid://81589895647169",        -- Lucide user
	Bell = "rbxassetid://97392696311902",           -- Lucide bell
	Search = "rbxassetid://121018724060431",        -- Lucide search
	Shield = "rbxassetid://110987169760162",        -- Lucide shield
	Check = "rbxassetid://93898873302694",          -- Lucide check
	Close = "rbxassetid://110786993356448",         -- Lucide x
	Chevron = "rbxassetid://136188197552572",       -- Lucide chevron
	Flame = "rbxassetid://98218034436456",          -- Lucide flame
	Crown = "rbxassetid://127843403295538",         -- Lucide crown
	Trophy = "rbxassetid://131545003268773",        -- Lucide trophy
	Grid = "rbxassetid://10723345518",
}

local TAB_ICON_MAP = {
	["session"] = LucianUI.Icons.Dashboard,
	["home"] = LucianUI.Icons.Home,
	["routine"] = LucianUI.Icons.Fishing,
	["farming"] = LucianUI.Icons.Fishing,
	["combat"] = LucianUI.Icons.Combat,
	["shop"] = LucianUI.Icons.Shop,
	["store"] = LucianUI.Icons.Store,
	["exchange"] = LucianUI.Icons.Exchange,
	["quests"] = LucianUI.Icons.Quests,
	["quest"] = LucianUI.Icons.Quests,
	["upgrade"] = LucianUI.Icons.Upgrade,
	["teleport"] = LucianUI.Icons.Teleport,
	["settings"] = LucianUI.Icons.Settings,
	["setting"] = LucianUI.Icons.Settings,
	["server hop"] = LucianUI.Icons.Globe,
	["server"] = LucianUI.Icons.Server,
	["layers"] = LucianUI.Icons.Layers,
}

-- Motion parameters
local SPRING_BOUNCE = TweenInfo.new(0.46, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local SMOOTH_QUAD = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local FAST_EASE = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function getSafeGuiParent(): Instance
	local tries = {
		function() return (gethui and gethui()) end,
		function() return CoreGui end,
		function() return Players.LocalPlayer:WaitForChild("PlayerGui") end,
		function() return game:GetService("StarterGui") end,
	}
	for _, f in ipairs(tries) do
		local ok, res = pcall(f)
		if ok and typeof(res) == "Instance" then
			return res
		end
	end
	return game:GetService("StarterGui")
end

local function makeDraggable(frame: GuiObject, handle: GuiObject)
	local dragging = false
	local dragInput: InputObject? = nil
	local dragStart: Vector3 = Vector3.zero
	local startPos: UDim2 = frame.Position

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	handle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
end

-- ==============================================================================
-- NOTIFICATION SYSTEM (Floating Toast Stack)
-- ==============================================================================
local notificationGui: ScreenGui? = nil

function LucianUI:Notify(selfOrConfig, maybeConfig)
	local cfg = type(selfOrConfig) == "table" and (selfOrConfig.Title or selfOrConfig.Message or selfOrConfig.Content or selfOrConfig.Duration) and selfOrConfig or maybeConfig or {}
	local title = cfg.Title or "Nexus"
	local message = cfg.Message or cfg.Content or cfg.Text or ""
	local duration = tonumber(cfg.Duration) or 3

	if not notificationGui or not notificationGui.Parent then
		local parentGui = getSafeGuiParent()
		local ng = Instance.new("ScreenGui")
		ng.Name = "NexusNotifications"
		ng.ResetOnSpawn = false
		ng.DisplayOrder = 2147483646
		ng.Parent = parentGui
		notificationGui = ng

		local stack = Instance.new("Frame")
		stack.Name = "Stack"
		stack.AnchorPoint = Vector2.new(1, 1)
		stack.Position = UDim2.new(1, -20, 1, -85)
		stack.Size = UDim2.new(0, 280, 0, 360)
		stack.BackgroundTransparency = 1
		stack.Parent = ng

		local layout = Instance.new("UIListLayout")
		layout.FillDirection = Enum.FillDirection.Vertical
		layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
		layout.Padding = UDim.new(0, 8)
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Parent = stack
	end

	local stack = notificationGui:FindFirstChild("Stack")
	if not stack then return end

	local card = Instance.new("Frame")
	card.Name = "NotifyCard"
	card.Size = UDim2.new(0, 260, 0, 56)
	card.BackgroundColor3 = LucianUI.Tokens.Dark.Surface
	card.Position = UDim2.new(1, 40, 0, 0)
	card.BackgroundTransparency = 0.05
	card.BorderSizePixel = 0
	card.ClipsDescendants = true
	card.Parent = stack

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 14)
	corner.Parent = card

	local stroke = Instance.new("UIStroke")
	stroke.Color = LucianUI.Tokens.Dark.Line
	stroke.Transparency = 0.82
	stroke.Thickness = 1
	stroke.Parent = card

	local stripe = Instance.new("Frame")
	stripe.Position = UDim2.new(0, 0, 0, 8)
	stripe.Size = UDim2.new(0, 3, 1, -16)
	stripe.BackgroundColor3 = LucianUI.Tokens.Dark.Accent
	stripe.BorderSizePixel = 0
	stripe.Parent = card

	local sCorner = Instance.new("UICorner")
	sCorner.CornerRadius = UDim.new(1, 0)
	sCorner.Parent = stripe

	local t = Instance.new("TextLabel")
	t.Position = UDim2.new(0, 14, 0, 8)
	t.Size = UDim2.new(1, -38, 0, 16)
	t.BackgroundTransparency = 1
	t.Text = title
	t.TextColor3 = LucianUI.Tokens.Dark.Ink
	t.Font = getUIFont("Bold")
	t.TextSize = 12
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.Parent = card

	local m = Instance.new("TextLabel")
	m.Position = UDim2.new(0, 14, 0, 26)
	m.Size = UDim2.new(1, -38, 0, 22)
	m.BackgroundTransparency = 1
	m.Text = message
	m.TextColor3 = LucianUI.Tokens.Dark.Ink2
	m.Font = getUIFont("Medium")
	m.TextSize = 10
	m.TextWrapped = true
	m.TextXAlignment = Enum.TextXAlignment.Left
	m.TextYAlignment = Enum.TextYAlignment.Top
	m.Parent = card

	local closeBtn = Instance.new("TextButton")
	closeBtn.Position = UDim2.new(1, -22, 0, 6)
	closeBtn.Size = UDim2.new(0, 16, 0, 16)
	closeBtn.BackgroundTransparency = 1
	closeBtn.Text = "×"
	closeBtn.TextColor3 = LucianUI.Tokens.Dark.Ink3
	closeBtn.Font = getUIFont("Bold")
	closeBtn.TextSize = 14
	closeBtn.Parent = card

	TweenService:Create(card, SPRING_BOUNCE, { Position = UDim2.new(0, 0, 0, 0) }):Play()

	local closing = false
	local function dismiss()
		if closing then return end
		closing = true
		local tOut = TweenService:Create(card, FAST_EASE, { Position = UDim2.new(1, 50, 0, 0), BackgroundTransparency = 1 })
		tOut:Play()
		tOut.Completed:Connect(function()
			card:Destroy()
		end)
	end

	closeBtn.MouseButton1Click:Connect(dismiss)
	task.delay(duration, dismiss)
end

-- ==============================================================================
-- ELEMENT #041: COMPACT NOTCHED BOTTOM TAB BAR (Unified 320x60px -> Scalable)
-- ==============================================================================
local TabBar041 = {}
TabBar041.__index = TabBar041

function TabBar041.new(config: {
	Parent: Instance?,
	ThemeName: string?,
	Width: number?,
	Height: number?,
	Tabs: { { Id: string, Title: string, Icon: string, Badge: number? } }?,
	OnSelect: ((index: number) -> ())?,
	OnActiveClick: ((index: number) -> ())?
})
	local self = setmetatable({}, TabBar041)
	self.ThemeName = config.ThemeName or "Dark"
	self.Theme = LucianUI.Tokens[self.ThemeName] or LucianUI.Tokens.Dark
	self.Width = config.Width or 420
	self.Height = config.Height or 56
	self.OnSelect = config.OnSelect
	self.OnActiveClick = config.OnActiveClick
	self.TabsData = config.Tabs or {}
	self.CurrentIndex = 1
	self.TabButtons = {}
	self.TabIcons = {}
	self.TabLabels = {}
	self.TabStripes = {}
	self.TabBadges = {}

	local root = Instance.new("Frame")
	root.Name = "Lucian041_TabBar"
	root.AnchorPoint = Vector2.new(0.5, 1)
	root.Position = UDim2.new(0.5, 0, 1, -16)
	root.Size = UDim2.new(0, self.Width, 0, self.Height)
	root.BackgroundTransparency = 1
	root.ZIndex = 30
	root.Parent = config.Parent
	self.Root = root

	-- Single, continuous solid capsule bar (will never divide, tear, or leave detached pill fragments)
	local barWrap = Instance.new("Frame")
	barWrap.Name = "BarWrapper"
	barWrap.Position = UDim2.new(0, 0, 0, 0)
	barWrap.Size = UDim2.new(1, 0, 1, 0)
	barWrap.BackgroundColor3 = self.Theme.Surface
	barWrap.BorderSizePixel = 0
	barWrap.ZIndex = 31
	barWrap.Parent = root
	self.BarWrap = barWrap

	local barCorner = Instance.new("UICorner")
	barCorner.CornerRadius = UDim.new(0, 24)
	barCorner.Parent = barWrap

	local barStroke = Instance.new("UIStroke")
	barStroke.Color = self.Theme.Line
	barStroke.Transparency = self.Theme.LineTransparency
	barStroke.Thickness = 1
	barStroke.Parent = barWrap
	self.BarStroke = barStroke





	-- Lucian #041 signature floating gradient bubble
	local bubble = Instance.new("Frame")
	bubble.Name = "FloatingBubble"
	bubble.AnchorPoint = Vector2.new(0.5, 0.5)
	bubble.Position = UDim2.new(0, 0, 0, -12)
	bubble.Size = UDim2.new(0, 44, 0, 44)
	bubble.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	bubble.BorderSizePixel = 0
	bubble.ClipsDescendants = true
	bubble.ZIndex = 50
	bubble.Parent = root
	self.Bubble = bubble

	local bCorner = Instance.new("UICorner")
	bCorner.CornerRadius = UDim.new(1, 0)
	bCorner.Parent = bubble

	local bStroke = Instance.new("UIStroke")
	bStroke.Color = Color3.fromRGB(255, 255, 255)
	bStroke.Transparency = 0.55
	bStroke.Thickness = 1.2
	bStroke.Parent = bubble

	local bGrad = Instance.new("UIGradient")
	bGrad.Color = self.Theme.Gradient
	bGrad.Rotation = 45
	bGrad.Parent = bubble
	self.BubbleGrad = bGrad

	local bIcon = Instance.new("ImageLabel")
	bIcon.Name = "BubbleIcon"
	bIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	bIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
	bIcon.Size = UDim2.new(0, 20, 0, 20)
	bIcon.BackgroundTransparency = 1
	bIcon.ImageColor3 = self.Theme.AccentInk
	bIcon.ZIndex = 51
	bIcon.Parent = bubble
	self.BubbleIcon = bIcon

	local bubbleBtn = Instance.new("TextButton")
	bubbleBtn.Name = "BubbleClickArea"
	bubbleBtn.Size = UDim2.new(1, 0, 1, 0)
	bubbleBtn.BackgroundTransparency = 1
	bubbleBtn.Text = ""
	bubbleBtn.ZIndex = 52
	bubbleBtn.Parent = bubble
	bubbleBtn.MouseButton1Click:Connect(function()
		if self.OnActiveClick then
			self.OnActiveClick(self.CurrentIndex)
		end
	end)

	local tabsList = Instance.new("Frame")
	tabsList.Name = "TabsList"
	tabsList.Size = UDim2.new(1, 0, 1, 0)
	tabsList.BackgroundTransparency = 1
	tabsList.ZIndex = 35
	tabsList.Parent = root
	self.TabsList = tabsList

	self:RebuildTabs()
	return self
end

function TabBar041:GetTabCenterX(index: number): number
	local totalTabs = #self.TabsData
	if totalTabs == 0 then return self.Width / 2 end
	local pad = 12
	local avail = self.Width - pad * 2
	local tabWidth = avail / totalTabs
	return pad + (index - 0.5) * tabWidth
end

function TabBar041:RebuildTabs()
	for _, child in ipairs(self.TabsList:GetChildren()) do
		child:Destroy()
	end
	self.TabButtons = {}
	self.TabIcons = {}
	self.TabLabels = {}
	self.TabStripes = {}
	self.TabBadges = {}

	local totalTabs = #self.TabsData
	if totalTabs == 0 then return end

	-- Dynamically scale width for number of tabs
	local targetWidth = math.clamp(totalTabs * 48 + 32, 320, 560)
	self.Width = targetWidth
	self.Root.Size = UDim2.new(0, self.Width, 0, self.Height)

	local pad = 12
	local avail = self.Width - pad * 2
	local tabWidth = avail / totalTabs

	for i, tabData in ipairs(self.TabsData) do
		local btn = Instance.new("TextButton")
		btn.Name = "Tab_" .. i
		btn.Position = UDim2.new(0, pad + (i - 1) * tabWidth, 0, 0)
		btn.Size = UDim2.new(0, tabWidth, 1, 0)
		btn.BackgroundTransparency = 1
		btn.Text = ""
		btn.AutoButtonColor = false
		btn.ZIndex = 36
		btn.Parent = self.TabsList

		local iconContainer = Instance.new("Frame")
		iconContainer.Name = "IconContainer"
		iconContainer.AnchorPoint = Vector2.new(0.5, 0.5)
		iconContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
		iconContainer.Size = UDim2.new(0, 20, 0, 20)
		iconContainer.BackgroundTransparency = 1
		iconContainer.ZIndex = 37
		iconContainer.Parent = btn

		local iconImg = Instance.new("ImageLabel")
		iconImg.Name = "Icon"
		iconImg.Size = UDim2.new(1, 0, 1, 0)
		iconImg.BackgroundTransparency = 1
		iconImg.Image = tabData.Icon
		iconImg.ImageColor3 = self.Theme.Ink3
		iconImg.ZIndex = 37
		iconImg.Parent = iconContainer

		local label = Instance.new("TextLabel")
		label.Name = "Label"
		label.AnchorPoint = Vector2.new(0.5, 1)
		label.Position = UDim2.new(0.5, 0, 1, -8)
		label.Size = UDim2.new(1, 0, 0, 14)
		label.BackgroundTransparency = 1
		label.Text = tabData.Title
		label.TextColor3 = self.Theme.Accent
		label.Font = getUIFont("Bold")
		label.TextSize = 11
		label.TextTransparency = 1
		label.TextTruncate = Enum.TextTruncate.None
		label.TextWrapped = false
		label.ZIndex = 38
		label.Parent = btn

		local stripe = Instance.new("Frame")
		stripe.Name = "ActiveStripe"
		stripe.AnchorPoint = Vector2.new(0.5, 1)
		stripe.Position = UDim2.new(0.5, 0, 1, -3)
		stripe.Size = UDim2.new(0, 20, 0, 3)
		stripe.BackgroundColor3 = self.Theme.Accent
		stripe.BorderSizePixel = 0
		stripe.BackgroundTransparency = 1
		stripe.ZIndex = 39
		stripe.Parent = btn

		local sCorn = Instance.new("UICorner")
		sCorn.CornerRadius = UDim.new(1, 0)
		sCorn.Parent = stripe

		local badge
		if tabData.Badge and tabData.Badge > 0 then
			local bFrame = Instance.new("Frame")
			bFrame.Name = "Badge"
			bFrame.AnchorPoint = Vector2.new(0.5, 0.5)
			bFrame.Position = UDim2.new(0.5, 10, 0, 14)
			bFrame.Size = UDim2.new(0, 14, 0, 14)
			bFrame.BackgroundColor3 = self.Theme.Danger
			bFrame.BorderSizePixel = 0
			bFrame.ZIndex = 41
			bFrame.Parent = btn

			local bCorn = Instance.new("UICorner")
			bCorn.CornerRadius = UDim.new(1, 0)
			bCorn.Parent = bFrame

			local bStrk = Instance.new("UIStroke")
			bStrk.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			bStrk.Color = self.Theme.Surface
			bStrk.Thickness = 2
			bStrk.Parent = bFrame

			local bText = Instance.new("TextLabel")
			bText.Size = UDim2.new(1, 0, 1, 0)
			bText.BackgroundTransparency = 1
			bText.Text = tostring(tabData.Badge)
			bText.TextColor3 = Color3.fromRGB(255, 255, 255)
			bText.TextSize = 9
			bText.Font = getUIFont("Bold")
			bText.ZIndex = 42
			bText.Parent = bFrame

			badge = bFrame
		end

		self.TabButtons[i] = btn
		self.TabIcons[i] = iconImg
		self.TabLabels[i] = label
		self.TabStripes[i] = stripe
		self.TabBadges[i] = badge

		btn.MouseButton1Click:Connect(function()
			if self.CurrentIndex == i then
				if self.OnActiveClick then
					self.OnActiveClick(i)
				else
					self:Deselect()
				end
			else
				self:SelectTab(i)
				if self.OnSelect then
					self.OnSelect(i)
				end
			end
		end)

		btn.MouseEnter:Connect(function()
			if self.CurrentIndex ~= i then
				TweenService:Create(iconImg, FAST_EASE, { ImageColor3 = self.Theme.Ink, ImageTransparency = 0 }):Play()
			end
		end)
		btn.MouseLeave:Connect(function()
			if self.CurrentIndex ~= i then
				TweenService:Create(iconImg, FAST_EASE, { ImageColor3 = self.Theme.Ink3, ImageTransparency = 0.45 }):Play()
			end
		end)
	end

	self:SelectTab(self.CurrentIndex or 1, true)
end

function TabBar041:SelectTab(index: number, immediate: boolean?)
	if index < 1 or index > #self.TabsData then return end
	self.CurrentIndex = index
	local targetX = self:GetTabCenterX(index)

	local bubblePos = UDim2.new(0, targetX, 0, -12)

	local activeTabData = self.TabsData[index]
	if activeTabData and self.BubbleIcon then
		self.BubbleIcon.Image = activeTabData.Icon
		self.BubbleIcon.ImageTransparency = 0
	end

	self.Bubble.Visible = true

	if immediate then
		self.Bubble.Position = bubblePos
		self.Bubble.Size = UDim2.new(0, 44, 0, 44)
		if self.BubbleIcon then self.BubbleIcon.ImageTransparency = 0 end
	else
		TweenService:Create(self.Bubble, SPRING_BOUNCE, { Position = bubblePos, Size = UDim2.new(0, 44, 0, 44) }):Play()
		if self.BubbleIcon then
			TweenService:Create(self.BubbleIcon, FAST_EASE, { ImageTransparency = 0 }):Play()
		end
	end

	for i, tabData in ipairs(self.TabsData) do
		local icon = self.TabIcons[i]
		local label = self.TabLabels[i]
		local stripe = self.TabStripes and self.TabStripes[i]
		local badge = self.TabBadges[i]

		if i == index then
			if icon then
				TweenService:Create(icon, FAST_EASE, { ImageTransparency = 1 }):Play()
			end
			if label then
				label.Visible = true
				TweenService:Create(label, FAST_EASE, { Position = UDim2.new(0.5, 0, 1, -8), TextTransparency = 0 }):Play()
			end
			if stripe then
				stripe.Visible = true
				TweenService:Create(stripe, FAST_EASE, { Size = UDim2.new(0, 22, 0, 3), BackgroundTransparency = 0 }):Play()
			end
			if badge then
				badge.Visible = false
			end
		else
			if icon then
				TweenService:Create(icon, FAST_EASE, { ImageColor3 = self.Theme.Ink3, ImageTransparency = 0.45 }):Play()
			end
			if label then
				TweenService:Create(label, FAST_EASE, { Position = UDim2.new(0.5, 0, 1, -4), TextTransparency = 1 }):Play()
			end
			if stripe then
				TweenService:Create(stripe, FAST_EASE, { Size = UDim2.new(0, 8, 0, 3), BackgroundTransparency = 1 }):Play()
			end
			if badge and tabData.Badge and tabData.Badge > 0 then
				badge.Visible = true
			end
		end
	end
end

function TabBar041:Deselect()
	self.CurrentIndex = 0
	TweenService:Create(self.Bubble, FAST_EASE, { Size = UDim2.new(0, 0, 0, 0) }):Play()
	if self.BubbleIcon then
		TweenService:Create(self.BubbleIcon, FAST_EASE, { ImageTransparency = 1 }):Play()
	end

	task.delay(0.2, function()
		if self.CurrentIndex == 0 and self.Bubble then
			self.Bubble.Visible = false
		end
	end)

	for i, _ in ipairs(self.TabsData) do
		local icon = self.TabIcons[i]
		local label = self.TabLabels[i]
		local stripe = self.TabStripes and self.TabStripes[i]
		if icon then
			TweenService:Create(icon, FAST_EASE, { ImageColor3 = self.Theme.Ink3, ImageTransparency = 0.45 }):Play()
		end
		if label then
			TweenService:Create(label, FAST_EASE, { Position = UDim2.new(0.5, 0, 1, -4), TextTransparency = 1 }):Play()
		end
		if stripe then
			TweenService:Create(stripe, FAST_EASE, { Size = UDim2.new(0, 8, 0, 3), BackgroundTransparency = 1 }):Play()
		end
	end
end

function TabBar041:SetBadge(index: number, count: number?)
	if not self.TabsData[index] then return end
	self.TabsData[index].Badge = count
	local badge = self.TabBadges[index]
	if count and count > 0 then
		if badge then
			badge.Visible = (self.CurrentIndex ~= index)
			local txt = badge:FindFirstChildOfClass("TextLabel")
			if txt then txt.Text = tostring(count) end
		else
			self:RebuildTabs()
		end
	else
		if badge then badge.Visible = false end
	end
end

function TabBar041:SetTitle(index: number, title: string)
	if self.TabsData[index] then
		self.TabsData[index].Title = title
		local lbl = self.TabLabels[index]
		if lbl then lbl.Text = title end
	end
end

function TabBar041:SetIcon(index: number, icon: string)
	if self.TabsData[index] then
		self.TabsData[index].Icon = icon
		local img = self.TabIcons[index]
		if img then img.Image = icon end
		if self.CurrentIndex == index and self.BubbleIcon then
			self.BubbleIcon.Image = icon
		end
	end
end
-- ==============================================================================
-- EXACT NEXUS VECTOR POLYGON RASTERIZER (256x256 STANDALONE MATHEMATICAL 'N')
-- ==============================================================================
local NEXUS_POLYGONS = {
	{
		Vector2.new(0, 256), Vector2.new(0, 0),
		Vector2.new(64, 0), Vector2.new(256, 256),
		Vector2.new(179.2, 256), Vector2.new(64, 102.4),
		Vector2.new(64, 256),
	},
	{
		Vector2.new(192, 0), Vector2.new(256, 0),
		Vector2.new(256, 179.2), Vector2.new(192, 89.6),
	},
}

local function drawN(parent: Instance, customScale: number?, customStep: number?, customColor: Color3?)
	local icon = Instance.new("Frame")
	icon.Name = "NexusIcon"
	icon.AnchorPoint = Vector2.new(0.5, 0.5)
	icon.Position = UDim2.fromScale(0.5, 0.5)
	icon.Size = UDim2.fromScale(customScale or 0.62, customScale or 0.62)
	icon.BackgroundTransparency = 1
	icon.Parent = parent

	-- Dựng hình bằng các dải ngang chuẩn, chống mờ viền subpixel
	local step = customStep or 3
	local col = customColor or Color3.fromRGB(255, 255, 255)

	for _, polygon in ipairs(NEXUS_POLYGONS) do
		for y = 0, 254, step do
			local scanY = y + step / 2
			local intersections = {}

			for i, a in ipairs(polygon) do
				local b = polygon[i % #polygon + 1]

				if (a.Y <= scanY and b.Y > scanY)
					or (b.Y <= scanY and a.Y > scanY) then
					local x = a.X
						+ (scanY - a.Y) * (b.X - a.X)
						/ (b.Y - a.Y)

					table.insert(intersections, x)
				end
			end

			table.sort(intersections)

			for i = 1, #intersections - 1, 2 do
				local left = intersections[i]
				local right = intersections[i + 1]

				local strip = Instance.new("Frame")
				strip.BorderSizePixel = 0
				strip.BackgroundColor3 = col
				strip.Position = UDim2.fromScale(left / 256, y / 256)
				strip.Size = UDim2.fromScale(
					(right - left) / 256,
					(step + 0.7) / 256
				)
				strip.Parent = icon
			end
		end
	end
	return icon
end

local NEXUS_2K_ASSET = "rbxassetid://79122933233892"

local function drawNexusMonogram(container: GuiObject, size: number)
	container:ClearAllChildren()

	local bg = Instance.new("Frame")
	bg.Name = "EmblemBg"
	bg.Size = UDim2.new(1, 0, 1, 0)
	bg.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
	bg.BorderSizePixel = 0
	bg.Parent = container

	local bgCorner = Instance.new("UICorner")
	bgCorner.CornerRadius = UDim.new(0, math.clamp(math.floor(size * 0.2), 4, 8))
	bgCorner.Parent = bg

	local bgStroke = Instance.new("UIStroke")
	bgStroke.Color = Color3.fromRGB(70, 70, 70)
	bgStroke.Thickness = 1
	bgStroke.Parent = bg

	local img = Instance.new("ImageLabel")
	img.Name = "NexusN_2K"
	img.AnchorPoint = Vector2.new(0.5, 0.5)
	img.Position = UDim2.fromScale(0.5, 0.5)
	img.Size = UDim2.fromScale(0.62, 0.62)
	img.BackgroundTransparency = 1
	img.Image = NEXUS_2K_ASSET
	img.ImageColor3 = Color3.fromRGB(255, 255, 255)
	img.Parent = bg
end

-- ==============================================================================
-- MOBILE FLOATING TOGGLE BUTTON (2K RESOLUTION & 4 TIGHT CORNERS)
-- ==============================================================================
local function createMobileToggleButton(parentGui: Instance, window)
	local button = Instance.new("TextButton")
	button.Name = "NexusButton"
	button.Size = UDim2.fromOffset(48, 48)
	button.Position = UDim2.new(0, 20, 0.5, -24)
	button.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
	button.BorderSizePixel = 0
	button.Text = ""
	button.AutoButtonColor = false
	button.ZIndex = 100
	button.Parent = parentGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8) -- 4 goc nho lai
	corner.Parent = button

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(70, 70, 70)
	stroke.Thickness = 1
	stroke.Parent = button

	local nImage = Instance.new("ImageLabel")
	nImage.Name = "NexusN_2K"
	nImage.AnchorPoint = Vector2.new(0.5, 0.5)
	nImage.Position = UDim2.fromScale(0.5, 0.5)
	nImage.Size = UDim2.fromScale(0.6, 0.6)
	nImage.BackgroundTransparency = 1
	nImage.Image = NEXUS_2K_ASSET
	nImage.ImageColor3 = Color3.fromRGB(255, 255, 255)
	nImage.Parent = button

	-- Touch & Mouse Draggable with Edge Snapping
	local dragging = false
	local dragStart = Vector2.new()
	local startPos = UDim2.new()
	local totalMoved = 0

	button.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = button.Position
			totalMoved = 0
			TweenService:Create(button, FAST_EASE, { Size = UDim2.fromOffset(42, 42) }):Play()
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			totalMoved = totalMoved + delta.Magnitude
			button.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)

	local function onDragEnd()
		if not dragging then return end
		dragging = false
		TweenService:Create(button, SPRING_BOUNCE, { Size = UDim2.fromOffset(48, 48) }):Play()

		if totalMoved < 8 then
			window:Toggle()
			local isOpen = window.IsOpen
			TweenService:Create(stroke, FAST_EASE, {
				Color = isOpen and Color3.fromRGB(167, 139, 250) or Color3.fromRGB(70, 70, 70)
			}):Play()
		else
			local cam = workspace.CurrentCamera
			local viewportWidth = cam and cam.ViewportSize.X or 800
			local curAbsX = button.AbsolutePosition.X
			local snapX = 20
			if curAbsX > viewportWidth / 2 then
				snapX = viewportWidth - 68
			end
			TweenService:Create(button, SPRING_BOUNCE, {
				Position = UDim2.new(0, snapX, button.Position.Y.Scale, button.Position.Y.Offset)
			}):Play()
		end
	end

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			onDragEnd()
		end
	end)

	return button
end
-- ==============================================================================
-- ELEMENT #040: COMPACT LUMEN RAIL NAVIGATION & MAIN CONTENT INTERFACE
-- ==============================================================================
local Element040 = {}
Element040.__index = Element040

function Element040.new(config: {
	Title: string?,
	SubTitle: string?,
	Subtitle: string?,
	Logo: string?,
	UserName: string?,
	UserRole: string?,
	UserAvatar: string?,
	Theme: string?,
	Width: number?,
	Height: number?,
	Parent: Instance?
})
	local self = setmetatable({}, Element040)
	self.ThemeName = config.Theme or "Dark"
	self.Theme = LucianUI.Tokens[self.ThemeName] or LucianUI.Tokens.Dark
	self.Width = config.Width or 480
	self.Height = config.Height or 340
	self.IsWide = false
	self.Tabs = {}
	self.RailItems = {}
	self.CurrentIndex = 1
	self.IsOpen = true

	local parentGui = config.Parent or getSafeGuiParent()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "Nexus_LucianUI_" .. tostring(math.random(1000, 9999))
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = parentGui
	self.ScreenGui = screenGui

	-- Master Container
	local container = Instance.new("Frame")
	container.Name = "Lucian040_Root"
	container.AnchorPoint = Vector2.new(0.5, 0.5)
	container.Position = UDim2.new(0.5, 0, 0.5, 0)
	container.Size = UDim2.new(0, self.Width, 0, self.Height)
	container.BackgroundTransparency = 1
	container.Parent = screenGui
	self.Root = container

	-- Left Collapsible Rail (56px collapsed, 150px wide)
	local rail = Instance.new("Frame")
	rail.Name = "Rail"
	rail.Position = UDim2.new(0, 0, 0, 0)
	rail.Size = UDim2.new(0, 56, 1, 0)
	rail.BackgroundColor3 = self.ThemeName == "Light" and self.Theme.Ink or Color3.fromRGB(18, 19, 27)
	local railStroke = Instance.new("UIStroke")
	railStroke.Color = Color3.fromRGB(255, 255, 255)
	railStroke.Transparency = 0.92
	railStroke.Thickness = 1
	railStroke.Parent = rail
	rail.BorderSizePixel = 0
	rail.ClipsDescendants = true
	rail.ZIndex = 10
	rail.Parent = container
	self.Rail = rail

	local railCorner = Instance.new("UICorner")
	railCorner.CornerRadius = UDim.new(0, 20)
	railCorner.Parent = rail

	makeDraggable(container, rail)

	-- Top Brand (.u040-top)
	local topBar = Instance.new("Frame")
	topBar.Name = "TopBar"
	topBar.Size = UDim2.new(1, 0, 0, 36)
	topBar.Position = UDim2.new(0, 9, 0, 10)
	topBar.BackgroundTransparency = 1
	topBar.ZIndex = 11
	topBar.Parent = rail

	local logo = Instance.new("Frame")
	logo.Name = "Logo"
	logo.Size = UDim2.new(0, 28, 0, 28)
	logo.BackgroundTransparency = 1
	logo.BorderSizePixel = 0
	logo.ZIndex = 12
	logo.Parent = topBar

	local logoCorner = Instance.new("UICorner")
	logoCorner.CornerRadius = UDim.new(0, 9)
	logoCorner.Parent = logo

	local logoGrad = Instance.new("UIGradient")
	logoGrad.Color = self.Theme.Gradient
	logoGrad.Rotation = 45
	logoGrad.Parent = logo

	local logoImg = Instance.new("ImageLabel")
	logoImg.Name = "LogoImage"
	logoImg.AnchorPoint = Vector2.new(0.5, 0.5)
	logoImg.Position = UDim2.new(0.5, 0, 0.5, 0)
	logoImg.Size = UDim2.new(0, 18, 0, 18)
	logoImg.BackgroundTransparency = 1
	logoImg.ImageColor3 = Color3.fromRGB(255, 255, 255)
	logoImg.ZIndex = 13
	logoImg.Visible = false
	logoImg.Parent = logo
	self.LogoImage = logoImg

	if config.Logo and config.Logo ~= "" then
		logoImg.Image = config.Logo
		logoImg.Visible = true
	else
		drawNexusMonogram(logo, 28)
	end

	local brandName = Instance.new("TextLabel")
	brandName.Name = "BrandName"
	brandName.Position = UDim2.new(0, 38, 0, 0)
	brandName.Size = UDim2.new(0, 90, 1, 0)
	brandName.BackgroundTransparency = 1
	brandName.Text = config.Title or "NEXUS"
	brandName.TextColor3 = Color3.fromRGB(244, 240, 232)
	brandName.Font = getUIFont("Bold")
	brandName.TextSize = 14
	brandName.TextXAlignment = Enum.TextXAlignment.Left
	brandName.TextTransparency = 1
	brandName.ZIndex = 12
	brandName.Parent = topBar
	self.BrandName = brandName

	-- Expand/Collapse Toggle Button (.u040-tog) matching exact reference image
	local togBtn = Instance.new("TextButton")
	togBtn.Name = "ExpandToggle"
	togBtn.AnchorPoint = Vector2.new(1, 0)
	togBtn.Position = UDim2.new(1, -2, 0, 14)
	togBtn.Size = UDim2.new(0, 20, 0, 26)
	togBtn.BackgroundColor3 = Color3.fromRGB(38, 40, 50)
	togBtn.BackgroundTransparency = 0
	togBtn.BorderSizePixel = 0
	togBtn.Text = ""
	togBtn.AutoButtonColor = false
	togBtn.ZIndex = 15
	togBtn.Parent = rail
	self.TogBtn = togBtn

	local tCorner = Instance.new("UICorner")
	tCorner.CornerRadius = UDim.new(0, 6)
	tCorner.Parent = togBtn

	local tStroke = Instance.new("UIStroke")
	tStroke.Color = Color3.fromRGB(65, 68, 82)
	tStroke.Transparency = 0.3
	tStroke.Thickness = 1
	tStroke.Parent = togBtn

	local togIcon = Instance.new("ImageLabel")
	togIcon.Name = "Chevron"
	togIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	togIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
	togIcon.Size = UDim2.new(0, 12, 0, 12)
	togIcon.BackgroundTransparency = 1
	togIcon.Image = LucianUI.Icons.Chevron
	togIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
	togIcon.Rotation = 0
	togIcon.ZIndex = 16
	togIcon.Parent = togBtn
	self.TogIcon = togIcon

	-- Nav List (.u040-nav) as a ScrollingFrame so 9+ tabs scroll smoothly
	local navList = Instance.new("ScrollingFrame")
	navList.Name = "NavList"
	navList.Position = UDim2.new(0, 8, 0, 50)
	navList.Size = UDim2.new(1, -16, 1, -102)
	navList.BackgroundTransparency = 1
	navList.BorderSizePixel = 0
	navList.ScrollBarThickness = 0
	navList.AutomaticCanvasSize = Enum.AutomaticSize.Y
	navList.CanvasSize = UDim2.new(0, 0, 0, 0)
	navList.ClipsDescendants = true
	navList.ZIndex = 11
	navList.Parent = rail
	self.NavList = navList

	local navPadding = Instance.new("UIPadding")
	navPadding.PaddingTop = UDim.new(0, 2)
	navPadding.PaddingBottom = UDim.new(0, 4)
	navPadding.Parent = navList

	-- Active Item Highlight Pill (.u040-hl)
	local activeHl = Instance.new("Frame")
	activeHl.Name = "ActiveHighlight"
	activeHl.Position = UDim2.new(0, 0, 0, 0)
	activeHl.Size = UDim2.new(1, 0, 0, 38)
	activeHl.BackgroundColor3 = Color3.fromRGB(244, 242, 238)
	activeHl.BackgroundTransparency = 0.86
	activeHl.BorderSizePixel = 0
	activeHl.ZIndex = 12
	activeHl.Parent = navList
	self.ActiveHl = activeHl

	local hlCorner = Instance.new("UICorner")
	hlCorner.CornerRadius = UDim.new(0, 12)
	hlCorner.Parent = activeHl

	-- Left Active Gradient Stripe
	local hlStripe = Instance.new("Frame")
	hlStripe.Name = "GradientStripe"
	hlStripe.AnchorPoint = Vector2.new(0, 0.5)
	hlStripe.Position = UDim2.new(0, 2, 0.5, 0)
	hlStripe.Size = UDim2.new(0, 3, 0, 20)
	hlStripe.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	hlStripe.BorderSizePixel = 0
	hlStripe.ZIndex = 13
	hlStripe.Parent = activeHl

	local sCorner = Instance.new("UICorner")
	sCorner.CornerRadius = UDim.new(1, 0)
	sCorner.Parent = hlStripe

	local sGrad = Instance.new("UIGradient")
	sGrad.Color = self.Theme.Gradient
	sGrad.Rotation = 90
	sGrad.Parent = hlStripe

	-- Bottom User Profile Card (.u040-me)
	local meCard = Instance.new("Frame")
	meCard.Name = "ProfileCard"
	meCard.Position = UDim2.new(0, 8, 1, -48)
	meCard.Size = UDim2.new(1, -16, 0, 40)
	meCard.BackgroundColor3 = Color3.fromRGB(244, 242, 238)
	meCard.BackgroundTransparency = 0.93
	meCard.BorderSizePixel = 0
	meCard.ZIndex = 11
	meCard.Parent = rail
	self.MeCard = meCard

	local meCorner = Instance.new("UICorner")
	meCorner.CornerRadius = UDim.new(0, 12)
	meCorner.Parent = meCard

	local avatar = Instance.new("Frame")
	avatar.Name = "Avatar"
	avatar.AnchorPoint = Vector2.new(0, 0.5)
	avatar.Position = UDim2.new(0, 7, 0.5, 0)
	avatar.Size = UDim2.new(0, 26, 0, 26)
	avatar.BackgroundTransparency = 1
	avatar.BorderSizePixel = 0
	avatar.ZIndex = 12
	avatar.Parent = meCard

	local avCorner = Instance.new("UICorner")
	avCorner.CornerRadius = UDim.new(1, 0)
	avCorner.Parent = avatar

	local avGrad = Instance.new("UIGradient")
	avGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 211, 168)),
		ColorSequenceKeypoint.new(0.6, Color3.fromRGB(255, 122, 147)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(139, 108, 255))
	})
	avGrad.Rotation = 45
	avGrad.Parent = avatar

	local avImg = Instance.new("ImageLabel")
	avImg.Name = "AvatarImage"
	avImg.AnchorPoint = Vector2.new(0.5, 0.5)
	avImg.Position = UDim2.new(0.5, 0, 0.5, 0)
	avImg.Size = UDim2.new(1, 0, 1, 0)
	avImg.BackgroundTransparency = 1
	avImg.ZIndex = 13
	avImg.Visible = false
	avImg.Parent = avatar
	self.AvatarImage = avImg

	local avImgCorner = Instance.new("UICorner")
	avImgCorner.CornerRadius = UDim.new(1, 0)
	avImgCorner.Parent = avImg

	if config.UserAvatar and config.UserAvatar ~= "" then
		avImg.Image = config.UserAvatar
		avImg.Visible = true
	else
		drawNexusMonogram(avatar, 30)
		task.spawn(function()
			local p = Players.LocalPlayer
			if p and p.UserId > 0 then
				local ok, url = pcall(function()
					return Players:GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
				end)
				if ok and url and avImg.Parent then
					avImg.Image = url
					avImg.Visible = true
				end
			end
		end)
	end

	local meName = Instance.new("TextLabel")
	meName.Name = "UserName"
	meName.Position = UDim2.new(0, 40, 0, 6)
	meName.Size = UDim2.new(0, 95, 0, 14)
	meName.BackgroundTransparency = 1
	meName.Text = config.UserName or "Ngmankhoi"
	meName.TextColor3 = Color3.fromRGB(244, 240, 232)
	meName.Font = getUIFont("Bold")
	meName.TextSize = 12
	meName.TextXAlignment = Enum.TextXAlignment.Left
	meName.TextTransparency = 1
	meName.ZIndex = 12
	meName.Parent = meCard
	self.MeName = meName

	local meRole = Instance.new("TextLabel")
	meRole.Name = "UserRole"
	meRole.Position = UDim2.new(0, 40, 0, 20)
	meRole.Size = UDim2.new(0, 95, 0, 12)
	meRole.BackgroundTransparency = 1
	meRole.Text = config.UserRole or "Lead Developer"
	meRole.TextColor3 = Color3.fromRGB(140, 138, 150)
	meRole.Font = getUIFont("Medium")
	meRole.TextSize = 10
	meRole.TextXAlignment = Enum.TextXAlignment.Left
	meRole.TextTransparency = 1
	meRole.ZIndex = 12
	meRole.Parent = meCard
	self.MeRole = meRole

	-- Right Main Content Card (.u040-main)
	local mainCard = Instance.new("Frame")
	mainCard.Name = "MainContent"
	mainCard.Position = UDim2.new(0, 64, 0, 0)
	mainCard.Size = UDim2.new(1, -64, 1, 0)
	mainCard.BackgroundColor3 = self.Theme.Surface
	mainCard.BorderSizePixel = 0
	mainCard.ClipsDescendants = false
	mainCard.ZIndex = 10
	mainCard.Parent = container
	self.MainCard = mainCard

	makeDraggable(container, mainCard)

	local mCorner = Instance.new("UICorner")
	mCorner.CornerRadius = UDim.new(0, 20)
	mCorner.Parent = mainCard

	local mStroke = Instance.new("UIStroke")
	mStroke.Color = self.Theme.Line
	mStroke.Transparency = self.Theme.LineTransparency
	mStroke.Thickness = 1
	mStroke.Parent = mainCard

	local mShadow = Instance.new("ImageLabel")
	mShadow.Name = "MainShadow"
	mShadow.AnchorPoint = Vector2.new(0.5, 0.5)
	mShadow.Position = UDim2.new(0.5, 0, 0.5, 6)
	mShadow.Size = UDim2.new(1, 20, 1, 20)
	mShadow.BackgroundTransparency = 1
	mShadow.Image = "rbxassetid://1316045217"
	mShadow.ImageColor3 = self.Theme.Shadow
	mShadow.ImageTransparency = 0.85
	mShadow.ScaleType = Enum.ScaleType.Slice
	mShadow.SliceCenter = Rect.new(10, 10, 118, 118)
	mShadow.ZIndex = 9
	mShadow.Parent = mainCard

	-- Main Header Labels
	local subtitleText = config.Subtitle or config.SubTitle or "HEAVYWEIGHT FISHING"
	local smallLabel = Instance.new("TextLabel")
	smallLabel.Name = "SubTitle"
	smallLabel.Position = UDim2.new(0, 18, 0, 12)
	smallLabel.Size = UDim2.new(1, -36, 0, 12)
	smallLabel.BackgroundTransparency = 1
	smallLabel.Text = subtitleText
	smallLabel.TextColor3 = self.Theme.Ink3
	smallLabel.Font = getUIFont("Bold")
	smallLabel.TextSize = 10
	smallLabel.TextXAlignment = Enum.TextXAlignment.Left
	smallLabel.ZIndex = 11
	smallLabel.Parent = mainCard
	self.SubTitleLabel = smallLabel

	local h3Title = Instance.new("TextLabel")
	h3Title.Name = "PageTitle"
	h3Title.Position = UDim2.new(0, 18, 0, 24)
	h3Title.Size = UDim2.new(1, -36, 0, 22)
	h3Title.BackgroundTransparency = 1
	h3Title.Text = "Home"
	h3Title.TextColor3 = self.Theme.Ink
	h3Title.Font = getUIFont("Bold")
	h3Title.TextSize = 18
	h3Title.TextXAlignment = Enum.TextXAlignment.Left
	h3Title.ZIndex = 11
	h3Title.Parent = mainCard
	self.H3Title = h3Title

	-- Content Area (Pages container)
	local pages = Instance.new("Frame")
	pages.Name = "PagesArea"
	pages.Position = UDim2.new(0, 0, 0, 50)
	pages.Size = UDim2.new(1, 0, 1, -52)
	pages.BackgroundTransparency = 1
	pages.ClipsDescendants = true
	pages.ZIndex = 11
	pages.Parent = mainCard
	self.PagesArea = pages

	-- Toggle Expand / Collapse Action
	local function toggleWide()
		self.IsWide = not self.IsWide
		local targetRailWidth = self.IsWide and 150 or 56
		local rot = self.IsWide and 180 or 0
		local alpha = self.IsWide and 0 or 1

		TweenService:Create(rail, SPRING_BOUNCE, { Size = UDim2.new(0, targetRailWidth, 1, 0) }):Play()
		TweenService:Create(mainCard, SPRING_BOUNCE, {
			Position = UDim2.new(0, targetRailWidth + 8, 0, 0),
			Size = UDim2.new(1, -(targetRailWidth + 8), 1, 0)
		}):Play()
		TweenService:Create(togIcon, SPRING_BOUNCE, { Rotation = rot }):Play()
		TweenService:Create(brandName, FAST_EASE, { TextTransparency = alpha }):Play()
		TweenService:Create(meName, FAST_EASE, { TextTransparency = alpha }):Play()
		TweenService:Create(meRole, FAST_EASE, { TextTransparency = alpha }):Play()

		for _, item in ipairs(self.RailItems) do
			TweenService:Create(item.Label, FAST_EASE, { TextTransparency = alpha }):Play()
			if item.Badge then
				local targetBadgeX = self.IsWide and 120 or 32
				TweenService:Create(item.Badge, SPRING_BOUNCE, { Position = UDim2.new(0, targetBadgeX, 0, 12) }):Play()
			end
		end
	end

	togBtn.MouseButton1Click:Connect(toggleWide)
	return self
end

-- ==============================================================================
-- TAB BUILDER & COMPONENT IMPLEMENTATION (100% NexusLib & Lucian Compatible)
-- ==============================================================================
function Element040:CreateTab(nameOrConfig: any)
	local tabTitle: string
	local tabIcon: string
	local tabBadge: number?

	if type(nameOrConfig) == "table" then
		tabTitle = tostring(nameOrConfig.Title or nameOrConfig.Name or "Tab")
		tabBadge = nameOrConfig.Badge
		if nameOrConfig.Icon and nameOrConfig.Icon ~= "" then
			tabIcon = nameOrConfig.Icon
		end
	else
		tabTitle = tostring(nameOrConfig or "Tab")
		tabBadge = nil
	end

	if not tabIcon or tabIcon == "" then
		local lower = string.lower(tabTitle)
		for key, iconId in pairs(TAB_ICON_MAP) do
			if string.find(lower, key, 1, true) then
				tabIcon = iconId
				break
			end
		end
		tabIcon = tabIcon or LucianUI.Icons.Grid
	end

	local index = #self.Tabs + 1
	local tab = {
		Index = index,
		Title = tabTitle,
		Icon = tabIcon,
		Badge = tabBadge,
		Window = self
	}

	-- Page Scrolling Container
	local page = Instance.new("ScrollingFrame")
	page.Name = "Page_" .. tabTitle
	page.Size = UDim2.new(1, 0, 1, 0)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.ScrollBarThickness = 2
	page.ScrollBarImageColor3 = self.Theme.Ink3
	page.ScrollBarImageTransparency = 0.6
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.CanvasSize = UDim2.new(0, 0, 0, 0)
	page.Visible = (index == 1)
	page.ZIndex = 12
	page.Parent = self.PagesArea
	tab.Page = page

	local pPadding = Instance.new("UIPadding")
	pPadding.PaddingTop = UDim.new(0, 4)
	pPadding.PaddingBottom = UDim.new(0, 12)
	pPadding.PaddingLeft = UDim.new(0, 14)
	pPadding.PaddingRight = UDim.new(0, 14)
	pPadding.Parent = page

	local pLayout = Instance.new("UIListLayout")
	pLayout.SortOrder = Enum.SortOrder.LayoutOrder
	pLayout.Padding = UDim.new(0, 7)
	pLayout.Parent = page

	-- Rail Item (.u040-it)
	local itBtn = Instance.new("TextButton")
	itBtn.Name = "Item_" .. index
	itBtn.Position = UDim2.new(0, 0, 0, (index - 1) * 40)
	itBtn.Size = UDim2.new(1, 0, 0, 38)
	itBtn.BackgroundTransparency = 1
	itBtn.Text = ""
	itBtn.AutoButtonColor = false
	itBtn.ZIndex = 14
	itBtn.Parent = self.NavList

	local itIcon = Instance.new("ImageLabel")
	itIcon.Name = "Icon"
	itIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	itIcon.Position = UDim2.new(0, 20, 0.5, 0)
	itIcon.Size = UDim2.new(0, 18, 0, 18)
	itIcon.BackgroundTransparency = 1
	itIcon.Image = tabIcon
	itIcon.ImageColor3 = (index == 1) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(140, 138, 150)
	itIcon.ZIndex = 15
	itIcon.Parent = itBtn

	local itLabel = Instance.new("TextLabel")
	itLabel.Name = "Label"
	itLabel.Position = UDim2.new(0, 44, 0, 0)
	itLabel.Size = UDim2.new(1, -50, 1, 0)
	itLabel.BackgroundTransparency = 1
	itLabel.Text = tabTitle
	itLabel.TextColor3 = Color3.fromRGB(244, 240, 232)
	itLabel.Font = getUIFont("Bold")
	itLabel.TextSize = 12
	itLabel.TextXAlignment = Enum.TextXAlignment.Left
	itLabel.TextTransparency = self.IsWide and 0 or 1
	itLabel.ZIndex = 15
	itLabel.Parent = itBtn

	local itBadge
	if tabBadge and tabBadge > 0 then
		itBadge = Instance.new("Frame")
		itBadge.Name = "Badge"
		itBadge.AnchorPoint = Vector2.new(0, 0.5)
		itBadge.Position = UDim2.new(0, self.IsWide and 120 or 32, 0, 12)
		itBadge.Size = UDim2.new(0, 14, 0, 14)
		itBadge.BackgroundColor3 = self.Theme.Danger
		itBadge.BorderSizePixel = 0
		itBadge.ZIndex = 16
		itBadge.Parent = itBtn

		local bCorn = Instance.new("UICorner")
		bCorn.CornerRadius = UDim.new(1, 0)
		bCorn.Parent = itBadge

		local bStrk = Instance.new("UIStroke")
		bStrk.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		bStrk.Color = self.Theme.Ink
		bStrk.Thickness = 2
		bStrk.Parent = itBadge

		local bText = Instance.new("TextLabel")
		bText.Size = UDim2.new(1, 0, 1, 0)
		bText.BackgroundTransparency = 1
		bText.Text = tostring(tabBadge)
		bText.TextColor3 = Color3.fromRGB(255, 255, 255)
		bText.TextSize = 9
		bText.Font = getUIFont("Bold")
		bText.ZIndex = 17
		bText.Parent = itBadge
	end

	table.insert(self.RailItems, {
		Button = itBtn,
		Icon = itIcon,
		Label = itLabel,
		Badge = itBadge
	})

	itBtn.MouseButton1Click:Connect(function()
		self:SelectTab(index)
	end)

	-- ==============================================================================
	-- COMPONENT BUILDERS (Supports both Tab and Section calling conventions)
	-- ==============================================================================

	-- Header Banner
	function tab:CreateHeader(config: { Title: string, Subtitle: string? })
		config = config or {}
		local headerFrame = Instance.new("Frame")
		headerFrame.Name = "Header"
		headerFrame.Size = UDim2.new(1, 0, 0, 42)
		headerFrame.BackgroundTransparency = 1
		headerFrame.Parent = page

		local hTitle = Instance.new("TextLabel")
		hTitle.Position = UDim2.new(0, 2, 0, 2)
		hTitle.Size = UDim2.new(1, -4, 0, 20)
		hTitle.BackgroundTransparency = 1
		hTitle.Text = config.Title or "Overview"
		hTitle.TextColor3 = self.Window.Theme.Ink
		hTitle.Font = getUIFont("Bold")
		hTitle.TextSize = 15
		hTitle.TextXAlignment = Enum.TextXAlignment.Left
		hTitle.Parent = headerFrame

		local hSub = Instance.new("TextLabel")
		hSub.Position = UDim2.new(0, 2, 0, 22)
		hSub.Size = UDim2.new(1, -4, 0, 16)
		hSub.BackgroundTransparency = 1
		hSub.Text = config.Subtitle or ""
		hSub.TextColor3 = self.Window.Theme.Ink3
		hSub.Font = getUIFont("Medium")
		hSub.TextSize = 11
		hSub.TextXAlignment = Enum.TextXAlignment.Left
		hSub.Parent = headerFrame

		return { _frame = headerFrame }
	end

	-- Stat Row: Creates Stat_1, Stat_2, Stat_3 with TextLabel (size >= 18) for live update compatibility
	function tab:CreateStatRow(stats: { { Title: string, Value: any, Color: Color3? } })
		stats = stats or {}
		local rowFrame = Instance.new("Frame")
		rowFrame.Name = "Stats"
		rowFrame.Size = UDim2.new(1, 0, 0, 70)
		rowFrame.BackgroundTransparency = 1
		rowFrame.Parent = page

		local layout = Instance.new("UIListLayout")
		layout.FillDirection = Enum.FillDirection.Horizontal
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Padding = UDim.new(0, 8)
		layout.Parent = rowFrame

		local count = math.max(#stats, 1)
		for i, stat in ipairs(stats) do
			local statOuter = Instance.new("Frame")
			statOuter.Name = "Stat_" .. i
			statOuter.LayoutOrder = i
			statOuter.Size = UDim2.new(1 / count, -(8 * (count - 1) / count), 1, 0)
			statOuter.BackgroundColor3 = self.Window.Theme.Surface2
			statOuter.BorderSizePixel = 0
			statOuter.Parent = rowFrame

			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 12)
			corner.Parent = statOuter

			local stroke = Instance.new("UIStroke")
			stroke.Color = self.Window.Theme.Line
			stroke.Transparency = self.Window.Theme.LineTransparency
			stroke.Thickness = 1
			stroke.Parent = statOuter

			local accent = Instance.new("Frame")
			accent.Name = "Accent"
			accent.Position = UDim2.new(0, 10, 0, 10)
			accent.Size = UDim2.new(0, 16, 0, 3)
			accent.BackgroundColor3 = stat.Color or self.Window.Theme.Accent
			accent.BorderSizePixel = 0
			accent.Parent = statOuter

			local aCorner = Instance.new("UICorner")
			aCorner.CornerRadius = UDim.new(1, 0)
			aCorner.Parent = accent

			local valLabel = Instance.new("TextLabel")
			valLabel.Name = "ValueLabel"
			valLabel.Position = UDim2.new(0, 10, 0, 16)
			valLabel.Size = UDim2.new(1, -12, 0, 24)
			valLabel.BackgroundTransparency = 1
			valLabel.Text = (stat.Value ~= nil and stat.Value ~= "") and tostring(stat.Value) or "-"
			valLabel.TextColor3 = self.Window.Theme.Ink
			valLabel.Font = getUIFont("Bold")
			valLabel.TextSize = 18
			valLabel.TextXAlignment = Enum.TextXAlignment.Left
			valLabel.TextTruncate = Enum.TextTruncate.AtEnd
			valLabel.TextWrapped = false
			valLabel.Parent = statOuter

			-- Guard against empty string polling (e.g. unequipped bait returning "")
			valLabel:GetPropertyChangedSignal("Text"):Connect(function()
				if valLabel.Text == "" or valLabel.Text == " " then
					valLabel.Text = "None"
				end
			end)

			local titleLabel = Instance.new("TextLabel")
			titleLabel.Name = "TitleLabel"
			titleLabel.Position = UDim2.new(0, 10, 0, 44)
			titleLabel.Size = UDim2.new(1, -12, 0, 16)
			titleLabel.BackgroundTransparency = 1
			titleLabel.Text = tostring(stat.Title or "STAT")
			titleLabel.TextColor3 = self.Window.Theme.Ink3
			titleLabel.Font = getUIFont("Bold")
			titleLabel.TextSize = 11
			titleLabel.TextXAlignment = Enum.TextXAlignment.Left
			titleLabel.TextTruncate = Enum.TextTruncate.None
			titleLabel.TextWrapped = false
			titleLabel.Parent = statOuter
		end

		return { _frame = rowFrame }
	end

	-- Featured Card (Discord / Announcement / Info card)
	function tab:CreateFeaturedCard(config: { Tag: string?, Title: string?, Description: string?, ButtonText: string?, Callback: (() -> ())? })
		config = config or {}
		local card = Instance.new("Frame")
		card.Name = "FeaturedCard"
		card.Size = UDim2.new(1, 0, 0, 100)
		card.BackgroundColor3 = self.Window.Theme.Surface2
		card.BorderSizePixel = 0
		card.Parent = page

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 14)
		corner.Parent = card

		local stroke = Instance.new("UIStroke")
		stroke.Color = self.Window.Theme.Line
		stroke.Transparency = self.Window.Theme.LineTransparency
		stroke.Thickness = 1
		stroke.Parent = card

		local tagPill = Instance.new("Frame")
		tagPill.Name = "TagPill"
		tagPill.Position = UDim2.new(0, 14, 0, 10)
		tagPill.Size = UDim2.new(0, 0, 0, 18)
		tagPill.AutomaticSize = Enum.AutomaticSize.X
		tagPill.BackgroundColor3 = self.Window.Theme.Surface3
		tagPill.BorderSizePixel = 0
		tagPill.Parent = card

		local tpCorner = Instance.new("UICorner")
		tpCorner.CornerRadius = UDim.new(1, 0)
		tpCorner.Parent = tagPill

		local tagLabel = Instance.new("TextLabel")
		tagLabel.Size = UDim2.new(1, 0, 1, 0)
		tagLabel.AutomaticSize = Enum.AutomaticSize.X
		tagLabel.BackgroundTransparency = 1
		tagLabel.Text = "  " .. string.upper(config.Tag or "NEXUS") .. "  "
		tagLabel.TextColor3 = self.Window.Theme.Accent
		tagLabel.Font = getUIFont("Bold")
		tagLabel.TextSize = 9
		tagLabel.Parent = tagPill

		local titleLabel = Instance.new("TextLabel")
		titleLabel.Name = "CardTitle"
		titleLabel.Position = UDim2.new(0, 14, 0, 32)
		titleLabel.Size = UDim2.new(1, -120, 0, 18)
		titleLabel.BackgroundTransparency = 1
		titleLabel.Text = config.Title or "Featured"
		titleLabel.TextColor3 = self.Window.Theme.Ink
		titleLabel.Font = getUIFont("Bold")
		titleLabel.TextSize = 14
		titleLabel.TextXAlignment = Enum.TextXAlignment.Left
		titleLabel.Parent = card

		local descLabel = Instance.new("TextLabel")
		descLabel.Name = "CardDesc"
		descLabel.Position = UDim2.new(0, 14, 0, 52)
		descLabel.Size = UDim2.new(1, -120, 0, 38)
		descLabel.BackgroundTransparency = 1
		descLabel.Text = config.Description or ""
		descLabel.TextColor3 = self.Window.Theme.Ink2
		descLabel.Font = getUIFont("Medium")
		descLabel.TextSize = 10
		descLabel.TextWrapped = true
		descLabel.TextXAlignment = Enum.TextXAlignment.Left
		descLabel.TextYAlignment = Enum.TextYAlignment.Top
		descLabel.Parent = card

		local btn = Instance.new("TextButton")
		btn.Name = "CardButton"
		btn.AnchorPoint = Vector2.new(1, 0.5)
		btn.Position = UDim2.new(1, -14, 0.5, 0)
		btn.Size = UDim2.new(0, 86, 0, 32)
		btn.BackgroundColor3 = self.Window.Theme.Accent
		btn.BorderSizePixel = 0
		btn.Text = config.ButtonText or "OPEN"
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.Font = getUIFont("Bold")
		btn.TextSize = 11
		btn.AutoButtonColor = true
		btn.Parent = card

		local bCorner = Instance.new("UICorner")
		bCorner.CornerRadius = UDim.new(0, 10)
		bCorner.Parent = btn

		if config.Callback then
			btn.MouseButton1Click:Connect(function()
				task.spawn(config.Callback)
			end)
		end

		return { _frame = card }
	end

	-- Action Row & Card Group
	function tab:CreateActionRow(actions)
		local results = {}
		for _, action in ipairs(actions or {}) do
			table.insert(results, self:CreateButton(action))
		end
		return results
	end

	function tab:CreateCardGroup(cards)
		local results = {}
		for _, card in ipairs(cards or {}) do
			table.insert(results, self:CreateButton({
				Name = card.Title or card.Name,
				Callback = card.Callback
			}))
		end
		return results
	end

	-- Section Header
	function tab:CreateSection(title: string)
		local sec = Instance.new("Frame")
		sec.Name = "Section_" .. tostring(title)
		sec.Size = UDim2.new(1, 0, 0, 22)
		sec.BackgroundTransparency = 1
		sec.Parent = page

		local sLabel = Instance.new("TextLabel")
		sLabel.Position = UDim2.new(0, 2, 0, 0)
		sLabel.Size = UDim2.new(1, -4, 1, 0)
		sLabel.BackgroundTransparency = 1
		sLabel.Text = string.upper(tostring(title))
		sLabel.TextColor3 = self.Window.Theme.Ink3
		sLabel.Font = getUIFont("Bold")
		sLabel.TextSize = 10
		sLabel.TextXAlignment = Enum.TextXAlignment.Left
		sLabel.Parent = sec

		local sectionObj = {
			_tab = self,
			_frame = sec,
			CreateToggle = function(_, cfg) return self:CreateToggle(cfg) end,
			CreateButton = function(_, cfg) return self:CreateButton(cfg) end,
			CreateSlider = function(_, cfg) return self:CreateSlider(cfg) end,
			CreateDropdown = function(_, cfg) return self:CreateDropdown(cfg) end,
			CreateMultiDropdown = function(_, cfg) return self:CreateMultiDropdown(cfg) end,
			CreateTextbox = function(_, cfg) return self:CreateTextbox(cfg) end,
			CreateLabel = function(_, text) return self:CreateLabel(text) end,
			CreateKeybind = function(_, cfg) return self:CreateKeybind(cfg) end,
			CreateCardGroup = function(_, cfg) return self:CreateCardGroup(cfg) end,
			CreateActionRow = function(_, cfg) return self:CreateActionRow(cfg) end,
			CreateBlock = function(_, cfg) return self:CreateBlock(cfg) end,
			CreateFeaturedCard = function(_, cfg) return self:CreateFeaturedCard(cfg) end,
			CreateStatRow = function(_, cfg) return self:CreateStatRow(cfg) end,
		}

		return sectionObj
	end

	-- Toggle Switch
	function tab:CreateToggle(tConfig: any)
		tConfig = tConfig or {}
		local title = tConfig.Name or tConfig.Title or "Toggle"
		local state = tConfig.Default == true

		local blk = Instance.new("Frame")
		blk.Name = "Toggle_" .. title
		blk.Size = UDim2.new(1, 0, 0, 44)
		blk.BackgroundColor3 = self.Window.Theme.Surface2
		blk.BorderSizePixel = 0
		blk.Parent = page

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 12)
		corner.Parent = blk

		local stroke = Instance.new("UIStroke")
		stroke.Color = self.Window.Theme.Line
		stroke.Transparency = self.Window.Theme.LineTransparency
		stroke.Thickness = 1
		stroke.Parent = blk

		local tLabel = Instance.new("TextLabel")
		tLabel.Position = UDim2.new(0, 14, 0, 0)
		tLabel.Size = UDim2.new(1, -64, 1, 0)
		tLabel.BackgroundTransparency = 1
		tLabel.Text = title
		tLabel.TextColor3 = self.Window.Theme.Ink
		tLabel.Font = getUIFont("Bold")
		tLabel.TextSize = 12
		tLabel.TextXAlignment = Enum.TextXAlignment.Left
		tLabel.Parent = blk

		local switch = Instance.new("TextButton")
		switch.AnchorPoint = Vector2.new(1, 0.5)
		switch.Position = UDim2.new(1, -12, 0.5, 0)
		switch.Size = UDim2.new(0, 38, 0, 22)
		switch.BackgroundColor3 = state and self.Window.Theme.Accent or self.Window.Theme.Surface3
		switch.BorderSizePixel = 0
		switch.Text = ""
		switch.AutoButtonColor = false
		switch.Parent = blk

		local sCorner = Instance.new("UICorner")
		sCorner.CornerRadius = UDim.new(1, 0)
		sCorner.Parent = switch

		local knob = Instance.new("Frame")
		knob.AnchorPoint = Vector2.new(0, 0.5)
		knob.Position = state and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
		knob.Size = UDim2.new(0, 16, 0, 16)
		knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		knob.BorderSizePixel = 0
		knob.Parent = switch

		local kCorner = Instance.new("UICorner")
		kCorner.CornerRadius = UDim.new(1, 0)
		kCorner.Parent = knob

		local function set(val, emit)
			state = val == true
			local targetPos = state and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
			local targetCol = state and self.Window.Theme.Accent or self.Window.Theme.Surface3
			TweenService:Create(knob, SPRING_BOUNCE, { Position = targetPos }):Play()
			TweenService:Create(switch, FAST_EASE, { BackgroundColor3 = targetCol }):Play()
			if emit and tConfig.Callback then
				task.spawn(tConfig.Callback, state)
			end
		end

		switch.MouseButton1Click:Connect(function()
			set(not state, true)
		end)

		local handle = {
			_frame = blk,
			Get = function()
				return state
			end,
			Set = function(selfOrVal, maybeVal, emit)
				local v = (maybeVal ~= nil) and maybeVal or selfOrVal
				set(v == true, emit ~= false)
			end,
			SetValue = function(selfOrVal, maybeVal, emit)
				local v = (maybeVal ~= nil) and maybeVal or selfOrVal
				set(v == true, emit ~= false)
			end
		}

		return handle
	end

	-- Action Button
	function tab:CreateButton(btnConfig: any)
		btnConfig = btnConfig or {}
		local title = btnConfig.Name or btnConfig.Title or "Button"

		local blk = Instance.new("Frame")
		blk.Name = "Button_" .. title
		blk.Size = UDim2.new(1, 0, 0, 44)
		blk.BackgroundColor3 = self.Window.Theme.Surface2
		blk.BorderSizePixel = 0
		blk.Parent = page

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 12)
		corner.Parent = blk

		local stroke = Instance.new("UIStroke")
		stroke.Color = self.Window.Theme.Line
		stroke.Transparency = self.Window.Theme.LineTransparency
		stroke.Thickness = 1
		stroke.Parent = blk

		local tLabel = Instance.new("TextLabel")
		tLabel.Position = UDim2.new(0, 14, 0, 0)
		tLabel.Size = UDim2.new(1, -44, 1, 0)
		tLabel.BackgroundTransparency = 1
		tLabel.Text = title
		tLabel.TextColor3 = self.Window.Theme.Ink
		tLabel.Font = getUIFont("Bold")
		tLabel.TextSize = 12
		tLabel.TextXAlignment = Enum.TextXAlignment.Left
		tLabel.Parent = blk

		local arr = Instance.new("ImageLabel")
		arr.AnchorPoint = Vector2.new(1, 0.5)
		arr.Position = UDim2.new(1, -12, 0.5, 0)
		arr.Size = UDim2.new(0, 12, 0, 12)
		arr.BackgroundTransparency = 1
		arr.Image = LucianUI.Icons.Chevron
		arr.ImageColor3 = self.Window.Theme.Ink3
		arr.Rotation = 0
		arr.Parent = blk

		local hitBtn = Instance.new("TextButton")
		hitBtn.Size = UDim2.new(1, 0, 1, 0)
		hitBtn.BackgroundTransparency = 1
		hitBtn.Text = ""
		hitBtn.Parent = blk

		hitBtn.MouseButton1Click:Connect(function()
			TweenService:Create(blk, FAST_EASE, { BackgroundColor3 = self.Window.Theme.Surface3 }):Play()
			task.delay(0.12, function()
				if blk.Parent then
					TweenService:Create(blk, FAST_EASE, { BackgroundColor3 = self.Window.Theme.Surface2 }):Play()
				end
			end)
			if btnConfig.Callback then
				task.spawn(btnConfig.Callback)
			end
		end)

		return { _frame = blk }
	end

	-- Slider Control
	function tab:CreateSlider(sConfig: any)
		sConfig = sConfig or {}
		local title = sConfig.Name or sConfig.Title or "Slider"
		local minVal = sConfig.Min or 0
		local maxVal = sConfig.Max or 100
		if maxVal < minVal then minVal, maxVal = maxVal, minVal end
		local range = maxVal - minVal
		local currentVal = math.clamp(sConfig.Default or minVal, minVal, maxVal)
		local suffix = sConfig.Suffix or ""
		local step = tonumber(sConfig.Step or sConfig.Increment)

		local blk = Instance.new("Frame")
		blk.Name = "Slider_" .. title
		blk.Size = UDim2.new(1, 0, 0, 48)
		blk.BackgroundColor3 = self.Window.Theme.Surface2
		blk.BorderSizePixel = 0
		blk.Parent = page

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 12)
		corner.Parent = blk

		local stroke = Instance.new("UIStroke")
		stroke.Color = self.Window.Theme.Line
		stroke.Transparency = self.Window.Theme.LineTransparency
		stroke.Thickness = 1
		stroke.Parent = blk

		local tLabel = Instance.new("TextLabel")
		tLabel.Position = UDim2.new(0, 14, 0, 6)
		tLabel.Size = UDim2.new(0.6, -14, 0, 16)
		tLabel.BackgroundTransparency = 1
		tLabel.Text = title
		tLabel.TextColor3 = self.Window.Theme.Ink
		tLabel.Font = getUIFont("Bold")
		tLabel.TextSize = 12
		tLabel.TextXAlignment = Enum.TextXAlignment.Left
		tLabel.Parent = blk

		local vLabel = Instance.new("TextLabel")
		vLabel.Position = UDim2.new(0.6, 0, 0, 6)
		vLabel.Size = UDim2.new(0.4, -14, 0, 16)
		vLabel.BackgroundTransparency = 1
		vLabel.Text = tostring(currentVal) .. suffix
		vLabel.TextColor3 = self.Window.Theme.Accent
		vLabel.Font = getUIFont("Bold")
		vLabel.TextSize = 11
		vLabel.TextXAlignment = Enum.TextXAlignment.Right
		vLabel.Parent = blk

		local track = Instance.new("Frame")
		track.Position = UDim2.new(0, 14, 0, 28)
		track.Size = UDim2.new(1, -28, 0, 6)
		track.BackgroundColor3 = self.Window.Theme.Surface3
		track.BorderSizePixel = 0
		track.Parent = blk

		local trCorn = Instance.new("UICorner")
		trCorn.CornerRadius = UDim.new(1, 0)
		trCorn.Parent = track

		local frac = range > 0 and math.clamp((currentVal - minVal) / range, 0, 1) or 0
		local fill = Instance.new("Frame")
		fill.Size = UDim2.new(frac, 0, 1, 0)
		fill.BackgroundColor3 = self.Window.Theme.Accent
		fill.BorderSizePixel = 0
		fill.Parent = track

		local fCorn = Instance.new("UICorner")
		fCorn.CornerRadius = UDim.new(1, 0)
		fCorn.Parent = fill

		local knob = Instance.new("Frame")
		knob.AnchorPoint = Vector2.new(0.5, 0.5)
		knob.Position = UDim2.new(frac, 0, 0.5, 0)
		knob.Size = UDim2.new(0, 14, 0, 14)
		knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		knob.BorderSizePixel = 0
		knob.Parent = track

		local kCorn = Instance.new("UICorner")
		kCorn.CornerRadius = UDim.new(1, 0)
		kCorn.Parent = knob

		local hit = Instance.new("TextButton")
		hit.Position = UDim2.new(0, 10, 0, 18)
		hit.Size = UDim2.new(1, -20, 0, 26)
		hit.BackgroundTransparency = 1
		hit.Text = ""
		hit.Parent = blk

		local sliding = false
		local function setValFromX(x, emit)
			local tPos = track.AbsolutePosition.X
			local tSize = math.max(1, track.AbsoluteSize.X)
			local rawFrac = math.clamp((x - tPos) / tSize, 0, 1)
			local rawVal = minVal + range * rawFrac
			if step and step > 0 and range > 0 then
				rawVal = minVal + math.round((rawVal - minVal) / step) * step
			end
			currentVal = math.clamp(rawVal, minVal, maxVal)
			local finalFrac = range > 0 and math.clamp((currentVal - minVal) / range, 0, 1) or 0
			fill.Size = UDim2.new(finalFrac, 0, 1, 0)
			knob.Position = UDim2.new(finalFrac, 0, 0.5, 0)
			vLabel.Text = tostring(currentVal) .. suffix
			if emit and sConfig.Callback then
				task.spawn(sConfig.Callback, currentVal)
			end
		end

		hit.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				sliding = true
				setValFromX(input.Position.X, true)
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				setValFromX(input.Position.X, true)
			end
		end)

		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				sliding = false
			end
		end)

		local handle = {
			_frame = blk,
			Get = function()
				return currentVal
			end,
			Set = function(selfOrVal, maybeVal, emit)
				local v = tonumber(maybeVal ~= nil and maybeVal or selfOrVal) or minVal
				currentVal = math.clamp(v, minVal, maxVal)
				local finalFrac = range > 0 and math.clamp((currentVal - minVal) / range, 0, 1) or 0
				fill.Size = UDim2.new(finalFrac, 0, 1, 0)
				knob.Position = UDim2.new(finalFrac, 0, 0.5, 0)
				vLabel.Text = tostring(currentVal) .. suffix
				if emit and sConfig.Callback then
					task.spawn(sConfig.Callback, currentVal)
				end
			end,
			SetValue = function(selfOrVal, maybeVal, emit)
				local v = tonumber(maybeVal ~= nil and maybeVal or selfOrVal) or minVal
				currentVal = math.clamp(v, minVal, maxVal)
				local finalFrac = range > 0 and math.clamp((currentVal - minVal) / range, 0, 1) or 0
				fill.Size = UDim2.new(finalFrac, 0, 1, 0)
				knob.Position = UDim2.new(finalFrac, 0, 0.5, 0)
				vLabel.Text = tostring(currentVal) .. suffix
				if emit and sConfig.Callback then
					task.spawn(sConfig.Callback, currentVal)
				end
			end
		}

		return handle
	end

	-- Single Dropdown
	function tab:CreateDropdown(dConfig: any)
		dConfig = dConfig or {}
		local title = dConfig.Name or dConfig.Title or "Dropdown"
		local options = dConfig.Options or {}
		local selected = dConfig.Default or options[1] or "Select"
		local expanded = false
		local rowHeight = 44
		local optHeight = 28

		local container = Instance.new("Frame")
		container.Name = "Dropdown_" .. title
		container.Size = UDim2.new(1, 0, 0, rowHeight)
		container.BackgroundColor3 = self.Window.Theme.Surface2
		container.BorderSizePixel = 0
		container.ClipsDescendants = true
		container.Parent = page

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 12)
		corner.Parent = container

		local stroke = Instance.new("UIStroke")
		stroke.Color = self.Window.Theme.Line
		stroke.Transparency = self.Window.Theme.LineTransparency
		stroke.Thickness = 1
		stroke.Parent = container

		local topBtn = Instance.new("TextButton")
		topBtn.Name = "TopRow"
		topBtn.Size = UDim2.new(1, 0, 0, rowHeight)
		topBtn.BackgroundTransparency = 1
		topBtn.Text = ""
		topBtn.Parent = container

		local tLabel = Instance.new("TextLabel")
		tLabel.Position = UDim2.new(0, 14, 0, 0)
		tLabel.Size = UDim2.new(0.5, -14, 1, 0)
		tLabel.BackgroundTransparency = 1
		tLabel.Text = title
		tLabel.TextColor3 = self.Window.Theme.Ink
		tLabel.Font = getUIFont("Bold")
		tLabel.TextSize = 12
		tLabel.TextXAlignment = Enum.TextXAlignment.Left
		tLabel.Parent = topBtn

		local valLabel = Instance.new("TextLabel")
		valLabel.Position = UDim2.new(0.5, 0, 0, 0)
		valLabel.Size = UDim2.new(0.5, -34, 1, 0)
		valLabel.BackgroundTransparency = 1
		valLabel.Text = tostring(selected)
		valLabel.TextColor3 = self.Window.Theme.Accent
		valLabel.Font = getUIFont("Bold")
		valLabel.TextSize = 11
		valLabel.TextXAlignment = Enum.TextXAlignment.Right
		valLabel.TextTruncate = Enum.TextTruncate.AtEnd
		valLabel.Parent = topBtn

		local arr = Instance.new("ImageLabel")
		arr.AnchorPoint = Vector2.new(1, 0.5)
		arr.Position = UDim2.new(1, -12, 0.5, 0)
		arr.Size = UDim2.new(0, 12, 0, 12)
		arr.BackgroundTransparency = 1
		arr.Image = LucianUI.Icons.Chevron
		arr.ImageColor3 = self.Window.Theme.Ink3
		arr.Rotation = 90
		arr.Parent = topBtn

		local optContainer = Instance.new("Frame")
		optContainer.Position = UDim2.new(0, 0, 0, rowHeight)
		optContainer.Size = UDim2.new(1, 0, 0, #options * optHeight)
		optContainer.BackgroundTransparency = 1
		optContainer.Parent = container

		local optionButtons = {}
		local function selectOption(optName, emit)
			selected = optName
			valLabel.Text = tostring(selected)
			for name, btn in pairs(optionButtons) do
				local isMatch = (name == selected)
				btn.BackgroundColor3 = isMatch and self.Window.Theme.Surface3 or self.Window.Theme.Surface2
				local txt = btn:FindFirstChild("OptText")
				if txt then
					txt.TextColor3 = isMatch and self.Window.Theme.Accent or self.Window.Theme.Ink2
					txt.Font = isMatch and getUIFont("Bold") or getUIFont("Medium")
				end
			end
			if emit and dConfig.Callback then
				task.spawn(dConfig.Callback, selected)
			end
		end

		for i, optName in ipairs(options) do
			local optBtn = Instance.new("TextButton")
			optBtn.Name = "Opt_" .. i
			optBtn.Position = UDim2.new(0, 0, 0, (i - 1) * optHeight)
			optBtn.Size = UDim2.new(1, 0, 0, optHeight)
			optBtn.BackgroundColor3 = (optName == selected) and self.Window.Theme.Surface3 or self.Window.Theme.Surface2
			optBtn.BorderSizePixel = 0
			optBtn.Text = ""
			optBtn.Parent = optContainer
			optionButtons[optName] = optBtn

			local txt = Instance.new("TextLabel")
			txt.Name = "OptText"
			txt.Position = UDim2.new(0, 18, 0, 0)
			txt.Size = UDim2.new(1, -26, 1, 0)
			txt.BackgroundTransparency = 1
			txt.Text = tostring(optName)
			txt.TextColor3 = (optName == selected) and self.Window.Theme.Accent or self.Window.Theme.Ink2
			txt.Font = (optName == selected) and getUIFont("Bold") or getUIFont("Medium")
			txt.TextSize = 11
			txt.TextXAlignment = Enum.TextXAlignment.Left
			txt.Parent = optBtn

			optBtn.MouseButton1Click:Connect(function()
				selectOption(optName, true)
				expanded = false
				TweenService:Create(arr, FAST_EASE, { Rotation = 90 }):Play()
				TweenService:Create(container, FAST_EASE, { Size = UDim2.new(1, 0, 0, rowHeight) }):Play()
			end)
		end

		topBtn.MouseButton1Click:Connect(function()
			expanded = not expanded
			local targetH = expanded and (rowHeight + #options * optHeight) or rowHeight
			local targetRot = expanded and -90 or 90
			TweenService:Create(arr, FAST_EASE, { Rotation = targetRot }):Play()
			TweenService:Create(container, FAST_EASE, { Size = UDim2.new(1, 0, 0, targetH) }):Play()
		end)

		local handle = {
			_frame = container,
			Get = function()
				return selected
			end,
			Set = function(selfOrVal, maybeVal, emit)
				local v = maybeVal ~= nil and maybeVal or selfOrVal
				selectOption(v, emit ~= false)
			end,
			SetValue = function(selfOrVal, maybeVal, emit)
				local v = maybeVal ~= nil and maybeVal or selfOrVal
				selectOption(v, emit ~= false)
			end
		}

		return handle
	end

	-- Multi-select Dropdown
	function tab:CreateMultiDropdown(mConfig: any)
		mConfig = mConfig or {}
		local title = mConfig.Name or mConfig.Title or "Multi-select"
		local options = mConfig.Options or {}
		local selectedMap = {}
		local selectedList = {}

		for _, opt in ipairs(mConfig.Default or {}) do
			if not selectedMap[opt] then
				selectedMap[opt] = true
				table.insert(selectedList, opt)
			end
		end

		local expanded = false
		local rowHeight = 44
		local optHeight = 28

		local container = Instance.new("Frame")
		container.Name = "MultiDropdown_" .. title
		container.Size = UDim2.new(1, 0, 0, rowHeight)
		container.BackgroundColor3 = self.Window.Theme.Surface2
		container.BorderSizePixel = 0
		container.ClipsDescendants = true
		container.Parent = page

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 12)
		corner.Parent = container

		local stroke = Instance.new("UIStroke")
		stroke.Color = self.Window.Theme.Line
		stroke.Transparency = self.Window.Theme.LineTransparency
		stroke.Thickness = 1
		stroke.Parent = container

		local topBtn = Instance.new("TextButton")
		topBtn.Name = "TopRow"
		topBtn.Size = UDim2.new(1, 0, 0, rowHeight)
		topBtn.BackgroundTransparency = 1
		topBtn.Text = ""
		topBtn.Parent = container

		local tLabel = Instance.new("TextLabel")
		tLabel.Position = UDim2.new(0, 14, 0, 0)
		tLabel.Size = UDim2.new(0.45, -14, 1, 0)
		tLabel.BackgroundTransparency = 1
		tLabel.Text = title
		tLabel.TextColor3 = self.Window.Theme.Ink
		tLabel.Font = getUIFont("Bold")
		tLabel.TextSize = 12
		tLabel.TextXAlignment = Enum.TextXAlignment.Left
		tLabel.Parent = topBtn

		local summaryLabel = Instance.new("TextLabel")
		summaryLabel.Position = UDim2.new(0.45, 0, 0, 0)
		summaryLabel.Size = UDim2.new(0.55, -34, 1, 0)
		summaryLabel.BackgroundTransparency = 1
		summaryLabel.TextColor3 = self.Window.Theme.Ink3
		summaryLabel.Font = getUIFont("Medium")
		summaryLabel.TextSize = 11
		summaryLabel.TextXAlignment = Enum.TextXAlignment.Right
		summaryLabel.TextTruncate = Enum.TextTruncate.AtEnd
		summaryLabel.Parent = topBtn

		local arr = Instance.new("ImageLabel")
		arr.AnchorPoint = Vector2.new(1, 0.5)
		arr.Position = UDim2.new(1, -12, 0.5, 0)
		arr.Size = UDim2.new(0, 12, 0, 12)
		arr.BackgroundTransparency = 1
		arr.Image = LucianUI.Icons.Chevron
		arr.ImageColor3 = self.Window.Theme.Ink3
		arr.Rotation = 90
		arr.Parent = topBtn

		local optContainer = Instance.new("Frame")
		optContainer.Position = UDim2.new(0, 0, 0, rowHeight)
		optContainer.Size = UDim2.new(1, 0, 0, #options * optHeight)
		optContainer.BackgroundTransparency = 1
		optContainer.Parent = container

		local optionButtons = {}

		local function updateSummary()
			if #selectedList == 0 then
				summaryLabel.Text = "None"
			elseif #selectedList <= 2 then
				summaryLabel.Text = table.concat(selectedList, ", ")
			else
				summaryLabel.Text = selectedList[1] .. ", " .. selectedList[2] .. " +" .. (#selectedList - 2) .. " more"
			end
			for optName, optBtn in pairs(optionButtons) do
				local isSel = selectedMap[optName] == true
				optBtn.BackgroundColor3 = isSel and self.Window.Theme.Surface3 or self.Window.Theme.Surface2
				local iconCheck = optBtn:FindFirstChild("CheckIcon")
				if iconCheck then
					iconCheck.Visible = isSel
				end
				local text = optBtn:FindFirstChild("OptText")
				if text then
					text.TextColor3 = isSel and self.Window.Theme.Accent or self.Window.Theme.Ink2
					text.Font = isSel and getUIFont("Bold") or getUIFont("Medium")
				end
			end
		end

		for i, optName in ipairs(options) do
			local optBtn = Instance.new("TextButton")
			optBtn.Name = "Opt_" .. i
			optBtn.Position = UDim2.new(0, 0, 0, (i - 1) * optHeight)
			optBtn.Size = UDim2.new(1, 0, 0, optHeight)
			optBtn.BackgroundTransparency = 0
			optBtn.BorderSizePixel = 0
			optBtn.Text = ""
			optBtn.Parent = optContainer
			optionButtons[optName] = optBtn

			local chk = Instance.new("ImageLabel")
			chk.Name = "CheckIcon"
			chk.AnchorPoint = Vector2.new(0, 0.5)
			chk.Position = UDim2.new(0, 14, 0.5, 0)
			chk.Size = UDim2.new(0, 14, 0, 14)
			chk.BackgroundTransparency = 1
			chk.Image = LucianUI.Icons.Check
			chk.ImageColor3 = self.Window.Theme.Accent
			chk.Visible = false
			chk.Parent = optBtn

			local txt = Instance.new("TextLabel")
			txt.Name = "OptText"
			txt.Position = UDim2.new(0, 36, 0, 0)
			txt.Size = UDim2.new(1, -44, 1, 0)
			txt.BackgroundTransparency = 1
			txt.Text = tostring(optName)
			txt.TextSize = 11
			txt.TextXAlignment = Enum.TextXAlignment.Left
			txt.Parent = optBtn

			optBtn.MouseButton1Click:Connect(function()
				if selectedMap[optName] then
					selectedMap[optName] = nil
					for idx, v in ipairs(selectedList) do
						if v == optName then
							table.remove(selectedList, idx)
							break
						end
					end
				else
					selectedMap[optName] = true
					table.insert(selectedList, optName)
				end
				updateSummary()
				if mConfig.Callback then
					task.spawn(mConfig.Callback, selectedList)
				end
			end)
		end

		updateSummary()

		topBtn.MouseButton1Click:Connect(function()
			expanded = not expanded
			local targetH = expanded and (rowHeight + #options * optHeight) or rowHeight
			local targetRot = expanded and -90 or 90
			TweenService:Create(arr, FAST_EASE, { Rotation = targetRot }):Play()
			TweenService:Create(container, FAST_EASE, { Size = UDim2.new(1, 0, 0, targetH) }):Play()
		end)

		local handle = {
			_frame = container,
			Get = function()
				return selectedList
			end,
			Set = function(selfOrVals, maybeVals, emit)
				local vals = type(selfOrVals) == "table" and not maybeVals and selfOrVals or maybeVals or {}
				selectedMap = {}
				selectedList = {}
				for _, opt in ipairs(vals) do
					selectedMap[opt] = true
					table.insert(selectedList, opt)
				end
				updateSummary()
				if emit and mConfig.Callback then
					task.spawn(mConfig.Callback, selectedList)
				end
			end,
			SetValue = function(selfOrVals, maybeVals, emit)
				local vals = type(selfOrVals) == "table" and not maybeVals and selfOrVals or maybeVals or {}
				selectedMap = {}
				selectedList = {}
				for _, opt in ipairs(vals) do
					selectedMap[opt] = true
					table.insert(selectedList, opt)
				end
				updateSummary()
				if emit and mConfig.Callback then
					task.spawn(mConfig.Callback, selectedList)
				end
			end
		}

		return handle
	end

	-- Textbox Control
	function tab:CreateTextbox(iConfig: any)
		iConfig = iConfig or {}
		local title = iConfig.Name or iConfig.Title or "Textbox"
		local defaultText = iConfig.Default or iConfig.Text or ""

		local blk = Instance.new("Frame")
		blk.Name = "Textbox_" .. title
		blk.Size = UDim2.new(1, 0, 0, 44)
		blk.BackgroundColor3 = self.Window.Theme.Surface2
		blk.BorderSizePixel = 0
		blk.Parent = page

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 12)
		corner.Parent = blk

		local stroke = Instance.new("UIStroke")
		stroke.Color = self.Window.Theme.Line
		stroke.Transparency = self.Window.Theme.LineTransparency
		stroke.Thickness = 1
		stroke.Parent = blk

		local tLabel = Instance.new("TextLabel")
		tLabel.Position = UDim2.new(0, 14, 0, 0)
		tLabel.Size = UDim2.new(0.45, -14, 1, 0)
		tLabel.BackgroundTransparency = 1
		tLabel.Text = title
		tLabel.TextColor3 = self.Window.Theme.Ink
		tLabel.Font = getUIFont("Bold")
		tLabel.TextSize = 12
		tLabel.TextXAlignment = Enum.TextXAlignment.Left
		tLabel.Parent = blk

		local tb = Instance.new("TextBox")
		tb.AnchorPoint = Vector2.new(1, 0.5)
		tb.Position = UDim2.new(1, -12, 0.5, 0)
		tb.Size = UDim2.new(0.5, 0, 0, 26)
		tb.BackgroundColor3 = self.Window.Theme.Surface3
		tb.BorderSizePixel = 0
		tb.Text = defaultText
		tb.PlaceholderText = iConfig.Placeholder or "Enter value..."
		tb.PlaceholderColor3 = self.Window.Theme.Ink3
		tb.TextColor3 = self.Window.Theme.Ink
		tb.Font = getUIFont("Medium")
		tb.TextSize = 11
		tb.ClearTextOnFocus = (iConfig.ClearTextOnFocus or iConfig.ClearOnFocus) == true
		tb.Parent = blk

		local tbCorn = Instance.new("UICorner")
		tbCorn.CornerRadius = UDim.new(0, 8)
		tbCorn.Parent = tb

		tb.FocusLost:Connect(function(enter)
			if iConfig.Callback then
				task.spawn(iConfig.Callback, tb.Text, enter)
			end
		end)

		local handle = {
			_frame = blk,
			Get = function()
				return tb.Text
			end,
			Set = function(selfOrVal, maybeVal)
				local v = tostring(maybeVal ~= nil and maybeVal or selfOrVal or "")
				tb.Text = v
			end,
			SetValue = function(selfOrVal, maybeVal)
				local v = tostring(maybeVal ~= nil and maybeVal or selfOrVal or "")
				tb.Text = v
			end
		}

		return handle
	end

	-- Text Label
	function tab:CreateLabel(textOrConfig: any)
		local text = type(textOrConfig) == "table" and (textOrConfig.Text or textOrConfig.Name or "") or tostring(textOrConfig or "")

		local lblFrame = Instance.new("Frame")
		lblFrame.Name = "LabelFrame"
		lblFrame.Size = UDim2.new(1, 0, 0, 28)
		lblFrame.BackgroundColor3 = self.Window.Theme.Surface2
		lblFrame.BorderSizePixel = 0
		lblFrame.Parent = page

		local lc = Instance.new("UICorner")
		lc.CornerRadius = UDim.new(0, 10)
		lc.Parent = lblFrame

		local lt = Instance.new("TextLabel")
		lt.Position = UDim2.new(0, 12, 0, 0)
		lt.Size = UDim2.new(1, -24, 1, 0)
		lt.BackgroundTransparency = 1
		lt.Text = text
		lt.TextColor3 = self.Window.Theme.Ink2
		lt.Font = getUIFont("Medium")
		lt.TextSize = 11
		lt.TextWrapped = true
		lt.TextXAlignment = Enum.TextXAlignment.Left
		lt.Parent = lblFrame

		local handle = {
			_frame = lblFrame,
			Set = function(selfOrText, maybeText)
				local newTxt = tostring(maybeText ~= nil and maybeText or selfOrText or "")
				lt.Text = newTxt
			end,
			SetValue = function(selfOrText, maybeText)
				local newTxt = tostring(maybeText ~= nil and maybeText or selfOrText or "")
				lt.Text = newTxt
			end
		}

		return handle
	end

	-- Signature Element #040 Block (.u040-blk, 48px)
	function tab:CreateBlock(cardConfig: {
		Title: string,
		Description: string?,
		Meta: string?,
		GradientIndex: number?,
		Callback: (() -> ())?
	})
		local rawIdx = cardConfig.GradientIndex or index
		local gIdx = ((rawIdx - 1) % 4) + 1
		local gSeq = self.Window.Theme.BlockGradients[gIdx]

		local blk = Instance.new("Frame")
		blk.Name = "Block_" .. cardConfig.Title
		blk.Size = UDim2.new(1, 0, 0, 48)
		blk.BackgroundColor3 = self.Window.Theme.Surface2
		blk.BorderSizePixel = 0
		blk.Parent = page

		local bCorner = Instance.new("UICorner")
		bCorner.CornerRadius = UDim.new(0, 12)
		bCorner.Parent = blk

		local badgeBox = Instance.new("Frame")
		badgeBox.Name = "BadgeIcon"
		badgeBox.Position = UDim2.new(0, 10, 0, 10)
		badgeBox.Size = UDim2.new(0, 28, 0, 28)
		badgeBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		badgeBox.BorderSizePixel = 0
		badgeBox.Parent = blk

		local bbCorner = Instance.new("UICorner")
		bbCorner.CornerRadius = UDim.new(0, 8)
		bbCorner.Parent = badgeBox

		local bbGrad = Instance.new("UIGradient")
		bbGrad.Color = gSeq
		bbGrad.Rotation = 45
		bbGrad.Parent = badgeBox

		local bTitle = Instance.new("TextLabel")
		bTitle.Name = "Title"
		bTitle.Position = UDim2.new(0, 46, 0, 8)
		bTitle.Size = UDim2.new(1, -56, 0, 16)
		bTitle.BackgroundTransparency = 1
		bTitle.Text = cardConfig.Title
		bTitle.TextColor3 = self.Window.Theme.Ink
		bTitle.Font = getUIFont("Bold")
		bTitle.TextSize = 12
		bTitle.TextXAlignment = Enum.TextXAlignment.Left
		bTitle.Parent = blk

		local bDesc = Instance.new("TextLabel")
		bDesc.Name = "Desc"
		bDesc.Position = UDim2.new(0, 46, 0, 24)
		bDesc.Size = UDim2.new(1, -56, 0, 16)
		bDesc.BackgroundTransparency = 1
		bDesc.Text = cardConfig.Description or ""
		bDesc.TextColor3 = self.Window.Theme.Ink3
		bDesc.Font = getUIFont("Medium")
		bDesc.TextSize = 10
		bDesc.TextXAlignment = Enum.TextXAlignment.Left
		bDesc.Parent = blk

		if cardConfig.Callback then
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, 0, 1, 0)
			btn.BackgroundTransparency = 1
			btn.Text = ""
			btn.Parent = blk
			btn.MouseButton1Click:Connect(cardConfig.Callback)
		end

		return blk
	end

	-- Keybind Listener
	function tab:CreateKeybind(kConfig: any)
		kConfig = kConfig or {}
		local title = kConfig.Name or kConfig.Title or "Keybind"
		local curKey = kConfig.Default or Enum.KeyCode.RightControl
		local listening = false

		local blk = Instance.new("Frame")
		blk.Name = "Keybind_" .. title
		blk.Size = UDim2.new(1, 0, 0, 44)
		blk.BackgroundColor3 = self.Window.Theme.Surface2
		blk.BorderSizePixel = 0
		blk.Parent = page

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 12)
		corner.Parent = blk

		local stroke = Instance.new("UIStroke")
		stroke.Color = self.Window.Theme.Line
		stroke.Transparency = self.Window.Theme.LineTransparency
		stroke.Thickness = 1
		stroke.Parent = blk

		local tLabel = Instance.new("TextLabel")
		tLabel.Position = UDim2.new(0, 14, 0, 0)
		tLabel.Size = UDim2.new(1, -94, 1, 0)
		tLabel.BackgroundTransparency = 1
		tLabel.Text = title
		tLabel.TextColor3 = self.Window.Theme.Ink
		tLabel.Font = getUIFont("Bold")
		tLabel.TextSize = 12
		tLabel.TextXAlignment = Enum.TextXAlignment.Left
		tLabel.Parent = blk

		local kBtn = Instance.new("TextButton")
		kBtn.AnchorPoint = Vector2.new(1, 0.5)
		kBtn.Position = UDim2.new(1, -12, 0.5, 0)
		kBtn.Size = UDim2.new(0, 76, 0, 24)
		kBtn.BackgroundColor3 = self.Window.Theme.Surface3
		kBtn.BorderSizePixel = 0
		kBtn.Text = curKey.Name
		kBtn.TextColor3 = self.Window.Theme.Accent
		kBtn.Font = getUIFont("Bold")
		kBtn.TextSize = 11
		kBtn.Parent = blk

		local kCorn = Instance.new("UICorner")
		kCorn.CornerRadius = UDim.new(0, 7)
		kCorn.Parent = kBtn

		kBtn.MouseButton1Click:Connect(function()
			listening = true
			kBtn.Text = "..."
			local conn
			conn = UserInputService.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.Keyboard then
					curKey = input.KeyCode
					kBtn.Text = curKey.Name
					listening = false
					conn:Disconnect()
					if kConfig.Callback then
						task.spawn(kConfig.Callback, curKey)
					end
				end
			end)
		end)

		return { _frame = blk }
	end

	-- Tab Updaters
	function tab:SetTitle(newTitle: string)
		tab.Title = newTitle
		itLabel.Text = newTitle
		if self.Window.H3Title and self.Window.CurrentIndex == index then
			self.Window.H3Title.Text = newTitle
		end
		if self.Window.TabBar then
			self.Window.TabBar:SetTitle(index, newTitle)
		end
	end

	function tab:SetIcon(newIcon: string)
		tab.Icon = newIcon
		itIcon.Image = newIcon
		if self.Window.TabBar then
			self.Window.TabBar:SetIcon(index, newIcon)
		end
	end

	function tab:SetBadge(count: number?)
		tab.Badge = count
		if itBadge then
			local bText = itBadge:FindFirstChildOfClass("TextLabel")
			if count and count > 0 then
				if bText then bText.Text = tostring(count) end
				itBadge.Visible = true
			else
				itBadge.Visible = false
			end
		end
		if self.Window.TabBar then
			self.Window.TabBar:SetBadge(index, count)
		end
	end

	table.insert(self.Tabs, tab)

	-- Synchronize with Bottom TabBar #041
	if self.TabBar then
		table.insert(self.TabBar.TabsData, {
			Id = string.lower(tab.Title),
			Title = tab.Title,
			Icon = tab.Icon,
			Badge = tab.Badge
		})
		self.TabBar:RebuildTabs()
	end

	return tab
end

function Element040:SelectTab(index: number, immediate: boolean?)
	if index < 1 or index > #self.Tabs then return end
	self.CurrentIndex = index

	-- Slide Active Highlight
	local targetHlPos = UDim2.new(0, 0, 0, (index - 1) * 40)
	if immediate then
		self.ActiveHl.Position = targetHlPos
	else
		TweenService:Create(self.ActiveHl, SPRING_BOUNCE, { Position = targetHlPos }):Play()
	end

	-- Swap Title
	local activeTab = self.Tabs[index]
	if activeTab then
		if not immediate then
			local shiftDown = TweenService:Create(self.H3Title, FAST_EASE, {
				TextTransparency = 1,
				Position = UDim2.new(0, 18, 0, 32)
			})
			shiftDown:Play()
			shiftDown.Completed:Connect(function()
				self.H3Title.Text = activeTab.Title
				self.H3Title.Position = UDim2.new(0, 18, 0, 16)
				TweenService:Create(self.H3Title, SPRING_BOUNCE, {
					TextTransparency = 0,
					Position = UDim2.new(0, 18, 0, 24)
				}):Play()
			end)
		else
			self.H3Title.Text = activeTab.Title
			self.H3Title.Position = UDim2.new(0, 18, 0, 24)
			self.H3Title.TextTransparency = 0
		end
	end

	-- Show active page & update icons
	for i, t in ipairs(self.Tabs) do
		t.Page.Visible = (i == index)
		local rItem = self.RailItems and self.RailItems[i]
		if rItem then
			rItem.Icon.ImageColor3 = (i == index) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(140, 138, 150)
		end
	end

	-- Sync with Bottom Tab Bar (#041)
	if self.TabBar and self.TabBar.CurrentIndex ~= index then
		self.TabBar:SelectTab(index, immediate)
	end
end

function Element040:SetTheme(themeName: string)
	local newTheme = LucianUI.Tokens[themeName]
	if not newTheme then return end
	self.ThemeName = themeName
	self.Theme = newTheme
	self.MainCard.BackgroundColor3 = newTheme.Surface
	self.H3Title.TextColor3 = newTheme.Ink

	if self.TabBar then
		self.TabBar.ThemeName = themeName
		self.TabBar.Theme = newTheme
		if self.TabBar.LeftBar then self.TabBar.LeftBar.BackgroundColor3 = newTheme.Surface end
		if self.TabBar.RightBar then self.TabBar.RightBar.BackgroundColor3 = newTheme.Surface end
		if self.TabBar.BottomBar then self.TabBar.BottomBar.BackgroundColor3 = newTheme.Surface end
		if self.TabBar.Scoop then self.TabBar.Scoop.ImageColor3 = newTheme.Surface end
				if self.TabBar.BarStroke then
			self.TabBar.BarStroke.Color = newTheme.Line
			self.TabBar.BarStroke.Transparency = newTheme.LineTransparency
		end
		if self.TabBar.BubbleGrad then
			self.TabBar.BubbleGrad.Color = newTheme.Gradient
		end
		self.TabBar:SelectTab(self.CurrentIndex, true)
	end
end

function Element040:SetTitle(title: string)
	if self.BrandName then
		self.BrandName.Text = title
	end
end

function Element040:SetSubTitle(subTitle: string)
	if self.SubTitleLabel then
		self.SubTitleLabel.Text = subTitle
	end
end

function Element040:SetLogo(logoId: string)
	if self.LogoImage then
		self.LogoImage.Image = logoId
		self.LogoImage.Visible = true
	end
end

function Element040:SetUserProfile(profile: { Name: string?, Role: string?, Avatar: string? })
	if profile.Name and self.MeName then
		self.MeName.Text = profile.Name
	end
	if profile.Role and self.MeRole then
		self.MeRole.Text = profile.Role
	end
	if profile.Avatar and self.AvatarImage then
		self.AvatarImage.Image = profile.Avatar
		self.AvatarImage.Visible = true
	end
end

function Element040:SetVisible(visible: boolean)
	self.IsOpen = visible
	if visible then
		self.Root.Visible = true
		if self.TabBar and self.TabBar.Root then
			self.TabBar.Root.Visible = true
			if self.TabBar.CurrentIndex == 0 then
				self.TabBar:SelectTab(self.CurrentIndex or 1)
			end
		end
	else
		if self.TabBar and self.TabBar.Root then
			self.TabBar:Deselect()
			self.TabBar.Root.Visible = false
		end
		self.Root.Visible = false
	end
end

function Element040:Toggle()
	self:SetVisible(not self.IsOpen)
end

function Element040:Minimize()
	self:SetVisible(false)
end

function Element040:Open()
	self:SetVisible(true)
end

function Element040:Destroy()
	pcall(function()
		self.ScreenGui:Destroy()
	end)
end

-- ==============================================================================
-- UNIFIED WINDOW BUILDER: ELEMENT #040 (PANEL) + ELEMENT #041 (BOTTOM TAB BAR)
-- ==============================================================================
function LucianUI:CreateWindow(config: any)
	config = config or {}
	local window040 = Element040.new(config)

	-- Bottom TabBar completely removed as requested
	window040.TabBar = {
		TabsData = {},
		CurrentIndex = 0,
		SelectTab = function() end,
		Deselect = function() end,
		SetBadge = function() end,
		SetTitle = function() end,
		SetIcon = function() end,
		RebuildTabs = function() end,
		Destroy = function() end,
	}

	-- Mobile Floating Draggable Toggle Button
	if config.MobileButton ~= false then
		local mobBtn = createMobileToggleButton(window040.ScreenGui, window040)
		window040.MobileButton = mobBtn
	end

	-- Keybind toggle
	local toggleKey = config.Keybind or config.ToggleKey or Enum.KeyCode.RightControl
	UserInputService.InputBegan:Connect(function(input, processed)
		if not processed and input.KeyCode == toggleKey then
			window040:Toggle()
		end
	end)

	if config.AutoShow ~= false and config.Visible ~= false then
		window040:SetVisible(true)
	end

	table.insert(LucianUI._windows, window040)
	return window040
end

-- Compatibility aliases for NexusLib ecosystem
LucianUI.CreateTabBar = function(_, cfg) return TabBar041.new(cfg) end
LucianUI.GetTheme = function() return "Dark" end
LucianUI.GetThemeName = function() return "Dark" end
LucianUI.GetThemes = function() return { "Dark", "Light" } end
LucianUI.SetTheme = function(_, t)
	for _, win in ipairs(LucianUI._windows) do
		win:SetTheme(t)
	end
end
LucianUI.DestroyAll = function()
	for _, win in ipairs(LucianUI._windows) do
		win:Destroy()
	end
	LucianUI._windows = {}
	if notificationGui then
		notificationGui:Destroy()
		notificationGui = nil
	end
end

local runtimeEnv = (getgenv and getgenv()) or _G or {}
runtimeEnv.NexusLib = LucianUI
runtimeEnv.LucianUI = LucianUI

return LucianUI
