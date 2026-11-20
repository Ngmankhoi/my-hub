--[[
    NEXUS UI  -  single-file Luau UI library (Roblox executors)

    Everything is in this one file: the ink-swirl intro, the Dynamic Island,
    the window, tabs, notifications, and every control. The white Nexus N logo
    is embedded as clean Base64 with a geometric vector shard fallback.

    Quick start (paste directly into your executor and press Execute, or):
        local Nexus = loadstring(readfile("nexuslibnew.txt"))()

    To import as a library without auto-running the demo UI:
        _G.NEXUS_LIB_ONLY = true
        local Nexus = loadstring(readfile("nexuslibnew.txt"))()
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local DOT = "\194\183" -- pure-ASCII UTF-8 middle dot so ANSI/CP1252 executors never corrupt it

getgenv = getgenv or function() return _G end
do
    local env = getgenv()
    if type(env.__NEXUS_CLEANUP) == "table" then
        for _, fn in ipairs(env.__NEXUS_CLEANUP) do
            pcall(fn)
        end
    end
    env.__NEXUS_CLEANUP = {}
end

local function TrackConn(conn)
    local env = getgenv()
    if type(env.__NEXUS_CLEANUP) == "table" then
        table.insert(env.__NEXUS_CLEANUP, function()
            if conn and conn.Connected then conn:Disconnect() end
        end)
    end
    return conn
end

local function TrackCleanup(fn)
    local env = getgenv()
    if type(env.__NEXUS_CLEANUP) == "table" then
        table.insert(env.__NEXUS_CLEANUP, fn)
    end
end

local NexusLib = {
    -- Exact Figma Make color tokens (pre-composited over #111114 so 3D game worlds never wash out UI rows)
    Theme = {
        Surface       = Color3.fromRGB(17, 17, 20),    -- #111114 (shared by island, window & notifications)
        SurfaceAlpha  = 0.06,                          -- 94% opaque dark glass
        Stroke        = Color3.fromRGB(255, 255, 255),
        StrokeAlpha   = 0.90,                          -- 1px subtle border (rgba(255,255,255,0.10))
        StrokeHover   = 0.84,                          -- hover border (rgba(255,255,255,0.16))
        Divider       = Color3.fromRGB(33, 33, 38),    -- #212126 (1px titlebar & sidebar dividers)
        Row           = Color3.fromRGB(25, 25, 29),    -- #19191d (--row: rgba(255,255,255,0.035) on #111114)
        RowHover      = Color3.fromRGB(31, 31, 36),    -- #1f1f24 (--row-hover: rgba(255,255,255,0.06) on #111114)
        Control       = Color3.fromRGB(34, 34, 39),    -- #222227 (--control: rgba(255,255,255,0.07) on #111114)
        ControlHover  = Color3.fromRGB(43, 43, 50),    -- #2b2b32 (--control-hover: rgba(255,255,255,0.11) on #111114)
        ToggleOff     = Color3.fromRGB(45, 45, 52),    -- #2d2d34 (rgba(255,255,255,0.12) on #111114)
        Menu          = Color3.fromRGB(24, 24, 28),    -- #18181c (dropdown menu surface)
        Knob          = Color3.fromRGB(142, 142, 150),  -- #8e8e96 (toggle off thumb)
        Text          = Color3.fromRGB(237, 237, 239), -- #ededef (--text)
        Dim           = Color3.fromRGB(138, 138, 146), -- #8a8a92 (--dim)
        Faint         = Color3.fromRGB(90, 90, 98),    -- #5a5a62 (--faint)
        White         = Color3.fromRGB(255, 255, 255),
    },
    ToggleKey = Enum.KeyCode.RightShift,
    DefaultWindowSize = Vector2.new(640, 420),
    NotifyDuration = 3,
    ReduceMotion = false,
    Listening = false,
}
NexusLib.__index = NexusLib

local Theme = NexusLib.Theme

--------------------------------------------------------------------------
-- helpers
--------------------------------------------------------------------------
local function GetSafeGui()
    if type(gethui) == "function" then
        local ok, hui = pcall(gethui)
        if ok and hui then
            return hui
        end
    end
    local ok, gui = pcall(function()
        local probe = Instance.new("ScreenGui")
        probe.Name = "Nexus_Probe"
        probe.Parent = CoreGui
        probe:Destroy()
        return CoreGui
    end)
    if ok and gui then
        return gui
    end
    local lp = Players.LocalPlayer or LocalPlayer
    return lp:WaitForChild("PlayerGui")
end

local function DestroyExisting(name)
    local parent = GetSafeGui()
    local old = parent and parent:FindFirstChild(name)
    if old then
        pcall(function() old:Destroy() end)
    end
end

local function Tween(instance, time, style, dir, props)
    local duration = NexusLib.ReduceMotion and 0.01 or (time or 0.28)
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(duration, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out),
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
        Name = "UIStroke",
        Color = color or Theme.Stroke,
        Transparency = transparency or Theme.StrokeAlpha,
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

-- Vector 2-stroke chevron (replaces Unicode characters that render as [?] in Roblox fonts)
local function Chevron(parent, props, color)
    local c = color or Theme.Dim
    local holder = New("Frame", {
        Size = UDim2.fromOffset(12, 12),
        BackgroundTransparency = 1,
        Parent = parent,
    })
    for k, v in pairs(props or {}) do
        holder[k] = v
    end
    local left = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, -2, 0.5, 0),
        Size = UDim2.fromOffset(6, 2),
        Rotation = 42,
        BackgroundColor3 = c,
        BorderSizePixel = 0,
        Parent = holder,
    }, { Corner(1) })
    local right = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 2, 0.5, 0),
        Size = UDim2.fromOffset(6, 2),
        Rotation = -42,
        BackgroundColor3 = c,
        BorderSizePixel = 0,
        Parent = holder,
    }, { Corner(1) })

    local api = { Frame = holder, Left = left, Right = right }
    function api:SetOpen(open, activeColor, idleColor)
        local col = open and (activeColor or Theme.Text) or (idleColor or c)
        Tween(holder, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, { Rotation = open and 180 or 0 })
        Tween(left, 0.2, nil, nil, { BackgroundColor3 = col })
        Tween(right, 0.2, nil, nil, { BackgroundColor3 = col })
    end
    return api
end

--------------------------------------------------------------------------
-- embedded logo (clean 128px pure-white alpha PNG + geometric shard fallback)
--------------------------------------------------------------------------
local LOGO_B64 = [=[
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
]=]

local B64_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local function DecodeBase64(data)
    if type(crypt) == "table" and type(crypt.base64decode) == "function" then
        local ok, res = pcall(crypt.base64decode, data)
        if ok and res and #res > 0 then return res end
    end
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

local NEXUS_ASSET = "rbxassetid://95635434702674"

local function GetLogoAsset()
    if NexusLib.LogoAsset ~= nil then
        return NexusLib.LogoAsset
    end
    -- If executor supports custom file assets, decode HD base64
    local ok, asset = pcall(function()
        local getAsset = getcustomasset or getsynasset
        if not (writefile and getAsset) then
            error("no file api")
        end
        local name = "nexus_logo_white_v5_hd.png"
        writefile(name, DecodeBase64(LOGO_B64))
        return getAsset(name)
    end)
    if ok and asset and asset ~= "" then
        NexusLib.LogoAsset = asset
        return asset
    end
    -- Universal ultra-sharp 2K Roblox asset ID fallback (works natively in Roblox Studio & every executor)
    NexusLib.LogoAsset = NEXUS_ASSET
    return NexusLib.LogoAsset
end

-- Renders the logo with crystal clarity across all environments
local function Logo(parent, props)
    local asset = GetLogoAsset()
    local p = {
        BackgroundTransparency = 1,
        Image = (asset and asset ~= "") and asset or NEXUS_ASSET,
        ImageColor3 = Theme.White,
        ScaleType = Enum.ScaleType.Fit,
        Parent = parent,
    }
    for k, v in pairs(props) do p[k] = v end
    return New("ImageLabel", p)
end

--------------------------------------------------------------------------
-- INK SWIRL INTRO
-- Two tapered ink strokes spiral in, orbit as a ring, shrink to two dots;
-- left dot shoots up into the Dynamic Island at T_PILL, right dot expands
-- into the main window at T_WINDOW. Click anywhere to skip.
--------------------------------------------------------------------------
function NexusLib:PlayInkIntro(callbackOrOpts)
    local onPill, onWindow
    if type(callbackOrOpts) == "table" then
        onPill = callbackOrOpts.OnPill
        onWindow = callbackOrOpts.OnWindow or callbackOrOpts.Callback
    else
        onWindow = callbackOrOpts
    end

    local TAU = math.pi * 2
    local K = TAU * 0.9
    local S0 = 0.2
    local PHI0 = { -0.75 * math.pi, 0.25 * math.pi }
    local S_END = (1.75 * math.pi + TAU) / K
    local POINTS = 26
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

    DestroyExisting("Nexus_InkIntro")
    local IntroGui = Instance.new("ScreenGui")
    IntroGui.Name = "Nexus_InkIntro"
    IntroGui.DisplayOrder = 999999
    IntroGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    IntroGui.ResetOnSpawn = false
    IntroGui.IgnoreGuiInset = true
    IntroGui.Parent = GetSafeGui()

    local Blur = Instance.new("BlurEffect")
    Blur.Size = 0
    pcall(function()
        Blur.Parent = Lighting
    end)
    Tween(Blur, 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Size = 16 })

    local Dim = Instance.new("TextButton")
    Dim.Size = UDim2.new(1, 0, 1, 0)
    Dim.BackgroundColor3 = Color3.fromRGB(8, 8, 9)
    Dim.BackgroundTransparency = 0.25
    Dim.BorderSizePixel = 0
    Dim.Text = ""
    Dim.AutoButtonColor = false
    Dim.Parent = IntroGui

    local camera = workspace.CurrentCamera
    local vp = (camera and camera.ViewportSize and camera.ViewportSize.X > 100) and camera.ViewportSize or Vector2.new(1280, 720)
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
    local firedPill = false
    local firedWindow = false

    local function firePill()
        if firedPill then return end
        firedPill = true
        if onPill then task.spawn(onPill) end
    end

    local function fireWindow()
        if firedWindow then return end
        firedWindow = true
        firePill()
        if onWindow then task.spawn(onWindow) end
    end

    local function Finish()
        if finished then return end
        finished = true
        if conn then conn:Disconnect() end
        fireWindow()
        Tween(Blur, 0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Size = 0 })
        IntroGui:Destroy()
        task.delay(0.4, function()
            pcall(function() Blur:Destroy() end)
        end)
    end

    Dim.MouseButton1Click:Connect(Finish)
    TrackCleanup(Finish)

    local t0 = os.clock()
    conn = TrackConn(RunService.RenderStepped:Connect(function()
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
                    math.min(w, h) / 2, INK:Lerp(ISLAND_BG, tone), 0, 0.10 * tone)
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

        if t >= T_PILL then
            firePill()
        end

        Dim.BackgroundTransparency = lerp(0.25, 1, smooth(T_SQUARE, T_WINDOW + 0.2, t))

        if t >= T_WINDOW then
            fireWindow()
            local f = clamp01((t - T_WINDOW) / (T_END - T_WINDOW))
            BlobL.BackgroundTransparency = f
            BlobR.BackgroundTransparency = f
            BlobL.Rim.Transparency = 1
            BlobR.Rim.Transparency = 1
        end
        if t >= T_END then
            Finish()
        end
    end))
end

function NexusLib:PlayIntro(callback)
    return NexusLib:PlayInkIntro(callback)
end

--------------------------------------------------------------------------
-- shared surface (native Frame so text & 1px strokes stay razor-sharp)
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

-- flat control button used in island drawer and inside rows
local function Button(parent, text, props, ghost)
    local bg = ghost and Theme.Surface or Theme.Control
    local b = New("TextButton", {
        BackgroundColor3 = bg,
        BackgroundTransparency = ghost and 0.4 or 0,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = text,
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
        TextColor3 = Theme.Text,
        Parent = parent,
    }, { Corner(7) })
    if ghost then
        Rim(Theme.StrokeAlpha).Parent = b
    end
    for k, v in pairs(props or {}) do b[k] = v end
    b.MouseEnter:Connect(function()
        Tween(b, 0.15, nil, nil, { BackgroundColor3 = Theme.ControlHover, BackgroundTransparency = 0 })
    end)
    b.MouseLeave:Connect(function()
        Tween(b, 0.15, nil, nil, { BackgroundColor3 = bg, BackgroundTransparency = ghost and 0.4 or 0 })
    end)
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
local ISLAND_OPEN_W, ISLAND_OPEN_H = 400, 82

function NexusLib:CreateDynamicIsland(config)
    config = config or {}
    DestroyExisting("Nexus_Island")
    local Gui = New("ScreenGui", {
        Name = "Nexus_Island", DisplayOrder = 100000, ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = true, Parent = GetSafeGui(),
    })

    local Island = Surface("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, ISLAND_TOP),
        Size = UDim2.fromOffset(ISLAND_W, ISLAND_H),
        ClipsDescendants = true,
        Parent = Gui,
    }, 20)
    local IslandCorner = Island:FindFirstChildOfClass("UICorner")

    local Bar = New("TextButton", {
        Size = UDim2.new(1, 0, 0, ISLAND_H), BackgroundTransparency = 1, Text = "",
        AutoButtonColor = false, Parent = Island,
    })
    Logo(Bar, { Position = UDim2.new(0, 12, 0.5, -9), Size = UDim2.fromOffset(18, 18) })
    local NameLabel = Label(Bar, {
        Position = UDim2.fromOffset(36, 0), Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X,
        Font = Enum.Font.GothamBold, TextSize = 12, Text = config.Title or "Nexus",
    })
    local Status = Label(Bar, {
        Position = UDim2.fromOffset(80, 0), Size = UDim2.new(0, 110, 1, 0),
        Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = Theme.Dim, Text = config.Status or "Active",
    })
    local function updateStatusPos()
        Status.Position = UDim2.fromOffset(36 + NameLabel.TextBounds.X + 8, 0)
    end
    NameLabel:GetPropertyChangedSignal("TextBounds"):Connect(updateStatusPos)
    task.defer(updateStatusPos)

    local Stats = Label(Bar, {
        AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -33, 0, 0), Size = UDim2.new(0, 115, 1, 0),
        Font = Enum.Font.Code, TextSize = 10, TextColor3 = Theme.Dim, TextXAlignment = Enum.TextXAlignment.Right,
        RichText = true,
        Text = "144 fps <font color=\"#5a5a62\">" .. DOT .. "</font> 19ms",
    })
    local Caret = Chevron(Bar, {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -13, 0.5, 0),
    }, Theme.Faint)

    -- drawer: Hide UI + Test notify
    local Drawer = New("Frame", {
        Position = UDim2.fromOffset(10, ISLAND_H + 2), Size = UDim2.new(1, -20, 0, 30),
        BackgroundTransparency = 1, Visible = false, Parent = Island,
    })
    local HideBtn = Button(Drawer, "Hide UI", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.25, -2, 0.5, 0), Size = UDim2.new(0.5, -3, 1, 0),
    }, false)
    local TestBtn = Button(Drawer, "Test notify", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.75, 2, 0.5, 0), Size = UDim2.new(0.5, -3, 1, 0),
    }, true)

    local IslandApi = { Gui = Gui, Frame = Island, Expanded = false, ShowStats = true }
    NexusLib.ActiveIsland = IslandApi

    function IslandApi:SetExpanded(on)
        IslandApi.Expanded = on
        if on then
            Drawer.Visible = true
        else
            task.delay(0.25, function()
                if not IslandApi.Expanded then
                    Drawer.Visible = false
                end
            end)
        end
        Tween(Island, 0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
            Size = on and UDim2.fromOffset(ISLAND_OPEN_W, ISLAND_OPEN_H) or UDim2.fromOffset(ISLAND_W, ISLAND_H),
        })
        if IslandCorner then
            Tween(IslandCorner, 0.35, nil, nil, { CornerRadius = UDim.new(0, on and 16 or 20) })
        end
        Caret:SetOpen(on, Theme.Text, Theme.Faint)
        if NexusLib.ActiveWindow then
            NexusLib.ActiveWindow:PushDown(on)
        end
    end
    function IslandApi:SetStatus(text)
        Status.TextTransparency = 1
        local targetX = 36 + NameLabel.TextBounds.X + 8
        Status.Position = UDim2.fromOffset(targetX, 4)
        Status.Text = text
        Tween(Status, 0.28, nil, nil, { TextTransparency = 0, Position = UDim2.fromOffset(targetX, 0) })
    end
    function IslandApi:SetStatsVisible(visible)
        IslandApi.ShowStats = visible
        Stats.Visible = visible
    end
    function IslandApi:SetHiddenLabel(hidden)
        HideBtn.Text = hidden and "Show UI" or "Hide UI"
    end
    function IslandApi:Gulp()
        Tween(Island, 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
            Size = UDim2.fromOffset(ISLAND_W + 12, ISLAND_H + 4)
        })
        task.delay(0.12, function()
            Tween(Island, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
                Size = UDim2.fromOffset(ISLAND_W, ISLAND_H)
            })
        end)
    end

    Bar.MouseButton1Click:Connect(function() IslandApi:SetExpanded(not IslandApi.Expanded) end)
    Island.MouseEnter:Connect(function() Tween(Island.UIStroke, 0.2, nil, nil, { Transparency = Theme.StrokeHover }) end)
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

    local frames, last = 0, os.clock()
    local statsConn
    statsConn = TrackConn(RunService.RenderStepped:Connect(function()
        if not Gui.Parent then
            if statsConn then statsConn:Disconnect() end
            return
        end
        frames = frames + 1
        if os.clock() - last >= 1 then
            local ping = 19
            pcall(function()
                ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            Stats.Text = frames .. " fps <font color=\"#5a5a62\">" .. DOT .. "</font> " .. ping .. "ms"
            frames, last = 0, os.clock()
        end
    end))

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
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = true, Parent = parent,
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
        ClipsDescendants = true, LayoutOrder = math.floor(os.clock() * 1000), Parent = Stack,
    })
    local Card = Surface("Frame", {
        AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 28, 1, 0),
        Size = UDim2.fromOffset(NOTE_W, NOTE_H), ClipsDescendants = true, Parent = Slot,
    }, 12)
    local Icon = Logo(Card, { Position = UDim2.fromOffset(12, 12), Size = UDim2.fromOffset(16, 16) })
    local TitleLbl = Label(Card, {
        Position = UDim2.fromOffset(36, 10), Size = UDim2.new(1, -48, 0, 16),
        Font = Enum.Font.GothamBold, TextSize = 12, Text = cfg.Title or "Nexus",
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
    local BodyLbl = Label(Card, {
        Position = UDim2.fromOffset(36, 27), Size = UDim2.new(1, -48, 0, 16),
        Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = Theme.Dim, Text = cfg.Content or cfg.Message or "",
        TextTruncate = Enum.TextTruncate.AtEnd,
    })

    local note = { Slot = Slot, Card = Card, Closed = false }
    function note:Close()
        if note.Closed then return end
        note.Closed = true
        for i, n in ipairs(NoteQueue) do
            if n == note then table.remove(NoteQueue, i) break end
        end
        Tween(Card, 0.26, Enum.EasingStyle.Quart, Enum.EasingDirection.In, {
            Position = UDim2.new(0, 32, 1, 0), BackgroundTransparency = 1,
        })
        if Card:FindFirstChild("UIStroke") then
            Tween(Card.UIStroke, 0.2, nil, nil, { Transparency = 1 })
        end
        Tween(TitleLbl, 0.2, nil, nil, { TextTransparency = 1 })
        Tween(BodyLbl, 0.2, nil, nil, { TextTransparency = 1 })
        if Icon then
            Tween(Icon, 0.2, nil, nil, { ImageTransparency = 1 })
        end
        task.delay(0.16, function()
            Tween(Slot, 0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, { Size = UDim2.fromOffset(NOTE_W, 0) })
        end)
        task.delay(0.46, function() pcall(function() Slot:Destroy() end) end)
    end

    table.insert(NoteQueue, note)
    while #NoteQueue > NOTE_MAX do
        NoteQueue[1]:Close()
    end

    Tween(Slot, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, { Size = UDim2.fromOffset(NOTE_W, NOTE_H + 8) })
    Tween(Card, 0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Position = UDim2.new(0, 0, 1, 0) })
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
    DestroyExisting("Nexus_Window")
    local size = config.Size or UDim2.fromOffset(NexusLib.DefaultWindowSize.X, NexusLib.DefaultWindowSize.Y)
    local homeY = ISLAND_TOP + ISLAND_H + 16
    local defaultPos = UDim2.new(0.5, 0, 0, homeY)
    local restPos = defaultPos

    local Gui = New("ScreenGui", {
        Name = "Nexus_Window", DisplayOrder = 99990, ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = true, Parent = GetSafeGui(),
    })

    -- Native Frame (not CanvasGroup) so all fonts, corners and 1px strokes render crisp at 100% resolution
    local Frame = Surface("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = restPos,
        Size = size,
        ClipsDescendants = true,
        Parent = Gui,
    }, 14)

    local Window = { Tabs = {}, CurrentTab = nil, Gui = Gui, Frame = Frame, Visible = true, Pushed = false }
    NexusLib.ActiveWindow = Window
    local closeOpenDropdown = nil
    local function dismissDropdown()
        if closeOpenDropdown then closeOpenDropdown() end
    end

    ---------------- title bar ----------------
    local TitleBar = New("Frame", {
        Size = UDim2.new(1, 0, 0, 46), BackgroundTransparency = 1, Parent = Frame,
    })
    -- 1px bottom divider
    New("Frame", {
        AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Theme.Divider, BorderSizePixel = 0, Parent = TitleBar,
    })
    Logo(TitleBar, { Position = UDim2.fromOffset(16, 14), Size = UDim2.fromOffset(18, 18) })
    local TitleText = Label(TitleBar, {
        Position = UDim2.fromOffset(42, 0), Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X,
        Font = Enum.Font.GothamBold, TextSize = 13, Text = config.Title or "Nexus Hub",
    })
    local Sub = Label(TitleBar, {
        Position = UDim2.fromOffset(116, 1), Size = UDim2.new(0, 200, 1, 0),
        Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = Theme.Faint, Text = config.Subtitle or config.SubTitle or "Universal",
    })
    local function updateSubPos()
        Sub.Position = UDim2.fromOffset(42 + TitleText.TextBounds.X + 8, 1)
    end
    TitleText:GetPropertyChangedSignal("TextBounds"):Connect(updateSubPos)
    task.defer(updateSubPos)

    local MinBtn = New("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(26, 26),
        BackgroundColor3 = Theme.Control, BackgroundTransparency = 1, BorderSizePixel = 0,
        AutoButtonColor = false, Text = "", Parent = TitleBar,
    }, { Corner(7) })
    local MinLine = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(10, 2),
        BackgroundColor3 = Theme.Dim, BorderSizePixel = 0, Parent = MinBtn,
    }, { Corner(1) })
    local minHovered = false
    MinBtn.MouseEnter:Connect(function()
        minHovered = true
        Tween(MinBtn, 0.15, nil, nil, { BackgroundTransparency = 0 })
        Tween(MinLine, 0.15, nil, nil, { BackgroundColor3 = Theme.Text })
    end)
    MinBtn.MouseLeave:Connect(function()
        minHovered = false
        Tween(MinBtn, 0.15, nil, nil, { BackgroundTransparency = 1 })
        Tween(MinLine, 0.15, nil, nil, { BackgroundColor3 = Theme.Dim })
    end)
    MinBtn.MouseButton1Click:Connect(function() Window:SetVisible(false) end)

    -- drag by the title bar (double-click resets position to center)
    local dragging, dragStart, startPos = false, nil, nil
    local lastClick = 0
    TitleBar.InputBegan:Connect(function(input)
        if minHovered then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dismissDropdown()
            local now = os.clock()
            if now - lastClick < 0.3 then
                dragging = false
                Window:ResetPosition()
                lastClick = 0
                return
            end
            lastClick = now
            dragging, dragStart, startPos = true, input.Position, Frame.Position
        end
    end)
    TrackConn(UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, math.max(16, startPos.Y.Offset + d.Y))
            Frame.Position = newPos
            restPos = newPos
        end
    end))
    TrackConn(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))

    ---------------- sidebar ----------------
    local Sidebar = New("Frame", {
        Position = UDim2.fromOffset(0, 46), Size = UDim2.new(0, 132, 1, -46),
        BackgroundTransparency = 1, Parent = Frame,
    })
    -- 1px right divider
    New("Frame", {
        AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0), Size = UDim2.new(0, 1, 1, 0),
        BackgroundColor3 = Theme.Divider, BorderSizePixel = 0, Parent = Sidebar,
    })
    local Glide = New("Frame", {
        Position = UDim2.fromOffset(8, 10), Size = UDim2.new(1, -16, 0, 32),
        BackgroundColor3 = Theme.Control, BorderSizePixel = 0, Visible = false, Parent = Sidebar,
    }, { Corner(8) })
    New("Frame", {
        AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.fromOffset(2, 12),
        BackgroundColor3 = Theme.Text, BorderSizePixel = 0, Parent = Glide,
    }, { Corner(1) })
    local TabList = New("ScrollingFrame", {
        Position = UDim2.fromOffset(8, 10), Size = UDim2.new(1, -16, 1, -20),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = Sidebar,
    }, {
        New("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }),
    })
    local PageHolder = New("Frame", {
        Position = UDim2.fromOffset(133, 46), Size = UDim2.new(1, -133, 1, -46),
        BackgroundTransparency = 1, ClipsDescendants = true, Parent = Frame,
    })

    ---------------- window methods ----------------
    function Window:SetVisible(on)
        if on == Window.Visible then return end
        Window.Visible = on
        dismissDropdown()
        local island = NexusLib.ActiveIsland
        if island then island:SetHiddenLabel(not on) end
        if on then
            Frame.Visible = true
            Tween(Frame, 0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
                Position = restPos, Size = size, BackgroundTransparency = Theme.SurfaceAlpha,
            })
            if island then island:SetStatus(Window.LastStatus or "Active") end
            NexusLib:Notify({ Title = "Nexus", Content = "Menu shown" })
        else
            local hideTarget = UDim2.new(restPos.X.Scale, restPos.X.Offset, 0, ISLAND_TOP + 2)
            Tween(Frame, 0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.In, {
                Position = hideTarget,
                Size = UDim2.fromOffset(size.X.Offset * 0.2, size.Y.Offset * 0.1),
                BackgroundTransparency = 0.98,
            })
            task.delay(0.3, function()
                if island and not Window.Visible then
                    island:Gulp()
                    island:SetStatus("Hidden")
                end
            end)
            task.delay(0.35, function()
                if not Window.Visible then Frame.Visible = false end
            end)
            NexusLib:Notify({ Title = "Nexus", Content = "Hidden, press " .. NexusLib.ToggleKey.Name .. " to show" })
        end
    end
    function Window:ToggleVisible()
        Window:SetVisible(not Window.Visible)
    end
    function Window:ResetPosition()
        restPos = UDim2.new(0.5, 0, 0, homeY + (Window.Pushed and (ISLAND_OPEN_H - ISLAND_H) or 0))
        Tween(Frame, 0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Position = restPos })
    end
    function Window:PushDown(pushed)
        if pushed == Window.Pushed then return end
        Window.Pushed = pushed
        dismissDropdown()
        local dy = pushed and (ISLAND_OPEN_H - ISLAND_H) or -(ISLAND_OPEN_H - ISLAND_H)
        restPos = UDim2.new(restPos.X.Scale, restPos.X.Offset, restPos.Y.Scale, restPos.Y.Offset + dy)
        if Window.Visible then
            Tween(Frame, 0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
                Position = restPos,
            })
        end
    end
    function Window:Notify(cfg)
        return NexusLib:Notify(cfg)
    end
    function Window:Destroy()
        Gui:Destroy()
    end

    TrackConn(UserInputService.InputBegan:Connect(function(input, processed)
        if Gui.Parent and not processed and not NexusLib.Listening and input.KeyCode == NexusLib.ToggleKey then
            Window:ToggleVisible()
        end
    end))

    ---------------- tabs ----------------
    function Window:CreateTab(name)
        local index = #Window.Tabs + 1

        local TabButton = New("TextButton", {
            Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, Text = "",
            AutoButtonColor = false, LayoutOrder = index, ZIndex = 2, Parent = TabList,
        })
        local text = Label(TabButton, {
            Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -16, 1, 0), Text = name,
            Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Theme.Dim, ZIndex = 2,
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
                PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 14),
                PaddingRight = UDim.new(0, 14), PaddingBottom = UDim.new(0, 16),
            }),
        })
        Page:GetPropertyChangedSignal("CanvasPosition"):Connect(dismissDropdown)

        local Tab = { Button = TabButton, Label = text, Page = Page, Index = index }
        local order = 0
        local sectionCount = 0
        local function nextOrder()
            order = order + 1
            return order
        end

        function Tab:Select()
            local prev = Window.CurrentTab
            if prev == Tab then return end
            dismissDropdown()
            for _, other in ipairs(Window.Tabs) do
                other.Page.Visible = false
                Tween(other.Label, 0.2, nil, nil, { TextColor3 = Theme.Dim })
            end
            local y = 10 + (index - 1) * 34
            if Glide.Visible then
                Tween(Glide, 0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Position = UDim2.fromOffset(8, y) })
            else
                Glide.Position = UDim2.fromOffset(8, y)
                Glide.Visible = true
            end
            Tween(text, 0.2, nil, nil, { TextColor3 = Theme.Text })
            local dir = (prev and prev.Index > index) and -1 or 1
            Page.Position = UDim2.fromOffset(18 * dir, 0)
            Page.Visible = true
            Tween(Page, 0.36, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, { Position = UDim2.fromOffset(0, 0) })
            Window.CurrentTab = Tab
        end
        TabButton.MouseButton1Click:Connect(function() Tab:Select() end)

        -- one row: title (+ description) on the left, control on the right
        local function Item(cfg, rightWidth)
            local hasDesc = cfg.Description ~= nil and cfg.Description ~= ""
            local h = hasDesc and 46 or 42
            local row = New("Frame", {
                Size = UDim2.new(1, 0, 0, h),
                BackgroundColor3 = Theme.Row,
                BorderSizePixel = 0,
                LayoutOrder = nextOrder(),
                Parent = Page,
            }, { Corner(9) })
            local w = -(24 + (rightWidth or 110))
            Label(row, {
                Position = UDim2.fromOffset(12, hasDesc and 8 or 0),
                Size = UDim2.new(1, w, 0, hasDesc and 15 or h),
                Font = Enum.Font.GothamMedium,
                TextSize = 12,
                Text = cfg.Name or "Item",
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
            hit.MouseEnter:Connect(function() Tween(row, 0.15, nil, nil, { BackgroundColor3 = Theme.RowHover }) end)
            hit.MouseLeave:Connect(function() Tween(row, 0.15, nil, nil, { BackgroundColor3 = Theme.Row }) end)
        end

        function Tab:CreateSection(title)
            sectionCount = sectionCount + 1
            local topGap = sectionCount > 1 and 8 or 0
            local wrap = New("Frame", {
                Size = UDim2.new(1, 0, 0, 20 + topGap),
                BackgroundTransparency = 1,
                LayoutOrder = nextOrder(),
                Parent = Page,
            })
            Label(wrap, {
                Position = UDim2.fromOffset(2, topGap + 2),
                Size = UDim2.new(1, -4, 0, 16),
                Text = string.upper(title),
                TextSize = 10,
                Font = Enum.Font.GothamMedium,
                TextColor3 = Theme.Faint,
            })

            local sec = { _instance = wrap }
            function sec:CreateToggle(...) return Tab:CreateToggle(...) end
            function sec:CreateSlider(...) return Tab:CreateSlider(...) end
            function sec:CreateButton(...) return Tab:CreateButton(...) end
            function sec:CreateInput(...) return Tab:CreateInput(...) end
            function sec:CreateTextbox(...) return Tab:CreateTextbox(...) end
            function sec:CreateDropdown(...) return Tab:CreateDropdown(...) end
            function sec:CreateMultiDropdown(...) return Tab:CreateMultiDropdown(...) end
            function sec:CreateKeybind(...) return Tab:CreateKeybind(...) end
            function sec:CreateLabel(...) return Tab:CreateLabel(...) end
            function sec:CreateHeader(...) return Tab:CreateHeader(...) end
            function sec:CreateFeaturedCard(...) return Tab:CreateFeaturedCard(...) end
            function sec:CreateStatRow(...) return Tab:CreateStatRow(...) end
            function sec:CreateActionRow(...) return Tab:CreateActionRow(...) end
            function sec:CreateCardGroup(...) return Tab:CreateCardGroup(...) end
            function sec:CreateBlock(...) return Tab:CreateBlock(...) end
            return sec
        end

        function Tab:CreateToggle(cfg)
            local state = cfg.Default or false
            local row, right = Item(cfg, 32)
            local track = New("Frame", {
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, 0, 0.5, 0),
                Size = UDim2.fromOffset(32, 18),
                BackgroundColor3 = state and Theme.Text or Theme.ToggleOff,
                BorderSizePixel = 0,
                Parent = right,
            }, { Corner(9) })
            local knob = New("Frame", {
                AnchorPoint = Vector2.new(0, 0.5),
                Position = state and UDim2.new(0, 16, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
                Size = UDim2.fromOffset(14, 14),
                BackgroundColor3 = state and Theme.Surface or Theme.Knob,
                BorderSizePixel = 0,
                Parent = track,
            }, { Corner(7) })

            local Toggle = {}
            function Toggle:Set(value, silent)
                state = value
                Tween(track, 0.22, nil, nil, {
                    BackgroundColor3 = state and Theme.Text or Theme.ToggleOff,
                })
                Tween(knob, 0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
                    Position = state and UDim2.new(0, 16, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
                    BackgroundColor3 = state and Theme.Surface or Theme.Knob,
                })
                if not silent and cfg.Callback then task.spawn(cfg.Callback, state) end
            end
            function Toggle:Get() return state end

            local hit = New("TextButton", {
                Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, AutoButtonColor = false, Text = "", ZIndex = 3, Parent = row,
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
                Size = UDim2.new(0, 28, 1, 0), TextXAlignment = Enum.TextXAlignment.Right,
                Font = Enum.Font.Code, TextSize = 10, TextColor3 = Theme.Dim, Text = tostring(value),
            })
            local hit = New("TextButton", {
                Position = UDim2.fromOffset(38, 0), Size = UDim2.new(1, -38, 1, 0),
                BackgroundTransparency = 1, Text = "", AutoButtonColor = false, Parent = right,
            })
            local track = New("Frame", {
                AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.new(1, 0, 0, 3),
                BackgroundColor3 = Theme.ToggleOff, BorderSizePixel = 0, Parent = hit,
            }, { Corner(2) })
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
                local p = math.clamp((x - track.AbsolutePosition.X) / math.max(1, track.AbsoluteSize.X), 0, 1)
                Slider:Set(min + (max - min) * p)
            end
            hit.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = true
                    Tween(knob, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Size = UDim2.fromOffset(15, 15) })
                    fromX(input.Position.X)
                end
            end)
            TrackConn(UserInputService.InputChanged:Connect(function(input)
                if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    fromX(input.Position.X)
                end
            end))
            TrackConn(UserInputService.InputEnded:Connect(function(input)
                if sliding and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                    sliding = false
                    Tween(knob, 0.2, nil, nil, { Size = UDim2.fromOffset(12, 12) })
                end
            end))
            return Slider
        end

        function Tab:CreateButton(cfg)
            cfg = cfg or {}
            local btnText = cfg.Text or "Run"
            local titleText = cfg.Name or cfg.Title or cfg.Text or "Button"
            local w = math.max(54, #btnText * 7 + 32)
            local row, right = Item({ Name = titleText, Description = cfg.Description }, w)
            local b = Button(right, btnText, {
                AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(w, 28),
            }, false)
            local function fire()
                if cfg.Callback then task.spawn(cfg.Callback) end
            end
            b.MouseButton1Click:Connect(fire)
            local hit = New("TextButton", {
                Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, AutoButtonColor = false, Text = "", ZIndex = 2, Parent = row,
            })
            hit.MouseButton1Click:Connect(fire)
            Hover(row, hit)
            return {
                _frame = row,
                Button = b,
                Set = function(self, t) b.Text = tostring(t) end,
            }
        end

        function Tab:CreateTextbox(cfg)
            return Tab:CreateInput(cfg)
        end

        function Tab:CreateInput(cfg)
            cfg = cfg or {}
            local _, right = Item(cfg, 150)
            local box = New("TextBox", {
                Size = UDim2.fromScale(1, 1),
                BackgroundColor3 = Theme.Control,
                BorderSizePixel = 0,
                Text = cfg.Default or "",
                PlaceholderText = cfg.Placeholder or "Enter value...",
                PlaceholderColor3 = Theme.Faint,
                Font = Enum.Font.Gotham,
                TextSize = 11,
                TextColor3 = Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false,
                Parent = right,
            }, { Corner(7), New("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }) })
            local stroke = Rim(1)
            stroke.Parent = box
            box.Focused:Connect(function() Tween(stroke, 0.15, nil, nil, { Transparency = Theme.StrokeHover }) end)
            box.FocusLost:Connect(function(enter)
                Tween(stroke, 0.15, nil, nil, { Transparency = 1 })
                if cfg.Callback then
                    task.spawn(cfg.Callback, box.Text, enter)
                    if enter and cfg.ClearOnSubmit then box.Text = "" end
                end
            end)
            local Input = { _box = box }
            function Input:Set(v) box.Text = tostring(v) end
            function Input:Get() return box.Text end
            return Input
        end

        function Tab:CreateDropdown(cfg)
            local options = cfg.Options or {}
            local value = cfg.Default or options[1]
            local _, right = Item(cfg, 106)
            local field = Button(right, "", { Size = UDim2.fromScale(1, 1) }, false)
            local valueLabel = Label(field, {
                Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -28, 1, 0),
                Font = Enum.Font.GothamMedium, TextSize = 11, Text = tostring(value),
            })
            local arrow = Chevron(field, {
                AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0),
            }, Theme.Dim)

            local menu, closeConn
            local function close()
                if closeOpenDropdown == close then closeOpenDropdown = nil end
                if closeConn then closeConn:Disconnect() closeConn = nil end
                arrow:SetOpen(false, Theme.Text, Theme.Dim)
                if menu then
                    local m = menu
                    menu = nil
                    Tween(m, 0.18, nil, nil, { Size = UDim2.fromOffset(m.Size.X.Offset, 0) })
                    task.delay(0.2, function() pcall(function() m:Destroy() end) end)
                end
            end
            local function set(v)
                value = v
                valueLabel.Text = tostring(v)
                if cfg.Callback then task.spawn(cfg.Callback, v) end
            end

            field.MouseButton1Click:Connect(function()
                if menu then close() return end
                dismissDropdown()
                closeOpenDropdown = close
                arrow:SetOpen(true, Theme.Text, Theme.Dim)
                local width = math.max(120, field.AbsoluteSize.X)
                local height = #options * 28 + 8
                local ox = field.AbsolutePosition.X - Gui.AbsolutePosition.X
                local oy = field.AbsolutePosition.Y - Gui.AbsolutePosition.Y
                menu = New("Frame", {
                    Position = UDim2.fromOffset(ox + field.AbsoluteSize.X - width, oy + field.AbsoluteSize.Y + 6),
                    Size = UDim2.fromOffset(width, 0),
                    BackgroundColor3 = Theme.Menu,
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                    ZIndex = 50,
                    Parent = Gui,
                }, {
                    Corner(9),
                    Rim(Theme.StrokeAlpha),
                    New("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4) }),
                    New("UIListLayout", { Padding = UDim.new(0, 1), SortOrder = Enum.SortOrder.LayoutOrder }),
                })
                Tween(menu, 0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, { Size = UDim2.fromOffset(width, height) })
                for i, option in ipairs(options) do
                    local selected = option == value
                    local item = New("TextButton", {
                        Size = UDim2.new(1, 0, 0, 27),
                        BackgroundColor3 = Theme.Control,
                        BackgroundTransparency = selected and 0 or 1,
                        BorderSizePixel = 0,
                        AutoButtonColor = false,
                        Text = tostring(option),
                        Font = Enum.Font.GothamMedium,
                        TextSize = 11,
                        TextColor3 = selected and Theme.Text or Theme.Dim,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        LayoutOrder = i,
                        ZIndex = 51,
                        Parent = menu,
                    }, { Corner(6), New("UIPadding", { PaddingLeft = UDim.new(0, 10) }) })
                    item.MouseEnter:Connect(function()
                        Tween(item, 0.1, nil, nil, { BackgroundTransparency = 0, TextColor3 = Theme.Text })
                    end)
                    item.MouseLeave:Connect(function()
                        Tween(item, 0.1, nil, nil, {
                            BackgroundTransparency = selected and 0 or 1,
                            TextColor3 = selected and Theme.Text or Theme.Dim,
                        })
                    end)
                    item.MouseButton1Click:Connect(function()
                        set(option)
                        close()
                    end)
                end
                closeConn = TrackConn(UserInputService.InputBegan:Connect(function(input)
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
                end))
            end)

            local Dropdown = {}
            function Dropdown:Set(v) set(v) end
            function Dropdown:Get() return value end
            function Dropdown:Refresh(newOptions)
                options = newOptions or {}
                if not table.find(options, value) then
                    set(options[1] or "")
                end
            end
            return Dropdown
        end

        function Tab:CreateMultiDropdown(cfg)
            cfg = cfg or {}
            local options = cfg.Options or {}
            local selectedMap = {}
            if type(cfg.Default) == "table" then
                for k, v in pairs(cfg.Default) do
                    if type(k) == "number" then selectedMap[v] = true
                    elseif v == true then selectedMap[k] = true end
                end
            end

            local _, right = Item(cfg, 116)
            local field = Button(right, "", { Size = UDim2.fromScale(1, 1) }, false)
            local valueLabel = Label(field, {
                Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -28, 1, 0),
                Font = Enum.Font.GothamMedium, TextSize = 11, Text = "0 selected",
            })
            local arrow = Chevron(field, {
                AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0),
            }, Theme.Dim)

            local function updateCount()
                local count = 0
                for _, opt in ipairs(options) do
                    if selectedMap[opt] then count = count + 1 end
                end
                valueLabel.Text = count == 0 and "None" or (count .. " selected")
            end
            updateCount()

            local menu, closeConn
            local function close()
                if closeOpenDropdown == close then closeOpenDropdown = nil end
                if closeConn then closeConn:Disconnect() closeConn = nil end
                arrow:SetOpen(false, Theme.Text, Theme.Dim)
                if menu then
                    local m = menu
                    menu = nil
                    Tween(m, 0.18, nil, nil, { Size = UDim2.fromOffset(m.Size.X.Offset, 0) })
                    task.delay(0.2, function() pcall(function() m:Destroy() end) end)
                end
            end

            field.MouseButton1Click:Connect(function()
                if menu then close() return end
                dismissDropdown()
                closeOpenDropdown = close
                arrow:SetOpen(true, Theme.Text, Theme.Dim)
                local width = math.max(130, field.AbsoluteSize.X)
                local height = #options * 28 + 8
                local ox = field.AbsolutePosition.X - Gui.AbsolutePosition.X
                local oy = field.AbsolutePosition.Y - Gui.AbsolutePosition.Y
                menu = New("Frame", {
                    Position = UDim2.fromOffset(ox + field.AbsoluteSize.X - width, oy + field.AbsoluteSize.Y + 6),
                    Size = UDim2.fromOffset(width, 0),
                    BackgroundColor3 = Theme.Menu,
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                    ZIndex = 50,
                    Parent = Gui,
                }, {
                    Corner(9),
                    Rim(Theme.StrokeAlpha),
                    New("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4) }),
                    New("UIListLayout", { Padding = UDim.new(0, 1), SortOrder = Enum.SortOrder.LayoutOrder }),
                })
                Tween(menu, 0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, { Size = UDim2.fromOffset(width, height) })

                for i, option in ipairs(options) do
                    local isChecked = selectedMap[option] == true
                    local item = New("TextButton", {
                        Size = UDim2.new(1, 0, 0, 27),
                        BackgroundColor3 = Theme.Control,
                        BackgroundTransparency = isChecked and 0 or 1,
                        BorderSizePixel = 0,
                        AutoButtonColor = false,
                        Text = (isChecked and "[x]  " or "[ ]  ") .. tostring(option),
                        Font = Enum.Font.GothamMedium,
                        TextSize = 11,
                        TextColor3 = isChecked and Theme.Text or Theme.Dim,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        LayoutOrder = i,
                        ZIndex = 51,
                        Parent = menu,
                    }, { Corner(6), New("UIPadding", { PaddingLeft = UDim.new(0, 8) }) })

                    item.MouseButton1Click:Connect(function()
                        selectedMap[option] = not selectedMap[option]
                        local checked = selectedMap[option] == true
                        item.Text = (checked and "[x]  " or "[ ]  ") .. tostring(option)
                        item.TextColor3 = checked and Theme.Text or Theme.Dim
                        item.BackgroundTransparency = checked and 0 or 1
                        updateCount()
                        if cfg.Callback then task.spawn(cfg.Callback, selectedMap) end
                    end)
                end

                closeConn = TrackConn(UserInputService.InputBegan:Connect(function(input)
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
                end))
            end)

            local MultiDropdown = {}
            function MultiDropdown:Set(tbl)
                selectedMap = {}
                if type(tbl) == "table" then
                    for k, v in pairs(tbl) do
                        if type(k) == "number" then selectedMap[v] = true
                        elseif v == true then selectedMap[k] = true end
                    end
                end
                updateCount()
                if cfg.Callback then task.spawn(cfg.Callback, selectedMap) end
            end
            function MultiDropdown:Get() return selectedMap end
            function MultiDropdown:Refresh(newOptions)
                options = newOptions or {}
                local newMap = {}
                for _, opt in ipairs(options) do
                    if selectedMap[opt] then newMap[opt] = true end
                end
                selectedMap = newMap
                updateCount()
            end
            return MultiDropdown
        end

        function Tab:CreateLabel(textOrCfg)
            local text = type(textOrCfg) == "table" and (textOrCfg.Text or textOrCfg.Name or "") or tostring(textOrCfg)
            local row = New("Frame", {
                Size = UDim2.new(1, 0, 0, 28),
                BackgroundTransparency = 1,
                LayoutOrder = nextOrder(),
                Parent = Page,
            })
            local lbl = Label(row, {
                Position = UDim2.fromOffset(12, 0),
                Size = UDim2.new(1, -24, 1, 0),
                Font = Enum.Font.GothamMedium,
                TextSize = 11,
                TextColor3 = Theme.Dim,
                Text = text,
            })
            return {
                _label = lbl,
                _frame = row,
                Set = function(self, newText)
                    lbl.Text = tostring(newText)
                end,
            }
        end

        function Tab:CreateHeader(cfg)
            cfg = cfg or {}
            local hasSub = cfg.Subtitle ~= nil and cfg.Subtitle ~= ""
            local h = hasSub and 38 or 28
            local wrap = New("Frame", {
                Size = UDim2.new(1, 0, 0, h),
                BackgroundTransparency = 1,
                LayoutOrder = nextOrder(),
                Parent = Page,
            })
            Label(wrap, {
                Position = UDim2.fromOffset(2, 2),
                Size = UDim2.new(1, -4, 0, 16),
                Font = Enum.Font.GothamBold,
                TextSize = 13,
                TextColor3 = Theme.Text,
                Text = cfg.Title or "Header",
            })
            if hasSub then
                Label(wrap, {
                    Position = UDim2.fromOffset(2, 20),
                    Size = UDim2.new(1, -4, 0, 14),
                    Font = Enum.Font.Gotham,
                    TextSize = 10,
                    TextColor3 = Theme.Dim,
                    Text = cfg.Subtitle,
                })
            end
            return wrap
        end

        function Tab:CreateFeaturedCard(cfg)
            cfg = cfg or {}
            local hasDesc = cfg.Description ~= nil and cfg.Description ~= ""
            local h = hasDesc and 84 or 56
            local card = New("Frame", {
                Size = UDim2.new(1, 0, 0, h),
                BackgroundColor3 = Theme.Row,
                BorderSizePixel = 0,
                LayoutOrder = nextOrder(),
                Parent = Page,
            }, { Corner(9), Rim(Theme.StrokeAlpha) })

            Label(card, {
                Position = UDim2.fromOffset(12, 8),
                Size = UDim2.new(1, -110, 0, 14),
                Font = Enum.Font.GothamBold,
                TextSize = 10,
                TextColor3 = Theme.Faint,
                Text = string.upper(cfg.Tag or "FEATURED"),
            })
            Label(card, {
                Position = UDim2.fromOffset(12, 24),
                Size = UDim2.new(1, -110, 0, 18),
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                TextColor3 = Theme.Text,
                Text = cfg.Title or "",
            })
            if hasDesc then
                Label(card, {
                    Position = UDim2.fromOffset(12, 44),
                    Size = UDim2.new(1, -110, 0, 32),
                    Font = Enum.Font.Gotham,
                    TextSize = 10,
                    TextColor3 = Theme.Dim,
                    TextWrapped = true,
                    Text = cfg.Description,
                })
            end

            if cfg.ButtonText then
                local b = Button(card, cfg.ButtonText, {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -10, 0.5, 0),
                    Size = UDim2.fromOffset(math.max(68, #cfg.ButtonText * 7 + 24), 28),
                }, false)
                b.MouseButton1Click:Connect(function()
                    if cfg.Callback then task.spawn(cfg.Callback) end
                end)
            end
            return card
        end

        function Tab:CreateStatRow(stats)
            stats = stats or {}
            local count = #stats
            if count == 0 then return { _frame = nil } end
            local row = New("Frame", {
                Size = UDim2.new(1, 0, 0, 48),
                BackgroundTransparency = 1,
                LayoutOrder = nextOrder(),
                Parent = Page,
            }, {
                New("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    Padding = UDim.new(0, 6),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                })
            })

            local valLabels = {}
            for i, st in ipairs(stats) do
                local cell = New("Frame", {
                    Name = "Stat_" .. i,
                    Size = UDim2.new(1 / count, -math.floor((count - 1) * 6 / count), 1, 0),
                    BackgroundColor3 = Theme.Row,
                    BorderSizePixel = 0,
                    LayoutOrder = i,
                    Parent = row,
                }, { Corner(8), Rim(Theme.StrokeAlpha) })

                Label(cell, {
                    Position = UDim2.fromOffset(8, 6),
                    Size = UDim2.new(1, -16, 0, 12),
                    Font = Enum.Font.GothamMedium,
                    TextSize = 9,
                    TextColor3 = Theme.Dim,
                    Text = string.upper(st.Title or "STAT"),
                })
                local vl = Label(cell, {
                    Name = "ValueLabel",
                    Position = UDim2.fromOffset(8, 20),
                    Size = UDim2.new(1, -16, 0, 22),
                    Font = Enum.Font.GothamBold,
                    TextSize = 18,
                    TextColor3 = st.Color or Theme.Text,
                    Text = tostring(st.Value or "-"),
                })
                valLabels[i] = vl
                if st.Title then valLabels[st.Title] = vl end
            end

            local StatRowObj = { _frame = row }
            function StatRowObj:Update(key, newVal)
                local target = valLabels[key]
                if target then target.Text = tostring(newVal) end
            end
            return StatRowObj
        end

        function Tab:CreateActionRow(...)
            local buttons = { ... }
            local n = #buttons
            if n == 0 then return end
            local row = New("Frame", {
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundTransparency = 1,
                LayoutOrder = nextOrder(),
                Parent = Page,
            }, {
                New("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    Padding = UDim.new(0, 6),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                })
            })
            for i, bcfg in ipairs(buttons) do
                local b = Button(row, bcfg.Text or bcfg.Name or "Action", {
                    Size = UDim2.new(1 / n, -math.floor((n - 1) * 6 / n), 1, 0),
                    LayoutOrder = i,
                }, false)
                b.MouseButton1Click:Connect(function()
                    if bcfg.Callback then task.spawn(bcfg.Callback) end
                end)
            end
            return row
        end

        function Tab:CreateCardGroup(title)
            return Tab:CreateSection(title)
        end

        function Tab:CreateBlock(title)
            return Tab:CreateSection(title)
        end

        function Tab:CreateKeybind(cfg)
            local key = cfg.Default or Enum.KeyCode.RightShift
            local _, right = Item(cfg, 96)
            local field = Button(right, key.Name, { Size = UDim2.fromScale(1, 1), Font = Enum.Font.Code, TextSize = 10 }, false)
            local stroke = Rim(1)
            stroke.Parent = field
            local blink
            field.MouseButton1Click:Connect(function()
                if NexusLib.Listening then return end
                NexusLib.Listening = true
                field.Text = "..."
                Tween(stroke, 0.15, nil, nil, { Transparency = Theme.StrokeHover })
                blink = TweenService:Create(field, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { TextTransparency = 0.5 })
                blink:Play()
                local conn
                conn = TrackConn(UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        conn:Disconnect()
                        blink:Cancel()
                        Tween(stroke, 0.15, nil, nil, { Transparency = 1 })
                        field.TextTransparency = 0
                        key = input.KeyCode
                        field.Text = key.Name
                        task.defer(function() NexusLib.Listening = false end)
                        if cfg.Callback then task.spawn(cfg.Callback, key) end
                    end
                end))
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
-- DEMO (matches the Figma Make UI 1:1)
--------------------------------------------------------------------------
function NexusLib:Demo()
    local Island
    NexusLib:PlayInkIntro({
        OnPill = function()
            Island = NexusLib:CreateDynamicIsland({ Title = "Nexus", Status = "Active" })
        end,
        OnWindow = function()
            if not Island then
                Island = NexusLib:CreateDynamicIsland({ Title = "Nexus", Status = "Active" })
            end
            local Window = NexusLib:CreateWindow({ Title = "Nexus Hub", SubTitle = "Universal" })
            local state = {
                opt1 = true, opt2 = false, opt3 = true,
            }
            local function refreshStatus()
                local count = 0
                for _, v in pairs(state) do if v then count = count + 1 end end
                local s = count .. " active"
                Window.LastStatus = s
                if Window.Visible and Island then Island:SetStatus(s) end
            end
            Window.LastStatus = "Active"
            local function note(title, on)
                NexusLib:Notify({ Title = title, Content = on and "Enabled" or "Disabled" })
            end

            local Main = Window:CreateTab("Main")
            Main:CreateSection("Options")
            Main:CreateToggle({
                Name = "Option 1",
                Description = "Primary toggle feature",
                Default = true,
                Callback = function(on)
                    state.opt1 = on
                    refreshStatus()
                    note("Option 1", on)
                end,
            })
            Main:CreateToggle({
                Name = "Option 2",
                Description = "Secondary toggle feature",
                Default = false,
                Callback = function(on)
                    state.opt2 = on
                    refreshStatus()
                    note("Option 2", on)
                end,
            })
            Main:CreateDropdown({
                Name = "Priority Mode",
                Options = { "Mode A", "Mode B", "Mode C" },
                Default = "Mode A",
                Callback = function(v)
                    NexusLib:Notify({ Title = "Priority", Content = v })
                end,
            })

            Main:CreateSection("Preferences")
            Main:CreateSlider({
                Name = "Sensitivity",
                Min = 10,
                Max = 100,
                Default = 50,
                Callback = function(v)
                end,
            })
            Main:CreateInput({
                Name = "User Tag",
                Description = "Enter custom identifier",
                Placeholder = "Name",
                Callback = function(name)
                    NexusLib:Notify({ Title = "Profile", Content = "Updated: " .. name })
                end,
            })
            Main:CreateButton({
                Name = "Reset Settings",
                Text = "Reset",
                Callback = function()
                    NexusLib:Notify({ Title = "Settings", Content = "Restored to defaults" })
                end,
            })

            local Visual = Window:CreateTab("Visual")
            Visual:CreateSection("Display")
            Visual:CreateToggle({
                Name = "Show Highlights",
                Default = true,
                Callback = function(on) state.opt3 = on refreshStatus() note("Highlights", on) end,
            })
            Visual:CreateSlider({
                Name = "Field of view",
                Min = 70,
                Max = 120,
                Default = 90,
                Callback = function(v)
                    if workspace.CurrentCamera then
                        workspace.CurrentCamera.FieldOfView = v
                    end
                end,
            })

            local Settings = Window:CreateTab("Settings")
            Settings:CreateSection("Interface")
            Settings:CreateKeybind({
                Name = "Menu key",
                Description = "Click, then press a key",
                Default = NexusLib.ToggleKey,
                Callback = function(key)
                    NexusLib.ToggleKey = key
                    NexusLib:Notify({ Title = "Keybind", Content = "Menu key set to " .. key.Name })
                end,
            })
            Settings:CreateToggle({
                Name = "Show FPS in island",
                Default = true,
                Callback = function(on)
                    if Island then Island:SetStatsVisible(on) end
                end,
            })
            Settings:CreateToggle({
                Name = "Reduce motion",
                Default = false,
                Callback = function(on)
                    NexusLib.ReduceMotion = on
                end,
            })
            Settings:CreateSlider({
                Name = "Notification time",
                Description = "Seconds",
                Min = 1,
                Max = 8,
                Default = 3,
                Callback = function(v)
                    NexusLib.NotifyDuration = v
                end,
            })
            Settings:CreateSection("Config")
            Settings:CreateButton({
                Name = "Save config",
                Text = "Save",
                Callback = function()
                    NexusLib:Notify({ Title = "Config", Content = "Saved" })
                end,
            })
        end,
    })
end

pcall(function() getgenv().NexusLib = NexusLib end)

if not _G.NEXUS_LIB_ONLY and not (shared and shared.NEXUS_LIB_ONLY) then
    task.spawn(function()
        NexusLib:Demo()
    end)
end

return NexusLib
