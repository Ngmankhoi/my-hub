--[[
    ╔════════════════════════════════════════════════╗
    ║         NexusLib UI Library v1.0               ║
    ║     Premium Gojo Hollow Purple Theme           ║
    ║     by Nexus Gaming Hub                        ║
    ╚════════════════════════════════════════════════╝

    Usage:
        local NexusLib = loadstring(game:HttpGet("url"))()
        -- or in Studio: require(script.Parent.NexusLib)

        local Window = NexusLib:CreateWindow({
            Title = "My Hub",
            Subtitle = "v1.0",
            Keybind = Enum.KeyCode.RightShift
        })

        local Tab = Window:CreateTab("Modules")
        local Section = Tab:CreateSection("Character")

        Section:CreateToggle({ Name = "Fly", Default = false, Callback = function(v) end })
        Section:CreateSlider({ Name = "Speed", Min = 16, Max = 200, Default = 16, Callback = function(v) end })
        Section:CreateDropdown({ Name = "Zone", Options = {"A","B"}, Callback = function(v) end })
        Section:CreateButton({ Name = "Execute", Callback = function() end })
        Section:CreateTextbox({ Name = "Player", Placeholder = "Username...", Callback = function(v) end })
        Section:CreateLabel("Status: Ready")

        NexusLib:Notify({ Title = "Hello", Message = "Welcome!", Duration = 5 })
]]

-- ═══════════════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════════════
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer
local guiParent = RunService:IsStudio()
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
local NexusLib = {}

-- ═══════════════════════════════════════════════════
-- NOTIFICATION SYSTEM
-- ═══════════════════════════════════════════════════
function NexusLib:Notify(config)
    config = config or {}
    local title = config.Title or "Notification"
    local message = config.Message or ""
    local duration = config.Duration or 5

    if not self._notifContainer or not self._notifContainer.Parent then return end

    local notif = Instance.new("CanvasGroup")
    notif.Name = "Notification"
    notif.Size = UDim2.new(1, 0, 0, 0)
    notif.BackgroundTransparency = 1
    notif.BorderSizePixel = 0
    notif.GroupTransparency = 1
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
    strokeGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 240, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(180, 50, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 30, 120))
    })
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
    logoGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 160, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 40, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 40, 100))
    })
    logoGrad.Rotation = 45

    local function createMiniN(parent)
        local nContainer = Instance.new("Frame")
        nContainer.Size = UDim2.new(1, 0, 1, 0)
        nContainer.BackgroundTransparency = 1
        nContainer.Parent = parent

        local l = Instance.new("Frame", nContainer)
        l.Size = UDim2.new(0, 4, 0, 16)
        l.Position = UDim2.new(0.5, -6, 0.5, 0)
        l.AnchorPoint = Vector2.new(0.5, 0.5)
        l.BackgroundColor3 = Color3.new(1, 1, 1)
        l.BorderSizePixel = 0
        Instance.new("UICorner", l).CornerRadius = UDim.new(1, 0)

        local r = Instance.new("Frame", nContainer)
        r.Size = UDim2.new(0, 4, 0, 16)
        r.Position = UDim2.new(0.5, 6, 0.5, 0)
        r.AnchorPoint = Vector2.new(0.5, 0.5)
        r.BackgroundColor3 = Color3.new(1, 1, 1)
        r.BorderSizePixel = 0
        Instance.new("UICorner", r).CornerRadius = UDim.new(1, 0)

        local d = Instance.new("Frame", nContainer)
        d.Size = UDim2.new(0, 4, 0, 18)
        d.Position = UDim2.new(0.5, 0, 0.5, 0)
        d.AnchorPoint = Vector2.new(0.5, 0.5)
        d.Rotation = -35
        d.BackgroundColor3 = Color3.new(1, 1, 1)
        d.BorderSizePixel = 0
        Instance.new("UICorner", d).CornerRadius = UDim.new(1, 0)
    end
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
    progressGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 240, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 30, 120))
    })

    notif.Parent = self._notifContainer

    -- Tilt Entrance Animation
    notif.Rotation = 8

    local expandTween = TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = targetSize})
    expandTween:Play()
    task.wait(0.12)

    local slideTween = TweenService:Create(inner, TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)})
    slideTween:Play()

    TweenService:Create(notif, TweenInfo.new(0.68, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {Rotation = 0}):Play()
    TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {GroupTransparency = 0}):Play()

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
        TweenService:Create(notif, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Rotation = -10,
            GroupTransparency = 1
        }):Play()

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
-- WINDOW : CreateWindow
-- ═══════════════════════════════════════════════════
function NexusLib:CreateWindow(config)
    config = config or {}
    local title = config.Title or "NEXUS"
    local subtitle = config.Subtitle or "GAMING HUB"
    local keybind = config.Keybind or Enum.KeyCode.RightShift

    -- Cleanup previous
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

    -- ScreenGui
    local sg = Instance.new("ScreenGui")
    sg.Name = "NexusLib"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.IgnoreGuiInset = true
    sg.Parent = guiParent
    w._sg = sg
    self._screenGui = sg

    -- Mobile Toggle Button (Hollow Purple orb)
    local mob = Instance.new("TextButton")
    mob.Name = "MobileBtn"
    mob.Size = UDim2.new(0, 50, 0, 50)
    mob.Position = UDim2.new(0, 20, 0.5, -25)
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

    -- Main Panel
    local mp = Instance.new("Frame")
    mp.Name = "MainPanel"
    mp.Size = UDim2.new(0, 750, 0, 480)
    mp.Position = UDim2.new(0.5, 0, 0.5, 0)
    mp.AnchorPoint = Vector2.new(0.5, 0.5)
    mp.BackgroundColor3 = Theme.Background
    mp.BackgroundTransparency = Theme.PanelTransparency
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
    w._mp = mp

    -- Sidebar
    local sb = Instance.new("Frame")
    sb.Name = "Sidebar"
    sb.Size = UDim2.new(0, 200, 1, 0)
    sb.BackgroundColor3 = Theme.SidebarBg
    sb.BackgroundTransparency = 0.3
    sb.BorderSizePixel = 0
    sb.Parent = mp
    corner(sb, 20)
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

    -- Nav Container
    local nc = Instance.new("Frame")
    nc.Name = "NavContainer"
    nc.Size = UDim2.new(1, -20, 1, -110)
    nc.Position = UDim2.new(0, 10, 0, 95)
    nc.BackgroundTransparency = 1
    nc.Parent = sb
    Instance.new("UIListLayout", nc).Padding = UDim.new(0, 6)
    nc:FindFirstChildOfClass("UIListLayout").SortOrder = Enum.SortOrder.LayoutOrder
    w._nc = nc

    -- Active Indicator
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

    -- Content Area
    local ca = Instance.new("Frame")
    ca.Name = "ContentArea"
    ca.Size = UDim2.new(1, -215, 1, -30)
    ca.Position = UDim2.new(0, 210, 0, 15)
    ca.BackgroundTransparency = 1
    ca.ZIndex = 1
    ca.Parent = mp
    w._ca = ca

    -- Close Button
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

    -- Minimize Button
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

    -- Notification Container
    local ncon = Instance.new("Frame")
    ncon.Name = "NotifContainer"
    ncon.Size = UDim2.new(0, 320, 0, 400)
    ncon.Position = UDim2.new(1, -340, 1, -420)
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

    -- ═══════ DRAGGING ═══════
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil

    local function updateDrag(input)
        local delta = input.Position - dragStart
        TweenService:Create(mp, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
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
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    table.insert(w._conns, UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then updateDrag(input) end
    end))

    -- ═══════ ROTATION ANIMATIONS ═══════
    local swirlSpeed = 100
    table.insert(w._conns, RunService.RenderStepped:Connect(function(dt)
        if mobRing and mobRing.Parent then mobRing.Rotation = mobRing.Rotation + swirlSpeed * dt end
        if logoRing and logoRing.Parent then logoRing.Rotation = logoRing.Rotation + swirlSpeed * dt end
    end))

    -- ═══════ SHIMMER ═══════
    TweenService:Create(mpStroke, TI.Shimmer, {Color = Color3.fromRGB(80, 120, 255)}):Play()

    -- ═══════ BUTTON HANDLERS ═══════
    local origSizes = {
        cb = UDim2.new(0, 32, 0, 32),
        minb = UDim2.new(0, 32, 0, 32),
        mob = UDim2.new(0, 50, 0, 50)
    }

    -- Close (destroy)
    cb.MouseButton1Click:Connect(function()
        if w._tweening then return end
        w._tweening = true
        mp.ClipsDescendants = true
        local t = TweenService:Create(mp, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0,0,0,0), BackgroundTransparency = 1
        })
        TweenService:Create(mob, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0,0,0,0), BackgroundTransparency = 1
        }):Play()
        t:Play()
        t.Completed:Connect(function() sg:Destroy() end)
    end)
    applyBouncy(cb, 1.1, 0.85, origSizes.cb)
    cb.MouseEnter:Connect(function() TweenService:Create(cb, TI.HIn, {BackgroundColor3 = Theme.CloseHover, TextColor3 = Color3.new(1,1,1)}):Play() end)
    cb.MouseLeave:Connect(function() TweenService:Create(cb, TI.HOut, {BackgroundColor3 = Color3.fromRGB(60,40,100), TextColor3 = Color3.fromRGB(180,160,220)}):Play() end)

    -- Minimize
    minb.MouseButton1Click:Connect(function() w:Minimize() end)
    applyBouncy(minb, 1.1, 0.85, origSizes.minb)
    minb.MouseEnter:Connect(function() TweenService:Create(minb, TI.HIn, {BackgroundColor3 = Theme.MinHover, BackgroundTransparency = 0.2}):Play() end)
    minb.MouseLeave:Connect(function() TweenService:Create(minb, TI.HOut, {BackgroundColor3 = Color3.fromRGB(60,40,100), BackgroundTransparency = 0.5}):Play() end)

    -- Mobile toggle
    mob.MouseButton1Click:Connect(function() w:Toggle() end)
    applyBouncy(mob, 1.1, 0.85, origSizes.mob)

    -- ═══════ KEYBIND ═══════
    table.insert(w._conns, UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == keybind then w:Toggle() end
    end))

    -- ═══════ INTRO ═══════
    task.defer(function()
        task.wait(0.1)
        w:_playIntro()
        task.wait(1)
        NexusLib:Notify({Title = title .. " Premium", Message = "UI Library loaded successfully!", Duration = 5})
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
    mp.Size = UDim2.new(0, 10, 0, 10)
    mp.Rotation = -15
    mp.BackgroundTransparency = 1

    local ps = mp:FindFirstChildOfClass("UIStroke")
    if ps then ps.Transparency = 1 end

    sb.Position = UDim2.new(-0.3, 0, 0, 0)
    sb.BackgroundTransparency = 1

    if self._activeTab then
        self._activeTab._view.GroupTransparency = 1
    end

    cb.Size = UDim2.new(0,0,0,0); cb.BackgroundTransparency = 1
    minb.Size = UDim2.new(0,0,0,0); minb.BackgroundTransparency = 1

    local pt = TweenService:Create(mp, TI.IPanel, {
        Size = UDim2.new(0, 750, 0, 480), Rotation = 0, BackgroundTransparency = 0.15
    })
    pt:Play()

    if ps then TweenService:Create(ps, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency = 0.5}):Play() end

    pt.Completed:Connect(function()
        mp.ClipsDescendants = false

        TweenService:Create(sb, TI.ISide, {Position = UDim2.new(0,0,0,0), BackgroundTransparency = 0.3}):Play()
        task.wait(0.1)

        if self._activeTab then
            local av = self._activeTab._view
            av.Position = UDim2.new(0, 30, 0, 0)
            av.Size = UDim2.new(1.05, 0, 1.05, 0)
            TweenService:Create(av, TI.ICont, {
                Position = UDim2.new(0,0,0,0), Size = UDim2.new(1,0,1,0), GroupTransparency = 0
            }):Play()
        end

        -- Cascade nav buttons
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
    self._tweening = true
    self._menuOpen = false
    self._mp.ClipsDescendants = true

    TweenService:Create(self._mp, TI.Antic, {Size = UDim2.new(0, 770, 0, 490)}):Play()
    task.wait(0.1)

    local ct = TweenService:Create(self._mp, TI.Close, {
        Size = UDim2.new(0, 200, 0, 120),
        Position = UDim2.new(0.5, 0, 0.8, 80),
        BackgroundTransparency = 1
    })
    ct:Play()

    local ps = self._mp:FindFirstChildOfClass("UIStroke")
    if ps then TweenService:Create(ps, TI.Close, {Transparency = 1}):Play() end

    ct.Completed:Connect(function()
        self._mp.Visible = false
        self._tweening = false
    end)
end

function Window:Open()
    if self._menuOpen or self._tweening then return end
    self._tweening = true
    self._menuOpen = true
    self._mp.Position = UDim2.new(0.5, 0, 0.5, 0)
    self:_playIntro()
    task.wait(0.5)
    self._tweening = false
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

    -- Nav Button
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
    sf.ScrollBarThickness = 3
    sf.ScrollBarImageColor3 = Theme.Accent
    sf.ScrollBarImageTransparency = 0.5
    sf.Parent = view

    local sfl = Instance.new("UIListLayout", sf)
    sfl.Padding = UDim.new(0, 10)
    sfl.SortOrder = Enum.SortOrder.LayoutOrder

    sfl:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sf.CanvasSize = UDim2.new(0, 0, 0, sfl.AbsoluteContentSize.Y + 15)
    end)
    t._scroll = sf

    -- Tab switching
    btn.MouseButton1Click:Connect(function()
        self:_switchTab(t)
    end)
    applyBouncy(btn, 1.03, 0.95)

    table.insert(self._tabs, t)

    if isFirst then
        self._activeTab = t
    end

    return t
end

function Window:_switchTab(targetTab)
    if not targetTab or targetTab == self._activeTab or self._tweening then return end
    self._tweening = true

    local prev = self._activeTab
    self._activeTab = targetTab

    -- Fade out previous
    TweenService:Create(prev._view, TI.TabOut, {
        Position = UDim2.new(0, -40, 0, 0),
        Size = UDim2.new(0.95, 0, 0.95, 0),
        GroupTransparency = 1
    }):Play()

    -- Move indicator
    local targetY = 104 + (targetTab._index - 1) * 48
    TweenService:Create(self._ind, TI.Smooth, {Position = UDim2.new(0, 10, 0, targetY)}):Play()

    -- Update nav button colors
    for _, t in ipairs(self._tabs) do
        local isTarget = (t == targetTab)
        TweenService:Create(t._navBtn, TI.HOut, {
            BackgroundColor3 = isTarget and Theme.ActiveTab or Theme.InactiveTab,
            BackgroundTransparency = isTarget and 0.2 or 0.8
        }):Play()
        TweenService:Create(t._navLabel, TI.HOut, {
            TextColor3 = isTarget and Theme.Text or Theme.TextSub
        }):Play()
    end

    task.wait(0.28)
    prev._view.Visible = false

    -- Fade in target
    targetTab._view.Visible = true
    targetTab._view.Position = UDim2.new(0, 40, 0, 0)
    targetTab._view.Size = UDim2.new(1.05, 0, 1.05, 0)
    targetTab._view.GroupTransparency = 1

    local fi = TweenService:Create(targetTab._view, TI.TabIn, {
        Position = UDim2.new(0,0,0,0), Size = UDim2.new(1,0,1,0), GroupTransparency = 0
    })
    fi:Play()
    fi.Completed:Connect(function() self._tweening = false end)
end

-- ═══════════════════════════════════════════════════
-- SECTION
-- ═══════════════════════════════════════════════════
function Tab:CreateSection(name)
    local s = setmetatable({}, Section)
    s._tab = self
    s._name = name

    self._orderCounter = self._orderCounter + 1

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

-- ═══════════════════════════════════════════════════
-- COMPONENTS
-- ═══════════════════════════════════════════════════

-- Helper: Create component container frame
local function compFrame(section, name)
    section._tab._orderCounter = section._tab._orderCounter + 1

    local f = Instance.new("Frame")
    f.Name = name or "Component"
    f.Size = UDim2.new(1, 0, 0, 50)
    f.BackgroundColor3 = Theme.CardBg
    f.BackgroundTransparency = Theme.CardTransparency
    f.BorderSizePixel = 0
    f.LayoutOrder = section._tab._orderCounter
    f.Parent = section._tab._scroll
    corner(f, 10)
    uistroke(f, Theme.StrokeCard)
    return f
end

local function compLabel(parent, text)
    local l = Instance.new("TextLabel", parent)
    l.Name = "Label"
    l.Size = UDim2.new(0.5, 0, 1, 0)
    l.Position = UDim2.new(0, 15, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Theme.Text
    l.TextSize = 13
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
    track.Size = UDim2.new(0, 36, 0, 20)
    track.Position = UDim2.new(1, -56, 0.5, -10)
    track.BackgroundColor3 = default and Theme.ToggleOn or Theme.ToggleOff
    track.BorderSizePixel = 0
    track.Text = ""
    track.AutoButtonColor = false
    corner(track, UDim.new(1, 0))
    uistroke(track, Theme.ToggleStroke, 1.2)

    local thumb = Instance.new("Frame", track)
    thumb.Name = "Thumb"
    thumb.Size = UDim2.new(0, 14, 0, 14)
    thumb.Position = UDim2.new(0, default and 19 or 3, 0.5, -7)
    thumb.BackgroundColor3 = Color3.new(1, 1, 1)
    thumb.BorderSizePixel = 0
    corner(thumb, UDim.new(1, 0))

    local function set(state, fire)
        toggle._state = state
        TweenService:Create(thumb, TI.Spring, {Position = UDim2.new(0, state and 19 or 3, 0.5, -7)}):Play()
        TweenService:Create(track, TI.HIn, {BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff}):Play()
        if fire ~= false then
            task.spawn(callback, state)
        end
    end

    track.MouseButton1Click:Connect(function()
        local sq = TweenService:Create(track, TI.Click, {Size = UDim2.new(0, 32, 0, 18)})
        sq:Play()
        sq.Completed:Connect(function()
            TweenService:Create(track, TI.Spring, {Size = UDim2.new(0, 36, 0, 20)}):Play()
        end)
        set(not toggle._state)
    end)

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

    local track = Instance.new("Frame", f)
    track.Name = "Track"
    track.Size = UDim2.new(0, 180, 0, 6)
    track.Position = UDim2.new(1, -200, 0.5, -3)
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

    local handle = Instance.new("TextButton", track)
    handle.Name = "Handle"
    handle.Size = UDim2.new(0, 16, 0, 16)
    handle.Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8)
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
        handle.Position = UDim2.new(pct, -8, 0.5, -8)
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
            TweenService:Create(handle, TI.HIn, {Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(handle.Position.X.Scale, -9, 0.5, -9)}):Play()
        end
    end)

    table.insert(self._tab._window._conns, UserInputService.InputEnded:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and active then
            active = false
            TweenService:Create(handle, TI.HOut, {Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(fill.Size.X.Scale, -8, 0.5, -8)}):Play()
        end
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
    compLabel(f, name)

    local header = Instance.new("TextButton", f)
    header.Name = "Header"
    header.Size = UDim2.new(0, 150, 0, 32)
    header.Position = UDim2.new(1, -170, 0.5, -16)
    header.BackgroundColor3 = Theme.DropBg
    header.Text = default or "Select... v"
    header.TextColor3 = Theme.Text
    header.Font = Theme.Bold
    header.TextSize = 11
    header.AutoButtonColor = false
    corner(header, 8)
    uistroke(header, Theme.DropStroke, 1)

    local ddList = Instance.new("Frame", f)
    ddList.Name = "List"
    ddList.Size = UDim2.new(0, 150, 0, 0)
    ddList.Position = UDim2.new(1, -170, 0, 42)
    ddList.BackgroundColor3 = Color3.fromRGB(22, 18, 40)
    ddList.BorderSizePixel = 0
    ddList.ZIndex = 10
    ddList.Visible = false
    corner(ddList, 8)
    uistroke(ddList, Theme.DropStroke, 1)
    Instance.new("UIListLayout", ddList).Padding = UDim.new(0, 4)

    local function setOpen(state)
        dropdown._isOpen = state
        ddList.Visible = true
        local h = state and (#options * 34) or 0
        local tw = TweenService:Create(ddList, TI.HIn, {Size = UDim2.new(0, 150, 0, h)})
        tw:Play()
        tw.Completed:Connect(function() if not dropdown._isOpen then ddList.Visible = false end end)
        header.Text = state and ((dropdown._selected or "Select...") .. " ^") or ((dropdown._selected or "Select...") .. " v")
    end

    local function populateOptions(opts)
        for _, c in ipairs(ddList:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        for i, optName in ipairs(opts) do
            local ob = Instance.new("TextButton", ddList)
            ob.Name = "Opt_" .. i
            ob.Size = UDim2.new(1, 0, 0, 30)
            ob.BackgroundColor3 = Theme.DropOpt
            ob.BackgroundTransparency = 0.5
            ob.BorderSizePixel = 0
            ob.Text = optName
            ob.TextColor3 = Color3.fromRGB(200, 190, 230)
            ob.Font = Theme.Medium
            ob.TextSize = 11
            ob.ZIndex = 11
            ob.AutoButtonColor = false
            corner(ob, 6)

            ob.MouseEnter:Connect(function() TweenService:Create(ob, TI.HIn, {BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.2}):Play() end)
            ob.MouseLeave:Connect(function() TweenService:Create(ob, TI.HOut, {BackgroundColor3 = Theme.DropOpt, BackgroundTransparency = 0.5}):Play() end)
            ob.MouseButton1Click:Connect(function()
                dropdown._selected = optName
                setOpen(false)
                header.Text = optName .. " v"
                task.spawn(callback, optName)
            end)
        end
    end

    populateOptions(options)

    header.MouseButton1Click:Connect(function()
        local sq = TweenService:Create(header, TI.Click, {Size = UDim2.new(0, 144, 0, 30)})
        sq:Play()
        sq.Completed:Connect(function() TweenService:Create(header, TI.Spring, {Size = UDim2.new(0, 150, 0, 32)}):Play() end)
        setOpen(not dropdown._isOpen)
    end)

    function dropdown:Set(opt) dropdown._selected = opt; header.Text = opt .. " v"; task.spawn(callback, opt) end
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

    local btn = Instance.new("TextButton")
    btn.Name = "Btn_" .. name
    btn.Size = UDim2.new(1, 0, 0, 42)
    btn.BackgroundColor3 = Color3.fromRGB(120, 70, 255)
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = Theme.Text
    btn.Font = Theme.Bold
    btn.TextSize = 13
    btn.AutoButtonColor = false
    btn.LayoutOrder = self._tab._orderCounter
    btn.Parent = self._tab._scroll
    corner(btn, 10)

    local bg = Instance.new("UIGradient", btn)
    bg.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 80, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(90, 40, 210))
    })
    bg.Rotation = 90

    applyBouncy(btn, 1.04, 0.92)

    btn.MouseButton1Click:Connect(function()
        -- Flash effect
        local orig = btn.BackgroundColor3
        TweenService:Create(btn, TI.Click, {BackgroundColor3 = Color3.new(1, 1, 1)}):Play()
        task.wait(0.1)
        TweenService:Create(btn, TI.Spring, {BackgroundColor3 = orig}):Play()
        task.spawn(callback)
    end)

    return {_frame = btn}
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

    local input = Instance.new("TextBox", f)
    input.Name = "Input"
    input.Size = UDim2.new(0, 170, 0, 30)
    input.Position = UDim2.new(1, -190, 0.5, -15)
    input.BackgroundColor3 = Color3.fromRGB(25, 20, 48)
    input.BorderSizePixel = 0
    input.Text = default
    input.PlaceholderText = placeholder
    input.PlaceholderColor3 = Color3.fromRGB(80, 70, 110)
    input.TextColor3 = Theme.Text
    input.TextSize = 12
    input.Font = Theme.Medium
    input.ClearTextOnFocus = false
    input.Parent = f
    corner(input, 8)
    uistroke(input, Theme.StrokeCard, 1)

    input.Focused:Connect(function()
        TweenService:Create(input:FindFirstChildOfClass("UIStroke"), TI.HIn, {Color = Theme.Accent}):Play()
    end)
    input.FocusLost:Connect(function(enterPressed)
        TweenService:Create(input:FindFirstChildOfClass("UIStroke"), TI.HOut, {Color = Theme.StrokeCard}):Play()
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
    f.Size = UDim2.new(1, 0, 0, 30)
    f.BackgroundTransparency = 1
    f.LayoutOrder = self._tab._orderCounter
    f.Parent = self._tab._scroll

    local tl = Instance.new("TextLabel", f)
    tl.Size = UDim2.new(1, -10, 1, 0)
    tl.Position = UDim2.new(0, 5, 0, 0)
    tl.BackgroundTransparency = 1
    tl.Text = text or ""
    tl.TextColor3 = Theme.TextSub
    tl.TextSize = 12
    tl.Font = Theme.Medium
    tl.TextXAlignment = Enum.TextXAlignment.Left

    local label = {}
    function label:Set(newText) tl.Text = newText end
    label._frame = f

    return label
end

-- ─────────── DASHBOARD COMPONENTS ───────────

function Tab:CreateHeader(config)
    config = config or {}
    local title = config.Title or "Welcome"
    local subtitle = config.Subtitle or ""
    
    self._orderCounter = self._orderCounter + 1
    local f = Instance.new("Frame")
    f.Name = "Header"
    f.Size = UDim2.new(1, 0, 0, 50)
    f.BackgroundTransparency = 1
    f.LayoutOrder = self._orderCounter
    f.Parent = self._scroll

    local tl = Instance.new("TextLabel", f)
    tl.Size = UDim2.new(1, -10, 0, 25)
    tl.Position = UDim2.new(0, 5, 0, 0)
    tl.BackgroundTransparency = 1
    tl.Text = title
    tl.TextColor3 = Theme.Text
    tl.TextSize = 22
    tl.Font = Theme.Bold
    tl.TextXAlignment = Enum.TextXAlignment.Left

    local sl = Instance.new("TextLabel", f)
    sl.Size = UDim2.new(1, -10, 0, 20)
    sl.Position = UDim2.new(0, 5, 0, 25)
    sl.BackgroundTransparency = 1
    sl.Text = subtitle
    sl.TextColor3 = Theme.TextSub
    sl.TextSize = 13
    sl.Font = Theme.Medium
    sl.TextXAlignment = Enum.TextXAlignment.Left

    return {_frame = f}
end

function Tab:CreateStatRow(stats)
    self._orderCounter = self._orderCounter + 1
    local f = Instance.new("Frame")
    f.Name = "StatRow"
    f.Size = UDim2.new(1, 0, 0, 80)
    f.BackgroundTransparency = 1
    f.LayoutOrder = self._orderCounter
    f.Parent = self._scroll

    local ll = Instance.new("UIListLayout", f)
    ll.FillDirection = Enum.FillDirection.Horizontal
    ll.SortOrder = Enum.SortOrder.LayoutOrder
    ll.Padding = UDim.new(0, 10)

    local count = #stats
    local width = (1 / count)
    local offset = (count - 1) * 10 / count

    for i, stat in ipairs(stats) do
        local sf = Instance.new("Frame", f)
        sf.Name = "Stat_" .. i
        sf.Size = UDim2.new(width, -offset, 1, 0)
        sf.BackgroundColor3 = Theme.CardBg
        sf.BackgroundTransparency = Theme.CardTransparency
        sf.BorderSizePixel = 0
        corner(sf, 10)
        uistroke(sf, stat.Color or Theme.StrokeCard, 1)

        local val = Instance.new("TextLabel", sf)
        val.Size = UDim2.new(1, 0, 0.6, 0)
        val.Position = UDim2.new(0, 0, 0, 0)
        val.BackgroundTransparency = 1
        val.Text = stat.Value or "0"
        val.TextColor3 = Theme.Text
        val.TextSize = 20
        val.Font = Theme.Bold
        val.TextXAlignment = Enum.TextXAlignment.Center
        val.TextYAlignment = Enum.TextYAlignment.Bottom

        local title = Instance.new("TextLabel", sf)
        title.Size = UDim2.new(1, 0, 0.4, 0)
        title.Position = UDim2.new(0, 0, 0.6, 0)
        title.BackgroundTransparency = 1
        title.Text = stat.Name or stat.Title or "Stat"
        title.TextColor3 = Theme.TextSub
        title.TextSize = 12
        title.Font = Theme.Medium
        title.TextXAlignment = Enum.TextXAlignment.Center
        title.TextYAlignment = Enum.TextYAlignment.Center
    end

    return {_frame = f}
end

function Tab:CreateFeaturedCard(config)
    config = config or {}
    local title = config.Title or "Featured"
    local desc = config.Description or ""
    local btnText = config.ButtonText or "PLAY NOW"
    local callback = config.Callback or function() end

    self._orderCounter = self._orderCounter + 1
    local f = Instance.new("Frame")
    f.Name = "FeaturedCard"
    f.Size = UDim2.new(1, 0, 0, 160)
    f.BackgroundColor3 = Theme.CardBg
    f.BackgroundTransparency = Theme.CardTransparency
    f.BorderSizePixel = 0
    f.LayoutOrder = self._orderCounter
    f.Parent = self._scroll
    corner(f, 10)
    uistroke(f, Theme.StrokeCard, 1)

    local tag = Instance.new("TextLabel", f)
    tag.Size = UDim2.new(0, 80, 0, 20)
    tag.Position = UDim2.new(0, 15, 0, 15)
    tag.BackgroundColor3 = Theme.ToggleOff
    tag.BorderSizePixel = 0
    tag.Text = "FEATURED"
    tag.TextColor3 = Theme.TextMuted
    tag.TextSize = 10
    tag.Font = Theme.Bold
    corner(tag, 4)

    local tl = Instance.new("TextLabel", f)
    tl.Size = UDim2.new(0.6, 0, 0, 25)
    tl.Position = UDim2.new(0, 15, 0, 40)
    tl.BackgroundTransparency = 1
    tl.Text = title
    tl.TextColor3 = Theme.Text
    tl.TextSize = 18
    tl.Font = Theme.Bold
    tl.TextXAlignment = Enum.TextXAlignment.Left

    local sl = Instance.new("TextLabel", f)
    sl.Size = UDim2.new(0.6, 0, 0, 40)
    sl.Position = UDim2.new(0, 15, 0, 65)
    sl.BackgroundTransparency = 1
    sl.Text = desc
    sl.TextColor3 = Theme.TextSub
    sl.TextSize = 12
    sl.Font = Theme.Medium
    sl.TextWrapped = true
    sl.TextXAlignment = Enum.TextXAlignment.Left
    sl.TextYAlignment = Enum.TextYAlignment.Top

    local btn = Instance.new("TextButton", f)
    btn.Size = UDim2.new(0, 120, 0, 32)
    btn.Position = UDim2.new(0, 15, 0, 115)
    btn.BackgroundColor3 = Theme.Accent
    btn.BorderSizePixel = 0
    btn.Text = btnText
    btn.TextColor3 = Theme.Text
    btn.Font = Theme.Bold
    btn.TextSize = 12
    btn.AutoButtonColor = false
    corner(btn, 8)
    applyBouncy(btn, 1.05, 0.95)
    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn, TI.Click, {BackgroundColor3 = Color3.new(1,1,1)}):Play()
        task.wait(0.1)
        TweenService:Create(btn, TI.Spring, {BackgroundColor3 = Theme.Accent}):Play()
        task.spawn(callback)
    end)

    -- Decorative Diamond
    local dec = Instance.new("Frame", f)
    dec.Size = UDim2.new(0, 60, 0, 60)
    dec.Position = UDim2.new(1, -70, 0.5, 0)
    dec.AnchorPoint = Vector2.new(0.5, 0.5)
    dec.BackgroundTransparency = 1
    dec.Rotation = 15
    local decS = uistroke(dec, Theme.AccentGlow, 1, 0.5)
    
    local dec2 = Instance.new("Frame", dec)
    dec2.Size = UDim2.new(0, 45, 0, 45)
    dec2.Position = UDim2.new(0.5, 0, 0.5, 0)
    dec2.AnchorPoint = Vector2.new(0.5, 0.5)
    dec2.BackgroundTransparency = 1
    dec2.Rotation = -30
    uistroke(dec2, Theme.AccentBlue, 1, 0.6)

    local dec3 = Instance.new("Frame", dec2)
    dec3.Size = UDim2.new(0, 15, 0, 15)
    dec3.Position = UDim2.new(0.5, 0, 0.5, 0)
    dec3.AnchorPoint = Vector2.new(0.5, 0.5)
    dec3.BackgroundColor3 = Color3.new(1,1,1)
    dec3.BorderSizePixel = 0
    corner(dec3, 2)

    task.spawn(function()
        while f.Parent do
            TweenService:Create(dec, TweenInfo.new(10, Enum.EasingStyle.Linear), {Rotation = dec.Rotation + 360}):Play()
            TweenService:Create(dec2, TweenInfo.new(8, Enum.EasingStyle.Linear), {Rotation = dec2.Rotation - 360}):Play()
            task.wait(8)
        end
    end)

    return {_frame = f}
end

function Tab:CreateActionRow(actions)
    self._orderCounter = self._orderCounter + 1
    local f = Instance.new("Frame")
    f.Name = "ActionRow"
    f.Size = UDim2.new(1, 0, 0, 90)
    f.BackgroundTransparency = 1
    f.LayoutOrder = self._orderCounter
    f.Parent = self._scroll

    local ll = Instance.new("UIListLayout", f)
    ll.FillDirection = Enum.FillDirection.Horizontal
    ll.SortOrder = Enum.SortOrder.LayoutOrder
    ll.Padding = UDim.new(0, 10)

    local count = #actions
    local width = (1 / count)
    local offset = (count - 1) * 10 / count

    for i, act in ipairs(actions) do
        local btn = Instance.new("TextButton", f)
        btn.Name = "Action_" .. i
        btn.Size = UDim2.new(width, -offset, 1, 0)
        btn.BackgroundColor3 = Theme.CardBg
        btn.BackgroundTransparency = Theme.CardTransparency
        btn.BorderSizePixel = 0
        btn.Text = ""
        btn.AutoButtonColor = false
        corner(btn, 10)
        uistroke(btn, Theme.StrokeCard, 1)

        local colorBar = Instance.new("Frame", btn)
        colorBar.Size = UDim2.new(0.6, 0, 0, 3)
        colorBar.Position = UDim2.new(0.2, 0, 0, 0)
        colorBar.BackgroundColor3 = act.Color or Theme.Accent
        colorBar.BorderSizePixel = 0
        corner(colorBar, 1)

        local label = Instance.new("TextLabel", btn)
        label.Size = UDim2.new(1, 0, 1, -10)
        label.Position = UDim2.new(0, 0, 0, 10)
        label.BackgroundTransparency = 1
        label.Text = act.Name or "Action"
        label.TextColor3 = Theme.TextSub
        label.TextSize = 12
        label.Font = Theme.Medium
        label.TextWrapped = true

        applyBouncy(btn, 1.05, 0.95)
        btn.MouseButton1Click:Connect(function()
            TweenService:Create(btn, TI.Click, {BackgroundColor3 = Theme.ToggleOff}):Play()
            task.wait(0.1)
            TweenService:Create(btn, TI.Spring, {BackgroundColor3 = Theme.CardBg}):Play()
            if act.Callback then task.spawn(act.Callback) end
        end)
        btn.MouseEnter:Connect(function() TweenService:Create(label, TI.HIn, {TextColor3 = Theme.Text}):Play() end)
        btn.MouseLeave:Connect(function() TweenService:Create(label, TI.HOut, {TextColor3 = Theme.TextSub}):Play() end)
    end

    return {_frame = f}
end

-- ═══════════════════════════════════════════════════
-- DESTROY ALL
-- ═══════════════════════════════════════════════════
function NexusLib:DestroyAll()
    if self._screenGui and self._screenGui.Parent then
        self._screenGui:Destroy()
    end
    if self._connections then
        for _, c in ipairs(self._connections) do pcall(function() c:Disconnect() end) end
    end
end


--[[
    NexusLib Example Usage
    Demonstrates how to use NexusLib UI Library
    
    For Roblox Studio: Place NexusLib.lua as ModuleScript, then require() it
    For Executors: loadstring the NexusLib source, then use this code
]]

-- In Studio, use: local NexusLib = require(path.to.NexusLib)
-- In Executor, use: local NexusLib = loadstring(game:HttpGet("url"))()
-- For testing, we'll require directly:
local NexusLib = require(script.Parent:WaitForChild("NexusLib"))

-- ═══════════════════════════════════════════
-- 1. CREATE WINDOW
-- ═══════════════════════════════════════════
local Window = NexusLib:CreateWindow({
    Title = "Nexus",
    Subtitle = "Gaming Hub",
    Keybind = Enum.KeyCode.RightShift  -- Press RightShift to toggle menu
})

-- ═══════════════════════════════════════════
-- 2. CREATE TABS
-- ═══════════════════════════════════════════
local HomeTab = Window:CreateTab("Home")
local ModulesTab = Window:CreateTab("Modules")
local SettingsTab = Window:CreateTab("Settings")

-- ═══════════════════════════════════════════
-- 3. HOME TAB (DASHBOARD)
-- ═══════════════════════════════════════════
HomeTab:CreateHeader({
    Title = "Welcome back, Player!",
    Subtitle = "Ready for your next adventure?"
})

HomeTab:CreateStatRow({
    {Title = "Level", Value = "47", Color = Color3.fromRGB(150, 80, 255)},
    {Title = "Coins", Value = "12,450", Color = Color3.fromRGB(255, 180, 50)},
    {Title = "Wins", Value = "286", Color = Color3.fromRGB(0, 160, 255)}
})

HomeTab:CreateFeaturedCard({
    Title = "Season 5: Cosmic Rift",
    Description = "Explore the Cosmic Rift and unlock exclusive rewards.",
    ButtonText = "PLAY NOW",
    Callback = function()
        NexusLib:Notify({Title = "Play", Message = "Teleporting to Cosmic Rift...", Duration = 3})
    end
})

HomeTab:CreateActionRow({
    {Name = "Daily Rewards", Color = Color3.fromRGB(255, 80, 80), Callback = function() end},
    {Name = "Invite Friends", Color = Color3.fromRGB(80, 160, 255), Callback = function() end},
    {Name = "Battle Pass", Color = Color3.fromRGB(255, 200, 80), Callback = function() end},
    {Name = "Game Modes", Color = Color3.fromRGB(80, 255, 150), Callback = function() end}
})

-- ═══════════════════════════════════════════
-- 4. MODULES TAB
-- ═══════════════════════════════════════════
local CharSection = ModulesTab:CreateSection("Character Options")

local speedSlider = CharSection:CreateSlider({
    Name = "WalkSpeed",
    Min = 16,
    Max = 200,
    Default = 16,
    Increment = 1,
    Callback = function(value)
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
            player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = value
        end
    end
})

local jumpToggle = CharSection:CreateToggle({
    Name = "Infinite Jump",
    Default = false,
    Callback = function(state)
        -- Infinite jump logic would go here
        NexusLib:Notify({
            Title = "Module",
            Message = "Infinite Jump " .. (state and "ENABLED" or "DISABLED"),
            Duration = 3
        })
    end
})

local CombatSection = ModulesTab:CreateSection("Combat & Teleportation")

CombatSection:CreateDropdown({
    Name = "Teleport Zone",
    Options = {"Spawn Location", "Cosmic Shop", "Rift Arena", "Boss Room"},
    Callback = function(selected)
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local positions = {
                ["Spawn Location"] = CFrame.new(0, 10, 0),
                ["Cosmic Shop"] = CFrame.new(100, 10, 100),
                ["Rift Arena"] = CFrame.new(-150, 15, -150),
                ["Boss Room"] = CFrame.new(200, 20, -200)
            }
            player.Character.HumanoidRootPart.CFrame = positions[selected] or CFrame.new(0, 10, 0)
            NexusLib:Notify({
                Title = "Teleport",
                Message = "Teleported to " .. selected,
                Duration = 4
            })
        end
    end
})

CombatSection:CreateToggle({
    Name = "Player ESP Outlines",
    Default = false,
    Callback = function(state)
        for _, plr in ipairs(game.Players:GetPlayers()) do
            if plr ~= game.Players.LocalPlayer and plr.Character then
                if state then
                    if not plr.Character:FindFirstChildOfClass("Highlight") then
                        local h = Instance.new("Highlight")
                        h.FillColor = Color3.fromRGB(160, 80, 255)
                        h.FillTransparency = 0.6
                        h.OutlineColor = Color3.new(1, 1, 1)
                        h.OutlineTransparency = 0.2
                        h.Parent = plr.Character
                    end
                else
                    local h = plr.Character:FindFirstChildOfClass("Highlight")
                    if h then h:Destroy() end
                end
            end
        end
    end
})

CombatSection:CreateButton({
    Name = "⚔️  Kill All Nearby",
    Callback = function()
        NexusLib:Notify({
            Title = "Combat",
            Message = "Feature requires game-specific implementation",
            Duration = 4
        })
    end
})

-- ═══════════════════════════════════════════
-- 5. SETTINGS TAB
-- ═══════════════════════════════════════════
local UISection = SettingsTab:CreateSection("UI Settings")

UISection:CreateTextbox({
    Name = "Custom Title",
    Placeholder = "Enter hub name...",
    Callback = function(text)
        NexusLib:Notify({
            Title = "Settings",
            Message = "Title changed to: " .. text,
            Duration = 3
        })
    end
})

UISection:CreateSlider({
    Name = "UI Scale",
    Min = 50,
    Max = 150,
    Default = 100,
    Increment = 5,
    Callback = function(value)
        -- Could adjust UI scale here
    end
})

local MiscSection = SettingsTab:CreateSection("Miscellaneous")

MiscSection:CreateToggle({
    Name = "Anti-AFK",
    Default = true,
    Callback = function(state)
        NexusLib:Notify({
            Title = "Anti-AFK",
            Message = state and "You will no longer be kicked for idling" or "Anti-AFK disabled",
            Duration = 3
        })
    end
})

MiscSection:CreateButton({
    Name = "🔄  Reset Character",
    Callback = function()
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
            player.Character:FindFirstChildOfClass("Humanoid").Health = 0
        end
    end
})

MiscSection:CreateButton({
    Name = "❌  Destroy UI",
    Callback = function()
        Window:Destroy()
    end
})
