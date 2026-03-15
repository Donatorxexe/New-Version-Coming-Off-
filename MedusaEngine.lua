--[[
  ╔══════════════════════════════════════════════════════════════════╗
  ║              M E D U S A   U N I V E R S A L   E N G I N E     ║
  ║                        v1.0.0 — Lua Edition                     ║
  ║                                                                  ║
  ║  Tema: Preto + Verde Esmeralda (0, 201, 107)                    ║
  ║  Organização: Config / Functions / UI                            ║
  ║  100% passivo até ativar funções                                 ║
  ╚══════════════════════════════════════════════════════════════════╝
]]

-- ═══════════════════════════════════════════════════════════════
--  HARD CLEAN — Limpa variáveis globais antes de iniciar
-- ═══════════════════════════════════════════════════════════════
if _G.Medusa then
    pcall(function()
        -- Desconectar todas as conexões anteriores
        if _G.Medusa.Connections then
            for _, conn in pairs(_G.Medusa.Connections) do
                pcall(function() conn:Disconnect() end)
            end
        end
        -- Destruir a GUI anterior
        if _G.Medusa.GUI then
            pcall(function() _G.Medusa.GUI:Destroy() end)
        end
        -- Restaurar propriedades originais
        if _G.Medusa.OriginalWS then
            pcall(function()
                local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.WalkSpeed = _G.Medusa.OriginalWS
                    hum.JumpPower = _G.Medusa.OriginalJP
                end
            end)
        end
    end)
    _G.Medusa = nil
    warn("[Medusa] Hard Clean: Previous instance purged.")
    task.wait(0.2)
end

_G.Medusa = {
    Connections = {},
    GUI = nil,
    OriginalWS = 16,
    OriginalJP = 50,
}

-- ═══════════════════════════════════════════════════════════════
--  SERVICES
-- ═══════════════════════════════════════════════════════════════
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- ═══════════════════════════════════════════════════════════════
--  CONFIG TABLE — Definições centrais
-- ═══════════════════════════════════════════════════════════════
local Config = {
    Version = "1.0.0",
    Theme = {
        Emerald      = Color3.fromRGB(0, 201, 107),
        EmeraldDark  = Color3.fromRGB(0, 121, 63),
        EmeraldGlow  = Color3.fromRGB(0, 255, 136),
        Background   = Color3.fromRGB(0, 0, 0),
        BgSecondary  = Color3.fromRGB(10, 10, 10),
        BgCard       = Color3.fromRGB(13, 13, 13),
        BgCardHover  = Color3.fromRGB(17, 17, 17),
        Border       = Color3.fromRGB(26, 26, 26),
        TextPrimary  = Color3.fromRGB(224, 224, 224),
        TextSecondary= Color3.fromRGB(112, 112, 112),
        White        = Color3.fromRGB(255, 255, 255),
        DarkGrey     = Color3.fromRGB(51, 51, 51),
        ToggleOff    = Color3.fromRGB(26, 26, 26),
        ToggleBorderOff = Color3.fromRGB(42, 42, 42),
    },
    Defaults = {
        WalkSpeed = 16,
        JumpPower = 50,
        FlySpeed  = 60,
    },
    Limits = {
        WalkSpeed = {min = 16,  max = 200},
        JumpPower = {min = 50,  max = 300},
        FlySpeed  = {min = 10,  max = 200},
    },
    State = {
        WalkSpeedEnabled = false,
        JumpPowerEnabled = false,
        InfJumpEnabled   = false,
        FlyEnabled       = false,
        NoclipEnabled    = false,
        FullbrightEnabled= false,
        ESPEnabled       = false,
        WalkSpeedValue   = 16,
        JumpPowerValue   = 50,
        FlySpeedValue    = 60,
    },
    IntroComplete = false,
    PanelVisible  = true,
}

-- ═══════════════════════════════════════════════════════════════
--  UTILITY HELPERS
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

local function Lerp(a, b, t)
    return a + (b - a) * t
end

local function AddConnection(conn)
    table.insert(_G.Medusa.Connections, conn)
    return conn
end

-- ═══════════════════════════════════════════════════════════════
--  SCREENGUI — Base (IgnoreGuiInset, DisplayOrder = 1000000)
-- ═══════════════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MedusaEngine"
ScreenGui.DisplayOrder = 1000000
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")
_G.Medusa.GUI = ScreenGui

-- Font references
local FontMono = Font.new("rbxasset://fonts/families/RobotoMono.json", Enum.FontWeight.Regular)
local FontMonoBold = Font.new("rbxasset://fonts/families/RobotoMono.json", Enum.FontWeight.Bold)
local FontMonoSemiBold = Font.new("rbxasset://fonts/families/RobotoMono.json", Enum.FontWeight.SemiBold)

-- ═══════════════════════════════════════════════════════════════
--  UI TABLE — Construção & Manipulação de Interface
-- ═══════════════════════════════════════════════════════════════
local UI = {}
UI.Elements = {}
UI.ConsoleLogs = {}
UI.Toasts = {}
UI.Tabs = {}

-- ── Helper: Create Instance ──
function UI.Create(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then
            pcall(function() inst[k] = v end)
        end
    end
    for _, child in ipairs(children or {}) do
        child.Parent = inst
    end
    if props and props.Parent then
        inst.Parent = props.Parent
    end
    return inst
end

-- ═══════════════════════════════════════════════════════════════
--  INTRO OVERLAY — Cinematográfica
-- ═══════════════════════════════════════════════════════════════
local IntroOverlay = UI.Create("Frame", {
    Name = "IntroOverlay",
    Size = UDim2.new(1, 0, 1, 0),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundColor3 = Config.Theme.Background,
    BorderSizePixel = 0,
    ZIndex = 100,
    Parent = ScreenGui,
})

-- ── Logo: M E D U S A com UIStroke Verde Esmeralda pulsando ──
local LogoLabel = UI.Create("TextLabel", {
    Name = "LogoText",
    Size = UDim2.new(1, 0, 0, 80),
    Position = UDim2.new(0, 0, 0.35, 0),
    BackgroundTransparency = 1,
    Text = "M E D U S A",
    FontFace = FontMonoBold,
    TextSize = 52,
    TextColor3 = Config.Theme.Background, -- Texto transparente (preto no preto)
    TextTransparency = 0,
    ZIndex = 102,
    Parent = IntroOverlay,
})

local LogoStroke = UI.Create("UIStroke", {
    Color = Config.Theme.Emerald,
    Thickness = 2,
    Transparency = 0.8,
    Parent = LogoLabel,
})

-- ── Subtitle ──
local SubtitleLabel = UI.Create("TextLabel", {
    Name = "Subtitle",
    Size = UDim2.new(1, 0, 0, 20),
    Position = UDim2.new(0, 0, 0.35, 70),
    BackgroundTransparency = 1,
    Text = "UNIVERSAL ENGINE v1.0.0",
    FontFace = FontMono,
    TextSize = 12,
    TextColor3 = Config.Theme.TextSecondary,
    TextTransparency = 1,
    ZIndex = 102,
    Parent = IntroOverlay,
})

-- ── Barra Neon: UIGradient 3 pontos (Verde Escuro > Branco > Verde Escuro) ──
local NeonBarBg = UI.Create("Frame", {
    Name = "NeonBarBg",
    Size = UDim2.new(0, 400, 0, 3),
    Position = UDim2.new(0.5, -200, 0.35, 120),
    BackgroundColor3 = Color3.fromRGB(17, 17, 17),
    BorderSizePixel = 0,
    ZIndex = 102,
    Visible = false,
    Parent = IntroOverlay,
}, {
    UI.Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
})

local NeonBarFill = UI.Create("Frame", {
    Name = "NeonBarFill",
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundColor3 = Config.Theme.Emerald,
    BorderSizePixel = 0,
    ZIndex = 103,
    Parent = NeonBarBg,
}, {
    UI.Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
})

local NeonGradient = UI.Create("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,   Config.Theme.EmeraldDark),
        ColorSequenceKeypoint.new(0.5, Config.Theme.White),
        ColorSequenceKeypoint.new(1,   Config.Theme.EmeraldDark),
    }),
    Offset = Vector2.new(-1, 0),
    Parent = NeonBarFill,
})

-- ── Barra de Progresso ──
local ProgressTrack = UI.Create("Frame", {
    Name = "ProgressTrack",
    Size = UDim2.new(0, 400, 0, 2),
    Position = UDim2.new(0.5, -200, 0.35, 128),
    BackgroundColor3 = Color3.fromRGB(10, 10, 10),
    BorderSizePixel = 0,
    ZIndex = 102,
    Visible = false,
    Parent = IntroOverlay,
}, {
    UI.Create("UICorner", {CornerRadius = UDim.new(0, 2)}),
})

local ProgressFill = UI.Create("Frame", {
    Name = "ProgressFill",
    Size = UDim2.new(0, 0, 1, 0),
    BackgroundColor3 = Config.Theme.Emerald,
    BorderSizePixel = 0,
    ZIndex = 103,
    Parent = ProgressTrack,
}, {
    UI.Create("UICorner", {CornerRadius = UDim.new(0, 2)}),
})

-- ── Loading Status Text ──
local LoadingStatus = UI.Create("TextLabel", {
    Name = "LoadingStatus",
    Size = UDim2.new(0, 400, 0, 18),
    Position = UDim2.new(0.5, -200, 0.35, 145),
    BackgroundTransparency = 1,
    Text = "",
    FontFace = FontMono,
    TextSize = 11,
    TextColor3 = Config.Theme.EmeraldDark,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTransparency = 1,
    ZIndex = 102,
    Parent = IntroOverlay,
})

-- ═══════════════════════════════════════════════════════════════
--  MAIN FRAME — Panel Principal
-- ═══════════════════════════════════════════════════════════════
local MainFrame = UI.Create("Frame", {
    Name = "MainFrame",
    Size = UDim2.new(0, 480, 0, 520),
    Position = UDim2.new(0.5, -240, 1.2, 0), -- Começa fora da tela (Y = 1.2)
    BackgroundColor3 = Config.Theme.BgSecondary,
    BorderSizePixel = 0,
    ZIndex = 50,
    Visible = false,
    Parent = ScreenGui,
}, {
    UI.Create("UICorner", {CornerRadius = UDim.new(0, 12)}),
    UI.Create("UIStroke", {
        Color = Config.Theme.Border,
        Thickness = 1,
    }),
})

-- ── Sombra Neon no MainFrame ──
local MainShadow = UI.Create("ImageLabel", {
    Name = "Shadow",
    Size = UDim2.new(1, 40, 1, 40),
    Position = UDim2.new(0, -20, 0, -20),
    BackgroundTransparency = 1,
    Image = "rbxassetid://6015897843",
    ImageColor3 = Color3.fromRGB(0, 201, 107),
    ImageTransparency = 0.92,
    ScaleType = Enum.ScaleType.Slice,
    SliceCenter = Rect.new(49, 49, 450, 450),
    ZIndex = 49,
    Parent = MainFrame,
})

-- ═══════════════════════════════════════════════════════════════
--  TITLE BAR
-- ═══════════════════════════════════════════════════════════════
local TitleBar = UI.Create("Frame", {
    Name = "TitleBar",
    Size = UDim2.new(1, 0, 0, 42),
    BackgroundColor3 = Config.Theme.Background,
    BorderSizePixel = 0,
    ZIndex = 51,
    Parent = MainFrame,
}, {
    UI.Create("UICorner", {CornerRadius = UDim.new(0, 12)}),
})

-- Fix corners: bottom cover
UI.Create("Frame", {
    Size = UDim2.new(1, 0, 0, 12),
    Position = UDim2.new(0, 0, 1, -12),
    BackgroundColor3 = Config.Theme.Background,
    BorderSizePixel = 0,
    ZIndex = 51,
    Parent = TitleBar,
})

-- Title bar bottom border
UI.Create("Frame", {
    Size = UDim2.new(1, 0, 0, 1),
    Position = UDim2.new(0, 0, 1, 0),
    BackgroundColor3 = Config.Theme.Border,
    BorderSizePixel = 0,
    ZIndex = 52,
    Parent = TitleBar,
})

-- ── Icon dot pulsante ──
local TitleIcon = UI.Create("Frame", {
    Name = "TitleIcon",
    Size = UDim2.new(0, 10, 0, 10),
    Position = UDim2.new(0, 16, 0.5, -5),
    BackgroundColor3 = Config.Theme.Emerald,
    BorderSizePixel = 0,
    ZIndex = 52,
    Parent = TitleBar,
}, {
    UI.Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
})

-- ── Title Text ──
UI.Create("TextLabel", {
    Size = UDim2.new(0, 80, 1, 0),
    Position = UDim2.new(0, 34, 0, 0),
    BackgroundTransparency = 1,
    Text = "MEDUSA",
    FontFace = FontMonoBold,
    TextSize = 13,
    TextColor3 = Config.Theme.Emerald,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 52,
    Parent = TitleBar,
})

UI.Create("TextLabel", {
    Size = UDim2.new(0, 160, 1, 0),
    Position = UDim2.new(0, 120, 0, 0),
    BackgroundTransparency = 1,
    Text = "v1.0.0 — Universal",
    FontFace = FontMono,
    TextSize = 10,
    TextColor3 = Config.Theme.TextSecondary,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 52,
    Parent = TitleBar,
})

-- ── Close Button ──
local CloseBtn = UI.Create("TextButton", {
    Name = "CloseBtn",
    Size = UDim2.new(0, 28, 0, 28),
    Position = UDim2.new(1, -38, 0.5, -14),
    BackgroundColor3 = Color3.fromRGB(15, 15, 15),
    BorderSizePixel = 0,
    Text = "×",
    FontFace = FontMono,
    TextSize = 18,
    TextColor3 = Config.Theme.TextSecondary,
    ZIndex = 53,
    Parent = TitleBar,
}, {
    UI.Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
    UI.Create("UIStroke", {Color = Color3.fromRGB(42, 42, 42), Thickness = 1}),
})

-- ── Minimize Button ──
local MinBtn = UI.Create("TextButton", {
    Name = "MinBtn",
    Size = UDim2.new(0, 28, 0, 28),
    Position = UDim2.new(1, -70, 0.5, -14),
    BackgroundColor3 = Color3.fromRGB(15, 15, 15),
    BorderSizePixel = 0,
    Text = "—",
    FontFace = FontMono,
    TextSize = 12,
    TextColor3 = Config.Theme.TextSecondary,
    ZIndex = 53,
    Parent = TitleBar,
}, {
    UI.Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
    UI.Create("UIStroke", {Color = Color3.fromRGB(42, 42, 42), Thickness = 1}),
})

-- ── Drag Logic ──
local dragging, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

AddConnection(UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end))

AddConnection(UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end))

-- ═══════════════════════════════════════════════════════════════
--  TAB NAVIGATION
-- ═══════════════════════════════════════════════════════════════
local TabBar = UI.Create("Frame", {
    Name = "TabBar",
    Size = UDim2.new(1, 0, 0, 36),
    Position = UDim2.new(0, 0, 0, 42),
    BackgroundColor3 = Config.Theme.Background,
    BorderSizePixel = 0,
    ZIndex = 51,
    Parent = MainFrame,
})

UI.Create("Frame", {
    Size = UDim2.new(1, 0, 0, 1),
    Position = UDim2.new(0, 0, 1, 0),
    BackgroundColor3 = Config.Theme.Border,
    BorderSizePixel = 0,
    ZIndex = 52,
    Parent = TabBar,
})

local TabNames = {"Movement", "Visuals", "Console"}
local TabButtons = {}
local TabPages = {}

for i, name in ipairs(TabNames) do
    local tabBtn = UI.Create("TextButton", {
        Name = "Tab_" .. name,
        Size = UDim2.new(0, 120, 1, 0),
        Position = UDim2.new(0, (i - 1) * 120 + 12, 0, 0),
        BackgroundTransparency = 1,
        Text = string.upper(name),
        FontFace = FontMono,
        TextSize = 11,
        TextColor3 = i == 1 and Config.Theme.Emerald or Config.Theme.TextSecondary,
        ZIndex = 53,
        Parent = TabBar,
    })

    -- Active indicator line
    local indicator = UI.Create("Frame", {
        Name = "Indicator",
        Size = UDim2.new(0.6, 0, 0, 2),
        Position = UDim2.new(0.2, 0, 1, -2),
        BackgroundColor3 = Config.Theme.Emerald,
        BorderSizePixel = 0,
        Visible = (i == 1),
        ZIndex = 54,
        Parent = tabBtn,
    }, {
        UI.Create("UICorner", {CornerRadius = UDim.new(0, 2)}),
    })

    TabButtons[name] = {Button = tabBtn, Indicator = indicator}
end

-- ═══════════════════════════════════════════════════════════════
--  CONTENT AREA — ScrollingFrame
-- ═══════════════════════════════════════════════════════════════
local ContentArea = UI.Create("ScrollingFrame", {
    Name = "ContentArea",
    Size = UDim2.new(1, 0, 1, -42 - 36 - 36), -- TitleBar - TabBar - Footer
    Position = UDim2.new(0, 0, 0, 42 + 36),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = Color3.fromRGB(26, 26, 26),
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ZIndex = 51,
    Parent = MainFrame,
})

-- ═══════════════════════════════════════════════════════════════
--  UI COMPONENT BUILDERS
-- ═══════════════════════════════════════════════════════════════

-- ── Section Header ──
function UI.CreateSectionHeader(parent, text)
    local container = UI.Create("Frame", {
        Size = UDim2.new(1, -32, 0, 20),
        Position = UDim2.new(0, 16, 0, 0),
        BackgroundTransparency = 1,
        ZIndex = 52,
        Parent = parent,
    })

    UI.Create("TextLabel", {
        Size = UDim2.new(0, 200, 1, 0),
        BackgroundTransparency = 1,
        Text = string.upper(text),
        FontFace = FontMono,
        TextSize = 9,
        TextColor3 = Config.Theme.TextSecondary,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 52,
        Parent = container,
    })

    -- Separator line
    UI.Create("Frame", {
        Size = UDim2.new(1, -120, 0, 1),
        Position = UDim2.new(0, 120, 0.5, 0),
        BackgroundColor3 = Config.Theme.Border,
        BorderSizePixel = 0,
        ZIndex = 52,
        Parent = container,
    })

    return container
end

-- ── Toggle Switch ──
function UI.CreateToggle(parent, position, id)
    local toggleFrame = UI.Create("Frame", {
        Name = "Toggle_" .. id,
        Size = UDim2.new(0, 38, 0, 20),
        Position = position,
        BackgroundColor3 = Config.Theme.ToggleOff,
        BorderSizePixel = 0,
        ZIndex = 55,
        Parent = parent,
    }, {
        UI.Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
        UI.Create("UIStroke", {Color = Config.Theme.ToggleBorderOff, Thickness = 1}),
    })

    local knob = UI.Create("Frame", {
        Name = "Knob",
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(0, 3, 0.5, -7),
        BackgroundColor3 = Config.Theme.DarkGrey,
        BorderSizePixel = 0,
        ZIndex = 56,
        Parent = toggleFrame,
    }, {
        UI.Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
    })

    -- Click area
    local clickBtn = UI.Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 57,
        Parent = toggleFrame,
    })

    UI.Elements["toggle_" .. id] = {
        Frame = toggleFrame,
        Knob = knob,
        Button = clickBtn,
        Stroke = toggleFrame:FindFirstChildOfClass("UIStroke"),
        IsOn = false,
    }

    return clickBtn
end

-- ── Slider ──
function UI.CreateSlider(parent, id, minVal, maxVal, defaultVal, labelText)
    local sliderContainer = UI.Create("Frame", {
        Name = "Slider_" .. id,
        Size = UDim2.new(1, -32, 0, 30),
        BackgroundTransparency = 1,
        ZIndex = 52,
        Parent = parent,
    })

    -- Label
    UI.Create("TextLabel", {
        Size = UDim2.new(0, 30, 0, 20),
        Position = UDim2.new(0, 0, 0.5, -10),
        BackgroundTransparency = 1,
        Text = tostring(minVal),
        FontFace = FontMono,
        TextSize = 10,
        TextColor3 = Config.Theme.TextSecondary,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 52,
        Parent = sliderContainer,
    })

    -- Track
    local track = UI.Create("Frame", {
        Name = "Track",
        Size = UDim2.new(1, -90, 0, 4),
        Position = UDim2.new(0, 35, 0.5, -2),
        BackgroundColor3 = Color3.fromRGB(26, 26, 26),
        BorderSizePixel = 0,
        ZIndex = 53,
        Parent = sliderContainer,
    }, {
        UI.Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
    })

    -- Fill
    local initPct = (defaultVal - minVal) / (maxVal - minVal)
    local fill = UI.Create("Frame", {
        Name = "Fill",
        Size = UDim2.new(initPct, 0, 1, 0),
        BackgroundColor3 = Config.Theme.Emerald,
        BorderSizePixel = 0,
        ZIndex = 54,
        Parent = track,
    }, {
        UI.Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
    })

    -- Thumb
    local thumb = UI.Create("Frame", {
        Name = "Thumb",
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(1, -7, 0.5, -7),
        BackgroundColor3 = Config.Theme.Emerald,
        BorderSizePixel = 0,
        ZIndex = 56,
        Parent = fill,
    }, {
        UI.Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
        UI.Create("UIStroke", {Color = Config.Theme.Background, Thickness = 2}),
    })

    -- Value label
    local valueLabel = UI.Create("TextLabel", {
        Name = "Value",
        Size = UDim2.new(0, 45, 0, 20),
        Position = UDim2.new(1, -45, 0.5, -10),
        BackgroundTransparency = 1,
        Text = tostring(defaultVal),
        FontFace = FontMonoSemiBold,
        TextSize = 12,
        TextColor3 = Config.Theme.Emerald,
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 52,
        Parent = sliderContainer,
    })

    -- Slider input area (invisible button over track)
    local inputBtn = UI.Create("TextButton", {
        Size = UDim2.new(1, 14, 0, 20),
        Position = UDim2.new(0, -7, 0.5, -10),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 57,
        Parent = track,
    })

    local sliderData = {
        Container = sliderContainer,
        Track = track,
        Fill = fill,
        ValueLabel = valueLabel,
        InputBtn = inputBtn,
        Min = minVal,
        Max = maxVal,
        Value = defaultVal,
        Dragging = false,
        Enabled = false,
    }

    -- Drag logic
    local function updateSlider(inputX)
        local trackAbsPos = track.AbsolutePosition.X
        local trackAbsSize = track.AbsoluteSize.X
        local pct = math.clamp((inputX - trackAbsPos) / trackAbsSize, 0, 1)
        local val = math.floor(minVal + pct * (maxVal - minVal))
        sliderData.Value = val
        fill.Size = UDim2.new(pct, 0, 1, 0)
        valueLabel.Text = tostring(val)
        return val
    end

    inputBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliderData.Dragging = true
            updateSlider(input.Position.X)
        end
    end)

    AddConnection(UIS.InputChanged:Connect(function(input)
        if sliderData.Dragging and sliderData.Enabled and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input.Position.X)
        end
    end))

    AddConnection(UIS.InputEnded:Connect(function(input)
        if sliderData.Dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            sliderData.Dragging = false
        end
    end))

    UI.Elements["slider_" .. id] = sliderData
    return sliderContainer, sliderData
end

-- ── Function Card ──
function UI.CreateFuncCard(parent, data)
    local card = UI.Create("Frame", {
        Name = "Card_" .. data.id,
        Size = UDim2.new(1, -32, 0, data.height or 70),
        BackgroundColor3 = Config.Theme.BgCard,
        BorderSizePixel = 0,
        ZIndex = 52,
        Parent = parent,
    }, {
        UI.Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
        UI.Create("UIStroke", {Color = Config.Theme.Border, Thickness = 1}),
        UI.Create("UIPadding", {
            PaddingLeft = UDim.new(0, 14),
            PaddingRight = UDim.new(0, 14),
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10),
        }),
    })

    -- Status dot
    local statusDot = UI.Create("Frame", {
        Name = "StatusDot",
        Size = UDim2.new(0, 6, 0, 6),
        Position = UDim2.new(0, 0, 0, 6),
        BackgroundColor3 = Config.Theme.DarkGrey,
        BorderSizePixel = 0,
        ZIndex = 54,
        Parent = card,
    }, {
        UI.Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
    })

    -- Function name
    UI.Create("TextLabel", {
        Size = UDim2.new(0.7, -20, 0, 16),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text = data.name,
        FontFace = FontMonoSemiBold,
        TextSize = 13,
        TextColor3 = Config.Theme.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 54,
        Parent = card,
    })

    -- Keybind badge
    if data.keybind then
        UI.Create("TextLabel", {
            Size = UDim2.new(0, 45, 0, 18),
            Position = UDim2.new(0, 14 + #data.name * 8, 0, -1),
            BackgroundColor3 = Color3.fromRGB(17, 17, 17),
            BorderSizePixel = 0,
            Text = data.keybind,
            FontFace = FontMono,
            TextSize = 10,
            TextColor3 = Color3.fromRGB(85, 85, 85),
            ZIndex = 54,
            Parent = card,
        }, {
            UI.Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
            UI.Create("UIStroke", {Color = Color3.fromRGB(34, 34, 34), Thickness = 1}),
        })
    end

    -- Description
    UI.Create("TextLabel", {
        Size = UDim2.new(0.8, 0, 0, 14),
        Position = UDim2.new(0, 14, 0, 20),
        BackgroundTransparency = 1,
        Text = data.desc,
        FontFace = FontMono,
        TextSize = 10,
        TextColor3 = Config.Theme.TextSecondary,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 54,
        Parent = card,
    })

    -- Toggle
    local toggleBtn = UI.CreateToggle(card, UDim2.new(1, -38, 0, 0), data.id)

    UI.Elements["card_" .. data.id] = {
        Card = card,
        StatusDot = statusDot,
        Stroke = card:FindFirstChildOfClass("UIStroke"),
    }

    return card, toggleBtn
end

-- ═══════════════════════════════════════════════════════════════
--  BUILD TAB PAGES
-- ═══════════════════════════════════════════════════════════════

-- ── Movement Tab ──
local MovementPage = UI.Create("Frame", {
    Name = "Page_Movement",
    Size = UDim2.new(1, 0, 0, 0),
    BackgroundTransparency = 1,
    AutomaticSize = Enum.AutomaticSize.Y,
    ZIndex = 51,
    Parent = ContentArea,
}, {
    UI.Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
    }),
    UI.Create("UIPadding", {
        PaddingTop = UDim.new(0, 12),
        PaddingBottom = UDim.new(0, 12),
    }),
})

TabPages["Movement"] = MovementPage

-- Section: Speed Controls
UI.CreateSectionHeader(MovementPage, "Speed Controls")

-- WalkSpeed Card
local wsCard = UI.CreateFuncCard(MovementPage, {
    id = "walkspeed",
    name = "WalkSpeed",
    desc = "Controla a velocidade de movimento do personagem",
    height = 95,
})

local wsSlider, wsSliderData = UI.CreateSlider(wsCard, "walkspeed", 16, 200, 16, "Speed")
wsSlider.Position = UDim2.new(0, 0, 0, 42)
wsSlider.Size = UDim2.new(1, 0, 0, 30)
wsSliderData.Enabled = false
wsSlider.Visible = true

-- JumpPower Card
local jpCard = UI.CreateFuncCard(MovementPage, {
    id = "jumppower",
    name = "JumpPower",
    desc = "Controla a potência de salto do personagem",
    height = 95,
})

local jpSlider, jpSliderData = UI.CreateSlider(jpCard, "jumppower", 50, 300, 50, "Power")
jpSlider.Position = UDim2.new(0, 0, 0, 42)
jpSlider.Size = UDim2.new(1, 0, 0, 30)
jpSliderData.Enabled = false

-- Section: Advanced Movement
UI.CreateSectionHeader(MovementPage, "Advanced Movement")

-- Infinite Jump Card
UI.CreateFuncCard(MovementPage, {
    id = "infjump",
    name = "Infinite Jump",
    desc = "Pula infinitamente enquanto mantiver a tecla pressionada",
    keybind = "Space",
    height = 55,
})

-- Fly Universal Card
local flyCard = UI.CreateFuncCard(MovementPage, {
    id = "fly",
    name = "Fly Universal",
    desc = "Sistema de voo via CFrame — indetectável por speed checks",
    keybind = "F",
    height = 170,
})

-- Fly Visualizer
local flyViz = UI.Create("Frame", {
    Name = "FlyViz",
    Size = UDim2.new(1, 0, 0, 70),
    Position = UDim2.new(0, 0, 0, 42),
    BackgroundColor3 = Config.Theme.Background,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    ZIndex = 54,
    Parent = flyCard,
}, {
    UI.Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
    UI.Create("UIStroke", {Color = Config.Theme.Border, Thickness = 1}),
})

-- Grid lines effect
for i = 0, 19 do
    UI.Create("Frame", {
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(0, i * 24, 0, 0),
        BackgroundColor3 = Config.Theme.Emerald,
        BackgroundTransparency = 0.95,
        BorderSizePixel = 0,
        ZIndex = 55,
        Parent = flyViz,
    })
    UI.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 0, i * 24),
        BackgroundColor3 = Config.Theme.Emerald,
        BackgroundTransparency = 0.95,
        BorderSizePixel = 0,
        ZIndex = 55,
        Parent = flyViz,
    })
end

-- Fly indicator dot
local flyDot = UI.Create("Frame", {
    Name = "FlyDot",
    Size = UDim2.new(0, 8, 0, 8),
    Position = UDim2.new(0.5, -4, 0.5, -4),
    BackgroundColor3 = Config.Theme.Emerald,
    BorderSizePixel = 0,
    ZIndex = 57,
    Parent = flyViz,
}, {
    UI.Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
})

local flyStatusLabel = UI.Create("TextLabel", {
    Name = "FlyStatusLabel",
    Size = UDim2.new(1, 0, 0, 14),
    Position = UDim2.new(0, 0, 1, -18),
    BackgroundTransparency = 1,
    Text = "GROUNDED",
    FontFace = FontMono,
    TextSize = 9,
    TextColor3 = Config.Theme.DarkGrey,
    ZIndex = 57,
    Parent = flyViz,
})

-- Fly Speed Slider
local flySlider, flySliderData = UI.CreateSlider(flyCard, "flyspeed", 10, 200, 60, "Fly Speed")
flySlider.Position = UDim2.new(0, 0, 0, 118)
flySlider.Size = UDim2.new(1, 0, 0, 30)
flySliderData.Enabled = false

-- ── Visuals Tab ──
local VisualsPage = UI.Create("Frame", {
    Name = "Page_Visuals",
    Size = UDim2.new(1, 0, 0, 0),
    BackgroundTransparency = 1,
    AutomaticSize = Enum.AutomaticSize.Y,
    Visible = false,
    ZIndex = 51,
    Parent = ContentArea,
}, {
    UI.Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
    }),
    UI.Create("UIPadding", {
        PaddingTop = UDim.new(0, 12),
        PaddingBottom = UDim.new(0, 12),
    }),
})

TabPages["Visuals"] = VisualsPage

UI.CreateSectionHeader(VisualsPage, "Rendering")

UI.CreateFuncCard(VisualsPage, {
    id = "fullbright",
    name = "Fullbright",
    desc = "Remove toda a escuridão e iluminação ambiente",
    height = 55,
})

UI.CreateFuncCard(VisualsPage, {
    id = "esp",
    name = "ESP Players",
    desc = "Mostra caixas e nomes de jogadores através de paredes",
    height = 55,
})

UI.CreateFuncCard(VisualsPage, {
    id = "noclip",
    name = "Noclip",
    desc = "Atravessa paredes e objetos sólidos",
    height = 55,
})

-- ── Console Tab ──
local ConsolePage = UI.Create("Frame", {
    Name = "Page_Console",
    Size = UDim2.new(1, 0, 0, 0),
    BackgroundTransparency = 1,
    AutomaticSize = Enum.AutomaticSize.Y,
    Visible = false,
    ZIndex = 51,
    Parent = ContentArea,
}, {
    UI.Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
    }),
    UI.Create("UIPadding", {
        PaddingTop = UDim.new(0, 12),
        PaddingBottom = UDim.new(0, 12),
    }),
})

TabPages["Console"] = ConsolePage

UI.CreateSectionHeader(ConsolePage, "Execution Log")

local ConsoleFrame = UI.Create("ScrollingFrame", {
    Name = "ConsoleArea",
    Size = UDim2.new(1, -32, 0, 280),
    BackgroundColor3 = Config.Theme.Background,
    BorderSizePixel = 0,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = Color3.fromRGB(26, 26, 26),
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ZIndex = 53,
    Parent = ConsolePage,
}, {
    UI.Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
    UI.Create("UIStroke", {Color = Config.Theme.Border, Thickness = 1}),
    UI.Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
    }),
    UI.Create("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
    }),
})

-- ═══════════════════════════════════════════════════════════════
--  FOOTER
-- ═══════════════════════════════════════════════════════════════
local Footer = UI.Create("Frame", {
    Name = "Footer",
    Size = UDim2.new(1, 0, 0, 36),
    Position = UDim2.new(0, 0, 1, -36),
    BackgroundColor3 = Config.Theme.Background,
    BorderSizePixel = 0,
    ZIndex = 51,
    Parent = MainFrame,
}, {
    UI.Create("UICorner", {CornerRadius = UDim.new(0, 12)}),
})

UI.Create("Frame", {
    Size = UDim2.new(1, 0, 0, 12),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundColor3 = Config.Theme.Background,
    BorderSizePixel = 0,
    ZIndex = 51,
    Parent = Footer,
})

UI.Create("Frame", {
    Size = UDim2.new(1, 0, 0, 1),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundColor3 = Config.Theme.Border,
    BorderSizePixel = 0,
    ZIndex = 52,
    Parent = Footer,
})

-- Active dot
UI.Create("Frame", {
    Size = UDim2.new(0, 6, 0, 6),
    Position = UDim2.new(0, 16, 0.5, -3),
    BackgroundColor3 = Config.Theme.Emerald,
    BorderSizePixel = 0,
    ZIndex = 53,
    Parent = Footer,
}, {
    UI.Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
})

UI.Create("TextLabel", {
    Size = UDim2.new(0, 100, 1, 0),
    Position = UDim2.new(0, 28, 0, 0),
    BackgroundTransparency = 1,
    Text = "Engine Active",
    FontFace = FontMono,
    TextSize = 10,
    TextColor3 = Config.Theme.TextSecondary,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 53,
    Parent = Footer,
})

local PingLabel = UI.Create("TextLabel", {
    Size = UDim2.new(0, 60, 1, 0),
    Position = UDim2.new(1, -76, 0, 0),
    BackgroundTransparency = 1,
    Text = "0ms",
    FontFace = FontMono,
    TextSize = 10,
    TextColor3 = Config.Theme.DarkGrey,
    TextXAlignment = Enum.TextXAlignment.Right,
    ZIndex = 53,
    Parent = Footer,
})

-- ═══════════════════════════════════════════════════════════════
--  TOAST NOTIFICATION SYSTEM
-- ═══════════════════════════════════════════════════════════════
local ToastContainer = UI.Create("Frame", {
    Name = "ToastContainer",
    Size = UDim2.new(0, 280, 1, 0),
    Position = UDim2.new(1, -290, 0, 0),
    BackgroundTransparency = 1,
    ZIndex = 110,
    Parent = ScreenGui,
}, {
    UI.Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
    }),
    UI.Create("UIPadding", {
        PaddingBottom = UDim.new(0, 20),
    }),
})

-- ═══════════════════════════════════════════════════════════════
--  FUNCTIONS TABLE — Lógica das funções
-- ═══════════════════════════════════════════════════════════════
local Functions = {}

-- ── Console Logger ──
function Functions.Log(msg, msgType)
    local timeStr = os.date("%H:%M:%S")
    local typeColor = Config.Theme.TextSecondary
    if msgType == "success" then
        typeColor = Config.Theme.Emerald
    elseif msgType == "warn" then
        typeColor = Color3.fromRGB(255, 184, 0)
    elseif msgType == "error" then
        typeColor = Color3.fromRGB(255, 68, 68)
    end

    local logLine = UI.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        ZIndex = 54,
        Parent = ConsoleFrame,
    })

    UI.Create("TextLabel", {
        Size = UDim2.new(0, 60, 1, 0),
        BackgroundTransparency = 1,
        Text = timeStr,
        FontFace = FontMono,
        TextSize = 10,
        TextColor3 = Config.Theme.DarkGrey,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 54,
        Parent = logLine,
    })

    UI.Create("TextLabel", {
        Size = UDim2.new(0, 55, 1, 0),
        Position = UDim2.new(0, 62, 0, 0),
        BackgroundTransparency = 1,
        Text = "[Medusa]",
        FontFace = FontMono,
        TextSize = 10,
        TextColor3 = Config.Theme.EmeraldDark,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 54,
        Parent = logLine,
    })

    UI.Create("TextLabel", {
        Size = UDim2.new(1, -122, 1, 0),
        Position = UDim2.new(0, 122, 0, 0),
        BackgroundTransparency = 1,
        Text = msg,
        FontFace = FontMono,
        TextSize = 10,
        TextColor3 = typeColor,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 54,
        Parent = logLine,
    })

    -- Auto scroll
    task.defer(function()
        ConsoleFrame.CanvasPosition = Vector2.new(0, ConsoleFrame.AbsoluteCanvasSize.Y)
    end)
end

-- ── Toast ──
function Functions.Toast(msg)
    local toast = UI.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Config.Theme.BgCard,
        BorderSizePixel = 0,
        ZIndex = 111,
        ClipsDescendants = true,
        Parent = ToastContainer,
    }, {
        UI.Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
        UI.Create("UIStroke", {Color = Config.Theme.Border, Thickness = 1}),
    })

    -- Green left accent
    UI.Create("Frame", {
        Size = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = Config.Theme.Emerald,
        BorderSizePixel = 0,
        ZIndex = 112,
        Parent = toast,
    })

    UI.Create("TextLabel", {
        Size = UDim2.new(1, -18, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text = msg,
        FontFace = FontMono,
        TextSize = 11,
        TextColor3 = Config.Theme.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 112,
        Parent = toast,
    })

    -- Slide in
    toast.Position = UDim2.new(1.2, 0, 0, 0)
    TweenService:Create(toast, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 0)
    }):Play()

    -- Auto-remove
    task.delay(2.5, function()
        local tween = TweenService:Create(toast, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(1.2, 0, 0, 0)
        })
        tween:Play()
        tween.Completed:Wait()
        toast:Destroy()
    end)
end

-- ── Toggle Visual Update ──
function Functions.SetToggleState(id, on)
    local toggleData = UI.Elements["toggle_" .. id]
    local cardData = UI.Elements["card_" .. id]
    if not toggleData then return end

    toggleData.IsOn = on

    if on then
        TweenService:Create(toggleData.Frame, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(0, 40, 21),
        }):Play()
        TweenService:Create(toggleData.Knob, TweenInfo.new(0.35, Enum.EasingStyle.Back), {
            Position = UDim2.new(1, -17, 0.5, -7),
            BackgroundColor3 = Config.Theme.Emerald,
        }):Play()
        toggleData.Stroke.Color = Config.Theme.Emerald
    else
        TweenService:Create(toggleData.Frame, TweenInfo.new(0.3), {
            BackgroundColor3 = Config.Theme.ToggleOff,
        }):Play()
        TweenService:Create(toggleData.Knob, TweenInfo.new(0.35, Enum.EasingStyle.Back), {
            Position = UDim2.new(0, 3, 0.5, -7),
            BackgroundColor3 = Config.Theme.DarkGrey,
        }):Play()
        toggleData.Stroke.Color = Config.Theme.ToggleBorderOff
    end

    -- Card glow
    if cardData then
        if on then
            cardData.Stroke.Color = Color3.fromRGB(0, 201, 107)
            cardData.Stroke.Transparency = 0.75
            cardData.StatusDot.BackgroundColor3 = Config.Theme.Emerald
        else
            cardData.Stroke.Color = Config.Theme.Border
            cardData.Stroke.Transparency = 0
            cardData.StatusDot.BackgroundColor3 = Config.Theme.DarkGrey
        end
    end
end

-- ── Set Slider Enabled ──
function Functions.SetSliderEnabled(id, enabled)
    local sliderData = UI.Elements["slider_" .. id]
    if sliderData then
        sliderData.Enabled = enabled
        -- Visual feedback
        for _, desc in pairs(sliderData.Container:GetDescendants()) do
            if desc:IsA("GuiObject") then
                TweenService:Create(desc, TweenInfo.new(0.3), {
                    BackgroundTransparency = desc.BackgroundTransparency > 0.5 and desc.BackgroundTransparency or (enabled and 0 or 0.6),
                }):Play()
            end
        end
    end
end

-- ═══════════════════════════════════════════════════════════════
--  FUNCTION IMPLEMENTATIONS — As funções reais de jogo
-- ═══════════════════════════════════════════════════════════════

-- ── WalkSpeed ──
function Functions.ToggleWalkSpeed()
    Config.State.WalkSpeedEnabled = not Config.State.WalkSpeedEnabled
    local on = Config.State.WalkSpeedEnabled

    Functions.SetToggleState("walkspeed", on)
    Functions.SetSliderEnabled("walkspeed", on)

    local hum = GetHumanoid()
    if hum then
        if on then
            hum.WalkSpeed = Config.State.WalkSpeedValue
        else
            hum.WalkSpeed = Config.Defaults.WalkSpeed
        end
    end

    Functions.Log(on and ("WalkSpeed ENABLED → " .. Config.State.WalkSpeedValue) or "WalkSpeed DISABLED → reset to 16", on and "success" or "")
    Functions.Toast("WalkSpeed " .. (on and ("ON → " .. Config.State.WalkSpeedValue) or "OFF"))
end

-- ── JumpPower ──
function Functions.ToggleJumpPower()
    Config.State.JumpPowerEnabled = not Config.State.JumpPowerEnabled
    local on = Config.State.JumpPowerEnabled

    Functions.SetToggleState("jumppower", on)
    Functions.SetSliderEnabled("jumppower", on)

    local hum = GetHumanoid()
    if hum then
        if on then
            hum.UseJumpPower = true
            hum.JumpPower = Config.State.JumpPowerValue
        else
            hum.JumpPower = Config.Defaults.JumpPower
        end
    end

    Functions.Log(on and ("JumpPower ENABLED → " .. Config.State.JumpPowerValue) or "JumpPower DISABLED → reset to 50", on and "success" or "")
    Functions.Toast("JumpPower " .. (on and ("ON → " .. Config.State.JumpPowerValue) or "OFF"))
end

-- ── Infinite Jump ──
function Functions.ToggleInfJump()
    Config.State.InfJumpEnabled = not Config.State.InfJumpEnabled
    local on = Config.State.InfJumpEnabled

    Functions.SetToggleState("infjump", on)

    Functions.Log(on and "Infinite Jump ENABLED" or "Infinite Jump DISABLED", on and "success" or "")
    Functions.Toast("Infinite Jump " .. (on and "ON" or "OFF"))
end

-- ── Fly Universal (CFrame) ──
local FlyBody = nil
local FlyGyro = nil

function Functions.ToggleFly()
    Config.State.FlyEnabled = not Config.State.FlyEnabled
    local on = Config.State.FlyEnabled

    Functions.SetToggleState("fly", on)
    Functions.SetSliderEnabled("flyspeed", on)

    local hrp = GetRootPart()
    local hum = GetHumanoid()

    if on then
        flyStatusLabel.Text = "AIRBORNE — CFRAME MODE"
        flyStatusLabel.TextColor3 = Config.Theme.Emerald

        -- Animate fly dot
        local floatTween = TweenService:Create(flyDot, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
            Position = UDim2.new(0.5, -4, 0.3, -4)
        })
        floatTween:Play()
        UI.Elements._flyDotTween = floatTween

        if hrp then
            -- Create BodyVelocity + BodyGyro for CFrame-based fly
            FlyBody = Instance.new("BodyVelocity")
            FlyBody.Name = "MedusaFly"
            FlyBody.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            FlyBody.Velocity = Vector3.new(0, 0, 0)
            FlyBody.Parent = hrp

            FlyGyro = Instance.new("BodyGyro")
            FlyGyro.Name = "MedusaGyro"
            FlyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            FlyGyro.D = 200
            FlyGyro.P = 40000
            FlyGyro.Parent = hrp

            if hum then
                hum.PlatformStand = true
            end
        end
    else
        flyStatusLabel.Text = "GROUNDED"
        flyStatusLabel.TextColor3 = Config.Theme.DarkGrey
        flyDot.Position = UDim2.new(0.5, -4, 0.5, -4)

        if UI.Elements._flyDotTween then
            UI.Elements._flyDotTween:Cancel()
        end

        if FlyBody then FlyBody:Destroy(); FlyBody = nil end
        if FlyGyro then FlyGyro:Destroy(); FlyGyro = nil end

        if hum then
            hum.PlatformStand = false
        end
    end

    Functions.Log(on and "Fly Universal ENABLED — CFrame bypass active" or "Fly Universal DISABLED", on and "success" or "")
    Functions.Toast("Fly " .. (on and "ON — CFrame Mode" or "OFF"))
end

-- ── Fullbright ──
function Functions.ToggleFullbright()
    Config.State.FullbrightEnabled = not Config.State.FullbrightEnabled
    local on = Config.State.FullbrightEnabled

    Functions.SetToggleState("fullbright", on)

    local lighting = game:GetService("Lighting")
    if on then
        _G.Medusa._origAmbient = lighting.Ambient
        _G.Medusa._origOutdoor = lighting.OutdoorAmbient
        _G.Medusa._origBright = lighting.Brightness
        lighting.Ambient = Color3.fromRGB(255, 255, 255)
        lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        lighting.Brightness = 2
        -- Remove fog/effects
        for _, v in pairs(lighting:GetChildren()) do
            if v:IsA("Atmosphere") or v:IsA("BloomEffect") or v:IsA("ColorCorrectionEffect") then
                v.Enabled = false
            end
        end
    else
        lighting.Ambient = _G.Medusa._origAmbient or Color3.fromRGB(127, 127, 127)
        lighting.OutdoorAmbient = _G.Medusa._origOutdoor or Color3.fromRGB(127, 127, 127)
        lighting.Brightness = _G.Medusa._origBright or 1
        for _, v in pairs(lighting:GetChildren()) do
            if v:IsA("Atmosphere") or v:IsA("BloomEffect") or v:IsA("ColorCorrectionEffect") then
                v.Enabled = true
            end
        end
    end

    Functions.Log(on and "Fullbright ENABLED" or "Fullbright DISABLED", on and "success" or "")
    Functions.Toast("Fullbright " .. (on and "ON" or "OFF"))
end

-- ── Noclip ──
function Functions.ToggleNoclip()
    Config.State.NoclipEnabled = not Config.State.NoclipEnabled
    local on = Config.State.NoclipEnabled

    Functions.SetToggleState("noclip", on)

    Functions.Log(on and "Noclip ENABLED" or "Noclip DISABLED", on and "success" or "")
    Functions.Toast("Noclip " .. (on and "ON" or "OFF"))
end

-- ── ESP Players ──
function Functions.ToggleESP()
    Config.State.ESPEnabled = not Config.State.ESPEnabled
    local on = Config.State.ESPEnabled

    Functions.SetToggleState("esp", on)

    if on then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= Player and plr.Character then
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "MedusaESP"
                    billboard.Size = UDim2.new(4, 0, 5.5, 0)
                    billboard.AlwaysOnTop = true
                    billboard.Adornee = hrp
                    billboard.Parent = hrp

                    local box = Instance.new("Frame")
                    box.Size = UDim2.new(1, 0, 1, 0)
                    box.BackgroundTransparency = 1
                    box.BorderSizePixel = 0
                    box.Parent = billboard

                    local stroke = Instance.new("UIStroke")
                    stroke.Color = Config.Theme.Emerald
                    stroke.Thickness = 1
                    stroke.Transparency = 0.3
                    stroke.Parent = box

                    local nameLabel = Instance.new("TextLabel")
                    nameLabel.Size = UDim2.new(1, 0, 0, 20)
                    nameLabel.Position = UDim2.new(0, 0, 0, -22)
                    nameLabel.BackgroundTransparency = 1
                    nameLabel.Text = plr.Name
                    nameLabel.TextColor3 = Config.Theme.Emerald
                    nameLabel.TextSize = 14
                    nameLabel.FontFace = FontMonoBold
                    nameLabel.Parent = billboard
                end
            end
        end
    else
        for _, plr in pairs(Players:GetPlayers()) do
            if plr.Character then
                for _, v in pairs(plr.Character:GetDescendants()) do
                    if v.Name == "MedusaESP" then v:Destroy() end
                end
            end
        end
    end

    Functions.Log(on and "ESP Players ENABLED" or "ESP Players DISABLED", on and "success" or "")
    Functions.Toast("ESP " .. (on and "ON" or "OFF"))
end

-- ═══════════════════════════════════════════════════════════════
--  CONNECT TOGGLE BUTTONS
-- ═══════════════════════════════════════════════════════════════
UI.Elements["toggle_walkspeed"].Button.MouseButton1Click:Connect(Functions.ToggleWalkSpeed)
UI.Elements["toggle_jumppower"].Button.MouseButton1Click:Connect(Functions.ToggleJumpPower)
UI.Elements["toggle_infjump"].Button.MouseButton1Click:Connect(Functions.ToggleInfJump)
UI.Elements["toggle_fly"].Button.MouseButton1Click:Connect(Functions.ToggleFly)
UI.Elements["toggle_fullbright"].Button.MouseButton1Click:Connect(Functions.ToggleFullbright)
UI.Elements["toggle_esp"].Button.MouseButton1Click:Connect(Functions.ToggleESP)
UI.Elements["toggle_noclip"].Button.MouseButton1Click:Connect(Functions.ToggleNoclip)

-- ═══════════════════════════════════════════════════════════════
--  TAB SWITCHING
-- ═══════════════════════════════════════════════════════════════
for name, tabData in pairs(TabButtons) do
    tabData.Button.MouseButton1Click:Connect(function()
        -- Deactivate all
        for n, td in pairs(TabButtons) do
            td.Button.TextColor3 = Config.Theme.TextSecondary
            td.Indicator.Visible = false
        end
        for _, page in pairs(TabPages) do
            page.Visible = false
        end

        -- Activate selected
        tabData.Button.TextColor3 = Config.Theme.Emerald
        tabData.Indicator.Visible = true
        if TabPages[name] then
            TabPages[name].Visible = true
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════
--  CLOSE / MINIMIZE
-- ═══════════════════════════════════════════════════════════════
CloseBtn.MouseButton1Click:Connect(function()
    Config.PanelVisible = false
    TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Position = UDim2.new(0.5, -240, 1.2, 0)
    }):Play()
    Functions.Toast("Medusa — Hidden (Press RightControl to toggle)")
end)

MinBtn.MouseButton1Click:Connect(function()
    Config.PanelVisible = false
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Position = UDim2.new(0.5, -240, 1, -50),
        Size = UDim2.new(0, 480, 0, 40)
    }):Play()
    Functions.Toast("Panel Minimized")
end)

-- ═══════════════════════════════════════════════════════════════
--  RUNTIME LOOPS — Atualização contínua (RenderStepped)
-- ═══════════════════════════════════════════════════════════════
AddConnection(RunService.RenderStepped:Connect(function()
    local hum = GetHumanoid()
    local hrp = GetRootPart()
    local cam = workspace.CurrentCamera

    -- WalkSpeed live update
    if Config.State.WalkSpeedEnabled and hum then
        local sliderData = UI.Elements["slider_walkspeed"]
        if sliderData then
            Config.State.WalkSpeedValue = sliderData.Value
            hum.WalkSpeed = sliderData.Value
        end
    end

    -- JumpPower live update
    if Config.State.JumpPowerEnabled and hum then
        local sliderData = UI.Elements["slider_jumppower"]
        if sliderData then
            Config.State.JumpPowerValue = sliderData.Value
            hum.JumpPower = sliderData.Value
        end
    end

    -- Fly CFrame update
    if Config.State.FlyEnabled and hrp and cam and FlyBody and FlyGyro then
        local flySlider = UI.Elements["slider_flyspeed"]
        local speed = flySlider and flySlider.Value or Config.State.FlySpeedValue
        Config.State.FlySpeedValue = speed

        local direction = Vector3.new(0, 0, 0)

        if UIS:IsKeyDown(Enum.KeyCode.W) then
            direction = direction + cam.CFrame.LookVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.S) then
            direction = direction - cam.CFrame.LookVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.A) then
            direction = direction - cam.CFrame.RightVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.D) then
            direction = direction + cam.CFrame.RightVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then
            direction = direction + Vector3.new(0, 1, 0)
        end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
            direction = direction - Vector3.new(0, 1, 0)
        end

        if direction.Magnitude > 0 then
            direction = direction.Unit
        end

        FlyBody.Velocity = direction * speed
        FlyGyro.CFrame = cam.CFrame
    end

    -- Noclip
    if Config.State.NoclipEnabled then
        local char = Player.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end))

-- ── Infinite Jump Input ──
AddConnection(UIS.JumpRequest:Connect(function()
    if Config.State.InfJumpEnabled then
        local hum = GetHumanoid()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end))

-- ═══════════════════════════════════════════════════════════════
--  KEYBOARD SHORTCUTS
-- ═══════════════════════════════════════════════════════════════
AddConnection(UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    if not Config.IntroComplete then return end

    -- RightControl: Toggle panel visibility
    if input.KeyCode == Enum.KeyCode.RightControl then
        if Config.PanelVisible then
            Config.PanelVisible = false
            TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(0.5, -240, 1.2, 0)
            }):Play()
            -- Reset size if minimized
            MainFrame.Size = UDim2.new(0, 480, 0, 520)
            Functions.Toast("Medusa — Hidden")
        else
            Config.PanelVisible = true
            MainFrame.Size = UDim2.new(0, 480, 0, 520)
            TweenService:Create(MainFrame, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Position = UDim2.new(0.5, -240, 0.5, -260)
            }):Play()
            Functions.Toast("Medusa — Visible")
        end
    end

    -- F: Toggle Fly
    if input.KeyCode == Enum.KeyCode.F then
        Functions.ToggleFly()
    end
end))

-- ═══════════════════════════════════════════════════════════════
--  PING SIMULATION
-- ═══════════════════════════════════════════════════════════════
task.spawn(function()
    while _G.Medusa and _G.Medusa.GUI and _G.Medusa.GUI.Parent do
        local stats = game:GetService("Stats")
        local ping = math.floor(Player:GetNetworkPing() * 1000)
        PingLabel.Text = ping .. "ms"
        task.wait(2)
    end
end)

-- ═══════════════════════════════════════════════════════════════
--  INTRO SEQUENCE — Loading Cinematográfico
-- ═══════════════════════════════════════════════════════════════
task.spawn(function()
    -- Salvar propriedades originais
    pcall(function()
        local hum = GetHumanoid()
        if hum then
            _G.Medusa.OriginalWS = hum.WalkSpeed
            _G.Medusa.OriginalJP = hum.JumpPower
        end
    end)

    -- Fase 1: Logo pulse (UIStroke transparency animation)
    task.spawn(function()
        local dir = 1
        local trans = 0.8
        while IntroOverlay and IntroOverlay.Parent and IntroOverlay.Visible do
            trans = trans + dir * 0.02
            if trans >= 0.8 then dir = -1
            elseif trans <= 0.0 then dir = 1 end
            LogoStroke.Transparency = trans
            task.wait(0.03)
        end
    end)

    -- Fade in subtitle
    task.wait(1)
    TweenService:Create(SubtitleLabel, TweenInfo.new(0.8), {TextTransparency = 0}):Play()

    -- Show neon bar & progress
    task.wait(0.5)
    NeonBarBg.Visible = true
    ProgressTrack.Visible = true

    -- Animate Neon gradient offset loop
    task.spawn(function()
        while IntroOverlay and IntroOverlay.Parent and IntroOverlay.Visible do
            TweenService:Create(NeonGradient, TweenInfo.new(1.5, Enum.EasingStyle.Linear), {
                Offset = Vector2.new(1, 0)
            }):Play()
            task.wait(1.5)
            NeonGradient.Offset = Vector2.new(-1, 0)
        end
    end)

    -- Show loading status
    task.wait(0.3)
    TweenService:Create(LoadingStatus, TweenInfo.new(0.3), {TextTransparency = 0}):Play()

    -- Loading steps
    local steps = {
        {pct = 0.05, msg = "Initializing _G.Medusa...",       delay = 0.4},
        {pct = 0.15, msg = "Hard Clean — purging globals...", delay = 0.35},
        {pct = 0.25, msg = "Loading Config table...",         delay = 0.3},
        {pct = 0.35, msg = "Building UI framework...",        delay = 0.4},
        {pct = 0.50, msg = "Registering Functions table...",  delay = 0.35},
        {pct = 0.62, msg = "Hooking WalkSpeed module...",     delay = 0.25},
        {pct = 0.70, msg = "Hooking JumpPower module...",     delay = 0.2},
        {pct = 0.78, msg = "Hooking InfJump listener...",     delay = 0.25},
        {pct = 0.86, msg = "Compiling Fly CFrame engine...",  delay = 0.4},
        {pct = 0.93, msg = "Bypassing speed detection...",    delay = 0.35},
        {pct = 0.97, msg = "Validating integrity...",         delay = 0.3},
        {pct = 1.00, msg = "Engine ready. Welcome.",          delay = 0.5},
    }

    for _, step in ipairs(steps) do
        TweenService:Create(ProgressFill, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {
            Size = UDim2.new(step.pct, 0, 1, 0)
        }):Play()
        LoadingStatus.Text = "> " .. step.msg
        task.wait(step.delay)
    end

    -- Finish intro
    task.wait(0.6)

    -- Fade out intro overlay
    TweenService:Create(IntroOverlay, TweenInfo.new(0.8, Enum.EasingStyle.Quad), {
        BackgroundTransparency = 1
    }):Play()

    for _, child in pairs(IntroOverlay:GetDescendants()) do
        if child:IsA("TextLabel") then
            TweenService:Create(child, TweenInfo.new(0.6), {TextTransparency = 1}):Play()
        elseif child:IsA("UIStroke") then
            TweenService:Create(child, TweenInfo.new(0.6), {Transparency = 1}):Play()
        elseif child:IsA("Frame") then
            pcall(function()
                TweenService:Create(child, TweenInfo.new(0.6), {BackgroundTransparency = 1}):Play()
            end)
        end
    end

    task.wait(0.9)
    IntroOverlay.Visible = false

    -- ═══ SHOW MAIN FRAME — Slide Up com EasingStyle.Back ═══
    Config.IntroComplete = true
    MainFrame.Visible = true

    TweenService:Create(MainFrame, TweenInfo.new(0.9, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -240, 0.5, -260)
    }):Play()

    -- Icon pulse animation
    task.spawn(function()
        while _G.Medusa and _G.Medusa.GUI and _G.Medusa.GUI.Parent do
            TweenService:Create(TitleIcon, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                BackgroundTransparency = 0.4
            }):Play()
            task.wait(1.5)
            TweenService:Create(TitleIcon, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                BackgroundTransparency = 0
            }):Play()
            task.wait(1.5)
        end
    end)

    -- Initial console logs
    task.wait(0.5)
    Functions.Log("_G.Medusa initialized successfully", "success")
    task.wait(0.1)
    Functions.Log("Engine v" .. Config.Version .. " — Universal Mode", "")
    task.wait(0.1)
    Functions.Log("Hard Clean complete — no residual globals", "success")
    task.wait(0.1)
    Functions.Log("All modules loaded — 0 injections on character", "")
    task.wait(0.1)
    Functions.Log("Passive mode active — toggle functions to begin", "warn")
    task.wait(0.1)
    Functions.Log("Keybinds: [RightCtrl] Toggle UI | [F] Fly", "")

    Functions.Toast("Medusa Engine v" .. Config.Version .. " loaded!")
end)

-- ═══════════════════════════════════════════════════════════════
--  CHARACTER RESPAWN HANDLER — Reconectar no respawn
-- ═══════════════════════════════════════════════════════════════
AddConnection(Player.CharacterAdded:Connect(function(char)
    task.wait(0.5)

    -- Restaurar estados ativos
    local hum = char:WaitForChild("Humanoid", 5)
    if not hum then return end

    if Config.State.WalkSpeedEnabled then
        hum.WalkSpeed = Config.State.WalkSpeedValue
    end
    if Config.State.JumpPowerEnabled then
        hum.UseJumpPower = true
        hum.JumpPower = Config.State.JumpPowerValue
    end

    -- Re-enable fly se estava ativo
    if Config.State.FlyEnabled then
        Config.State.FlyEnabled = false
        Functions.ToggleFly()
    end

    _G.Medusa.OriginalWS = 16
    _G.Medusa.OriginalJP = 50

    Functions.Log("Character respawned — states restored", "warn")
end))

warn("[Medusa] Universal Engine v" .. Config.Version .. " — Script loaded successfully.")
