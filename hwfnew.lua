--[[
 _   _  _______   ___   _ _____   _   _ _   _______
| \ | ||  ___\ \ / / | | /  ___| | | | | | | | ___ \
|  \| || |__  \ V /| | | \ `--.  | |_| | | | | |_/ /
| . ` ||  __| /   \| | | |`--. \ |  _  | | | | ___ \
| |\  || |___/ /^\ \ |_| /\__/ / | | | | |_| | |_/ /
\_| \_/\____/\/   \/\___/\____/  \_| |_/\___/\____/

]]
print([[
 _   _  _______   ___   _ _____   _   _ _   _______
| \ | ||  ___\ \ / / | | /  ___| | | | | | | | ___ \
|  \| || |__  \ V /| | | \ `--.  | |_| | | | | |_/ /
| . ` ||  __| /   \| | | |`--. \ |  _  | | | | ___ \
| |\  || |___/ /^\ \ |_| /\__/ / | | | | |_| | |_/ /
\_| \_/\____/\/   \/\___/\____/  \_| |_/\___/\____/   (siêu vip hẹ hẹ)

]])

-- Reuse the locally loaded Nexus build when launched through the executor MCP.
local runtimeEnv = (getgenv and getgenv()) or _G
local NexusLib = runtimeEnv.NexusLib or loadstring(game:HttpGet("https://raw.githubusercontent.com/Ngmankhoi/my-hub/refs/heads/main/NexusLib.lua"))()

if getgenv().MinigameAnchorLock then getgenv().MinigameAnchorLock:Disconnect() end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local Events = ReplicatedStorage:WaitForChild("Events", 9e9)
local MainGui = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("MainGui", 9e9)

-- Cleanup old toggle if any
for _, v in pairs(LocalPlayer:WaitForChild("PlayerGui"):GetChildren()) do
    if v.Name:find("MobileToggle") then v:Destroy() end
end
for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
    if v.Name:find("MobileToggle") then v:Destroy() end
end

local CODES = {
    "14M5Visits", "14MVisits", "15M5Visits", "15MVisits",
    "16M5Visits", "16MVisits", "17M5Visits", "17MVisits",
    "18M5Visits", "18MVisits", "19M5Visits", "19MVisits",
    "20M5Visits", "20MVisits", "21MVisits", "22MVisits",
    "34KLikes", "35KLikes", "36KLikes", "37KLikes",
    "38KLikes", "39KLikes", "40KLikes", "41KLikes",
    "6KActives",
    "AFK", "CodeBug", "Enzo", "Enzo2",
    "FreeReroll", "FreeReroll2", "HWF", "PEAK",
    "ThanksForNitroBoost", "WaitForPeak",
}

local Window = NexusLib:CreateWindow({
    Title = "NEXUS / FIELD UNIT",
    Subtitle = "HEAVYWEIGHT FISHING · LIVE SESSION",
    Keybind = Enum.KeyCode.RightAlt,
})

-- ==================== HOME TAB ====================
local HomeTab = Window:CreateTab("Session")

HomeTab:CreateHeader({
    Title = "Session overview",
    Subtitle = "Live instruments for " .. LocalPlayer.Name
})

local InfoSection = HomeTab:CreateSection("Release notes")

InfoSection:CreateButton({
    Name = "Review update · v1.8",
    Callback = function()
        NexusLib:Notify({
            Title = "Update Log",
            Message = "- NEW UI\n",
            Duration = 6
        })
    end
})

local statRow = HomeTab:CreateStatRow({
    {Title = "LEVEL", Value = "...", Color = Color3.fromRGB(190, 158, 103)},
    {Title = "BALANCE", Value = "...", Color = Color3.fromRGB(128, 159, 164)},
    {Title = "SESSION", Value = "00:00:00", Color = Color3.fromRGB(139, 161, 142)}
})

local hwid = "N/A"
pcall(function() hwid = game:GetService("RbxAnalyticsService"):GetClientId() end)

HomeTab:CreateFeaturedCard({
    Tag = "FIELD UNIT",
    Title = "Heavyweight Fishing · 1.8",
    Description = "Script by: Ngmankhoi,NgdepZaiNhatTG\nVersion: 1.8\nHWID: " .. string.sub(hwid, 1, 15) .. "...",
    ButtonText = "DISCORD",
    Callback = function()
        NexusLib:Notify({
            Title = "Discord",
            Message = "Link copied to clipboard!",
            Duration = 3
        })
        if setclipboard then setclipboard("https://discord.gg/gHxeHTMwRc") end
    end
})

-- Session playtime begins when this script is opened, not when the character joined.
local scriptStartTime = time()
task.spawn(function()
    local function setStat(statFrame, text)
        if not statFrame then return end
        for _, child in ipairs(statFrame:GetDescendants()) do
            if child:IsA("TextLabel") and child.TextSize >= 18 then
                child.Text = text
                return
            end
        end
    end

    while task.wait(1) do
        pcall(function()
            local mg = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("MainGui")

            -- Prefer replicated player values, then use the in-game HUD as a fallback.
            local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
            local function readNumber(names)
                for _, name in ipairs(names) do
                    local value = (leaderstats and leaderstats:FindFirstChild(name)) or LocalPlayer:GetAttribute(name)
                    if value then
                        local raw = value:IsA("ValueBase") and value.Value or value
                        if type(raw) == "number" then return tostring(raw) end
                    end
                end
            end

            -- Get Level
            local lvlText = readNumber({"Level", "level", "LVL"}) or "N/A"
            if mg then
                local lvlNode = mg:FindFirstChild("Level")
                if lvlNode then
                    local val = lvlNode:FindFirstChild("Value")
                    if val and val:IsA("TextLabel") then
                        local match = val.Text:match("Level:%s*(%d+)")
                        if match then lvlText = match else lvlText = val.Text end
                    end
                end
            end

            -- Get Money
            local cashText = readNumber({"Money", "Cash", "Coins", "Gold", "money", "cash"}) or "N/A"
            if mg then
                local cashNode = mg:FindFirstChild("Main") and mg.Main:FindFirstChild("Stats") and mg.Main.Stats:FindFirstChild("Cash")
                if cashNode then
                    local tl = cashNode:FindFirstChildOfClass("TextLabel")
                    if tl then cashText = tl.Text end
                end
            end

            -- Get Play Time
            local uptime = math.floor(time() - scriptStartTime)
            local h = math.floor(uptime / 3600)
            local m = math.floor((uptime % 3600) / 60)
            local s = uptime % 60
            local timeText = string.format("%02d:%02d:%02d", h, m, s)

            -- Update UI
            if statRow and statRow._frame then
                setStat(statRow._frame:FindFirstChild("Stat_1"), lvlText)
                setStat(statRow._frame:FindFirstChild("Stat_2"), cashText)
                setStat(statRow._frame:FindFirstChild("Stat_3"), timeText)
            end
        end)
    end
end)

-- ==================== FARMING TAB ====================
local FarmingTab = Window:CreateTab("Routine")
local FarmSection = FarmingTab:CreateSection("Fishing routine")
local Fishing = {
    Flags = {
        MainFarm = true,
        AutoCast = false,
        AutoSkill = false,
        AutoSkillEnabled = false,
        AutoFarmBoss = false,
        AutoFarmSecretBoss = false,
        UseSkillZ = true,
        UseSkillX = true,
        UseSkillC = true,
        UseSkillV = true,
        SkillDelay = 0.35,
        AnchorLock = false,
        AntiAFK = false,
        AutoSkillCheck = false
    },
    BossFarm = {
        CurrentTarget = nil,
        CurrentType = nil,
        CurrentToken = nil,
        CurrentRunId = 0,
        HasHooked = false,
        PendingCancel = false,
        LastCast = 0,
        LastCancel = 0,
        LastFastCancel = 0,
        LastSkill = 0,
        CastingSkills = false,
        LastProgress = 0,
        LastNotify = ""
    }
}
local MiscFlags = { FlyMode = false, Noclip = false, InfiniteJump = false, WalkOnWater = false, FullBright = false, AutoSell = false }
local State = getgenv().NexusState or {}
getgenv().NexusState = State
State.AntiAfkEnabled = false
State.LastAntiAfkAction = State.LastAntiAfkAction or "N/A"
State.NextAntiAfkActionAt = State.NextAntiAfkActionAt or 0
State.AntiAfkMethod = "IdleEvent + Timer"
State.AntiAfkLoopRunning = false
State.LastAntiAfkActionAt = State.LastAntiAfkActionAt or 0

FarmSection:CreateToggle({ Name = "Anchor (Lock Bar)", Default = false, Callback = function(V) Fishing.Flags.AnchorLock = V end })
FarmSection:CreateToggle({ Name = "Auto Cast", Default = false, Callback = function(V) Fishing.Flags.AutoCast = V end })
FarmSection:CreateToggle({ Name = "Auto Farm Boss", Default = false, Callback = function(V)
    Fishing.Flags.AutoFarmBoss = V
    if V then Fishing.Flags.AutoCast = false end
    if not V and not Fishing.Flags.AutoFarmSecretBoss then
        Fishing.BossFarm.CurrentTarget = nil
        Fishing.BossFarm.CurrentType = nil
        Fishing.BossFarm.CurrentToken = nil
        Fishing.BossFarm.HasHooked = false
        Fishing.BossFarm.PendingCancel = false
        Fishing.BossFarm.CurrentRunId = Fishing.BossFarm.CurrentRunId + 1
    end
end })
FarmSection:CreateToggle({ Name = "Auto Farm Secret Boss", Default = false, Callback = function(V)
    Fishing.Flags.AutoFarmSecretBoss = V
    if V then Fishing.Flags.AutoCast = false end
    if not V and not Fishing.Flags.AutoFarmBoss then
        Fishing.BossFarm.CurrentTarget = nil
        Fishing.BossFarm.CurrentType = nil
        Fishing.BossFarm.CurrentToken = nil
        Fishing.BossFarm.HasHooked = false
        Fishing.BossFarm.PendingCancel = false
        Fishing.BossFarm.CurrentRunId = Fishing.BossFarm.CurrentRunId + 1
    end
end })
FarmSection:CreateToggle({ Name = "Auto Skill", Default = false, Callback = function(V)
    Fishing.Flags.AutoSkill = V
    Fishing.Flags.AutoSkillEnabled = V
    if not V then Fishing.BossFarm.CastingSkills = false end
end })
FarmSection:CreateToggle({ Name = "Auto Sell Fish", Default = false, Callback = function(V) MiscFlags.AutoSell = V end })
FarmSection:CreateToggle({ Name = "Auto Enzo", Default = false, Callback = function(V) Fishing.Flags.AutoSkillCheck = V end })
FarmSection:CreateToggle({ Name = "Anti AFK", Default = false, Callback = function(V)
    Fishing.Flags.AntiAFK = V
    State.AntiAfkEnabled = V
    if V then
        if getgenv().NexusStartAntiAfk then getgenv().NexusStartAntiAfk() end
    else
        if getgenv().NexusStopAntiAfk then getgenv().NexusStopAntiAfk() end
    end
end })

local AntiAfkSection = FarmingTab:CreateSection("Anti-AFK Status")
local AntiAfkUi = { Status = nil, LastAction = nil, NextAction = nil, Method = nil }
local function createAntiAfkLabel(defaultText)
    local created = nil
    pcall(function()
        if AntiAfkSection.CreateLabel then
            created = AntiAfkSection:CreateLabel(defaultText)
        elseif AntiAfkSection.CreateParagraph then
            created = AntiAfkSection:CreateParagraph({ Title = defaultText, Content = "" })
        end
    end)
    return created
end
AntiAfkUi.Status = createAntiAfkLabel("Status: Stopped")
AntiAfkUi.LastAction = createAntiAfkLabel("Last Action: N/A")
AntiAfkUi.NextAction = createAntiAfkLabel("Next Action: N/A")
AntiAfkUi.Method = createAntiAfkLabel("Method: IdleEvent + Timer")

local SkillSection = FarmingTab:CreateSection("Skill Selection")
SkillSection:CreateToggle({ Name = "Use Z", Default = true, Callback = function(V) Fishing.Flags.UseSkillZ = V end })
SkillSection:CreateToggle({ Name = "Use X", Default = true, Callback = function(V) Fishing.Flags.UseSkillX = V end })
SkillSection:CreateToggle({ Name = "Use C", Default = true, Callback = function(V) Fishing.Flags.UseSkillC = V end })
SkillSection:CreateToggle({ Name = "Use V", Default = true, Callback = function(V) Fishing.Flags.UseSkillV = V end })

-- ==================== TELEPORT TAB ====================
local TeleportTab = Window:CreateTab("Teleport")
local TPSection = TeleportTab:CreateSection("NPC & Weather", "Left")

TPSection:CreateButton({
    Name = "TP to Taoist",
    Callback = function()
        local taoist = nil
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("Model") and string.find(v.Name:lower(), "taoist") and v:FindFirstChild("HumanoidRootPart") then taoist = v break end
        end
        if taoist and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = taoist.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4)
            NexusLib:Notify({ Title = "Taoist", Message = "Teleported!", Duration = 3 })
        else
            NexusLib:Notify({ Title = "Taoist", Message = "Not found!", Duration = 3 })
        end
    end
})

TPSection:CreateButton({
    Name = "TP to Maoshan",
    Callback = function()
        local maoshan = nil
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("Model") and (string.find(v.Name:lower(), "maoshan") or string.find(v.Name:lower(), "merchant")) and v:FindFirstChild("HumanoidRootPart") then
                maoshan = v
                break
            end
        end
        if maoshan and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = maoshan.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4)
            NexusLib:Notify({ Title = "Maoshan", Message = "Teleported!", Duration = 3 })
        else
            NexusLib:Notify({ Title = "Maoshan", Message = "Not found!", Duration = 3 })
        end
    end
})

local islands = {
    {name = "Island 1", cframe = CFrame.new(-227.55, 5.56, 18.23)},
    {name = "Island 2", cframe = CFrame.new(-1202.46, 6.76, -48.39)},
    {name = "Island 3", cframe = CFrame.new(71.63, 6.76, 1208.88)},
    {name = "Island 4", cframe = CFrame.new(-1226.98, 6.76, 1240.85)},
    {name = "Island 5", cframe = CFrame.new(67.43, 6.76, -1296.41)},
    {name = "Island 6", cframe = CFrame.new(-1349.34, 9.27, -1486.87)},
    {name = "Island 7", cframe = CFrame.new(1442.64, 9.27, -1484.09)},
    {name = "Island 8", cframe = CFrame.new(1259.40, 6.76, 1401.47)},
    {name = "Island 9", cframe = CFrame.new(1394.60, 9.27, 196.46)},
    {name = "Island 10", cframe = CFrame.new(2937.69, 6.77, 5.51)},
}

local weatherIslands = {
    ["foggy"] = "Island 7", ["blazing sun"] = "Island 8", ["snowy"] = "Island 6",
    ["windy"] = "Island 5", ["rainy"] = "Island 3", ["thunderstorm"] = "Island 2"
}

local function getCurrentWeather()
    local info = MainGui:FindFirstChild("Info")
    if info then
        local infoFrame = info:FindFirstChild("Info")
        if infoFrame then
            local weatherFrame = infoFrame:FindFirstChild("Weather")
            if weatherFrame then
                local val = weatherFrame:FindFirstChild("Value")
                if val then
                    local text = val:IsA("TextLabel") and val.Text or val.Value
                    return text:gsub("Weather:%s*", "")
                end
            end
        end
    end
    return "Clear"
end

TPSection:CreateButton({
    Name = "Teleport To Current Weather",
    Callback = function()
        local currentWeather = getCurrentWeather()
        if currentWeather:lower() == "clear" or currentWeather == "" then
            NexusLib:Notify({ Title = "Weather TP", Message = "Server weather is Clear, no event to TP!", Duration = 3 })
            return
        end
        local targetIslandName = weatherIslands[currentWeather:lower()]
        if targetIslandName then
            for _, v in ipairs(islands) do
                if v.name:lower() == targetIslandName:lower() then
                    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.CFrame = CFrame.new(v.cframe.Position) + Vector3.new(0, 5, 0)
                        NexusLib:Notify({ Title = "Weather TP", Message = "Teleported to " .. targetIslandName .. " for " .. currentWeather, Duration = 4 })
                    end
                    return
                end
            end
        else
            NexusLib:Notify({ Title = "Weather TP", Message = "Unknown weather island mapping for: " .. currentWeather, Duration = 4 })
        end
    end
})

local IslandSection = TeleportTab:CreateSection("Islands", "Right")

for _, v in ipairs(islands) do
    IslandSection:CreateButton({
        Name = v.name,
        Callback = function()
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = CFrame.new(v.cframe.Position) + Vector3.new(0, 5, 0)
                NexusLib:Notify({ Title = "Teleport", Message = "Teleported to " .. v.name, Duration = 3 })
            end
        end
    })
end

-- ==================== SETTINGS TAB ====================
local SettingsTab = Window:CreateTab("Settings")
local CharSection = SettingsTab:CreateSection("Character")

CharSection:CreateTextbox({ Name = "Walk Speed", Placeholder = "16", Default = "16", Callback = function(V) pcall(function() LocalPlayer.Character.Humanoid.WalkSpeed = tonumber(V) or 16 end) end })

local flying, flySpeed, bg, bv = false, 50, nil, nil
local function startFly()
    local c = LocalPlayer.Character if not c or not c:FindFirstChild("HumanoidRootPart") then return end
    local h = c.HumanoidRootPart
    bg = Instance.new("BodyGyro", h) bg.P = 9e4 bg.maxTorque = Vector3.new(9e9,9e9,9e9) bg.cframe = h.CFrame
    bv = Instance.new("BodyVelocity", h) bv.velocity = Vector3.new(0,0,0) bv.maxForce = Vector3.new(9e9,9e9,9e9)
    flying = true c.Humanoid.PlatformStand = true
end
local function stopFly()
    flying = false if bg then bg:Destroy() end if bv then bv:Destroy() end
    local c = LocalPlayer.Character if c and c:FindFirstChild("Humanoid") then c.Humanoid.PlatformStand = false end
end

CharSection:CreateToggle({ Name = "Fly Mode", Default = false, Callback = function(V) MiscFlags.FlyMode = V if V then startFly() else stopFly() end end })
CharSection:CreateTextbox({ Name = "Fly Speed", Placeholder = "50", Default = "50", Callback = function(V) flySpeed = tonumber(V) or 50 end })
CharSection:CreateToggle({ Name = "Noclip", Default = false, Callback = function(V) MiscFlags.Noclip = V end })
CharSection:CreateToggle({ Name = "Infinite Jump", Default = false, Callback = function(V) MiscFlags.InfiniteJump = V end })

local waterY = nil
local waterPart = Instance.new("Part")
waterPart.Size = Vector3.new(200, 1, 200) waterPart.Transparency = 1 waterPart.Anchored = true waterPart.CanCollide = true waterPart.Name = "WaterWalkPart"

CharSection:CreateToggle({
    Name = "Walk On Water", Default = false,
    Callback = function(V)
        MiscFlags.WalkOnWater = V
        if V then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then waterY = LocalPlayer.Character.HumanoidRootPart.Position.Y - 3.2 end
            pcall(function() for _, v in pairs(Workspace:GetDescendants()) do if v:IsA("BasePart") and (v.Name:lower():match("water") or v.Name:lower():match("ocean") or v.Material == Enum.Material.Water) then v.CanCollide = true end end end)
        else
            waterY = nil
            pcall(function() for _, v in pairs(Workspace:GetDescendants()) do if v:IsA("BasePart") and (v.Name:lower():match("water") or v.Name:lower():match("ocean") or v.Material == Enum.Material.Water) then v.CanCollide = false end end end)
        end
    end
})

local WorldSection = SettingsTab:CreateSection("World & Misc")
local origA, origB, origT, origBr, origOA = Lighting.Ambient, Lighting.ColorShift_Bottom, Lighting.ColorShift_Top, Lighting.Brightness, Lighting.OutdoorAmbient
WorldSection:CreateToggle({
    Name = "Full Bright", Default = false,
    Callback = function(V)
        MiscFlags.FullBright = V
        if not V then Lighting.Ambient = origA Lighting.ColorShift_Bottom = origB Lighting.ColorShift_Top = origT Lighting.Brightness = origBr Lighting.OutdoorAmbient = origOA end
    end
})

WorldSection:CreateButton({
    Name = "Redeem All Codes",
    Callback = function()
        task.spawn(function()
            for _, code in ipairs(CODES) do
                pcall(function() Events.RedeemCode:FireServer(code) end)
                task.wait(0.3)
            end
            NexusLib:Notify({ Title = "Codes", Message = "All codes redeemed!", Duration = 3 })
        end)
    end
})

WorldSection:CreateButton({
    Name = "Performance Mod",
    Callback = function()
        pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
        local t = Workspace:FindFirstChildOfClass("Terrain")
        if t then t.WaterWaveSize = 0 t.WaterWaveSpeed = 0 t.WaterReflectance = 0 t.WaterTransparency = 1 end
        Lighting.GlobalShadows = false Lighting.FogEnd = 9e9 Lighting.ShadowSoftness = 0
        Lighting.EnvironmentDiffuseScale = 0 Lighting.EnvironmentSpecularScale = 0
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect") then v:Destroy() end
        end
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic v.Reflectance = 0 v.CastShadow = false
            elseif v:IsA("Decal") or v:IsA("Texture") or v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then v:Destroy() end
        end
        NexusLib:Notify({ Title = "Performance", Message = "Optimized Game!", Duration = 3 })
    end
})

--// Inventory Helper \\--
local function GetInventoryLimit()
    local Data = ReplicatedStorage:FindFirstChild("Data")
    if not Data then return 0 end
    local userFolder = Data:FindFirstChild(tostring(LocalPlayer.UserId))
    if not userFolder then return 0 end

    local sum = 0
    pcall(function()
        for _, v in pairs(userFolder.Inventory:GetChildren()) do
            sum = sum + 1
        end
        for _, v in pairs(userFolder.Hotbar:GetChildren()) do
            sum = sum + v.Quantity.Value
        end
    end)
    return sum
end

local function IsInventoryFull()
    local Data = ReplicatedStorage:FindFirstChild("Data")
    if not Data then return false end
    local userFolder = Data:FindFirstChild(tostring(LocalPlayer.UserId))
    if not userFolder then return false end

    local limit = 0
    pcall(function()
        limit = userFolder.InventoryLimit.Value
    end)
    return GetInventoryLimit() >= limit
end

--// Boss / Secret Boss Roll Farm Helpers \--
local BossKeywords = { "boss", "raid", "giant", "king", "lord" }
local SecretBossKeywords = { "secret", "hidden", "mythic", "event", "rare" }
local SkillOrder = { "Z", "X", "C", "V" }
local BossNameSet, SecretBossNameSet = {}, {}

local function bossFarmEnabled()
    return Fishing.Flags.AutoFarmBoss or Fishing.Flags.AutoFarmSecretBoss
end

local function loadBossNameSets()
    table.clear(BossNameSet)
    table.clear(SecretBossNameSet)

    local Info = ReplicatedStorage:FindFirstChild("Info")
    if not Info then return end

    pcall(function()
        local areaRarity = Info:FindFirstChild("FishingAreaRarity")
        if areaRarity then
            local data = require(areaRarity)
            if type(data) == "table" and type(data["Secret Boss"]) == "table" then
                for fishName in pairs(data["Secret Boss"]) do
                    SecretBossNameSet[string.lower(tostring(fishName))] = true
                    BossNameSet[string.lower(tostring(fishName))] = true
                end
            end
        end
    end)

    pcall(function()
        local inv = Info:FindFirstChild("Inventory")
        if inv then
            for _, module in pairs(inv:GetChildren()) do
                if module:IsA("ModuleScript") then
                    local ok, data = pcall(require, module)
                    if ok and type(data) == "table" then
                        local name = string.lower(tostring(data.FishName or module.Name))
                        if data.Boss == true or data.SpecialBoss == true or data.SecretBoss == true then
                            BossNameSet[name] = true
                        end
                        if data.SecretBoss == true then
                            SecretBossNameSet[name] = true
                        end
                    end
                end
            end
        end
    end)
end
loadBossNameSets()

task.spawn(function()
    while task.wait(30) do
        loadBossNameSets()
    end
end)

local function textHasKeyword(text, keywords)
    text = string.lower(tostring(text or ""))
    for _, keyword in ipairs(keywords) do
        if string.find(text, keyword, 1, true) then
            return true
        end
    end
    return false
end

local function getCurrentHookTarget()
    local target = Fishing.BossFarm.CurrentTarget
    local info = { Name = nil, Data = nil, Instance = nil, Boss = false, SecretBoss = false }

    if type(target) == "table" then
        info.Data = target
        info.Name = target.FishName or target.Name or target.fishName
        info.Boss = target.Boss == true or target.SpecialBoss == true or target.SecretBoss == true
        info.SecretBoss = target.SecretBoss == true
    elseif typeof and typeof(target) == "Instance" then
        info.Instance = target
        info.Name = target:GetAttribute("FishName") or target.Name
        info.Boss = target:GetAttribute("Boss") == true or target:GetAttribute("SpecialBoss") == true or target:GetAttribute("SecretBoss") == true
        info.SecretBoss = target:GetAttribute("SecretBoss") == true
    elseif type(target) == "string" then
        info.Name = target
    end

    local fishId = LocalPlayer:GetAttribute("FishID")
    local fishes = Workspace:FindFirstChild("Fishes")
    local fishInst = fishId and fishes and fishes:FindFirstChild(tostring(fishId))
    if fishInst then
        info.Instance = fishInst
        info.Name = info.Name or fishInst:GetAttribute("FishName") or fishInst.Name
        info.Boss = info.Boss or fishInst:GetAttribute("Boss") == true or fishInst:GetAttribute("SpecialBoss") == true or fishInst:GetAttribute("SecretBoss") == true
        info.SecretBoss = info.SecretBoss or fishInst:GetAttribute("SecretBoss") == true
    end

    local fishingGui = MainGui:FindFirstChild("Fishing")
    local progression = fishingGui and fishingGui:FindFirstChild("ProgressionBar")
    local fishNameLabel = progression and progression:FindFirstChild("FishName")
    if (not info.Name or info.Name == "" or info.Name == "???") and fishNameLabel and fishNameLabel.Text ~= "" then
        info.Name = fishNameLabel.Text
    end

    return info
end

local function isSecretBossTarget(target)
    local t = target or getCurrentHookTarget()
    local name = string.lower(tostring(t.Name or ""))
    if t.SecretBoss or SecretBossNameSet[name] then
        return true
    end
    return textHasKeyword(name, SecretBossKeywords)
end

local function isBossTarget(target)
    local t = target or getCurrentHookTarget()
    local name = string.lower(tostring(t.Name or ""))
    if isSecretBossTarget(t) then
        return true
    end
    if t.Boss or BossNameSet[name] then
        return true
    end
    return textHasKeyword(name, BossKeywords)
end

local function shouldFarmBossTarget(target)
    local t = target or getCurrentHookTarget()
    if isSecretBossTarget(t) then
        return true, "Secret Boss"
    end
    if Fishing.Flags.AutoFarmSecretBoss and not Fishing.Flags.AutoFarmBoss then
        return false, "Normal"
    end
    if Fishing.Flags.AutoFarmBoss and isBossTarget(t) then
        return true, "Boss"
    end
    return false, "Normal"
end

local function castRod()
    if not bossFarmEnabled() then return false end
    if tick() - Fishing.BossFarm.LastCast < 0.35 then return false end

    local character = LocalPlayer.Character
    if not character then return false end

    if character:GetAttribute("Fishing") and not character:GetAttribute("Retractable") then
        return false
    end

    Fishing.BossFarm.LastCast = tick()
    Fishing.BossFarm.CurrentTarget = nil
    Fishing.BossFarm.CurrentType = nil
    Fishing.BossFarm.CurrentToken = nil
    Fishing.BossFarm.HasHooked = false
    Fishing.BossFarm.PendingCancel = false
    pcall(function()
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then Events.Fishing:FireServer(hrp.CFrame) end
    end)
    return true
end

local function resetBossFarmTarget()
    Fishing.BossFarm.CurrentTarget = nil
    Fishing.BossFarm.CurrentType = nil
    Fishing.BossFarm.CurrentToken = nil
    Fishing.BossFarm.HasHooked = false
    Fishing.BossFarm.PendingCancel = false
end

local function cancelOrReleaseNormalFish()
    if not bossFarmEnabled() then return false end

    local character = LocalPlayer.Character
    if not character then return false end

    if not character:GetAttribute("Fishing") then
        resetBossFarmTarget()
        return true
    end

    -- Cá thường đã hook: giữ PendingCancel để retry cho tới khi game cho rút cần.
    Fishing.BossFarm.PendingCancel = true

    -- Ép local minigame tự CleanUp(false) bằng cách đưa bar ra ngoài vùng.
    -- Sau đó gửi token p3 như client gốc và fallback bằng Fishing:FireServer khi Retractable=true.
    pcall(function()
        local fishingGui = MainGui:FindFirstChild("Fishing")
        local barFrame = fishingGui and fishingGui:FindFirstChild("BarFrame")
        local bar = barFrame and barFrame:FindFirstChild("Bar")
        if bar then
            bar.Position = UDim2.new(-0.15, 0, bar.Position.Y.Scale, bar.Position.Y.Offset)
        end
    end)

    if Fishing.BossFarm.CurrentToken and tick() - Fishing.BossFarm.LastFastCancel > 0.5 then
        Fishing.BossFarm.LastFastCancel = tick()
        pcall(function()
            Events.FishingMinigame:FireServer(false, Fishing.BossFarm.CurrentToken)
        end)
    end

    if not character:GetAttribute("Retractable") then
        return false
    end

    if tick() - Fishing.BossFarm.LastCancel < 0.35 then return false end
    Fishing.BossFarm.LastCancel = tick()

    pcall(function()
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then Events.Fishing:FireServer(hrp.CFrame) end
    end)

    return false
end

local function isSkillSelected(key)
    if key == "Z" then return Fishing.Flags.UseSkillZ == true end
    if key == "X" then return Fishing.Flags.UseSkillX == true end
    if key == "C" then return Fishing.Flags.UseSkillC == true end
    if key == "V" then return Fishing.Flags.UseSkillV == true end
    return false
end

local function getSelectedSkills()
    local selected = {}
    for _, key in ipairs(SkillOrder) do
        if isSkillSelected(key) then
            table.insert(selected, key)
        end
    end
    return selected
end

local function skillReady(key)
    local fishingGui = MainGui:FindFirstChild("Fishing")
    local skillFrame = fishingGui and fishingGui:FindFirstChild("SkillButton") and fishingGui.SkillButton:FindFirstChild("Frame")
    local button = skillFrame and skillFrame:FindFirstChild(key)
    if button and button:IsA("TextButton") then
        if button.Visible == false then return false end
        local cd = button:FindFirstChild("CD")
        if cd and cd:IsA("TextLabel") then
            local cdText = tostring(cd.Text or "")
            local cdNumber = tonumber(cdText:match("[%d%.]+"))
            if cdNumber and cdNumber > 0 then return false end
        end
    end

    local character = LocalPlayer.Character
    local skillsFolder = character and character:FindFirstChild("Skills")
    if not skillsFolder then return true end

    for _, skill in ipairs(skillsFolder:GetChildren()) do
        if skill:IsA("NumberValue") and skill:GetAttribute("Key") == key then
            return skill.Value <= 0
        end
    end
    return true
end

local function autoSkillEnabled()
    return Fishing.Flags.AutoSkill == true or Fishing.Flags.AutoSkillEnabled == true
end

local function isLiveBossSkillTarget()
    if not bossFarmEnabled() then return false end
    if Fishing.BossFarm.PendingCancel then return false end

    local character = LocalPlayer.Character
    if not character or not character:GetAttribute("Fishing") then return false end

    local fishingGui = MainGui:FindFirstChild("Fishing")
    if not fishingGui or not fishingGui.Visible then return false end

    local liveTarget = getCurrentHookTarget()
    local shouldFarm = shouldFarmBossTarget(liveTarget)
    if not shouldFarm then return false end

    return true, liveTarget
end

local function castSelectedSkills(target)
    if not autoSkillEnabled() then return end
    if Fishing.BossFarm.CastingSkills then return end

    local shouldFarm = shouldFarmBossTarget(target)
    if not shouldFarm then return end

    local selectedSkills = getSelectedSkills()
    if #selectedSkills == 0 then return end

    if tick() - Fishing.BossFarm.LastSkill < Fishing.Flags.SkillDelay then return end

    Fishing.BossFarm.CastingSkills = true
    local ok, err = pcall(function()
        for _, key in ipairs(SkillOrder) do
            if not autoSkillEnabled() then break end
            if not isSkillSelected(key) then continue end

            local liveOk = isLiveBossSkillTarget()
            if not liveOk then break end

            if skillReady(key) then
                Fishing.BossFarm.LastSkill = tick()
                pcall(function()
                    Events.UseSkill:FireServer(key)
                end)
                task.wait(Fishing.Flags.SkillDelay)
            end
        end
    end)
    Fishing.BossFarm.CastingSkills = false
end

local function farmHookedBoss(target)
    if not bossFarmEnabled() then return end
    local shouldFarm, targetType = shouldFarmBossTarget(target)
    if not shouldFarm then return end

    Fishing.BossFarm.CurrentType = targetType
    if Fishing.BossFarm.LastNotify ~= targetType .. tostring(target.Name) then
        Fishing.BossFarm.LastNotify = targetType .. tostring(target.Name)
        NexusLib:Notify({ Title = "Boss Farm", Message = "Farming " .. targetType .. ": " .. tostring(target.Name or "Unknown"), Duration = 3 })
    end

    if tick() - Fishing.BossFarm.LastProgress > 0.04 then
        Fishing.BossFarm.LastProgress = tick()
        pcall(function()
            Events.UpdateFishProgression:FireServer()
        end)
    end

    castSelectedSkills(target)
end

-- ==================== MAIN LOOPS ====================
task.spawn(function()
    while task.wait(0.5) do
        if Fishing.Flags.MainFarm then
            if Fishing.Flags.AutoCast then
                local c = LocalPlayer.Character
                if c then
                    -- Original working cast condition (removed auto-equip)
                    if not c:GetAttribute("Fishing") then
                        pcall(function()
                            local hrp = c:FindFirstChild("HumanoidRootPart")
                            if hrp then Events.Fishing:FireServer(hrp.CFrame) end
                        end)
                    end
                end
            end
            if autoSkillEnabled() and MainGui:FindFirstChild("Fishing") and MainGui.Fishing.Visible then
                pcall(function()
                    if bossFarmEnabled() then
                        local target = getCurrentHookTarget()
                        local shouldFarm = shouldFarmBossTarget(target)
                        if shouldFarm then
                            castSelectedSkills(target)
                        end
                    else
                        local char = LocalPlayer.Character
                        local skillsFolder = char and char:FindFirstChild("Skills")
                        if skillsFolder then
                            for _, key in ipairs(getSelectedSkills()) do
                                if skillReady(key) then
                                    Events.UseSkill:FireServer(key)
                                    task.wait(Fishing.Flags.SkillDelay)
                                end
                            end
                        end
                    end
                end)
            end
        end
    end
end)


task.spawn(function()
    while task.wait(0.2) do
        if bossFarmEnabled() then
            local character = LocalPlayer.Character
            local fishingGui = MainGui:FindFirstChild("Fishing")

            if character and character:GetAttribute("Fishing") then
                -- Đang chờ cá cắn: không rút cần ở state này.
                -- Khi đã hook cá thường thì giữ PendingCancel và retry tới khi rút được.
                if Fishing.BossFarm.PendingCancel then
                    cancelOrReleaseNormalFish()
                elseif Fishing.BossFarm.HasHooked and fishingGui and fishingGui.Visible then
                    local target = getCurrentHookTarget()
                    local shouldFarm = shouldFarmBossTarget(target)
                    if shouldFarm then
                        Fishing.BossFarm.PendingCancel = false
                        farmHookedBoss(target)
                    elseif target and target.Name and target.Name ~= "???" then
                        Fishing.BossFarm.PendingCancel = true
                        cancelOrReleaseNormalFish()
                    end
                end
            else
                resetBossFarmTarget()
                castRod()
            end
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if MiscFlags.AutoSell then 
            pcall(function() Events.SellFish:FireServer("All") end) 
        end
    end
end)

-- Minigame instant progression loop when AutoCast is enabled
Events.FishingMinigame.OnClientEvent:Connect(function(p1, p2, p3)
    if not p1 or not p2 then return end

    Fishing.BossFarm.CurrentTarget = p1
    Fishing.BossFarm.CurrentToken = p3
    Fishing.BossFarm.HasHooked = true
    Fishing.BossFarm.PendingCancel = false
    Fishing.BossFarm.CurrentRunId = Fishing.BossFarm.CurrentRunId + 1
    local runId = Fishing.BossFarm.CurrentRunId
    local target = getCurrentHookTarget()
    local shouldFarm, targetType = shouldFarmBossTarget(target)

    if bossFarmEnabled() and not shouldFarm then
        Fishing.BossFarm.PendingCancel = true
        task.delay(0.15, cancelOrReleaseNormalFish)
        return
    end

    if Fishing.Flags.AutoCast or (bossFarmEnabled() and shouldFarm) then
        task.spawn(function()
            local minigameActive = true
            local connection
            connection = MainGui.Fishing:GetPropertyChangedSignal("Visible"):Connect(function()
                if not MainGui.Fishing.Visible then
                    minigameActive = false
                    if connection then connection:Disconnect() end
                end
            end)

            while minigameActive do
                if bossFarmEnabled() then
                    if runId ~= Fishing.BossFarm.CurrentRunId then break end
                    target = getCurrentHookTarget()
                    shouldFarm, targetType = shouldFarmBossTarget(target)
                    if not shouldFarm then
                        Fishing.BossFarm.PendingCancel = true
                        cancelOrReleaseNormalFish()
                        break
                    end
                    farmHookedBoss(target)
                    task.wait(0.05)
                else
                    Events.UpdateFishProgression:FireServer()
                    task.wait(0.01)
                end
            end

            if bossFarmEnabled() and runId == Fishing.BossFarm.CurrentRunId then
                resetBossFarmTarget()
            end
        end)
    end
end)

Events.Slam.OnClientEvent:Connect(function(cb)
    if Fishing.Flags.MainFarm then
        task.spawn(function()
            task.wait(0.1)
            pcall(function() cb:FireServer("Perfect") end)
            local tc = MainGui:FindFirstChild("Fishing") and MainGui.Fishing:FindFirstChild("TrashCan")
            if tc and tc:FindFirstChild("Slam") then tc.Slam:Destroy() end
        end)
    end
end)

-- Focus-independent Auto Enzo solver
local prevBarPos = 0
local lastFrameTime = tick()
local currentSpeed = 0
local lastQTEClick = 0

RunService.RenderStepped:Connect(function()
    if Fishing.Flags.AnchorLock and not Fishing.BossFarm.PendingCancel and MainGui:FindFirstChild("Fishing") and MainGui.Fishing.Visible then
        local bf = MainGui.Fishing:FindFirstChild("BarFrame")
        local b = bf and bf:FindFirstChild("Bar")
        if b then b.Position = UDim2.new(0.5, 0, 0.5, 0) end
    end
    if flying and bg and bv and LocalPlayer.Character then
        local h = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then
            local cam = Workspace.CurrentCamera or Camera
            local cf = cam and cam.CFrame or h.CFrame
            -- W/S đi theo full hướng camera: nhìn lên thì bay lên, nhìn xuống thì bay xuống.
            local forward = cf.LookVector
            -- A/D giữ strafe ngang để dễ điều khiển, không bị kéo lên/xuống khi nghiêng camera.
            local right = Vector3.new(cf.RightVector.X, 0, cf.RightVector.Z)
            if forward.Magnitude > 0 then forward = forward.Unit end
            if right.Magnitude > 0 then right = right.Unit end

            local move = Vector3.new(0, 0, 0)
            if flyKeys.W then move = move + forward end
            if flyKeys.S then move = move - forward end
            if flyKeys.D then move = move + right end
            if flyKeys.A then move = move - right end
            if flyKeys.Up then move = move + Vector3.new(0, 1, 0) end
            if flyKeys.Down then move = move - Vector3.new(0, 1, 0) end

            if move.Magnitude > 0 then
                bv.Velocity = move.Unit * flySpeed
            else
                bv.Velocity = Vector3.new(0, 0, 0)
            end

            bg.CFrame = CFrame.new(h.Position, h.Position + cf.LookVector)
            if humanoid then
                humanoid.AutoRotate = false
                humanoid.PlatformStand = false
                humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
            end
        end
    end
    if MiscFlags.FullBright then
        Lighting.Ambient = Color3.new(1,1,1) Lighting.ColorShift_Bottom = Color3.new(1,1,1) Lighting.ColorShift_Top = Color3.new(1,1,1)
        Lighting.Brightness = 2 Lighting.OutdoorAmbient = Color3.new(1,1,1)
    end
    
    if Fishing.Flags.AutoSkillCheck then
        pcall(function()
            local fishing = MainGui:FindFirstChild("Fishing")
            local bossBar = fishing and fishing:FindFirstChild("BossFightBar")
            if bossBar and bossBar.Visible then
                local bar = bossBar:FindFirstChild("Bar")
                local hitbox = bossBar:FindFirstChild("Hitbox")
                if bar and hitbox then
                    local barPos = bar.Position.X.Scale
                    local hbPos = hitbox.Position.X.Scale
                    local hbSize = hitbox.Size.X.Scale
                    
                    local now = tick()
                    local dt = now - lastFrameTime
                    lastFrameTime = now
                    
                    if dt > 0.001 and dt < 0.1 then
                        local rawSpeed = (barPos - prevBarPos) / dt
                        prevBarPos = barPos
                        if math.abs(rawSpeed) < 5 then
                            currentSpeed = currentSpeed * 0.7 + rawSpeed * 0.3
                        end
                    else
                        prevBarPos = barPos
                    end
                    
                    -- Detect input latency dynamically based on device input type
                    local lastInput = UserInputService:GetLastInputType()
                    local latency = (lastInput == Enum.UserInputType.Touch) and 0.06 or 0.025
                    local compensatedBarPos = barPos - (currentSpeed * latency)
                    
                    local halfWidth = hbSize / 2
                    -- Use safe margin inside the green zone (15% of width)
                    local margin = hbSize * 0.15
                    
                    if compensatedBarPos >= (hbPos - halfWidth + margin) and compensatedBarPos <= (hbPos + halfWidth - margin) then
                        if tick() - lastQTEClick > 0.08 then
                            lastQTEClick = tick()
                            local mobileFishing = MainGui:FindFirstChild("Mobile") and MainGui.Mobile:FindFirstChild("Fishing")
                            if mobileFishing then
                                firesignal(mobileFishing.MouseButton1Down)
                            end
                        end
                    end
                else
                    prevBarPos = 0
                    lastFrameTime = tick()
                    currentSpeed = 0
                end
            else
                prevBarPos = 0
                lastFrameTime = tick()
                currentSpeed = 0
            end
        end)
    end
end)

RunService.Stepped:Connect(function()
    if MiscFlags.Noclip and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") and v.CanCollide then v.CanCollide = false end end
    end
    if MiscFlags.WalkOnWater and waterY and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local h = LocalPlayer.Character.HumanoidRootPart
        waterPart.Parent = Workspace waterPart.Position = Vector3.new(h.Position.X, waterY, h.Position.Z)
    else waterPart.Parent = nil end
end)

UserInputService.JumpRequest:Connect(function()
    if MiscFlags.InfiniteJump and LocalPlayer.Character then
        local h = LocalPlayer.Character:FindFirstChildOfClass('Humanoid')
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed or not flying then return end
    if input.KeyCode == Enum.KeyCode.W then flyKeys.W = true end
    if input.KeyCode == Enum.KeyCode.A then flyKeys.A = true end
    if input.KeyCode == Enum.KeyCode.S then flyKeys.S = true end
    if input.KeyCode == Enum.KeyCode.D then flyKeys.D = true end
    if input.KeyCode == Enum.KeyCode.Space then flyKeys.Up = true end
    if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Enum.KeyCode.LeftShift then flyKeys.Down = true end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then flyKeys.W = false end
    if input.KeyCode == Enum.KeyCode.A then flyKeys.A = false end
    if input.KeyCode == Enum.KeyCode.S then flyKeys.S = false end
    if input.KeyCode == Enum.KeyCode.D then flyKeys.D = false end
    if input.KeyCode == Enum.KeyCode.Space then flyKeys.Up = false end
    if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Enum.KeyCode.LeftShift then flyKeys.Down = false end
end)


-- ==================== PROACTIVE ANTI-AFK ====================
local ANTI_AFK_ACTION_INTERVAL = 12 * 60
local ANTI_AFK_TIMER_CHECK_MIN = 60
local ANTI_AFK_TIMER_CHECK_MAX = 120
local ANTI_AFK_DEBOUNCE = 45

local function updateAntiAfkLabel(label, text)
    if not label then return end
    pcall(function()
        if type(label) == "table" then
            if label.SetText then
                label:SetText(text)
            elseif label.Update then
                label:Update(text)
            elseif label.Set then
                label:Set(text)
            elseif label.Text ~= nil then
                label.Text = text
            elseif label.Title ~= nil then
                label.Title = text
            end
        elseif typeof and typeof(label) == "Instance" then
            if label:IsA("TextLabel") or label:IsA("TextButton") then
                label.Text = text
            end
        end
    end)
end

local function formatAntiAfkTime(seconds)
    seconds = math.max(0, math.floor(tonumber(seconds) or 0))
    local minutes = math.floor(seconds / 60)
    local remain = seconds % 60
    return string.format("%dm %02ds", minutes, remain)
end

local function getAntiAfkNextActionText()
    if not State.AntiAfkEnabled then return "N/A" end
    return formatAntiAfkTime(State.NextAntiAfkActionAt - os.time())
end

local function setAntiAfkStatus(text)
    State.AntiAfkStatus = text
    updateAntiAfkLabel(AntiAfkUi and AntiAfkUi.Status, "Status: " .. tostring(text))
    updateAntiAfkLabel(AntiAfkUi and AntiAfkUi.LastAction, "Last Action: " .. tostring(State.LastAntiAfkAction or "N/A"))
    updateAntiAfkLabel(AntiAfkUi and AntiAfkUi.NextAction, "Next Action: " .. getAntiAfkNextActionText())
    updateAntiAfkLabel(AntiAfkUi and AntiAfkUi.Method, "Method: " .. tostring(State.AntiAfkMethod or "IdleEvent + Timer"))
end

local function cleanupAntiAfkConnections()
    if getgenv().AntiAFKConnection then
        pcall(function() getgenv().AntiAFKConnection:Disconnect() end)
        getgenv().AntiAFKConnection = nil
    end
    if getgenv().NexusAntiAfkIdleConnection then
        pcall(function() getgenv().NexusAntiAfkIdleConnection:Disconnect() end)
        getgenv().NexusAntiAfkIdleConnection = nil
    end
    if getgenv().NexusNeverKickLoop then
        pcall(function() task.cancel(getgenv().NexusNeverKickLoop) end)
        getgenv().NexusNeverKickLoop = nil
    end
    if getgenv().NexusAntiAfkTimerLoop then
        pcall(function() task.cancel(getgenv().NexusAntiAfkTimerLoop) end)
        getgenv().NexusAntiAfkTimerLoop = nil
    end
    if getgenv().NexusAntiAfkDisconnectFallbackConnection then
        pcall(function() getgenv().NexusAntiAfkDisconnectFallbackConnection:Disconnect() end)
        getgenv().NexusAntiAfkDisconnectFallbackConnection = nil
    end
    State.AntiAfkLoopRunning = false
end

local function notifyAntiAfk(title, message, duration)
    pcall(function()
        NexusLib:Notify({ Title = title, Message = message, Duration = duration or 3 })
    end)
end

local function performAntiAfkAction(reason)
    if not State.AntiAfkEnabled or not Fishing.Flags.AntiAFK then return false end

    local now = os.time()
    if State.LastAntiAfkActionAt and now - State.LastAntiAfkActionAt < ANTI_AFK_DEBOUNCE then
        setAntiAfkStatus("Debounced")
        return false
    end

    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local method = nil

    if humanoid and humanoid.Health > 0 then
        local okJump = pcall(function()
            humanoid.Jump = true
        end)
        if okJump then method = "Jump" end

        local okMove = pcall(function()
            humanoid:Move(Vector3.new(0.1, 0, 0), true)
            task.wait(0.15)
            humanoid:Move(Vector3.zero, true)
        end)
        if okMove then method = method and (method .. " + Move") or "Move" end
    end

    if not method then
        local okVirtualInput = pcall(function()
            local VirtualInputManager = game:GetService("VirtualInputManager")
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
            task.wait(0.05)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
        end)
        if okVirtualInput then method = "VirtualInput" end
    end

    if not method then
        local okVirtualUser = pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
        if okVirtualUser then method = "VirtualUser" end
    end

    if method then
        State.LastAntiAfkActionAt = now
        State.LastAntiAfkAction = method
        State.NextAntiAfkActionAt = now + ANTI_AFK_ACTION_INTERVAL
        State.AntiAfkMethod = "Idled + Timer"
        setAntiAfkStatus("Running")
        notifyAntiAfk("Anti-AFK", "Action sent: " .. method, 2)
        return true
    end

    setAntiAfkStatus("Action failed")
    return false
end

local function bindIdleEvent()
    if getgenv().NexusAntiAfkIdleConnection then
        pcall(function() getgenv().NexusAntiAfkIdleConnection:Disconnect() end)
        getgenv().NexusAntiAfkIdleConnection = nil
    end
    getgenv().NexusAntiAfkIdleConnection = LocalPlayer.Idled:Connect(function()
        performAntiAfkAction("Idled")
    end)
    getgenv().AntiAFKConnection = getgenv().NexusAntiAfkIdleConnection
end

local function startAntiAfkTimer()
    if State.AntiAfkLoopRunning then return end
    State.AntiAfkLoopRunning = true
    getgenv().NexusAntiAfkTimerLoop = task.spawn(function()
        while State.AntiAfkEnabled and Fishing.Flags.AntiAFK do
            local now = os.time()
            if State.NextAntiAfkActionAt <= 0 then
                State.NextAntiAfkActionAt = now + ANTI_AFK_ACTION_INTERVAL
            end
            if now >= State.NextAntiAfkActionAt then
                performAntiAfkAction("Timer")
            else
                setAntiAfkStatus("Running")
            end
            task.wait(math.random(ANTI_AFK_TIMER_CHECK_MIN, ANTI_AFK_TIMER_CHECK_MAX))
        end
        State.AntiAfkLoopRunning = false
    end)
end

local function bindDisconnectFallback()
    pcall(function()
        local GuiService = game:GetService("GuiService")
        if GuiService.ErrorMessageChanged then
            getgenv().NexusAntiAfkDisconnectFallbackConnection = GuiService.ErrorMessageChanged:Connect(function(message)
                if State.AntiAfkEnabled and message and tostring(message) ~= "" then
                    setAntiAfkStatus("Disconnected fallback")
                    task.delay(3, function()
                        if State.AntiAfkEnabled and getgenv().NexusAntiAfkRejoinBackup then
                            getgenv().NexusAntiAfkRejoinBackup()
                        end
                    end)
                end
            end)
        end
    end)
end

local function startAntiAfk()
    cleanupAntiAfkConnections()
    State.AntiAfkEnabled = true
    Fishing.Flags.AntiAFK = true
    State.AntiAfkMethod = "Idled + Timer"
    State.NextAntiAfkActionAt = os.time() + ANTI_AFK_ACTION_INTERVAL
    bindIdleEvent()
    bindDisconnectFallback()
    startAntiAfkTimer()
    setAntiAfkStatus("Running")
    notifyAntiAfk("Anti-AFK", "Enabled: proactive idle prevention", 3)
end

local function stopAntiAfk()
    State.AntiAfkEnabled = false
    Fishing.Flags.AntiAFK = false
    cleanupAntiAfkConnections()
    State.NextAntiAfkActionAt = 0
    setAntiAfkStatus("Stopped")
    notifyAntiAfk("Anti-AFK", "Disabled", 2)
end

-- Backup only: no proactive rejoin loop. This is kept as a callable fallback for external disconnect handlers.
local function antiAfkRejoinBackup()
    pcall(function()
        local TeleportService = game:GetService("TeleportService")
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)
end

getgenv().NexusStartAntiAfk = startAntiAfk
getgenv().NexusStopAntiAfk = stopAntiAfk
getgenv().NexusPerformAntiAfkAction = performAntiAfkAction
getgenv().NexusAntiAfkRejoinBackup = antiAfkRejoinBackup

cleanupAntiAfkConnections()
setAntiAfkStatus("Stopped")
task.wait(1.5)
NexusLib:Notify({
    Title = "Nexus Hub",
    Message = "Tysm for using the script!",
    Duration = 7
})

task.wait(0.5)
NexusLib:Notify({
    Title = "Join our Discord!",
    Message = "Join Discord for updates & support!",
    Duration = 10
})
getgenv().AutoFarm = true


