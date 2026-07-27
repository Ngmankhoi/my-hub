-- [[ MASTER CLEAN KAITUN SCRIPT ]] --
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId

-- 1. Fetch Real Game Name (No fallback "Game (0)")
local GameName = ""
if PlaceId and PlaceId > 0 then
    local okGame, gameInfo = pcall(function()
        return MarketplaceService:GetProductInfo(PlaceId)
    end)
    if okGame and gameInfo and gameInfo.Name then
        GameName = gameInfo.Name
    end
end

-- 2. Target Parent Execution
local TargetParent = gethui and gethui() or (RunService:IsStudio() and (LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") or game:GetService("StarterGui")) or CoreGui)

if TargetParent:FindFirstChild("KaitunOverlay") then
    TargetParent.KaitunOverlay:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KaitunOverlay"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = TargetParent

-- Floating Main Card
local OverlayCard = Instance.new("Frame")
OverlayCard.Size = UDim2.new(0, 460, 0, 205)
OverlayCard.Position = UDim2.new(0.5, -230, 0.04, 0)
OverlayCard.BackgroundColor3 = Color3.fromRGB(14, 15, 22)
OverlayCard.BorderSizePixel = 0
OverlayCard.ClipsDescendants = true
OverlayCard.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 14)
UICorner.Parent = OverlayCard

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(0, 229, 255)
UIStroke.Thickness = 1.5
UIStroke.Transparency = 0.2
UIStroke.Parent = OverlayCard

-- Header Title (No Icon, No OVERLAY, Clean Game Name)
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 38)
Header.BackgroundColor3 = Color3.fromRGB(20, 22, 32)
Header.BorderSizePixel = 0
Header.Parent = OverlayCard

local HeaderTextString = "<b>KAITUN</b>"
if GameName ~= "" then
    HeaderTextString = "<b>KAITUN</b> | <font color='#00E5FF'>" .. GameName .. "</font>"
end

local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Size = UDim2.new(1, -20, 1, 0)
HeaderTitle.Position = UDim2.new(0, 12, 0, 0)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = HeaderTextString
HeaderTitle.RichText = true
HeaderTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
HeaderTitle.TextSize = 13
HeaderTitle.Font = Enum.Font.GothamBold
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.Parent = Header

-- User Headshot Avatar
local AvatarFrame = Instance.new("ImageLabel")
AvatarFrame.Size = UDim2.new(0, 40, 0, 40)
AvatarFrame.Position = UDim2.new(0, 12, 0, 46)
AvatarFrame.BackgroundColor3 = Color3.fromRGB(25, 28, 40)
AvatarFrame.Image = "rbxassetid://0"
AvatarFrame.Parent = OverlayCard

local AvatarCorner = Instance.new("UICorner")
AvatarCorner.CornerRadius = UDim.new(1, 0)
AvatarCorner.Parent = AvatarFrame

local AvatarStroke = Instance.new("UIStroke")
AvatarStroke.Color = Color3.fromRGB(0, 229, 255)
AvatarStroke.Thickness = 1
AvatarStroke.Parent = AvatarFrame

if LocalPlayer then
    task.spawn(function()
        local content = Players:GetUserThumbnailAsync(
            LocalPlayer.UserId,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size420x420
        )
        if content then
            AvatarFrame.Image = content
        end
    end)
end

-- Account Display Name
local AccountText = LocalPlayer and (LocalPlayer.DisplayName .. " (@" .. LocalPlayer.Name .. ")") or ""
local UserLabel = Instance.new("TextLabel")
UserLabel.Size = UDim2.new(0, 320, 0, 40)
UserLabel.Position = UDim2.new(0, 60, 0, 46)
UserLabel.BackgroundTransparency = 1
UserLabel.Text = "Account: <font color='#00E5FF'>" .. AccountText .. "</font>"
UserLabel.RichText = true
UserLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
UserLabel.TextSize = 13
UserLabel.Font = Enum.Font.GothamBold
UserLabel.TextXAlignment = Enum.TextXAlignment.Left
UserLabel.Parent = OverlayCard

-- Task Box ("TASK:")
local TaskBox = Instance.new("Frame")
TaskBox.Size = UDim2.new(1, -24, 0, 44)
TaskBox.Position = UDim2.new(0, 12, 0, 94)
TaskBox.BackgroundColor3 = Color3.fromRGB(20, 22, 34)
TaskBox.Parent = OverlayCard

local TaskCorner = Instance.new("UICorner")
TaskCorner.CornerRadius = UDim.new(0, 8)
TaskCorner.Parent = TaskBox

local TaskTitle = Instance.new("TextLabel")
TaskTitle.Size = UDim2.new(1, -16, 0, 18)
TaskTitle.Position = UDim2.new(0, 10, 0, 3)
TaskTitle.BackgroundTransparency = 1
TaskTitle.Text = "TASK:"
TaskTitle.TextColor3 = Color3.fromRGB(120, 125, 140)
TaskTitle.TextSize = 10
TaskTitle.Font = Enum.Font.GothamBold
TaskTitle.TextXAlignment = Enum.TextXAlignment.Left
TaskTitle.Parent = TaskBox

local TaskStatus = Instance.new("TextLabel")
TaskStatus.Name = "TaskStatus"
TaskStatus.Size = UDim2.new(1, -16, 0, 18)
TaskStatus.Position = UDim2.new(0, 10, 0, 21)
TaskStatus.BackgroundTransparency = 1
TaskStatus.Text = "▶ Initializing Script..."
TaskStatus.TextColor3 = Color3.fromRGB(0, 255, 136)
TaskStatus.TextSize = 12
TaskStatus.Font = Enum.Font.GothamBold
TaskStatus.TextXAlignment = Enum.TextXAlignment.Left
TaskStatus.Parent = TaskBox

-- Expose SetTask API to Global Environment
local setTaskFunc = function(text)
    TaskStatus.Text = "▶ " .. tostring(text)
end
if getgenv then getgenv().SetTask = setTaskFunc end
_G.SetTask = setTaskFunc

-- Stats Row (LEVEL, MONEY, FPS)
local StatsRow = Instance.new("Frame")
StatsRow.Size = UDim2.new(1, -24, 0, 48)
StatsRow.Position = UDim2.new(0, 12, 0, 146)
StatsRow.BackgroundTransparency = 1
StatsRow.Parent = OverlayCard

local StatLayout = Instance.new("UIListLayout")
StatLayout.FillDirection = Enum.FillDirection.Horizontal
StatLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
StatLayout.Padding = UDim.new(0, 8)
StatLayout.Parent = StatsRow

local StatLabels = {}
local function CreateStatItem(key, name, defaultVal, colorHex)
    local Item = Instance.new("Frame")
    Item.Size = UDim2.new(0.315, 0, 1, 0)
    Item.BackgroundColor3 = Color3.fromRGB(22, 24, 36)
    Item.Parent = StatsRow

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Item

    local ValLabel = Instance.new("TextLabel")
    ValLabel.Name = "ValLabel"
    ValLabel.Size = UDim2.new(1, 0, 0, 24)
    ValLabel.Position = UDim2.new(0, 0, 0, 4)
    ValLabel.BackgroundTransparency = 1
    ValLabel.Text = defaultVal
    ValLabel.TextColor3 = Color3.fromHex(colorHex)
    ValLabel.TextSize = 14
    ValLabel.Font = Enum.Font.GothamBold
    ValLabel.Parent = Item

    local SubLabel = Instance.new("TextLabel")
    SubLabel.Size = UDim2.new(1, 0, 0, 14)
    SubLabel.Position = UDim2.new(0, 0, 0, 26)
    SubLabel.BackgroundTransparency = 1
    SubLabel.Text = name
    SubLabel.TextColor3 = Color3.fromRGB(140, 145, 160)
    SubLabel.TextSize = 10
    SubLabel.Font = Enum.Font.Gotham
    SubLabel.Parent = Item

    StatLabels[key] = ValLabel
end

CreateStatItem("Level", "LEVEL", "1", "00E5FF")
CreateStatItem("Money", "MONEY", "$0", "00FF88")
CreateStatItem("FPS", "FPS", "60 FPS", "FFAA00")

-- Formatting Helper ($1,234,567)
local function FormatNumber(val)
    local str = tostring(math.floor(tonumber(val) or 0))
    return str:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

-- FPS Tracker Loop
local frameCount = 0
local lastFpsUpdate = os.clock()

RunService.RenderStepped:Connect(function(dt)
    frameCount = frameCount + 1
    local now = os.clock()
    if now - lastFpsUpdate >= 0.5 then
        local currentFps = math.floor(frameCount / (now - lastFpsUpdate))
        StatLabels["FPS"].Text = currentFps .. " FPS"
        frameCount = 0
        lastFpsUpdate = now
    end
end)

-- Real-Time Level & Money Sync Loop
if LocalPlayer then
    task.spawn(function()
        while task.wait(0.5) do
            -- Level Fetch
            local lvl = 1
            local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
            local dataFolder = LocalPlayer:FindFirstChild("Data")
            
            if leaderstats and leaderstats:FindFirstChild("Level") then
                lvl = leaderstats.Level.Value
            elseif leaderstats and leaderstats:FindFirstChild("Lvl") then
                lvl = leaderstats.Lvl.Value
            elseif dataFolder and dataFolder:FindFirstChild("Level") then
                lvl = dataFolder.Level.Value
            elseif LocalPlayer:GetAttribute("Level") then
                lvl = LocalPlayer:GetAttribute("Level")
            end
            StatLabels["Level"].Text = FormatNumber(lvl)

            -- Money Fetch
            local money = 0
            if leaderstats and leaderstats:FindFirstChild("Money") then
                money = leaderstats.Money.Value
            elseif leaderstats and leaderstats:FindFirstChild("Beli") then
                money = leaderstats.Beli.Value
            elseif leaderstats and leaderstats:FindFirstChild("Gold") then
                money = leaderstats.Gold.Value
            elseif dataFolder and dataFolder:FindFirstChild("Money") then
                money = dataFolder.Money.Value
            elseif dataFolder and dataFolder:FindFirstChild("Beli") then
                money = dataFolder.Beli.Value
            elseif LocalPlayer:GetAttribute("Money") then
                money = LocalPlayer:GetAttribute("Money")
            end
            StatLabels["Money"].Text = "$" .. FormatNumber(money)
        end
    end)
end
