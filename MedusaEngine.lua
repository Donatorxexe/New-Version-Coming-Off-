--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║          🐍 MEDUSA UNIVERSAL ENGINE v1.0.1 🐍               ║
    ║              C O B R A   E D I T I O N                      ║
    ║                                                              ║
    ║  96 Functions | 6 Modules | Verde Esmeralda Theme            ║
    ║  Combat v2 | ESP 3D | Movement | World | Utility | HUD      ║
    ║                                                              ║
    ║  Hard Clean | Passive Load | CFrame Fly | Neon Intro         ║
    ╚══════════════════════════════════════════════════════════════╝
--]]

-- ╔════════════════════════════════════════╗
-- ║     SECTION 1: HARD CLEAN SYSTEM      ║
-- ╚════════════════════════════════════════╝

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
        if _G.Medusa.Loops then
            for k, _ in pairs(_G.Medusa.Loops) do
                _G.Medusa.Loops[k] = false
            end
        end
    end)
    _G.Medusa = nil
    task.wait(0.3)
end

-- ╔════════════════════════════════════════╗
-- ║   SECTION 2: SERVICES & CONFIG        ║
-- ╚════════════════════════════════════════╝

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Config = {
    Version = "1.0.1",
    Name = "MEDUSA",
    Theme = {
        Primary = Color3.fromRGB(0, 201, 107),
        PrimaryDark = Color3.fromRGB(0, 140, 75),
        Accent = Color3.fromRGB(0, 255, 135),
        Background = Color3.fromRGB(15, 15, 15),
        Card = Color3.fromRGB(22, 22, 22),
        CardHover = Color3.fromRGB(30, 30, 30),
        Surface = Color3.fromRGB(18, 18, 18),
        Text = Color3.fromRGB(220, 220, 220),
        TextDim = Color3.fromRGB(120, 120, 120),
        Red = Color3.fromRGB(255, 60, 60),
        Yellow = Color3.fromRGB(255, 200, 60),
        White = Color3.fromRGB(255, 255, 255),
        Black = Color3.fromRGB(0, 0, 0),
    },
    Keybinds = {
        ToggleUI = Enum.KeyCode.M,
        Fly = Enum.KeyCode.F,
        Noclip = Enum.KeyCode.N,
        InfJump = Enum.KeyCode.Space,
        ESP = Enum.KeyCode.J,
    },
    Defaults = {
        WalkSpeed = 16,
        JumpPower = 50,
        FlySpeed = 80,
        FOVRadius = 120,
        ESPMaxDist = 1000,
        Gravity = 196.2,
        Reach = 10,
    }
}

-- ╔════════════════════════════════════════╗
-- ║   SECTION 3: STATE & FUNCTIONS TABLE  ║
-- ╚════════════════════════════════════════╝

local State = {
    -- Combat v2
    SilentAim = false,
    Aimbot = false,
    KillAura = false,
    AutoParry = false,
    Reach = false,
    AutoCombo = false,
    TriggerBot = false,
    FOVCircle = false,
    TargetStrafe = false,
    AutoBlock = false,
    ClickTP = false,
    TargetInfo = false,
    AntiBackstab = false,
    AutoClicker = false,
    ComboLock = false,
    HitboxExpander = false,

    -- ESP 3D
    BoxESP = false,
    NameESP = false,
    HealthESP = false,
    DistanceESP = false,
    Tracers = false,
    Chams = false,
    HeadDot = false,
    SkeletonESP = false,
    ItemESP = false,
    NPCESP = false,
    CornerBox = false,
    TeamCheck = false,
    VisibleCheck = false,
    Crosshair = false,
    FOVDisplay = false,
    RadarESP = false,

    -- Movement
    WalkSpeedOn = false,
    JumpPowerOn = false,
    Fly = false,
    Noclip = false,
    InfiniteJump = false,
    SpeedGlitch = false,
    LongJump = false,
    HighJump = false,
    Spider = false,
    Phase = false,
    TPtoMouse = false,
    AutoWalk = false,
    BunnyHop = false,
    Glide = false,
    Dash = false,
    Anchor = false,

    -- World
    Fullbright = false,
    AntiFog = false,
    DayTime = false,
    NightTime = false,
    NoWeather = false,
    RemoveEffects = false,
    AntiLag = false,
    NoInvisWalls = false,
    XRay = false,
    SmallChars = false,
    CustomGravity = false,
    TPtoRandom = false,
    TPtoSpawn = false,
    MapCleaner = false,
    NoClipParts = false,
    Destroy3D = false,

    -- Utility
    AntiAFK = false,
    ServerHop = false,
    Rejoin = false,
    FPSUnlock = false,
    ChatSpam = false,
    AntiKick = false,
    GodMode = false,
    CopyGameID = false,
    CopyServerID = false,
    ResetChar = false,
    HideName = false,
    Sit = false,
    AntiVoid = false,
    AutoRespawn = false,
    InfStamina = false,
    NoRagdoll = false,

    -- HUD
    FPSCounter = false,
    PingDisplay = false,
    Coordinates = false,
    PlayerCount = false,
    VelocityDisplay = false,
    TargetInfoHUD = false,
    Watermark = false,
    KeybindList = false,
    SessionTimer = false,
    KillCounter = false,
    Clock = false,
    MemoryUsage = false,
    GameInfo = false,
    Notifications = true,
    MinimapDot = false,
    PerfStats = false,
}

local Values = {
    WalkSpeed = Config.Defaults.WalkSpeed,
    JumpPower = Config.Defaults.JumpPower,
    FlySpeed = Config.Defaults.FlySpeed,
    FOVRadius = Config.Defaults.FOVRadius,
    ESPMaxDist = Config.Defaults.ESPMaxDist,
    Gravity = Config.Defaults.Gravity,
    Reach = Config.Defaults.Reach,
    AimbotSmooth = 5,
    TargetStrafeRadius = 15,
    ClickerCPS = 12,
    ChatSpamMsg = "Medusa 🐍",
    ChatSpamDelay = 2,
    DashPower = 100,
    HighJumpPower = 150,
    GlideSpeed = 50,
}

-- ╔════════════════════════════════════════╗
-- ║  SECTION 4: GLOBAL STATE (_G.Medusa)  ║
-- ╚════════════════════════════════════════╝

_G.Medusa = {
    Active = true,
    State = State,
    Values = Values,
    Config = Config,
    Connections = {},
    Loops = {},
    ESPObjects = {},
    ScreenGui = nil,
    UIVisible = true,
    ConsoleLog = {},
    SessionStart = tick(),
    Kills = 0,
}

-- ╔════════════════════════════════════════╗
-- ║     SECTION 5: UTILITY FUNCTIONS      ║
-- ╚════════════════════════════════════════╝

local function GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function GetHumanoid()
    local char = GetCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function GetRootPart()
    local char = GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function SafeTween(obj, info, props)
    local success, err = pcall(function()
        TweenService:Create(obj, info, props):Play()
    end)
    return success
end

local function AddConnection(conn)
    table.insert(_G.Medusa.Connections, conn)
    return conn
end

local function ConsoleLog(msg, msgType)
    msgType = msgType or "INFO"
    local timestamp = os.date("%H:%M:%S")
    local entry = string.format("[%s] [%s] %s", timestamp, msgType, msg)
    table.insert(_G.Medusa.ConsoleLog, entry)
    if #_G.Medusa.ConsoleLog > 200 then
        table.remove(_G.Medusa.ConsoleLog, 1)
    end
end

local function GetClosestPlayer(maxDist, fovCheck)
    local closest = nil
    local closestDist = maxDist or 9999
    local root = GetRootPart()
    if not root then return nil end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                if State.TeamCheck and player.Team == LocalPlayer.Team then continue end
                local dist = (root.Position - hrp.Position).Magnitude
                if fovCheck then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                        local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                        if screenDist <= Values.FOVRadius and dist < closestDist then
                            closestDist = dist
                            closest = player
                        end
                    end
                else
                    if dist < closestDist then
                        closestDist = dist
                        closest = player
                    end
                end
            end
        end
    end
    return closest
end

-- ╔════════════════════════════════════════════════════╗
-- ║    SECTION 6: COMBAT v2 MODULE (16 Functions)     ║
-- ╚════════════════════════════════════════════════════╝

local CombatModule = {}

-- 1. Silent Aim
function CombatModule.SilentAim(enabled)
    State.SilentAim = enabled
    if enabled then
        ConsoleLog("Silent Aim ENABLED", "COMBAT")
    else
        ConsoleLog("Silent Aim DISABLED", "COMBAT")
    end
end

-- 2. Aimbot
function CombatModule.Aimbot(enabled)
    State.Aimbot = enabled
    if enabled then
        _G.Medusa.Loops.Aimbot = true
        ConsoleLog("Aimbot ENABLED (Smooth: "..Values.AimbotSmooth..")", "COMBAT")
        task.spawn(function()
            while _G.Medusa.Loops.Aimbot and State.Aimbot do
                local target = GetClosestPlayer(Values.ESPMaxDist, true)
                if target and target.Character then
                    local head = target.Character:FindFirstChild("Head")
                    if head then
                        local targetCF = CFrame.new(Camera.CFrame.Position, head.Position)
                        Camera.CFrame = Camera.CFrame:Lerp(targetCF, 1 / Values.AimbotSmooth)
                    end
                end
                RunService.RenderStepped:Wait()
            end
        end)
    else
        _G.Medusa.Loops.Aimbot = false
        ConsoleLog("Aimbot DISABLED", "COMBAT")
    end
end

-- 3. Kill Aura
function CombatModule.KillAura(enabled)
    State.KillAura = enabled
    if enabled then
        _G.Medusa.Loops.KillAura = true
        ConsoleLog("Kill Aura ENABLED", "COMBAT")
        task.spawn(function()
            while _G.Medusa.Loops.KillAura and State.KillAura do
                local root = GetRootPart()
                if root then
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character then
                            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                            local hum = player.Character:FindFirstChildOfClass("Humanoid")
                            if hrp and hum and hum.Health > 0 then
                                if State.TeamCheck and player.Team == LocalPlayer.Team then continue end
                                local dist = (root.Position - hrp.Position).Magnitude
                                if dist <= Values.Reach then
                                    -- Simulate click on closest tool
                                    local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                                    if tool and tool:FindFirstChild("Handle") then
                                        firetouchinterest(tool.Handle, hrp, 0)
                                        task.wait()
                                        firetouchinterest(tool.Handle, hrp, 1)
                                    end
                                end
                            end
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
    else
        _G.Medusa.Loops.KillAura = false
        ConsoleLog("Kill Aura DISABLED", "COMBAT")
    end
end

-- 4. Auto Parry
function CombatModule.AutoParry(enabled)
    State.AutoParry = enabled
    if enabled then
        _G.Medusa.Loops.AutoParry = true
        ConsoleLog("Auto Parry ENABLED", "COMBAT")
        task.spawn(function()
            while _G.Medusa.Loops.AutoParry and State.AutoParry do
                local root = GetRootPart()
                if root then
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character then
                            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                            local hum = player.Character:FindFirstChildOfClass("Humanoid")
                            if hrp and hum and hum.Health > 0 then
                                local dist = (root.Position - hrp.Position).Magnitude
                                if dist <= 15 then
                                    local anim = hum:FindFirstChildOfClass("Animator")
                                    if anim then
                                        for _, track in pairs(anim:GetPlayingAnimationTracks()) do
                                            if string.find(string.lower(track.Animation.AnimationId), "attack") or
                                               string.find(string.lower(track.Animation.AnimationId), "swing") or
                                               string.find(string.lower(track.Animation.AnimationId), "punch") then
                                                -- Trigger block
                                                local blockRemote = ReplicatedStorage:FindFirstChild("Block") or
                                                    ReplicatedStorage:FindFirstChild("BlockEvent")
                                                if blockRemote then
                                                    blockRemote:FireServer()
                                                end
                                                task.wait(0.3)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                task.wait(0.05)
            end
        end)
    else
        _G.Medusa.Loops.AutoParry = false
        ConsoleLog("Auto Parry DISABLED", "COMBAT")
    end
end

-- 5. Reach Extender
function CombatModule.Reach(enabled)
    State.Reach = enabled
    if enabled then
        _G.Medusa.Loops.Reach = true
        ConsoleLog("Reach ENABLED ("..Values.Reach.." studs)", "COMBAT")
        task.spawn(function()
            while _G.Medusa.Loops.Reach and State.Reach do
                local char = GetCharacter()
                if char then
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool and tool:FindFirstChild("Handle") then
                        local handle = tool.Handle
                        handle.Size = Vector3.new(Values.Reach, Values.Reach, Values.Reach)
                        handle.Massless = true
                        handle.Transparency = 1
                    end
                end
                task.wait(0.1)
            end
        end)
    else
        _G.Medusa.Loops.Reach = false
        local char = GetCharacter()
        if char then
            local tool = char:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChild("Handle") then
                tool.Handle.Size = Vector3.new(1, 1, 1)
                tool.Handle.Transparency = 0
            end
        end
        ConsoleLog("Reach DISABLED", "COMBAT")
    end
end

-- 6. Auto Combo
function CombatModule.AutoCombo(enabled)
    State.AutoCombo = enabled
    if enabled then
        _G.Medusa.Loops.AutoCombo = true
        ConsoleLog("Auto Combo ENABLED", "COMBAT")
        task.spawn(function()
            while _G.Medusa.Loops.AutoCombo and State.AutoCombo do
                local target = GetClosestPlayer(Values.Reach + 5, false)
                if target then
                    mouse1click()
                    task.wait(0.15)
                    mouse1click()
                    task.wait(0.15)
                    mouse1click()
                    task.wait(0.4)
                end
                task.wait(0.1)
            end
        end)
    else
        _G.Medusa.Loops.AutoCombo = false
        ConsoleLog("Auto Combo DISABLED", "COMBAT")
    end
end

-- 7. Trigger Bot
function CombatModule.TriggerBot(enabled)
    State.TriggerBot = enabled
    if enabled then
        _G.Medusa.Loops.TriggerBot = true
        ConsoleLog("Trigger Bot ENABLED", "COMBAT")
        task.spawn(function()
            while _G.Medusa.Loops.TriggerBot and State.TriggerBot do
                local mouse = LocalPlayer:GetMouse()
                if mouse.Target then
                    local targetModel = mouse.Target:FindFirstAncestorOfClass("Model")
                    if targetModel then
                        local targetPlayer = Players:GetPlayerFromCharacter(targetModel)
                        if targetPlayer and targetPlayer ~= LocalPlayer then
                            if State.TeamCheck and targetPlayer.Team == LocalPlayer.Team then
                                task.wait(0.05)
                                continue
                            end
                            mouse1click()
                        end
                    end
                end
                task.wait(0.05)
            end
        end)
    else
        _G.Medusa.Loops.TriggerBot = false
        ConsoleLog("Trigger Bot DISABLED", "COMBAT")
    end
end

-- 8. FOV Circle
function CombatModule.FOVCircle(enabled)
    State.FOVCircle = enabled
    if enabled then
        if not _G.Medusa.FOVCircleDraw then
            _G.Medusa.FOVCircleDraw = Drawing.new("Circle")
            _G.Medusa.FOVCircleDraw.Thickness = 1.5
            _G.Medusa.FOVCircleDraw.NumSides = 64
            _G.Medusa.FOVCircleDraw.Filled = false
            _G.Medusa.FOVCircleDraw.Color = Config.Theme.Primary
            _G.Medusa.FOVCircleDraw.Transparency = 0.7
        end
        _G.Medusa.FOVCircleDraw.Radius = Values.FOVRadius
        _G.Medusa.FOVCircleDraw.Visible = true
        _G.Medusa.Loops.FOVCircle = true
        ConsoleLog("FOV Circle ENABLED (Radius: "..Values.FOVRadius..")", "COMBAT")
        task.spawn(function()
            while _G.Medusa.Loops.FOVCircle and State.FOVCircle do
                _G.Medusa.FOVCircleDraw.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                _G.Medusa.FOVCircleDraw.Radius = Values.FOVRadius
                RunService.RenderStepped:Wait()
            end
        end)
    else
        if _G.Medusa.FOVCircleDraw then
            _G.Medusa.FOVCircleDraw.Visible = false
        end
        _G.Medusa.Loops.FOVCircle = false
        ConsoleLog("FOV Circle DISABLED", "COMBAT")
    end
end

-- 9. Target Strafe
function CombatModule.TargetStrafe(enabled)
    State.TargetStrafe = enabled
    if enabled then
        _G.Medusa.Loops.TargetStrafe = true
        _G.Medusa.StrafeAngle = 0
        ConsoleLog("Target Strafe ENABLED", "COMBAT")
        task.spawn(function()
            while _G.Medusa.Loops.TargetStrafe and State.TargetStrafe do
                local target = GetClosestPlayer(50, false)
                local root = GetRootPart()
                if target and target.Character and root then
                    local hrp = target.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        _G.Medusa.StrafeAngle = _G.Medusa.StrafeAngle + 3
                        local rad = math.rad(_G.Medusa.StrafeAngle)
                        local offset = Vector3.new(
                            math.cos(rad) * Values.TargetStrafeRadius,
                            0,
                            math.sin(rad) * Values.TargetStrafeRadius
                        )
                        local targetPos = hrp.Position + offset
                        root.CFrame = CFrame.new(targetPos, hrp.Position)
                    end
                end
                RunService.RenderStepped:Wait()
            end
        end)
    else
        _G.Medusa.Loops.TargetStrafe = false
        ConsoleLog("Target Strafe DISABLED", "COMBAT")
    end
end

-- 10. Auto Block
function CombatModule.AutoBlock(enabled)
    State.AutoBlock = enabled
    if enabled then
        _G.Medusa.Loops.AutoBlock = true
        ConsoleLog("Auto Block ENABLED", "COMBAT")
        task.spawn(function()
            while _G.Medusa.Loops.AutoBlock and State.AutoBlock do
                local root = GetRootPart()
                if root then
                    local closestDist = 20
                    local shouldBlock = false
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character then
                            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                local dist = (root.Position - hrp.Position).Magnitude
                                if dist < closestDist then
                                    shouldBlock = true
                                end
                            end
                        end
                    end
                    if shouldBlock then
                        local blockRemote = ReplicatedStorage:FindFirstChild("Block") or
                            ReplicatedStorage:FindFirstChild("BlockEvent") or
                            ReplicatedStorage:FindFirstChild("Combat") and ReplicatedStorage.Combat:FindFirstChild("Block")
                        if blockRemote then
                            pcall(function() blockRemote:FireServer(true) end)
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
    else
        _G.Medusa.Loops.AutoBlock = false
        ConsoleLog("Auto Block DISABLED", "COMBAT")
    end
end

-- 11. Click TP
function CombatModule.ClickTP(enabled)
    State.ClickTP = enabled
    if enabled then
        ConsoleLog("Click TP ENABLED (Click anywhere to teleport)", "COMBAT")
        _G.Medusa.ClickTPConn = AddConnection(LocalPlayer:GetMouse().Button1Down:Connect(function()
            if State.ClickTP then
                local mouse = LocalPlayer:GetMouse()
                local root = GetRootPart()
                if root and mouse.Hit then
                    root.CFrame = mouse.Hit + Vector3.new(0, 3, 0)
                end
            end
        end))
    else
        if _G.Medusa.ClickTPConn then
            _G.Medusa.ClickTPConn:Disconnect()
            _G.Medusa.ClickTPConn = nil
        end
        ConsoleLog("Click TP DISABLED", "COMBAT")
    end
end

-- 12. Target Info
function CombatModule.TargetInfo(enabled)
    State.TargetInfo = enabled
    ConsoleLog("Target Info " .. (enabled and "ENABLED" or "DISABLED"), "COMBAT")
end

-- 13. Anti Backstab
function CombatModule.AntiBackstab(enabled)
    State.AntiBackstab = enabled
    if enabled then
        _G.Medusa.Loops.AntiBackstab = true
        ConsoleLog("Anti Backstab ENABLED", "COMBAT")
        task.spawn(function()
            while _G.Medusa.Loops.AntiBackstab and State.AntiBackstab do
                local root = GetRootPart()
                if root then
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character then
                            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                local dist = (root.Position - hrp.Position).Magnitude
                                if dist <= 10 then
                                    local dirToEnemy = (hrp.Position - root.Position).Unit
                                    local lookDir = root.CFrame.LookVector
                                    local dot = dirToEnemy:Dot(lookDir)
                                    if dot < -0.5 then
                                        root.CFrame = CFrame.new(root.Position, hrp.Position)
                                    end
                                end
                            end
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
    else
        _G.Medusa.Loops.AntiBackstab = false
        ConsoleLog("Anti Backstab DISABLED", "COMBAT")
    end
end

-- 14. Auto Clicker
function CombatModule.AutoClicker(enabled)
    State.AutoClicker = enabled
    if enabled then
        _G.Medusa.Loops.AutoClicker = true
        ConsoleLog("Auto Clicker ENABLED ("..Values.ClickerCPS.." CPS)", "COMBAT")
        task.spawn(function()
            while _G.Medusa.Loops.AutoClicker and State.AutoClicker do
                mouse1click()
                task.wait(1 / Values.ClickerCPS)
            end
        end)
    else
        _G.Medusa.Loops.AutoClicker = false
        ConsoleLog("Auto Clicker DISABLED", "COMBAT")
    end
end

-- 15. Combo Lock
function CombatModule.ComboLock(enabled)
    State.ComboLock = enabled
    if enabled then
        _G.Medusa.Loops.ComboLock = true
        ConsoleLog("Combo Lock ENABLED", "COMBAT")
        task.spawn(function()
            while _G.Medusa.Loops.ComboLock and State.ComboLock do
                local target = GetClosestPlayer(20, false)
                local root = GetRootPart()
                if target and target.Character and root then
                    local hrp = target.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        root.CFrame = CFrame.new(root.Position, Vector3.new(hrp.Position.X, root.Position.Y, hrp.Position.Z))
                    end
                end
                RunService.RenderStepped:Wait()
            end
        end)
    else
        _G.Medusa.Loops.ComboLock = false
        ConsoleLog("Combo Lock DISABLED", "COMBAT")
    end
end

-- 16. Hitbox Expander
function CombatModule.HitboxExpander(enabled)
    State.HitboxExpander = enabled
    if enabled then
        _G.Medusa.Loops.HitboxExpander = true
        ConsoleLog("Hitbox Expander ENABLED", "COMBAT")
        task.spawn(function()
            while _G.Medusa.Loops.HitboxExpander and State.HitboxExpander do
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            hrp.Size = Vector3.new(Values.Reach, Values.Reach, Values.Reach)
                            hrp.Transparency = 0.7
                            hrp.CanCollide = false
                            hrp.Material = Enum.Material.ForceField
                            hrp.BrickColor = BrickColor.new("Lime green")
                        end
                    end
                end
                task.wait(0.5)
            end
        end)
    else
        _G.Medusa.Loops.HitboxExpander = false
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.Size = Vector3.new(2, 2, 1)
                    hrp.Transparency = 1
                end
            end
        end
        ConsoleLog("Hitbox Expander DISABLED", "COMBAT")
    end
end

-- ╔════════════════════════════════════════════════════╗
-- ║      SECTION 7: ESP 3D MODULE (16 Functions)      ║
-- ╚════════════════════════════════════════════════════╝

local ESPModule = {}

local function ClearESP()
    for _, obj in pairs(_G.Medusa.ESPObjects) do
        pcall(function()
            if typeof(obj) == "Instance" then
                obj:Destroy()
            elseif type(obj) == "table" and obj.Remove then
                obj:Remove()
            end
        end)
    end
    _G.Medusa.ESPObjects = {}
end

local function CreateESPForPlayer(player)
    if player == LocalPlayer then return end
    if not player.Character then return end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    local hum = player.Character:FindFirstChildOfClass("Humanoid")
    local head = player.Character:FindFirstChild("Head")
    if not hrp or not hum or not head then return end

    local espFolder = Instance.new("Folder")
    espFolder.Name = "MedusaESP_" .. player.Name
    espFolder.Parent = player.Character
    table.insert(_G.Medusa.ESPObjects, espFolder)

    -- Chams / Highlight
    if State.Chams then
        local highlight = Instance.new("Highlight")
        highlight.FillColor = Config.Theme.Primary
        highlight.FillTransparency = 0.7
        highlight.OutlineColor = Config.Theme.Accent
        highlight.OutlineTransparency = 0.3
        highlight.Adornee = player.Character
        highlight.Parent = espFolder
    end

    -- BillboardGui for Name, Health, Distance
    local bb = Instance.new("BillboardGui")
    bb.Adornee = head
    bb.Size = UDim2.new(0, 200, 0, 80)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.Parent = espFolder

    local yOff = 0

    if State.NameESP then
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0, 16)
        nameLabel.Position = UDim2.new(0, 0, 0, yOff)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.DisplayName .. " (@" .. player.Name .. ")"
        nameLabel.TextColor3 = Config.Theme.Primary
        nameLabel.TextStrokeColor3 = Config.Theme.Black
        nameLabel.TextStrokeTransparency = 0.3
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 13
        nameLabel.Parent = bb
        yOff = yOff + 16
    end

    if State.HealthESP then
        local hpBg = Instance.new("Frame")
        hpBg.Size = UDim2.new(0.8, 0, 0, 4)
        hpBg.Position = UDim2.new(0.1, 0, 0, yOff + 2)
        hpBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        hpBg.BorderSizePixel = 0
        hpBg.Parent = bb
        Instance.new("UICorner", hpBg).CornerRadius = UDim.new(0, 2)

        local hpFill = Instance.new("Frame")
        hpFill.Size = UDim2.new(math.clamp(hum.Health / hum.MaxHealth, 0, 1), 0, 1, 0)
        hpFill.BackgroundColor3 = Config.Theme.Primary
        hpFill.BorderSizePixel = 0
        hpFill.Parent = hpBg
        Instance.new("UICorner", hpFill).CornerRadius = UDim.new(0, 2)

        table.insert(_G.Medusa.ESPObjects, hpFill)
        yOff = yOff + 8
    end

    if State.DistanceESP then
        local distLabel = Instance.new("TextLabel")
        distLabel.Size = UDim2.new(1, 0, 0, 14)
        distLabel.Position = UDim2.new(0, 0, 0, yOff + 2)
        distLabel.BackgroundTransparency = 1
        distLabel.Text = "0m"
        distLabel.TextColor3 = Config.Theme.TextDim
        distLabel.TextStrokeColor3 = Config.Theme.Black
        distLabel.TextStrokeTransparency = 0.5
        distLabel.Font = Enum.Font.Gotham
        distLabel.TextSize = 11
        distLabel.Name = "DistLabel"
        distLabel.Parent = bb
    end
end

local function UpdateESPLoop()
    _G.Medusa.Loops.ESP = true
    task.spawn(function()
        while _G.Medusa.Loops.ESP do
            local root = GetRootPart()
            if root then
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                        local hum = player.Character:FindFirstChildOfClass("Humanoid")
                        local espFolder = player.Character:FindFirstChild("MedusaESP_" .. player.Name)
                        if espFolder and hrp and hum then
                            local dist = math.floor((root.Position - hrp.Position).Magnitude)
                            if dist > Values.ESPMaxDist then
                                espFolder.Parent = nil
                            else
                                espFolder.Parent = player.Character
                                -- Update distance
                                local bb = espFolder:FindFirstChildOfClass("BillboardGui")
                                if bb then
                                    local dl = bb:FindFirstChild("DistLabel")
                                    if dl then dl.Text = dist .. "m" end
                                end
                            end
                        end
                    end
                end
            end
            task.wait(0.2)
        end
    end)
end

-- 1. Box ESP
function ESPModule.BoxESP(enabled)
    State.BoxESP = enabled
    ConsoleLog("Box ESP " .. (enabled and "ENABLED" or "DISABLED"), "ESP")
    if enabled then
        _G.Medusa.Loops.BoxESP = true
        task.spawn(function()
            while _G.Medusa.Loops.BoxESP and State.BoxESP do
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local existingBox = player.Character:FindFirstChild("MedusaBox")
                            if not existingBox then
                                local box = Instance.new("BoxHandleAdornment")
                                box.Name = "MedusaBox"
                                box.Adornee = hrp
                                box.Size = Vector3.new(4, 5, 1)
                                box.Color3 = Config.Theme.Primary
                                box.Transparency = 0.6
                                box.AlwaysOnTop = true
                                box.ZIndex = 5
                                box.Parent = player.Character
                                table.insert(_G.Medusa.ESPObjects, box)
                            end
                        end
                    end
                end
                task.wait(1)
            end
        end)
    else
        _G.Medusa.Loops.BoxESP = false
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character then
                local box = player.Character:FindFirstChild("MedusaBox")
                if box then box:Destroy() end
            end
        end
    end
end

-- 2. Name ESP
function ESPModule.NameESP(enabled)
    State.NameESP = enabled
    ConsoleLog("Name ESP " .. (enabled and "ENABLED" or "DISABLED"), "ESP")
    ClearESP()
    if enabled then
        for _, p in pairs(Players:GetPlayers()) do CreateESPForPlayer(p) end
        UpdateESPLoop()
    else
        _G.Medusa.Loops.ESP = false
    end
end

-- 3. Health ESP
function ESPModule.HealthESP(enabled)
    State.HealthESP = enabled
    ConsoleLog("Health ESP " .. (enabled and "ENABLED" or "DISABLED"), "ESP")
    ClearESP()
    if enabled or State.NameESP or State.DistanceESP then
        for _, p in pairs(Players:GetPlayers()) do CreateESPForPlayer(p) end
        UpdateESPLoop()
    end
end

-- 4. Distance ESP
function ESPModule.DistanceESP(enabled)
    State.DistanceESP = enabled
    ConsoleLog("Distance ESP " .. (enabled and "ENABLED" or "DISABLED"), "ESP")
    ClearESP()
    if enabled or State.NameESP or State.HealthESP then
        for _, p in pairs(Players:GetPlayers()) do CreateESPForPlayer(p) end
        UpdateESPLoop()
    end
end

-- 5. Tracers
function ESPModule.Tracers(enabled)
    State.Tracers = enabled
    if enabled then
        _G.Medusa.Loops.Tracers = true
        _G.Medusa.TracerLines = _G.Medusa.TracerLines or {}
        ConsoleLog("Tracers ENABLED", "ESP")
        task.spawn(function()
            while _G.Medusa.Loops.Tracers and State.Tracers do
                for _, line in pairs(_G.Medusa.TracerLines) do
                    pcall(function() line:Remove() end)
                end
                _G.Medusa.TracerLines = {}
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                            if onScreen then
                                pcall(function()
                                    local line = Drawing.new("Line")
                                    line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                                    line.To = Vector2.new(screenPos.X, screenPos.Y)
                                    line.Color = Config.Theme.Primary
                                    line.Thickness = 1.5
                                    line.Transparency = 0.7
                                    line.Visible = true
                                    table.insert(_G.Medusa.TracerLines, line)
                                end)
                            end
                        end
                    end
                end
                RunService.RenderStepped:Wait()
            end
            for _, line in pairs(_G.Medusa.TracerLines or {}) do
                pcall(function() line:Remove() end)
            end
            _G.Medusa.TracerLines = {}
        end)
    else
        _G.Medusa.Loops.Tracers = false
        ConsoleLog("Tracers DISABLED", "ESP")
    end
end

-- 6. Chams
function ESPModule.Chams(enabled)
    State.Chams = enabled
    ConsoleLog("Chams " .. (enabled and "ENABLED" or "DISABLED"), "ESP")
    -- Remove existing
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            local folder = player.Character:FindFirstChild("MedusaESP_" .. player.Name)
            if folder then
                local h = folder:FindFirstChildOfClass("Highlight")
                if h then h:Destroy() end
            end
        end
    end
    if enabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local folder = player.Character:FindFirstChild("MedusaESP_" .. player.Name)
                if not folder then
                    folder = Instance.new("Folder")
                    folder.Name = "MedusaESP_" .. player.Name
                    folder.Parent = player.Character
                    table.insert(_G.Medusa.ESPObjects, folder)
                end
                local highlight = Instance.new("Highlight")
                highlight.FillColor = Config.Theme.Primary
                highlight.FillTransparency = 0.7
                highlight.OutlineColor = Config.Theme.Accent
                highlight.OutlineTransparency = 0.3
                highlight.Adornee = player.Character
                highlight.Parent = folder
            end
        end
    end
end

-- 7. Head Dot
function ESPModule.HeadDot(enabled)
    State.HeadDot = enabled
    if enabled then
        _G.Medusa.Loops.HeadDot = true
        _G.Medusa.HeadDots = _G.Medusa.HeadDots or {}
        ConsoleLog("Head Dot ENABLED", "ESP")
        task.spawn(function()
            while _G.Medusa.Loops.HeadDot and State.HeadDot do
                for _, dot in pairs(_G.Medusa.HeadDots) do
                    pcall(function() dot:Remove() end)
                end
                _G.Medusa.HeadDots = {}
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local head = player.Character:FindFirstChild("Head")
                        if head then
                            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                            if onScreen then
                                pcall(function()
                                    local dot = Drawing.new("Circle")
                                    dot.Position = Vector2.new(screenPos.X, screenPos.Y)
                                    dot.Radius = 3
                                    dot.Color = Config.Theme.Primary
                                    dot.Filled = true
                                    dot.Thickness = 1
                                    dot.Visible = true
                                    table.insert(_G.Medusa.HeadDots, dot)
                                end)
                            end
                        end
                    end
                end
                RunService.RenderStepped:Wait()
            end
            for _, dot in pairs(_G.Medusa.HeadDots or {}) do
                pcall(function() dot:Remove() end)
            end
        end)
    else
        _G.Medusa.Loops.HeadDot = false
        ConsoleLog("Head Dot DISABLED", "ESP")
    end
end

-- 8. Skeleton ESP
function ESPModule.SkeletonESP(enabled)
    State.SkeletonESP = enabled
    ConsoleLog("Skeleton ESP " .. (enabled and "ENABLED" or "DISABLED"), "ESP")
    if enabled then
        _G.Medusa.Loops.Skeleton = true
        _G.Medusa.SkeletonLines = _G.Medusa.SkeletonLines or {}
        task.spawn(function()
            local bones = {
                {"Head", "UpperTorso"},
                {"UpperTorso", "LowerTorso"},
                {"UpperTorso", "LeftUpperArm"},
                {"UpperTorso", "RightUpperArm"},
                {"LeftUpperArm", "LeftLowerArm"},
                {"RightUpperArm", "RightLowerArm"},
                {"LeftLowerArm", "LeftHand"},
                {"RightLowerArm", "RightHand"},
                {"LowerTorso", "LeftUpperLeg"},
                {"LowerTorso", "RightUpperLeg"},
                {"LeftUpperLeg", "LeftLowerLeg"},
                {"RightUpperLeg", "RightLowerLeg"},
                {"LeftLowerLeg", "LeftFoot"},
                {"RightLowerLeg", "RightFoot"},
            }
            while _G.Medusa.Loops.Skeleton and State.SkeletonESP do
                for _, line in pairs(_G.Medusa.SkeletonLines) do
                    pcall(function() line:Remove() end)
                end
                _G.Medusa.SkeletonLines = {}
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        for _, bone in pairs(bones) do
                            local p1 = player.Character:FindFirstChild(bone[1])
                            local p2 = player.Character:FindFirstChild(bone[2])
                            if p1 and p2 then
                                local s1, o1 = Camera:WorldToViewportPoint(p1.Position)
                                local s2, o2 = Camera:WorldToViewportPoint(p2.Position)
                                if o1 and o2 then
                                    pcall(function()
                                        local line = Drawing.new("Line")
                                        line.From = Vector2.new(s1.X, s1.Y)
                                        line.To = Vector2.new(s2.X, s2.Y)
                                        line.Color = Config.Theme.Primary
                                        line.Thickness = 1.5
                                        line.Visible = true
                                        table.insert(_G.Medusa.SkeletonLines, line)
                                    end)
                                end
                            end
                        end
                    end
                end
                RunService.RenderStepped:Wait()
            end
            for _, line in pairs(_G.Medusa.SkeletonLines or {}) do
                pcall(function() line:Remove() end)
            end
        end)
    else
        _G.Medusa.Loops.Skeleton = false
    end
end

-- 9. Item ESP
function ESPModule.ItemESP(enabled)
    State.ItemESP = enabled
    ConsoleLog("Item ESP " .. (enabled and "ENABLED" or "DISABLED"), "ESP")
    if enabled then
        _G.Medusa.Loops.ItemESP = true
        task.spawn(function()
            while _G.Medusa.Loops.ItemESP and State.ItemESP do
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Tool") or (obj:IsA("Model") and obj:FindFirstChild("Handle")) then
                        if not obj:FindFirstChild("MedusaItemESP") then
                            local bb = Instance.new("BillboardGui")
                            bb.Name = "MedusaItemESP"
                            bb.Adornee = obj:IsA("Tool") and (obj:FindFirstChild("Handle") or obj) or obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")
                            bb.Size = UDim2.new(0, 150, 0, 20)
                            bb.StudsOffset = Vector3.new(0, 2, 0)
                            bb.AlwaysOnTop = true
                            bb.Parent = obj

                            local label = Instance.new("TextLabel")
                            label.Size = UDim2.new(1, 0, 1, 0)
                            label.BackgroundTransparency = 1
                            label.Text = "📦 " .. obj.Name
                            label.TextColor3 = Config.Theme.Yellow
                            label.TextStrokeColor3 = Config.Theme.Black
                            label.TextStrokeTransparency = 0.3
                            label.Font = Enum.Font.GothamBold
                            label.TextSize = 12
                            label.Parent = bb

                            table.insert(_G.Medusa.ESPObjects, bb)
                        end
                    end
                end
                task.wait(2)
            end
        end)
    else
        _G.Medusa.Loops.ItemESP = false
        for _, obj in pairs(Workspace:GetDescendants()) do
            local esp = obj:FindFirstChild("MedusaItemESP")
            if esp then esp:Destroy() end
        end
    end
end

-- 10. NPC ESP
function ESPModule.NPCESP(enabled)
    State.NPCESP = enabled
    ConsoleLog("NPC ESP " .. (enabled and "ENABLED" or "DISABLED"), "ESP")
    if enabled then
        _G.Medusa.Loops.NPCESP = true
        task.spawn(function()
            while _G.Medusa.Loops.NPCESP and State.NPCESP do
                for _, model in pairs(Workspace:GetDescendants()) do
                    if model:IsA("Model") and model:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(model) then
                        if not model:FindFirstChild("MedusaNPCESP") then
                            local head = model:FindFirstChild("Head")
                            if head then
                                local bb = Instance.new("BillboardGui")
                                bb.Name = "MedusaNPCESP"
                                bb.Adornee = head
                                bb.Size = UDim2.new(0, 150, 0, 20)
                                bb.StudsOffset = Vector3.new(0, 2.5, 0)
                                bb.AlwaysOnTop = true
                                bb.Parent = model

                                local label = Instance.new("TextLabel")
                                label.Size = UDim2.new(1, 0, 1, 0)
                                label.BackgroundTransparency = 1
                                label.Text = "👾 " .. model.Name
                                label.TextColor3 = Config.Theme.Red
                                label.TextStrokeColor3 = Config.Theme.Black
                                label.TextStrokeTransparency = 0.3
                                label.Font = Enum.Font.GothamBold
                                label.TextSize = 12
                                label.Parent = bb

                                table.insert(_G.Medusa.ESPObjects, bb)
                            end
                        end
                    end
                end
                task.wait(3)
            end
        end)
    else
        _G.Medusa.Loops.NPCESP = false
        for _, model in pairs(Workspace:GetDescendants()) do
            local esp = model:FindFirstChild("MedusaNPCESP")
            if esp then esp:Destroy() end
        end
    end
end

-- 11. Corner Box
function ESPModule.CornerBox(enabled)
    State.CornerBox = enabled
    ConsoleLog("Corner Box ESP " .. (enabled and "ENABLED" or "DISABLED"), "ESP")
end

-- 12. Team Check
function ESPModule.TeamCheck(enabled)
    State.TeamCheck = enabled
    ConsoleLog("Team Check " .. (enabled and "ENABLED" or "DISABLED"), "ESP")
end

-- 13. Visible Check
function ESPModule.VisibleCheck(enabled)
    State.VisibleCheck = enabled
    ConsoleLog("Visible Check " .. (enabled and "ENABLED" or "DISABLED"), "ESP")
end

-- 14. Crosshair
function ESPModule.Crosshair(enabled)
    State.Crosshair = enabled
    if enabled then
        ConsoleLog("Crosshair ENABLED", "ESP")
        _G.Medusa.CrosshairLines = _G.Medusa.CrosshairLines or {}
        for _, l in pairs(_G.Medusa.CrosshairLines) do pcall(function() l:Remove() end) end
        _G.Medusa.CrosshairLines = {}
        _G.Medusa.Loops.Crosshair = true
        task.spawn(function()
            local lines = {}
            for i = 1, 4 do
                pcall(function()
                    local l = Drawing.new("Line")
                    l.Color = Config.Theme.Primary
                    l.Thickness = 1.5
                    l.Visible = true
                    lines[i] = l
                end)
            end
            _G.Medusa.CrosshairLines = lines
            while _G.Medusa.Loops.Crosshair and State.Crosshair do
                local cx = Camera.ViewportSize.X / 2
                local cy = Camera.ViewportSize.Y / 2
                local gap = 5
                local size = 12
                if lines[1] then
                    lines[1].From = Vector2.new(cx - size, cy); lines[1].To = Vector2.new(cx - gap, cy)
                end
                if lines[2] then
                    lines[2].From = Vector2.new(cx + gap, cy); lines[2].To = Vector2.new(cx + size, cy)
                end
                if lines[3] then
                    lines[3].From = Vector2.new(cx, cy - size); lines[3].To = Vector2.new(cx, cy - gap)
                end
                if lines[4] then
                    lines[4].From = Vector2.new(cx, cy + gap); lines[4].To = Vector2.new(cx, cy + size)
                end
                RunService.RenderStepped:Wait()
            end
            for _, l in pairs(lines) do pcall(function() l:Remove() end) end
        end)
    else
        _G.Medusa.Loops.Crosshair = false
        ConsoleLog("Crosshair DISABLED", "ESP")
    end
end

-- 15. FOV Display
function ESPModule.FOVDisplay(enabled)
    State.FOVDisplay = enabled
    CombatModule.FOVCircle(enabled)
end

-- 16. Radar ESP
function ESPModule.RadarESP(enabled)
    State.RadarESP = enabled
    ConsoleLog("Radar ESP " .. (enabled and "ENABLED" or "DISABLED"), "ESP")
end

-- ╔════════════════════════════════════════════════════╗
-- ║    SECTION 8: MOVEMENT MODULE (16 Functions)      ║
-- ╚════════════════════════════════════════════════════╝

local MovementModule = {}

-- 1. WalkSpeed
function MovementModule.WalkSpeed(enabled)
    State.WalkSpeedOn = enabled
    if enabled then
        _G.Medusa.Loops.WalkSpeed = true
        ConsoleLog("WalkSpeed ENABLED ("..Values.WalkSpeed..")", "MOVE")
        task.spawn(function()
            while _G.Medusa.Loops.WalkSpeed and State.WalkSpeedOn do
                local hum = GetHumanoid()
                if hum then hum.WalkSpeed = Values.WalkSpeed end
                task.wait(0.1)
            end
        end)
    else
        _G.Medusa.Loops.WalkSpeed = false
        local hum = GetHumanoid()
        if hum then hum.WalkSpeed = Config.Defaults.WalkSpeed end
        ConsoleLog("WalkSpeed DISABLED (Reset to "..Config.Defaults.WalkSpeed..")", "MOVE")
    end
end

-- 2. JumpPower
function MovementModule.JumpPower(enabled)
    State.JumpPowerOn = enabled
    if enabled then
        _G.Medusa.Loops.JumpPower = true
        ConsoleLog("JumpPower ENABLED ("..Values.JumpPower..")", "MOVE")
        task.spawn(function()
            while _G.Medusa.Loops.JumpPower and State.JumpPowerOn do
                local hum = GetHumanoid()
                if hum then
                    hum.UseJumpPower = true
                    hum.JumpPower = Values.JumpPower
                end
                task.wait(0.1)
            end
        end)
    else
        _G.Medusa.Loops.JumpPower = false
        local hum = GetHumanoid()
        if hum then hum.JumpPower = Config.Defaults.JumpPower end
        ConsoleLog("JumpPower DISABLED (Reset to "..Config.Defaults.JumpPower..")", "MOVE")
    end
end

-- 3. Fly (CFrame-based)
function MovementModule.Fly(enabled)
    State.Fly = enabled
    if enabled then
        ConsoleLog("Fly ENABLED (Speed: "..Values.FlySpeed..")", "MOVE")
        local root = GetRootPart()
        local hum = GetHumanoid()
        if not root or not hum then return end

        local bv = Instance.new("BodyVelocity")
        bv.Name = "MedusaFly"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Parent = root

        local bg = Instance.new("BodyGyro")
        bg.Name = "MedusaGyro"
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.D = 200
        bg.P = 10000
        bg.Parent = root

        _G.Medusa.FlyBV = bv
        _G.Medusa.FlyBG = bg
        _G.Medusa.Loops.Fly = true

        hum.PlatformStand = true

        AddConnection(RunService.RenderStepped:Connect(function()
            if not _G.Medusa.Loops.Fly or not State.Fly then return end
            if not root or not root.Parent then return end

            local dir = Vector3.new(0, 0, 0)
            local camCF = Camera.CFrame

            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + camCF.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - camCF.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - camCF.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + camCF.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end

            if dir.Magnitude > 0 then
                dir = dir.Unit * Values.FlySpeed
            end

            bv.Velocity = dir
            bg.CFrame = camCF
        end))
    else
        _G.Medusa.Loops.Fly = false
        if _G.Medusa.FlyBV then _G.Medusa.FlyBV:Destroy() _G.Medusa.FlyBV = nil end
        if _G.Medusa.FlyBG then _G.Medusa.FlyBG:Destroy() _G.Medusa.FlyBG = nil end
        local hum = GetHumanoid()
        if hum then hum.PlatformStand = false end
        ConsoleLog("Fly DISABLED", "MOVE")
    end
end

-- 4. Noclip
function MovementModule.Noclip(enabled)
    State.Noclip = enabled
    if enabled then
        _G.Medusa.Loops.Noclip = true
        ConsoleLog("Noclip ENABLED", "MOVE")
        AddConnection(RunService.Stepped:Connect(function()
            if not _G.Medusa.Loops.Noclip or not State.Noclip then return end
            local char = GetCharacter()
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end))
    else
        _G.Medusa.Loops.Noclip = false
        ConsoleLog("Noclip DISABLED", "MOVE")
    end
end

-- 5. Infinite Jump
function MovementModule.InfiniteJump(enabled)
    State.InfiniteJump = enabled
    if enabled then
        ConsoleLog("Infinite Jump ENABLED", "MOVE")
        _G.Medusa.InfJumpConn = AddConnection(UserInputService.JumpRequest:Connect(function()
            if State.InfiniteJump then
                local hum = GetHumanoid()
                if hum then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end))
    else
        if _G.Medusa.InfJumpConn then
            _G.Medusa.InfJumpConn:Disconnect()
            _G.Medusa.InfJumpConn = nil
        end
        ConsoleLog("Infinite Jump DISABLED", "MOVE")
    end
end

-- 6. Speed Glitch
function MovementModule.SpeedGlitch(enabled)
    State.SpeedGlitch = enabled
    if enabled then
        _G.Medusa.Loops.SpeedGlitch = true
        ConsoleLog("Speed Glitch ENABLED", "MOVE")
        task.spawn(function()
            while _G.Medusa.Loops.SpeedGlitch and State.SpeedGlitch do
                local root = GetRootPart()
                local hum = GetHumanoid()
                if root and hum and hum.MoveDirection.Magnitude > 0 then
                    root.CFrame = root.CFrame + hum.MoveDirection * (Values.WalkSpeed / 16)
                end
                RunService.RenderStepped:Wait()
            end
        end)
    else
        _G.Medusa.Loops.SpeedGlitch = false
        ConsoleLog("Speed Glitch DISABLED", "MOVE")
    end
end

-- 7. Long Jump
function MovementModule.LongJump(enabled)
    State.LongJump = enabled
    if enabled then
        _G.Medusa.Loops.LongJump = true
        ConsoleLog("Long Jump ENABLED", "MOVE")
        task.spawn(function()
            while _G.Medusa.Loops.LongJump and State.LongJump do
                local hum = GetHumanoid()
                local root = GetRootPart()
                if hum and root then
                    if hum:GetState() == Enum.HumanoidStateType.Freefall then
                        root.Velocity = Vector3.new(root.Velocity.X * 1.02, root.Velocity.Y, root.Velocity.Z * 1.02)
                    end
                end
                RunService.RenderStepped:Wait()
            end
        end)
    else
        _G.Medusa.Loops.LongJump = false
        ConsoleLog("Long Jump DISABLED", "MOVE")
    end
end

-- 8. High Jump
function MovementModule.HighJump(enabled)
    State.HighJump = enabled
    if enabled then
        _G.Medusa.Loops.HighJump = true
        ConsoleLog("High Jump ENABLED ("..Values.HighJumpPower..")", "MOVE")
        task.spawn(function()
            while _G.Medusa.Loops.HighJump and State.HighJump do
                local hum = GetHumanoid()
                if hum then
                    hum.UseJumpPower = true
                    hum.JumpPower = Values.HighJumpPower
                end
                task.wait(0.1)
            end
        end)
    else
        _G.Medusa.Loops.HighJump = false
        local hum = GetHumanoid()
        if hum then hum.JumpPower = Config.Defaults.JumpPower end
        ConsoleLog("High Jump DISABLED", "MOVE")
    end
end

-- 9. Spider (Wall Climb)
function MovementModule.Spider(enabled)
    State.Spider = enabled
    if enabled then
        _G.Medusa.Loops.Spider = true
        ConsoleLog("Spider (Wall Climb) ENABLED", "MOVE")
        task.spawn(function()
            while _G.Medusa.Loops.Spider and State.Spider do
                local root = GetRootPart()
                local hum = GetHumanoid()
                if root and hum then
                    local ray = Ray.new(root.Position, root.CFrame.LookVector * 3)
                    local hit = Workspace:FindPartOnRay(ray, GetCharacter())
                    if hit then
                        local bv = root:FindFirstChild("MedusaSpider")
                        if not bv then
                            bv = Instance.new("BodyVelocity")
                            bv.Name = "MedusaSpider"
                            bv.MaxForce = Vector3.new(0, math.huge, 0)
                            bv.Parent = root
                        end
                        bv.Velocity = Vector3.new(0, Values.WalkSpeed, 0)
                    else
                        local bv = root:FindFirstChild("MedusaSpider")
                        if bv then bv:Destroy() end
                    end
                end
                RunService.RenderStepped:Wait()
            end
            local root = GetRootPart()
            if root then
                local bv = root:FindFirstChild("MedusaSpider")
                if bv then bv:Destroy() end
            end
        end)
    else
        _G.Medusa.Loops.Spider = false
        ConsoleLog("Spider DISABLED", "MOVE")
    end
end

-- 10. Phase
function MovementModule.Phase(enabled)
    State.Phase = enabled
    if enabled then
        _G.Medusa.Loops.Phase = true
        ConsoleLog("Phase ENABLED", "MOVE")
        task.spawn(function()
            while _G.Medusa.Loops.Phase and State.Phase do
                local root = GetRootPart()
                local hum = GetHumanoid()
                if root and hum and hum.MoveDirection.Magnitude > 0 then
                    root.CFrame = root.CFrame + hum.MoveDirection * 1.5
                end
                RunService.RenderStepped:Wait()
            end
        end)
    else
        _G.Medusa.Loops.Phase = false
        ConsoleLog("Phase DISABLED", "MOVE")
    end
end

-- 11. TP to Mouse
function MovementModule.TPtoMouse(enabled)
    State.TPtoMouse = enabled
    if enabled then
        ConsoleLog("TP to Mouse ENABLED (Click to TP)", "MOVE")
        _G.Medusa.TPMouseConn = AddConnection(LocalPlayer:GetMouse().Button1Down:Connect(function()
            if State.TPtoMouse then
                local mouse = LocalPlayer:GetMouse()
                local root = GetRootPart()
                if root and mouse.Hit then
                    root.CFrame = mouse.Hit + Vector3.new(0, 5, 0)
                end
            end
        end))
    else
        if _G.Medusa.TPMouseConn then
            _G.Medusa.TPMouseConn:Disconnect()
            _G.Medusa.TPMouseConn = nil
        end
        ConsoleLog("TP to Mouse DISABLED", "MOVE")
    end
end

-- 12. Auto Walk
function MovementModule.AutoWalk(enabled)
    State.AutoWalk = enabled
    if enabled then
        _G.Medusa.Loops.AutoWalk = true
        ConsoleLog("Auto Walk ENABLED", "MOVE")
        task.spawn(function()
            while _G.Medusa.Loops.AutoWalk and State.AutoWalk do
                local hum = GetHumanoid()
                local root = GetRootPart()
                if hum and root then
                    hum:Move(root.CFrame.LookVector, false)
                end
                RunService.RenderStepped:Wait()
            end
        end)
    else
        _G.Medusa.Loops.AutoWalk = false
        ConsoleLog("Auto Walk DISABLED", "MOVE")
    end
end

-- 13. Bunny Hop
function MovementModule.BunnyHop(enabled)
    State.BunnyHop = enabled
    if enabled then
        _G.Medusa.Loops.BunnyHop = true
        ConsoleLog("Bunny Hop ENABLED", "MOVE")
        task.spawn(function()
            while _G.Medusa.Loops.BunnyHop and State.BunnyHop do
                local hum = GetHumanoid()
                if hum and hum:GetState() ~= Enum.HumanoidStateType.Freefall then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
                task.wait(0.15)
            end
        end)
    else
        _G.Medusa.Loops.BunnyHop = false
        ConsoleLog("Bunny Hop DISABLED", "MOVE")
    end
end

-- 14. Glide
function MovementModule.Glide(enabled)
    State.Glide = enabled
    if enabled then
        _G.Medusa.Loops.Glide = true
        ConsoleLog("Glide ENABLED", "MOVE")
        task.spawn(function()
            while _G.Medusa.Loops.Glide and State.Glide do
                local root = GetRootPart()
                local hum = GetHumanoid()
                if root and hum and hum:GetState() == Enum.HumanoidStateType.Freefall then
                    root.Velocity = Vector3.new(root.Velocity.X, math.max(root.Velocity.Y, -5), root.Velocity.Z)
                end
                RunService.RenderStepped:Wait()
            end
        end)
    else
        _G.Medusa.Loops.Glide = false
        ConsoleLog("Glide DISABLED", "MOVE")
    end
end

-- 15. Dash
function MovementModule.Dash(enabled)
    State.Dash = enabled
    if enabled then
        ConsoleLog("Dash ENABLED (Press Q to dash)", "MOVE")
        _G.Medusa.DashConn = AddConnection(UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.KeyCode == Enum.KeyCode.Q and State.Dash then
                local root = GetRootPart()
                local hum = GetHumanoid()
                if root and hum then
                    local dashDir = hum.MoveDirection
                    if dashDir.Magnitude < 0.1 then dashDir = root.CFrame.LookVector end
                    root.Velocity = dashDir * Values.DashPower + Vector3.new(0, 20, 0)
                    ConsoleLog("Dash!", "MOVE")
                end
            end
        end))
    else
        if _G.Medusa.DashConn then
            _G.Medusa.DashConn:Disconnect()
            _G.Medusa.DashConn = nil
        end
        ConsoleLog("Dash DISABLED", "MOVE")
    end
end

-- 16. Anchor
function MovementModule.Anchor(enabled)
    State.Anchor = enabled
    local root = GetRootPart()
    if root then
        root.Anchored = enabled
    end
    ConsoleLog("Anchor " .. (enabled and "ENABLED" or "DISABLED"), "MOVE")
end

-- ╔════════════════════════════════════════════════════╗
-- ║     SECTION 9: WORLD MODULE (16 Functions)        ║
-- ╚════════════════════════════════════════════════════╝

local WorldModule = {}

-- Store original lighting
local OriginalLighting = {
    Ambient = Lighting.Ambient,
    Brightness = Lighting.Brightness,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart,
    ClockTime = Lighting.ClockTime,
    GlobalShadows = Lighting.GlobalShadows,
}

-- 1. Fullbright
function WorldModule.Fullbright(enabled)
    State.Fullbright = enabled
    if enabled then
        _G.Medusa.Loops.Fullbright = true
        ConsoleLog("Fullbright ENABLED", "WORLD")
        task.spawn(function()
            while _G.Medusa.Loops.Fullbright and State.Fullbright do
                Lighting.Ambient = Color3.fromRGB(200, 200, 200)
                Lighting.Brightness = 2
                Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
                Lighting.FogEnd = 100000
                Lighting.GlobalShadows = false
                task.wait(0.5)
            end
        end)
    else
        _G.Medusa.Loops.Fullbright = false
        Lighting.Ambient = OriginalLighting.Ambient
        Lighting.Brightness = OriginalLighting.Brightness
        Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
        Lighting.FogEnd = OriginalLighting.FogEnd
        Lighting.GlobalShadows = OriginalLighting.GlobalShadows
        ConsoleLog("Fullbright DISABLED", "WORLD")
    end
end

-- 2. Anti-Fog
function WorldModule.AntiFog(enabled)
    State.AntiFog = enabled
    if enabled then
        _G.Medusa.Loops.AntiFog = true
        ConsoleLog("Anti-Fog ENABLED", "WORLD")
        task.spawn(function()
            while _G.Medusa.Loops.AntiFog and State.AntiFog do
                Lighting.FogEnd = 100000
                Lighting.FogStart = 100000
                for _, effect in pairs(Lighting:GetDescendants()) do
                    if effect:IsA("Atmosphere") then
                        effect.Density = 0
                    end
                end
                task.wait(1)
            end
        end)
    else
        _G.Medusa.Loops.AntiFog = false
        Lighting.FogEnd = OriginalLighting.FogEnd
        Lighting.FogStart = OriginalLighting.FogStart
        ConsoleLog("Anti-Fog DISABLED", "WORLD")
    end
end

-- 3. Day Time
function WorldModule.DayTime(enabled)
    State.DayTime = enabled
    if enabled then
        State.NightTime = false
        _G.Medusa.Loops.DayTime = true
        ConsoleLog("Day Time ENABLED", "WORLD")
        task.spawn(function()
            while _G.Medusa.Loops.DayTime and State.DayTime do
                Lighting.ClockTime = 14
                task.wait(1)
            end
        end)
    else
        _G.Medusa.Loops.DayTime = false
        Lighting.ClockTime = OriginalLighting.ClockTime
        ConsoleLog("Day Time DISABLED", "WORLD")
    end
end

-- 4. Night Time
function WorldModule.NightTime(enabled)
    State.NightTime = enabled
    if enabled then
        State.DayTime = false
        _G.Medusa.Loops.NightTime = true
        ConsoleLog("Night Time ENABLED", "WORLD")
        task.spawn(function()
            while _G.Medusa.Loops.NightTime and State.NightTime do
                Lighting.ClockTime = 0
                task.wait(1)
            end
        end)
    else
        _G.Medusa.Loops.NightTime = false
        Lighting.ClockTime = OriginalLighting.ClockTime
        ConsoleLog("Night Time DISABLED", "WORLD")
    end
end

-- 5. No Weather
function WorldModule.NoWeather(enabled)
    State.NoWeather = enabled
    ConsoleLog("No Weather " .. (enabled and "ENABLED" or "DISABLED"), "WORLD")
    if enabled then
        for _, effect in pairs(Lighting:GetDescendants()) do
            if effect:IsA("Atmosphere") or effect:IsA("Clouds") or effect:IsA("Sky") then
                effect.Parent = nil
                table.insert(_G.Medusa.ESPObjects, {Type = "Weather", Object = effect, OrigParent = Lighting})
            end
        end
        for _, cloud in pairs(Workspace:FindFirstChildOfClass("Terrain"):GetChildren()) do
            if cloud:IsA("Clouds") then
                cloud.Parent = nil
            end
        end
    end
end

-- 6. Remove Effects
function WorldModule.RemoveEffects(enabled)
    State.RemoveEffects = enabled
    ConsoleLog("Remove Effects " .. (enabled and "ENABLED" or "DISABLED"), "WORLD")
    if enabled then
        for _, effect in pairs(Lighting:GetChildren()) do
            if effect:IsA("PostEffect") or effect:IsA("BlurEffect") or
               effect:IsA("BloomEffect") or effect:IsA("SunRaysEffect") or
               effect:IsA("ColorCorrectionEffect") or effect:IsA("DepthOfFieldEffect") then
                effect.Enabled = false
            end
        end
        for _, effect in pairs(Camera:GetChildren()) do
            if effect:IsA("PostEffect") or effect:IsA("BlurEffect") or
               effect:IsA("BloomEffect") or effect:IsA("ColorCorrectionEffect") then
                effect.Enabled = false
            end
        end
    else
        for _, effect in pairs(Lighting:GetChildren()) do
            if effect:IsA("PostEffect") or effect:IsA("BlurEffect") or
               effect:IsA("BloomEffect") or effect:IsA("SunRaysEffect") or
               effect:IsA("ColorCorrectionEffect") or effect:IsA("DepthOfFieldEffect") then
                effect.Enabled = true
            end
        end
    end
end

-- 7. Anti-Lag
function WorldModule.AntiLag(enabled)
    State.AntiLag = enabled
    ConsoleLog("Anti-Lag " .. (enabled and "ENABLED" or "DISABLED"), "WORLD")
    if enabled then
        local count = 0
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or
               obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") or
               obj:IsA("Explosion") then
                obj.Enabled = false
                count = count + 1
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 1
                count = count + 1
            elseif obj:IsA("MeshPart") or obj:IsA("UnionOperation") then
                obj.RenderFidelity = Enum.RenderFidelity.Performance
            end
        end
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "🐍 Anti-Lag",
            Text = "Removed " .. count .. " effects",
            Duration = 3
        })
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    else
        settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
    end
end

-- 8. No Invisible Walls
function WorldModule.NoInvisWalls(enabled)
    State.NoInvisWalls = enabled
    ConsoleLog("No Invisible Walls " .. (enabled and "ENABLED" or "DISABLED"), "WORLD")
    if enabled then
        for _, part in pairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") and part.Transparency >= 0.9 then
                part.CanCollide = false
            end
        end
    end
end

-- 9. X-Ray
function WorldModule.XRay(enabled)
    State.XRay = enabled
    ConsoleLog("X-Ray " .. (enabled and "ENABLED" or "DISABLED"), "WORLD")
    if enabled then
        _G.Medusa.XRayParts = _G.Medusa.XRayParts or {}
        for _, part in pairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") and not part:IsDescendantOf(GetCharacter() or Instance.new("Folder")) then
                if part.Transparency < 0.5 then
                    table.insert(_G.Medusa.XRayParts, {Part = part, OrigTransparency = part.Transparency})
                    part.Transparency = 0.7
                    part.Material = Enum.Material.ForceField
                end
            end
        end
    else
        if _G.Medusa.XRayParts then
            for _, data in pairs(_G.Medusa.XRayParts) do
                if data.Part and data.Part.Parent then
                    data.Part.Transparency = data.OrigTransparency
                    data.Part.Material = Enum.Material.SmoothPlastic
                end
            end
            _G.Medusa.XRayParts = {}
        end
    end
end

-- 10. Small Characters
function WorldModule.SmallChars(enabled)
    State.SmallChars = enabled
    ConsoleLog("Small Characters " .. (enabled and "ENABLED" or "DISABLED"), "WORLD")
    if enabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local hum = player.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    pcall(function()
                        hum.BodyDepthScale.Value = 0.5
                        hum.BodyHeightScale.Value = 0.5
                        hum.BodyWidthScale.Value = 0.5
                        hum.HeadScale.Value = 0.5
                    end)
                end
            end
        end
    end
end

-- 11. Custom Gravity
function WorldModule.CustomGravity(enabled)
    State.CustomGravity = enabled
    if enabled then
        Workspace.Gravity = Values.Gravity
        ConsoleLog("Custom Gravity ENABLED ("..Values.Gravity..")", "WORLD")
    else
        Workspace.Gravity = 196.2
        ConsoleLog("Custom Gravity DISABLED (Reset to 196.2)", "WORLD")
    end
end

-- 12. TP to Random Player
function WorldModule.TPtoRandom()
    local players = Players:GetPlayers()
    local validPlayers = {}
    for _, p in pairs(players) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(validPlayers, p)
        end
    end
    if #validPlayers > 0 then
        local target = validPlayers[math.random(1, #validPlayers)]
        local root = GetRootPart()
        if root then
            root.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(5, 0, 0)
            ConsoleLog("Teleported to " .. target.Name, "WORLD")
        end
    else
        ConsoleLog("No valid players to teleport to", "WARN")
    end
end

-- 13. TP to Spawn
function WorldModule.TPtoSpawn()
    local root = GetRootPart()
    if root then
        local spawn = Workspace:FindFirstChildOfClass("SpawnLocation")
        if spawn then
            root.CFrame = spawn.CFrame + Vector3.new(0, 5, 0)
            ConsoleLog("Teleported to spawn", "WORLD")
        else
            root.CFrame = CFrame.new(0, 50, 0)
            ConsoleLog("No spawn found, teleported to origin", "WORLD")
        end
    end
end

-- 14. Map Cleaner
function WorldModule.MapCleaner()
    local count = 0
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or
           obj:IsA("Fire") or obj:IsA("Sparkles") or obj:IsA("PointLight") or
           obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
            obj:Destroy()
            count = count + 1
        end
    end
    ConsoleLog("Map Cleaner: Removed " .. count .. " objects", "WORLD")
end

-- 15. No Clip Parts
function WorldModule.NoClipParts(enabled)
    State.NoClipParts = enabled
    ConsoleLog("No Clip Parts " .. (enabled and "ENABLED" or "DISABLED"), "WORLD")
    if enabled then
        for _, part in pairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end

-- 16. Destroy 3D Decorations
function WorldModule.Destroy3D()
    local count = 0
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("MeshPart") and obj.Transparency > 0.5 then
            obj:Destroy()
            count = count + 1
        elseif obj:IsA("SpecialMesh") then
            obj:Destroy()
            count = count + 1
        end
    end
    ConsoleLog("Destroy 3D: Removed " .. count .. " decorations", "WORLD")
    State.Destroy3D = true
end

-- ╔════════════════════════════════════════════════════╗
-- ║    SECTION 10: UTILITY MODULE (16 Functions)      ║
-- ╚════════════════════════════════════════════════════╝

local UtilityModule = {}

-- 1. Anti-AFK
function UtilityModule.AntiAFK(enabled)
    State.AntiAFK = enabled
    if enabled then
        ConsoleLog("Anti-AFK ENABLED", "UTIL")
        local VirtualUser = game:GetService("VirtualUser")
        _G.Medusa.AntiAFKConn = AddConnection(LocalPlayer.Idled:Connect(function()
            if State.AntiAFK then
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0))
                ConsoleLog("Anti-AFK: Prevented kick", "UTIL")
            end
        end))
    else
        if _G.Medusa.AntiAFKConn then
            _G.Medusa.AntiAFKConn:Disconnect()
            _G.Medusa.AntiAFKConn = nil
        end
        ConsoleLog("Anti-AFK DISABLED", "UTIL")
    end
end

-- 2. Server Hop
function UtilityModule.ServerHop()
    ConsoleLog("Server Hopping...", "UTIL")
    pcall(function()
        local servers = game.HttpService:JSONDecode(
            game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
        )
        for _, server in pairs(servers.data) do
            if server.id ~= game.JobId and server.playing < server.maxPlayers then
                TeleportService = game:GetService("TeleportService")
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id)
                return
            end
        end
    end)
end

-- 3. Rejoin
function UtilityModule.Rejoin()
    ConsoleLog("Rejoining server...", "UTIL")
    pcall(function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end)
end

-- 4. FPS Unlock
function UtilityModule.FPSUnlock(enabled)
    State.FPSUnlock = enabled
    if enabled then
        pcall(function()
            setfpscap(999)
        end)
        ConsoleLog("FPS Unlock ENABLED", "UTIL")
    else
        pcall(function()
            setfpscap(60)
        end)
        ConsoleLog("FPS Unlock DISABLED", "UTIL")
    end
end

-- 5. Chat Spam
function UtilityModule.ChatSpam(enabled)
    State.ChatSpam = enabled
    if enabled then
        _G.Medusa.Loops.ChatSpam = true
        ConsoleLog("Chat Spam ENABLED", "UTIL")
        task.spawn(function()
            while _G.Medusa.Loops.ChatSpam and State.ChatSpam do
                pcall(function()
                    local chatRemote = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
                    if chatRemote then
                        local sayMsg = chatRemote:FindFirstChild("SayMessageRequest")
                        if sayMsg then
                            sayMsg:FireServer(Values.ChatSpamMsg, "All")
                        end
                    else
                        game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
                            Text = Values.ChatSpamMsg,
                            Color = Config.Theme.Primary
                        })
                    end
                end)
                task.wait(Values.ChatSpamDelay)
            end
        end)
    else
        _G.Medusa.Loops.ChatSpam = false
        ConsoleLog("Chat Spam DISABLED", "UTIL")
    end
end

-- 6. Anti-Kick
function UtilityModule.AntiKick(enabled)
    State.AntiKick = enabled
    if enabled then
        ConsoleLog("Anti-Kick ENABLED", "UTIL")
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            if getnamecallmethod() == "Kick" and self == LocalPlayer then
                ConsoleLog("Anti-Kick: Blocked kick attempt", "UTIL")
                return
            end
            return oldNamecall(self, ...)
        end)
    else
        ConsoleLog("Anti-Kick DISABLED", "UTIL")
    end
end

-- 7. God Mode (Attempt)
function UtilityModule.GodMode(enabled)
    State.GodMode = enabled
    if enabled then
        ConsoleLog("God Mode ENABLED (Attempt)", "UTIL")
        pcall(function()
            local hum = GetHumanoid()
            if hum then
                hum:Remove()
                task.wait(0.1)
                local newHum = Instance.new("Humanoid")
                newHum.Parent = GetCharacter()
            end
        end)
    else
        ConsoleLog("God Mode DISABLED", "UTIL")
    end
end

-- 8. Copy Game ID
function UtilityModule.CopyGameID()
    pcall(function()
        setclipboard(tostring(game.PlaceId))
        ConsoleLog("Game ID copied: " .. tostring(game.PlaceId), "UTIL")
    end)
end

-- 9. Copy Server ID
function UtilityModule.CopyServerID()
    pcall(function()
        setclipboard(tostring(game.JobId))
        ConsoleLog("Server ID copied: " .. tostring(game.JobId), "UTIL")
    end)
end

-- 10. Reset Character
function UtilityModule.ResetChar()
    local hum = GetHumanoid()
    if hum then
        hum.Health = 0
        ConsoleLog("Character Reset", "UTIL")
    end
end

-- 11. Hide Name
function UtilityModule.HideName(enabled)
    State.HideName = enabled
    if enabled then
        local char = GetCharacter()
        if char then
            local head = char:FindFirstChild("Head")
            if head then
                for _, obj in pairs(head:GetChildren()) do
                    if obj:IsA("BillboardGui") or obj.Name == "NameTag" then
                        obj.Enabled = false
                    end
                end
            end
            local hum = GetHumanoid()
            if hum then hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None end
        end
        ConsoleLog("Hide Name ENABLED", "UTIL")
    else
        local hum = GetHumanoid()
        if hum then hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer end
        ConsoleLog("Hide Name DISABLED", "UTIL")
    end
end

-- 12. Sit
function UtilityModule.Sit(enabled)
    State.Sit = enabled
    local hum = GetHumanoid()
    if hum then hum.Sit = enabled end
    ConsoleLog("Sit " .. (enabled and "ENABLED" or "DISABLED"), "UTIL")
end

-- 13. Anti-Void
function UtilityModule.AntiVoid(enabled)
    State.AntiVoid = enabled
    if enabled then
        _G.Medusa.Loops.AntiVoid = true
        ConsoleLog("Anti-Void ENABLED", "UTIL")
        task.spawn(function()
            while _G.Medusa.Loops.AntiVoid and State.AntiVoid do
                local root = GetRootPart()
                if root and root.Position.Y < -200 then
                    root.CFrame = CFrame.new(0, 100, 0)
                    ConsoleLog("Anti-Void: Rescued from void", "UTIL")
                end
                task.wait(0.5)
            end
        end)
    else
        _G.Medusa.Loops.AntiVoid = false
        ConsoleLog("Anti-Void DISABLED", "UTIL")
    end
end

-- 14. Auto Respawn
function UtilityModule.AutoRespawn(enabled)
    State.AutoRespawn = enabled
    if enabled then
        ConsoleLog("Auto Respawn ENABLED", "UTIL")
        _G.Medusa.AutoRespawnConn = AddConnection(GetHumanoid().Died:Connect(function()
            if State.AutoRespawn then
                task.wait(game.Players.RespawnTime or 5)
                pcall(function()
                    LocalPlayer:LoadCharacter()
                end)
                ConsoleLog("Auto Respawn: Respawned", "UTIL")
            end
        end))
    else
        if _G.Medusa.AutoRespawnConn then
            _G.Medusa.AutoRespawnConn:Disconnect()
            _G.Medusa.AutoRespawnConn = nil
        end
        ConsoleLog("Auto Respawn DISABLED", "UTIL")
    end
end

-- 15. Infinite Stamina
function UtilityModule.InfStamina(enabled)
    State.InfStamina = enabled
    if enabled then
        _G.Medusa.Loops.InfStamina = true
        ConsoleLog("Infinite Stamina ENABLED", "UTIL")
        task.spawn(function()
            while _G.Medusa.Loops.InfStamina and State.InfStamina do
                for _, gui in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
                    if gui:IsA("Frame") and (string.find(string.lower(gui.Name), "stamina") or
                       string.find(string.lower(gui.Name), "energy") or
                       string.find(string.lower(gui.Name), "sprint")) then
                        pcall(function()
                            for _, bar in pairs(gui:GetDescendants()) do
                                if bar:IsA("Frame") then
                                    bar.Size = UDim2.new(1, 0, bar.Size.Y.Scale, bar.Size.Y.Offset)
                                end
                            end
                        end)
                    end
                end
                task.wait(0.1)
            end
        end)
    else
        _G.Medusa.Loops.InfStamina = false
        ConsoleLog("Infinite Stamina DISABLED", "UTIL")
    end
end

-- 16. No Ragdoll
function UtilityModule.NoRagdoll(enabled)
    State.NoRagdoll = enabled
    if enabled then
        _G.Medusa.Loops.NoRagdoll = true
        ConsoleLog("No Ragdoll ENABLED", "UTIL")
        task.spawn(function()
            while _G.Medusa.Loops.NoRagdoll and State.NoRagdoll do
                local hum = GetHumanoid()
                if hum then
                    hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                    if hum:GetState() == Enum.HumanoidStateType.Ragdoll or
                       hum:GetState() == Enum.HumanoidStateType.FallingDown then
                        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                    end
                end
                task.wait(0.1)
            end
        end)
    else
        _G.Medusa.Loops.NoRagdoll = false
        local hum = GetHumanoid()
        if hum then
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        end
        ConsoleLog("No Ragdoll DISABLED", "UTIL")
    end
end

-- ╔══════════════════════════════════════════════════════╗
-- ║  SECTION 11: CINEMATIC INTRO (Cobra 🐍 Edition)     ║
-- ╚══════════════════════════════════════════════════════╝

local function PlayCinematicIntro(callback)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MedusaIntro"
    screenGui.IgnoreGuiInset = true
    screenGui.DisplayOrder = 1000000
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.ResetOnSpawn = false
    screenGui.Parent = (syn and syn.protect_gui and CoreGui) or LocalPlayer.PlayerGui

    -- Black background
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Config.Theme.Black
    bg.BorderSizePixel = 0
    bg.ZIndex = 1
    bg.Parent = screenGui

    -- Scanlines
    local scanlines = Instance.new("Frame")
    scanlines.Size = UDim2.new(1, 0, 1, 0)
    scanlines.BackgroundTransparency = 0.95
    scanlines.BackgroundColor3 = Config.Theme.Black
    scanlines.ZIndex = 2
    scanlines.Parent = bg

    -- Matrix rain particles (0s and 1s)
    task.spawn(function()
        for i = 1, 40 do
            local particle = Instance.new("TextLabel")
            particle.Size = UDim2.new(0, 20, 0, 20)
            particle.Position = UDim2.new(math.random(0, 100) / 100, 0, -0.05, 0)
            particle.BackgroundTransparency = 1
            particle.Text = math.random(0, 1) == 0 and "0" or "1"
            particle.TextColor3 = Config.Theme.Primary
            particle.TextTransparency = math.random(40, 80) / 100
            particle.Font = Enum.Font.Code
            particle.TextSize = math.random(10, 18)
            particle.ZIndex = 3
            particle.Parent = bg

            local fallTime = math.random(30, 80) / 10
            SafeTween(particle,
                TweenInfo.new(fallTime, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, false, math.random(0, 30) / 10),
                {Position = UDim2.new(particle.Position.X.Scale, 0, 1.1, 0)}
            )
        end
    end)

    -- Vignette effect
    local vignette = Instance.new("ImageLabel")
    vignette.Size = UDim2.new(1, 0, 1, 0)
    vignette.BackgroundTransparency = 1
    vignette.Image = "rbxassetid://1049630956"
    vignette.ImageColor3 = Config.Theme.Primary
    vignette.ImageTransparency = 0.85
    vignette.ZIndex = 4
    vignette.ScaleType = Enum.ScaleType.Stretch
    vignette.Parent = bg

    -- Vignette pulse
    SafeTween(vignette,
        TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        {ImageTransparency = 0.6}
    )

    -- Center container
    local center = Instance.new("Frame")
    center.Size = UDim2.new(0, 400, 0, 350)
    center.Position = UDim2.new(0.5, -200, 0.5, -175)
    center.BackgroundTransparency = 1
    center.ZIndex = 10
    center.Parent = bg

    -- ═══════════════════════════════════════
    -- PHASE 1: COBRA 🐍 DESLIZA PARA O ECRÃ
    -- ═══════════════════════════════════════

    -- Cobra Glow (larger copy behind)
    local cobraGlow = Instance.new("TextLabel")
    cobraGlow.Size = UDim2.new(0, 0, 0, 0)
    cobraGlow.Position = UDim2.new(0.5, 0, 0.2, 0)
    cobraGlow.AnchorPoint = Vector2.new(0.5, 0.5)
    cobraGlow.BackgroundTransparency = 1
    cobraGlow.Text = "🐍"
    cobraGlow.TextScaled = true
    cobraGlow.Font = Enum.Font.GothamBold
    cobraGlow.TextColor3 = Config.Theme.Primary
    cobraGlow.TextTransparency = 0.5
    cobraGlow.ZIndex = 11
    cobraGlow.Parent = center

    -- Cobra Main
    local cobra = Instance.new("TextLabel")
    cobra.Size = UDim2.new(0, 0, 0, 0)
    cobra.Position = UDim2.new(0.5, 0, 0.2, 0)
    cobra.AnchorPoint = Vector2.new(0.5, 0.5)
    cobra.BackgroundTransparency = 1
    cobra.Text = "🐍"
    cobra.TextScaled = true
    cobra.Font = Enum.Font.GothamBold
    cobra.TextColor3 = Config.Theme.White
    cobra.ZIndex = 12
    cobra.Parent = center

    -- UIStroke on cobra for neon glow
    local cobraStroke = Instance.new("UIStroke")
    cobraStroke.Color = Config.Theme.Primary
    cobraStroke.Thickness = 2
    cobraStroke.Transparency = 0.3
    cobraStroke.Parent = cobra

    -- Animate cobra birth (Size 0 -> 150)
    SafeTween(cobra,
        TweenInfo.new(1.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Size = UDim2.new(0, 150, 0, 150)}
    )
    SafeTween(cobraGlow,
        TweenInfo.new(1.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Size = UDim2.new(0, 185, 0, 185)}
    )

    -- Cobra glow pulse loop
    task.spawn(function()
        while cobraGlow and cobraGlow.Parent do
            SafeTween(cobraGlow,
                TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                {TextTransparency = 0.8}
            )
            task.wait(1.2)
            if not cobraGlow or not cobraGlow.Parent then break end
            SafeTween(cobraGlow,
                TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                {TextTransparency = 0.2}
            )
            task.wait(1.2)
        end
    end)

    -- Cobra stroke hypnotic pulse
    task.spawn(function()
        while cobraStroke and cobraStroke.Parent do
            SafeTween(cobraStroke,
                TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                {Thickness = 5, Transparency = 0.7}
            )
            task.wait(1)
            if not cobraStroke or not cobraStroke.Parent then break end
            SafeTween(cobraStroke,
                TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                {Thickness = 2, Transparency = 0.1}
            )
            task.wait(1)
        end
    end)

    -- Wait for cobra to fully appear
    task.wait(2)

    -- ═══════════════════════════════════════
    -- PHASE 2: TEXTO "M E D U S A" GLITCH
    -- ═══════════════════════════════════════

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0.45, 0)
    title.BackgroundTransparency = 1
    title.Text = ""
    title.TextColor3 = Config.Theme.Primary
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 42
    title.ZIndex = 13
    title.Parent = center

    local titleStroke = Instance.new("UIStroke")
    titleStroke.Color = Config.Theme.Primary
    titleStroke.Thickness = 2
    titleStroke.Transparency = 0.3
    titleStroke.Parent = title

    -- Title stroke pulse sync
    task.spawn(function()
        while titleStroke and titleStroke.Parent do
            SafeTween(titleStroke,
                TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                {Transparency = 1}
            )
            task.wait(1.5)
            if not titleStroke or not titleStroke.Parent then break end
            SafeTween(titleStroke,
                TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                {Transparency = 0.2}
            )
            task.wait(1.5)
        end
    end)

    -- Glitch reveal effect
    local glitchChars = "!@#$%^&*01<>{}|/\\~`"
    local targetText = "M E D U S A"
    for pass = 1, 15 do
        local result = ""
        for i = 1, #targetText do
            local c = targetText:sub(i, i)
            if c == " " then
                result = result .. " "
            elseif pass > 10 or math.random(1, 15 - pass) == 1 then
                result = result .. c
            else
                result = result .. glitchChars:sub(math.random(1, #glitchChars), math.random(1, #glitchChars))
            end
        end
        title.Text = result
        task.wait(0.08)
    end
    title.Text = targetText

    task.wait(0.5)

    -- Version text
    local version = Instance.new("TextLabel")
    version.Size = UDim2.new(1, 0, 0, 20)
    version.Position = UDim2.new(0, 0, 0.55, 0)
    version.BackgroundTransparency = 1
    version.Text = "C O B R A   E D I T I O N  ·  v" .. Config.Version
    version.TextColor3 = Config.Theme.PrimaryDark
    version.Font = Enum.Font.Gotham
    version.TextSize = 14
    version.TextTransparency = 1
    version.ZIndex = 13
    version.Parent = center
    SafeTween(version, TweenInfo.new(0.8), {TextTransparency = 0})

    task.wait(0.5)

    -- ═══════════════════════════════════════
    -- PHASE 3: BARRA NEON COM LOADING
    -- ═══════════════════════════════════════

    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(0.7, 0, 0, 4)
    barBg.Position = UDim2.new(0.15, 0, 0.68, 0)
    barBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    barBg.BorderSizePixel = 0
    barBg.ZIndex = 13
    barBg.Parent = center
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(0, 2)

    local barFill = Instance.new("Frame")
    barFill.Size = UDim2.new(0, 0, 1, 0)
    barFill.BackgroundColor3 = Config.Theme.Primary
    barFill.BorderSizePixel = 0
    barFill.ZIndex = 14
    barFill.Parent = barBg
    Instance.new("UICorner", barFill).CornerRadius = UDim.new(0, 2)

    -- Neon gradient on bar
    local barGrad = Instance.new("UIGradient")
    barGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Config.Theme.PrimaryDark),
        ColorSequenceKeypoint.new(0.5, Config.Theme.White),
        ColorSequenceKeypoint.new(1, Config.Theme.PrimaryDark),
    })
    barGrad.Parent = barFill

    -- Animate gradient offset loop
    task.spawn(function()
        while barGrad and barGrad.Parent do
            SafeTween(barGrad,
                TweenInfo.new(1, Enum.EasingStyle.Linear),
                {Offset = Vector2.new(1, 0)}
            )
            task.wait(1)
            if barGrad and barGrad.Parent then
                barGrad.Offset = Vector2.new(-1, 0)
            end
        end
    end)

    -- Status text
    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.new(1, 0, 0, 16)
    statusText.Position = UDim2.new(0, 0, 0.73, 0)
    statusText.BackgroundTransparency = 1
    statusText.Text = ""
    statusText.TextColor3 = Config.Theme.TextDim
    statusText.Font = Enum.Font.Code
    statusText.TextSize = 11
    statusText.ZIndex = 13
    statusText.Parent = center

    -- Loading steps
    local loadingSteps = {
        {0.05, "Initializing Medusa Engine..."},
        {0.10, "Hard Clean: Clearing globals..."},
        {0.15, "Loading Combat v2 Module (16 functions)..."},
        {0.25, "Loading ESP 3D Module (16 functions)..."},
        {0.35, "Loading Movement Module (16 functions)..."},
        {0.45, "Loading World Module (16 functions)..."},
        {0.55, "Loading Utility Module (16 functions)..."},
        {0.65, "Loading HUD Module (16 functions)..."},
        {0.75, "Compiling 96 functions..."},
        {0.82, "Injecting UI framework..."},
        {0.90, "Binding keybinds (M/F/N)..."},
        {0.95, "Connecting to game services..."},
        {1.00, "🐍 Medusa is ready. Welcome."},
    }

    for _, step in ipairs(loadingSteps) do
        statusText.Text = step[2]
        SafeTween(barFill,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad),
            {Size = UDim2.new(step[1], 0, 1, 0)}
        )
        task.wait(0.25)
    end

    task.wait(0.8)

    -- ═══════════════════════════════════════
    -- PHASE 4: FADE OUT
    -- ═══════════════════════════════════════

    SafeTween(bg, TweenInfo.new(1, Enum.EasingStyle.Quad), {BackgroundTransparency = 1})
    for _, child in pairs(bg:GetDescendants()) do
        pcall(function()
            if child:IsA("TextLabel") then
                SafeTween(child, TweenInfo.new(0.8), {TextTransparency = 1})
            elseif child:IsA("ImageLabel") then
                SafeTween(child, TweenInfo.new(0.8), {ImageTransparency = 1})
            elseif child:IsA("Frame") then
                SafeTween(child, TweenInfo.new(0.8), {BackgroundTransparency = 1})
            end
        end)
    end

    task.wait(1.2)
    screenGui:Destroy()

    if callback then callback() end
end

-- ╔══════════════════════════════════════════════════════╗
-- ║  SECTION 12: MAIN UI BUILDER (96-Function Panel)    ║
-- ╚══════════════════════════════════════════════════════╝

local function BuildMainUI()
    -- ScreenGui
    local gui = Instance.new("ScreenGui")
    gui.Name = "MedusaEngine"
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 999999
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.ResetOnSpawn = false
    gui.Parent = (syn and syn.protect_gui and CoreGui) or LocalPlayer.PlayerGui
    _G.Medusa.ScreenGui = gui

    -- Toast system
    local toastContainer = Instance.new("Frame")
    toastContainer.Size = UDim2.new(0, 260, 1, 0)
    toastContainer.Position = UDim2.new(1, -270, 0, 0)
    toastContainer.BackgroundTransparency = 1
    toastContainer.ZIndex = 100
    toastContainer.Parent = gui

    local toastLayout = Instance.new("UIListLayout")
    toastLayout.SortOrder = Enum.SortOrder.LayoutOrder
    toastLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    toastLayout.Padding = UDim.new(0, 5)
    toastLayout.Parent = toastContainer

    local function ShowToast(msg)
        if not State.Notifications then return end
        local toast = Instance.new("Frame")
        toast.Size = UDim2.new(1, 0, 0, 36)
        toast.BackgroundColor3 = Config.Theme.Card
        toast.BorderSizePixel = 0
        toast.BackgroundTransparency = 1
        toast.ZIndex = 101
        toast.Parent = toastContainer
        Instance.new("UICorner", toast).CornerRadius = UDim.new(0, 6)

        local ts = Instance.new("UIStroke")
        ts.Color = Config.Theme.PrimaryDark
        ts.Thickness = 1
        ts.Transparency = 0.5
        ts.Parent = toast

        local tLabel = Instance.new("TextLabel")
        tLabel.Size = UDim2.new(1, -16, 1, 0)
        tLabel.Position = UDim2.new(0, 8, 0, 0)
        tLabel.BackgroundTransparency = 1
        tLabel.Text = "🐍 " .. msg
        tLabel.TextColor3 = Config.Theme.Text
        tLabel.Font = Enum.Font.Gotham
        tLabel.TextSize = 12
        tLabel.TextXAlignment = Enum.TextXAlignment.Left
        tLabel.TextTruncate = Enum.TextTruncate.AtEnd
        tLabel.ZIndex = 102
        tLabel.Parent = toast

        SafeTween(toast, TweenInfo.new(0.3), {BackgroundTransparency = 0})
        task.delay(3, function()
            SafeTween(toast, TweenInfo.new(0.5), {BackgroundTransparency = 1})
            task.wait(0.6)
            if toast and toast.Parent then toast:Destroy() end
        end)
    end

    -- Main Frame (starts off-screen for slide-up)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 520, 0, 640)
    mainFrame.Position = UDim2.new(0.5, -260, 1.2, 0)
    mainFrame.AnchorPoint = Vector2.new(0, 0)
    mainFrame.BackgroundColor3 = Config.Theme.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.ZIndex = 10
    mainFrame.Parent = gui

    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Config.Theme.PrimaryDark
    mainStroke.Thickness = 1.5
    mainStroke.Transparency = 0.3
    mainStroke.Parent = mainFrame

    -- Draggable
    local dragging, dragStart, startPos
    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    mainFrame.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
           input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- ═════════════════
    -- HEADER
    -- ═════════════════
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 48)
    header.BackgroundColor3 = Config.Theme.Surface
    header.BorderSizePixel = 0
    header.ZIndex = 11
    header.Parent = mainFrame
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 10)

    -- Fix bottom corners of header
    local headerFix = Instance.new("Frame")
    headerFix.Size = UDim2.new(1, 0, 0, 10)
    headerFix.Position = UDim2.new(0, 0, 1, -10)
    headerFix.BackgroundColor3 = Config.Theme.Surface
    headerFix.BorderSizePixel = 0
    headerFix.ZIndex = 11
    headerFix.Parent = header

    -- Header gradient
    local headerGrad = Instance.new("UIGradient")
    headerGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 25, 20)),
        ColorSequenceKeypoint.new(1, Config.Theme.Surface),
    })
    headerGrad.Rotation = 90
    headerGrad.Parent = header

    -- Cobra icon in header
    local headerCobra = Instance.new("TextLabel")
    headerCobra.Size = UDim2.new(0, 32, 0, 32)
    headerCobra.Position = UDim2.new(0, 12, 0.5, -16)
    headerCobra.BackgroundTransparency = 1
    headerCobra.Text = "🐍"
    headerCobra.TextScaled = true
    headerCobra.Font = Enum.Font.GothamBold
    headerCobra.ZIndex = 12
    headerCobra.Parent = header

    -- Title
    local headerTitle = Instance.new("TextLabel")
    headerTitle.Size = UDim2.new(0, 200, 0, 20)
    headerTitle.Position = UDim2.new(0, 50, 0, 6)
    headerTitle.BackgroundTransparency = 1
    headerTitle.Text = "MEDUSA ENGINE"
    headerTitle.TextColor3 = Config.Theme.Primary
    headerTitle.Font = Enum.Font.GothamBlack
    headerTitle.TextSize = 16
    headerTitle.TextXAlignment = Enum.TextXAlignment.Left
    headerTitle.ZIndex = 12
    headerTitle.Parent = header

    -- Subtitle
    local headerSub = Instance.new("TextLabel")
    headerSub.Size = UDim2.new(0, 200, 0, 14)
    headerSub.Position = UDim2.new(0, 50, 0, 26)
    headerSub.BackgroundTransparency = 1
    headerSub.Text = "Cobra Edition · v" .. Config.Version .. " · 96 Functions"
    headerSub.TextColor3 = Config.Theme.TextDim
    headerSub.Font = Enum.Font.Gotham
    headerSub.TextSize = 11
    headerSub.TextXAlignment = Enum.TextXAlignment.Left
    headerSub.ZIndex = 12
    headerSub.Parent = header

    -- Status dot
    local statusDot = Instance.new("Frame")
    statusDot.Size = UDim2.new(0, 8, 0, 8)
    statusDot.Position = UDim2.new(1, -65, 0.5, -4)
    statusDot.BackgroundColor3 = Config.Theme.Primary
    statusDot.ZIndex = 12
    statusDot.Parent = header
    Instance.new("UICorner", statusDot).CornerRadius = UDim.new(1, 0)

    SafeTween(statusDot,
        TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        {BackgroundTransparency = 0.6}
    )

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(0, 35, 0, 14)
    statusLabel.Position = UDim2.new(1, -52, 0.5, -7)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "LIVE"
    statusLabel.TextColor3 = Config.Theme.Primary
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.TextSize = 10
    statusLabel.ZIndex = 12
    statusLabel.Parent = header

    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -38, 0.5, -15)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Config.Theme.TextDim
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.ZIndex = 12
    closeBtn.Parent = header
    closeBtn.MouseButton1Click:Connect(function()
        _G.Medusa.UIVisible = false
        SafeTween(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In),
            {Position = UDim2.new(0.5, -260, 1.2, 0)})
        ShowToast("UI Hidden (Press M to show)")
    end)

    -- Neon line under header
    local neonLine = Instance.new("Frame")
    neonLine.Size = UDim2.new(1, -20, 0, 2)
    neonLine.Position = UDim2.new(0, 10, 0, 48)
    neonLine.BackgroundColor3 = Config.Theme.Primary
    neonLine.BorderSizePixel = 0
    neonLine.ZIndex = 12
    neonLine.Parent = mainFrame

    local neonGrad = Instance.new("UIGradient")
    neonGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
        ColorSequenceKeypoint.new(0.2, Config.Theme.Primary),
        ColorSequenceKeypoint.new(0.5, Config.Theme.White),
        ColorSequenceKeypoint.new(0.8, Config.Theme.Primary),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
    })
    neonGrad.Parent = neonLine

    -- ═════════════════
    -- TAB SYSTEM
    -- ═════════════════
    local tabBar = Instance.new("Frame")
    tabBar.Size = UDim2.new(1, -20, 0, 32)
    tabBar.Position = UDim2.new(0, 10, 0, 55)
    tabBar.BackgroundTransparency = 1
    tabBar.ZIndex = 11
    tabBar.Parent = mainFrame

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 0)
    tabLayout.Parent = tabBar

    local tabs = {"⚔ Combat", "👁 ESP", "⚡ Movement", "🌍 World", "🔧 Utility", "📊 HUD"}
    local tabButtons = {}
    local tabPages = {}
    local activeTabIndicator

    -- Tab indicator line
    activeTabIndicator = Instance.new("Frame")
    activeTabIndicator.Size = UDim2.new(0, 520 / #tabs - 4, 0, 2)
    activeTabIndicator.Position = UDim2.new(0, 2, 1, -2)
    activeTabIndicator.BackgroundColor3 = Config.Theme.Primary
    activeTabIndicator.BorderSizePixel = 0
    activeTabIndicator.ZIndex = 13
    activeTabIndicator.Parent = tabBar

    -- Content area
    local contentArea = Instance.new("Frame")
    contentArea.Size = UDim2.new(1, -20, 1, -130)
    contentArea.Position = UDim2.new(0, 10, 0, 92)
    contentArea.BackgroundTransparency = 1
    contentArea.ClipsDescendants = true
    contentArea.ZIndex = 11
    contentArea.Parent = mainFrame

    -- Helper: Create ScrollingFrame page
    local function CreatePage(name)
        local page = Instance.new("ScrollingFrame")
        page.Name = name
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.ScrollBarThickness = 3
        page.ScrollBarImageColor3 = Config.Theme.Primary
        page.BorderSizePixel = 0
        page.Visible = false
        page.ZIndex = 11
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.Parent = contentArea

        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 4)
        layout.Parent = page

        local padding = Instance.new("UIPadding")
        padding.PaddingTop = UDim.new(0, 4)
        padding.PaddingBottom = UDim.new(0, 10)
        padding.Parent = page

        return page
    end

    -- Helper: Section Header
    local function CreateSection(parent, title, order)
        local section = Instance.new("Frame")
        section.Size = UDim2.new(1, 0, 0, 26)
        section.BackgroundTransparency = 1
        section.LayoutOrder = order or 0
        section.ZIndex = 11
        section.Parent = parent

        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(0, 3, 0, 14)
        bar.Position = UDim2.new(0, 0, 0.5, -7)
        bar.BackgroundColor3 = Config.Theme.Primary
        bar.BorderSizePixel = 0
        bar.ZIndex = 12
        bar.Parent = section
        Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 2)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -12, 1, 0)
        label.Position = UDim2.new(0, 12, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = string.upper(title)
        label.TextColor3 = Config.Theme.Primary
        label.Font = Enum.Font.GothamBold
        label.TextSize = 11
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.ZIndex = 12
        label.Parent = section
    end

    -- Helper: Toggle Card
    local function CreateToggle(parent, name, order, callback)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, 0, 0, 34)
        card.BackgroundColor3 = Config.Theme.Card
        card.BorderSizePixel = 0
        card.LayoutOrder = order or 0
        card.ZIndex = 11
        card.Parent = parent
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)

        local cardStroke = Instance.new("UIStroke")
        cardStroke.Color = Color3.fromRGB(35, 35, 35)
        cardStroke.Thickness = 1
        cardStroke.Parent = card

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -80, 1, 0)
        label.Position = UDim2.new(0, 12, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Config.Theme.Text
        label.Font = Enum.Font.Gotham
        label.TextSize = 13
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.ZIndex = 12
        label.Parent = card

        -- Status
        local status = Instance.new("TextLabel")
        status.Size = UDim2.new(0, 30, 0, 14)
        status.Position = UDim2.new(1, -75, 0.5, -7)
        status.BackgroundTransparency = 1
        status.Text = "OFF"
        status.TextColor3 = Config.Theme.TextDim
        status.Font = Enum.Font.GothamBold
        status.TextSize = 10
        status.ZIndex = 12
        status.Parent = card

        -- Toggle button
        local toggleBg = Instance.new("Frame")
        toggleBg.Size = UDim2.new(0, 38, 0, 20)
        toggleBg.Position = UDim2.new(1, -48, 0.5, -10)
        toggleBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        toggleBg.BorderSizePixel = 0
        toggleBg.ZIndex = 12
        toggleBg.Parent = card
        Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(1, 0)

        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 16, 0, 16)
        knob.Position = UDim2.new(0, 2, 0.5, -8)
        knob.BackgroundColor3 = Config.Theme.TextDim
        knob.BorderSizePixel = 0
        knob.ZIndex = 13
        knob.Parent = toggleBg
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

        local isOn = false

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.ZIndex = 14
        btn.Parent = card

        btn.MouseButton1Click:Connect(function()
            isOn = not isOn
            if isOn then
                SafeTween(toggleBg, TweenInfo.new(0.2), {BackgroundColor3 = Config.Theme.PrimaryDark})
                SafeTween(knob, TweenInfo.new(0.2), {Position = UDim2.new(0, 20, 0.5, -8), BackgroundColor3 = Config.Theme.Primary})
                SafeTween(cardStroke, TweenInfo.new(0.2), {Color = Config.Theme.PrimaryDark})
                status.Text = "ON"
                status.TextColor3 = Config.Theme.Primary
            else
                SafeTween(toggleBg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)})
                SafeTween(knob, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = Config.Theme.TextDim})
                SafeTween(cardStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(35, 35, 35)})
                status.Text = "OFF"
                status.TextColor3 = Config.Theme.TextDim
            end
            ShowToast(name .. " " .. (isOn and "ON" or "OFF"))
            if callback then callback(isOn) end
        end)

        return {Card = card, SetState = function(state)
            isOn = state
            if isOn then
                toggleBg.BackgroundColor3 = Config.Theme.PrimaryDark
                knob.Position = UDim2.new(0, 20, 0.5, -8)
                knob.BackgroundColor3 = Config.Theme.Primary
                cardStroke.Color = Config.Theme.PrimaryDark
                status.Text = "ON"
                status.TextColor3 = Config.Theme.Primary
            else
                toggleBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                knob.Position = UDim2.new(0, 2, 0.5, -8)
                knob.BackgroundColor3 = Config.Theme.TextDim
                cardStroke.Color = Color3.fromRGB(35, 35, 35)
                status.Text = "OFF"
                status.TextColor3 = Config.Theme.TextDim
            end
        end}
    end

    -- Helper: Slider Card
    local function CreateSlider(parent, name, min, max, default, order, callback)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, 0, 0, 50)
        card.BackgroundColor3 = Config.Theme.Card
        card.BorderSizePixel = 0
        card.LayoutOrder = order or 0
        card.ZIndex = 11
        card.Parent = parent
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)

        local cardStroke = Instance.new("UIStroke")
        cardStroke.Color = Color3.fromRGB(35, 35, 35)
        cardStroke.Thickness = 1
        cardStroke.Parent = card

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.6, 0, 0, 18)
        label.Position = UDim2.new(0, 12, 0, 4)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Config.Theme.Text
        label.Font = Enum.Font.Gotham
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.ZIndex = 12
        label.Parent = card

        local valueBadge = Instance.new("TextLabel")
        valueBadge.Size = UDim2.new(0, 50, 0, 18)
        valueBadge.Position = UDim2.new(1, -62, 0, 4)
        valueBadge.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        valueBadge.BorderSizePixel = 0
        valueBadge.Text = tostring(default)
        valueBadge.TextColor3 = Config.Theme.Primary
        valueBadge.Font = Enum.Font.GothamBold
        valueBadge.TextSize = 11
        valueBadge.ZIndex = 12
        valueBadge.Parent = card
        Instance.new("UICorner", valueBadge).CornerRadius = UDim.new(0, 4)

        -- Slider track
        local track = Instance.new("Frame")
        track.Size = UDim2.new(1, -24, 0, 6)
        track.Position = UDim2.new(0, 12, 0, 32)
        track.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        track.BorderSizePixel = 0
        track.ZIndex = 12
        track.Parent = card
        Instance.new("UICorner", track).CornerRadius = UDim.new(0, 3)

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Config.Theme.Primary
        fill.BorderSizePixel = 0
        fill.ZIndex = 13
        fill.Parent = track
        Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)

        local fillGrad = Instance.new("UIGradient")
        fillGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Config.Theme.PrimaryDark),
            ColorSequenceKeypoint.new(0.5, Config.Theme.Primary),
            ColorSequenceKeypoint.new(1, Config.Theme.Accent),
        })
        fillGrad.Parent = fill

        -- Knob
        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 14, 0, 14)
        knob.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
        knob.BackgroundColor3 = Config.Theme.Primary
        knob.BorderSizePixel = 0
        knob.ZIndex = 14
        knob.Parent = track
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

        local knobStroke = Instance.new("UIStroke")
        knobStroke.Color = Config.Theme.Accent
        knobStroke.Thickness = 1.5
        knobStroke.Transparency = 0.5
        knobStroke.Parent = knob

        -- Interaction
        local sliding = false
        local sliderBtn = Instance.new("TextButton")
        sliderBtn.Size = UDim2.new(1, 0, 0, 20)
        sliderBtn.Position = UDim2.new(0, 0, 0, 24)
        sliderBtn.BackgroundTransparency = 1
        sliderBtn.Text = ""
        sliderBtn.ZIndex = 15
        sliderBtn.Parent = card

        sliderBtn.MouseButton1Down:Connect(function() sliding = true end)

        AddConnection(UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or
               input.UserInputType == Enum.UserInputType.Touch then
                sliding = false
            end
        end))

        AddConnection(UserInputService.InputChanged:Connect(function(input)
            if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or
               input.UserInputType == Enum.UserInputType.Touch) then
                local trackAbs = track.AbsolutePosition
                local trackSize = track.AbsoluteSize
                local relX = math.clamp((input.Position.X - trackAbs.X) / trackSize.X, 0, 1)
                local value = math.floor(min + (max - min) * relX)

                fill.Size = UDim2.new(relX, 0, 1, 0)
                knob.Position = UDim2.new(relX, -7, 0.5, -7)
                valueBadge.Text = tostring(value)

                if callback then callback(value) end
            end
        end))

        return {Card = card}
    end

    -- Helper: Action Button
    local function CreateButton(parent, name, order, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 32)
        btn.BackgroundColor3 = Config.Theme.Card
        btn.BorderSizePixel = 0
        btn.LayoutOrder = order or 0
        btn.Text = ""
        btn.ZIndex = 11
        btn.Parent = parent
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        local btnStroke = Instance.new("UIStroke")
        btnStroke.Color = Color3.fromRGB(35, 35, 35)
        btnStroke.Thickness = 1
        btnStroke.Parent = btn

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -20, 1, 0)
        label.Position = UDim2.new(0, 12, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = "▶ " .. name
        label.TextColor3 = Config.Theme.Text
        label.Font = Enum.Font.Gotham
        label.TextSize = 13
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.ZIndex = 12
        label.Parent = btn

        btn.MouseButton1Click:Connect(function()
            SafeTween(btnStroke, TweenInfo.new(0.1), {Color = Config.Theme.Primary})
            task.delay(0.3, function()
                SafeTween(btnStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(35, 35, 35)})
            end)
            ShowToast(name .. " executed")
            if callback then callback() end
        end)
    end

    -- Create all pages
    for i, tabName in ipairs(tabs) do
        local page = CreatePage(tabName)
        tabPages[tabName] = page

        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(1 / #tabs, 0, 1, 0)
        tabBtn.BackgroundTransparency = 1
        tabBtn.Text = tabName
        tabBtn.TextColor3 = i == 1 and Config.Theme.Primary or Config.Theme.TextDim
        tabBtn.Font = Enum.Font.GothamBold
        tabBtn.TextSize = 11
        tabBtn.LayoutOrder = i
        tabBtn.ZIndex = 12
        tabBtn.Parent = tabBar
        tabButtons[tabName] = tabBtn

        tabBtn.MouseButton1Click:Connect(function()
            for tName, tPage in pairs(tabPages) do
                tPage.Visible = (tName == tabName)
                tabButtons[tName].TextColor3 = (tName == tabName) and Config.Theme.Primary or Config.Theme.TextDim
            end
            local idx = table.find(tabs, tabName) or 1
            local tabWidth = 500 / #tabs
            SafeTween(activeTabIndicator, TweenInfo.new(0.2, Enum.EasingStyle.Quad),
                {Position = UDim2.new(0, (idx - 1) * tabWidth + 2, 1, -2)})
        end)
    end

    -- Show first tab
    tabPages[tabs[1]].Visible = true

    -- ═══════════════════════════════════════
    -- TAB 1: COMBAT v2 (16 Functions)
    -- ═══════════════════════════════════════
    local combatPage = tabPages[tabs[1]]
    local o = 0

    CreateSection(combatPage, "Aiming", o); o = o + 1
    CreateToggle(combatPage, "Silent Aim", o, function(v) CombatModule.SilentAim(v) end); o = o + 1
    CreateToggle(combatPage, "Aimbot", o, function(v) CombatModule.Aimbot(v) end); o = o + 1
    CreateSlider(combatPage, "Aimbot Smoothness", 1, 20, 5, o, function(v) Values.AimbotSmooth = v end); o = o + 1
    CreateToggle(combatPage, "FOV Circle", o, function(v) CombatModule.FOVCircle(v) end); o = o + 1
    CreateSlider(combatPage, "FOV Radius", 50, 500, 120, o, function(v) Values.FOVRadius = v end); o = o + 1
    CreateToggle(combatPage, "Trigger Bot", o, function(v) CombatModule.TriggerBot(v) end); o = o + 1

    CreateSection(combatPage, "Melee", o); o = o + 1
    CreateToggle(combatPage, "Kill Aura", o, function(v) CombatModule.KillAura(v) end); o = o + 1
    CreateToggle(combatPage, "Auto Parry", o, function(v) CombatModule.AutoParry(v) end); o = o + 1
    CreateToggle(combatPage, "Auto Block", o, function(v) CombatModule.AutoBlock(v) end); o = o + 1
    CreateToggle(combatPage, "Auto Combo", o, function(v) CombatModule.AutoCombo(v) end); o = o + 1
    CreateToggle(combatPage, "Combo Lock", o, function(v) CombatModule.ComboLock(v) end); o = o + 1
    CreateToggle(combatPage, "Auto Clicker", o, function(v) CombatModule.AutoClicker(v) end); o = o + 1
    CreateSlider(combatPage, "Clicker CPS", 1, 30, 12, o, function(v) Values.ClickerCPS = v end); o = o + 1

    CreateSection(combatPage, "Range & Hitbox", o); o = o + 1
    CreateToggle(combatPage, "Reach Extender", o, function(v) CombatModule.Reach(v) end); o = o + 1
    CreateSlider(combatPage, "Reach Distance", 5, 50, 10, o, function(v) Values.Reach = v end); o = o + 1
    CreateToggle(combatPage, "Hitbox Expander", o, function(v) CombatModule.HitboxExpander(v) end); o = o + 1

    CreateSection(combatPage, "Tactics", o); o = o + 1
    CreateToggle(combatPage, "Target Strafe", o, function(v) CombatModule.TargetStrafe(v) end); o = o + 1
    CreateSlider(combatPage, "Strafe Radius", 5, 30, 15, o, function(v) Values.TargetStrafeRadius = v end); o = o + 1
    CreateToggle(combatPage, "Click TP", o, function(v) CombatModule.ClickTP(v) end); o = o + 1
    CreateToggle(combatPage, "Anti Backstab", o, function(v) CombatModule.AntiBackstab(v) end); o = o + 1
    CreateToggle(combatPage, "Target Info", o, function(v) CombatModule.TargetInfo(v) end); o = o + 1

    -- ═══════════════════════════════════════
    -- TAB 2: ESP 3D (16 Functions)
    -- ═══════════════════════════════════════
    local espPage = tabPages[tabs[2]]
    o = 0

    CreateSection(espPage, "Player ESP", o); o = o + 1
    CreateToggle(espPage, "Box ESP", o, function(v) ESPModule.BoxESP(v) end); o = o + 1
    CreateToggle(espPage, "Name ESP", o, function(v) ESPModule.NameESP(v) end); o = o + 1
    CreateToggle(espPage, "Health ESP", o, function(v) ESPModule.HealthESP(v) end); o = o + 1
    CreateToggle(espPage, "Distance ESP", o, function(v) ESPModule.DistanceESP(v) end); o = o + 1
    CreateToggle(espPage, "Tracers", o, function(v) ESPModule.Tracers(v) end); o = o + 1
    CreateToggle(espPage, "Chams / Highlight", o, function(v) ESPModule.Chams(v) end); o = o + 1
    CreateToggle(espPage, "Head Dot", o, function(v) ESPModule.HeadDot(v) end); o = o + 1
    CreateToggle(espPage, "Skeleton ESP", o, function(v) ESPModule.SkeletonESP(v) end); o = o + 1
    CreateToggle(espPage, "Corner Box ESP", o, function(v) ESPModule.CornerBox(v) end); o = o + 1

    CreateSection(espPage, "World ESP", o); o = o + 1
    CreateToggle(espPage, "Item ESP", o, function(v) ESPModule.ItemESP(v) end); o = o + 1
    CreateToggle(espPage, "NPC ESP", o, function(v) ESPModule.NPCESP(v) end); o = o + 1
    CreateToggle(espPage, "Radar ESP", o, function(v) ESPModule.RadarESP(v) end); o = o + 1

    CreateSection(espPage, "Settings", o); o = o + 1
    CreateToggle(espPage, "Team Check", o, function(v) ESPModule.TeamCheck(v) end); o = o + 1
    CreateToggle(espPage, "Visible Check", o, function(v) ESPModule.VisibleCheck(v) end); o = o + 1
    CreateSlider(espPage, "Max Distance", 100, 2000, 1000, o, function(v) Values.ESPMaxDist = v end); o = o + 1

    CreateSection(espPage, "Crosshair", o); o = o + 1
    CreateToggle(espPage, "Crosshair", o, function(v) ESPModule.Crosshair(v) end); o = o + 1
    CreateToggle(espPage, "FOV Display", o, function(v) ESPModule.FOVDisplay(v) end); o = o + 1

    -- ═══════════════════════════════════════
    -- TAB 3: MOVEMENT (16 Functions)
    -- ═══════════════════════════════════════
    local movePage = tabPages[tabs[3]]
    o = 0

    CreateSection(movePage, "Speed & Jump", o); o = o + 1
    CreateToggle(movePage, "WalkSpeed", o, function(v) MovementModule.WalkSpeed(v) end); o = o + 1
    CreateSlider(movePage, "Speed Value", 16, 500, 16, o, function(v) Values.WalkSpeed = v end); o = o + 1
    CreateToggle(movePage, "JumpPower", o, function(v) MovementModule.JumpPower(v) end); o = o + 1
    CreateSlider(movePage, "Jump Value", 50, 500, 50, o, function(v) Values.JumpPower = v end); o = o + 1
    CreateToggle(movePage, "Infinite Jump", o, function(v) MovementModule.InfiniteJump(v) end); o = o + 1
    CreateToggle(movePage, "Speed Glitch", o, function(v) MovementModule.SpeedGlitch(v) end); o = o + 1

    CreateSection(movePage, "Aerial", o); o = o + 1
    CreateToggle(movePage, "Fly [F]", o, function(v) MovementModule.Fly(v) end); o = o + 1
    CreateSlider(movePage, "Fly Speed", 10, 300, 80, o, function(v) Values.FlySpeed = v end); o = o + 1
    CreateToggle(movePage, "Glide", o, function(v) MovementModule.Glide(v) end); o = o + 1
    CreateToggle(movePage, "High Jump", o, function(v) MovementModule.HighJump(v) end); o = o + 1
    CreateSlider(movePage, "High Jump Power", 50, 500, 150, o, function(v) Values.HighJumpPower = v end); o = o + 1
    CreateToggle(movePage, "Long Jump", o, function(v) MovementModule.LongJump(v) end); o = o + 1

    CreateSection(movePage, "Traversal", o); o = o + 1
    CreateToggle(movePage, "Noclip [N]", o, function(v) MovementModule.Noclip(v) end); o = o + 1
    CreateToggle(movePage, "Spider (Wall Climb)", o, function(v) MovementModule.Spider(v) end); o = o + 1
    CreateToggle(movePage, "Phase", o, function(v) MovementModule.Phase(v) end); o = o + 1
    CreateToggle(movePage, "Bunny Hop", o, function(v) MovementModule.BunnyHop(v) end); o = o + 1
    CreateToggle(movePage, "Auto Walk", o, function(v) MovementModule.AutoWalk(v) end); o = o + 1
    CreateToggle(movePage, "Dash [Q]", o, function(v) MovementModule.Dash(v) end); o = o + 1
    CreateSlider(movePage, "Dash Power", 50, 300, 100, o, function(v) Values.DashPower = v end); o = o + 1

    CreateSection(movePage, "Teleport", o); o = o + 1
    CreateToggle(movePage, "TP to Mouse (Click)", o, function(v) MovementModule.TPtoMouse(v) end); o = o + 1
    CreateToggle(movePage, "Anchor", o, function(v) MovementModule.Anchor(v) end); o = o + 1

    -- ═══════════════════════════════════════
    -- TAB 4: WORLD (16 Functions)
    -- ═══════════════════════════════════════
    local worldPage = tabPages[tabs[4]]
    o = 0

    CreateSection(worldPage, "Lighting", o); o = o + 1
    CreateToggle(worldPage, "Fullbright", o, function(v) WorldModule.Fullbright(v) end); o = o + 1
    CreateToggle(worldPage, "Anti-Fog", o, function(v) WorldModule.AntiFog(v) end); o = o + 1
    CreateToggle(worldPage, "Day Time", o, function(v) WorldModule.DayTime(v) end); o = o + 1
    CreateToggle(worldPage, "Night Time", o, function(v) WorldModule.NightTime(v) end); o = o + 1
    CreateToggle(worldPage, "Remove Post Effects", o, function(v) WorldModule.RemoveEffects(v) end); o = o + 1
    CreateToggle(worldPage, "No Weather", o, function(v) WorldModule.NoWeather(v) end); o = o + 1

    CreateSection(worldPage, "Physics", o); o = o + 1
    CreateToggle(worldPage, "Custom Gravity", o, function(v) WorldModule.CustomGravity(v) end); o = o + 1
    CreateSlider(worldPage, "Gravity Value", 0, 500, 196, o, function(v)
        Values.Gravity = v
        if State.CustomGravity then Workspace.Gravity = v end
    end); o = o + 1

    CreateSection(worldPage, "Render", o); o = o + 1
    CreateToggle(worldPage, "X-Ray", o, function(v) WorldModule.XRay(v) end); o = o + 1
    CreateToggle(worldPage, "No Invisible Walls", o, function(v) WorldModule.NoInvisWalls(v) end); o = o + 1
    CreateToggle(worldPage, "Small Characters", o, function(v) WorldModule.SmallChars(v) end); o = o + 1
    CreateToggle(worldPage, "No Clip Parts", o, function(v) WorldModule.NoClipParts(v) end); o = o + 1

    CreateSection(worldPage, "Actions", o); o = o + 1
    CreateButton(worldPage, "Anti-Lag (Remove Effects)", o, function() WorldModule.AntiLag(true) end); o = o + 1
    CreateButton(worldPage, "Map Cleaner", o, function() WorldModule.MapCleaner() end); o = o + 1
    CreateButton(worldPage, "Destroy 3D Decorations", o, function() WorldModule.Destroy3D() end); o = o + 1
    CreateButton(worldPage, "TP to Spawn", o, function() WorldModule.TPtoSpawn() end); o = o + 1
    CreateButton(worldPage, "TP to Random Player", o, function() WorldModule.TPtoRandom() end); o = o + 1

    -- ═══════════════════════════════════════
    -- TAB 5: UTILITY (16 Functions)
    -- ═══════════════════════════════════════
    local utilPage = tabPages[tabs[5]]
    o = 0

    CreateSection(utilPage, "Protection", o); o = o + 1
    CreateToggle(utilPage, "Anti-AFK", o, function(v) UtilityModule.AntiAFK(v) end); o = o + 1
    CreateToggle(utilPage, "Anti-Kick", o, function(v) UtilityModule.AntiKick(v) end); o = o + 1
    CreateToggle(utilPage, "Anti-Void", o, function(v) UtilityModule.AntiVoid(v) end); o = o + 1
    CreateToggle(utilPage, "God Mode (Attempt)", o, function(v) UtilityModule.GodMode(v) end); o = o + 1
    CreateToggle(utilPage, "No Ragdoll", o, function(v) UtilityModule.NoRagdoll(v) end); o = o + 1
    CreateToggle(utilPage, "Auto Respawn", o, function(v) UtilityModule.AutoRespawn(v) end); o = o + 1

    CreateSection(utilPage, "Character", o); o = o + 1
    CreateToggle(utilPage, "Hide Name", o, function(v) UtilityModule.HideName(v) end); o = o + 1
    CreateToggle(utilPage, "Sit", o, function(v) UtilityModule.Sit(v) end); o = o + 1
    CreateToggle(utilPage, "Infinite Stamina", o, function(v) UtilityModule.InfStamina(v) end); o = o + 1

    CreateSection(utilPage, "Chat", o); o = o + 1
    CreateToggle(utilPage, "Chat Spam", o, function(v) UtilityModule.ChatSpam(v) end); o = o + 1
    CreateSlider(utilPage, "Spam Delay (sec)", 1, 10, 2, o, function(v) Values.ChatSpamDelay = v end); o = o + 1

    CreateSection(utilPage, "Performance", o); o = o + 1
    CreateToggle(utilPage, "FPS Unlock", o, function(v) UtilityModule.FPSUnlock(v) end); o = o + 1

    CreateSection(utilPage, "Server", o); o = o + 1
    CreateButton(utilPage, "Server Hop", o, function() UtilityModule.ServerHop() end); o = o + 1
    CreateButton(utilPage, "Rejoin", o, function() UtilityModule.Rejoin() end); o = o + 1
    CreateButton(utilPage, "Copy Game ID", o, function() UtilityModule.CopyGameID() end); o = o + 1
    CreateButton(utilPage, "Copy Server ID", o, function() UtilityModule.CopyServerID() end); o = o + 1
    CreateButton(utilPage, "Reset Character", o, function() UtilityModule.ResetChar() end); o = o + 1

    -- ═══════════════════════════════════════
    -- TAB 6: HUD (16 Functions)
    -- ═══════════════════════════════════════
    local hudPage = tabPages[tabs[6]]
    o = 0

    -- HUD Display Frame
    local hudDisplay = Instance.new("Frame")
    hudDisplay.Name = "HUDDisplay"
    hudDisplay.Size = UDim2.new(0, 200, 0, 300)
    hudDisplay.Position = UDim2.new(0, 10, 0, 10)
    hudDisplay.BackgroundColor3 = Config.Theme.Background
    hudDisplay.BackgroundTransparency = 0.3
    hudDisplay.BorderSizePixel = 0
    hudDisplay.Visible = false
    hudDisplay.ZIndex = 50
    hudDisplay.Parent = gui
    Instance.new("UICorner", hudDisplay).CornerRadius = UDim.new(0, 8)

    local hudStroke = Instance.new("UIStroke")
    hudStroke.Color = Config.Theme.PrimaryDark
    hudStroke.Thickness = 1
    hudStroke.Parent = hudDisplay

    local hudLayout = Instance.new("UIListLayout")
    hudLayout.SortOrder = Enum.SortOrder.LayoutOrder
    hudLayout.Padding = UDim.new(0, 2)
    hudLayout.Parent = hudDisplay

    local hudPadding = Instance.new("UIPadding")
    hudPadding.PaddingTop = UDim.new(0, 6)
    hudPadding.PaddingLeft = UDim.new(0, 8)
    hudPadding.PaddingRight = UDim.new(0, 8)
    hudPadding.Parent = hudDisplay

    -- HUD Labels
    local hudLabels = {}
    local hudItems = {
        "FPS", "Ping", "Coords", "Players", "Velocity",
        "Session", "Clock", "Memory", "Game", "Kills"
    }
    for i, name in ipairs(hudItems) do
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 16)
        lbl.BackgroundTransparency = 1
        lbl.Text = name .. ": --"
        lbl.TextColor3 = Config.Theme.Primary
        lbl.Font = Enum.Font.Code
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.LayoutOrder = i
        lbl.ZIndex = 51
        lbl.Parent = hudDisplay
        hudLabels[name] = lbl
    end

    -- HUD Watermark
    local watermark = Instance.new("TextLabel")
    watermark.Name = "Watermark"
    watermark.Size = UDim2.new(0, 220, 0, 22)
    watermark.Position = UDim2.new(0.5, -110, 0, 5)
    watermark.BackgroundColor3 = Config.Theme.Background
    watermark.BackgroundTransparency = 0.3
    watermark.BorderSizePixel = 0
    watermark.Text = "🐍 MEDUSA ENGINE v" .. Config.Version .. " | " .. LocalPlayer.Name
    watermark.TextColor3 = Config.Theme.Primary
    watermark.Font = Enum.Font.Code
    watermark.TextSize = 12
    watermark.Visible = false
    watermark.ZIndex = 50
    watermark.Parent = gui
    Instance.new("UICorner", watermark).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", watermark).Color = Config.Theme.PrimaryDark

    -- HUD Update Loop
    local anyHUD = false
    task.spawn(function()
        while _G.Medusa and _G.Medusa.Active do
            anyHUD = false
            for _, v in pairs({State.FPSCounter, State.PingDisplay, State.Coordinates,
                State.PlayerCount, State.VelocityDisplay, State.SessionTimer,
                State.Clock, State.MemoryUsage, State.GameInfo, State.KillCounter}) do
                if v then anyHUD = true break end
            end
            hudDisplay.Visible = anyHUD

            if anyHUD then
                if State.FPSCounter then
                    local fps = math.floor(1 / RunService.RenderStepped:Wait())
                    hudLabels["FPS"].Text = "FPS: " .. fps
                    hudLabels["FPS"].Visible = true
                else hudLabels["FPS"].Visible = false end

                if State.PingDisplay then
                    local ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
                    hudLabels["Ping"].Text = "Ping: " .. ping .. "ms"
                    hudLabels["Ping"].TextColor3 = ping < 80 and Config.Theme.Primary or
                        (ping < 150 and Config.Theme.Yellow or Config.Theme.Red)
                    hudLabels["Ping"].Visible = true
                else hudLabels["Ping"].Visible = false end

                if State.Coordinates then
                    local root = GetRootPart()
                    if root then
                        local p = root.Position
                        hudLabels["Coords"].Text = string.format("XYZ: %.0f, %.0f, %.0f", p.X, p.Y, p.Z)
                    end
                    hudLabels["Coords"].Visible = true
                else hudLabels["Coords"].Visible = false end

                if State.PlayerCount then
                    hudLabels["Players"].Text = "Players: " .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers
                    hudLabels["Players"].Visible = true
                else hudLabels["Players"].Visible = false end

                if State.VelocityDisplay then
                    local root = GetRootPart()
                    if root then
                        hudLabels["Velocity"].Text = "Speed: " .. math.floor(root.Velocity.Magnitude) .. " s/s"
                    end
                    hudLabels["Velocity"].Visible = true
                else hudLabels["Velocity"].Visible = false end

                if State.SessionTimer then
                    local elapsed = math.floor(tick() - _G.Medusa.SessionStart)
                    local mins = math.floor(elapsed / 60)
                    local secs = elapsed % 60
                    hudLabels["Session"].Text = string.format("Session: %02d:%02d", mins, secs)
                    hudLabels["Session"].Visible = true
                else hudLabels["Session"].Visible = false end

                if State.Clock then
                    hudLabels["Clock"].Text = "Time: " .. os.date("%H:%M:%S")
                    hudLabels["Clock"].Visible = true
                else hudLabels["Clock"].Visible = false end

                if State.MemoryUsage then
                    local mem = math.floor(gcinfo() / 1024 * 10) / 10
                    hudLabels["Memory"].Text = "Memory: " .. mem .. " MB"
                    hudLabels["Memory"].Visible = true
                else hudLabels["Memory"].Visible = false end

                if State.GameInfo then
                    hudLabels["Game"].Text = "Game: " .. game.PlaceId
                    hudLabels["Game"].Visible = true
                else hudLabels["Game"].Visible = false end

                if State.KillCounter then
                    hudLabels["Kills"].Text = "Kills: " .. _G.Medusa.Kills
                    hudLabels["Kills"].Visible = true
                else hudLabels["Kills"].Visible = false end
            end

            task.wait(0.5)
        end
    end)

    -- HUD Tab Controls
    CreateSection(hudPage, "Info Overlays", o); o = o + 1
    CreateToggle(hudPage, "FPS Counter", o, function(v) State.FPSCounter = v ConsoleLog("FPS Counter " .. (v and "ON" or "OFF"), "HUD") end); o = o + 1
    CreateToggle(hudPage, "Ping Display", o, function(v) State.PingDisplay = v ConsoleLog("Ping Display " .. (v and "ON" or "OFF"), "HUD") end); o = o + 1
    CreateToggle(hudPage, "Coordinates", o, function(v) State.Coordinates = v ConsoleLog("Coordinates " .. (v and "ON" or "OFF"), "HUD") end); o = o + 1
    CreateToggle(hudPage, "Player Count", o, function(v) State.PlayerCount = v ConsoleLog("Player Count " .. (v and "ON" or "OFF"), "HUD") end); o = o + 1
    CreateToggle(hudPage, "Velocity Display", o, function(v) State.VelocityDisplay = v ConsoleLog("Velocity " .. (v and "ON" or "OFF"), "HUD") end); o = o + 1
    CreateToggle(hudPage, "Session Timer", o, function(v) State.SessionTimer = v ConsoleLog("Session Timer " .. (v and "ON" or "OFF"), "HUD") end); o = o + 1
    CreateToggle(hudPage, "Clock", o, function(v) State.Clock = v ConsoleLog("Clock " .. (v and "ON" or "OFF"), "HUD") end); o = o + 1
    CreateToggle(hudPage, "Memory Usage", o, function(v) State.MemoryUsage = v ConsoleLog("Memory " .. (v and "ON" or "OFF"), "HUD") end); o = o + 1
    CreateToggle(hudPage, "Game Info", o, function(v) State.GameInfo = v ConsoleLog("Game Info " .. (v and "ON" or "OFF"), "HUD") end); o = o + 1
    CreateToggle(hudPage, "Kill Counter", o, function(v) State.KillCounter = v ConsoleLog("Kill Counter " .. (v and "ON" or "OFF"), "HUD") end); o = o + 1

    CreateSection(hudPage, "Branding", o); o = o + 1
    CreateToggle(hudPage, "Watermark", o, function(v)
        State.Watermark = v
        watermark.Visible = v
        ConsoleLog("Watermark " .. (v and "ON" or "OFF"), "HUD")
    end); o = o + 1
    CreateToggle(hudPage, "Notifications", o, function(v) State.Notifications = v end); o = o + 1
    CreateToggle(hudPage, "Keybind List", o, function(v) State.KeybindList = v ConsoleLog("Keybind List " .. (v and "ON" or "OFF"), "HUD") end); o = o + 1
    CreateToggle(hudPage, "Minimap Dot", o, function(v) State.MinimapDot = v ConsoleLog("Minimap " .. (v and "ON" or "OFF"), "HUD") end); o = o + 1
    CreateToggle(hudPage, "Performance Stats", o, function(v) State.PerfStats = v ConsoleLog("Perf Stats " .. (v and "ON" or "OFF"), "HUD") end); o = o + 1
    CreateToggle(hudPage, "Target Info HUD", o, function(v) State.TargetInfoHUD = v ConsoleLog("Target Info " .. (v and "ON" or "OFF"), "HUD") end); o = o + 1

    -- ═══════════════════════════════════════
    -- FOOTER
    -- ═══════════════════════════════════════
    local footerLine = Instance.new("Frame")
    footerLine.Size = UDim2.new(1, -20, 0, 1)
    footerLine.Position = UDim2.new(0, 10, 1, -32)
    footerLine.BackgroundColor3 = Config.Theme.Primary
    footerLine.BorderSizePixel = 0
    footerLine.ZIndex = 12
    footerLine.Parent = mainFrame

    local footGrad = Instance.new("UIGradient")
    footGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
        ColorSequenceKeypoint.new(0.3, Config.Theme.Primary),
        ColorSequenceKeypoint.new(0.7, Config.Theme.Primary),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
    })
    footGrad.Parent = footerLine

    local footer = Instance.new("TextLabel")
    footer.Size = UDim2.new(1, -20, 0, 24)
    footer.Position = UDim2.new(0, 10, 1, -28)
    footer.BackgroundTransparency = 1
    footer.Text = "🐍 Medusa Engine · [M] Toggle · [F] Fly · [N] Noclip · [Q] Dash"
    footer.TextColor3 = Config.Theme.TextDim
    footer.Font = Enum.Font.Gotham
    footer.TextSize = 10
    footer.ZIndex = 12
    footer.Parent = mainFrame

    -- Ping in footer
    local footerPing = Instance.new("TextLabel")
    footerPing.Size = UDim2.new(0, 60, 0, 24)
    footerPing.Position = UDim2.new(1, -70, 1, -28)
    footerPing.BackgroundTransparency = 1
    footerPing.Text = "-- ms"
    footerPing.TextColor3 = Config.Theme.Primary
    footerPing.Font = Enum.Font.Code
    footerPing.TextSize = 10
    footerPing.TextXAlignment = Enum.TextXAlignment.Right
    footerPing.ZIndex = 12
    footerPing.Parent = mainFrame

    task.spawn(function()
        while _G.Medusa and _G.Medusa.Active do
            local ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
            footerPing.Text = ping .. " ms"
            footerPing.TextColor3 = ping < 80 and Config.Theme.Primary or
                (ping < 150 and Config.Theme.Yellow or Config.Theme.Red)
            task.wait(2)
        end
    end)

    -- ═══════════════════════════════════════
    -- SLIDE UP ANIMATION (EasingStyle.Back)
    -- ═══════════════════════════════════════
    SafeTween(mainFrame,
        TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Position = UDim2.new(0.5, -260, 0.5, -320)}
    )

    ShowToast("Medusa Engine loaded! 96 functions ready.")
    ConsoleLog("🐍 Medusa Engine v" .. Config.Version .. " initialized with 96 functions", "SYSTEM")

    return mainFrame
end

-- ╔══════════════════════════════════════════════════════╗
-- ║      SECTION 13: KEYBIND SYSTEM                     ║
-- ╚══════════════════════════════════════════════════════╝

local function SetupKeybinds(mainFrame)
    AddConnection(UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end

        -- [M] Toggle UI
        if input.KeyCode == Config.Keybinds.ToggleUI then
            _G.Medusa.UIVisible = not _G.Medusa.UIVisible
            if _G.Medusa.UIVisible then
                SafeTween(mainFrame,
                    TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                    {Position = UDim2.new(0.5, -260, 0.5, -320)})
            else
                SafeTween(mainFrame,
                    TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In),
                    {Position = UDim2.new(0.5, -260, 1.2, 0)})
            end
        end

        -- [F] Toggle Fly
        if input.KeyCode == Config.Keybinds.Fly then
            State.Fly = not State.Fly
            MovementModule.Fly(State.Fly)
        end

        -- [N] Toggle Noclip
        if input.KeyCode == Config.Keybinds.Noclip then
            State.Noclip = not State.Noclip
            MovementModule.Noclip(State.Noclip)
        end
    end))
end

-- ╔══════════════════════════════════════════════════════╗
-- ║         SECTION 14: INITIALIZE ENGINE               ║
-- ╚══════════════════════════════════════════════════════╝

ConsoleLog("🐍 Medusa Universal Engine v" .. Config.Version .. " starting...", "SYSTEM")
ConsoleLog("Hard Clean: Complete", "SYSTEM")
ConsoleLog("Modules: Combat v2, ESP 3D, Movement, World, Utility, HUD", "SYSTEM")
ConsoleLog("Total Functions: 96", "SYSTEM")

PlayCinematicIntro(function()
    local mainFrame = BuildMainUI()
    SetupKeybinds(mainFrame)

    -- Handle respawn
    AddConnection(LocalPlayer.CharacterAdded:Connect(function(char)
        ConsoleLog("Character respawned — reapplying active functions", "SYSTEM")
        task.wait(1)

        if State.WalkSpeedOn then
            local hum = GetHumanoid()
            if hum then hum.WalkSpeed = Values.WalkSpeed end
        end
        if State.JumpPowerOn then
            local hum = GetHumanoid()
            if hum then hum.UseJumpPower = true hum.JumpPower = Values.JumpPower end
        end
        if State.Fly then
            MovementModule.Fly(false)
            task.wait(0.5)
            MovementModule.Fly(true)
        end
        if State.Noclip then
            MovementModule.Noclip(true)
        end
    end))

    ConsoleLog("🐍 Engine ready. Welcome to Medusa.", "SYSTEM")
end)
