-- =====================================================
-- NEXUS GAMING HUB UI LIBRARY (NexusLib) + KEY SYSTEM
-- =====================================================

local NexusLib = {}
--[[
    ╔════════════════════════════════════════════════╗
    ║         NexusLib UI Library v1.0               ║
    ║     Premium Gojo Hollow Purple Theme           ║
    ║     by Nexus Gaming Hub                        ║
    ╚════════════════════════════════════════════════╝
]]

-- ═══════════════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════════════
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer
local guiParent = (RunService:IsStudio() and localPlayer)
    and localPlayer:WaitForChild("PlayerGui")
    or (typeof(gethui) == "function" and gethui() or game:GetService("CoreGui"))

-- ═══════════════════════════════════════════════════
-- THEME
-- ═══════════════════════════════════════════════════
local Theme = {
    Background      = Color3.fromRGB(15, 15, 35),
    BgGrad1         = Color3.fromRGB(25, 20, 50),
    BgGrad2         = Color3.fromRGB(10, 10, 30),
    SidebarBg       = Color3.fromRGB(12, 12, 28),
    CardBg          = Color3.fromRGB(20, 18, 45),

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
    NSlide  = TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    NTilt   = TweenInfo.new(0.68, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
    NFade   = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    NClose  = TweenInfo.new(0.38, Enum.EasingStyle.Back, Enum.EasingDirection.In),
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

local function createMiniN(parent)
    local ct = Instance.new("Frame")
    ct.Size = UDim2.new(1, 0, 1, 0)
    ct.BackgroundTransparency = 1
    ct.Parent = parent

    local function bar(px, sy, rot)
        local b = Instance.new("Frame")
        b.Size = UDim2.new(0, 4, 0, sy)
        b.Position = UDim2.new(0.5, px, 0.5, 0)
        b.AnchorPoint = Vector2.new(0.5, 0.5)
        b.BackgroundColor3 = Color3.new(1, 1, 1)
        b.BorderSizePixel = 0
        b.Rotation = rot or 0
        b.Parent = ct
        corner(b, UDim.new(1, 0))
    end

    bar(-6, 16, 0)
    bar(6, 16, 0)
    bar(0, 18, -35)
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

NexusLib._notifContainer = nil
NexusLib._connections = {}
NexusLib._screenGui = nil

-- ═══════════════════════════════════════════════════
-- NOTIFICATION SYSTEM (ADVANCED LASER STYLE)
-- ═══════════════════════════════════════════════════
function NexusLib:EnsureNotifContainer()
    if not self._notifGui or not self._notifGui.Parent then
        self._notifGui = Instance.new("ScreenGui")
        self._notifGui.Name = "NexusNotifications"
        self._notifGui.Parent = guiParent
        
        local ncon = Instance.new("Frame")
        ncon.Name = "NotifContainer"
        ncon.Size = UDim2.new(0, 320, 0, 400)
        ncon.Position = UDim2.new(1, -340, 1, -420)
        ncon.BackgroundTransparency = 1
        ncon.Parent = self._notifGui
        
        local ncl = Instance.new("UIListLayout", ncon)
        ncl.Padding = UDim.new(0, 10)
        ncl.VerticalAlignment = Enum.VerticalAlignment.Bottom
        ncl.SortOrder = Enum.SortOrder.LayoutOrder
        self._notifContainer = ncon
    end
end

function NexusLib:Notify(config)
    self:EnsureNotifContainer()
    
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
    inner.BackgroundColor3 = Color3.fromRGB(15, 12, 28)
    inner.BackgroundTransparency = 0.15
    inner.BorderSizePixel = 0
    inner.Parent = notif
    Instance.new("UICorner", inner).CornerRadius = UDim.new(0, 12)

    -- Laser border stroke
    local stroke = Instance.new("UIStroke", inner)
    stroke.Thickness = 2.0
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    local strokeGrad = Instance.new("UIGradient", stroke)
    strokeGrad.Color = Theme.LaserGrad
    strokeGrad.Rotation = 45

    -- Inner glass border shine
    local glare = Instance.new("Frame")
    glare.Size = UDim2.new(1, -4, 1, -4)
    glare.Position = UDim2.new(0, 2, 0, 2)
    glare.BackgroundTransparency = 1
    glare.BorderSizePixel = 0
    glare.Parent = inner
    Instance.new("UICorner", glare).CornerRadius = UDim.new(0, 10)
    local glareStroke = Instance.new("UIStroke", glare)
    glareStroke.Thickness = 1
    glareStroke.Color = Color3.new(1, 1, 1)
    glareStroke.Transparency = 0.88

    -- Mini geometric logo indicator
    local logoIcon = Instance.new("Frame")
    logoIcon.Name = "MiniLogo"
    logoIcon.Size = UDim2.new(0, 36, 0, 36)
    logoIcon.Position = UDim2.new(0, 12, 0.5, 0)
    logoIcon.AnchorPoint = Vector2.new(0, 0.5)
    logoIcon.BackgroundColor3 = Color3.new(1, 1, 1)
    logoIcon.BorderSizePixel = 0
    logoIcon.Parent = inner
    Instance.new("UICorner", logoIcon).CornerRadius = UDim.new(0, 9)

    local logoGrad = Instance.new("UIGradient", logoIcon)
    logoGrad.Color = Theme.HollowPurple
    logoGrad.Rotation = 45

    createMiniN(logoIcon)

    -- Title
    local tLabel = Instance.new("TextLabel")
    tLabel.Size = UDim2.new(1, -95, 0, 20)
    tLabel.Position = UDim2.new(0, 60, 0, 12)
    tLabel.BackgroundTransparency = 1
    tLabel.Text = title
    tLabel.TextColor3 = Color3.new(1, 1, 1)
    tLabel.TextSize = 13
    tLabel.Font = Enum.Font.GothamBold
    tLabel.TextXAlignment = Enum.TextXAlignment.Left
    tLabel.Parent = inner

    -- Message
    local mLabel = Instance.new("TextLabel")
    mLabel.Size = UDim2.new(1, -95, 0, 30)
    mLabel.Position = UDim2.new(0, 60, 0, 30)
    mLabel.BackgroundTransparency = 1
    mLabel.Text = message
    mLabel.TextColor3 = Color3.fromRGB(180, 170, 210)
    mLabel.TextSize = 11
    mLabel.Font = Enum.Font.GothamMedium
    mLabel.TextWrapped = true
    mLabel.TextXAlignment = Enum.TextXAlignment.Left
    mLabel.TextYAlignment = Enum.TextYAlignment.Top
    mLabel.Parent = inner

    -- Close
    local xBtn = Instance.new("TextButton")
    xBtn.Name = "CloseButton"
    xBtn.Size = UDim2.new(0, 20, 0, 20)
    xBtn.Position = UDim2.new(1, -26, 0.5, -10)
    xBtn.BackgroundTransparency = 1
    xBtn.Text = "X"
    xBtn.TextColor3 = Color3.fromRGB(140, 130, 170)
    xBtn.TextSize = 12
    xBtn.Font = Enum.Font.GothamBold
    xBtn.AutoButtonColor = false
    xBtn.Parent = inner

    -- Progress track
    local progressTrack = Instance.new("Frame")
    progressTrack.Size = UDim2.new(1, -24, 0, 2)
    progressTrack.Position = UDim2.new(0, 12, 1, -5)
    progressTrack.BackgroundColor3 = Color3.fromRGB(30, 25, 50)
    progressTrack.BorderSizePixel = 0
    progressTrack.Parent = inner
    Instance.new("UICorner", progressTrack)

    local progressBar = Instance.new("Frame")
    progressBar.Size = UDim2.new(1, 0, 1, 0)
    progressBar.BackgroundColor3 = Color3.new(1, 1, 1)
    progressBar.BorderSizePixel = 0
    progressBar.Parent = progressTrack
    Instance.new("UICorner", progressBar)

    local progressGrad = Instance.new("UIGradient", progressBar)
    progressGrad.Color = Theme.LaserGrad

    notif.Parent = self._notifContainer

    -- Entrance Animation
    local expandTween = TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = targetSize})
    expandTween:Play()
    task.wait(0.12)

    local slideTween = TweenService:Create(inner, TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)})
    slideTween:Play()

    local hoverIn = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local hoverOut = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    xBtn.MouseEnter:Connect(function() TweenService:Create(xBtn, hoverIn, {TextColor3 = Color3.fromRGB(255, 80, 80)}):Play() end)
    xBtn.MouseLeave:Connect(function() TweenService:Create(xBtn, hoverOut, {TextColor3 = Color3.fromRGB(140, 130, 170)}):Play() end)

    local progressTween = TweenService:Create(progressBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 1, 0)})
    progressTween:Play()

    local isClosing = false
    local function closeNotif()
        if isClosing then return end
        isClosing = true

        local slideOut = TweenService:Create(inner, TweenInfo.new(0.38, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Position = UDim2.new(1.3, 0, 0, 0)
        })
        slideOut:Play()

        slideOut.Completed:Connect(function()
            local collapse = TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(1, 0, 0, 0)})
            collapse:Play()
            collapse.Completed:Connect(function() notif:Destroy() end)
        end)
    end
    xBtn.MouseButton1Click:Connect(closeNotif)
    task.spawn(function()
        task.wait(duration)
        if notif and notif.Parent then closeNotif() end
    end)
end

-- ═══════════════════════════════════════════════════
-- KEY SYSTEM (ADVANCED WITH NOTIFY & BUTTON)
-- ═══════════════════════════════════════════════════
function NexusLib:CreateKeySystem(config)
    config = config or {}
    
    local appearance = config.Appearance or {}
    local links = config.Links or {}
    local shop = config.Shop or {}
    
    local title = appearance.Title or config.Title or "NEXUS"
    local subtitle = appearance.Subtitle or config.Subtitle or "KEY SYSTEM"
    local note = config.Note or "Please enter your Freemium Key to continue!"
    local keyLink = links.GetKey or config.KeyLink or "https://discord.gg/QAdVUX2wCH"
    local keys = config.Keys or {"NEXUS-FREEMIUM"}
    local callback = config.Callback or function() end

    local hasShop = shop.Enabled == true
    local mainHeight = hasShop and 320 or 260

    if self._keyGui and self._keyGui.Parent then
        self._keyGui:Destroy()
    end
    self:EnsureNotifContainer()

    local sg = Instance.new("ScreenGui")
    sg.Name = "NexusKeySystem"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.IgnoreGuiInset = true
    sg.Parent = guiParent
    self._keyGui = sg

    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 350, 0, mainHeight)
    main.Position = UDim2.new(0.5, 0, 0.5, 0)
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.BackgroundColor3 = Theme.Background
    main.BackgroundTransparency = 0.1
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Parent = sg
    corner(main, 12)
    local mainStroke = uistroke(main, Theme.StrokeMain, 1.5, 0.2)
    grad(mainStroke, Theme.HollowStroke, 160)
    local mainScale = Instance.new("UIScale", main)
    mainScale.Scale = 0

    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, 60)
    topBar.BackgroundTransparency = 1
    topBar.Parent = main

    local logo, logoRing = createLogoIcon(topBar, UDim2.new(0, 35, 0, 35), UDim2.new(0, 15, 0.5, 0), Vector2.new(0, 0.5))

    local tl = Instance.new("TextLabel")
    tl.Size = UDim2.new(0, 200, 0, 20)
    tl.Position = UDim2.new(0, 60, 0.5, -10)
    tl.BackgroundTransparency = 1
    tl.Text = string.format("<font color='rgb(150,80,255)'>%s</font> %s", title:upper(), subtitle:upper())
    tl.RichText = true
    tl.TextColor3 = Theme.Text
    tl.TextSize = 16
    tl.Font = Theme.Bold
    tl.TextXAlignment = Enum.TextXAlignment.Left
    tl.Parent = topBar

    local cb = Instance.new("TextButton")
    cb.Name = "CloseBtn"
    cb.Size = UDim2.new(0, 28, 0, 28)
    cb.Position = UDim2.new(1, -38, 0.5, -14)
    cb.BackgroundColor3 = Color3.fromRGB(60, 40, 100)
    cb.BackgroundTransparency = 0.5
    cb.BorderSizePixel = 0
    cb.Text = "X"
    cb.TextColor3 = Color3.fromRGB(180, 160, 220)
    cb.TextSize = 14
    cb.Font = Theme.Bold
    cb.AutoButtonColor = false
    cb.Parent = topBar
    corner(cb, 6)
    applyBouncy(cb, 1.1, 0.85)

    cb.MouseButton1Click:Connect(function()
        TweenService:Create(mainScale, TI.Close, {Scale = 0}):Play()
        task.wait(0.4)
        sg:Destroy()
    end)

    local div = Instance.new("Frame")
    div.Size = UDim2.new(1, -30, 0, 1)
    div.Position = UDim2.new(0, 15, 0, 60)
    div.BackgroundColor3 = Theme.Divider
    div.BackgroundTransparency = 0.5
    div.BorderSizePixel = 0
    div.Parent = main

    local noteLabel = Instance.new("TextLabel")
    noteLabel.Size = UDim2.new(1, -40, 0, 30)
    noteLabel.Position = UDim2.new(0, 20, 0, 75)
    noteLabel.BackgroundTransparency = 1
    noteLabel.Text = note
    noteLabel.TextColor3 = Theme.TextSub
    noteLabel.TextSize = 13
    noteLabel.Font = Theme.Medium
    noteLabel.TextWrapped = true
    noteLabel.TextXAlignment = Enum.TextXAlignment.Center
    noteLabel.Parent = main

    local inputCon = Instance.new("Frame")
    inputCon.Size = UDim2.new(1, -60, 0, 45)
    inputCon.Position = UDim2.new(0, 30, 0, 120)
    inputCon.BackgroundColor3 = Theme.CardBg
    inputCon.BorderSizePixel = 0
    inputCon.Parent = main
    corner(inputCon, 8)
    local inStroke = uistroke(inputCon, Theme.StrokeCard, 1.2)

    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -20, 1, 0)
    input.Position = UDim2.new(0, 10, 0, 0)
    input.BackgroundTransparency = 1
    input.Text = ""
    input.PlaceholderText = "Enter Key here..."
    input.PlaceholderColor3 = Color3.fromRGB(90, 80, 120)
    input.TextColor3 = Theme.Text
    input.TextSize = 14
    input.Font = Theme.Medium
    input.ClearTextOnFocus = false
    input.TextXAlignment = Enum.TextXAlignment.Center
    input.Parent = inputCon

    input.Focused:Connect(function() TweenService:Create(inStroke, TI.HIn, {Color = Theme.Accent}):Play() end)
    input.FocusLost:Connect(function() TweenService:Create(inStroke, TI.HOut, {Color = Theme.StrokeCard}):Play() end)

    local btnCon = Instance.new("Frame")
    btnCon.Size = UDim2.new(1, -60, 0, 40)
    btnCon.Position = UDim2.new(0, 30, 0, 190)
    btnCon.BackgroundTransparency = 1
    btnCon.Parent = main

    local getBtn = Instance.new("TextButton")
    getBtn.Size = UDim2.new(0.48, 0, 1, 0)
    getBtn.Position = UDim2.new(0, 0, 0, 0)
    getBtn.BackgroundColor3 = Theme.CardBg
    getBtn.BorderSizePixel = 0
    getBtn.Text = "GET KEY"
    getBtn.TextColor3 = Theme.Text
    getBtn.TextSize = 13
    getBtn.Font = Theme.Bold
    getBtn.AutoButtonColor = false
    getBtn.Parent = btnCon
    corner(getBtn, 8)
    uistroke(getBtn, Theme.StrokeCard, 1)
    applyBouncy(getBtn, 1.05, 0.95)

    getBtn.MouseButton1Click:Connect(function()
        if setclipboard then setclipboard(keyLink) end
        self:Notify({Title = "Key System", Message = "Key link copied to clipboard!", Duration = 3})
    end)

    local verifyBtn = Instance.new("TextButton")
    verifyBtn.Size = UDim2.new(0.48, 0, 1, 0)
    verifyBtn.Position = UDim2.new(0.52, 0, 0, 0)
    verifyBtn.BackgroundColor3 = Theme.Accent
    verifyBtn.BorderSizePixel = 0
    verifyBtn.Text = "VERIFY KEY"
    verifyBtn.TextColor3 = Theme.Text
    verifyBtn.TextSize = 13
    verifyBtn.Font = Theme.Bold
    verifyBtn.AutoButtonColor = false
    verifyBtn.Parent = btnCon
    corner(verifyBtn, 8)
    applyBouncy(verifyBtn, 1.05, 0.95)

    verifyBtn.MouseButton1Click:Connect(function()
        local entered = input.Text
        local valid = false
        for _, k in ipairs(keys) do
            if entered == k then valid = true; break end
        end

        if valid then
            self:Notify({Title = "Key System", Message = "Key valid! Access granted.", Duration = 3})
            TweenService:Create(mainScale, TI.Close, {Scale = 0}):Play()
            task.delay(0.5, function()
                sg:Destroy()
                task.spawn(callback)
            end)
        else
            self:Notify({Title = "Key System", Message = "Invalid Key! Please try again.", Duration = 3})
            
            local oPos = inputCon.Position
            local shake = TweenService:Create(inputCon, TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 5, true), {
                Position = UDim2.new(0, 35, 0, 120)
            })
            local colorTween = TweenService:Create(inStroke, TI.HIn, {Color = Color3.fromRGB(255, 50, 50)})
            shake:Play(); colorTween:Play()
            shake.Completed:Connect(function()
                inputCon.Position = oPos
                TweenService:Create(inStroke, TI.HOut, {Color = Theme.StrokeCard}):Play()
            end)
        end
    end)
    
    if hasShop then
        local shopCon = Instance.new("Frame")
        shopCon.Size = UDim2.new(1, -60, 0, 45)
        shopCon.Position = UDim2.new(0, 30, 0, 245)
        shopCon.BackgroundColor3 = Color3.fromRGB(20, 18, 45)
        shopCon.BorderSizePixel = 0
        shopCon.Parent = main
        corner(shopCon, 8)
        uistroke(shopCon, Color3.fromRGB(60, 50, 100), 1)

        local shopTitle = Instance.new("TextLabel")
        shopTitle.Size = UDim2.new(1, -90, 0, 20)
        shopTitle.Position = UDim2.new(0, 10, 0, 5)
        shopTitle.BackgroundTransparency = 1
        shopTitle.Text = shop.Title or "Get Premium"
        shopTitle.TextColor3 = Theme.Text
        shopTitle.TextSize = 13
        shopTitle.Font = Theme.Bold
        shopTitle.TextXAlignment = Enum.TextXAlignment.Left
        shopTitle.Parent = shopCon

        local shopSub = Instance.new("TextLabel")
        shopSub.Size = UDim2.new(1, -90, 0, 15)
        shopSub.Position = UDim2.new(0, 10, 0, 25)
        shopSub.BackgroundTransparency = 1
        shopSub.Text = shop.Subtitle or "Instant delivery • 24/7 support"
        shopSub.TextColor3 = Theme.TextSub
        shopSub.TextSize = 10
        shopSub.Font = Theme.Medium
        shopSub.TextXAlignment = Enum.TextXAlignment.Left
        shopSub.Parent = shopCon

        local shopBtn = Instance.new("TextButton")
        shopBtn.Size = UDim2.new(0, 70, 0, 26)
        shopBtn.Position = UDim2.new(1, -80, 0.5, -13)
        shopBtn.BackgroundColor3 = Theme.Accent
        shopBtn.BorderSizePixel = 0
        shopBtn.Text = shop.ButtonText or "Buy"
        shopBtn.TextColor3 = Theme.Text
        shopBtn.TextSize = 11
        shopBtn.Font = Theme.Bold
        shopBtn.AutoButtonColor = false
        shopBtn.Parent = shopCon
        corner(shopBtn, 6)
        applyBouncy(shopBtn, 1.05, 0.95)

        shopBtn.MouseButton1Click:Connect(function()
            if setclipboard and shop.Link then
                setclipboard(shop.Link)
                self:Notify({Title = "Store", Message = "Store link copied!", Duration = 3})
            end
        end)
    end

    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
    main.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = inp.Position; startPos = main.Position
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    main.InputChanged:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then dragInput = inp end
    end)
    table.insert(self._connections, UserInputService.InputChanged:Connect(function(inp)
        if inp == dragInput and dragging then
            local delta = inp.Position - dragStart
            TweenService:Create(main, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            }):Play()
        end
    end))
    table.insert(self._connections, RunService.RenderStepped:Connect(function(dt)
        if logoRing and logoRing.Parent then logoRing.Rotation = logoRing.Rotation + 100 * dt end
    end))

    TweenService:Create(mainScale, TI.IPanel, {Scale = 1}):Play()
end


-- ═══════════════════════════════════════════════════
-- WINDOW : CreateWindow (From Full Library)
-- ═══════════════════════════════════════════════════
function NexusLib:CreateWindow(config)
    config = config or {}
    local title = config.Title or "NEXUS"
    local subtitle = config.Subtitle or "GAMING HUB"
    local keybind = config.Keybind or Enum.KeyCode.RightShift

    if self._screenGui and self._screenGui.Parent then
        self._screenGui:Destroy()
    end
    if self._connections then
        for _, c in ipairs(self._connections) do pcall(function() c:Disconnect() end) end
    end
    self._connections = {}

    local w = setmetatable({}, Window)
    w._tabs = {}
    w._activeTab = nil
    w._menuOpen = true
    w._tweening = false
    w._orderCounter = 0
    w._conns = {}

    local sg = Instance.new("ScreenGui")
    sg.Name = "NexusLib"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.IgnoreGuiInset = true
    sg.Parent = guiParent
    w._sg = sg
    self._screenGui = sg
    self:EnsureNotifContainer()

    local mob = Instance.new("TextButton")
    mob.Name = "MobileBtn"
    mob.Size = UDim2.new(0, 50, 0, 50)
    mob.Position = UDim2.new(0, 45, 0.5, 0)
    mob.AnchorPoint = Vector2.new(0.5, 0.5)
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

    local mp = Instance.new("Frame")
    mp.Name = "MainPanel"
    mp.Size = UDim2.new(0, 750, 0, 480)
    mp.Position = UDim2.new(0.5, 0, 0.5, 0)
    mp.AnchorPoint = Vector2.new(0.5, 0.5)
    mp.BackgroundColor3 = Theme.Background
    mp.BackgroundTransparency = 0.1
    mp.BorderSizePixel = 0
    mp.Parent = sg
    corner(mp, 20)
    local mpStroke = uistroke(mp, Theme.StrokeMain, 1.5, 0.5)
    local mpGrad = Instance.new("UIGradient", mp)
    mpGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.BgGrad1),
        ColorSequenceKeypoint.new(1, Theme.BgGrad2)
    })
    mpGrad.Rotation = 160
    
    local mpScale = Instance.new("UIScale", mp)
    mpScale.Scale = 1
    w._scale = mpScale
    w._mp = mp

    local sb = Instance.new("Frame")
    sb.Name = "Sidebar"
    sb.Size = UDim2.new(0, 200, 1, 0)
    sb.BackgroundColor3 = Theme.SidebarBg
    sb.BackgroundTransparency = 0.3
    sb.BorderSizePixel = 0
    sb.Parent = mp
    corner(sb, 20)
    w._sb = sb

    local dv = Instance.new("Frame")
    dv.Size = UDim2.new(0, 1, 0.85, 0)
    dv.Position = UDim2.new(1, 0, 0.075, 0)
    dv.BackgroundColor3 = Theme.Divider
    dv.BackgroundTransparency = 0.6
    dv.BorderSizePixel = 0
    dv.Parent = sb

    local lf = Instance.new("Frame")
    lf.Name = "LogoFrame"
    lf.Size = UDim2.new(1, 0, 0, 80)
    lf.BackgroundTransparency = 1
    lf.Parent = sb
    local logoIcon, logoRing = createLogoIcon(lf)
    local lt = Instance.new("TextLabel")
    lt.Size = UDim2.new(0, 110, 0, 20)
    lt.Position = UDim2.new(0, 75, 0.5, -12)
    lt.BackgroundTransparency = 1
    lt.Text = title:upper()
    lt.TextColor3 = Theme.Text
    lt.TextSize = 18
    lt.Font = Theme.Bold
    lt.TextXAlignment = Enum.TextXAlignment.Left
    lt.Parent = lf
    local lsub = Instance.new("TextLabel")
    lsub.Size = UDim2.new(0, 110, 0, 15)
    lsub.Position = UDim2.new(0, 75, 0.5, 8)
    lsub.BackgroundTransparency = 1
    lsub.Text = subtitle:upper()
    lsub.TextColor3 = Theme.TextMuted
    lsub.TextSize = 10
    lsub.Font = Theme.Medium
    lsub.TextXAlignment = Enum.TextXAlignment.Left
    lsub.Parent = lf

    local nc = Instance.new("Frame")
    nc.Name = "NavContainer"
    nc.Size = UDim2.new(1, -20, 1, -110)
    nc.Position = UDim2.new(0, 10, 0, 95)
    nc.BackgroundTransparency = 1
    nc.Parent = sb
    Instance.new("UIListLayout", nc).Padding = UDim.new(0, 6)
    nc:FindFirstChildOfClass("UIListLayout").SortOrder = Enum.SortOrder.LayoutOrder
    w._nc = nc

    local ind = Instance.new("Frame")
    ind.Name = "Indicator"
    ind.Size = UDim2.new(0, 3, 0, 24)
    ind.Position = UDim2.new(0, 10, 0, 104)
    ind.BackgroundColor3 = Theme.AccentGlow
    ind.BorderSizePixel = 0
    ind.ZIndex = 5
    ind.Parent = sb
    corner(ind, 2)
    w._ind = ind

    local ca = Instance.new("Frame")
    ca.Name = "ContentArea"
    ca.Size = UDim2.new(1, -215, 1, -30)
    ca.Position = UDim2.new(0, 210, 0, 15)
    ca.BackgroundTransparency = 1
    ca.ZIndex = 1
    ca.Parent = mp
    w._ca = ca

    local cb = Instance.new("TextButton")
    cb.Name = "CloseBtn"
    cb.Size = UDim2.new(0, 32, 0, 32)
    cb.Position = UDim2.new(1, -42, 0, 10)
    cb.BackgroundColor3 = Color3.fromRGB(60, 40, 100)
    cb.BackgroundTransparency = 0.5
    cb.BorderSizePixel = 0
    cb.Text = "X"
    cb.TextColor3 = Color3.fromRGB(180, 160, 220)
    cb.TextSize = 14
    cb.Font = Theme.Bold
    cb.AutoButtonColor = false
    cb.ZIndex = 15
    cb.Parent = mp
    corner(cb, 8)
    w._cb = cb

    local minb = Instance.new("TextButton")
    minb.Name = "MinBtn"
    minb.Size = UDim2.new(0, 32, 0, 32)
    minb.Position = UDim2.new(1, -78, 0, 10)
    minb.BackgroundColor3 = Color3.fromRGB(60, 40, 100)
    minb.BackgroundTransparency = 0.5
    minb.BorderSizePixel = 0
    minb.Text = "-"
    minb.TextColor3 = Color3.fromRGB(180, 160, 220)
    minb.TextSize = 16
    minb.Font = Theme.Bold
    minb.AutoButtonColor = false
    minb.ZIndex = 15
    minb.Parent = mp
    corner(minb, 8)
    w._minb = minb

    local dragBar = Instance.new("Frame")
    dragBar.Name = "DragBar"
    dragBar.Size = UDim2.new(1, -120, 0, 45)
    dragBar.BackgroundTransparency = 1
    dragBar.ZIndex = 2
    dragBar.Parent = mp
    local sidebarDrag = Instance.new("Frame")
    sidebarDrag.Name = "SidebarDrag"
    sidebarDrag.Size = UDim2.new(1, 0, 1, 0)
    sidebarDrag.BackgroundTransparency = 1
    sidebarDrag.ZIndex = 0
    sidebarDrag.Parent = sb

    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
    local function makeDraggable(df)
        df.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true; dragStart = input.Position; startPos = mp.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
    end
    makeDraggable(dragBar); makeDraggable(sidebarDrag)

    mp.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    table.insert(w._conns, UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            TweenService:Create(mp, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            }):Play()
        end
    end))

    table.insert(w._conns, RunService.RenderStepped:Connect(function(dt)
        if mobRing and mobRing.Parent then mobRing.Rotation = mobRing.Rotation + 100 * dt end
        if logoRing and logoRing.Parent then logoRing.Rotation = logoRing.Rotation + 100 * dt end
    end))

    TweenService:Create(mpStroke, TI.Shimmer, {Color = Color3.fromRGB(80, 120, 255)}):Play()

    cb.MouseButton1Click:Connect(function()
        if w._tweening then return end
        w._tweening = true; mp.ClipsDescendants = true
        local tScale = TweenService:Create(w._scale, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), { Scale = 0 })
        TweenService:Create(mp, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { BackgroundTransparency = 1 }):Play()
        for _, v in pairs(mp:GetDescendants()) do
            pcall(function()
                if v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox") then
                    TweenService:Create(v, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
                elseif v:IsA("ImageLabel") or v:IsA("ImageButton") then
                    TweenService:Create(v, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {ImageTransparency = 1, BackgroundTransparency = 1}):Play()
                elseif v:IsA("Frame") or v:IsA("ScrollingFrame") then
                    TweenService:Create(v, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
                elseif v:IsA("UIStroke") then
                    TweenService:Create(v, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Transparency = 1}):Play()
                end
            end)
        end
        TweenService:Create(mob, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0), BackgroundTransparency = 1}):Play()
        tScale:Play()
        tScale.Completed:Connect(function() sg:Destroy() end)
    end)
    applyBouncy(cb, 1.1, 0.85, UDim2.new(0, 32, 0, 32))

    minb.MouseButton1Click:Connect(function() w:Minimize() end)
    applyBouncy(minb, 1.1, 0.85, UDim2.new(0, 32, 0, 32))
    mob.MouseButton1Click:Connect(function() w:Toggle() end)
    applyBouncy(mob, 1.1, 0.85, UDim2.new(0, 50, 0, 50))

    table.insert(w._conns, UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == keybind then w:Toggle() end
    end))

    task.defer(function()
        task.wait(0.1)
        w:_playIntro()
        task.wait(1)
        NexusLib:Notify({Title = title, Message = "Hub loaded successfully!", Duration = 5})
    end)

    return w
end

function Window:_playIntro()
    self._tweening = true
    local mp, sb, cb, minb, nc = self._mp, self._sb, self._cb, self._minb, self._nc
    mp.Visible = true; mp.ClipsDescendants = true; mp.Size = UDim2.new(0, 10, 0, 10); mp.Rotation = -15; mp.BackgroundTransparency = 1
    local ps = mp:FindFirstChildOfClass("UIStroke")
    if ps then ps.Transparency = 1 end
    sb.Position = UDim2.new(-0.3, 0, 0, 0); sb.BackgroundTransparency = 1
    if self._activeTab then self._activeTab._view.GroupTransparency = 1 end
    cb.Size = UDim2.new(0,0,0,0); cb.BackgroundTransparency = 1
    minb.Size = UDim2.new(0,0,0,0); minb.BackgroundTransparency = 1

    local pt = TweenService:Create(mp, TI.IPanel, {Size = UDim2.new(0, 750, 0, 480), Rotation = 0, BackgroundTransparency = 0.1})
    pt:Play()
    if ps then TweenService:Create(ps, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency = 0.5}):Play() end
    pt.Completed:Connect(function()
        mp.ClipsDescendants = false
        TweenService:Create(sb, TI.ISide, {Position = UDim2.new(0,0,0,0), BackgroundTransparency = 0.3}):Play()
        task.wait(0.1)
        if self._activeTab then
            local av = self._activeTab._view
            av.Position = UDim2.new(0, 30, 0, 0); av.Size = UDim2.new(1.05, 0, 1.05, 0)
            TweenService:Create(av, TI.ICont, {Position = UDim2.new(0,0,0,0), Size = UDim2.new(1,0,1,0), GroupTransparency = 0}):Play()
        end
        for _, btn in ipairs(nc:GetChildren()) do
            if btn:IsA("TextButton") then
                local op = btn.Position
                btn.Position = UDim2.new(-0.5, 0, op.Y.Scale, op.Y.Offset)
                task.wait(0.04)
                TweenService:Create(btn, TI.INav, {Position = op}):Play()
            end
        end
        TweenService:Create(cb, TI.IBtn, {Size = UDim2.new(0,32,0,32), BackgroundTransparency = 0.5}):Play()
        TweenService:Create(minb, TI.IBtn, {Size = UDim2.new(0,32,0,32), BackgroundTransparency = 0.5}):Play()
        self._tweening = false
    end)
end

function Window:Minimize()
    if not self._menuOpen or self._tweening then return end
    self._tweening = true; self._menuOpen = false; self._mp.ClipsDescendants = true
    TweenService:Create(self._mp, TI.Antic, {Size = UDim2.new(0, 770, 0, 490)}):Play()
    task.wait(0.1)
    local ct = TweenService:Create(self._mp, TI.Close, {Size = UDim2.new(0, 200, 0, 120), Position = UDim2.new(0.5, 0, 0.8, 80), BackgroundTransparency = 1})
    ct:Play()
    local ps = self._mp:FindFirstChildOfClass("UIStroke")
    if ps then TweenService:Create(ps, TI.Close, {Transparency = 1}):Play() end
    ct.Completed:Connect(function() self._mp.Visible = false; self._tweening = false end)
end
function Window:Open()
    if self._menuOpen or self._tweening then return end
    self._tweening = true; self._menuOpen = true; self._mp.Position = UDim2.new(0.5, 0, 0.5, 0)
    self:_playIntro(); task.wait(0.5); self._tweening = false
end
function Window:Toggle() if self._menuOpen then self:Minimize() else self:Open() end end
function Window:Destroy()
    for _, c in ipairs(self._conns) do pcall(function() c:Disconnect() end) end
    if self._sg and self._sg.Parent then self._sg:Destroy() end
end

-- Tab/Section code omitted for brevity unless needed.
-- But the user wants a full working library.
-- I will just include the CreateTab and CreateSection implementations from the paste to be safe.
function Window:CreateTab(name)
    local tabIndex = #self._tabs + 1
    local t = setmetatable({}, Tab)
    t._window = self; t._name = name; t._index = tabIndex; t._orderCounter = 0

    local isFirst = (tabIndex == 1)
    local btn = Instance.new("TextButton")
    btn.Name = "Nav_" .. name
    btn.Size = UDim2.new(1, 0, 0, 42)
    btn.BackgroundColor3 = isFirst and Theme.ActiveTab or Theme.InactiveTab
    btn.BackgroundTransparency = isFirst and 0.2 or 0.8
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.LayoutOrder = tabIndex
    btn.AutoButtonColor = false
    btn.Parent = self._nc
    corner(btn, 10)

    local tl = Instance.new("TextLabel")
    tl.Size = UDim2.new(1, -20, 1, 0)
    tl.Position = UDim2.new(0, 20, 0, 0)
    tl.BackgroundTransparency = 1
    tl.Text = name
    tl.TextColor3 = isFirst and Theme.Text or Theme.TextSub
    tl.TextSize = 14
    tl.Font = Theme.Medium
    tl.TextXAlignment = Enum.TextXAlignment.Left
    tl.Parent = btn
    t._navBtn = btn; t._navLabel = tl

    local view = Instance.new("CanvasGroup")
    view.Name = name .. "View"
    view.Size = UDim2.new(1, 0, 1, 0)
    view.BackgroundTransparency = 1
    view.BorderSizePixel = 0
    view.GroupTransparency = isFirst and 0 or 1
    view.Visible = isFirst
    view.Parent = self._ca
    t._view = view

    local sf = Instance.new("ScrollingFrame")
    sf.Name = "Scroll"
    sf.Size = UDim2.new(1, -6, 1, 0)
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel = 0
    sf.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
    sf.ScrollBarThickness = 3
    sf.ScrollBarImageColor3 = Theme.Accent
    sf.ScrollBarImageTransparency = 0.5
    sf.Parent = view

    local wrapper = Instance.new("Frame")
    wrapper.Name = "Wrapper"
    wrapper.Size = UDim2.new(1, -18, 1, 0)
    wrapper.Position = UDim2.new(0, 12, 0, 0)
    wrapper.BackgroundTransparency = 1
    wrapper.Parent = sf

    local sfl = Instance.new("UIListLayout", wrapper)
    sfl.Padding = UDim.new(0, 10)
    sfl.SortOrder = Enum.SortOrder.LayoutOrder

    sfl:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sf.CanvasSize = UDim2.new(0, 0, 0, sfl.AbsoluteContentSize.Y + 15)
        wrapper.Size = UDim2.new(1, -18, 0, sfl.AbsoluteContentSize.Y + 15)
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
    local prev = self._activeTab; self._activeTab = targetTab
    TweenService:Create(prev._view, TI.TabOut, {Position = UDim2.new(0, -40, 0, 0), Size = UDim2.new(0.95, 0, 0.95, 0), GroupTransparency = 1}):Play()
    local targetY = 104 + (targetTab._index - 1) * 48
    TweenService:Create(self._ind, TI.Smooth, {Position = UDim2.new(0, 10, 0, targetY)}):Play()

    for _, t in ipairs(self._tabs) do
        local isTarget = (t == targetTab)
        TweenService:Create(t._navBtn, TI.HOut, {BackgroundColor3 = isTarget and Theme.ActiveTab or Theme.InactiveTab, BackgroundTransparency = isTarget and 0.2 or 0.8}):Play()
        TweenService:Create(t._navLabel, TI.HOut, {TextColor3 = isTarget and Theme.Text or Theme.TextSub}):Play()
    end
    task.wait(0.28); prev._view.Visible = false
    targetTab._view.Visible = true; targetTab._view.Position = UDim2.new(0, 40, 0, 0); targetTab._view.Size = UDim2.new(1.05, 0, 1.05, 0); targetTab._view.GroupTransparency = 1
    local fi = TweenService:Create(targetTab._view, TI.TabIn, {Position = UDim2.new(0,0,0,0), Size = UDim2.new(1,0,1,0), GroupTransparency = 0})
    fi:Play()
    fi.Completed:Connect(function() self._tweening = false end)
end

function Tab:CreateSection(name)
    local s = setmetatable({}, Section)
    s._tab = self; s._name = name; self._orderCounter = self._orderCounter + 1

    local sec = Instance.new("Frame")
    sec.Name = "Sec_" .. name:gsub(" ", "")
    sec.Size = UDim2.new(1, 0, 0, 30)
    sec.BackgroundTransparency = 1
    sec.LayoutOrder = self._orderCounter
    sec.Parent = self._scroll

    local title = Instance.new("TextLabel", sec)
    title.Size = UDim2.new(1, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = name:upper()
    title.TextColor3 = Theme.AccentGlow
    title.TextSize = 11
    title.Font = Theme.Bold
    title.TextXAlignment = Enum.TextXAlignment.Left

    local line = Instance.new("Frame", sec)
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 1, -1)
    line.BackgroundColor3 = Theme.AccentGlow
    line.BackgroundTransparency = 0.8
    line.BorderSizePixel = 0

    s._frame = sec
    return s
end

function Section:CreateButton(config)
    config = config or {}
    local name = config.Name or "Button"
    local callback = config.Callback or function() end

    self._tab._orderCounter = self._tab._orderCounter + 1
    local container = Instance.new("Frame")
    container.Name = "Btn_" .. name
    container.Size = UDim2.new(1, 0, 0, 42)
    container.BackgroundTransparency = 1
    container.LayoutOrder = self._tab._orderCounter
    container.Parent = self._tab._scroll

    local btn = Instance.new("TextButton", container)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.AnchorPoint = Vector2.new(0.5, 0.5)
    btn.Position = UDim2.new(0.5, 0, 0.5, 0)
    btn.BackgroundColor3 = Color3.fromRGB(35, 30, 65)
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = Theme.Text
    btn.Font = Theme.Bold
    btn.TextSize = 13
    btn.AutoButtonColor = false
    corner(btn, 10)
    local stroke = uistroke(btn, Color3.fromRGB(150, 100, 255), 1)
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual

    applyBouncy(btn, 1.04, 0.92)
    local ti = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    btn.MouseEnter:Connect(function() TweenService:Create(btn, ti, {BackgroundColor3 = Color3.fromRGB(60, 50, 100)}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn, ti, {BackgroundColor3 = Color3.fromRGB(35, 30, 65)}):Play() end)

    btn.MouseButton1Click:Connect(function()
        local orig = Color3.fromRGB(35, 30, 65)
        TweenService:Create(btn, TI.Click, {BackgroundColor3 = Color3.fromRGB(180, 140, 255)}):Play()
        task.wait(0.1)
        TweenService:Create(btn, TI.Spring, {BackgroundColor3 = orig}):Play()
        task.spawn(callback)
    end)

    return {_frame = container}
end

NexusLib:CreateKeySystem({
    Keys = {"TEST"},
    Callback = function()
        print("KEY SUCCESS! Loading the full Hub...")
        local Window = NexusLib:CreateWindow({
            Title = "NEXUS HUB",
            Subtitle = "Premium Version"
        })
        local Tab = Window:CreateTab("Main")
        local Section = Tab:CreateSection("Features")
        Section:CreateButton({
            Name = "Click Me",
            Callback = function()
                NexusLib:Notify({Title = "Test", Message = "Button Clicked!"})
            end
        })
    end
})
