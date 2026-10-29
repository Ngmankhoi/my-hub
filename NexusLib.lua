--[[
    ==========================================================================
    NEXUS UI (ROBLOX) - ULTIMATE SINGLE-FILE LUAU UI LIBRARY
    ==========================================================================
    Features:
      • Ink-Swirl Intro: Two spiral strokes orbit, shrink to 2 dots, then morph
        into the Dynamic Island and Main Glassmorphic Window.
      • Dynamic Island: Sleek top pill with live FPS & Ping, live status,
        expandable drawer (Hide/Show UI, Test Notify), and Gulp() swallow effect.
      • Glassmorphic Window: Single-surface dark design (rgba 17,17,20, 0.88),
        1px subtle white stroke rim, 14px rounded corners.
      • Sidebar Navigation: Smooth pill Glide indicator with back spring bounce.
      • Notifications: Stacked bottom-right notifications with logo, progress bar,
        and slide/collapse animations.
      • Mobile Ready: Floating 2K Nexus monogram draggable button with touch &
        mouse edge-snapping for mobile/tablet players.
      • Complete Controls: Section, Toggle, Slider, Dropdown, MultiDropdown,
        Input/Textbox, Keybind, Button, Label, Header, ActionRow, StatRow.
      • 100% Zero External Dependencies: Embedded 2K vector monogram + official
        Roblox 2K asset fallback. Works out of the box in Studio & Executors!

    Usage:
        local Nexus = loadstring(game:HttpGet("https://raw.githubusercontent.com/Ngmankhoi/my-hub/main/Nexus_UI.lua"))()
        Nexus:Demo() -- Run full showcase demo
    ==========================================================================
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

_G.NexusLib = nil
local NexusLib = {

    Theme = {
        Surface           = Color3.fromRGB(17, 17, 20),
        SurfaceAlpha      = 0.12,
        StrokeAlpha       = 0.92,
        RowAlpha          = 0.965,
        RowHoverAlpha     = 0.94,
        ControlAlpha      = 0.93,
        ControlHoverAlpha = 0.89,
        Menu              = Color3.fromRGB(24, 24, 28),
        Knob              = Color3.fromRGB(142, 142, 150),
        Text              = Color3.fromRGB(237, 237, 239),
        Dim               = Color3.fromRGB(138, 138, 146),
        Faint             = Color3.fromRGB(90, 90, 98),
        White             = Color3.fromRGB(255, 255, 255),
        Accent            = Color3.fromRGB(167, 139, 250),
    },
    ToggleKey = Enum.KeyCode.RightShift,
    DefaultWindowSize = Vector2.new(640, 420),
    NotifyDuration = 6,
    Listening = false,
    _windows = {},
}
NexusLib.__index = NexusLib
_G.NexusLib = NexusLib
shared.NexusLib = NexusLib


local Theme = NexusLib.Theme

-- Motion parameters
local SPRING_BOUNCE = TweenInfo.new(0.46, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local SMOOTH_QUAD = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local FAST_EASE = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Official 2K Vector Assets
local NEXUS_2K_ASSET = "rbxassetid://79122933233892"
local CHEVRON_ASSET  = "rbxassetid://136188197552572"

-- 1:1 Tab Icons
local TAB_ICONS = {
    Dashboard = "rbxassetid://139929981863901",
    Fishing   = "rbxassetid://71754848048049",
    Shop      = "rbxassetid://128420521375441",
    Exchange  = "rbxassetid://131324733048447",
    Quests    = "rbxassetid://92649798577170",
    Upgrade   = "rbxassetid://81819858538839",
    Teleport  = "rbxassetid://84279202219901",
    Settings  = "rbxassetid://80758916183665",
    Globe     = "rbxassetid://114238209622913",
    Home      = "rbxassetid://98755624629571",
    Swords    = "rbxassetid://81872698913435",
    Eye       = "rbxassetid://81973586053257",
}
NexusLib.Icons = TAB_ICONS

local TAB_KEY_MAP = {
    ["session"]  = TAB_ICONS.Dashboard,
    ["main"]     = TAB_ICONS.Dashboard,
    ["home"]     = TAB_ICONS.Home,
    ["routine"]  = TAB_ICONS.Fishing,
    ["fishing"]  = TAB_ICONS.Fishing,
    ["farming"]  = TAB_ICONS.Fishing,
    ["combat"]   = TAB_ICONS.Swords,
    ["aim"]      = TAB_ICONS.Swords,
    ["shop"]     = TAB_ICONS.Shop,
    ["store"]    = TAB_ICONS.Shop,
    ["exchange"] = TAB_ICONS.Exchange,
    ["quests"]   = TAB_ICONS.Quests,
    ["quest"]    = TAB_ICONS.Quests,
    ["upgrade"]  = TAB_ICONS.Upgrade,
    ["teleport"] = TAB_ICONS.Teleport,
    ["visual"]   = TAB_ICONS.Eye,
    ["esp"]      = TAB_ICONS.Eye,
    ["settings"] = TAB_ICONS.Settings,
    ["config"]   = TAB_ICONS.Settings,
    ["server"]   = TAB_ICONS.Globe,
    ["hop"]      = TAB_ICONS.Globe,
}

--------------------------------------------------------------------------
-- HELPERS
--------------------------------------------------------------------------
local function GetSafeGui(): Instance
    local tries = {
        function() return (gethui and gethui()) end,
        function()
            local test = Instance.new("Folder")
            test.Parent = CoreGui
            test:Destroy()
            return CoreGui
        end,
        function() return (LocalPlayer and LocalPlayer:WaitForChild("PlayerGui", 5)) end,
        function() return (Players.LocalPlayer and Players.LocalPlayer:WaitForChild("PlayerGui", 5)) end,
        function() return game:GetService("StarterGui") end,
    }
    for _, f in ipairs(tries) do
        local ok, gui = pcall(f)
        if ok and typeof(gui) == "Instance" then
            return gui
        end
    end
    return game:GetService("StarterGui")
end

local function Tween(instance, time, style, dir, props)
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(time or 0.28, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out),
        props
    )
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
        Color = color or Color3.fromRGB(255, 255, 255),
        Transparency = transparency,
        Thickness = 1,
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
    for k, v in pairs(props) do
        p[k] = v
    end
    return New("TextLabel", p)
end

--------------------------------------------------------------------------
-- 2K MATHEMATICAL SCANLINE MONOGRAM FALLBACK
--------------------------------------------------------------------------
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

local function drawNexusMonogram(container, size)
    local icon = Instance.new("Frame")
    icon.Name = "NexusMonogram"
    icon.AnchorPoint = Vector2.new(0.5, 0.5)
    icon.Position = UDim2.fromScale(0.5, 0.5)
    icon.Size = UDim2.fromScale(0.8, 0.8)
    icon.BackgroundTransparency = 1
    icon.Parent = container

    local step = 3
    for _, polygon in ipairs(NEXUS_POLYGONS) do
        for y = 0, 254, step do
            local scanY = y + step / 2
            local intersections = {}
            for i, a in ipairs(polygon) do
                local b = polygon[i % #polygon + 1]
                if (a.Y <= scanY and b.Y > scanY) or (b.Y <= scanY and a.Y > scanY) then
                    local x = a.X + (scanY - a.Y) * (b.X - a.X) / (b.Y - a.Y)
                    table.insert(intersections, x)
                end
            end
            table.sort(intersections)
            for i = 1, #intersections - 1, 2 do
                local left = intersections[i]
                local right = intersections[i + 1]
                local strip = Instance.new("Frame")
                strip.BorderSizePixel = 0
                strip.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                strip.Position = UDim2.fromScale(left / 256, y / 256)
                strip.Size = UDim2.fromScale((right - left) / 256, (step + 0.7) / 256)
                strip.Parent = icon
            end
        end
    end
    return icon
end

-- Sharp 2K Logo Component
local function Logo(parent, props)
    local container = New("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = parent,
    })
    for k, v in pairs(props or {}) do
        container[k] = v
    end

    local img = New("ImageLabel", {
        Name = "Logo2K",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Image = NEXUS_2K_ASSET,
        ImageColor3 = Theme.White,
        ScaleType = Enum.ScaleType.Fit,
        Parent = container,
    })

    -- Interactive Logo Animation (Hover scale & glow)
    local logoScale = New("UIScale", { Scale = 1, Parent = container })
    container.MouseEnter:Connect(function()
        Tween(logoScale, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Scale = 1.12 })
    end)
    container.MouseLeave:Connect(function()
        Tween(logoScale, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Scale = 1 })
    end)

    -- Fallback scanline if asset fails to load
    task.delay(1.5, function()
        if not img.IsLoaded and img.Parent then
            img.Visible = false
            drawNexusMonogram(container, container.AbsoluteSize.Y)
        end
    end)

    return container
end

--------------------------------------------------------------------------
-- SHARED SURFACE BUILDERS
--------------------------------------------------------------------------
local function Surface(class, props, radius)
    local p = {
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = Theme.SurfaceAlpha,
        BorderSizePixel = 0,
    }
    for k, v in pairs(props) do p[k] = v end
    return New(class, p, { Corner(radius or 14), Rim(Theme.StrokeAlpha) })
end

local function Soft(transparency)
    return { BackgroundColor3 = Theme.White, BackgroundTransparency = transparency, BorderSizePixel = 0 }
end

local function Merge(a, b)
    local out = {}
    for k, v in pairs(a) do out[k] = v end
    for k, v in pairs(b) do out[k] = v end
    return out
end

local function Button(parent, text, props)
    local b = New("TextButton", Merge(Soft(Theme.ControlAlpha), {
        AutoButtonColor = false,
        Text = text,
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
        TextColor3 = Theme.Text,
        Parent = parent,
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
    pcall(function() Blur.Parent = Lighting end)
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
        task.delay(0.5, function() pcall(function() Blur:Destroy() end) end)
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
    _G.NexusLib = NexusLib
shared.NexusLib = NexusLib
return NexusLib:PlayInkIntro(callback)
end

--------------------------------------------------------------------------
-- DYNAMIC ISLAND
--------------------------------------------------------------------------
local ISLAND_TOP, ISLAND_W, ISLAND_H = 14, 340, 40
local ISLAND_OPEN_W, ISLAND_OPEN_H = 400, 86

function NexusLib:CreateDynamicIsland(config)
    config = config or {}
    local Gui = New("ScreenGui", {
        Name = "Nexus_Island",
        DisplayOrder = 100000,
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        Parent = GetSafeGui(),
    })

    local Island = Surface("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, ISLAND_TOP),
        Size = UDim2.fromOffset(ISLAND_W, ISLAND_H),
        ClipsDescendants = true,
        ZIndex = 10,
        Parent = Gui,
    }, 20)
    local Bump = New("UIScale", { Scale = 0.85, Parent = Island })
    Tween(Bump, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Scale = 1 })

    local Bar = New("TextButton", {
        Size = UDim2.new(1, 0, 0, ISLAND_H),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 11,
        Parent = Island,
    })

    -- Container for Logo + Title + Status with UIListLayout (prevents text overlap)
    local LeftGroup = New("Frame", {
        Position = UDim2.fromOffset(12, 0),
        Size = UDim2.new(1, -150, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = 12,
        Parent = Bar,
    }, {
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    })

    Logo(LeftGroup, {
        Size = UDim2.fromOffset(18, 18),
        LayoutOrder = 1,
        ZIndex = 13,
    })

    Label(LeftGroup, {
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        Text = config.Title or "Nexus",
        LayoutOrder = 2,
        ZIndex = 13,
    })

    local Status = Label(LeftGroup, {
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = Theme.Dim,
        Text = config.Status or "Ready",
        LayoutOrder = 3,
        ZIndex = 13,
    })

    local Stats = Label(Bar, {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -32, 0, 0),
        Size = UDim2.new(0, 110, 1, 0),
        Font = Enum.Font.Code,
        TextSize = 10,
        TextColor3 = Theme.Dim,
        TextXAlignment = Enum.TextXAlignment.Right,
        Text = "60 fps · 0ms",
        ZIndex = 12,
    })

    local Caret = New("ImageLabel", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.fromOffset(10, 10),
        BackgroundTransparency = 1,
        Image = CHEVRON_ASSET,
        ImageColor3 = Theme.Faint,
        Rotation = 90, -- points down
        ZIndex = 12,
        Parent = Bar,
    })

    -- Drawer: Hide/Show UI + Test notify
    local Drawer = New("Frame", {
        Position = UDim2.fromOffset(10, ISLAND_H + 2),
        Size = UDim2.new(1, -20, 0, 30),
        BackgroundTransparency = 1,
        ZIndex = 11,
        Parent = Island,
    }, {
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    })
    local HideBtn = Button(Drawer, "Hide UI", { Size = UDim2.new(0.5, -3, 1, 0), LayoutOrder = 1, ZIndex = 12 })
    local TestBtn = Button(Drawer, "Test notify", {
        Size = UDim2.new(0.5, -3, 1, 0), LayoutOrder = 2, BackgroundTransparency = 1, ZIndex = 12,
    })
    Rim(Theme.StrokeAlpha).Parent = TestBtn

    local IslandApi = { Gui = Gui, Frame = Island, Expanded = false }
    NexusLib.ActiveIsland = IslandApi

    function IslandApi:SetExpanded(on)
        IslandApi.Expanded = on
        Tween(Island, 0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
            Size = on and UDim2.fromOffset(ISLAND_OPEN_W, ISLAND_OPEN_H) or UDim2.fromOffset(ISLAND_W, ISLAND_H),
        })
        Tween(Caret, 0.3, nil, nil, {
            Rotation = on and -90 or 90,
            ImageColor3 = on and Theme.Text or Theme.Faint,
        })
        if NexusLib.ActiveWindow then
            NexusLib.ActiveWindow:PushDown(on)
        end
    end

    function IslandApi:SetStatus(text)
        Status.TextTransparency = 1
        Status.Text = text
        Tween(Status, 0.3, nil, nil, { TextTransparency = 0 })
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

    Bar.MouseButton1Click:Connect(function()
        IslandApi:SetExpanded(not IslandApi.Expanded)
    end)

    Island.MouseEnter:Connect(function() Tween(Island.UIStroke, 0.2, nil, nil, { Transparency = 0.86 }) end)
    Island.MouseLeave:Connect(function() Tween(Island.UIStroke, 0.2, nil, nil, { Transparency = Theme.StrokeAlpha }) end)

    HideBtn.MouseButton1Click:Connect(function()
        if NexusLib.ActiveWindow then
            NexusLib.ActiveWindow:ToggleVisible()
        end
        IslandApi:SetExpanded(false)
    end)

    TestBtn.MouseButton1Click:Connect(function()
        NexusLib:Notify({ Title = "Nexus", Content = "Test notification from Dynamic Island" })
    end)

    -- Live FPS & Ping
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
local NOTE_W, NOTE_H, NOTE_MAX = 270, 58, 5
local NoteQueue = {}

function NexusLib:Notify(cfg)
    cfg = cfg or {}
    local duration = cfg.Duration or NexusLib.NotifyDuration or 3
    local parent = GetSafeGui()
    local Gui = parent:FindFirstChild("Nexus_Notifications")
    if not Gui then
        Gui = New("ScreenGui", {
            Name = "Nexus_Notifications",
            DisplayOrder = 100001,
            ResetOnSpawn = false,
            IgnoreGuiInset = true,
            Parent = parent,
        })
        New("Frame", {
            Name = "Stack",
            AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(1, -20, 1, -20),
            Size = UDim2.new(0, NOTE_W, 1, -40),
            BackgroundTransparency = 1,
            Parent = Gui,
        }, {
            New("UIListLayout", {
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
                Padding = UDim.new(0, 6),
                SortOrder = Enum.SortOrder.LayoutOrder,
            }),
        })
    end
    local Stack = Gui.Stack

    local Slot = New("Frame", {
        Size = UDim2.fromOffset(NOTE_W, 0),
        BackgroundTransparency = 1,
        LayoutOrder = math.floor(os.clock() * 1000),
        Parent = Stack,
    })
    local Card = Surface("CanvasGroup", {
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 28, 1, 0),
        Size = UDim2.fromOffset(NOTE_W, NOTE_H),
        GroupTransparency = 1,
        Parent = Slot,
    }, 12)

    Logo(Card, {
        Position = UDim2.fromOffset(12, 12),
        Size = UDim2.fromOffset(18, 18),
    })

    Label(Card, {
        Position = UDim2.fromOffset(38, 10),
        Size = UDim2.new(1, -50, 0, 16),
        Font = Enum.Font.GothamBold,
        Text = cfg.Title or "Nexus",
        TextTruncate = Enum.TextTruncate.AtEnd,
    })

    Label(Card, {
        Position = UDim2.fromOffset(38, 27),
        Size = UDim2.new(1, -50, 0, 16),
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = Theme.Dim,
        Text = cfg.Content or cfg.Text or "",
        TextTruncate = Enum.TextTruncate.AtEnd,
    })

    local Bar = New("Frame", Merge(Soft(0.65), {
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.fromScale(0, 1),
        Size = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = Theme.Accent,
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
            Position = UDim2.new(0, 28, 1, 0),
            GroupTransparency = 1,
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

    Tween(Slot, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, { Size = UDim2.fromOffset(NOTE_W, NOTE_H + 6) })
    Tween(Card, 0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Position = UDim2.new(0, 0, 1, 0), GroupTransparency = 0 })
    Tween(Bar, duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, { Size = UDim2.new(0, 0, 0, 2) })
    task.delay(duration, function() note:Close() end)
    return note
end

--------------------------------------------------------------------------
-- MOBILE FLOATING DRAGGABLE BUTTON
--------------------------------------------------------------------------
local function createMobileToggleButton(parentGui, window)
    local button = Instance.new("TextButton")
    button.Name = "NexusMobileToggle"
    button.Size = UDim2.fromOffset(46, 46)
    button.Position = UDim2.new(0, 20, 0.5, -23)
    button.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    button.BorderSizePixel = 0
    button.Text = ""
    button.AutoButtonColor = false
    button.ZIndex = 200
    button.Parent = parentGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(65, 65, 75)
    stroke.Thickness = 1
    stroke.Parent = button

    local icon = drawNexusMonogram(button, 28)
    icon.Size = UDim2.fromScale(0.55, 0.55)
    icon.ZIndex = 201
    for _, ch in ipairs(icon:GetChildren()) do
        if ch:IsA("GuiObject") then ch.ZIndex = 202 end
    end

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
            Tween(button, 0.15, nil, nil, { Size = UDim2.fromOffset(40, 40) })
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
        Tween(button, 0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Size = UDim2.fromOffset(46, 46) })

        if totalMoved < 8 then
            window:ToggleVisible()
            local isOpen = window.Visible
            Tween(stroke, 0.2, nil, nil, {
                Color = isOpen and Theme.Accent or Color3.fromRGB(65, 65, 75)
            })
        else
            local cam = workspace.CurrentCamera
            local vpWidth = cam and cam.ViewportSize.X or 800
            local curX = button.AbsolutePosition.X
            local snapX = 20
            if curX > vpWidth / 2 then
                snapX = vpWidth - 66
            end
            Tween(button, 0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
                Position = UDim2.new(0, snapX, button.Position.Y.Scale, button.Position.Y.Offset)
            })
        end
    end

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            onDragEnd()
        end
    end)

    return button
end

--------------------------------------------------------------------------
-- MAIN WINDOW
--------------------------------------------------------------------------
function NexusLib:CreateWindow(config)
    config = config or {}
    local size = config.Size or UDim2.fromOffset(NexusLib.DefaultWindowSize.X, NexusLib.DefaultWindowSize.Y)
    local homeY = ISLAND_TOP + ISLAND_H + 12

    -- Automatic Dynamic Island creation if enabled (default true)
    if config.Island ~= false and not NexusLib.ActiveIsland then
        NexusLib:CreateDynamicIsland({
            Title = config.Title or "Nexus",
            Status = "Ready",
        })
    end

    local Gui = New("ScreenGui", {
        Name = "Nexus_Window",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        Parent = GetSafeGui(),
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

    local Window = {
        Tabs = {},
        CurrentTab = nil,
        Gui = Gui,
        Frame = Frame,
        Visible = true,
        Pushed = false,
        IsOpen = true,
    }
    NexusLib.ActiveWindow = Window

    -- Dummy TabBar for compatibility
    Window.TabBar = {
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

    local savedPos = Frame.Position

    ---------------- TITLE BAR ----------------
    local TitleBar = New("Frame", {
        Size = UDim2.new(1, 0, 0, 46),
        BackgroundTransparency = 1,
        Parent = Frame,
    })
    New("Frame", Merge(Soft(1 - 0.08), {
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.fromScale(0, 1),
        Size = UDim2.new(1, 0, 0, 1),
        Parent = TitleBar,
    }))

    Logo(TitleBar, {
        Position = UDim2.fromOffset(16, 14),
        Size = UDim2.fromOffset(18, 18),
    })

    -- Title + Subtitle container using UIListLayout to prevent overlapping
    local TitleContainer = New("Frame", {
        Position = UDim2.fromOffset(42, 0),
        Size = UDim2.new(1, -90, 1, 0),
        BackgroundTransparency = 1,
        Parent = TitleBar,
    }, {
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    })

    local TitleText = Label(TitleContainer, {
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        Text = config.Title or "Nexus Hub",
        LayoutOrder = 1,
    })

    local subText = config.Subtitle or config.SubTitle or ""
    local Sub = Label(TitleContainer, {
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = Theme.Faint,
        Text = subText,
        LayoutOrder = 2,
    })

    -- Minimize Button
    local MinBtn = New("TextButton", Merge(Soft(1), {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.fromOffset(26, 26),
        AutoButtonColor = false,
        Text = "",
        Parent = TitleBar,
    }), { Corner(7) })

    local MinLine = New("Frame", Merge(Soft(0), {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(10, 2),
        BackgroundColor3 = Theme.Dim,
        Parent = MinBtn,
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

    -- Draggable Title Bar
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

    ---------------- SIDEBAR ----------------
    local Sidebar = New("Frame", {
        Position = UDim2.fromOffset(0, 46),
        Size = UDim2.new(0, 140, 1, -46),
        BackgroundTransparency = 1,
        Parent = Frame,
    })
    New("Frame", Merge(Soft(1 - 0.08), {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.fromScale(1, 0),
        Size = UDim2.new(0, 1, 1, 0),
        Parent = Sidebar,
    }))

    -- Glide pill indicator with spring bounce
    local Glide = New("Frame", Merge(Soft(Theme.ControlAlpha), {
        Position = UDim2.fromOffset(8, 10),
        Size = UDim2.new(1, -16, 0, 32),
        Visible = false,
        Parent = Sidebar,
    }), { Corner(8) })
    New("Frame", Merge(Soft(0), {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.fromScale(0, 0.5),
        Size = UDim2.fromOffset(2, 14),
        BackgroundColor3 = Theme.Accent,
        Parent = Glide,
    }), { Corner(1) })

    local TabScroll = New("ScrollingFrame", {
        Position = UDim2.fromOffset(8, 10),
        Size = UDim2.new(1, -16, 1, -20),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ClipsDescendants = true,
        Parent = Sidebar,
    }, {
        New("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }),
    })

    local PageHolder = New("Frame", {
        Position = UDim2.fromOffset(141, 46),
        Size = UDim2.new(1, -141, 1, -46),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = Frame,
    })

    ---------------- WINDOW METHODS ----------------
    function Window:SetVisible(on)
        if on == Window.Visible then return end
        Window.Visible = on
        Window.IsOpen = on
        local island = NexusLib.ActiveIsland
        if island then island:SetHiddenLabel(not on) end

        if on then
            Frame.Visible = true
            Tween(Frame, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
                Position = savedPos,
                GroupTransparency = 0,
            })
            Tween(Pop, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Scale = 1 })
            if island then island:SetStatus("Ready") end
        else
            savedPos = Frame.Position
            Tween(Frame, 0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In, {
                Position = UDim2.new(0.5, 0, 0, ISLAND_TOP),
                GroupTransparency = 1,
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
            NexusLib:Notify({ Title = "Nexus", Content = "Window hidden. Tap icon or press key to show." })
        end
    end

    function Window:ToggleVisible()
        Window:SetVisible(not Window.Visible)
    end
    function Window:Toggle()
        Window:ToggleVisible()
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
        _G.NexusLib = NexusLib
        shared.NexusLib = NexusLib
        return NexusLib:Notify(cfg)
    end

    function Window:Destroy()
        Gui:Destroy()
    end

    -- Toggle keybind
    local toggleKey = config.Keybind or config.ToggleKey or NexusLib.ToggleKey
    NexusLib.ToggleKey = toggleKey
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and not NexusLib.Listening and input.KeyCode == NexusLib.ToggleKey then
            Window:ToggleVisible()
        end
    end)

    -- Mobile floating button
    if config.MobileButton ~= false then
        local mobBtn = createMobileToggleButton(Gui, Window)
        Window.MobileButton = mobBtn
    end

    ---------------- TABS BUILDER ----------------
    function Window:CreateTab(nameOrConfig)
        local tabTitle, tabIcon, tabBadge
        if type(nameOrConfig) == "table" then
            tabTitle = tostring(nameOrConfig.Title or nameOrConfig.Name or "Tab")
            tabBadge = nameOrConfig.Badge
            tabIcon  = nameOrConfig.Icon
        else
            tabTitle = tostring(nameOrConfig or "Tab")
        end

        if not tabIcon or tabIcon == "" then
            local lower = string.lower(tabTitle)
            for k, ico in pairs(TAB_KEY_MAP) do
                if string.find(lower, k, 1, true) then
                    tabIcon = ico
                    break
                end
            end
        end

        local index = #Window.Tabs + 1

        local TabButton = New("TextButton", {
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
            LayoutOrder = index,
            ZIndex = 2,
            Parent = TabScroll,
        })

        local iconImg = nil
        local textOffsetX = 12
        if tabIcon and tabIcon ~= "" then
            iconImg = New("ImageLabel", {
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 10, 0.5, 0),
                Size = UDim2.fromOffset(14, 14),
                BackgroundTransparency = 1,
                Image = tabIcon,
                ImageColor3 = Theme.Dim,
                ZIndex = 3,
                Parent = TabButton,
            })
            textOffsetX = 30
        end

        local text = Label(TabButton, {
            Position = UDim2.fromOffset(textOffsetX, 0),
            Size = UDim2.new(1, -(textOffsetX + 4), 1, 0),
            Text = tabTitle,
            TextColor3 = Theme.Dim,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 3,
        })

        TabButton.MouseEnter:Connect(function()
            Tween(text, 0.15, nil, nil, { TextColor3 = Theme.Text })
            if iconImg then Tween(iconImg, 0.15, nil, nil, { ImageColor3 = Theme.Text }) end
        end)
        TabButton.MouseLeave:Connect(function()
            if Window.CurrentTab and Window.CurrentTab.Index ~= index then
                Tween(text, 0.15, nil, nil, { TextColor3 = Theme.Dim })
                if iconImg then Tween(iconImg, 0.15, nil, nil, { ImageColor3 = Theme.Dim }) end
            end
        end)

        local Page = New("ScrollingFrame", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Theme.White,
            ScrollBarImageTransparency = 0.85,
            CanvasSize = UDim2.new(),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            Parent = PageHolder,
        }, {
            New("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }),
            New("UIPadding", {
                PaddingTop = UDim.new(0, 8),
                PaddingLeft = UDim.new(0, 14),
                PaddingRight = UDim.new(0, 14),
                PaddingBottom = UDim.new(0, 14),
            }),
        })

        local Tab = {
            Button = TabButton,
            Label = text,
            Icon = iconImg,
            Page = Page,
            Index = index,
            Title = tabTitle,
            Window = Window,
        }

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
                if other.Icon then Tween(other.Icon, 0.2, nil, nil, { ImageColor3 = Theme.Dim }) end
            end

            local y = 10 + (index - 1) * 34
            if Glide.Visible then
                Tween(Glide, 0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Position = UDim2.fromOffset(8, y) })
            else
                Glide.Position = UDim2.fromOffset(8, y)
                Glide.Visible = true
            end

            Tween(text, 0.2, nil, nil, { TextColor3 = Theme.Text })
            if iconImg then Tween(iconImg, 0.2, nil, nil, { ImageColor3 = Theme.White }) end

            local dir = (prev and prev.Index > index) and -1 or 1
            Page.Position = UDim2.fromOffset(18 * dir, 0)
            Page.Visible = true
            Tween(Page, 0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, { Position = UDim2.fromOffset(0, 0) })
            Window.CurrentTab = Tab
        end

        TabButton.MouseButton1Click:Connect(function() Tab:Select() end)

        function Tab:SetTitle(newTitle)
            Tab.Title = tostring(newTitle)
            text.Text = tostring(newTitle)
        end
        function Tab:SetIcon(newIcon)
            if iconImg then
                iconImg.Image = newIcon
            end
        end
        function Tab:SetBadge(count) end

        -- Row builder
        local function Item(cfg, rightWidth)
            local hasDesc = cfg.Description ~= nil and cfg.Description ~= ""
            local h = hasDesc and 46 or 42
            local row = New("Frame", Merge(Soft(Theme.RowAlpha), {
                Size = UDim2.new(1, 0, 0, h),
                LayoutOrder = nextOrder(),
                Parent = Page,
            }), { Corner(9) })

            local w = -(24 + (rightWidth or 110))
            Label(row, {
                Position = UDim2.fromOffset(12, hasDesc and 8 or 0),
                Size = UDim2.new(1, w, 0, hasDesc and 16 or h),
                Text = cfg.Name or cfg.Title or "Item",
                TextTruncate = Enum.TextTruncate.AtEnd,
            })
            if hasDesc then
                Label(row, {
                    Position = UDim2.fromOffset(12, 24),
                    Size = UDim2.new(1, w, 0, 14),
                    Font = Enum.Font.Gotham,
                    TextSize = 10,
                    TextColor3 = Theme.Dim,
                    Text = cfg.Description,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                })
            end
            local right = New("Frame", {
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -10, 0.5, 0),
                Size = UDim2.fromOffset(rightWidth or 110, 28),
                BackgroundTransparency = 1,
                Parent = row,
            })
            return row, right
        end

        local function Hover(row, hit)
            hit.MouseEnter:Connect(function() Tween(row, 0.15, nil, nil, { BackgroundTransparency = Theme.RowHoverAlpha }) end)
            hit.MouseLeave:Connect(function() Tween(row, 0.15, nil, nil, { BackgroundTransparency = Theme.RowAlpha }) end)
        end

        ---------------- COMPONENTS ----------------
        function Tab:CreateSection(title)
            return Label(Page, {
                Size = UDim2.new(1, 0, 0, 26),
                Text = string.upper(tostring(title or "SECTION")),
                TextSize = 10,
                Font = Enum.Font.GothamBold,
                TextColor3 = Theme.Faint,
                TextYAlignment = Enum.TextYAlignment.Bottom,
                LayoutOrder = nextOrder(),
            })
        end

        function Tab:CreateHeader(title)
            return Tab:CreateSection(title)
        end

        function Tab:CreateLabel(textOrCfg)
            local t = type(textOrCfg) == "table" and (textOrCfg.Text or textOrCfg.Name or "") or tostring(textOrCfg)
            local row = New("Frame", Merge(Soft(Theme.RowAlpha), {
                Size = UDim2.new(1, 0, 0, 36),
                LayoutOrder = nextOrder(),
                Parent = Page,
            }), { Corner(9) })
            local lbl = Label(row, {
                Position = UDim2.fromOffset(12, 0),
                Size = UDim2.new(1, -24, 1, 0),
                Text = t,
                TextColor3 = Theme.Dim,
                TextTruncate = Enum.TextTruncate.AtEnd,
            })
            local handle = { _frame = row }
            function handle:SetText(val) lbl.Text = tostring(val) end
            function handle:Set(val) lbl.Text = tostring(val) end
            return handle
        end

        function Tab:CreateToggle(cfg)
            cfg = cfg or {}
            local state = cfg.Default or false
            local row, right = Item(cfg, 34)

            local track = New("Frame", Merge(Soft(state and 0 or 0.88), {
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, 0, 0.5, 0),
                Size = UDim2.fromOffset(32, 18),
                BackgroundColor3 = state and Theme.Text or Theme.White,
                Parent = right,
            }), { Corner(9) })

            local knob = New("Frame", {
                AnchorPoint = Vector2.new(0, 0.5),
                Position = state and UDim2.new(0, 16, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
                Size = UDim2.fromOffset(14, 14),
                BackgroundColor3 = state and Theme.Surface or Theme.Knob,
                BorderSizePixel = 0,
                Parent = track,
            }, { Corner(7) })

            local Toggle = { _frame = row }
            function Toggle:Set(selfOrVal, maybeVal, silent)
                local value = (maybeVal ~= nil) and maybeVal or selfOrVal
                state = not not value
                Tween(track, 0.22, nil, nil, {
                    BackgroundColor3 = state and Theme.Text or Theme.White,
                    BackgroundTransparency = state and 0 or 0.88,
                })
                Tween(knob, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
                    Position = state and UDim2.new(0, 16, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
                    BackgroundColor3 = state and Theme.Surface or Theme.Knob,
                })
                if not silent and cfg.Callback then task.spawn(cfg.Callback, state) end
            end
            Toggle.SetValue = Toggle.Set
            function Toggle:Get() return state end

            local hit = New("TextButton", {
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 3,
                Parent = row,
            })
            hit.MouseButton1Click:Connect(function() Toggle:Set(not state) end)
            Hover(row, hit)
            return Toggle
        end

        function Tab:CreateSlider(cfg)
            cfg = cfg or {}
            local min = cfg.Min or 0
            local max = cfg.Max or 100
            local step = cfg.Step or cfg.Increment or 1
            if max < min then min, max = max, min end
            local value = math.clamp(cfg.Default or min, min, max)
            local row, right = Item(cfg, 180)

            local valueLabel = Label(right, {
                Size = UDim2.new(0, 34, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Right,
                Font = Enum.Font.Code,
                TextSize = 10,
                TextColor3 = Theme.Dim,
                Text = tostring(value) .. (cfg.Suffix or ""),
            })

            local hit = New("TextButton", {
                Position = UDim2.fromOffset(42, 0),
                Size = UDim2.new(1, -42, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                Parent = right,
            })
            local track = New("Frame", Merge(Soft(0.88), {
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.fromScale(0, 0.5),
                Size = UDim2.new(1, 0, 0, 3),
                Parent = hit,
            }), { Corner(2) })

            local fill = New("Frame", {
                Size = UDim2.fromScale((value - min) / (max - min), 1),
                BackgroundColor3 = Theme.Text,
                BorderSizePixel = 0,
                Parent = track,
            }, { Corner(2) })

            local knob = New("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale((value - min) / (max - min), 0.5),
                Size = UDim2.fromOffset(12, 12),
                BackgroundColor3 = Theme.White,
                BorderSizePixel = 0,
                Parent = track,
            }, { Corner(6) })

            local Slider = { _frame = row }
            function Slider:Set(selfOrVal, maybeVal, silent)
                local v = (maybeVal ~= nil) and maybeVal or selfOrVal
                v = math.clamp(math.floor((v - min) / step + 0.5) * step + min, min, max)
                value = v
                local p = (v - min) / (max - min)
                Tween(fill, 0.08, nil, nil, { Size = UDim2.fromScale(p, 1) })
                Tween(knob, 0.08, nil, nil, { Position = UDim2.fromScale(p, 0.5) })
                valueLabel.Text = tostring(v) .. (cfg.Suffix or "")
                if not silent and cfg.Callback then task.spawn(cfg.Callback, v) end
            end
            Slider.SetValue = Slider.Set
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
            local row, right = Item(cfg, 72)
            local b = Button(right, cfg.Text or "Run", {
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, 0, 0.5, 0),
                Size = UDim2.fromOffset(72, 28),
            })
            b.MouseButton1Click:Connect(function()
                if cfg.Callback then task.spawn(cfg.Callback) end
            end)
            return { _frame = row }
        end

        function Tab:CreateInput(cfg)
            cfg = cfg or {}
            local row, right = Item(cfg, 150)
            local box = New("TextBox", Merge(Soft(Theme.ControlAlpha), {
                Size = UDim2.fromScale(1, 1),
                Text = cfg.Default or "",
                PlaceholderText = cfg.Placeholder or "Type...",
                PlaceholderColor3 = Theme.Faint,
                Font = Enum.Font.Gotham,
                TextSize = 11,
                TextColor3 = Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false,
                Parent = right,
            }), { Corner(7), New("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }) })

            local stroke = Rim(1)
            stroke.Parent = box
            box.Focused:Connect(function() Tween(stroke, 0.15, nil, nil, { Transparency = 0.86 }) end)
            box.FocusLost:Connect(function(enter)
                Tween(stroke, 0.15, nil, nil, { Transparency = 1 })
                if enter and box.Text ~= "" and cfg.Callback then
                    task.spawn(cfg.Callback, box.Text)
                    if cfg.ClearOnSubmit then box.Text = "" end
                end
            end)

            local Input = { _frame = row }
            function Input:Set(selfOrVal, maybeVal)
                local v = (maybeVal ~= nil) and maybeVal or selfOrVal
                box.Text = tostring(v)
            end
            Input.SetValue = Input.Set
            function Input:Get() return box.Text end
            return Input
        end

        function Tab:CreateTextbox(cfg)
            return Tab:CreateInput(cfg)
        end

        function Tab:CreateDropdown(cfg)
            cfg = cfg or {}
            local options = cfg.Options or {}
            local value = cfg.Default or options[1] or "Select"
            local row, right = Item(cfg, 120)

            local field = Button(right, "", { Size = UDim2.fromScale(1, 1) })
            local valueLabel = Label(field, {
                Position = UDim2.fromOffset(10, 0),
                Size = UDim2.new(1, -28, 1, 0),
                TextSize = 11,
                Text = tostring(value),
                TextTruncate = Enum.TextTruncate.AtEnd,
            })
            local arrow = New("ImageLabel", {
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -8, 0.5, 0),
                Size = UDim2.fromOffset(10, 10),
                BackgroundTransparency = 1,
                Image = CHEVRON_ASSET,
                ImageColor3 = Theme.Dim,
                Rotation = 90, -- points down
                Parent = field,
            })

            local menu, closeConn
            local function close()
                if closeConn then closeConn:Disconnect() closeConn = nil end
                Tween(arrow, 0.25, nil, nil, { Rotation = 90 })
                if menu then
                    local m = menu
                    menu = nil
                    Tween(m, 0.18, nil, nil, { Size = UDim2.fromOffset(m.Size.X.Offset, 0) })
                    task.delay(0.2, function() m:Destroy() end)
                end
            end

            local function set(v, emit)
                value = v
                valueLabel.Text = tostring(v)
                if emit ~= false and cfg.Callback then task.spawn(cfg.Callback, v) end
            end

            field.MouseButton1Click:Connect(function()
                if menu then close() return end
                Tween(arrow, 0.25, nil, nil, { Rotation = -90 })
                local width = math.max(130, field.AbsoluteSize.X)
                local maxVisible = math.min(6, #options)
                local height = maxVisible * 28 + 8

                menu = New("Frame", {
                    Position = UDim2.fromOffset(field.AbsolutePosition.X + field.AbsoluteSize.X - width, field.AbsolutePosition.Y + field.AbsoluteSize.Y + 6),
                    Size = UDim2.fromOffset(width, 0),
                    BackgroundColor3 = Theme.Menu,
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                    ZIndex = 50,
                    Parent = Gui,
                }, {
                    Corner(9),
                    Rim(Theme.StrokeAlpha),
                    New("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4) }),
                })

                local scrollList = New("ScrollingFrame", {
                    Size = UDim2.fromScale(1, 1),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = Theme.White,
                    ScrollBarImageTransparency = 0.8,
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    ZIndex = 51,
                    Parent = menu,
                }, {
                    New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2) }),
                })

                Tween(menu, 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, { Size = UDim2.fromOffset(width, height) })

                for i, option in ipairs(options) do
                    local selected = (option == value)
                    local item = New("TextButton", Merge(Soft(selected and Theme.ControlAlpha or 1), {
                        Size = UDim2.new(1, 0, 0, 26),
                        AutoButtonColor = false,
                        Text = tostring(option),
                        Font = Enum.Font.GothamMedium,
                        TextSize = 11,
                        TextColor3 = selected and Theme.Accent or Theme.Dim,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        LayoutOrder = i,
                        ZIndex = 52,
                        Parent = scrollList,
                    }), { Corner(6), New("UIPadding", { PaddingLeft = UDim.new(0, 10) }) })

                    item.MouseEnter:Connect(function()
                        Tween(item, 0.1, nil, nil, { BackgroundTransparency = Theme.ControlAlpha, TextColor3 = Theme.Text })
                    end)
                    item.MouseLeave:Connect(function()
                        Tween(item, 0.1, nil, nil, {
                            BackgroundTransparency = selected and Theme.ControlAlpha or 1,
                            TextColor3 = selected and Theme.Accent or Theme.Dim,
                        })
                    end)
                    item.MouseButton1Click:Connect(function()
                        set(option, true)
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

            local Dropdown = { _frame = row }
            function Dropdown:Set(selfOrVal, maybeVal, emit)
                local v = (maybeVal ~= nil) and maybeVal or selfOrVal
                set(v, emit ~= false)
            end
            Dropdown.SetValue = Dropdown.Set
            function Dropdown:Get() return value end
            return Dropdown
        end

        function Tab:CreateMultiDropdown(cfg)
            cfg = cfg or {}
            local options = cfg.Options or {}
            local selectedMap = {}
            for _, v in ipairs(cfg.Default or {}) do
                selectedMap[v] = true
            end
            local row, right = Item(cfg, 140)

            local function getSummary()
                local list = {}
                for _, opt in ipairs(options) do
                    if selectedMap[opt] then table.insert(list, opt) end
                end
                if #list == 0 then return "None" end
                if #list <= 2 then return table.concat(list, ", ") end
                return list[1] .. ", " .. list[2] .. " +" .. tostring(#list - 2)
            end

            local field = Button(right, "", { Size = UDim2.fromScale(1, 1) })
            local valueLabel = Label(field, {
                Position = UDim2.fromOffset(10, 0),
                Size = UDim2.new(1, -28, 1, 0),
                TextSize = 10,
                Text = getSummary(),
                TextTruncate = Enum.TextTruncate.AtEnd,
            })
            local arrow = New("ImageLabel", {
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -8, 0.5, 0),
                Size = UDim2.fromOffset(10, 10),
                BackgroundTransparency = 1,
                Image = CHEVRON_ASSET,
                ImageColor3 = Theme.Dim,
                Rotation = 90,
                Parent = field,
            })

            local menu, closeConn
            local function close()
                if closeConn then closeConn:Disconnect() closeConn = nil end
                Tween(arrow, 0.25, nil, nil, { Rotation = 90 })
                if menu then
                    local m = menu
                    menu = nil
                    Tween(m, 0.18, nil, nil, { Size = UDim2.fromOffset(m.Size.X.Offset, 0) })
                    task.delay(0.2, function() m:Destroy() end)
                end
            end

            local function emitCallback()
                local out = {}
                for _, opt in ipairs(options) do
                    if selectedMap[opt] then table.insert(out, opt) end
                end
                valueLabel.Text = getSummary()
                if cfg.Callback then task.spawn(cfg.Callback, out) end
            end

            field.MouseButton1Click:Connect(function()
                if menu then close() return end
                Tween(arrow, 0.25, nil, nil, { Rotation = -90 })
                local width = math.max(140, field.AbsoluteSize.X)
                local maxVisible = math.min(6, #options)
                local height = maxVisible * 28 + 8

                menu = New("Frame", {
                    Position = UDim2.fromOffset(field.AbsolutePosition.X + field.AbsoluteSize.X - width, field.AbsolutePosition.Y + field.AbsoluteSize.Y + 6),
                    Size = UDim2.fromOffset(width, 0),
                    BackgroundColor3 = Theme.Menu,
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                    ZIndex = 50,
                    Parent = Gui,
                }, {
                    Corner(9),
                    Rim(Theme.StrokeAlpha),
                    New("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4) }),
                })

                local scrollList = New("ScrollingFrame", {
                    Size = UDim2.fromScale(1, 1),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = Theme.White,
                    ScrollBarImageTransparency = 0.8,
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    ZIndex = 51,
                    Parent = menu,
                }, {
                    New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2) }),
                })

                Tween(menu, 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, { Size = UDim2.fromOffset(width, height) })

                for i, option in ipairs(options) do
                    local isSel = selectedMap[option] == true
                    local item = New("TextButton", Merge(Soft(isSel and Theme.ControlAlpha or 1), {
                        Size = UDim2.new(1, 0, 0, 26),
                        AutoButtonColor = false,
                        Text = (isSel and "✓  " or "    ") .. tostring(option),
                        Font = Enum.Font.GothamMedium,
                        TextSize = 11,
                        TextColor3 = isSel and Theme.Accent or Theme.Dim,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        LayoutOrder = i,
                        ZIndex = 52,
                        Parent = scrollList,
                    }), { Corner(6), New("UIPadding", { PaddingLeft = UDim.new(0, 8) }) })

                    item.MouseButton1Click:Connect(function()
                        selectedMap[option] = not selectedMap[option]
                        local nowSel = selectedMap[option] == true
                        item.Text = (nowSel and "✓  " or "    ") .. tostring(option)
                        item.TextColor3 = nowSel and Theme.Accent or Theme.Dim
                        Tween(item, 0.1, nil, nil, { BackgroundTransparency = nowSel and Theme.ControlAlpha or 1 })
                        emitCallback()
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

            local MultiDropdown = { _frame = row }
            function MultiDropdown:Set(selfOrList, maybeList)
                local list = (maybeList ~= nil) and maybeList or selfOrList
                selectedMap = {}
                for _, v in ipairs(list or {}) do selectedMap[v] = true end
                emitCallback()
            end
            MultiDropdown.SetValue = MultiDropdown.Set
            function MultiDropdown:Get()
                local out = {}
                for _, opt in ipairs(options) do
                    if selectedMap[opt] then table.insert(out, opt) end
                end
                return out
            end
            return MultiDropdown
        end

        function Tab:CreateKeybind(cfg)
            cfg = cfg or {}
            local key = cfg.Default or Enum.KeyCode.RightShift
            local row, right = Item(cfg, 96)
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

            local Keybind = { _frame = row }
            function Keybind:Get() return key end
            function Keybind:Set(selfOrKey, maybeKey)
                local k = (maybeKey ~= nil) and maybeKey or selfOrKey
                key = k
                field.Text = key.Name
            end
            Keybind.SetValue = Keybind.Set
            return Keybind
        end

        function Tab:CreateActionRow(cfg)
            return Tab:CreateButton(cfg)
        end

        function Tab:CreateStatRow(title, value)
            local row = New("Frame", Merge(Soft(Theme.RowAlpha), {
                Size = UDim2.new(1, 0, 0, 36),
                LayoutOrder = nextOrder(),
                Parent = Page,
            }), { Corner(9) })
            Label(row, {
                Position = UDim2.fromOffset(12, 0),
                Size = UDim2.new(0.5, -12, 1, 0),
                Text = tostring(title),
                TextColor3 = Theme.Dim,
            })
            local valLbl = Label(row, {
                Position = UDim2.new(0.5, 0, 0, 0),
                Size = UDim2.new(0.5, -12, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Right,
                Font = Enum.Font.GothamBold,
                TextColor3 = Theme.Text,
                Text = tostring(value or ""),
            })
            local handle = { _frame = row }
            function handle:SetValue(val) valLbl.Text = tostring(val) end
            function handle:Set(val) valLbl.Text = tostring(val) end
            return handle
        end

        function Tab:CreateBlock(title, desc)
            return Tab:CreateLabel({ Text = tostring(title) .. (desc and (" - " .. tostring(desc)) or "") })
        end

        function Tab:CreateCardGroup(title)
            return Tab:CreateSection(title)
        end

        function Tab:CreateFeaturedCard(cfg)
            return Tab:CreateSection(cfg and cfg.Title or "FEATURED")
        end

        table.insert(Window.Tabs, Tab)
        if index == 1 then
            Tab:Select()
        end
        return Tab
    end

    table.insert(NexusLib._windows, Window)

    -- Auto-play Ink-Swirl Intro and show Welcome Notify when script opens
    if config.Intro ~= false and not NexusLib._introPlayed then
        NexusLib._introPlayed = true
        Frame.Visible = false
        if Window.MobileButton then Window.MobileButton.Visible = false end
        if NexusLib.ActiveIsland then NexusLib.ActiveIsland.Frame.Visible = false end

        NexusLib:PlayInkIntro(function()
            if NexusLib.ActiveIsland then
                NexusLib.ActiveIsland.Frame.Visible = true
            end
            Frame.Visible = true
            if Window.MobileButton then Window.MobileButton.Visible = true end
            Window:SetVisible(true)
            NexusLib:Notify({
                Title = config.Title or "Nexus Hub",
                Content = (config.Subtitle or config.SubTitle or "Universal") .. " · Loaded",
                Duration = 6,
            })
        end)
    else
        task.defer(function()
            NexusLib:Notify({
                Title = config.Title or "Nexus Hub",
                Content = (config.Subtitle or config.SubTitle or "Universal") .. " · Loaded",
                Duration = 6,
            })
        end)
    end

    return Window
end

--------------------------------------------------------------------------
-- DEMO (Full Showcase)
--------------------------------------------------------------------------
function NexusLib:Demo()
    NexusLib:PlayInkIntro(function()
        local Island = NexusLib:CreateDynamicIsland({ Title = "Nexus", Status = "Farming" })
        local Window = NexusLib:CreateWindow({
            Title = "Nexus Hub",
            Subtitle = "Universal Edition",
            Size = UDim2.fromOffset(640, 420),
            MobileButton = true,
        })

        local function note(title, on)
            NexusLib:Notify({ Title = title, Content = on and "Enabled" or "Disabled" })
        end

        -- MAIN TAB
        local Main = Window:CreateTab({ Title = "Main", Icon = TAB_ICONS.Dashboard })
        Main:CreateSection("Automation")
        Main:CreateToggle({
            Name = "Auto farm",
            Description = "Attacks the nearest enemy automatically",
            Default = true,
            Callback = function(on)
                Island:SetStatus(on and "Farming" or "Ready")
                note("Auto farm", on)
            end,
        })
        Main:CreateToggle({
            Name = "Kill aura",
            Description = "Hits everything in weapon reach",
            Default = false,
            Callback = function(on) note("Kill aura", on) end,
        })
        Main:CreateDropdown({
            Name = "Target priority",
            Options = { "Nearest", "Lowest HP", "Highest Level", "Boss Only" },
            Default = "Nearest",
            Callback = function(v) NexusLib:Notify({ Title = "Target Priority", Content = v }) end,
        })
        Main:CreateMultiDropdown({
            Name = "Filter mobs",
            Options = { "Common", "Rare", "Elite", "Boss", "Event" },
            Default = { "Rare", "Elite", "Boss" },
            Callback = function(list) NexusLib:Notify({ Title = "Filter", Content = table.concat(list, ", ") }) end,
        })

        Main:CreateSection("Player & Movement")
        Main:CreateSlider({
            Name = "Walk speed",
            Min = 16,
            Max = 250,
            Default = 16,
            Suffix = " ws",
            Callback = function(v)
                pcall(function()
                    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum.WalkSpeed = v end
                end)
            end,
        })
        Main:CreateInput({
            Name = "Teleport to player",
            Description = "Type player name and hit Enter",
            Placeholder = "Username...",
            Callback = function(name)
                local target = Players:FindFirstChild(name)
                local root = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
                local mine = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if root and mine then
                    mine.CFrame = root.CFrame * CFrame.new(0, 0, 3)
                    NexusLib:Notify({ Title = "Teleport", Content = "Teleported to " .. name })
                else
                    NexusLib:Notify({ Title = "Teleport", Content = "Player not found: " .. name })
                end
            end,
        })
        Main:CreateButton({
            Name = "Reset character",
            Text = "Reset",
            Callback = function()
                pcall(function()
                    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum.Health = 0 end
                end)
            end,
        })

        -- COMBAT TAB
        local Combat = Window:CreateTab({ Title = "Combat", Icon = TAB_ICONS.Swords })
        Combat:CreateSection("Aim & Weapon")
        Combat:CreateToggle({ Name = "Silent aim", Description = "Redirects bullets/hits to target head", Default = true })
        Combat:CreateDropdown({ Name = "Aim target part", Options = { "Head", "Torso", "HumanoidRootPart" }, Default = "Head" })
        Combat:CreateSlider({ Name = "Hitbox expansion", Description = "Studs", Min = 2, Max = 60, Default = 14, Suffix = " studs" })
        Combat:CreateSection("Defense")
        Combat:CreateToggle({ Name = "Auto parry / block", Description = "Detects enemy swing animation" })

        -- VISUAL TAB
        local Visual = Window:CreateTab({ Title = "Visual", Icon = TAB_ICONS.Eye })
        Visual:CreateSection("ESP Options")
        Visual:CreateToggle({ Name = "Player boxes", Default = true })
        Visual:CreateToggle({ Name = "Chams highlight", Description = "Glow through walls" })
        Visual:CreateToggle({ Name = "Tracers", Default = false })
        Visual:CreateSection("Camera")
        Visual:CreateSlider({
            Name = "Field of view",
            Min = 70,
            Max = 120,
            Default = 70,
            Suffix = "°",
            Callback = function(v) workspace.CurrentCamera.FieldOfView = v end,
        })

        -- SETTINGS TAB
        local Settings = Window:CreateTab({ Title = "Settings", Icon = TAB_ICONS.Settings })
        Settings:CreateSection("Keybinds & Controls")
        Settings:CreateKeybind({
            Name = "Menu keybind",
            Description = "Click and press any key to rebind",
            Default = NexusLib.ToggleKey,
            Callback = function(key)
                NexusLib.ToggleKey = key
                NexusLib:Notify({ Title = "Keybind Changed", Content = "Menu key set to " .. key.Name })
            end,
        })
        Settings:CreateSlider({
            Name = "Notification duration",
            Description = "Seconds on screen",
            Min = 1,
            Max = 8,
            Default = 3,
            Suffix = "s",
            Callback = function(v) NexusLib.NotifyDuration = v end,
        })
        Settings:CreateSection("Configuration")
        Settings:CreateButton({
            Name = "Save configuration",
            Text = "Save",
            Callback = function() NexusLib:Notify({ Title = "Config", Content = "Settings saved to profile." }) end,
        })

        NexusLib:Notify({ Title = "Nexus Loaded", Content = "Welcome to Nexus UI! Tap floating button or use menu key." })
    end)
end

_G.NexusLib = NexusLib
shared.NexusLib = NexusLib
return NexusLib
