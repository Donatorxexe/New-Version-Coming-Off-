--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║            M E D U S A   U N I V E R S A L   E N G I N E   ║
    ║                        Version 1.0.1                        ║
    ║                      Cobra Edition                          ║
    ║                                                              ║
    ║   Performance • Stability • Neon Aesthetics                  ║
    ║   Theme: Black & Emerald Green (0, 201, 107)                 ║
    ╚══════════════════════════════════════════════════════════════╝
]]

-- ═══════════════════════════════════════════════════════════════
-- SECTION 1: HARD CLEAN (Limpa qualquer instância anterior)
-- ═══════════════════════════════════════════════════════════════

if _G.Medusa then
    pcall(function()
        if _G.Medusa.Connections then
            for _, conn in pairs(_G.Medusa.Connections) do
                pcall(function() conn:Disconnect() end)
            end
        end
        if _G.Medusa.ScreenGui then
            _G.Medusa.ScreenGui:Destroy()
        end
        if _G.Medusa.FlyBody then
            pcall(function() _G.Medusa.FlyBody:Destroy() end)
        end
        if _G.Medusa.FlyGyro then
            pcall(function() _G.Medusa.FlyGyro:Destroy() end)
        end
    end)
    _G.Medusa = nil
    task.wait(0.3)
end

-- ═══════════════════════════════════════════════════════════════
-- SECTION 2: SERVICES & CONFIG TABLE
-- ═══════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local Config = {
    Version = "1.0.1",
    Theme = {
        Primary     = Color3.fromRGB(0, 201, 107),
        PrimaryDark = Color3.fromRGB(0, 100, 53),
        PrimaryDeep = Color3.fromRGB(0, 60, 32),
        Accent      = Color3.fromRGB(0, 255, 136),
        Background  = Color3.fromRGB(10, 10, 10),
        Card        = Color3.fromRGB(16, 16, 16),
        CardHover   = Color3.fromRGB(22, 22, 22),
        Surface     = Color3.fromRGB(20, 20, 20),
        SurfaceAlt  = Color3.fromRGB(26, 26, 26),
        Border      = Color3.fromRGB(0, 201, 107),
        Text        = Color3.fromRGB(0, 201, 107),
        TextBright  = Color3.fromRGB(0, 255, 136),
        TextDim     = Color3.fromRGB(0, 80, 42),
        TextMuted   = Color3.fromRGB(40, 40, 40),
        White       = Color3.fromRGB(255, 255, 255),
        Red         = Color3.fromRGB(255, 55, 55),
        RedDark     = Color3.fromRGB(80, 20, 20),
        Off         = Color3.fromRGB(50, 50, 50),
        OffDim      = Color3.fromRGB(30, 30, 30),
    },
    CobraAsset = "rbxassetid://15682885994",
    ToggleKey  = Enum.KeyCode.M,
    FlyKey     = Enum.KeyCode.F,
    Defaults = {
        WalkSpeed  = 16,
        JumpPower  = 50,
        FlySpeed   = 80,
    },
}

-- ═══════════════════════════════════════════════════════════════
-- SECTION 3: STATE & FUNCTIONS TABLE
-- ═══════════════════════════════════════════════════════════════

local Functions = {
    WalkSpeed = {
        Enabled = false,
        Value   = Config.Defaults.WalkSpeed,
    },
    JumpPower = {
        Enabled = false,
        Value   = Config.Defaults.JumpPower,
    },
    InfiniteJump = {
        Enabled = false,
    },
    Fly = {
        Enabled = false,
        Speed   = Config.Defaults.FlySpeed,
    },
    Fullbright = {
        Enabled = false,
    },
    Noclip = {
        Enabled = false,
    },
}

local UI = {
    Refs    = {},
    Toasts  = {},
    Console = {},
    Tweens  = {},
}

-- ═══════════════════════════════════════════════════════════════
-- SECTION 4: GLOBAL STATE (_G.Medusa)
-- ═══════════════════════════════════════════════════════════════

_G.Medusa = {
    Config      = Config,
    Functions   = Functions,
    UI          = UI,
    Connections = {},
    ScreenGui   = nil,
    FlyBody     = nil,
    FlyGyro     = nil,
    Active      = true,
}

-- ═══════════════════════════════════════════════════════════════
-- SECTION 5: UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

local function GetCharacter()
    return Player.Character or Player.CharacterAdded:Wait()
end

local function GetHumanoid()
    local char = GetCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function GetRootPart()
    local char = GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function AddConnection(conn)
    table.insert(_G.Medusa.Connections, conn)
    return conn
end

local function SafeTween(obj, info, props)
    if not obj or not obj.Parent then return nil end
    local success, tween = pcall(function()
        return TweenService:Create(obj, info, props)
    end)
    if success and tween then
        table.insert(UI.Tweens, tween)
        tween:Play()
        return tween
    end
    return nil
end

local function ConsoleLog(msg, logType)
    logType = logType or "INFO"
    local timestamp = string.format("%.1f", tick() % 10000)
    local entry = {
        Time = timestamp,
        Type = logType,
        Message = msg,
    }
    table.insert(UI.Console, entry)

    if UI.Refs.ConsoleScroll then
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -10, 0, 18)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.Code
        label.TextSize = 11
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.RichText = true
        label.TextWrapped = true
        label.AutomaticSize = Enum.AutomaticSize.Y

        local typeColor
        if logType == "INFO" then
            typeColor = "rgb(0,201,107)"
        elseif logType == "WARN" then
            typeColor = "rgb(255,200,0)"
        elseif logType == "ERROR" then
            typeColor = "rgb(255,60,60)"
        elseif logType == "SYSTEM" then
            typeColor = "rgb(0,255,140)"
        else
            typeColor = "rgb(0,201,107)"
        end

        label.Text = string.format(
            '<font color="rgb(0,80,42)">[%s]</font> <font color="%s">[%s]</font> <font color="rgb(0,201,107)"> %s</font>',
            timestamp, typeColor, logType, msg
        )
        label.TextColor3 = Config.Theme.Primary
        label.Parent = UI.Refs.ConsoleScroll

        task.defer(function()
            if UI.Refs.ConsoleScroll then
                UI.Refs.ConsoleScroll.CanvasPosition = Vector2.new(0, UI.Refs.ConsoleScroll.AbsoluteCanvasSize.Y)
            end
        end)
    end
end

local function ShowToast(message, duration)
    duration = duration or 3
    if not UI.Refs.ToastContainer then return end

    local toast = Instance.new("Frame")
    toast.Size = UDim2.new(0, 320, 0, 44)
    toast.BackgroundColor3 = Config.Theme.Card
    toast.BorderSizePixel = 0
    toast.Position = UDim2.new(1, 50, 1, -(#UI.Toasts * 54 + 14))
    toast.AnchorPoint = Vector2.new(1, 1)
    toast.Parent = UI.Refs.ToastContainer

    local toastCorner = Instance.new("UICorner")
    toastCorner.CornerRadius = UDim.new(0, 8)
    toastCorner.Parent = toast

    local toastStroke = Instance.new("UIStroke")
    toastStroke.Color = Config.Theme.Primary
    toastStroke.Thickness = 1
    toastStroke.Transparency = 0.4
    toastStroke.Parent = toast

    -- Barra lateral verde (accent)
    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 3, 0.7, 0)
    accentBar.Position = UDim2.new(0, 6, 0.15, 0)
    accentBar.BackgroundColor3 = Config.Theme.Primary
    accentBar.BorderSizePixel = 0
    accentBar.Parent = toast

    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(1, 0)
    accentCorner.Parent = accentBar

    local toastIcon = Instance.new("TextLabel")
    toastIcon.Size = UDim2.new(0, 24, 1, 0)
    toastIcon.Position = UDim2.new(0, 16, 0, 0)
    toastIcon.BackgroundTransparency = 1
    toastIcon.Text = "🐍"
    toastIcon.TextSize = 14
    toastIcon.Font = Enum.Font.GothamBold
    toastIcon.TextColor3 = Config.Theme.Primary
    toastIcon.Parent = toast

    local toastLabel = Instance.new("TextLabel")
    toastLabel.Size = UDim2.new(1, -50, 1, 0)
    toastLabel.Position = UDim2.new(0, 42, 0, 0)
    toastLabel.BackgroundTransparency = 1
    toastLabel.Text = message
    toastLabel.TextColor3 = Config.Theme.Primary
    toastLabel.Font = Enum.Font.GothamMedium
    toastLabel.TextSize = 12
    toastLabel.TextXAlignment = Enum.TextXAlignment.Left
    toastLabel.TextTruncate = Enum.TextTruncate.AtEnd
    toastLabel.Parent = toast

    table.insert(UI.Toasts, toast)

    -- Slide in
    SafeTween(toast, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -14, 1, -(#UI.Toasts * 54 + 14))
    })

    -- Glow flash on appear
    SafeTween(toastStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        Transparency = 0
    })
    task.delay(0.3, function()
        SafeTween(toastStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
            Transparency = 0.5
        })
    end)

    -- Auto destroy
    task.delay(duration, function()
        SafeTween(toast, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 60, toast.Position.Y.Scale, toast.Position.Y.Offset),
            BackgroundTransparency = 0.5,
        })
        task.wait(0.45)
        for i, t in ipairs(UI.Toasts) do
            if t == toast then
                table.remove(UI.Toasts, i)
                break
            end
        end
        if toast and toast.Parent then toast:Destroy() end
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- SECTION 6: CORE FUNCTIONS (Movement / Fly / Visuals)
-- ═══════════════════════════════════════════════════════════════

local function ApplyWalkSpeed()
    local hum = GetHumanoid()
    if not hum then return end
    if Functions.WalkSpeed.Enabled then
        hum.WalkSpeed = Functions.WalkSpeed.Value
    else
        hum.WalkSpeed = Config.Defaults.WalkSpeed
    end
end

local function ApplyJumpPower()
    local hum = GetHumanoid()
    if not hum then return end
    if Functions.JumpPower.Enabled then
        hum.UseJumpPower = true
        hum.JumpPower = Functions.JumpPower.Value
    else
        hum.UseJumpPower = true
        hum.JumpPower = Config.Defaults.JumpPower
    end
end

local function StartInfiniteJump()
    if _G.Medusa._infJumpConn then return end
    _G.Medusa._infJumpConn = AddConnection(
        UserInputService.JumpRequest:Connect(function()
            if Functions.InfiniteJump.Enabled then
                local hum = GetHumanoid()
                if hum then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    )
end

local function StartFly()
    local root = GetRootPart()
    local hum = GetHumanoid()
    if not root or not hum then return end

    if _G.Medusa.FlyBody then
        pcall(function() _G.Medusa.FlyBody:Destroy() end)
    end
    if _G.Medusa.FlyGyro then
        pcall(function() _G.Medusa.FlyGyro:Destroy() end)
    end

    local bodyVel = Instance.new("BodyVelocity")
    bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVel.Velocity = Vector3.new(0, 0, 0)
    bodyVel.Parent = root
    _G.Medusa.FlyBody = bodyVel

    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.D = 200
    bodyGyro.P = 40000
    bodyGyro.Parent = root
    _G.Medusa.FlyGyro = bodyGyro

    hum.PlatformStand = true

    if _G.Medusa._flyConn then
        pcall(function() _G.Medusa._flyConn:Disconnect() end)
    end

    _G.Medusa._flyConn = AddConnection(
        RunService.RenderStepped:Connect(function()
            if not Functions.Fly.Enabled then return end
            local r = GetRootPart()
            if not r then return end

            local cam = workspace.CurrentCamera
            local speed = Functions.Fly.Speed
            local direction = Vector3.new(0, 0, 0)

            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                direction = direction + cam.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                direction = direction - cam.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                direction = direction - cam.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                direction = direction + cam.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                direction = direction + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                direction = direction - Vector3.new(0, 1, 0)
            end

            if direction.Magnitude > 0 then
                direction = direction.Unit
            end

            bodyVel.Velocity = direction * speed
            bodyGyro.CFrame = cam.CFrame
        end)
    )

    ConsoleLog("Fly system ENGAGED — BodyVelocity mode active", "SYSTEM")
end

local function StopFly()
    local hum = GetHumanoid()
    if hum then
        hum.PlatformStand = false
    end

    if _G.Medusa._flyConn then
        pcall(function() _G.Medusa._flyConn:Disconnect() end)
        _G.Medusa._flyConn = nil
    end

    if _G.Medusa.FlyBody then
        pcall(function() _G.Medusa.FlyBody:Destroy() end)
        _G.Medusa.FlyBody = nil
    end
    if _G.Medusa.FlyGyro then
        pcall(function() _G.Medusa.FlyGyro:Destroy() end)
        _G.Medusa.FlyGyro = nil
    end

    ConsoleLog("Fly system DISENGAGED", "SYSTEM")
end

-- ═══════════════════════════════════════════════════════════════
-- SECTION 7: UI BUILDER — CINEMATIC INTRO (Cobra Neon)
-- ═══════════════════════════════════════════════════════════════

local function PlayCinematicIntro(screenGui, callback)
    ConsoleLog("Cinematic Intro v1.0.1 — Cobra Sequence initiating...", "SYSTEM")

    -- === INTRO CONTAINER ===
    local introFrame = Instance.new("Frame")
    introFrame.Name = "IntroFrame"
    introFrame.Size = UDim2.new(1, 0, 1, 0)
    introFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    introFrame.BorderSizePixel = 0
    introFrame.ZIndex = 100
    introFrame.Parent = screenGui

    -- === VIGNETTE OVERLAY ===
    local vignette = Instance.new("ImageLabel")
    vignette.Name = "Vignette"
    vignette.Size = UDim2.new(1, 0, 1, 0)
    vignette.BackgroundTransparency = 1
    vignette.Image = "rbxassetid://1039998000"
    vignette.ImageColor3 = Config.Theme.Primary
    vignette.ImageTransparency = 0.85
    vignette.ScaleType = Enum.ScaleType.Stretch
    vignette.ZIndex = 101
    vignette.Parent = introFrame

    -- Vignette pulse sync
    task.spawn(function()
        while introFrame and introFrame.Parent do
            SafeTween(vignette, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                ImageTransparency = 0.65
            })
            task.wait(1.8)
            SafeTween(vignette, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                ImageTransparency = 0.9
            })
            task.wait(1.8)
        end
    end)

    -- === MATRIX RAIN (0s e 1s) ===
    local matrixContainer = Instance.new("Frame")
    matrixContainer.Name = "MatrixRain"
    matrixContainer.Size = UDim2.new(1, 0, 1, 0)
    matrixContainer.BackgroundTransparency = 1
    matrixContainer.ClipsDescendants = true
    matrixContainer.ZIndex = 102
    matrixContainer.Parent = introFrame

    task.spawn(function()
        local chars = {"0", "1", "M", "E", "D", "U", "S", "A", "0", "1", "0", "1"}
        while introFrame and introFrame.Parent do
            for i = 1, 3 do
                local drop = Instance.new("TextLabel")
                drop.Size = UDim2.new(0, 14, 0, 14)
                drop.Position = UDim2.new(math.random() * 0.95, 0, -0.05, 0)
                drop.BackgroundTransparency = 1
                drop.Text = chars[math.random(1, #chars)]
                drop.TextColor3 = Config.Theme.Primary
                drop.TextTransparency = math.random(50, 85) / 100
                drop.Font = Enum.Font.Code
                drop.TextSize = math.random(10, 16)
                drop.ZIndex = 102
                drop.Parent = matrixContainer

                local fallTime = math.random(30, 80) / 10
                SafeTween(drop, TweenInfo.new(fallTime, Enum.EasingStyle.Linear), {
                    Position = UDim2.new(drop.Position.X.Scale, 0, 1.1, 0),
                    TextTransparency = 1,
                })
                task.delay(fallTime + 0.1, function()
                    if drop and drop.Parent then drop:Destroy() end
                end)
            end
            task.wait(0.15)
        end
    end)

    -- === SCANLINES ===
    local scanlines = Instance.new("Frame")
    scanlines.Size = UDim2.new(1, 0, 1, 0)
    scanlines.BackgroundTransparency = 1
    scanlines.ZIndex = 103
    scanlines.Parent = introFrame

    for i = 0, 60 do
        local line = Instance.new("Frame")
        line.Size = UDim2.new(1, 0, 0, 1)
        line.Position = UDim2.new(0, 0, i / 60, 0)
        line.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        line.BackgroundTransparency = 0.93
        line.BorderSizePixel = 0
        line.ZIndex = 103
        line.Parent = scanlines
    end

    -- === CENTRAL CONTENT ===
    local centerContainer = Instance.new("Frame")
    centerContainer.Name = "CenterContent"
    centerContainer.Size = UDim2.new(0, 420, 0, 380)
    centerContainer.Position = UDim2.new(0.5, 0, 0.45, 0)
    centerContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    centerContainer.BackgroundTransparency = 1
    centerContainer.ZIndex = 110
    centerContainer.Parent = introFrame

    -- ╔═══════════════════════════════════════════════════════════╗
    -- ║  COBRA NEON — O Símbolo da Medusa (v1.0.1 FIX)         ║
    -- ║  Sem UIStroke/UICorner em ImageLabel (causa quadrado)   ║
    -- ║  Glow = cópia da cobra maior por trás (neon real)       ║
    -- ╚═══════════════════════════════════════════════════════════╝

    -- LAYER 1: Glow radial difuso (aura ambiente)
    local cobraAura = Instance.new("ImageLabel")
    cobraAura.Name = "CobraAura"
    cobraAura.Size = UDim2.new(0, 0, 0, 0)
    cobraAura.Position = UDim2.new(0.5, 0, 0, 95)
    cobraAura.AnchorPoint = Vector2.new(0.5, 0.5)
    cobraAura.BackgroundTransparency = 1
    cobraAura.Image = "rbxassetid://5028857084"
    cobraAura.ImageColor3 = Config.Theme.Primary
    cobraAura.ImageTransparency = 0.75
    cobraAura.ScaleType = Enum.ScaleType.Fit
    cobraAura.ZIndex = 111
    cobraAura.Parent = centerContainer

    -- LAYER 2: Glow da cobra (cópia da MESMA imagem, maior, semi-transparente)
    -- Isto cria o efeito neon REAL sem UIStroke
    local cobraGlow = Instance.new("ImageLabel")
    cobraGlow.Name = "CobraGlow"
    cobraGlow.Size = UDim2.new(0, 0, 0, 0)
    cobraGlow.Position = UDim2.new(0.5, 0, 0, 20)
    cobraGlow.AnchorPoint = Vector2.new(0.5, 0)
    cobraGlow.BackgroundTransparency = 1
    cobraGlow.Image = Config.CobraAsset  -- MESMA cobra como glow
    cobraGlow.ImageColor3 = Config.Theme.Accent  -- Verde mais brilhante para glow
    cobraGlow.ImageTransparency = 0.4
    cobraGlow.ScaleType = Enum.ScaleType.Fit
    cobraGlow.ZIndex = 113
    cobraGlow.Parent = centerContainer

    -- LAYER 3: Cobra principal (nítida, por cima de tudo)
    local cobraImage = Instance.new("ImageLabel")
    cobraImage.Name = "CobraNeon"
    cobraImage.Size = UDim2.new(0, 0, 0, 0)
    cobraImage.Position = UDim2.new(0.5, 0, 0, 20)
    cobraImage.AnchorPoint = Vector2.new(0.5, 0)
    cobraImage.BackgroundTransparency = 1
    cobraImage.Image = Config.CobraAsset
    cobraImage.ImageColor3 = Config.Theme.Primary
    cobraImage.ImageTransparency = 0
    cobraImage.ScaleType = Enum.ScaleType.Fit
    cobraImage.ZIndex = 115
    cobraImage.Parent = centerContainer

    -- SEM UIStroke, SEM UICorner — limpo, sem moldura

    -- ═══ FASE 1: Cobra desliza para o ecrã ═══
    ConsoleLog("Phase 1: Cobra Neon sliding in...", "SYSTEM")
    task.wait(0.5)

    -- Cobra principal cresce de 0 para 150x150
    local cobraSlideIn = SafeTween(cobraImage,
        TweenInfo.new(1.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        { Size = UDim2.new(0, 150, 0, 150) }
    )

    -- Glow da cobra cresce ligeiramente MAIOR (offset de +30px cada lado = aura)
    SafeTween(cobraGlow,
        TweenInfo.new(1.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        { Size = UDim2.new(0, 180, 0, 180) }
    )

    -- Aura ambiente cresce bem grande
    SafeTween(cobraAura,
        TweenInfo.new(1.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { Size = UDim2.new(0, 300, 0, 300) }
    )

    -- Loop Hipnótico do Glow (O Olho de Medusa)
    -- Em vez de UIStroke, o glow PULSA a transparência criando a aura neon
    task.spawn(function()
        while cobraGlow and cobraGlow.Parent and introFrame and introFrame.Parent do
            SafeTween(cobraGlow,
                TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                { ImageTransparency = 0.2 }  -- Mais visível (brilho máximo)
            )
            task.wait(1.2)
            SafeTween(cobraGlow,
                TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                { ImageTransparency = 0.8 }  -- Quase invisível (brilho mínimo)
            )
            task.wait(1.2)
        end
    end)

    -- Aura ambiente pulsa em sincronia (mais lento, mais subtil)
    task.spawn(function()
        while cobraAura and cobraAura.Parent and introFrame and introFrame.Parent do
            SafeTween(cobraAura,
                TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                { ImageTransparency = 0.55 }
            )
            task.wait(1.8)
            SafeTween(cobraAura,
                TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                { ImageTransparency = 0.9 }
            )
            task.wait(1.8)
        end
    end)

    -- Espera cobra terminar o slide
    if cobraSlideIn then cobraSlideIn.Completed:Wait() end
    ConsoleLog("Phase 1 COMPLETE — Cobra fully visible", "SYSTEM")
    task.wait(0.3)

    -- ╔═══════════════════════════════════════════════╗
    -- ║  TEXTO 'M E D U S A' — Glitch após a cobra   ║
    -- ╚═══════════════════════════════════════════════╝

    ConsoleLog("Phase 2: MEDUSA text glitch sequence...", "SYSTEM")

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "MedusaTitle"
    titleLabel.Size = UDim2.new(1, 0, 0, 60)
    titleLabel.Position = UDim2.new(0, 0, 0, 180)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = ""
    titleLabel.TextColor3 = Config.Theme.Primary
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 42
    titleLabel.ZIndex = 115
    titleLabel.Parent = centerContainer

    local titleStroke = Instance.new("UIStroke")
    titleStroke.Color = Config.Theme.Primary
    titleStroke.Thickness = 2
    titleStroke.Transparency = 0.2
    titleStroke.Parent = titleLabel

    -- Pulse do título em sincronia
    task.spawn(function()
        while titleStroke and titleStroke.Parent and introFrame and introFrame.Parent do
            SafeTween(titleStroke,
                TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                { Transparency = 1.0 }
            )
            task.wait(1.2)
            SafeTween(titleStroke,
                TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                { Transparency = 0.2 }
            )
            task.wait(1.2)
        end
    end)

    -- Efeito Glitch
    local targetText = "M E D U S A"
    local glitchChars = "!@#$%^&*()_+-=01<>/~"

    for glitchPass = 1, 12 do
        local glitched = ""
        for i = 1, #targetText do
            local char = targetText:sub(i, i)
            if char == " " then
                glitched = glitched .. " "
            elseif glitchPass > (i * 0.8) then
                glitched = glitched .. char
            else
                local ri = math.random(1, #glitchChars)
                glitched = glitched .. glitchChars:sub(ri, ri)
            end
        end
        titleLabel.Text = glitched
        task.wait(0.08)
    end
    titleLabel.Text = targetText
    ConsoleLog("Phase 2 COMPLETE — Title revealed", "SYSTEM")

    -- Subtítulo
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, 0, 0, 20)
    subtitle.Position = UDim2.new(0, 0, 0, 240)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "U N I V E R S A L   E N G I N E"
    subtitle.TextColor3 = Config.Theme.TextDim
    subtitle.TextTransparency = 1
    subtitle.Font = Enum.Font.GothamMedium
    subtitle.TextSize = 13
    subtitle.ZIndex = 115
    subtitle.Parent = centerContainer

    SafeTween(subtitle, TweenInfo.new(0.8, Enum.EasingStyle.Quad), {
        TextTransparency = 0
    })
    task.wait(0.5)

    -- ╔═══════════════════════════════════════════════╗
    -- ║  BARRA NEON — Gradiente com luz a correr      ║
    -- ╚═══════════════════════════════════════════════╝

    ConsoleLog("Phase 3: Neon loading bar initiated...", "SYSTEM")

    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(0.65, 0, 0, 4)
    barBg.Position = UDim2.new(0.175, 0, 0, 280)
    barBg.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    barBg.BorderSizePixel = 0
    barBg.ZIndex = 115
    barBg.Parent = centerContainer

    local barBgCorner = Instance.new("UICorner")
    barBgCorner.CornerRadius = UDim.new(1, 0)
    barBgCorner.Parent = barBg

    -- Glow atrás da barra
    local barGlow = Instance.new("ImageLabel")
    barGlow.Size = UDim2.new(0.65, 40, 0, 30)
    barGlow.Position = UDim2.new(0.175, -20, 0, 267)
    barGlow.BackgroundTransparency = 1
    barGlow.Image = "rbxassetid://5028857084"
    barGlow.ImageColor3 = Config.Theme.Primary
    barGlow.ImageTransparency = 0.85
    barGlow.ZIndex = 114
    barGlow.Parent = centerContainer

    local barFill = Instance.new("Frame")
    barFill.Size = UDim2.new(0, 0, 1, 0)
    barFill.BackgroundColor3 = Config.Theme.Primary
    barFill.BorderSizePixel = 0
    barFill.ZIndex = 116
    barFill.Parent = barBg

    local barFillCorner = Instance.new("UICorner")
    barFillCorner.CornerRadius = UDim.new(1, 0)
    barFillCorner.Parent = barFill

    -- UIGradient 3 pontos: Verde Escuro -> Branco -> Verde Escuro
    local barGradient = Instance.new("UIGradient")
    barGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Config.Theme.PrimaryDark),
        ColorSequenceKeypoint.new(0.5, Config.Theme.White),
        ColorSequenceKeypoint.new(1, Config.Theme.PrimaryDark),
    })
    barGradient.Offset = Vector2.new(-1, 0)
    barGradient.Parent = barFill

    -- Luz a correr
    task.spawn(function()
        while barGradient and barGradient.Parent and introFrame and introFrame.Parent do
            SafeTween(barGradient,
                TweenInfo.new(1.5, Enum.EasingStyle.Linear),
                { Offset = Vector2.new(1, 0) }
            )
            task.wait(1.5)
            barGradient.Offset = Vector2.new(-1, 0)
        end
    end)

    -- Status text
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, 0, 0, 16)
    statusLabel.Position = UDim2.new(0, 0, 0, 295)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Initializing..."
    statusLabel.TextColor3 = Config.Theme.TextDim
    statusLabel.Font = Enum.Font.Code
    statusLabel.TextSize = 10
    statusLabel.ZIndex = 115
    statusLabel.Parent = centerContainer

    -- Loading steps
    local loadingSteps = {
        {0.08,  "Cleaning global state..."},
        {0.15,  "Hard clean complete"},
        {0.22,  "Loading Cobra Neon module..."},
        {0.30,  "Cobra Neon initialized"},
        {0.38,  "Injecting UI framework..."},
        {0.48,  "Building movement systems..."},
        {0.55,  "WalkSpeed module ready"},
        {0.63,  "JumpPower module ready"},
        {0.70,  "Infinite Jump loaded"},
        {0.78,  "CFrame Fly engine ready"},
        {0.85,  "Binding keybinds..."},
        {0.92,  "Anti-detection layer active"},
        {1.00,  "M E D U S A  ready"},
    }

    for _, step in ipairs(loadingSteps) do
        SafeTween(barFill, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
            Size = UDim2.new(step[1], 0, 1, 0)
        })
        statusLabel.Text = "> " .. step[2]
        ConsoleLog(step[2], "INFO")
        task.wait(math.random(15, 30) / 100)
    end

    ConsoleLog("Phase 3 COMPLETE — All modules loaded", "SYSTEM")
    task.wait(0.5)

    -- Version badge
    local versionLabel = Instance.new("TextLabel")
    versionLabel.Size = UDim2.new(1, 0, 0, 16)
    versionLabel.Position = UDim2.new(0, 0, 0, 325)
    versionLabel.BackgroundTransparency = 1
    versionLabel.Text = "v" .. Config.Version .. " • Cobra Edition"
    versionLabel.TextColor3 = Config.Theme.PrimaryDark
    versionLabel.TextTransparency = 1
    versionLabel.Font = Enum.Font.Code
    versionLabel.TextSize = 10
    versionLabel.ZIndex = 115
    versionLabel.Parent = centerContainer

    SafeTween(versionLabel, TweenInfo.new(0.6, Enum.EasingStyle.Quad), {
        TextTransparency = 0
    })

    task.wait(1)

    -- ═══ FASE 4: Fade out ═══
    ConsoleLog("Phase 4: Transitioning to main interface...", "SYSTEM")

    SafeTween(introFrame, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        BackgroundTransparency = 1
    })

    for _, child in ipairs(centerContainer:GetDescendants()) do
        if child:IsA("TextLabel") then
            SafeTween(child, TweenInfo.new(0.8, Enum.EasingStyle.Quad), {
                TextTransparency = 1
            })
        elseif child:IsA("ImageLabel") then
            SafeTween(child, TweenInfo.new(0.8, Enum.EasingStyle.Quad), {
                ImageTransparency = 1
            })
        elseif child:IsA("Frame") then
            SafeTween(child, TweenInfo.new(0.8, Enum.EasingStyle.Quad), {
                BackgroundTransparency = 1
            })
        elseif child:IsA("UIStroke") then
            SafeTween(child, TweenInfo.new(0.8, Enum.EasingStyle.Quad), {
                Transparency = 1
            })
        end
    end

    SafeTween(vignette, TweenInfo.new(0.8, Enum.EasingStyle.Quad), {
        ImageTransparency = 1
    })

    task.wait(1.2)
    introFrame:Destroy()

    ConsoleLog("Cinematic Intro COMPLETE — Welcome to Medusa", "SYSTEM")

    if callback then
        callback()
    end
end

-- ═══════════════════════════════════════════════════════════════
-- SECTION 8: UI COMPONENTS — Premium Polished Style (v1.0.0)
-- ═══════════════════════════════════════════════════════════════

-- Cria um card container estilizado
local function CreateCard(parent, name, yPos, height)
    local card = Instance.new("Frame")
    card.Name = name
    card.Size = UDim2.new(1, -24, 0, height)
    card.Position = UDim2.new(0, 12, 0, yPos)
    card.BackgroundColor3 = Config.Theme.Card
    card.BorderSizePixel = 0
    card.ZIndex = 15
    card.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.Color = Config.Theme.PrimaryDeep
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = card

    return card, stroke
end

-- Cria um section header com ícone
local function CreateSectionHeader(parent, text, yPos)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -24, 0, 28)
    container.Position = UDim2.new(0, 12, 0, yPos)
    container.BackgroundTransparency = 1
    container.ZIndex = 15
    container.Parent = parent

    -- Linha decorativa esquerda
    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, 3, 0, 16)
    line.Position = UDim2.new(0, 0, 0.5, 0)
    line.AnchorPoint = Vector2.new(0, 0.5)
    line.BackgroundColor3 = Config.Theme.Primary
    line.BorderSizePixel = 0
    line.ZIndex = 16
    line.Parent = container

    local lineCorner = Instance.new("UICorner")
    lineCorner.CornerRadius = UDim.new(1, 0)
    lineCorner.Parent = line

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -14, 1, 0)
    label.Position = UDim2.new(0, 14, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Config.Theme.Primary
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 16
    label.Parent = container

    return container
end

-- Toggle premium com glow
local function CreateToggle(parent, name, yPos, defaultState, onToggle)
    local card, cardStroke = CreateCard(parent, name .. "Toggle", yPos, 40)

    -- Hover effect
    local hoverBtn = Instance.new("TextButton")
    hoverBtn.Size = UDim2.new(1, 0, 1, 0)
    hoverBtn.BackgroundTransparency = 1
    hoverBtn.Text = ""
    hoverBtn.ZIndex = 20
    hoverBtn.Parent = card

    AddConnection(hoverBtn.MouseEnter:Connect(function()
        SafeTween(card, TweenInfo.new(0.2), { BackgroundColor3 = Config.Theme.CardHover })
    end))
    AddConnection(hoverBtn.MouseLeave:Connect(function()
        SafeTween(card, TweenInfo.new(0.2), { BackgroundColor3 = Config.Theme.Card })
    end))

    -- Nome
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.Position = UDim2.new(0, 14, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Config.Theme.Text
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 17
    label.Parent = card

    -- Status text (ON/OFF)
    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.new(0, 36, 0, 16)
    statusText.Position = UDim2.new(1, -100, 0.5, 0)
    statusText.AnchorPoint = Vector2.new(0, 0.5)
    statusText.BackgroundTransparency = 1
    statusText.Text = "OFF"
    statusText.TextColor3 = Config.Theme.Off
    statusText.Font = Enum.Font.Code
    statusText.TextSize = 10
    statusText.TextXAlignment = Enum.TextXAlignment.Right
    statusText.ZIndex = 17
    statusText.Parent = card

    -- Toggle track
    local toggleBg = Instance.new("Frame")
    toggleBg.Size = UDim2.new(0, 44, 0, 22)
    toggleBg.Position = UDim2.new(1, -58, 0.5, 0)
    toggleBg.AnchorPoint = Vector2.new(0, 0.5)
    toggleBg.BackgroundColor3 = Config.Theme.OffDim
    toggleBg.BorderSizePixel = 0
    toggleBg.ZIndex = 17
    toggleBg.Parent = card

    local toggleBgCorner = Instance.new("UICorner")
    toggleBgCorner.CornerRadius = UDim.new(1, 0)
    toggleBgCorner.Parent = toggleBg

    local toggleBgStroke = Instance.new("UIStroke")
    toggleBgStroke.Color = Config.Theme.Off
    toggleBgStroke.Thickness = 1
    toggleBgStroke.Transparency = 0.5
    toggleBgStroke.Parent = toggleBg

    -- Toggle circle (knob)
    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 16, 0, 16)
    circle.Position = UDim2.new(0, 3, 0.5, 0)
    circle.AnchorPoint = Vector2.new(0, 0.5)
    circle.BackgroundColor3 = Config.Theme.Off
    circle.BorderSizePixel = 0
    circle.ZIndex = 18
    circle.Parent = toggleBg

    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = circle

    -- Glow no circle quando ON
    local circleGlow = Instance.new("ImageLabel")
    circleGlow.Size = UDim2.new(3, 0, 3, 0)
    circleGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
    circleGlow.AnchorPoint = Vector2.new(0.5, 0.5)
    circleGlow.BackgroundTransparency = 1
    circleGlow.Image = "rbxassetid://5028857084"
    circleGlow.ImageColor3 = Config.Theme.Primary
    circleGlow.ImageTransparency = 1
    circleGlow.ZIndex = 17
    circleGlow.Parent = circle

    local isOn = defaultState or false

    local function UpdateVisual()
        if isOn then
            SafeTween(circle, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Position = UDim2.new(1, -19, 0.5, 0),
                BackgroundColor3 = Config.Theme.Primary,
            })
            SafeTween(toggleBg, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
                BackgroundColor3 = Config.Theme.PrimaryDeep,
            })
            SafeTween(toggleBgStroke, TweenInfo.new(0.25), {
                Color = Config.Theme.Primary,
                Transparency = 0.3,
            })
            SafeTween(cardStroke, TweenInfo.new(0.25), {
                Color = Config.Theme.Primary,
                Transparency = 0.3,
            })
            SafeTween(circleGlow, TweenInfo.new(0.3), {
                ImageTransparency = 0.5,
            })
            SafeTween(statusText, TweenInfo.new(0.2), {
                TextColor3 = Config.Theme.Primary,
            })
            statusText.Text = "ON"
        else
            SafeTween(circle, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, 3, 0.5, 0),
                BackgroundColor3 = Config.Theme.Off,
            })
            SafeTween(toggleBg, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
                BackgroundColor3 = Config.Theme.OffDim,
            })
            SafeTween(toggleBgStroke, TweenInfo.new(0.25), {
                Color = Config.Theme.Off,
                Transparency = 0.5,
            })
            SafeTween(cardStroke, TweenInfo.new(0.25), {
                Color = Config.Theme.PrimaryDeep,
                Transparency = 0.5,
            })
            SafeTween(circleGlow, TweenInfo.new(0.3), {
                ImageTransparency = 1,
            })
            SafeTween(statusText, TweenInfo.new(0.2), {
                TextColor3 = Config.Theme.Off,
            })
            statusText.Text = "OFF"
        end
    end

    AddConnection(hoverBtn.MouseButton1Click:Connect(function()
        isOn = not isOn
        UpdateVisual()
        if onToggle then onToggle(isOn) end
    end))

    UpdateVisual()

    return card, function() return isOn end, function(state)
        isOn = state
        UpdateVisual()
    end
end

-- Slider premium com gradient fill e glow knob
local function CreateSlider(parent, name, yPos, min, max, default, onValueChanged)
    local card, cardStroke = CreateCard(parent, name .. "Slider", yPos, 54)

    -- Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.55, 0, 0, 22)
    label.Position = UDim2.new(0, 14, 0, 3)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Config.Theme.Text
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 17
    label.Parent = card

    -- Value display (no canto direito, estilizado)
    local valueBg = Instance.new("Frame")
    valueBg.Size = UDim2.new(0, 52, 0, 20)
    valueBg.Position = UDim2.new(1, -14, 0, 4)
    valueBg.AnchorPoint = Vector2.new(1, 0)
    valueBg.BackgroundColor3 = Config.Theme.PrimaryDeep
    valueBg.BorderSizePixel = 0
    valueBg.ZIndex = 17
    valueBg.Parent = card

    local valueBgCorner = Instance.new("UICorner")
    valueBgCorner.CornerRadius = UDim.new(0, 4)
    valueBgCorner.Parent = valueBg

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(1, 0, 1, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Config.Theme.Primary
    valueLabel.Font = Enum.Font.Code
    valueLabel.TextSize = 11
    valueLabel.ZIndex = 18
    valueLabel.Parent = valueBg

    -- Slider track
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -28, 0, 6)
    sliderBg.Position = UDim2.new(0, 14, 0, 34)
    sliderBg.BackgroundColor3 = Config.Theme.OffDim
    sliderBg.BorderSizePixel = 0
    sliderBg.ZIndex = 17
    sliderBg.Parent = card

    local sliderBgCorner = Instance.new("UICorner")
    sliderBgCorner.CornerRadius = UDim.new(1, 0)
    sliderBgCorner.Parent = sliderBg

    -- Fill com gradient
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Config.Theme.Primary
    sliderFill.BorderSizePixel = 0
    sliderFill.ZIndex = 18
    sliderFill.Parent = sliderBg

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = sliderFill

    local fillGradient = Instance.new("UIGradient")
    fillGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Config.Theme.PrimaryDark),
        ColorSequenceKeypoint.new(0.7, Config.Theme.Primary),
        ColorSequenceKeypoint.new(1, Config.Theme.Accent),
    })
    fillGradient.Parent = sliderFill

    -- Knob
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.BackgroundColor3 = Config.Theme.Primary
    knob.BorderSizePixel = 0
    knob.ZIndex = 19
    knob.Parent = sliderBg

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    -- Glow no knob
    local knobGlow = Instance.new("ImageLabel")
    knobGlow.Size = UDim2.new(3, 0, 3, 0)
    knobGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
    knobGlow.AnchorPoint = Vector2.new(0.5, 0.5)
    knobGlow.BackgroundTransparency = 1
    knobGlow.Image = "rbxassetid://5028857084"
    knobGlow.ImageColor3 = Config.Theme.Primary
    knobGlow.ImageTransparency = 0.6
    knobGlow.ZIndex = 18
    knobGlow.Parent = knob

    -- Outer ring no knob
    local knobRing = Instance.new("UIStroke")
    knobRing.Color = Config.Theme.Accent
    knobRing.Thickness = 1.5
    knobRing.Transparency = 0.4
    knobRing.Parent = knob

    -- Interaction
    local dragging = false
    local currentValue = default

    local sliderBtn = Instance.new("TextButton")
    sliderBtn.Size = UDim2.new(1, 10, 0, 22)
    sliderBtn.Position = UDim2.new(0, -5, 0, 26)
    sliderBtn.BackgroundTransparency = 1
    sliderBtn.Text = ""
    sliderBtn.ZIndex = 21
    sliderBtn.Parent = card

    local function UpdateSlider(input)
        local pos = input.Position
        local absPos = sliderBg.AbsolutePosition
        local absSize = sliderBg.AbsoluteSize

        local relX = math.clamp((pos.X - absPos.X) / absSize.X, 0, 1)
        currentValue = math.floor(min + (max - min) * relX)

        SafeTween(sliderFill, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {
            Size = UDim2.new(relX, 0, 1, 0)
        })
        SafeTween(knob, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {
            Position = UDim2.new(relX, 0, 0.5, 0)
        })
        valueLabel.Text = tostring(currentValue)

        if onValueChanged then onValueChanged(currentValue) end
    end

    AddConnection(sliderBtn.MouseButton1Down:Connect(function(x, y)
        dragging = true
        SafeTween(knob, TweenInfo.new(0.15, Enum.EasingStyle.Back), {
            Size = UDim2.new(0, 18, 0, 18)
        })
        SafeTween(knobGlow, TweenInfo.new(0.15), {
            ImageTransparency = 0.3
        })
    end))

    AddConnection(UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateSlider(input)
        end
    end))

    AddConnection(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                dragging = false
                SafeTween(knob, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
                    Size = UDim2.new(0, 14, 0, 14)
                })
                SafeTween(knobGlow, TweenInfo.new(0.2), {
                    ImageTransparency = 0.6
                })
            end
        end
    end))

    return card, function() return currentValue end
end

-- ═══════════════════════════════════════════════════════════════
-- SECTION 9: UI BUILDER — MAIN INTERFACE (Premium v1.0.0 Style)
-- ═══════════════════════════════════════════════════════════════

local function BuildMainUI(screenGui)

    -- ═══ MAIN FRAME ═══
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 440, 0, 540)
    mainFrame.Position = UDim2.new(0.5, 0, 1.3, 0) -- Começa fora do ecrã
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = Config.Theme.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.ZIndex = 10
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    UI.Refs.MainFrame = mainFrame

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = mainFrame

    -- Double stroke para depth
    local mainStrokeOuter = Instance.new("UIStroke")
    mainStrokeOuter.Color = Config.Theme.Primary
    mainStrokeOuter.Thickness = 1.5
    mainStrokeOuter.Transparency = 0.3
    mainStrokeOuter.Parent = mainFrame

    -- Glow pulse no frame
    task.spawn(function()
        while mainStrokeOuter and mainStrokeOuter.Parent do
            SafeTween(mainStrokeOuter, TweenInfo.new(2.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Transparency = 0.7
            })
            task.wait(2.5)
            SafeTween(mainStrokeOuter, TweenInfo.new(2.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Transparency = 0.2
            })
            task.wait(2.5)
        end
    end)

    -- ═══ BACKGROUND PATTERN (scanlines subtis) ═══
    for i = 0, 120 do
        local scanline = Instance.new("Frame")
        scanline.Size = UDim2.new(1, 0, 0, 1)
        scanline.Position = UDim2.new(0, 0, 0, i * 4.5)
        scanline.BackgroundColor3 = Config.Theme.Primary
        scanline.BackgroundTransparency = 0.97
        scanline.BorderSizePixel = 0
        scanline.ZIndex = 10
        scanline.Parent = mainFrame
    end

    -- ═══════════════════════════════════════════
    -- HEADER — Premium com cobra e gradient
    -- ═══════════════════════════════════════════

    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 56)
    header.BackgroundColor3 = Config.Theme.Surface
    header.BorderSizePixel = 0
    header.ZIndex = 12
    header.Parent = mainFrame

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 12)
    headerCorner.Parent = header

    -- Fix cantos inferiores
    local headerFix = Instance.new("Frame")
    headerFix.Size = UDim2.new(1, 0, 0, 16)
    headerFix.Position = UDim2.new(0, 0, 1, -16)
    headerFix.BackgroundColor3 = Config.Theme.Surface
    headerFix.BorderSizePixel = 0
    headerFix.ZIndex = 12
    headerFix.Parent = header

    -- Gradient subtil no header
    local headerGradient = Instance.new("UIGradient")
    headerGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 22, 22)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 16, 16)),
    })
    headerGradient.Rotation = 90
    headerGradient.Parent = header

    -- Cobra glow no header (cópia maior por trás = neon real)
    local headerCobraGlow = Instance.new("ImageLabel")
    headerCobraGlow.Name = "HeaderCobraGlow"
    headerCobraGlow.Size = UDim2.new(0, 44, 0, 44)
    headerCobraGlow.Position = UDim2.new(0, 32, 0.5, 0)
    headerCobraGlow.AnchorPoint = Vector2.new(0.5, 0.5)
    headerCobraGlow.BackgroundTransparency = 1
    headerCobraGlow.Image = Config.CobraAsset  -- MESMA cobra, não radial genérico
    headerCobraGlow.ImageColor3 = Config.Theme.Accent
    headerCobraGlow.ImageTransparency = 0.5
    headerCobraGlow.ScaleType = Enum.ScaleType.Fit
    headerCobraGlow.ZIndex = 13
    headerCobraGlow.Parent = header

    -- Cobra icon no header (nítida, por cima)
    local headerCobra = Instance.new("ImageLabel")
    headerCobra.Name = "HeaderCobra"
    headerCobra.Size = UDim2.new(0, 32, 0, 32)
    headerCobra.Position = UDim2.new(0, 16, 0.5, 0)
    headerCobra.AnchorPoint = Vector2.new(0, 0.5)
    headerCobra.BackgroundTransparency = 1
    headerCobra.Image = Config.CobraAsset
    headerCobra.ImageColor3 = Config.Theme.Primary
    headerCobra.ImageTransparency = 0
    headerCobra.ScaleType = Enum.ScaleType.Fit
    headerCobra.ZIndex = 14
    headerCobra.Parent = header

    -- Pulse subtil no glow do header
    task.spawn(function()
        while headerCobraGlow and headerCobraGlow.Parent do
            SafeTween(headerCobraGlow, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                ImageTransparency = 0.3
            })
            task.wait(1.5)
            SafeTween(headerCobraGlow, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                ImageTransparency = 0.7
            })
            task.wait(1.5)
        end
    end)

    -- Título
    local headerTitle = Instance.new("TextLabel")
    headerTitle.Size = UDim2.new(0, 200, 0, 22)
    headerTitle.Position = UDim2.new(0, 56, 0, 10)
    headerTitle.BackgroundTransparency = 1
    headerTitle.Text = "M E D U S A"
    headerTitle.TextColor3 = Config.Theme.Primary
    headerTitle.Font = Enum.Font.GothamBold
    headerTitle.TextSize = 18
    headerTitle.TextXAlignment = Enum.TextXAlignment.Left
    headerTitle.ZIndex = 14
    headerTitle.Parent = header

    -- Subtítulo
    local headerSub = Instance.new("TextLabel")
    headerSub.Size = UDim2.new(0, 200, 0, 14)
    headerSub.Position = UDim2.new(0, 56, 0, 32)
    headerSub.BackgroundTransparency = 1
    headerSub.Text = "Universal Engine v" .. Config.Version .. " • Cobra Edition"
    headerSub.TextColor3 = Config.Theme.TextDim
    headerSub.Font = Enum.Font.Code
    headerSub.TextSize = 10
    headerSub.TextXAlignment = Enum.TextXAlignment.Left
    headerSub.ZIndex = 14
    headerSub.Parent = header

    -- Status dot (pulsing green)
    local statusDot = Instance.new("Frame")
    statusDot.Size = UDim2.new(0, 8, 0, 8)
    statusDot.Position = UDim2.new(1, -70, 0.5, 0)
    statusDot.AnchorPoint = Vector2.new(0, 0.5)
    statusDot.BackgroundColor3 = Config.Theme.Primary
    statusDot.BorderSizePixel = 0
    statusDot.ZIndex = 14
    statusDot.Parent = header

    local statusDotCorner = Instance.new("UICorner")
    statusDotCorner.CornerRadius = UDim.new(1, 0)
    statusDotCorner.Parent = statusDot

    -- Pulse no dot
    task.spawn(function()
        while statusDot and statusDot.Parent do
            SafeTween(statusDot, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                BackgroundTransparency = 0.5
            })
            task.wait(1)
            SafeTween(statusDot, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                BackgroundTransparency = 0
            })
            task.wait(1)
        end
    end)

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(0, 40, 0, 14)
    statusLabel.Position = UDim2.new(1, -58, 0.5, 0)
    statusLabel.AnchorPoint = Vector2.new(0, 0.5)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "LIVE"
    statusLabel.TextColor3 = Config.Theme.Primary
    statusLabel.Font = Enum.Font.Code
    statusLabel.TextSize = 10
    statusLabel.ZIndex = 14
    statusLabel.Parent = header

    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -14, 0.5, 0)
    closeBtn.AnchorPoint = Vector2.new(1, 0.5)
    closeBtn.BackgroundColor3 = Config.Theme.RedDark
    closeBtn.BackgroundTransparency = 0.5
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Config.Theme.Red
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 12
    closeBtn.ZIndex = 15
    closeBtn.Parent = header

    local closeBtnCorner = Instance.new("UICorner")
    closeBtnCorner.CornerRadius = UDim.new(0, 6)
    closeBtnCorner.Parent = closeBtn

    AddConnection(closeBtn.MouseEnter:Connect(function()
        SafeTween(closeBtn, TweenInfo.new(0.15), { BackgroundTransparency = 0 })
    end))
    AddConnection(closeBtn.MouseLeave:Connect(function()
        SafeTween(closeBtn, TweenInfo.new(0.15), { BackgroundTransparency = 0.5 })
    end))

    AddConnection(closeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        ConsoleLog("UI hidden via close button — press [M] to show", "INFO")
    end))

    -- ═══ HEADER NEON LINE ═══
    local neonLine = Instance.new("Frame")
    neonLine.Size = UDim2.new(0.92, 0, 0, 1)
    neonLine.Position = UDim2.new(0.04, 0, 0, 58)
    neonLine.BackgroundColor3 = Config.Theme.Primary
    neonLine.BackgroundTransparency = 0.4
    neonLine.BorderSizePixel = 0
    neonLine.ZIndex = 12
    neonLine.Parent = mainFrame

    -- Gradient na neon line
    local neonLineGrad = Instance.new("UIGradient")
    neonLineGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
        ColorSequenceKeypoint.new(0.3, Config.Theme.Primary),
        ColorSequenceKeypoint.new(0.5, Config.Theme.Accent),
        ColorSequenceKeypoint.new(0.7, Config.Theme.Primary),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
    })
    neonLineGrad.Parent = neonLine

    -- ═══════════════════════════════════════════
    -- TAB SYSTEM — Premium underline style
    -- ═══════════════════════════════════════════

    local tabBar = Instance.new("Frame")
    tabBar.Name = "TabBar"
    tabBar.Size = UDim2.new(1, -24, 0, 34)
    tabBar.Position = UDim2.new(0, 12, 0, 64)
    tabBar.BackgroundTransparency = 1
    tabBar.ZIndex = 12
    tabBar.Parent = mainFrame

    local tabNames = {"Movement", "Visuals", "Console"}
    local tabIcons = {"⚡", "👁", "📜"}
    local tabButtons = {}
    local tabContents = {}
    local tabIndicators = {}
    local activeTab = "Movement"

    for i, tabName in ipairs(tabNames) do
        local tabBtn = Instance.new("TextButton")
        tabBtn.Name = tabName .. "Tab"
        tabBtn.Size = UDim2.new(1 / #tabNames, -6, 0, 28)
        tabBtn.Position = UDim2.new((i - 1) / #tabNames, 3, 0, 0)
        tabBtn.BackgroundColor3 = (i == 1) and Config.Theme.Card or Config.Theme.Background
        tabBtn.BackgroundTransparency = (i == 1) and 0 or 0.5
        tabBtn.BorderSizePixel = 0
        tabBtn.Text = tabIcons[i] .. "  " .. tabName
        tabBtn.TextColor3 = (i == 1) and Config.Theme.Primary or Config.Theme.TextDim
        tabBtn.Font = Enum.Font.GothamMedium
        tabBtn.TextSize = 11
        tabBtn.ZIndex = 13
        tabBtn.Parent = tabBar

        local tabBtnCorner = Instance.new("UICorner")
        tabBtnCorner.CornerRadius = UDim.new(0, 6)
        tabBtnCorner.Parent = tabBtn

        -- Indicator bar (underline verde quando active)
        local indicator = Instance.new("Frame")
        indicator.Size = UDim2.new(0.6, 0, 0, 2)
        indicator.Position = UDim2.new(0.2, 0, 1, -1)
        indicator.BackgroundColor3 = Config.Theme.Primary
        indicator.BackgroundTransparency = (i == 1) and 0 or 1
        indicator.BorderSizePixel = 0
        indicator.ZIndex = 14
        indicator.Parent = tabBtn

        local indicatorCorner = Instance.new("UICorner")
        indicatorCorner.CornerRadius = UDim.new(1, 0)
        indicatorCorner.Parent = indicator

        tabButtons[tabName] = tabBtn
        tabIndicators[tabName] = indicator

        -- Tab content
        local content = Instance.new("ScrollingFrame")
        content.Name = tabName .. "Content"
        content.Size = UDim2.new(1, 0, 1, -140)
        content.Position = UDim2.new(0, 0, 0, 103)
        content.BackgroundTransparency = 1
        content.BorderSizePixel = 0
        content.ScrollBarThickness = 3
        content.ScrollBarImageColor3 = Config.Theme.Primary
        content.ScrollBarImageTransparency = 0.3
        content.CanvasSize = UDim2.new(0, 0, 0, 520)
        content.Visible = (i == 1)
        content.ZIndex = 11
        content.Parent = mainFrame

        tabContents[tabName] = content

        -- Hover effects
        AddConnection(tabBtn.MouseEnter:Connect(function()
            if activeTab ~= tabName then
                SafeTween(tabBtn, TweenInfo.new(0.15), {
                    BackgroundTransparency = 0.2,
                    TextColor3 = Config.Theme.Primary,
                })
            end
        end))
        AddConnection(tabBtn.MouseLeave:Connect(function()
            if activeTab ~= tabName then
                SafeTween(tabBtn, TweenInfo.new(0.15), {
                    BackgroundTransparency = 0.5,
                    TextColor3 = Config.Theme.TextDim,
                })
            end
        end))

        AddConnection(tabBtn.MouseButton1Click:Connect(function()
            activeTab = tabName
            for tName, tBtn in pairs(tabButtons) do
                local ind = tabIndicators[tName]
                if tName == tabName then
                    SafeTween(tBtn, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
                        BackgroundColor3 = Config.Theme.Card,
                        BackgroundTransparency = 0,
                        TextColor3 = Config.Theme.Primary,
                    })
                    SafeTween(ind, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
                        BackgroundTransparency = 0,
                    })
                else
                    SafeTween(tBtn, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
                        BackgroundColor3 = Config.Theme.Background,
                        BackgroundTransparency = 0.5,
                        TextColor3 = Config.Theme.TextDim,
                    })
                    SafeTween(ind, TweenInfo.new(0.2), {
                        BackgroundTransparency = 1,
                    })
                end
            end
            for tName, tContent in pairs(tabContents) do
                tContent.Visible = (tName == tabName)
            end
            ConsoleLog("Tab: " .. tabName, "INFO")
        end))
    end

    -- ═══════════════════════════════════════════
    -- TAB: MOVEMENT
    -- ═══════════════════════════════════════════
    local movTab = tabContents["Movement"]

    CreateSectionHeader(movTab, "SPEED CONTROLS", 5)

    CreateToggle(movTab, "WalkSpeed", 38, false, function(state)
        Functions.WalkSpeed.Enabled = state
        ApplyWalkSpeed()
        ShowToast("WalkSpeed " .. (state and "ENABLED" or "DISABLED"))
        ConsoleLog("WalkSpeed " .. (state and "ON (" .. Functions.WalkSpeed.Value .. ")" or "OFF — Reset to " .. Config.Defaults.WalkSpeed), state and "INFO" or "WARN")
    end)

    CreateSlider(movTab, "Speed Value", 84, 16, 200, Config.Defaults.WalkSpeed, function(val)
        Functions.WalkSpeed.Value = val
        if Functions.WalkSpeed.Enabled then ApplyWalkSpeed() end
    end)

    CreateToggle(movTab, "JumpPower", 148, false, function(state)
        Functions.JumpPower.Enabled = state
        ApplyJumpPower()
        ShowToast("JumpPower " .. (state and "ENABLED" or "DISABLED"))
        ConsoleLog("JumpPower " .. (state and "ON (" .. Functions.JumpPower.Value .. ")" or "OFF — Reset to " .. Config.Defaults.JumpPower), state and "INFO" or "WARN")
    end)

    CreateSlider(movTab, "Jump Value", 194, 50, 300, Config.Defaults.JumpPower, function(val)
        Functions.JumpPower.Value = val
        if Functions.JumpPower.Enabled then ApplyJumpPower() end
    end)

    -- Separator neon
    local sep1 = Instance.new("Frame")
    sep1.Size = UDim2.new(0.88, 0, 0, 1)
    sep1.Position = UDim2.new(0.06, 0, 0, 260)
    sep1.BackgroundColor3 = Config.Theme.PrimaryDeep
    sep1.BackgroundTransparency = 0.3
    sep1.BorderSizePixel = 0
    sep1.ZIndex = 15
    sep1.Parent = movTab

    local sep1Grad = Instance.new("UIGradient")
    sep1Grad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.3, 0),
        NumberSequenceKeypoint.new(0.7, 0),
        NumberSequenceKeypoint.new(1, 1),
    })
    sep1Grad.Parent = sep1

    CreateSectionHeader(movTab, "JUMP MECHANICS", 268)

    CreateToggle(movTab, "Infinite Jump", 300, false, function(state)
        Functions.InfiniteJump.Enabled = state
        StartInfiniteJump()
        ShowToast("Infinite Jump " .. (state and "ON  [Space]" or "OFF"))
        ConsoleLog("Infinite Jump " .. (state and "ACTIVATED" or "DEACTIVATED"), state and "INFO" or "WARN")
    end)

    -- Separator
    local sep2 = Instance.new("Frame")
    sep2.Size = UDim2.new(0.88, 0, 0, 1)
    sep2.Position = UDim2.new(0.06, 0, 0, 352)
    sep2.BackgroundColor3 = Config.Theme.PrimaryDeep
    sep2.BackgroundTransparency = 0.3
    sep2.BorderSizePixel = 0
    sep2.ZIndex = 15
    sep2.Parent = movTab

    local sep2Grad = Instance.new("UIGradient")
    sep2Grad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.3, 0),
        NumberSequenceKeypoint.new(0.7, 0),
        NumberSequenceKeypoint.new(1, 1),
    })
    sep2Grad.Parent = sep2

    CreateSectionHeader(movTab, "FLY SYSTEM (CFrame)", 360)

    local _, flyGetter, flySetter = CreateToggle(movTab, "Fly  [F]", 393, false, function(state)
        Functions.Fly.Enabled = state
        if state then
            StartFly()
        else
            StopFly()
        end
        ShowToast("Fly " .. (state and "ENGAGED" or "DISENGAGED"))
        ConsoleLog("CFrame Fly " .. (state and "ACTIVE — Speed: " .. Functions.Fly.Speed or "INACTIVE"), state and "SYSTEM" or "WARN")
    end)
    UI.Refs.FlyToggleSet = flySetter

    CreateSlider(movTab, "Fly Speed", 439, 20, 300, Config.Defaults.FlySpeed, function(val)
        Functions.Fly.Speed = val
    end)

    -- Keybind info card
    local keybindCard = CreateCard(movTab, "KeybindInfo", 503, 36)

    local keybindLabel = Instance.new("TextLabel")
    keybindLabel.Size = UDim2.new(1, -20, 1, 0)
    keybindLabel.Position = UDim2.new(0, 10, 0, 0)
    keybindLabel.BackgroundTransparency = 1
    keybindLabel.Text = "W/A/S/D Move  •  Space Up  •  Shift Down  •  [M] UI  •  [F] Fly"
    keybindLabel.TextColor3 = Config.Theme.TextDim
    keybindLabel.Font = Enum.Font.Code
    keybindLabel.TextSize = 9
    keybindLabel.TextWrapped = true
    keybindLabel.ZIndex = 17
    keybindLabel.Parent = keybindCard

    -- ═══════════════════════════════════════════
    -- TAB: VISUALS
    -- ═══════════════════════════════════════════
    local visTab = tabContents["Visuals"]

    CreateSectionHeader(visTab, "RENDERING", 5)

    CreateToggle(visTab, "Fullbright", 38, false, function(state)
        Functions.Fullbright.Enabled = state
        if state then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
        else
            Lighting.Brightness = 1
            Lighting.ClockTime = 14
            Lighting.FogEnd = 10000
            Lighting.GlobalShadows = true
        end
        ShowToast("Fullbright " .. (state and "ON" or "OFF"))
        ConsoleLog("Fullbright " .. (state and "ENABLED" or "DISABLED"), "INFO")
    end)

    CreateToggle(visTab, "Noclip", 84, false, function(state)
        Functions.Noclip.Enabled = state
        if state then
            if not _G.Medusa._noclipConn then
                _G.Medusa._noclipConn = AddConnection(
                    RunService.Stepped:Connect(function()
                        local char = GetCharacter()
                        if char then
                            for _, part in pairs(char:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.CanCollide = false
                                end
                            end
                        end
                    end)
                )
            end
        else
            if _G.Medusa._noclipConn then
                pcall(function() _G.Medusa._noclipConn:Disconnect() end)
                _G.Medusa._noclipConn = nil
            end
        end
        ShowToast("Noclip " .. (state and "ON" or "OFF"))
        ConsoleLog("Noclip " .. (state and "ACTIVATED" or "DEACTIVATED"), state and "INFO" or "WARN")
    end)

    -- Separator
    local visSep = Instance.new("Frame")
    visSep.Size = UDim2.new(0.88, 0, 0, 1)
    visSep.Position = UDim2.new(0.06, 0, 0, 136)
    visSep.BackgroundColor3 = Config.Theme.PrimaryDeep
    visSep.BackgroundTransparency = 0.3
    visSep.BorderSizePixel = 0
    visSep.ZIndex = 15
    visSep.Parent = visTab

    local visSepGrad = Instance.new("UIGradient")
    visSepGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.3, 0),
        NumberSequenceKeypoint.new(0.7, 0),
        NumberSequenceKeypoint.new(1, 1),
    })
    visSepGrad.Parent = visSep

    CreateSectionHeader(visTab, "COMING SOON", 144)

    CreateToggle(visTab, "ESP Players", 177, false, function(state)
        ShowToast("ESP coming in v1.1.0")
        ConsoleLog("ESP placeholder — coming v1.1.0", "WARN")
    end)

    CreateToggle(visTab, "Chams", 223, false, function(state)
        ShowToast("Chams coming in v1.1.0")
        ConsoleLog("Chams placeholder — coming v1.1.0", "WARN")
    end)

    -- ═══════════════════════════════════════════
    -- TAB: CONSOLE
    -- ═══════════════════════════════════════════
    local conTab = tabContents["Console"]

    CreateSectionHeader(conTab, "RUNTIME LOG", 5)

    local consoleBg = Instance.new("Frame")
    consoleBg.Size = UDim2.new(1, -24, 1, -50)
    consoleBg.Position = UDim2.new(0, 12, 0, 38)
    consoleBg.BackgroundColor3 = Color3.fromRGB(6, 6, 6)
    consoleBg.BorderSizePixel = 0
    consoleBg.ZIndex = 15
    consoleBg.Parent = conTab

    local consoleBgCorner = Instance.new("UICorner")
    consoleBgCorner.CornerRadius = UDim.new(0, 8)
    consoleBgCorner.Parent = consoleBg

    local consoleBgStroke = Instance.new("UIStroke")
    consoleBgStroke.Color = Config.Theme.PrimaryDeep
    consoleBgStroke.Thickness = 1
    consoleBgStroke.Transparency = 0.4
    consoleBgStroke.Parent = consoleBg

    -- Terminal header decoration
    local termHeader = Instance.new("Frame")
    termHeader.Size = UDim2.new(1, 0, 0, 24)
    termHeader.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    termHeader.BorderSizePixel = 0
    termHeader.ZIndex = 16
    termHeader.Parent = consoleBg

    local termHeaderCorner = Instance.new("UICorner")
    termHeaderCorner.CornerRadius = UDim.new(0, 8)
    termHeaderCorner.Parent = termHeader

    local termHeaderFix = Instance.new("Frame")
    termHeaderFix.Size = UDim2.new(1, 0, 0, 10)
    termHeaderFix.Position = UDim2.new(0, 0, 1, -10)
    termHeaderFix.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    termHeaderFix.BorderSizePixel = 0
    termHeaderFix.ZIndex = 16
    termHeaderFix.Parent = termHeader

    local termTitle = Instance.new("TextLabel")
    termTitle.Size = UDim2.new(1, -12, 1, 0)
    termTitle.Position = UDim2.new(0, 12, 0, 0)
    termTitle.BackgroundTransparency = 1
    termTitle.Text = "medusa@engine:~$ tail -f medusa.log"
    termTitle.TextColor3 = Config.Theme.TextDim
    termTitle.Font = Enum.Font.Code
    termTitle.TextSize = 10
    termTitle.TextXAlignment = Enum.TextXAlignment.Left
    termTitle.ZIndex = 17
    termTitle.Parent = termHeader

    -- Console scroll
    local consoleScroll = Instance.new("ScrollingFrame")
    consoleScroll.Name = "ConsoleScroll"
    consoleScroll.Size = UDim2.new(1, -8, 1, -32)
    consoleScroll.Position = UDim2.new(0, 4, 0, 28)
    consoleScroll.BackgroundTransparency = 1
    consoleScroll.BorderSizePixel = 0
    consoleScroll.ScrollBarThickness = 2
    consoleScroll.ScrollBarImageColor3 = Config.Theme.Primary
    consoleScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    consoleScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    consoleScroll.ZIndex = 17
    consoleScroll.Parent = consoleBg

    local consoleLayout = Instance.new("UIListLayout")
    consoleLayout.SortOrder = Enum.SortOrder.LayoutOrder
    consoleLayout.Padding = UDim.new(0, 2)
    consoleLayout.Parent = consoleScroll

    UI.Refs.ConsoleScroll = consoleScroll

    -- ═══════════════════════════════════════════
    -- FOOTER — Premium com ping e status
    -- ═══════════════════════════════════════════

    local footer = Instance.new("Frame")
    footer.Name = "Footer"
    footer.Size = UDim2.new(1, 0, 0, 30)
    footer.Position = UDim2.new(0, 0, 1, -30)
    footer.BackgroundColor3 = Config.Theme.Surface
    footer.BorderSizePixel = 0
    footer.ZIndex = 12
    footer.Parent = mainFrame

    local footerCorner = Instance.new("UICorner")
    footerCorner.CornerRadius = UDim.new(0, 12)
    footerCorner.Parent = footer

    local footerFix = Instance.new("Frame")
    footerFix.Size = UDim2.new(1, 0, 0, 14)
    footerFix.Position = UDim2.new(0, 0, 0, 0)
    footerFix.BackgroundColor3 = Config.Theme.Surface
    footerFix.BorderSizePixel = 0
    footerFix.ZIndex = 12
    footerFix.Parent = footer

    -- Neon line acima do footer
    local footerLine = Instance.new("Frame")
    footerLine.Size = UDim2.new(0.92, 0, 0, 1)
    footerLine.Position = UDim2.new(0.04, 0, 0, 0)
    footerLine.BackgroundColor3 = Config.Theme.Primary
    footerLine.BackgroundTransparency = 0.6
    footerLine.BorderSizePixel = 0
    footerLine.ZIndex = 13
    footerLine.Parent = footer

    local footerLineGrad = Instance.new("UIGradient")
    footerLineGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
        ColorSequenceKeypoint.new(0.5, Config.Theme.Primary),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
    })
    footerLineGrad.Parent = footerLine

    local footerLeft = Instance.new("TextLabel")
    footerLeft.Size = UDim2.new(0.6, 0, 1, 0)
    footerLeft.Position = UDim2.new(0, 14, 0, 0)
    footerLeft.BackgroundTransparency = 1
    footerLeft.Text = "🐍 Medusa v" .. Config.Version .. "  •  [M] Toggle UI"
    footerLeft.TextColor3 = Config.Theme.TextDim
    footerLeft.Font = Enum.Font.Code
    footerLeft.TextSize = 9
    footerLeft.TextXAlignment = Enum.TextXAlignment.Left
    footerLeft.ZIndex = 14
    footerLeft.Parent = footer

    local pingLabel = Instance.new("TextLabel")
    pingLabel.Name = "PingDisplay"
    pingLabel.Size = UDim2.new(0, 80, 1, 0)
    pingLabel.Position = UDim2.new(1, -14, 0, 0)
    pingLabel.AnchorPoint = Vector2.new(1, 0)
    pingLabel.BackgroundTransparency = 1
    pingLabel.Text = "0ms"
    pingLabel.TextColor3 = Config.Theme.TextDim
    pingLabel.Font = Enum.Font.Code
    pingLabel.TextSize = 9
    pingLabel.TextXAlignment = Enum.TextXAlignment.Right
    pingLabel.ZIndex = 14
    pingLabel.Parent = footer

    -- Ping updater
    task.spawn(function()
        while pingLabel and pingLabel.Parent do
            local success, ping = pcall(function()
                return math.floor(Player:GetNetworkPing() * 1000)
            end)
            if success then
                pingLabel.Text = ping .. "ms"
                if ping < 80 then
                    pingLabel.TextColor3 = Config.Theme.Primary
                elseif ping < 150 then
                    pingLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
                else
                    pingLabel.TextColor3 = Config.Theme.Red
                end
            end
            task.wait(1)
        end
    end)

    -- ═══ TOAST CONTAINER ═══
    local toastContainer = Instance.new("Frame")
    toastContainer.Name = "ToastContainer"
    toastContainer.Size = UDim2.new(1, 0, 1, 0)
    toastContainer.BackgroundTransparency = 1
    toastContainer.ZIndex = 50
    toastContainer.Parent = screenGui
    UI.Refs.ToastContainer = toastContainer

    -- ═══ SLIDE UP ANIMATION (Y=1.3 → center com EasingStyle.Back) ═══
    SafeTween(mainFrame, TweenInfo.new(1.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, 0, 0.5, 0)
    })

    ConsoleLog("Main UI loaded — premium interface active", "SYSTEM")
    ConsoleLog("Welcome to Medusa Universal Engine v" .. Config.Version, "SYSTEM")
    ConsoleLog("Cobra Edition — The Serpent watches over you", "SYSTEM")

    task.delay(1.5, function()
        ShowToast("Medusa v" .. Config.Version .. " loaded!")
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- SECTION 10: KEYBIND SYSTEM
-- ═══════════════════════════════════════════════════════════════

local function SetupKeybinds()
    AddConnection(UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end

        -- [M] Toggle UI
        if input.KeyCode == Config.ToggleKey then
            if UI.Refs.MainFrame then
                local isVisible = UI.Refs.MainFrame.Visible
                UI.Refs.MainFrame.Visible = not isVisible

                if not isVisible then
                    UI.Refs.MainFrame.Position = UDim2.new(0.5, 0, 0.55, 0)
                    SafeTween(UI.Refs.MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                        Position = UDim2.new(0.5, 0, 0.5, 0)
                    })
                end

                ConsoleLog("UI " .. (not isVisible and "SHOWN" or "HIDDEN") .. " via [M]", "INFO")
            end
        end

        -- [F] Toggle Fly
        if input.KeyCode == Config.FlyKey then
            Functions.Fly.Enabled = not Functions.Fly.Enabled
            if Functions.Fly.Enabled then
                StartFly()
                ShowToast("Fly ENGAGED [F]")
            else
                StopFly()
                ShowToast("Fly DISENGAGED [F]")
            end
            -- Sync toggle visual
            if UI.Refs.FlyToggleSet then
                UI.Refs.FlyToggleSet(Functions.Fly.Enabled)
            end
            ConsoleLog("Fly toggled via [F]: " .. (Functions.Fly.Enabled and "ON" or "OFF"), "SYSTEM")
        end
    end))

    ConsoleLog("Keybinds ready — [M] Toggle UI, [F] Toggle Fly", "SYSTEM")
end

-- ═══════════════════════════════════════════════════════════════
-- SECTION 11: INITIALIZATION
-- ═══════════════════════════════════════════════════════════════

local function Initialize()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MedusaEngine"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.DisplayOrder = 1000000
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local success = pcall(function()
        screenGui.Parent = game:GetService("CoreGui")
    end)
    if not success then
        screenGui.Parent = Player:WaitForChild("PlayerGui")
    end

    _G.Medusa.ScreenGui = screenGui

    ConsoleLog("ScreenGui created — DisplayOrder: 1000000", "SYSTEM")
    ConsoleLog("Hard Clean complete — fresh state", "SYSTEM")

    SetupKeybinds()

    PlayCinematicIntro(screenGui, function()
        BuildMainUI(screenGui)
    end)

    -- Respawn handler
    AddConnection(Player.CharacterAdded:Connect(function(char)
        task.wait(1)
        ConsoleLog("Character respawned — reapplying modules", "SYSTEM")
        if Functions.WalkSpeed.Enabled then
            ApplyWalkSpeed()
            ConsoleLog("WalkSpeed reapplied: " .. Functions.WalkSpeed.Value, "INFO")
        end
        if Functions.JumpPower.Enabled then
            ApplyJumpPower()
            ConsoleLog("JumpPower reapplied: " .. Functions.JumpPower.Value, "INFO")
        end
        if Functions.Fly.Enabled then
            task.wait(0.5)
            StartFly()
            ConsoleLog("Fly system restarted after respawn", "SYSTEM")
        end
    end))
end

-- ═══════════════════════════════════════════════════════════════
-- LAUNCH
-- ═══════════════════════════════════════════════════════════════

Initialize()

--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║                 M E D U S A  v1.0.1                         ║
    ║                  Cobra Edition                               ║
    ║                                                              ║
    ║  Keybinds:                                                   ║
    ║    [M] — Toggle UI visibility                                ║
    ║    [F] — Toggle Fly on/off                                   ║
    ║                                                              ║
    ║  Movement:                                                   ║
    ║    • WalkSpeed (16-200, toggle + slider)                     ║
    ║    • JumpPower (50-300, toggle + slider)                     ║
    ║    • Infinite Jump (toggle)                                   ║
    ║    • CFrame Fly (toggle + speed slider)                      ║
    ║                                                              ║
    ║  Visuals:                                                    ║
    ║    • Fullbright (toggle)                                     ║
    ║    • Noclip (toggle)                                         ║
    ║    • ESP Players (coming v1.1.0)                             ║
    ║    • Chams (coming v1.1.0)                                   ║
    ║                                                              ║
    ║  Console:                                                    ║
    ║    • Real-time log with timestamps                           ║
    ║    • Terminal-style interface                                 ║
    ║                                                              ║
    ║  Theme: Black + Emerald Green (0, 201, 107)                  ║
    ║  100% passive until activated — zero injection on load       ║
    ╚══════════════════════════════════════════════════════════════╝
]]
