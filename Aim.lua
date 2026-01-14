-- Patroclo's Hub Aim (Actualizado: Aimlock Nearest por DISTANCIA 3D)
-- Ahora se fija en el JUGADOR MÁS CERCANO en el mundo (distancia real), no por mouse
-- Ignora paredes (puedes agregar raycast si quieres visible-only)
-- GUI pequeña, FPS, Ping, Toggle con botón y tecla INSERT

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Variables
local AimlockEnabled = false
local Target = nil

-- Crear GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Patroclo's Hub Aim"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0, 15, 0, 15)
MainFrame.Size = UDim2.new(0, 220, 0, 140)
MainFrame.Active = true
MainFrame.Draggable = true

-- Esquinas redondeadas
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- Borde glow
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(100, 150, 255)
UIStroke.Thickness = 1.5
UIStroke.Transparency = 0.5
UIStroke.Parent = MainFrame

-- Título
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "Title"
TitleLabel.Parent = MainFrame
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 0, 0, 0)
TitleLabel.Size = UDim2.new(1, 0, 0, 35)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "Patroclo's Hub Aim"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextScaled = true
TitleLabel.TextStrokeTransparency = 0.8

-- Botón Toggle Aimlock
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = MainFrame
ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
ToggleButton.Position = UDim2.new(0, 10, 0, 45)
ToggleButton.Size = UDim2.new(0.78, 0, 0, 30)
ToggleButton.Font = Enum.Font.GothamSemibold
ToggleButton.Text = "Aimlock: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 100, 100)
ToggleButton.TextScaled = true
ToggleButton.BorderSizePixel = 0

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = ToggleButton

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Color3.fromRGB(60, 60, 70)
ToggleStroke.Thickness = 1
ToggleStroke.Parent = ToggleButton

-- FPS Label
local FPSLabel = Instance.new("TextLabel")
FPSLabel.Name = "FPSLabel"
FPSLabel.Parent = MainFrame
FPSLabel.BackgroundTransparency = 1
FPSLabel.Position = UDim2.new(0, 10, 0, 85)
FPSLabel.Size = UDim2.new(1, -20, 0, 20)
FPSLabel.Font = Enum.Font.Gotham
FPSLabel.Text = "FPS: Calculando..."
FPSLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
FPSLabel.TextScaled = true
FPSLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Ping Label
local PingLabel = Instance.new("TextLabel")
PingLabel.Name = "PingLabel"
PingLabel.Parent = MainFrame
PingLabel.BackgroundTransparency = 1
PingLabel.Position = UDim2.new(0, 10, 0, 110)
PingLabel.Size = UDim2.new(1, -20, 0, 20)
PingLabel.Font = Enum.Font.Gotham
PingLabel.Text = "Ping: -- ms"
PingLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
PingLabel.TextScaled = true
PingLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Funciones
local function UpdateToggleButton()
    if AimlockEnabled then
        ToggleButton.Text = "Aimlock: ON"
        ToggleButton.TextColor3 = Color3.fromRGB(100, 255, 100)
        ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 60, 30)
    else
        ToggleButton.Text = "Aimlock: OFF"
        ToggleButton.TextColor3 = Color3.fromRGB(255, 100, 100)
        ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
    end
    TweenService:Create(ToggleButton, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
end

local function GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    
    -- Verificar que el LocalPlayer tenga Character
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    
    local myRootPart = LocalPlayer.Character.HumanoidRootPart
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Head") then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                -- Skip same team (si hay teams)
                if not player.Team or player.Team ~= LocalPlayer.Team then
                    local theirRootPart = player.Character.HumanoidRootPart
                    local distance = (myRootPart.Position - theirRootPart.Position).Magnitude
                    if distance < shortestDistance then
                        closestPlayer = player
                        shortestDistance = distance
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- Toggle con botón
ToggleButton.MouseButton1Click:Connect(function()
    AimlockEnabled = not AimlockEnabled
    UpdateToggleButton()
end)

-- Toggle con tecla INSERT
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        AimlockEnabled = not AimlockEnabled
        UpdateToggleButton()
    end
end)

-- Aimlock Loop (Nearest por distancia 3D)
RunService.Heartbeat:Connect(function()
    if AimlockEnabled then
        Target = GetClosestPlayer()
        if Target and Target.Character and Target.Character:FindFirstChild("Head") then
            local head = Target.Character.Head
            local headPosition = head.Position + Vector3.new(0, 0.5, 0)  -- Offset al centro de la cabeza
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, headPosition), 0.15)
        end
    end
end)

-- FPS Counter
local lastFPSTime = tick()
local fpsFrames = 0
RunService.RenderStepped:Connect(function()
    fpsFrames = fpsFrames + 1
    local currentTime = tick()
    if currentTime - lastFPSTime >= 1 then
        FPSLabel.Text = "FPS: " .. math.floor(fpsFrames / (currentTime - lastFPSTime))
        fpsFrames = 0
        lastFPSTime = currentTime
    end
end)

-- Ping Updater
spawn(function()
    while true do
        wait(0.5)
        local ping = LocalPlayer:GetNetworkPing()
        PingLabel.Text = "Ping: " .. ping .. " ms"
        if ping < 50 then
            PingLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        elseif ping < 100 then
            PingLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
        else
            PingLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end
end)

-- Inicializar
UpdateToggleButton()
print("Patroclo's Hub Aim (Nearest 3D) cargado! Presiona INSERT para toggle.")
