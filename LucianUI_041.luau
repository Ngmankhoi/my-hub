--!strict
--[[
	Lucian UX/UI Prompt #027, #040 & #041 · Roblox Studio Luau Library
	MIT License (c) 2026 Seokwoooo · https://lucianlabs.dev/uxui-prompt/
	
	Features:
	- Element #027: Lumen Expandable Search Bar & Command Palette Popup (.u027) with
	  live filtering, recent pills, suggested results with gradient badges, and keyboard/mouse focus
	- Element #040: Lumen Collapsible Rail Navigation (56px -> 150px compact) with
	  active highlight pill, gradient stripe, user profile card, and signature .u040-blk cards
	- Element #041: Compact Notched Bottom Tab Bar (320x60px) with genuine scooped circular notch,
	  floating gradient bubble, ambient glow, active label, and badge pip
	- Proportional compact sizing fitting all screen resolutions with zero overflow
	- 1:1 synchronization between Element #040 Rail, Element #027 Search, and Element #041 Bottom Bar
	- Zero misaligned shadow artifacts, zero toast notifications
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LucianUI = {}
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
			ColorSequence.new(Color3.fromRGB(139, 108, 255), Color3.fromRGB(91, 140, 255)), -- #8B6CFF -> #5B8CFF
			ColorSequence.new(Color3.fromRGB(255, 181, 71), Color3.fromRGB(255, 122, 69)),  -- #FFB547 -> #FF7A45
			ColorSequence.new(Color3.fromRGB(34, 195, 166), Color3.fromRGB(14, 165, 233)),  -- #22C3A6 -> #0EA5E9
			ColorSequence.new(Color3.fromRGB(255, 122, 147), Color3.fromRGB(176, 79, 208))  -- #FF7A93 -> #B04FD0
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

-- Tested, verified loaded Lucide icons in Roblox
LucianUI.Icons = {
	Home = "rbxassetid://10723407389",
	Projects = "rbxassetid://10723345518",
	Grid = "rbxassetid://10723345518",
	Calendar = "rbxassetid://10709790644",
	Messages = "rbxassetid://10709791281",
	Chat = "rbxassetid://10709791281",
	Settings = "rbxassetid://10734950309",
	Explore = "rbxassetid://10723346959",
	Eye = "rbxassetid://10723346959",
	Saved = "rbxassetid://10709791523",
	Star = "rbxassetid://10709791523",
	Alerts = "rbxassetid://10709790537",
	Bell = "rbxassetid://10709790537",
	Check = "rbxassetid://10709790757",
	Chevron = "rbxassetid://10709790948",
	Close = "rbxassetid://10747384394",
	Search = "rbxassetid://6031154871",
	User = "rbxassetid://10747373176",
	Profile = "rbxassetid://10747373176",
	Gamepad = "rbxassetid://10723374641",
	Combat = "rbxassetid://10734952036",
	Sword = "rbxassetid://10734952036",
	Shield = "rbxassetid://10734950813",
	Fire = "rbxassetid://10723376114",
	Flame = "rbxassetid://10723376114",
	Zap = "rbxassetid://10734952479",
	Bolt = "rbxassetid://10734952479",
	Sliders = "rbxassetid://10734951847",
	Code = "rbxassetid://10709791437",
	Terminal = "rbxassetid://10709791437",
	Layers = "rbxassetid://10723377626",
	Folder = "rbxassetid://10723387563",
	Key = "rbxassetid://10723396702",
	Heart = "rbxassetid://10723394370",
	Info = "rbxassetid://10723395402",
	Help = "rbxassetid://10723405367",
	Music = "rbxassetid://10723415903",
	Trash = "rbxassetid://10747374931",
	Edit = "rbxassetid://10734941499",
}

-- Motion parameters
local SPRING_BOUNCE = TweenInfo.new(0.46, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local SMOOTH_QUAD = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local FAST_EASE = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function getSafeGuiParent(): Instance
	local success, result = pcall(function()
		return CoreGui
	end)
	if success and result then
		return result
	end
	local localPlayer = Players.LocalPlayer
	if localPlayer then
		return localPlayer:WaitForChild("PlayerGui")
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
-- ELEMENT #041: COMPACT NOTCHED BOTTOM BAR (320x60px, Real Circular Scoop)
-- ==============================================================================
local TabBar041 = {}
TabBar041.__index = TabBar041

function TabBar041.new(config: {
	Parent: Instance?,
	ThemeName: string?,
	Width: number?,
	Height: number?,
	Tabs: { { Id: string, Title: string, Icon: string, Badge: number? } },
	OnSelect: ((index: number) -> ())?,
	OnActiveClick: ((index: number) -> ())?
})
	local self = setmetatable({}, TabBar041)
	self.ThemeName = config.ThemeName or "Light"
	self.Theme = LucianUI.Tokens[self.ThemeName] or LucianUI.Tokens.Light
	self.Width = config.Width or 320
	self.Height = config.Height or 60
	self.TabsData = config.Tabs or {}
	self.CurrentIndex = 1
	self.OnSelect = config.OnSelect
	self.OnActiveClick = config.OnActiveClick

	local parent = config.Parent or getSafeGuiParent()

	-- Docked Container at Bottom Center
	local container = Instance.new("Frame")
	container.Name = "Lucian041_TabBar"
	container.AnchorPoint = Vector2.new(0.5, 1)
	container.Position = UDim2.new(0.5, 0, 1, -12)
	container.Size = UDim2.new(0, self.Width, 0, self.Height)
	container.BackgroundTransparency = 1
	container.ZIndex = 30
	container.Parent = parent
	self.Container = container

	-- Soft Bottom Shadow
	local barShadow = Instance.new("ImageLabel")
	barShadow.Name = "BarShadow"
	barShadow.AnchorPoint = Vector2.new(0.5, 0.5)
	barShadow.Position = UDim2.new(0.5, 0, 0.5, 10)
	barShadow.Size = UDim2.new(1, 24, 1, 24)
	barShadow.BackgroundTransparency = 1
	barShadow.Image = "rbxassetid://1316045217"
	barShadow.ImageColor3 = self.Theme.Shadow
	barShadow.ImageTransparency = 0.82
	barShadow.ScaleType = Enum.ScaleType.Slice
	barShadow.SliceCenter = Rect.new(10, 10, 118, 118)
	barShadow.ZIndex = 29
	barShadow.Parent = container

	-- Main Bar Background with Scooped Circular Notch Cutout
	local barGroup = Instance.new("CanvasGroup")
	barGroup.Name = "BarBackground"
	barGroup.Size = UDim2.new(1, 0, 1, 0)
	barGroup.BackgroundTransparency = 1
	barGroup.BorderSizePixel = 0
	barGroup.ZIndex = 30
	barGroup.Parent = container
	self.BarGroup = barGroup

	local barCorner = Instance.new("UICorner")
	barCorner.CornerRadius = UDim.new(0, 22)
	barCorner.Parent = barGroup

	local barStroke = Instance.new("UIStroke")
	barStroke.Color = self.Theme.Line
	barStroke.Transparency = self.Theme.LineTransparency
	barStroke.Thickness = 1
	barStroke.Parent = barGroup
	self.BarStroke = barStroke

	local startX = self:GetTabCenterX(1)

	local leftBar = Instance.new("Frame")
	leftBar.Name = "LeftBar"
	leftBar.Position = UDim2.new(0, 0, 0, 0)
	leftBar.Size = UDim2.new(0, math.max(0, startX - 35), 1, 0)
	leftBar.BackgroundColor3 = self.Theme.Surface
	leftBar.BorderSizePixel = 0
	leftBar.Parent = barGroup
	self.LeftBar = leftBar

	local rightBar = Instance.new("Frame")
	rightBar.Name = "RightBar"
	rightBar.Position = UDim2.new(0, startX + 35, 0, 0)
	rightBar.Size = UDim2.new(1, -(startX + 35), 1, 0)
	rightBar.BackgroundColor3 = self.Theme.Surface
	rightBar.BorderSizePixel = 0
	rightBar.Parent = barGroup
	self.RightBar = rightBar

	local bottomBar = Instance.new("Frame")
	bottomBar.Name = "BottomBar"
	bottomBar.Position = UDim2.new(0, startX - 35, 0, 30)
	bottomBar.Size = UDim2.new(0, 70, 1, -30)
	bottomBar.BackgroundColor3 = self.Theme.Surface
	bottomBar.BorderSizePixel = 0
	bottomBar.Parent = barGroup
	self.BottomBar = bottomBar

	local scoop = Instance.new("ImageLabel")
	scoop.Name = "Scoop"
	scoop.Position = UDim2.new(0, startX - 35, 0, 0)
	scoop.Size = UDim2.new(0, 70, 0, 30)
	scoop.BackgroundTransparency = 1
	scoop.Image = "rbxassetid://82537862460752"
	scoop.ImageColor3 = self.Theme.Surface
	scoop.BorderSizePixel = 0
	scoop.Parent = barGroup
	self.Scoop = scoop

	local notchCover = Instance.new("Frame")
	notchCover.Name = "NotchCover"
	notchCover.Position = UDim2.new(0, startX - 35, 0, 0)
	notchCover.Size = UDim2.new(0, 70, 0, 30)
	notchCover.BackgroundColor3 = self.Theme.Surface
	notchCover.BorderSizePixel = 0
	notchCover.BackgroundTransparency = 1
	notchCover.ZIndex = 32
	notchCover.Parent = barGroup
	self.NotchCover = notchCover

	-- Ambient glow behind bubble (.u041-bub box-shadow: 0 14px 26px -12px rgba(91,72,255,.7))
	local bubbleGlow = Instance.new("ImageLabel")
	bubbleGlow.Name = "BubbleGlow"
	bubbleGlow.AnchorPoint = Vector2.new(0.5, 0.5)
	bubbleGlow.Position = UDim2.new(0, startX, 0, 5)
	bubbleGlow.Size = UDim2.new(0, 70, 0, 70)
	bubbleGlow.BackgroundTransparency = 1
	bubbleGlow.Image = "rbxassetid://121871384597239"
	bubbleGlow.ImageColor3 = Color3.fromRGB(91, 72, 255)
	bubbleGlow.ImageTransparency = 0.25
	bubbleGlow.ZIndex = 32
	bubbleGlow.Parent = container
	self.BubbleGlow = bubbleGlow

	-- Floating Gradient Bubble (.u041-bub, 48x48px)
	local bubble = Instance.new("Frame")
	bubble.Name = "Bubble"
	bubble.AnchorPoint = Vector2.new(0.5, 0.5)
	bubble.Position = UDim2.new(0, startX, 0, -3)
	bubble.Size = UDim2.new(0, 48, 0, 48)
	bubble.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	bubble.BorderSizePixel = 0
	bubble.ZIndex = 35
	bubble.Parent = container
	self.Bubble = bubble

	local bubbleCorner = Instance.new("UICorner")
	bubbleCorner.CornerRadius = UDim.new(1, 0)
	bubbleCorner.Parent = bubble

	local bubbleGrad = Instance.new("UIGradient")
	bubbleGrad.Color = self.Theme.Gradient
	bubbleGrad.Rotation = 45
	bubbleGrad.Parent = bubble
	self.BubbleGrad = bubbleGrad

	-- Pure White Crisp Icon inside Bubble
	local bubbleIcon = Instance.new("ImageLabel")
	bubbleIcon.Name = "BubbleIcon"
	bubbleIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	bubbleIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
	bubbleIcon.Size = UDim2.new(0, 20, 0, 20)
	bubbleIcon.BackgroundTransparency = 1
	bubbleIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
	bubbleIcon.ZIndex = 36
	bubbleIcon.Parent = bubble
	self.BubbleIcon = bubbleIcon

	-- Interactive Click Button on Floating Bubble (.u041-bub)
	local bubbleBtn = Instance.new("TextButton")
	bubbleBtn.Name = "BubbleButton"
	bubbleBtn.Size = UDim2.new(1, 0, 1, 0)
	bubbleBtn.BackgroundTransparency = 1
	bubbleBtn.Text = ""
	bubbleBtn.ZIndex = 45
	bubbleBtn.Parent = bubble
	self.BubbleButton = bubbleBtn

	bubbleBtn.MouseButton1Click:Connect(function()
		if self.OnActiveClick then
			self.OnActiveClick(self.CurrentIndex)
		elseif self.OnSelect then
			self.OnSelect(self.CurrentIndex)
		end
	end)

	-- Tabs List Container
	local tabsList = Instance.new("Frame")
	tabsList.Name = "TabsList"
	tabsList.Size = UDim2.new(1, 0, 1, 0)
	tabsList.BackgroundTransparency = 1
	tabsList.ZIndex = 38
	tabsList.Parent = container
	self.TabsList = tabsList

	self.TabButtons = {}
	self.TabIcons = {}
	self.TabLabels = {}
	self.TabBadges = {}

	self:RebuildTabs()
	return self
end

function TabBar041:GetTabCenterX(index: number): number
	local pad = 16
	local totalTabs = math.max(1, #self.TabsData)
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
	self.TabBadges = {}

	local totalTabs = #self.TabsData
	if totalTabs == 0 then return end

	local pad = 16
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
		btn.ZIndex = 39
		btn.Parent = self.TabsList

		-- Inactive tab icon
		local iconContainer = Instance.new("Frame")
		iconContainer.Name = "IconContainer"
		iconContainer.AnchorPoint = Vector2.new(0.5, 0.5)
		iconContainer.Position = UDim2.new(0.5, 0, 0.5, -2)
		iconContainer.Size = UDim2.new(0, 18, 0, 18)
		iconContainer.BackgroundTransparency = 1
		iconContainer.ZIndex = 40
		iconContainer.Parent = btn

		local iconImg = Instance.new("ImageLabel")
		iconImg.Name = "Icon"
		iconImg.Size = UDim2.new(1, 0, 1, 0)
		iconImg.BackgroundTransparency = 1
		iconImg.Image = tabData.Icon
		iconImg.ImageColor3 = self.Theme.Ink3
		iconImg.ZIndex = 40
		iconImg.Parent = iconContainer

		-- Active Tab Label under Bubble (.u041-lab)
		local label = Instance.new("TextLabel")
		label.Name = "Label"
		label.AnchorPoint = Vector2.new(0.5, 1)
		label.Position = UDim2.new(0.5, 0, 1, -7)
		label.Size = UDim2.new(1, 0, 0, 13)
		label.BackgroundTransparency = 1
		label.Text = tabData.Title
		label.TextColor3 = self.Theme.Ink
		label.Font = Enum.Font.GothamBold
		label.TextSize = 10
		label.TextTransparency = 1
		label.ZIndex = 40
		label.Parent = btn

		-- Notification Badge (.u041-pip)
		local badge
		if tabData.Badge and tabData.Badge > 0 then
			local bFrame = Instance.new("Frame")
			bFrame.Name = "Badge"
			bFrame.AnchorPoint = Vector2.new(0.5, 0.5)
			bFrame.Position = UDim2.new(0.5, 10, 0, 14)
			bFrame.Size = UDim2.new(0, 15, 0, 15)
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
			bText.Font = Enum.Font.GothamBold
			bText.ZIndex = 42
			bText.Parent = bFrame

			badge = bFrame
		end

		self.TabButtons[i] = btn
		self.TabIcons[i] = iconContainer
		self.TabLabels[i] = label
		self.TabBadges[i] = badge

		btn.MouseEnter:Connect(function()
			if self.CurrentIndex ~= i then
				TweenService:Create(iconImg, FAST_EASE, { ImageColor3 = self.Theme.Ink }):Play()
			end
		end)

		btn.MouseLeave:Connect(function()
			if self.CurrentIndex ~= i then
				TweenService:Create(iconImg, FAST_EASE, { ImageColor3 = self.Theme.Ink3 }):Play()
			end
		end)

		btn.MouseButton1Click:Connect(function()
			if self.CurrentIndex == i then
				if self.OnActiveClick then
					self.OnActiveClick(i)
				else
					self:Deselect()
				end
			else
				self:SelectTab(i)
			end
		end)
	end

	self:SelectTab(self.CurrentIndex or 1, true)
end

function TabBar041:SelectTab(index: number, immediate: boolean?)
	if index < 1 or index > #self.TabsData then return end
	local prevIndex = self.CurrentIndex
	self.CurrentIndex = index
	local targetX = self:GetTabCenterX(index)

	local bubblePos = UDim2.new(0, targetX, 0, -3)
	local glowPos = UDim2.new(0, targetX, 0, 5)

	local leftSize = UDim2.new(0, math.max(0, targetX - 35), 1, 0)
	local rightPos = UDim2.new(0, targetX + 35, 0, 0)
	local rightSize = UDim2.new(1, -(targetX + 35), 1, 0)
	local bottomPos = UDim2.new(0, targetX - 35, 0, 30)
	local scoopPos = UDim2.new(0, targetX - 35, 0, 0)

	local activeTabData = self.TabsData[index]
	if activeTabData and self.BubbleIcon then
		self.BubbleIcon.Image = activeTabData.Icon
	end

	self.Bubble.Visible = true
	if self.BubbleGlow then self.BubbleGlow.Visible = true end
	if self.RightBar then self.RightBar.Visible = true end
	if self.BottomBar then self.BottomBar.Visible = true end
	if self.Scoop then self.Scoop.Visible = true end

	if immediate then
		self.Bubble.Size = UDim2.new(0, 48, 0, 48)
		self.Bubble.Position = bubblePos
		if self.BubbleGlow then
			self.BubbleGlow.Size = UDim2.new(0, 70, 0, 70)
			self.BubbleGlow.Position = glowPos
		end
		if self.LeftBar then self.LeftBar.Size = leftSize end
		if self.RightBar then
			self.RightBar.Position = rightPos
			self.RightBar.Size = rightSize
		end
		if self.BottomBar then self.BottomBar.Position = bottomPos end
		if self.Scoop then self.Scoop.Position = scoopPos end
		if self.NotchCover then
			self.NotchCover.Position = scoopPos
			self.NotchCover.BackgroundTransparency = 1
		end
	else
		if prevIndex == 0 then
			-- Rising up smoothly from idle unselected state
			self.LeftBar.Size = leftSize
			self.RightBar.Position = rightPos
			self.RightBar.Size = rightSize
			self.BottomBar.Position = bottomPos
			self.Scoop.Position = scoopPos

			if self.NotchCover then
				self.NotchCover.Position = scoopPos
				self.NotchCover.BackgroundTransparency = 0
				TweenService:Create(self.NotchCover, FAST_EASE, { BackgroundTransparency = 1 }):Play()
			end

			self.Bubble.Position = UDim2.new(0, targetX, 0, 10)
			self.Bubble.Size = UDim2.new(0, 0, 0, 0)
			TweenService:Create(self.Bubble, SPRING_BOUNCE, { Position = bubblePos, Size = UDim2.new(0, 48, 0, 48) }):Play()

			if self.BubbleGlow then
				self.BubbleGlow.Position = glowPos
				self.BubbleGlow.Size = UDim2.new(0, 0, 0, 0)
				TweenService:Create(self.BubbleGlow, SPRING_BOUNCE, { Size = UDim2.new(0, 70, 0, 70) }):Play()
			end
		else
			-- Smooth gliding between active tabs
			if self.NotchCover then
				self.NotchCover.Position = scoopPos
				self.NotchCover.BackgroundTransparency = 1
			end
			TweenService:Create(self.Bubble, SPRING_BOUNCE, { Position = bubblePos, Size = UDim2.new(0, 48, 0, 48) }):Play()
			if self.BubbleGlow then
				TweenService:Create(self.BubbleGlow, SPRING_BOUNCE, { Position = glowPos, Size = UDim2.new(0, 70, 0, 70) }):Play()
			end
			if self.LeftBar then
				TweenService:Create(self.LeftBar, SPRING_BOUNCE, { Size = leftSize }):Play()
			end
			if self.RightBar then
				TweenService:Create(self.RightBar, SPRING_BOUNCE, { Position = rightPos, Size = rightSize }):Play()
			end
			if self.BottomBar then
				TweenService:Create(self.BottomBar, SPRING_BOUNCE, { Position = bottomPos }):Play()
			end
			if self.Scoop then
				TweenService:Create(self.Scoop, SPRING_BOUNCE, { Position = scoopPos }):Play()
			end
		end
	end

	for i = 1, #self.TabsData do
		local iconContainer = self.TabIcons[i]
		local label = self.TabLabels[i]
		local badge = self.TabBadges[i]

		if i == index then
			if immediate then
				if iconContainer then iconContainer.Visible = false end
				if label then
					label.Position = UDim2.new(0.5, 0, 1, -7)
					label.TextTransparency = 0
				end
				if badge then badge.Visible = false end
			else
				if iconContainer then iconContainer.Visible = false end
				if label then
					TweenService:Create(label, FAST_EASE, { Position = UDim2.new(0.5, 0, 1, -7), TextTransparency = 0 }):Play()
				end
				if badge then
					TweenService:Create(badge, FAST_EASE, { Size = UDim2.new(0, 0, 0, 0) }):Play()
				end
			end
		else
			if immediate then
				if iconContainer then iconContainer.Visible = true end
				if label then
					label.Position = UDim2.new(0.5, 0, 1, -3)
					label.TextTransparency = 1
				end
				if badge then
					badge.Visible = true
					badge.Size = UDim2.new(0, 15, 0, 15)
				end
			else
				if iconContainer then iconContainer.Visible = true end
				if label then
					TweenService:Create(label, FAST_EASE, { Position = UDim2.new(0.5, 0, 1, -3), TextTransparency = 1 }):Play()
				end
				if badge then
					badge.Visible = true
					TweenService:Create(badge, FAST_EASE, { Size = UDim2.new(0, 15, 0, 15) }):Play()
				end
			end
		end
	end

	if self.OnSelect and (prevIndex ~= index or immediate) then
		self.OnSelect(index)
	end
end

-- Deselect all tabs: smoothly flattens the bar into an idle resting state with no active tab/bubble
function TabBar041:Deselect(immediate: boolean?)
	local prevIndex = self.CurrentIndex
	self.CurrentIndex = 0

	local targetX = self:GetTabCenterX(prevIndex > 0 and prevIndex or 1)
	local sinkBubblePos = UDim2.new(0, targetX, 0, 14)
	local zeroSize = UDim2.new(0, 0, 0, 0)

	if immediate then
		if self.NotchCover then
			self.NotchCover.Position = UDim2.new(0, targetX - 35, 0, 0)
			self.NotchCover.BackgroundTransparency = 0
		end
		if self.Bubble then
			self.Bubble.Visible = false
			self.Bubble.Size = zeroSize
			self.Bubble.Position = sinkBubblePos
		end
		if self.BubbleGlow then
			self.BubbleGlow.Visible = false
			self.BubbleGlow.Size = zeroSize
		end
	else
		if self.NotchCover then
			self.NotchCover.Position = UDim2.new(0, targetX - 35, 0, 0)
			TweenService:Create(self.NotchCover, FAST_EASE, { BackgroundTransparency = 0 }):Play()
		end
		if self.Bubble then
			local bTween = TweenService:Create(self.Bubble, FAST_EASE, {
				Size = zeroSize,
				Position = sinkBubblePos
			})
			bTween:Play()
			bTween.Completed:Connect(function()
				if self.CurrentIndex == 0 then
					self.Bubble.Visible = false
				end
			end)
		end
		if self.BubbleGlow then
			local gTween = TweenService:Create(self.BubbleGlow, FAST_EASE, { Size = zeroSize })
			gTween:Play()
			gTween.Completed:Connect(function()
				if self.CurrentIndex == 0 then
					self.BubbleGlow.Visible = false
				end
			end)
		end
	end

	-- Restore all tab icons to visible state and hide all labels
	for i = 1, #self.TabsData do
		local iconContainer = self.TabIcons[i]
		local label = self.TabLabels[i]
		local badge = self.TabBadges[i]
		local tabData = self.TabsData[i]

		if immediate then
			if iconContainer then
				iconContainer.Visible = true
				local img = iconContainer:FindFirstChild("Icon")
				if img and img:IsA("ImageLabel") then
					img.ImageColor3 = self.Theme.Ink3
				end
			end
			if label then
				label.Position = UDim2.new(0.5, 0, 1, -3)
				label.TextTransparency = 1
			end
			if badge then
				if tabData.Badge and tabData.Badge > 0 then
					badge.Visible = true
					badge.Size = UDim2.new(0, 15, 0, 15)
				else
					badge.Visible = false
				end
			end
		else
			if iconContainer then
				iconContainer.Visible = true
				local img = iconContainer:FindFirstChild("Icon")
				if img and img:IsA("ImageLabel") then
					TweenService:Create(img, FAST_EASE, { ImageColor3 = self.Theme.Ink3 }):Play()
				end
			end
			if label then
				TweenService:Create(label, FAST_EASE, { Position = UDim2.new(0.5, 0, 1, -3), TextTransparency = 1 }):Play()
			end
			if badge then
				if tabData.Badge and tabData.Badge > 0 then
					badge.Visible = true
					TweenService:Create(badge, FAST_EASE, { Size = UDim2.new(0, 15, 0, 15) }):Play()
				else
					badge.Visible = false
				end
			end
		end
	end
end

function TabBar041:SetBadge(index: number, count: number?)
	local badge = self.TabBadges[index]
	if not badge then return end
	if count and count > 0 then
		local bText = badge:FindFirstChildOfClass("TextLabel")
		if bText then bText.Text = tostring(count) end
		badge.Visible = (self.CurrentIndex ~= index)
	else
		badge.Visible = false
	end
end

function TabBar041:SetTitle(index: number, title: string)
	if self.TabsData[index] then
		self.TabsData[index].Title = title
	end
	if self.TabLabels and self.TabLabels[index] then
		self.TabLabels[index].Text = title
	end
end

function TabBar041:SetIcon(index: number, icon: string)
	if self.TabsData[index] then
		self.TabsData[index].Icon = icon
	end
	if self.TabIcons and self.TabIcons[index] then
		self.TabIcons[index].Image = icon
	end
	if self.CurrentIndex == index and self.BubbleIcon then
		self.BubbleIcon.Image = icon
	end
end

-- ==============================================================================
-- ELEMENT #040: COMPACT LUMEN RAIL NAVIGATION & MAIN CONTENT INTERFACE (460x330px)
-- WITH ELEMENT #027 EXPANDABLE SEARCH & COMMAND PALETTE INTEGRATED
-- ==============================================================================
local Element040 = {}
Element040.__index = Element040

function Element040.new(config: {
	Title: string?,
	SubTitle: string?,
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
	self.ThemeName = config.Theme or "Light"
	self.Theme = LucianUI.Tokens[self.ThemeName] or LucianUI.Tokens.Light
	self.Width = config.Width or 460
	self.Height = config.Height or 330
	self.IsWide = false
	self.Tabs = {}
	self.RailItems = {}
	self.CurrentIndex = 1
	self.IsOpen = true

	local parentGui = config.Parent or getSafeGuiParent()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "LucianUI_040_041_" .. tostring(math.random(1000, 9999))
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = parentGui
	self.ScreenGui = screenGui

	-- Master Container
	local container = Instance.new("Frame")
	container.Name = "Lucian040_Root"
	container.AnchorPoint = Vector2.new(0.5, 0.5)
	container.Position = UDim2.new(0.5, 0, 0.38, 0)
	container.Size = UDim2.new(0, self.Width, 0, self.Height)
	container.BackgroundTransparency = 1
	container.Parent = screenGui
	self.Root = container

	-- Left Collapsible Rail (.u040-rail: 56px collapsed, 150px wide)
	local rail = Instance.new("Frame")
	rail.Name = "Rail"
	rail.Position = UDim2.new(0, 0, 0, 0)
	rail.Size = UDim2.new(0, 56, 1, 0)
	rail.BackgroundColor3 = self.Theme.Ink
	rail.BorderSizePixel = 0
	rail.ClipsDescendants = true
	rail.ZIndex = 10
	rail.Parent = container
	self.Rail = rail

	local railCorner = Instance.new("UICorner")
	railCorner.CornerRadius = UDim.new(0, 20)
	railCorner.Parent = rail

	-- Drag handle
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
	logo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
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
	end

	local brandName = Instance.new("TextLabel")
	brandName.Name = "BrandName"
	brandName.Position = UDim2.new(0, 38, 0, 0)
	brandName.Size = UDim2.new(0, 90, 1, 0)
	brandName.BackgroundTransparency = 1
	brandName.Text = config.Title or "n3xuz"
	brandName.TextColor3 = self.Theme.Page
	brandName.Font = Enum.Font.GothamBold
	brandName.TextSize = 14
	brandName.TextXAlignment = Enum.TextXAlignment.Left
	brandName.TextTransparency = 1
	brandName.ZIndex = 12
	brandName.Parent = topBar
	self.BrandName = brandName

	-- Expand/Collapse Toggle Button (.u040-tog)
	local togBtn = Instance.new("TextButton")
	togBtn.Name = "ExpandToggle"
	togBtn.AnchorPoint = Vector2.new(1, 0)
	togBtn.Position = UDim2.new(1, 0, 0, 12)
	togBtn.Size = UDim2.new(0, 24, 0, 28)
	togBtn.BackgroundColor3 = Color3.fromRGB(244, 242, 238)
	togBtn.BackgroundTransparency = 0.88
	togBtn.BorderSizePixel = 0
	togBtn.Text = ""
	togBtn.AutoButtonColor = false
	togBtn.ZIndex = 15
	togBtn.Parent = rail
	self.TogBtn = togBtn

	local tCorner = Instance.new("UICorner")
	tCorner.CornerRadius = UDim.new(0, 8)
	tCorner.Parent = togBtn

	local togIcon = Instance.new("ImageLabel")
	togIcon.Name = "Chevron"
	togIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	togIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
	togIcon.Size = UDim2.new(0, 12, 0, 12)
	togIcon.BackgroundTransparency = 1
	togIcon.Image = LucianUI.Icons.Chevron
	togIcon.ImageColor3 = self.Theme.Page
	togIcon.Rotation = -90
	togIcon.ZIndex = 16
	togIcon.Parent = togBtn
	self.TogIcon = togIcon

	-- Nav List (.u040-nav)
	local navList = Instance.new("Frame")
	navList.Name = "NavList"
	navList.Position = UDim2.new(0, 8, 0, 52)
	navList.Size = UDim2.new(1, -16, 0, 200)
	navList.BackgroundTransparency = 1
	navList.ZIndex = 11
	navList.Parent = rail
	self.NavList = navList

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

	-- Left Active Gradient Stripe (.u040-hl::before)
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
	avatar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
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
	end

	local meName = Instance.new("TextLabel")
	meName.Name = "UserName"
	meName.Position = UDim2.new(0, 40, 0, 6)
	meName.Size = UDim2.new(0, 95, 0, 14)
	meName.BackgroundTransparency = 1
	meName.Text = config.UserName or "Ngmankhoi"
	meName.TextColor3 = self.Theme.Page
	meName.Font = Enum.Font.GothamBold
	meName.TextSize = 11.5
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
	meRole.TextColor3 = self.Theme.Ink3
	meRole.Font = Enum.Font.Gotham
	meRole.TextSize = 9.5
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
	local smallLabel = Instance.new("TextLabel")
	smallLabel.Name = "SubTitle"
	smallLabel.Position = UDim2.new(0, 18, 0, 12)
	smallLabel.Size = UDim2.new(0, 140, 0, 12)
	smallLabel.BackgroundTransparency = 1
	smallLabel.Text = config.SubTitle or "n3xuz Hub"
	smallLabel.TextColor3 = self.Theme.Ink3
	smallLabel.Font = Enum.Font.GothamBold
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
	h3Title.Font = Enum.Font.GothamBold
	h3Title.TextSize = 18
	h3Title.TextXAlignment = Enum.TextXAlignment.Left
	h3Title.ZIndex = 11
	h3Title.Parent = mainCard
	self.H3Title = h3Title

	-- Content Area (Pages container)
	local pages = Instance.new("Frame")
	pages.Name = "PagesArea"
	pages.Position = UDim2.new(0, 0, 0, 52)
	pages.Size = UDim2.new(1, 0, 1, -54)
	pages.BackgroundTransparency = 1
	pages.ClipsDescendants = true
	pages.ZIndex = 11
	pages.Parent = mainCard
	self.PagesArea = pages

	-- Toggle Expand / Collapse Action
	local function toggleWide()
		self.IsWide = not self.IsWide
		local targetRailWidth = self.IsWide and 150 or 56
		local rot = self.IsWide and 90 or -90
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
				local badgeX = self.IsWide and 120 or 32
				TweenService:Create(item.Badge, SPRING_BOUNCE, { Position = UDim2.new(0, badgeX, 0, 12) }):Play()
			end
		end
	end

	togBtn.MouseButton1Click:Connect(toggleWide)
	return self
end

function Element040:CreateTab(config: {
	Title: string,
	Icon: string?,
	Badge: number?
})
	local index = #self.Tabs + 1
	local tabIcon = config.Icon or LucianUI.Icons.Home
	local tab = {
		Index = index,
		Title = config.Title,
		Icon = tabIcon,
		Badge = config.Badge,
		Window = self
	}

	-- Page Scrolling Container
	local page = Instance.new("ScrollingFrame")
	page.Name = "Page_" .. config.Title
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
	pPadding.PaddingBottom = UDim.new(0, 10)
	pPadding.PaddingLeft = UDim.new(0, 16)
	pPadding.PaddingRight = UDim.new(0, 16)
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
	itIcon.ImageColor3 = (index == 1) and self.Theme.Page or self.Theme.Ink3
	itIcon.ZIndex = 15
	itIcon.Parent = itBtn

	local itLabel = Instance.new("TextLabel")
	itLabel.Name = "Label"
	itLabel.Position = UDim2.new(0, 44, 0, 0)
	itLabel.Size = UDim2.new(1, -50, 1, 0)
	itLabel.BackgroundTransparency = 1
	itLabel.Text = config.Title
	itLabel.TextColor3 = self.Theme.Page
	itLabel.Font = Enum.Font.GothamBold
	itLabel.TextSize = 12
	itLabel.TextXAlignment = Enum.TextXAlignment.Left
	itLabel.TextTransparency = self.IsWide and 0 or 1
	itLabel.ZIndex = 15
	itLabel.Parent = itBtn

	local itBadge
	if config.Badge and config.Badge > 0 then
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
		bText.Text = tostring(config.Badge)
		bText.TextColor3 = Color3.fromRGB(255, 255, 255)
		bText.TextSize = 9
		bText.Font = Enum.Font.GothamBold
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
	-- TAB METHODS & COMPONENT BUILDERS (Compact Proportions)
	-- ==============================================================================
	
	-- Section Header
	function tab:CreateSection(title: string)
		local sec = Instance.new("Frame")
		sec.Name = "Section_" .. title
		sec.Size = UDim2.new(1, 0, 0, 20)
		sec.BackgroundTransparency = 1
		sec.Parent = page

		local sLabel = Instance.new("TextLabel")
		sLabel.Position = UDim2.new(0, 2, 0, 0)
		sLabel.Size = UDim2.new(1, -4, 1, 0)
		sLabel.BackgroundTransparency = 1
		sLabel.Text = string.upper(title)
		sLabel.TextColor3 = self.Window.Theme.Ink3
		sLabel.Font = Enum.Font.GothamBold
		sLabel.TextSize = 9.5
		sLabel.TextXAlignment = Enum.TextXAlignment.Left
		sLabel.Parent = sec

		return sec
	end

	-- Text Label
	function tab:CreateLabel(lblConfig: { Text: string })
		local lblFrame = Instance.new("Frame")
		lblFrame.Name = "LabelFrame"
		lblFrame.Size = UDim2.new(1, 0, 0, 32)
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
		lt.Text = lblConfig.Text
		lt.TextColor3 = self.Window.Theme.Ink2
		lt.Font = Enum.Font.Gotham
		lt.TextSize = 11
		lt.TextWrapped = true
		lt.TextXAlignment = Enum.TextXAlignment.Left
		lt.Parent = lblFrame

		return lblFrame
	end

	-- Compact Signature Element #040 Block (.u040-blk, 48px)
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
		bTitle.Font = Enum.Font.GothamBold
		bTitle.TextSize = 12
		bTitle.TextXAlignment = Enum.TextXAlignment.Left
		bTitle.Parent = blk

		local bDesc = Instance.new("TextLabel")
		bDesc.Name = "Desc"
		bDesc.Position = UDim2.new(0, 46, 0, 24)
		bDesc.Size = UDim2.new(1, -56, 0, 14)
		bDesc.BackgroundTransparency = 1
		bDesc.Text = cardConfig.Description or cardConfig.Meta or "Lucian UI module active"
		bDesc.TextColor3 = self.Window.Theme.Ink2
		bDesc.Font = Enum.Font.Gotham
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

	-- Compact Action Button
	function tab:CreateButton(btnConfig: { Title: string, Description: string?, Callback: () -> () })
		local blk = tab:CreateBlock({
			Title = btnConfig.Title,
			Description = btnConfig.Description or "Click to execute action",
			GradientIndex = index,
			Callback = btnConfig.Callback
		})

		local arr = Instance.new("ImageLabel")
		arr.AnchorPoint = Vector2.new(1, 0.5)
		arr.Position = UDim2.new(1, -12, 0.5, 0)
		arr.Size = UDim2.new(0, 12, 0, 12)
		arr.BackgroundTransparency = 1
		arr.Image = LucianUI.Icons.Chevron
		arr.ImageColor3 = self.Window.Theme.Ink3
		arr.Rotation = -90
		arr.Parent = blk

		return blk
	end

	-- Compact Toggle Switch
	function tab:CreateToggle(tConfig: { Title: string, Description: string?, Default: boolean?, Callback: (boolean) -> () })
		local blk = tab:CreateBlock({
			Title = tConfig.Title,
			Description = tConfig.Description or "Toggle feature state",
			GradientIndex = index
		})
		local state = tConfig.Default or false

		local switch = Instance.new("TextButton")
		switch.AnchorPoint = Vector2.new(1, 0.5)
		switch.Position = UDim2.new(1, -12, 0.5, 0)
		switch.Size = UDim2.new(0, 36, 0, 20)
		switch.BackgroundColor3 = state and self.Window.Theme.Accent or self.Window.Theme.Surface3
		switch.Text = ""
		switch.AutoButtonColor = false
		switch.Parent = blk

		local sCorn = Instance.new("UICorner")
		sCorn.CornerRadius = UDim.new(1, 0)
		sCorn.Parent = switch

		local thumb = Instance.new("Frame")
		thumb.AnchorPoint = Vector2.new(0, 0.5)
		thumb.Size = UDim2.new(0, 14, 0, 14)
		thumb.Position = state and UDim2.new(1, -17, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
		thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		thumb.BorderSizePixel = 0
		thumb.Parent = switch

		local tCorn = Instance.new("UICorner")
		tCorn.CornerRadius = UDim.new(1, 0)
		tCorn.Parent = thumb

		switch.MouseButton1Click:Connect(function()
			state = not state
			local targetColor = state and self.Window.Theme.Accent or self.Window.Theme.Surface3
			local targetPos = state and UDim2.new(1, -17, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
			TweenService:Create(switch, FAST_EASE, { BackgroundColor3 = targetColor }):Play()
			TweenService:Create(thumb, SPRING_BOUNCE, { Position = targetPos }):Play()
			tConfig.Callback(state)
		end)

		return blk
	end

	-- Compact Slider
	function tab:CreateSlider(sConfig: {
		Title: string,
		Min: number,
		Max: number,
		Default: number?,
		Suffix: string?,
		Callback: (number) -> ()
	})
		local minVal = sConfig.Min
		local maxVal = sConfig.Max
		local currentVal = sConfig.Default or minVal
		local suffix = sConfig.Suffix or ""

		local blk = tab:CreateBlock({
			Title = sConfig.Title,
			Description = tostring(currentVal) .. suffix,
			GradientIndex = index
		})

		local desc = blk:FindFirstChild("Desc")

		local track = Instance.new("Frame")
		track.AnchorPoint = Vector2.new(1, 0.5)
		track.Position = UDim2.new(1, -12, 0.5, 0)
		track.Size = UDim2.new(0, 100, 0, 5)
		track.BackgroundColor3 = self.Window.Theme.Surface3
		track.BorderSizePixel = 0
		track.Parent = blk

		local trCorn = Instance.new("UICorner")
		trCorn.CornerRadius = UDim.new(1, 0)
		trCorn.Parent = track

		local frac = math.clamp((currentVal - minVal) / math.max(1, (maxVal - minVal)), 0, 1)
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
		knob.Size = UDim2.new(0, 13, 0, 13)
		knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		knob.BorderSizePixel = 0
		knob.Parent = track

		local kCorn = Instance.new("UICorner")
		kCorn.CornerRadius = UDim.new(1, 0)
		kCorn.Parent = knob

		local dragging = false
		local function updateVal(inputX: number)
			local trAbs = track.AbsolutePosition.X
			local trWidth = track.AbsoluteSize.X
			local newFrac = math.clamp((inputX - trAbs) / trWidth, 0, 1)
			currentVal = math.round(minVal + newFrac * (maxVal - minVal))
			fill.Size = UDim2.new(newFrac, 0, 1, 0)
			knob.Position = UDim2.new(newFrac, 0, 0.5, 0)
			if desc and desc:IsA("TextLabel") then
				desc.Text = tostring(currentVal) .. suffix
			end
			sConfig.Callback(currentVal)
		end

		track.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				updateVal(input.Position.X)
			end
		end)

		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				updateVal(input.Position.X)
			end
		end)

		return blk
	end

	-- Compact Dropdown Selector
	function tab:CreateDropdown(dConfig: {
		Title: string,
		Options: { string },
		Default: string?,
		Callback: (string) -> ()
	})
		local options = dConfig.Options or {}
		local selected = dConfig.Default or options[1] or ""
		local expanded = false

		local containerFrame = Instance.new("Frame")
		containerFrame.Name = "Dropdown_" .. dConfig.Title
		containerFrame.Size = UDim2.new(1, 0, 0, 48)
		containerFrame.BackgroundColor3 = self.Window.Theme.Surface2
		containerFrame.BorderSizePixel = 0
		containerFrame.ClipsDescendants = true
		containerFrame.Parent = page

		local dCorner = Instance.new("UICorner")
		dCorner.CornerRadius = UDim.new(0, 12)
		dCorner.Parent = containerFrame

		local topRow = Instance.new("TextButton")
		topRow.Size = UDim2.new(1, 0, 0, 48)
		topRow.BackgroundTransparency = 1
		topRow.Text = ""
		topRow.Parent = containerFrame

		local badgeBox = Instance.new("Frame")
		badgeBox.Position = UDim2.new(0, 10, 0, 10)
		badgeBox.Size = UDim2.new(0, 28, 0, 28)
		badgeBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		badgeBox.BorderSizePixel = 0
		badgeBox.Parent = topRow

		local bbCorner = Instance.new("UICorner")
		bbCorner.CornerRadius = UDim.new(0, 8)
		bbCorner.Parent = badgeBox

		local bbGrad = Instance.new("UIGradient")
		bbGrad.Color = self.Window.Theme.BlockGradients[((index - 1) % 4 + 1)]
		bbGrad.Rotation = 45
		bbGrad.Parent = badgeBox

		local dTitle = Instance.new("TextLabel")
		dTitle.Position = UDim2.new(0, 46, 0, 8)
		dTitle.Size = UDim2.new(1, -90, 0, 16)
		dTitle.BackgroundTransparency = 1
		dTitle.Text = dConfig.Title
		dTitle.TextColor3 = self.Window.Theme.Ink
		dTitle.Font = Enum.Font.GothamBold
		dTitle.TextSize = 12
		dTitle.TextXAlignment = Enum.TextXAlignment.Left
		dTitle.Parent = topRow

		local dVal = Instance.new("TextLabel")
		dVal.Position = UDim2.new(0, 46, 0, 24)
		dVal.Size = UDim2.new(1, -90, 0, 14)
		dVal.BackgroundTransparency = 1
		dVal.Text = selected
		dVal.TextColor3 = self.Window.Theme.Accent
		dVal.Font = Enum.Font.GothamBold
		dVal.TextSize = 10.5
		dVal.TextXAlignment = Enum.TextXAlignment.Left
		dVal.Parent = topRow

		local arr = Instance.new("ImageLabel")
		arr.AnchorPoint = Vector2.new(1, 0.5)
		arr.Position = UDim2.new(1, -12, 0.5, 0)
		arr.Size = UDim2.new(0, 12, 0, 12)
		arr.BackgroundTransparency = 1
		arr.Image = LucianUI.Icons.Chevron
		arr.ImageColor3 = self.Window.Theme.Ink3
		arr.Rotation = 180
		arr.Parent = topRow

		local optList = Instance.new("Frame")
		optList.Position = UDim2.new(0, 0, 0, 48)
		optList.Size = UDim2.new(1, 0, 0, #options * 26)
		optList.BackgroundTransparency = 1
		optList.Parent = containerFrame

		for optIdx, optName in ipairs(options) do
			local optBtn = Instance.new("TextButton")
			optBtn.Position = UDim2.new(0, 0, 0, (optIdx - 1) * 26)
			optBtn.Size = UDim2.new(1, 0, 0, 26)
			optBtn.BackgroundColor3 = (optName == selected) and self.Window.Theme.Surface3 or self.Window.Theme.Surface2
			optBtn.BorderSizePixel = 0
			optBtn.Text = "      " .. optName
			optBtn.TextColor3 = (optName == selected) and self.Window.Theme.Accent or self.Window.Theme.Ink2
			optBtn.Font = Enum.Font.Gotham
			optBtn.TextSize = 11
			optBtn.TextXAlignment = Enum.TextXAlignment.Left
			optBtn.Parent = optList

			optBtn.MouseButton1Click:Connect(function()
				selected = optName
				dVal.Text = selected
				expanded = false
				TweenService:Create(arr, FAST_EASE, { Rotation = 180 }):Play()
				TweenService:Create(containerFrame, FAST_EASE, { Size = UDim2.new(1, 0, 0, 48) }):Play()
				dConfig.Callback(selected)
			end)
		end

		topRow.MouseButton1Click:Connect(function()
			expanded = not expanded
			local targetH = expanded and (48 + #options * 26) or 48
			local targetRot = expanded and 0 or 180
			TweenService:Create(arr, FAST_EASE, { Rotation = targetRot }):Play()
			TweenService:Create(containerFrame, FAST_EASE, { Size = UDim2.new(1, 0, 0, targetH) }):Play()
		end)

		return containerFrame
	end

	-- Compact Text Input Box
	function tab:CreateInput(iConfig: {
		Title: string,
		Description: string?,
		Placeholder: string?,
		Callback: (string) -> ()
	})
		local blk = tab:CreateBlock({
			Title = iConfig.Title,
			Description = iConfig.Description or "Type text and press enter",
			GradientIndex = index
		})

		local tb = Instance.new("TextBox")
		tb.AnchorPoint = Vector2.new(1, 0.5)
		tb.Position = UDim2.new(1, -12, 0.5, 0)
		tb.Size = UDim2.new(0, 100, 0, 24)
		tb.BackgroundColor3 = self.Window.Theme.Surface3
		tb.BorderSizePixel = 0
		tb.Text = ""
		tb.PlaceholderText = iConfig.Placeholder or "Type..."
		tb.PlaceholderColor3 = self.Window.Theme.Ink3
		tb.TextColor3 = self.Window.Theme.Ink
		tb.Font = Enum.Font.Gotham
		tb.TextSize = 10.5
		tb.ClearTextOnFocus = false
		tb.Parent = blk

		local tbCorn = Instance.new("UICorner")
		tbCorn.CornerRadius = UDim.new(0, 7)
		tbCorn.Parent = tb

		tb.FocusLost:Connect(function(enterPressed)
			if enterPressed then
				iConfig.Callback(tb.Text)
			end
		end)

		return blk
	end

	-- Compact Keybind Listener
	function tab:CreateKeybind(kConfig: {
		Title: string,
		Default: Enum.KeyCode?,
		Callback: (Enum.KeyCode) -> ()
	})
		local curKey = kConfig.Default or Enum.KeyCode.RightControl
		local listening = false

		local blk = tab:CreateBlock({
			Title = kConfig.Title,
			Description = "Current: " .. curKey.Name,
			GradientIndex = index
		})

		local desc = blk:FindFirstChild("Desc")

		local kBtn = Instance.new("TextButton")
		kBtn.AnchorPoint = Vector2.new(1, 0.5)
		kBtn.Position = UDim2.new(1, -12, 0.5, 0)
		kBtn.Size = UDim2.new(0, 80, 0, 22)
		kBtn.BackgroundColor3 = self.Window.Theme.Surface3
		kBtn.BorderSizePixel = 0
		kBtn.Text = curKey.Name
		kBtn.TextColor3 = self.Window.Theme.Accent
		kBtn.Font = Enum.Font.GothamBold
		kBtn.TextSize = 10
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
					if desc and desc:IsA("TextLabel") then
						desc.Text = "Current: " .. curKey.Name
					end
					listening = false
					conn:Disconnect()
					kConfig.Callback(curKey)
				end
			end)
		end)

		return blk
	end

	function tab:SetTitle(newTitle: string)
		tab.Title = newTitle
		itLabel.Text = newTitle
		if tab.Window.H3Title and tab.Window.CurrentIndex == index then
			tab.Window.H3Title.Text = newTitle
		end
		if tab.Window.TabBar then
			tab.Window.TabBar:SetTitle(index, newTitle)
		end
	end

	function tab:SetIcon(newIcon: string)
		tab.Icon = newIcon
		itIcon.Image = newIcon
		if tab.Window.TabBar then
			tab.Window.TabBar:SetIcon(index, newIcon)
		end
	end

	-- Badge Updater
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
		if tab.Window.TabBar then
			tab.Window.TabBar:SetBadge(index, count)
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

	-- 1. Slide Active Highlight (.u040-hl)
	local targetHlPos = UDim2.new(0, 0, 0, (index - 1) * 40)
	if immediate then
		self.ActiveHl.Position = targetHlPos
	else
		TweenService:Create(self.ActiveHl, SPRING_BOUNCE, { Position = targetHlPos }):Play()
	end

	-- 2. Swap Title (.u040-main h3.swap animation)
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

	-- 3. Show active page & update icons
	for i, t in ipairs(self.Tabs) do
		t.Page.Visible = (i == index)
		local rItem = self.RailItems and self.RailItems[i]
		if rItem then
			rItem.Icon.ImageColor3 = (i == index) and self.Theme.Page or self.Theme.Ink3
		end
	end

	-- 4. Sync with Bottom Tab Bar (#041)
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
		if self.TabBar.NotchCover then self.TabBar.NotchCover.BackgroundColor3 = newTheme.Surface end
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
		if self.TabBar and self.TabBar.CurrentIndex == 0 then
			self.TabBar:SelectTab(self.CurrentIndex or 1)
		end
	else
		if self.TabBar and self.TabBar.CurrentIndex ~= 0 then
			self.TabBar:Deselect()
		end
		self.Root.Visible = false
	end
end

function Element040:Toggle()
	self:SetVisible(not self.IsOpen)
end

-- ==============================================================================
-- UNIFIED WINDOW BUILDER: ELEMENT #040 (PANEL) + ELEMENT #041 (BOTTOM TAB BAR)
-- ==============================================================================
function LucianUI:CreateWindow(config: {
	Title: string?,
	SubTitle: string?,
	Logo: string?,
	UserName: string?,
	UserRole: string?,
	UserAvatar: string?,
	Theme: string?,
	Width: number?,
	Height: number?,
	ToggleKey: Enum.KeyCode?
})
	local window040 = Element040.new(config)

	-- Build Element #041 Bottom Bar docked at screen bottom (compact 320x60px)
	local tabBar041 = TabBar041.new({
		Parent = window040.ScreenGui,
		ThemeName = window040.ThemeName,
		Width = 320,
		Height = 60,
		Tabs = {},
		OnSelect = function(idx)
			if not window040.IsOpen then
				window040:SetVisible(true)
			end
			window040:SelectTab(idx)
		end,
		OnActiveClick = function(idx)
			-- Clicking the active tab or bubble closes panel and returns to idle unselected state
			window040:SetVisible(false)
		end
	})

	window040.TabBar = tabBar041

	-- Keybind toggle
	local toggleKey = config.ToggleKey or Enum.KeyCode.RightControl
	UserInputService.InputBegan:Connect(function(input, processed)
		if not processed and input.KeyCode == toggleKey then
			window040:Toggle()
		end
	end)

	return window040
end

function LucianUI:CreateTabBar(config: any)
	return TabBar041.new(config)
end

function LucianUI:Notify(_config: any)
	-- No-op: notification popups removed
end

return LucianUI
