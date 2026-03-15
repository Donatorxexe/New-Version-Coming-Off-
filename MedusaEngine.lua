--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║          🐍 MEDUSA UNIVERSAL ENGINE v1.0.2 🐍               ║
    ║            C O B R A   E D I T I O N                        ║
    ║                                                              ║
    ║  96 Functions | 5 Tabs | 2-Column Layout | Search Bar       ║
    ║  Combat | Vision (ESP) | Movement | World & Utl | HUD       ║
    ║                                                              ║
    ║  Metatable Bypass | Hard Clean | Passive Load | Neon Intro   ║
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
-- ║   SECTION 2: METATABLE BYPASS         ║
-- ╚════════════════════════════════════════╝

local BypassActive = false
pcall(function()
    local mt = getrawmetatable(game)
    if mt then
        local oldIndex = mt.__index
        local oldNewindex = mt.__newindex
        if setreadonly then setreadonly(mt, false) end
        if make_writeable then make_writeable(mt) end

        mt.__newindex = newcclosure and newcclosure(function(self, key, value)
            if BypassActive then
                if key == "WalkSpeed" or key == "JumpPower" or key == "JumpHeight" then
                    return rawset(self, key, value)
                end
            end
            return oldNewindex(self, key, value)
        end) or function(self, key, value)
            if BypassActive then
                if key == "WalkSpeed" or key == "JumpPower" or key == "JumpHeight" then
                    return rawset(self, key, value)
                end
            end
            return oldNewindex(self, key, value)
        end

        if setreadonly then setreadonly(mt, true) end
        BypassActive = true
    end
end)

-- ╔════════════════════════════════════════╗
-- ║   SECTION 3: SERVICES & CONFIG        ║
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
    Version = "1.0.5",
    Name = "MEDUSA",
    ClickSound = "rbxassetid://6895079853",
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
-- ║   SECTION 4: STATE & VALUES           ║
-- ╚════════════════════════════════════════╝

local State = {
    -- Combat
    SilentAim = false, Aimbot = false, KillAura = false, AutoParry = false,
    Reach = false, AutoCombo = false, TriggerBot = false, FOVCircle = false,
    TargetStrafe = false, AutoBlock = false, ClickTP = false, TargetInfo = false,
    AntiBackstab = false, AutoClicker = false, ComboLock = false, HitboxExpander = false,
    -- ESP
    BoxESP = false, NameESP = false, HealthESP = false, DistanceESP = false,
    Tracers = false, Chams = false, HeadDot = false, SkeletonESP = false,
    ItemESP = false, NPCESP = false, CornerBox = false, TeamCheck = false,
    VisibleCheck = false, Crosshair = false, FOVDisplay = false, RadarESP = false,
    -- Movement
    WalkSpeedOn = false, JumpPowerOn = false, Fly = false, Noclip = false,
    InfiniteJump = false, SpeedGlitch = false, LongJump = false, HighJump = false,
    Spider = false, Phase = false, TPtoMouse = false, AutoWalk = false,
    BunnyHop = false, Glide = false, Dash = false, Anchor = false,
    -- World
    Fullbright = false, AntiFog = false, DayTime = false, NightTime = false,
    NoWeather = false, RemoveEffects = false, AntiLag = false, NoInvisWalls = false,
    XRay = false, SmallChars = false, CustomGravity = false, TPtoRandom = false,
    TPtoSpawn = false, MapCleaner = false, NoClipParts = false, Destroy3D = false,
    -- Utility
    AntiAFK = false, ServerHop = false, Rejoin = false, FPSUnlock = false,
    ChatSpam = false, AntiKick = false, GodMode = false, CopyGameID = false,
    CopyServerID = false, ResetChar = false, HideName = false, Sit = false,
    AntiVoid = false, AutoRespawn = false, InfStamina = false, NoRagdoll = false,
    -- HUD
    FPSCounter = false, PingDisplay = false, Coordinates = false, PlayerCount = false,
    VelocityDisplay = false, TargetInfoHUD = false, Watermark = false, KeybindList = false,
    SessionTimer = false, KillCounter = false, Clock = false, MemoryUsage = false,
    GameInfo = false, Notifications = true, MinimapDot = false, PerfStats = false,
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
    ChatSpamMsg = "Medusa Engine",
    ChatSpamDelay = 2,
    DashPower = 100,
    HighJumpPower = 150,
    GlideSpeed = 50,
    SoundVolume = 0.5,
}

-- ╔════════════════════════════════════════╗
-- ║  SECTION 5: GLOBAL STATE              ║
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
    AllCards = {},
}

-- ╔════════════════════════════════════════╗
-- ║     SECTION 6: UTILITY FUNCTIONS      ║
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
    local success = pcall(function()
        TweenService:Create(obj, info, props):Play()
    end)
    return success
end

local function AddConnection(conn)
    table.insert(_G.Medusa.Connections, conn)
    return conn
end

-- ══════ DRAGGABLE SYSTEM (PC + Mobile) ══════
local function MakeDraggable(frame, dragHandle)
    dragHandle = dragHandle or frame
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ══════ ACTIVE MODULES LIST UPDATER (v1.0.5 — Anti-Duplicate) ══════
local function UpdateActiveList(name, isOn)
    local content = _G.Medusa.ActiveListContent
    if not content then return end

    local safeName = "Active_" .. string.gsub(name, "%s", "_")

    if isOn then
        -- Prevent duplicates: destroy existing before creating new
        local existing = content:FindFirstChild(safeName)
        if existing then return end

        local entry = Instance.new("TextLabel")
        entry.Name = safeName
        entry.Size = UDim2.new(1, 0, 0, 15)
        entry.BackgroundTransparency = 1
        entry.Text = "▸ " .. name
        entry.TextColor3 = Config.Theme.Accent
        entry.Font = Enum.Font.Gotham
        entry.TextSize = 10
        entry.TextXAlignment = Enum.TextXAlignment.Left
        entry.TextTransparency = 1
        entry.ZIndex = 52
        entry.Parent = content
        SafeTween(entry, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0})
    else
        local entry = content:FindFirstChild(safeName)
        if entry then
            SafeTween(entry, TweenInfo.new(0.25), {TextTransparency = 1})
            task.delay(0.3, function()
                if entry and entry.Parent then entry:Destroy() end
            end)
        end
    end
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

-- ══════ CLICK SOUND SYSTEM ══════
local function PlayClickSound()
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = Config.ClickSound
        sound.Volume = Values.SoundVolume
        sound.PlayOnRemove = false
        sound.Parent = game:GetService("SoundService")
        sound:Play()
        game:GetService("Debris"):AddItem(sound, 1)
    end)
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
-- ║    SECTION 7: COMBAT v2 MODULE (16 Functions)     ║
-- ╚════════════════════════════════════════════════════╝

local CombatModule = {}

function CombatModule.SilentAim(enabled)
    State.SilentAim = enabled
    ConsoleLog("Silent Aim " .. (enabled and "ENABLED" or "DISABLED"), "COMBAT")
end

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
                                                local blockRemote = ReplicatedStorage:FindFirstChild("Block") or
                                                    ReplicatedStorage:FindFirstChild("BlockEvent")
                                                if blockRemote then blockRemote:FireServer() end
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
                        tool.Handle.Size = Vector3.new(Values.Reach, Values.Reach, Values.Reach)
                        tool.Handle.Massless = true
                        tool.Handle.Transparency = 1
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

function CombatModule.AutoCombo(enabled)
    State.AutoCombo = enabled
    if enabled then
        _G.Medusa.Loops.AutoCombo = true
        ConsoleLog("Auto Combo ENABLED", "COMBAT")
        task.spawn(function()
            while _G.Medusa.Loops.AutoCombo and State.AutoCombo do
                local target = GetClosestPlayer(Values.Reach + 5, false)
                if target then
                    mouse1click(); task.wait(0.15)
                    mouse1click(); task.wait(0.15)
                    mouse1click(); task.wait(0.4)
                end
                task.wait(0.1)
            end
        end)
    else
        _G.Medusa.Loops.AutoCombo = false
        ConsoleLog("Auto Combo DISABLED", "COMBAT")
    end
end

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
                                task.wait(0.05); continue
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
        if _G.Medusa.FOVCircleDraw then _G.Medusa.FOVCircleDraw.Visible = false end
        _G.Medusa.Loops.FOVCircle = false
        ConsoleLog("FOV Circle DISABLED", "COMBAT")
    end
end

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
                        local offset = Vector3.new(math.cos(rad) * Values.TargetStrafeRadius, 0, math.sin(rad) * Values.TargetStrafeRadius)
                        root.CFrame = CFrame.new(hrp.Position + offset, hrp.Position)
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

function CombatModule.AutoBlock(enabled)
    State.AutoBlock = enabled
    if enabled then
        _G.Medusa.Loops.AutoBlock = true
        ConsoleLog("Auto Block ENABLED", "COMBAT")
        task.spawn(function()
            while _G.Medusa.Loops.AutoBlock and State.AutoBlock do
                local root = GetRootPart()
                if root then
                    local shouldBlock = false
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character then
                            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                            if hrp and (root.Position - hrp.Position).Magnitude < 20 then
                                shouldBlock = true
                            end
                        end
                    end
                    if shouldBlock then
                        local blockRemote = ReplicatedStorage:FindFirstChild("Block") or
                            ReplicatedStorage:FindFirstChild("BlockEvent")
                        if blockRemote then pcall(function() blockRemote:FireServer(true) end) end
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

function CombatModule.ClickTP(enabled)
    State.ClickTP = enabled
    if enabled then
        ConsoleLog("Click TP ENABLED", "COMBAT")
        _G.Medusa.ClickTPConn = AddConnection(LocalPlayer:GetMouse().Button1Down:Connect(function()
            if State.ClickTP then
                local mouse = LocalPlayer:GetMouse()
                local root = GetRootPart()
                if root and mouse.Hit then root.CFrame = mouse.Hit + Vector3.new(0, 3, 0) end
            end
        end))
    else
        if _G.Medusa.ClickTPConn then _G.Medusa.ClickTPConn:Disconnect(); _G.Medusa.ClickTPConn = nil end
        ConsoleLog("Click TP DISABLED", "COMBAT")
    end
end

function CombatModule.TargetInfo(enabled)
    State.TargetInfo = enabled
    ConsoleLog("Target Info " .. (enabled and "ENABLED" or "DISABLED"), "COMBAT")
end

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
                                    local dot = (hrp.Position - root.Position).Unit:Dot(root.CFrame.LookVector)
                                    if dot < -0.5 then root.CFrame = CFrame.new(root.Position, hrp.Position) end
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
                            hrp.Transparency = 0.7; hrp.CanCollide = false
                            hrp.Material = Enum.Material.ForceField
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
                if hrp then hrp.Size = Vector3.new(2, 2, 1); hrp.Transparency = 1 end
            end
        end
        ConsoleLog("Hitbox Expander DISABLED", "COMBAT")
    end
end

-- ╔════════════════════════════════════════════════════╗
-- ║      SECTION 8: ESP 3D MODULE (16 Functions)      ║
-- ╚════════════════════════════════════════════════════╝

local ESPModule = {}

local function ClearESP()
    for _, obj in pairs(_G.Medusa.ESPObjects) do
        pcall(function()
            if typeof(obj) == "Instance" then obj:Destroy()
            elseif type(obj) == "table" and obj.Remove then obj:Remove() end
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

    if State.Chams then
        local highlight = Instance.new("Highlight")
        highlight.FillColor = Config.Theme.Primary; highlight.FillTransparency = 0.7
        highlight.OutlineColor = Config.Theme.Accent; highlight.OutlineTransparency = 0.3
        highlight.Adornee = player.Character; highlight.Parent = espFolder
    end

    local bb = Instance.new("BillboardGui")
    bb.Adornee = head; bb.Size = UDim2.new(0, 200, 0, 80)
    bb.StudsOffset = Vector3.new(0, 3, 0); bb.AlwaysOnTop = true; bb.Parent = espFolder
    local yOff = 0

    if State.NameESP then
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0, 16); nameLabel.Position = UDim2.new(0, 0, 0, yOff)
        nameLabel.BackgroundTransparency = 1; nameLabel.Text = player.DisplayName .. " (@" .. player.Name .. ")"
        nameLabel.TextColor3 = Config.Theme.Primary; nameLabel.TextStrokeColor3 = Config.Theme.Black
        nameLabel.TextStrokeTransparency = 0.3; nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 13; nameLabel.Parent = bb; yOff = yOff + 16
    end

    if State.HealthESP then
        local hpBg = Instance.new("Frame")
        hpBg.Size = UDim2.new(0.8, 0, 0, 4); hpBg.Position = UDim2.new(0.1, 0, 0, yOff + 2)
        hpBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40); hpBg.BorderSizePixel = 0; hpBg.Parent = bb
        Instance.new("UICorner", hpBg).CornerRadius = UDim.new(0, 2)
        local hpFill = Instance.new("Frame")
        hpFill.Size = UDim2.new(math.clamp(hum.Health / hum.MaxHealth, 0, 1), 0, 1, 0)
        hpFill.BackgroundColor3 = Config.Theme.Primary; hpFill.BorderSizePixel = 0; hpFill.Parent = hpBg
        Instance.new("UICorner", hpFill).CornerRadius = UDim.new(0, 2)
        table.insert(_G.Medusa.ESPObjects, hpFill); yOff = yOff + 8
    end

    if State.DistanceESP then
        local distLabel = Instance.new("TextLabel")
        distLabel.Size = UDim2.new(1, 0, 0, 14); distLabel.Position = UDim2.new(0, 0, 0, yOff + 2)
        distLabel.BackgroundTransparency = 1; distLabel.Text = "0m"
        distLabel.TextColor3 = Config.Theme.TextDim; distLabel.TextStrokeColor3 = Config.Theme.Black
        distLabel.TextStrokeTransparency = 0.5; distLabel.Font = Enum.Font.Gotham
        distLabel.TextSize = 11; distLabel.Name = "DistLabel"; distLabel.Parent = bb
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
                        local espFolder = player.Character:FindFirstChild("MedusaESP_" .. player.Name)
                        if espFolder and hrp then
                            local dist = math.floor((root.Position - hrp.Position).Magnitude)
                            if dist > Values.ESPMaxDist then espFolder.Parent = nil
                            else
                                espFolder.Parent = player.Character
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
                        if hrp and not player.Character:FindFirstChild("MedusaBox") then
                            local box = Instance.new("BoxHandleAdornment")
                            box.Name = "MedusaBox"; box.Adornee = hrp
                            box.Size = Vector3.new(4, 5, 1); box.Color3 = Config.Theme.Primary
                            box.Transparency = 0.6; box.AlwaysOnTop = true; box.ZIndex = 5
                            box.Parent = player.Character
                            table.insert(_G.Medusa.ESPObjects, box)
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

function ESPModule.NameESP(enabled)
    State.NameESP = enabled
    ConsoleLog("Name ESP " .. (enabled and "ENABLED" or "DISABLED"), "ESP")
    ClearESP()
    if enabled then
        for _, p in pairs(Players:GetPlayers()) do CreateESPForPlayer(p) end
        UpdateESPLoop()
    else _G.Medusa.Loops.ESP = false end
end

function ESPModule.HealthESP(enabled)
    State.HealthESP = enabled
    ConsoleLog("Health ESP " .. (enabled and "ENABLED" or "DISABLED"), "ESP")
    ClearESP()
    if enabled or State.NameESP or State.DistanceESP then
        for _, p in pairs(Players:GetPlayers()) do CreateESPForPlayer(p) end
        UpdateESPLoop()
    end
end

function ESPModule.DistanceESP(enabled)
    State.DistanceESP = enabled
    ConsoleLog("Distance ESP " .. (enabled and "ENABLED" or "DISABLED"), "ESP")
    ClearESP()
    if enabled or State.NameESP or State.HealthESP then
        for _, p in pairs(Players:GetPlayers()) do CreateESPForPlayer(p) end
        UpdateESPLoop()
    end
end

function ESPModule.Tracers(enabled)
    State.Tracers = enabled
    if enabled then
        _G.Medusa.Loops.Tracers = true
        _G.Medusa.TracerLines = _G.Medusa.TracerLines or {}
        ConsoleLog("Tracers ENABLED", "ESP")
        task.spawn(function()
            while _G.Medusa.Loops.Tracers and State.Tracers do
                for _, line in pairs(_G.Medusa.TracerLines) do pcall(function() line:Remove() end) end
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
                                    line.Color = Config.Theme.Primary; line.Thickness = 1.5
                                    line.Transparency = 0.7; line.Visible = true
                                    table.insert(_G.Medusa.TracerLines, line)
                                end)
                            end
                        end
                    end
                end
                RunService.RenderStepped:Wait()
            end
            for _, line in pairs(_G.Medusa.TracerLines or {}) do pcall(function() line:Remove() end) end
            _G.Medusa.TracerLines = {}
        end)
    else
        _G.Medusa.Loops.Tracers = false
        ConsoleLog("Tracers DISABLED", "ESP")
    end
end

function ESPModule.Chams(enabled)
    State.Chams = enabled
    ConsoleLog("Chams " .. (enabled and "ENABLED" or "DISABLED"), "ESP")
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            local folder = player.Character:FindFirstChild("MedusaESP_" .. player.Name)
            if folder then local h = folder:FindFirstChildOfClass("Highlight"); if h then h:Destroy() end end
        end
    end
    if enabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local folder = player.Character:FindFirstChild("MedusaESP_" .. player.Name)
                if not folder then
                    folder = Instance.new("Folder"); folder.Name = "MedusaESP_" .. player.Name
                    folder.Parent = player.Character; table.insert(_G.Medusa.ESPObjects, folder)
                end
                local highlight = Instance.new("Highlight")
                highlight.FillColor = Config.Theme.Primary; highlight.FillTransparency = 0.7
                highlight.OutlineColor = Config.Theme.Accent; highlight.OutlineTransparency = 0.3
                highlight.Adornee = player.Character; highlight.Parent = folder
            end
        end
    end
end

function ESPModule.HeadDot(enabled)
    State.HeadDot = enabled
    if enabled then
        _G.Medusa.Loops.HeadDot = true; _G.Medusa.HeadDots = {}
        ConsoleLog("Head Dot ENABLED", "ESP")
        task.spawn(function()
            while _G.Medusa.Loops.HeadDot and State.HeadDot do
                for _, dot in pairs(_G.Medusa.HeadDots) do pcall(function() dot:Remove() end) end
                _G.Medusa.HeadDots = {}
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local head = player.Character:FindFirstChild("Head")
                        if head then
                            local sp, on = Camera:WorldToViewportPoint(head.Position)
                            if on then pcall(function()
                                local dot = Drawing.new("Circle")
                                dot.Position = Vector2.new(sp.X, sp.Y); dot.Radius = 3
                                dot.Color = Config.Theme.Primary; dot.Filled = true; dot.Visible = true
                                table.insert(_G.Medusa.HeadDots, dot)
                            end) end
                        end
                    end
                end
                RunService.RenderStepped:Wait()
            end
            for _, dot in pairs(_G.Medusa.HeadDots or {}) do pcall(function() dot:Remove() end) end
        end)
    else _G.Medusa.Loops.HeadDot = false; ConsoleLog("Head Dot DISABLED", "ESP") end
end

function ESPModule.SkeletonESP(enabled)
    State.SkeletonESP = enabled
    ConsoleLog("Skeleton ESP " .. (enabled and "ENABLED" or "DISABLED"), "ESP")
    if enabled then
        _G.Medusa.Loops.Skeleton = true; _G.Medusa.SkeletonLines = {}
        task.spawn(function()
            local bones = {
                {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
                {"UpperTorso","LeftUpperArm"},{"UpperTorso","RightUpperArm"},
                {"LeftUpperArm","LeftLowerArm"},{"RightUpperArm","RightLowerArm"},
                {"LeftLowerArm","LeftHand"},{"RightLowerArm","RightHand"},
                {"LowerTorso","LeftUpperLeg"},{"LowerTorso","RightUpperLeg"},
                {"LeftUpperLeg","LeftLowerLeg"},{"RightUpperLeg","RightLowerLeg"},
                {"LeftLowerLeg","LeftFoot"},{"RightLowerLeg","RightFoot"},
            }
            while _G.Medusa.Loops.Skeleton and State.SkeletonESP do
                for _, l in pairs(_G.Medusa.SkeletonLines) do pcall(function() l:Remove() end) end
                _G.Medusa.SkeletonLines = {}
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        for _, bone in pairs(bones) do
                            local p1, p2 = player.Character:FindFirstChild(bone[1]), player.Character:FindFirstChild(bone[2])
                            if p1 and p2 then
                                local s1, o1 = Camera:WorldToViewportPoint(p1.Position)
                                local s2, o2 = Camera:WorldToViewportPoint(p2.Position)
                                if o1 and o2 then pcall(function()
                                    local line = Drawing.new("Line")
                                    line.From = Vector2.new(s1.X, s1.Y); line.To = Vector2.new(s2.X, s2.Y)
                                    line.Color = Config.Theme.Primary; line.Thickness = 1.5; line.Visible = true
                                    table.insert(_G.Medusa.SkeletonLines, line)
                                end) end
                            end
                        end
                    end
                end
                RunService.RenderStepped:Wait()
            end
            for _, l in pairs(_G.Medusa.SkeletonLines or {}) do pcall(function() l:Remove() end) end
        end)
    else _G.Medusa.Loops.Skeleton = false end
end

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
                            local bb = Instance.new("BillboardGui"); bb.Name = "MedusaItemESP"
                            bb.Adornee = obj:IsA("Tool") and (obj:FindFirstChild("Handle") or obj) or obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")
                            bb.Size = UDim2.new(0, 150, 0, 20); bb.StudsOffset = Vector3.new(0, 2, 0)
                            bb.AlwaysOnTop = true; bb.Parent = obj
                            local label = Instance.new("TextLabel"); label.Size = UDim2.new(1, 0, 1, 0)
                            label.BackgroundTransparency = 1; label.Text = "Item: " .. obj.Name
                            label.TextColor3 = Config.Theme.Yellow; label.TextStrokeColor3 = Config.Theme.Black
                            label.TextStrokeTransparency = 0.3; label.Font = Enum.Font.GothamBold
                            label.TextSize = 12; label.Parent = bb
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
            local esp = obj:FindFirstChild("MedusaItemESP"); if esp then esp:Destroy() end
        end
    end
end

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
                                local bb = Instance.new("BillboardGui"); bb.Name = "MedusaNPCESP"
                                bb.Adornee = head; bb.Size = UDim2.new(0, 150, 0, 20)
                                bb.StudsOffset = Vector3.new(0, 2.5, 0); bb.AlwaysOnTop = true; bb.Parent = model
                                local label = Instance.new("TextLabel"); label.Size = UDim2.new(1, 0, 1, 0)
                                label.BackgroundTransparency = 1; label.Text = "NPC: " .. model.Name
                                label.TextColor3 = Config.Theme.Red; label.TextStrokeColor3 = Config.Theme.Black
                                label.TextStrokeTransparency = 0.3; label.Font = Enum.Font.GothamBold
                                label.TextSize = 12; label.Parent = bb
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
        for _, m in pairs(Workspace:GetDescendants()) do
            local e = m:FindFirstChild("MedusaNPCESP"); if e then e:Destroy() end
        end
    end
end

function ESPModule.CornerBox(enabled) State.CornerBox = enabled; ConsoleLog("Corner Box " .. (enabled and "ENABLED" or "DISABLED"), "ESP") end
function ESPModule.TeamCheck(enabled) State.TeamCheck = enabled; ConsoleLog("Team Check " .. (enabled and "ENABLED" or "DISABLED"), "ESP") end
function ESPModule.VisibleCheck(enabled) State.VisibleCheck = enabled; ConsoleLog("Visible Check " .. (enabled and "ENABLED" or "DISABLED"), "ESP") end

function ESPModule.Crosshair(enabled)
    State.Crosshair = enabled
    if enabled then
        ConsoleLog("Crosshair ENABLED", "ESP")
        _G.Medusa.CrosshairLines = {}; _G.Medusa.Loops.Crosshair = true
        task.spawn(function()
            local lines = {}
            for i = 1, 4 do pcall(function()
                local l = Drawing.new("Line"); l.Color = Config.Theme.Primary; l.Thickness = 1.5; l.Visible = true
                lines[i] = l
            end) end
            _G.Medusa.CrosshairLines = lines
            while _G.Medusa.Loops.Crosshair and State.Crosshair do
                local cx, cy = Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2
                local gap, size = 5, 12
                if lines[1] then lines[1].From = Vector2.new(cx-size, cy); lines[1].To = Vector2.new(cx-gap, cy) end
                if lines[2] then lines[2].From = Vector2.new(cx+gap, cy); lines[2].To = Vector2.new(cx+size, cy) end
                if lines[3] then lines[3].From = Vector2.new(cx, cy-size); lines[3].To = Vector2.new(cx, cy-gap) end
                if lines[4] then lines[4].From = Vector2.new(cx, cy+gap); lines[4].To = Vector2.new(cx, cy+size) end
                RunService.RenderStepped:Wait()
            end
            for _, l in pairs(lines) do pcall(function() l:Remove() end) end
        end)
    else _G.Medusa.Loops.Crosshair = false; ConsoleLog("Crosshair DISABLED", "ESP") end
end

function ESPModule.FOVDisplay(enabled) State.FOVDisplay = enabled; CombatModule.FOVCircle(enabled) end
function ESPModule.RadarESP(enabled) State.RadarESP = enabled; ConsoleLog("Radar " .. (enabled and "ENABLED" or "DISABLED"), "ESP") end

-- ╔════════════════════════════════════════════════════╗
-- ║    SECTION 9: MOVEMENT MODULE (16 Functions)      ║
-- ╚════════════════════════════════════════════════════╝

local MovementModule = {}

function MovementModule.WalkSpeed(enabled)
    State.WalkSpeedOn = enabled
    if enabled then
        _G.Medusa.Loops.WalkSpeed = true
        ConsoleLog("WalkSpeed ENABLED ("..Values.WalkSpeed..")", "MOVE")
        task.spawn(function()
            while _G.Medusa.Loops.WalkSpeed and State.WalkSpeedOn do
                local hum = GetHumanoid(); if hum then hum.WalkSpeed = Values.WalkSpeed end
                task.wait(0.1)
            end
        end)
    else
        _G.Medusa.Loops.WalkSpeed = false
        local hum = GetHumanoid(); if hum then hum.WalkSpeed = Config.Defaults.WalkSpeed end
        ConsoleLog("WalkSpeed DISABLED", "MOVE")
    end
end

function MovementModule.JumpPower(enabled)
    State.JumpPowerOn = enabled
    if enabled then
        _G.Medusa.Loops.JumpPower = true
        ConsoleLog("JumpPower ENABLED ("..Values.JumpPower..")", "MOVE")
        task.spawn(function()
            while _G.Medusa.Loops.JumpPower and State.JumpPowerOn do
                local hum = GetHumanoid()
                if hum then hum.UseJumpPower = true; hum.JumpPower = Values.JumpPower end
                task.wait(0.1)
            end
        end)
    else
        _G.Medusa.Loops.JumpPower = false
        local hum = GetHumanoid(); if hum then hum.JumpPower = Config.Defaults.JumpPower end
        ConsoleLog("JumpPower DISABLED", "MOVE")
    end
end

function MovementModule.Fly(enabled)
    State.Fly = enabled
    if enabled then
        ConsoleLog("Fly ENABLED (Speed: "..Values.FlySpeed..")", "MOVE")
        local root = GetRootPart(); local hum = GetHumanoid()
        if not root or not hum then return end
        local bv = Instance.new("BodyVelocity"); bv.Name = "MedusaFly"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0, 0, 0); bv.Parent = root
        local bg = Instance.new("BodyGyro"); bg.Name = "MedusaGyro"
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.D = 200; bg.P = 10000; bg.Parent = root
        _G.Medusa.FlyBV = bv; _G.Medusa.FlyBG = bg; _G.Medusa.Loops.Fly = true
        hum.PlatformStand = true
        AddConnection(RunService.RenderStepped:Connect(function()
            if not _G.Medusa.Loops.Fly or not State.Fly then return end
            if not root or not root.Parent then return end
            local dir = Vector3.new(0, 0, 0); local camCF = Camera.CFrame
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + camCF.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - camCF.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - camCF.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + camCF.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
            if dir.Magnitude > 0 then dir = dir.Unit * Values.FlySpeed end
            bv.Velocity = dir; bg.CFrame = camCF
        end))
    else
        _G.Medusa.Loops.Fly = false
        if _G.Medusa.FlyBV then _G.Medusa.FlyBV:Destroy(); _G.Medusa.FlyBV = nil end
        if _G.Medusa.FlyBG then _G.Medusa.FlyBG:Destroy(); _G.Medusa.FlyBG = nil end
        local hum = GetHumanoid(); if hum then hum.PlatformStand = false end
        ConsoleLog("Fly DISABLED", "MOVE")
    end
end

function MovementModule.Noclip(enabled)
    State.Noclip = enabled
    if enabled then
        _G.Medusa.Loops.Noclip = true; ConsoleLog("Noclip ENABLED", "MOVE")
        AddConnection(RunService.Stepped:Connect(function()
            if not _G.Medusa.Loops.Noclip or not State.Noclip then return end
            local char = GetCharacter()
            if char then for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end end
        end))
    else _G.Medusa.Loops.Noclip = false; ConsoleLog("Noclip DISABLED", "MOVE") end
end

function MovementModule.InfiniteJump(enabled)
    State.InfiniteJump = enabled
    if enabled then
        ConsoleLog("Infinite Jump ENABLED", "MOVE")
        _G.Medusa.InfJumpConn = AddConnection(UserInputService.JumpRequest:Connect(function()
            if State.InfiniteJump then
                local hum = GetHumanoid(); if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end))
    else
        if _G.Medusa.InfJumpConn then _G.Medusa.InfJumpConn:Disconnect(); _G.Medusa.InfJumpConn = nil end
        ConsoleLog("Infinite Jump DISABLED", "MOVE")
    end
end

function MovementModule.SpeedGlitch(enabled)
    State.SpeedGlitch = enabled
    if enabled then
        _G.Medusa.Loops.SpeedGlitch = true; ConsoleLog("Speed Glitch ENABLED", "MOVE")
        task.spawn(function()
            while _G.Medusa.Loops.SpeedGlitch and State.SpeedGlitch do
                local root = GetRootPart(); local hum = GetHumanoid()
                if root and hum and hum.MoveDirection.Magnitude > 0 then
                    root.CFrame = root.CFrame + hum.MoveDirection * (Values.WalkSpeed / 16)
                end
                RunService.RenderStepped:Wait()
            end
        end)
    else _G.Medusa.Loops.SpeedGlitch = false; ConsoleLog("Speed Glitch DISABLED", "MOVE") end
end

function MovementModule.LongJump(enabled)
    State.LongJump = enabled
    if enabled then
        _G.Medusa.Loops.LongJump = true; ConsoleLog("Long Jump ENABLED", "MOVE")
        task.spawn(function()
            while _G.Medusa.Loops.LongJump and State.LongJump do
                local hum = GetHumanoid(); local root = GetRootPart()
                if hum and root and hum:GetState() == Enum.HumanoidStateType.Freefall then
                    root.Velocity = Vector3.new(root.Velocity.X * 1.02, root.Velocity.Y, root.Velocity.Z * 1.02)
                end
                RunService.RenderStepped:Wait()
            end
        end)
    else _G.Medusa.Loops.LongJump = false; ConsoleLog("Long Jump DISABLED", "MOVE") end
end

function MovementModule.HighJump(enabled)
    State.HighJump = enabled
    if enabled then
        _G.Medusa.Loops.HighJump = true; ConsoleLog("High Jump ENABLED", "MOVE")
        task.spawn(function()
            while _G.Medusa.Loops.HighJump and State.HighJump do
                local hum = GetHumanoid()
                if hum then hum.UseJumpPower = true; hum.JumpPower = Values.HighJumpPower end
                task.wait(0.1)
            end
        end)
    else
        _G.Medusa.Loops.HighJump = false
        local hum = GetHumanoid(); if hum then hum.JumpPower = Config.Defaults.JumpPower end
        ConsoleLog("High Jump DISABLED", "MOVE")
    end
end

function MovementModule.Spider(enabled)
    State.Spider = enabled
    if enabled then
        _G.Medusa.Loops.Spider = true; ConsoleLog("Spider ENABLED", "MOVE")
        task.spawn(function()
            while _G.Medusa.Loops.Spider and State.Spider do
                local root = GetRootPart()
                if root then
                    local ray = Ray.new(root.Position, root.CFrame.LookVector * 3)
                    local hit = Workspace:FindPartOnRay(ray, GetCharacter())
                    if hit then
                        local bv = root:FindFirstChild("MedusaSpider")
                        if not bv then
                            bv = Instance.new("BodyVelocity"); bv.Name = "MedusaSpider"
                            bv.MaxForce = Vector3.new(0, math.huge, 0); bv.Parent = root
                        end
                        bv.Velocity = Vector3.new(0, Values.WalkSpeed, 0)
                    else
                        local bv = root:FindFirstChild("MedusaSpider"); if bv then bv:Destroy() end
                    end
                end
                RunService.RenderStepped:Wait()
            end
            local root = GetRootPart()
            if root then local bv = root:FindFirstChild("MedusaSpider"); if bv then bv:Destroy() end end
        end)
    else _G.Medusa.Loops.Spider = false; ConsoleLog("Spider DISABLED", "MOVE") end
end

function MovementModule.Phase(enabled)
    State.Phase = enabled
    if enabled then
        _G.Medusa.Loops.Phase = true; ConsoleLog("Phase ENABLED", "MOVE")
        task.spawn(function()
            while _G.Medusa.Loops.Phase and State.Phase do
                local root = GetRootPart(); local hum = GetHumanoid()
                if root and hum and hum.MoveDirection.Magnitude > 0 then
                    root.CFrame = root.CFrame + hum.MoveDirection * 1.5
                end
                RunService.RenderStepped:Wait()
            end
        end)
    else _G.Medusa.Loops.Phase = false; ConsoleLog("Phase DISABLED", "MOVE") end
end

function MovementModule.TPtoMouse(enabled)
    State.TPtoMouse = enabled
    if enabled then
        ConsoleLog("TP to Mouse ENABLED", "MOVE")
        _G.Medusa.TPMouseConn = AddConnection(LocalPlayer:GetMouse().Button1Down:Connect(function()
            if State.TPtoMouse then
                local mouse = LocalPlayer:GetMouse(); local root = GetRootPart()
                if root and mouse.Hit then root.CFrame = mouse.Hit + Vector3.new(0, 5, 0) end
            end
        end))
    else
        if _G.Medusa.TPMouseConn then _G.Medusa.TPMouseConn:Disconnect(); _G.Medusa.TPMouseConn = nil end
        ConsoleLog("TP to Mouse DISABLED", "MOVE")
    end
end

function MovementModule.AutoWalk(enabled)
    State.AutoWalk = enabled
    if enabled then
        _G.Medusa.Loops.AutoWalk = true; ConsoleLog("Auto Walk ENABLED", "MOVE")
        task.spawn(function()
            while _G.Medusa.Loops.AutoWalk and State.AutoWalk do
                local hum = GetHumanoid(); local root = GetRootPart()
                if hum and root then hum:Move(root.CFrame.LookVector, false) end
                RunService.RenderStepped:Wait()
            end
        end)
    else _G.Medusa.Loops.AutoWalk = false; ConsoleLog("Auto Walk DISABLED", "MOVE") end
end

function MovementModule.BunnyHop(enabled)
    State.BunnyHop = enabled
    if enabled then
        _G.Medusa.Loops.BunnyHop = true; ConsoleLog("Bunny Hop ENABLED", "MOVE")
        task.spawn(function()
            while _G.Medusa.Loops.BunnyHop and State.BunnyHop do
                local hum = GetHumanoid()
                if hum and hum:GetState() ~= Enum.HumanoidStateType.Freefall then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
                task.wait(0.15)
            end
        end)
    else _G.Medusa.Loops.BunnyHop = false; ConsoleLog("Bunny Hop DISABLED", "MOVE") end
end

function MovementModule.Glide(enabled)
    State.Glide = enabled
    if enabled then
        _G.Medusa.Loops.Glide = true; ConsoleLog("Glide ENABLED", "MOVE")
        task.spawn(function()
            while _G.Medusa.Loops.Glide and State.Glide do
                local root = GetRootPart(); local hum = GetHumanoid()
                if root and hum and hum:GetState() == Enum.HumanoidStateType.Freefall then
                    root.Velocity = Vector3.new(root.Velocity.X, math.max(root.Velocity.Y, -5), root.Velocity.Z)
                end
                RunService.RenderStepped:Wait()
            end
        end)
    else _G.Medusa.Loops.Glide = false; ConsoleLog("Glide DISABLED", "MOVE") end
end

function MovementModule.Dash(enabled)
    State.Dash = enabled
    if enabled then
        ConsoleLog("Dash ENABLED (Press Q)", "MOVE")
        _G.Medusa.DashConn = AddConnection(UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.KeyCode == Enum.KeyCode.Q and State.Dash then
                local root = GetRootPart(); local hum = GetHumanoid()
                if root and hum then
                    local dashDir = hum.MoveDirection
                    if dashDir.Magnitude < 0.1 then dashDir = root.CFrame.LookVector end
                    root.Velocity = dashDir * Values.DashPower + Vector3.new(0, 20, 0)
                end
            end
        end))
    else
        if _G.Medusa.DashConn then _G.Medusa.DashConn:Disconnect(); _G.Medusa.DashConn = nil end
        ConsoleLog("Dash DISABLED", "MOVE")
    end
end

function MovementModule.Anchor(enabled)
    State.Anchor = enabled
    local root = GetRootPart(); if root then root.Anchored = enabled end
    ConsoleLog("Anchor " .. (enabled and "ENABLED" or "DISABLED"), "MOVE")
end

-- ╔════════════════════════════════════════════════════╗
-- ║     SECTION 10: WORLD MODULE (16 Functions)       ║
-- ╚════════════════════════════════════════════════════╝

local WorldModule = {}
local OriginalLighting = {
    Ambient = Lighting.Ambient, Brightness = Lighting.Brightness,
    OutdoorAmbient = Lighting.OutdoorAmbient, FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart, ClockTime = Lighting.ClockTime,
    GlobalShadows = Lighting.GlobalShadows,
}

function WorldModule.Fullbright(enabled)
    State.Fullbright = enabled
    if enabled then
        _G.Medusa.Loops.Fullbright = true; ConsoleLog("Fullbright ENABLED", "WORLD")
        task.spawn(function()
            while _G.Medusa.Loops.Fullbright and State.Fullbright do
                Lighting.Ambient = Color3.fromRGB(200, 200, 200); Lighting.Brightness = 2
                Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200); Lighting.FogEnd = 100000
                Lighting.GlobalShadows = false; task.wait(0.5)
            end
        end)
    else
        _G.Medusa.Loops.Fullbright = false
        Lighting.Ambient = OriginalLighting.Ambient; Lighting.Brightness = OriginalLighting.Brightness
        Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient; Lighting.FogEnd = OriginalLighting.FogEnd
        Lighting.GlobalShadows = OriginalLighting.GlobalShadows; ConsoleLog("Fullbright DISABLED", "WORLD")
    end
end

function WorldModule.AntiFog(enabled)
    State.AntiFog = enabled
    if enabled then
        _G.Medusa.Loops.AntiFog = true; ConsoleLog("Anti-Fog ENABLED", "WORLD")
        task.spawn(function()
            while _G.Medusa.Loops.AntiFog and State.AntiFog do
                Lighting.FogEnd = 100000; Lighting.FogStart = 100000
                for _, e in pairs(Lighting:GetDescendants()) do if e:IsA("Atmosphere") then e.Density = 0 end end
                task.wait(1)
            end
        end)
    else
        _G.Medusa.Loops.AntiFog = false
        Lighting.FogEnd = OriginalLighting.FogEnd; Lighting.FogStart = OriginalLighting.FogStart
        ConsoleLog("Anti-Fog DISABLED", "WORLD")
    end
end

function WorldModule.DayTime(enabled)
    State.DayTime = enabled
    if enabled then
        State.NightTime = false; _G.Medusa.Loops.DayTime = true; ConsoleLog("Day Time ENABLED", "WORLD")
        task.spawn(function() while _G.Medusa.Loops.DayTime and State.DayTime do Lighting.ClockTime = 14; task.wait(1) end end)
    else _G.Medusa.Loops.DayTime = false; Lighting.ClockTime = OriginalLighting.ClockTime; ConsoleLog("Day Time DISABLED", "WORLD") end
end

function WorldModule.NightTime(enabled)
    State.NightTime = enabled
    if enabled then
        State.DayTime = false; _G.Medusa.Loops.NightTime = true; ConsoleLog("Night Time ENABLED", "WORLD")
        task.spawn(function() while _G.Medusa.Loops.NightTime and State.NightTime do Lighting.ClockTime = 0; task.wait(1) end end)
    else _G.Medusa.Loops.NightTime = false; Lighting.ClockTime = OriginalLighting.ClockTime; ConsoleLog("Night Time DISABLED", "WORLD") end
end

function WorldModule.NoWeather(enabled) State.NoWeather = enabled; ConsoleLog("No Weather " .. (enabled and "ENABLED" or "DISABLED"), "WORLD")
    if enabled then
        for _, e in pairs(Lighting:GetDescendants()) do if e:IsA("Atmosphere") or e:IsA("Clouds") or e:IsA("Sky") then e.Parent = nil end end
        pcall(function() for _, c in pairs(Workspace:FindFirstChildOfClass("Terrain"):GetChildren()) do if c:IsA("Clouds") then c.Parent = nil end end end)
    end
end

function WorldModule.RemoveEffects(enabled) State.RemoveEffects = enabled; ConsoleLog("Remove Effects " .. (enabled and "ENABLED" or "DISABLED"), "WORLD")
    if enabled then
        for _, e in pairs(Lighting:GetChildren()) do
            if e:IsA("PostEffect") or e:IsA("BlurEffect") or e:IsA("BloomEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("DepthOfFieldEffect") then e.Enabled = false end
        end
        for _, e in pairs(Camera:GetChildren()) do
            if e:IsA("PostEffect") or e:IsA("BlurEffect") or e:IsA("BloomEffect") or e:IsA("ColorCorrectionEffect") then e.Enabled = false end
        end
    else
        for _, e in pairs(Lighting:GetChildren()) do
            if e:IsA("PostEffect") or e:IsA("BlurEffect") or e:IsA("BloomEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("DepthOfFieldEffect") then e.Enabled = true end
        end
    end
end

function WorldModule.AntiLag(enabled) State.AntiLag = enabled; ConsoleLog("Anti-Lag " .. (enabled and "ENABLED" or "DISABLED"), "WORLD")
    if enabled then
        local count = 0
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") or obj:IsA("Explosion") then
                obj.Enabled = false; count = count + 1
            elseif obj:IsA("Decal") or obj:IsA("Texture") then obj.Transparency = 1; count = count + 1
            elseif obj:IsA("MeshPart") or obj:IsA("UnionOperation") then obj.RenderFidelity = Enum.RenderFidelity.Performance end
        end
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    else settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic end
end

function WorldModule.NoInvisWalls(enabled) State.NoInvisWalls = enabled; ConsoleLog("No Invisible Walls " .. (enabled and "ENABLED" or "DISABLED"), "WORLD")
    if enabled then for _, p in pairs(Workspace:GetDescendants()) do if p:IsA("BasePart") and p.Transparency >= 0.9 then p.CanCollide = false end end end
end

function WorldModule.XRay(enabled) State.XRay = enabled; ConsoleLog("X-Ray " .. (enabled and "ENABLED" or "DISABLED"), "WORLD")
    if enabled then
        _G.Medusa.XRayParts = {}
        for _, p in pairs(Workspace:GetDescendants()) do
            if p:IsA("BasePart") and not p:IsDescendantOf(GetCharacter() or Instance.new("Folder")) and p.Transparency < 0.5 then
                table.insert(_G.Medusa.XRayParts, {Part = p, Orig = p.Transparency})
                p.Transparency = 0.7; p.Material = Enum.Material.ForceField
            end
        end
    else
        if _G.Medusa.XRayParts then
            for _, d in pairs(_G.Medusa.XRayParts) do if d.Part and d.Part.Parent then d.Part.Transparency = d.Orig; d.Part.Material = Enum.Material.SmoothPlastic end end
            _G.Medusa.XRayParts = {}
        end
    end
end

function WorldModule.SmallChars(enabled) State.SmallChars = enabled; ConsoleLog("Small Chars " .. (enabled and "ENABLED" or "DISABLED"), "WORLD")
    if enabled then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local h = p.Character:FindFirstChildOfClass("Humanoid")
                if h then pcall(function() h.BodyDepthScale.Value=0.5; h.BodyHeightScale.Value=0.5; h.BodyWidthScale.Value=0.5; h.HeadScale.Value=0.5 end) end
            end
        end
    end
end

function WorldModule.CustomGravity(enabled) State.CustomGravity = enabled
    if enabled then Workspace.Gravity = Values.Gravity; ConsoleLog("Custom Gravity ("..Values.Gravity..")", "WORLD")
    else Workspace.Gravity = 196.2; ConsoleLog("Gravity reset", "WORLD") end
end

function WorldModule.TPtoRandom()
    local valid = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then table.insert(valid, p) end
    end
    if #valid > 0 then
        local t = valid[math.random(#valid)]; local root = GetRootPart()
        if root then root.CFrame = t.Character.HumanoidRootPart.CFrame + Vector3.new(5,0,0); ConsoleLog("TP to "..t.Name, "WORLD") end
    end
end

function WorldModule.TPtoSpawn()
    local root = GetRootPart()
    if root then
        local sp = Workspace:FindFirstChildOfClass("SpawnLocation")
        root.CFrame = sp and (sp.CFrame + Vector3.new(0,5,0)) or CFrame.new(0,50,0)
        ConsoleLog("TP to spawn", "WORLD")
    end
end

function WorldModule.MapCleaner()
    local c = 0
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") or obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
            obj:Destroy(); c = c + 1
        end
    end
    ConsoleLog("Map Cleaner: "..c.." removed", "WORLD")
end

function WorldModule.NoClipParts(enabled) State.NoClipParts = enabled; ConsoleLog("NoClip Parts " .. (enabled and "ENABLED" or "DISABLED"), "WORLD")
    if enabled then for _, p in pairs(Workspace:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end
end

function WorldModule.Destroy3D()
    local c = 0
    for _, obj in pairs(Workspace:GetDescendants()) do
        if (obj:IsA("MeshPart") and obj.Transparency > 0.5) or obj:IsA("SpecialMesh") then obj:Destroy(); c = c + 1 end
    end
    ConsoleLog("Destroy 3D: "..c.." removed", "WORLD"); State.Destroy3D = true
end

-- ╔════════════════════════════════════════════════════╗
-- ║    SECTION 11: UTILITY MODULE (16 Functions)      ║
-- ╚════════════════════════════════════════════════════╝

local UtilityModule = {}

function UtilityModule.AntiAFK(enabled) State.AntiAFK = enabled
    if enabled then ConsoleLog("Anti-AFK ENABLED", "UTIL"); local VU = game:GetService("VirtualUser")
        _G.Medusa.AntiAFKConn = AddConnection(LocalPlayer.Idled:Connect(function()
            if State.AntiAFK then VU:CaptureController(); VU:ClickButton2(Vector2.new(0,0)); ConsoleLog("Anti-AFK triggered", "UTIL") end
        end))
    else if _G.Medusa.AntiAFKConn then _G.Medusa.AntiAFKConn:Disconnect(); _G.Medusa.AntiAFKConn = nil end; ConsoleLog("Anti-AFK DISABLED", "UTIL") end
end

function UtilityModule.ServerHop() ConsoleLog("Server Hopping...", "UTIL")
    pcall(function()
        local servers = game.HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
        for _, s in pairs(servers.data) do
            if s.id ~= game.JobId and s.playing < s.maxPlayers then game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, s.id); return end
        end
    end)
end

function UtilityModule.Rejoin() ConsoleLog("Rejoining...", "UTIL"); pcall(function() game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer) end) end

function UtilityModule.FPSUnlock(enabled) State.FPSUnlock = enabled
    if enabled then pcall(function() setfpscap(999) end); ConsoleLog("FPS Unlock ENABLED", "UTIL")
    else pcall(function() setfpscap(60) end); ConsoleLog("FPS Unlock DISABLED", "UTIL") end
end

function UtilityModule.ChatSpam(enabled) State.ChatSpam = enabled
    if enabled then
        _G.Medusa.Loops.ChatSpam = true; ConsoleLog("Chat Spam ENABLED", "UTIL")
        task.spawn(function()
            while _G.Medusa.Loops.ChatSpam and State.ChatSpam do
                pcall(function()
                    local cr = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
                    if cr then local sm = cr:FindFirstChild("SayMessageRequest"); if sm then sm:FireServer(Values.ChatSpamMsg, "All") end
                    else StarterGui:SetCore("ChatMakeSystemMessage", {Text = Values.ChatSpamMsg, Color = Config.Theme.Primary}) end
                end)
                task.wait(Values.ChatSpamDelay)
            end
        end)
    else _G.Medusa.Loops.ChatSpam = false; ConsoleLog("Chat Spam DISABLED", "UTIL") end
end

function UtilityModule.AntiKick(enabled) State.AntiKick = enabled
    if enabled then ConsoleLog("Anti-Kick ENABLED", "UTIL")
        pcall(function()
            local oldNc; oldNc = hookmetamethod(game, "__namecall", function(self, ...)
                if getnamecallmethod() == "Kick" and self == LocalPlayer then ConsoleLog("Kick blocked!", "UTIL"); return end
                return oldNc(self, ...)
            end)
        end)
    else ConsoleLog("Anti-Kick DISABLED", "UTIL") end
end

function UtilityModule.GodMode(enabled) State.GodMode = enabled
    if enabled then ConsoleLog("God Mode ENABLED", "UTIL")
        pcall(function() local h = GetHumanoid(); if h then h:Remove(); task.wait(0.1); Instance.new("Humanoid").Parent = GetCharacter() end end)
    else ConsoleLog("God Mode DISABLED", "UTIL") end
end

function UtilityModule.CopyGameID() pcall(function() setclipboard(tostring(game.PlaceId)); ConsoleLog("Game ID: "..game.PlaceId, "UTIL") end) end
function UtilityModule.CopyServerID() pcall(function() setclipboard(tostring(game.JobId)); ConsoleLog("Server ID copied", "UTIL") end) end
function UtilityModule.ResetChar() local h = GetHumanoid(); if h then h.Health = 0; ConsoleLog("Character Reset", "UTIL") end end

function UtilityModule.HideName(enabled) State.HideName = enabled
    if enabled then
        local char = GetCharacter(); if char then
            local head = char:FindFirstChild("Head")
            if head then for _, o in pairs(head:GetChildren()) do if o:IsA("BillboardGui") then o.Enabled = false end end end
            local hum = GetHumanoid(); if hum then hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None end
        end; ConsoleLog("Hide Name ENABLED", "UTIL")
    else local hum = GetHumanoid(); if hum then hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer end; ConsoleLog("Hide Name DISABLED", "UTIL") end
end

function UtilityModule.Sit(enabled) State.Sit = enabled; local hum = GetHumanoid(); if hum then hum.Sit = enabled end; ConsoleLog("Sit " .. (enabled and "ON" or "OFF"), "UTIL") end

function UtilityModule.AntiVoid(enabled) State.AntiVoid = enabled
    if enabled then _G.Medusa.Loops.AntiVoid = true; ConsoleLog("Anti-Void ENABLED", "UTIL")
        task.spawn(function()
            while _G.Medusa.Loops.AntiVoid and State.AntiVoid do
                local root = GetRootPart()
                if root and root.Position.Y < -200 then root.CFrame = CFrame.new(0,100,0); ConsoleLog("Rescued from void", "UTIL") end
                task.wait(0.5)
            end
        end)
    else _G.Medusa.Loops.AntiVoid = false; ConsoleLog("Anti-Void DISABLED", "UTIL") end
end

function UtilityModule.AutoRespawn(enabled) State.AutoRespawn = enabled
    if enabled then ConsoleLog("Auto Respawn ENABLED", "UTIL")
        _G.Medusa.AutoRespawnConn = AddConnection(GetHumanoid().Died:Connect(function()
            if State.AutoRespawn then task.wait(game.Players.RespawnTime or 5); pcall(function() LocalPlayer:LoadCharacter() end) end
        end))
    else if _G.Medusa.AutoRespawnConn then _G.Medusa.AutoRespawnConn:Disconnect(); _G.Medusa.AutoRespawnConn = nil end; ConsoleLog("Auto Respawn DISABLED", "UTIL") end
end

function UtilityModule.InfStamina(enabled) State.InfStamina = enabled
    if enabled then _G.Medusa.Loops.InfStamina = true; ConsoleLog("Inf Stamina ENABLED", "UTIL")
        task.spawn(function()
            while _G.Medusa.Loops.InfStamina and State.InfStamina do
                for _, gui in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
                    if gui:IsA("Frame") and (string.find(string.lower(gui.Name), "stamina") or string.find(string.lower(gui.Name), "energy")) then
                        pcall(function() for _, bar in pairs(gui:GetDescendants()) do if bar:IsA("Frame") then bar.Size = UDim2.new(1,0,bar.Size.Y.Scale,bar.Size.Y.Offset) end end end)
                    end
                end
                task.wait(0.1)
            end
        end)
    else _G.Medusa.Loops.InfStamina = false; ConsoleLog("Inf Stamina DISABLED", "UTIL") end
end

function UtilityModule.NoRagdoll(enabled) State.NoRagdoll = enabled
    if enabled then _G.Medusa.Loops.NoRagdoll = true; ConsoleLog("No Ragdoll ENABLED", "UTIL")
        task.spawn(function()
            while _G.Medusa.Loops.NoRagdoll and State.NoRagdoll do
                local hum = GetHumanoid()
                if hum then
                    hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                    if hum:GetState() == Enum.HumanoidStateType.Ragdoll or hum:GetState() == Enum.HumanoidStateType.FallingDown then
                        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                    end
                end
                task.wait(0.1)
            end
        end)
    else _G.Medusa.Loops.NoRagdoll = false
        local hum = GetHumanoid(); if hum then hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true); hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true) end
        ConsoleLog("No Ragdoll DISABLED", "UTIL")
    end
end

-- ╔══════════════════════════════════════════════════════╗
-- ║  SECTION 12: CINEMATIC INTRO (Cobra Edition)        ║
-- ╚══════════════════════════════════════════════════════╝

local function PlayCinematicIntro(callback)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MedusaIntro"; screenGui.IgnoreGuiInset = true
    screenGui.DisplayOrder = 1000000; screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.ResetOnSpawn = false
    screenGui.Parent = (syn and syn.protect_gui and CoreGui) or LocalPlayer.PlayerGui

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0); bg.BackgroundColor3 = Config.Theme.Black
    bg.BorderSizePixel = 0; bg.ZIndex = 1; bg.Parent = screenGui

    -- Matrix rain
    task.spawn(function()
        for i = 1, 40 do
            local p = Instance.new("TextLabel")
            p.Size = UDim2.new(0, 20, 0, 20); p.Position = UDim2.new(math.random(0, 100)/100, 0, -0.05, 0)
            p.BackgroundTransparency = 1; p.Text = math.random(0,1) == 0 and "0" or "1"
            p.TextColor3 = Config.Theme.Primary; p.TextTransparency = math.random(40,80)/100
            p.Font = Enum.Font.Code; p.TextSize = math.random(10,18); p.ZIndex = 3; p.Parent = bg
            SafeTween(p, TweenInfo.new(math.random(30,80)/10, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, false, math.random(0,30)/10),
                {Position = UDim2.new(p.Position.X.Scale, 0, 1.1, 0)})
        end
    end)

    -- Vignette
    local vignette = Instance.new("ImageLabel")
    vignette.Size = UDim2.new(1, 0, 1, 0); vignette.BackgroundTransparency = 1
    vignette.Image = "rbxassetid://1049630956"; vignette.ImageColor3 = Config.Theme.Primary
    vignette.ImageTransparency = 0.85; vignette.ZIndex = 4; vignette.ScaleType = Enum.ScaleType.Stretch; vignette.Parent = bg
    SafeTween(vignette, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {ImageTransparency = 0.6})

    local center = Instance.new("Frame")
    center.Size = UDim2.new(0, 400, 0, 350); center.Position = UDim2.new(0.5, -200, 0.5, -175)
    center.BackgroundTransparency = 1; center.ZIndex = 10; center.Parent = bg

    -- COBRA GLOW
    local cobraGlow = Instance.new("TextLabel")
    cobraGlow.Size = UDim2.new(0, 0, 0, 0); cobraGlow.Position = UDim2.new(0.5, 0, 0.2, 0)
    cobraGlow.AnchorPoint = Vector2.new(0.5, 0.5); cobraGlow.BackgroundTransparency = 1
    cobraGlow.Text = "🐍"; cobraGlow.TextScaled = true; cobraGlow.Font = Enum.Font.GothamBold
    cobraGlow.TextColor3 = Config.Theme.Primary; cobraGlow.TextTransparency = 0.5
    cobraGlow.ZIndex = 11; cobraGlow.Parent = center

    -- COBRA MAIN
    local cobra = Instance.new("TextLabel")
    cobra.Size = UDim2.new(0, 0, 0, 0); cobra.Position = UDim2.new(0.5, 0, 0.2, 0)
    cobra.AnchorPoint = Vector2.new(0.5, 0.5); cobra.BackgroundTransparency = 1
    cobra.Text = "🐍"; cobra.TextScaled = true; cobra.Font = Enum.Font.GothamBold
    cobra.TextColor3 = Config.Theme.White; cobra.ZIndex = 12; cobra.Parent = center

    local cobraStroke = Instance.new("UIStroke")
    cobraStroke.Color = Config.Theme.Primary; cobraStroke.Thickness = 2; cobraStroke.Transparency = 0.3; cobraStroke.Parent = cobra

    SafeTween(cobra, TweenInfo.new(1.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 150, 0, 150)})
    SafeTween(cobraGlow, TweenInfo.new(1.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 185, 0, 185)})

    task.spawn(function()
        while cobraGlow and cobraGlow.Parent do
            SafeTween(cobraGlow, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextTransparency = 0.8}); task.wait(1.2)
            if not cobraGlow or not cobraGlow.Parent then break end
            SafeTween(cobraGlow, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextTransparency = 0.2}); task.wait(1.2)
        end
    end)

    task.spawn(function()
        while cobraStroke and cobraStroke.Parent do
            SafeTween(cobraStroke, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Thickness = 5, Transparency = 0.7}); task.wait(1)
            if not cobraStroke or not cobraStroke.Parent then break end
            SafeTween(cobraStroke, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Thickness = 2, Transparency = 0.1}); task.wait(1)
        end
    end)

    task.wait(2)

    -- GLITCH TEXT
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50); title.Position = UDim2.new(0, 0, 0.45, 0)
    title.BackgroundTransparency = 1; title.Text = ""; title.TextColor3 = Config.Theme.Primary
    title.Font = Enum.Font.GothamBlack; title.TextSize = 42; title.ZIndex = 13; title.Parent = center

    local titleStroke = Instance.new("UIStroke")
    titleStroke.Color = Config.Theme.Primary; titleStroke.Thickness = 2; titleStroke.Transparency = 0.3; titleStroke.Parent = title
    task.spawn(function()
        while titleStroke and titleStroke.Parent do
            SafeTween(titleStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 1}); task.wait(1.5)
            if not titleStroke or not titleStroke.Parent then break end
            SafeTween(titleStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0.2}); task.wait(1.5)
        end
    end)

    local glitchChars = "!@#$%^&*01<>{}|/\\~`"
    local targetText = "M E D U S A"
    for pass = 1, 15 do
        local result = ""
        for i = 1, #targetText do
            local c = targetText:sub(i, i)
            if c == " " then result = result .. " "
            elseif pass > 10 or math.random(1, 15 - pass) == 1 then result = result .. c
            else result = result .. glitchChars:sub(math.random(1, #glitchChars), math.random(1, #glitchChars)) end
        end
        title.Text = result; task.wait(0.08)
    end
    title.Text = targetText; task.wait(0.5)

    local version = Instance.new("TextLabel")
    version.Size = UDim2.new(1, 0, 0, 20); version.Position = UDim2.new(0, 0, 0.55, 0)
    version.BackgroundTransparency = 1; version.Text = "C O B R A   E D I T I O N  ·  v" .. Config.Version
    version.TextColor3 = Config.Theme.PrimaryDark; version.Font = Enum.Font.Gotham
    version.TextSize = 14; version.TextTransparency = 1; version.ZIndex = 13; version.Parent = center
    SafeTween(version, TweenInfo.new(0.8), {TextTransparency = 0}); task.wait(0.5)

    -- LOADING BAR
    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(0.7, 0, 0, 4); barBg.Position = UDim2.new(0.15, 0, 0.68, 0)
    barBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30); barBg.BorderSizePixel = 0; barBg.ZIndex = 13; barBg.Parent = center
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(0, 2)

    local barFill = Instance.new("Frame")
    barFill.Size = UDim2.new(0, 0, 1, 0); barFill.BackgroundColor3 = Config.Theme.Primary
    barFill.BorderSizePixel = 0; barFill.ZIndex = 14; barFill.Parent = barBg
    Instance.new("UICorner", barFill).CornerRadius = UDim.new(0, 2)

    local barGrad = Instance.new("UIGradient")
    barGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Config.Theme.PrimaryDark),
        ColorSequenceKeypoint.new(0.5, Config.Theme.White),
        ColorSequenceKeypoint.new(1, Config.Theme.PrimaryDark),
    }); barGrad.Parent = barFill
    task.spawn(function()
        while barGrad and barGrad.Parent do
            SafeTween(barGrad, TweenInfo.new(1, Enum.EasingStyle.Linear), {Offset = Vector2.new(1, 0)}); task.wait(1)
            if barGrad and barGrad.Parent then barGrad.Offset = Vector2.new(-1, 0) end
        end
    end)

    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.new(1, 0, 0, 16); statusText.Position = UDim2.new(0, 0, 0.73, 0)
    statusText.BackgroundTransparency = 1; statusText.Text = ""; statusText.TextColor3 = Config.Theme.TextDim
    statusText.Font = Enum.Font.Code; statusText.TextSize = 11; statusText.ZIndex = 13; statusText.Parent = center

    local steps = {
        {0.05, "Initializing Medusa Engine..."},
        {0.10, "Metatable Bypass: Active"},
        {0.18, "Loading Combat v2 (16 functions)..."},
        {0.30, "Loading Vision ESP (16 functions)..."},
        {0.42, "Loading Movement Module (16 functions)..."},
        {0.54, "Loading World + Utility (32 functions)..."},
        {0.66, "Loading HUD + Visuals (16 functions)..."},
        {0.75, "Compiling 96 functions..."},
        {0.82, "Building 2-Column UI..."},
        {0.90, "Binding keybinds (M/F/N/Q)..."},
        {0.95, "Initializing search system..."},
        {1.00, "🐍 Medusa is ready."},
    }
    for _, step in ipairs(steps) do
        statusText.Text = step[2]
        SafeTween(barFill, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = UDim2.new(step[1], 0, 1, 0)})
        task.wait(0.25)
    end
    task.wait(0.8)

    SafeTween(bg, TweenInfo.new(1, Enum.EasingStyle.Quad), {BackgroundTransparency = 1})
    for _, child in pairs(bg:GetDescendants()) do
        pcall(function()
            if child:IsA("TextLabel") then SafeTween(child, TweenInfo.new(0.8), {TextTransparency = 1})
            elseif child:IsA("ImageLabel") then SafeTween(child, TweenInfo.new(0.8), {ImageTransparency = 1})
            elseif child:IsA("Frame") then SafeTween(child, TweenInfo.new(0.8), {BackgroundTransparency = 1}) end
        end)
    end
    task.wait(1.2); screenGui:Destroy()
    if callback then callback() end
end

-- ╔══════════════════════════════════════════════════════════════╗
-- ║  SECTION 13: MAIN UI BUILDER (5 Tabs, 2 Columns, Search)   ║
-- ╚══════════════════════════════════════════════════════════════╝

local function BuildMainUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "MedusaEngine"; gui.IgnoreGuiInset = true; gui.DisplayOrder = 999999
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; gui.ResetOnSpawn = false
    gui.Parent = (syn and syn.protect_gui and CoreGui) or LocalPlayer.PlayerGui
    _G.Medusa.ScreenGui = gui

    -- ══════ TOAST SYSTEM (Fixed v1.0.5 — Glassmorphism, no huge square) ══════
    local toastContainer = Instance.new("Frame")
    toastContainer.Name = "ToastContainer"
    toastContainer.Size = UDim2.new(0, 0, 0, 0)
    toastContainer.Position = UDim2.new(1, -255, 1, -15)
    toastContainer.AnchorPoint = Vector2.new(0, 1)
    toastContainer.AutomaticSize = Enum.AutomaticSize.XY
    toastContainer.BackgroundTransparency = 1
    toastContainer.ClipsDescendants = false
    toastContainer.Active = false
    toastContainer.Selectable = false
    toastContainer.ZIndex = 100
    toastContainer.Parent = gui
    local toastLayout = Instance.new("UIListLayout")
    toastLayout.SortOrder = Enum.SortOrder.LayoutOrder
    toastLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    toastLayout.Padding = UDim.new(0, 6)
    toastLayout.Parent = toastContainer

    local toastOrder = 0
    local function ShowToast(msg)
        if not State.Notifications then return end
        PlayClickSound()
        toastOrder = toastOrder + 1

        -- Outer wrapper (compact, passthrough when invisible)
        local toast = Instance.new("Frame")
        toast.Name = "Toast_" .. toastOrder
        toast.Size = UDim2.new(0, 220, 0, 0)
        toast.AutomaticSize = Enum.AutomaticSize.Y
        toast.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
        toast.BackgroundTransparency = 1
        toast.BorderSizePixel = 0
        toast.LayoutOrder = toastOrder
        toast.ZIndex = 101
        toast.ClipsDescendants = true
        toast.Active = false
        toast.Selectable = false
        toast.Parent = toastContainer
        Instance.new("UICorner", toast).CornerRadius = UDim.new(0, 8)

        local ts = Instance.new("UIStroke")
        ts.Color = Config.Theme.PrimaryDark
        ts.Thickness = 1
        ts.Transparency = 1
        ts.Parent = toast

        -- Inner padding
        local tPad = Instance.new("UIPadding")
        tPad.PaddingTop = UDim.new(0, 6)
        tPad.PaddingBottom = UDim.new(0, 8)
        tPad.PaddingLeft = UDim.new(0, 8)
        tPad.PaddingRight = UDim.new(0, 8)
        tPad.Parent = toast

        -- Glassmorphism top glow line
        local tGlow = Instance.new("Frame")
        tGlow.Size = UDim2.new(1, 16, 0, 1)
        tGlow.Position = UDim2.new(0, -8, 0, -6)
        tGlow.BackgroundColor3 = Config.Theme.Primary
        tGlow.BackgroundTransparency = 0.4
        tGlow.BorderSizePixel = 0
        tGlow.ZIndex = 103
        tGlow.Parent = toast
        local tGlowG = Instance.new("UIGradient")
        tGlowG.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)),
            ColorSequenceKeypoint.new(0.3, Config.Theme.Primary),
            ColorSequenceKeypoint.new(0.7, Config.Theme.Primary),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0,0)),
        })
        tGlowG.Parent = tGlow

        -- Content row
        local tRow = Instance.new("Frame")
        tRow.Size = UDim2.new(1, 0, 0, 20)
        tRow.BackgroundTransparency = 1
        tRow.ZIndex = 103
        tRow.Parent = toast

        -- Icon
        local tIcon = Instance.new("TextLabel")
        tIcon.Size = UDim2.new(0, 18, 0, 18)
        tIcon.Position = UDim2.new(0, 0, 0, 1)
        tIcon.BackgroundTransparency = 1
        tIcon.Text = "🐍"
        tIcon.TextScaled = true
        tIcon.ZIndex = 104
        tIcon.Parent = tRow

        -- Text
        local tL = Instance.new("TextLabel")
        tL.Size = UDim2.new(1, -24, 1, 0)
        tL.Position = UDim2.new(0, 22, 0, 0)
        tL.BackgroundTransparency = 1
        tL.Text = msg
        tL.TextColor3 = Config.Theme.Text
        tL.Font = Enum.Font.Gotham
        tL.TextSize = 11
        tL.TextXAlignment = Enum.TextXAlignment.Left
        tL.TextWrapped = true
        tL.AutomaticSize = Enum.AutomaticSize.Y
        tL.TextTruncate = Enum.TextTruncate.AtEnd
        tL.ZIndex = 104
        tL.Parent = tRow

        -- Progress bar at bottom
        local tBar = Instance.new("Frame")
        tBar.Size = UDim2.new(1, 0, 0, 2)
        tBar.Position = UDim2.new(0, 0, 0, 24)
        tBar.BackgroundColor3 = Config.Theme.Primary
        tBar.BorderSizePixel = 0
        tBar.ZIndex = 104
        tBar.Parent = toast
        Instance.new("UICorner", tBar).CornerRadius = UDim.new(0, 1)
        local tBarG = Instance.new("UIGradient")
        tBarG.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Config.Theme.PrimaryDark),
            ColorSequenceKeypoint.new(0.5, Config.Theme.Accent),
            ColorSequenceKeypoint.new(1, Config.Theme.PrimaryDark),
        })
        tBarG.Parent = tBar

        -- Animate in: slide from right + fade (glassmorphism = 50% transparent)
        toast.Position = UDim2.new(0.3, 0, 0, 0)
        SafeTween(toast, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {BackgroundTransparency = 0.5, Position = UDim2.new(0, 0, 0, 0)})
        SafeTween(ts, TweenInfo.new(0.3), {Transparency = 0.3})

        -- Progress bar shrinks over 3.5s
        SafeTween(tBar, TweenInfo.new(3.5, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 2)})

        -- Auto dismiss after 4s
        task.delay(4, function()
            if not toast or not toast.Parent then return end
            SafeTween(toast, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                {BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0, 0)})
            pcall(function()
                SafeTween(tL, TweenInfo.new(0.3), {TextTransparency = 1})
                SafeTween(tIcon, TweenInfo.new(0.3), {TextTransparency = 1})
                SafeTween(tBar, TweenInfo.new(0.3), {BackgroundTransparency = 1})
                SafeTween(tGlow, TweenInfo.new(0.3), {BackgroundTransparency = 1})
                SafeTween(ts, TweenInfo.new(0.3), {Transparency = 1})
            end)
            task.wait(0.5)
            if toast and toast.Parent then toast:Destroy() end
        end)
    end

    -- ══════ MAIN FRAME ══════
    local mainFrame = Instance.new("Frame"); mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 580, 0, 680); mainFrame.Position = UDim2.new(0.5, -290, 1.2, 0)
    mainFrame.BackgroundColor3 = Config.Theme.Background; mainFrame.BorderSizePixel = 0; mainFrame.ZIndex = 10; mainFrame.Parent = gui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
    local mainStroke = Instance.new("UIStroke"); mainStroke.Color = Config.Theme.PrimaryDark; mainStroke.Thickness = 1.5; mainStroke.Transparency = 0.3; mainStroke.Parent = mainFrame

    -- ══════ HEADER ══════
    local header = Instance.new("Frame"); header.Size = UDim2.new(1, 0, 0, 48)
    header.BackgroundColor3 = Config.Theme.Surface; header.BorderSizePixel = 0; header.ZIndex = 11; header.Parent = mainFrame
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 10)
    local hFix = Instance.new("Frame"); hFix.Size = UDim2.new(1, 0, 0, 10); hFix.Position = UDim2.new(0, 0, 1, -10)
    hFix.BackgroundColor3 = Config.Theme.Surface; hFix.BorderSizePixel = 0; hFix.ZIndex = 11; hFix.Parent = header
    local hGrad = Instance.new("UIGradient"); hGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 25, 20)), ColorSequenceKeypoint.new(1, Config.Theme.Surface),
    }); hGrad.Rotation = 90; hGrad.Parent = header

    local hCobra = Instance.new("TextLabel"); hCobra.Size = UDim2.new(0, 32, 0, 32); hCobra.Position = UDim2.new(0, 12, 0.5, -16)
    hCobra.BackgroundTransparency = 1; hCobra.Text = "🐍"; hCobra.TextScaled = true; hCobra.ZIndex = 12; hCobra.Parent = header

    local hTitle = Instance.new("TextLabel"); hTitle.Size = UDim2.new(0, 200, 0, 20); hTitle.Position = UDim2.new(0, 50, 0, 6)
    hTitle.BackgroundTransparency = 1; hTitle.Text = "MEDUSA ENGINE"; hTitle.TextColor3 = Config.Theme.Primary
    hTitle.Font = Enum.Font.GothamBlack; hTitle.TextSize = 16; hTitle.TextXAlignment = Enum.TextXAlignment.Left; hTitle.ZIndex = 12; hTitle.Parent = header

    local hSub = Instance.new("TextLabel"); hSub.Size = UDim2.new(0, 280, 0, 14); hSub.Position = UDim2.new(0, 50, 0, 26)
    hSub.BackgroundTransparency = 1; hSub.Text = "Cobra Edition · v" .. Config.Version .. " · 96 Fn · Predator HUD · Glass FX"
    hSub.TextColor3 = Config.Theme.TextDim; hSub.Font = Enum.Font.Gotham; hSub.TextSize = 11
    hSub.TextXAlignment = Enum.TextXAlignment.Left; hSub.ZIndex = 12; hSub.Parent = header

    local sDot = Instance.new("Frame"); sDot.Size = UDim2.new(0, 8, 0, 8); sDot.Position = UDim2.new(1, -65, 0.5, -4)
    sDot.BackgroundColor3 = Config.Theme.Primary; sDot.ZIndex = 12; sDot.Parent = header
    Instance.new("UICorner", sDot).CornerRadius = UDim.new(1, 0)
    SafeTween(sDot, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {BackgroundTransparency = 0.6})

    local sLbl = Instance.new("TextLabel"); sLbl.Size = UDim2.new(0, 35, 0, 14); sLbl.Position = UDim2.new(1, -52, 0.5, -7)
    sLbl.BackgroundTransparency = 1; sLbl.Text = "LIVE"; sLbl.TextColor3 = Config.Theme.Primary
    sLbl.Font = Enum.Font.GothamBold; sLbl.TextSize = 10; sLbl.ZIndex = 12; sLbl.Parent = header

    local closeBtn = Instance.new("TextButton"); closeBtn.Size = UDim2.new(0, 30, 0, 30); closeBtn.Position = UDim2.new(1, -38, 0.5, -15)
    closeBtn.BackgroundTransparency = 1; closeBtn.Text = "X"; closeBtn.TextColor3 = Config.Theme.TextDim
    closeBtn.Font = Enum.Font.GothamBold; closeBtn.TextSize = 16; closeBtn.ZIndex = 12; closeBtn.Parent = header
    closeBtn.MouseButton1Click:Connect(function()
        _G.Medusa.UIVisible = false
        SafeTween(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(0.5, -290, 1.2, 0)})
        ShowToast("UI Hidden [M]")
    end)

    -- Neon line
    local nL = Instance.new("Frame"); nL.Size = UDim2.new(1, -20, 0, 2); nL.Position = UDim2.new(0, 10, 0, 48)
    nL.BackgroundColor3 = Config.Theme.Primary; nL.BorderSizePixel = 0; nL.ZIndex = 12; nL.Parent = mainFrame
    local nG = Instance.new("UIGradient"); nG.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)), ColorSequenceKeypoint.new(0.2, Config.Theme.Primary),
        ColorSequenceKeypoint.new(0.5, Config.Theme.White), ColorSequenceKeypoint.new(0.8, Config.Theme.Primary),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0,0)),
    }); nG.Parent = nL

    -- Drag: Arrastar pelo Header (PC + Mobile)
    MakeDraggable(mainFrame, header)

    -- ══════ SEARCH BAR ══════
    local searchFrame = Instance.new("Frame"); searchFrame.Size = UDim2.new(1, -20, 0, 28)
    searchFrame.Position = UDim2.new(0, 10, 0, 54); searchFrame.BackgroundColor3 = Config.Theme.Card
    searchFrame.BorderSizePixel = 0; searchFrame.ZIndex = 12; searchFrame.Parent = mainFrame
    Instance.new("UICorner", searchFrame).CornerRadius = UDim.new(0, 6)
    local searchStroke = Instance.new("UIStroke"); searchStroke.Color = Color3.fromRGB(35,35,35); searchStroke.Thickness = 1; searchStroke.Parent = searchFrame

    local searchIcon = Instance.new("TextLabel"); searchIcon.Size = UDim2.new(0, 24, 0, 28)
    searchIcon.Position = UDim2.new(0, 8, 0, 0); searchIcon.BackgroundTransparency = 1
    searchIcon.Text = "🔍"; searchIcon.TextSize = 12; searchIcon.ZIndex = 13; searchIcon.Parent = searchFrame

    local searchBox = Instance.new("TextBox"); searchBox.Size = UDim2.new(1, -40, 1, 0)
    searchBox.Position = UDim2.new(0, 32, 0, 0); searchBox.BackgroundTransparency = 1
    searchBox.Text = ""; searchBox.PlaceholderText = "Search 96 functions..."
    searchBox.PlaceholderColor3 = Config.Theme.TextDim; searchBox.TextColor3 = Config.Theme.Text
    searchBox.Font = Enum.Font.Gotham; searchBox.TextSize = 12; searchBox.TextXAlignment = Enum.TextXAlignment.Left
    searchBox.ClearTextOnFocus = false; searchBox.ZIndex = 13; searchBox.Parent = searchFrame

    searchBox.Focused:Connect(function() SafeTween(searchStroke, TweenInfo.new(0.2), {Color = Config.Theme.Primary}) end)
    searchBox.FocusLost:Connect(function() SafeTween(searchStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(35,35,35)}) end)

    -- ══════ TAB SYSTEM (5 Tabs) ══════
    local tabBar = Instance.new("Frame"); tabBar.Size = UDim2.new(1, -20, 0, 30)
    tabBar.Position = UDim2.new(0, 10, 0, 86); tabBar.BackgroundTransparency = 1; tabBar.ZIndex = 11; tabBar.Parent = mainFrame
    local tabLay = Instance.new("UIListLayout"); tabLay.FillDirection = Enum.FillDirection.Horizontal
    tabLay.SortOrder = Enum.SortOrder.LayoutOrder; tabLay.Padding = UDim.new(0, 0); tabLay.Parent = tabBar

    -- ══════ BREATHING UISTROKE (Main Frame) ══════
    task.spawn(function()
        while mainStroke and mainStroke.Parent do
            SafeTween(mainStroke, TweenInfo.new(2.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Color = Config.Theme.Primary, Transparency = 0.1})
            task.wait(2.5)
            if not mainStroke or not mainStroke.Parent then break end
            SafeTween(mainStroke, TweenInfo.new(2.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Color = Config.Theme.PrimaryDark, Transparency = 0.5})
            task.wait(2.5)
        end
    end)

    local tabs = {"🐍 Combat", "🐍 Vision", "🐍 Movement", "🐍 World&Utl", "🐍 HUD", "⚙ Settings"}
    local tabButtons = {}
    local tabPages = {}

    local tabIndicator = Instance.new("Frame")
    tabIndicator.Size = UDim2.new(0, 560 / #tabs - 4, 0, 2)
    tabIndicator.Position = UDim2.new(0, 2, 1, -2)
    tabIndicator.BackgroundColor3 = Config.Theme.Primary; tabIndicator.BorderSizePixel = 0
    tabIndicator.ZIndex = 13; tabIndicator.Parent = tabBar

    -- Content area
    local contentArea = Instance.new("Frame"); contentArea.Size = UDim2.new(1, -20, 1, -156)
    contentArea.Position = UDim2.new(0, 10, 0, 120); contentArea.BackgroundTransparency = 1
    contentArea.ClipsDescendants = true; contentArea.ZIndex = 11; contentArea.Parent = mainFrame

    -- ══════ UI BUILDERS ══════

    local function CreateDualPage(name)
        local page = Instance.new("Frame"); page.Name = name
        page.Size = UDim2.new(1, 0, 1, 0); page.BackgroundTransparency = 1; page.Visible = false
        page.ZIndex = 11; page.Parent = contentArea

        -- LEFT COLUMN (Toggles)
        local leftCol = Instance.new("ScrollingFrame"); leftCol.Name = "Left"
        leftCol.Size = UDim2.new(0.48, 0, 1, 0); leftCol.Position = UDim2.new(0, 0, 0, 0)
        leftCol.BackgroundTransparency = 1; leftCol.ScrollBarThickness = 2
        leftCol.ScrollBarImageColor3 = Config.Theme.Primary; leftCol.BorderSizePixel = 0
        leftCol.ZIndex = 11; leftCol.CanvasSize = UDim2.new(0, 0, 0, 0)
        leftCol.AutomaticCanvasSize = Enum.AutomaticSize.Y; leftCol.Parent = page
        local lLayout = Instance.new("UIListLayout"); lLayout.SortOrder = Enum.SortOrder.LayoutOrder
        lLayout.Padding = UDim.new(0, 3); lLayout.Parent = leftCol
        Instance.new("UIPadding", leftCol).PaddingBottom = UDim.new(0, 10)

        -- RIGHT COLUMN (Sliders & Adjustments)
        local rightCol = Instance.new("ScrollingFrame"); rightCol.Name = "Right"
        rightCol.Size = UDim2.new(0.48, 0, 1, 0); rightCol.Position = UDim2.new(0.52, 0, 0, 0)
        rightCol.BackgroundTransparency = 1; rightCol.ScrollBarThickness = 2
        rightCol.ScrollBarImageColor3 = Config.Theme.Primary; rightCol.BorderSizePixel = 0
        rightCol.ZIndex = 11; rightCol.CanvasSize = UDim2.new(0, 0, 0, 0)
        rightCol.AutomaticCanvasSize = Enum.AutomaticSize.Y; rightCol.Parent = page
        local rLayout = Instance.new("UIListLayout"); rLayout.SortOrder = Enum.SortOrder.LayoutOrder
        rLayout.Padding = UDim.new(0, 3); rLayout.Parent = rightCol
        Instance.new("UIPadding", rightCol).PaddingBottom = UDim.new(0, 10)

        return page, leftCol, rightCol
    end

    local function CreateSection(parent, title, order)
        local s = Instance.new("Frame"); s.Size = UDim2.new(1, 0, 0, 22)
        s.BackgroundTransparency = 1; s.LayoutOrder = order; s.ZIndex = 11; s.Parent = parent
        local bar = Instance.new("Frame"); bar.Size = UDim2.new(0, 3, 0, 12); bar.Position = UDim2.new(0, 0, 0.5, -6)
        bar.BackgroundColor3 = Config.Theme.Primary; bar.BorderSizePixel = 0; bar.ZIndex = 12; bar.Parent = s
        Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 2)
        local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1, -10, 1, 0); lbl.Position = UDim2.new(0, 10, 0, 0)
        lbl.BackgroundTransparency = 1; lbl.Text = string.upper(title); lbl.TextColor3 = Config.Theme.Primary
        lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 10; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 12; lbl.Parent = s
    end

    local function CreateToggle(parent, name, order, callback)
        local card = Instance.new("Frame"); card.Name = "Card_" .. name; card.Size = UDim2.new(1, 0, 0, 32)
        card.BackgroundColor3 = Config.Theme.Card; card.BorderSizePixel = 0; card.LayoutOrder = order; card.ZIndex = 11; card.Parent = parent
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)
        local cS = Instance.new("UIStroke"); cS.Color = Color3.fromRGB(35,35,35); cS.Thickness = 1; cS.Parent = card
        local lbl = Instance.new("TextLabel"); lbl.Name = "Label"; lbl.Size = UDim2.new(1, -65, 1, 0); lbl.Position = UDim2.new(0, 10, 0, 0)
        lbl.BackgroundTransparency = 1; lbl.Text = name; lbl.TextColor3 = Config.Theme.Text
        lbl.Font = Enum.Font.Gotham; lbl.TextSize = 12; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 12; lbl.Parent = card
        local tBg = Instance.new("Frame"); tBg.Size = UDim2.new(0, 34, 0, 18); tBg.Position = UDim2.new(1, -42, 0.5, -9)
        tBg.BackgroundColor3 = Color3.fromRGB(40,40,40); tBg.BorderSizePixel = 0; tBg.ZIndex = 12; tBg.Parent = card
        Instance.new("UICorner", tBg).CornerRadius = UDim.new(1, 0)
        local knob = Instance.new("Frame"); knob.Size = UDim2.new(0, 14, 0, 14); knob.Position = UDim2.new(0, 2, 0.5, -7)
        knob.BackgroundColor3 = Config.Theme.TextDim; knob.BorderSizePixel = 0; knob.ZIndex = 13; knob.Parent = tBg
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
        local isOn = false
        local btn = Instance.new("TextButton"); btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1
        btn.Text = ""; btn.ZIndex = 14; btn.Parent = card
        -- Hover effects (0.9 → 0.7 transparency shift)
        btn.MouseEnter:Connect(function()
            SafeTween(card, TweenInfo.new(0.15), {BackgroundColor3 = Config.Theme.CardHover})
            SafeTween(cS, TweenInfo.new(0.15), {Color = isOn and Config.Theme.Primary or Color3.fromRGB(50,50,50)})
        end)
        btn.MouseLeave:Connect(function()
            SafeTween(card, TweenInfo.new(0.2), {BackgroundColor3 = Config.Theme.Card})
            SafeTween(cS, TweenInfo.new(0.2), {Color = isOn and Config.Theme.PrimaryDark or Color3.fromRGB(35,35,35)})
        end)
        btn.MouseButton1Click:Connect(function()
            PlayClickSound()
            isOn = not isOn
            if isOn then
                SafeTween(tBg, TweenInfo.new(0.2), {BackgroundColor3 = Config.Theme.PrimaryDark})
                SafeTween(knob, TweenInfo.new(0.2), {Position = UDim2.new(0, 18, 0.5, -7), BackgroundColor3 = Config.Theme.Primary})
                SafeTween(cS, TweenInfo.new(0.2), {Color = Config.Theme.PrimaryDark})
            else
                SafeTween(tBg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40,40,40)})
                SafeTween(knob, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = Config.Theme.TextDim})
                SafeTween(cS, TweenInfo.new(0.2), {Color = Color3.fromRGB(35,35,35)})
            end
            ShowToast(name .. " " .. (isOn and "ON" or "OFF"))
            UpdateActiveList(name, isOn)
            if callback then callback(isOn) end
        end)
        table.insert(_G.Medusa.AllCards, card)
    end

    local function CreateSlider(parent, name, min, max, default, order, callback)
        local card = Instance.new("Frame"); card.Name = "Card_" .. name; card.Size = UDim2.new(1, 0, 0, 46)
        card.BackgroundColor3 = Config.Theme.Card; card.BorderSizePixel = 0; card.LayoutOrder = order; card.ZIndex = 11; card.Parent = parent
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)
        Instance.new("UIStroke", card).Color = Color3.fromRGB(35,35,35)
        local lbl = Instance.new("TextLabel"); lbl.Name = "Label"; lbl.Size = UDim2.new(0.65, 0, 0, 16); lbl.Position = UDim2.new(0, 10, 0, 3)
        lbl.BackgroundTransparency = 1; lbl.Text = name; lbl.TextColor3 = Config.Theme.Text
        lbl.Font = Enum.Font.Gotham; lbl.TextSize = 11; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 12; lbl.Parent = card
        local vBadge = Instance.new("TextLabel"); vBadge.Size = UDim2.new(0, 44, 0, 16); vBadge.Position = UDim2.new(1, -54, 0, 3)
        vBadge.BackgroundColor3 = Color3.fromRGB(30,30,30); vBadge.BorderSizePixel = 0; vBadge.Text = tostring(default)
        vBadge.TextColor3 = Config.Theme.Primary; vBadge.Font = Enum.Font.GothamBold; vBadge.TextSize = 10; vBadge.ZIndex = 12; vBadge.Parent = card
        Instance.new("UICorner", vBadge).CornerRadius = UDim.new(0, 4)
        local track = Instance.new("Frame"); track.Size = UDim2.new(1, -20, 0, 6); track.Position = UDim2.new(0, 10, 0, 28)
        track.BackgroundColor3 = Color3.fromRGB(35,35,35); track.BorderSizePixel = 0; track.ZIndex = 12; track.Parent = card
        Instance.new("UICorner", track).CornerRadius = UDim.new(0, 3)
        local fill = Instance.new("Frame"); fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
        fill.BackgroundColor3 = Config.Theme.Primary; fill.BorderSizePixel = 0; fill.ZIndex = 13; fill.Parent = track
        Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)
        local fG = Instance.new("UIGradient"); fG.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Config.Theme.PrimaryDark), ColorSequenceKeypoint.new(0.5, Config.Theme.Primary),
            ColorSequenceKeypoint.new(1, Config.Theme.Accent),
        }); fG.Parent = fill
        local knob = Instance.new("Frame"); knob.Size = UDim2.new(0, 12, 0, 12)
        knob.Position = UDim2.new((default-min)/(max-min), -6, 0.5, -6)
        knob.BackgroundColor3 = Config.Theme.Primary; knob.BorderSizePixel = 0; knob.ZIndex = 14; knob.Parent = track
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
        Instance.new("UIStroke", knob).Color = Config.Theme.Accent
        local sliding = false
        local sBtn = Instance.new("TextButton"); sBtn.Size = UDim2.new(1, 0, 0, 18); sBtn.Position = UDim2.new(0, 0, 0, 22)
        sBtn.BackgroundTransparency = 1; sBtn.Text = ""; sBtn.ZIndex = 15; sBtn.Parent = card
        sBtn.MouseButton1Down:Connect(function() sliding = true end)
        AddConnection(UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = false end
        end))
        AddConnection(UserInputService.InputChanged:Connect(function(input)
            if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local tAbs = track.AbsolutePosition; local tSize = track.AbsoluteSize
                local relX = math.clamp((input.Position.X - tAbs.X) / tSize.X, 0, 1)
                local value = math.floor(min + (max - min) * relX)
                fill.Size = UDim2.new(relX, 0, 1, 0); knob.Position = UDim2.new(relX, -6, 0.5, -6)
                vBadge.Text = tostring(value)
                if callback then callback(value) end
            end
        end))
        table.insert(_G.Medusa.AllCards, card)
    end

    local function CreateButton(parent, name, order, callback)
        local btn = Instance.new("TextButton"); btn.Name = "Card_" .. name; btn.Size = UDim2.new(1, 0, 0, 30)
        btn.BackgroundColor3 = Config.Theme.Card; btn.BorderSizePixel = 0; btn.LayoutOrder = order
        btn.Text = ""; btn.ZIndex = 11; btn.Parent = parent
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        local bS = Instance.new("UIStroke"); bS.Color = Color3.fromRGB(35,35,35); bS.Thickness = 1; bS.Parent = btn
        local lbl = Instance.new("TextLabel"); lbl.Name = "Label"; lbl.Size = UDim2.new(1, -16, 1, 0); lbl.Position = UDim2.new(0, 10, 0, 0)
        lbl.BackgroundTransparency = 1; lbl.Text = "▶ " .. name; lbl.TextColor3 = Config.Theme.Text
        lbl.Font = Enum.Font.Gotham; lbl.TextSize = 12; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 12; lbl.Parent = btn
        -- Hover effects
        btn.MouseEnter:Connect(function()
            SafeTween(btn, TweenInfo.new(0.15), {BackgroundColor3 = Config.Theme.CardHover})
            SafeTween(bS, TweenInfo.new(0.15), {Color = Color3.fromRGB(50,50,50)})
            SafeTween(lbl, TweenInfo.new(0.15), {TextColor3 = Config.Theme.Primary})
        end)
        btn.MouseLeave:Connect(function()
            SafeTween(btn, TweenInfo.new(0.2), {BackgroundColor3 = Config.Theme.Card})
            SafeTween(bS, TweenInfo.new(0.2), {Color = Color3.fromRGB(35,35,35)})
            SafeTween(lbl, TweenInfo.new(0.2), {TextColor3 = Config.Theme.Text})
        end)
        btn.MouseButton1Click:Connect(function()
            PlayClickSound()
            SafeTween(bS, TweenInfo.new(0.1), {Color = Config.Theme.Primary})
            SafeTween(btn, TweenInfo.new(0.05), {BackgroundColor3 = Config.Theme.PrimaryDark})
            task.delay(0.15, function() SafeTween(btn, TweenInfo.new(0.2), {BackgroundColor3 = Config.Theme.Card}) end)
            task.delay(0.3, function() SafeTween(bS, TweenInfo.new(0.2), {Color = Color3.fromRGB(35,35,35)}) end)
            ShowToast(name .. " executed"); if callback then callback() end
        end)
        table.insert(_G.Medusa.AllCards, btn)
    end

    -- ══════════════════════════════════════════════════════
    -- CREATE 5 TAB PAGES WITH 2-COLUMN LAYOUT
    -- ══════════════════════════════════════════════════════

    for i, tabName in ipairs(tabs) do
        local page, leftCol, rightCol = CreateDualPage(tabName)
        tabPages[tabName] = page

        local tabBtn = Instance.new("TextButton"); tabBtn.Size = UDim2.new(1/#tabs, 0, 1, 0)
        tabBtn.BackgroundTransparency = 1; tabBtn.Text = tabName
        tabBtn.TextColor3 = i == 1 and Config.Theme.Primary or Config.Theme.TextDim
        tabBtn.Font = Enum.Font.GothamBold; tabBtn.TextSize = 10; tabBtn.LayoutOrder = i; tabBtn.ZIndex = 12; tabBtn.Parent = tabBar
        tabButtons[tabName] = tabBtn

        tabBtn.MouseButton1Click:Connect(function()
            for tN, tP in pairs(tabPages) do
                tP.Visible = (tN == tabName); tabButtons[tN].TextColor3 = (tN == tabName) and Config.Theme.Primary or Config.Theme.TextDim
            end
            local idx = table.find(tabs, tabName) or 1; local tabW = 560 / #tabs
            SafeTween(tabIndicator, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = UDim2.new(0, (idx-1)*tabW + 2, 1, -2)})
        end)
    end
    tabPages[tabs[1]].Visible = true

    -- ═══════════════════════════════════════
    -- TAB 1: COMBAT (Left=Toggles, Right=Sliders)
    -- ═══════════════════════════════════════
    local cL = tabPages[tabs[1]]:FindFirstChild("Left")
    local cR = tabPages[tabs[1]]:FindFirstChild("Right")
    local o = 0

    CreateSection(cL, "Aiming", o); CreateSection(cR, "Aim Settings", o); o=o+1
    CreateToggle(cL, "Silent Aim v2", o, function(v) CombatModule.SilentAim(v) end); CreateSlider(cR, "Aimbot Smoothness", 1, 20, 5, o, function(v) Values.AimbotSmooth=v end); o=o+1
    CreateToggle(cL, "Aimbot", o, function(v) CombatModule.Aimbot(v) end); CreateSlider(cR, "FOV Radius", 50, 500, 120, o, function(v) Values.FOVRadius=v end); o=o+1
    CreateToggle(cL, "FOV Circle", o, function(v) CombatModule.FOVCircle(v) end); o=o+1
    CreateToggle(cL, "Trigger Bot", o, function(v) CombatModule.TriggerBot(v) end); o=o+1

    CreateSection(cL, "Melee Combat", o); CreateSection(cR, "Range & Hitbox", o); o=o+1
    CreateToggle(cL, "Kill Aura", o, function(v) CombatModule.KillAura(v) end); CreateSlider(cR, "Reach Distance", 5, 50, 10, o, function(v) Values.Reach=v end); o=o+1
    CreateToggle(cL, "Auto Parry", o, function(v) CombatModule.AutoParry(v) end); CreateSlider(cR, "Clicker CPS", 1, 30, 12, o, function(v) Values.ClickerCPS=v end); o=o+1
    CreateToggle(cL, "Auto Block", o, function(v) CombatModule.AutoBlock(v) end); CreateSlider(cR, "Strafe Radius", 5, 30, 15, o, function(v) Values.TargetStrafeRadius=v end); o=o+1
    CreateToggle(cL, "Auto Combo", o, function(v) CombatModule.AutoCombo(v) end); o=o+1
    CreateToggle(cL, "Combo Lock", o, function(v) CombatModule.ComboLock(v) end); o=o+1
    CreateToggle(cL, "Auto Clicker", o, function(v) CombatModule.AutoClicker(v) end); o=o+1

    CreateSection(cL, "Utility", o); o=o+1
    CreateToggle(cL, "Reach Extender", o, function(v) CombatModule.Reach(v) end); o=o+1
    CreateToggle(cL, "Hitbox Expander", o, function(v) CombatModule.HitboxExpander(v) end); o=o+1
    CreateToggle(cL, "Target Strafe", o, function(v) CombatModule.TargetStrafe(v) end); o=o+1
    CreateToggle(cL, "Click TP", o, function(v) CombatModule.ClickTP(v) end); o=o+1
    CreateToggle(cL, "Anti Backstab", o, function(v) CombatModule.AntiBackstab(v) end); o=o+1
    CreateToggle(cL, "Target Info", o, function(v) CombatModule.TargetInfo(v) end); o=o+1

    -- ═══════════════════════════════════════
    -- TAB 2: VISION (ESP) (Left=Toggles, Right=Sliders)
    -- ═══════════════════════════════════════
    local eL = tabPages[tabs[2]]:FindFirstChild("Left")
    local eR = tabPages[tabs[2]]:FindFirstChild("Right")
    o = 0

    CreateSection(eL, "Player ESP", o); CreateSection(eR, "ESP Settings", o); o=o+1
    CreateToggle(eL, "3D Box ESP", o, function(v) ESPModule.BoxESP(v) end); CreateSlider(eR, "Max Distance", 100, 2000, 1000, o, function(v) Values.ESPMaxDist=v end); o=o+1
    CreateToggle(eL, "Name ESP", o, function(v) ESPModule.NameESP(v) end); o=o+1
    CreateToggle(eL, "Health ESP", o, function(v) ESPModule.HealthESP(v) end); o=o+1
    CreateToggle(eL, "Distance ESP", o, function(v) ESPModule.DistanceESP(v) end); o=o+1
    CreateToggle(eL, "Tracers", o, function(v) ESPModule.Tracers(v) end); o=o+1
    CreateToggle(eL, "Chams Neon", o, function(v) ESPModule.Chams(v) end); o=o+1
    CreateToggle(eL, "Head Dot", o, function(v) ESPModule.HeadDot(v) end); o=o+1
    CreateToggle(eL, "Skeleton ESP", o, function(v) ESPModule.SkeletonESP(v) end); o=o+1
    CreateToggle(eL, "Corner Box ESP", o, function(v) ESPModule.CornerBox(v) end); o=o+1

    CreateSection(eL, "World ESP", o); CreateSection(eR, "Filters", o); o=o+1
    CreateToggle(eL, "Item ESP", o, function(v) ESPModule.ItemESP(v) end); CreateToggle(eR, "Team Check", o, function(v) ESPModule.TeamCheck(v) end); o=o+1
    CreateToggle(eL, "NPC ESP", o, function(v) ESPModule.NPCESP(v) end); CreateToggle(eR, "Visible Check", o, function(v) ESPModule.VisibleCheck(v) end); o=o+1
    CreateToggle(eL, "Radar 2D", o, function(v) ESPModule.RadarESP(v) end); o=o+1

    CreateSection(eL, "Crosshair", o); o=o+1
    CreateToggle(eL, "Crosshair", o, function(v) ESPModule.Crosshair(v) end); o=o+1
    CreateToggle(eL, "FOV Display", o, function(v) ESPModule.FOVDisplay(v) end); o=o+1

    -- ═══════════════════════════════════════
    -- TAB 3: MOVEMENT (Left=Toggles, Right=Sliders)
    -- ═══════════════════════════════════════
    local mL = tabPages[tabs[3]]:FindFirstChild("Left")
    local mR = tabPages[tabs[3]]:FindFirstChild("Right")
    o = 0

    CreateSection(mL, "Speed & Jump", o); CreateSection(mR, "Speed Settings", o); o=o+1
    CreateToggle(mL, "WalkSpeed", o, function(v) MovementModule.WalkSpeed(v) end); CreateSlider(mR, "Speed Value", 16, 500, 16, o, function(v) Values.WalkSpeed=v end); o=o+1
    CreateToggle(mL, "JumpPower", o, function(v) MovementModule.JumpPower(v) end); CreateSlider(mR, "Jump Value", 50, 500, 50, o, function(v) Values.JumpPower=v end); o=o+1
    CreateToggle(mL, "Infinite Jump", o, function(v) MovementModule.InfiniteJump(v) end); CreateSlider(mR, "High Jump Power", 50, 500, 150, o, function(v) Values.HighJumpPower=v end); o=o+1
    CreateToggle(mL, "Speed Glitch", o, function(v) MovementModule.SpeedGlitch(v) end); o=o+1

    CreateSection(mL, "Aerial", o); CreateSection(mR, "Fly Settings", o); o=o+1
    CreateToggle(mL, "Fly CFrame [F]", o, function(v) MovementModule.Fly(v) end); CreateSlider(mR, "Fly Speed", 10, 300, 80, o, function(v) Values.FlySpeed=v end); o=o+1
    CreateToggle(mL, "Glide", o, function(v) MovementModule.Glide(v) end); CreateSlider(mR, "Dash Power", 50, 300, 100, o, function(v) Values.DashPower=v end); o=o+1
    CreateToggle(mL, "High Jump", o, function(v) MovementModule.HighJump(v) end); o=o+1
    CreateToggle(mL, "Long Jump", o, function(v) MovementModule.LongJump(v) end); o=o+1

    CreateSection(mL, "Traversal", o); o=o+1
    CreateToggle(mL, "Noclip [N]", o, function(v) MovementModule.Noclip(v) end); o=o+1
    CreateToggle(mL, "Spider", o, function(v) MovementModule.Spider(v) end); o=o+1
    CreateToggle(mL, "Phase", o, function(v) MovementModule.Phase(v) end); o=o+1
    CreateToggle(mL, "Bunny Hop", o, function(v) MovementModule.BunnyHop(v) end); o=o+1
    CreateToggle(mL, "Auto Walk", o, function(v) MovementModule.AutoWalk(v) end); o=o+1
    CreateToggle(mL, "Dash [Q]", o, function(v) MovementModule.Dash(v) end); o=o+1
    CreateToggle(mL, "TP to Mouse", o, function(v) MovementModule.TPtoMouse(v) end); o=o+1
    CreateToggle(mL, "Anchor", o, function(v) MovementModule.Anchor(v) end); o=o+1

    -- ═══════════════════════════════════════
    -- TAB 4: WORLD & UTILITY (Left=World, Right=Utility)
    -- ═══════════════════════════════════════
    local wL = tabPages[tabs[4]]:FindFirstChild("Left")
    local wR = tabPages[tabs[4]]:FindFirstChild("Right")
    o = 0

    CreateSection(wL, "World - Lighting", o); CreateSection(wR, "Utility - Protection", o); o=o+1
    CreateToggle(wL, "Fullbright", o, function(v) WorldModule.Fullbright(v) end); CreateToggle(wR, "Anti-AFK", o, function(v) UtilityModule.AntiAFK(v) end); o=o+1
    CreateToggle(wL, "Anti-Fog", o, function(v) WorldModule.AntiFog(v) end); CreateToggle(wR, "Anti-Kick", o, function(v) UtilityModule.AntiKick(v) end); o=o+1
    CreateToggle(wL, "Day Time", o, function(v) WorldModule.DayTime(v) end); CreateToggle(wR, "Anti-Void", o, function(v) UtilityModule.AntiVoid(v) end); o=o+1
    CreateToggle(wL, "Night Time", o, function(v) WorldModule.NightTime(v) end); CreateToggle(wR, "God Mode", o, function(v) UtilityModule.GodMode(v) end); o=o+1
    CreateToggle(wL, "No Weather", o, function(v) WorldModule.NoWeather(v) end); CreateToggle(wR, "No Ragdoll", o, function(v) UtilityModule.NoRagdoll(v) end); o=o+1
    CreateToggle(wL, "Remove Effects", o, function(v) WorldModule.RemoveEffects(v) end); CreateToggle(wR, "Auto Respawn", o, function(v) UtilityModule.AutoRespawn(v) end); o=o+1

    CreateSection(wL, "World - Render", o); CreateSection(wR, "Utility - Character", o); o=o+1
    CreateToggle(wL, "X-Ray", o, function(v) WorldModule.XRay(v) end); CreateToggle(wR, "Hide Name", o, function(v) UtilityModule.HideName(v) end); o=o+1
    CreateToggle(wL, "No Invisible Walls", o, function(v) WorldModule.NoInvisWalls(v) end); CreateToggle(wR, "Sit", o, function(v) UtilityModule.Sit(v) end); o=o+1
    CreateToggle(wL, "Small Characters", o, function(v) WorldModule.SmallChars(v) end); CreateToggle(wR, "Infinite Stamina", o, function(v) UtilityModule.InfStamina(v) end); o=o+1
    CreateToggle(wL, "No Clip Parts", o, function(v) WorldModule.NoClipParts(v) end); CreateToggle(wR, "Chat Spam", o, function(v) UtilityModule.ChatSpam(v) end); o=o+1

    CreateSection(wL, "World - Physics", o); CreateSection(wR, "Utility - Performance", o); o=o+1
    CreateToggle(wL, "Custom Gravity", o, function(v) WorldModule.CustomGravity(v) end); CreateToggle(wR, "FPS Unlock", o, function(v) UtilityModule.FPSUnlock(v) end); o=o+1
    CreateSlider(wL, "Gravity Value", 0, 500, 196, o, function(v) Values.Gravity=v; if State.CustomGravity then Workspace.Gravity=v end end); CreateSlider(wR, "Spam Delay", 1, 10, 2, o, function(v) Values.ChatSpamDelay=v end); o=o+1

    CreateSection(wL, "World - Actions", o); CreateSection(wR, "Utility - Server", o); o=o+1
    CreateButton(wL, "Anti-Lag", o, function() WorldModule.AntiLag(true) end); CreateButton(wR, "Server Hop", o, function() UtilityModule.ServerHop() end); o=o+1
    CreateButton(wL, "Map Cleaner", o, function() WorldModule.MapCleaner() end); CreateButton(wR, "Rejoin", o, function() UtilityModule.Rejoin() end); o=o+1
    CreateButton(wL, "Destroy 3D", o, function() WorldModule.Destroy3D() end); CreateButton(wR, "Copy Game ID", o, function() UtilityModule.CopyGameID() end); o=o+1
    CreateButton(wL, "TP to Spawn", o, function() WorldModule.TPtoSpawn() end); CreateButton(wR, "Copy Server ID", o, function() UtilityModule.CopyServerID() end); o=o+1
    CreateButton(wL, "TP to Random", o, function() WorldModule.TPtoRandom() end); CreateButton(wR, "Reset Character", o, function() UtilityModule.ResetChar() end); o=o+1

    -- ═══════════════════════════════════════
    -- TAB 5: HUD & VISUALS (Left=Overlays, Right=Branding)
    -- ═══════════════════════════════════════
    local hL = tabPages[tabs[5]]:FindFirstChild("Left")
    local hR = tabPages[tabs[5]]:FindFirstChild("Right")
    o = 0

    -- HUD Display
    local hudDisplay = Instance.new("Frame"); hudDisplay.Name = "HUDDisplay"
    hudDisplay.Size = UDim2.new(0, 200, 0, 300); hudDisplay.Position = UDim2.new(0, 10, 0, 10)
    hudDisplay.BackgroundColor3 = Config.Theme.Background; hudDisplay.BackgroundTransparency = 0.3
    hudDisplay.BorderSizePixel = 0; hudDisplay.Visible = false; hudDisplay.ZIndex = 50; hudDisplay.Parent = gui
    Instance.new("UICorner", hudDisplay).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", hudDisplay).Color = Config.Theme.PrimaryDark
    local hudLay = Instance.new("UIListLayout"); hudLay.SortOrder = Enum.SortOrder.LayoutOrder; hudLay.Padding = UDim.new(0, 2); hudLay.Parent = hudDisplay
    local hudPad = Instance.new("UIPadding"); hudPad.PaddingTop = UDim.new(0, 6); hudPad.PaddingLeft = UDim.new(0, 8); hudPad.PaddingRight = UDim.new(0, 8); hudPad.Parent = hudDisplay

    local hudLabels = {}
    for i, name in ipairs({"FPS","Ping","Coords","Players","Velocity","Session","Clock","Memory","Game","Kills"}) do
        local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1, 0, 0, 16); lbl.BackgroundTransparency = 1
        lbl.Text = name..": --"; lbl.TextColor3 = Config.Theme.Primary; lbl.Font = Enum.Font.Code
        lbl.TextSize = 11; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.LayoutOrder = i; lbl.ZIndex = 51; lbl.Parent = hudDisplay
        hudLabels[name] = lbl
    end

    local watermark = Instance.new("TextLabel"); watermark.Name = "Watermark"
    watermark.Size = UDim2.new(0, 240, 0, 22); watermark.Position = UDim2.new(0.5, -120, 0, 5)
    watermark.BackgroundColor3 = Config.Theme.Background; watermark.BackgroundTransparency = 0.3; watermark.BorderSizePixel = 0
    watermark.Text = "🐍 MEDUSA v" .. Config.Version .. " | " .. LocalPlayer.Name
    watermark.TextColor3 = Config.Theme.Primary; watermark.Font = Enum.Font.Code; watermark.TextSize = 12
    watermark.Visible = false; watermark.ZIndex = 50; watermark.Parent = gui
    Instance.new("UICorner", watermark).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", watermark).Color = Config.Theme.PrimaryDark

    -- HUD Loop
    task.spawn(function()
        while _G.Medusa and _G.Medusa.Active do
            local anyHUD = false
            for _, v in pairs({State.FPSCounter, State.PingDisplay, State.Coordinates, State.PlayerCount, State.VelocityDisplay, State.SessionTimer, State.Clock, State.MemoryUsage, State.GameInfo, State.KillCounter}) do
                if v then anyHUD = true; break end
            end
            hudDisplay.Visible = anyHUD
            if anyHUD then
                if State.FPSCounter then local fps = math.floor(1/RunService.RenderStepped:Wait()); hudLabels["FPS"].Text = "FPS: "..fps; hudLabels["FPS"].Visible = true else hudLabels["FPS"].Visible = false end
                if State.PingDisplay then local p = math.floor(LocalPlayer:GetNetworkPing()*1000); hudLabels["Ping"].Text = "Ping: "..p.."ms"; hudLabels["Ping"].TextColor3 = p<80 and Config.Theme.Primary or (p<150 and Config.Theme.Yellow or Config.Theme.Red); hudLabels["Ping"].Visible = true else hudLabels["Ping"].Visible = false end
                if State.Coordinates then local r = GetRootPart(); if r then hudLabels["Coords"].Text = string.format("XYZ: %.0f, %.0f, %.0f", r.Position.X, r.Position.Y, r.Position.Z) end; hudLabels["Coords"].Visible = true else hudLabels["Coords"].Visible = false end
                if State.PlayerCount then hudLabels["Players"].Text = "Players: "..#Players:GetPlayers().."/"..Players.MaxPlayers; hudLabels["Players"].Visible = true else hudLabels["Players"].Visible = false end
                if State.VelocityDisplay then local r = GetRootPart(); if r then hudLabels["Velocity"].Text = "Speed: "..math.floor(r.Velocity.Magnitude).." s/s" end; hudLabels["Velocity"].Visible = true else hudLabels["Velocity"].Visible = false end
                if State.SessionTimer then local e = math.floor(tick()-_G.Medusa.SessionStart); hudLabels["Session"].Text = string.format("Session: %02d:%02d", math.floor(e/60), e%60); hudLabels["Session"].Visible = true else hudLabels["Session"].Visible = false end
                if State.Clock then hudLabels["Clock"].Text = "Time: "..os.date("%H:%M:%S"); hudLabels["Clock"].Visible = true else hudLabels["Clock"].Visible = false end
                if State.MemoryUsage then hudLabels["Memory"].Text = "Memory: "..math.floor(gcinfo()/1024*10)/10 .." MB"; hudLabels["Memory"].Visible = true else hudLabels["Memory"].Visible = false end
                if State.GameInfo then hudLabels["Game"].Text = "Game: "..game.PlaceId; hudLabels["Game"].Visible = true else hudLabels["Game"].Visible = false end
                if State.KillCounter then hudLabels["Kills"].Text = "Kills: ".._G.Medusa.Kills; hudLabels["Kills"].Visible = true else hudLabels["Kills"].Visible = false end
            end
            task.wait(0.5)
        end
    end)

    CreateSection(hL, "Info Overlays", o); CreateSection(hR, "Branding & Display", o); o=o+1
    CreateToggle(hL, "FPS Counter", o, function(v) State.FPSCounter=v end); CreateToggle(hR, "Watermark", o, function(v) State.Watermark=v; watermark.Visible=v end); o=o+1
    CreateToggle(hL, "Ping Display", o, function(v) State.PingDisplay=v end); CreateToggle(hR, "Notifications", o, function(v) State.Notifications=v end); o=o+1
    CreateToggle(hL, "Coordinates", o, function(v) State.Coordinates=v end); CreateToggle(hR, "Keybind List", o, function(v) State.KeybindList=v end); o=o+1
    CreateToggle(hL, "Player Count", o, function(v) State.PlayerCount=v end); CreateToggle(hR, "Minimap Dot", o, function(v) State.MinimapDot=v end); o=o+1
    CreateToggle(hL, "Velocity", o, function(v) State.VelocityDisplay=v end); CreateToggle(hR, "Perf Stats", o, function(v) State.PerfStats=v end); o=o+1
    CreateToggle(hL, "Session Timer", o, function(v) State.SessionTimer=v end); CreateToggle(hR, "Target Info HUD", o, function(v) State.TargetInfoHUD=v end); o=o+1
    CreateToggle(hL, "Clock", o, function(v) State.Clock=v end); o=o+1
    CreateToggle(hL, "Memory Usage", o, function(v) State.MemoryUsage=v end); o=o+1
    CreateToggle(hL, "Game Info", o, function(v) State.GameInfo=v end); o=o+1
    CreateToggle(hL, "Kill Counter", o, function(v) State.KillCounter=v end); o=o+1

    -- ══════ SEARCH FILTER LOGIC ══════
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = string.lower(searchBox.Text)
        for _, card in pairs(_G.Medusa.AllCards) do
            if query == "" then
                card.Visible = true
            else
                local lbl = card:FindFirstChild("Label")
                if lbl then
                    card.Visible = string.find(string.lower(lbl.Text), query, 1, true) ~= nil
                else
                    card.Visible = string.find(string.lower(card.Name), query, 1, true) ~= nil
                end
            end
        end
    end)

    -- ══════ ACTIVE MODULES HUD (Glassmorphism, Draggable, Top-Right) ══════
    local activeFrame = Instance.new("Frame")
    activeFrame.Name = "ActiveList"
    activeFrame.Size = UDim2.new(0, 170, 0, 28)
    activeFrame.Position = UDim2.new(1, -185, 0, 10)
    activeFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
    activeFrame.BackgroundTransparency = 0.35
    activeFrame.BorderSizePixel = 0
    activeFrame.ZIndex = 50
    activeFrame.AutomaticSize = Enum.AutomaticSize.Y
    activeFrame.ClipsDescendants = true
    activeFrame.Active = true
    activeFrame.Parent = gui
    Instance.new("UICorner", activeFrame).CornerRadius = UDim.new(0, 8)

    local aStroke = Instance.new("UIStroke")
    aStroke.Color = Config.Theme.PrimaryDark
    aStroke.Thickness = 1
    aStroke.Transparency = 0.4
    aStroke.Parent = activeFrame

    -- Glassmorphism inner glow
    local aGlow = Instance.new("Frame")
    aGlow.Size = UDim2.new(1, 0, 0, 1)
    aGlow.Position = UDim2.new(0, 0, 0, 0)
    aGlow.BackgroundColor3 = Config.Theme.Primary
    aGlow.BackgroundTransparency = 0.6
    aGlow.BorderSizePixel = 0
    aGlow.ZIndex = 51
    aGlow.Parent = activeFrame
    local aGlowGrad = Instance.new("UIGradient")
    aGlowGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)),
        ColorSequenceKeypoint.new(0.3, Config.Theme.Primary),
        ColorSequenceKeypoint.new(0.7, Config.Theme.Primary),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0,0)),
    })
    aGlowGrad.Parent = aGlow

    -- Header (drag handle)
    local aHeader = Instance.new("Frame")
    aHeader.Name = "DragHandle"
    aHeader.Size = UDim2.new(1, 0, 0, 24)
    aHeader.BackgroundTransparency = 1
    aHeader.ZIndex = 51
    aHeader.Parent = activeFrame

    local aCobra = Instance.new("TextLabel")
    aCobra.Size = UDim2.new(0, 16, 0, 16)
    aCobra.Position = UDim2.new(0, 8, 0.5, -8)
    aCobra.BackgroundTransparency = 1
    aCobra.Text = "🐍"
    aCobra.TextScaled = true
    aCobra.ZIndex = 52
    aCobra.Parent = aHeader

    local aTitle = Instance.new("TextLabel")
    aTitle.Size = UDim2.new(1, -30, 1, 0)
    aTitle.Position = UDim2.new(0, 28, 0, 0)
    aTitle.BackgroundTransparency = 1
    aTitle.Text = "ACTIVE MODULES"
    aTitle.TextColor3 = Config.Theme.Primary
    aTitle.Font = Enum.Font.GothamBold
    aTitle.TextSize = 9
    aTitle.TextXAlignment = Enum.TextXAlignment.Left
    aTitle.ZIndex = 52
    aTitle.Parent = aHeader

    local aCount = Instance.new("TextLabel")
    aCount.Name = "Count"
    aCount.Size = UDim2.new(0, 20, 0, 14)
    aCount.Position = UDim2.new(1, -26, 0.5, -7)
    aCount.BackgroundColor3 = Config.Theme.PrimaryDark
    aCount.BackgroundTransparency = 0.5
    aCount.Text = "0"
    aCount.TextColor3 = Config.Theme.Primary
    aCount.Font = Enum.Font.GothamBold
    aCount.TextSize = 9
    aCount.ZIndex = 52
    aCount.Parent = aHeader
    Instance.new("UICorner", aCount).CornerRadius = UDim.new(0, 4)

    -- Separator
    local aSep = Instance.new("Frame")
    aSep.Size = UDim2.new(1, -16, 0, 1)
    aSep.Position = UDim2.new(0, 8, 0, 24)
    aSep.BackgroundColor3 = Config.Theme.PrimaryDark
    aSep.BackgroundTransparency = 0.6
    aSep.BorderSizePixel = 0
    aSep.ZIndex = 51
    aSep.Parent = activeFrame

    -- Content area for active module entries
    local aContent = Instance.new("Frame")
    aContent.Name = "Content"
    aContent.Size = UDim2.new(1, 0, 0, 0)
    aContent.Position = UDim2.new(0, 0, 0, 26)
    aContent.BackgroundTransparency = 1
    aContent.AutomaticSize = Enum.AutomaticSize.Y
    aContent.ZIndex = 51
    aContent.Parent = activeFrame

    local aLayout = Instance.new("UIListLayout")
    aLayout.SortOrder = Enum.SortOrder.Name
    aLayout.Padding = UDim.new(0, 1)
    aLayout.Parent = aContent

    local aPad = Instance.new("UIPadding")
    aPad.PaddingLeft = UDim.new(0, 8)
    aPad.PaddingRight = UDim.new(0, 8)
    aPad.PaddingBottom = UDim.new(0, 6)
    aPad.Parent = aContent

    -- Make ActiveList draggable via its header
    MakeDraggable(activeFrame, aHeader)

    -- Store reference for UpdateActiveList
    _G.Medusa.ActiveListContent = aContent

    -- Update count badge when children change
    aContent.ChildAdded:Connect(function()
        task.wait(0.05)
        local count = 0
        for _, child in pairs(aContent:GetChildren()) do
            if child:IsA("TextLabel") then count = count + 1 end
        end
        aCount.Text = tostring(count)
        if count > 0 then
            SafeTween(aStroke, TweenInfo.new(0.3), {Color = Config.Theme.Primary, Transparency = 0.2})
        end
    end)
    aContent.ChildRemoved:Connect(function()
        task.wait(0.05)
        local count = 0
        for _, child in pairs(aContent:GetChildren()) do
            if child:IsA("TextLabel") then count = count + 1 end
        end
        aCount.Text = tostring(count)
        if count == 0 then
            SafeTween(aStroke, TweenInfo.new(0.3), {Color = Config.Theme.PrimaryDark, Transparency = 0.4})
        end
    end)

    -- Pulse the ActiveList stroke + glow (Breathing effect synchronized)
    task.spawn(function()
        while activeFrame and activeFrame.Parent do
            SafeTween(aGlow, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0.85})
            SafeTween(aStroke, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Color = Config.Theme.Primary, Transparency = 0.2})
            task.wait(2)
            if not activeFrame or not activeFrame.Parent then break end
            SafeTween(aGlow, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0.5})
            SafeTween(aStroke, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Color = Config.Theme.PrimaryDark, Transparency = 0.5})
            task.wait(2)
        end
    end)

    -- ══════ TARGET INFO CARD (🎯 Predador HUD — Draggable, Glassmorphism) ══════
    local targetFrame = Instance.new("Frame")
    targetFrame.Name = "TargetInfo"
    targetFrame.Size = UDim2.new(0, 170, 0, 0)
    targetFrame.Position = UDim2.new(1, -185, 0, 200)
    targetFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
    targetFrame.BackgroundTransparency = 0.35
    targetFrame.BorderSizePixel = 0
    targetFrame.Visible = false
    targetFrame.AutomaticSize = Enum.AutomaticSize.Y
    targetFrame.ClipsDescendants = true
    targetFrame.Active = true
    targetFrame.ZIndex = 50
    targetFrame.Parent = gui
    Instance.new("UICorner", targetFrame).CornerRadius = UDim.new(0, 8)

    local tiStroke = Instance.new("UIStroke")
    tiStroke.Color = Config.Theme.PrimaryDark
    tiStroke.Thickness = 1
    tiStroke.Transparency = 0.4
    tiStroke.Parent = targetFrame

    -- Glassmorphism glow line (top)
    local tiGlow = Instance.new("Frame")
    tiGlow.Size = UDim2.new(1, 0, 0, 1)
    tiGlow.BackgroundColor3 = Config.Theme.Primary
    tiGlow.BackgroundTransparency = 0.5
    tiGlow.BorderSizePixel = 0
    tiGlow.ZIndex = 51
    tiGlow.Parent = targetFrame
    local tiGlowG = Instance.new("UIGradient")
    tiGlowG.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)),
        ColorSequenceKeypoint.new(0.3, Config.Theme.Primary),
        ColorSequenceKeypoint.new(0.7, Config.Theme.Primary),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0,0)),
    })
    tiGlowG.Parent = tiGlow

    -- Header (drag handle)
    local tiHeader = Instance.new("Frame")
    tiHeader.Name = "DragHandle"
    tiHeader.Size = UDim2.new(1, 0, 0, 24)
    tiHeader.Position = UDim2.new(0, 0, 0, 2)
    tiHeader.BackgroundTransparency = 1
    tiHeader.ZIndex = 51
    tiHeader.Parent = targetFrame

    local tiEmoji = Instance.new("TextLabel")
    tiEmoji.Size = UDim2.new(0, 16, 0, 16)
    tiEmoji.Position = UDim2.new(0, 8, 0.5, -8)
    tiEmoji.BackgroundTransparency = 1
    tiEmoji.Text = "🎯"
    tiEmoji.TextScaled = true
    tiEmoji.ZIndex = 52
    tiEmoji.Parent = tiHeader

    local tiTitle = Instance.new("TextLabel")
    tiTitle.Size = UDim2.new(1, -30, 1, 0)
    tiTitle.Position = UDim2.new(0, 28, 0, 0)
    tiTitle.BackgroundTransparency = 1
    tiTitle.Text = "TARGET INFO"
    tiTitle.TextColor3 = Config.Theme.Primary
    tiTitle.Font = Enum.Font.GothamBold
    tiTitle.TextSize = 9
    tiTitle.TextXAlignment = Enum.TextXAlignment.Left
    tiTitle.ZIndex = 52
    tiTitle.Parent = tiHeader

    -- Separator
    local tiSep = Instance.new("Frame")
    tiSep.Size = UDim2.new(1, -16, 0, 1)
    tiSep.Position = UDim2.new(0, 8, 0, 27)
    tiSep.BackgroundColor3 = Config.Theme.PrimaryDark
    tiSep.BackgroundTransparency = 0.6
    tiSep.BorderSizePixel = 0
    tiSep.ZIndex = 51
    tiSep.Parent = targetFrame

    -- Target content labels
    local tiContent = Instance.new("Frame")
    tiContent.Name = "Content"
    tiContent.Size = UDim2.new(1, 0, 0, 0)
    tiContent.Position = UDim2.new(0, 0, 0, 30)
    tiContent.BackgroundTransparency = 1
    tiContent.AutomaticSize = Enum.AutomaticSize.Y
    tiContent.ZIndex = 51
    tiContent.Parent = targetFrame

    local tiLayout = Instance.new("UIListLayout")
    tiLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tiLayout.Padding = UDim.new(0, 2)
    tiLayout.Parent = tiContent

    local tiPad = Instance.new("UIPadding")
    tiPad.PaddingLeft = UDim.new(0, 6)
    tiPad.PaddingRight = UDim.new(0, 6)
    tiPad.PaddingBottom = UDim.new(0, 5)
    tiPad.Parent = tiContent

    -- Create info labels for target (compact: 12px lines)
    local tiLabels = {}
    for i, lName in ipairs({"Name", "Health", "Distance", "Tool", "Team"}) do
        local lbl = Instance.new("TextLabel")
        lbl.Name = lName
        lbl.Size = UDim2.new(1, 0, 0, 12)
        lbl.BackgroundTransparency = 1
        lbl.Text = lName .. ": --"
        lbl.TextColor3 = (i == 1) and Config.Theme.Accent or Config.Theme.Text
        lbl.Font = (i == 1) and Enum.Font.GothamBold or Enum.Font.Gotham
        lbl.TextSize = (i == 1) and 10 or 9
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.LayoutOrder = i
        lbl.ZIndex = 52
        lbl.Parent = tiContent
        tiLabels[lName] = lbl
    end

    -- Health bar inside target info
    local tiHpBg = Instance.new("Frame")
    tiHpBg.Size = UDim2.new(1, 0, 0, 4)
    tiHpBg.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    tiHpBg.BorderSizePixel = 0
    tiHpBg.LayoutOrder = 6
    tiHpBg.ZIndex = 52
    tiHpBg.Parent = tiContent
    Instance.new("UICorner", tiHpBg).CornerRadius = UDim.new(0, 2)

    local tiHpFill = Instance.new("Frame")
    tiHpFill.Size = UDim2.new(1, 0, 1, 0)
    tiHpFill.BackgroundColor3 = Config.Theme.Primary
    tiHpFill.BorderSizePixel = 0
    tiHpFill.ZIndex = 53
    tiHpFill.Parent = tiHpBg
    Instance.new("UICorner", tiHpFill).CornerRadius = UDim.new(0, 2)
    local tiHpGrad = Instance.new("UIGradient")
    tiHpGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Config.Theme.PrimaryDark),
        ColorSequenceKeypoint.new(0.5, Config.Theme.Primary),
        ColorSequenceKeypoint.new(1, Config.Theme.Accent),
    })
    tiHpGrad.Parent = tiHpFill

    -- Make TargetInfo draggable
    MakeDraggable(targetFrame, tiHeader)

    -- Store reference
    _G.Medusa.TargetInfoFrame = targetFrame
    _G.Medusa.TargetInfoLabels = tiLabels
    _G.Medusa.TargetInfoHpFill = tiHpFill

    -- TargetInfo update loop
    task.spawn(function()
        while _G.Medusa and _G.Medusa.Active do
            if State.TargetInfo or State.TargetInfoHUD then
                local target = GetClosestPlayer(50, false)
                if target and target.Character then
                    targetFrame.Visible = true
                    local hum = target.Character:FindFirstChildOfClass("Humanoid")
                    local hrp = target.Character:FindFirstChild("HumanoidRootPart")
                    local root = GetRootPart()
                    tiLabels["Name"].Text = "🎯 " .. target.DisplayName
                    if hum then
                        local hp = math.floor(hum.Health)
                        local maxHp = math.floor(hum.MaxHealth)
                        tiLabels["Health"].Text = "HP: " .. hp .. "/" .. maxHp
                        local ratio = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                        SafeTween(tiHpFill, TweenInfo.new(0.3), {Size = UDim2.new(ratio, 0, 1, 0)})
                        if ratio > 0.6 then tiHpFill.BackgroundColor3 = Config.Theme.Primary
                        elseif ratio > 0.3 then tiHpFill.BackgroundColor3 = Config.Theme.Yellow
                        else tiHpFill.BackgroundColor3 = Config.Theme.Red end
                    end
                    if hrp and root then
                        tiLabels["Distance"].Text = "Dist: " .. math.floor((root.Position - hrp.Position).Magnitude) .. "m"
                    end
                    local tool = target.Character:FindFirstChildOfClass("Tool")
                    tiLabels["Tool"].Text = "Tool: " .. (tool and tool.Name or "None")
                    tiLabels["Team"].Text = "Team: " .. tostring(target.Team and target.Team.Name or "N/A")
                else
                    targetFrame.Visible = false
                end
            else
                targetFrame.Visible = false
            end
            task.wait(0.25)
        end
    end)

    -- Breathing UIStroke on TargetInfo (synchronized with ActiveList)
    task.spawn(function()
        while targetFrame and targetFrame.Parent do
            SafeTween(tiStroke, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Color = Config.Theme.Primary, Transparency = 0.2})
            SafeTween(tiGlow, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0.85})
            task.wait(2)
            if not targetFrame or not targetFrame.Parent then break end
            SafeTween(tiStroke, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Color = Config.Theme.PrimaryDark, Transparency = 0.5})
            SafeTween(tiGlow, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0.5})
            task.wait(2)
        end
    end)

    -- ══════ FOOTER ══════
    local fLine = Instance.new("Frame"); fLine.Size = UDim2.new(1, -20, 0, 1); fLine.Position = UDim2.new(0, 10, 1, -32)
    fLine.BackgroundColor3 = Config.Theme.Primary; fLine.BorderSizePixel = 0; fLine.ZIndex = 12; fLine.Parent = mainFrame
    local fG = Instance.new("UIGradient"); fG.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)), ColorSequenceKeypoint.new(0.3, Config.Theme.Primary),
        ColorSequenceKeypoint.new(0.7, Config.Theme.Primary), ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0,0)),
    }); fG.Parent = fLine

    local footer = Instance.new("TextLabel"); footer.Size = UDim2.new(1, -80, 0, 24); footer.Position = UDim2.new(0, 10, 1, -28)
    footer.BackgroundTransparency = 1; footer.Text = "🐍 Medusa · [M] Toggle · [F] Fly · [N] Noclip · [Q] Dash"
    footer.TextColor3 = Config.Theme.TextDim; footer.Font = Enum.Font.Gotham; footer.TextSize = 10; footer.ZIndex = 12; footer.Parent = mainFrame

    local fPing = Instance.new("TextLabel"); fPing.Size = UDim2.new(0, 60, 0, 24); fPing.Position = UDim2.new(1, -70, 1, -28)
    fPing.BackgroundTransparency = 1; fPing.Text = "-- ms"; fPing.TextColor3 = Config.Theme.Primary
    fPing.Font = Enum.Font.Code; fPing.TextSize = 10; fPing.TextXAlignment = Enum.TextXAlignment.Right; fPing.ZIndex = 12; fPing.Parent = mainFrame
    task.spawn(function()
        while _G.Medusa and _G.Medusa.Active do
            local p = math.floor(LocalPlayer:GetNetworkPing()*1000)
            fPing.Text = p.." ms"; fPing.TextColor3 = p<80 and Config.Theme.Primary or (p<150 and Config.Theme.Yellow or Config.Theme.Red)
            task.wait(2)
        end
    end)

    -- SLIDE UP
    SafeTween(mainFrame, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -290, 0.5, -340)})
    ShowToast("Medusa Engine loaded! 96 functions ready.")
    ConsoleLog("🐍 Medusa v" .. Config.Version .. " | 96 functions | 5 tabs | 2-column", "SYSTEM")
    return mainFrame
end

-- ╔══════════════════════════════════════════════════════╗
-- ║      SECTION 14: KEYBIND SYSTEM                     ║
-- ╚══════════════════════════════════════════════════════╝

local function SetupKeybinds(mainFrame)
    AddConnection(UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Config.Keybinds.ToggleUI then
            _G.Medusa.UIVisible = not _G.Medusa.UIVisible
            if _G.Medusa.UIVisible then
                SafeTween(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -290, 0.5, -340)})
            else
                SafeTween(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(0.5, -290, 1.2, 0)})
            end
        end
        if input.KeyCode == Config.Keybinds.Fly then State.Fly = not State.Fly; MovementModule.Fly(State.Fly) end
        if input.KeyCode == Config.Keybinds.Noclip then State.Noclip = not State.Noclip; MovementModule.Noclip(State.Noclip) end
    end))
end

-- ╔══════════════════════════════════════════════════════╗
-- ║         SECTION 15: INITIALIZE ENGINE               ║
-- ╚══════════════════════════════════════════════════════╝

ConsoleLog("🐍 Medusa Universal Engine v" .. Config.Version .. " starting...", "SYSTEM")
ConsoleLog("Hard Clean: Complete", "SYSTEM")
ConsoleLog("Metatable Bypass: " .. (BypassActive and "ACTIVE" or "PASSIVE"), "SYSTEM")
ConsoleLog("Modules: Combat, Vision, Movement, World, Utility, HUD", "SYSTEM")
ConsoleLog("Total Functions: 96 | Layout: 2-Column | Tabs: 5", "SYSTEM")

PlayCinematicIntro(function()
    local mainFrame = BuildMainUI()
    SetupKeybinds(mainFrame)

    AddConnection(LocalPlayer.CharacterAdded:Connect(function()
        ConsoleLog("Character respawned — reapplying", "SYSTEM")
        task.wait(1)
        if State.WalkSpeedOn then local h = GetHumanoid(); if h then h.WalkSpeed = Values.WalkSpeed end end
        if State.JumpPowerOn then local h = GetHumanoid(); if h then h.UseJumpPower=true; h.JumpPower = Values.JumpPower end end
        if State.Fly then MovementModule.Fly(false); task.wait(0.5); MovementModule.Fly(true) end
        if State.Noclip then MovementModule.Noclip(true) end
    end))

    ConsoleLog("🐍 Engine ready. Welcome to Medusa.", "SYSTEM")
end)
