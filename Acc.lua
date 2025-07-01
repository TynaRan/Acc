local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/TynaRan/Acc/refs/heads/main/cat%20(1).txt"))()
local Window = Library:CreateWindow("Phantom Aim", Vector2.new(492, 598), Enum.KeyCode.RightControl)
local AimingTab = Window:CreateTab("Combat")

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

-- Variables
local LocalPlayer = Players.LocalPlayer
local Character
local RootPart
local Camera = workspace.CurrentCamera
local ShootEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Shoot")

-- Initialize character
local function initializeCharacter()
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    RootPart = Character:WaitForChild("HumanoidRootPart")
    
    LocalPlayer.CharacterAdded:Connect(function(newChar)
        Character = newChar
        RootPart = newChar:WaitForChild("HumanoidRootPart")
    end)
end

initializeCharacter()
local function createPremiumRay(startPos, endPos, color)
    -- Main container
    local rayContainer = Instance.new("Part")
    rayContainer.Anchored = true
    rayContainer.CanCollide = false
    rayContainer.Transparency = 1
    rayContainer.Size = Vector3.new(0.1,0.1,0.1)
    rayContainer.CFrame = CFrame.new(startPos, endPos)
    
    -- Beam effect
    local beam = Instance.new("Beam")
    beam.Color = ColorSequence.new(color)
    beam.Width0 = 0.15
    beam.Width1 = 0.05
    beam.Brightness = 5
    beam.LightEmission = 1
    beam.LightInfluence = 0
    beam.Texture = "rbxassetid://446111271"
    beam.TextureSpeed = 1.5
    
    -- Attachments
    local startAttach = Instance.new("Attachment")
    local endAttach = Instance.new("Attachment")
    startAttach.Position = Vector3.new(0,0,0)
    endAttach.Position = Vector3.new(0,0,-(startPos - endPos).Magnitude)
    
    -- Glow particles
    local particles = Instance.new("ParticleEmitter")
    particles.LightEmission = 1
    particles.Texture = "rbxassetid://242487985"
    particles.Color = ColorSequence.new(color)
    particles.Size = NumberSequence.new(0.3)
    particles.Speed = NumberRange.new(0.2)
    particles.Lifetime = NumberRange.new(0.4)
    particles.Rate = 50
    particles.Transparency = NumberSequence.new(0.5)
    
    -- Impact effect
    local impact = Instance.new("Part")
    impact.Anchored = true
    impact.CanCollide = false
    impact.Size = Vector3.new(0.5,0.5,0.5)
    impact.Shape = Enum.PartType.Ball
    impact.Color = color
    impact.Material = Enum.Material.Neon
    impact.CFrame = CFrame.new(endPos)
    impact.Transparency = 0.3
    
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.Sphere
    mesh.Scale = Vector3.new(0.1,0.1,0.1)
    mesh.Parent = impact
    
    -- Parenting
    startAttach.Parent = rayContainer
    endAttach.Parent = rayContainer
    beam.Attachment0 = startAttach
    beam.Attachment1 = endAttach
    beam.Parent = rayContainer
    particles.Parent = startAttach
    impact.Parent = workspace
    rayContainer.Parent = workspace
    
    -- Tween only valid properties
    local tweenInfo = TweenInfo.new(
        0.5,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    
    local validTweens = {
        TweenService:Create(particles, tweenInfo, {Rate = 0}), -- Only tween Rate
        TweenService:Create(impact, tweenInfo, {Transparency = 1}),
        TweenService:Create(mesh, tweenInfo, {Scale = Vector3.new(0.5,0.5,0.5)})
    }
    
    for _, tween in ipairs(validTweens) do
        tween:Play()
    end
    
    -- Cleanup
    delay(0.6, function()
        rayContainer:Destroy()
        impact:Destroy()
    end)
end
-- UI Settings
local SilentAimSection = AimingTab:CreateSector("Silent Aim", "left")
local VisualSection = AimingTab:CreateSector("Visual Effects", "right")
local AudioSection = AimingTab:CreateSector("Audio", "left")

-- Settings
local settings = {
    silentAim = {
        enabled = false,
        fov = 120,
        wallCheck = false,
        teamCheck = true
    },
    visuals = {
        enabled = true,
        color = Color3.fromRGB(0, 255, 255),
        thickness = 0.15,
        duration = 0.5,
    impactSize = 0.5
    },
    audio = {
        hitSound = true,
        soundId = "rbxassetid://160432334",
        volume = 0.5
    }
}

-- UI Elements (same as before)
SilentAimSection:AddToggle("Enabled", settings.silentAim.enabled, function(state)
    settings.silentAim.enabled = state
end)

SilentAimSection:AddSlider("FOV", 10, settings.silentAim.fov, 360, 1, function(value)
    settings.silentAim.fov = value
end)

SilentAimSection:AddToggle("Wall Check", settings.silentAim.wallCheck, function(state)
    settings.silentAim.wallCheck = state
end)

SilentAimSection:AddToggle("Team Check", settings.silentAim.teamCheck, function(state)
    settings.silentAim.teamCheck = state
end)

VisualSection:AddToggle("Enabled", settings.visuals.enabled, function(state)
    settings.visuals.enabled = state
end)

local ColorToggle = VisualSection:AddToggle("Custom Color", false, function() end)
ColorToggle:AddColorpicker(settings.visuals.color, function(color)
    settings.visuals.color = color
end)

VisualSection:AddSlider("Thickness", 1, settings.visuals.thickness*10, 30, 1, function(value)
    settings.visuals.thickness = value/10
end)

VisualSection:AddSlider("Duration", 1, settings.visuals.duration*10, 20, 1, function(value)
    settings.visuals.duration = value/10
end)

VisualSection:AddSlider("Impact Size", 1, settings.visuals.impactSize*10, 20, 1, function(value)
    settings.visuals.impactSize = value/10
end)

AudioSection:AddToggle("Hit Sound", settings.audio.hitSound, function(state)
    settings.audio.hitSound = state
end)

AudioSection:AddTextbox("Sound ID", settings.audio.soundId, function(text)
    settings.audio.soundId = text
end)

AudioSection:AddSlider("Volume", 1, settings.audio.volume*10, 10, 1, function(value)
    settings.audio.volume = value/10
end)

-- Silent Aim Functions (same as before)
local function isEnemy(player)
    if not player or not player.Character then return false end
    if settings.silentAim.teamCheck and LocalPlayer.Team and player.Team == LocalPlayer.Team then
        return false
    end
    return true
end

local function wallCheck(position)
    if not settings.silentAim.wallCheck then return true end
    local origin = Camera.CFrame.Position
    local direction = (position - origin).Unit * (origin - position).Magnitude
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {Character, Camera}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    local raycastResult = workspace:Raycast(origin, direction, raycastParams)
    return not raycastResult
end

local function getClosestEnemy()
    if not Character or not RootPart then return nil end
    
    local closestPlayer, closestDistance = nil, settings.silentAim.fov
    local cameraPos = Camera.CFrame.Position

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isEnemy(player) then
            local targetChar = player.Character
            if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                local targetPos = targetChar.HumanoidRootPart.Position
                local screenPoint = Camera:WorldToViewportPoint(targetPos)
                local distance = (RootPart.Position - targetPos).Magnitude
                
                if screenPoint.Z > 0 and distance < closestDistance and wallCheck(targetPos) then
                    closestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end

    return closestPlayer
end

local function playHitSound()
    if not settings.audio.hitSound then return end
    
    local sound = Instance.new("Sound")
    sound.SoundId = settings.audio.soundId
    sound.Volume = settings.audio.volume
    sound.Parent = SoundService
    sound:Play()
    game:GetService("Debris"):AddItem(sound, 3)
end

local function getSilentAimCFrame(target)
    if not target or not target.Character then return nil end
    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return nil end

    local gun = Character:FindFirstChild("jjolgrdvdvkgdohCustomGun") or Character:FindFirstChildWhichIsA("Tool")
    if not gun then return nil end

    local gunHandle = gun:FindFirstChild("Handle") or gun:FindFirstChild("Part")
    if not gunHandle then return nil end

    local direction = (targetRoot.Position - gunHandle.Position).Unit
    return CFrame.lookAt(gunHandle.Position, targetRoot.Position)
end

-- Main silent aim function
local function shootAtClosestEnemy()
    if not settings.silentAim.enabled or not Character or not RootPart then return end

    local closestEnemy = getClosestEnemy()
    if not closestEnemy then return end

    local targetChar = closestEnemy.Character
    if not targetChar then return end

    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end

    local silentAimCFrame = getSilentAimCFrame(closestEnemy)
    if not silentAimCFrame then return end

    local gun = Character:FindFirstChild("jjolgrdvdvkgdohCustomGun") or Character:FindFirstChildWhichIsA("Tool")
    if not gun then return end

    local gunHandle = gun:FindFirstChild("Handle") or gun:FindFirstChild("Part")
    if not gunHandle then return end

    -- Create premium visual ray
    if settings.visuals.enabled then
        createPremiumRay(gunHandle.Position, targetRoot.Position, settings.visuals.color)
    end

    -- Play hit sound
    playHitSound()

    -- Fire the shoot event
    local args = {
        os.clock(),
        gun,
        silentAimCFrame,
        false,
        {
            ["1"] = {
                targetChar:FindFirstChild("Humanoid"),
                false,
                false,
                5
            }
        }
    }

    ShootEvent:FireServer(unpack(args))
end

-- Heartbeat connection
RunService.Heartbeat:Connect(function()
    shootAtClosestEnemy()
end)
