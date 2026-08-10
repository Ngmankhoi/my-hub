print([[
 _   _  _______   ___   _ _____   _   _ _   _______
| \ | ||  ___\ \ / / | | /  ___| | | | | | | | ___ \
|  \| || |__  \ V /| | | \ `--.  | |_| | | | | |_/ /
| . ` ||  __| /   \| | | |`--. \ |  _  | | | | ___ \
| |\  || |___/ /^\ \ |_| /\__/ / | | | | |_| | |_/ /
\\_| \\_/\\____/\\/   \\/\\___/\\____/  \\_| |_/\\___/\\____/   (sieu vip he he)
]])


local runtimeEnv = (getgenv and getgenv()) or _G
local NexusLib = runtimeEnv.NexusLib or loadstring(game:HttpGet("https://raw.githubusercontent.com/Ngmankhoi/my-hub/main/NexusLib.lua"))()

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
local Info = ReplicatedStorage:WaitForChild("Info", 9e9)
local Data = ReplicatedStorage:WaitForChild("Data", 9e9)

for _, v in pairs(LocalPlayer:WaitForChild("PlayerGui"):GetChildren()) do
    if v.Name:find("MobileToggle") then v:Destroy() end
end
for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
    if v.Name:find("MobileToggle") then v:Destroy() end
end

local CODES = {
    "BigUPD",
    "23MVisits",
    "24MVisits",
    "25MVisits",
    "26MVisits",
    "42KLikes",
    "43KLikes",
    "44KLikes",
    "45KLikes",
    "UIBUG"
}

local Window = NexusLib:CreateWindow({
    Title = "NEXUS / FIELD UNIT",
    Subtitle = "HEAVYWEIGHT FISHING - LIVE SESSION",
    Keybind = Enum.KeyCode.RightAlt,
})

local HomeTab = Window:CreateTab("Session")

HomeTab:CreateHeader({
    Title = "Session overview",
    Subtitle = "Live instruments for " .. LocalPlayer.Name
})

local InfoSection = HomeTab:CreateSection("Release notes")

InfoSection:CreateButton({
    Name = "Review update v1.8",
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
    Title = "Heavyweight Fishing 1.8",
    Description = "Script by: Ngmankhoi,NgdepZaiNhatTG\nVersion: 1.8\nHWID: " .. string.sub(hwid, 1, 15) .. "...",
    ButtonText = "DISCORD",
    Callback = function()
        NexusLib:Notify({
            Title = "Discord",
            Message = "Link copied to clipboard!",
            Duration = 3
        })
        if setclipboard then setclipboard("https://discord.gg/QAdVUX2wCH") end
    end
})

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

            local cashText = readNumber({"Money", "Cash", "Coins", "Gold", "money", "cash"}) or "N/A"
            if mg then
                local cashNode = mg:FindFirstChild("Main") and mg.Main:FindFirstChild("Stats") and mg.Main.Stats:FindFirstChild("Cash")
                if cashNode then
                    local tl = cashNode:FindFirstChildOfClass("TextLabel")
                    if tl then cashText = tl.Text end
                end
            end

            local uptime = math.floor(time() - scriptStartTime)
            local h = math.floor(uptime / 3600)
            local m = math.floor((uptime % 3600) / 60)
            local s = uptime % 60
            local timeText = string.format("%02d:%02d:%02d", h, m, s)

            if statRow and statRow._frame then
                setStat(statRow._frame:FindFirstChild("Stat_1"), lvlText)
                setStat(statRow._frame:FindFirstChild("Stat_2"), cashText)
                setStat(statRow._frame:FindFirstChild("Stat_3"), timeText)
            end
        end)
    end
end)

local FarmingTab = Window:CreateTab("Routine")
local FarmSection = FarmingTab:CreateSection("Fishing routine")
local Fishing = {
    Flags = {
        MainFarm = true,
        AutoCast = false,
        AutoSkill = false,
        SelectedSkills = { "Z", "X", "C", "V" },
        AutoFarmBoss = false,
        AutoFarmSecretBoss = false,
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
        LastProgress = 0,
        LastNotify = ""
    }
}
local MiscFlags = { FlyMode = false, Noclip = false, InfiniteJump = false, WalkOnWater = false, FullBright = false, AutoSell = false, AutoBuy = false, AutoEquipBait = false }

FarmSection:CreateToggle({ Name = "Lock catch bar", Default = false, Callback = function(V) Fishing.Flags.AnchorLock = V end })
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
FarmSection:CreateToggle({ Name = "Auto Skill", Default = false, Callback = function(V) Fishing.Flags.AutoSkill = V end })
FarmSection:CreateToggle({ Name = "Auto Sell Fish", Default = false, Callback = function(V) MiscFlags.AutoSell = V end })
FarmSection:CreateToggle({ Name = "Auto Enzo", Default = false, Callback = function(V) Fishing.Flags.AutoSkillCheck = V end })
FarmSection:CreateToggle({ Name = "Anti AFK", Default = false, Callback = function(V) Fishing.Flags.AntiAFK = V end })

local SkillSection = FarmingTab:CreateSection("Skill profile")
SkillSection:CreateMultiDropdown({
    Name = "Skills to press",
    Options = {"Z", "X", "C", "V"},
    Default = {"Z", "X", "C", "V"},
    Callback = function(values)
        Fishing.Flags.SelectedSkills = values
    end
})

local EquipSection = FarmingTab:CreateSection("Auto Equip")

local function GetPlayerData()
    if not Data then return nil end
    return Data:FindFirstChild(tostring(LocalPlayer.UserId))
end

local function GetModule(folder, name)
    local m = folder:FindFirstChild(name)
    if m then
        local ok, mod = pcall(require, m)
        if ok and type(mod) == "table" then return mod end
    end
    return nil
end

local function GetAvailableBaits()
    local p = GetPlayerData()
    if not p then return {} end
    local baits = {}
    local baitFolder = p:FindFirstChild("Bait")
    if not baitFolder then return {} end
    for _, b in pairs(baitFolder:GetChildren()) do
        if b:IsA("NumberValue") and b.Value > 0 then
            table.insert(baits, b.Name)
        end
    end
    return baits
end

local function GetBaitStats(baitName)
    local mod = GetModule(Info.Bait, baitName)
    if mod then return {Luck = mod.Luck or 0} end
    return {Luck = 0}
end

local function GetBestBait()
    local baits = GetAvailableBaits()
    local best, bestLuck = nil, -1
    for _, name in ipairs(baits) do
        local s = GetBaitStats(name)
        if s.Luck > bestLuck then bestLuck = s.Luck; best = name end
    end
    return best
end

local function EquipBait(baitName)
    if not baitName then return false end
    return pcall(function() Events.EquipBait:InvokeServer(baitName) end)
end

local function GetOwnedRods()
    local p = GetPlayerData()
    if not p then return {} end
    local rods = {}
    for _, f in pairs(p.FishingRodInventory:GetChildren()) do
        if f:IsA("Folder") and f.Owned and f.Owned.Value == true then
            table.insert(rods, f.Name)
        end
    end
    return rods
end

local function GetRodStats(rodName)
    local mod = GetModule(Info.Inventory, rodName)
    if mod then return {Power = mod.Power or 0, Luck = mod.Luck or 0} end
    return {Power = 0, Luck = 0}
end

local function GetBestRod()
    local rods = GetOwnedRods()
    local best, bestScore = nil, -1
    for _, name in ipairs(rods) do
        local s = GetRodStats(name)
        local score = s.Power + s.Luck
        if score > bestScore then bestScore = score; best = name end
    end
    return best
end

local function EquipRod(rodName)
    if not rodName then return false end
    return pcall(function() Events.EquipFishingRod:InvokeServer(rodName) end)
end

local function GetAvailableOrbs()
    local p = GetPlayerData()
    if not p then return {} end
    local orbs = {}
    local orbFolder = p:FindFirstChild("Orb")
    if not orbFolder then return {} end
    for _, f in pairs(orbFolder:GetChildren()) do
        if f:IsA("Folder") then
            local eq = f:FindFirstChild("Equipping")
            if eq and eq.Value == false then
                table.insert(orbs, f.Name)
            end
        end
    end
    return orbs
end

local function GetOrbStats(orbName)
    local p = GetPlayerData()
    if not p then return {} end
    local f = p.Orb:FindFirstChild(orbName)
    if not f then return {} end
    local stats = {}
    for _, child in pairs(f:GetChildren()) do
        if child:IsA("NumberValue") and child.Name ~= "Equipping" and child.Name ~= "Favorite" then
            stats[child.Name] = child.Value
        end
    end
    return stats
end

local function GetBestOrb()
    local orbs = GetAvailableOrbs()
    local best, bestScore = nil, -1
    for _, name in ipairs(orbs) do
        local s = GetOrbStats(name)
        local score = (s.Damage or 0) * 2 + (s.Luck or 0) * 1.5 + (s.Cash or 0) * 0.5
        if score > bestScore then bestScore = score; best = name end
    end
    return best
end

local function EquipOrb(orbName)
    if not orbName then return false end
    return pcall(function() Events.EquipOrb:InvokeServer(orbName) end)
end

EquipSection:CreateToggle({
    Name = "Auto Equip Best Bait",
    Default = false,
    Callback = function(value)
        MiscFlags.AutoEquipBait = value
        if value then
            NexusLib:Notify({ Title = "Auto Equip", Message = "Best bait will be equipped automatically", Duration = 2 })
        else
            NexusLib:Notify({ Title = "Auto Equip", Message = "Disabled", Duration = 2 })
        end
    end
})

EquipSection:CreateButton({
    Name = "Equip Best Rod",
    Callback = function()
        local best = GetBestRod()
        if best then
            if EquipRod(best) then
                NexusLib:Notify({ Title = "Equip Rod", Message = "Equipped best rod: " .. best, Duration = 2 })
            else
                NexusLib:Notify({ Title = "Equip Rod", Message = "Failed to equip rod", Duration = 2 })
            end
        else
            NexusLib:Notify({ Title = "Equip Rod", Message = "No rod available", Duration = 2 })
        end
    end
})

EquipSection:CreateButton({
    Name = "Equip Best Orb",
    Callback = function()
        local best = GetBestOrb()
        if best then
            if EquipOrb(best) then
                NexusLib:Notify({ Title = "Equip Orb", Message = "Equipped best orb: " .. best, Duration = 2 })
            else
                NexusLib:Notify({ Title = "Equip Orb", Message = "Failed to equip orb", Duration = 2 })
            end
        else
            NexusLib:Notify({ Title = "Equip Orb", Message = "No orb available", Duration = 2 })
        end
    end
})

task.spawn(function()
    while task.wait(3) do
        if MiscFlags.AutoEquipBait then
            pcall(function()
                local userId = LocalPlayer.UserId
                local userData = Data:FindFirstChild(tostring(userId))
                if not userData then return end
                local equippedBaitValue = userData:FindFirstChild("EquippedBait")
                if not equippedBaitValue then return end
                local currentBait = equippedBaitValue.Value or ""
                local best = GetBestBait()
                if best and best ~= currentBait then
                    if EquipBait(best) then
                        NexusLib:Notify({ Title = "Auto Equip", Message = "Equipped best bait: " .. best, Duration = 2 })
                    end
                end
            end)
        end
    end
end)

local ShopTab = Window:CreateTab("Shop")

local BuySection = ShopTab:CreateSection("Auto Buy Bait")
local function GetBuyableBaits()
    local baits = {}
    if not Info or not Info:FindFirstChild("Bait") then return {"No bait available"} end
    for _, child in pairs(Info.Bait:GetChildren()) do
        if child:IsA("ModuleScript") then
            local success, mod = pcall(require, child)
            if success and type(mod) == "table" and mod.Price and mod.Price > 0 then
                table.insert(baits, child.Name)
            end
        end
    end
    if #baits == 0 then return {"No bait available"} end
    return baits
end

local buyableBaits = GetBuyableBaits()
local selectedBait = buyableBaits[1] or "No bait available"
local buyBaitQuantity = 10
local buyBaitThreshold = 5

BuySection:CreateDropdown({
    Name = "Select Bait to Buy",
    Options = buyableBaits,
    Default = selectedBait,
    Callback = function(value)
        selectedBait = value
    end
})

BuySection:CreateTextbox({
    Name = "Buy Amount",
    Placeholder = "10",
    Default = "10",
    Callback = function(value)
        local num = tonumber(value)
        if num and num >= 1 then
            buyBaitQuantity = math.clamp(math.floor(num), 1, 100)
        end
    end
})

BuySection:CreateTextbox({
    Name = "Buy When Below",
    Placeholder = "5",
    Default = "5",
    Callback = function(value)
        local num = tonumber(value)
        if num and num >= 0 then
            buyBaitThreshold = math.floor(num)
        end
    end
})

BuySection:CreateButton({
    Name = "Buy Now",
    Callback = function()
        if selectedBait == "No bait available" then
            NexusLib:Notify({ Title = "Buy Bait", Message = "No bait selected", Duration = 2 })
            return
        end
        local ok, err = pcall(function()
            Events.BuyBait:FireServer(selectedBait, buyBaitQuantity)
        end)
        if ok then
            NexusLib:Notify({ Title = "Buy Bait", Message = "Bought " .. buyBaitQuantity .. "x " .. selectedBait, Duration = 2 })
        else
            NexusLib:Notify({ Title = "Buy Bait", Message = "Failed: " .. tostring(err), Duration = 2 })
        end
    end
})

local autoBuyToggle = BuySection:CreateToggle({
    Name = "Auto Buy Bait",
    Default = false,
    Callback = function(value)
        MiscFlags.AutoBuy = value
        if value then
            NexusLib:Notify({ Title = "Auto Buy", Message = "[ON] Buy " .. buyBaitQuantity .. " " .. buyBaitName, Duration = 3 })
        else
            NexusLib:Notify({ Title = "Auto Buy", Message = "OFF", Duration = 2 })
        end
    end
})

task.spawn(function()
    local lastBuyTick = 0
    while task.wait(1) do
        if MiscFlags.AutoBuy and (tick() - lastBuyTick) > 3 then
            local baitName = selectedBait
            local qty = buyBaitQuantity
            local threshold = buyBaitThreshold
            
            if baitName ~= "No bait available" then
                local count = -1
                pcall(function()
                    local userData = Data:FindFirstChild(tostring(LocalPlayer.UserId))
                    if not userData then return end
                    local baitFolder = userData:FindFirstChild("Bait")
                    if not baitFolder then return end
                    local bait = baitFolder:FindFirstChild(baitName)
                    if bait and (bait:IsA("NumberValue") or bait:IsA("IntValue")) then
                        count = bait.Value
                    end
                end)
                
                if count >= 0 and count < threshold then
                    lastBuyTick = tick()
                    pcall(function()
                        Events.BuyBait:FireServer(baitName, qty)
                    end)
                    NexusLib:Notify({ 
                        Title = "Auto Buy", 
                        Message = baitName .. ": " .. count .. " left - bought " .. qty,
                        Duration = 2 
                    })
                end
            end
        end
    end
end)

local RodSection = ShopTab:CreateSection("Auto Buy Rod")
local function GetBuyableRods()
    local p = Data and Data:FindFirstChild(tostring(LocalPlayer.UserId))
    if not p then return {"No rod available"} end
    local rods = {}
    local inv = p:FindFirstChild("FishingRodInventory")
    if not inv then return {"No rod available"} end
    for _, rodFolder in pairs(inv:GetChildren()) do
        if rodFolder:IsA("Folder") then
            local owned = rodFolder:FindFirstChild("Owned")
            if owned and owned.Value == false then
                local mod = Info and Info.Inventory and Info.Inventory:FindFirstChild(rodFolder.Name)
                if mod then
                    table.insert(rods, rodFolder.Name)
                end
            end
        end
    end
    if #rods == 0 then return {"No rod available"} end
    return rods
end

local buyableRods = GetBuyableRods()
local selectedRod = buyableRods[1] or "No rod available"

local rodDropdown = RodSection:CreateDropdown({
    Name = "Select Rod to Buy",
    Options = buyableRods,
    Default = selectedRod,
    Callback = function(value)
        selectedRod = value
    end
})

RodSection:CreateButton({
    Name = "Buy Selected Rod",
    Callback = function()
        if selectedRod == "No rod available" then
            NexusLib:Notify({ Title = "Buy Rod", Message = "No rod available to buy", Duration = 2 })
            return
        end
        pcall(function()
            Events.BuyFishingRod:FireServer(selectedRod)
            NexusLib:Notify({ Title = "Buy Rod", Message = "Bought " .. selectedRod, Duration = 2 })
        end)
    end
})

local LearnSection = ShopTab:CreateSection("Learn Skills")
local function GetLearnableSkills()
    local p = Data and Data:FindFirstChild(tostring(LocalPlayer.UserId))
    if not p then return {"No skill available"} end
    local skills = {}
    for _, skillFolder in pairs(p.Skill:GetChildren()) do
        if skillFolder:IsA("Folder") then
            local owned = skillFolder:FindFirstChild("Owned")
            if owned and owned.Value == false then
                local mod = Info and Info.Skill and Info.Skill:FindFirstChild(skillFolder.Name)
                if mod then
                    local ok, m = pcall(require, mod)
                    if ok and m and m.Price and m.Price > 0 then
                        table.insert(skills, skillFolder.Name)
                    end
                end
            end
        end
    end
    if #skills == 0 then return {"No skill available"} end
    return skills
end

local learnableSkills = GetLearnableSkills()
local selectedLearnSkills = {}

local learnDropdown = LearnSection:CreateMultiDropdown({
    Name = "Select Skills to Learn",
    Options = learnableSkills,
    Default = {},
    Callback = function(values)
        selectedLearnSkills = values
    end
})

LearnSection:CreateButton({
    Name = "Learn Selected Skills",
    Callback = function()
        if #selectedLearnSkills == 0 then
            NexusLib:Notify({ Title = "Learn Skills", Message = "No skills selected", Duration = 2 })
            return
        end
        for _, skillName in ipairs(selectedLearnSkills) do
            pcall(function()
                Events.BuySkill:FireServer(skillName)
                NexusLib:Notify({ Title = "Learn Skills", Message = "Learned " .. skillName, Duration = 2 })
                task.wait(0.5)
            end)
        end
        NexusLib:Notify({ Title = "Learn Skills", Message = "All selected skills learned!", Duration = 3 })
    end
})

local TraitSection = ShopTab:CreateSection("Trait Reroll")
local function GetOwnedSkillNames()
    local p = Data and Data:FindFirstChild(tostring(LocalPlayer.UserId))
    if not p then return {"No skill owned"} end
    local skills = {}
    for _, f in pairs(p.Skill:GetChildren()) do
        if f:IsA("Folder") and f.Owned and f.Owned.Value == true then
            table.insert(skills, f.Name)
        end
    end
    if #skills == 0 then return {"No skill owned"} end
    return skills
end

local function GetTraitNames()
    local traits = {}
    if not Info or not Info:FindFirstChild("Trait") then return {"No trait available"} end
    for _, child in pairs(Info.Trait:GetChildren()) do
        if child:IsA("ModuleScript") then
            local ok, mod = pcall(require, child)
            if ok and type(mod) == "table" and mod.Name then
                table.insert(traits, mod.Name)
            end
        end
    end
    if #traits == 0 then return {"No trait available"} end
    return traits
end

local ownedSkills = GetOwnedSkillNames()
local selectedSkillForReroll = ownedSkills[1] or "No skill owned"
local traitNames = GetTraitNames()
local selectedTargetTrait = traitNames[1] or "No trait available"
local ignoreLocked = false

local traitSkillDropdown = TraitSection:CreateDropdown({
    Name = "Select Skill",
    Options = ownedSkills,
    Default = selectedSkillForReroll,
    Callback = function(value)
        selectedSkillForReroll = value
    end
})

local targetTraitDropdown = TraitSection:CreateDropdown({
    Name = "Target Trait",
    Options = traitNames,
    Default = selectedTargetTrait,
    Callback = function(value)
        selectedTargetTrait = value
    end
})

local ignoreLockedToggle = TraitSection:CreateToggle({
    Name = "Ignore Locked",
    Default = false,
    Callback = function(value)
        ignoreLocked = value
    end
})

local rerollRunning = false
local rerollThread = nil
local RerollTrait = Events:FindFirstChild("RerollTrait")

TraitSection:CreateButton({
    Name = "Reroll Until Trait",
    Callback = function()
        if rerollRunning then
            rerollRunning = false
            if rerollThread then
                task.cancel(rerollThread)
                rerollThread = nil
            end
            NexusLib:Notify({ Title = "Reroll", Message = "Stopped", Duration = 2 })
            return
        end

        local skillName = selectedSkillForReroll
        local targetTrait = selectedTargetTrait

        if not skillName or skillName == "" or skillName == "No skill owned" then
            NexusLib:Notify({ Title = "Reroll", Message = "Select a valid skill", Duration = 2 })
            return
        end

        if not targetTrait or targetTrait == "" or targetTrait == "No trait available" then
            NexusLib:Notify({ Title = "Reroll", Message = "Select a target trait", Duration = 2 })
            return
        end

        if not RerollTrait then
            NexusLib:Notify({ Title = "Reroll", Message = "RerollTrait event not found", Duration = 2 })
            return
        end

        local p = Data and Data:FindFirstChild(tostring(LocalPlayer.UserId))
        local rerollCount = p and p:FindFirstChild("Trait Reroll")
        if rerollCount and rerollCount.Value <= 0 then
            NexusLib:Notify({ Title = "Reroll", Message = "No rerolls left!", Duration = 2 })
            return
        end

        rerollRunning = true
        NexusLib:Notify({ Title = "Reroll", Message = "Reroll started... Target: " .. targetTrait, Duration = 2 })

        rerollThread = task.spawn(function()
            while rerollRunning do
                local p2 = Data and Data:FindFirstChild(tostring(LocalPlayer.UserId))
                local count = p2 and p2:FindFirstChild("Trait Reroll")
                if count and count.Value <= 0 then
                    NexusLib:Notify({ Title = "Reroll", Message = "No rerolls left, stopping", Duration = 2 })
                    break
                end

                local success, result = pcall(function()
                    return RerollTrait:InvokeServer(skillName, ignoreLocked)
                end)

                if not success or not result then
                    NexusLib:Notify({ Title = "Reroll", Message = "Reroll failed, stopping", Duration = 2 })
                    break
                end

                local traitName = result.Name
                if traitName == targetTrait then
                    NexusLib:Notify({ Title = "Reroll", Message = "Got " .. targetTrait .. " on " .. skillName .. "!", Duration = 3 })
                    break
                end

                task.wait(0.2)
            end

            rerollRunning = false
            rerollThread = nil
            NexusLib:Notify({ Title = "Reroll", Message = "Stopped", Duration = 2 })
        end)
    end
})

local gachaSection = ShopTab:CreateSection("Auto Gacha")

local function GetTicketCount()
    local userData = Data:FindFirstChild(tostring(LocalPlayer.UserId))
    if not userData then return 0 end
    local gachaData = userData:FindFirstChild("Gacha")
    if not gachaData then return 0 end
    local tickets = gachaData:FindFirstChild("Tickets")
    if tickets and tickets:IsA("NumberValue") then
        return tickets.Value
    end
    return 0
end

local function GetCrystals()
    local userData = Data:FindFirstChild(tostring(LocalPlayer.UserId))
    if not userData then return 0 end
    local names = {"Crystals", "Gems", "Diamonds", "Crystal", "Gem"}
    for _, name in ipairs(names) do
        local val = userData:FindFirstChild(name)
        if val and val:IsA("NumberValue") then
            return val.Value
        end
    end
    local currency = userData:FindFirstChild("Currency")
    if currency then
        for _, name in ipairs(names) do
            local val = currency:FindFirstChild(name)
            if val and val:IsA("NumberValue") then
                return val.Value
            end
        end
    end
    return 0
end

local bannerOptions = {"Egoless Banner", "Celestial Banner"}
local selectedBanner = bannerOptions[1]
local amountOptions = {"1", "10"}
local selectedAmount = "1"
local autoGachaRunning = false
local autoGachaThread = nil

local bannerDropdown = gachaSection:CreateDropdown({
    Name = "Select Banner",
    Options = bannerOptions,
    Default = selectedBanner,
    Callback = function(value)
        selectedBanner = value
    end
})

local amountDropdown = gachaSection:CreateDropdown({
    Name = "Tickets per roll",
    Options = amountOptions,
    Default = selectedAmount,
    Callback = function(value)
        selectedAmount = value
    end
})

local autoGachaToggle = gachaSection:CreateToggle({
    Name = "Auto Gacha",
    Default = false,
    Callback = function(value)
        autoGachaRunning = value
        if value then
            if autoGachaThread then
                task.cancel(autoGachaThread)
                autoGachaThread = nil
            end
            autoGachaThread = task.spawn(function()
                while autoGachaRunning do
                    pcall(function()
                        local ticketCount = GetTicketCount()
                        local needed = tonumber(selectedAmount) or 1
                        local crystalCount = GetCrystals()
                        local canRoll = false

                        if ticketCount >= needed then
                            canRoll = true
                        else
                            local missing = needed - ticketCount
                            local crystalsNeeded = missing * 5
                            if crystalCount >= crystalsNeeded then
                                canRoll = true
                            else
                                NexusLib:Notify({
                                    Title = "Gacha",
                                    Message = "Not enough tickets/crystals! Need " .. crystalsNeeded .. " crystals (have " .. crystalCount .. "). Stopping.",
                                    Duration = 4
                                })
                                autoGachaRunning = false
                                if autoGachaToggle and autoGachaToggle.Set then
                                    autoGachaToggle:Set(false)
                                end
                                return
                            end
                        end

                        if canRoll then
                            local isTen = (selectedAmount == "10")
                            Events.Gacha:FireServer(isTen, selectedBanner)
                            NexusLib:Notify({
                                Title = "Gacha",
                                Message = "Rolled " .. selectedAmount .. " ticket(s) on " .. selectedBanner,
                                Duration = 2
                            })
                        end
                    end)
                    task.wait(2)
                end
            end)
        else
            if autoGachaThread then
                task.cancel(autoGachaThread)
                autoGachaThread = nil
            end
            NexusLib:Notify({
                Title = "Gacha",
                Message = "Stopped",
                Duration = 2
            })
        end
    end
})

local QuestsTab = Window:CreateTab("Quests")

local ClaimSection = QuestsTab:CreateSection("Auto Claim Ticket Quest")

local questTypes = {"Easy Quest", "Hard Quest"}
local selectedQuest = questTypes[1]

local function HasActiveQuest()
    local userData = Data:FindFirstChild(tostring(LocalPlayer.UserId))
    if not userData then return false end

    local quest = userData:FindFirstChild("Quest")
    if not quest then return false end

    local main = quest:FindFirstChild("Main")
    if not main then return false end

    for _, child in pairs(main:GetChildren()) do
        if child:IsA("Folder") then
            local name = child.Name
            if name == "Easy Ticket Quest" or name == "Hard Ticket Quest" then
                return true
            end
        end
    end
    return false
end

local claimDropdown = ClaimSection:CreateDropdown({
    Name = "Select Quest Type",
    Options = questTypes,
    Default = selectedQuest,
    Callback = function(value)
        selectedQuest = value
    end
})

local autoClaimRunning = false
local autoClaimThread = nil

local function ClaimTicketQuest(questType)
    local action = (questType == "Easy Quest") and "EasyAcceptQuest" or "HardAcceptQuest"
    local extraData = {
        workspace.NPC.Function["Ticket Quest Giver"],
        "Ticket Quest"
    }
    pcall(function()
        Events.ChooseDialogueOption:FireServer(
            "Ticket Quest Giver",
            1,
            action,
            extraData
        )
    end)
end

local autoClaimToggle = ClaimSection:CreateToggle({
    Name = "Auto Claim Ticket Quest",
    Default = false,
    Callback = function(value)
        autoClaimRunning = value
        if value then
            if autoClaimThread then
                task.cancel(autoClaimThread)
                autoClaimThread = nil
            end
            autoClaimThread = task.spawn(function()
                while autoClaimRunning do
                    pcall(function()
                        if HasActiveQuest() then
                            NexusLib:Notify({
                                Title = "Quest",
                                Message = "Already have an active quest. Skipping...",
                                Duration = 2
                            })
                        else
                            ClaimTicketQuest(selectedQuest)
                            NexusLib:Notify({
                                Title = "Quest",
                                Message = "Claimed " .. selectedQuest,
                                Duration = 2
                            })
                        end
                    end)
                    task.wait(5)
                end
            end)
        else
            if autoClaimThread then
                task.cancel(autoClaimThread)
                autoClaimThread = nil
            end
            NexusLib:Notify({
                Title = "Quest",
                Message = "Auto claim stopped",
                Duration = 2
            })
        end
    end
})

local DoSection = QuestsTab:CreateSection("Auto Do Ticket Quest")

local autoDoRunning = false
local autoDoThread = nil
local ticketTargetCount = 0
local ticketCurrentCount = 0
local ticketQuestActive = false

local function parseQuestString(str)
    if not str or str == "" then return nil, nil end
    local parts = {}
    for part in string.gmatch(str, "[^,]+") do
        table.insert(parts, part)
    end
    if #parts >= 3 then
        local target = nil
        local typ = nil
        if string.find(parts[1], "Boss") then
            target = tonumber(parts[3])
            typ = parts[1]
        else
            target = tonumber(parts[2])
            typ = parts[3]
        end
        if target and typ then
            return target, typ
        end
    end
    return nil, nil
end

local function getCurrentQuestProgress()
    local userData = Data:FindFirstChild(tostring(LocalPlayer.UserId))
    if not userData then return nil end
    local quest = userData:FindFirstChild("Quest")
    if not quest then return nil end
    local main = quest:FindFirstChild("Main")
    if not main then return nil end
    
    for _, folder in pairs(main:GetChildren()) do
        if folder:IsA("Folder") and (folder.Name == "Easy Ticket Quest" or folder.Name == "Hard Ticket Quest") then
            local current = nil
            local target = nil
            local typ = nil
            local questName = folder.Name
            
            for _, child in pairs(folder:GetChildren()) do
                if child:IsA("NumberValue") or child:IsA("IntValue") then
                    if child.Name == "1" then
                        current = child.Value
                    end
                end
            end
            
            local objective = folder:FindFirstChild("Objective")
            if objective then
                for _, child in pairs(objective:GetChildren()) do
                    if child:IsA("StringValue") and child.Name == "1" then
                        local val = child.Value
                        if val and val ~= "" then
                            local t, ty = parseQuestString(val)
                            if t and ty then
                                target = t
                                typ = ty
                            end
                        end
                    end
                end
            end
            
            if current and target and typ then
                return current, target, questName, typ
            end
        end
    end
    return nil
end

local savedRoutineFlags = nil

local function saveRoutineFlags()
    savedRoutineFlags = {
        AutoCast = Fishing.Flags.AutoCast,
        AnchorLock = Fishing.Flags.AnchorLock,
        AutoSkill = Fishing.Flags.AutoSkill,
        AutoSell = MiscFlags.AutoSell,
        AutoSkillCheck = Fishing.Flags.AutoSkillCheck,
        AntiAFK = Fishing.Flags.AntiAFK,
        AutoFarmBoss = Fishing.Flags.AutoFarmBoss,
        AutoFarmSecretBoss = Fishing.Flags.AutoFarmSecretBoss,
        AutoBuy = MiscFlags.AutoBuy,
        AutoEquipBait = MiscFlags.AutoEquipBait,
    }
end

local function restoreRoutineFlags()
    if savedRoutineFlags then
        Fishing.Flags.AutoCast = savedRoutineFlags.AutoCast
        Fishing.Flags.AnchorLock = savedRoutineFlags.AnchorLock
        Fishing.Flags.AutoSkill = savedRoutineFlags.AutoSkill
        MiscFlags.AutoSell = savedRoutineFlags.AutoSell
        Fishing.Flags.AutoSkillCheck = savedRoutineFlags.AutoSkillCheck
        Fishing.Flags.AntiAFK = savedRoutineFlags.AntiAFK
        Fishing.Flags.AutoFarmBoss = savedRoutineFlags.AutoFarmBoss
        Fishing.Flags.AutoFarmSecretBoss = savedRoutineFlags.AutoFarmSecretBoss
        MiscFlags.AutoBuy = savedRoutineFlags.AutoBuy
        MiscFlags.AutoEquipBait = savedRoutineFlags.AutoEquipBait
        savedRoutineFlags = nil
    else
        Fishing.Flags.AutoFarmBoss = false
        Fishing.Flags.AutoFarmSecretBoss = false
    end
end

local function enableBasicFishing()
    if not savedRoutineFlags then
        saveRoutineFlags()
    end
    Fishing.Flags.AutoCast = true
    Fishing.Flags.AnchorLock = true
    Fishing.Flags.AutoSkill = true
    MiscFlags.AutoSell = true
    Fishing.Flags.AutoSkillCheck = true
    Fishing.Flags.AntiAFK = true
end

local function disableAllFishing()
    restoreRoutineFlags()
end

local function updateQuestStatus()
    local current, target, questName, typ = getCurrentQuestProgress()
    if current and target and questName then
        ticketTargetCount = target
        ticketCurrentCount = current
        ticketQuestActive = true

        if current >= target then
            NexusLib:Notify({ Title = "Quest", Message = "Complete! Claiming...", Duration = 3 })
            local extraData = { workspace.NPC.Function["Ticket Quest Giver"] }
            local actions = {"Claim", "Quest", "Complete", "CompleteQuest", "ClaimQuest", "Reward"}
            for _, action in ipairs(actions) do
                pcall(function()
                    Events.ChooseDialogueOption:FireServer("Ticket Quest Giver", 1, action, extraData)
                end)
                task.wait(0.2)
            end
            disableAllFishing()
            ticketQuestActive = false
            return
        end

        if typ and string.find(typ:lower(), "boss") then
            enableBasicFishing()
            Fishing.Flags.AutoFarmBoss = true
            Fishing.Flags.AutoFarmSecretBoss = false
            NexusLib:Notify({ Title = "Auto Do Quest", Message = "Farming bosses: " .. current .. "/" .. target, Duration = 3 })
        elseif typ == "Fishing" then
            enableBasicFishing()
            Fishing.Flags.AutoFarmBoss = false
            Fishing.Flags.AutoFarmSecretBoss = false
            NexusLib:Notify({ Title = "Auto Do Quest", Message = "Fishing: " .. current .. "/" .. target, Duration = 3 })
        elseif typ == "UseBait" then
            enableBasicFishing()
            Fishing.Flags.AutoFarmBoss = false
            Fishing.Flags.AutoFarmSecretBoss = false
            MiscFlags.AutoBuy = true
            local buyable = GetBuyableBaits()
            local found = false
            for _, name in ipairs(buyable) do
                if name == "Basic Bait" then
                    selectedBait = name
                    found = true
                    break
                end
            end
            if not found then
                selectedBait = buyable[1] or "No bait available"
            end
            MiscFlags.AutoEquipBait = true
            NexusLib:Notify({ Title = "Auto Do Quest", Message = "UseBait quest, farming with bait: " .. selectedBait, Duration = 3 })
        else
            enableBasicFishing()
            Fishing.Flags.AutoFarmBoss = false
            Fishing.Flags.AutoFarmSecretBoss = false
            NexusLib:Notify({ Title = "Auto Do Quest", Message = "Unknown type, farming as normal: " .. current .. "/" .. target, Duration = 3 })
        end
    else
        if ticketQuestActive then
            ticketQuestActive = false
            ticketTargetCount = 0
            ticketCurrentCount = 0
            disableAllFishing()
            NexusLib:Notify({ Title = "Auto Do Quest", Message = "No active quest found", Duration = 3 })
        end
    end
end

local function startAutoDoLoop()
    if autoDoThread then return end
    autoDoThread = task.spawn(function()
        while autoDoRunning do
            pcall(updateQuestStatus)
            task.wait(3)
        end
        autoDoThread = nil
    end)
end

local autoDoToggle = DoSection:CreateToggle({
    Name = "Auto Do Ticket Quest",
    Default = false,
    Callback = function(value)
        autoDoRunning = value
        if value then
            if autoDoThread then
                task.cancel(autoDoThread)
                autoDoThread = nil
            end
            startAutoDoLoop()
            NexusLib:Notify({ Title = "Auto Do Quest", Message = "Started monitoring quest objective", Duration = 2 })
        else
            if autoDoThread then
                task.cancel(autoDoThread)
                autoDoThread = nil
            end
            disableAllFishing()
            NexusLib:Notify({ Title = "Auto Do Quest", Message = "Stopped", Duration = 2 })
        end
    end
})

-- ===== TELEPORT TO RECOMMEND ISLAND (GAN NHAT) =====
local islands = {
    {name = "Island 1", cframe = CFrame.new(-297, 9, 12), power = 0},
    {name = "Island 2", cframe = CFrame.new(-1313, 9, 32), power = 17},
    {name = "Island 3", cframe = CFrame.new(57, 9, 1115), power = 28},
    {name = "Island 4", cframe = CFrame.new(-1343, 9, 1083), power = 35},
    {name = "Island 5", cframe = CFrame.new(38, 9, -1351), power = 45},
    {name = "Island 6", cframe = CFrame.new(-1184, 20, -1652), power = 55},
    {name = "Island 7", cframe = CFrame.new(1370, 9, -1458), power = 62},
    {name = "Island 8", cframe = CFrame.new(1130, 9, 1364), power = 72},
    {name = "Island 9", cframe = CFrame.new(1412, 9, 279), power = 90},
    {name = "Island 10", cframe = CFrame.new(3027, 9, 1), power = 100},
}

Events.PowerWarning.OnClientEvent:Connect(function() end)

local function getTotalPower()
    local total = 0
    local char = LocalPlayer.Character
    if char then
        local stats = char:FindFirstChild("Stats")
        if stats then
            local rp = stats:FindFirstChild("RodPower")
            if rp and rp:IsA("NumberValue") then
                total = total + rp.Value
            end
            local fp = stats:FindFirstChild("FishPower")
            if fp and fp:IsA("NumberValue") then
                total = total + fp.Value
            end
        end
        local attr = char:GetAttribute("RodPower")
        if attr and type(attr) == "number" and attr > 0 and total == 0 then
            total = attr
        end
    end
    if total == 0 then
        local userId = LocalPlayer.UserId
        local userData = Data:FindFirstChild(tostring(userId))
        if userData then
            local rodNameValue = userData:FindFirstChild("FishingRod")
            if rodNameValue then
                local rodName = rodNameValue.Value
                if rodName and rodName ~= "" then
                    local rodModule = Info:FindFirstChild("Inventory") and Info.Inventory:FindFirstChild(rodName)
                    if rodModule then
                        local success, rodData = pcall(require, rodModule)
                        if success and type(rodData) == "table" then
                            total = rodData.Power or 0
                        end
                    end
                end
            end
        end
    end
    return total
end

local autoRecommendRunning = false
local autoRecommendThread = nil

local RecommendToggle = DoSection:CreateToggle({
    Name = "Teleport to Recommend Island",
    Default = false,
    Callback = function(value)
        autoRecommendRunning = value
        if value then
            if autoRecommendThread then
                task.cancel(autoRecommendThread)
                autoRecommendThread = nil
            end
            autoRecommendThread = task.spawn(function()
                while autoRecommendRunning do
                    pcall(function()
                        local currentPower = getTotalPower()
                        local eligibleIslands = {}
                        for _, island in ipairs(islands) do
                            local req = island.power or 0
                            if req <= currentPower then
                                table.insert(eligibleIslands, island)
                            end
                        end
                        table.sort(eligibleIslands, function(a, b)
                            return a.power > b.power
                        end)
                        local bestIsland = nil
                        if #eligibleIslands >= 2 then
                            bestIsland = eligibleIslands[2]
                        elseif #eligibleIslands == 1 then
                            bestIsland = eligibleIslands[1]
                        end

                        if bestIsland then
                            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                local currentPos = hrp.Position
                                local targetPos = bestIsland.cframe.Position
                                local distance = (currentPos - targetPos).Magnitude
                                if distance > 10 then
                                    hrp.CFrame = CFrame.new(targetPos) + Vector3.new(0, 5, 0)
                                    NexusLib:Notify({
                                        Title = "Recommend",
                                        Message = "Teleported to " .. bestIsland.name .. " (Power " .. bestIsland.power .. " | Total: " .. currentPower .. ")",
                                        Duration = 2
                                    })
                                end
                            end
                        else
                            NexusLib:Notify({
                                Title = "Recommend",
                                Message = "No suitable island (Total Power: " .. currentPower .. ")",
                                Duration = 3
                            })
                        end
                    end)
                    task.wait()
                end
            end)
        else
            if autoRecommendThread then
                task.cancel(autoRecommendThread)
                autoRecommendThread = nil
            end
        end
    end
})

-- ===== UPGRADE TAB =====
local UpgradeTab = Window:CreateTab("Upgrade")
local UpgradeSection = UpgradeTab:CreateSection("Character Upgrade")

local optionsList = {"Cash", "Level", "Crystal", "Ticket"}
local selectedOptions = {"Cash", "Level"}
local UpgradeCharacter = Events:WaitForChild("UpgradeCharacter")

local multiDropdown = UpgradeSection:CreateMultiDropdown({
    Name = "Select 2 upgrade options",
    Options = optionsList,
    Default = selectedOptions,
    Callback = function(values)
        if #values > 2 then
            NexusLib:Notify({
                Title = "Upgrade",
                Message = "You can only select 2 options!",
                Duration = 2
            })
            local newValues = {}
            for i = #values - 1, #values do
                table.insert(newValues, values[i])
            end
            selectedOptions = newValues
            multiDropdown:Set(selectedOptions)
        else
            selectedOptions = values
        end
    end
})

local function checkResources(option1, option2)
    local userData = Data:FindFirstChild(tostring(LocalPlayer.UserId))
    if not userData then return false, "No user data" end

    local resources = {
        Cash = { path = userData:FindFirstChild("Cash"), needed = 5000000000 },
        Level = { path = userData:FindFirstChild("Level") and userData.Level:FindFirstChild("Level"), needed = 500 },
        Crystal = { path = userData:FindFirstChild("Crystal"), needed = 1000 },
        Ticket = { path = userData:FindFirstChild("Ticket"), needed = 200 }
    }

    local function getValue(res)
        if res and res.path then
            if res.path:IsA("NumberValue") or res.path:IsA("IntValue") then
                return res.path.Value
            end
        end
        return 0
    end

    local need1 = resources[option1]
    local need2 = resources[option2]
    if not need1 or not need2 then
        return false, "Invalid option"
    end

    local val1 = getValue(need1)
    local val2 = getValue(need2)
    if val1 >= need1.needed and val2 >= need2.needed then
        return true, "Enough"
    else
        local msg = option1 .. " (" .. val1 .. "/" .. need1.needed .. ") or " .. option2 .. " (" .. val2 .. "/" .. need2.needed .. ")"
        return false, "Not enough: " .. msg
    end
end

local autoRebirthRunning = false
local autoRebirthThread = nil

local autoToggle = UpgradeSection:CreateToggle({
    Name = "Auto Rebirth",
    Default = false,
    Callback = function(value)
        autoRebirthRunning = value
        if value then
            if autoRebirthThread then
                task.cancel(autoRebirthThread)
                autoRebirthThread = nil
            end
            autoRebirthThread = task.spawn(function()
                while autoRebirthRunning do
                    pcall(function()
                        if #selectedOptions ~= 2 then
                            NexusLib:Notify({
                                Title = "Auto Rebirth",
                                Message = "Please select exactly 2 options!",
                                Duration = 2
                            })
                            task.wait(2)
                            return
                        end

                        local ok, msg = checkResources(selectedOptions[1], selectedOptions[2])
                        if ok then
                            local result = UpgradeCharacter:InvokeServer(selectedOptions)
                            if result and result.ok then
                                NexusLib:Notify({
                                    Title = "Auto Rebirth",
                                    Message = "Upgraded successfully!",
                                    Duration = 2
                                })
                            else
                                NexusLib:Notify({
                                    Title = "Auto Rebirth",
                                    Message = "Upgrade failed: " .. (result and result.msg or "unknown error"),
                                    Duration = 3
                                })
                            end
                        else
                            if math.random(1, 5) == 1 then
                                NexusLib:Notify({
                                    Title = "Auto Rebirth",
                                    Message = msg,
                                    Duration = 3
                                })
                            end
                        end
                    end)
                    task.wait(2)
                end
            end)
        else
            if autoRebirthThread then
                task.cancel(autoRebirthThread)
                autoRebirthThread = nil
            end
            NexusLib:Notify({
                Title = "Auto Rebirth",
                Message = "Stopped",
                Duration = 2
            })
        end
    end
})

local function displayStats()
    local userData = Data:FindFirstChild(tostring(LocalPlayer.UserId))
    if not userData then return end
    local cash = userData:FindFirstChild("Cash") and userData.Cash.Value or 0
    local level = userData:FindFirstChild("Level") and userData.Level:FindFirstChild("Level") and userData.Level.Level.Value or 0
    local crystal = userData:FindFirstChild("Crystal") and userData.Crystal.Value or 0
    local ticket = userData:FindFirstChild("Ticket") and userData.Ticket.Value or 0
    NexusLib:Notify({
        Title = "Resources",
        Message = string.format("Cash: %.2fB | Level: %d | Crystal: %d | Ticket: %d", cash/1e9, level, crystal, ticket),
        Duration = 4
    })
end

UpgradeSection:CreateButton({
    Name = "Check Resources",
    Callback = displayStats
})

-- ===== KET THUC PHAN MOI =====

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

TPSection:CreateButton({
    Name = "TP to Spirit",
    Callback = function()
        local godFolder = workspace:FindFirstChild("NPC") and workspace.NPC:FindFirstChild("God")
        if not godFolder then
            NexusLib:Notify({ Title = "Spirit", Message = "Folder God not found!", Duration = 3 })
            return
        end
        local target = nil
        for _, child in pairs(godFolder:GetChildren()) do
            if child:IsA("Model") then
                local hrp = child:FindFirstChild("HumanoidRootPart")
                if hrp then
                    target = hrp
                    break
                end
            elseif child:IsA("BasePart") then
                target = child
                break
            end
        end
        if not target then
            NexusLib:Notify({ Title = "Spirit", Message = "No Spirit found!", Duration = 3 })
            return
        end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = target.CFrame + Vector3.new(0, 3, 0)
            NexusLib:Notify({ Title = "Spirit", Message = "Teleported to Spirit!", Duration = 3 })
        end
    end
})

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

local SettingsTab = Window:CreateTab("Settings")
local CharSection = SettingsTab:CreateSection("Character")

CharSection:CreateTextbox({ Name = "Walk Speed", Placeholder = "16", Default = "16", Callback = function(V) pcall(function() LocalPlayer.Character.Humanoid.WalkSpeed = tonumber(V) or 16 end) end })

local flying, flySpeed, bg, bv = false, 50, nil, nil
local flyInputConnection, flyInputEndConnection
local flyKeys = { Up = false, Down = false }
local function startFly()
    local c = LocalPlayer.Character
    if not c or not c:FindFirstChild("HumanoidRootPart") then return end
    if flying then return end
    if bg then bg:Destroy() end
    if bv then bv:Destroy() end
    local h = c.HumanoidRootPart
    bg = Instance.new("BodyGyro", h)
    bg.P = 9e4
    bg.maxTorque = Vector3.new(9e9,9e9,9e9)
    bg.cframe = h.CFrame
    bv = Instance.new("BodyVelocity", h)
    bv.velocity = Vector3.new(0,0,0)
    bv.maxForce = Vector3.new(9e9,9e9,9e9)
    flying = true
    local humanoid = c:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.PlatformStand = true
    end
    if flyInputConnection then flyInputConnection:Disconnect() end
    if flyInputEndConnection then flyInputEndConnection:Disconnect() end
    flyInputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.Space then flyKeys.Up = true end
        if input.KeyCode == Enum.KeyCode.LeftControl then flyKeys.Down = true end
    end)
    flyInputEndConnection = UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Space then flyKeys.Up = false end
        if input.KeyCode == Enum.KeyCode.LeftControl then flyKeys.Down = false end
    end)
end
local function stopFly()
    flying = false
    flyKeys.Up, flyKeys.Down = false, false
    if flyInputConnection then flyInputConnection:Disconnect(); flyInputConnection = nil end
    if flyInputEndConnection then flyInputEndConnection:Disconnect(); flyInputEndConnection = nil end
    if bg then bg:Destroy(); bg = nil end
    if bv then bv:Destroy(); bv = nil end
    local c = LocalPlayer.Character
    if c then
        local humanoid = c:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
    end
end
CharSection:CreateToggle({ Name = "Fly Mode", Default = false, Callback = function(V) MiscFlags.FlyMode = V if V then startFly() else stopFly() end end })
CharSection:CreateTextbox({ Name = "Fly Speed", Placeholder = "50", Default = "50", Callback = function(V) flySpeed = tonumber(V) or 50 end })
CharSection:CreateToggle({ Name = "Noclip", Default = false, Callback = function(V) MiscFlags.Noclip = V end })
CharSection:CreateToggle({ Name = "Infinite Jump", Default = false, Callback = function(V) MiscFlags.InfiniteJump = V end })

local waterY = nil
local waterPart = nil
local waterPartsList = {}
local waterWalkConnection = nil
local waterWalkEnabled = false

local function findWaterParts()
    local parts = {}
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            local name = v.Name:lower()
            if name:match("water") or name:match("ocean") or v.Material == Enum.Material.Water then
                table.insert(parts, v)
            end
        end
    end
    return parts
end

local function enableWaterWalk()
    if waterWalkEnabled then return end
    waterWalkEnabled = true

    waterPartsList = findWaterParts()
    for _, part in ipairs(waterPartsList) do
        part.CanCollide = true
    end

    waterPart = Instance.new("Part")
    waterPart.Size = Vector3.new(16, 1, 16)
    waterPart.Transparency = 1
    waterPart.Anchored = true
    waterPart.CanCollide = true
    waterPart.Name = "WaterWalkPart"
    waterPart.Parent = Workspace

    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        waterY = char.HumanoidRootPart.Position.Y - 3.2
    else
        waterY = 0
    end

    if waterWalkConnection then waterWalkConnection:Disconnect() end
    waterWalkConnection = RunService.RenderStepped:Connect(function()
        if not waterWalkEnabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        if waterPart then
            waterPart.Position = Vector3.new(root.Position.X, waterY, root.Position.Z)
        end
    end)
end

local function disableWaterWalk()
    if not waterWalkEnabled then return end
    waterWalkEnabled = false

    if waterWalkConnection then
        waterWalkConnection:Disconnect()
        waterWalkConnection = nil
    end

    if waterPart then
        waterPart:Destroy()
        waterPart = nil
    end

    for _, part in ipairs(waterPartsList) do
        if part and part.Parent then
            part.CanCollide = false
        end
    end
    waterPartsList = {}
end

CharSection:CreateToggle({
    Name = "Walk On Water",
    Default = false,
    Callback = function(V)
        MiscFlags.WalkOnWater = V
        if V then
            enableWaterWalk()
        else
            disableWaterWalk()
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

local function GetPlayerData()
    if not Data then return nil end
    return Data:FindFirstChild(tostring(LocalPlayer.UserId))
end

local function GetInventoryLimit()
    local userFolder = GetPlayerData()
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
    local userFolder = GetPlayerData()
    if not userFolder then return false end

    local limit = 0
    pcall(function()
        limit = userFolder.InventoryLimit.Value
    end)
    return GetInventoryLimit() >= limit
end

local GuiService = game:GetService("GuiService")
local nexusPanel = LocalPlayer.PlayerGui:FindFirstChild("NexusPanel")

local function DisableNexusKeyboardActivation(object)
    if object:IsA("GuiObject") then
        object.Selectable = false
    end
end

if runtimeEnv.NexusSpaceGuardConnection then
    runtimeEnv.NexusSpaceGuardConnection:Disconnect()
    runtimeEnv.NexusSpaceGuardConnection = nil
end
if runtimeEnv.NexusSelectableGuardConnection then
    runtimeEnv.NexusSelectableGuardConnection:Disconnect()
    runtimeEnv.NexusSelectableGuardConnection = nil
end

if nexusPanel then
    DisableNexusKeyboardActivation(nexusPanel)
    for _, object in ipairs(nexusPanel:GetDescendants()) do
        DisableNexusKeyboardActivation(object)
    end
    runtimeEnv.NexusSelectableGuardConnection = nexusPanel.DescendantAdded:Connect(function(object)
        task.defer(DisableNexusKeyboardActivation, object)
    end)
end

runtimeEnv.NexusSpaceGuardConnection = UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then
        local selected = GuiService.SelectedObject
        if selected and nexusPanel and selected:IsDescendantOf(nexusPanel) then
            GuiService.SelectedObject = nil
        end
    end
end)

local BossKeywords = { "boss", "raid", "giant", "king", "lord" }
local SecretBossKeywords = { "secret", "hidden", "mythic", "event", "rare" }
local BossNameSet, SecretBossNameSet = {}, {}

local function bossFarmEnabled()
    return Fishing.Flags.AutoFarmBoss or Fishing.Flags.AutoFarmSecretBoss
end

local function loadBossNameSets()
    table.clear(BossNameSet)
    table.clear(SecretBossNameSet)
    local infoFolder = ReplicatedStorage:FindFirstChild("Info")
    if not infoFolder then return end

    pcall(function()
        local areaRarity = infoFolder:FindFirstChild("FishingAreaRarity")
        if areaRarity then
            local rarityData = require(areaRarity)
            if type(rarityData) == "table" and type(rarityData["Secret Boss"]) == "table" then
                for fishName in pairs(rarityData["Secret Boss"]) do
                    local name = string.lower(tostring(fishName))
                    SecretBossNameSet[name] = true
                    BossNameSet[name] = true
                end
            end
        end
    end)

    pcall(function()
        local inventory = infoFolder:FindFirstChild("Inventory")
        if inventory then
            for _, module in pairs(inventory:GetChildren()) do
                if module:IsA("ModuleScript") then
                    local ok, itemData = pcall(require, module)
                    if ok and type(itemData) == "table" then
                        local name = string.lower(tostring(itemData.FishName or module.Name))
                        if itemData.Boss == true or itemData.SpecialBoss == true or itemData.SecretBoss == true then
                            BossNameSet[name] = true
                        end
                        if itemData.SecretBoss == true then
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
    while task.wait(30) do loadBossNameSets() end
end)

local function textHasKeyword(text, keywords)
    text = string.lower(tostring(text or ""))
    for _, keyword in ipairs(keywords) do
        if string.find(text, keyword, 1, true) then return true end
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
    local fishInstance = fishId and fishes and fishes:FindFirstChild(tostring(fishId))
    if fishInstance then
        info.Instance = fishInstance
        info.Name = info.Name or fishInstance:GetAttribute("FishName") or fishInstance.Name
        info.Boss = info.Boss or fishInstance:GetAttribute("Boss") == true or fishInstance:GetAttribute("SpecialBoss") == true or fishInstance:GetAttribute("SecretBoss") == true
        info.SecretBoss = info.SecretBoss or fishInstance:GetAttribute("SecretBoss") == true
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
    local current = target or getCurrentHookTarget()
    local name = string.lower(tostring(current.Name or ""))
    return current.SecretBoss or SecretBossNameSet[name] or textHasKeyword(name, SecretBossKeywords)
end

local function isBossTarget(target)
    local current = target or getCurrentHookTarget()
    local name = string.lower(tostring(current.Name or ""))
    if isSecretBossTarget(current) then return true end
    return current.Boss or BossNameSet[name] or textHasKeyword(name, BossKeywords)
end

local function shouldFarmBossTarget(target)
    local current = target or getCurrentHookTarget()
    if isSecretBossTarget(current) then return true, "Secret Boss" end
    if Fishing.Flags.AutoFarmSecretBoss and not Fishing.Flags.AutoFarmBoss then return false, "Normal" end
    if Fishing.Flags.AutoFarmBoss and isBossTarget(current) then return true, "Boss" end
    return false, "Normal"
end

local function resetBossFarmTarget()
    Fishing.BossFarm.CurrentTarget = nil
    Fishing.BossFarm.CurrentType = nil
    Fishing.BossFarm.CurrentToken = nil
    Fishing.BossFarm.HasHooked = false
    Fishing.BossFarm.PendingCancel = false
end

local function castRod()
    if not bossFarmEnabled() or tick() - Fishing.BossFarm.LastCast < 0.35 then return false end
    local character = LocalPlayer.Character
    if not character then return false end
    if character:GetAttribute("Fishing") and not character:GetAttribute("Retractable") then return false end

    Fishing.BossFarm.LastCast = tick()
    resetBossFarmTarget()
    pcall(function()
        local root = character:FindFirstChild("HumanoidRootPart")
        if root then Events.Fishing:FireServer(root.CFrame) end
    end)
    return true
end

local function cancelOrReleaseNormalFish()
    if not bossFarmEnabled() then return false end
    local character = LocalPlayer.Character
    if not character then return false end
    if not character:GetAttribute("Fishing") then resetBossFarmTarget(); return true end

    Fishing.BossFarm.PendingCancel = true
    pcall(function()
        local fishingGui = MainGui:FindFirstChild("Fishing")
        local barFrame = fishingGui and fishingGui:FindFirstChild("BarFrame")
        local bar = barFrame and barFrame:FindFirstChild("Bar")
        if bar then bar.Position = UDim2.new(-0.15, 0, bar.Position.Y.Scale, bar.Position.Y.Offset) end
    end)

    if Fishing.BossFarm.CurrentToken and tick() - Fishing.BossFarm.LastFastCancel > 0.5 then
        Fishing.BossFarm.LastFastCancel = tick()
        pcall(function() Events.FishingMinigame:FireServer(false, Fishing.BossFarm.CurrentToken) end)
    end
    if not character:GetAttribute("Retractable") then return false end
    if tick() - Fishing.BossFarm.LastCancel < 0.35 then return false end

    Fishing.BossFarm.LastCancel = tick()
    pcall(function()
        local root = character:FindFirstChild("HumanoidRootPart")
        if root then Events.Fishing:FireServer(root.CFrame) end
    end)
    return false
end

local function farmHookedBoss(target)
    if not bossFarmEnabled() then return end
    local shouldFarm, targetType = shouldFarmBossTarget(target)
    if not shouldFarm then return end

    Fishing.BossFarm.CurrentType = targetType
    local notifyKey = targetType .. tostring(target.Name)
    if Fishing.BossFarm.LastNotify ~= notifyKey then
        Fishing.BossFarm.LastNotify = notifyKey
        NexusLib:Notify({ Title = "Boss Farm", Message = "Farming " .. targetType .. ": " .. tostring(target.Name or "Unknown"), Duration = 3 })
    end
    if tick() - Fishing.BossFarm.LastProgress > 0.04 then
        Fishing.BossFarm.LastProgress = tick()
        pcall(function() Events.UpdateFishProgression:FireServer() end)
    end
end

task.spawn(function()
    while task.wait(0.5) do
        if Fishing.Flags.MainFarm then
            if Fishing.Flags.AutoCast then
                local c = LocalPlayer.Character
                if c then
                    if not c:GetAttribute("Fishing") then
                        pcall(function() Events.Fishing:FireServer() end)
                    end
                end
            end
            if Fishing.Flags.AutoSkill and MainGui:FindFirstChild("Fishing") and MainGui.Fishing.Visible then
                pcall(function()
                    local char = LocalPlayer.Character
                    local skillsFolder = char and char:FindFirstChild("Skills")
                    if skillsFolder then
                        local selectedSkills = Fishing.Flags.SelectedSkills
                        local readySkills = {}
                        for _, skill in ipairs(skillsFolder:GetChildren()) do
                            if skill:IsA("NumberValue") and skill.Value <= 0 then
                                local key = skill:GetAttribute("Key")
                                if key then readySkills[key] = true end
                            end
                        end
                        for _, key in ipairs(selectedSkills) do
                            if readySkills[key] then
                                Events.UseSkill:FireServer(key)
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
                if Fishing.BossFarm.PendingCancel then
                    cancelOrReleaseNormalFish()
                elseif Fishing.BossFarm.HasHooked and fishingGui and fishingGui.Visible then
                    local target = getCurrentHookTarget()
                    local shouldFarm = shouldFarmBossTarget(target)
                    if shouldFarm then
                        Fishing.BossFarm.PendingCancel = false
                        farmHookedBoss(target)
                    elseif target.Name and target.Name ~= "???" then
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

Events.FishingMinigame.OnClientEvent:Connect(function(p1, p2, p3)
    if not p1 or not p2 then return end

    Fishing.BossFarm.CurrentTarget = p1
    Fishing.BossFarm.CurrentToken = p3
    Fishing.BossFarm.HasHooked = true
    Fishing.BossFarm.PendingCancel = false
    Fishing.BossFarm.CurrentRunId = Fishing.BossFarm.CurrentRunId + 1
    local runId = Fishing.BossFarm.CurrentRunId
    local target = getCurrentHookTarget()
    local shouldFarm = shouldFarmBossTarget(target)

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
                    shouldFarm = shouldFarmBossTarget(target)
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
        if h then
            local cameraLook = Camera.CFrame.LookVector
            local cameraRight = Camera.CFrame.RightVector
            local move = LocalPlayer.Character.Humanoid.MoveDirection
            local horizontal = Vector3.new(move.X, 0, move.Z)
            local vertical = (flyKeys.Up and 1 or 0) - (flyKeys.Down and 1 or 0)
            bv.Velocity = horizontal * flySpeed + Vector3.new(0, vertical * flySpeed, 0)
            local look = Vector3.new(cameraLook.X, 0, cameraLook.Z)
            if look.Magnitude > 0.01 then bg.CFrame = CFrame.lookAt(h.Position, h.Position + look.Unit) end
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
                    
                    local lastInput = UserInputService:GetLastInputType()
                    local latency = (lastInput == Enum.UserInputType.Touch) and 0.06 or 0.025
                    local compensatedBarPos = barPos - (currentSpeed * latency)
                    
                    local halfWidth = hbSize / 2
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
end)

UserInputService.JumpRequest:Connect(function()
    if MiscFlags.InfiniteJump and LocalPlayer.Character then
        local h = LocalPlayer.Character:FindFirstChildOfClass('Humanoid')
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

if getgenv().AntiAFKConnection then getgenv().AntiAFKConnection:Disconnect() end

local VirtualUser = game:GetService("VirtualUser")
getgenv().AntiAFKConnection = LocalPlayer.Idled:Connect(function()
    if Fishing.Flags.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

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

task.spawn(function()
-- ==========================================
-- TACH RIENG WEBHOOK SCANNER (MAOSHAN, TAOIST, WEATHER)
-- ==========================================

local MAOSHAN_WEBHOOK = "https://discord.com/api/webhooks/1536228349712531536/dCA_BJmBBmTw1RJCIPwNptZ3uVRyPLcW9rbylMm4ODMKU_NmU92mJpnqLK12DssjLXql"
local TAOIST_WEBHOOK = "https://discord.com/api/webhooks/1536240143600717935/_fSUXRnG3dENc1b8_b9YASIEbg8XzkO7P0q8TZX1kMcBf6YfsFhAkYoNB1pDFFpjIK6n"
local WEATHER_WEBHOOK = "https://discord.com/api/webhooks/1536240273040998461/EvM4E_BUCyOyQtLuv-YFMpEEa_GsUUYd2618qlv0vBF4r5no0BzGowZ8EH436gclLdYG"

local SCAN_INTERVAL = 5 -- Thoi gian giua moi lan quet (giay)

-- Bat/tat tinh nang quet
local ScanMaoshan = true
local ScanTaoist = true
local ScanWeather = true

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")

local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
local function b64encode(data)
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b64chars:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

local function sendDiscordWebhook(url, eventName)
    local httpRequest = (typeof(request) == "function" and request) or (typeof(http_request) == "function" and http_request) or (syn and typeof(syn.request) == "function" and syn.request) or (http and typeof(http.request) == "function" and http.request)
    if not httpRequest or url == "" then return end
    
    local jobId = game.JobId
    local encodedJobId = b64encode(jobId)
    local playerStr = #Players:GetPlayers() .. "/" .. Players.MaxPlayers
    local timeStr = os.date("%Y-%m-%d %H:%M:%S")

    local payload = HttpService:JSONEncode({
        username = "Spyder Scanner",
        embeds = {{
            author = { name = "Nexus Hub - Event Scanner" },
            color = 0xFF6B35,
            fields = {
                { name = "Player Count", value = "```\n" .. playerStr .. "\n```", inline = true },
                { name = "Event", value = "```\n" .. eventName .. " Found!\n```", inline = true },
                { name = "Job ID", value = "```\nNEXUSHUB|" .. encodedJobId .. "\n```", inline = false },
                { name = "Time", value = timeStr, inline = false },
            },
            footer = { text = "Event Scanner" },
        }}
    })

    pcall(httpRequest, {
        Url = url,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = payload,
    })
end

local function sendWeatherWebhook(url, weatherName)
    local httpRequest = (typeof(request) == "function" and request) or (typeof(http_request) == "function" and http_request) or (syn and typeof(syn.request) == "function" and syn.request) or (http and typeof(http.request) == "function" and http.request)
    if not httpRequest or url == "" then return end
    
    local jobId = game.JobId
    local encodedJobId = b64encode(jobId)
    local playerStr = #Players:GetPlayers() .. "/" .. Players.MaxPlayers
    local timeStr = os.date("%Y-%m-%d %H:%M:%S")

    -- Mau embed theo loai thoi tiet
    local colors = {
        ["Rainy"] = 0x2A75BB,
        ["Thunderstorm"] = 0x800080,
        ["Foggy"] = 0x808080,
        ["Windy"] = 0x87CEEB,
        ["Snowy"] = 0xFFFAFA,
        ["Blazing Sun"] = 0xFF4500
    }
    local embedColor = colors[weatherName] or 0x00A2FF

    local payload = HttpService:JSONEncode({
        username = "Nexus Weather System",
        embeds = {{
            author = { name = "Nexus Hub - Weather Alert" },
            title = "New weather spotted: " .. weatherName .. "!",
            color = embedColor,
            fields = {
                { name = "Weather", value = "```\n" .. weatherName .. "\n```", inline = true },
                { name = "Player Count", value = "```\n" .. playerStr .. "\n```", inline = true },
                { name = "Job ID", value = "```\nNEXUSHUB|" .. encodedJobId .. "\n```", inline = false },
                { name = "Time", value = timeStr, inline = false },
            },
            footer = { text = "Event Scanner" },
        }}
    })

    pcall(httpRequest, {
        Url = url,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = payload,
    })
end

-- Bien luu trang thai de khong bi spam tin nhan
local MaoshanSent = false
local TaoistSent = false
local LastWeather = nil

local weathersList = {"Rainy", "Thunderstorm", "Foggy", "Windy", "Snowy", "Blazing Sun"}

local function getCurrentWeatherUI()
    local LocalPlayer = Players.LocalPlayer
    if not LocalPlayer then return nil end
    local MainGui = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("MainGui")
    if MainGui then
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
    end
    return nil
end

task.spawn(function()
    while task.wait(SCAN_INTERVAL) do
        -- 1. Quet Maoshan
        if ScanMaoshan then
            local foundMaoshan = false
            pcall(function()
                if workspace:FindFirstChild("NPC") then
                    for _, c in pairs(workspace.NPC:GetChildren()) do
                        if c.Name == "Maoshan" or c.Name == "Maoshan NPC" then foundMaoshan = true break end
                    end
                end
                if not foundMaoshan and workspace:FindFirstChild("Merchant") then
                    for _, c in pairs(workspace.Merchant:GetChildren()) do
                        if c.Name == "Maoshan" or c.Name == "Maoshan NPC" then foundMaoshan = true break end
                    end
                end
                if not foundMaoshan then
                    for _, c in pairs(workspace:GetChildren()) do
                        if c.Name == "Maoshan" or c.Name == "Maoshan NPC" then foundMaoshan = true break end
                    end
                end
            end)
            if foundMaoshan and not MaoshanSent then
                MaoshanSent = true
                sendDiscordWebhook(MAOSHAN_WEBHOOK, "Maoshan NPC")
            elseif not foundMaoshan and MaoshanSent then
                MaoshanSent = false
            end
        end

        -- 2. Quet Taoist
        if ScanTaoist then
            local foundTaoist = false
            pcall(function()
                if workspace:FindFirstChild("NPC") then
                    for _, c in pairs(workspace.NPC:GetChildren()) do
                        if c.Name == "Taoist" or c.Name == "Taoist NPC" then foundTaoist = true break end
                    end
                end
                if not foundTaoist and workspace:FindFirstChild("Merchant") then
                    for _, c in pairs(workspace.Merchant:GetChildren()) do
                        if c.Name == "Taoist" or c.Name == "Taoist NPC" then foundTaoist = true break end
                    end
                end
                if not foundTaoist then
                    for _, c in pairs(workspace:GetChildren()) do
                        if c.Name == "Taoist" or c.Name == "Taoist NPC" then foundTaoist = true break end
                    end
                end
            end)
            if foundTaoist and not TaoistSent then
                TaoistSent = true
                sendDiscordWebhook(TAOIST_WEBHOOK, "Taoist NPC")
            elseif not foundTaoist and TaoistSent then
                TaoistSent = false
            end
        end

        -- 3. Quet Weather
        if ScanWeather then
            local currentActiveWeather = nil
            pcall(function()
                -- The check qua UI truoc (chuan nhat)
                local uiWeather = getCurrentWeatherUI()
                if uiWeather and uiWeather ~= "Clear" and uiWeather ~= "" then
                    currentActiveWeather = uiWeather
                else
                    -- Fallback neu UI chua load
                    for _, w in ipairs(weathersList) do
                        if workspace:FindFirstChild(w) or Lighting:FindFirstChild(w) then
                            currentActiveWeather = w
                            break
                        end
                    end
                end
            end)

            if currentActiveWeather and currentActiveWeather ~= LastWeather and currentActiveWeather:lower() ~= "clear" then
                LastWeather = currentActiveWeather
                sendWeatherWebhook(WEATHER_WEBHOOK, currentActiveWeather)
            elseif not currentActiveWeather and LastWeather then
                LastWeather = nil
            end
        end
    end
end)
end)
