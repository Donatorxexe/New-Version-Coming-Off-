-- MEDUSA v16.0 | Ficheiro Unico (Logica + UI)
-- Se tinhas medusa_v16_ui.lua separado, apaga-o. Este ficheiro contem tudo.
-- Uso: loadstring(readfile("medusa_v16.lua"))()

if _G.MedusaLoaded then
	if _G.MedusaEject then pcall(_G.MedusaEject) end
	task.wait(0.5)
end

pcall(function()
	local coreGui = game:GetService("CoreGui")
	for _, gui in pairs(coreGui:GetChildren()) do
		if gui:IsA("ScreenGui") then
			local n = gui.Name:lower()
			if n:find("medusa") or n:find("medusaui") or n:find("medusav16") then
				gui:Destroy()
			end
		end
	end
end)
pcall(function()
	local playerGui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
	if playerGui then
		for _, gui in pairs(playerGui:GetChildren()) do
			if gui:IsA("ScreenGui") then
				local n = gui.Name:lower()
				if n:find("medusa") or n:find("medusaui") or n:find("medusav16") then
					gui:Destroy()
				end
			end
		end
	end
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

_G.MedusaLoaded = true

_G.MedusaConfig = {
	Aimbot_Enabled = false,
	Aimbot_TeamCheck = true,
	Aimbot_ShowFOV = false,
	Aimbot_FOVRadius = 180,
	Aimbot_Smoothing = 50,
	Aimbot_AimPart = "HumanoidRootPart",
	ESP_Enabled = false,
	ESP_Boxes = true,
	ESP_Names = true,
	ESP_Health = true,
	ESP_Distance = true,
	ESP_MaxDistance = 1500,
	ESP_TeamCheck = true,
	ESP_Color = Color3.fromRGB(0, 201, 107),
	Speed_Enabled = false,
	WalkSpeed = 16,
	JumpPower = 50,
	InfJump_Enabled = false,
	Noclip_Enabled = false,
	Fly_Enabled = false,
	Fly_Speed = 80,
	SilentAim_Enabled = false,
	SilentAim_Hitchance = 100,
	SilentAim_AimPart = "HumanoidRootPart",
	NoRecoil_Enabled = false,
	NoSpread_Enabled = false,
	AntiAFK_Enabled = false,
	ESP_Skeleton = false,
	Prediction_Enabled = false,
	TriggerBot_Enabled = false,
	HitSound_Enabled = false,
	ESP_Tracers = false,
	ESP_ViewAngles = false,
	FullBright_Enabled = false,
	SpinBot_Enabled = false,
	SpinBot_Speed = 20,
	TargetPredator_Enabled = false,
	KillPopups_Enabled = false,
	SpectatorList_Enabled = false,
	Exposure = 0,
	Contrast = 0,
	PPBypass_Enabled = false,
	CustomCrosshair_Enabled = false,
	CrosshairSize = 12,
	CrosshairColor = Color3.fromRGB(0, 201, 107),
	MetaBypass_Enabled = false,
	AutoStomp_Enabled = false,
	AutoStomp_Range = 15,
	TimeOfDay = 14,
	FogStart_Val = 0,
	FogEnd_Val = 100000,
	RainbowUI_Enabled = false,
	InstantReload_Enabled = false,
	BulletTracers_Enabled = false,
	VelocityBypass_Enabled = false,
	AmbientR = 127, AmbientG = 127, AmbientB = 127,
	OutdoorR = 127, OutdoorG = 127, OutdoorB = 127,
	CC_Saturation = 0, CC_Brightness = 0,
	ClockSpeed = 1,
	AccentR = 0, AccentG = 201, AccentB = 107,
	MenuTransparency = 15,
	HeadSize_Enabled = false, HeadSize = 1,
	Breadcrumbs_Enabled = false,
	UISounds_Enabled = true,
	UISounds_Volume = 0.5,
	KillStreak_Enabled = false,
	FootstepSpam_Enabled = false,
	Vignette_Enabled = false,
	Grain_Enabled = false,
	HealthText_ESP = false,
	OffscreenArrows_Enabled = false,
	NameSpoof_Enabled = false,
	Intro_Enabled = true,
	RGBGlow_Enabled = false,
}
local Config = _G.MedusaConfig

_G.MedusaSignals = {}

local function RegisterSignal(name, connection)
	if _G.MedusaSignals[name] then
		pcall(function() _G.MedusaSignals[name]:Disconnect() end)
	end
	_G.MedusaSignals[name] = connection
end

local function DisconnectAllSignals()
	for name, conn in pairs(_G.MedusaSignals) do
		pcall(function() conn:Disconnect() end)
		_G.MedusaSignals[name] = nil
	end
end

local ESPObjects = {}
local FOVCircle = nil

local function CleanupAllDrawings()
	for plr, drawings in pairs(ESPObjects) do
		for _, obj in pairs(drawings) do
			pcall(function() obj:Remove() end)
		end
		ESPObjects[plr] = nil
	end
	if FOVCircle then
		pcall(function() FOVCircle:Remove() end)
		FOVCircle = nil
	end
end

local function GetCharacter()
	return LocalPlayer and LocalPlayer.Character
end

local function GetHumanoid()
	local char = GetCharacter()
	return char and char:FindFirstChildOfClass("Humanoid")
end

local function GetRootPart()
	local char = GetCharacter()
	return char and char:FindFirstChild("HumanoidRootPart")
end

local function IsAlive(player)
	if not player or not player.Character then return false end
	local hum = player.Character:FindFirstChildOfClass("Humanoid")
	return hum and hum.Health > 0
end

local function IsSameTeam(player)
	if not LocalPlayer.Team then return false end
	return player.Team == LocalPlayer.Team
end

local function CreateFOVCircle()
	if FOVCircle then return end
	FOVCircle = Drawing.new("Circle")
	FOVCircle.Color = Color3.fromRGB(130, 80, 255)
	FOVCircle.Thickness = 1.2
	FOVCircle.Filled = false
	FOVCircle.Transparency = 0.6
	FOVCircle.NumSides = 64
	FOVCircle.Visible = false
end

local function GetClosestPlayer()
	local target = nil
	local shortestDistance = Config.Aimbot_FOVRadius
	for _, player in ipairs(Players:GetPlayers()) do
		if player == LocalPlayer then continue end
		if not IsAlive(player) then continue end
		if Config.Aimbot_TeamCheck and IsSameTeam(player) then continue end
		local aimPart = player.Character:FindFirstChild(Config.Aimbot_AimPart) or player.Character:FindFirstChild("HumanoidRootPart")
		if not aimPart then continue end
		local screenPos, onScreen = Camera:WorldToViewportPoint(aimPart.Position)
		if not onScreen then continue end
		local mousePos = UserInputService:GetMouseLocation()
		local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
		if distance < shortestDistance then
			shortestDistance = distance
			target = player
		end
	end
	return target
end

local function StartAimbot()
	CreateFOVCircle()
	RegisterSignal("Aimbot_RenderStepped", RunService.RenderStepped:Connect(function()
		if not _G.MedusaLoaded then return end
		if FOVCircle then
			FOVCircle.Visible = Config.Aimbot_ShowFOV and Config.Aimbot_Enabled
			FOVCircle.Radius = Config.Aimbot_FOVRadius
			FOVCircle.Position = UserInputService:GetMouseLocation()
		end
		if not Config.Aimbot_Enabled then return end
		if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
		local target = GetClosestPlayer()
		if not target then return end
		local aimPart = target.Character:FindFirstChild(Config.Aimbot_AimPart) or target.Character:FindFirstChild("HumanoidRootPart")
		if not aimPart then return end
		local screenPos, onScreen = Camera:WorldToViewportPoint(aimPart.Position)
		if not onScreen then return end
		local mousePos = UserInputService:GetMouseLocation()
		local delta = Vector2.new(screenPos.X, screenPos.Y) - mousePos
		local smooth = Config.Aimbot_Smoothing / 100
		mousemoverel(delta.X * smooth, delta.Y * smooth)
	end))
end

local function StopAimbot()
	if _G.MedusaSignals["Aimbot_RenderStepped"] then
		_G.MedusaSignals["Aimbot_RenderStepped"]:Disconnect()
		_G.MedusaSignals["Aimbot_RenderStepped"] = nil
	end
	if FOVCircle then FOVCircle.Visible = false end
end

local oldNamecall = nil
local silentAimActive = false

local function StartSilentAim()
	if silentAimActive then return end
	silentAimActive = true
	if not oldNamecall then
		oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
			local method = getnamecallmethod()
			if not _G.MedusaLoaded or not Config.SilentAim_Enabled then
				return oldNamecall(self, ...)
			end
			if method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRay"
				or method == "FindPartOnRayWithWhitelist" or method == "Raycast" then
				if math.random(1, 100) <= Config.SilentAim_Hitchance then
					local target = GetClosestPlayer()
					if target and target.Character then
						local aimPart = target.Character:FindFirstChild(Config.SilentAim_AimPart)
							or target.Character:FindFirstChild("HumanoidRootPart")
						if aimPart then
							local aimPos = aimPart.Position
							if Config.Prediction_Enabled then
								local rv = target.Character:FindFirstChild("HumanoidRootPart")
								if rv then aimPos = aimPos + rv.AssemblyLinearVelocity * 0.12 end
							end
							local args = {...}
							if method == "Raycast" and typeof(args[1]) == "Vector3" then
								local origin = args[1]
								local dir = (aimPos - origin).Unit * 1000
								local params = args[2]
								return oldNamecall(self, origin, dir, params)
							elseif method == "FindPartOnRayWithIgnoreList" then
								local ray = args[1]
								if typeof(ray) == "Ray" then
									local newRay = Ray.new(ray.Origin, (aimPos - ray.Origin).Unit * 1000)
									args[1] = newRay
									return oldNamecall(self, unpack(args))
								end
							elseif method == "FindPartOnRay" then
								local ray = args[1]
								if typeof(ray) == "Ray" then
									local newRay = Ray.new(ray.Origin, (aimPos - ray.Origin).Unit * 1000)
									args[1] = newRay
									return oldNamecall(self, unpack(args))
								end
							elseif method == "FindPartOnRayWithWhitelist" then
								local ray = args[1]
								if typeof(ray) == "Ray" then
									local newRay = Ray.new(ray.Origin, (aimPos - ray.Origin).Unit * 1000)
									args[1] = newRay
									return oldNamecall(self, unpack(args))
								end
							end
						end
					end
				end
			end
			return oldNamecall(self, ...)
		end))
	end
end

local function StopSilentAim()
	silentAimActive = false
	Config.SilentAim_Enabled = false
end

local SKEL_JOINTS = {
	{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
	{"UpperTorso","LeftUpperArm"},{"UpperTorso","RightUpperArm"},
	{"LowerTorso","LeftUpperLeg"},{"LowerTorso","RightUpperLeg"},
	{"LeftUpperArm","LeftLowerArm"},{"RightUpperArm","RightLowerArm"},
	{"LeftUpperLeg","LeftLowerLeg"},{"RightUpperLeg","RightLowerLeg"},
}
local R6MAP = {UpperTorso="Torso",LowerTorso="Torso",LeftUpperArm="Left Arm",RightUpperArm="Right Arm",LeftUpperLeg="Left Leg",RightUpperLeg="Right Leg",LeftLowerArm="Left Arm",RightLowerArm="Right Arm",LeftLowerLeg="Left Leg",RightLowerLeg="Right Leg"}

local function CreateESPForPlayer(player)
	if player == LocalPlayer then return end
	if ESPObjects[player] then return end
	local drawings = {
		box = Drawing.new("Square"),
		nameTag = Drawing.new("Text"),
		healthBar = Drawing.new("Square"),
		healthFill = Drawing.new("Square"),
		distTag = Drawing.new("Text"),
	}
	drawings.box.Color = Config.ESP_Color
	drawings.box.Thickness = 1.2
	drawings.box.Filled = false
	drawings.box.Visible = false
	drawings.box.Transparency = 0.85
	drawings.nameTag.Color = Color3.new(1, 1, 1)
	drawings.nameTag.Size = 13
	drawings.nameTag.Center = true
	drawings.nameTag.Outline = true
	drawings.nameTag.OutlineColor = Color3.new(0, 0, 0)
	drawings.nameTag.Visible = false
	drawings.nameTag.Font = 2
	drawings.healthBar.Color = Color3.fromRGB(40, 40, 40)
	drawings.healthBar.Thickness = 1
	drawings.healthBar.Filled = true
	drawings.healthBar.Visible = false
	drawings.healthBar.Transparency = 0.7
	drawings.healthFill.Color = Color3.fromRGB(0, 255, 0)
	drawings.healthFill.Thickness = 0
	drawings.healthFill.Filled = true
	drawings.healthFill.Visible = false
	drawings.healthFill.Transparency = 0.85
	drawings.distTag.Color = Color3.fromRGB(200, 200, 200)
	drawings.distTag.Size = 12
	drawings.distTag.Center = true
	drawings.distTag.Outline = true
	drawings.distTag.OutlineColor = Color3.new(0, 0, 0)
	drawings.distTag.Visible = false
	drawings.distTag.Font = 2
	for i = 1, 10 do
		local sk = Drawing.new("Line")
		sk.Color = Config.ESP_Color
		sk.Thickness = 1.2
		sk.Visible = false
		sk.Transparency = 0.85
		drawings["sk"..i] = sk
	end
	local tr = Drawing.new("Line")
	tr.Color = Config.ESP_Color
	tr.Thickness = 1
	tr.Visible = false
	tr.Transparency = 0.7
	drawings.tracer = tr
	local va = Drawing.new("Line")
	va.Color = Color3.fromRGB(255, 200, 80)
	va.Thickness = 1.5
	va.Visible = false
	va.Transparency = 0.8
	drawings.viewAngle = va
	local ht = Drawing.new("Text")
	ht.Color = Color3.new(1, 1, 1)
	ht.Size = 11
	ht.Center = true
	ht.Outline = true
	ht.OutlineColor = Color3.new(0, 0, 0)
	ht.Visible = false
	ht.Font = 2
	drawings.healthText = ht
	ESPObjects[player] = drawings
end

local function RemoveESPForPlayer(player)
	if ESPObjects[player] then
		for _, obj in pairs(ESPObjects[player]) do
			pcall(function() obj:Remove() end)
		end
		ESPObjects[player] = nil
	end
end

local function UpdateESP()
	local myRoot = GetRootPart()
	for player, drawings in pairs(ESPObjects) do
		local shouldShow = Config.ESP_Enabled and player.Character and IsAlive(player) and player.Character:FindFirstChild("HumanoidRootPart")
		if shouldShow and Config.ESP_TeamCheck and IsSameTeam(player) then
			shouldShow = false
		end
		if not shouldShow then
			for _, obj in pairs(drawings) do obj.Visible = false end
			continue
		end
		local hrp = player.Character.HumanoidRootPart
		local hum = player.Character:FindFirstChildOfClass("Humanoid")
		local distance = myRoot and (myRoot.Position - hrp.Position).Magnitude or 0
		if distance > Config.ESP_MaxDistance then
			for _, obj in pairs(drawings) do obj.Visible = false end
			continue
		end
		local rootPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
		if not onScreen then
			for _, obj in pairs(drawings) do obj.Visible = false end
			continue
		end
		local scaleFactor = 1 / (rootPos.Z * math.tan(math.rad(Camera.FieldOfView / 2)) * 2) * 1000
		local boxWidth = math.clamp(scaleFactor * 4.5, 8, 600)
		local boxHeight = math.clamp(scaleFactor * 6.0, 12, 800)
		local boxX = rootPos.X - boxWidth / 2
		local boxY = rootPos.Y - boxHeight / 2
		drawings.box.Visible = Config.ESP_Boxes
		drawings.box.Position = Vector2.new(boxX, boxY)
		drawings.box.Size = Vector2.new(boxWidth, boxHeight)
		drawings.box.Color = Config.ESP_Color
		drawings.nameTag.Visible = Config.ESP_Names
		drawings.nameTag.Position = Vector2.new(rootPos.X, boxY - 16)
		drawings.nameTag.Text = player.DisplayName
		if hum and Config.ESP_Health then
			local barWidth = 3
			local barX = boxX - barWidth - 3
			local healthPct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
			drawings.healthBar.Visible = true
			drawings.healthBar.Position = Vector2.new(barX, boxY)
			drawings.healthBar.Size = Vector2.new(barWidth, boxHeight)
			local fillHeight = boxHeight * healthPct
			drawings.healthFill.Visible = true
			drawings.healthFill.Position = Vector2.new(barX, boxY + (boxHeight - fillHeight))
			drawings.healthFill.Size = Vector2.new(barWidth, fillHeight)
			local r = math.clamp(2 * (1 - healthPct), 0, 1)
			local g = math.clamp(2 * healthPct, 0, 1)
			drawings.healthFill.Color = Color3.new(r, g, 0)
		else
			drawings.healthBar.Visible = false
			drawings.healthFill.Visible = false
		end
		if hum and Config.HealthText_ESP and drawings.healthText then
			drawings.healthText.Visible = true
			local barX = boxX - 3 - 3
			drawings.healthText.Position = Vector2.new(barX - 2, boxY - 14)
			drawings.healthText.Text = string.format("%d/%d", math.floor(hum.Health), math.floor(hum.MaxHealth))
		elseif drawings.healthText then
			drawings.healthText.Visible = false
		end
		drawings.distTag.Visible = Config.ESP_Distance
		drawings.distTag.Position = Vector2.new(rootPos.X, boxY + boxHeight + 3)
		drawings.distTag.Text = string.format("[%dm]", math.floor(distance))
		if Config.ESP_Skeleton then
			local char = player.Character
			for i, joint in ipairs(SKEL_JOINTS) do
				local sk = drawings["sk"..i]
				if sk then
					local partA = char:FindFirstChild(joint[1]) or char:FindFirstChild(R6MAP[joint[1]] or "")
					local partB = char:FindFirstChild(joint[2]) or char:FindFirstChild(R6MAP[joint[2]] or "")
					if partA and partB and partA ~= partB then
						local a, aOn = Camera:WorldToViewportPoint(partA.Position)
						local b, bOn = Camera:WorldToViewportPoint(partB.Position)
						if aOn and bOn then
							sk.From = Vector2.new(a.X, a.Y)
							sk.To = Vector2.new(b.X, b.Y)
							sk.Color = Config.ESP_Color
							sk.Visible = true
						else
							sk.Visible = false
						end
					else
						sk.Visible = false
					end
				end
			end
		else
			for i = 1, 10 do
				local sk = drawings["sk"..i]
				if sk then sk.Visible = false end
			end
		end
		if Config.ESP_Tracers and drawings.tracer then
			local screenBottom = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
			drawings.tracer.From = screenBottom
			drawings.tracer.To = Vector2.new(rootPos.X, rootPos.Y)
			drawings.tracer.Color = Config.ESP_Color
			drawings.tracer.Visible = true
		elseif drawings.tracer then
			drawings.tracer.Visible = false
		end
		if Config.ESP_ViewAngles and drawings.viewAngle then
			local head = player.Character:FindFirstChild("Head")
			if head then
				local look = head.CFrame.LookVector
				local endP3 = head.Position + look * 5
				local hp, hOn = Camera:WorldToViewportPoint(head.Position)
				local ep, eOn = Camera:WorldToViewportPoint(endP3)
				if hOn and eOn then
					drawings.viewAngle.From = Vector2.new(hp.X, hp.Y)
					drawings.viewAngle.To = Vector2.new(ep.X, ep.Y)
					drawings.viewAngle.Visible = true
				else
					drawings.viewAngle.Visible = false
				end
			else
				drawings.viewAngle.Visible = false
			end
		elseif drawings.viewAngle then
			drawings.viewAngle.Visible = false
		end
	end
end

local function StartESP()
	for _, player in ipairs(Players:GetPlayers()) do
		CreateESPForPlayer(player)
	end
	RegisterSignal("ESP_PlayerAdded", Players.PlayerAdded:Connect(function(player)
		CreateESPForPlayer(player)
	end))
	RegisterSignal("ESP_PlayerRemoving", Players.PlayerRemoving:Connect(function(player)
		RemoveESPForPlayer(player)
	end))
	RegisterSignal("ESP_RenderStepped", RunService.RenderStepped:Connect(function()
		if not _G.MedusaLoaded then return end
		UpdateESP()
	end))
end

local function StopESP()
	for _, name in ipairs({"ESP_RenderStepped", "ESP_PlayerAdded", "ESP_PlayerRemoving"}) do
		if _G.MedusaSignals[name] then
			_G.MedusaSignals[name]:Disconnect()
			_G.MedusaSignals[name] = nil
		end
	end
	for _, drawings in pairs(ESPObjects) do
		for _, obj in pairs(drawings) do obj.Visible = false end
	end
end

local OriginalWalkSpeed = 16
local OriginalJumpPower = 50

local function StartSpeedJump()
	local hum = GetHumanoid()
	if hum then
		OriginalWalkSpeed = hum.WalkSpeed
		OriginalJumpPower = hum.JumpPower
	end
	RegisterSignal("Speed_Heartbeat", RunService.Heartbeat:Connect(function()
		if not _G.MedusaLoaded then return end
		if not Config.Speed_Enabled then return end
		local hum = GetHumanoid()
		if not hum then return end
		hum.WalkSpeed = Config.WalkSpeed
		hum.JumpPower = Config.JumpPower
	end))
end

local function StopSpeedJump()
	if _G.MedusaSignals["Speed_Heartbeat"] then
		_G.MedusaSignals["Speed_Heartbeat"]:Disconnect()
		_G.MedusaSignals["Speed_Heartbeat"] = nil
	end
	local hum = GetHumanoid()
	if hum then
		hum.WalkSpeed = OriginalWalkSpeed
		hum.JumpPower = OriginalJumpPower
	end
end

local function StartInfiniteJump()
	RegisterSignal("InfJump_Request", UserInputService.JumpRequest:Connect(function()
		if not _G.MedusaLoaded then return end
		if not Config.InfJump_Enabled then return end
		local hum = GetHumanoid()
		if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
	end))
end

local function StopInfiniteJump()
	if _G.MedusaSignals["InfJump_Request"] then
		_G.MedusaSignals["InfJump_Request"]:Disconnect()
		_G.MedusaSignals["InfJump_Request"] = nil
	end
end

local function StartNoclip()
	RegisterSignal("Noclip_Stepped", RunService.Stepped:Connect(function()
		if not _G.MedusaLoaded then return end
		if not Config.Noclip_Enabled then return end
		local char = GetCharacter()
		if not char then return end
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") then part.CanCollide = false end
		end
	end))
end

local function StopNoclip()
	if _G.MedusaSignals["Noclip_Stepped"] then
		_G.MedusaSignals["Noclip_Stepped"]:Disconnect()
		_G.MedusaSignals["Noclip_Stepped"] = nil
	end
	local char = GetCharacter()
	if char then
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") then part.CanCollide = (part.Name ~= "Head") end
		end
	end
end

local FlyBodyGyro = nil
local FlyBodyVelocity = nil
local FlyKeysHeld = {}

local function StartFly()
	RegisterSignal("Fly_InputBegan", UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.KeyCode then FlyKeysHeld[input.KeyCode] = true end
	end))
	RegisterSignal("Fly_InputEnded", UserInputService.InputEnded:Connect(function(input)
		if input.KeyCode then FlyKeysHeld[input.KeyCode] = false end
	end))
	RegisterSignal("Fly_RenderStepped", RunService.RenderStepped:Connect(function()
		if not _G.MedusaLoaded then return end
		local hrp = GetRootPart()
		local hum = GetHumanoid()
		if not hrp or not hum then return end
		if Config.Fly_Enabled then
			if not FlyBodyGyro or not FlyBodyGyro.Parent then
				FlyBodyGyro = Instance.new("BodyGyro")
				FlyBodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
				FlyBodyGyro.P = 1e4
				FlyBodyGyro.D = 500
				FlyBodyGyro.Parent = hrp
			end
			if not FlyBodyVelocity or not FlyBodyVelocity.Parent then
				FlyBodyVelocity = Instance.new("BodyVelocity")
				FlyBodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
				FlyBodyVelocity.Velocity = Vector3.zero
				FlyBodyVelocity.Parent = hrp
			end
			hum.PlatformStand = true
			FlyBodyGyro.CFrame = Camera.CFrame
			local direction = Vector3.zero
			local camCF = Camera.CFrame
			local function key(kc) return FlyKeysHeld[kc] == true end
			if key(Enum.KeyCode.W) then direction = direction + camCF.LookVector end
			if key(Enum.KeyCode.S) then direction = direction - camCF.LookVector end
			if key(Enum.KeyCode.A) then direction = direction - camCF.RightVector end
			if key(Enum.KeyCode.D) then direction = direction + camCF.RightVector end
			if key(Enum.KeyCode.Space) then direction = direction + Vector3.new(0, 1, 0) end
			if key(Enum.KeyCode.LeftShift) then direction = direction - Vector3.new(0, 1, 0) end
			if direction.Magnitude > 0 then direction = direction.Unit end
			FlyBodyVelocity.Velocity = direction * Config.Fly_Speed
		else
			if FlyBodyGyro and FlyBodyGyro.Parent then FlyBodyGyro:Destroy() FlyBodyGyro = nil end
			if FlyBodyVelocity and FlyBodyVelocity.Parent then FlyBodyVelocity:Destroy() FlyBodyVelocity = nil end
			if hum then hum.PlatformStand = false end
		end
	end))
end

local function StopFly()
	for _, name in ipairs({"Fly_InputBegan", "Fly_InputEnded", "Fly_RenderStepped"}) do
		if _G.MedusaSignals[name] then
			_G.MedusaSignals[name]:Disconnect()
			_G.MedusaSignals[name] = nil
		end
	end
	if FlyBodyGyro and FlyBodyGyro.Parent then FlyBodyGyro:Destroy() end
	FlyBodyGyro = nil
	if FlyBodyVelocity and FlyBodyVelocity.Parent then FlyBodyVelocity:Destroy() end
	FlyBodyVelocity = nil
	local hum = GetHumanoid()
	if hum then hum.PlatformStand = false end
	FlyKeysHeld = {}
end

local function StartNoRecoilSpread()
	RegisterSignal("NoRecoilSpread_HB", RunService.Heartbeat:Connect(function()
		if not _G.MedusaLoaded then return end
		if not Config.NoRecoil_Enabled and not Config.NoSpread_Enabled then return end
		local char = GetCharacter()
		if not char then return end
		local bp = LocalPlayer:FindFirstChild("Backpack")
		local function Scan(tool)
			for _, d in ipairs(tool:GetDescendants()) do
				if d:IsA("NumberValue") or d:IsA("IntValue") then
					local n = d.Name:lower()
					if Config.NoRecoil_Enabled and (n:find("recoil") or n:find("kick")) then d.Value = 0 end
					if Config.NoSpread_Enabled and (n:find("spread") or n:find("bloom")) then d.Value = 0 end
				end
			end
		end
		for _, t in ipairs(char:GetChildren()) do if t:IsA("Tool") then Scan(t) end end
		if bp then for _, t in ipairs(bp:GetChildren()) do if t:IsA("Tool") then Scan(t) end end end
	end))
end

local function StopNoRecoilSpread()
	if not Config.NoRecoil_Enabled and not Config.NoSpread_Enabled then
		if _G.MedusaSignals["NoRecoilSpread_HB"] then
			_G.MedusaSignals["NoRecoilSpread_HB"]:Disconnect()
			_G.MedusaSignals["NoRecoilSpread_HB"] = nil
		end
	end
end

local VirtualUser = game:GetService("VirtualUser")

local function StartAntiAFK()
	RegisterSignal("AntiAFK_Idled", LocalPlayer.Idled:Connect(function()
		if not _G.MedusaLoaded then return end
		if not Config.AntiAFK_Enabled then return end
		pcall(function()
			VirtualUser:CaptureController()
			VirtualUser:ClickButton2(Vector2.new())
		end)
	end))
end

local function StopAntiAFK()
	if _G.MedusaSignals["AntiAFK_Idled"] then
		_G.MedusaSignals["AntiAFK_Idled"]:Disconnect()
		_G.MedusaSignals["AntiAFK_Idled"] = nil
	end
end

local function StartTriggerBot()
	RegisterSignal("TriggerBot_RS", RunService.RenderStepped:Connect(function()
		if not _G.MedusaLoaded or not Config.TriggerBot_Enabled then return end
		local cam = Camera
		local rayResult = workspace:Raycast(cam.CFrame.Position, cam.CFrame.LookVector * 1000)
		if rayResult and rayResult.Instance then
			local hit = rayResult.Instance
			local targetPlr = Players:GetPlayerFromCharacter(hit.Parent) or Players:GetPlayerFromCharacter(hit.Parent and hit.Parent.Parent)
			if targetPlr and targetPlr ~= LocalPlayer and IsAlive(targetPlr) then
				if Config.Aimbot_TeamCheck and IsSameTeam(targetPlr) then return end
				pcall(function() mouse1click() end)
			end
		end
	end))
end

local function StopTriggerBot()
	if _G.MedusaSignals["TriggerBot_RS"] then
		_G.MedusaSignals["TriggerBot_RS"]:Disconnect()
		_G.MedusaSignals["TriggerBot_RS"] = nil
	end
end

local trackedHealth = {}
local hitSound = nil

local function StartHitSounds()
	if not hitSound then
		hitSound = Instance.new("Sound")
		hitSound.SoundId = "rbxassetid://6333186162"
		hitSound.Volume = 1
		hitSound.PlayOnRemove = false
		hitSound.Parent = game:GetService("SoundService")
	end
	trackedHealth = {}
	RegisterSignal("HitSound_HB", RunService.Heartbeat:Connect(function()
		if not _G.MedusaLoaded or not Config.HitSound_Enabled then return end
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer and plr.Character then
				local hum = plr.Character:FindFirstChildOfClass("Humanoid")
				if hum then
					local prev = trackedHealth[plr]
					local curr = hum.Health
					if prev and curr < prev and prev - curr > 0.1 then
						pcall(function() hitSound:Play() end)
					end
					trackedHealth[plr] = curr
				end
			end
		end
	end))
end

local function StopHitSounds()
	if _G.MedusaSignals["HitSound_HB"] then
		_G.MedusaSignals["HitSound_HB"]:Disconnect()
		_G.MedusaSignals["HitSound_HB"] = nil
	end
	trackedHealth = {}
	if hitSound then pcall(function() hitSound:Destroy() end) hitSound = nil end
end

local originalLighting = {}

local function StartFullBright()
	local lighting = game:GetService("Lighting")
	originalLighting.Ambient = lighting.Ambient
	originalLighting.Brightness = lighting.Brightness
	originalLighting.FogEnd = lighting.FogEnd
	originalLighting.GlobalShadows = lighting.GlobalShadows
	lighting.Ambient = Color3.new(1, 1, 1)
	lighting.Brightness = 2
	lighting.FogEnd = 1e6
	lighting.GlobalShadows = false
	for _, v in ipairs(lighting:GetDescendants()) do
		if v:IsA("Atmosphere") or v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") then
			originalLighting[v] = v.Enabled
			v.Enabled = false
		end
	end
end

local function StopFullBright()
	local lighting = game:GetService("Lighting")
	if originalLighting.Ambient then lighting.Ambient = originalLighting.Ambient end
	if originalLighting.Brightness then lighting.Brightness = originalLighting.Brightness end
	if originalLighting.FogEnd then lighting.FogEnd = originalLighting.FogEnd end
	if originalLighting.GlobalShadows ~= nil then lighting.GlobalShadows = originalLighting.GlobalShadows end
	for v, state in pairs(originalLighting) do
		if typeof(v) == "Instance" then
			pcall(function() v.Enabled = state end)
		end
	end
	originalLighting = {}
end

local function StartSpinBot()
	RegisterSignal("SpinBot_HB", RunService.Heartbeat:Connect(function()
		if not _G.MedusaLoaded or not Config.SpinBot_Enabled then return end
		local hrp = GetRootPart()
		if hrp then
			hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(Config.SpinBot_Speed), 0)
		end
	end))
end

local function StopSpinBot()
	if _G.MedusaSignals["SpinBot_HB"] then
		_G.MedusaSignals["SpinBot_HB"]:Disconnect()
		_G.MedusaSignals["SpinBot_HB"] = nil
	end
end

local crosshairLines = {}
local function StartCustomCrosshair()
	if #crosshairLines > 0 then return end
	for i = 1, 4 do
		local l = Drawing.new("Line")
		l.Visible = false
		l.Color = Config.CrosshairColor
		l.Thickness = 2
		l.Transparency = 1
		crosshairLines[i] = l
	end
	RegisterSignal("Crosshair_RS", RunService.RenderStepped:Connect(function()
		if not _G.MedusaLoaded then return end
		local show = Config.CustomCrosshair_Enabled
		local vs = Camera.ViewportSize
		local cx, cy = vs.X / 2, vs.Y / 2
		local sz = Config.CrosshairSize
		local col = Config.CrosshairColor
		for i, l in ipairs(crosshairLines) do
			l.Color = col
			l.Visible = show
		end
		if show then
			crosshairLines[1].From = Vector2.new(cx - sz, cy)
			crosshairLines[1].To = Vector2.new(cx - 4, cy)
			crosshairLines[2].From = Vector2.new(cx + 4, cy)
			crosshairLines[2].To = Vector2.new(cx + sz, cy)
			crosshairLines[3].From = Vector2.new(cx, cy - sz)
			crosshairLines[3].To = Vector2.new(cx, cy - 4)
			crosshairLines[4].From = Vector2.new(cx, cy + 4)
			crosshairLines[4].To = Vector2.new(cx, cy + sz)
		end
	end))
end
local function StopCustomCrosshair()
	if _G.MedusaSignals["Crosshair_RS"] then
		_G.MedusaSignals["Crosshair_RS"]:Disconnect()
		_G.MedusaSignals["Crosshair_RS"] = nil
	end
	for _, l in ipairs(crosshairLines) do pcall(function() l:Remove() end) end
	crosshairLines = {}
end

local originalPP = {}
local function StartPPBypass()
	local lighting = game:GetService("Lighting")
	for _, v in ipairs(lighting:GetDescendants()) do
		if v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("DepthOfFieldEffect") then
			originalPP[v] = v.Enabled
			v.Enabled = false
		end
	end
end
local function StopPPBypass()
	for v, state in pairs(originalPP) do
		pcall(function() v.Enabled = state end)
	end
	originalPP = {}
end

local function StartExposureContrast()
	RegisterSignal("Exposure_HB", RunService.Heartbeat:Connect(function()
		if not _G.MedusaLoaded then return end
		local lighting = game:GetService("Lighting")
		local cc = lighting:FindFirstChildOfClass("ColorCorrectionEffect")
		if not cc then
			cc = Instance.new("ColorCorrectionEffect")
			cc.Name = "MedusaCC"
			cc.Parent = lighting
		end
		cc.Brightness = Config.Exposure / 100
		cc.Contrast = Config.Contrast / 100
	end))
end
local function StopExposureContrast()
	if _G.MedusaSignals["Exposure_HB"] then
		_G.MedusaSignals["Exposure_HB"]:Disconnect()
		_G.MedusaSignals["Exposure_HB"] = nil
	end
	pcall(function()
		local cc = game:GetService("Lighting"):FindFirstChild("MedusaCC")
		if cc then cc:Destroy() end
	end)
end

local killTrack = {}
local killPopupQueue = {}
local function StartKillPopups()
	killTrack = {}
	RegisterSignal("KillPopup_HB", RunService.Heartbeat:Connect(function()
		if not _G.MedusaLoaded or not Config.KillPopups_Enabled then return end
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer and plr.Character then
				local hum = plr.Character:FindFirstChildOfClass("Humanoid")
				if hum then
					local prev = killTrack[plr]
					local curr = hum.Health
					if prev and prev > 0 and curr <= 0 then
						table.insert(killPopupQueue, {name = plr.DisplayName, tick = tick()})
					end
					killTrack[plr] = curr
				end
			end
		end
	end))
end
local function StopKillPopups()
	if _G.MedusaSignals["KillPopup_HB"] then
		_G.MedusaSignals["KillPopup_HB"]:Disconnect()
		_G.MedusaSignals["KillPopup_HB"] = nil
	end
	killTrack = {}
	killPopupQueue = {}
end

local spectatorList = {}
local function StartSpectatorList()
	RegisterSignal("Spectator_HB", RunService.Heartbeat:Connect(function()
		if not _G.MedusaLoaded or not Config.SpectatorList_Enabled then return end
		spectatorList = {}
		local myHRP = GetRootPart()
		if not myHRP then return end
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer and plr.Character then
				local cam = plr.Character:FindFirstChildOfClass("Camera")
				if not cam then
					local hum = plr.Character:FindFirstChildOfClass("Humanoid")
					if hum and hum.Health <= 0 then
						table.insert(spectatorList, plr.DisplayName)
					end
				end
			end
		end
	end))
end
local function StopSpectatorList()
	if _G.MedusaSignals["Spectator_HB"] then
		_G.MedusaSignals["Spectator_HB"]:Disconnect()
		_G.MedusaSignals["Spectator_HB"] = nil
	end
	spectatorList = {}
end

local metaHooked = false
local originalIndex = nil
local function StartMetaBypass()
	if metaHooked then return end
	metaHooked = true
	pcall(function()
		local mt = getrawmetatable(game)
		local oldIndex = mt.__index
		originalIndex = oldIndex
		setreadonly(mt, false)
		mt.__index = newcclosure(function(self, key)
			if not _G.MedusaLoaded or not Config.MetaBypass_Enabled then
				return oldIndex(self, key)
			end
			if self:IsA("Humanoid") then
				if key == "WalkSpeed" then return 16 end
				if key == "JumpPower" or key == "JumpHeight" then return 50 end
			end
			return oldIndex(self, key)
		end)
		setreadonly(mt, true)
	end)
end
local function StopMetaBypass()
	Config.MetaBypass_Enabled = false
end

local function StartAutoStomp()
	RegisterSignal("AutoStomp_HB", RunService.Heartbeat:Connect(function()
		if not _G.MedusaLoaded or not Config.AutoStomp_Enabled then return end
		local myHRP = GetRootPart()
		if not myHRP then return end
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer and plr.Character then
				local hum = plr.Character:FindFirstChildOfClass("Humanoid")
				local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
				if hum and hrp and hum.Health > 0 and hum.Health < hum.MaxHealth * 0.15 then
					local dist = (myHRP.Position - hrp.Position).Magnitude
					if dist <= Config.AutoStomp_Range then
						pcall(function()
							for _, tool in ipairs(LocalPlayer.Character:GetChildren()) do
								if tool:IsA("Tool") then tool:Activate() end
							end
						end)
					end
				end
			end
		end
	end))
end
local function StopAutoStomp()
	if _G.MedusaSignals["AutoStomp_HB"] then
		_G.MedusaSignals["AutoStomp_HB"]:Disconnect()
		_G.MedusaSignals["AutoStomp_HB"] = nil
	end
end

local originalTime = nil
local originalFog = {}
local function StartTimeChanger()
	local lighting = game:GetService("Lighting")
	if not originalTime then originalTime = lighting.ClockTime end
	if not originalFog.Start then
		originalFog.Start = lighting.FogStart
		originalFog.End = lighting.FogEnd
	end
	RegisterSignal("TimeFog_HB", RunService.Heartbeat:Connect(function()
		if not _G.MedusaLoaded then return end
		pcall(function()
			lighting.ClockTime = Config.TimeOfDay
			lighting.FogStart = Config.FogStart_Val
			lighting.FogEnd = Config.FogEnd_Val
		end)
	end))
end
local function StopTimeChanger()
	if _G.MedusaSignals["TimeFog_HB"] then
		_G.MedusaSignals["TimeFog_HB"]:Disconnect()
		_G.MedusaSignals["TimeFog_HB"] = nil
	end
	pcall(function()
		local lighting = game:GetService("Lighting")
		if originalTime then lighting.ClockTime = originalTime originalTime = nil end
		if originalFog.Start then lighting.FogStart = originalFog.Start end
		if originalFog.End then lighting.FogEnd = originalFog.End end
		originalFog = {}
	end)
end

local rainbowHue = 0
local function StartRainbowUI()
	RegisterSignal("Rainbow_HB", RunService.Heartbeat:Connect(function(dt)
		if not _G.MedusaLoaded or not Config.RainbowUI_Enabled then return end
		rainbowHue = (rainbowHue + dt * 0.3) % 1
		Config.ESP_Color = Color3.fromHSV(rainbowHue, 0.7, 1)
	end))
end
local function StopRainbowUI()
	if _G.MedusaSignals["Rainbow_HB"] then
		_G.MedusaSignals["Rainbow_HB"]:Disconnect()
		_G.MedusaSignals["Rainbow_HB"] = nil
	end
	Config.ESP_Color = Color3.fromRGB(130, 80, 255)
end

local function StartInstantReload()
	RegisterSignal("InstReload_HB", RunService.Heartbeat:Connect(function()
		if not _G.MedusaLoaded or not Config.InstantReload_Enabled then return end
		pcall(function()
			if not getgc then return end
			for _, v in ipairs(getgc(true)) do
				if type(v) == "table" then
					for key, val in pairs(v) do
						local k = tostring(key):lower()
						if type(val) == "number" and val > 0 then
							if k:find("reload") and k:find("time") or k:find("reloadspeed") then
								v[key] = 0.01
							end
						end
					end
				end
			end
		end)
	end))
end
local function StopInstantReload()
	if _G.MedusaSignals["InstReload_HB"] then
		_G.MedusaSignals["InstReload_HB"]:Disconnect()
		_G.MedusaSignals["InstReload_HB"] = nil
	end
end

local bulletDrawings = {}
local function StartBulletTracers()
	RegisterSignal("BulletTrace_RS", RunService.RenderStepped:Connect(function()
		if not _G.MedusaLoaded or not Config.BulletTracers_Enabled then return end
	end))
	RegisterSignal("BulletTrace_Input", UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if not Config.BulletTracers_Enabled then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local cam = Camera
			local origin = cam.CFrame.Position
			local direction = cam.CFrame.LookVector * 500
			local rayResult = workspace:Raycast(origin, direction)
			local endPos = rayResult and rayResult.Position or (origin + direction)
			local fromScreen = cam:WorldToViewportPoint(origin + cam.CFrame.LookVector * 2)
			local toScreen = cam:WorldToViewportPoint(endPos)
			if fromScreen.Z > 0 and toScreen.Z > 0 then
				local line = Drawing.new("Line")
				line.From = Vector2.new(fromScreen.X, fromScreen.Y)
				line.To = Vector2.new(toScreen.X, toScreen.Y)
				line.Color = Color3.fromRGB(255, 200, 50)
				line.Thickness = 1.5
				line.Transparency = 1
				line.Visible = true
				table.insert(bulletDrawings, line)
				task.spawn(function()
					task.wait(0.4)
					pcall(function()
						for i = 1, 10 do
							line.Transparency = 1 - (i / 10)
							task.wait(0.03)
						end
						line:Remove()
					end)
					for idx, d in ipairs(bulletDrawings) do
						if d == line then table.remove(bulletDrawings, idx) break end
					end
				end)
			end
		end
	end))
end
local function StopBulletTracers()
	for _, name in ipairs({"BulletTrace_RS", "BulletTrace_Input"}) do
		if _G.MedusaSignals[name] then
			_G.MedusaSignals[name]:Disconnect()
			_G.MedusaSignals[name] = nil
		end
	end
	for _, d in ipairs(bulletDrawings) do pcall(function() d:Remove() end) end
	bulletDrawings = {}
end

local velBypassHooked = false
local function StartVelocityBypass()
	if velBypassHooked then return end
	velBypassHooked = true
	pcall(function()
		local mt = getrawmetatable(game)
		local oldIndex = mt.__index
		local oldNewindex = mt.__newindex
		setreadonly(mt, false)
		mt.__newindex = newcclosure(function(self, key, value)
			if not _G.MedusaLoaded or not Config.VelocityBypass_Enabled then
				return oldNewindex(self, key, value)
			end
			if self:IsA("Humanoid") then
				if key == "WalkSpeed" or key == "JumpPower" or key == "JumpHeight" then
					return
				end
			end
			if self:IsA("BasePart") and key == "Velocity" then
				return
			end
			return oldNewindex(self, key, value)
		end)
		setreadonly(mt, true)
	end)
end
local function StopVelocityBypass()
	Config.VelocityBypass_Enabled = false
end

local ambientOriginal = nil
local function StartAmbientColor()
	if not ambientOriginal then
		local L = game:GetService("Lighting")
		ambientOriginal = {Ambient = L.Ambient, OutdoorAmbient = L.OutdoorAmbient}
	end
	RegisterSignal("Ambient_HB", RunService.Heartbeat:Connect(function()
		if not _G.MedusaLoaded then return end
		local L = game:GetService("Lighting")
		L.Ambient = Color3.fromRGB(Config.AmbientR, Config.AmbientG, Config.AmbientB)
		L.OutdoorAmbient = Color3.fromRGB(Config.OutdoorR, Config.OutdoorG, Config.OutdoorB)
	end))
end
local function StopAmbientColor()
	if _G.MedusaSignals["Ambient_HB"] then
		_G.MedusaSignals["Ambient_HB"]:Disconnect()
		_G.MedusaSignals["Ambient_HB"] = nil
	end
	if ambientOriginal then
		pcall(function()
			local L = game:GetService("Lighting")
			L.Ambient = ambientOriginal.Ambient
			L.OutdoorAmbient = ambientOriginal.OutdoorAmbient
		end)
	end
end

local ccEffect = nil
local function StartColorCorrection()
	if not ccEffect then
		ccEffect = Instance.new("ColorCorrectionEffect")
		ccEffect.Name = "MedusaCC"
		ccEffect.Parent = game:GetService("Lighting")
	end
	RegisterSignal("CC_HB", RunService.Heartbeat:Connect(function()
		if not _G.MedusaLoaded then return end
		if ccEffect and ccEffect.Parent then
			ccEffect.Saturation = Config.CC_Saturation / 100
			ccEffect.Brightness = Config.CC_Brightness / 100
		end
	end))
end
local function StopColorCorrection()
	if _G.MedusaSignals["CC_HB"] then
		_G.MedusaSignals["CC_HB"]:Disconnect()
		_G.MedusaSignals["CC_HB"] = nil
	end
	if ccEffect then pcall(function() ccEffect:Destroy() end) ccEffect = nil end
end

local function StartClockSpeed()
	RegisterSignal("Clock_HB", RunService.Heartbeat:Connect(function(dt)
		if not _G.MedusaLoaded then return end
		if Config.ClockSpeed > 1 then
			local L = game:GetService("Lighting")
			local mins = L:GetMinutesAfterMidnight()
			L:SetMinutesAfterMidnight(mins + (dt * 60 * (Config.ClockSpeed - 1)))
		end
	end))
end
local function StopClockSpeed()
	if _G.MedusaSignals["Clock_HB"] then
		_G.MedusaSignals["Clock_HB"]:Disconnect()
		_G.MedusaSignals["Clock_HB"] = nil
	end
end

local headSizeOriginals = {}
local function StartHeadSize()
	RegisterSignal("HeadSize_HB", RunService.Heartbeat:Connect(function()
		if not _G.MedusaLoaded or not Config.HeadSize_Enabled then return end
		for _, plr in pairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer and plr.Character then
				local head = plr.Character:FindFirstChild("Head")
				if head then
					if not headSizeOriginals[plr.Name] then
						headSizeOriginals[plr.Name] = head.Size
					end
					local s = Config.HeadSize
					head.Size = Vector3.new(s, s, s)
					head.Transparency = s > 2 and 0.7 or 0
				end
			end
		end
	end))
end
local function StopHeadSize()
	if _G.MedusaSignals["HeadSize_HB"] then
		_G.MedusaSignals["HeadSize_HB"]:Disconnect()
		_G.MedusaSignals["HeadSize_HB"] = nil
	end
	for _, plr in pairs(Players:GetPlayers()) do
		if plr.Character then
			local head = plr.Character:FindFirstChild("Head")
			if head and headSizeOriginals[plr.Name] then
				pcall(function() head.Size = headSizeOriginals[plr.Name] end)
				pcall(function() head.Transparency = 0 end)
			end
		end
	end
	headSizeOriginals = {}
end

local breadcrumbs = {}
local function StartBreadcrumbs()
	RegisterSignal("Bread_HB", RunService.Heartbeat:Connect(function()
		if not _G.MedusaLoaded or not Config.Breadcrumbs_Enabled then return end
		local hrp = GetRootPart()
		if not hrp then return end
		local pos = hrp.Position
		if #breadcrumbs == 0 or (pos - breadcrumbs[#breadcrumbs].Position).Magnitude > 8 then
			local part = Instance.new("Part")
			part.Size = Vector3.new(0.5, 0.5, 0.5)
			part.Position = pos - Vector3.new(0, 2.5, 0)
			part.Anchored = true
			part.CanCollide = false
			part.Material = Enum.Material.Neon
			part.Color = Color3.fromRGB(Config.AccentR, Config.AccentG, Config.AccentB)
			part.Transparency = 0.3
			part.Parent = workspace
			table.insert(breadcrumbs, part)
			if #breadcrumbs > 200 then
				breadcrumbs[1]:Destroy()
				table.remove(breadcrumbs, 1)
			end
		end
	end))
end
local function StopBreadcrumbs()
	if _G.MedusaSignals["Bread_HB"] then
		_G.MedusaSignals["Bread_HB"]:Disconnect()
		_G.MedusaSignals["Bread_HB"] = nil
	end
	for _, p in ipairs(breadcrumbs) do pcall(function() p:Destroy() end) end
	breadcrumbs = {}
end

local UI_SOUND_IDS = {
	click = "rbxassetid://6895079853",
	hover = "rbxassetid://6895079590",
	tab = "rbxassetid://6895079980",
}
local function PlayUISound(soundType)
	if not Config.UISounds_Enabled then return end
	pcall(function()
		local s = Instance.new("Sound")
		s.SoundId = UI_SOUND_IDS[soundType] or UI_SOUND_IDS.click
		s.Volume = Config.UISounds_Volume or 0.5
		s.PlayOnRemove = true
		s.Parent = workspace
		game:GetService("Debris"):AddItem(s, 0.1)
		s:Destroy()
	end)
end

local killStreak = 0
local killStreakSounds = {
	[3] = "rbxassetid://4612373218",
	[5] = "rbxassetid://4612374015",
	[10] = "rbxassetid://4612374762",
}
local killStreakTracking = {}
local function StartKillStreaks()
	RegisterSignal("KStreak_HB", RunService.Heartbeat:Connect(function()
		if not _G.MedusaLoaded or not Config.KillStreak_Enabled then return end
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer and plr.Character then
				local hum = plr.Character:FindFirstChildOfClass("Humanoid")
				if hum then
					local prev = killStreakTracking[plr.Name]
					if prev and prev > 0 and hum.Health <= 0 then
						killStreak = killStreak + 1
						local sndId = killStreakSounds[killStreak]
						if sndId then
							pcall(function()
								local s = Instance.new("Sound")
								s.SoundId = sndId
								s.Volume = 0.8
								s.PlayOnRemove = true
								s.Parent = workspace
								game:GetService("Debris"):AddItem(s, 0.1)
								s:Destroy()
							end)
						end
					end
					killStreakTracking[plr.Name] = hum.Health
				end
			end
		end
	end))
end
local function StopKillStreaks()
	if _G.MedusaSignals["KStreak_HB"] then
		_G.MedusaSignals["KStreak_HB"]:Disconnect()
		_G.MedusaSignals["KStreak_HB"] = nil
	end
	killStreak = 0
	killStreakTracking = {}
end

local footstepParts = {}
local function StartFootstepSpam()
	RegisterSignal("Footstep_HB", RunService.Heartbeat:Connect(function()
		if not _G.MedusaLoaded or not Config.FootstepSpam_Enabled then return end
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
				pcall(function()
					local pos = plr.Character.HumanoidRootPart.Position
					local offset = Vector3.new(math.random(-15, 15), 0, math.random(-15, 15))
					local s = Instance.new("Sound")
					s.SoundId = "rbxassetid://9126214745"
					s.Volume = 0.4
					s.RollOffMaxDistance = 60
					s.PlayOnRemove = true
					local a = Instance.new("Attachment")
					a.WorldPosition = pos + offset
					a.Parent = workspace.Terrain
					s.Parent = a
					game:GetService("Debris"):AddItem(a, 0.3)
					task.delay(0.25, function() pcall(function() a:Destroy() end) end)
				end)
			end
		end
	end))
end
local function StopFootstepSpam()
	if _G.MedusaSignals["Footstep_HB"] then
		_G.MedusaSignals["Footstep_HB"]:Disconnect()
		_G.MedusaSignals["Footstep_HB"] = nil
	end
end

local vignetteGui = nil
local grainGui = nil
local function StartVignette()
	if vignetteGui then return end
	vignetteGui = Instance.new("ImageLabel")
	vignetteGui.Name = "MedusaVignette"
	vignetteGui.Size = UDim2.new(1, 0, 1, 0)
	vignetteGui.Position = UDim2.new(0, 0, 0, 0)
	vignetteGui.BackgroundTransparency = 1
	vignetteGui.Image = "rbxassetid://1049674457"
	vignetteGui.ImageColor3 = Color3.fromRGB(0, 0, 0)
	vignetteGui.ImageTransparency = 0.3
	vignetteGui.ScaleType = Enum.ScaleType.Stretch
	vignetteGui.ZIndex = 999
	pcall(function()
		local sg = Instance.new("ScreenGui")
		sg.Name = "MedusaVignetteGui"
		sg.IgnoreGuiInset = true
		sg.DisplayOrder = 999
		sg.Parent = game:GetService("CoreGui")
		vignetteGui.Parent = sg
	end)
end
local function StopVignette()
	if vignetteGui then
		pcall(function() vignetteGui.Parent:Destroy() end)
		vignetteGui = nil
	end
end

local grainThread = nil
local function StartGrain()
	if grainGui then return end
	local sg = Instance.new("ScreenGui")
	sg.Name = "MedusaGrainGui"
	sg.IgnoreGuiInset = true
	sg.DisplayOrder = 998
	pcall(function() sg.Parent = game:GetService("CoreGui") end)
	grainGui = Instance.new("Frame")
	grainGui.Size = UDim2.new(1, 0, 1, 0)
	grainGui.BackgroundColor3 = Color3.fromRGB(127, 127, 127)
	grainGui.BackgroundTransparency = 0.92
	grainGui.BorderSizePixel = 0
	grainGui.Parent = sg
	grainThread = task.spawn(function()
		while grainGui and grainGui.Parent do
			grainGui.BackgroundTransparency = 0.88 + math.random() * 0.08
			task.wait(0.05)
		end
	end)
end
local function StopGrain()
	if grainThread then pcall(function() task.cancel(grainThread) end) grainThread = nil end
	if grainGui then
		pcall(function() grainGui.Parent:Destroy() end)
		grainGui = nil
	end
end

local arrowDrawings = {}
local function StartOffscreenArrows()
	RegisterSignal("Arrows_RS", RunService.RenderStepped:Connect(function()
		if not _G.MedusaLoaded or not Config.OffscreenArrows_Enabled then
			for _, a in pairs(arrowDrawings) do pcall(function() a:Remove() end) end
			arrowDrawings = {}
			return
		end
		local cam = Camera
		local screenCenter = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
		local seen = {}
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
				local hum = plr.Character:FindFirstChildOfClass("Humanoid")
				if hum and hum.Health > 0 then
					local pos, onScreen = cam:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
					if not onScreen then
						seen[plr.Name] = true
						if not arrowDrawings[plr.Name] then
							local tri = Drawing.new("Triangle")
							tri.Color = Config.ESP_Color or Color3.fromRGB(130, 80, 255)
							tri.Filled = true
							tri.Thickness = 1
							arrowDrawings[plr.Name] = tri
						end
						local dir = (Vector2.new(pos.X, pos.Y) - screenCenter).Unit
						local edge = screenCenter + dir * math.min(cam.ViewportSize.X, cam.ViewportSize.Y) * 0.42
						local perp = Vector2.new(-dir.Y, dir.X)
						local tip = edge + dir * 14
						arrowDrawings[plr.Name].PointA = tip
						arrowDrawings[plr.Name].PointB = edge + perp * 8
						arrowDrawings[plr.Name].PointC = edge - perp * 8
						arrowDrawings[plr.Name].Visible = true
					else
						if arrowDrawings[plr.Name] then
							arrowDrawings[plr.Name].Visible = false
						end
					end
				end
			end
		end
		for name, d in pairs(arrowDrawings) do
			if not seen[name] then
				pcall(function() d:Remove() end)
				arrowDrawings[name] = nil
			end
		end
	end))
end
local function StopOffscreenArrows()
	if _G.MedusaSignals["Arrows_RS"] then
		_G.MedusaSignals["Arrows_RS"]:Disconnect()
		_G.MedusaSignals["Arrows_RS"] = nil
	end
	for _, d in pairs(arrowDrawings) do pcall(function() d:Remove() end) end
	arrowDrawings = {}
end

local spoofedName = nil
local function StartNameSpoof()
	spoofedName = LocalPlayer.DisplayName
	pcall(function()
		local nameTag = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
		if nameTag then
			local bg = nameTag:FindFirstChildOfClass("BillboardGui")
			if bg then
				local tl = bg:FindFirstChildOfClass("TextLabel")
				if tl then tl.Text = "[Hidden]" end
			end
		end
	end)
end
local function StopNameSpoof()
	pcall(function()
		if spoofedName and LocalPlayer.Character then
			local head = LocalPlayer.Character:FindFirstChild("Head")
			if head then
				local bg = head:FindFirstChildOfClass("BillboardGui")
				if bg then
					local tl = bg:FindFirstChildOfClass("TextLabel")
					if tl then tl.Text = spoofedName end
				end
			end
		end
	end)
	spoofedName = nil
end

local function TeleportToPlayer(targetName)
	local hrp = GetRootPart()
	if not hrp then return end
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr.Name == targetName or plr.DisplayName == targetName then
			if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
				hrp.CFrame = plr.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
			end
			return
		end
	end
end

local function TeleportToCoord(pos)
	local hrp = GetRootPart()
	if not hrp then return end
	hrp.CFrame = CFrame.new(pos)
end

local function FullEject()
	_G.MedusaLoaded = false
	pcall(function()
		local hum = GetHumanoid()
		if hum then
			hum.WalkSpeed = OriginalWalkSpeed or 16
			hum.JumpPower = OriginalJumpPower or 50
			hum.PlatformStand = false
		end
	end)
	pcall(function()
		local char = GetCharacter()
		if char then
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then part.CanCollide = (part.Name ~= "Head") end
			end
		end
	end)
	pcall(StopAimbot)
	pcall(StopSilentAim)
	pcall(StopESP)
	pcall(StopSpeedJump)
	pcall(StopInfiniteJump)
	pcall(StopNoclip)
	pcall(StopFly)
	pcall(StopNoRecoilSpread)
	pcall(StopAntiAFK)
	pcall(StopTriggerBot)
	pcall(StopHitSounds)
	pcall(StopFullBright)
	pcall(StopSpinBot)
	pcall(StopCustomCrosshair)
	pcall(StopPPBypass)
	pcall(StopExposureContrast)
	pcall(StopKillPopups)
	pcall(StopSpectatorList)
	pcall(StopMetaBypass)
	pcall(StopAutoStomp)
	pcall(StopTimeChanger)
	pcall(StopRainbowUI)
	pcall(StopInstantReload)
	pcall(StopBulletTracers)
	pcall(StopVelocityBypass)
	pcall(StopAmbientColor)
	pcall(StopColorCorrection)
	pcall(StopClockSpeed)
	pcall(StopHeadSize)
	pcall(StopBreadcrumbs)
	pcall(StopKillStreaks)
	pcall(StopFootstepSpam)
	pcall(StopVignette)
	pcall(StopGrain)
	pcall(StopOffscreenArrows)
	pcall(StopNameSpoof)
	DisconnectAllSignals()
	CleanupAllDrawings()
	pcall(function()
		if _G.MedusaOriginalNamecall then
			local mt = getrawmetatable(game)
			setreadonly(mt, false)
			mt.__namecall = _G.MedusaOriginalNamecall
			setreadonly(mt, true)
			_G.MedusaOriginalNamecall = nil
		end
	end)
	pcall(function()
		if _G.MedusaOriginalIndex then
			local mt = getrawmetatable(game)
			setreadonly(mt, false)
			mt.__index = _G.MedusaOriginalIndex
			setreadonly(mt, true)
			_G.MedusaOriginalIndex = nil
		end
	end)
	pcall(function()
		if _G.MedusaOriginalNewindex then
			local mt = getrawmetatable(game)
			setreadonly(mt, false)
			mt.__newindex = _G.MedusaOriginalNewindex
			setreadonly(mt, true)
			_G.MedusaOriginalNewindex = nil
		end
	end)
	task.wait(0.2)
	_G.MedusaConfig = nil
	_G.MedusaSignals = nil
	_G.MedusaFunctions = nil
	_G.MedusaEject = nil
end

_G.MedusaEject = FullEject

_G.MedusaFunctions = {
	StartAimbot = StartAimbot,
	StopAimbot = StopAimbot,
	StartSilentAim = StartSilentAim,
	StopSilentAim = StopSilentAim,
	GetClosestPlayer = GetClosestPlayer,
	StartESP = StartESP,
	StopESP = StopESP,
	CreateESPForPlayer = CreateESPForPlayer,
	RemoveESPForPlayer = RemoveESPForPlayer,
	StartSpeedJump = StartSpeedJump,
	StopSpeedJump = StopSpeedJump,
	StartInfiniteJump = StartInfiniteJump,
	StopInfiniteJump = StopInfiniteJump,
	StartNoclip = StartNoclip,
	StopNoclip = StopNoclip,
	StartFly = StartFly,
	StopFly = StopFly,
	StartNoRecoilSpread = StartNoRecoilSpread,
	StopNoRecoilSpread = StopNoRecoilSpread,
	StartAntiAFK = StartAntiAFK,
	StopAntiAFK = StopAntiAFK,
	StartTriggerBot = StartTriggerBot,
	StopTriggerBot = StopTriggerBot,
	StartHitSounds = StartHitSounds,
	StopHitSounds = StopHitSounds,
	StartFullBright = StartFullBright,
	StopFullBright = StopFullBright,
	StartSpinBot = StartSpinBot,
	StopSpinBot = StopSpinBot,
	TeleportToPlayer = TeleportToPlayer,
	TeleportToCoord = TeleportToCoord,
	StartCustomCrosshair = StartCustomCrosshair,
	StopCustomCrosshair = StopCustomCrosshair,
	StartPPBypass = StartPPBypass,
	StopPPBypass = StopPPBypass,
	StartExposureContrast = StartExposureContrast,
	StopExposureContrast = StopExposureContrast,
	StartKillPopups = StartKillPopups,
	StopKillPopups = StopKillPopups,
	StartSpectatorList = StartSpectatorList,
	StopSpectatorList = StopSpectatorList,
	StartMetaBypass = StartMetaBypass,
	StopMetaBypass = StopMetaBypass,
	StartAutoStomp = StartAutoStomp,
	StopAutoStomp = StopAutoStomp,
	StartTimeChanger = StartTimeChanger,
	StopTimeChanger = StopTimeChanger,
	StartRainbowUI = StartRainbowUI,
	StopRainbowUI = StopRainbowUI,
	StartInstantReload = StartInstantReload,
	StopInstantReload = StopInstantReload,
	StartBulletTracers = StartBulletTracers,
	StopBulletTracers = StopBulletTracers,
	StartVelocityBypass = StartVelocityBypass,
	StopVelocityBypass = StopVelocityBypass,
	StartAmbientColor = StartAmbientColor,
	StopAmbientColor = StopAmbientColor,
	StartColorCorrection = StartColorCorrection,
	StopColorCorrection = StopColorCorrection,
	StartClockSpeed = StartClockSpeed,
	StopClockSpeed = StopClockSpeed,
	StartHeadSize = StartHeadSize,
	StopHeadSize = StopHeadSize,
	StartBreadcrumbs = StartBreadcrumbs,
	StopBreadcrumbs = StopBreadcrumbs,
	PlayUISound = PlayUISound,
	StartKillStreaks = StartKillStreaks,
	StopKillStreaks = StopKillStreaks,
	StartFootstepSpam = StartFootstepSpam,
	StopFootstepSpam = StopFootstepSpam,
	StartVignette = StartVignette,
	StopVignette = StopVignette,
	StartGrain = StartGrain,
	StopGrain = StopGrain,
	StartOffscreenArrows = StartOffscreenArrows,
	StopOffscreenArrows = StopOffscreenArrows,
	StartNameSpoof = StartNameSpoof,
	StopNameSpoof = StopNameSpoof,
	GetSpectatorList = function() return spectatorList end,
	GetKillPopupQueue = function() return killPopupQueue end,
	FullEject = FullEject,
	RegisterSignal = RegisterSignal,
	CleanupAllDrawings = CleanupAllDrawings,
}

local Fn = _G.MedusaFunctions

local THEME = {
	Background   = Color3.fromRGB(12, 12, 16),
	Sidebar      = Color3.fromRGB(10, 10, 14),
	Surface      = Color3.fromRGB(20, 22, 24),
	SurfaceHover = Color3.fromRGB(28, 32, 30),
	Accent       = Color3.fromRGB(0, 201, 107),
	AccentDim    = Color3.fromRGB(0, 80, 45),
	Text         = Color3.fromRGB(220, 230, 225),
	TextDim      = Color3.fromRGB(110, 130, 120),
	Positive     = Color3.fromRGB(0, 220, 110),
	Negative     = Color3.fromRGB(220, 60, 80),
	Border       = Color3.fromRGB(30, 45, 35),
}

local FONT_BODY = Enum.Font.Gotham
local FONT_SEMI = Enum.Font.GothamSemibold
local FONT_BOLD = Enum.Font.GothamBold
local TWEEN_FAST = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TWEEN_SMOOTH = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local UISignals = {}

local function RegisterUISignal(name, connection)
	if UISignals[name] then
		pcall(function() UISignals[name]:Disconnect() end)
	end
	UISignals[name] = connection
end

local function DisconnectAllUISignals()
	for name, conn in pairs(UISignals) do
		pcall(function() conn:Disconnect() end)
		UISignals[name] = nil
	end
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MedusaV16_Global"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999

pcall(function() screenGui.Parent = game:GetService("CoreGui") end)
if not screenGui.Parent then
	screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 560, 0, 400)
mainFrame.Position = UDim2.new(0.5, -280, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
mainFrame.BackgroundTransparency = Config.MenuTransparency / 100
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local mc = Instance.new("UICorner")
mc.CornerRadius = UDim.new(0, 12)
mc.Parent = mainFrame

local ms = Instance.new("UIStroke")
ms.Color = Color3.fromRGB(0, 201, 107)
ms.Thickness = 1.5
ms.Transparency = 0.2
ms.Parent = mainFrame

local glassOverlay = Instance.new("Frame")
glassOverlay.Name = "GlassOverlay"
glassOverlay.Size = UDim2.new(1, 0, 1, 0)
glassOverlay.BackgroundColor3 = Color3.fromRGB(10, 20, 14)
glassOverlay.BackgroundTransparency = 0.93
glassOverlay.BorderSizePixel = 0
glassOverlay.ZIndex = 0
glassOverlay.Parent = mainFrame
Instance.new("UICorner", glassOverlay).CornerRadius = UDim.new(0, 12)
local glassGrad = Instance.new("UIGradient")
glassGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 50, 30)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(8, 12, 10)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 40, 25)),
})
glassGrad.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.95),
	NumberSequenceKeypoint.new(0.5, 0.98),
	NumberSequenceKeypoint.new(1, 0.95),
})
glassGrad.Rotation = 135
glassGrad.Parent = glassOverlay

local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.Size = UDim2.new(1, 40, 1, 40)
shadow.Position = UDim2.new(0, -20, 0, -20)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://6015897843"
shadow.ImageColor3 = Color3.fromRGB(0, 10, 5)
shadow.ImageTransparency = 0.3
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(49, 49, 450, 450)
shadow.ZIndex = 0
shadow.Parent = mainFrame

local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 38)
titleBar.BackgroundColor3 = Color3.fromRGB(8, 10, 9)
titleBar.BackgroundTransparency = 0.05
titleBar.BorderSizePixel = 0
titleBar.ZIndex = 5
titleBar.Parent = mainFrame

local tc = Instance.new("UICorner")
tc.CornerRadius = UDim.new(0, 10)
tc.Parent = titleBar

local titleFix = Instance.new("Frame")
titleFix.Size = UDim2.new(1, 0, 0, 12)
titleFix.Position = UDim2.new(0, 0, 1, -12)
titleFix.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
titleFix.BorderSizePixel = 0
titleFix.ZIndex = 5
titleFix.Parent = titleBar

local accentLine = Instance.new("Frame")
accentLine.Size = UDim2.new(1, 0, 0, 2)
accentLine.Position = UDim2.new(0, 0, 1, -2)
accentLine.BackgroundColor3 = THEME.Accent
accentLine.BorderSizePixel = 0
accentLine.ZIndex = 6
accentLine.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -50, 1, 0)
titleText.Position = UDim2.new(0, 14, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "MEDUSA v16.0"
titleText.TextColor3 = THEME.Text
titleText.TextSize = 13
titleText.Font = FONT_BOLD
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.ZIndex = 6
titleText.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 36, 0, 36)
closeBtn.Position = UDim2.new(1, -36, 0, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "X"
closeBtn.TextColor3 = THEME.TextDim
closeBtn.TextSize = 16
closeBtn.Font = FONT_BOLD
closeBtn.ZIndex = 7
closeBtn.Parent = titleBar

RegisterUISignal("Close_Enter", closeBtn.MouseEnter:Connect(function()
	TweenService:Create(closeBtn, TWEEN_FAST, {TextColor3 = THEME.Negative}):Play()
end))

RegisterUISignal("Close_Leave", closeBtn.MouseLeave:Connect(function()
	TweenService:Create(closeBtn, TWEEN_FAST, {TextColor3 = THEME.TextDim}):Play()
end))

RegisterUISignal("Close_Click", closeBtn.MouseButton1Click:Connect(function()
	TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
		Size = UDim2.new(0, 560 * 0.9, 0, 400 * 0.9),
		Position = UDim2.new(0.5, -252, 0.5, -180),
	}):Play()
	TweenService:Create(mainFrame, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
	task.wait(0.3)
	DisconnectAllUISignals()
	pcall(function() Fn.FullEject() end)
	pcall(function() screenGui:Destroy() end)
end))

do
	local dragging = false
	local dragStart, startPos
	RegisterUISignal("Drag_Begin", titleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = mainFrame.Position
		end
	end))
	RegisterUISignal("Drag_End", UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end))
	RegisterUISignal("Drag_Move", UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			mainFrame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end))
end

local uiVisible = true
RegisterUISignal("ToggleKey", UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.RightControl then
		uiVisible = not uiVisible
		screenGui.Enabled = uiVisible
	end
end))

local contentArea = Instance.new("Frame")
contentArea.Name = "ContentArea"
contentArea.Size = UDim2.new(1, 0, 1, -38)
contentArea.Position = UDim2.new(0, 0, 0, 38)
contentArea.BackgroundTransparency = 1
contentArea.BorderSizePixel = 0
contentArea.Parent = mainFrame

local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 130, 1, 0)
sidebar.BackgroundColor3 = THEME.Sidebar
sidebar.BorderSizePixel = 0
sidebar.Parent = contentArea

local sc = Instance.new("UICorner")
sc.CornerRadius = UDim.new(0, 8)
sc.Parent = sidebar

local sidebarFix = Instance.new("Frame")
sidebarFix.Size = UDim2.new(0, 12, 1, 0)
sidebarFix.Position = UDim2.new(1, -12, 0, 0)
sidebarFix.BackgroundColor3 = THEME.Sidebar
sidebarFix.BorderSizePixel = 0
sidebarFix.Parent = sidebar

local separator = Instance.new("Frame")
separator.Size = UDim2.new(0, 1, 1, -16)
separator.Position = UDim2.new(0, 130, 0, 8)
separator.BackgroundColor3 = THEME.AccentDim
separator.BackgroundTransparency = 0.5
separator.BorderSizePixel = 0
separator.Parent = contentArea

local sidebarButtons = Instance.new("Frame")
sidebarButtons.Size = UDim2.new(1, -12, 1, -50)
sidebarButtons.Position = UDim2.new(0, 6, 0, 8)
sidebarButtons.BackgroundTransparency = 1
sidebarButtons.Parent = sidebar

local sidebarLayout = Instance.new("UIListLayout")
sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
sidebarLayout.Padding = UDim.new(0, 4)
sidebarLayout.Parent = sidebarButtons

local branding = Instance.new("TextLabel")
branding.Size = UDim2.new(1, 0, 0, 30)
branding.Position = UDim2.new(0, 0, 1, -35)
branding.BackgroundTransparency = 1
branding.Text = "MEDUSA"
branding.TextColor3 = THEME.AccentDim
branding.TextSize = 11
branding.Font = FONT_BOLD
branding.Parent = sidebar

local tabContent = Instance.new("Frame")
tabContent.Name = "TabContent"
tabContent.Size = UDim2.new(1, -136, 1, -6)
tabContent.Position = UDim2.new(0, 133, 0, 3)
tabContent.BackgroundTransparency = 1
tabContent.BorderSizePixel = 0
tabContent.Parent = contentArea

local tabs = {}
local activeTab = nil

local TAB_DATA = {
	{name = "Combat",   icon = ">>", order = 1},
	{name = "Visuals",  icon = "o",  order = 2},
	{name = "Utility",  icon = "#",  order = 3},
	{name = "Teleport", icon = "~>", order = 4},
	{name = "HUD",      icon = "@",  order = 5},
	{name = "Settings", icon = "*",  order = 6},
}

local function CreateTabFrame(name)
	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = name .. "Tab"
	scroll.Size = UDim2.new(1, 0, 1, 0)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = 3
	scroll.ScrollBarImageColor3 = THEME.Accent
	scroll.ScrollBarImageTransparency = 0.5
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.Visible = false
	scroll.Parent = tabContent
	local p = Instance.new("UIPadding")
	p.PaddingLeft = UDim.new(0, 10)
	p.PaddingRight = UDim.new(0, 10)
	p.PaddingTop = UDim.new(0, 8)
	p.PaddingBottom = UDim.new(0, 8)
	p.Parent = scroll
	local l = Instance.new("UIListLayout")
	l.SortOrder = Enum.SortOrder.LayoutOrder
	l.Padding = UDim.new(0, 6)
	l.Parent = scroll
	return scroll
end

local function SwitchTab(name)
	if activeTab == name then return end
	if activeTab and tabs[activeTab] then
		local prev = tabs[activeTab]
		prev.frame.Visible = false
		TweenService:Create(prev.indicator, TWEEN_FAST, {BackgroundTransparency = 1}):Play()
		TweenService:Create(prev.button, TWEEN_FAST, {BackgroundColor3 = THEME.Sidebar}):Play()
		TweenService:Create(prev.label, TWEEN_FAST, {TextColor3 = THEME.TextDim}):Play()
		TweenService:Create(prev.iconLabel, TWEEN_FAST, {TextColor3 = THEME.TextDim}):Play()
	end
	activeTab = name
	local curr = tabs[name]
	curr.frame.Visible = true
	TweenService:Create(curr.indicator, TWEEN_FAST, {BackgroundTransparency = 0}):Play()
	TweenService:Create(curr.button, TWEEN_FAST, {BackgroundColor3 = THEME.SurfaceHover}):Play()
	TweenService:Create(curr.label, TWEEN_FAST, {TextColor3 = THEME.Text}):Play()
	TweenService:Create(curr.iconLabel, TWEEN_FAST, {TextColor3 = THEME.Accent}):Play()
end

for _, data in ipairs(TAB_DATA) do
	local tabFrame = CreateTabFrame(data.name)
	local btn = Instance.new("TextButton")
	btn.Name = data.name .. "Tab"
	btn.Size = UDim2.new(1, 0, 0, 34)
	btn.BackgroundColor3 = THEME.Sidebar
	btn.BackgroundTransparency = 0
	btn.BorderSizePixel = 0
	btn.Text = ""
	btn.LayoutOrder = data.order
	btn.AutoButtonColor = false
	btn.Parent = sidebarButtons
	local bc = Instance.new("UICorner")
	bc.CornerRadius = UDim.new(0, 6)
	bc.Parent = btn
	local indicator = Instance.new("Frame")
	indicator.Size = UDim2.new(0, 3, 0, 18)
	indicator.Position = UDim2.new(0, 0, 0.5, -9)
	indicator.BackgroundColor3 = THEME.Accent
	indicator.BackgroundTransparency = 1
	indicator.BorderSizePixel = 0
	indicator.Parent = btn
	local ic = Instance.new("UICorner")
	ic.CornerRadius = UDim.new(0, 2)
	ic.Parent = indicator
	local iconLabel = Instance.new("TextLabel")
	iconLabel.Size = UDim2.new(0, 24, 1, 0)
	iconLabel.Position = UDim2.new(0, 10, 0, 0)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Text = data.icon
	iconLabel.TextColor3 = THEME.TextDim
	iconLabel.TextSize = 14
	iconLabel.Font = FONT_BODY
	iconLabel.Parent = btn
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -40, 1, 0)
	label.Position = UDim2.new(0, 38, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = data.name
	label.TextColor3 = THEME.TextDim
	label.TextSize = 12
	label.Font = FONT_SEMI
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = btn
	tabs[data.name] = {
		button = btn,
		frame = tabFrame,
		indicator = indicator,
		label = label,
		iconLabel = iconLabel,
	}
	RegisterUISignal("Tab_Enter_" .. data.name, btn.MouseEnter:Connect(function()
		if activeTab ~= data.name then
			TweenService:Create(btn, TWEEN_FAST, {BackgroundColor3 = THEME.Surface}):Play()
			TweenService:Create(label, TWEEN_FAST, {TextColor3 = THEME.Text}):Play()
		end
	end))
	RegisterUISignal("Tab_Leave_" .. data.name, btn.MouseLeave:Connect(function()
		if activeTab ~= data.name then
			TweenService:Create(btn, TWEEN_FAST, {BackgroundColor3 = THEME.Sidebar}):Play()
			TweenService:Create(label, TWEEN_FAST, {TextColor3 = THEME.TextDim}):Play()
		end
	end))
	RegisterUISignal("Tab_Click_" .. data.name, btn.MouseButton1Click:Connect(function()
		SwitchTab(data.name)
	end))
end

local function CreateSectionHeader(parent, text, order)
	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 28)
	header.BackgroundTransparency = 1
	header.LayoutOrder = order or 0
	header.Parent = parent
	local lb = Instance.new("TextLabel")
	lb.Size = UDim2.new(1, 0, 1, 0)
	lb.BackgroundTransparency = 1
	lb.Text = "> " .. string.upper(text)
	lb.TextColor3 = THEME.Accent
	lb.TextSize = 11
	lb.Font = FONT_BOLD
	lb.TextXAlignment = Enum.TextXAlignment.Left
	lb.Parent = header
	local line = Instance.new("Frame")
	line.Size = UDim2.new(1, 0, 0, 1)
	line.Position = UDim2.new(0, 0, 1, -2)
	line.BackgroundColor3 = THEME.AccentDim
	line.BackgroundTransparency = 0.6
	line.BorderSizePixel = 0
	line.Parent = header
	return header
end

local function CreateToggle(parent, text, configKey, startFn, stopFn, order)
	local holder = Instance.new("Frame")
	holder.Name = "Toggle_" .. configKey
	holder.Size = UDim2.new(1, 0, 0, 32)
	holder.BackgroundColor3 = THEME.Surface
	holder.BorderSizePixel = 0
	holder.LayoutOrder = order or 0
	holder.Parent = parent
	local hc = Instance.new("UICorner")
	hc.CornerRadius = UDim.new(0, 6)
	hc.Parent = holder
	local lb = Instance.new("TextLabel")
	lb.Size = UDim2.new(1, -60, 1, 0)
	lb.Position = UDim2.new(0, 12, 0, 0)
	lb.BackgroundTransparency = 1
	lb.Text = text
	lb.TextColor3 = THEME.Text
	lb.TextSize = 12
	lb.Font = FONT_SEMI
	lb.TextXAlignment = Enum.TextXAlignment.Left
	lb.Parent = holder
	local switchBg = Instance.new("Frame")
	switchBg.Size = UDim2.new(0, 36, 0, 18)
	switchBg.Position = UDim2.new(1, -48, 0.5, -9)
	switchBg.BackgroundColor3 = Config[configKey] and THEME.Accent or THEME.Border
	switchBg.BorderSizePixel = 0
	switchBg.Parent = holder
	local sbc = Instance.new("UICorner")
	sbc.CornerRadius = UDim.new(1, 0)
	sbc.Parent = switchBg
	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 14, 0, 14)
	knob.Position = Config[configKey] and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
	knob.BackgroundColor3 = Color3.new(1, 1, 1)
	knob.BorderSizePixel = 0
	knob.Parent = switchBg
	local kc = Instance.new("UICorner")
	kc.CornerRadius = UDim.new(1, 0)
	kc.Parent = knob
	local clickArea = Instance.new("TextButton")
	clickArea.Size = UDim2.new(1, 0, 1, 0)
	clickArea.BackgroundTransparency = 1
	clickArea.Text = ""
	clickArea.ZIndex = 3
	clickArea.Parent = holder
	local enabled = Config[configKey] or false
	local function UpdateVisual()
		if enabled then
			TweenService:Create(switchBg, TWEEN_SMOOTH, {BackgroundColor3 = THEME.Accent}):Play()
			TweenService:Create(knob, TWEEN_SMOOTH, {Position = UDim2.new(1, -16, 0.5, -7)}):Play()
		else
			TweenService:Create(switchBg, TWEEN_SMOOTH, {BackgroundColor3 = THEME.Border}):Play()
			TweenService:Create(knob, TWEEN_SMOOTH, {Position = UDim2.new(0, 2, 0.5, -7)}):Play()
		end
	end
	RegisterUISignal("Tog_" .. configKey, clickArea.MouseButton1Click:Connect(function()
		enabled = not enabled
		Config[configKey] = enabled
		UpdateVisual()
		if enabled then
			if startFn then pcall(startFn) end
		else
			if stopFn then pcall(stopFn) end
		end
	end))
	RegisterUISignal("TogHov_" .. configKey, clickArea.MouseEnter:Connect(function()
		TweenService:Create(holder, TWEEN_FAST, {BackgroundColor3 = THEME.SurfaceHover}):Play()
	end))
	RegisterUISignal("TogOut_" .. configKey, clickArea.MouseLeave:Connect(function()
		TweenService:Create(holder, TWEEN_FAST, {BackgroundColor3 = THEME.Surface}):Play()
	end))
	return holder
end

local function CreateSlider(parent, text, configKey, min, max, step, order)
	local holder = Instance.new("Frame")
	holder.Name = "Slider_" .. configKey
	holder.Size = UDim2.new(1, 0, 0, 46)
	holder.BackgroundColor3 = THEME.Surface
	holder.BorderSizePixel = 0
	holder.LayoutOrder = order or 0
	holder.Parent = parent
	local hc = Instance.new("UICorner")
	hc.CornerRadius = UDim.new(0, 6)
	hc.Parent = holder
	local lb = Instance.new("TextLabel")
	lb.Size = UDim2.new(1, -60, 0, 18)
	lb.Position = UDim2.new(0, 12, 0, 4)
	lb.BackgroundTransparency = 1
	lb.Text = text
	lb.TextColor3 = THEME.Text
	lb.TextSize = 11
	lb.Font = FONT_SEMI
	lb.TextXAlignment = Enum.TextXAlignment.Left
	lb.Parent = holder
	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(0, 50, 0, 18)
	valueLabel.Position = UDim2.new(1, -58, 0, 4)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Text = tostring(Config[configKey] or min)
	valueLabel.TextColor3 = THEME.Accent
	valueLabel.TextSize = 11
	valueLabel.Font = FONT_BOLD
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.Parent = holder
	local track = Instance.new("Frame")
	track.Size = UDim2.new(1, -24, 0, 6)
	track.Position = UDim2.new(0, 12, 0, 30)
	track.BackgroundColor3 = THEME.Border
	track.BorderSizePixel = 0
	track.Parent = holder
	local trc = Instance.new("UICorner")
	trc.CornerRadius = UDim.new(1, 0)
	trc.Parent = track
	local initVal = Config[configKey] or min
	local initPct = math.clamp((initVal - min) / (max - min), 0, 1)
	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(initPct, 0, 1, 0)
	fill.BackgroundColor3 = THEME.Accent
	fill.BorderSizePixel = 0
	fill.Parent = track
	local fc = Instance.new("UICorner")
	fc.CornerRadius = UDim.new(1, 0)
	fc.Parent = fill
	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 14, 0, 14)
	knob.Position = UDim2.new(initPct, -7, 0.5, -7)
	knob.BackgroundColor3 = Color3.new(1, 1, 1)
	knob.BorderSizePixel = 0
	knob.ZIndex = 3
	knob.Parent = track
	local knc = Instance.new("UICorner")
	knc.CornerRadius = UDim.new(1, 0)
	knc.Parent = knob
	local inputArea = Instance.new("TextButton")
	inputArea.Size = UDim2.new(1, 0, 0, 20)
	inputArea.Position = UDim2.new(0, 0, 0, 22)
	inputArea.BackgroundTransparency = 1
	inputArea.Text = ""
	inputArea.ZIndex = 4
	inputArea.Parent = holder
	local dragging = false
	local function UpdateSlider(inputX)
		local tPos = track.AbsolutePosition.X
		local tSize = track.AbsoluteSize.X
		local pct = math.clamp((inputX - tPos) / tSize, 0, 1)
		local raw = min + (max - min) * pct
		local stepped = math.floor(raw / step + 0.5) * step
		stepped = math.clamp(stepped, min, max)
		local finalPct = (stepped - min) / (max - min)
		fill.Size = UDim2.new(finalPct, 0, 1, 0)
		knob.Position = UDim2.new(finalPct, -7, 0.5, -7)
		valueLabel.Text = tostring(stepped)
		Config[configKey] = stepped
	end
	RegisterUISignal("SlDown_" .. configKey, inputArea.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			UpdateSlider(input.Position.X)
		end
	end))
	RegisterUISignal("SlUp_" .. configKey, UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end))
	RegisterUISignal("SlMove_" .. configKey, UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch) then
			UpdateSlider(input.Position.X)
		end
	end))
	RegisterUISignal("SlHov_" .. configKey, inputArea.MouseEnter:Connect(function()
		TweenService:Create(holder, TWEEN_FAST, {BackgroundColor3 = THEME.SurfaceHover}):Play()
	end))
	RegisterUISignal("SlOut_" .. configKey, inputArea.MouseLeave:Connect(function()
		TweenService:Create(holder, TWEEN_FAST, {BackgroundColor3 = THEME.Surface}):Play()
	end))
	return holder
end

do
	local tab = tabs["Combat"].frame
	CreateSectionHeader(tab, "Aimbot", 1)
	CreateToggle(tab, "Enable Aimbot", "Aimbot_Enabled", Fn.StartAimbot, Fn.StopAimbot, 2)
	CreateToggle(tab, "Show FOV Circle", "Aimbot_ShowFOV", nil, nil, 3)
	CreateToggle(tab, "Team Check", "Aimbot_TeamCheck", nil, nil, 4)
	CreateSlider(tab, "FOV Radius", "Aimbot_FOVRadius", 50, 500, 10, 5)
	CreateSlider(tab, "Smoothing", "Aimbot_Smoothing", 5, 100, 5, 6)
	CreateSectionHeader(tab, "Silent Aim", 10)
	CreateToggle(tab, "Enable Silent Aim", "SilentAim_Enabled", Fn.StartSilentAim, Fn.StopSilentAim, 11)
	CreateSlider(tab, "Hit Chance %", "SilentAim_Hitchance", 1, 100, 1, 12)
	CreateSectionHeader(tab, "Weapon Mods", 20)
	CreateToggle(tab, "No Recoil", "NoRecoil_Enabled", Fn.StartNoRecoilSpread, Fn.StopNoRecoilSpread, 21)
	CreateToggle(tab, "No Spread", "NoSpread_Enabled", Fn.StartNoRecoilSpread, Fn.StopNoRecoilSpread, 22)
	CreateSectionHeader(tab, "Advanced", 30)
	CreateToggle(tab, "Trigger Bot", "TriggerBot_Enabled", Fn.StartTriggerBot, Fn.StopTriggerBot, 31)
	CreateToggle(tab, "Prediction", "Prediction_Enabled", nil, nil, 32)
	CreateToggle(tab, "Hit Sounds", "HitSound_Enabled", Fn.StartHitSounds, Fn.StopHitSounds, 33)
	CreateSectionHeader(tab, "Protection", 40)
	CreateToggle(tab, "Meta Bypass (AC)", "MetaBypass_Enabled", Fn.StartMetaBypass, Fn.StopMetaBypass, 41)
	CreateToggle(tab, "Auto Stomp", "AutoStomp_Enabled", Fn.StartAutoStomp, Fn.StopAutoStomp, 42)
	CreateSlider(tab, "Stomp Range", "AutoStomp_Range", 5, 50, 1, 43)
	CreateSectionHeader(tab, "Gun Mods", 50)
	CreateToggle(tab, "Instant Reload", "InstantReload_Enabled", Fn.StartInstantReload, Fn.StopInstantReload, 51)
	CreateToggle(tab, "Bullet Tracers", "BulletTracers_Enabled", Fn.StartBulletTracers, Fn.StopBulletTracers, 52)
	CreateSectionHeader(tab, "Hitbox", 60)
	CreateToggle(tab, "Head Enlargement", "HeadSize_Enabled", Fn.StartHeadSize, Fn.StopHeadSize, 61)
	CreateSlider(tab, "Head Size", "HeadSize", 1, 10, 1, 62)
end

do
	local tab = tabs["Visuals"].frame
	CreateSectionHeader(tab, "ESP", 1)
	CreateToggle(tab, "Enable ESP", "ESP_Enabled", Fn.StartESP, Fn.StopESP, 2)
	CreateToggle(tab, "Boxes", "ESP_Boxes", nil, nil, 3)
	CreateToggle(tab, "Names", "ESP_Names", nil, nil, 4)
	CreateToggle(tab, "Health Bars", "ESP_Health", nil, nil, 5)
	CreateToggle(tab, "Distance", "ESP_Distance", nil, nil, 6)
	CreateToggle(tab, "Team Check", "ESP_TeamCheck", nil, nil, 7)
	CreateSlider(tab, "Max Distance", "ESP_MaxDistance", 100, 3000, 50, 8)
	CreateSectionHeader(tab, "Skeleton", 10)
	CreateToggle(tab, "Skeleton ESP", "ESP_Skeleton", nil, nil, 11)
	CreateSectionHeader(tab, "Tracers & Angles", 20)
	CreateToggle(tab, "Tracers", "ESP_Tracers", nil, nil, 21)
	CreateToggle(tab, "View Angles", "ESP_ViewAngles", nil, nil, 22)
	CreateSectionHeader(tab, "World", 30)
	CreateToggle(tab, "FullBright", "FullBright_Enabled", Fn.StartFullBright, Fn.StopFullBright, 31)
	CreateToggle(tab, "PP Bypass", "PPBypass_Enabled", Fn.StartPPBypass, Fn.StopPPBypass, 32)
	CreateSectionHeader(tab, "Cinematic", 40)
	CreateSlider(tab, "Exposure", "Exposure", -100, 100, 5, 41)
	CreateSlider(tab, "Contrast", "Contrast", -100, 100, 5, 42)
	CreateSectionHeader(tab, "Crosshair", 50)
	CreateToggle(tab, "Custom Crosshair", "CustomCrosshair_Enabled", Fn.StartCustomCrosshair, Fn.StopCustomCrosshair, 51)
	CreateSlider(tab, "Crosshair Size", "CrosshairSize", 4, 30, 1, 52)
	CreateSectionHeader(tab, "Environment", 60)
	CreateToggle(tab, "Time/Fog Control", "TimeOfDay", Fn.StartTimeChanger, Fn.StopTimeChanger, 61)
	CreateSlider(tab, "Time of Day", "TimeOfDay", 0, 24, 1, 62)
	CreateSlider(tab, "Fog Start", "FogStart_Val", 0, 5000, 50, 63)
	CreateSlider(tab, "Fog End", "FogEnd_Val", 100, 100000, 500, 64)
	CreateToggle(tab, "Rainbow ESP/UI", "RainbowUI_Enabled", Fn.StartRainbowUI, Fn.StopRainbowUI, 65)
	CreateSectionHeader(tab, "Atmosphere", 70)
	CreateToggle(tab, "Ambient Control", "AmbientR", Fn.StartAmbientColor, Fn.StopAmbientColor, 71)
	CreateSlider(tab, "Ambient R", "AmbientR", 0, 255, 5, 72)
	CreateSlider(tab, "Ambient G", "AmbientG", 0, 255, 5, 73)
	CreateSlider(tab, "Ambient B", "AmbientB", 0, 255, 5, 74)
	CreateSlider(tab, "Outdoor R", "OutdoorR", 0, 255, 5, 75)
	CreateSlider(tab, "Outdoor G", "OutdoorG", 0, 255, 5, 76)
	CreateSlider(tab, "Outdoor B", "OutdoorB", 0, 255, 5, 77)
	CreateSectionHeader(tab, "Color Correction", 80)
	CreateToggle(tab, "Enable CC", "CC_Saturation", Fn.StartColorCorrection, Fn.StopColorCorrection, 81)
	CreateSlider(tab, "Saturation", "CC_Saturation", -100, 100, 5, 82)
	CreateSlider(tab, "Brightness", "CC_Brightness", -100, 100, 5, 83)
	CreateSectionHeader(tab, "Time", 90)
	CreateToggle(tab, "Clock Speed", "ClockSpeed", Fn.StartClockSpeed, Fn.StopClockSpeed, 91)
	CreateSlider(tab, "Speed Multi", "ClockSpeed", 1, 20, 1, 92)
end

do
	local tab = tabs["Utility"].frame
	CreateSectionHeader(tab, "Movement", 1)
	CreateToggle(tab, "Speed Override", "Speed_Enabled", Fn.StartSpeedJump, Fn.StopSpeedJump, 2)
	CreateSlider(tab, "WalkSpeed", "WalkSpeed", 16, 500, 1, 3)
	CreateSlider(tab, "JumpPower", "JumpPower", 50, 500, 5, 4)
	CreateSectionHeader(tab, "Exploits", 10)
	CreateToggle(tab, "Infinite Jump", "InfJump_Enabled", Fn.StartInfiniteJump, Fn.StopInfiniteJump, 11)
	CreateToggle(tab, "Noclip", "Noclip_Enabled", Fn.StartNoclip, Fn.StopNoclip, 12)
	CreateSectionHeader(tab, "Flight", 20)
	CreateToggle(tab, "Enable Fly", "Fly_Enabled", Fn.StartFly, Fn.StopFly, 21)
	CreateSlider(tab, "Fly Speed", "Fly_Speed", 20, 300, 5, 22)
	CreateSectionHeader(tab, "Anti-Kick", 30)
	CreateToggle(tab, "Anti-AFK", "AntiAFK_Enabled", Fn.StartAntiAFK, Fn.StopAntiAFK, 31)
	CreateSectionHeader(tab, "Anti-Aim", 40)
	CreateToggle(tab, "SpinBot", "SpinBot_Enabled", Fn.StartSpinBot, Fn.StopSpinBot, 41)
	CreateSlider(tab, "Spin Speed", "SpinBot_Speed", 5, 50, 1, 42)
	CreateSectionHeader(tab, "Navigation", 50)
	CreateToggle(tab, "Breadcrumbs", "Breadcrumbs_Enabled", Fn.StartBreadcrumbs, Fn.StopBreadcrumbs, 51)
end

do
	local tab = tabs["Settings"].frame
	CreateSectionHeader(tab, "Interface", 1)
	local hint = Instance.new("Frame")
	hint.Size = UDim2.new(1, 0, 0, 32)
	hint.BackgroundColor3 = THEME.Surface
	hint.BorderSizePixel = 0
	hint.LayoutOrder = 2
	hint.Parent = tab
	local hic = Instance.new("UICorner")
	hic.CornerRadius = UDim.new(0, 6)
	hic.Parent = hint
	local ht = Instance.new("TextLabel")
	ht.Size = UDim2.new(1, -24, 1, 0)
	ht.Position = UDim2.new(0, 12, 0, 0)
	ht.BackgroundTransparency = 1
	ht.Text = "Toggle UI:  Right Ctrl"
	ht.TextColor3 = THEME.TextDim
	ht.TextSize = 11
	ht.Font = FONT_SEMI
	ht.TextXAlignment = Enum.TextXAlignment.Left
	ht.Parent = hint
	CreateSectionHeader(tab, "Theme", 3)
	CreateSlider(tab, "Accent R", "AccentR", 0, 255, 5, 4)
	CreateSlider(tab, "Accent G", "AccentG", 0, 255, 5, 5)
	CreateSlider(tab, "Accent B", "AccentB", 0, 255, 5, 6)
	CreateSlider(tab, "Menu Opacity", "MenuTransparency", 0, 80, 5, 7)
	CreateSectionHeader(tab, "Effects", 8)
	CreateToggle(tab, "Cinematic Intro", "Intro_Enabled", nil, nil, 9)
	CreateToggle(tab, "RGB Border Glow", "RGBGlow_Enabled", nil, nil, 10)
	CreateSectionHeader(tab, "Danger Zone", 11)
	local ejectBtn = Instance.new("TextButton")
	ejectBtn.Size = UDim2.new(1, 0, 0, 36)
	ejectBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 25)
	ejectBtn.BorderSizePixel = 0
	ejectBtn.Text = "FULL EJECT"
	ejectBtn.TextColor3 = THEME.Negative
	ejectBtn.TextSize = 12
	ejectBtn.Font = FONT_BOLD
	ejectBtn.LayoutOrder = 11
	ejectBtn.AutoButtonColor = false
	ejectBtn.Parent = tab
	local ec = Instance.new("UICorner")
	ec.CornerRadius = UDim.new(0, 6)
	ec.Parent = ejectBtn
	RegisterUISignal("Eject_Hov", ejectBtn.MouseEnter:Connect(function()
		TweenService:Create(ejectBtn, TWEEN_FAST, {BackgroundColor3 = Color3.fromRGB(90, 25, 30)}):Play()
	end))
	RegisterUISignal("Eject_Out", ejectBtn.MouseLeave:Connect(function()
		TweenService:Create(ejectBtn, TWEEN_FAST, {BackgroundColor3 = Color3.fromRGB(60, 20, 25)}):Play()
	end))
	RegisterUISignal("Eject_Click", ejectBtn.MouseButton1Click:Connect(function()
		DisconnectAllUISignals()
		pcall(function() Fn.FullEject() end)
		pcall(function() screenGui:Destroy() end)
	end))
	CreateSectionHeader(tab, "Info", 20)
	local infoFrame = Instance.new("Frame")
	infoFrame.Size = UDim2.new(1, 0, 0, 50)
	infoFrame.BackgroundColor3 = THEME.Surface
	infoFrame.BorderSizePixel = 0
	infoFrame.LayoutOrder = 21
	infoFrame.Parent = tab
	local ifc = Instance.new("UICorner")
	ifc.CornerRadius = UDim.new(0, 6)
	ifc.Parent = infoFrame
	local it = Instance.new("TextLabel")
	it.Size = UDim2.new(1, -24, 1, 0)
	it.Position = UDim2.new(0, 12, 0, 0)
	it.BackgroundTransparency = 1
	it.Text = "MEDUSA v16.0 Unified\nAimbot + ESP + Utility\nRight Ctrl = Toggle UI"
	it.TextColor3 = THEME.TextDim
	it.TextSize = 10
	it.Font = FONT_BODY
	it.TextXAlignment = Enum.TextXAlignment.Left
	it.TextYAlignment = Enum.TextYAlignment.Center
	it.TextWrapped = true
	it.Parent = infoFrame
end

do
	local tab = tabs["Teleport"].frame
	CreateSectionHeader(tab, "Player Teleport", 1)
	local listHolder = Instance.new("Frame")
	listHolder.Size = UDim2.new(1, 0, 0, 180)
	listHolder.BackgroundColor3 = THEME.Surface
	listHolder.BorderSizePixel = 0
	listHolder.LayoutOrder = 2
	listHolder.Parent = tab
	local lhc = Instance.new("UICorner")
	lhc.CornerRadius = UDim.new(0, 6)
	lhc.Parent = listHolder
	local scrollList = Instance.new("ScrollingFrame")
	scrollList.Size = UDim2.new(1, -8, 1, -8)
	scrollList.Position = UDim2.new(0, 4, 0, 4)
	scrollList.BackgroundTransparency = 1
	scrollList.BorderSizePixel = 0
	scrollList.ScrollBarThickness = 2
	scrollList.ScrollBarImageColor3 = THEME.Accent
	scrollList.CanvasSize = UDim2.new(0, 0, 0, 0)
	scrollList.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scrollList.Parent = listHolder
	local sll = Instance.new("UIListLayout")
	sll.SortOrder = Enum.SortOrder.LayoutOrder
	sll.Padding = UDim.new(0, 2)
	sll.Parent = scrollList
	local function RefreshPlayers()
		for _, c in ipairs(scrollList:GetChildren()) do
			if c:IsA("TextButton") then c:Destroy() end
		end
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer then
				local btn = Instance.new("TextButton")
				btn.Size = UDim2.new(1, 0, 0, 26)
				btn.BackgroundColor3 = THEME.Surface
				btn.BorderSizePixel = 0
				btn.Text = "  " .. plr.DisplayName
				btn.TextColor3 = THEME.Text
				btn.TextSize = 11
				btn.Font = FONT_BODY
				btn.TextXAlignment = Enum.TextXAlignment.Left
				btn.AutoButtonColor = false
				btn.Parent = scrollList
				local bc = Instance.new("UICorner")
				bc.CornerRadius = UDim.new(0, 4)
				bc.Parent = btn
				btn.MouseEnter:Connect(function()
					TweenService:Create(btn, TWEEN_FAST, {BackgroundColor3 = THEME.SurfaceHover}):Play()
				end)
				btn.MouseLeave:Connect(function()
					TweenService:Create(btn, TWEEN_FAST, {BackgroundColor3 = THEME.Surface}):Play()
				end)
				btn.MouseButton1Click:Connect(function()
					pcall(function() Fn.TeleportToPlayer(plr.Name) end)
				end)
			end
		end
	end
	RefreshPlayers()
	local refreshBtn = Instance.new("TextButton")
	refreshBtn.Size = UDim2.new(1, 0, 0, 30)
	refreshBtn.BackgroundColor3 = THEME.AccentDim
	refreshBtn.BorderSizePixel = 0
	refreshBtn.Text = "Refresh List"
	refreshBtn.TextColor3 = THEME.Text
	refreshBtn.TextSize = 11
	refreshBtn.Font = FONT_SEMI
	refreshBtn.LayoutOrder = 3
	refreshBtn.AutoButtonColor = false
	refreshBtn.Parent = tab
	local rc = Instance.new("UICorner")
	rc.CornerRadius = UDim.new(0, 6)
	rc.Parent = refreshBtn
	RegisterUISignal("TP_Refresh_Hov", refreshBtn.MouseEnter:Connect(function()
		TweenService:Create(refreshBtn, TWEEN_FAST, {BackgroundColor3 = THEME.Accent}):Play()
	end))
	RegisterUISignal("TP_Refresh_Out", refreshBtn.MouseLeave:Connect(function()
		TweenService:Create(refreshBtn, TWEEN_FAST, {BackgroundColor3 = THEME.AccentDim}):Play()
	end))
	RegisterUISignal("TP_Refresh_Click", refreshBtn.MouseButton1Click:Connect(function()
		RefreshPlayers()
	end))
	CreateSectionHeader(tab, "Coordinate TP", 10)
	local coordHolder = Instance.new("Frame")
	coordHolder.Size = UDim2.new(1, 0, 0, 32)
	coordHolder.BackgroundColor3 = THEME.Surface
	coordHolder.BorderSizePixel = 0
	coordHolder.LayoutOrder = 11
	coordHolder.Parent = tab
	local chc = Instance.new("UICorner")
	chc.CornerRadius = UDim.new(0, 6)
	chc.Parent = coordHolder
	local coordInfo = Instance.new("TextLabel")
	coordInfo.Size = UDim2.new(1, -24, 1, 0)
	coordInfo.Position = UDim2.new(0, 12, 0, 0)
	coordInfo.BackgroundTransparency = 1
	coordInfo.Text = "Use Fn.TeleportToCoord(Vector3.new(x,y,z))"
	coordInfo.TextColor3 = THEME.TextDim
	coordInfo.TextSize = 10
	coordInfo.Font = FONT_BODY
	coordInfo.TextXAlignment = Enum.TextXAlignment.Left
	coordInfo.Parent = coordHolder
end

do
	local tab = tabs["HUD"].frame
	CreateSectionHeader(tab, "Target Info", 1)
	CreateToggle(tab, "Target Predator", "TargetPredator_Enabled", nil, nil, 2)
	CreateSectionHeader(tab, "Notifications", 10)
	CreateToggle(tab, "Kill Popups", "KillPopups_Enabled", Fn.StartKillPopups, Fn.StopKillPopups, 11)
	CreateSectionHeader(tab, "Awareness", 20)
	CreateToggle(tab, "Spectator List", "SpectatorList_Enabled", Fn.StartSpectatorList, Fn.StopSpectatorList, 21)
end

do
	local predatorFrame = Instance.new("Frame")
	predatorFrame.Name = "TargetPredator"
	predatorFrame.Size = UDim2.new(0, 200, 0, 70)
	predatorFrame.Position = UDim2.new(1, -210, 0, 50)
	predatorFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
	predatorFrame.BackgroundTransparency = 0.15
	predatorFrame.BorderSizePixel = 0
	predatorFrame.Visible = false
	predatorFrame.Parent = screenGui
	local pfc = Instance.new("UICorner")
	pfc.CornerRadius = UDim.new(0, 8)
	pfc.Parent = predatorFrame
	local pfs = Instance.new("UIStroke")
	pfs.Color = Color3.fromRGB(130, 80, 255)
	pfs.Thickness = 1
	pfs.Transparency = 0.5
	pfs.Parent = predatorFrame
	local pName = Instance.new("TextLabel")
	pName.Name = "TargetName"
	pName.Size = UDim2.new(1, -16, 0, 20)
	pName.Position = UDim2.new(0, 8, 0, 6)
	pName.BackgroundTransparency = 1
	pName.Text = "No Target"
	pName.TextColor3 = Color3.fromRGB(220, 220, 230)
	pName.TextSize = 12
	pName.Font = Enum.Font.GothamBold
	pName.TextXAlignment = Enum.TextXAlignment.Left
	pName.Parent = predatorFrame
	local pHPBg = Instance.new("Frame")
	pHPBg.Size = UDim2.new(1, -16, 0, 8)
	pHPBg.Position = UDim2.new(0, 8, 0, 30)
	pHPBg.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
	pHPBg.BorderSizePixel = 0
	pHPBg.Parent = predatorFrame
	local phbc = Instance.new("UICorner")
	phbc.CornerRadius = UDim.new(1, 0)
	phbc.Parent = pHPBg
	local pHPFill = Instance.new("Frame")
	pHPFill.Name = "HPFill"
	pHPFill.Size = UDim2.new(1, 0, 1, 0)
	pHPFill.BackgroundColor3 = Color3.fromRGB(80, 220, 120)
	pHPFill.BorderSizePixel = 0
	pHPFill.Parent = pHPBg
	local phfc = Instance.new("UICorner")
	phfc.CornerRadius = UDim.new(1, 0)
	phfc.Parent = pHPFill
	local pDist = Instance.new("TextLabel")
	pDist.Name = "TargetDist"
	pDist.Size = UDim2.new(1, -16, 0, 18)
	pDist.Position = UDim2.new(0, 8, 0, 44)
	pDist.BackgroundTransparency = 1
	pDist.Text = "0m"
	pDist.TextColor3 = Color3.fromRGB(120, 120, 140)
	pDist.TextSize = 10
	pDist.Font = Enum.Font.Gotham
	pDist.TextXAlignment = Enum.TextXAlignment.Left
	pDist.Parent = predatorFrame
	RegisterUISignal("Predator_RS", RunService.RenderStepped:Connect(function()
		if not _G.MedusaLoaded then return end
		if not Config.TargetPredator_Enabled then
			predatorFrame.Visible = false
			return
		end
		local target = Fn.GetClosestPlayer()
		if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
			predatorFrame.Visible = true
			pName.Text = target.DisplayName
			local hum = target.Character:FindFirstChildOfClass("Humanoid")
			if hum then
				local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
				pHPFill.Size = UDim2.new(pct, 0, 1, 0)
				pHPFill.BackgroundColor3 = Color3.fromRGB(255 * (1 - pct), 220 * pct, 80 * pct)
			end
			local myHRP = GetRootPart()
			if myHRP then
				local d = math.floor((myHRP.Position - target.Character.HumanoidRootPart.Position).Magnitude)
				pDist.Text = d .. "m"
			end
		else
			predatorFrame.Visible = false
		end
	end))
	local popupContainer = Instance.new("Frame")
	popupContainer.Name = "KillPopups"
	popupContainer.Size = UDim2.new(0, 300, 0, 200)
	popupContainer.Position = UDim2.new(0.5, -150, 0, 80)
	popupContainer.BackgroundTransparency = 1
	popupContainer.Parent = screenGui
	RegisterUISignal("KillPopup_RS", RunService.RenderStepped:Connect(function()
		if not _G.MedusaLoaded or not Config.KillPopups_Enabled then return end
		local queue = Fn.GetKillPopupQueue()
		while #queue > 0 do
			local kill = table.remove(queue, 1)
			local popup = Instance.new("TextLabel")
			popup.Size = UDim2.new(1, 0, 0, 30)
			popup.BackgroundTransparency = 1
			popup.Text = "ELIMINATED " .. string.upper(kill.name)
			popup.TextColor3 = Color3.fromRGB(255, 60, 60)
			popup.TextStrokeTransparency = 0.5
			popup.TextStrokeColor3 = Color3.new(0, 0, 0)
			popup.TextSize = 18
			popup.Font = Enum.Font.GothamBold
			popup.Parent = popupContainer
			task.spawn(function()
				task.wait(2)
				if popup and popup.Parent then
					TweenService:Create(popup, TweenInfo.new(0.5), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
					task.wait(0.6)
					if popup.Parent then popup:Destroy() end
				end
			end)
		end
	end))
	local specFrame = Instance.new("Frame")
	specFrame.Name = "SpectatorDisplay"
	specFrame.Size = UDim2.new(0, 160, 0, 120)
	specFrame.Position = UDim2.new(0, 10, 0.5, -60)
	specFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
	specFrame.BackgroundTransparency = 0.2
	specFrame.BorderSizePixel = 0
	specFrame.Visible = false
	specFrame.Parent = screenGui
	local spc = Instance.new("UICorner")
	spc.CornerRadius = UDim.new(0, 6)
	spc.Parent = specFrame
	local sps = Instance.new("UIStroke")
	sps.Color = Color3.fromRGB(130, 80, 255)
	sps.Thickness = 1
	sps.Transparency = 0.6
	sps.Parent = specFrame
	local specTitle = Instance.new("TextLabel")
	specTitle.Size = UDim2.new(1, -8, 0, 18)
	specTitle.Position = UDim2.new(0, 4, 0, 4)
	specTitle.BackgroundTransparency = 1
	specTitle.Text = "SPECTATORS"
	specTitle.TextColor3 = Color3.fromRGB(130, 80, 255)
	specTitle.TextSize = 10
	specTitle.Font = Enum.Font.GothamBold
	specTitle.TextXAlignment = Enum.TextXAlignment.Left
	specTitle.Parent = specFrame
	local specList = Instance.new("TextLabel")
	specList.Name = "SpecList"
	specList.Size = UDim2.new(1, -8, 1, -24)
	specList.Position = UDim2.new(0, 4, 0, 22)
	specList.BackgroundTransparency = 1
	specList.Text = ""
	specList.TextColor3 = Color3.fromRGB(220, 220, 230)
	specList.TextSize = 10
	specList.Font = Enum.Font.Gotham
	specList.TextXAlignment = Enum.TextXAlignment.Left
	specList.TextYAlignment = Enum.TextYAlignment.Top
	specList.TextWrapped = true
	specList.Parent = specFrame
	RegisterUISignal("SpecDisplay_RS", RunService.Heartbeat:Connect(function()
		if not _G.MedusaLoaded then return end
		if not Config.SpectatorList_Enabled then
			specFrame.Visible = false
			return
		end
		local list = Fn.GetSpectatorList()
		if #list > 0 then
			specFrame.Visible = true
			specList.Text = table.concat(list, "\n")
		else
			specFrame.Visible = false
		end
	end))
end

SwitchTab("Combat")

local function PlayCinematicIntro()
	mainFrame.Visible = false
	local introScreen = Instance.new("Frame")
	introScreen.Size = UDim2.new(1, 0, 1, 0)
	introScreen.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	introScreen.BackgroundTransparency = 0
	introScreen.BorderSizePixel = 0
	introScreen.ZIndex = 9999
	introScreen.Parent = screenGui
	local introLogo = Instance.new("TextLabel")
	introLogo.Size = UDim2.new(1, 0, 0, 70)
	introLogo.Position = UDim2.new(0, 0, 0.5, -70)
	introLogo.BackgroundTransparency = 1
	introLogo.RichText = true
	introLogo.Text = "<font color=\"#00C96B\">M E D U S A</font> <font color=\"#00C96B\">🐍</font><font color=\"#00FF7F\">💚</font>"
	introLogo.TextColor3 = Color3.fromRGB(0, 201, 107)
	introLogo.TextSize = 48
	introLogo.Font = Enum.Font.GothamBold
	introLogo.TextTransparency = 1
	introLogo.ZIndex = 10001
	introLogo.Parent = introScreen
	local logoGlow = Instance.new("UIStroke")
	logoGlow.Color = Color3.fromRGB(0, 201, 107)
	logoGlow.Thickness = 0
	logoGlow.Transparency = 0.2
	logoGlow.Parent = introLogo
	local introSlogan = Instance.new("TextLabel")
	introSlogan.Size = UDim2.new(1, 0, 0, 22)
	introSlogan.Position = UDim2.new(0, 0, 0.5, 8)
	introSlogan.BackgroundTransparency = 1
	introSlogan.Text = "Cinematic Edition  —  Perfection in Every Pixel"
	introSlogan.TextColor3 = Color3.fromRGB(0, 160, 85)
	introSlogan.TextSize = 14
	introSlogan.Font = Enum.Font.GothamMedium
	introSlogan.TextTransparency = 1
	introSlogan.ZIndex = 10001
	introSlogan.Parent = introScreen
	local barBg = Instance.new("Frame")
	barBg.Size = UDim2.new(0, 300, 0, 4)
	barBg.Position = UDim2.new(0.5, -150, 0.5, 48)
	barBg.BackgroundColor3 = Color3.fromRGB(15, 25, 18)
	barBg.BackgroundTransparency = 0
	barBg.BorderSizePixel = 0
	barBg.ZIndex = 10001
	barBg.Parent = introScreen
	Instance.new("UICorner", barBg).CornerRadius = UDim.new(0, 3)
	local barStroke = Instance.new("UIStroke")
	barStroke.Color = Color3.fromRGB(0, 100, 55)
	barStroke.Thickness = 1
	barStroke.Transparency = 0.5
	barStroke.Parent = barBg
	local barFill = Instance.new("Frame")
	barFill.Size = UDim2.new(0, 0, 1, 0)
	barFill.BackgroundColor3 = Color3.fromRGB(0, 201, 107)
	barFill.BorderSizePixel = 0
	barFill.ZIndex = 10002
	barFill.Parent = barBg
	Instance.new("UICorner", barFill).CornerRadius = UDim.new(0, 3)
	local barNeonGrad = Instance.new("UIGradient")
	barNeonGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 80, 40)),
		ColorSequenceKeypoint.new(0.3, Color3.fromRGB(0, 255, 130)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 255, 200)),
		ColorSequenceKeypoint.new(0.7, Color3.fromRGB(0, 255, 130)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 80, 40)),
	})
	barNeonGrad.Parent = barFill
	local barGlowOuter = Instance.new("UIStroke")
	barGlowOuter.Color = Color3.fromRGB(0, 201, 107)
	barGlowOuter.Thickness = 1.5
	barGlowOuter.Transparency = 0.3
	barGlowOuter.Parent = barFill
	local introStatus = Instance.new("TextLabel")
	introStatus.Size = UDim2.new(1, 0, 0, 18)
	introStatus.Position = UDim2.new(0, 0, 0.5, 62)
	introStatus.BackgroundTransparency = 1
	introStatus.Text = ""
	introStatus.TextColor3 = Color3.fromRGB(0, 140, 75)
	introStatus.TextSize = 11
	introStatus.Font = Enum.Font.Gotham
	introStatus.TextTransparency = 0.3
	introStatus.ZIndex = 10001
	introStatus.Parent = introScreen
	local pctLabel = Instance.new("TextLabel")
	pctLabel.Size = UDim2.new(0, 50, 0, 14)
	pctLabel.Position = UDim2.new(0.5, 160, 0.5, 44)
	pctLabel.BackgroundTransparency = 1
	pctLabel.Text = "0%"
	pctLabel.TextColor3 = Color3.fromRGB(0, 201, 107)
	pctLabel.TextSize = 10
	pctLabel.Font = Enum.Font.GothamBold
	pctLabel.TextXAlignment = Enum.TextXAlignment.Left
	pctLabel.TextTransparency = 0.3
	pctLabel.ZIndex = 10001
	pctLabel.Parent = introScreen
	local bootSound = nil
	pcall(function()
		bootSound = Instance.new("Sound")
		bootSound.SoundId = "rbxassetid://5502095102"
		bootSound.Volume = 0.7
		bootSound.Parent = game:GetService("SoundService")
	end)
	TweenService:Create(introLogo, TweenInfo.new(1.0, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		TextTransparency = 0,
	}):Play()
	task.spawn(function()
		local glowDir = 1
		local glowTrans = 0.2
		while introLogo and introLogo.Parent do
			glowTrans = glowTrans + (0.015 * glowDir)
			if glowTrans >= 0.8 then glowDir = -1
			elseif glowTrans <= 0.2 then glowDir = 1 end
			pcall(function() logoGlow.Transparency = glowTrans end)
			task.wait(0.03)
		end
	end)
	task.spawn(function()
		local neonOffset = 0
		while barFill and barFill.Parent do
			neonOffset = (neonOffset + 0.025) % 1
			pcall(function() barNeonGrad.Offset = Vector2.new(neonOffset, 0) end)
			task.wait(0.02)
		end
	end)
	task.wait(0.6)
	TweenService:Create(introSlogan, TweenInfo.new(0.7, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		TextTransparency = 0,
	}):Play()
	task.wait(0.4)
	pcall(function() if bootSound then bootSound:Play() end end)
	local stages = {
		{pct = 0.20, dur = 0.9,  msg = "Initializing Medusa Protocol..."},
		{pct = 0.50, dur = 1.2,  msg = "Bypassing Security Systems..."},
		{pct = 0.80, dur = 1.1,  msg = "Identifying Server Location..."},
		{pct = 1.00, dur = 0.8,  msg = "Synchronizing Interface..."},
	}
	for i, stage in ipairs(stages) do
		introStatus.Text = stage.msg
		pctLabel.Text = math.floor(stage.pct * 100) .. "%"
		TweenService:Create(barFill, TweenInfo.new(stage.dur, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Size = UDim2.new(stage.pct, 0, 1, 0),
		}):Play()
		if i == #stages then
			task.wait(stage.dur + 0.2)
			introStatus.Text = "Ready."
			introStatus.TextColor3 = Color3.fromRGB(0, 201, 107)
			introStatus.TextTransparency = 0
			pctLabel.Text = "100%"
			TweenService:Create(barGlowOuter, TweenInfo.new(0.3), {Transparency = 0, Thickness = 2.5}):Play()
			pcall(function()
				local readySound = Instance.new("Sound")
				readySound.SoundId = "rbxassetid://6333186162"
				readySound.Volume = 0.5
				readySound.Parent = game:GetService("SoundService")
				readySound:Play()
				task.delay(3, function() pcall(function() readySound:Destroy() end) end)
			end)
			task.wait(0.8)
		else
			task.wait(stage.dur + 0.15)
		end
	end
	TweenService:Create(introLogo, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
	TweenService:Create(introSlogan, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
	TweenService:Create(introStatus, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
	TweenService:Create(pctLabel, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
	TweenService:Create(barBg, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
	TweenService:Create(barFill, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
	TweenService:Create(barStroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
	TweenService:Create(barGlowOuter, TweenInfo.new(0.3), {Transparency = 1}):Play()
	task.wait(0.4)
	TweenService:Create(introScreen, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
	task.wait(0.7)
	introScreen:Destroy()
	task.delay(6, function() pcall(function() if bootSound then bootSound:Destroy() end end) end)
	mainFrame.Visible = true
	mainFrame.Position = UDim2.new(0.5, -280, 1.1, 0)
	mainFrame.Size = UDim2.new(0, 560, 0, 400)
	mainFrame.BackgroundTransparency = 0.3
	TweenService:Create(mainFrame, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, -280, 0.5, -200),
		BackgroundTransparency = Config.MenuTransparency / 100,
	}):Play()
	task.wait(1.0)
	local notifFrame = Instance.new("Frame")
	notifFrame.Size = UDim2.new(0, 380, 0, 44)
	notifFrame.Position = UDim2.new(0.5, -190, 0, -55)
	notifFrame.BackgroundColor3 = Color3.fromRGB(5, 15, 10)
	notifFrame.BackgroundTransparency = 0.05
	notifFrame.BorderSizePixel = 0
	notifFrame.ZIndex = 10000
	notifFrame.Parent = screenGui
	Instance.new("UICorner", notifFrame).CornerRadius = UDim.new(0, 8)
	local nStroke = Instance.new("UIStroke")
	nStroke.Color = Color3.fromRGB(0, 201, 107)
	nStroke.Thickness = 1.2
	nStroke.Transparency = 0.2
	nStroke.Parent = notifFrame
	local nAccent = Instance.new("Frame")
	nAccent.Size = UDim2.new(0, 3, 1, -10)
	nAccent.Position = UDim2.new(0, 7, 0, 5)
	nAccent.BackgroundColor3 = Color3.fromRGB(0, 201, 107)
	nAccent.BorderSizePixel = 0
	nAccent.ZIndex = 10001
	nAccent.Parent = notifFrame
	Instance.new("UICorner", nAccent).CornerRadius = UDim.new(0, 2)
	local nIcon = Instance.new("TextLabel")
	nIcon.Size = UDim2.new(0, 24, 1, 0)
	nIcon.Position = UDim2.new(0, 16, 0, 0)
	nIcon.BackgroundTransparency = 1
	nIcon.Text = "🐍"
	nIcon.TextSize = 16
	nIcon.ZIndex = 10001
	nIcon.Parent = notifFrame
	local nText = Instance.new("TextLabel")
	nText.Size = UDim2.new(1, -48, 1, 0)
	nText.Position = UDim2.new(0, 42, 0, 0)
	nText.BackgroundTransparency = 1
	nText.RichText = true
	nText.Text = "<font color=\"#00C96B\">MEDUSA v16.0</font>  <font color=\"#888888\">~</font>  <font color=\"#B4F0D2\">A Lenda Verde Voltou.</font>"
	nText.TextColor3 = Color3.fromRGB(180, 240, 210)
	nText.TextSize = 12
	nText.Font = Enum.Font.GothamMedium
	nText.TextXAlignment = Enum.TextXAlignment.Left
	nText.ZIndex = 10001
	nText.Parent = notifFrame
	TweenService:Create(notifFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, -190, 0, 18),
	}):Play()
	task.delay(4.5, function()
		TweenService:Create(notifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
			Position = UDim2.new(0.5, -190, 0, -65),
			BackgroundTransparency = 1,
		}):Play()
		TweenService:Create(nStroke, TweenInfo.new(0.4), {Transparency = 1}):Play()
		TweenService:Create(nText, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
		TweenService:Create(nIcon, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
		TweenService:Create(nAccent, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
		task.delay(0.6, function() pcall(function() notifFrame:Destroy() end) end)
	end)
end

local function SkipIntro()
	mainFrame.Visible = true
	mainFrame.Size = UDim2.new(0, 560, 0, 400)
	mainFrame.Position = UDim2.new(0.5, -280, 1.1, 0)
	mainFrame.BackgroundTransparency = 0.3
	TweenService:Create(mainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, -280, 0.5, -200),
		BackgroundTransparency = Config.MenuTransparency / 100,
	}):Play()
end

if Config.Intro_Enabled then
	PlayCinematicIntro()
else
	SkipIntro()
end

Fn.StartExposureContrast()

local rgbHue = 0.38
local mainStroke = nil
pcall(function()
	for _, child in pairs(mainFrame:GetChildren()) do
		if child:IsA("UIStroke") then
			mainStroke = child
			break
		end
	end
end)

RegisterUISignal("Theme_HB", RunService.Heartbeat:Connect(function()
	if not _G.MedusaLoaded then return end
	local newAccent = Color3.fromRGB(Config.AccentR, Config.AccentG, Config.AccentB)
	if THEME.Accent ~= newAccent then
		THEME.Accent = newAccent
		pcall(function() accentLine.BackgroundColor3 = newAccent end)
	end
	local t = Config.MenuTransparency / 100
	if mainFrame.BackgroundTransparency ~= t and not Config.RGBGlow_Enabled then
		mainFrame.BackgroundTransparency = t
	end
	if Config.RGBGlow_Enabled and mainStroke then
		rgbHue = (rgbHue + 0.002) % 1
		local rgbColor = Color3.fromHSV(rgbHue, 0.7, 1)
		mainStroke.Color = rgbColor
		mainStroke.Transparency = 0.15
		pcall(function() accentLine.BackgroundColor3 = rgbColor end)
		mainFrame.BackgroundTransparency = 0.12
	elseif mainStroke and not Config.RGBGlow_Enabled then
		mainStroke.Color = THEME.Accent
		mainStroke.Transparency = 0.2
	end
end))
print("[MEDUSA] v16.0 Cinematic Edition ~ Loaded Successfully")
