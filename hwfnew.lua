-- Nexus Guard V3 - Hub Loader (whitelist + V3 cipher + server URLs)
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local runtime = (getgenv and getgenv()) or _G

-- ============================================================
-- ===== ANTI-HOOK / ANTI-DUMP & V3 DYNAMIC STRINGS =====
-- V3 cipher: xorshift32 stream + position salt + checksum.
-- Old V2 decoders cannot read V3 blobs.
-- ============================================================
local _raw_loadstring = loadstring
local _raw_HttpGet = game.HttpGet
local _raw_HttpPost = HttpService.PostAsync
local _raw_JSONEncode = HttpService.JSONEncode
local _raw_JSONDecode = HttpService.JSONDecode
local _raw_getinfo = debug and debug.getinfo
local _raw_request = (syn and syn.request) or http_request or request or (fluxus and fluxus.request)

local _TAMPER_FLAG = 1

local function isFunctionHooked(fn)
    if type(fn) ~= "function" then return true end
    if iscclosure and not iscclosure(fn) then return true end
    if ishooked and ishooked(fn) then return true end
    if _raw_getinfo then
        local ok, info = pcall(_raw_getinfo, fn)
        if not ok or type(info) ~= "table" then return true end
        if info.what ~= "C" or (info.source and info.source ~= "=[C]") then return true end
    end
    return false
end

local function corruptExecution()
    _TAMPER_FLAG = 0xDEADBEEF
    task.spawn(function()
        task.wait(math.random(1, 2))
        local function crash() return crash() + 1 end
        pcall(crash)
        LocalPlayer:Kick("Nexus Security: Tamper detected.")
    end)
end

local function verifyIntegrity()
    if isFunctionHooked(_raw_loadstring) or (loadstring and isFunctionHooked(loadstring)) then
        corruptExecution()
        return false
    end
    if _raw_getinfo and isFunctionHooked(_raw_getinfo) then
        corruptExecution()
        return false
    end
    return true
end
verifyIntegrity()

-- V3 string resolver (mirrors nexus_guard_build.py enc_v3).
local function resolveStringV3(payload)
    local seed = payload.seed
    if _TAMPER_FLAG ~= 1 then seed = (seed + 9999) % 65536 end
    local bytes = payload.bytes
    local state = bit32.bxor(seed, 0x9E3779B9)
    local chars = {}
    local sum = 0
    for i = 1, #bytes do
        local i0 = i - 1
        state = bit32.bxor(state, bit32.lshift(state, 13))
        state = bit32.bxor(state, bit32.rshift(state, 17))
        state = bit32.bxor(state, bit32.lshift(state, 5))
        local shift = 8 * (i0 % 4)
        local keyByte = (bit32.band(bit32.rshift(state, shift), 0xFF) + i0 * 31 + seed) % 256
        local plain = bit32.bxor(bytes[i], keyByte)
        sum = sum + plain
        chars[i] = string.char(plain)
    end
    local check = (sum * 33 + #bytes * 7 + payload.seed) % 65536
    local s = table.concat(chars)
    table.clear(chars)
    if check ~= payload.check then return nil end
    return s
end

-- Only the guard endpoint + get-key link live here. Script and lib URLs
-- are returned by the server after validation, never stored in this file.
local ENC_GUARD_URL = { seed = 42421, check = 59415, bytes = {132, 199, 220, 204, 60, 224, 186, 102, 43, 197, 96, 77, 49, 247, 217, 188, 145, 50, 51, 169, 50, 246, 249, 228, 83, 248, 38, 112, 222, 18, 125, 128, 120, 209, 10, 162, 111, 9, 255, 112, 107, 14, 52, 111, 237, 153, 65, 230, 128, 67, 138, 236, 164, 135, 230, 31, 41, 157, 117, 224, 227, 145, 218, 131, 123} }
local ENC_GET_KEY_URL = { seed = 18707, check = 54639, bytes = {134, 144, 191, 38, 186, 253, 212, 214, 135, 53, 97, 237, 240, 190, 11, 235, 128, 98, 160, 74, 194, 111, 69, 160, 151, 45, 127, 91, 94, 108, 181, 56} }

local CONFIG = {
    PROTOCOL_VERSION = 3,
    BUNDLE = "hub",
    PRODUCT_LABEL = "Product: Hub",
    GUARD_URL = resolveStringV3(ENC_GUARD_URL),
    FALLBACK_URL = "https://vgvaxescpirfdkrcamyk.supabase.co/functions/v1/key-system",
    DEFAULT_LIB = "https://raw.githubusercontent.com/Ngmankhoi/my-hub/main/NexusLib.lua",
    DEFAULT_PREMIUM = "https://raw.githubusercontent.com/Ngmankhoi/my-hub/refs/heads/main/Nexus_obfuscated.lua",
    DEFAULT_FREEMIUM = "https://raw.githubusercontent.com/Ngmankhoi/my-hub/refs/heads/main/nexus_hub_freemium_obfuscated.lua",
    GET_KEY_URL = resolveStringV3(ENC_GET_KEY_URL),
    REQUEST_TIMEOUT = 20,
    KEY_FILES = { "NexusPremiumKey.txt", "NexusFreemiumKey.txt" },
}

local MESSAGES = {
    INVALID_KEY = "Key does not exist or is wrong.",
    KEY_DISABLED = "Key has been disabled.",
    KEY_EXPIRED = "Key has expired.",
    HWID_MISMATCH = "Key is bound to another device. Reset HWID first.",
    HWID_REQUIRED = "Device ID missing. Rejoin and try again.",
    EXECUTOR_BLOCKED = "Executor not supported. Use a whitelisted executor.",
    LOCKED_OUT = "Too many failed attempts. Try again in 15 minutes.",
    RATE_LIMITED = "Too many requests. Wait a moment and retry.",
    NETWORK_ERROR = "Cannot reach auth server. Check network and retry.",
    SERVER_NOT_CONFIGURED = "Server is not configured. Contact the owner.",
}

local function getRawHwid()
    local base = nil
    if type(gethwid) == "function" then pcall(function() base = gethwid() end) end
    if type(base) ~= "string" or #base < 4 then
        pcall(function() base = game:GetService("RbxAnalyticsService"):GetClientId() end)
    end
    if type(base) ~= "string" or #base < 4 then
        base = "player:" .. tostring(LocalPlayer.UserId) .. ":place:" .. tostring(game.PlaceId)
    end
    return tostring(base) .. ":" .. tostring(LocalPlayer.UserId)
end

local function getExecutorName()
    local name = "unknown"
    pcall(function()
        if type(identifyexecutor) == "function" then
            local ok, v = pcall(identifyexecutor)
            if ok and type(v) == "string" and #v > 0 then name = v end
        elseif type(getexecutorname) == "function" then
            local ok, v = pcall(getexecutorname)
            if ok and type(v) == "string" and #v > 0 then name = v end
        end
    end)
    return name
end

local function makeClientNonce()
    local parts = {}
    for i = 1, 16 do parts[i] = string.format("%x", math.random(0, 15)) end
    return table.concat(parts)
end

local function requestAdapter()
    return _raw_request or (syn and syn.request) or http_request or request or (fluxus and fluxus.request)
end

local function loaderNotify(msg)
    pcall(function() print("[Nexus Guard V3] " .. tostring(msg)) end)
end

local function copyToClipboard(value)
    local text = tostring(value or "")
    local candidates = {
        setclipboard,
        runtime and runtime.setclipboard,
        toclipboard,
        runtime and runtime.toclipboard,
        writeclipboard,
        syn and syn.write_clipboard,
        Clipboard and Clipboard.set,
        clipboard and clipboard.set,
    }
    for _, fn in ipairs(candidates) do
        if type(fn) == "function" then
            local ok = pcall(fn, text)
            if ok then return true end
        end
    end
    return false
end

loaderNotify("Guard V3 started...")

local function httpGetFull(url)
    local reqFn = requestAdapter()
    if reqFn then
        local ok, r = pcall(reqFn, { Url = url, Method = "GET" })
        if ok and r then
            local body = r.Body or r.body
            if body and #body > 0 then return body end
        end
    end
    return game:HttpGet(url)
end

local function safeValidate(key, hwid)
    local payload = {
        action = "validate",
        key = key,
        hwid = hwid,
        executor = getExecutorName(),
        client_nonce = makeClientNonce(),
        bundle = CONFIG.BUNDLE,
        protocol_version = CONFIG.PROTOCOL_VERSION,
    }

    local function postJson(targetUrl)
        local ok, result = pcall(function()
            local requestFn = requestAdapter()
            local encoded = HttpService:JSONEncode(payload)
            if requestFn then
                local raw = requestFn({
                    Url = targetUrl,
                    Method = "POST",
                    Headers = { ["Content-Type"] = "application/json" },
                    Body = encoded,
                    Timeout = CONFIG.REQUEST_TIMEOUT,
                })
                return HttpService:JSONDecode(raw.Body or raw.body or "{}")
            end
            return HttpService:JSONDecode(HttpService:PostAsync(targetUrl, encoded, Enum.HttpContentType.ApplicationJson, false))
        end)
        if ok and type(result) == "table" then return result end
        return nil
    end

    local result = postJson(CONFIG.GUARD_URL)
    if not result or result.ok ~= true or result.code == "INTERNAL_ERROR" or result.code == "SERVER_NOT_CONFIGURED" then
        if not result or result.code == "INTERNAL_ERROR" or result.code == "SERVER_NOT_CONFIGURED" or result.code == "NETWORK_ERROR" then
            local fallback = postJson(CONFIG.FALLBACK_URL)
            if fallback and type(fallback) == "table" then
                result = fallback
            end
        end
    end

    if not result or type(result) ~= "table" then
        return { ok = false, code = "NETWORK_ERROR" }
    end

    if result.ok then
        local t = string.upper(tostring(result.tier or "FREEMIUM"))
        if not result.server_nonce then
            result.server_nonce = result.launch_token or result.device_token or ("NXSNONCE_" .. tostring(os.time()))
        end
        if not result.lib_url or #result.lib_url < 8 then
            result.lib_url = CONFIG.DEFAULT_LIB
        end
        if not result.script_url or #result.script_url < 8 or result.script_url:find("9264428959880330") then
            result.script_url = (t == "PREMIUM") and CONFIG.DEFAULT_PREMIUM or CONFIG.DEFAULT_FREEMIUM
        end
    end

    return result
end

local function executeMainScript(record)
    if runtime.NexusMainLoaded then return true end
    if not verifyIntegrity() then return false end
    loaderNotify("Downloading script...")
    local tier = string.upper(tostring(record.tier or runtime.NexusVerifiedTier or "FREEMIUM"))
    local defaultScript = (tier == "PREMIUM") and CONFIG.DEFAULT_PREMIUM or CONFIG.DEFAULT_FREEMIUM
    local defaultLib = CONFIG.DEFAULT_LIB

    local libUrl = record.lib_url
    if type(libUrl) ~= "string" or #libUrl < 8 then libUrl = defaultLib end
    local scriptUrl = record.script_url
    if type(scriptUrl) ~= "string" or #scriptUrl < 8 or scriptUrl:find("9264428959880330") then
        scriptUrl = defaultScript
    end
    if runtime.NexusLib == nil then
        local okLib, libErr = pcall(function()
            local libSrc = httpGetFull(libUrl)
            if type(libSrc) ~= "string" or #libSrc < 100 then error("lib download failed") end
            local compileLib = _raw_loadstring or loadstring
            if isFunctionHooked(compileLib) then error("loadstring hook detected") end
            local libFn, err = compileLib(libSrc, "@NexusLib.lua")
            if not libFn then error(err) end
            local value = libFn()
            if value ~= nil then runtime.NexusLib = value end
        end)
        if not okLib then loaderNotify("Warning: NexusLib failed: " .. tostring(libErr)) end
    end
    local src = httpGetFull(scriptUrl)
    if type(src) ~= "string" or #src < 100 then
        loaderNotify("ERROR: script download failed or empty.")
        return false
    end
    local compileFn = _raw_loadstring or loadstring
    if isFunctionHooked(compileFn) then
        LocalPlayer:Kick("Nexus Security: loadstring hook detected.")
        return false
    end
    local main, err = compileFn(src, "@nexus_main.lua")
    src = nil
    if not main then
        loaderNotify("ERROR compile: " .. tostring(err))
        return false
    end
    runtime.NexusMainLoaded = true
    loaderNotify("Running script...")
    task.spawn(function()
        local ok, ret = pcall(main)
        if ok and type(ret) == "function" then
            local ok2, err2 = pcall(ret)
            if not ok2 then loaderNotify("ERROR main(): " .. tostring(err2)) end
        elseif not ok then
            loaderNotify("ERROR script: " .. tostring(ret))
        end
    end)
    return true
end

local function clearCachedKey()
    runtime.Key = nil
    runtime.NexusVerifiedTier = nil
    runtime.NexusPremiumVerified = nil
    runtime.NexusFreemiumVerified = nil
    runtime.NexusGuardNonce = nil
    pcall(function()
        if not (delfile and isfile) then return end
        local dead = {
            "NexusPremiumKey.txt",
            "NexusFreemiumKey.txt",
            "NexusHub.txt",
            "NexusKey.txt",
            "nexus_key.json",
        }
        for _, fname in ipairs(dead) do
            if isfile(fname) then pcall(delfile, fname) end
        end
    end)
end

local function markVerified(key, tier, serverNonce)
    if key then runtime.Key = key end
    local t = string.upper(tostring(tier or "FREEMIUM"))
    if t ~= "PREMIUM" then t = "FREEMIUM" end
    runtime.NexusVerifiedTier = t
    runtime.NexusPremiumVerified = nil
    runtime.NexusFreemiumVerified = nil
    runtime.NexusMainLoaded = nil
    runtime.NexusGuardNonce = serverNonce
    if t == "PREMIUM" then
        runtime.NexusPremiumVerified = true
    else
        runtime.NexusFreemiumVerified = true
    end
    if writefile and key then
        local targetFile = (t == "PREMIUM") and CONFIG.KEY_FILES[1] or CONFIG.KEY_FILES[2]
        pcall(writefile, targetFile, key)
        local oldFile = (t == "PREMIUM") and CONFIG.KEY_FILES[2] or CONFIG.KEY_FILES[1]
        pcall(function()
            if delfile and isfile and isfile(oldFile) then delfile(oldFile) end
        end)
        pcall(function()
            if delfile and isfile then
                for _, f in ipairs({ "NexusHub.txt", "NexusKey.txt" }) do
                    if isfile(f) then delfile(f) end
                end
            end
        end)
    end
end

local function friendlyMessage(code)
    return MESSAGES[tostring(code or "")] or tostring(code or "Unknown error.")
end

local function showKeySystemUI(defaultKey)
    if not verifyIntegrity() then return end
    local home = nil
    pcall(function()
        if type(gethui) == "function" then home = gethui() end
    end)
    if home == nil then pcall(function() home = LocalPlayer:FindFirstChild("PlayerGui") end) end
    if home == nil then pcall(function() home = game:GetService("CoreGui") end) end
    if home == nil then
        LocalPlayer:Kick("Nexus Guard: no UI parent.")
        return
    end
    local gui = nil
    pcall(function()
        gui = Instance.new("ScreenGui")
        gui.Name = "NexusGuardV3"
        gui.ResetOnSpawn = false
        gui.Parent = home
    end)
    if gui == nil then
        LocalPlayer:Kick("Nexus Guard: UI build failed.")
        return
    end
    do
        local frame = Instance.new("Frame")
        frame.Size = UDim2.fromOffset(360, 320)
        frame.Position = UDim2.new(0.5, -180, 0.5, -160)
        frame.BackgroundColor3 = Color3.fromRGB(16, 18, 24)
        frame.BorderSizePixel = 0
        frame.Parent = gui
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 12)
        corner.Parent = frame
        local title = Instance.new("TextLabel")
        title.Text = "NEXUS KEY SYSTEM V3"
        title.Size = UDim2.new(1, 0, 0, 40)
        title.Position = UDim2.new(0, 0, 0, 8)
        title.BackgroundTransparency = 1
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 18
        title.Parent = frame
        local product = Instance.new("TextLabel")
        product.Text = CONFIG.PRODUCT_LABEL
        product.Size = UDim2.new(1, 0, 0, 20)
        product.Position = UDim2.new(0, 0, 0, 46)
        product.BackgroundTransparency = 1
        product.TextColor3 = Color3.fromRGB(140, 150, 170)
        product.Font = Enum.Font.Gotham
        product.TextSize = 13
        product.Parent = frame
        local box = Instance.new("TextBox")
        box.Text = tostring(defaultKey or "")
        box.PlaceholderText = "Paste your key..."
        box.Size = UDim2.new(1, -32, 0, 40)
        box.Position = UDim2.new(0, 16, 0, 74)
        box.BackgroundColor3 = Color3.fromRGB(28, 32, 42)
        box.TextColor3 = Color3.fromRGB(255, 255, 255)
        box.Font = Enum.Font.Gotham
        box.TextSize = 14
        box.ClearTextOnFocus = false
        box.Parent = frame
        local status = Instance.new("TextLabel")
        status.Text = "Paste key and press Submit."
        status.Size = UDim2.new(1, -32, 0, 40)
        status.Position = UDim2.new(0, 16, 0, 120)
        status.BackgroundTransparency = 1
        status.TextColor3 = Color3.fromRGB(160, 170, 190)
        status.Font = Enum.Font.Gotham
        status.TextSize = 13
        status.TextWrapped = true
        status.Parent = frame
        local function setStatus(msg)
            pcall(function() status.Text = tostring(msg) end)
        end
        local function onSubmit()
            local key = tostring(box.Text or ""):gsub("^%s+", ""):gsub("%s+$", "")
            if #key < 8 then
                setStatus("Please paste a valid key.")
                return
            end
            setStatus("Checking key...")
            task.spawn(function()
                local res = safeValidate(key, getRawHwid())
                if res.ok then
                    local tier = string.upper(tostring(res.tier or "FREEMIUM"))
                    if tier ~= "PREMIUM" then tier = "FREEMIUM" end
                    markVerified(key, tier, res.server_nonce)
                    setStatus("Key accepted (" .. tier .. "). Loading...")
                    task.wait(0.6)
                    pcall(function() gui:Destroy() end)
                    executeMainScript(res)
                else
                    setStatus("Failed: " .. friendlyMessage(res.code))
                    loaderNotify("Validate failed: " .. tostring(res.code))
                end
            end)
        end
        local submit = Instance.new("TextButton")
        submit.Text = "Submit Key"
        submit.Size = UDim2.new(1, -32, 0, 42)
        submit.Position = UDim2.new(0, 16, 0, 168)
        submit.BackgroundColor3 = Color3.fromRGB(60, 110, 220)
        submit.TextColor3 = Color3.fromRGB(255, 255, 255)
        submit.Font = Enum.Font.GothamBold
        submit.TextSize = 15
        submit.Parent = frame
        local getkey = Instance.new("TextButton")
        getkey.Text = "Get Key / Copy Link"
        getkey.Size = UDim2.new(1, -32, 0, 42)
        getkey.Position = UDim2.new(0, 16, 0, 218)
        getkey.BackgroundColor3 = Color3.fromRGB(40, 46, 60)
        getkey.TextColor3 = Color3.fromRGB(255, 255, 255)
        getkey.Font = Enum.Font.GothamBold
        getkey.TextSize = 15
        getkey.Parent = frame
        submit.MouseButton1Click:Connect(function() onSubmit() end)
        getkey.MouseButton1Click:Connect(function()
            if copyToClipboard(CONFIG.GET_KEY_URL) then
                setStatus("Get-key link copied to clipboard.")
            else
                setStatus("Copy this link: " .. tostring(CONFIG.GET_KEY_URL))
            end
        end)
    end
end

local rawKey = nil
if type(runtime.Key) == "string" and #runtime.Key >= 8 then
    rawKey = runtime.Key
else
    pcall(function()
        if not (isfile and readfile) then return end
        for _, fname in ipairs(CONFIG.KEY_FILES) do
            if isfile(fname) then
                local saved = readfile(fname)
                if saved and type(saved) == "string" and #saved >= 8 then
                    rawKey = saved
                    break
                end
            end
        end
    end)
end

if rawKey then
    rawKey = rawKey:gsub("^%s+", ""):gsub("%s+$", "")
    local result = safeValidate(rawKey, getRawHwid())
    if result.ok then
        local tier = string.upper(tostring(result.tier or "FREEMIUM"))
        if tier ~= "PREMIUM" then tier = "FREEMIUM" end
        markVerified(rawKey, tier, result.server_nonce)
        executeMainScript(result)
        return
    else
        local code = tostring(result.code or "")
        if code == "KEY_EXPIRED" or code == "INVALID_KEY" or code == "KEY_DISABLED" or code == "HWID_MISMATCH" then
            clearCachedKey()
            loaderNotify("Cached key rejected (" .. code .. "). Cache cleared.")
            rawKey = ""
        end
    end
end

showKeySystemUI(rawKey)
