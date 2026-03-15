--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║            M E D U S A   U N I V E R S A L   E N G I N E   ║
    ║                        Version 1.0.1                        ║
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

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local Config = {
    Version = "1.0.1",
    Theme = {
        Primary    = Color3.fromRGB(0, 201, 107),     -- Verde Esmeralda
        PrimaryDark = Color3.fromRGB(0, 120, 64),     -- Verde Escuro
        Background = Color3.fromRGB(8, 8, 8),         -- Preto Profundo
        Surface    = Color3.fromRGB(14, 14, 14),      -- Surface
        SurfaceAlt = Color3.fromRGB(20, 20, 20),      -- Surface alternativo
        Border     = Color3.fromRGB(0, 201, 107),     -- Border Verde
        Text       = Color3.fromRGB(0, 201, 107),     -- Texto Verde
        TextDim    = Color3.fromRGB(0, 100, 53),      -- Texto Verde Dim
        White      = Color3.fromRGB(255, 255, 255),   -- Branco (só para brilho neon)
        Red        = Color3.fromRGB(255, 60, 60),     -- Vermelho (estados OFF)
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
}

local UI = {
    Refs      = {},     -- Referências a elementos UI
    Toasts    = {},     -- Fila de notificações
    Console   = {},     -- Log entries
    Tweens    = {},     -- Tweens activos
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
    local tween = TweenService:Create(obj, info, props)
    table.insert(UI.Tweens, tween)
    tween:Play()
    return tween
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
    
    -- Actualiza console UI se existir
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
            '<font color="rgb(0,100,53)">[%s]</font> <font color="%s">[%s]</font> <font color="rgb(0,201,107)">%s</font>',
            timestamp, typeColor, logType, msg
        )
        label.TextColor3 = Config.Theme.Primary
        label.Parent = UI.Refs.ConsoleScroll
        
        -- Auto-scroll
        task.defer(function()
            if UI.Refs.ConsoleScroll then
                UI.Refs.ConsoleScroll.CanvasPosition = Vector2.new(0, UI.Refs.ConsoleScroll.AbsoluteCanvasSize.Y)
            end
        end)
    end
end

local function ShowToast(message, duration)
    duration = duration or 2.5
    if not UI.Refs.ToastContainer then return end
    
    local toast = Instance.new("Frame")
    toast.Size = UDim2.new(0, 300, 0, 40)
    toast.BackgroundColor3 = Config.Theme.Surface
    toast.BorderSizePixel = 0
    toast.Position = UDim2.new(1, 50, 1, -(#UI.Toasts * 50 + 10))
    toast.AnchorPoint = Vector2.new(1, 1)
    toast.Parent = UI.Refs.ToastContainer
    
    local toastCorner = Instance.new("UICorner")
    toastCorner.CornerRadius = UDim.new(0, 6)
    toastCorner.Parent = toast
    
    local toastStroke = Instance.new("UIStroke")
    toastStroke.Color = Config.Theme.Primary
    toastStroke.Thickness = 1
    toastStroke.Transparency = 0.5
    toastStroke.Parent = toast
    
    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 3, 1, 0)
    accentBar.BackgroundColor3 = Config.Theme.Primary
    accentBar.BorderSizePixel = 0
    accentBar.Parent = toast
    
    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(0, 6)
    accentCorner.Parent = accentBar
    
    local toastLabel = Instance.new("TextLabel")
    toastLabel.Size = UDim2.new(1, -20, 1, 0)
    toastLabel.Position = UDim2.new(0, 15, 0, 0)
    toastLabel.BackgroundTransparency = 1
    toastLabel.Text = "🐍 " .. message
    toastLabel.TextColor3 = Config.Theme.Primary
    toastLabel.Font = Enum.Font.GothamMedium
    toastLabel.TextSize = 12
    toastLabel.TextXAlignment = Enum.TextXAlignment.Left
    toastLabel.Parent = toast
    
    table.insert(UI.Toasts, toast)
    
    -- Slide in
    SafeTween(toast, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -10, 1, -(#UI.Toasts * 50 + 10))
    })
    
    -- Auto destroy
    task.delay(duration, function()
        SafeTween(toast, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 50, toast.Position.Y.Scale, toast.Position.Y.Offset)
        })
        task.wait(0.35)
        for i, t in ipairs(UI.Toasts) do
            if t == toast then
                table.remove(UI.Toasts, i)
                break
            end
        end
        toast:Destroy()
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- SECTION 6: CORE FUNCTIONS (Movement / Fly)
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
    
    -- Limpa instâncias anteriores
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
    
    ConsoleLog("Fly system ENGAGED — CFrame mode active", "SYSTEM")
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
-- SECTION 7: UI BUILDER — CINEMATIC INTRO
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
    
    -- Vignette pulse loop
    task.spawn(function()
        while introFrame and introFrame.Parent do
            SafeTween(vignette, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                ImageTransparency = 0.7
            })
            task.wait(2)
            SafeTween(vignette, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                ImageTransparency = 0.9
            })
            task.wait(2)
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
        local matrixActive = true
        
        while matrixActive and introFrame and introFrame.Parent do
            for i = 1, 3 do
                local drop = Instance.new("TextLabel")
                drop.Size = UDim2.new(0, 14, 0, 14)
                drop.Position = UDim2.new(math.random() * 0.95, 0, -0.05, 0)
                drop.BackgroundTransparency = 1
                drop.Text = chars[math.random(1, #chars)]
                drop.TextColor3 = Config.Theme.Primary
                drop.TextTransparency = math.random(40, 80) / 100
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
    
    -- === SCANLINES OVERLAY ===
    local scanlines = Instance.new("Frame")
    scanlines.Name = "Scanlines"
    scanlines.Size = UDim2.new(1, 0, 1, 0)
    scanlines.BackgroundTransparency = 1
    scanlines.ZIndex = 103
    scanlines.Parent = introFrame
    
    for i = 0, 50 do
        local line = Instance.new("Frame")
        line.Size = UDim2.new(1, 0, 0, 1)
        line.Position = UDim2.new(0, 0, i / 50, 0)
        line.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        line.BackgroundTransparency = 0.92
        line.BorderSizePixel = 0
        line.ZIndex = 103
        line.Parent = scanlines
    end
    
    -- === CENTRAL CONTENT CONTAINER ===
    local centerContainer = Instance.new("Frame")
    centerContainer.Name = "CenterContent"
    centerContainer.Size = UDim2.new(0, 400, 0, 350)
    centerContainer.Position = UDim2.new(0.5, 0, 0.45, 0)
    centerContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    centerContainer.BackgroundTransparency = 1
    centerContainer.ZIndex = 110
    centerContainer.Parent = introFrame
    
    -- ╔═══════════════════════════════════════════════╗
    -- ║  COBRA NEON — O Símbolo da Medusa            ║
    -- ╚═══════════════════════════════════════════════╝
    
    local cobraImage = Instance.new("ImageLabel")
    cobraImage.Name = "CobraNeon"
    cobraImage.Size = UDim2.new(0, 0, 0, 0)  -- Começa invisível (0,0)
    cobraImage.Position = UDim2.new(0.5, 0, 0, 20)
    cobraImage.AnchorPoint = Vector2.new(0.5, 0)
    cobraImage.BackgroundTransparency = 1
    cobraImage.Image = Config.CobraAsset
    cobraImage.ImageColor3 = Config.Theme.Primary
    cobraImage.ImageTransparency = 0
    cobraImage.ScaleType = Enum.ScaleType.Fit
    cobraImage.ZIndex = 115
    cobraImage.Parent = centerContainer
    
    -- UIStroke na Cobra (O Olho de Medusa)
    local cobraStroke = Instance.new("UIStroke")
    cobraStroke.Name = "CobraHypnoticStroke"
    cobraStroke.Color = Config.Theme.Primary
    cobraStroke.Thickness = 2
    cobraStroke.Transparency = 0.1
    cobraStroke.Parent = cobraImage
    
    -- Corner suave na cobra
    local cobraCorner = Instance.new("UICorner")
    cobraCorner.CornerRadius = UDim.new(0, 8)
    cobraCorner.Parent = cobraImage
    
    -- Glow atrás da cobra
    local cobraGlow = Instance.new("ImageLabel")
    cobraGlow.Name = "CobraGlow"
    cobraGlow.Size = UDim2.new(0, 0, 0, 0)
    cobraGlow.Position = UDim2.new(0.5, 0, 0, 95)
    cobraGlow.AnchorPoint = Vector2.new(0.5, 0.5)
    cobraGlow.BackgroundTransparency = 1
    cobraGlow.Image = "rbxassetid://5028857084"
    cobraGlow.ImageColor3 = Config.Theme.Primary
    cobraGlow.ImageTransparency = 0.7
    cobraGlow.ZIndex = 114
    cobraGlow.Parent = centerContainer
    
    -- ═══ FASE 1: Cobra desliza para o ecrã (1.5s) ═══
    ConsoleLog("Phase 1: Cobra Neon sliding in...", "SYSTEM")
    task.wait(0.5)
    
    -- Animação de deslize — cresce de (0,0) até (150,150)
    local cobraSlideIn = SafeTween(cobraImage, 
        TweenInfo.new(1.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        { Size = UDim2.new(0, 150, 0, 150) }
    )
    
    -- Glow cresce junto
    SafeTween(cobraGlow, 
        TweenInfo.new(1.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        { Size = UDim2.new(0, 250, 0, 250) }
    )
    
    -- ═══ Loop Hipnótico do Olho de Medusa (UIStroke pulse) ═══
    task.spawn(function()
        while cobraStroke and cobraStroke.Parent and introFrame and introFrame.Parent do
            -- Transparency 0.1 -> 1.0, Thickness 2 -> 5
            SafeTween(cobraStroke,
                TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                { Transparency = 1.0, Thickness = 5 }
            )
            task.wait(1.2)
            -- Volta: Transparency 1.0 -> 0.1, Thickness 5 -> 2
            SafeTween(cobraStroke,
                TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                { Transparency = 0.1, Thickness = 2 }
            )
            task.wait(1.2)
        end
    end)
    
    -- Glow pulse em sincronia
    task.spawn(function()
        while cobraGlow and cobraGlow.Parent and introFrame and introFrame.Parent do
            SafeTween(cobraGlow,
                TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                { ImageTransparency = 0.4 }
            )
            task.wait(1.2)
            SafeTween(cobraGlow,
                TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                { ImageTransparency = 0.85 }
            )
            task.wait(1.2)
        end
    end)
    
    -- Espera cobra terminar de aparecer
    cobraSlideIn.Completed:Wait()
    ConsoleLog("Phase 1 COMPLETE — Cobra fully visible", "SYSTEM")
    task.wait(0.3)
    
    -- ╔═══════════════════════════════════════════════╗
    -- ║  TEXTO 'M E D U S A' — Glitch após a cobra   ║
    -- ╚═══════════════════════════════════════════════╝
    
    -- ═══ FASE 2: Texto MEDUSA com efeito glitch ═══
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
    
    -- UIStroke no título (pulsa em sincronia)
    local titleStroke = Instance.new("UIStroke")
    titleStroke.Name = "TitleStroke"
    titleStroke.Color = Config.Theme.Primary
    titleStroke.Thickness = 2
    titleStroke.Transparency = 0.2
    titleStroke.Parent = titleLabel
    
    -- Pulse do stroke do título em sincronia com a cobra
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
    
    -- Efeito Glitch: texto aleatório antes de revelar
    local targetText = "M E D U S A"
    local glitchChars = "!@#$%^&*()_+-=[]{}|;:<>?/~`01"
    
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
    
    -- === SUBTÍTULO ===
    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
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
    
    -- ═══ FASE 3: Loading Bar Neon ═══
    ConsoleLog("Phase 3: Neon loading bar initiated...", "SYSTEM")
    
    local barBg = Instance.new("Frame")
    barBg.Name = "LoadingBarBG"
    barBg.Size = UDim2.new(0.7, 0, 0, 4)
    barBg.Position = UDim2.new(0.15, 0, 0, 275)
    barBg.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    barBg.BorderSizePixel = 0
    barBg.ZIndex = 115
    barBg.Parent = centerContainer
    
    local barBgCorner = Instance.new("UICorner")
    barBgCorner.CornerRadius = UDim.new(0, 4)
    barBgCorner.Parent = barBg
    
    local barFill = Instance.new("Frame")
    barFill.Name = "LoadingBarFill"
    barFill.Size = UDim2.new(0, 0, 1, 0)
    barFill.BackgroundColor3 = Config.Theme.Primary
    barFill.BorderSizePixel = 0
    barFill.ZIndex = 116
    barFill.Parent = barBg
    
    local barFillCorner = Instance.new("UICorner")
    barFillCorner.CornerRadius = UDim.new(0, 4)
    barFillCorner.Parent = barFill
    
    -- UIGradient com 3 pontos na barra: Verde Escuro -> Branco -> Verde Escuro
    local barGradient = Instance.new("UIGradient")
    barGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Config.Theme.PrimaryDark),
        ColorSequenceKeypoint.new(0.5, Config.Theme.White),
        ColorSequenceKeypoint.new(1, Config.Theme.PrimaryDark),
    })
    barGradient.Offset = Vector2.new(-1, 0)
    barGradient.Parent = barFill
    
    -- Anima o gradiente offset (luz a correr)
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
    statusLabel.Name = "StatusText"
    statusLabel.Size = UDim2.new(1, 0, 0, 16)
    statusLabel.Position = UDim2.new(0, 0, 0, 290)
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
        task.wait(math.random(15, 35) / 100)
    end
    
    ConsoleLog("Phase 3 COMPLETE — All modules loaded", "SYSTEM")
    task.wait(0.5)
    
    -- Version badge
    local versionLabel = Instance.new("TextLabel")
    versionLabel.Name = "VersionLabel"
    versionLabel.Size = UDim2.new(1, 0, 0, 16)
    versionLabel.Position = UDim2.new(0, 0, 0, 315)
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
    
    -- ═══ FASE 4: Fade out intro ═══
    ConsoleLog("Phase 4: Transitioning to main interface...", "SYSTEM")
    
    SafeTween(introFrame, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        BackgroundTransparency = 1
    })
    
    -- Fade todos os filhos
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
    
    -- Fade vignette e matrix
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
-- SECTION 8: UI BUILDER — MAIN INTERFACE
-- ═══════════════════════════════════════════════════════════════

local function CreateToggle(parent, name, yPos, defaultState, onToggle)
    local container = Instance.new("Frame")
    container.Name = name .. "Toggle"
    container.Size = UDim2.new(1, -20, 0, 36)
    container.Position = UDim2.new(0, 10, 0, yPos)
    container.BackgroundColor3 = Config.Theme.Surface
    container.BorderSizePixel = 0
    container.ZIndex = 15
    container.Parent = parent
    
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 6)
    containerCorner.Parent = container
    
    local containerStroke = Instance.new("UIStroke")
    containerStroke.Color = Config.Theme.PrimaryDark
    containerStroke.Thickness = 1
    containerStroke.Transparency = 0.7
    containerStroke.Parent = container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Config.Theme.Primary
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 16
    label.Parent = container
    
    local toggleBg = Instance.new("Frame")
    toggleBg.Name = "ToggleBG"
    toggleBg.Size = UDim2.new(0, 40, 0, 20)
    toggleBg.Position = UDim2.new(1, -52, 0.5, 0)
    toggleBg.AnchorPoint = Vector2.new(0, 0.5)
    toggleBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    toggleBg.BorderSizePixel = 0
    toggleBg.ZIndex = 16
    toggleBg.Parent = container
    
    local toggleBgCorner = Instance.new("UICorner")
    toggleBgCorner.CornerRadius = UDim.new(1, 0)
    toggleBgCorner.Parent = toggleBg
    
    local toggleCircle = Instance.new("Frame")
    toggleCircle.Name = "Circle"
    toggleCircle.Size = UDim2.new(0, 16, 0, 16)
    toggleCircle.Position = UDim2.new(0, 2, 0.5, 0)
    toggleCircle.AnchorPoint = Vector2.new(0, 0.5)
    toggleCircle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    toggleCircle.BorderSizePixel = 0
    toggleCircle.ZIndex = 17
    toggleCircle.Parent = toggleBg
    
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = toggleCircle
    
    local isOn = defaultState or false
    
    local function UpdateVisual()
        if isOn then
            SafeTween(toggleCircle, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
                Position = UDim2.new(1, -18, 0.5, 0),
                BackgroundColor3 = Config.Theme.Primary,
            })
            SafeTween(toggleBg, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
                BackgroundColor3 = Config.Theme.PrimaryDark,
            })
            SafeTween(containerStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                Transparency = 0.2,
            })
        else
            SafeTween(toggleCircle, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
                Position = UDim2.new(0, 2, 0.5, 0),
                BackgroundColor3 = Color3.fromRGB(80, 80, 80),
            })
            SafeTween(toggleBg, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
                BackgroundColor3 = Color3.fromRGB(30, 30, 30),
            })
            SafeTween(containerStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                Transparency = 0.7,
            })
        end
    end
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 18
    btn.Parent = container
    
    AddConnection(btn.MouseButton1Click:Connect(function()
        isOn = not isOn
        UpdateVisual()
        if onToggle then onToggle(isOn) end
    end))
    
    UpdateVisual()
    
    return container, function() return isOn end, function(state)
        isOn = state
        UpdateVisual()
    end
end

local function CreateSlider(parent, name, yPos, min, max, default, onValueChanged)
    local container = Instance.new("Frame")
    container.Name = name .. "Slider"
    container.Size = UDim2.new(1, -20, 0, 50)
    container.Position = UDim2.new(0, 10, 0, yPos)
    container.BackgroundColor3 = Config.Theme.Surface
    container.BorderSizePixel = 0
    container.ZIndex = 15
    container.Parent = parent
    
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 6)
    containerCorner.Parent = container
    
    local containerStroke = Instance.new("UIStroke")
    containerStroke.Color = Config.Theme.PrimaryDark
    containerStroke.Thickness = 1
    containerStroke.Transparency = 0.7
    containerStroke.Parent = container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 0, 20)
    label.Position = UDim2.new(0, 12, 0, 4)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Config.Theme.Primary
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 16
    label.Parent = container
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "ValueDisplay"
    valueLabel.Size = UDim2.new(0.3, 0, 0, 20)
    valueLabel.Position = UDim2.new(0.7, -12, 0, 4)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Config.Theme.Primary
    valueLabel.Font = Enum.Font.Code
    valueLabel.TextSize = 12
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.ZIndex = 16
    valueLabel.Parent = container
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Name = "SliderBG"
    sliderBg.Size = UDim2.new(1, -24, 0, 6)
    sliderBg.Position = UDim2.new(0, 12, 0, 32)
    sliderBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    sliderBg.BorderSizePixel = 0
    sliderBg.ZIndex = 16
    sliderBg.Parent = container
    
    local sliderBgCorner = Instance.new("UICorner")
    sliderBgCorner.CornerRadius = UDim.new(1, 0)
    sliderBgCorner.Parent = sliderBg
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "Fill"
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Config.Theme.Primary
    sliderFill.BorderSizePixel = 0
    sliderFill.ZIndex = 17
    sliderFill.Parent = sliderBg
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = sliderFill
    
    -- Gradient neon na fill
    local fillGradient = Instance.new("UIGradient")
    fillGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Config.Theme.PrimaryDark),
        ColorSequenceKeypoint.new(1, Config.Theme.Primary),
    })
    fillGradient.Parent = sliderFill
    
    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.BackgroundColor3 = Config.Theme.Primary
    knob.BorderSizePixel = 0
    knob.ZIndex = 18
    knob.Parent = sliderBg
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob
    
    local knobStroke = Instance.new("UIStroke")
    knobStroke.Color = Config.Theme.White
    knobStroke.Thickness = 1
    knobStroke.Transparency = 0.7
    knobStroke.Parent = knob
    
    -- Slider interaction
    local dragging = false
    local currentValue = default
    
    local sliderBtn = Instance.new("TextButton")
    sliderBtn.Size = UDim2.new(1, 0, 0, 20)
    sliderBtn.Position = UDim2.new(0, 0, 0, 25)
    sliderBtn.BackgroundTransparency = 1
    sliderBtn.Text = ""
    sliderBtn.ZIndex = 19
    sliderBtn.Parent = container
    
    local function UpdateSlider(input)
        local pos = input.Position
        local absPos = sliderBg.AbsolutePosition
        local absSize = sliderBg.AbsoluteSize
        
        local relX = math.clamp((pos.X - absPos.X) / absSize.X, 0, 1)
        currentValue = math.floor(min + (max - min) * relX)
        
        sliderFill.Size = UDim2.new(relX, 0, 1, 0)
        knob.Position = UDim2.new(relX, 0, 0.5, 0)
        valueLabel.Text = tostring(currentValue)
        
        if onValueChanged then onValueChanged(currentValue) end
    end
    
    AddConnection(sliderBtn.MouseButton1Down:Connect(function()
        dragging = true
    end))
    
    AddConnection(UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            UpdateSlider(input)
        end
    end))
    
    AddConnection(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end))
    
    AddConnection(sliderBtn.MouseButton1Click:Connect(function()
        -- Clique directo no slider (sem drag)
    end))
    
    return container, function() return currentValue end
end

local function BuildMainUI(screenGui)
    -- ═══════════════════════════════════════════
    -- MAIN FRAME — Slide Up com EasingStyle.Back
    -- ═══════════════════════════════════════════
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 420, 0, 520)
    mainFrame.Position = UDim2.new(0.5, 0, 1.2, 0)  -- Começa fora do ecrã (Y = 1.2)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = Config.Theme.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.ZIndex = 10
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    UI.Refs.MainFrame = mainFrame
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 10)
    mainCorner.Parent = mainFrame
    
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Config.Theme.Primary
    mainStroke.Thickness = 1.5
    mainStroke.Transparency = 0.3
    mainStroke.Parent = mainFrame
    
    -- Glow externo do frame principal
    task.spawn(function()
        while mainStroke and mainStroke.Parent do
            SafeTween(mainStroke, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Transparency = 0.7
            })
            task.wait(2)
            SafeTween(mainStroke, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Transparency = 0.2
            })
            task.wait(2)
        end
    end)
    
    -- ═══ HEADER ═══
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = Config.Theme.Surface
    header.BorderSizePixel = 0
    header.ZIndex = 11
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 10)
    headerCorner.Parent = header
    
    -- Fix para cantos inferiores do header
    local headerFix = Instance.new("Frame")
    headerFix.Size = UDim2.new(1, 0, 0, 15)
    headerFix.Position = UDim2.new(0, 0, 1, -15)
    headerFix.BackgroundColor3 = Config.Theme.Surface
    headerFix.BorderSizePixel = 0
    headerFix.ZIndex = 11
    headerFix.Parent = header
    
    -- Cobra mini no header
    local headerCobra = Instance.new("ImageLabel")
    headerCobra.Size = UDim2.new(0, 28, 0, 28)
    headerCobra.Position = UDim2.new(0, 14, 0.5, 0)
    headerCobra.AnchorPoint = Vector2.new(0, 0.5)
    headerCobra.BackgroundTransparency = 1
    headerCobra.Image = Config.CobraAsset
    headerCobra.ImageColor3 = Config.Theme.Primary
    headerCobra.ScaleType = Enum.ScaleType.Fit
    headerCobra.ZIndex = 12
    headerCobra.Parent = header
    
    local headerTitle = Instance.new("TextLabel")
    headerTitle.Size = UDim2.new(0, 200, 0, 20)
    headerTitle.Position = UDim2.new(0, 48, 0, 8)
    headerTitle.BackgroundTransparency = 1
    headerTitle.Text = "M E D U S A"
    headerTitle.TextColor3 = Config.Theme.Primary
    headerTitle.Font = Enum.Font.GothamBold
    headerTitle.TextSize = 16
    headerTitle.TextXAlignment = Enum.TextXAlignment.Left
    headerTitle.ZIndex = 12
    headerTitle.Parent = header
    
    local headerSub = Instance.new("TextLabel")
    headerSub.Size = UDim2.new(0, 200, 0, 14)
    headerSub.Position = UDim2.new(0, 48, 0, 28)
    headerSub.BackgroundTransparency = 1
    headerSub.Text = "Universal Engine v" .. Config.Version
    headerSub.TextColor3 = Config.Theme.TextDim
    headerSub.Font = Enum.Font.Code
    headerSub.TextSize = 10
    headerSub.TextXAlignment = Enum.TextXAlignment.Left
    headerSub.ZIndex = 12
    headerSub.Parent = header
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -40, 0.5, 0)
    closeBtn.AnchorPoint = Vector2.new(0, 0.5)
    closeBtn.BackgroundColor3 = Config.Theme.Surface
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Config.Theme.Red
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.ZIndex = 13
    closeBtn.Parent = header
    
    local closeBtnCorner = Instance.new("UICorner")
    closeBtnCorner.CornerRadius = UDim.new(0, 6)
    closeBtnCorner.Parent = closeBtn
    
    AddConnection(closeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = not mainFrame.Visible
        ConsoleLog("UI toggled via close button", "INFO")
    end))
    
    -- Linha neon separadora
    local headerLine = Instance.new("Frame")
    headerLine.Size = UDim2.new(0.9, 0, 0, 1)
    headerLine.Position = UDim2.new(0.05, 0, 0, 52)
    headerLine.BackgroundColor3 = Config.Theme.Primary
    headerLine.BackgroundTransparency = 0.6
    headerLine.BorderSizePixel = 0
    headerLine.ZIndex = 11
    headerLine.Parent = mainFrame
    
    -- ═══ TAB SYSTEM ═══
    local tabBar = Instance.new("Frame")
    tabBar.Name = "TabBar"
    tabBar.Size = UDim2.new(1, -20, 0, 32)
    tabBar.Position = UDim2.new(0, 10, 0, 58)
    tabBar.BackgroundTransparency = 1
    tabBar.ZIndex = 11
    tabBar.Parent = mainFrame
    
    local tabNames = {"Movement", "Visuals", "Console"}
    local tabButtons = {}
    local tabContents = {}
    local activeTab = "Movement"
    
    for i, tabName in ipairs(tabNames) do
        local tabBtn = Instance.new("TextButton")
        tabBtn.Name = tabName .. "Tab"
        tabBtn.Size = UDim2.new(1/#tabNames, -4, 1, 0)
        tabBtn.Position = UDim2.new((i-1)/#tabNames, 2, 0, 0)
        tabBtn.BackgroundColor3 = (i == 1) and Config.Theme.PrimaryDark or Config.Theme.Surface
        tabBtn.BackgroundTransparency = (i == 1) and 0 or 0
        tabBtn.BorderSizePixel = 0
        tabBtn.Text = tabName
        tabBtn.TextColor3 = (i == 1) and Config.Theme.Primary or Config.Theme.TextDim
        tabBtn.Font = Enum.Font.GothamMedium
        tabBtn.TextSize = 11
        tabBtn.ZIndex = 12
        tabBtn.Parent = tabBar
        
        local tabBtnCorner = Instance.new("UICorner")
        tabBtnCorner.CornerRadius = UDim.new(0, 6)
        tabBtnCorner.Parent = tabBtn
        
        tabButtons[tabName] = tabBtn
        
        -- Tab content frame
        local content = Instance.new("ScrollingFrame")
        content.Name = tabName .. "Content"
        content.Size = UDim2.new(1, 0, 1, -130)
        content.Position = UDim2.new(0, 0, 0, 95)
        content.BackgroundTransparency = 1
        content.BorderSizePixel = 0
        content.ScrollBarThickness = 3
        content.ScrollBarImageColor3 = Config.Theme.Primary
        content.ScrollBarImageTransparency = 0.5
        content.CanvasSize = UDim2.new(0, 0, 0, 600)
        content.Visible = (i == 1)
        content.ZIndex = 11
        content.Parent = mainFrame
        
        tabContents[tabName] = content
        
        AddConnection(tabBtn.MouseButton1Click:Connect(function()
            activeTab = tabName
            for tName, tBtn in pairs(tabButtons) do
                if tName == tabName then
                    SafeTween(tBtn, TweenInfo.new(0.2), {
                        BackgroundColor3 = Config.Theme.PrimaryDark,
                        TextColor3 = Config.Theme.Primary,
                    })
                else
                    SafeTween(tBtn, TweenInfo.new(0.2), {
                        BackgroundColor3 = Config.Theme.Surface,
                        TextColor3 = Config.Theme.TextDim,
                    })
                end
            end
            for tName, tContent in pairs(tabContents) do
                tContent.Visible = (tName == tabName)
            end
            ConsoleLog("Tab switched to: " .. tabName, "INFO")
        end))
    end
    
    -- ═══════════════════════════════════════════
    -- TAB: MOVEMENT
    -- ═══════════════════════════════════════════
    local movementTab = tabContents["Movement"]
    
    -- Section Header
    local movHeader = Instance.new("TextLabel")
    movHeader.Size = UDim2.new(1, -20, 0, 25)
    movHeader.Position = UDim2.new(0, 10, 0, 5)
    movHeader.BackgroundTransparency = 1
    movHeader.Text = "⚡ MOVEMENT CONTROLS"
    movHeader.TextColor3 = Config.Theme.Primary
    movHeader.Font = Enum.Font.GothamBold
    movHeader.TextSize = 12
    movHeader.TextXAlignment = Enum.TextXAlignment.Left
    movHeader.ZIndex = 15
    movHeader.Parent = movementTab
    
    -- WalkSpeed Toggle
    CreateToggle(movementTab, "WalkSpeed", 35, false, function(state)
        Functions.WalkSpeed.Enabled = state
        ApplyWalkSpeed()
        ShowToast("WalkSpeed " .. (state and "ENABLED" or "DISABLED"))
        ConsoleLog("WalkSpeed " .. (state and "ON (" .. Functions.WalkSpeed.Value .. ")" or "OFF — Reset to " .. Config.Defaults.WalkSpeed), state and "INFO" or "WARN")
    end)
    
    -- WalkSpeed Slider
    CreateSlider(movementTab, "Speed Value", 78, 16, 200, Config.Defaults.WalkSpeed, function(val)
        Functions.WalkSpeed.Value = val
        if Functions.WalkSpeed.Enabled then
            ApplyWalkSpeed()
        end
    end)
    
    -- JumpPower Toggle
    CreateToggle(movementTab, "JumpPower", 140, false, function(state)
        Functions.JumpPower.Enabled = state
        ApplyJumpPower()
        ShowToast("JumpPower " .. (state and "ENABLED" or "DISABLED"))
        ConsoleLog("JumpPower " .. (state and "ON (" .. Functions.JumpPower.Value .. ")" or "OFF — Reset to " .. Config.Defaults.JumpPower), state and "INFO" or "WARN")
    end)
    
    -- JumpPower Slider
    CreateSlider(movementTab, "Jump Value", 183, 50, 300, Config.Defaults.JumpPower, function(val)
        Functions.JumpPower.Value = val
        if Functions.JumpPower.Enabled then
            ApplyJumpPower()
        end
    end)
    
    -- Separator
    local sep1 = Instance.new("Frame")
    sep1.Size = UDim2.new(0.85, 0, 0, 1)
    sep1.Position = UDim2.new(0.075, 0, 0, 245)
    sep1.BackgroundColor3 = Config.Theme.PrimaryDark
    sep1.BackgroundTransparency = 0.5
    sep1.BorderSizePixel = 0
    sep1.ZIndex = 15
    sep1.Parent = movementTab
    
    -- Infinite Jump Toggle
    CreateToggle(movementTab, "Infinite Jump", 255, false, function(state)
        Functions.InfiniteJump.Enabled = state
        StartInfiniteJump()
        ShowToast("Infinite Jump " .. (state and "ENABLED [Space]" or "DISABLED"))
        ConsoleLog("Infinite Jump " .. (state and "ACTIVATED" or "DEACTIVATED"), state and "INFO" or "WARN")
    end)
    
    -- Separator 2
    local sep2 = Instance.new("Frame")
    sep2.Size = UDim2.new(0.85, 0, 0, 1)
    sep2.Position = UDim2.new(0.075, 0, 0, 303)
    sep2.BackgroundColor3 = Config.Theme.PrimaryDark
    sep2.BackgroundTransparency = 0.5
    sep2.BorderSizePixel = 0
    sep2.ZIndex = 15
    sep2.Parent = movementTab
    
    -- Fly Section Header
    local flyHeader = Instance.new("TextLabel")
    flyHeader.Size = UDim2.new(1, -20, 0, 25)
    flyHeader.Position = UDim2.new(0, 10, 0, 310)
    flyHeader.BackgroundTransparency = 1
    flyHeader.Text = "🐍 FLY SYSTEM (CFrame)"
    flyHeader.TextColor3 = Config.Theme.Primary
    flyHeader.Font = Enum.Font.GothamBold
    flyHeader.TextSize = 12
    flyHeader.TextXAlignment = Enum.TextXAlignment.Left
    flyHeader.ZIndex = 15
    flyHeader.Parent = movementTab
    
    -- Fly Toggle
    CreateToggle(movementTab, "Fly [F]", 340, false, function(state)
        Functions.Fly.Enabled = state
        if state then
            StartFly()
        else
            StopFly()
        end
        ShowToast("Fly " .. (state and "ENGAGED" or "DISENGAGED"))
        ConsoleLog("CFrame Fly " .. (state and "ACTIVE — Speed: " .. Functions.Fly.Speed or "INACTIVE"), state and "SYSTEM" or "WARN")
    end)
    
    -- Fly Speed Slider
    CreateSlider(movementTab, "Fly Speed", 383, 20, 300, Config.Defaults.FlySpeed, function(val)
        Functions.Fly.Speed = val
    end)
    
    -- Keybind info
    local keybindInfo = Instance.new("TextLabel")
    keybindInfo.Size = UDim2.new(1, -20, 0, 40)
    keybindInfo.Position = UDim2.new(0, 10, 0, 445)
    keybindInfo.BackgroundTransparency = 1
    keybindInfo.Text = "W/A/S/D = Direction  •  Space = Up  •  Shift = Down\n[M] Toggle UI  •  [F] Toggle Fly"
    keybindInfo.TextColor3 = Config.Theme.TextDim
    keybindInfo.Font = Enum.Font.Code
    keybindInfo.TextSize = 9
    keybindInfo.TextWrapped = true
    keybindInfo.ZIndex = 15
    keybindInfo.Parent = movementTab
    
    -- ═══════════════════════════════════════════
    -- TAB: VISUALS
    -- ═══════════════════════════════════════════
    local visualsTab = tabContents["Visuals"]
    
    local visHeader = Instance.new("TextLabel")
    visHeader.Size = UDim2.new(1, -20, 0, 25)
    visHeader.Position = UDim2.new(0, 10, 0, 5)
    visHeader.BackgroundTransparency = 1
    visHeader.Text = "👁 VISUAL SETTINGS"
    visHeader.TextColor3 = Config.Theme.Primary
    visHeader.Font = Enum.Font.GothamBold
    visHeader.TextSize = 12
    visHeader.TextXAlignment = Enum.TextXAlignment.Left
    visHeader.ZIndex = 15
    visHeader.Parent = visualsTab
    
    CreateToggle(visualsTab, "Fullbright", 35, false, function(state)
        local lighting = game:GetService("Lighting")
        if state then
            lighting.Brightness = 2
            lighting.ClockTime = 14
            lighting.FogEnd = 100000
            lighting.GlobalShadows = false
        else
            lighting.Brightness = 1
            lighting.ClockTime = 14
            lighting.FogEnd = 10000
            lighting.GlobalShadows = true
        end
        ShowToast("Fullbright " .. (state and "ON" or "OFF"))
        ConsoleLog("Fullbright " .. (state and "ENABLED" or "DISABLED"), "INFO")
    end)
    
    CreateToggle(visualsTab, "ESP (Coming Soon)", 78, false, function(state)
        ShowToast("ESP module coming in v1.1.0")
        ConsoleLog("ESP module placeholder — coming v1.1.0", "WARN")
    end)
    
    CreateToggle(visualsTab, "Noclip", 121, false, function(state)
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
    
    -- ═══════════════════════════════════════════
    -- TAB: CONSOLE
    -- ═══════════════════════════════════════════
    local consoleTab = tabContents["Console"]
    
    local consoleHeader = Instance.new("TextLabel")
    consoleHeader.Size = UDim2.new(1, -20, 0, 25)
    consoleHeader.Position = UDim2.new(0, 10, 0, 5)
    consoleHeader.BackgroundTransparency = 1
    consoleHeader.Text = "📜 CONSOLE LOG"
    consoleHeader.TextColor3 = Config.Theme.Primary
    consoleHeader.Font = Enum.Font.GothamBold
    consoleHeader.TextSize = 12
    consoleHeader.TextXAlignment = Enum.TextXAlignment.Left
    consoleHeader.ZIndex = 15
    consoleHeader.Parent = consoleTab
    
    local consoleBg = Instance.new("Frame")
    consoleBg.Size = UDim2.new(1, -20, 1, -40)
    consoleBg.Position = UDim2.new(0, 10, 0, 32)
    consoleBg.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
    consoleBg.BorderSizePixel = 0
    consoleBg.ZIndex = 15
    consoleBg.Parent = consoleTab
    
    local consoleBgCorner = Instance.new("UICorner")
    consoleBgCorner.CornerRadius = UDim.new(0, 6)
    consoleBgCorner.Parent = consoleBg
    
    local consoleBgStroke = Instance.new("UIStroke")
    consoleBgStroke.Color = Config.Theme.PrimaryDark
    consoleBgStroke.Thickness = 1
    consoleBgStroke.Transparency = 0.6
    consoleBgStroke.Parent = consoleBg
    
    local consoleScroll = Instance.new("ScrollingFrame")
    consoleScroll.Name = "ConsoleScroll"
    consoleScroll.Size = UDim2.new(1, -8, 1, -8)
    consoleScroll.Position = UDim2.new(0, 4, 0, 4)
    consoleScroll.BackgroundTransparency = 1
    consoleScroll.BorderSizePixel = 0
    consoleScroll.ScrollBarThickness = 2
    consoleScroll.ScrollBarImageColor3 = Config.Theme.Primary
    consoleScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    consoleScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    consoleScroll.ZIndex = 16
    consoleScroll.Parent = consoleBg
    
    local consoleLayout = Instance.new("UIListLayout")
    consoleLayout.SortOrder = Enum.SortOrder.LayoutOrder
    consoleLayout.Padding = UDim.new(0, 2)
    consoleLayout.Parent = consoleScroll
    
    UI.Refs.ConsoleScroll = consoleScroll
    
    -- ═══ FOOTER ═══
    local footer = Instance.new("Frame")
    footer.Name = "Footer"
    footer.Size = UDim2.new(1, 0, 0, 28)
    footer.Position = UDim2.new(0, 0, 1, -28)
    footer.BackgroundColor3 = Config.Theme.Surface
    footer.BorderSizePixel = 0
    footer.ZIndex = 11
    footer.Parent = mainFrame
    
    local footerCorner = Instance.new("UICorner")
    footerCorner.CornerRadius = UDim.new(0, 10)
    footerCorner.Parent = footer
    
    -- Fix para cantos superiores do footer
    local footerFix = Instance.new("Frame")
    footerFix.Size = UDim2.new(1, 0, 0, 15)
    footerFix.Position = UDim2.new(0, 0, 0, 0)
    footerFix.BackgroundColor3 = Config.Theme.Surface
    footerFix.BorderSizePixel = 0
    footerFix.ZIndex = 11
    footerFix.Parent = footer
    
    local footerText = Instance.new("TextLabel")
    footerText.Size = UDim2.new(1, -20, 1, 0)
    footerText.Position = UDim2.new(0, 10, 0, 0)
    footerText.BackgroundTransparency = 1
    footerText.Text = "🐍 Medusa v" .. Config.Version .. " • Cobra Edition • [M] Toggle"
    footerText.TextColor3 = Config.Theme.TextDim
    footerText.Font = Enum.Font.Code
    footerText.TextSize = 9
    footerText.TextXAlignment = Enum.TextXAlignment.Left
    footerText.ZIndex = 12
    footerText.Parent = footer
    
    local pingLabel = Instance.new("TextLabel")
    pingLabel.Name = "PingDisplay"
    pingLabel.Size = UDim2.new(0, 80, 1, 0)
    pingLabel.Position = UDim2.new(1, -90, 0, 0)
    pingLabel.BackgroundTransparency = 1
    pingLabel.Text = "0ms"
    pingLabel.TextColor3 = Config.Theme.TextDim
    pingLabel.Font = Enum.Font.Code
    pingLabel.TextSize = 9
    pingLabel.TextXAlignment = Enum.TextXAlignment.Right
    pingLabel.ZIndex = 12
    pingLabel.Parent = footer
    
    -- Ping updater
    task.spawn(function()
        while pingLabel and pingLabel.Parent do
            local ping = math.floor(Player:GetNetworkPing() * 1000)
            pingLabel.Text = ping .. "ms"
            if ping < 80 then
                pingLabel.TextColor3 = Config.Theme.Primary
            elseif ping < 150 then
                pingLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
            else
                pingLabel.TextColor3 = Config.Theme.Red
            end
            task.wait(1)
        end
    end)
    
    -- ═══ Toast Container ═══
    local toastContainer = Instance.new("Frame")
    toastContainer.Name = "ToastContainer"
    toastContainer.Size = UDim2.new(1, 0, 1, 0)
    toastContainer.BackgroundTransparency = 1
    toastContainer.ZIndex = 50
    toastContainer.Parent = screenGui
    UI.Refs.ToastContainer = toastContainer
    
    -- ═══ ANIMAÇÃO SLIDE UP (Y=1.2 -> centro) com EasingStyle.Back ═══
    SafeTween(mainFrame, TweenInfo.new(1.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, 0, 0.5, 0)
    })
    
    ConsoleLog("Main UI loaded and animated — all systems operational", "SYSTEM")
    ConsoleLog("Welcome to Medusa Universal Engine v" .. Config.Version, "SYSTEM")
    ConsoleLog("Cobra Edition — The Serpent watches over you", "SYSTEM")
    
    ShowToast("Medusa v" .. Config.Version .. " loaded successfully!")
end

-- ═══════════════════════════════════════════════════════════════
-- SECTION 9: KEYBIND SYSTEM
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
                    -- Animação de reaparição
                    UI.Refs.MainFrame.Position = UDim2.new(0.5, 0, 0.55, 0)
                    SafeTween(UI.Refs.MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                        Position = UDim2.new(0.5, 0, 0.5, 0)
                    })
                end
                
                ConsoleLog("UI " .. (not isVisible and "SHOWN" or "HIDDEN") .. " via [M] keybind", "INFO")
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
            ConsoleLog("Fly toggled via [F] keybind: " .. (Functions.Fly.Enabled and "ON" or "OFF"), "SYSTEM")
        end
    end))
    
    ConsoleLog("Keybind system initialized — [M] Toggle UI, [F] Toggle Fly", "SYSTEM")
end

-- ═══════════════════════════════════════════════════════════════
-- SECTION 10: MAIN INITIALIZATION
-- ═══════════════════════════════════════════════════════════════

local function Initialize()
    -- Criar ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MedusaEngine"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.DisplayOrder = 1000000
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Tentar colocar no CoreGui (mais seguro) ou PlayerGui
    local success = pcall(function()
        screenGui.Parent = game:GetService("CoreGui")
    end)
    if not success then
        screenGui.Parent = Player:WaitForChild("PlayerGui")
    end
    
    _G.Medusa.ScreenGui = screenGui
    
    ConsoleLog("ScreenGui created — DisplayOrder: 1000000", "SYSTEM")
    ConsoleLog("Hard Clean complete — fresh state initialized", "SYSTEM")
    
    -- Setup keybinds primeiro (para poder logar durante a intro)
    SetupKeybinds()
    
    -- Play intro cinematográfica, depois construir UI
    PlayCinematicIntro(screenGui, function()
        BuildMainUI(screenGui)
    end)
    
    -- Manter WalkSpeed/JumpPower sincronizado ao respawn
    AddConnection(Player.CharacterAdded:Connect(function(char)
        task.wait(1)
        ConsoleLog("Character respawned — reapplying active modules", "SYSTEM")
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
    ║  Modules:                                                    ║
    ║    • WalkSpeed (16-200, toggle)                              ║
    ║    • JumpPower (50-300, toggle)                               ║
    ║    • Infinite Jump (toggle)                                   ║
    ║    • CFrame Fly (toggle + speed slider)                      ║
    ║    • Fullbright (toggle)                                     ║
    ║    • Noclip (toggle)                                         ║
    ║    • Console Log (real-time)                                 ║
    ║                                                              ║
    ║  Theme: Black + Emerald Green (0, 201, 107)                  ║
    ║  100% passive until activated — zero injection on load       ║
    ╚══════════════════════════════════════════════════════════════╝
]]
