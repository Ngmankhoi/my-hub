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
        Size = UDim2.fromOffset(5, 1.5),
        Rotation = 40,
        BackgroundColor3 = c,
        BorderSizePixel = 0,
        Parent = holder,
    }, { Corner(1) })
    local right = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 2, 0.5, 0),
        Size = UDim2.fromOffset(5, 1.5),
        Rotation = -40,
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
local LOGO_B64 = [=[iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAAUW0lEQVR42u1dCXdURRZuCFEPirhviIIb4q6jOO4LODquoyhGxQV1xAWVEWHcdXRw35WQAIKAM6yJSIgBEsjeCYGwJGEnG9k6QX7DndQ5X81ca6pev+5+3f365b1z6hC6X1Xd5atbt27dqg4E/Md//Md//Md//Md/AoEAET1KRKf4kvCcXi+z++IAIvqEiMYTUZovOk8ofzgRTYykwmAiykEZ6wMhpZV/LBGtIaJzI604gojWEVEFEa3q/fs6X5wpp/yhRFRMRAXRNvA0EZURUQkR1RHRVF+sKQWAeUS0i4hei7aBdCL6DFZAgKCWiMqJ6F5fvK5XvvDhthFRJxFdHWtjnzFLUNrrF9QT0c9ENNIXtSuVPwrKb4Le+sfa4GFEtBzKL0Gp6l0yNhLRHCK6yBe7a5Q/kog2EtEWjP4/OdnwNgaAEqBrNxG19v77kC9+V3j8DUS0ATqpd7qDSUBWCVYIRcw3aCOibCI6x1dFUpSfRkQLMT1vwuj/zulO+hHRFHQipoO8XvOfCxBU9joe+9DxbCI6zVdLQgHwJjz+9UwPo+PV2etEtJmBQCw31uL/An0t8A9eIaIjffXEXfl/IaL9mJIroPy6uAXwsDwUAYYglL6SiLIYCMrhgXbBb7jeV1Ncgz07MDUXEFE75D4j3h1fApNTAaUvAQjklCBAsBPECP9gOhEd46vMUR0MIaIaDLZSWIAulLGJIOABKFdagn8J5PWi8gdmDaowJ3XBd/ib8FZ99cUs+8OJaDVGvJD/L5h6hZybxfeJIuR+dFiJkb8MIJiJYFEpipgKOhgQHvU3mWKS+0zIsxorsnVs9Gclmph3iWgvU/YSgGAGlibr8XkNm6NEme9PC1HJ+y7Ir4HJu5HJ9b5kmKNieJ4yWvgjAwGfEirgO0hid2G1MNBXrS1Zj4TDtx9+ViEsrZSn+PyEZBB2GpTZAGekGMvDGYYpYRP8B0m48BVu9VVsKeOL4PF3wpoKyzoLn0k5fplMAm8AAndCyQIECxgIpDUoYNZgJ/MNupC8cIev7v+T7bEYNEJG2yG/xZAXH/1Dkk3oOBBTy0b7jwoIMokin31fo4BAlFd9tf9Orl8zJZfB6Zut+FQ5biF2OluelILYWRoQ5DIQVLNljGT0Ml/1/425tGOQVLHRX6gMmhfdQnAa8gn3M4KLNCBQp4QyLBclqoVlOKmPK38gnOouFn5fg423FgUAp7uJ8GMwZ3VAkaVArA4EmYgfSGtQiWWlnEpO6aPKPwQDSchhD5PPPM3oX+VGBm5ioeByNh1ka0AwA5HEUlZkKHlWHwXAE+C/k02nKyCrRgUAL7uViadg0vfAxJcihDnTAIIf8D1fLrbGbWvTvco/CtMhD/gUQm45ivJFudDNzEwCkTuZYgssQDAbS0j57kbUHdKHAPA9ZLaPDRy5pN6hKL/S7cz0x7JPzmVyOliF+V8HgsXKdLAL7x/aB5R/K2TVxJS/CnJZoxn9U1OBqWuJKISyHYyVARiZBsewkL1XCWa/97jyB2C+D8F5lvzPhQPdweQoy0WpwFh/hIJDzLuXzK00WIGF7J0ymD5Rf7xHlS9k9CV43MP4FqP/OZF4KwJkSnk5ZXZVcdysCQx2Kgj/2QCCpeydcqx9RTnPgwCYANm0I0wu91Rme2afhIhug/JDLEYgFbzcAIKVylTQBgEd7iHln84SZzaxuX8+ZJDhJaTPY/NXF8LAUsHLNACYxSKFMloo6r7pIZl8p/GP8pgMPvISAM5TnJlWZvLKsAJQQZCjTAX7Ue8mD8jjEshDBszk6P8BvIs9k3lem+/+oXiyzYz5MpZfyPMJ+KqgBvWE0K5JYTkMhLKlDCR/vzDe610Z6o2R8cOxucFBsFcZAT8pIJinTAW7UE9MSSemqNefy/jfp7GCmXJn1YvLnrvAXMgghBIcPjWtCiqZQ/lNCvJ/ksL7bo0F/El+59Wgx30wd1wQO5ggZGpZJisF7PtatqK4IcX4v1Lheyfjaz5LnJH89fciCMTR87uJ6D1m0lVvuEQBwRx2OrkMggthrjwjhXh/WAFAA+NpDnitZd8fncqKTjOdE8QaWKSSPY70sVYwXMcEsp4JJRNzJF8VtLFRdFaKOsJbGU9Z4HM/vhPBoMGpDACxvfl1mADROJTJ2O8OKSHjtVgNSBAUse+2MkEuSRGZLFAAsJlNe5lYBoYQD8gQy8VUBsCpiG+/qpvL8P04Vt5igaItCghmQUALNWFiKcz7UkAmZQoANuKzIpYllYdTVFNTOhzcy8z5MOmC0WmGd65TQFBp2Dxai6yiTGVVUIN3Q7AgZ7tYHunMvMsiI6IF4O01Jos5KX0LCxFdhatLJLP3G2IDYlXwIMpbSsh4I1P2ajZP8r2CLaxOiVvvJ+j1dYZptnUr2e7oq0wODyJS+lIqA+AWmGnBaDeiXido3huuMB7E+90sN64cJQ8AmM2mgXLEEmSdxW5cPiFfspuVEKM/U5HBQ3By30plANwL5hoZ0yt0GT44YSSZn4w1sKzTAUsihfUzHMNc9tkGBjRRnnOhPCYoAOgE7bNxxx8HwFS8MyaVAfA4GNyiMF6onhAmoiNw7FwKIEep0475kluCLLQlP9uuCPcKl8njY4WnNlzS/aCmiPl/daoHfJ6HYiqU0dkNBR6icRqlAJ5VrIAEQRVT+EoEi8pYP23s/Vo3HUXXgHq2Qfly/h+T6gB4kimnVWG+W01sRJj4XiaENZo6TQwAoizCqkD+f7Py/qcukgenbbWF8h/2xEaQuK8euW3l2PRQlblfNdPiinMmiLc1dbrh8FWi3RJsohQYHMJON8QHsARsZ3TNtwCAOGf5ghcAMAWZrTKjR6fMnTzDFeHjZ+A/qCsCXlogxHVQ+i/strIKjcX5c5JlMUKhxwoACzxxeQZGcCbmvmqDIqUluIrVOwwh0ckWVqAbzuWzWPaVI1gkrUCN8q7IOxiaRFncrdCzwKB8sVK4OOCFB15vJpZsxTDHJmXWc9SLEYsRPcXCCojyAQSXpfgG5VA6f/fHJMriRZsAuD3glQcXHGQyK9BsochuftEh5syfsCOYa1GnhAVOvlMAUK1ZfdyZJFl8YQMAIgx8rVeUn64kdGRjlHeHKVNYG5caHDu1fKiEkosMsQE5FVyUBHmsDAOAacKP8dLoP0oBgCi/2gBACFGw/oH/XYhscuxkacVP3UhhPoEcA1mvSXm/OdEna5HxZALAJEx3Y7wEgJM1AFhiAwCyDEM7p7BraHUm3SqoMh/1KjX+x+oEyuIYDb0SAB8g6pcf8NIjtmUV5c/GfN5hQ/nb+Nm3Xm//HmbS6wx1dsAPUDdUslFPN/1MSJAsxhgAMBmRTSGfp7wGgMuY8mciqqfzzHXlDU177zAQmGIKXxk862mYflo0sfiLEyCLdzS0rkepQazkaq8B4Cbm/PH1eb1d86+0d6wS7dtm0wrI8hhWIuoUsjHet2wafJ928FGFfZGhXgPAnRj5v8ARk0UIvMei1Fi0+YzSVqOm/gcWEbbxCEmrdcRITI+jLJo1fbYqvKR7DQAZyN8rVxitDgOAmRZtDsZokm1Vwafg9UssAPAgHNEuTb9vxEkOpxj4bAIP5Z5zAMH4C+xqWF72hAHAQzYsC2+vRqPQjywA8BqsUEipE4rHoVNMhTo+9wLAArBzvQiA9zTK34T5zwoAQ8O02w9OlWpVOhTz+rQBABkIymzX9L3L6fsJsVfRY+hrM8LcL3kRAJ9rANAcRvl1Nts+BGlhvO1apa05FlbgXRYbUGnIdlgOnxh43QGHWFiju7wIgJma0d8TpsyLoP17NADbpQj4YQMAHkJCRp2GBjEVPO2gHP5t4LUeDukWN6eyx8q4VEwltnzDAeCpCNrvh8MiKgiaWHtfWViBL/F+i4GWhx2SQ42h/a2wiJu9egA0nyllrw3l90R6vg/RRtXRDDIQ7MCtpToAPI33N2gcwh4oZ0SMMjjM0HYPpiwxKNYFvPiwHzSstan8fQ46m/JSqR6Y2X8aQCCXlHUGmlbGKIMRFvxuBACWe1H5RzJltNgEwKIo+xqO7d8KzfKQj75i3K/HAZCFiKKVg/pIDHK41YLfWjih33sRAGdCqNtsKr8nliRInC/UxRy2aBy8ZbiAUaZfdWJJWG0w1wLAN0ZJ14sW/ErZ/N2LALgKc3FnBAC4IMY+J2sAUIELGHSefh78gHy2Lm8w0NbBcxYjoOkbQ3udSIZ1zNl0GwBuNwRajPN/rJ4wElBKDCAwRR9bkFDKR2WH4d1gpDTiGJyurf3guSda6+KUosSW7R/j0O6ECEf/DIf6fd4AgEpleWgqISWWoJZXIqRnq8U+QCv+HpFMAFwKb/11J69cwyWI+REAYJRD/Q7Elq8OBEGbsYhOphy1dNm9n5CIBln0sZv5GwOTCYDhWKPnIgP3SgfbTkNuXmMYgW91mKdrDQCQewZ2LJPVfkWDLl/BMLhMbcgpqSHZc7XYXj2AE7a5KKMd7mMYlmAHDGVeHPj61AIEWy1osVtqw41cMbdb1G/Gv0XJBkAaS5WWAFiOrdyjHOwnHdagSSOMSXGKQ6zA3K8r0tuPBQSfhKHhPou6bfh3oRs89r0gppiBIBe7aRc63NfxOPLFhXFBnPi60QIAEgSxWoK7Lfr/q0W9EP790A0A2ABi9ioAkNbgAXFs2+E+R+JE7+54boQQ0WdhQLAnRgA0my6phGMdrv7EBOj3REtrjoTNAzCJqzQgyMUZvwERdHq43VEaZ+ZHhAFAJdb9sYBgiaHvT2KxIA7K4PNwLyxlBNVolC9CrCURdCjP97vi512QHmYFgFpmkqMtb2v6zbZRb1SceR8rLG24l7IYQe1wnnKRcSM95mk2OxQx9kfYZou4GLlfkgFwAnb9rEAg8wpjAcFEpd8cG3VOjCPf14CGb8O9+KFClDxnzz32s210OIktKach906Um5P9u3/wAYrDgGATtoWzYPXaIwSAiC/8gfVZGub9tjjyezVC3KvDDl5kyaqM8CXSdhsdTtQwuAzWIAP3/gxOMgim2vAHRBj4FdD8BLvE2i4Iitmh1vow726KE5/nsulbBL7G2THbVoQutTnyTQGTNyHQu5J5Yxd+qGGdjangZ2a9MnBn77s4T9BmAwTPob/9Yd5bGQceB8OCSQCIVc7l4So9EIbQKVEqn5cNOLEzNpm/BYyTQeGsQDOzAmpZZHMqeNzGe985zNshcHil8lfCkg8KV/GWMIReF6PyeRHbtS9h735QEgAwAKeVrABQjyDReA0ApjoQPDoQiWNtk6/+uEqHr94EL9vsVL48DKGDbc75dkuIm8okgOB6jdLL2d/VoO9TgxVocQgAjzrI022a5fsOWzeO4Jc7uu06KjDjTgjgjiQBoJ8mNrCe5Q1UYgez2gCAAof4H+0gTzMU5a/AVPS13QYeMWyOZBlCi/UOCOC0JPoCA+DhcxAUsr83QB7vaADwoUMAOMshXtKxZF/BAFAVsZVF6PI3pUwwvHsG9g5+i7LsckGEcKQy6gthCSpZBpHOCozHNPBbDEVY3MMc4uMCtLmaBfDa8dnNkTR0NJYunNDLLd5/OQYBuOInUTGauRXIZX/XgVbdimBpjACoc5CHDLRZDOUXsX6GRdoYV2qXVdIDrnevjVIAE10CgOGI2Eml57OpQDqD63DpNQfAi/guWgAsdZCH99FmBQBQy/SXHmljaRDAb3ayVZCP3xOFAEYEXPLg+Da3AouVRFJpshdhfS9BUB0DAN5xkP48tFkLALTi/5WxbKGKqWC6zfc/TbX5X+NEzWEA+BX5kTJ9jNO+DzkGGTj9HC0A7nWI9jTmjzTAD5B9/BBLw+L4dEYEvkNjBMznBVz2YMeQh4nnITciaLBw1fgByGgBMNIhus9kbe7B6sUZKxNJpC5Ch/DrgAsfpHAFUYoAgnI2DailJUo/4IBTu6MilsLabQUI5P/HJ1J4yy2WO+pnT7oUAOmY5yUIlqFsjdHjV8s2B2l+k7XbowDyikQJ7gh4nDpmd7I1qSyjAi59xH4+O0RSigsoijQ8xFLyHKR3hUU/gxIltMstTF01HCf++XEBFz+44l5agcVwCOsdBEC2g7TuNvSxJZECm2AgYh+E2MA+2x1w+cMihNIXyMLWasghALznEJ3HW/QxN5ECm6EhoAceaRBJFvLzlLgNA7trEgSLAILNDgHgSYdovNXQfrvd84tOCUsXEKljZjSI1Gvx+fuBFHmQ1x/E/kA28gicsAKjHaRP53Tfk0ghidO4B5XSpig/iLnqYCzXrSQBAMfj5HQQ6WBZiBEcjLGc5xB9CzRtf55oIV2hIWKbBgC1+G5UIIUeZC/JH66eg2vdO2MEwFEO0VajtLsu4VlWSCjlRLRrlB9k18UMSjEADMQOYZD9VnFBDMpvcYiuIUq7JU5fcWuXkLkKIVssAFAYSMEHByyCMP9zAYKqKAGQ42DUUraZn7RzF4oZ6rBQvihfBFL0wZZrEIGXbJSmKADg1E0oC6VFSVpcBRHAHsbcdgvlf5UUE+Ucr4MR7i5DdDAbsYFIlL/UIVrS2AVT9yRTKNcpnn+VRvFiLT024IEHx62C2HOXVqDVpvL3OTUAiOh8tPlCsgUyBYTwoA8vwlm6JOChB1NBBS65yEa8I5zy25xc/cjbzt0gDOkA7tUof62bsn4c5HkoAJAPANhxBqc7TMMJbhGGTD7YqCj/W/ELXwGPPixCuADpc5bLPvEDml4UwhDD6J/Mf/DRowA4EpHBtTh/bwWAx7wqhOcx+mtYvPzOQB95MADWIGHEpPx8zw4GMN4I5YvcuVMDfezBNngBkmGk0nc7veZ3I+OHImt4E2766nPKZ3GQPIS/D0Im+fj7Yy8zfgVu0vjM7m1gHpbFGNwncJD9XH2O15m+H7d99Av4j0yIEQAYB6t4ltcZHuCr/XfyOAeJGMeJswK+RPomCEYjRn+yLw3/8R//cffzHyu0J71nF5YFAAAAAElFTkSuQmCC]=]

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

local function GetLogoAsset()
    if NexusLib.LogoAsset ~= nil then
        return NexusLib.LogoAsset
    end
    local ok, asset = pcall(function()
        local getAsset = getcustomasset or getsynasset
        if not (writefile and getAsset) then
            error("no file api")
        end
        local name = "nexus_logo_white_v4.png"
        writefile(name, DecodeBase64(LOGO_B64))
        return getAsset(name)
    end)
    NexusLib.LogoAsset = (ok and asset) or ""
    return NexusLib.LogoAsset
end

-- Renders the embedded PNG logo, or draws the geometric shattered-N shards if file APIs are unavailable
local function Logo(parent, props)
    local asset = GetLogoAsset()
    if asset ~= "" then
        local p = {
            BackgroundTransparency = 1,
            Image = asset,
            ImageColor3 = Theme.White,
            ScaleType = Enum.ScaleType.Fit,
            Parent = parent,
        }
        for k, v in pairs(props) do p[k] = v end
        return New("ImageLabel", p)
    end
    local box = New("Frame", { BackgroundTransparency = 1, Parent = parent })
    for k, v in pairs(props) do box[k] = v end
    local function shard(px, py, sx, sy, rot)
        New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(px, py),
            Size = UDim2.fromScale(sx, sy),
            Rotation = rot,
            BackgroundColor3 = Theme.White,
            BorderSizePixel = 0,
            Parent = box,
        }, { Corner(1) })
    end
    -- Stylized shattered Nexus "N" geometry
    shard(0.42, 0.50, 0.16, 0.96, -33) -- main diagonal slash
    shard(0.75, 0.46, 0.14, 0.88, 14)  -- right vertical-slanted leg
    shard(0.24, 0.48, 0.11, 0.30, 12)  -- left upper shard
    shard(0.20, 0.78, 0.11, 0.28, 16)  -- left lower shard
    shard(0.90, 0.76, 0.08, 0.26, 16)  -- right outer shard
    return box
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
    end)
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
        IgnoreGuiInset = true, Parent = GetSafeGui(),
    })

    local Island = Surface("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, ISLAND_TOP),
        Size = UDim2.fromOffset(ISLAND_W, ISLAND_H),
        ClipsDescendants = true,
        Parent = Gui,
    }, 20)
    local IslandCorner = Island:FindFirstChildOfClass("UICorner")
    local Bump = New("UIScale", { Scale = 0.92, Parent = Island })
    Tween(Bump, 0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Scale = 1 })

    local Bar = New("TextButton", {
        Size = UDim2.new(1, 0, 0, ISLAND_H), BackgroundTransparency = 1, Text = "",
        AutoButtonColor = false, Parent = Island,
    })
    Logo(Bar, { Position = UDim2.new(0, 12, 0.5, -9), Size = UDim2.fromOffset(18, 18) })
    local NameLabel = Label(Bar, {
        Position = UDim2.fromOffset(39, 0), Size = UDim2.new(0, 42, 1, 0),
        Font = Enum.Font.GothamBold, TextSize = 12, Text = config.Title or "Nexus",
    })
    local Status = Label(Bar, {
        Position = UDim2.fromOffset(84, 0), Size = UDim2.new(0, 110, 1, 0),
        Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = Theme.Dim, Text = config.Status or "Farming",
    })
    local Stats = Label(Bar, {
        AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -33, 0, 0), Size = UDim2.new(0, 115, 1, 0),
        Font = Enum.Font.Code, TextSize = 10, TextColor3 = Theme.Dim, TextXAlignment = Enum.TextXAlignment.Right,
        RichText = true,
        Text = "144 fps <font color=\"#5a5a62\">·</font> 19ms",
    })
    local Caret = Chevron(Bar, {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -13, 0.5, 0),
    }, Theme.Faint)

    -- drawer: Clean full-width Hide UI button (removed test notify button)
    local Drawer = New("Frame", {
        Position = UDim2.fromOffset(10, ISLAND_H + 2), Size = UDim2.new(1, -20, 0, 30),
        BackgroundTransparency = 1, Parent = Island,
    }, {
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    })
    local HideBtn = Button(Drawer, "Hide UI", { Size = UDim2.new(1, 0, 1, 0), LayoutOrder = 1 }, false)

    local IslandApi = { Gui = Gui, Frame = Island, Expanded = false, ShowStats = true }
    NexusLib.ActiveIsland = IslandApi

    function IslandApi:SetExpanded(on)
        IslandApi.Expanded = on
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
        Status.Position = UDim2.fromOffset(84, 4)
        Status.Text = text
        Tween(Status, 0.28, nil, nil, { TextTransparency = 0, Position = UDim2.fromOffset(84, 0) })
    end
    function IslandApi:SetStatsVisible(visible)
        IslandApi.ShowStats = visible
        Stats.Visible = visible
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
    Island.MouseEnter:Connect(function() Tween(Island.UIStroke, 0.2, nil, nil, { Transparency = Theme.StrokeHover }) end)
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
            local ping = 19
            pcall(function()
                ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            Stats.Text = frames .. " fps <font color=\"#5a5a62\">·</font> " .. ping .. "ms"
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

    local Slot = New("Frame", {
        Size = UDim2.fromOffset(NOTE_W, 0), BackgroundTransparency = 1,
        LayoutOrder = math.floor(os.clock() * 1000), Parent = Stack,
    })
    local Card = Surface("Frame", {
        AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 28, 1, 0),
        Size = UDim2.fromOffset(NOTE_W, NOTE_H), ClipsDescendants = true, Parent = Slot,
    }, 12)
    Logo(Card, { Position = UDim2.fromOffset(12, 12), Size = UDim2.fromOffset(16, 16) })
    Label(Card, {
        Position = UDim2.fromOffset(38, 10), Size = UDim2.new(1, -50, 0, 16),
        Font = Enum.Font.GothamBold, TextSize = 12, Text = cfg.Title or "Nexus",
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
    Label(Card, {
        Position = UDim2.fromOffset(38, 27), Size = UDim2.new(1, -50, 0, 16),
        Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = Theme.Dim, Text = cfg.Content or cfg.Message or "",
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
    local Bar = New("Frame", {
        AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = Theme.White, BackgroundTransparency = 0.65, BorderSizePixel = 0,
        Parent = Card,
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
    -- Countdown bar always runs at real duration even when ReduceMotion is enabled
    TweenService:Create(Bar, TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 0, 0, 2),
    }):Play()
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
    local homeY = ISLAND_TOP + ISLAND_H + 12

    local Gui = New("ScreenGui", {
        Name = "Nexus_Window", DisplayOrder = 99990, ResetOnSpawn = false,
        IgnoreGuiInset = true, Parent = GetSafeGui(),
    })

    -- Native Frame (not CanvasGroup) so all fonts, corners and 1px strokes render crisp at 100% resolution
    local Frame = Surface("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, homeY),
        Size = size,
        ClipsDescendants = true,
        Parent = Gui,
    }, 14)
    local Pop = New("UIScale", { Scale = 0.96, Parent = Frame })
    Tween(Pop, 0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Scale = 1 })

    local Window = { Tabs = {}, CurrentTab = nil, Gui = Gui, Frame = Frame, Visible = true, Pushed = false }
    NexusLib.ActiveWindow = Window
    local savedPos = Frame.Position

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
        Position = UDim2.fromOffset(44, 0), Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X,
        Font = Enum.Font.GothamBold, TextSize = 13, Text = config.Title or "Nexus Hub",
    })
    local Sub = Label(TitleBar, {
        Position = UDim2.fromOffset(118, 1), Size = UDim2.new(0, 200, 1, 0),
        Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = Theme.Faint, Text = config.SubTitle or "Universal",
    })
    local function updateSubPos()
        Sub.Position = UDim2.fromOffset(44 + TitleText.TextBounds.X + 8, 1)
    end
    TitleText:GetPropertyChangedSignal("TextBounds"):Connect(updateSubPos)
    task.defer(updateSubPos)

    local MinBtn = New("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(26, 26),
        BackgroundColor3 = Theme.Control, BackgroundTransparency = 1, BorderSizePixel = 0,
        AutoButtonColor = false, Text = "", Parent = TitleBar,
    }, { Corner(7) })
    local MinLine = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(10, 1.5),
        BackgroundColor3 = Theme.Dim, BorderSizePixel = 0, Parent = MinBtn,
    }, { Corner(1) })
    MinBtn.MouseEnter:Connect(function()
        Tween(MinBtn, 0.15, nil, nil, { BackgroundTransparency = 0 })
        Tween(MinLine, 0.15, nil, nil, { BackgroundColor3 = Theme.Text })
    end)
    MinBtn.MouseLeave:Connect(function()
        Tween(MinBtn, 0.15, nil, nil, { BackgroundTransparency = 1 })
        Tween(MinLine, 0.15, nil, nil, { BackgroundColor3 = Theme.Dim })
    end)
    MinBtn.MouseButton1Click:Connect(function() Window:SetVisible(false) end)

    -- drag by the title bar (double-click resets position to center)
    local dragging, dragStart, startPos = false, nil, nil
    local lastClick = 0
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, math.max(8, startPos.Y.Offset + d.Y))
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
    local TabList = New("Frame", {
        Position = UDim2.fromOffset(8, 10), Size = UDim2.new(1, -16, 1, -20),
        BackgroundTransparency = 1, Parent = Sidebar,
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
        local island = NexusLib.ActiveIsland
        if island then island:SetHiddenLabel(not on) end
        if on then
            Frame.Visible = true
            Tween(Frame, 0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
                Position = savedPos, BackgroundTransparency = Theme.SurfaceAlpha,
            })
            Tween(Pop, 0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Scale = 1 })
            if island then island:SetStatus("Farming") end
        else
            savedPos = Frame.Position
            Tween(Frame, 0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.In, {
                Position = UDim2.new(0.5, 0, 0, ISLAND_TOP), BackgroundTransparency = 0.85,
            })
            Tween(Pop, 0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.In, { Scale = 0.25 })
            task.delay(0.3, function()
                if island then
                    island:Gulp()
                    island:SetStatus("Hidden")
                end
            end)
            task.delay(0.35, function()
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

            local sec = {}
            function sec:CreateToggle(...) return Tab:CreateToggle(...) end
            function sec:CreateSlider(...) return Tab:CreateSlider(...) end
            function sec:CreateButton(...) return Tab:CreateButton(...) end
            function sec:CreateInput(...) return Tab:CreateInput(...) end
            function sec:CreateTextbox(...) return Tab:CreateInput(...) end
            function sec:CreateDropdown(...) return Tab:CreateDropdown(...) end
            function sec:CreateMultiDropdown(...) return Tab:CreateMultiDropdown(...) end
            function sec:CreateKeybind(...) return Tab:CreateKeybind(...) end
            function sec:CreateLabel(...) return Tab:CreateLabel(...) end
            function sec:CreateHeader(...) return Tab:CreateHeader(...) end
            function sec:CreateActionRow(...) return Tab:CreateActionRow(...) end
            function sec:CreateCardGroup(...) return Tab:CreateCardGroup(...) end
            function sec:CreateStatRow(...) return Tab:CreateStatRow(...) end
            function sec:CreateBlock(...) return Tab:CreateBlock(...) end
            function sec:CreateFeaturedCard(...) return Tab:CreateFeaturedCard(...) end
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
            local text = cfg.Text or "Go"
            local w = math.max(54, #text * 7 + 32)
            local _, right = Item(cfg, w)
            local b = Button(right, text, {
                AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(w, 28),
            }, false)
            b.MouseButton1Click:Connect(function()
                if cfg.Callback then task.spawn(cfg.Callback) end
            end)
            return b
        end

        function Tab:CreateInput(cfg)
            local _, right = Item(cfg, 150)
            local box = New("TextBox", {
                Size = UDim2.fromScale(1, 1),
                BackgroundColor3 = Theme.Control,
                BorderSizePixel = 0,
                Text = cfg.Default or "",
                PlaceholderText = cfg.Placeholder or "Username",
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
            local Input = {}
            function Input:Set(v) box.Text = tostring(v) end
            function Input:Get() return box.Text end
            return Input
        end

        function Tab:CreateTextbox(cfg)
            return Tab:CreateInput(cfg)
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
            function Dropdown:Refresh(newOptions)
                options = newOptions or {}
                if not table.find(options, value) then
                    set(options[1] or "")
                end
            end
            return Dropdown
        end

        function Tab:CreateMultiDropdown(cfg)
            local options = cfg.Options or {}
            local selectedMap = {}
            if type(cfg.Default) == "table" then
                for k, v in pairs(cfg.Default) do
                    if type(k) == "number" then
                        selectedMap[v] = true
                    elseif v == true then
                        selectedMap[k] = true
                    end
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
                conn = UserInputService.InputBegan:Connect(function(input)
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
                end)
            end)
            local Keybind = {}
            function Keybind:Get() return key end
            return Keybind
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
            local LabelObj = {}
            function LabelObj:Set(newText)
                lbl.Text = tostring(newText)
            end
            return LabelObj
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
        end

        function Tab:CreateFeaturedCard(cfg)
            cfg = cfg or {}
            local card = New("Frame", {
                Size = UDim2.new(1, 0, 0, 52),
                BackgroundColor3 = Theme.Row,
                BorderSizePixel = 0,
                LayoutOrder = nextOrder(),
                Parent = Page,
            }, { Corner(9), Rim(Theme.StrokeAlpha) })

            Label(card, {
                Position = UDim2.fromOffset(12, 8),
                Size = UDim2.new(1, -24, 0, 14),
                Font = Enum.Font.GothamBold,
                TextSize = 10,
                TextColor3 = Theme.Faint,
                Text = string.upper(cfg.Tag or "FEATURED"),
            })
            Label(card, {
                Position = UDim2.fromOffset(12, 24),
                Size = UDim2.new(1, -24, 0, 18),
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                TextColor3 = Theme.Text,
                Text = cfg.Title or "",
            })
            return card
        end

        function Tab:CreateStatRow(stats)
            stats = stats or {}
            local count = #stats
            if count == 0 then return end
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
                    Size = UDim2.new(1 / count, -((count - 1) * 6 / count), 1, 0),
                    BackgroundColor3 = Theme.Row,
                    BorderSizePixel = 0,
                    LayoutOrder = i,
                    Parent = row,
                }, { Corner(8) })

                Label(cell, {
                    Position = UDim2.fromOffset(8, 6),
                    Size = UDim2.new(1, -16, 0, 13),
                    Font = Enum.Font.GothamMedium,
                    TextSize = 9,
                    TextColor3 = Theme.Dim,
                    Text = string.upper(st.Title or "STAT"),
                })
                local vl = Label(cell, {
                    Position = UDim2.fromOffset(8, 22),
                    Size = UDim2.new(1, -16, 0, 18),
                    Font = Enum.Font.GothamBold,
                    TextSize = 11,
                    TextColor3 = st.Color or Theme.Text,
                    Text = tostring(st.Value or "-"),
                })
                valLabels[i] = vl
                if st.Title then valLabels[st.Title] = vl end
            end

            local StatRowObj = {}
            function StatRowObj:Update(key, newVal)
                local target = valLabels[key]
                if target then target.Text = tostring(newVal) end
            end
            return StatRowObj
        end

        function Tab:CreateActionRow(...)
            local buttons = { ... }
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
            local n = #buttons
            for i, bcfg in ipairs(buttons) do
                local b = Button(row, bcfg.Text or "Action", {
                    Size = UDim2.new(1 / n, -((n - 1) * 6 / n), 1, 0),
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
            Island = NexusLib:CreateDynamicIsland({ Title = "Nexus", Status = "Farming" })
        end,
        OnWindow = function()
            if not Island then
                Island = NexusLib:CreateDynamicIsland({ Title = "Nexus", Status = "Farming" })
            end
            local Window = NexusLib:CreateWindow({ Title = "Nexus Hub", SubTitle = "Universal" })
            local function note(title, on)
                NexusLib:Notify({ Title = title, Content = on and "Enabled" or "Disabled" })
            end

            local Main = Window:CreateTab("Main")
            Main:CreateSection("Automation")
            Main:CreateToggle({
                Name = "Auto farm",
                Description = "Attacks the nearest enemy",
                Default = true,
                Callback = function(on)
                    Island:SetStatus(on and "Farming" or "Ready")
                    note("Auto farm", on)
                end,
            })
            Main:CreateToggle({
                Name = "Kill aura",
                Description = "Hits everything in range",
                Default = false,
                Callback = function(on)
                    if on then Island:SetStatus("Kill aura") end
                    note("Kill aura", on)
                end,
            })
            Main:CreateDropdown({
                Name = "Target priority",
                Options = { "Nearest", "Lowest HP", "Boss" },
                Default = "Nearest",
                Callback = function(v)
                    NexusLib:Notify({ Title = "Target", Content = v })
                end,
            })

            Main:CreateSection("Player")
            Main:CreateSlider({
                Name = "Walk speed",
                Min = 16,
                Max = 200,
                Default = 60,
                Callback = function(v)
                    local char = LocalPlayer.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if hum then hum.WalkSpeed = v end
                end,
            })
            local infJumpOn = true
            Main:CreateToggle({
                Name = "Infinite jump",
                Default = true,
                Callback = function(on)
                    infJumpOn = on
                    note("Infinite jump", on)
                end,
            })
            UserInputService.JumpRequest:Connect(function()
                if infJumpOn then
                    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
                end
            end)
            Main:CreateInput({
                Name = "Teleport to player",
                Description = "Type a name, press Enter",
                Placeholder = "Username",
                Callback = function(name)
                    local target = Players:FindFirstChild(name)
                    local root = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
                    local mine = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if root and mine then
                        mine.CFrame = root.CFrame * CFrame.new(0, 0, 3)
                    end
                    NexusLib:Notify({ Title = "Teleport", Content = "Teleported to " .. name })
                end,
            })
            Main:CreateButton({
                Name = "Return to spawn",
                Text = "Go",
                Callback = function()
                    NexusLib:Notify({ Title = "Teleport", Content = "Back at spawn" })
                end,
            })

            local Combat = Window:CreateTab("Combat")
            Combat:CreateSection("Aim")
            Combat:CreateToggle({
                Name = "Silent aim",
                Description = "Redirects shots to the target",
                Default = true,
                Callback = function(on) note("Silent aim", on) end,
            })
            Combat:CreateDropdown({
                Name = "Aim part",
                Options = { "Head", "Torso", "Root" },
                Default = "Head",
            })
            Combat:CreateSlider({
                Name = "Hitbox size",
                Description = "Studs",
                Min = 2,
                Max = 50,
                Default = 14,
            })
            Combat:CreateSection("Defense")
            Combat:CreateToggle({
                Name = "Auto parry",
                Description = "Blocks incoming attacks",
                Default = false,
                Callback = function(on) note("Auto parry", on) end,
            })

            local Visual = Window:CreateTab("Visual")
            Visual:CreateSection("ESP")
            Visual:CreateToggle({
                Name = "Boxes",
                Default = true,
                Callback = function(on) note("Boxes", on) end,
            })
            Visual:CreateToggle({
                Name = "Chams",
                Description = "Highlight through walls",
                Default = false,
                Callback = function(on) note("Chams", on) end,
            })
            Visual:CreateToggle({
                Name = "Tracers",
                Default = false,
                Callback = function(on) note("Tracers", on) end,
            })
            Visual:CreateSection("Camera")
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

getgenv = getgenv or function() return _G end
pcall(function() getgenv().NexusLib = NexusLib end)

if not _G.NEXUS_LIB_ONLY and not (shared and shared.NEXUS_LIB_ONLY) then
    task.spawn(function()
        NexusLib:Demo()
    end)
end

return NexusLib
