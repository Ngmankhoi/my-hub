--[[
    NEXUS UI  -  single-file Luau UI library (Roblox executors)
    Everything is in this one file: the ink-swirl intro, the Dynamic Island,
    the window, tabs, and every element. The logo is embedded (no uploads).
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

local NexusLib = {
    Theme = {
        Surface       = Color3.fromRGB(17, 17, 20),   -- rgba(17,17,20,0.88)
        SurfaceAlpha  = 0.12,
        StrokeAlpha   = 0.92,                         -- white @ 8%
        RowAlpha      = 0.965,
        RowHoverAlpha = 0.94,
        ControlAlpha  = 0.93,
        ControlHoverAlpha = 0.89,
        Menu          = Color3.fromRGB(24, 24, 28),
        Knob          = Color3.fromRGB(142, 142, 150),
        Text          = Color3.fromRGB(237, 237, 239),
        Dim           = Color3.fromRGB(138, 138, 146),
        Faint         = Color3.fromRGB(90, 90, 98),
        White         = Color3.fromRGB(255, 255, 255),
    },
    ToggleKey = Enum.KeyCode.RightAlt,
    DefaultWindowSize = Vector2.new(640, 420),
    NotifyDuration = 3,
    Listening = false,
}
NexusLib.__index = NexusLib

local Theme = NexusLib.Theme

--------------------------------------------------------------------------
-- helpers
--------------------------------------------------------------------------
local function GetSafeGui()
    local ok, gui = pcall(function()
        return CoreGui
    end)
    if ok and gui then
        return gui
    end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local function Tween(instance, time, style, dir, props)
    local tween = TweenService:Create(instance, TweenInfo.new(time or 0.28, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out), props)
    tween:Play()
    return tween
end

local function New(class, props, children)
    local inst = Instance.new(class)
    local parent
    for k, v in pairs(props or {}) do
        if k == "Parent" then
            parent = v
        else
            inst[k] = v
        end
    end
    for _, child in ipairs(children or {}) do
        child.Parent = inst
    end
    inst.Parent = parent
    return inst
end

local function Corner(radius)
    return New("UICorner", { CornerRadius = UDim.new(0, radius) })
end

local function Rim(transparency, color)
    return New("UIStroke", {
        Color = color or Color3.fromRGB(255, 255, 255), Transparency = transparency, Thickness = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
end

local function Label(parent, props)
    local p = {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = parent,
    }
    for k, v in pairs(props or {}) do
        p[k] = v
    end
    return New("TextLabel", p)
end

--------------------------------------------------------------------------
-- embedded logo
--------------------------------------------------------------------------
local LOGO_B64 = [=[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]=]

local B64_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local function DecodeBase64(data)
    local lookup = {}
    for i = 1, #B64_CHARS do
        lookup[B64_CHARS:sub(i, i)] = i - 1
    end
    data = data:gsub("[^%w%+/=]", "")
    local out, n = {}, 0
    for i = 1, #data, 4 do
        local a = lookup[data:sub(i, i)]
        local b = lookup[data:sub(i + 1, i + 1)]
        local c = lookup[data:sub(i + 2, i + 2)]
        local d = lookup[data:sub(i + 3, i + 3)]
        if a and b then
            local v = a * 262144 + b * 4096 + (c or 0) * 64 + (d or 0)
            n = n + 1
            out[n] = string.char(math.floor(v / 65536) % 256)
            if c then
                n = n + 1
                out[n] = string.char(math.floor(v / 256) % 256)
            end
            if d then
                n = n + 1
                out[n] = string.char(v % 256)
            end
        end
    end
    return table.concat(out)
end

local function GetLogoAsset()
    if NexusLib.LogoAsset ~= nil then
        return NexusLib.LogoAsset
    end
    local ok, asset = pcall(function()
        local getAsset = getcustomasset or getsynasset
        if not (writefile and getAsset) then
            error("no file api")
        end
        local name = "nexus_logo.png"
        if not (isfile and isfile(name)) then
            writefile(name, DecodeBase64(LOGO_B64))
        end
        return getAsset(name)
    end)
    NexusLib.LogoAsset = (ok and asset) or ""
    return NexusLib.LogoAsset
end

local function Logo(parent, props)
    local asset = GetLogoAsset()
    if asset ~= "" then
        local p = { BackgroundTransparency = 1, Image = asset, ScaleType = Enum.ScaleType.Fit, Parent = parent }
        for k, v in pairs(props or {}) do p[k] = v end
        return New("ImageLabel", p)
    end
    local p = {
        BackgroundTransparency = 1, Text = "N", Font = Enum.Font.GothamBlack,
        TextColor3 = Theme.White, TextScaled = true, Parent = parent,
    }
    for k, v in pairs(props or {}) do p[k] = v end
    return New("TextLabel", p)
end

--------------------------------------------------------------------------
-- INK SWIRL INTRO
--------------------------------------------------------------------------
function NexusLib:PlayInkIntro(callback)
    local TAU = math.pi * 2
    local K = TAU * 0.9
    local S0 = 0.2
    local PHI0 = { -0.75 * math.pi, 0.25 * math.pi }
    local S_END = (1.75 * math.pi + TAU) / K
    local POINTS = 24
    local RING = 46

    local T_SPIN = 2.15
    local T_GROW = T_SPIN + 0.35
    local T_PILL = T_GROW + 0.45
    local T_SQUARE = T_GROW + 0.25
    local T_WINDOW = T_SQUARE + 0.7
    local T_END = T_WINDOW + 0.45

    local function clamp01(x) return math.clamp(x, 0, 1) end
    local function lerp(a, b, t) return a + (b - a) * t end
    local function easeOutCubic(x) return 1 - (1 - x) ^ 3 end
    local function easeOutQuart(x) return 1 - (1 - x) ^ 4 end
    local function easeInOutCubic(x)
        if x < 0.5 then return 4 * x * x * x end
        return 1 - (-2 * x + 2) ^ 3 / 2
    end
    local function smooth(a, b, x)
        local t = clamp01((x - a) / (b - a))
        return t * t * (3 - 2 * t)
    end

    local INK = Color3.fromRGB(245, 245, 245)
    local ISLAND_BG = Theme.Surface
    local SQUARE_BG = Color3.fromRGB(32, 32, 36)
    local WINDOW_BG = Theme.Surface

    local IntroGui = Instance.new("ScreenGui")
    IntroGui.Name = "Nexus_InkIntro"
    IntroGui.DisplayOrder = 999999
    IntroGui.ResetOnSpawn = false
    IntroGui.IgnoreGuiInset = true
    IntroGui.Parent = GetSafeGui()

    local Blur = Instance.new("BlurEffect")
    Blur.Size = 0
    pcall(function()
        Blur.Parent = game:GetService("Lighting")
    end)
    Tween(Blur, 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Size = 18 })

    local Dim = Instance.new("TextButton")
    Dim.Size = UDim2.new(1, 0, 1, 0)
    Dim.BackgroundColor3 = Color3.fromRGB(5, 6, 8)
    Dim.BackgroundTransparency = 0.45
    Dim.BorderSizePixel = 0
    Dim.Text = ""
    Dim.AutoButtonColor = false
    Dim.Parent = IntroGui

    local camera = workspace.CurrentCamera
    local vp = camera and camera.ViewportSize or Vector2.new(1280, 720)
    local cx, cy = vp.X / 2, vp.Y * 0.46
    local R0 = math.max(vp.X, vp.Y) * 0.6
    local winSize = NexusLib.DefaultWindowSize
    local win = { cx = vp.X / 2, cy = 66 + winSize.Y / 2, w = winSize.X, h = winSize.Y }
    local isl = { cx = vp.X / 2, cy = 14 + 20, w = 340, h = 40 }

    local segs = { {}, {} }
    for i = 1, 2 do
        for k = 1, POINTS - 1 do
            local f = Instance.new("Frame")
            f.AnchorPoint = Vector2.new(0.5, 0.5)
            f.BackgroundColor3 = INK
            f.BorderSizePixel = 0
            f.Visible = false
            f.Parent = IntroGui
            local c = Instance.new("UICorner")
            c.CornerRadius = UDim.new(0.5, 0)
            c.Parent = f
            segs[i][k] = f
        end
    end

    local function makeBlob()
        local f = Instance.new("Frame")
        f.AnchorPoint = Vector2.new(0.5, 0.5)
        f.BorderSizePixel = 0
        f.Visible = false
        f.Parent = IntroGui
        local c = Instance.new("UICorner")
        c.Name = "Corner"
        c.Parent = f
        local s = Instance.new("UIStroke")
        s.Name = "Rim"
        s.Thickness = 1
        s.Color = Color3.fromRGB(255, 255, 255)
        s.Transparency = 1
        s.Parent = f
        return f
    end
    local BlobL, BlobR = makeBlob(), makeBlob()

    local function place(f, x, y, w, h, radius, color, alpha, rim)
        f.Visible = true
        f.Position = UDim2.fromOffset(x, y)
        f.Size = UDim2.fromOffset(w, h)
        f.BackgroundColor3 = color
        f.BackgroundTransparency = alpha or 0
        f.Corner.CornerRadius = UDim.new(0, radius)
        f.Rim.Transparency = 1 - (rim or 0)
    end

    local function spiralPoint(i, s, ringR)
        local r = ringR
        if s < 1 then
            r = lerp(R0, ringR, easeOutCubic(clamp01(s)))
        end
        local phi = PHI0[i] + K * s
        return Vector2.new(cx + math.cos(phi) * r, cy + math.sin(phi) * r)
    end

    local function drawStroke(i, head, tail, maxW, ringR)
        local prev
        for k = 0, POINTS - 1 do
            local u = k / (POINTS - 1)
            local p = spiralPoint(i, tail + (head - tail) * u, ringR)
            if prev then
                local uMid = (k - 0.5) / (POINTS - 1)
                local w = maxW * math.sin(math.pi * uMid) ^ 0.65 + 0.8
                local d = p - prev
                local mid = (p + prev) / 2
                local f = segs[i][k]
                f.Visible = true
                f.Position = UDim2.fromOffset(mid.X, mid.Y)
                f.Size = UDim2.fromOffset(d.Magnitude + w * 0.5, w)
                f.Rotation = math.deg(math.atan2(d.Y, d.X))
            end
            prev = p
        end
    end

    local function hideStrokes()
        for i = 1, 2 do
            for _, f in ipairs(segs[i]) do
                f.Visible = false
            end
        end
    end

    local conn
    local finished = false
    local calledBack = false

    local function fireCallback()
        if calledBack then return end
        calledBack = true
        if callback then
            task.spawn(callback)
        end
    end

    local function Finish()
        if finished then return end
        finished = true
        if conn then conn:Disconnect() end
        fireCallback()
        Tween(Blur, 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Size = 0 })
        IntroGui:Destroy()
        task.delay(0.5, function()
            Blur:Destroy()
        end)
    end

    Dim.MouseButton1Click:Connect(Finish)

    local t0 = os.clock()
    conn = RunService.RenderStepped:Connect(function()
        local t = os.clock() - t0

        if t < T_SPIN then
            local head = lerp(S0, S_END, easeOutQuart(t / T_SPIN))
            local len = lerp(0.2, 0.5, smooth(0.15, 1.0, t)) * lerp(1, 0.07, smooth(1.5, T_SPIN, t))
            local tail = math.max(0, head - len)
            local maxW = lerp(6, 9, smooth(1.4, T_SPIN, t))
            local ringR = lerp(RING, 16, easeInOutCubic(smooth(1.3, T_SPIN, t)))
            for i = 1, 2 do
                drawStroke(i, head, tail, maxW, ringR)
            end
        else
            hideStrokes()
            local d = lerp(9, 18, easeOutCubic(clamp01((t - T_SPIN) / (T_GROW - T_SPIN))))
            local gap = 16

            local p = clamp01((t - T_GROW) / (T_PILL - T_GROW))
            if p <= 0 then
                place(BlobL, cx - gap, cy, d, d, d / 2, INK)
            else
                local e = easeInOutCubic(p)
                local h = p < 0.5 and lerp(18, 44, p / 0.5) or lerp(44, isl.h, (p - 0.5) / 0.5)
                local w = p < 0.5 and lerp(18, 12, p / 0.5) or lerp(12, isl.w, easeOutCubic((p - 0.5) / 0.5))
                local tone = smooth(0.55, 1, p)
                place(BlobL, lerp(cx - gap, isl.cx, e), lerp(cy, isl.cy, e), w, h,
                    math.min(w, h) / 2, INK:Lerp(ISLAND_BG, tone), 0, 0.08 * tone)
            end

            local q = clamp01((t - T_GROW) / (T_SQUARE - T_GROW))
            local x2 = clamp01((t - T_SQUARE) / (T_WINDOW - T_SQUARE))
            if x2 <= 0 then
                local sq = easeOutCubic(q)
                place(BlobR, cx + gap, cy, lerp(d, 34, sq), lerp(d, 28, sq), lerp(d / 2, 8, sq),
                    INK:Lerp(SQUARE_BG, sq))
            else
                local e = easeInOutCubic(x2)
                place(BlobR, lerp(cx + gap, win.cx, e), lerp(cy, win.cy, e), lerp(34, win.w, e),
                    lerp(28, win.h, e), lerp(8, 14, e), SQUARE_BG:Lerp(WINDOW_BG, e), 0, 0.08 * e)
            end
        end

        if t >= T_WINDOW then
            fireCallback()
            local f = clamp01((t - T_WINDOW) / (T_END - T_WINDOW))
            BlobL.BackgroundTransparency = f
            BlobR.BackgroundTransparency = f
            BlobL.Rim.Transparency = 1
            BlobR.Rim.Transparency = 1
            Dim.BackgroundTransparency = lerp(0.45, 1, f)
        end
        if t >= T_END then
            Finish()
        end
    end)
end

function NexusLib:PlayIntro(callback)
    return NexusLib:PlayInkIntro(callback)
end

--------------------------------------------------------------------------
-- shared surface
--------------------------------------------------------------------------
local function Surface(class, props, radius)
    local p = {
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = Theme.SurfaceAlpha,
        BorderSizePixel = 0,
    }
    for k, v in pairs(props or {}) do p[k] = v end
    return New(class, p, { Corner(radius or 14), Rim(Theme.StrokeAlpha) })
end

local function Soft(transparency)
    return { BackgroundColor3 = Theme.White, BackgroundTransparency = transparency, BorderSizePixel = 0 }
end

local function Merge(a, b)
    local out = {}
    for k, v in pairs(a or {}) do out[k] = v end
    for k, v in pairs(b or {}) do out[k] = v end
    return out
end

local function Button(parent, text, props)
    local b = New("TextButton", Merge(Soft(Theme.ControlAlpha), {
        AutoButtonColor = false, Text = text, Font = Enum.Font.GothamMedium, TextSize = 11,
        TextColor3 = Theme.Text, Parent = parent,
    }), { Corner(7) })
    for k, v in pairs(props or {}) do b[k] = v end
    b.MouseEnter:Connect(function() Tween(b, 0.15, nil, nil, { BackgroundTransparency = Theme.ControlHoverAlpha }) end)
    b.MouseLeave:Connect(function() Tween(b, 0.15, nil, nil, { BackgroundTransparency = Theme.ControlAlpha }) end)
    b.MouseButton1Down:Connect(function()
        local s = b:FindFirstChild("Press") or New("UIScale", { Name = "Press", Parent = b })
        Tween(s, 0.08, nil, nil, { Scale = 0.96 })
    end)
    b.MouseButton1Up:Connect(function()
        local s = b:FindFirstChild("Press")
        if s then Tween(s, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Scale = 1 }) end
    end)
    return b
end

--------------------------------------------------------------------------
-- DYNAMIC ISLAND (Clean drawer, test notify button removed)
--------------------------------------------------------------------------
local ISLAND_TOP, ISLAND_W, ISLAND_H = 14, 340, 40
local ISLAND_OPEN_W, ISLAND_OPEN_H = 340, 78

function NexusLib:CreateDynamicIsland(config)
    config = config or {}
    if NexusLib.ActiveIsland and NexusLib.ActiveIsland.Gui and NexusLib.ActiveIsland.Gui.Parent then
        return NexusLib.ActiveIsland
    end

    local Gui = New("ScreenGui", {
        Name = "Nexus_Island", DisplayOrder = 100000, ResetOnSpawn = false,
        IgnoreGuiInset = true, Parent = GetSafeGui(),
    })

    local Island = Surface("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, ISLAND_TOP),
        Size = UDim2.fromOffset(ISLAND_W, ISLAND_H),
        ClipsDescendants = true,
        Parent = Gui,
    }, 20)
    local Bump = New("UIScale", { Scale = 0.85, Parent = Island })
    Tween(Bump, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Scale = 1 })

    local Bar = New("TextButton", {
        Size = UDim2.new(1, 0, 0, ISLAND_H), BackgroundTransparency = 1, Text = "",
        AutoButtonColor = false, Parent = Island,
    })
    Logo(Bar, { Position = UDim2.new(0, 12, 0.5, -9), Size = UDim2.fromOffset(18, 18) })
    Label(Bar, {
        Position = UDim2.fromOffset(38, 0), Size = UDim2.new(0, 46, 1, 0),
        Font = Enum.Font.GothamBold, Text = config.Title or "Nexus",
    })
    local Status = Label(Bar, {
        Position = UDim2.fromOffset(88, 0), Size = UDim2.new(0, 110, 1, 0),
        Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = Theme.Dim, Text = config.Status or "Ready",
    })
    local Stats = Label(Bar, {
        AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -32, 0, 0), Size = UDim2.new(0, 110, 1, 0),
        Font = Enum.Font.Code, TextSize = 10, TextColor3 = Theme.Dim, TextXAlignment = Enum.TextXAlignment.Right,
        Text = "60 fps · 0ms",
    })
    local Caret = Label(Bar, {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(12, 12),
        TextXAlignment = Enum.TextXAlignment.Center, TextColor3 = Theme.Faint, TextSize = 11, Text = "▾",
    })

    local Drawer = New("Frame", {
        Position = UDim2.fromOffset(10, ISLAND_H + 2), Size = UDim2.new(1, -20, 0, 28),
        BackgroundTransparency = 1, Parent = Island,
    })
    local HideBtn = Button(Drawer, "Hide UI", { Size = UDim2.new(1, 0, 1, 0) })

    local IslandApi = { Gui = Gui, Frame = Island, Expanded = false }
    NexusLib.ActiveIsland = IslandApi

    function IslandApi:SetExpanded(on)
        IslandApi.Expanded = on
        Tween(Island, 0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
            Size = on and UDim2.fromOffset(ISLAND_OPEN_W, ISLAND_OPEN_H) or UDim2.fromOffset(ISLAND_W, ISLAND_H),
        })
        Tween(Caret, 0.3, nil, nil, { Rotation = on and 180 or 0, TextColor3 = on and Theme.Text or Theme.Faint })
        if NexusLib.ActiveWindow then
            NexusLib.ActiveWindow:PushDown(on)
        end
    end
    function IslandApi:SetStatus(text)
        Status.TextTransparency = 1
        Status.Position = UDim2.fromOffset(88, 4)
        Status.Text = text
        Tween(Status, 0.3, nil, nil, { TextTransparency = 0, Position = UDim2.fromOffset(88, 0) })
    end
    function IslandApi:SetHiddenLabel(hidden)
        HideBtn.Text = hidden and "Show UI" or "Hide UI"
    end
    function IslandApi:Gulp()
        Tween(Bump, 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Scale = 1.06 })
        task.delay(0.12, function()
            Tween(Bump, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Scale = 1 })
        end)
    end

    Bar.MouseButton1Click:Connect(function() IslandApi:SetExpanded(not IslandApi.Expanded) end)
    Island.MouseEnter:Connect(function() Tween(Island.UIStroke, 0.2, nil, nil, { Transparency = 0.86 }) end)
    Island.MouseLeave:Connect(function() Tween(Island.UIStroke, 0.2, nil, nil, { Transparency = Theme.StrokeAlpha }) end)
    HideBtn.MouseButton1Click:Connect(function()
        if NexusLib.ActiveWindow then
            NexusLib.ActiveWindow:ToggleVisible()
        end
        IslandApi:SetExpanded(false)
    end)

    local frames, last = 0, os.clock()
    RunService.RenderStepped:Connect(function()
        frames = frames + 1
        if os.clock() - last >= 1 then
            local ping = 0
            pcall(function()
                ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            Stats.Text = frames .. " fps · " .. ping .. "ms"
            frames, last = 0, os.clock()
        end
    end)

    return IslandApi
end

--------------------------------------------------------------------------
-- NOTIFICATIONS
--------------------------------------------------------------------------
local NOTE_W, NOTE_H, NOTE_MAX = 260, 56, 5
local NoteQueue = {}

function NexusLib:Notify(cfg)
    cfg = cfg or {}
    local duration = cfg.Duration or NexusLib.NotifyDuration or 3
    local parent = GetSafeGui()
    local Gui = parent:FindFirstChild("Nexus_Notifications")
    if not Gui then
        Gui = New("ScreenGui", {
            Name = "Nexus_Notifications", DisplayOrder = 100001, ResetOnSpawn = false,
            IgnoreGuiInset = true, Parent = parent,
        })
        New("Frame", {
            Name = "Stack", AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -20, 1, -20),
            Size = UDim2.new(0, NOTE_W, 1, -40), BackgroundTransparency = 1, Parent = Gui,
        }, {
            New("UIListLayout", {
                VerticalAlignment = Enum.VerticalAlignment.Bottom, Padding = UDim.new(0, 0),
                SortOrder = Enum.SortOrder.LayoutOrder,
            }),
        })
    end
    local Stack = Gui.Stack

    local Slot = New("Frame", {
        Size = UDim2.fromOffset(NOTE_W, 0), BackgroundTransparency = 1,
        LayoutOrder = math.floor(os.clock() * 1000), Parent = Stack,
    })
    local Card = Surface("CanvasGroup", {
        AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 28, 1, 0),
        Size = UDim2.fromOffset(NOTE_W, NOTE_H), GroupTransparency = 1, Parent = Slot,
    }, 12)
    Logo(Card, { Position = UDim2.fromOffset(12, 12), Size = UDim2.fromOffset(16, 16) })
    Label(Card, {
        Position = UDim2.fromOffset(38, 10), Size = UDim2.new(1, -50, 0, 16),
        Font = Enum.Font.GothamBold, Text = cfg.Title or "Nexus", TextTruncate = Enum.TextTruncate.AtEnd,
    })
    Label(Card, {
        Position = UDim2.fromOffset(38, 27), Size = UDim2.new(1, -50, 0, 16),
        Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = Theme.Dim,
        Text = cfg.Content or cfg.Message or "",
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
    local Bar = New("Frame", Merge(Soft(0.65), {
        AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 2),
        Parent = Card,
    }))

    local note = { Slot = Slot, Card = Card, Closed = false }
    function note:Close()
        if note.Closed then return end
        note.Closed = true
        for i, n in ipairs(NoteQueue) do
            if n == note then table.remove(NoteQueue, i) break end
        end
        Tween(Card, 0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.In, {
            Position = UDim2.new(0, 28, 1, 0), GroupTransparency = 1,
        })
        task.delay(0.18, function()
            Tween(Slot, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, { Size = UDim2.fromOffset(NOTE_W, 0) })
        end)
        task.delay(0.5, function() Slot:Destroy() end)
    end

    table.insert(NoteQueue, note)
    while #NoteQueue > NOTE_MAX do
        NoteQueue[1]:Close()
    end

    Tween(Slot, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, { Size = UDim2.fromOffset(NOTE_W, NOTE_H + 8) })
    Tween(Card, 0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Position = UDim2.new(0, 0, 1, 0), GroupTransparency = 0 })
    Tween(Bar, duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, { Size = UDim2.new(0, 0, 0, 2) })
    task.delay(duration, function() note:Close() end)
    return note
end

--------------------------------------------------------------------------
-- WINDOW
--------------------------------------------------------------------------
function NexusLib:CreateWindow(config)
    config = config or {}
    if config.Keybind then
        NexusLib.ToggleKey = config.Keybind
    end

    -- Automatically ensure Dynamic Island is present
    if config.NoIsland ~= true and not NexusLib.ActiveIsland then
        pcall(function()
            NexusLib:CreateDynamicIsland({ Title = config.Title or "Nexus", Status = "Ready" })
        end)
    end

    local size = config.Size or UDim2.fromOffset(NexusLib.DefaultWindowSize.X, NexusLib.DefaultWindowSize.Y)
    local homeY = ISLAND_TOP + ISLAND_H + 12

    local Gui = New("ScreenGui", {
        Name = "Nexus_Window", ResetOnSpawn = false, IgnoreGuiInset = true, Parent = GetSafeGui(),
    })

    local Frame = Surface("CanvasGroup", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, homeY),
        Size = size,
        GroupTransparency = 1,
        Parent = Gui,
    }, 14)
    local Pop = New("UIScale", { Scale = 0.96, Parent = Frame })
    Tween(Frame, 0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { GroupTransparency = 0 })
    Tween(Pop, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Scale = 1 })

    local Window = { Tabs = {}, CurrentTab = nil, Gui = Gui, Visible = true, Pushed = false }
    NexusLib.ActiveWindow = Window
    local savedPos = Frame.Position

    local TitleBar = New("Frame", { Size = UDim2.new(1, 0, 0, 46), BackgroundTransparency = 1, Parent = Frame })
    New("Frame", Merge(Soft(1 - 0.08), {
        AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 1),
        Parent = TitleBar,
    }))
    Logo(TitleBar, { Position = UDim2.fromOffset(16, 14), Size = UDim2.fromOffset(18, 18) })
    local TitleText = Label(TitleBar, {
        Position = UDim2.fromOffset(44, 0), Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X,
        Font = Enum.Font.GothamBold, Text = config.Title or "Nexus Hub",
    })
    local subText = config.SubTitle or config.Subtitle or ""
    local Sub = Label(TitleBar, {
        Position = UDim2.fromOffset(44, 0), Size = UDim2.new(0, 200, 1, 0),
        Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = Theme.Faint, Text = subText,
    })
    task.defer(function()
        Sub.Position = UDim2.fromOffset(44 + TitleText.AbsoluteSize.X + 8, 0)
    end)

    local MinBtn = New("TextButton", Merge(Soft(1), {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(26, 26),
        AutoButtonColor = false, Text = "", Parent = TitleBar,
    }), { Corner(7) })
    local MinLine = New("Frame", Merge(Soft(0), {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(10, 2),
        BackgroundColor3 = Theme.Dim, Parent = MinBtn,
    }), { Corner(1) })
    MinBtn.MouseEnter:Connect(function()
        Tween(MinBtn, 0.15, nil, nil, { BackgroundTransparency = Theme.ControlAlpha })
        Tween(MinLine, 0.15, nil, nil, { BackgroundColor3 = Theme.Text })
    end)
    MinBtn.MouseLeave:Connect(function()
        Tween(MinBtn, 0.15, nil, nil, { BackgroundTransparency = 1 })
        Tween(MinLine, 0.15, nil, nil, { BackgroundColor3 = Theme.Dim })
    end)
    MinBtn.MouseButton1Click:Connect(function() Window:SetVisible(false) end)

    local dragging, dragStart, startPos = false, nil, nil
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging, dragStart, startPos = true, input.Position, Frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    local Sidebar = New("Frame", {
        Position = UDim2.fromOffset(0, 46), Size = UDim2.new(0, 132, 1, -46),
        BackgroundTransparency = 1, Parent = Frame,
    })
    New("Frame", Merge(Soft(1 - 0.08), {
        AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0), Size = UDim2.new(0, 1, 1, 0),
        Parent = Sidebar,
    }))
    local Glide = New("Frame", Merge(Soft(Theme.ControlAlpha), {
        Position = UDim2.fromOffset(8, 10), Size = UDim2.new(1, -16, 0, 32), Visible = false, Parent = Sidebar,
    }), { Corner(8) })
    New("Frame", Merge(Soft(0), {
        AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.fromOffset(2, 12),
        BackgroundColor3 = Theme.Text, Parent = Glide,
    }), { Corner(1) })
    local TabList = New("Frame", {
        Position = UDim2.fromOffset(8, 10), Size = UDim2.new(1, -16, 1, -20), BackgroundTransparency = 1, Parent = Sidebar,
    }, {
        New("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }),
    })
    local PageHolder = New("Frame", {
        Position = UDim2.fromOffset(133, 46), Size = UDim2.new(1, -133, 1, -46),
        BackgroundTransparency = 1, ClipsDescendants = true, Parent = Frame,
    })

    function Window:SetVisible(on)
        if on == Window.Visible then return end
        Window.Visible = on
        local island = NexusLib.ActiveIsland
        if island then island:SetHiddenLabel(not on) end
        if on then
            Frame.Visible = true
            Tween(Frame, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Position = savedPos, GroupTransparency = 0 })
            Tween(Pop, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Scale = 1 })
            if island then island:SetStatus("Ready") end
        else
            savedPos = Frame.Position
            Tween(Frame, 0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In, {
                Position = UDim2.new(0.5, 0, 0, ISLAND_TOP), GroupTransparency = 1,
            })
            Tween(Pop, 0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In, { Scale = 0.3 })
            task.delay(0.35, function()
                if island then
                    island:Gulp()
                    island:SetStatus("Hidden")
                end
            end)
            task.delay(0.4, function()
                if not Window.Visible then Frame.Visible = false end
            end)
        end
    end

    function Window:ToggleVisible()
        Window:SetVisible(not Window.Visible)
    end
    function Window:ResetPosition()
        savedPos = UDim2.new(0.5, 0, 0, homeY + (Window.Pushed and (ISLAND_OPEN_H - ISLAND_H) or 0))
        Tween(Frame, 0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Position = savedPos })
    end
    function Window:PushDown(pushed)
        if pushed == Window.Pushed then return end
        Window.Pushed = pushed
        local dy = pushed and (ISLAND_OPEN_H - ISLAND_H) or -(ISLAND_OPEN_H - ISLAND_H)
        savedPos = UDim2.new(savedPos.X.Scale, savedPos.X.Offset, savedPos.Y.Scale, savedPos.Y.Offset + dy)
        if Window.Visible then
            local p = Frame.Position
            Tween(Frame, 0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
                Position = UDim2.new(p.X.Scale, p.X.Offset, p.Y.Scale, p.Y.Offset + dy),
            })
        end
    end
    function Window:Notify(cfg)
        return NexusLib:Notify(cfg)
    end
    function Window:Destroy()
        Gui:Destroy()
    end

    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and not NexusLib.Listening and input.KeyCode == NexusLib.ToggleKey then
            Window:ToggleVisible()
        end
    end)

    ---------------- tabs ----------------
    function Window:CreateTab(name)
        local index = #Window.Tabs + 1

        local TabButton = New("TextButton", {
            Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, Text = "",
            AutoButtonColor = false, LayoutOrder = index, ZIndex = 2, Parent = TabList,
        })
        local text = Label(TabButton, {
            Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -16, 1, 0), Text = name,
            TextColor3 = Theme.Dim, ZIndex = 2,
        })
        TabButton.MouseEnter:Connect(function() Tween(text, 0.15, nil, nil, { TextColor3 = Theme.Text }) end)
        TabButton.MouseLeave:Connect(function()
            if Window.CurrentTab and Window.CurrentTab.Index ~= index then
                Tween(text, 0.15, nil, nil, { TextColor3 = Theme.Dim })
            end
        end)

        local Page = New("ScrollingFrame", {
            Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0,
            ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.White, ScrollBarImageTransparency = 0.85,
            CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false, Parent = PageHolder,
        }, {
            New("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }),
            New("UIPadding", {
                PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 14),
                PaddingRight = UDim.new(0, 14), PaddingBottom = UDim.new(0, 14),
            }),
        })

        local Tab = { Button = TabButton, Label = text, Page = Page, Index = index }
        local order = 0
        local function nextOrder()
            order = order + 1
            return order
        end

        function Tab:Select()
            local prev = Window.CurrentTab
            if prev == Tab then return end
            for _, other in ipairs(Window.Tabs) do
                other.Page.Visible = false
                Tween(other.Label, 0.2, nil, nil, { TextColor3 = Theme.Dim })
            end
            local y = 10 + (index - 1) * 34
            if Glide.Visible then
                Tween(Glide, 0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Position = UDim2.fromOffset(8, y) })
            else
                Glide.Position = UDim2.fromOffset(8, y)
                Glide.Visible = true
            end
            Tween(text, 0.2, nil, nil, { TextColor3 = Theme.Text })
            local dir = (prev and prev.Index > index) and -1 or 1
            Page.Position = UDim2.fromOffset(18 * dir, 0)
            Page.Visible = true
            Tween(Page, 0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, { Position = UDim2.fromOffset(0, 0) })
            Window.CurrentTab = Tab
        end
        TabButton.MouseButton1Click:Connect(function() Tab:Select() end)

        local function Item(cfg, rightWidth)
            cfg = cfg or {}
            local hasDesc = cfg.Description ~= nil and cfg.Description ~= ""
            local h = hasDesc and 46 or 42
            local row = New("Frame", Merge(Soft(Theme.RowAlpha), {
                Size = UDim2.new(1, 0, 0, h), LayoutOrder = nextOrder(), Parent = Page,
            }), { Corner(9) })
            local w = -(24 + (rightWidth or 110))
            Label(row, {
                Position = UDim2.fromOffset(12, hasDesc and 8 or 0), Size = UDim2.new(1, w, 0, hasDesc and 16 or h),
                Text = cfg.Name or "Item", TextTruncate = Enum.TextTruncate.AtEnd,
            })
            if hasDesc then
                Label(row, {
                    Position = UDim2.fromOffset(12, 24), Size = UDim2.new(1, w, 0, 14),
                    Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = Theme.Dim, Text = cfg.Description,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                })
            end
            local right = New("Frame", {
                AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0),
                Size = UDim2.fromOffset(rightWidth or 110, 28), BackgroundTransparency = 1, Parent = row,
            })
            return row, right
        end

        local function Hover(row, hit)
            hit.MouseEnter:Connect(function() Tween(row, 0.15, nil, nil, { BackgroundTransparency = Theme.RowHoverAlpha }) end)
            hit.MouseLeave:Connect(function() Tween(row, 0.15, nil, nil, { BackgroundTransparency = Theme.RowAlpha }) end)
        end

        function Tab:CreateSection(title)
            local lbl = Label(Page, {
                Size = UDim2.new(1, 0, 0, 26), Text = string.upper(tostring(title or "Section")), TextSize = 10,
                Font = Enum.Font.GothamMedium, TextColor3 = Theme.Faint,
                TextYAlignment = Enum.TextYAlignment.Bottom, LayoutOrder = nextOrder(),
            })
            local sectionObj = {
                _label = lbl,
                _tab = Tab,
                CreateToggle = function(_, cfg) return Tab:CreateToggle(cfg) end,
                CreateButton = function(_, cfg) return Tab:CreateButton(cfg) end,
                CreateSlider = function(_, cfg) return Tab:CreateSlider(cfg) end,
                CreateDropdown = function(_, cfg) return Tab:CreateDropdown(cfg) end,
                CreateMultiDropdown = function(_, cfg) return Tab:CreateMultiDropdown(cfg) end,
                CreateInput = function(_, cfg) return Tab:CreateInput(cfg) end,
                CreateTextbox = function(_, cfg) return Tab:CreateInput(cfg) end,
                CreateKeybind = function(_, cfg) return Tab:CreateKeybind(cfg) end,
                CreateLabel = function(_, textVal) return Tab:CreateLabel(textVal) end,
                CreateHeader = function(_, textVal) return Tab:CreateHeader(textVal) end,
                CreateActionRow = function(_, actions) return Tab:CreateActionRow(actions) end,
                CreateCardGroup = function(_, cards) return Tab:CreateCardGroup(cards) end,
                CreateBlock = function(_, cfg) return Tab:CreateBlock(cfg) end,
                CreateFeaturedCard = function(_, cfg) return Tab:CreateFeaturedCard(cfg) end,
                CreateStatRow = function(_, statTitle, statVal) return Tab:CreateStatRow(statTitle, statVal) end,
            }
            return setmetatable(sectionObj, {
                __index = function(t, k)
                    if Tab[k] ~= nil and type(Tab[k]) == "function" then
                        return function(_, ...) return Tab[k](Tab, ...) end
                    end
                    return rawget(t, k)
                end,
            })
        end
        Tab.Section = Tab.CreateSection

        function Tab:CreateToggle(cfg)
            cfg = cfg or {}
            local state = cfg.Default or false
            local row, right = Item(cfg, 32)
            local track = New("Frame", Merge(Soft(state and 0 or 0.88), {
                AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(32, 18),
                BackgroundColor3 = state and Theme.Text or Theme.White, Parent = right,
            }), { Corner(9) })
            local knob = New("Frame", {
                AnchorPoint = Vector2.new(0, 0.5), Position = state and UDim2.new(0, 16, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
                Size = UDim2.fromOffset(14, 14), BackgroundColor3 = state and Theme.Surface or Theme.Knob,
                BorderSizePixel = 0, Parent = track,
            }, { Corner(7) })

            local Toggle = {}
            function Toggle:Set(value, silent)
                state = value == true
                Tween(track, 0.22, nil, nil, {
                    BackgroundColor3 = state and Theme.Text or Theme.White, BackgroundTransparency = state and 0 or 0.88,
                })
                Tween(knob, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
                    Position = state and UDim2.new(0, 16, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
                    BackgroundColor3 = state and Theme.Surface or Theme.Knob,
                })
                if not silent and cfg.Callback then task.spawn(cfg.Callback, state) end
            end
            function Toggle:Get() return state end

            local hit = New("TextButton", {
                Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", ZIndex = 3, Parent = row,
            })
            hit.MouseButton1Click:Connect(function() Toggle:Set(not state) end)
            Hover(row, hit)
            return Toggle
        end

        function Tab:CreateSlider(cfg)
            cfg = cfg or {}
            local min, max, step = cfg.Min or 0, cfg.Max or 100, cfg.Step or 1
            local value = math.clamp(cfg.Default or min, min, max)
            local _, right = Item(cfg, 180)

            local valueLabel = Label(right, {
                Size = UDim2.new(0, 30, 1, 0), TextXAlignment = Enum.TextXAlignment.Right,
                Font = Enum.Font.Code, TextSize = 10, TextColor3 = Theme.Dim, Text = tostring(value),
            })
            local hit = New("TextButton", {
                Position = UDim2.fromOffset(40, 0), Size = UDim2.new(1, -40, 1, 0),
                BackgroundTransparency = 1, Text = "", Parent = right,
            })
            local track = New("Frame", Merge(Soft(0.88), {
                AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.new(1, 0, 0, 3),
                Parent = hit,
            }), { Corner(2) })
            local fill = New("Frame", {
                Size = UDim2.fromScale((value - min) / (max - min), 1), BackgroundColor3 = Theme.Text,
                BorderSizePixel = 0, Parent = track,
            }, { Corner(2) })
            local knob = New("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale((value - min) / (max - min), 0.5),
                Size = UDim2.fromOffset(12, 12), BackgroundColor3 = Theme.White, BorderSizePixel = 0, Parent = track,
            }, { Corner(6) })

            local Slider = {}
            function Slider:Set(v, silent)
                v = math.clamp(math.floor((v - min) / step + 0.5) * step + min, min, max)
                value = v
                local p = (v - min) / (max - min)
                Tween(fill, 0.08, nil, nil, { Size = UDim2.fromScale(p, 1) })
                Tween(knob, 0.08, nil, nil, { Position = UDim2.fromScale(p, 0.5) })
                valueLabel.Text = tostring(v)
                if not silent and cfg.Callback then task.spawn(cfg.Callback, v) end
            end
            function Slider:Get() return value end

            local sliding = false
            local function fromX(x)
                local p = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                Slider:Set(min + (max - min) * p)
            end
            hit.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = true
                    Tween(knob, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Size = UDim2.fromOffset(15, 15) })
                    fromX(input.Position.X)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    fromX(input.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if sliding and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                    sliding = false
                    Tween(knob, 0.2, nil, nil, { Size = UDim2.fromOffset(12, 12) })
                end
            end)
            return Slider
        end

        function Tab:CreateButton(cfg)
            cfg = cfg or {}
            local _, right = Item(cfg, 72)
            local b = Button(right, cfg.Text or cfg.Name or "Run", {
                AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(72, 28),
            })
            b.MouseButton1Click:Connect(function()
                if cfg.Callback then task.spawn(cfg.Callback) end
            end)
            return {
                Set = function(_, textVal) b.Text = tostring(textVal) end,
            }
        end

        function Tab:CreateInput(cfg)
            cfg = cfg or {}
            local _, right = Item(cfg, 150)
            local box = New("TextBox", Merge(Soft(Theme.ControlAlpha), {
                Size = UDim2.fromScale(1, 1), Text = cfg.Default or "", PlaceholderText = cfg.Placeholder or "Type...",
                PlaceholderColor3 = Theme.Faint, Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, Parent = right,
            }), { Corner(7), New("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }) })
            local stroke = Rim(1)
            stroke.Parent = box
            box.Focused:Connect(function() Tween(stroke, 0.15, nil, nil, { Transparency = 0.86 }) end)
            box.FocusLost:Connect(function(enter)
                Tween(stroke, 0.15, nil, nil, { Transparency = 1 })
                if cfg.Callback then
                    task.spawn(cfg.Callback, box.Text)
                    if enter and cfg.ClearOnSubmit == true then box.Text = "" end
                end
            end)
            local Input = {}
            function Input:Set(v) box.Text = tostring(v) end
            function Input:Get() return box.Text end
            return Input
        end
        Tab.CreateTextbox = Tab.CreateInput

        function Tab:CreateDropdown(cfg)
            cfg = cfg or {}
            local options = cfg.Options or {}
            local value = cfg.Default or options[1]
            local _, right = Item(cfg, 110)
            local field = Button(right, "", { Size = UDim2.fromScale(1, 1) })
            local valueLabel = Label(field, {
                Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -28, 1, 0), TextSize = 11, Text = tostring(value or ""),
            })
            local arrow = Label(field, {
                AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.fromOffset(12, 12),
                TextXAlignment = Enum.TextXAlignment.Center, TextColor3 = Theme.Dim, TextSize = 11, Text = "▾",
            })

            local menu, closeConn
            local function close()
                if closeConn then closeConn:Disconnect() closeConn = nil end
                Tween(arrow, 0.25, nil, nil, { Rotation = 0 })
                if menu then
                    local m = menu
                    menu = nil
                    Tween(m, 0.18, nil, nil, { Size = UDim2.fromOffset(m.Size.X.Offset, 0) })
                    task.delay(0.2, function() m:Destroy() end)
                end
            end
            local function set(v, silent)
                value = v
                valueLabel.Text = tostring(v or "")
                if not silent and cfg.Callback then task.spawn(cfg.Callback, v) end
            end

            field.MouseButton1Click:Connect(function()
                if menu then close() return end
                Tween(arrow, 0.25, nil, nil, { Rotation = 180 })
                local width = math.max(120, field.AbsoluteSize.X)
                local height = #options * 28 + 8
                menu = New("Frame", {
                    Position = UDim2.fromOffset(field.AbsolutePosition.X + field.AbsoluteSize.X - width, field.AbsolutePosition.Y + field.AbsoluteSize.Y + 6),
                    Size = UDim2.fromOffset(width, 0), BackgroundColor3 = Theme.Menu,
                    BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 50, Parent = Gui,
                }, { Corner(9), Rim(Theme.StrokeAlpha), New("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4) }), New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }) })
                Tween(menu, 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, { Size = UDim2.fromOffset(width, height) })
                for i, option in ipairs(options) do
                    local selected = option == value
                    local item = New("TextButton", Merge(Soft(selected and Theme.ControlAlpha or 1), {
                        Size = UDim2.new(1, 0, 0, 28), AutoButtonColor = false,
                        Text = tostring(option), Font = Enum.Font.GothamMedium, TextSize = 11,
                        TextColor3 = selected and Theme.Text or Theme.Dim, TextXAlignment = Enum.TextXAlignment.Left,
                        LayoutOrder = i, ZIndex = 51, Parent = menu,
                    }), { Corner(6), New("UIPadding", { PaddingLeft = UDim.new(0, 10) }) })
                    item.MouseEnter:Connect(function() Tween(item, 0.1, nil, nil, { BackgroundTransparency = Theme.ControlAlpha, TextColor3 = Theme.Text }) end)
                    item.MouseLeave:Connect(function()
                        Tween(item, 0.1, nil, nil, {
                            BackgroundTransparency = selected and Theme.ControlAlpha or 1,
                            TextColor3 = selected and Theme.Text or Theme.Dim,
                        })
                    end)
                    item.MouseButton1Click:Connect(function()
                        set(option)
                        close()
                    end)
                end
                closeConn = UserInputService.InputBegan:Connect(function(input)
                    if menu and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                        local pos = input.Position
                        local a, s = menu.AbsolutePosition, menu.AbsoluteSize
                        local f, fs = field.AbsolutePosition, field.AbsoluteSize
                        local inMenu = pos.X >= a.X and pos.X <= a.X + s.X and pos.Y >= a.Y and pos.Y <= a.Y + s.Y
                        local inField = pos.X >= f.X and pos.X <= f.X + fs.X and pos.Y >= f.Y and pos.Y <= f.Y + fs.Y
                        if not inMenu and not inField then
                            task.defer(close)
                        end
                    end
                end)
            end)

            local Dropdown = {}
            function Dropdown:Set(v, silent) set(v, silent) end
            function Dropdown:Get() return value end
            function Dropdown:Refresh(newOptions)
                options = newOptions or {}
                if not table.find(options, value) then
                    set(options[1])
                end
            end
            return Dropdown
        end

        function Tab:CreateMultiDropdown(cfg)
            cfg = cfg or {}
            local options = cfg.Options or {}
            local selectedMap = {}
            local defaults = cfg.Default or {}
            if type(defaults) == "table" then
                for _, v in ipairs(defaults) do selectedMap[tostring(v)] = true end
            elseif defaults ~= nil then
                selectedMap[tostring(defaults)] = true
            end

            local _, right = Item(cfg, 120)
            local field = Button(right, "", { Size = UDim2.fromScale(1, 1) })
            local valueLabel = Label(field, {
                Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -28, 1, 0), TextSize = 11, Text = "0 Selected",
            })
            local arrow = Label(field, {
                AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.fromOffset(12, 12),
                TextXAlignment = Enum.TextXAlignment.Center, TextColor3 = Theme.Dim, TextSize = 11, Text = "▾",
            })

            local function getSelectedList()
                local list = {}
                for opt, state in pairs(selectedMap) do
                    if state then table.insert(list, opt) end
                end
                return list
            end

            local function updateDisplay()
                local list = getSelectedList()
                if #list == 0 then
                    valueLabel.Text = "None"
                elseif #list == 1 then
                    valueLabel.Text = list[1]
                else
                    valueLabel.Text = #list .. " Selected"
                end
            end
            updateDisplay()

            local menu, closeConn
            local function close()
                if closeConn then closeConn:Disconnect() closeConn = nil end
                Tween(arrow, 0.25, nil, nil, { Rotation = 0 })
                if menu then
                    local m = menu
                    menu = nil
                    Tween(m, 0.18, nil, nil, { Size = UDim2.fromOffset(m.Size.X.Offset, 0) })
                    task.delay(0.2, function() m:Destroy() end)
                end
            end

            field.MouseButton1Click:Connect(function()
                if menu then close() return end
                Tween(arrow, 0.25, nil, nil, { Rotation = 180 })
                local width = math.max(130, field.AbsoluteSize.X)
                local height = #options * 28 + 8
                menu = New("Frame", {
                    Position = UDim2.fromOffset(field.AbsolutePosition.X + field.AbsoluteSize.X - width, field.AbsolutePosition.Y + field.AbsoluteSize.Y + 6),
                    Size = UDim2.fromOffset(width, 0), BackgroundColor3 = Theme.Menu,
                    BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 50, Parent = Gui,
                }, { Corner(9), Rim(Theme.StrokeAlpha), New("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4) }), New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }) })
                Tween(menu, 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, { Size = UDim2.fromOffset(width, height) })

                for i, option in ipairs(options) do
                    local optStr = tostring(option)
                    local isSel = selectedMap[optStr] == true
                    local item = New("TextButton", Merge(Soft(isSel and Theme.ControlAlpha or 1), {
                        Size = UDim2.new(1, 0, 0, 28), AutoButtonColor = false,
                        Text = (isSel and "✓ " or "   ") .. optStr, Font = Enum.Font.GothamMedium, TextSize = 11,
                        TextColor3 = isSel and Theme.Text or Theme.Dim, TextXAlignment = Enum.TextXAlignment.Left,
                        LayoutOrder = i, ZIndex = 51, Parent = menu,
                    }), { Corner(6), New("UIPadding", { PaddingLeft = UDim.new(0, 8) }) })

                    item.MouseButton1Click:Connect(function()
                        selectedMap[optStr] = not selectedMap[optStr]
                        local nowSel = selectedMap[optStr] == true
                        item.Text = (nowSel and "✓ " or "   ") .. optStr
                        item.TextColor3 = nowSel and Theme.Text or Theme.Dim
                        item.BackgroundTransparency = nowSel and Theme.ControlAlpha or 1
                        updateDisplay()
                        if cfg.Callback then task.spawn(cfg.Callback, getSelectedList()) end
                    end)
                end

                closeConn = UserInputService.InputBegan:Connect(function(input)
                    if menu and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                        local pos = input.Position
                        local a, s = menu.AbsolutePosition, menu.AbsoluteSize
                        local f, fs = field.AbsolutePosition, field.AbsoluteSize
                        local inMenu = pos.X >= a.X and pos.X <= a.X + s.X and pos.Y >= a.Y and pos.Y <= a.Y + s.Y
                        local inField = pos.X >= f.X and pos.X <= f.X + fs.X and pos.Y >= f.Y and pos.Y <= f.Y + fs.Y
                        if not inMenu and not inField then
                            task.defer(close)
                        end
                    end
                end)
            end)

            local Multi = {}
            function Multi:Set(list, silent)
                selectedMap = {}
                if type(list) == "table" then
                    for _, v in ipairs(list) do selectedMap[tostring(v)] = true end
                end
                updateDisplay()
                if not silent and cfg.Callback then task.spawn(cfg.Callback, getSelectedList()) end
            end
            function Multi:Get() return getSelectedList() end
            function Multi:Refresh(newOptions)
                options = newOptions or {}
            end
            return Multi
        end

        function Tab:CreateKeybind(cfg)
            cfg = cfg or {}
            local key = cfg.Default or Enum.KeyCode.RightShift
            local _, right = Item(cfg, 96)
            local field = Button(right, key.Name, { Size = UDim2.fromScale(1, 1), Font = Enum.Font.Code, TextSize = 10 })
            local blink
            field.MouseButton1Click:Connect(function()
                if NexusLib.Listening then return end
                NexusLib.Listening = true
                field.Text = "..."
                blink = TweenService:Create(field, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { TextTransparency = 0.6 })
                blink:Play()
                local conn
                conn = UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        conn:Disconnect()
                        blink:Cancel()
                        field.TextTransparency = 0
                        key = input.KeyCode
                        field.Text = key.Name
                        task.defer(function() NexusLib.Listening = false end)
                        if cfg.Callback then task.spawn(cfg.Callback, key) end
                    end
                end)
            end)
            local Keybind = {}
            function Keybind:Get() return key end
            function Keybind:Set(k)
                key = k
                field.Text = key.Name
            end
            return Keybind
        end

        function Tab:CreateLabel(textVal)
            local row = New("Frame", Merge(Soft(Theme.RowAlpha), {
                Size = UDim2.new(1, 0, 0, 32), LayoutOrder = nextOrder(), Parent = Page,
            }), { Corner(8) })
            local lbl = Label(row, {
                Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -24, 1, 0),
                Text = tostring(textVal or ""), TextColor3 = Theme.Dim, Font = Enum.Font.Gotham,
            })
            return {
                _frame = row,
                Set = function(_, newText) lbl.Text = tostring(newText or "") end,
            }
        end

        function Tab:CreateHeader(textVal)
            return Label(Page, {
                Size = UDim2.new(1, 0, 0, 30), Text = string.upper(tostring(textVal or "")),
                Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = Theme.Text,
                TextYAlignment = Enum.TextYAlignment.Bottom, LayoutOrder = nextOrder(),
            })
        end

        function Tab:CreateActionRow(actions)
            actions = actions or {}
            local count = #actions
            local row = New("Frame", {
                Size = UDim2.new(1, 0, 0, 36), BackgroundTransparency = 1, LayoutOrder = nextOrder(), Parent = Page,
            }, {
                New("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6) }),
            })
            local results = {}
            for i, act in ipairs(actions) do
                local w = (1 / count)
                local b = Button(row, act.Name or "Action", {
                    Size = UDim2.new(w, -((count - 1) * 6 / count), 1, 0),
                })
                b.MouseButton1Click:Connect(function()
                    if act.Callback then task.spawn(act.Callback) end
                end)
                table.insert(results, b)
            end
            return results
        end

        function Tab:CreateCardGroup(cards)
            cards = cards or {}
            local count = #cards
            local row = New("Frame", {
                Size = UDim2.new(1, 0, 0, 42), BackgroundTransparency = 1, LayoutOrder = nextOrder(), Parent = Page,
            }, {
                New("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6) }),
            })
            local results = {}
            for i, card in ipairs(cards) do
                local w = (1 / count)
                local b = Button(row, card.Title or card.Name or "Card", {
                    Size = UDim2.new(w, -((count - 1) * 6 / count), 1, 0),
                })
                b.MouseButton1Click:Connect(function()
                    if card.Callback then task.spawn(card.Callback) end
                end)
                table.insert(results, b)
            end
            return results
        end

        function Tab:CreateStatRow(titleVal, statVal)
            local row = New("Frame", Merge(Soft(Theme.RowAlpha), {
                Size = UDim2.new(1, 0, 0, 36), LayoutOrder = nextOrder(), Parent = Page,
            }), { Corner(8) })
            Label(row, {
                Position = UDim2.fromOffset(12, 0), Size = UDim2.new(0.5, -12, 1, 0),
                Text = tostring(titleVal or ""), TextColor3 = Theme.Dim,
            })
            local valLbl = Label(row, {
                AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 0), Size = UDim2.new(0.5, -12, 1, 0),
                Text = tostring(statVal or ""), TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Right,
                Font = Enum.Font.Code,
            })
            return {
                _frame = row,
                Set = function(_, v) valLbl.Text = tostring(v or "") end,
            }
        end

        function Tab:CreateBlock(cfg)
            cfg = cfg or {}
            return Tab:CreateButton(cfg)
        end
        Tab.CreateFeaturedCard = Tab.CreateBlock

        table.insert(Window.Tabs, Tab)
        if index == 1 then
            Tab:Select()
        end
        return Tab
    end

    return Window
end

local runtimeEnv = (getgenv and getgenv()) or _G or {}
runtimeEnv.NexusLib = NexusLib

return NexusLib
