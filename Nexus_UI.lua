--[[
    NEXUS UI  -  single-file Luau UI library (Roblox executors)

    Everything is in this one file: the ink-swirl intro, the Dynamic Island,
    the window, tabs, and every element. The logo is embedded (no uploads).

    Quick start:
        local Nexus = loadstring(readfile("Nexus_UI.lua"))()   -- or game:HttpGet(...)
        Nexus:Demo()                                            -- full sample UI

    Or build your own:
        Nexus:PlayInkIntro(function()
            local Island = Nexus:CreateDynamicIsland({ Title = "Nexus" })
            local Window = Nexus:CreateWindow({ Title = "Nexus Hub", SubTitle = "Universal" })

            local Main = Window:CreateTab("Main")
            Main:CreateSection("Automation")
            Main:CreateToggle({ Name = "Auto farm", Description = "Attacks the nearest enemy",
                Default = true, Callback = function(on) end })
            Main:CreateSlider({ Name = "Walk speed", Min = 16, Max = 200, Default = 16, Callback = function(v) end })
            Main:CreateDropdown({ Name = "Target", Options = { "Nearest", "Boss" }, Callback = function(v) end })
            Main:CreateInput({ Name = "Player", Placeholder = "Username", Callback = function(text) end })
            Main:CreateKeybind({ Name = "Key", Default = Enum.KeyCode.F, Callback = function(key) end })
            Main:CreateButton({ Name = "Return to spawn", Text = "Go", Callback = function() end })

            Nexus:Notify({ Title = "Nexus", Content = "Loaded", Duration = 3 })
        end)

    The island, window and notifications share one surface (Theme.Surface).
    Hide UI (island drawer, the minimize button or ToggleKey) flies the window into the island.
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
        Surface      = Color3.fromRGB(17, 17, 20),   -- rgba(17,17,20,0.88)
        SurfaceAlpha = 0.12,
        StrokeAlpha  = 0.92,                         -- white @ 8%
        RowAlpha     = 0.965,
        RowHoverAlpha = 0.94,
        ControlAlpha = 0.93,
        ControlHoverAlpha = 0.89,
        Menu    = Color3.fromRGB(24, 24, 28),
        Knob    = Color3.fromRGB(142, 142, 150),
        Text    = Color3.fromRGB(237, 237, 239),
        Dim     = Color3.fromRGB(138, 138, 146),
        Faint   = Color3.fromRGB(90, 90, 98),
        White   = Color3.fromRGB(255, 255, 255),
    },
    ToggleKey = Enum.KeyCode.RightShift,
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
    for k, v in pairs(props) do
        p[k] = v
    end
    return New("TextLabel", p)
end

--------------------------------------------------------------------------
-- embedded logo (white N, 160px PNG). Written to disk once and loaded with
-- getcustomasset. Falls back to a plain "N" if the executor has no file API.
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

-- logo image (or a bold "N" when files are unavailable)
local function Logo(parent, props)
    local asset = GetLogoAsset()
    if asset ~= "" then
        local p = { BackgroundTransparency = 1, Image = asset, ScaleType = Enum.ScaleType.Fit, Parent = parent }
        for k, v in pairs(props) do p[k] = v end
        return New("ImageLabel", p)
    end
    local p = {
        BackgroundTransparency = 1, Text = "N", Font = Enum.Font.GothamBlack,
        TextColor3 = Theme.White, TextScaled = true, Parent = parent,
    }
    for k, v in pairs(props) do p[k] = v end
    return New("TextLabel", p)
end

--------------------------------------------------------------------------
-- INK SWIRL INTRO
-- Two ink strokes spiral in, orbit as a ring, shrink to two dots; the left dot
-- becomes the Dynamic Island, the right one grows into the window. Click to skip.
--------------------------------------------------------------------------
function NexusLib:PlayInkIntro(callback)
    local TAU = math.pi * 2
    local K = TAU * 0.9                          -- angular travel per unit of path
    local S0 = 0.2                               -- initial head position on the spiral
    local PHI0 = { -0.75 * math.pi, 0.25 * math.pi }
    local S_END = (1.75 * math.pi + TAU) / K     -- strokes rest on left / right
    local POINTS = 24
    local RING = 46

    -- Timeline (seconds)
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
    local ISLAND_BG = Theme.Surface               -- same surface as island + window
    local SQUARE_BG = Color3.fromRGB(32, 32, 36)
    local WINDOW_BG = Theme.Surface

    local IntroGui = Instance.new("ScreenGui")
    IntroGui.Name = "Nexus_InkIntro"
    IntroGui.DisplayOrder = 999999
    IntroGui.ResetOnSpawn = false
    IntroGui.IgnoreGuiInset = true
    IntroGui.Parent = GetSafeGui()

    -- Blur the game behind the intro
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

    -- Layout targets (must match CreateDynamicIsland / CreateWindow)
    local camera = workspace.CurrentCamera
    local vp = camera and camera.ViewportSize or Vector2.new(1280, 720)
    local cx, cy = vp.X / 2, vp.Y * 0.46
    local R0 = math.max(vp.X, vp.Y) * 0.6
    local winSize = NexusLib.DefaultWindowSize
    local win = { cx = vp.X / 2, cy = 66 + winSize.Y / 2, w = winSize.X, h = winSize.Y }
    local isl = { cx = vp.X / 2, cy = 14 + 20, w = 340, h = 40 }

    -- Stroke segments (tapered capsules chained along the spiral)
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
            -- Phase 1+2: spiral in, orbit as a ring, shrink toward two dots
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

            -- Phase 3: two dots grow
            local d = lerp(9, 18, easeOutCubic(clamp01((t - T_SPIN) / (T_GROW - T_SPIN))))
            local gap = 16

            -- Left blob: stretches, flies up and becomes the island pill
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

            -- Right blob: rounded square, then expands into the window
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

        -- Phase 4: build the real UI underneath, fade the blobs away
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
-- shared surface (island, window and notifications all use this)
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

-- small flat button used in the island drawer and inside rows
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
-- DYNAMIC ISLAND
--------------------------------------------------------------------------
local ISLAND_TOP, ISLAND_W, ISLAND_H = 14, 340, 40
local ISLAND_OPEN_W, ISLAND_OPEN_H = 400, 86

function NexusLib:CreateDynamicIsland(config)
    config = config or {}
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

    -- drawer: Hide UI + Test notify
    local Drawer = New("Frame", {
        Position = UDim2.fromOffset(10, ISLAND_H + 2), Size = UDim2.new(1, -20, 0, 30),
        BackgroundTransparency = 1, Parent = Island,
    }, {
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    })
    local HideBtn = Button(Drawer, "Hide UI", { Size = UDim2.new(0.5, -3, 1, 0), LayoutOrder = 1 })
    local TestBtn = Button(Drawer, "Test notify", {
        Size = UDim2.new(0.5, -3, 1, 0), LayoutOrder = 2, BackgroundTransparency = 1,
    })
    Rim(Theme.StrokeAlpha).Parent = TestBtn

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
    -- quick squash when the window flies into the island
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
    TestBtn.MouseButton1Click:Connect(function()
        NexusLib:Notify({ Title = "Nexus", Content = "This is a test notification" })
    end)

    -- live stats
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
-- NOTIFICATIONS (stacked bottom-right, countdown bar, slide in / collapse out)
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

    -- slot animates its height so the others glide up/down
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
        Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = Theme.Dim, Text = cfg.Content or "",
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

    ---------------- title bar ----------------
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
    local Sub = Label(TitleBar, {
        Position = UDim2.fromOffset(44, 0), Size = UDim2.new(0, 200, 1, 0),
        Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = Theme.Faint, Text = config.SubTitle or "",
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

    -- drag by the title bar
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

    ---------------- sidebar ----------------
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

    ---------------- window methods ----------------
    -- hiding flies the window up into the island; showing drops it back out
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
            NexusLib:Notify({ Title = "Nexus", Content = "Hidden, press " .. NexusLib.ToggleKey.Name .. " to show" })
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

        -- one row: title (+ description) on the left, control on the right
        local function Item(cfg, rightWidth)
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
            Label(Page, {
                Size = UDim2.new(1, 0, 0, 26), Text = string.upper(title), TextSize = 10,
                Font = Enum.Font.GothamMedium, TextColor3 = Theme.Faint,
                TextYAlignment = Enum.TextYAlignment.Bottom, LayoutOrder = nextOrder(),
            })
        end

        function Tab:CreateToggle(cfg)
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
                state = value
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
            local _, right = Item(cfg, 72)
            local b = Button(right, cfg.Text or "Run", {
                AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(72, 28),
            })
            b.MouseButton1Click:Connect(function()
                if cfg.Callback then task.spawn(cfg.Callback) end
            end)
        end

        function Tab:CreateInput(cfg)
            local _, right = Item(cfg, 150)
            local box = New("TextBox", Merge(Soft(Theme.ControlAlpha), {
                Size = UDim2.fromScale(1, 1), Text = "", PlaceholderText = cfg.Placeholder or "Type...",
                PlaceholderColor3 = Theme.Faint, Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, Parent = right,
            }), { Corner(7), New("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }) })
            local stroke = Rim(1)
            stroke.Parent = box
            box.Focused:Connect(function() Tween(stroke, 0.15, nil, nil, { Transparency = 0.86 }) end)
            box.FocusLost:Connect(function(enter)
                Tween(stroke, 0.15, nil, nil, { Transparency = 1 })
                if enter and box.Text ~= "" and cfg.Callback then
                    task.spawn(cfg.Callback, box.Text)
                    if cfg.ClearOnSubmit ~= false then box.Text = "" end
                end
            end)
            local Input = {}
            function Input:Set(v) box.Text = v end
            function Input:Get() return box.Text end
            return Input
        end

        function Tab:CreateDropdown(cfg)
            local options = cfg.Options or {}
            local value = cfg.Default or options[1]
            local _, right = Item(cfg, 110)
            local field = Button(right, "", { Size = UDim2.fromScale(1, 1) })
            local valueLabel = Label(field, {
                Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -28, 1, 0), TextSize = 11, Text = tostring(value),
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
            local function set(v)
                value = v
                valueLabel.Text = tostring(v)
                if cfg.Callback then task.spawn(cfg.Callback, v) end
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
            function Dropdown:Set(v) set(v) end
            function Dropdown:Get() return value end
            return Dropdown
        end

        function Tab:CreateKeybind(cfg)
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
            return Keybind
        end

        table.insert(Window.Tabs, Tab)
        if index == 1 then
            Tab:Select()
        end
        return Tab
    end

    return Window
end

--------------------------------------------------------------------------
-- DEMO (call Nexus:Demo() to see the whole UI)
--------------------------------------------------------------------------
function NexusLib:Demo()
    NexusLib:PlayInkIntro(function()
        local Island = NexusLib:CreateDynamicIsland({ Title = "Nexus", Status = "Farming" })
        local Window = NexusLib:CreateWindow({ Title = "Nexus Hub", SubTitle = "Universal" })
        local function note(title, on) NexusLib:Notify({ Title = title, Content = on and "Enabled" or "Disabled" }) end

        local Main = Window:CreateTab("Main")
        Main:CreateSection("Automation")
        Main:CreateToggle({ Name = "Auto farm", Description = "Attacks the nearest enemy", Default = true,
            Callback = function(on) Island:SetStatus(on and "Farming" or "Ready") note("Auto farm", on) end })
        Main:CreateToggle({ Name = "Kill aura", Description = "Hits everything in range",
            Callback = function(on) note("Kill aura", on) end })
        Main:CreateDropdown({ Name = "Target priority", Options = { "Nearest", "Lowest HP", "Boss" }, Default = "Nearest",
            Callback = function(v) NexusLib:Notify({ Title = "Target", Content = v }) end })
        Main:CreateSection("Player")
        Main:CreateSlider({ Name = "Walk speed", Min = 16, Max = 200, Default = 16,
            Callback = function(v)
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = v end
            end })
        Main:CreateInput({ Name = "Teleport to player", Description = "Type a name, press Enter", Placeholder = "Username",
            Callback = function(name)
                local target = Players:FindFirstChild(name)
                local root = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
                local mine = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if root and mine then
                    mine.CFrame = root.CFrame * CFrame.new(0, 0, 3)
                    NexusLib:Notify({ Title = "Teleport", Content = "Teleported to " .. name })
                else
                    NexusLib:Notify({ Title = "Teleport", Content = "Player not found" })
                end
            end })
        Main:CreateButton({ Name = "Reset character", Text = "Reset",
            Callback = function()
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.Health = 0 end
            end })

        local Combat = Window:CreateTab("Combat")
        Combat:CreateSection("Aim")
        Combat:CreateToggle({ Name = "Silent aim", Description = "Redirects shots to the target", Default = true })
        Combat:CreateDropdown({ Name = "Aim part", Options = { "Head", "Torso", "Root" }, Default = "Head" })
        Combat:CreateSlider({ Name = "Hitbox size", Description = "Studs", Min = 2, Max = 50, Default = 14 })
        Combat:CreateSection("Defense")
        Combat:CreateToggle({ Name = "Auto parry", Description = "Blocks incoming attacks" })

        local Visual = Window:CreateTab("Visual")
        Visual:CreateSection("ESP")
        Visual:CreateToggle({ Name = "Boxes", Default = true })
        Visual:CreateToggle({ Name = "Chams", Description = "Highlight through walls" })
        Visual:CreateToggle({ Name = "Tracers" })
        Visual:CreateSection("Camera")
        Visual:CreateSlider({ Name = "Field of view", Min = 70, Max = 120, Default = 70,
            Callback = function(v) workspace.CurrentCamera.FieldOfView = v end })

        local Settings = Window:CreateTab("Settings")
        Settings:CreateSection("Interface")
        Settings:CreateKeybind({ Name = "Menu key", Description = "Click, then press a key", Default = NexusLib.ToggleKey,
            Callback = function(key)
                NexusLib.ToggleKey = key
                NexusLib:Notify({ Title = "Keybind", Content = "Menu key set to " .. key.Name })
            end })
        Settings:CreateSlider({ Name = "Notification time", Description = "Seconds", Min = 1, Max = 8, Default = 3,
            Callback = function(v) NexusLib.NotifyDuration = v end })
        Settings:CreateSection("Config")
        Settings:CreateButton({ Name = "Save config", Text = "Save",
            Callback = function() NexusLib:Notify({ Title = "Config", Content = "Saved" }) end })

        NexusLib:Notify({ Title = "Nexus", Content = "Loaded. " .. NexusLib.ToggleKey.Name .. " toggles the menu" })
    end)
end

return NexusLib
