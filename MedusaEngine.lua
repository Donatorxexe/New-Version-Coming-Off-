--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║          🐍 MEDUSA UNIVERSAL ENGINE v1.0.1 🐍               ║
    ║          Cobra Edition — Emoji Neon Build                    ║
    ║          Theme: Black + Emerald Green (0, 201, 107)          ║
    ╚══════════════════════════════════════════════════════════════╝
    
    Sections:
      1. Hard Clean
      2. Services & Config
      3. State & Functions
      4. Utilities
      5. Core Functions (WalkSpeed, JumpPower, InfJump, Fly, Fullbright, Noclip)
      6. Cinematic Intro (Cobra Emoji Neon + Glitch + Neon Bar)
      7. Main UI Builder (Premium v1.0.0 style)
      8. Keybinds
      9. Initialize
--]]

-- ════════════════════════════════════════════
-- 1. HARD CLEAN
-- ════════════════════════════════════════════
if _G.Medusa then
    pcall(function()
        if _G.Medusa.Connections then
            for _, conn in pairs(_G.Medusa.Connections) do
                pcall(function() conn:Disconnect() end)
            end
        end
        if _G.Medusa.ScreenGui then
            pcall(function() _G.Medusa.ScreenGui:Destroy() end)
        end
    end)
    _G.Medusa = nil
end

-- ════════════════════════════════════════════
-- 2. SERVICES & CONFIG
-- ════════════════════════════════════════════
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")

local Player = Players.LocalPlayer

local Config = {
    Version = "1.0.1",
    BuildTag = "Cobra Edition",
    
    -- Theme
    Primary = Color3.fromRGB(0, 201, 107),       -- Emerald Green
    PrimaryDark = Color3.fromRGB(0, 140, 75),     -- Dark Emerald
    Accent = Color3.fromRGB(0, 255, 136),         -- Bright Neon Green
    Background = Color3.fromRGB(12, 12, 12),      -- Near Black
    Surface = Color3.fromRGB(18, 18, 18),         -- Card Surface
    SurfaceHover = Color3.fromRGB(24, 24, 24),    -- Card Hover
    Border = Color3.fromRGB(35, 35, 35),          -- Subtle Border
    TextPrimary = Color3.fromRGB(230, 230, 230),  -- Main Text
    TextSecondary = Color3.fromRGB(120, 120, 120), -- Dim Text
    
    -- Defaults
    DefaultWalkSpeed = 16,
    DefaultJumpPower = 50,
    MaxWalkSpeed = 200,
    MaxJumpPower = 300,
    DefaultFlySpeed = 80,
    
    -- Keybinds
    ToggleKey = Enum.KeyCode.M,
    FlyKey = Enum.KeyCode.F,
    
    -- UI
    MainSize = UDim2.new(0, 480, 0, 520),
    CornerRadius = UDim.new(0, 10),
}

-- ════════════════════════════════════════════
-- 3. STATE & FUNCTIONS
-- ════════════════════════════════════════════
local State = {
    WalkSpeedEnabled = false,
    WalkSpeedValue = Config.DefaultWalkSpeed,
    JumpPowerEnabled = false,
    JumpPowerValue = Config.DefaultJumpPower,
    InfiniteJumpEnabled = false,
    FlyEnabled = false,
    FlySpeed = Config.DefaultFlySpeed,
    FullbrightEnabled = false,
    NoclipEnabled = false,
    UIVisible = true,
}

local Connections = {}
local ConsoleMessages = {}
local ActiveTab = "Movement"

-- ════════════════════════════════════════════
-- 4. UTILITIES
-- ════════════════════════════════════════════
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

local function SafeTween(instance, tweenInfo, properties)
    local success, err = pcall(function()
        local tween = TweenService:Create(instance, tweenInfo, properties)
        tween:Play()
        return tween
    end)
end

local function ConsoleLog(message, msgType)
    msgType = msgType or "INFO"
    local timestamp = os.date("%H:%M:%S")
    local entry = {
        Time = timestamp,
        Type = msgType,
        Message = message
    }
    table.insert(ConsoleMessages, entry)
    -- Keep last 50 messages
    if #ConsoleMessages > 50 then
        table.remove(ConsoleMessages, 1)
    end
end

-- ════════════════════════════════════════════
-- 5. CORE FUNCTIONS
-- ════════════════════════════════════════════
local Functions = {}

function Functions.SetWalkSpeed(enabled, value)
    State.WalkSpeedEnabled = enabled
    if value then State.WalkSpeedValue = value end
    local hum = GetHumanoid()
    if hum then
        if enabled then
            hum.WalkSpeed = State.WalkSpeedValue
            ConsoleLog("WalkSpeed SET → " .. State.WalkSpeedValue, "EXEC")
        else
            hum.WalkSpeed = Config.DefaultWalkSpeed
            ConsoleLog("WalkSpeed RESET → " .. Config.DefaultWalkSpeed, "EXEC")
        end
    end
end

function Functions.SetJumpPower(enabled, value)
    State.JumpPowerEnabled = enabled
    if value then State.JumpPowerValue = value end
    local hum = GetHumanoid()
    if hum then
        hum.UseJumpPower = true
        if enabled then
            hum.JumpPower = State.JumpPowerValue
            ConsoleLog("JumpPower SET → " .. State.JumpPowerValue, "EXEC")
        else
            hum.JumpPower = Config.DefaultJumpPower
            ConsoleLog("JumpPower RESET → " .. Config.DefaultJumpPower, "EXEC")
        end
    end
end

function Functions.SetInfiniteJump(enabled)
    State.InfiniteJumpEnabled = enabled
    if enabled then
        ConsoleLog("Infinite Jump ENABLED", "EXEC")
    else
        ConsoleLog("Infinite Jump DISABLED", "EXEC")
    end
end

function Functions.SetFly(enabled)
    State.FlyEnabled = enabled
    local char = GetCharacter()
    local rootPart = GetRootPart()
    local hum = GetHumanoid()
    
    if not rootPart or not hum then return end
    
    if enabled then
        -- Create flight bodies
        local bv = rootPart:FindFirstChild("MedusaFlyVelocity")
        if not bv then
            bv = Instance.new("BodyVelocity")
            bv.Name = "MedusaFlyVelocity"
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.Parent = rootPart
        end
        
        local bg = rootPart:FindFirstChild("MedusaFlyGyro")
        if not bg then
            bg = Instance.new("BodyGyro")
            bg.Name = "MedusaFlyGyro"
            bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            bg.D = 200
            bg.P = 10000
            bg.Parent = rootPart
        end
        
        -- Disconnect old fly connection
        if Connections["FlyLoop"] then
            Connections["FlyLoop"]:Disconnect()
        end
        
        Connections["FlyLoop"] = RunService.Heartbeat:Connect(function()
            if not State.FlyEnabled then return end
            local camera = workspace.CurrentCamera
            local moveDir = Vector3.new(0, 0, 0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDir = moveDir + camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDir = moveDir - camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDir = moveDir - camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDir = moveDir + camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveDir = moveDir + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                moveDir = moveDir - Vector3.new(0, 1, 0)
            end
            
            local bv2 = rootPart:FindFirstChild("MedusaFlyVelocity")
            local bg2 = rootPart:FindFirstChild("MedusaFlyGyro")
            if bv2 then
                if moveDir.Magnitude > 0 then
                    bv2.Velocity = moveDir.Unit * State.FlySpeed
                else
                    bv2.Velocity = Vector3.new(0, 0, 0)
                end
            end
            if bg2 then
                bg2.CFrame = camera.CFrame
            end
        end)
        
        ConsoleLog("Fly ENABLED — Speed: " .. State.FlySpeed, "EXEC")
    else
        -- Remove flight bodies
        if Connections["FlyLoop"] then
            Connections["FlyLoop"]:Disconnect()
            Connections["FlyLoop"] = nil
        end
        local bv = rootPart:FindFirstChild("MedusaFlyVelocity")
        if bv then bv:Destroy() end
        local bg = rootPart:FindFirstChild("MedusaFlyGyro")
        if bg then bg:Destroy() end
        
        ConsoleLog("Fly DISABLED", "EXEC")
    end
end

function Functions.SetFullbright(enabled)
    State.FullbrightEnabled = enabled
    if enabled then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(178, 178, 178)
        ConsoleLog("Fullbright ENABLED", "EXEC")
    else
        Lighting.Brightness = 1
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = true
        Lighting.Ambient = Color3.fromRGB(0, 0, 0)
        ConsoleLog("Fullbright DISABLED", "EXEC")
    end
end

function Functions.SetNoclip(enabled)
    State.NoclipEnabled = enabled
    if enabled then
        if Connections["NoclipLoop"] then
            Connections["NoclipLoop"]:Disconnect()
        end
        Connections["NoclipLoop"] = RunService.Stepped:Connect(function()
            if not State.NoclipEnabled then return end
            local char = GetCharacter()
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
        ConsoleLog("Noclip ENABLED", "EXEC")
    else
        if Connections["NoclipLoop"] then
            Connections["NoclipLoop"]:Disconnect()
            Connections["NoclipLoop"] = nil
        end
        ConsoleLog("Noclip DISABLED", "EXEC")
    end
end

-- ════════════════════════════════════════════
-- 6. CINEMATIC INTRO  🐍
-- ════════════════════════════════════════════
local ScreenGui, MainFrame

local function PlayCinematicIntro(callback)
    -- === Create ScreenGui ===
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MedusaEngine"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.DisplayOrder = 1000000
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
    
    -- === Black Background ===
    local introBg = Instance.new("Frame")
    introBg.Name = "IntroBg"
    introBg.Size = UDim2.new(1, 0, 1, 0)
    introBg.Position = UDim2.new(0, 0, 0, 0)
    introBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    introBg.BackgroundTransparency = 0
    introBg.BorderSizePixel = 0
    introBg.ZIndex = 100
    introBg.Parent = ScreenGui
    
    -- === Scanlines Overlay ===
    local scanlines = Instance.new("Frame")
    scanlines.Name = "Scanlines"
    scanlines.Size = UDim2.new(1, 0, 1, 0)
    scanlines.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    scanlines.BackgroundTransparency = 0.92
    scanlines.ZIndex = 101
    scanlines.Parent = introBg
    
    -- === Vignette Frame ===
    local vignette = Instance.new("Frame")
    vignette.Name = "Vignette"
    vignette.Size = UDim2.new(1.2, 0, 1.2, 0)
    vignette.Position = UDim2.new(-0.1, 0, -0.1, 0)
    vignette.BackgroundColor3 = Config.Primary
    vignette.BackgroundTransparency = 0.95
    vignette.ZIndex = 102
    vignette.Parent = introBg
    
    local vignetteCorner = Instance.new("UICorner")
    vignetteCorner.CornerRadius = UDim.new(0.5, 0)
    vignetteCorner.Parent = vignette
    
    -- Vignette pulse
    spawn(function()
        while introBg and introBg.Parent do
            SafeTween(vignette, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                BackgroundTransparency = 0.88
            })
            wait(2)
            SafeTween(vignette, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                BackgroundTransparency = 0.96
            })
            wait(2)
        end
    end)
    
    -- === Matrix Rain (0s and 1s) ===
    spawn(function()
        for i = 1, 40 do
            local matrixChar = Instance.new("TextLabel")
            matrixChar.Name = "Matrix_" .. i
            matrixChar.Size = UDim2.new(0, 14, 0, 14)
            matrixChar.Position = UDim2.new(math.random() * 0.95, 0, -0.05, 0)
            matrixChar.BackgroundTransparency = 1
            matrixChar.Text = tostring(math.random(0, 1))
            matrixChar.TextColor3 = Config.Primary
            matrixChar.TextTransparency = math.random() * 0.5 + 0.3
            matrixChar.TextSize = math.random(10, 16)
            matrixChar.Font = Enum.Font.Code
            matrixChar.ZIndex = 103
            matrixChar.Parent = introBg
            
            spawn(function()
                local duration = math.random(30, 80) / 10
                local startX = math.random() * 0.95
                SafeTween(matrixChar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
                    Position = UDim2.new(startX, 0, 1.1, 0)
                })
                wait(duration)
                if matrixChar and matrixChar.Parent then
                    matrixChar:Destroy()
                end
            end)
            wait(0.15)
        end
    end)
    
    -- === Center Container ===
    local centerContainer = Instance.new("Frame")
    centerContainer.Name = "CenterContainer"
    centerContainer.Size = UDim2.new(0, 300, 0, 300)
    centerContainer.Position = UDim2.new(0.5, -150, 0.5, -150)
    centerContainer.BackgroundTransparency = 1
    centerContainer.ZIndex = 110
    centerContainer.Parent = introBg
    
    -- ╔════════════════════════════════════════╗
    -- ║  🐍 COBRA EMOJI — NEON GLOW SYSTEM    ║
    -- ╚════════════════════════════════════════╝
    
    -- Glow Layer (slightly larger copy behind, pulsing)
    local cobraGlow = Instance.new("TextLabel")
    cobraGlow.Name = "CobraGlow"
    cobraGlow.Text = "🐍"
    cobraGlow.TextScaled = true
    cobraGlow.Font = Enum.Font.GothamBold
    cobraGlow.BackgroundTransparency = 1
    cobraGlow.TextTransparency = 0.5
    cobraGlow.Size = UDim2.new(0, 0, 0, 0)
    cobraGlow.Position = UDim2.new(0.5, 0, 0.25, 0)
    cobraGlow.AnchorPoint = Vector2.new(0.5, 0.5)
    cobraGlow.ZIndex = 111
    cobraGlow.Parent = centerContainer
    
    local cobraGlowStroke = Instance.new("UIStroke")
    cobraGlowStroke.Color = Config.Primary
    cobraGlowStroke.Thickness = 4
    cobraGlowStroke.Transparency = 0.3
    cobraGlowStroke.Parent = cobraGlow
    
    -- Main Cobra Emoji
    local cobraMain = Instance.new("TextLabel")
    cobraMain.Name = "CobraMain"
    cobraMain.Text = "🐍"
    cobraMain.TextScaled = true
    cobraMain.Font = Enum.Font.GothamBold
    cobraMain.BackgroundTransparency = 1
    cobraMain.TextTransparency = 0
    cobraMain.Size = UDim2.new(0, 0, 0, 0)
    cobraMain.Position = UDim2.new(0.5, 0, 0.25, 0)
    cobraMain.AnchorPoint = Vector2.new(0.5, 0.5)
    cobraMain.ZIndex = 112
    cobraMain.Parent = centerContainer
    
    local cobraStroke = Instance.new("UIStroke")
    cobraStroke.Name = "CobraStroke"
    cobraStroke.Color = Config.Primary
    cobraStroke.Thickness = 3
    cobraStroke.Transparency = 0
    cobraStroke.Parent = cobraMain
    
    -- === PHASE 1: Cobra slides in (grows from 0 to full size) ===
    ConsoleLog("Phase 1: Cobra Neon awakening...", "INTRO")
    
    -- Grow glow layer (slightly larger)
    local glowTween = TweenService:Create(cobraGlow, TweenInfo.new(1.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 170, 0, 170)
    })
    glowTween:Play()
    
    -- Grow main cobra
    local cobraTween = TweenService:Create(cobraMain, TweenInfo.new(1.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 150, 0, 150)
    })
    cobraTween:Play()
    
    -- Start glow pulse loop (runs during entire intro)
    spawn(function()
        while cobraGlow and cobraGlow.Parent do
            -- Pulse glow transparency
            TweenService:Create(cobraGlow, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                TextTransparency = 0.2
            }):Play()
            TweenService:Create(cobraGlowStroke, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Transparency = 0.1,
                Thickness = 5
            }):Play()
            wait(1.2)
            TweenService:Create(cobraGlow, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                TextTransparency = 0.8
            }):Play()
            TweenService:Create(cobraGlowStroke, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Transparency = 0.7,
                Thickness = 2
            }):Play()
            wait(1.2)
        end
    end)
    
    -- Main cobra stroke pulse (synced)
    spawn(function()
        while cobraStroke and cobraStroke.Parent do
            TweenService:Create(cobraStroke, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Transparency = 0.1,
                Thickness = 5
            }):Play()
            wait(1.2)
            TweenService:Create(cobraStroke, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Transparency = 0.8,
                Thickness = 2
            }):Play()
            wait(1.2)
        end
    end)
    
    -- Wait for cobra to fully appear
    cobraTween.Completed:Wait()
    wait(0.5)
    
    -- === PHASE 2: MEDUSA text glitch (AFTER cobra is visible) ===
    ConsoleLog("Phase 2: Glitch text reveal...", "INTRO")
    
    local medusaText = Instance.new("TextLabel")
    medusaText.Name = "MedusaTitle"
    medusaText.Text = ""
    medusaText.TextScaled = false
    medusaText.TextSize = 42
    medusaText.Font = Enum.Font.GothamBold
    medusaText.TextColor3 = Config.Primary
    medusaText.BackgroundTransparency = 1
    medusaText.Size = UDim2.new(1, 0, 0, 50)
    medusaText.Position = UDim2.new(0, 0, 0.55, 0)
    medusaText.TextXAlignment = Enum.TextXAlignment.Center
    medusaText.ZIndex = 112
    medusaText.Parent = centerContainer
    
    local titleStroke = Instance.new("UIStroke")
    titleStroke.Color = Config.Primary
    titleStroke.Thickness = 2
    titleStroke.Transparency = 0.3
    titleStroke.Parent = medusaText
    
    -- Title stroke pulse (synced with cobra)
    spawn(function()
        while titleStroke and titleStroke.Parent do
            TweenService:Create(titleStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Transparency = 0.2
            }):Play()
            wait(1.5)
            TweenService:Create(titleStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Transparency = 0.8
            }):Play()
            wait(1.5)
        end
    end)
    
    -- Glitch effect: random chars before reveal
    local finalText = "M E D U S A"
    local glitchChars = "!@#$%^&*01<>{}[]|/"
    
    for pass = 1, 14 do
        local glitched = ""
        for c = 1, #finalText do
            local realChar = finalText:sub(c, c)
            if realChar == " " then
                glitched = glitched .. " "
            else
                if math.random() < (pass / 14) then
                    glitched = glitched .. realChar
                else
                    local ri = math.random(1, #glitchChars)
                    glitched = glitched .. glitchChars:sub(ri, ri)
                end
            end
        end
        medusaText.Text = glitched
        wait(0.08)
    end
    medusaText.Text = finalText
    
    -- Version tag
    local versionTag = Instance.new("TextLabel")
    versionTag.Name = "VersionTag"
    versionTag.Text = "v" .. Config.Version .. " — " .. Config.BuildTag
    versionTag.TextSize = 13
    versionTag.Font = Enum.Font.Gotham
    versionTag.TextColor3 = Config.TextSecondary
    versionTag.BackgroundTransparency = 1
    versionTag.Size = UDim2.new(1, 0, 0, 20)
    versionTag.Position = UDim2.new(0, 0, 0.68, 0)
    versionTag.TextXAlignment = Enum.TextXAlignment.Center
    versionTag.TextTransparency = 1
    versionTag.ZIndex = 112
    versionTag.Parent = centerContainer
    
    TweenService:Create(versionTag, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextTransparency = 0
    }):Play()
    
    wait(0.4)
    
    -- === PHASE 3: Neon Loading Bar ===
    ConsoleLog("Phase 3: Neon loading bar...", "INTRO")
    
    local barContainer = Instance.new("Frame")
    barContainer.Name = "BarContainer"
    barContainer.Size = UDim2.new(0.7, 0, 0, 4)
    barContainer.Position = UDim2.new(0.15, 0, 0.78, 0)
    barContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    barContainer.BorderSizePixel = 0
    barContainer.ZIndex = 112
    barContainer.Parent = centerContainer
    
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 3)
    barCorner.Parent = barContainer
    
    local barFill = Instance.new("Frame")
    barFill.Name = "BarFill"
    barFill.Size = UDim2.new(0, 0, 1, 0)
    barFill.BackgroundColor3 = Config.Primary
    barFill.BorderSizePixel = 0
    barFill.ZIndex = 113
    barFill.Parent = barContainer
    
    local barFillCorner = Instance.new("UICorner")
    barFillCorner.CornerRadius = UDim.new(0, 3)
    barFillCorner.Parent = barFill
    
    -- Gradient on bar fill (Dark Green -> White -> Dark Green)
    local barGradient = Instance.new("UIGradient")
    barGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Config.PrimaryDark),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Config.PrimaryDark)
    })
    barGradient.Parent = barFill
    
    -- Animate gradient offset (neon light running)
    spawn(function()
        while barFill and barFill.Parent do
            TweenService:Create(barGradient, TweenInfo.new(1.5, Enum.EasingStyle.Linear), {
                Offset = Vector2.new(1, 0)
            }):Play()
            wait(1.5)
            barGradient.Offset = Vector2.new(-1, 0)
        end
    end)
    
    -- Status text
    local statusText = Instance.new("TextLabel")
    statusText.Name = "StatusText"
    statusText.Size = UDim2.new(1, 0, 0, 18)
    statusText.Position = UDim2.new(0, 0, 0.84, 0)
    statusText.BackgroundTransparency = 1
    statusText.TextColor3 = Config.TextSecondary
    statusText.TextSize = 11
    statusText.Font = Enum.Font.Code
    statusText.ZIndex = 112
    statusText.Parent = centerContainer
    
    -- Loading steps
    local loadSteps = {
        {0.08, "Initializing kernel..."},
        {0.15, "Hard clean complete"},
        {0.22, "Loading Config table..."},
        {0.30, "Mapping services..."},
        {0.40, "Binding core functions..."},
        {0.50, "WalkSpeed module ready"},
        {0.58, "JumpPower module ready"},
        {0.65, "InfiniteJump module ready"},
        {0.72, "Fly Universal loaded"},
        {0.80, "Fullbright module ready"},
        {0.88, "Noclip module ready"},
        {0.94, "Building UI framework..."},
        {1.00, "🐍 Medusa is alive"},
    }
    
    for _, step in ipairs(loadSteps) do
        local progress = step[1]
        local msg = step[2]
        statusText.Text = "> " .. msg
        ConsoleLog(msg, "LOAD")
        TweenService:Create(barFill, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(progress, 0, 1, 0)
        }):Play()
        wait(0.25)
    end
    
    wait(0.6)
    
    -- === PHASE 4: Fade out intro, slide in main ===
    ConsoleLog("Phase 4: Transition to main UI...", "INTRO")
    
    -- Fade out all intro elements
    for _, child in pairs(centerContainer:GetChildren()) do
        if child:IsA("TextLabel") then
            TweenService:Create(child, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
                TextTransparency = 1
            }):Play()
        end
        if child:IsA("Frame") then
            TweenService:Create(child, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
                BackgroundTransparency = 1
            }):Play()
        end
    end
    
    -- Fade cobra glow + main
    TweenService:Create(cobraGlow, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
        TextTransparency = 1
    }):Play()
    TweenService:Create(cobraMain, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
        TextTransparency = 1
    }):Play()
    
    wait(0.6)
    
    -- Fade background
    TweenService:Create(introBg, TweenInfo.new(0.6, Enum.EasingStyle.Quad), {
        BackgroundTransparency = 1
    }):Play()
    wait(0.7)
    
    introBg:Destroy()
    
    -- Callback to build main UI
    if callback then
        callback()
    end
end

-- ════════════════════════════════════════════
-- 7. MAIN UI BUILDER (Premium v1.0.0 Style)
-- ════════════════════════════════════════════
local TabContents = {}
local ToastContainer

local function ShowToast(message, duration)
    duration = duration or 2.5
    if not ToastContainer then return end
    
    local toast = Instance.new("Frame")
    toast.Size = UDim2.new(1, 0, 0, 32)
    toast.BackgroundColor3 = Config.Surface
    toast.BorderSizePixel = 0
    toast.BackgroundTransparency = 1
    toast.Parent = ToastContainer
    
    local tCorner = Instance.new("UICorner")
    tCorner.CornerRadius = UDim.new(0, 6)
    tCorner.Parent = toast
    
    local tStroke = Instance.new("UIStroke")
    tStroke.Color = Config.Primary
    tStroke.Thickness = 1
    tStroke.Transparency = 0.5
    tStroke.Parent = toast
    
    local tText = Instance.new("TextLabel")
    tText.Size = UDim2.new(1, -20, 1, 0)
    tText.Position = UDim2.new(0, 10, 0, 0)
    tText.BackgroundTransparency = 1
    tText.Text = "🐍 " .. message
    tText.TextColor3 = Config.Primary
    tText.TextSize = 12
    tText.Font = Enum.Font.Gotham
    tText.TextXAlignment = Enum.TextXAlignment.Left
    tText.TextTransparency = 1
    tText.Parent = toast
    
    -- Fade in
    TweenService:Create(toast, TweenInfo.new(0.3), { BackgroundTransparency = 0.1 }):Play()
    TweenService:Create(tText, TweenInfo.new(0.3), { TextTransparency = 0 }):Play()
    
    -- Fade out & destroy
    spawn(function()
        wait(duration)
        TweenService:Create(toast, TweenInfo.new(0.4), { BackgroundTransparency = 1 }):Play()
        TweenService:Create(tText, TweenInfo.new(0.4), { TextTransparency = 1 }):Play()
        wait(0.5)
        if toast and toast.Parent then toast:Destroy() end
    end)
end

-- === UI Component Factories ===

local function CreateCard(parent, height)
    height = height or 50
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, height)
    card.BackgroundColor3 = Config.Surface
    card.BorderSizePixel = 0
    card.Parent = parent
    
    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 8)
    cardCorner.Parent = card
    
    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = Config.Border
    cardStroke.Thickness = 1
    cardStroke.Transparency = 0.3
    cardStroke.Parent = card
    
    return card, cardStroke
end

local function CreateSectionHeader(parent, title)
    local headerFrame = Instance.new("Frame")
    headerFrame.Size = UDim2.new(1, 0, 0, 22)
    headerFrame.BackgroundTransparency = 1
    headerFrame.Parent = parent
    
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 3, 0, 14)
    bar.Position = UDim2.new(0, 0, 0.5, -7)
    bar.BackgroundColor3 = Config.Primary
    bar.BorderSizePixel = 0
    bar.Parent = headerFrame
    
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 2)
    barCorner.Parent = bar
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -12, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = Config.TextSecondary
    label.TextSize = 11
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = headerFrame
    
    return headerFrame
end

local function CreateToggle(parent, name, default, onChanged)
    local card, cardStroke = CreateCard(parent, 42)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, -10, 1, 0)
    label.Position = UDim2.new(0, 14, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Config.TextPrimary
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = card
    
    -- Status text
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(0, 30, 1, 0)
    statusLabel.Position = UDim2.new(1, -90, 0, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = default and "ON" or "OFF"
    statusLabel.TextColor3 = default and Config.Primary or Config.TextSecondary
    statusLabel.TextSize = 10
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.TextXAlignment = Enum.TextXAlignment.Right
    statusLabel.Parent = card
    
    -- Toggle track
    local track = Instance.new("Frame")
    track.Size = UDim2.new(0, 40, 0, 20)
    track.Position = UDim2.new(1, -54, 0.5, -10)
    track.BackgroundColor3 = default and Config.Primary or Color3.fromRGB(40, 40, 40)
    track.BorderSizePixel = 0
    track.Parent = card
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track
    
    -- Toggle knob
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = track
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob
    
    -- Knob glow when on
    local knobStroke = Instance.new("UIStroke")
    knobStroke.Color = Config.Primary
    knobStroke.Thickness = default and 2 or 0
    knobStroke.Transparency = 0.4
    knobStroke.Parent = knob
    
    local isOn = default or false
    
    -- Click handler
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.ZIndex = 5
    button.Parent = card
    
    button.MouseButton1Click:Connect(function()
        isOn = not isOn
        
        -- Animate track
        TweenService:Create(track, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = isOn and Config.Primary or Color3.fromRGB(40, 40, 40)
        }):Play()
        
        -- Animate knob
        TweenService:Create(knob, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = isOn and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        }):Play()
        
        -- Knob glow
        TweenService:Create(knobStroke, TweenInfo.new(0.2), {
            Thickness = isOn and 2 or 0
        }):Play()
        
        -- Card stroke flash
        TweenService:Create(cardStroke, TweenInfo.new(0.15), {
            Color = Config.Primary,
            Transparency = 0
        }):Play()
        spawn(function()
            wait(0.3)
            TweenService:Create(cardStroke, TweenInfo.new(0.4), {
                Color = Config.Border,
                Transparency = 0.3
            }):Play()
        end)
        
        -- Status text
        statusLabel.Text = isOn and "ON" or "OFF"
        statusLabel.TextColor3 = isOn and Config.Primary or Config.TextSecondary
        
        if onChanged then
            onChanged(isOn)
        end
        
        ShowToast(name .. (isOn and " enabled" or " disabled"))
    end)
    
    -- Hover effect
    button.MouseEnter:Connect(function()
        TweenService:Create(card, TweenInfo.new(0.15), {
            BackgroundColor3 = Config.SurfaceHover
        }):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(card, TweenInfo.new(0.15), {
            BackgroundColor3 = Config.Surface
        }):Play()
    end)
    
    return {
        SetState = function(state)
            isOn = state
            track.BackgroundColor3 = isOn and Config.Primary or Color3.fromRGB(40, 40, 40)
            knob.Position = isOn and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            knobStroke.Thickness = isOn and 2 or 0
            statusLabel.Text = isOn and "ON" or "OFF"
            statusLabel.TextColor3 = isOn and Config.Primary or Config.TextSecondary
        end
    }
end

local function CreateSlider(parent, name, min, max, default, onChanged)
    local card = CreateCard(parent, 58)
    
    -- Label + Value
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 0, 20)
    label.Position = UDim2.new(0, 14, 0, 6)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Config.TextPrimary
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = card
    
    -- Value badge
    local valueBadge = Instance.new("Frame")
    valueBadge.Size = UDim2.new(0, 44, 0, 18)
    valueBadge.Position = UDim2.new(1, -58, 0, 5)
    valueBadge.BackgroundColor3 = Color3.fromRGB(0, 201, 107)
    valueBadge.BackgroundTransparency = 0.85
    valueBadge.BorderSizePixel = 0
    valueBadge.Parent = card
    
    local vbCorner = Instance.new("UICorner")
    vbCorner.CornerRadius = UDim.new(0, 4)
    vbCorner.Parent = valueBadge
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(1, 0, 1, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Config.Primary
    valueLabel.TextSize = 11
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.Parent = valueBadge
    
    -- Slider track
    local sliderTrack = Instance.new("Frame")
    sliderTrack.Size = UDim2.new(1, -28, 0, 6)
    sliderTrack.Position = UDim2.new(0, 14, 0, 36)
    sliderTrack.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    sliderTrack.BorderSizePixel = 0
    sliderTrack.Parent = card
    
    local stCorner = Instance.new("UICorner")
    stCorner.CornerRadius = UDim.new(1, 0)
    stCorner.Parent = sliderTrack
    
    -- Slider fill
    local initialPercent = (default - min) / (max - min)
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new(initialPercent, 0, 1, 0)
    sliderFill.BackgroundColor3 = Config.Primary
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderTrack
    
    local sfCorner = Instance.new("UICorner")
    sfCorner.CornerRadius = UDim.new(1, 0)
    sfCorner.Parent = sliderFill
    
    -- Fill gradient
    local fillGradient = Instance.new("UIGradient")
    fillGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Config.PrimaryDark),
        ColorSequenceKeypoint.new(0.5, Config.Primary),
        ColorSequenceKeypoint.new(1, Config.Accent)
    })
    fillGradient.Parent = sliderFill
    
    -- Knob
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new(initialPercent, -7, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.ZIndex = 3
    knob.Parent = sliderTrack
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob
    
    local knobRing = Instance.new("UIStroke")
    knobRing.Color = Config.Primary
    knobRing.Thickness = 2
    knobRing.Transparency = 0.3
    knobRing.Parent = knob
    
    -- Interaction
    local dragging = false
    
    local dragButton = Instance.new("TextButton")
    dragButton.Size = UDim2.new(1, 0, 0, 24)
    dragButton.Position = UDim2.new(0, 0, 0, 28)
    dragButton.BackgroundTransparency = 1
    dragButton.Text = ""
    dragButton.ZIndex = 5
    dragButton.Parent = card
    
    local function updateSlider(inputX)
        local trackAbsPos = sliderTrack.AbsolutePosition.X
        local trackAbsSize = sliderTrack.AbsoluteSize.X
        local relativeX = math.clamp((inputX - trackAbsPos) / trackAbsSize, 0, 1)
        local value = math.floor(min + (max - min) * relativeX)
        
        valueLabel.Text = tostring(value)
        
        TweenService:Create(sliderFill, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {
            Size = UDim2.new(relativeX, 0, 1, 0)
        }):Play()
        
        knob.Position = UDim2.new(relativeX, -7, 0.5, -7)
        
        if onChanged then
            onChanged(value)
        end
    end
    
    dragButton.MouseButton1Down:Connect(function()
        dragging = true
        -- Grow knob on grab
        TweenService:Create(knob, TweenInfo.new(0.15), {
            Size = UDim2.new(0, 18, 0, 18),
        }):Play()
        knob.Position = UDim2.new(knob.Position.X.Scale, -9, 0.5, -9)
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input.Position.X)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                dragging = false
                -- Shrink knob back
                TweenService:Create(knob, TweenInfo.new(0.15), {
                    Size = UDim2.new(0, 14, 0, 14),
                }):Play()
                knob.Position = UDim2.new(knob.Position.X.Scale, -7, 0.5, -7)
            end
        end
    end)
    
    dragButton.MouseButton1Click:Connect(function()
        local mouse = Player:GetMouse()
        updateSlider(mouse.X)
    end)
    
    return {
        SetValue = function(val)
            local p = (val - min) / (max - min)
            valueLabel.Text = tostring(val)
            sliderFill.Size = UDim2.new(p, 0, 1, 0)
            knob.Position = UDim2.new(p, -7, 0.5, -7)
        end
    }
end

-- === Build Main Frame ===
local function BuildMainUI()
    -- === Main Frame (starts off-screen for slide-up) ===
    MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = Config.MainSize
    MainFrame.Position = UDim2.new(0.5, -240, 1.2, 0) -- Off-screen below
    MainFrame.AnchorPoint = Vector2.new(0, 0)
    MainFrame.BackgroundColor3 = Config.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = Config.CornerRadius
    mainCorner.Parent = MainFrame
    
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Config.PrimaryDark
    mainStroke.Thickness = 1
    mainStroke.Transparency = 0.5
    mainStroke.Parent = MainFrame
    
    -- Make draggable
    local dragToggle, dragStart, startPos
    local dragInput
    
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragToggle = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end)
    
    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragToggle then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- ═══════════════ HEADER ═══════════════
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 48)
    header.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
    header.BorderSizePixel = 0
    header.Parent = MainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 10)
    headerCorner.Parent = header
    
    -- Fix bottom corners of header
    local headerFix = Instance.new("Frame")
    headerFix.Size = UDim2.new(1, 0, 0, 12)
    headerFix.Position = UDim2.new(0, 0, 1, -12)
    headerFix.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
    headerFix.BorderSizePixel = 0
    headerFix.Parent = header
    
    -- Header Cobra Emoji
    local headerCobra = Instance.new("TextLabel")
    headerCobra.Size = UDim2.new(0, 28, 0, 28)
    headerCobra.Position = UDim2.new(0, 14, 0.5, -14)
    headerCobra.BackgroundTransparency = 1
    headerCobra.Text = "🐍"
    headerCobra.TextScaled = true
    headerCobra.Font = Enum.Font.GothamBold
    headerCobra.ZIndex = 3
    headerCobra.Parent = header
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0, 120, 0, 20)
    titleLabel.Position = UDim2.new(0, 48, 0, 8)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "MEDUSA"
    titleLabel.TextColor3 = Config.Primary
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = header
    
    local titleStroke = Instance.new("UIStroke")
    titleStroke.Color = Config.Primary
    titleStroke.Thickness = 1
    titleStroke.Transparency = 0.6
    titleStroke.Parent = titleLabel
    
    -- Version subtitle
    local subtitleLabel = Instance.new("TextLabel")
    subtitleLabel.Size = UDim2.new(0, 120, 0, 14)
    subtitleLabel.Position = UDim2.new(0, 48, 0, 28)
    subtitleLabel.BackgroundTransparency = 1
    subtitleLabel.Text = "v" .. Config.Version .. " • Universal Engine"
    subtitleLabel.TextColor3 = Config.TextSecondary
    subtitleLabel.TextSize = 10
    subtitleLabel.Font = Enum.Font.Gotham
    subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    subtitleLabel.Parent = header
    
    -- Status dot (pulsing)
    local statusDot = Instance.new("Frame")
    statusDot.Size = UDim2.new(0, 8, 0, 8)
    statusDot.Position = UDim2.new(1, -70, 0.5, -4)
    statusDot.BackgroundColor3 = Config.Primary
    statusDot.BorderSizePixel = 0
    statusDot.Parent = header
    
    local sdCorner = Instance.new("UICorner")
    sdCorner.CornerRadius = UDim.new(1, 0)
    sdCorner.Parent = statusDot
    
    -- Pulse the status dot
    spawn(function()
        while statusDot and statusDot.Parent do
            TweenService:Create(statusDot, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                BackgroundTransparency = 0.6
            }):Play()
            wait(1)
            TweenService:Create(statusDot, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                BackgroundTransparency = 0
            }):Play()
            wait(1)
        end
    end)
    
    local liveLabel = Instance.new("TextLabel")
    liveLabel.Size = UDim2.new(0, 24, 0, 14)
    liveLabel.Position = UDim2.new(1, -58, 0.5, -7)
    liveLabel.BackgroundTransparency = 1
    liveLabel.Text = "LIVE"
    liveLabel.TextColor3 = Config.Primary
    liveLabel.TextSize = 9
    liveLabel.Font = Enum.Font.GothamBold
    liveLabel.Parent = header
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -34, 0.5, -14)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Config.TextSecondary
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = header
    
    closeBtn.MouseButton1Click:Connect(function()
        State.UIVisible = false
        TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, -240, 1.2, 0)
        }):Play()
    end)
    
    closeBtn.MouseEnter:Connect(function()
        closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
    end)
    closeBtn.MouseLeave:Connect(function()
        closeBtn.TextColor3 = Config.TextSecondary
    end)
    
    -- Neon line under header (gradient 5 points)
    local neonLine = Instance.new("Frame")
    neonLine.Size = UDim2.new(1, 0, 0, 2)
    neonLine.Position = UDim2.new(0, 0, 0, 48)
    neonLine.BackgroundColor3 = Config.Primary
    neonLine.BorderSizePixel = 0
    neonLine.Parent = MainFrame
    
    local neonGradient = Instance.new("UIGradient")
    neonGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
        ColorSequenceKeypoint.new(0.25, Config.PrimaryDark),
        ColorSequenceKeypoint.new(0.5, Config.Primary),
        ColorSequenceKeypoint.new(0.75, Config.PrimaryDark),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
    })
    neonGradient.Parent = neonLine
    
    -- ═══════════════ TABS ═══════════════
    local tabBar = Instance.new("Frame")
    tabBar.Size = UDim2.new(1, 0, 0, 34)
    tabBar.Position = UDim2.new(0, 0, 0, 52)
    tabBar.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
    tabBar.BorderSizePixel = 0
    tabBar.Parent = MainFrame
    
    local tabNames = {"⚡ Movement", "👁 Visuals", "📜 Console"}
    local tabKeys = {"Movement", "Visuals", "Console"}
    local tabButtons = {}
    local tabIndicator
    
    for i, tabName in ipairs(tabNames) do
        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(1 / #tabNames, 0, 1, 0)
        tabBtn.Position = UDim2.new((i - 1) / #tabNames, 0, 0, 0)
        tabBtn.BackgroundTransparency = 1
        tabBtn.Text = tabName
        tabBtn.TextColor3 = (i == 1) and Config.Primary or Config.TextSecondary
        tabBtn.TextSize = 12
        tabBtn.Font = Enum.Font.GothamBold
        tabBtn.Parent = tabBar
        tabButtons[tabKeys[i]] = tabBtn
        
        tabBtn.MouseButton1Click:Connect(function()
            ActiveTab = tabKeys[i]
            for k, btn in pairs(tabButtons) do
                TweenService:Create(btn, TweenInfo.new(0.2), {
                    TextColor3 = (k == ActiveTab) and Config.Primary or Config.TextSecondary
                }):Play()
            end
            -- Move indicator
            if tabIndicator then
                TweenService:Create(tabIndicator, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Position = UDim2.new((i - 1) / #tabNames, 4, 1, -3)
                }):Play()
            end
            -- Show/hide content
            for key, content in pairs(TabContents) do
                content.Visible = (key == ActiveTab)
            end
        end)
        
        tabBtn.MouseEnter:Connect(function()
            if tabKeys[i] ~= ActiveTab then
                TweenService:Create(tabBtn, TweenInfo.new(0.15), {
                    TextColor3 = Config.PrimaryDark
                }):Play()
            end
        end)
        tabBtn.MouseLeave:Connect(function()
            if tabKeys[i] ~= ActiveTab then
                TweenService:Create(tabBtn, TweenInfo.new(0.15), {
                    TextColor3 = Config.TextSecondary
                }):Play()
            end
        end)
    end
    
    -- Tab underline indicator
    tabIndicator = Instance.new("Frame")
    tabIndicator.Size = UDim2.new(1 / #tabNames, -8, 0, 2)
    tabIndicator.Position = UDim2.new(0, 4, 1, -3)
    tabIndicator.BackgroundColor3 = Config.Primary
    tabIndicator.BorderSizePixel = 0
    tabIndicator.Parent = tabBar
    
    local tiCorner = Instance.new("UICorner")
    tiCorner.CornerRadius = UDim.new(1, 0)
    tiCorner.Parent = tabIndicator
    
    -- Separator
    local separator = Instance.new("Frame")
    separator.Size = UDim2.new(0.92, 0, 0, 1)
    separator.Position = UDim2.new(0.04, 0, 0, 86)
    separator.BackgroundColor3 = Config.Border
    separator.BackgroundTransparency = 0.5
    separator.BorderSizePixel = 0
    separator.Parent = MainFrame
    
    local sepGradient = Instance.new("UIGradient")
    sepGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.1, 0),
        NumberSequenceKeypoint.new(0.9, 0),
        NumberSequenceKeypoint.new(1, 1),
    })
    sepGradient.Parent = separator
    
    -- ═══════════════ CONTENT AREA ═══════════════
    local contentArea = Instance.new("Frame")
    contentArea.Size = UDim2.new(1, -20, 1, -130)
    contentArea.Position = UDim2.new(0, 10, 0, 92)
    contentArea.BackgroundTransparency = 1
    contentArea.ClipsDescendants = true
    contentArea.Parent = MainFrame
    
    -- === MOVEMENT TAB ===
    local movementTab = Instance.new("ScrollingFrame")
    movementTab.Name = "MovementTab"
    movementTab.Size = UDim2.new(1, 0, 1, 0)
    movementTab.BackgroundTransparency = 1
    movementTab.ScrollBarThickness = 3
    movementTab.ScrollBarImageColor3 = Config.Primary
    movementTab.BorderSizePixel = 0
    movementTab.CanvasSize = UDim2.new(0, 0, 0, 420)
    movementTab.Parent = contentArea
    TabContents["Movement"] = movementTab
    
    local movLayout = Instance.new("UIListLayout")
    movLayout.Padding = UDim.new(0, 6)
    movLayout.SortOrder = Enum.SortOrder.LayoutOrder
    movLayout.Parent = movementTab
    
    -- Speed Section
    CreateSectionHeader(movementTab, "SPEED CONTROLS")
    
    local wsToggle = CreateToggle(movementTab, "WalkSpeed", false, function(enabled)
        Functions.SetWalkSpeed(enabled, State.WalkSpeedValue)
    end)
    
    CreateSlider(movementTab, "WalkSpeed Value", 16, Config.MaxWalkSpeed, Config.DefaultWalkSpeed, function(val)
        State.WalkSpeedValue = val
        if State.WalkSpeedEnabled then
            Functions.SetWalkSpeed(true, val)
        end
    end)
    
    local jpToggle = CreateToggle(movementTab, "JumpPower", false, function(enabled)
        Functions.SetJumpPower(enabled, State.JumpPowerValue)
    end)
    
    CreateSlider(movementTab, "JumpPower Value", 50, Config.MaxJumpPower, Config.DefaultJumpPower, function(val)
        State.JumpPowerValue = val
        if State.JumpPowerEnabled then
            Functions.SetJumpPower(true, val)
        end
    end)
    
    -- Jump & Fly Section
    CreateSectionHeader(movementTab, "AERIAL CONTROLS")
    
    CreateToggle(movementTab, "Infinite Jump", false, function(enabled)
        Functions.SetInfiniteJump(enabled)
    end)
    
    local flyToggle = CreateToggle(movementTab, "Fly Universal [F]", false, function(enabled)
        Functions.SetFly(enabled)
    end)
    
    CreateSlider(movementTab, "Fly Speed", 10, 200, Config.DefaultFlySpeed, function(val)
        State.FlySpeed = val
        ConsoleLog("Fly speed → " .. val, "SET")
    end)
    
    -- === VISUALS TAB ===
    local visualsTab = Instance.new("ScrollingFrame")
    visualsTab.Name = "VisualsTab"
    visualsTab.Size = UDim2.new(1, 0, 1, 0)
    visualsTab.BackgroundTransparency = 1
    visualsTab.ScrollBarThickness = 3
    visualsTab.ScrollBarImageColor3 = Config.Primary
    visualsTab.BorderSizePixel = 0
    visualsTab.CanvasSize = UDim2.new(0, 0, 0, 200)
    visualsTab.Visible = false
    visualsTab.Parent = contentArea
    TabContents["Visuals"] = visualsTab
    
    local visLayout = Instance.new("UIListLayout")
    visLayout.Padding = UDim.new(0, 6)
    visLayout.SortOrder = Enum.SortOrder.LayoutOrder
    visLayout.Parent = visualsTab
    
    CreateSectionHeader(visualsTab, "RENDER")
    
    CreateToggle(visualsTab, "Fullbright", false, function(enabled)
        Functions.SetFullbright(enabled)
    end)
    
    CreateToggle(visualsTab, "Noclip", false, function(enabled)
        Functions.SetNoclip(enabled)
    end)
    
    -- === CONSOLE TAB ===
    local consoleTab = Instance.new("Frame")
    consoleTab.Name = "ConsoleTab"
    consoleTab.Size = UDim2.new(1, 0, 1, 0)
    consoleTab.BackgroundTransparency = 1
    consoleTab.Visible = false
    consoleTab.Parent = contentArea
    TabContents["Console"] = consoleTab
    
    -- Terminal header
    local termHeader = Instance.new("TextLabel")
    termHeader.Size = UDim2.new(1, 0, 0, 22)
    termHeader.BackgroundColor3 = Color3.fromRGB(6, 6, 6)
    termHeader.BorderSizePixel = 0
    termHeader.Text = "  medusa@engine:~$ tail -f medusa.log"
    termHeader.TextColor3 = Config.Primary
    termHeader.TextSize = 10
    termHeader.Font = Enum.Font.Code
    termHeader.TextXAlignment = Enum.TextXAlignment.Left
    termHeader.Parent = consoleTab
    
    local thCorner = Instance.new("UICorner")
    thCorner.CornerRadius = UDim.new(0, 6)
    thCorner.Parent = termHeader
    
    local consoleScroll = Instance.new("ScrollingFrame")
    consoleScroll.Size = UDim2.new(1, 0, 1, -28)
    consoleScroll.Position = UDim2.new(0, 0, 0, 26)
    consoleScroll.BackgroundColor3 = Color3.fromRGB(6, 6, 6)
    consoleScroll.BorderSizePixel = 0
    consoleScroll.ScrollBarThickness = 3
    consoleScroll.ScrollBarImageColor3 = Config.Primary
    consoleScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    consoleScroll.Parent = consoleTab
    
    local csCorner = Instance.new("UICorner")
    csCorner.CornerRadius = UDim.new(0, 6)
    csCorner.Parent = consoleScroll
    
    local consoleLayout = Instance.new("UIListLayout")
    consoleLayout.Padding = UDim.new(0, 2)
    consoleLayout.SortOrder = Enum.SortOrder.LayoutOrder
    consoleLayout.Parent = consoleScroll
    
    -- Console updater
    local lastConsoleCount = 0
    spawn(function()
        while consoleScroll and consoleScroll.Parent do
            if #ConsoleMessages > lastConsoleCount then
                for i = lastConsoleCount + 1, #ConsoleMessages do
                    local entry = ConsoleMessages[i]
                    local line = Instance.new("TextLabel")
                    line.Size = UDim2.new(1, -10, 0, 16)
                    line.BackgroundTransparency = 1
                    
                    local typeColor = Config.TextSecondary
                    if entry.Type == "EXEC" then typeColor = Config.Primary
                    elseif entry.Type == "LOAD" then typeColor = Config.Accent
                    elseif entry.Type == "INTRO" then typeColor = Config.PrimaryDark
                    elseif entry.Type == "ERR" then typeColor = Color3.fromRGB(255, 80, 80) end
                    
                    line.Text = string.format("[%s] [%s] %s", entry.Time, entry.Type, entry.Message)
                    line.TextColor3 = typeColor
                    line.TextSize = 10
                    line.Font = Enum.Font.Code
                    line.TextXAlignment = Enum.TextXAlignment.Left
                    line.TextWrapped = true
                    line.Parent = consoleScroll
                end
                lastConsoleCount = #ConsoleMessages
                consoleScroll.CanvasSize = UDim2.new(0, 0, 0, #ConsoleMessages * 18)
                consoleScroll.CanvasPosition = Vector2.new(0, math.max(0, #ConsoleMessages * 18 - consoleScroll.AbsoluteSize.Y))
            end
            wait(0.3)
        end
    end)
    
    -- ═══════════════ FOOTER ═══════════════
    local footerLine = Instance.new("Frame")
    footerLine.Size = UDim2.new(0.92, 0, 0, 1)
    footerLine.Position = UDim2.new(0.04, 0, 1, -38)
    footerLine.BackgroundColor3 = Config.Primary
    footerLine.BackgroundTransparency = 0.6
    footerLine.BorderSizePixel = 0
    footerLine.Parent = MainFrame
    
    local flGradient = Instance.new("UIGradient")
    flGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.15, 0),
        NumberSequenceKeypoint.new(0.85, 0),
        NumberSequenceKeypoint.new(1, 1),
    })
    flGradient.Parent = footerLine
    
    local footer = Instance.new("Frame")
    footer.Size = UDim2.new(1, 0, 0, 32)
    footer.Position = UDim2.new(0, 0, 1, -34)
    footer.BackgroundTransparency = 1
    footer.Parent = MainFrame
    
    local footerText = Instance.new("TextLabel")
    footerText.Size = UDim2.new(0.5, 0, 1, 0)
    footerText.Position = UDim2.new(0, 14, 0, 0)
    footerText.BackgroundTransparency = 1
    footerText.Text = "🐍 Medusa Universal Engine"
    footerText.TextColor3 = Config.TextSecondary
    footerText.TextSize = 10
    footerText.Font = Enum.Font.Gotham
    footerText.TextXAlignment = Enum.TextXAlignment.Left
    footerText.Parent = footer
    
    local pingLabel = Instance.new("TextLabel")
    pingLabel.Size = UDim2.new(0.4, 0, 1, 0)
    pingLabel.Position = UDim2.new(0.6, 0, 0, 0)
    pingLabel.BackgroundTransparency = 1
    pingLabel.Text = "Ping: --ms"
    pingLabel.TextColor3 = Config.Primary
    pingLabel.TextSize = 10
    pingLabel.Font = Enum.Font.Code
    pingLabel.TextXAlignment = Enum.TextXAlignment.Right
    pingLabel.Parent = footer
    
    -- Ping updater
    spawn(function()
        while pingLabel and pingLabel.Parent do
            local ping = math.floor(Player:GetNetworkPing() * 1000)
            pingLabel.Text = "Ping: " .. ping .. "ms"
            if ping < 80 then
                pingLabel.TextColor3 = Config.Primary
            elseif ping < 150 then
                pingLabel.TextColor3 = Color3.fromRGB(230, 200, 50)
            else
                pingLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
            end
            wait(1)
        end
    end)
    
    -- ═══════════════ TOAST CONTAINER ═══════════════
    ToastContainer = Instance.new("Frame")
    ToastContainer.Size = UDim2.new(0, 250, 0, 200)
    ToastContainer.Position = UDim2.new(1, -260, 1, -220)
    ToastContainer.BackgroundTransparency = 1
    ToastContainer.Parent = ScreenGui
    
    local toastLayout = Instance.new("UIListLayout")
    toastLayout.Padding = UDim.new(0, 4)
    toastLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    toastLayout.SortOrder = Enum.SortOrder.LayoutOrder
    toastLayout.Parent = ToastContainer
    
    -- ═══════════════ SLIDE UP ANIMATION ═══════════════
    ConsoleLog("Main UI built successfully", "INFO")
    
    TweenService:Create(MainFrame, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -240, 0.5, -260)
    }):Play()
    
    wait(1)
    ShowToast("Engine loaded — Press [M] to toggle")
    ConsoleLog("🐍 Medusa v" .. Config.Version .. " is alive", "INFO")
end

-- ════════════════════════════════════════════
-- 8. KEYBINDS
-- ════════════════════════════════════════════
Connections["Keybinds"] = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- [M] Toggle UI
    if input.KeyCode == Config.ToggleKey then
        if State.UIVisible then
            State.UIVisible = false
            TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Position = UDim2.new(0.5, -240, 1.2, 0)
            }):Play()
        else
            State.UIVisible = true
            TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Position = UDim2.new(0.5, -240, 0.5, -260)
            }):Play()
        end
    end
    
    -- [F] Toggle Fly
    if input.KeyCode == Config.FlyKey then
        State.FlyEnabled = not State.FlyEnabled
        Functions.SetFly(State.FlyEnabled)
        ShowToast("Fly " .. (State.FlyEnabled and "ENABLED" or "DISABLED"))
    end
end)

-- Infinite Jump handler
Connections["InfJump"] = UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJumpEnabled then
        local hum = GetHumanoid()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- ════════════════════════════════════════════
-- 9. INITIALIZE
-- ════════════════════════════════════════════
_G.Medusa = {
    Config = Config,
    State = State,
    Functions = Functions,
    Connections = Connections,
    ScreenGui = nil, -- Set after intro
    Version = Config.Version,
}

ConsoleLog("Hard clean complete", "LOAD")
ConsoleLog("Medusa Engine v" .. Config.Version .. " initializing...", "LOAD")

-- Respawn handler (re-apply active functions)
Connections["Respawn"] = Player.CharacterAdded:Connect(function(char)
    wait(1)
    ConsoleLog("Character respawned — re-applying...", "INFO")
    if State.WalkSpeedEnabled then
        Functions.SetWalkSpeed(true, State.WalkSpeedValue)
    end
    if State.JumpPowerEnabled then
        Functions.SetJumpPower(true, State.JumpPowerValue)
    end
    if State.FlyEnabled then
        Functions.SetFly(true)
    end
    if State.NoclipEnabled then
        Functions.SetNoclip(true)
    end
end)

-- Launch!
PlayCinematicIntro(function()
    _G.Medusa.ScreenGui = ScreenGui
    BuildMainUI()
end)
