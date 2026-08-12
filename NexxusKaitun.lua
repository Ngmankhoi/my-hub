local StatusToast = {}

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local Palette = {
    surface = Color3.fromRGB(14, 16, 18),
    bevel = Color3.fromRGB(28, 32, 35),
    text = Color3.fromRGB(241, 243, 244),
    green = Color3.fromRGB(67, 235, 143),
    amber = Color3.fromRGB(255, 174, 62),
    red = Color3.fromRGB(255, 82, 92),
}

local Statuses = {
    success = { color = Palette.green, label = "ONLINE" },
    info = { color = Palette.green, label = "ACTIVE" },
    warning = { color = Palette.amber, label = "NOTICE" },
    error = { color = Palette.red, label = "ALERT" },
}

local Enter = TweenInfo.new(0.48, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local Exit = TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
local Soft = TweenInfo.new(0.26, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local PulseOut = TweenInfo.new(0.72, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
local PulseIn = TweenInfo.new(0.72, Enum.EasingStyle.Sine, Enum.EasingDirection.In)

local active = nil

local function create(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props) do obj[k] = v end
    obj.Parent = parent
    return obj
end

local function round(parent, r)
    return create("UICorner", { CornerRadius = UDim.new(0, r) }, parent)
end

local function tween(obj, info, props)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

function StatusToast.Show(config)
    config = config or {}
    if active then active:Close(true) end

    local state = Statuses[config.Status or "success"] or Statuses.success
    local text = config.Text or config.Message or "Loading..."

    local gui = Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("NexusStatusToast")
    if gui then gui:Destroy() end
    gui = create("ScreenGui", {
        Name = "NexusStatusToast",
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        DisplayOrder = 1002,
    }, Players.LocalPlayer.PlayerGui)

    local holder = create("Frame", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 14),
        Size = UDim2.fromOffset(278, 48),
    }, gui)

    local bezel = create("Frame", {
        BackgroundColor3 = Palette.bevel,
        BackgroundTransparency = 0.08,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
    }, holder)
    round(bezel, 24)
    create("UIStroke", { Color = Color3.fromRGB(125, 132, 132), Transparency = 0.68, Thickness = 1 }, bezel)

    local card = create("CanvasGroup", {
        BackgroundColor3 = Palette.surface,
        BackgroundTransparency = 0.01,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, -4, 1, -4),
        GroupTransparency = 1,
        ClipsDescendants = true,
    }, bezel)
    round(card, 22)

    local cardScale = create("UIScale", { Scale = 0.86 }, card)

    create("Frame", {
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 0.965,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 15, 0, 3),
        Size = UDim2.new(1, -30, 0, 1),
    }, card)

    local beacon = create("Frame", {
        BackgroundColor3 = Color3.fromRGB(19, 29, 27),
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 12, 0.5, 0),
        Size = UDim2.fromOffset(21, 21),
    }, card)
    round(beacon, 13)

    local beaconRim = create("UIStroke", { Color = state.color, Transparency = 0.77, Thickness = 1 }, beacon)

    local halo = create("Frame", {
        BackgroundColor3 = state.color,
        BackgroundTransparency = 0.81,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(15, 15),
    }, beacon)
    round(halo, 8)

    local dot = create("Frame", {
        BackgroundColor3 = state.color,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(10, 10),
    }, beacon)
    round(dot, 5)

    local msg = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 48, 0, 0),
        Size = UDim2.new(1, -62, 1, 0),
        Text = text,
        TextColor3 = Palette.text,
        TextTransparency = 1,
        TextSize = 14,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, card)

    local progress = create("Frame", {
        BackgroundColor3 = state.color,
        BorderSizePixel = 0,
        BackgroundTransparency = 0.34,
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 20, 1, -3),
        Size = UDim2.new(1, -40, 0, 1),
    }, card)
    round(progress, 1)

    local closed = false
    local handle = {}

    function handle:Update(nextText, nextStatus)
        if closed then return end
        if nextStatus then
            state = Statuses[nextStatus] or state
            beaconRim.Color = state.color
            halo.BackgroundColor3 = state.color
            dot.BackgroundColor3 = state.color
            progress.BackgroundColor3 = state.color
        end
        tween(msg, Soft, { TextTransparency = 1 }).Completed:Wait()
        if closed then return end
        msg.Text = nextText
        tween(msg, Soft, { TextTransparency = 0 })
    end

    function handle:Close(immediate)
        if closed then return end
        closed = true
        active = nil
        if immediate then gui:Destroy() return end
        tween(card, Exit, { GroupTransparency = 1 })
        tween(cardScale, Exit, { Scale = 0.91 })
        task.delay(0.24, function() if gui.Parent then gui:Destroy() end end)
    end

    active = handle

    tween(card, Enter, { GroupTransparency = 0 })
    tween(cardScale, TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 })
    tween(msg, TweenInfo.new(0.34, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { TextTransparency = 0 })

    task.spawn(function()
        while not closed and gui.Parent do
            tween(halo, PulseOut, { Size = UDim2.fromOffset(21, 21), BackgroundTransparency = 0.93 }).Completed:Wait()
            if closed then break end
            tween(halo, PulseIn, { Size = UDim2.fromOffset(15, 15), BackgroundTransparency = 0.81 }).Completed:Wait()
        end
    end)

    local dur = config.Duration or 5
    tween(progress, TweenInfo.new(dur, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 0, 1) })
    task.delay(dur, function() handle:Close() end)

    return handle
end

return StatusToast
