-- =====================================================
-- NEXUS GAMING HUB UI LIBRARY (NexusLib v1.1 Mobile Ready)
-- =====================================================

local NexusLib = {}
--[[
    ╔════════════════════════════════════════════════╗
    ║         NexusLib UI Library v1.1               ║
    ║     Premium Gojo Hollow Purple Theme           ║
    ║        (Full Mobile Responsive Ready)          ║
    ║     by Nexus Gaming Hub                        ║
    ╚════════════════════════════════════════════════╝
]]

-- ═══════════════════════════════════════════════════
-- SERVICES & DEVICE DETECTION
-- ═══════════════════════════════════════════════════
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer
local guiParent = RunService:IsStudio()
    and localPlayer:WaitForChild("PlayerGui")
    or (typeof(gethui) == "function" and gethui() or game:GetService("CoreGui"))

local isTouch = UserInputService.TouchEnabled
local isKeyboard = UserInputService.KeyboardEnabled
local isMobile = isTouch and not isKeyboard

-- ═══════════════════════════════════════════════════
-- THEME
-- ═══════════════════════════════════════════════════
local Theme = {
    Background      = Color3.fromRGB(15, 15, 35),
    BgGrad1         = Color3.fromRGB(25, 20, 50),
    BgGrad2         = Color3.fromRGB(10, 10, 30),
    SidebarBg       = Color3.fromRGB(12, 12, 28),
    CardBg          = Color3.fromRGB(20, 18, 45),
    PanelTransparency = 0.15,
    CardTransparency  = 0.2,

    Accent          = Color3.fromRGB(150, 80, 255),
    AccentBlue      = Color3.fromRGB(0, 160, 255),
    AccentPink      = Color3.fromRGB(255, 40, 100),
    AccentGlow      = Color3.fromRGB(160, 120, 255),

    Text            = Color3.new(1, 1, 1),
    TextSub         = Color3.fromRGB(140, 130, 170),
    TextMuted       = Color3.fromRGB(120, 100, 180),

    StrokeMain      = Color3.fromRGB(100, 80, 200),
    StrokeCard      = Color3.fromRGB(60, 50, 100),
    Divider         = Color3.fromRGB(80, 60, 160),

    ToggleOff       = Color3.fromRGB(30, 25, 55),
    ToggleOn        = Color3.fromRGB(150, 80, 255),
    ToggleStroke    = Color3.fromRGB(100, 80, 150),

    SliderTrack     = Color3.fromRGB(40, 30, 70),
    SliderStroke    = Color3.fromRGB(180, 80, 255),

    ActiveTab       = Color3.fromRGB(100, 60, 220),
    InactiveTab     = Color3.fromRGB(20, 18, 40),

    CloseHover      = Color3.fromRGB(120, 40, 40),
    MinHover        = Color3.fromRGB(80, 80, 110),

    DropBg          = Color3.fromRGB(35, 30, 65),
    DropOpt         = Color3.fromRGB(30, 25, 50),
    DropStroke      = Color3.fromRGB(150, 100, 255),

    NotifBg         = Color3.fromRGB(15, 12, 28),

    Bold            = Enum.Font.GothamBold,
    Medium          = Enum.Font.GothamMedium,

    HollowPurple = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 160, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 40, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 40, 100))
    }),
    HollowStroke = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 220, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(220, 80, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 80, 140))
    }),
    LaserGrad = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 240, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(180, 50, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 30, 120))
    }),
    FillGrad = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 180, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 50, 255))
    }),
    RingGrad = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 180, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(180, 50, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 50, 150))
    }),
}

-- ═══════════════════════════════════════════════════
-- TWEEN PRESETS
-- ═══════════════════════════════════════════════════
local TI = {
    HIn     = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    HOut    = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Click   = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Spring  = TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    Smooth  = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    Antic   = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Close   = TweenInfo.new(0.38, Enum.EasingStyle.Back, Enum.EasingDirection.In),
    TabOut  = TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.In),
    TabIn   = TweenInfo.new(0.38, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    IPanel  = TweenInfo.new(0.65, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    ISide   = TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    ICont   = TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    IBtn    = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    INav    = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    Shimmer = TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
}

-- ═══════════════════════════════════════════════════
-- UTILITY
-- ═══════════════════════════════════════════════════
local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = typeof(r) == "UDim" and r or UDim.new(0, r or 10)
    c.Parent = p
    return c
end

local function uistroke(p, col, thick, trans)
    local s = Instance.new("UIStroke")
    s.Color = col or Theme.StrokeCard
    s.Thickness = thick or 1
    s.Transparency = trans or 0
    s.Parent = p
    return s
end

local function grad(p, colors, rot)
    local g = Instance.new("UIGradient")
    g.Color = colors or Theme.HollowPurple
    g.Rotation = rot or 45
    g.Parent = p
    return g
end

local function scaleUDim2(s, factor)
    return UDim2.new(s.X.Scale * factor, s.X.Offset * factor, s.Y.Scale * factor, s.Y.Offset * factor)
end

local function createGeometricN(parent)
    local ct = Instance.new("Frame")
    ct.Name = "GeometricN"
    ct.Size = UDim2.new(1, 0, 1, 0)
    ct.BackgroundTransparency = 1
    ct.Parent = parent

    local function bar(name, sy, px, rot)
        local b = Instance.new("Frame")
        b.Name = name
        b.Size = UDim2.new(0, 5, 0, sy)
        b.Position = UDim2.new(0.5, px, 0.5, 0)
        b.AnchorPoint = Vector2.new(0.5, 0.5)
        b.BackgroundColor3 = Color3.new(1, 1, 1)
        b.BorderSizePixel = 0
        b.Rotation = rot or 0
        b.Parent = ct
        corner(b, UDim.new(1, 0))
        uistroke(b, Color3.fromRGB(160, 80, 255), 1.5, 0.25)
    end

    bar("L", 22, -8, 0)
    bar("R", 22, 8, 0)
    bar("D", 25, 0, -35)
    return ct
end

local function applyBouncy(btn, hs, cs, ds)
    hs = hs or 1.05; cs = cs or 0.9; ds = ds or btn.Size
    btn.MouseEnter:Connect(function() TweenService:Create(btn, TI.HIn, {Size = scaleUDim2(ds, hs)}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn, TI.HOut, {Size = ds}):Play() end)
    btn.MouseButton1Down:Connect(function() TweenService:Create(btn, TI.Click, {Size = scaleUDim2(ds, cs)}):Play() end)
    btn.MouseButton1Up:Connect(function() TweenService:Create(btn, TI.Spring, {Size = scaleUDim2(ds, hs)}):Play() end)
end

local function createLogoIcon(parent, size, pos, anchor)
    local li = Instance.new("Frame")
    li.Name = "LogoIcon"
    li.Size = size or UDim2.new(0, 45, 0, 45)
    li.Position = pos or UDim2.new(0, 20, 0.5, 0)
    li.AnchorPoint = anchor or Vector2.new(0, 0.5)
    li.BackgroundColor3 = Color3.new(1, 1, 1)
    li.BorderSizePixel = 0
    li.Parent = parent
    corner(li, 12)
    grad(li, Theme.HollowPurple, 45)

    local s = uistroke(li, nil, 1.5)
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    grad(s, Theme.HollowStroke, 45)

    local ring = Instance.new("Frame")
    ring.Name = "Ring"
    ring.Size = UDim2.new(0.85, 0, 0.85, 0)
    ring.Position = UDim2.new(0.5, 0, 0.5, 0)
    ring.AnchorPoint = Vector2.new(0.5, 0.5)
    ring.BackgroundTransparency = 1
    ring.Parent = li
    corner(ring, UDim.new(1, 0))
    local rs = uistroke(ring, Color3.new(1, 1, 1), 1.2)
    grad(rs, Theme.RingGrad, 90)

    createGeometricN(li)
    return li, ring
end

-- ═══════════════════════════════════════════════════
-- FORWARD DECLARATIONS
-- ═══════════════════════════════════════════════════
local Window = {}; Window.__index = Window
local Tab = {}; Tab.__index = Tab
local Section = {}; Section.__index = Section

-- ═══════════════════════════════════════════════════
-- NOTIFICATION SYSTEM
-- ═══════════════════════════════════════════════════
function NexusLib:Notify(config)
    config = config or {}
    local title = config.Title or "Notification"
    local message = config.Message or ""
    local duration = config.Duration or 5

    if not self._notifContainer or not self._notifContainer.Parent then return end

    local notif = Instance.new("Frame")
    notif.Name = "Notification"
    notif.Size = UDim2.new(1, 0, 0, 0)
    notif.BackgroundTransparency = 1
    notif.BorderSizePixel = 0
    notif.ClipsDescendants = true
    local targetSize = UDim2.new(1, 0, 0, 72)

    local inner = Instance.new("Frame")
    inner.Name = "VisualFrame"
    inner.Size = UDim2.new(1, 0, 1, 0)
    inner.Position = UDim2.new(1.3, 0, 0, 0)
    inner.BackgroundColor3 = Theme.NotifBg
    inner.BackgroundTransparency = 0.15
    inner.BorderSizePixel = 0
    inner.Parent = notif
    corner(inner, 12)

    local stroke = uistroke(inner, nil, 2)
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    grad(stroke, Theme.LaserGrad, 45)

    -- Title
    local tLabel = Instance.new("TextLabel")
    tLabel.Size = UDim2.new(1, -60, 0, 20)
    tLabel.Position = UDim2.new(0, 15, 0, 12)
    tLabel.BackgroundTransparency = 1
    tLabel.Text = title
    tLabel.TextColor3 = Theme.Text
    tLabel.TextSize = 13
    tLabel.Font = Theme.Bold
    tLabel.TextXAlignment = Enum.TextXAlignment.Left
    tLabel.Parent = inner

    -- Message
    local mLabel = Instance.new("TextLabel")
    mLabel.Size = UDim2.new(1, -60, 0, 30)
    mLabel.Position = UDim2.new(0, 15, 0, 30)
    mLabel.BackgroundTransparency = 1
    mLabel.Text = message
    mLabel.TextColor3 = Color3.fromRGB(180, 170, 210)
    mLabel.TextSize = 11
    mLabel.Font = Theme.Medium
    mLabel.TextWrapped = true
    mLabel.TextXAlignment = Enum.TextXAlignment.Left
    mLabel.TextYAlignment = Enum.TextYAlignment.Top
    mLabel.Parent = inner

    -- Close Btn
    local xBtn = Instance.new("TextButton")
    xBtn.Name = "CloseButton"
    xBtn.Size = UDim2.new(0, 24, 0, 24)
    xBtn.Position = UDim2.new(1, -28, 0.5, -12)
    xBtn.BackgroundTransparency = 1
    xBtn.Text = "✕"
    xBtn.TextColor3 = Theme.TextSub
    xBtn.TextSize = 14
    xBtn.Font = Theme.Bold
    xBtn.AutoButtonColor = false
    xBtn.Parent = inner

    -- Progress track
    local progressTrack = Instance.new("Frame")
    progressTrack.Size = UDim2.new(1, -24, 0, 2)
    progressTrack.Position = UDim2.new(0, 12, 1, -5)
    progressTrack.BackgroundColor3 = Color3.fromRGB(30, 25, 50)
    progressTrack.BorderSizePixel = 0
    progressTrack.Parent = inner
    corner(progressTrack)

    local progressBar = Instance.new("Frame")
    progressBar.Size = UDim2.new(1, 0, 1, 0)
    progressBar.BackgroundColor3 = Color3.new(1, 1, 1)
    progressBar.BorderSizePixel = 0
    progressBar.Parent = progressTrack
    corner(progressBar)
    grad(progressBar, Theme.LaserGrad, 0)

    notif.Parent = self._notifContainer

    TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = targetSize}):Play()
    task.wait(0.1)
    TweenService:Create(inner, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()

    local progressTween = TweenService:Create(progressBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 1, 0)})
    progressTween:Play()

    local isClosing = false
    local function closeNotif()
        if isClosing then return end
        isClosing = true
        local slideOut = TweenService:Create(inner, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(1.3, 0, 0, 0)})
        slideOut:Play()
        slideOut.Completed:Connect(function()
            local collapse = TweenService:Create(notif, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(1, 0, 0, 0)})
            collapse:Play()
            collapse.Completed:Connect(function() notif:Destroy() end)
        end)
    end
    xBtn.MouseButton1Click:Connect(closeNotif)
    task.delay(duration, function() if notif and notif.Parent then closeNotif() end end)
end

-- ═══════════════════════════════════════════════════
-- WINDOW : CreateWindow
-- ═══════════════════════════════════════════════════
function NexusLib:CreateWindow(config)
    config = config or {}
    local title = config.Title or "NEXUS"
    local subtitle = config.Subtitle or "GAMING HUB"
    local keybind = config.Keybind or Enum.KeyCode.RightShift

    if self._screenGui and self._screenGui.Parent then self._screenGui:Destroy() end
    if self._connections then
        for _, c in ipairs(self._connections) do pcall(function() c:Disconnect() end) end
    end
    self._connections = {}

    local w = setmetatable({}, Window)
    w._tabs = {}
    w._activeTab = nil
    w._menuOpen = true
    w._tweening = false
    w._conns = {}

    -- ScreenGui
    local sg = Instance.new("ScreenGui")
    sg.Name = "NexusLib"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.IgnoreGuiInset = true
    sg.Parent = guiParent
    w._sg = sg
    self._screenGui = sg

    -- Mobile Toggle Button (Draggable Hollow Purple Orb)
    local mobSize = isMobile and 54 or 46
    local mob = Instance.new("TextButton")
    mob.Name = "MobileBtn"
    mob.Size = UDim2.new(0, mobSize, 0, mobSize)
    mob.Position = UDim2.new(0, 20, 0.5, -mobSize/2)
    mob.BackgroundColor3 = Color3.new(1,1,1)
    mob.BackgroundTransparency = 0.15
    mob.BorderSizePixel = 0
    mob.Text = ""
    mob.AutoButtonColor = false
    mob.Parent = sg
    corner(mob, UDim.new(1, 0))
    grad(mob, Theme.HollowPurple, 45)

    local mobS = uistroke(mob, nil, 2)
    mobS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    grad(mobS, Theme.HollowStroke, 45)

    local mobRing = Instance.new("Frame")
    mobRing.Name = "Ring"
    mobRing.Size = UDim2.new(0.85, 0, 0.85, 0)
    mobRing.Position = UDim2.new(0.5, 0, 0.5, 0)
    mobRing.AnchorPoint = Vector2.new(0.5, 0.5)
    mobRing.BackgroundTransparency = 1
    mobRing.Parent = mob
    corner(mobRing, UDim.new(1, 0))
    local mrs = uistroke(mobRing, Color3.new(1,1,1), 1.2)
    grad(mrs, Theme.RingGrad, 90)
    createGeometricN(mob)
    w._mob = mob

    -- Make Mobile Orb Draggable on Touch/Mouse
    local mobDragging, mobDragStart, mobStartPos = false, nil, nil
    mob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            mobDragging = true
            mobDragStart = input.Position
            mobStartPos = mob.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then mobDragging = false end
            end)
        end
    end)
    table.insert(w._conns, UserInputService.InputChanged:Connect(function(input)
        if mobDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - mobDragStart
            mob.Position = UDim2.new(mobStartPos.X.Scale, mobStartPos.X.Offset + delta.X, mobStartPos.Y.Scale, mobStartPos.Y.Offset + delta.Y)
        end
    end))

    -- Main Panel (Mobile Responsive Layout)
    local mp = Instance.new("Frame")
    mp.Name = "MainPanel"
    
    local sidebarWidth = isMobile and 150 or 200
    if isMobile then
        mp.Size = UDim2.new(0.92, 0, 0.88, 0) -- Scaled for mobile screens
    else
        mp.Size = UDim2.new(0, 750, 0, 480)
    end
    
    mp.Position = UDim2.new(0.5, 0, 0.5, 0)
    mp.AnchorPoint = Vector2.new(0.5, 0.5)
    mp.BackgroundColor3 = Theme.Background
    mp.BackgroundTransparency = Theme.PanelTransparency
    mp.BorderSizePixel = 0
    mp.Parent = sg
    corner(mp, isMobile and 14 or 20)

    local mpStroke = uistroke(mp, Theme.StrokeMain, 1.5, 0.5)
    local mpGrad = Instance.new("UIGradient", mp)
    mpGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.BgGrad1),
        ColorSequenceKeypoint.new(1, Theme.BgGrad2)
    })
    mpGrad.Rotation = 160

    -- Dynamic Viewport Auto Scaling
    local mpScale = Instance.new("UIScale", mp)
    mpScale.Scale = 1
    w._scale = mpScale
    w._mp = mp

    local function updateScale()
        local camera = Workspace.CurrentCamera
        if camera and isMobile then
            local vSize = camera.ViewportSize
            if vSize.Y < 420 then
                mpScale.Scale = math.clamp(vSize.Y / 420, 0.72, 1)
            else
                mpScale.Scale = 1
            end
        end
    end
    updateScale()
    table.insert(w._conns, Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale))

    -- Sidebar
    local sb = Instance.new("Frame")
    sb.Name = "Sidebar"
    sb.Size = UDim2.new(0, sidebarWidth, 1, 0)
    sb.BackgroundColor3 = Theme.SidebarBg
    sb.BackgroundTransparency = 0.3
    sb.BorderSizePixel = 0
    sb.Parent = mp
    corner(sb, isMobile and 14 or 20)
    w._sb = sb

    -- Divider
    local dv = Instance.new("Frame")
    dv.Size = UDim2.new(0, 1, 0.85, 0)
    dv.Position = UDim2.new(1, 0, 0.075, 0)
    dv.BackgroundColor3 = Theme.Divider
    dv.BackgroundTransparency = 0.6
    dv.BorderSizePixel = 0
    dv.Parent = sb

    -- Logo Frame
    local lf = Instance.new("Frame")
    lf.Name = "LogoFrame"
    lf.Size = UDim2.new(1, 0, 0, isMobile and 60 or 80)
    lf.BackgroundTransparency = 1
    lf.Parent = sb

    local logoIcon, logoRing = createLogoIcon(lf, UDim2.new(0, isMobile and 36 or 45, 0, isMobile and 36 or 45), UDim2.new(0, isMobile and 12 or 20, 0.5, 0))

    local lt = Instance.new("TextLabel")
    lt.Size = UDim2.new(1, -(isMobile and 55 or 75), 0, 20)
    lt.Position = UDim2.new(0, isMobile and 55 or 75, 0.5, isMobile and -10 or -12)
    lt.BackgroundTransparency = 1
    lt.Text = title:upper()
    lt.TextColor3 = Theme.Text
    lt.TextSize = isMobile and 14 or 18
    lt.Font = Theme.Bold
    lt.TextXAlignment = Enum.TextXAlignment.Left
    lt.Parent = lf

    local lsub = Instance.new("TextLabel")
    lsub.Size = UDim2.new(1, -(isMobile and 55 or 75), 0, 15)
    lsub.Position = UDim2.new(0, isMobile and 55 or 75, 0.5, isMobile and 8 or 8)
    lsub.BackgroundTransparency = 1
    lsub.Text = subtitle:upper()
    lsub.TextColor3 = Theme.TextMuted
    lsub.TextSize = isMobile and 9 or 10
    lsub.Font = Theme.Medium
    lsub.TextXAlignment = Enum.TextXAlignment.Left
    lsub.Parent = lf

    -- Nav Container
    local nc = Instance.new("Frame")
    nc.Name = "NavContainer"
    nc.Size = UDim2.new(1, -16, 1, -(isMobile and 75 or 110))
    nc.Position = UDim2.new(0, 8, 0, isMobile and 65 or 95)
    nc.BackgroundTransparency = 1
    nc.Parent = sb
    local ncl = Instance.new("UIListLayout", nc)
    ncl.Padding = UDim.new(0, 5)
    ncl.SortOrder = Enum.SortOrder.LayoutOrder
    w._nc = nc

    -- Active Tab Indicator
    local ind = Instance.new("Frame")
    ind.Name = "Indicator"
    ind.Size = UDim2.new(0, 3, 0, isMobile and 20 or 24)
    ind.Position = UDim2.new(0, 8, 0, isMobile and 72 or 104)
    ind.BackgroundColor3 = Theme.AccentGlow
    ind.BorderSizePixel = 0
    ind.ZIndex = 5
    ind.Parent = sb
    corner(ind, 2)
    w._ind = ind

    -- Content Area
    local ca = Instance.new("Frame")
    ca.Name = "ContentArea"
    ca.Size = UDim2.new(1, -(sidebarWidth + (isMobile and 15 or 25)), 1, -20)
    ca.Position = UDim2.new(0, sidebarWidth + (isMobile and 8 or 10), 0, 10)
    ca.BackgroundTransparency = 1
    ca.ZIndex = 1
    ca.Parent = mp
    w._ca = ca

    -- Touch-friendly Control Buttons Size (38px on Mobile, 32px on PC)
    local ctrlBtnSize = isMobile and 38 or 32
    
    -- Close Button
    local cb = Instance.new("TextButton")
    cb.Name = "CloseBtn"
    cb.Size = UDim2.new(0, ctrlBtnSize, 0, ctrlBtnSize)
    cb.Position = UDim2.new(1, -(ctrlBtnSize + 10), 0, 8)
    cb.BackgroundColor3 = Color3.fromRGB(60, 40, 100)
    cb.BackgroundTransparency = 0.5
    cb.BorderSizePixel = 0
    cb.Text = "✕"
    cb.TextColor3 = Color3.fromRGB(220, 180, 240)
    cb.TextSize = isMobile and 16 or 14
    cb.Font = Theme.Bold
    cb.AutoButtonColor = false
    cb.ZIndex = 15
    cb.Parent = mp
    corner(cb, 8)
    w._cb = cb

    -- Minimize Button
    local minb = Instance.new("TextButton")
    minb.Name = "MinBtn"
    minb.Size = UDim2.new(0, ctrlBtnSize, 0, ctrlBtnSize)
    minb.Position = UDim2.new(1, -(ctrlBtnSize * 2 + 18), 0, 8)
    minb.BackgroundColor3 = Color3.fromRGB(60, 40, 100)
    minb.BackgroundTransparency = 0.5
    minb.BorderSizePixel = 0
    minb.Text = "━"
    minb.TextColor3 = Color3.fromRGB(220, 180, 240)
    minb.TextSize = isMobile and 14 or 12
    minb.Font = Theme.Bold
    minb.AutoButtonColor = false
    minb.ZIndex = 15
    minb.Parent = mp
    corner(minb, 8)
    w._minb = minb

    -- Notification Container
    local ncon = Instance.new("Frame")
    ncon.Name = "NotifContainer"
    ncon.Size = UDim2.new(0, isMobile and 260 or 320, 0, 400)
    ncon.Position = UDim2.new(1, isMobile and -270 or -340, 1, -420)
    ncon.BackgroundTransparency = 1
    ncon.Parent = sg
    local ncl = Instance.new("UIListLayout", ncon)
    ncl.Padding = UDim.new(0, 10)
    ncl.VerticalAlignment = Enum.VerticalAlignment.Bottom
    ncl.SortOrder = Enum.SortOrder.LayoutOrder
    self._notifContainer = ncon

    -- Drag Bar
    local dragBar = Instance.new("Frame")
    dragBar.Name = "DragBar"
    dragBar.Size = UDim2.new(1, -(ctrlBtnSize * 2 + 30), 0, 45)
    dragBar.BackgroundTransparency = 1
    dragBar.ZIndex = 2
    dragBar.Parent = mp

    local sidebarDrag = Instance.new("Frame")
    sidebarDrag.Name = "SidebarDrag"
    sidebarDrag.Size = UDim2.new(1, 0, 1, 0)
    sidebarDrag.BackgroundTransparency = 1
    sidebarDrag.ZIndex = 0
    sidebarDrag.Parent = sb

    -- Draggable Window
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
    local function updateDrag(input)
        local delta = input.Position - dragStart
        TweenService:Create(mp, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        }):Play()
    end
    local function makeDraggable(df)
        df.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = mp.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
    end
    makeDraggable(dragBar)
    makeDraggable(sidebarDrag)

    mp.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    table.insert(w._conns, UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then updateDrag(input) end
    end))

    -- Rotation Animation
    local swirlSpeed = 100
    table.insert(w._conns, RunService.RenderStepped:Connect(function(dt)
        if mobRing and mobRing.Parent then mobRing.Rotation = mobRing.Rotation + swirlSpeed * dt end
        if logoRing and logoRing.Parent then logoRing.Rotation = logoRing.Rotation + swirlSpeed * dt end
    end))

    TweenService:Create(mpStroke, TI.Shimmer, {Color = Color3.fromRGB(80, 120, 255)}):Play()

    -- Button Click Handlers
    cb.MouseButton1Click:Connect(function()
        if w._tweening then return end
        w._tweening = true
        local tScale = TweenService:Create(w._scale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), { Scale = 0 })
        tScale:Play()
        tScale.Completed:Connect(function() sg:Destroy() end)
    end)
    applyBouncy(cb, 1.1, 0.85, UDim2.new(0, ctrlBtnSize, 0, ctrlBtnSize))

    minb.MouseButton1Click:Connect(function() w:Minimize() end)
    applyBouncy(minb, 1.1, 0.85, UDim2.new(0, ctrlBtnSize, 0, ctrlBtnSize))

    mob.MouseButton1Click:Connect(function() w:Toggle() end)
    applyBouncy(mob, 1.1, 0.85, UDim2.new(0, mobSize, 0, mobSize))

    -- Keybind
    table.insert(w._conns, UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == keybind then w:Toggle() end
    end))

    -- Play Intro
    task.defer(function()
        task.wait(0.1)
        w:_playIntro()
        task.wait(0.8)
        NexusLib:Notify({Title = title .. " Mobile Ready", Message = "Loaded successfully!", Duration = 4})
    end)

    return w
end

-- ═══════════════════════════════════════════════════
-- WINDOW METHODS
-- ═══════════════════════════════════════════════════
function Window:_playIntro()
    self._tweening = true
    local mp = self._mp
    local sb = self._sb
    local cb = self._cb
    local minb = self._minb
    local nc = self._nc

    mp.Visible = true
    mp.ClipsDescendants = true
    self._scale.Scale = 0.2

    local pt = TweenService:Create(self._scale, TI.IPanel, { Scale = 1 })
    pt:Play()

    pt.Completed:Connect(function()
        mp.ClipsDescendants = false
        self._tweening = false
    end)
end

function Window:Minimize()
    if not self._menuOpen or self._tweening then return end
    self._tweening = true
    self._menuOpen = false
    self._mp.ClipsDescendants = true

    local ct = TweenService:Create(self._scale, TI.Close, { Scale = 0 })
    ct:Play()
    ct.Completed:Connect(function()
        self._mp.Visible = false
        self._tweening = false
    end)
end

function Window:Open()
    if self._menuOpen or self._tweening then return end
    self._tweening = true
    self._menuOpen = true
    self._mp.Visible = true
    local pt = TweenService:Create(self._scale, TI.IPanel, { Scale = 1 })
    pt:Play()
    pt.Completed:Connect(function()
        self._mp.ClipsDescendants = false
        self._tweening = false
    end)
end

function Window:Toggle()
    if self._menuOpen then self:Minimize() else self:Open() end
end

function Window:Destroy()
    for _, c in ipairs(self._conns) do pcall(function() c:Disconnect() end) end
    if self._sg and self._sg.Parent then self._sg:Destroy() end
end

-- ═══════════════════════════════════════════════════
-- TAB
-- ═══════════════════════════════════════════════════
function Window:CreateTab(name)
    local tabIndex = #self._tabs + 1
    local t = setmetatable({}, Tab)
    t._window = self
    t._name = name
    t._index = tabIndex
    t._orderCounter = 0

    local isFirst = (tabIndex == 1)
    local navHeight = isMobile and 36 or 42
    
    local btn = Instance.new("TextButton")
    btn.Name = "Nav_" .. name
    btn.Size = UDim2.new(1, 0, 0, navHeight)
    btn.BackgroundColor3 = isFirst and Theme.ActiveTab or Theme.InactiveTab
    btn.BackgroundTransparency = isFirst and 0.2 or 0.8
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.LayoutOrder = tabIndex
    btn.AutoButtonColor = false
    btn.Parent = self._nc
    corner(btn, 8)

    local tl = Instance.new("TextLabel")
    tl.Size = UDim2.new(1, -15, 1, 0)
    tl.Position = UDim2.new(0, 15, 0, 0)
    tl.BackgroundTransparency = 1
    tl.Text = name
    tl.TextColor3 = isFirst and Theme.Text or Theme.TextSub
    tl.TextSize = isMobile and 12 or 14
    tl.Font = Theme.Medium
    tl.TextXAlignment = Enum.TextXAlignment.Left
    tl.Parent = btn
    t._navBtn = btn
    t._navLabel = tl

    -- Content View
    local view = Instance.new("CanvasGroup")
    view.Name = name .. "View"
    view.Size = UDim2.new(1, 0, 1, 0)
    view.BackgroundTransparency = 1
    view.BorderSizePixel = 0
    view.GroupTransparency = isFirst and 0 or 1
    view.Visible = isFirst
    view.Parent = self._ca
    t._view = view

    -- Scroll Frame
    local sf = Instance.new("ScrollingFrame")
    sf.Name = "Scroll"
    sf.Size = UDim2.new(1, 0, 1, 0)
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel = 0
    sf.ScrollBarThickness = isMobile and 2 or 3
    sf.ScrollBarImageColor3 = Theme.Accent
    sf.ScrollBarImageTransparency = 0.5
    sf.Parent = view

    local wrapper = Instance.new("Frame")
    wrapper.Name = "Wrapper"
    wrapper.Size = UDim2.new(1, isMobile and -8 or -14, 1, 0)
    wrapper.Position = UDim2.new(0, 4, 0, 0)
    wrapper.BackgroundTransparency = 1
    wrapper.Parent = sf

    local sfl = Instance.new("UIListLayout", wrapper)
    sfl.Padding = UDim.new(0, isMobile and 8 or 10)
    sfl.SortOrder = Enum.SortOrder.LayoutOrder

    sfl:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sf.CanvasSize = UDim2.new(0, 0, 0, sfl.AbsoluteContentSize.Y + 15)
        wrapper.Size = UDim2.new(1, isMobile and -8 or -14, 0, sfl.AbsoluteContentSize.Y + 15)
    end)
    t._scroll = wrapper

    btn.MouseButton1Click:Connect(function() self:_switchTab(t) end)
    applyBouncy(btn, 1.03, 0.95)

    table.insert(self._tabs, t)
    if isFirst then self._activeTab = t end

    return t
end

function Window:_switchTab(targetTab)
    if not targetTab or targetTab == self._activeTab or self._tweening then return end
    self._tweening = true

    local prev = self._activeTab
    self._activeTab = targetTab

    TweenService:Create(prev._view, TI.TabOut, { GroupTransparency = 1 }):Play()

    local navHeight = isMobile and 36 or 42
    local spacing = isMobile and 41 or 47
    local targetY = (isMobile and 72 or 104) + (targetTab._index - 1) * spacing
    TweenService:Create(self._ind, TI.Smooth, {Position = UDim2.new(0, 8, 0, targetY)}):Play()

    for _, t in ipairs(self._tabs) do
        local isTarget = (t == targetTab)
        TweenService:Create(t._navBtn, TI.HOut, {
            BackgroundColor3 = isTarget and Theme.ActiveTab or Theme.InactiveTab,
            BackgroundTransparency = isTarget and 0.2 or 0.8
        }):Play()
        TweenService:Create(t._navLabel, TI.HOut, { TextColor3 = isTarget and Theme.Text or Theme.TextSub }):Play()
    end

    task.wait(0.2)
    prev._view.Visible = false

    targetTab._view.Visible = true
    targetTab._view.GroupTransparency = 1

    local fi = TweenService:Create(targetTab._view, TI.TabIn, { GroupTransparency = 0 })
    fi:Play()
    fi.Completed:Connect(function() self._tweening = false end)
end

-- ═══════════════════════════════════════════════════
-- SECTION & COMPONENTS
-- ═══════════════════════════════════════════════════
function Tab:CreateSection(name)
    local s = setmetatable({}, Section)
    s._tab = self
    s._name = name
    self._orderCounter = self._orderCounter + 1

    local sec = Instance.new("Frame")
    sec.Name = "Sec_" .. name:gsub(" ", "")
    sec.Size = UDim2.new(1, 0, 0, isMobile and 24 or 30)
    sec.BackgroundTransparency = 1
    sec.LayoutOrder = self._orderCounter
    sec.Parent = self._scroll

    local title = Instance.new("TextLabel", sec)
    title.Size = UDim2.new(1, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = name:upper()
    title.TextColor3 = Theme.AccentGlow
    title.TextSize = isMobile and 10 or 11
    title.Font = Theme.Bold
    title.TextXAlignment = Enum.TextXAlignment.Left

    s._frame = sec
    return s
end

local function compFrame(section, name)
    section._tab._orderCounter = section._tab._orderCounter + 1
    local f = Instance.new("Frame")
    f.Name = name or "Component"
    f.Size = UDim2.new(1, 0, 0, isMobile and 44 or 50)
    f.BackgroundColor3 = Theme.CardBg
    f.BackgroundTransparency = Theme.CardTransparency
    f.BorderSizePixel = 0
    f.LayoutOrder = section._tab._orderCounter
    f.Parent = section._tab._scroll
    corner(f, 8)
    uistroke(f, Theme.StrokeCard)
    return f
end

local function compLabel(parent, text)
    local l = Instance.new("TextLabel", parent)
    l.Name = "Label"
    l.Size = UDim2.new(0.5, 0, 1, 0)
    l.Position = UDim2.new(0, 12, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Theme.Text
    l.TextSize = isMobile and 11 or 13
    l.Font = Theme.Bold
    l.TextXAlignment = Enum.TextXAlignment.Left
    return l
end

-- ─────────── TOGGLE ───────────
function Section:CreateToggle(config)
    config = config or {}
    local name = config.Name or "Toggle"
    local default = config.Default or false
    local callback = config.Callback or function() end

    local toggle = {_state = default}
    local f = compFrame(self, "Toggle_" .. name)
    compLabel(f, name)

    local track = Instance.new("TextButton", f)
    track.Name = "Track"
    track.Size = UDim2.new(0, isMobile and 42 or 36, 0, isMobile and 24 or 20)
    track.Position = UDim2.new(1, isMobile and -52 or -48, 0.5, isMobile and -12 or -10)
    track.BackgroundColor3 = default and Theme.ToggleOn or Theme.ToggleOff
    track.BorderSizePixel = 0
    track.Text = ""
    track.AutoButtonColor = false
    corner(track, UDim.new(1, 0))
    uistroke(track, Theme.ToggleStroke, 1.2)

    local thumb = Instance.new("Frame", track)
    thumb.Name = "Thumb"
    local tSize = isMobile and 18 or 14
    thumb.Size = UDim2.new(0, tSize, 0, tSize)
    thumb.Position = UDim2.new(0, default and (isMobile and 21 or 19) or 3, 0.5, -tSize/2)
    thumb.BackgroundColor3 = Color3.new(1, 1, 1)
    thumb.BorderSizePixel = 0
    corner(thumb, UDim.new(1, 0))

    local function set(state, fire)
        toggle._state = state
        TweenService:Create(thumb, TI.Spring, {Position = UDim2.new(0, state and (isMobile and 21 or 19) or 3, 0.5, -tSize/2)}):Play()
        TweenService:Create(track, TI.HIn, {BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff}):Play()
        if fire ~= false then task.spawn(callback, state) end
    end

    track.MouseButton1Click:Connect(function() set(not toggle._state) end)
    if default then set(default, false) end

    function toggle:Set(state) set(state) end
    function toggle:Get() return self._state end
    toggle._frame = f
    return toggle
end

-- ─────────── SLIDER ───────────
function Section:CreateSlider(config)
    config = config or {}
    local name = config.Name or "Slider"
    local min = config.Min or 0
    local max = config.Max or 100
    local default = config.Default or min
    local increment = config.Increment or 1
    local callback = config.Callback or function() end

    local slider = {_value = default}
    local f = compFrame(self, "Slider_" .. name)
    local label = compLabel(f, name .. ": " .. default)

    local trackWidth = isMobile and 120 or 180
    local track = Instance.new("Frame", f)
    track.Name = "Track"
    track.Size = UDim2.new(0, trackWidth, 0, 6)
    track.Position = UDim2.new(1, -(trackWidth + 15), 0.5, -3)
    track.BackgroundColor3 = Theme.SliderTrack
    track.BorderSizePixel = 0
    corner(track)

    local fill = Instance.new("Frame", track)
    fill.Name = "Fill"
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    fill.BorderSizePixel = 0
    corner(fill)
    grad(fill, Theme.FillGrad)

    local handleSize = isMobile and 20 or 16
    local handle = Instance.new("TextButton", track)
    handle.Name = "Handle"
    handle.Size = UDim2.new(0, handleSize, 0, handleSize)
    handle.Position = UDim2.new((default - min) / (max - min), -handleSize/2, 0.5, -handleSize/2)
    handle.BackgroundColor3 = Color3.new(1, 1, 1)
    handle.BorderSizePixel = 0
    handle.Text = ""
    handle.AutoButtonColor = false
    corner(handle, UDim.new(1, 0))
    uistroke(handle, Theme.SliderStroke, 2)

    local active = false

    local function setVal(val, fire)
        val = math.clamp(math.round(val / increment) * increment, min, max)
        slider._value = val
        label.Text = name .. ": " .. val
        local pct = (val - min) / (max - min)
        fill.Size = UDim2.new(pct, 0, 1, 0)
        handle.Position = UDim2.new(pct, -handleSize/2, 0.5, -handleSize/2)
        if fire ~= false then task.spawn(callback, val) end
    end

    local function fromInput(input)
        local tw = track.AbsoluteSize.X
        local off = input.Position.X - track.AbsolutePosition.X
        local pct = math.clamp(off / tw, 0, 1)
        setVal(min + pct * (max - min))
    end

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            active = true
        end
    end)
    table.insert(self._tab._window._conns, UserInputService.InputEnded:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then active = false end
    end))
    table.insert(self._tab._window._conns, UserInputService.InputChanged:Connect(function(input)
        if active and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            fromInput(input)
        end
    end))

    function slider:Set(val) setVal(val) end
    function slider:Get() return self._value end
    slider._frame = f
    return slider
end

-- ─────────── DROPDOWN ───────────
function Section:CreateDropdown(config)
    config = config or {}
    local name = config.Name or "Dropdown"
    local options = config.Options or {}
    local default = config.Default or nil
    local callback = config.Callback or function() end

    local dropdown = {_selected = default, _isOpen = false}
    local f = compFrame(self, "Drop_" .. name)
    local container = Instance.new("Frame")
    container.Name = "Container_" .. name
    container.Size = UDim2.new(1, 0, 0, isMobile and 44 or 50)
    container.BackgroundTransparency = 1
    container.LayoutOrder = f.LayoutOrder
    container.Parent = self._tab._scroll
    f.Parent = container
    compLabel(f, name)

    local dropWidth = isMobile and 110 or 150
    local header = Instance.new("TextButton", f)
    header.Name = "Header"
    header.Size = UDim2.new(0, dropWidth, 0, isMobile and 28 or 32)
    header.Position = UDim2.new(1, -(dropWidth + 12), 0.5, isMobile and -14 or -16)
    header.BackgroundColor3 = Theme.DropBg
    header.Text = default or "Select..."
    header.TextColor3 = Theme.Text
    header.Font = Theme.Bold
    header.TextSize = isMobile and 10 or 11
    header.AutoButtonColor = false
    corner(header, 6)
    uistroke(header, Theme.DropStroke, 1)

    local ddList = Instance.new("Frame", f)
    ddList.Name = "List"
    ddList.Size = UDim2.new(0, dropWidth, 0, 0)
    ddList.Position = UDim2.new(1, -(dropWidth + 12), 0, isMobile and 36 or 42)
    ddList.BackgroundColor3 = Color3.fromRGB(22, 18, 40)
    ddList.BorderSizePixel = 0
    ddList.ZIndex = 10
    ddList.Visible = false
    ddList.ClipsDescendants = true
    corner(ddList, 6)
    uistroke(ddList, Theme.DropStroke, 1)

    local sf = Instance.new("ScrollingFrame", ddList)
    sf.Size = UDim2.new(1, 0, 1, 0)
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel = 0
    sf.ScrollBarThickness = 2

    local listLayout = Instance.new("UIListLayout", sf)
    listLayout.Padding = UDim.new(0, 3)

    local function setOpen(state)
        dropdown._isOpen = state
        ddList.Visible = true
        local targetH = state and math.min(#options * 32, 140) or 0
        TweenService:Create(ddList, TI.HIn, {Size = UDim2.new(0, dropWidth, 0, targetH)}):Play()
        TweenService:Create(container, TI.HIn, {Size = UDim2.new(1, 0, 0, (isMobile and 44 or 50) + targetH)}):Play()
        header.Text = dropdown._selected or "Select..."
    end

    local function populateOptions(opts)
        for _, c in ipairs(sf:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
        for i, optName in ipairs(opts) do
            local ob = Instance.new("TextButton", sf)
            ob.Name = "Opt_" .. i
            ob.Size = UDim2.new(1, 0, 0, 28)
            ob.BackgroundColor3 = Theme.DropOpt
            ob.BackgroundTransparency = 0.5
            ob.BorderSizePixel = 0
            ob.Text = optName
            ob.TextColor3 = Color3.fromRGB(200, 190, 230)
            ob.Font = Theme.Medium
            ob.TextSize = isMobile and 10 or 11
            ob.ZIndex = 11
            ob.AutoButtonColor = false
            corner(ob, 4)

            ob.MouseButton1Click:Connect(function()
                dropdown._selected = optName
                setOpen(false)
                header.Text = optName
                task.spawn(callback, optName)
            end)
        end
    end
    populateOptions(options)
    header.MouseButton1Click:Connect(function() setOpen(not dropdown._isOpen) end)

    function dropdown:Set(opt) dropdown._selected = opt; header.Text = opt; task.spawn(callback, opt) end
    function dropdown:Refresh(opts) options = opts; populateOptions(opts) end
    function dropdown:Get() return self._selected end
    dropdown._frame = f
    return dropdown
end

-- ─────────── BUTTON ───────────
function Section:CreateButton(config)
    config = config or {}
    local name = config.Name or "Button"
    local callback = config.Callback or function() end

    self._tab._orderCounter = self._tab._orderCounter + 1
    local container = Instance.new("Frame")
    container.Name = "Btn_" .. name
    container.Size = UDim2.new(1, 0, 0, isMobile and 38 or 42)
    container.BackgroundTransparency = 1
    container.LayoutOrder = self._tab._orderCounter
    container.Parent = self._tab._scroll

    local btn = Instance.new("TextButton", container)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(35, 30, 65)
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = Theme.Text
    btn.Font = Theme.Bold
    btn.TextSize = isMobile and 12 or 13
    btn.AutoButtonColor = false
    corner(btn, 8)
    uistroke(btn, Color3.fromRGB(150, 100, 255), 1)

    applyBouncy(btn, 1.03, 0.95)
    btn.MouseButton1Click:Connect(function() task.spawn(callback) end)
    return {_frame = container}
end

-- ─────────── TEXTBOX ───────────
function Section:CreateTextbox(config)
    config = config or {}
    local name = config.Name or "Input"
    local placeholder = config.Placeholder or "Type here..."
    local default = config.Default or ""
    local callback = config.Callback or function() end

    local textbox = {_value = default}
    local f = compFrame(self, "Txt_" .. name)
    compLabel(f, name)

    local inputWidth = isMobile and 120 or 170
    local input = Instance.new("TextBox", f)
    input.Name = "Input"
    input.Size = UDim2.new(0, inputWidth, 0, isMobile and 26 or 30)
    input.Position = UDim2.new(1, -(inputWidth + 12), 0.5, isMobile and -13 or -15)
    input.BackgroundColor3 = Color3.fromRGB(25, 20, 48)
    input.BorderSizePixel = 0
    input.Text = default
    input.PlaceholderText = placeholder
    input.PlaceholderColor3 = Color3.fromRGB(80, 70, 110)
    input.TextColor3 = Theme.Text
    input.TextSize = isMobile and 10 or 12
    input.Font = Theme.Medium
    input.ClearTextOnFocus = false
    corner(input, 6)
    uistroke(input, Theme.StrokeCard, 1)

    input.FocusLost:Connect(function(enterPressed)
        textbox._value = input.Text
        if enterPressed then task.spawn(callback, input.Text) end
    end)

    function textbox:Set(text) input.Text = text; textbox._value = text end
    function textbox:Get() return self._value end
    textbox._frame = f
    return textbox
end

-- ─────────── LABEL ───────────
function Section:CreateLabel(text)
    self._tab._orderCounter = self._tab._orderCounter + 1
    local f = Instance.new("Frame")
    f.Name = "Label"
    f.Size = UDim2.new(1, 0, 0, isMobile and 24 or 30)
    f.BackgroundTransparency = 1
    f.LayoutOrder = self._tab._orderCounter
    f.Parent = self._tab._scroll

    local tl = Instance.new("TextLabel", f)
    tl.Size = UDim2.new(1, -10, 1, 0)
    tl.Position = UDim2.new(0, 5, 0, 0)
    tl.BackgroundTransparency = 1
    tl.Text = text or ""
    tl.TextColor3 = Theme.TextSub
    tl.TextSize = isMobile and 11 or 12
    tl.Font = Theme.Medium
    tl.TextXAlignment = Enum.TextXAlignment.Left

    local label = {}
    function label:Set(newText) tl.Text = newText end
    label._frame = f
    return label
end

-- ═══════════════════════════════════════════════════
-- DESTROY ALL
-- ═══════════════════════════════════════════════════
function NexusLib:DestroyAll()
    if self._screenGui and self._screenGui.Parent then self._screenGui:Destroy() end
    if self._connections then
        for _, c in ipairs(self._connections) do pcall(function() c:Disconnect() end) end
    end
    return self
end

return NexusLib
