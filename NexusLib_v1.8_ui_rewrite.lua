-- Nexus Panel UI v1.8
-- Update log: NEW UI
-- Rebuilt as a restrained, responsive Roblox instrument panel.

local NEXUS_VERSION = "1.8"
local NEXUS_UPDATE_LOG = "NEW UI"
local scriptStartedAt = os.clock()

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local guiParent = player:WaitForChild("PlayerGui")
local env = (getgenv and getgenv()) or _G

-- A re-execution must tear down the prior library before it can attach input listeners.
local previousNexus = env.NexusLib
if previousNexus and previousNexus.DestroyAll then pcall(function() previousNexus:DestroyAll() end) end
for _, child in ipairs(guiParent:GetChildren()) do
    if child:GetAttribute("NexusPanel") or child.Name == "NexusNotifications" then child:Destroy() end
end

local NexusLib = {
    _windows = {}, _notificationGui = nil, _connections = {}, _debounces = {},
    _notifyQueue = {}, _activeNotifications = 0, _notifyLast = {},
    _uiLoops = {}, _infoPanels = {},
    Info = { ["Script Name"] = "Nexus", Version = NEXUS_VERSION, ["Current Module"] = "N/A", ["Current Target"] = "N/A", Status = "Ready", ["Last Action"] = "Loaded", Warning = "None", ["Player"] = player.Name, ["Game"] = game.Name, Runtime = "00:00:00", FPS = "N/A", Ping = "N/A" },
}

local C = {
    canvas = Color3.fromRGB(15, 16, 17),
    shell = Color3.fromRGB(27, 28, 29),
    rail = Color3.fromRGB(20, 21, 22),
    raised = Color3.fromRGB(37, 38, 39),
    hover = Color3.fromRGB(46, 47, 48),
    pressed = Color3.fromRGB(40, 38, 33),
    line = Color3.fromRGB(67, 68, 67),
    lineSoft = Color3.fromRGB(48, 49, 49),
    ivory = Color3.fromRGB(241, 238, 229),
    secondary = Color3.fromRGB(167, 168, 164),
    muted = Color3.fromRGB(101, 104, 103),
    brass = Color3.fromRGB(196, 161, 101),
    brassSoft = Color3.fromRGB(74, 63, 45),
    mist = Color3.fromRGB(126, 157, 160),
    success = Color3.fromRGB(132, 164, 139),
    danger = Color3.fromRGB(184, 91, 81),
    warning = Color3.fromRGB(214, 165, 77),
    info = Color3.fromRGB(126, 157, 160),
}

local Motion = {
    fast = TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    base = TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    enter = TweenInfo.new(0.46, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    exit = TweenInfo.new(0.20, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
    tabIn = TweenInfo.new(0.30, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    tabOut = TweenInfo.new(0.14, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
}

local interactionTweens = setmetatable({}, { __mode = "k" })

local function make(className, props, parent)
    local object = Instance.new(className)
    for key, value in pairs(props or {}) do object[key] = value end
    object.Parent = parent
    return object
end

local function corner(parent, radius)
    return make("UICorner", { CornerRadius = UDim.new(0, radius) }, parent)
end

local function stroke(parent, color, transparency, thickness)
    return make("UIStroke", {
        Color = color or C.line,
        Transparency = transparency or 0,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, parent)
end

local function padding(parent, left, right, top, bottom)
    return make("UIPadding", {
        PaddingLeft = UDim.new(0, left), PaddingRight = UDim.new(0, right),
        PaddingTop = UDim.new(0, top), PaddingBottom = UDim.new(0, bottom),
    }, parent)
end

local function tween(object, info, properties)
    local animation = TweenService:Create(object, info, properties)
    animation:Play()
    return animation
end

local function animate(object, channel, info, properties)
    local channels = interactionTweens[object]
    if not channels then
        channels = {}
        interactionTweens[object] = channels
    end
    if channels[channel] then channels[channel]:Cancel() end
    local animation = TweenService:Create(object, info, properties)
    channels[channel] = animation
    animation.Completed:Connect(function()
        if channels[channel] == animation then channels[channel] = nil end
    end)
    animation:Play()
    return animation
end

-- Public utility surface: every tween is returned for optional cancellation/inspection.
local function createTween(instance, tweenInfo, props)
    return tween(instance, tweenInfo or Motion.base, props)
end

local function debounceAction(key, delay, callback)
    local now = os.clock()
    local untilTime = NexusLib._debounces[key] or 0
    if now < untilTime then return false end
    NexusLib._debounces[key] = now + (delay or 0.12)
    callback()
    return true
end

function NexusLib:createTween(instance, tweenInfo, props) return createTween(instance, tweenInfo, props) end
function NexusLib:debounceAction(key, delay, callback) return debounceAction(key, delay, callback) end
function NexusLib:trackConnection(connection)
    if connection then table.insert(self._connections, connection) end
    return connection
end
function NexusLib:trackUILoop(loop)
    if loop then table.insert(self._uiLoops, loop) end
    return loop
end
function NexusLib:stopAllUILoops()
    for _, loop in ipairs(self._uiLoops) do
        pcall(function()
            if typeof(loop) == "RBXScriptConnection" then loop:Disconnect()
            elseif type(loop) == "table" and loop.Stop then loop:Stop()
            elseif type(loop) == "function" then loop() end
        end)
    end
    table.clear(self._uiLoops)
end
function NexusLib:cleanupConnections()
    for _, connection in ipairs(self._connections) do pcall(function() connection:Disconnect() end) end
    table.clear(self._connections)
end
function NexusLib:destroyOldUI() self:DestroyAll() end

local function label(parent, text, size, color, font)
    return make("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Text = text or "",
        TextColor3 = color or C.ivory,
        TextSize = size or 13,
        Font = font or Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
    }, parent)
end

local function clampScrollPosition(scroll)
    if not scroll or not scroll.Parent then return end
    local maxY = math.max(0, scroll.AbsoluteCanvasSize.Y - scroll.AbsoluteWindowSize.Y)
    local clampedY = math.clamp(scroll.CanvasPosition.Y, 0, maxY)
    if math.abs(scroll.CanvasPosition.Y - clampedY) > 0.01 then
        scroll.CanvasPosition = Vector2.new(0, clampedY)
    end
end

local function navIcon(parent, name)
    local host = make("Frame", {
        Name = name .. "Icon", BackgroundTransparency = 1,
        Position = UDim2.fromOffset(10, 9), Size = UDim2.fromOffset(18, 18),
        ClipsDescendants = true, ZIndex = 4,
    }, parent)
    local parts = {}
    local function line(x, y, w, h)
        local part = make("Frame", {
            BorderSizePixel = 0, BackgroundColor3 = C.muted,
            Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(w, h), ZIndex = 4,
        }, host)
        table.insert(parts, part)
        return part
    end
    local function outline(x, y, w, h, radius, rotation)
        local part = make("Frame", {
            BorderSizePixel = 0, BackgroundTransparency = 1,
            Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(w, h),
            Rotation = rotation or 0, ZIndex = 4,
        }, host)
        corner(part, radius or 2)
        local edge = stroke(part, C.muted, 0.1)
        table.insert(parts, edge)
        return part
    end
    if name == "Session" then
        outline(4, 4, 10, 10, 5)
        local dot = line(8, 8, 2, 2); corner(dot, 1)
    elseif name == "Routine" then
        line(3, 4, 12, 1); line(3, 8, 12, 1); line(3, 12, 12, 1)
        local a = line(6, 2, 2, 5); corner(a, 1)
        local b = line(11, 6, 2, 5); corner(b, 1)
        local c = line(5, 10, 2, 5); corner(c, 1)
    elseif name == "Teleport" then
        outline(5, 5, 8, 8, 1, 45)
        local dot = line(8, 8, 2, 2); corner(dot, 1)
    else
        outline(3, 5, 12, 8, 2)
        line(6, 8, 6, 1); line(6, 11, 4, 1)
    end
    return parts
end

local function setNavIconColor(parts, color)
    for _, part in ipairs(parts) do
        if part:IsA("UIStroke") then part.Color = color else part.BackgroundColor3 = color end
    end
end

local function addPressScale(button)
    local scale = make("UIScale", { Scale = 1 }, button)
    -- Keep the button's outer geometry fixed. Scaling rounded GuiObjects can
    -- invalidate Roblox's corner cache and make the background appear smaller.
    return scale
end

local function hoverLayer(parent, color, radius, zIndex, transparency)
    local layer = make("Frame", {
        Name = "HoverLayer", BackgroundColor3 = color, BorderSizePixel = 0,
        BackgroundTransparency = transparency or 0,
        Size = UDim2.fromScale(1, 1), Visible = false,
        Active = false, Selectable = false, ZIndex = zIndex or (parent.ZIndex + 1),
    }, parent)
    corner(layer, radius)
    return layer
end

local function bindHover(hitTarget, layer, onEnter, onLeave)
    -- Keep hover state on a dedicated child. Mutating a rounded input object's
    -- own background can corrupt Roblox's corner/render cache for that object.
    hitTarget.MouseEnter:Connect(function()
        layer.Visible = true
        if onEnter then onEnter() end
    end)
    hitTarget.MouseLeave:Connect(function()
        layer.Visible = false
        if onLeave then onLeave() end
    end)
end

local function resetHoverLayers(root)
    if not root then return end
    if root.Name == "HoverLayer" then root.Visible = false end
    for _, object in ipairs(root:GetDescendants()) do
        if object.Name == "HoverLayer" and object:IsA("GuiObject") then
            object.Visible = false
        end
    end
end

local function makeButtonInteractive(button)
    local scale = button:FindFirstChildOfClass("UIScale") or make("UIScale", { Scale = 1 }, button)
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            animate(scale, "press", Motion.fast, { Scale = 0.96 })
        end
    end)
    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            animate(scale, "press", Motion.fast, { Scale = 1 })
        end
    end)
    return scale
end

local function setToggleVisual(track, knob, enabled)
    if not track or not knob then return end
    tween(track, Motion.base, { BackgroundColor3 = enabled and C.success or Color3.fromRGB(55, 57, 57) })
    tween(knob, Motion.base, { Position = enabled and UDim2.new(1, -11, 0.5, 0) or UDim2.new(0, 11, 0.5, 0) })
end

local function playOpenAnimation(frame)
    if not frame then return end
    frame.Visible = true
    if frame:IsA("CanvasGroup") then frame.GroupTransparency = 1; tween(frame, Motion.enter, { GroupTransparency = 0 }) end
end

local function playCloseAnimation(frame)
    if not frame then return end
    if frame:IsA("CanvasGroup") then
        tween(frame, Motion.exit, { GroupTransparency = 1 })
        task.delay(0.22, function() if frame.Parent then frame.Visible = false end end)
    else
        frame.Visible = false
    end
end

function NexusLib:makeButtonInteractive(button) return makeButtonInteractive(button) end
function NexusLib:setToggleVisual(track, knob, enabled) return setToggleVisual(track, knob, enabled) end
function NexusLib:playOpenAnimation(frame) return playOpenAnimation(frame) end
function NexusLib:playCloseAnimation(frame) return playCloseAnimation(frame) end
function NexusLib:createMobileToggleButton(window)
    return window and window._gui and window._gui:FindFirstChild("NexusLauncher")
end

local function bindActivation(hitTarget, callback, debounceDelay)
    local pressedInput, pressedAt, pressedWithPointer = nil, nil, false
    hitTarget.Selectable = true
    makeButtonInteractive(hitTarget)
    hitTarget.InputBegan:Connect(function(input)
        if pressedInput ~= nil then return end
        local pointer = input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
        local key = input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.ButtonA
        if not pointer and not key then return end
        pressedInput, pressedAt, pressedWithPointer = input, pointer and input.Position or nil, pointer
    end)
    hitTarget.InputEnded:Connect(function(input)
        if input ~= pressedInput then return end
        local start, pointer = pressedAt, pressedWithPointer
        pressedInput, pressedAt, pressedWithPointer = nil, nil, false
        local activate = not pointer
        if pointer then
            local point, pos, size = input.Position, hitTarget.AbsolutePosition, hitTarget.AbsoluteSize
            activate = start and point.X >= pos.X and point.X <= pos.X + size.X and point.Y >= pos.Y and point.Y <= pos.Y + size.Y and (point - start).Magnitude <= 8
        end
        if activate then debounceAction("activation:" .. hitTarget:GetDebugId(), debounceDelay or 0.12, callback) end
    end)
end


local Window = {}; Window.__index = Window
local Tab = {}; Tab.__index = Tab
local Section = {}; Section.__index = Section

local NotifyColors = { Success = C.success, Error = C.danger, Warning = C.warning, Info = C.info }
local NotifyIcons = { Success = "✓", Error = "!", Warning = "!", Info = "i" }

local function ensureNotificationGui(self)
    if self._notificationGui and self._notificationGui.Parent then return self._notificationGui.Stack end
    self._notificationGui = make("ScreenGui", { Name = "NexusNotifications", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 1002 }, guiParent)
    self._notificationGui:SetAttribute("NexusPanel", true)
    local stack = make("Frame", { Name = "Stack", BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -16, 1, -16), Size = UDim2.new(0, 336, 1, -32) }, self._notificationGui)
    make("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, VerticalAlignment = Enum.VerticalAlignment.Bottom, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, stack)
    return stack
end

local function showNotification(self, config)
    local stack, kind = ensureNotificationGui(self), string.upper(config.Type or "Info")
    local accent = NotifyColors[kind:sub(1,1) .. kind:sub(2):lower()] or NotifyColors.Info
    local card = make("CanvasGroup", { Name = "Notification", BackgroundColor3 = C.shell, BackgroundTransparency = 0.02, Size = UDim2.new(1, 0, 0, 78), GroupTransparency = 1, Position = UDim2.new(0, 20, 0, 0) }, stack)
    corner(card, 14); stroke(card, C.line, 0.15)
    make("Frame", { BorderSizePixel = 0, BackgroundColor3 = accent, Position = UDim2.new(0, 0, 0, 12), Size = UDim2.new(0, 3, 1, -24) }, card)
    local icon = make("Frame", { BorderSizePixel = 0, BackgroundColor3 = accent, Position = UDim2.fromOffset(16, 12), Size = UDim2.fromOffset(18, 18) }, card)
    corner(icon, 6)
    local iconText = label(icon, NotifyIcons[kind:sub(1,1) .. kind:sub(2):lower()] or "i", 11, C.canvas, Enum.Font.GothamBold)
    iconText.TextXAlignment = Enum.TextXAlignment.Center
    local title = label(card, config.Title or kind, 12, C.ivory, Enum.Font.GothamBold)
    title.Position = UDim2.fromOffset(42, 10); title.Size = UDim2.new(1, -75, 0, 19)
    local message = label(card, config.Message or "", 11, C.secondary)
    message.Position = UDim2.fromOffset(42, 31); message.Size = UDim2.new(1, -61, 0, 34); message.TextWrapped = true; message.TextYAlignment = Enum.TextYAlignment.Top
    local close = make("Frame", { Name = "Close", BackgroundTransparency = 1, Active = true, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0, 7), Size = UDim2.fromOffset(25, 25), ZIndex = 10 }, card)
    local closeText = label(close, "×", 17, C.muted, Enum.Font.GothamBold); closeText.TextXAlignment = Enum.TextXAlignment.Center; closeText.ZIndex = 11
    bindHover(close, hoverLayer(close, C.hover, 8, 10, 0.25))
    local dismissed = false
    local function dismiss()
        if dismissed then return end
        dismissed = true
        tween(card, Motion.exit, { GroupTransparency = 1, Position = UDim2.new(0, 20, 0, 0) })
        task.delay(0.22, function()
            if card.Parent then card:Destroy() end
            self._activeNotifications = math.max(0, self._activeNotifications - 1)
            if #self._notifyQueue > 0 then
                local nextConfig = table.remove(self._notifyQueue, 1)
                self._activeNotifications = self._activeNotifications + 1
                showNotification(self, nextConfig)
            end
        end)
    end
    bindActivation(close, dismiss)
    tween(card, Motion.enter, { GroupTransparency = 0, Position = UDim2.new(0, 0, 0, 0) })
    task.delay(config.Duration or 4, dismiss)
end

function NexusLib:Notify(config)
    config = type(config) == "table" and config or { Message = tostring(config) }
    local key, cooldown = config.Key or ((config.Type or "Info") .. ":" .. (config.Message or "")), config.Cooldown or 0.75
    local now = os.clock()
    if now - (self._notifyLast[key] or -math.huge) < cooldown then return false end
    self._notifyLast[key] = now
    if self._activeNotifications >= 3 then table.insert(self._notifyQueue, config) else self._activeNotifications = self._activeNotifications + 1; showNotification(self, config) end
    return true
end

function NexusLib:notify(message, notifyType, duration)
    return self:Notify({ Message = tostring(message or ""), Type = notifyType or "Info", Duration = duration })
end

function NexusLib:clearNotifications()
    table.clear(self._notifyQueue)
    self._activeNotifications = 0
    if self._notificationGui then self._notificationGui:Destroy(); self._notificationGui = nil end
end

function NexusLib:CreateWindow(config)
    config = config or {}
    self:DestroyAll()

    local sg = make("ScreenGui", {
        Name = "NexusPanel", ResetOnSpawn = false, IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 1000,
    }, guiParent)
    sg:SetAttribute("NexusPanel", true)

    local viewport = make("Frame", {
        Name = "Viewport", BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1), ClipsDescendants = false,
    }, sg)
    local scale = make("UIScale", { Scale = 1 }, viewport)

    local shadow = make("Frame", {
        Name = "ContactDepth", BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(3, 4, 4), BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 5),
        Size = UDim2.fromOffset(764, 504),
    }, viewport)
    corner(shadow, 22)

    local shell = make("CanvasGroup", {
        Name = "Panel", BackgroundColor3 = C.shell, BorderSizePixel = 0, GroupTransparency = 0,
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 18),
        Size = UDim2.fromOffset(760, 500),
        ClipsDescendants = true,
    }, viewport)
    corner(shell, 20)
    local panelScale = make("UIScale", { Scale = 0.975 }, shell)
    make("UIGradient", {
        Color = ColorSequence.new(C.shell, C.canvas), Rotation = 90,
    }, shell)
    local rail = make("Frame", {
        Name = "Rail", BorderSizePixel = 0, BackgroundColor3 = C.rail,
        Size = UDim2.new(0, 184, 1, 0),
    }, shell)
    -- Roblox does not clip descendants to a parent's UICorner. Round the rail
    -- itself, then square only its inner edge so the panel's two left corners
    -- remain visible while the content boundary stays perfectly vertical.
    corner(rail, 20)
    make("Frame", {
        Name = "InnerEdgeFill", BorderSizePixel = 0, BackgroundColor3 = C.rail,
        Position = UDim2.new(1, -20, 0, 0), Size = UDim2.new(0, 20, 1, 0),
    }, rail)
    make("Frame", {
        BorderSizePixel = 0, BackgroundColor3 = C.lineSoft,
        Position = UDim2.new(1, -1, 0, 0), Size = UDim2.new(0, 1, 1, 0),
    }, rail)

    local avatarUri = string.format("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150", player.UserId)
    local mark = make("ImageLabel", {
        BorderSizePixel = 0, BackgroundColor3 = C.raised,
        Image = avatarUri, ScaleType = Enum.ScaleType.Crop,
        Position = UDim2.fromOffset(20, 22), Size = UDim2.fromOffset(28, 28),
        ClipsDescendants = true,
    }, rail)
    corner(mark, 9); stroke(mark, C.brassSoft, 0.08)

    local brand = label(rail, player.DisplayName, 12, C.ivory, Enum.Font.GothamBold)
    brand.Position = UDim2.fromOffset(58, 18); brand.Size = UDim2.new(1, -70, 0, 20)
    brand.TextTruncate = Enum.TextTruncate.AtEnd
    local subtitle = label(rail, "@" .. player.Name, 9, C.muted, Enum.Font.GothamMedium)
    subtitle.Position = UDim2.fromOffset(58, 38); subtitle.Size = UDim2.new(1, -70, 0, 14)
    subtitle.TextTruncate = Enum.TextTruncate.AtEnd

    local nav = make("Frame", {
        Name = "Navigation", BackgroundTransparency = 1,
        Position = UDim2.fromOffset(14, 86), Size = UDim2.new(1, -28, 1, -130),
        ClipsDescendants = true, ZIndex = 2,
    }, rail)
    make("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }, nav)

    local hint = label(rail, "RIGHT ALT  ·  TOGGLE", 9, C.muted, Enum.Font.GothamMedium)
    hint.Position = UDim2.new(0, 20, 1, -32); hint.Size = UDim2.new(1, -40, 0, 16)

    local top = make("Frame", {
        Name = "TopBar", BackgroundTransparency = 1,
        Position = UDim2.fromOffset(184, 0), Size = UDim2.new(1, -184, 0, 72),
    }, shell)
    local context = label(top, "SESSION", 10, C.brass, Enum.Font.GothamBold)
    context.Position = UDim2.fromOffset(24, 15); context.Size = UDim2.new(1, -120, 0, 14)
    local pageTitle = label(top, "Overview", 18, C.ivory, Enum.Font.GothamBold)
    pageTitle.Position = UDim2.fromOffset(24, 30); pageTitle.Size = UDim2.new(1, -120, 0, 26)

    local function createTopButton(name, glyph, textSize, hoverColor, xOffset)
        local button = make("Frame", {
            Name = name, BackgroundTransparency = 1, Active = true,
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, xOffset, 0, 18), Size = UDim2.fromOffset(34, 34),
            ZIndex = 10,
        }, top)
        local surface = make("Frame", {
            Name = "Surface", BackgroundColor3 = C.raised, BorderSizePixel = 0,
            Size = UDim2.fromScale(1, 1), Active = false, ZIndex = 3,
        }, button)
        corner(surface, 10); stroke(surface, C.lineSoft, 0.1)
        local hover = hoverLayer(surface, hoverColor, 10, 4)
        local glyphLabel = label(button, glyph, textSize, C.secondary, Enum.Font.GothamBold)
        glyphLabel.Name = "Glyph"; glyphLabel.TextXAlignment = Enum.TextXAlignment.Center
        glyphLabel.ZIndex = 5
        addPressScale(button)
        bindHover(button, hover)
        return button
    end

    local minimize = createTopButton("MinimizeButton", "—", 14, C.hover, -52)
    local close = createTopButton("CloseButton", "×", 16, C.danger, -12)

    local content = make("Frame", {
        Name = "ContentViewport", BackgroundTransparency = 1,
        Position = UDim2.fromOffset(184, 72), Size = UDim2.new(1, -184, 1, -72),
        ClipsDescendants = true,
    }, shell)

    local launcher = make("Frame", {
        Name = "NexusLauncher", BackgroundTransparency = 1, BorderSizePixel = 0,
        Active = true, Visible = false, ZIndex = 10,
        Position = UDim2.fromOffset(18, 104), Size = UDim2.fromOffset(56, 56),
    }, sg)
    local launcherVisual = make("ImageLabel", {
        Name = "LauncherVisual", BackgroundColor3 = C.shell, BorderSizePixel = 0,
        Image = avatarUri, ScaleType = Enum.ScaleType.Crop,
        Size = UDim2.fromScale(1, 1), ClipsDescendants = true, ZIndex = 3,
    }, launcher)
    corner(launcherVisual, 16); stroke(launcherVisual, C.brassSoft, 0.08)
    local launcherGlyph = label(launcher, "N", 17, C.ivory, Enum.Font.GothamBold)
    launcherGlyph.TextXAlignment = Enum.TextXAlignment.Center; launcherGlyph.ZIndex = 5
    local launcherHover = hoverLayer(launcherVisual, C.brassSoft, 14, 4, 0.58)
    bindHover(launcher, launcherHover)

    local window = setmetatable({
        _gui = sg, _shell = shell, _shadow = shadow, _scale = scale, _panelScale = panelScale,
        _nav = nav, _content = content, _pageTitle = pageTitle, _context = context,
        _tabs = {}, _active = nil, _hoveredTab = nil, _open = true, _connections = {},
        _transitionId = 0, _pageTweens = {},
        _visibilityId = 0, _transitioning = false, _openPosition = UDim2.new(0.5, 0, 0.5, 0),
        _keybind = config.Keybind or Enum.KeyCode.RightAlt,
    }, Window)
    table.insert(self._windows, window)

    local function updateScale()
        local camera = workspace.CurrentCamera
        if not camera then return end
        local v = camera.ViewportSize
        scale.Scale = math.min(1, (v.X - 32) / 760, (v.Y - 32) / 500)
    end
    local cameraConnection = nil
    local function bindCamera()
        if cameraConnection then cameraConnection:Disconnect(); cameraConnection = nil end
        local camera = workspace.CurrentCamera
        if camera then
            updateScale()
            cameraConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
        end
    end
    bindCamera()
    table.insert(window._connections, workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindCamera))
    table.insert(window._connections, { Disconnect = function() if cameraConnection then cameraConnection:Disconnect() end end })

    local dragging, dragStart, startPosition
    table.insert(window._connections, top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging, dragStart, startPosition = true, input.Position, shell.Position
        end
    end))
    table.insert(window._connections, UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            shell.Position = startPosition + UDim2.fromOffset(delta.X / scale.Scale, delta.Y / scale.Scale)
            shadow.Position = shell.Position + UDim2.fromOffset(0, 5)
        end
    end))
    table.insert(window._connections, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then window._openPosition = shell.Position end
            dragging = false
        end
    end))

    bindActivation(close, function() window:Destroy() end)
    bindActivation(minimize, function() window:Minimize() end)

    local launcherDragging = false
    local launcherMoved = false
    local launcherPointer = nil
    local launcherUsesMouse = false
    local launcherDragStart = Vector2.zero
    local launcherStartPosition = launcher.Position
    local function updateLauncherDrag(position)
        local delta = position - launcherDragStart
        if delta.Magnitude < 4 then return end
        launcherMoved = true
        local camera = workspace.CurrentCamera
        local viewportSize = camera and camera.ViewportSize or Vector2.new(1920, 1080)
        local maxX = math.max(8, viewportSize.X - launcher.AbsoluteSize.X - 8)
        local maxY = math.max(8, viewportSize.Y - launcher.AbsoluteSize.Y - 8)
        launcher.Position = UDim2.fromOffset(
            math.clamp(launcherStartPosition.X.Offset + delta.X, 8, maxX),
            math.clamp(launcherStartPosition.Y.Offset + delta.Y, 8, maxY)
        )
    end
    table.insert(window._connections, launcher.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            launcherDragging = true
            launcherMoved = false
            launcherPointer = input
            launcherUsesMouse = input.UserInputType == Enum.UserInputType.MouseButton1
            launcherDragStart = input.Position
            launcherStartPosition = launcher.Position
        end
    end))
    table.insert(window._connections, UserInputService.InputChanged:Connect(function(input)
        if not launcherDragging then return end
        if launcherUsesMouse then
            if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        elseif input ~= launcherPointer then
            return
        end
        updateLauncherDrag(input.Position)
    end))
    table.insert(window._connections, UserInputService.InputEnded:Connect(function(input)
        if not launcherDragging then return end
        local ownsRelease = launcherUsesMouse
            and input.UserInputType == Enum.UserInputType.MouseButton1
            or (not launcherUsesMouse and input == launcherPointer)
        if not ownsRelease then return end
        updateLauncherDrag(input.Position)
        launcherDragging = false
        launcherPointer = nil
    end))
    bindActivation(launcher, function()
        if not launcherMoved then window:Open() end
    end)
    table.insert(window._connections, UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == window._keybind and not UserInputService:GetFocusedTextBox() then
            window:Toggle()
        end
    end))

    launcher.Visible = false
    tween(shell, Motion.enter, { Position = UDim2.new(0.5, 0, 0.5, 0) })
    tween(panelScale, Motion.enter, { Scale = 1 })
    tween(shadow, Motion.enter, { BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0.5, 5) })
    return window
end

function Window:_renderNavState()
    for _, item in ipairs(self._tabs) do
        local selected = item == self._active
        local hovered = item == self._hoveredTab and not selected
        item._button.BackgroundTransparency = (selected or hovered) and 0 or 1
        item._label.TextColor3 = (selected or hovered) and C.ivory or C.secondary
        setNavIconColor(item._iconParts, selected and C.brass or (hovered and C.secondary or C.muted))
    end
end

function Window:CreateTab(name)
    local index = #self._tabs + 1
    local button = make("Frame", {
        Name = name .. "Tab", LayoutOrder = index, BackgroundColor3 = Color3.fromRGB(30, 31, 31),
        BackgroundTransparency = 1, Active = true,
        Size = UDim2.fromOffset(156, 36), ZIndex = 3,
    }, self._nav)
    corner(button, 7)
    local iconParts = navIcon(button, name)
    local text = label(button, name, 12, C.secondary, Enum.Font.GothamMedium)
    text.Position = UDim2.fromOffset(38, 0); text.Size = UDim2.new(1, -48, 1, 0); text.ZIndex = 4

    local page = make("Frame", {
        Name = name .. "Page", BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1), Position = UDim2.fromOffset(10, 0),
        Visible = false,
    }, self._content)
    local scroll = make("ScrollingFrame", {
        Name = "Scroll", BackgroundTransparency = 1, BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 0), Size = UDim2.new(1, -20, 1, -20),
        CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 2, ScrollBarImageColor3 = C.brass,
        ScrollBarImageTransparency = 0.42,
        VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
        ElasticBehavior = Enum.ElasticBehavior.Never,
        ScrollingDirection = Enum.ScrollingDirection.Y,
    }, page)
    padding(scroll, 24, 4, 4, 24)
    make("UIListLayout", { Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder }, scroll)
    table.insert(self._connections, scroll:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(function()
        task.defer(clampScrollPosition, scroll)
    end))
    table.insert(self._connections, scroll:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(function()
        task.defer(clampScrollPosition, scroll)
    end))

    local tab = setmetatable({
        _window = self, _name = name, _button = button, _index = index,
        _label = text, _iconParts = iconParts, _page = page, _scroll = scroll, _order = 0,
    }, Tab)
    table.insert(self._tabs, tab)
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self:_select(tab)
        end
    end)
    button.MouseEnter:Connect(function()
        self._hoveredTab = tab
        self:_renderNavState()
    end)
    button.MouseLeave:Connect(function()
        if self._hoveredTab == tab then self._hoveredTab = nil end
        self:_renderNavState()
    end)
    if not self._active then self:_select(tab, true) end
    return tab
end

function Window:_select(tab, instant)
    if self._active == tab then return end
    self._transitionId = self._transitionId + 1
    self._active = tab
    self._pageTitle.Text = tab._name
    self._context.Text = "NEXUS PANEL  /  " .. string.upper(tab._name)

    for page, activeTween in pairs(self._pageTweens) do
        pcall(function() activeTween:Cancel() end)
        self._pageTweens[page] = nil
    end

    -- Normalize every page before revealing the next one. Roblox applies
    -- visibility before tween completion, so overlapping exit/entry tweens can
    -- render both scrolling pages for one frame during rapid switching.
    for _, item in ipairs(self._tabs) do
        if item ~= tab then
            item._page.Visible = false
            item._page.Position = UDim2.fromOffset(10, 0)
        end
    end
    self:_renderNavState()
    tab._page.Visible = true
    clampScrollPosition(tab._scroll)
    if instant then
        tab._page.Position = UDim2.fromOffset(0, 0)
    else
        tab._page.Position = UDim2.fromOffset(11, 0)
        local incoming = tween(tab._page, Motion.tabIn, { Position = UDim2.fromOffset(0, 0) })
        self._pageTweens[tab._page] = incoming
        incoming.Completed:Connect(function()
            if self._pageTweens[tab._page] == incoming then self._pageTweens[tab._page] = nil end
        end)
    end
end

function Window:Minimize()
    if not self._open or self._transitioning then return end
    self._transitioning, self._open = true, false
    resetHoverLayers(self._shell)
    self._visibilityId = self._visibilityId + 1
    local id, launcher = self._visibilityId, self._gui:FindFirstChild("NexusLauncher")
    tween(self._shell, Motion.exit, { Position = self._openPosition + UDim2.fromOffset(0, 12), GroupTransparency = 1 })
    tween(self._panelScale, Motion.exit, { Scale = 0.975 })
    tween(self._shadow, Motion.exit, { BackgroundTransparency = 1 })
    task.delay(0.22, function()
        if self._visibilityId ~= id then return end
        self._shell.Visible = false
        if launcher then launcher.Visible = true; local visual = launcher:FindFirstChild("LauncherVisual"); if visual then visual.ImageTransparency = 1; tween(visual, Motion.enter, { ImageTransparency = 0 }) end end
        self._transitioning = false
    end)
end

function Window:Open()
    if self._open or self._transitioning then return end
    self._transitioning, self._open = true, true
    self._visibilityId = self._visibilityId + 1
    local id, launcher = self._visibilityId, self._gui:FindFirstChild("NexusLauncher")
    if launcher then resetHoverLayers(launcher); launcher.Visible = false end
    self._shell.Visible = true; self._shell.GroupTransparency = 1
    self._shell.Position = self._openPosition + UDim2.fromOffset(0, 12)
    self._panelScale.Scale = 0.975
    tween(self._shell, Motion.enter, { Position = self._openPosition, GroupTransparency = 0 })
    tween(self._panelScale, Motion.enter, { Scale = 1 })
    tween(self._shadow, Motion.enter, { BackgroundTransparency = 1 })
    task.delay(0.46, function() if self._visibilityId == id then self._transitioning = false end end)
end

function Window:Toggle()
    if self._transitioning then return end
    if self._open then self:Minimize() else self:Open() end
end

function Window:Destroy()
    for _, connection in ipairs(self._connections) do pcall(function() connection:Disconnect() end) end
    if self._gui then self._gui:Destroy() end
end

local function nextOrder(tab)
    tab._order = tab._order + 1
    return tab._order
end

function Tab:CreateHeader(config)
    config = config or {}
    local frame = make("Frame", {
        Name = "Header", LayoutOrder = nextOrder(self), BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 66),
    }, self._scroll)
    local eyebrow = label(frame, "LIVE WORKSPACE", 9, C.brass, Enum.Font.GothamBold)
    eyebrow.Size = UDim2.new(1, 0, 0, 14)
    local title = label(frame, config.Title or "Overview", 22, C.ivory, Enum.Font.GothamBold)
    title.Position = UDim2.fromOffset(0, 17); title.Size = UDim2.new(1, 0, 0, 28)
    local sub = label(frame, config.Subtitle or "", 11, C.secondary)
    sub.Position = UDim2.fromOffset(0, 46); sub.Size = UDim2.new(1, 0, 0, 17)
    return frame
end

function Tab:CreateSection(name)
    local header = make("Frame", {
        Name = name .. "Section", LayoutOrder = nextOrder(self), BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 24),
    }, self._scroll)
    local text = label(header, string.upper(name), 9, C.brass, Enum.Font.GothamBold)
    text.Size = UDim2.new(1, 0, 1, 0)
    local section = setmetatable({ _tab = self, _name = name }, Section)
    return section
end

local function controlRow(section, name, height)
    local tab = section._tab
    local outer = make("Frame", {
        Name = name or "Control", LayoutOrder = nextOrder(tab),
        BackgroundColor3 = C.lineSoft, BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, height or 48),
    }, tab._scroll)
    corner(outer, 13)
    local core = make("Frame", {
        Name = "Core", BackgroundColor3 = C.raised, BorderSizePixel = 0,
        Position = UDim2.fromOffset(1, 1), Size = UDim2.new(1, -2, 1, -2),
    }, outer)
    corner(core, 12)
    return outer, core
end

function Section:CreateToggle(config)
    config = config or {}
    local outer, core = controlRow(self, config.Name or "Toggle", 48)
    local title = label(core, config.Name or "Toggle", 12, C.ivory, Enum.Font.GothamMedium)
    title.Position = UDim2.fromOffset(16, 0); title.Size = UDim2.new(1, -82, 1, 0); title.ZIndex = 3
    local button = make("Frame", {
        Name = "HitArea", BackgroundTransparency = 1, Active = true,
        Size = UDim2.fromScale(1, 1), ZIndex = 10,
    }, core)
    local track = make("Frame", {
        BackgroundColor3 = config.Default and C.success or Color3.fromRGB(55, 57, 57),
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.fromOffset(38, 22), ZIndex = 3,
    }, core)
    corner(track, 11)
    local knob = make("Frame", {
        BackgroundColor3 = C.ivory, BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = config.Default and UDim2.new(1, -11, 0.5, 0) or UDim2.new(0, 11, 0.5, 0),
        Size = UDim2.fromOffset(14, 14), ZIndex = 4,
    }, track)
    corner(knob, 7)
    local state = config.Default == true
    local function set(value, emit)
        state = value == true
        setToggleVisual(track, knob, state)
        if emit and config.Callback then task.spawn(config.Callback, state) end
    end
    bindActivation(button, function() set(not state, true) end)
    bindHover(button, hoverLayer(core, C.hover, 12, 2))
    return { _frame = outer, Set = function(_, v) set(v, true) end, Get = function() return state end }
end

function Section:CreateButton(config)
    config = config or {}
    local outer, core = controlRow(self, config.Name or "Button", 48)
    local button = make("Frame", {
        Name = "HitArea", BackgroundTransparency = 1, Active = true,
        Size = UDim2.fromScale(1, 1), ZIndex = 10,
    }, core)
    local text = label(core, config.Name or "Action", 12, C.ivory, Enum.Font.GothamMedium)
    text.Position = UDim2.fromOffset(16, 0); text.Size = UDim2.new(1, -64, 1, 0); text.ZIndex = 3
    local island = make("Frame", {
        BackgroundColor3 = C.brassSoft, BorderSizePixel = 0,
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.fromOffset(28, 28), ZIndex = 3,
    }, core)
    corner(island, 9)
    local arrow = label(island, ">", 11, C.brass, Enum.Font.GothamBold)
    arrow.ZIndex = 4
    arrow.TextXAlignment = Enum.TextXAlignment.Center
    arrow.TextYAlignment = Enum.TextYAlignment.Center
    bindHover(button, hoverLayer(core, C.hover, 12, 2))
    bindActivation(button, function() if config.Callback then task.spawn(config.Callback) end end)
    return { _frame = outer }
end

function Section:CreateDropdown(config)
    config = config or {}
    local options = config.Options or {}
    local selected = config.Default or options[1] or "Select"
    local outer, core = controlRow(self, config.Name or "Dropdown", 48)
    outer.ClipsDescendants = true
    local title = label(core, config.Name or "Select", 11, C.secondary, Enum.Font.GothamMedium)
    title.Position = UDim2.fromOffset(16, 0); title.Size = UDim2.new(0.52, -16, 0, 48); title.ZIndex = 3
    local value = label(core, tostring(selected), 11, C.ivory, Enum.Font.GothamMedium)
    value.Position = UDim2.new(0.52, 0, 0, 0); value.Size = UDim2.new(0.48, -42, 0, 48); value.ZIndex = 3
    value.TextXAlignment = Enum.TextXAlignment.Right
    local chevron = make("Frame", {
        Name = "Chevron", BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -15, 0, 24),
        Size = UDim2.fromOffset(14, 14), ZIndex = 6,
    }, core)
    local chevronLeft = make("Frame", {
        BorderSizePixel = 0, BackgroundColor3 = C.brass,
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(5, 7),
        Size = UDim2.fromOffset(7, 2), Rotation = 45, ZIndex = 6,
    }, chevron)
    local chevronRight = make("Frame", {
        BorderSizePixel = 0, BackgroundColor3 = C.brass,
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(9, 7),
        Size = UDim2.fromOffset(7, 2), Rotation = -45, ZIndex = 6,
    }, chevron)
    local hit = make("Frame", {
        Name = "HitArea", BackgroundTransparency = 1, Active = true,
        Size = UDim2.new(1, 0, 0, 48), ZIndex = 10,
    }, core)
    local list = make("Frame", {
        BackgroundTransparency = 1, Position = UDim2.fromOffset(8, 50),
        Size = UDim2.new(1, -16, 0, math.max(0, #options * 42 - 4)), ZIndex = 3,
    }, core)
    make("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, list)
    local open = false
    local parentScroll = self._tab._scroll
    local function setOpen(nextOpen)
        open = nextOpen
        if not open then resetHoverLayers(outer) end
        outer.Size = UDim2.new(1, 0, 0, open and (58 + #options * 42) or 48)
        chevron.Rotation = open and 180 or 0
        task.defer(clampScrollPosition, parentScroll)
    end
    for i, option in ipairs(options) do
        local choice = make("Frame", {
            Name = "Choice_" .. i, LayoutOrder = i, BackgroundColor3 = C.shell,
            BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 38), ZIndex = 3,
        }, list)
        corner(choice, 9)
        local choiceHover = hoverLayer(choice, C.hover, 9, 4)
        local choiceLabel = label(choice, tostring(option), 11, C.secondary, Enum.Font.GothamMedium)
        choiceLabel.Name = "ChoiceLabel"; choiceLabel.Position = UDim2.fromOffset(12, 0)
        choiceLabel.Size = UDim2.new(1, -24, 1, 0); choiceLabel.ZIndex = 5
        local choiceHit = make("Frame", {
            Name = "HitArea", BackgroundTransparency = 1, Active = true,
            Size = UDim2.fromScale(1, 1), ZIndex = 10,
        }, choice)
        bindHover(choiceHit, choiceHover,
            function() choiceLabel.TextColor3 = C.ivory end,
            function() choiceLabel.TextColor3 = C.secondary end)
        bindActivation(choiceHit, function()
            selected = option; value.Text = tostring(option); setOpen(false)
            if config.Callback then task.spawn(config.Callback, option) end
        end)
    end
    bindActivation(hit, function() setOpen(not open) end)
    local headerHover = hoverLayer(core, C.hover, 12, 2)
    headerHover.Size = UDim2.new(1, 0, 0, 48)
    bindHover(hit, headerHover)
    return { _frame = outer, Get = function() return selected end, Set = function(_, v) selected = v; value.Text = tostring(v) end }
end

-- Multiple highlighted selections; there is deliberately no toggle/switch control.
function Section:CreateMultiChoice(config)
    config = config or {}
    local options = config.Options or {}
    local selected = {}
    for _, option in ipairs(config.Default or {}) do selected[option] = true end

    local outer, core = controlRow(self, config.Name or "Skills", 48 + math.max(0, #options - 1) * 38)
    local title = label(core, config.Name or "Skills", 11, C.secondary, Enum.Font.GothamBold)
    title.Position = UDim2.fromOffset(16, 8); title.Size = UDim2.new(1, -32, 0, 18); title.ZIndex = 3
    local list = make("Frame", {
        BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 30),
        Size = UDim2.new(1, -24, 1, -36), ZIndex = 3,
    }, core)
    make("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, list)

    local rows = {}
    local function values()
        local result = {}
        for _, option in ipairs(options) do if selected[option] then table.insert(result, option) end end
        return result
    end
    local function paint(option)
        local row = rows[option]
        if not row then return end
        local active = selected[option] == true
        row.core.BackgroundColor3 = active and C.brassSoft or C.shell
        row.text.TextColor3 = active and C.brass or C.secondary
        row.mark.Visible = active
    end
    local function set(option, active, emit)
        selected[option] = active == true
        paint(option)
        if emit and config.Callback then task.spawn(config.Callback, values()) end
    end

    for index, option in ipairs(options) do
        local row = make("Frame", {
            Name = "Skill_" .. tostring(index), LayoutOrder = index, BackgroundColor3 = C.lineSoft,
            BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 34), ZIndex = 3,
        }, list)
        corner(row, 9)
        local rowCore = make("Frame", {
            BackgroundColor3 = C.shell, BorderSizePixel = 0,
            Position = UDim2.fromOffset(1, 1), Size = UDim2.new(1, -2, 1, -2), ZIndex = 4,
        }, row)
        corner(rowCore, 8)
        local rowText = label(rowCore, tostring(option), 11, C.secondary, Enum.Font.GothamMedium)
        rowText.Position = UDim2.fromOffset(12, 0); rowText.Size = UDim2.new(1, -40, 1, 0); rowText.ZIndex = 5
        local mark = label(rowCore, "✓", 13, C.brass, Enum.Font.GothamBold)
        mark.TextXAlignment = Enum.TextXAlignment.Center
        mark.AnchorPoint = Vector2.new(1, 0.5); mark.Position = UDim2.new(1, -10, 0.5, 0); mark.Size = UDim2.fromOffset(18, 18); mark.ZIndex = 5
        local hit = make("Frame", { Name = "HitArea", BackgroundTransparency = 1, Active = true, Size = UDim2.fromScale(1, 1), ZIndex = 10 }, rowCore)
        rows[option] = { core = rowCore, text = rowText, mark = mark }
        paint(option)
        bindHover(hit, hoverLayer(rowCore, C.hover, 8, 6, 0.65))
        bindActivation(hit, function() set(option, not selected[option], true) end)
    end

    return {
        _frame = outer,
        Get = values,
        Set = function(_, option, active) set(option, active, true) end,
    }
end

-- BMAD naming adapter: selections use the same multi-highlight control and emit the selected list.
function Section:CreateBMADSkillSelector(config)
    config = config or {}
    config.Name = config.Name or "BMAD Skills"
    return self:CreateMultiChoice(config)
end

function Section:CreateTextbox(config)
    config = config or {}
    local outer, core = controlRow(self, config.Name or "Textbox", 52)
    core.Active = true
    local title = label(core, config.Name or "Input", 11, C.secondary)
    title.Position = UDim2.fromOffset(16, 0); title.Size = UDim2.new(0.45, -16, 1, 0); title.ZIndex = 3
    local input = make("TextBox", {
        BackgroundColor3 = C.shell, Text = config.Default or "", PlaceholderText = config.Placeholder or "Enter value",
        PlaceholderColor3 = C.muted, TextColor3 = C.ivory, TextSize = 11,
        Font = Enum.Font.GothamMedium, ClearTextOnFocus = false,
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.new(0.52, 0, 0, 34), ZIndex = 3,
    }, core)
    padding(input, 12, 12, 0, 0); corner(input, 9); local inputStroke = stroke(input, C.line, 0.1)
    bindHover(core, hoverLayer(core, C.hover, 12, 2))
    input.Focused:Connect(function() tween(inputStroke, Motion.fast, { Color = C.brass }) end)
    input.FocusLost:Connect(function(enter) tween(inputStroke, Motion.base, { Color = C.line }); if config.Callback then task.spawn(config.Callback, input.Text, enter) end end)
    return { _frame = outer, Get = function() return input.Text end, Set = function(_, v) input.Text = tostring(v) end }
end

function Tab:CreateStatRow(stats)
    local frame = make("Frame", {
        Name = "Stats", LayoutOrder = nextOrder(self), BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 92),
    }, self._scroll)
    make("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, frame)
    local count = math.max(#stats, 1)
    local statValues = {}
    for i, stat in ipairs(stats) do
        local outer = make("Frame", {
            Name = "Stat_" .. i, LayoutOrder = i, BackgroundColor3 = C.lineSoft,
            BorderSizePixel = 0, Size = UDim2.new(1 / count, -(10 * (count - 1) / count), 1, 0),
        }, frame)
        corner(outer, 14)
        local core = make("Frame", {
            BackgroundColor3 = C.raised, BorderSizePixel = 0,
            Position = UDim2.fromOffset(1, 1), Size = UDim2.new(1, -2, 1, -2),
        }, outer)
        corner(core, 13)
        local accent = make("Frame", { BorderSizePixel = 0, BackgroundColor3 = stat.Color or C.brass, Position = UDim2.fromOffset(14, 15), Size = UDim2.fromOffset(18, 2) }, core)
        corner(accent, 1)
        local value = label(core, tostring(stat.Value or "—"), 18, C.ivory, Enum.Font.GothamBold)
        value.Position = UDim2.fromOffset(14, 25); value.Size = UDim2.new(1, -28, 0, 28)
        local title = label(core, string.upper(stat.Title or "STAT"), 9, C.muted, Enum.Font.GothamBold)
        title.Position = UDim2.fromOffset(14, 57); title.Size = UDim2.new(1, -28, 0, 18)
        statValues[stat.Key or stat.Title or tostring(i)] = value
    end
    return {
        _frame = frame,
        Values = statValues,
        Set = function(_, key, nextValue)
            local target = statValues[key]
            if target then target.Text = tostring(nextValue) end
        end,
    }
end

local function normalizeInfoValue(value)
    if value == nil or value == "" then return "N/A" end
    return tostring(value)
end

function NexusLib:_refreshInfoPanels()
    for index = #self._infoPanels, 1, -1 do
        local panel = self._infoPanels[index]
        if not panel._frame or not panel._frame.Parent then table.remove(self._infoPanels, index) else panel:_render() end
    end
end

function NexusLib:setInfo(key, value)
    self.Info[tostring(key)] = normalizeInfoValue(value)
    self:_refreshInfoPanels()
end

function NexusLib:updateInfoPanel(values)
    for key, value in pairs(values or {}) do self.Info[tostring(key)] = normalizeInfoValue(value) end
    self:_refreshInfoPanels()
end

local function getPerformanceInfo()
    local fps, ping = "N/A", "N/A"
    pcall(function() fps = tostring(math.floor(workspace:GetRealPhysicsFPS() + 0.5)) end)
    pcall(function() ping = tostring(math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() + 0.5)) .. " ms" end)
    return fps, ping
end

function NexusLib:_startInfoUpdater()
    if self._infoUpdater then return end
    local elapsed = 0
    self._infoUpdater = self:trackConnection(RunService.Heartbeat:Connect(function(deltaTime)
        elapsed = elapsed + deltaTime
        if elapsed < 1 then return end
        elapsed = 0
        self.Info.Runtime = self:FormatPlaytime(os.clock() - scriptStartedAt)
        self.Info.Player = player.Name
        self.Info.Game = game.Name ~= "" and game.Name or "N/A"
        self.Info.FPS, self.Info.Ping = getPerformanceInfo()
        self:_refreshInfoPanels()
    end))
end

function Tab:CreateInformationPanel(config)
    config = config or {}
    local keys = config.Fields or { "Script Name", "Version", "Status", "Current Module", "Current Target", "Last Action", "Warning", "Player", "Game", "Runtime", "FPS", "Ping" }
    local expandedHeight = 42 + #keys * 22
    local outer, core = controlRow(setmetatable({ _tab = self }, Section), "InformationPanel", expandedHeight)
    outer.Name = "InformationPanel"
    outer.ClipsDescendants = true
    local title = label(core, config.Title or "SCRIPT INFORMATION", 10, C.brass, Enum.Font.GothamBold)
    title.Position = UDim2.fromOffset(14, 8); title.Size = UDim2.new(1, -56, 0, 18); title.ZIndex = 3
    local collapse = make("Frame", { Name = "Collapse", BackgroundColor3 = C.shell, BorderSizePixel = 0, Active = true, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 8), Size = UDim2.fromOffset(24, 24), ZIndex = 5 }, core)
    corner(collapse, 7)
    local collapseText = label(collapse, "−", 14, C.brass, Enum.Font.GothamBold); collapseText.TextXAlignment = Enum.TextXAlignment.Center; collapseText.ZIndex = 6
    local rows = make("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 32), Size = UDim2.new(1, -28, 1, -38), ZIndex = 3 }, core)
    make("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }, rows)
    local values = {}
    for order, key in ipairs(keys) do
        local row = make("Frame", { LayoutOrder = order, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20) }, rows)
        local keyLabel = label(row, string.upper(key), 9, C.muted, Enum.Font.GothamBold); keyLabel.Size = UDim2.new(0.42, 0, 1, 0)
        local valueLabel = label(row, "N/A", 10, C.secondary, Enum.Font.GothamMedium); valueLabel.Position = UDim2.new(0.42, 0, 0, 0); valueLabel.Size = UDim2.new(0.58, 0, 1, 0); valueLabel.TextXAlignment = Enum.TextXAlignment.Right; valueLabel.TextTruncate = Enum.TextTruncate.AtEnd
        values[key] = valueLabel
    end
    local panel = { _frame = outer, _core = core, _rows = values, _expanded = true, _expandedHeight = expandedHeight }
    function panel:_render()
        for key, valueLabel in pairs(self._rows) do valueLabel.Text = tostring(NexusLib.Info[key] or "N/A") end
    end
    function panel:Set(key, value) NexusLib:setInfo(key, value) end
    function panel:Get(key) return NexusLib.Info[key] end
    function panel:Toggle()
        self._expanded = not self._expanded
        collapseText.Text = self._expanded and "−" or "+"
        tween(outer, Motion.base, { Size = UDim2.new(1, 0, 0, self._expanded and self._expandedHeight or 42) })
    end
    panel:_render(); table.insert(NexusLib._infoPanels, panel); NexusLib:_startInfoUpdater()
    bindActivation(collapse, function() panel:Toggle() end)
    bindHover(collapse, hoverLayer(collapse, C.hover, 7, 6, 0.35))
    return panel
end

function Tab:CreateFeaturedCard(config)
    config = config or {}
    local outer = make("Frame", {
        Name = "Featured", LayoutOrder = nextOrder(self), BackgroundColor3 = C.brassSoft,
        BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 126),
    }, self._scroll)
    corner(outer, 16)
    local core = make("Frame", {
        BackgroundColor3 = C.raised, BorderSizePixel = 0,
        Position = UDim2.fromOffset(1, 1), Size = UDim2.new(1, -2, 1, -2),
    }, outer)
    corner(core, 15)
    local tag = label(core, config.Tag or "DETAIL", 9, C.brass, Enum.Font.GothamBold)
    tag.Position = UDim2.fromOffset(16, 13); tag.Size = UDim2.new(1, -130, 0, 14)
    local title = label(core, config.Title or "Nexus", 16, C.ivory, Enum.Font.GothamBold)
    title.Position = UDim2.fromOffset(16, 30); title.Size = UDim2.new(1, -150, 0, 24)
    local desc = label(core, config.Description or "", 10, C.secondary)
    desc.Position = UDim2.fromOffset(16, 57); desc.Size = UDim2.new(1, -168, 0, 55)
    desc.TextWrapped = true; desc.TextYAlignment = Enum.TextYAlignment.Top
    local action = make("Frame", {
        Name = "Action", BackgroundColor3 = C.brass, BorderSizePixel = 0,
        Active = true, AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -16, 0.5, 0), Size = UDim2.fromOffset(112, 38),
        ZIndex = 4,
    }, core)
    corner(action, 11)
    local actionHover = hoverLayer(action, C.ivory, 11, 5)
    local actionText = label(action, config.ButtonText or "OPEN", 10, C.canvas, Enum.Font.GothamBold)
    actionText.TextXAlignment = Enum.TextXAlignment.Center
    actionText.ZIndex = 6
    local actionHit = make("Frame", {
        Name = "HitArea", BackgroundTransparency = 1, Active = true,
        Size = UDim2.fromScale(1, 1), ZIndex = 10,
    }, action)
    bindHover(actionHit, actionHover)
    bindActivation(actionHit, function() if config.Callback then task.spawn(config.Callback) end end)
    return { _frame = outer }
end

function Tab:CreateActionRow(actions)
    local section = setmetatable({ _tab = self, _name = "Actions" }, Section)
    local results = {}
    for _, action in ipairs(actions or {}) do table.insert(results, section:CreateButton(action)) end
    return results
end

function Tab:CreateCardGroup(cards)
    local section = setmetatable({ _tab = self, _name = "Cards" }, Section)
    local results = {}
    for _, card in ipairs(cards or {}) do table.insert(results, section:CreateButton({ Name = card.Title or card.Name, Callback = card.Callback })) end
    return results
end

function Section:CreateLabel(text)
    local tab = self._tab
    local frame = make("Frame", { LayoutOrder = nextOrder(tab), BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30) }, tab._scroll)
    local content = label(frame, text or "", 11, C.secondary)
    content.TextWrapped = true
    return { _frame = frame, Set = function(_, v) content.Text = tostring(v) end }
end

function Section:CreateSlider(config)
    config = config or {}
    local min, max = config.Min or 0, config.Max or 100
    if max < min then min, max = max, min end
    local range = max - min
    local current = math.clamp(config.Default or min, min, max)
    local outer, core = controlRow(self, config.Name or "Slider", 58)
    local title = label(core, config.Name or "Slider", 11, C.ivory)
    title.Position = UDim2.fromOffset(16, 4); title.Size = UDim2.new(0.55, 0, 0, 22); title.ZIndex = 3
    local value = label(core, tostring(current), 10, C.brass, Enum.Font.GothamBold)
    value.Position = UDim2.new(0.55, 0, 0, 4); value.Size = UDim2.new(0.45, -16, 0, 22); value.TextXAlignment = Enum.TextXAlignment.Right; value.ZIndex = 3
    local track = make("Frame", { BackgroundColor3 = C.shell, BorderSizePixel = 0, ClipsDescendants = true, Position = UDim2.fromOffset(16, 35), Size = UDim2.new(1, -32, 0, 6), ZIndex = 3 }, core)
    corner(track, 3)
    local initialAlpha = range > 0 and math.clamp((current - min) / range, 0, 1) or 0
    local fill = make("Frame", { BackgroundColor3 = C.brass, BorderSizePixel = 0, Size = UDim2.new(initialAlpha, 0, 1, 0), ZIndex = 4 }, track)
    corner(fill, 3)
    local hit = make("Frame", {
        Name = "HitArea", BackgroundTransparency = 1, Active = true,
        Position = UDim2.fromOffset(16, 23), Size = UDim2.new(1, -32, 0, 28), ZIndex = 10,
    }, core)
    local function setFromX(x, emit)
        local alpha = range > 0
            and math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            or 0
        local raw = min + range * alpha
        local step = tonumber(config.Step or config.Increment)
        if step and step > 0 and range > 0 then
            raw = min + math.round((raw - min) / step) * step
        end
        current = range > 0 and math.clamp(raw, min, max) or min
        value.Text = tostring(current); fill.Size = UDim2.new(alpha, 0, 1, 0)
        if emit and config.Callback then task.spawn(config.Callback, current) end
    end
    local sliding = false
    bindHover(hit, hoverLayer(core, C.hover, 12, 2))
    hit.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = true; setFromX(input.Position.X, true) end end)
    table.insert(self._tab._window._connections, UserInputService.InputChanged:Connect(function(input) if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then setFromX(input.Position.X, true) end end))
    table.insert(self._tab._window._connections, UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = false end end))
    return { _frame = outer, Get = function() return current end }
end

-- Lower-case component aliases accept the requested mobile-friendly options API.
local function normalizeOptions(options)
    options = options or {}
    options.Name = options.Name or options.name
    options.Default = options.Default ~= nil and options.Default or options.default
    options.Callback = options.Callback or options.callback
    options.Options = options.Options or options.options
    return options
end
function Section:createButton(options) return self:CreateButton(normalizeOptions(options)) end
function Section:createToggle(options) return self:CreateToggle(normalizeOptions(options)) end
function Section:createTextBox(options) return self:CreateTextbox(normalizeOptions(options)) end
function Section:createDropdown(options) return self:CreateDropdown(normalizeOptions(options)) end
function Tab:createSection(title) return self:CreateSection(title) end
function Section:createLabel(text) return self:CreateLabel(text) end

function NexusLib:DestroyAll()
    for _, window in ipairs(self._windows) do pcall(function() window:Destroy() end) end
    table.clear(self._windows)
    self:stopAllUILoops()
    self:cleanupConnections()
    self:clearNotifications()
    table.clear(self._infoPanels)
    self._infoUpdater = nil
    for _, child in ipairs(guiParent:GetChildren()) do
        if child.Name == "NexusPanel" or child:GetAttribute("NexusPanel") == true then child:Destroy() end
    end
end



-- v1.8 session data bindings. Values are read-only observations from the local player.
local function getNumericValue(parent, candidates)
    if not parent then return nil end
    for _, name in ipairs(candidates) do
        local item = parent:FindFirstChild(name)
        if item and (item:IsA("IntValue") or item:IsA("NumberValue")) then return item.Value end
    end
    return nil
end

function NexusLib:GetSessionData()
    local leaderstats = player:FindFirstChild("leaderstats")
    local money = getNumericValue(leaderstats, { "Money", "Cash", "Coins", "Gold" })
        or player:GetAttribute("Money") or player:GetAttribute("Cash") or player:GetAttribute("Coins")
    local level = getNumericValue(leaderstats, { "Level", "Lvl", "Rank" })
        or player:GetAttribute("Level") or player:GetAttribute("Lvl") or player:GetAttribute("Rank")
    return { Money = money or 0, Level = level or 0, PlaytimeSeconds = math.max(0, math.floor(os.clock() - scriptStartedAt)) }
end

function NexusLib:FormatPlaytime(seconds)
    seconds = math.max(0, math.floor(tonumber(seconds) or 0))
    return string.format("%02d:%02d:%02d", math.floor(seconds / 3600), math.floor(seconds / 60) % 60, seconds % 60)
end

function NexusLib:BindSessionStats(statRow, config)
    config = config or {}
    local keys = { Money = config.MoneyKey or "Money", Level = config.LevelKey or "Level", Playtime = config.PlaytimeKey or "Playtime" }
    local elapsed = 1
    local connection = RunService.Heartbeat:Connect(function(deltaTime)
        elapsed = elapsed + deltaTime
        if elapsed < 1 then return end
        elapsed = 0
        local data = self:GetSessionData()
        statRow:Set(keys.Money, data.Money)
        statRow:Set(keys.Level, data.Level)
        statRow:Set(keys.Playtime, self:FormatPlaytime(data.PlaytimeSeconds))
    end)
    table.insert(self._connections, connection)
    return { Disconnect = function() connection:Disconnect() end }
end

NexusLib.Version = NEXUS_VERSION
NexusLib.UpdateLog = NEXUS_UPDATE_LOG

env.NexusLib = NexusLib
return NexusLib
