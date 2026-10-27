--!strict
--[[
	<!-- Lucian UX/UI Prompt #025 · MIT License (c) 2026 Seokwoooo · https://lucianlabs.dev/uxui-prompt/#025 -->
	Element #025: Notched Floating Label Field + Key System Engine for Roblox
	Adapted for Nexus / Nexus Script Ecosystem by Ngmankhoi
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local KeySystem = {
	_version = "3.2.0",
}
KeySystem.__index = KeySystem

-- ==============================================================================
-- DESIGN TOKENS (Lucian UX/UI Theme)
-- ==============================================================================
KeySystem.Tokens = {
	Page = Color3.fromRGB(11, 12, 17),
	Surface = Color3.fromRGB(19, 21, 29),
	Surface2 = Color3.fromRGB(27, 29, 41),
	Surface3 = Color3.fromRGB(36, 39, 54),
	Ink = Color3.fromRGB(246, 248, 252),
	Ink2 = Color3.fromRGB(180, 185, 202),
	Ink3 = Color3.fromRGB(115, 122, 142),
	Line = Color3.fromRGB(255, 255, 255),
	LineTransparency = 0.90,
	Line2 = Color3.fromRGB(255, 255, 255),
	Line2Transparency = 0.82,
	Accent = Color3.fromRGB(123, 97, 255),
	AccentSoft = Color3.fromRGB(123, 97, 255),
	AccentInk = Color3.fromRGB(255, 255, 255),
	Mint = Color3.fromRGB(22, 192, 140),          -- #16C08C Valid check
	Danger = Color3.fromRGB(255, 90, 110),        -- #FF5A6E Error red
	Warn = Color3.fromRGB(255, 178, 62),
	Gradient = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(139, 108, 255)),
		ColorSequenceKeypoint.new(0.55, Color3.fromRGB(91, 140, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(44, 212, 178))
	}),
}

-- Motion Curves
local SPRING = TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local EASE = TweenInfo.new(0.30, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local FAST = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Authentic Lucide Icons on Roblox
local ICONS = {
	Check = "rbxassetid://93898873302694",
	Close = "rbxassetid://110786993356448",
	Key = "rbxassetid://10723396702",
	Link = "rbxassetid://131324733048447",
	Shield = "rbxassetid://110987169760162",
	Discord = "rbxassetid://10709791281",
}

local function getSafeGuiParent(): Instance
	local tries = {
		function() return (gethui and gethui()) end,
		function() return CoreGui end,
		function() return Players.LocalPlayer:WaitForChild("PlayerGui") end,
	}
	for _, f in ipairs(tries) do
		local ok, res = pcall(f)
		if ok and typeof(res) == "Instance" then return res end
	end
	return game:GetService("StarterGui")
end

local function getUIFont(weight: "Regular" | "Medium" | "Bold"): Enum.Font
	if weight == "Bold" then
		return Enum.Font.BuilderSansBold
	elseif weight == "Medium" then
		return Enum.Font.BuilderSansMedium
	else
		return Enum.Font.BuilderSans
	end
end

-- ==============================================================================
-- SHOW KEY SYSTEM UI (ELEMENT #025 NOTCHED FLOATING FIELD)
-- ==============================================================================
function KeySystem.Show(config: {
	Title: string?,
	Subtitle: string?,
	GetKeyUrl: string?,
	DiscordUrl: string?,
	DefaultKey: string?,
	OnValidate: ((key: string) -> (boolean, string?))?,
	OnSuccess: ((key: string) -> ())?,
})
	config = config or {}
	local titleText = config.Title or "Nexus Keysystem"
	local subText = config.Subtitle or "Nexus Security & Hardware Verification"
	local getKeyUrl = config.GetKeyUrl or "https://websitenexus1.vercel.app/"
	local discordUrl = config.DiscordUrl or "https://discord.gg/QAdVUX2wCH"

	local parentGui = getSafeGuiParent()

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "NexusKeySystem_025"
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 2147483647
	screenGui.Parent = parentGui

	-- Dimmed Backdrop
	local backdrop = Instance.new("Frame")
	backdrop.Name = "Backdrop"
	backdrop.Size = UDim2.new(1, 0, 1, 0)
	backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	backdrop.BackgroundTransparency = 1
	backdrop.BorderSizePixel = 0
	backdrop.Parent = screenGui

	TweenService:Create(backdrop, EASE, { BackgroundTransparency = 0.5 }):Play()

	-- Dialog Card (360 x 380 px)
	local card = Instance.new("Frame")
	card.Name = "KeyCard"
	card.AnchorPoint = Vector2.new(0.5, 0.5)
	card.Position = UDim2.new(0.5, 0, 0.5, 20)
	card.Size = UDim2.new(0, 360, 0, 370)
	card.BackgroundColor3 = KeySystem.Tokens.Surface
	card.BorderSizePixel = 0
	card.Parent = screenGui

	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 20)
	cardCorner.Parent = card

	local cardStroke = Instance.new("UIStroke")
	cardStroke.Color = KeySystem.Tokens.Line
	cardStroke.Transparency = KeySystem.Tokens.LineTransparency
	cardStroke.Thickness = 1
	cardStroke.Parent = card

	-- Top Brand Glow Accent Stripe
	local topStripe = Instance.new("Frame")
	topStripe.Name = "AccentStripe"
	topStripe.Position = UDim2.new(0, 24, 0, 0)
	topStripe.Size = UDim2.new(1, -48, 0, 2)
	topStripe.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	topStripe.BorderSizePixel = 0
	topStripe.Parent = card

	local stripeGrad = Instance.new("UIGradient")
	stripeGrad.Color = KeySystem.Tokens.Gradient
	stripeGrad.Parent = topStripe

	-- Header Info
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "CardTitle"
	titleLabel.Position = UDim2.new(0, 24, 0, 22)
	titleLabel.Size = UDim2.new(1, -48, 0, 22)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = titleText
	titleLabel.TextColor3 = KeySystem.Tokens.Ink
	titleLabel.Font = getUIFont("Bold")
	titleLabel.TextSize = 18
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = card

	local subLabel = Instance.new("TextLabel")
	subLabel.Name = "CardSubtitle"
	subLabel.Position = UDim2.new(0, 24, 0, 46)
	subLabel.Size = UDim2.new(1, -48, 0, 14)
	subLabel.BackgroundTransparency = 1
	subLabel.Text = subText
	subLabel.TextColor3 = KeySystem.Tokens.Ink3
	subLabel.Font = getUIFont("Medium")
	subLabel.TextSize = 11
	subLabel.TextXAlignment = Enum.TextXAlignment.Left
	subLabel.Parent = card

	-- ==============================================================================
	-- ELEMENT #025: NOTCHED FLOATING LABEL INPUT CONTAINER
	-- ==============================================================================
	local fieldContainer = Instance.new("Frame")
	fieldContainer.Name = "Element025_Field"
	fieldContainer.Position = UDim2.new(0, 24, 0, 84)
	fieldContainer.Size = UDim2.new(1, -48, 0, 60)
	fieldContainer.BackgroundTransparency = 1
	fieldContainer.Parent = card

	-- The Input Box Background
	local box = Instance.new("Frame")
	box.Name = "Box"
	box.Size = UDim2.new(1, 0, 1, 0)
	box.BackgroundColor3 = KeySystem.Tokens.Surface2
	box.BorderSizePixel = 0
	box.Parent = fieldContainer

	local boxCorner = Instance.new("UICorner")
	boxCorner.CornerRadius = UDim.new(0, 14)
	boxCorner.Parent = box

	-- Multi-segment Border Outline (l, g, r) simulating Lucian #025 .u025-line notch
	local boxStroke = Instance.new("UIStroke")
	boxStroke.Color = KeySystem.Tokens.Line2
	boxStroke.Transparency = KeySystem.Tokens.Line2Transparency
	boxStroke.Thickness = 1.5
	boxStroke.Parent = box

	-- Notch Cover: Masking pill that covers the top border when label rises
	local notchMask = Instance.new("Frame")
	notchMask.Name = "NotchMask"
	notchMask.Position = UDim2.new(0, 14, 0, -2)
	notchMask.Size = UDim2.new(0, 0, 0, 4) -- expands dynamically to label width
	notchMask.BackgroundColor3 = KeySystem.Tokens.Surface
	notchMask.BorderSizePixel = 0
	notchMask.ZIndex = 5
	notchMask.Visible = false
	notchMask.Parent = fieldContainer

	-- The Actual TextBox Input
	local textBox = Instance.new("TextBox")
	textBox.Name = "KeyInput"
	textBox.Position = UDim2.new(0, 16, 0, 14)
	textBox.Size = UDim2.new(1, -56, 1, -18)
	textBox.BackgroundTransparency = 1
	textBox.Text = tostring(config.DefaultKey or "")
	textBox.PlaceholderText = ""
	textBox.TextColor3 = KeySystem.Tokens.Ink
	textBox.Font = getUIFont("Bold")
	textBox.TextSize = 13
	textBox.TextXAlignment = Enum.TextXAlignment.Left
	textBox.ClearTextOnFocus = false
	textBox.ZIndex = 6
	textBox.Parent = fieldContainer

	-- Element #025 Floating Label (.u025-lab)
	local floatLabel = Instance.new("TextLabel")
	floatLabel.Name = "FloatingLabel"
	floatLabel.Position = UDim2.new(0, 16, 0.5, -9)
	floatLabel.Size = UDim2.new(0, 0, 0, 18)
	floatLabel.AutomaticSize = Enum.AutomaticSize.X
	floatLabel.BackgroundTransparency = 1
	floatLabel.Text = " License Key "
	floatLabel.TextColor3 = KeySystem.Tokens.Ink3
	floatLabel.Font = getUIFont("Medium")
	floatLabel.TextSize = 13
	floatLabel.ZIndex = 7
	floatLabel.Parent = fieldContainer

	-- Element #025 Success Circle Checkmark (.u025-ok)
	local okCircle = Instance.new("Frame")
	okCircle.Name = "OkBadge"
	okCircle.AnchorPoint = Vector2.new(1, 0.5)
	okCircle.Position = UDim2.new(1, -14, 0.5, 0)
	okCircle.Size = UDim2.new(0, 24, 0, 24)
	okCircle.BackgroundColor3 = KeySystem.Tokens.Mint
	okCircle.BorderSizePixel = 0
	okCircle.ZIndex = 8
	okCircle.Visible = false
	okCircle.Parent = fieldContainer

	local okCorner = Instance.new("UICorner")
	okCorner.CornerRadius = UDim.new(1, 0)
	okCorner.Parent = okCircle

	local okIcon = Instance.new("ImageLabel")
	okIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	okIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
	okIcon.Size = UDim2.new(0, 14, 0, 14)
	okIcon.BackgroundTransparency = 1
	okIcon.Image = ICONS.Check
	okIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
	okIcon.ZIndex = 9
	okIcon.Parent = okCircle

	-- Element #025 Dropdown Help / Error Message (.u025-help)
	local helpFrame = Instance.new("Frame")
	helpFrame.Name = "HelpMessage"
	helpFrame.Position = UDim2.new(0, 24, 0, 150)
	helpFrame.Size = UDim2.new(1, -48, 0, 18)
	helpFrame.BackgroundTransparency = 1
	helpFrame.Visible = false
	helpFrame.Parent = card

	local helpDot = Instance.new("Frame")
	helpDot.Name = "Dot"
	helpDot.Position = UDim2.new(0, 2, 0.5, -4)
	helpDot.Size = UDim2.new(0, 8, 0, 8)
	helpDot.BackgroundColor3 = KeySystem.Tokens.Danger
	helpDot.BorderSizePixel = 0
	helpDot.Parent = helpFrame

	local hdCorner = Instance.new("UICorner")
	hdCorner.CornerRadius = UDim.new(1, 0)
	hdCorner.Parent = helpDot

	local helpText = Instance.new("TextLabel")
	helpText.Name = "Text"
	helpText.Position = UDim2.new(0, 16, 0, 0)
	helpText.Size = UDim2.new(1, -20, 1, 0)
	helpText.BackgroundTransparency = 1
	helpText.Text = "Invalid key format or expired. Please check."
	helpText.TextColor3 = KeySystem.Tokens.Danger
	helpText.Font = getUIFont("Medium")
	helpText.TextSize = 11
	helpText.TextXAlignment = Enum.TextXAlignment.Left
	helpText.Parent = helpFrame

	-- ==============================================================================
	-- ELEMENT #025 FLOATING & SHAKE CONTROLLER
	-- ==============================================================================
	local isFocused = false

	local function updateLift()
		local hasText = #textBox.Text > 0
		local shouldLift = isFocused or hasText

		if shouldLift then
			-- Lift label into notch
			TweenService:Create(floatLabel, EASE, {
				Position = UDim2.new(0, 12, 0, -9),
				TextColor3 = isFocused and KeySystem.Tokens.Accent or KeySystem.Tokens.Ink2,
				TextSize = 10.5
			}):Play()
			notchMask.Visible = true
			notchMask.Size = UDim2.new(0, floatLabel.AbsoluteSize.X + 8, 0, 4)
			notchMask.Position = UDim2.new(0, 12, 0, -2)
			TweenService:Create(textBox, EASE, { Position = UDim2.new(0, 16, 0, 16), Size = UDim2.new(1, -56, 1, -20) }):Play()
		else
			-- Return label inside box
			TweenService:Create(floatLabel, EASE, {
				Position = UDim2.new(0, 16, 0.5, -9),
				TextColor3 = KeySystem.Tokens.Ink3,
				TextSize = 13
			}):Play()
			notchMask.Visible = false
			TweenService:Create(textBox, EASE, { Position = UDim2.new(0, 16, 0, 8), Size = UDim2.new(1, -56, 1, -16) }):Play()
		end
	end

	textBox.Focused:Connect(function()
		isFocused = true
		helpFrame.Visible = false
		boxStroke.Color = KeySystem.Tokens.Accent
		boxStroke.Transparency = 0.2
		updateLift()
	end)

	textBox.FocusLost:Connect(function()
		isFocused = false
		boxStroke.Color = KeySystem.Tokens.Line2
		boxStroke.Transparency = KeySystem.Tokens.Line2Transparency
		updateLift()
	end)

	textBox:GetPropertyChangedSignal("Text"):Connect(function()
		updateLift()
	end)

	-- Shake animation on error (.u025-shake)
	local function triggerShake(msg: string)
		helpFrame.Visible = true
		helpText.Text = msg
		helpText.TextColor3 = KeySystem.Tokens.Danger
		helpDot.BackgroundColor3 = KeySystem.Tokens.Danger
		boxStroke.Color = KeySystem.Tokens.Danger
		boxStroke.Transparency = 0.2
		floatLabel.TextColor3 = KeySystem.Tokens.Danger

		local origPos = fieldContainer.Position
		task.spawn(function()
			local offsets = { -8, 8, -6, 6, -3, 3, 0 }
			for _, off in ipairs(offsets) do
				fieldContainer.Position = origPos + UDim2.new(0, off, 0, 0)
				task.wait(0.04)
			end
		end)
	end

	local function triggerSuccess()
		helpFrame.Visible = true
		helpText.Text = "Key verified successfully! Launching..."
		helpText.TextColor3 = KeySystem.Tokens.Mint
		helpDot.BackgroundColor3 = KeySystem.Tokens.Mint
		boxStroke.Color = KeySystem.Tokens.Mint
		boxStroke.Transparency = 0.2
		floatLabel.TextColor3 = KeySystem.Tokens.Mint

		okCircle.Visible = true
		okCircle.Size = UDim2.new(0, 0, 0, 0)
		TweenService:Create(okCircle, SPRING, { Size = UDim2.new(0, 24, 0, 24) }):Play()
	end

	-- ==============================================================================
	-- ACTION BUTTONS
	-- ==============================================================================
	-- 1. Primary Action: Submit Key
	local submitBtn = Instance.new("TextButton")
	submitBtn.Name = "SubmitBtn"
	submitBtn.Position = UDim2.new(0, 24, 0, 182)
	submitBtn.Size = UDim2.new(1, -48, 0, 48)
	submitBtn.BackgroundColor3 = KeySystem.Tokens.Ink
	submitBtn.BorderSizePixel = 0
	submitBtn.Text = "Submit Key"
	submitBtn.TextColor3 = KeySystem.Tokens.Page
	submitBtn.Font = getUIFont("Bold")
	submitBtn.TextSize = 14
	submitBtn.AutoButtonColor = false
	submitBtn.Parent = card

	local sbCorner = Instance.new("UICorner")
	sbCorner.CornerRadius = UDim.new(0, 14)
	sbCorner.Parent = submitBtn

	submitBtn.MouseEnter:Connect(function()
		TweenService:Create(submitBtn, FAST, { BackgroundColor3 = Color3.fromRGB(255, 255, 255) }):Play()
	end)
	submitBtn.MouseLeave:Connect(function()
		TweenService:Create(submitBtn, FAST, { BackgroundColor3 = KeySystem.Tokens.Ink }):Play()
	end)

	-- 2. Secondary Action: Get Key (Link)
	local getKeyBtn = Instance.new("TextButton")
	getKeyBtn.Name = "GetKeyBtn"
	getKeyBtn.Position = UDim2.new(0, 24, 0, 240)
	getKeyBtn.Size = UDim2.new(1, -48, 0, 44)
	getKeyBtn.BackgroundColor3 = KeySystem.Tokens.Surface2
	getKeyBtn.BorderSizePixel = 0
	getKeyBtn.Text = "Get Key / Copy Link"
	getKeyBtn.TextColor3 = KeySystem.Tokens.Ink
	getKeyBtn.Font = getUIFont("Bold")
	getKeyBtn.TextSize = 13
	getKeyBtn.AutoButtonColor = false
	getKeyBtn.Parent = card

	local gkCorner = Instance.new("UICorner")
	gkCorner.CornerRadius = UDim.new(0, 14)
	gkCorner.Parent = getKeyBtn

	local gkStroke = Instance.new("UIStroke")
	gkStroke.Color = KeySystem.Tokens.Line
	gkStroke.Transparency = KeySystem.Tokens.LineTransparency
	gkStroke.Thickness = 1
	gkStroke.Parent = getKeyBtn

	-- 3. Discord Support Link Button
	local discordBtn = Instance.new("TextButton")
	discordBtn.Name = "DiscordBtn"
	discordBtn.Position = UDim2.new(0, 24, 0, 294)
	discordBtn.Size = UDim2.new(1, -48, 0, 44)
	discordBtn.BackgroundColor3 = KeySystem.Tokens.Surface2
	discordBtn.BorderSizePixel = 0
	discordBtn.Text = "Join Discord Community"
	discordBtn.TextColor3 = KeySystem.Tokens.Ink2
	discordBtn.Font = getUIFont("Medium")
	discordBtn.TextSize = 12
	discordBtn.AutoButtonColor = false
	discordBtn.Parent = card

	local dcCorner = Instance.new("UICorner")
	dcCorner.CornerRadius = UDim.new(0, 14)
	dcCorner.Parent = discordBtn

	local dcStroke = Instance.new("UIStroke")
	dcStroke.Color = KeySystem.Tokens.Line
	dcStroke.Transparency = KeySystem.Tokens.LineTransparency
	dcStroke.Thickness = 1
	dcStroke.Parent = discordBtn

	-- Button Interactions
	local function copyText(text: string): boolean
		if setclipboard then
			pcall(setclipboard, text)
			return true
		end
		return false
	end

	getKeyBtn.MouseButton1Click:Connect(function()
		if copyText(getKeyUrl) then
			getKeyBtn.Text = "Copied link to clipboard!"
			task.delay(1.8, function()
				if getKeyBtn.Parent then getKeyBtn.Text = "Get Key / Copy Link" end
			end)
		else
			helpFrame.Visible = true
			helpText.Text = "Copy URL: " .. getKeyUrl
			helpText.TextColor3 = KeySystem.Tokens.Warn
			helpDot.BackgroundColor3 = KeySystem.Tokens.Warn
		end
	end)

	discordBtn.MouseButton1Click:Connect(function()
		if copyText(discordUrl) then
			discordBtn.Text = "Discord link copied!"
			task.delay(1.8, function()
				if discordBtn.Parent then discordBtn.Text = "Join Discord Community" end
			end)
		end
	end)

	local isSubmitting = false
	submitBtn.MouseButton1Click:Connect(function()
		if isSubmitting then return end
		local key = textBox.Text:gsub("^%s+", ""):gsub("%s+$", "")

		if #key < 4 then
			triggerShake("Please enter a valid key.")
			return
		end

		isSubmitting = true
		submitBtn.Text = "Verifying..."
		TweenService:Create(submitBtn, FAST, { BackgroundColor3 = KeySystem.Tokens.Surface3, TextColor3 = KeySystem.Tokens.Ink3 }):Play()

		task.spawn(function()
			local ok = true
			local errMsg: string? = nil

			if config.OnValidate then
				local vok, verr = pcall(config.OnValidate, key)
				if vok then
					ok = (verr == true)
					if not ok then errMsg = "Invalid key or HWID mismatch." end
				else
					ok = false
					errMsg = tostring(verr)
				end
			else
				-- Default mock test validate
				task.wait(0.6)
				ok = (#key >= 6)
				if not ok then errMsg = "Key must be at least 6 characters." end
			end

			if ok then
				triggerSuccess()
				task.wait(0.8)

				-- Exit tween
				TweenService:Create(card, FAST, { Position = UDim2.new(0.5, 0, 0.5, -30), BackgroundTransparency = 1 }):Play()
				TweenService:Create(backdrop, FAST, { BackgroundTransparency = 1 }):Play()

				task.wait(0.2)
				screenGui:Destroy()

				if config.OnSuccess then
					pcall(config.OnSuccess, key)
				end
			else
				isSubmitting = false
				submitBtn.Text = "Submit Key"
				TweenService:Create(submitBtn, FAST, { BackgroundColor3 = KeySystem.Tokens.Ink, TextColor3 = KeySystem.Tokens.Page }):Play()
				triggerShake(errMsg or "Key validation failed.")
			end
		end)
	end)

	-- Initial entrance animation
	card.Position = UDim2.new(0.5, 0, 0.5, 40)
	TweenService:Create(card, SPRING, { Position = UDim2.new(0.5, 0, 0.5, 0) }):Play()

	if #textBox.Text > 0 then
		updateLift()
	end

	return screenGui
end

local runtimeEnv = (getgenv and getgenv()) or _G or {}
runtimeEnv.NexusKeySystem = KeySystem
return KeySystem
