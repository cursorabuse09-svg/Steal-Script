local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local mouse = player:GetMouse()

local savedPosition = nil
local marker = nil
local noclipEnabled = false
local clickTpEnabled = false

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = game.CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 280)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -140)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 12)
uiCorner.Parent = mainFrame

local uiStroke = Instance.new("UIStroke")
uiStroke.Color = Color3.fromRGB(70, 70, 80)
uiStroke.Thickness = 2
uiStroke.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 45)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
titleLabel.BorderSizePixel = 0
titleLabel.Text = "TELEPORT HUB"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 22
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleLabel

local titleFix = Instance.new("Frame")
titleFix.Size = UDim2.new(1, 0, 0, 12)
titleFix.Position = UDim2.new(0, 0, 1, -12)
titleFix.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
titleFix.BorderSizePixel = 0
titleFix.Parent = titleLabel

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -38, 0, 7.5)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
closeButton.BorderSizePixel = 0
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 18
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = titleLabel

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeButton

local function createButton(text, position, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 280, 0, 45)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(50, 120, 255)
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 16
    button.Font = Enum.Font.GothamBold
    button.Parent = mainFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 10)
    buttonCorner.Parent = button
    
    local buttonStroke = Instance.new("UIStroke")
    buttonStroke.Color = Color3.fromRGB(70, 140, 255)
    buttonStroke.Thickness = 2
    buttonStroke.Transparency = 0.5
    buttonStroke.Parent = button
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 140, 255)}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 120, 255)}):Play()
    end)
    
    button.MouseButton1Click:Connect(callback)
    
    return button
end

local function createToggle(text, position, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(0, 280, 0, 45)
    toggleFrame.Position = position
    toggleFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Parent = mainFrame
    
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 10)
    frameCorner.Parent = toggleFrame
    
    local frameStroke = Instance.new("UIStroke")
    frameStroke.Color = Color3.fromRGB(60, 60, 70)
    frameStroke.Thickness = 2
    frameStroke.Parent = toggleFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 16
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 60, 0, 30)
    toggleButton.Position = UDim2.new(1, -70, 0.5, -15)
    toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    toggleButton.BorderSizePixel = 0
    toggleButton.Text = ""
    toggleButton.Parent = toggleFrame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleButton
    
    local toggleIndicator = Instance.new("Frame")
    toggleIndicator.Size = UDim2.new(0, 24, 0, 24)
    toggleIndicator.Position = UDim2.new(0, 3, 0.5, -12)
    toggleIndicator.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    toggleIndicator.BorderSizePixel = 0
    toggleIndicator.Parent = toggleButton
    
    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(1, 0)
    indicatorCorner.Parent = toggleIndicator
    
    local state = false
    
    toggleButton.MouseButton1Click:Connect(function()
        state = not state
        callback(state)
        
        if state then
            TweenService:Create(toggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 200, 100)}):Play()
            TweenService:Create(toggleIndicator, TweenInfo.new(0.2), {Position = UDim2.new(1, -27, 0.5, -12)}):Play()
            TweenService:Create(toggleIndicator, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        else
            TweenService:Create(toggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 70)}):Play()
            TweenService:Create(toggleIndicator, TweenInfo.new(0.2), {Position = UDim2.new(0, 3, 0.5, -12)}):Play()
            TweenService:Create(toggleIndicator, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200, 200, 200)}):Play()
        end
    end)
    
    return toggleFrame
end

local function createMarker(position)
    if marker then
        marker:Destroy()
    end
    
    marker = Instance.new("Part")
    marker.Name = "TeleportMarker"
    marker.Size = Vector3.new(4, 8, 4)
    marker.Position = position
    marker.Anchored = true
    marker.CanCollide = false
    marker.Material = Enum.Material.Neon
    marker.BrickColor = BrickColor.new("Cyan")
    marker.Transparency = 0.3
    marker.Parent = workspace
    
    local pointLight = Instance.new("PointLight")
    pointLight.Brightness = 3
    pointLight.Color = Color3.fromRGB(0, 255, 255)
    pointLight.Range = 25
    pointLight.Parent = marker
    
    local beam = Instance.new("Part")
    beam.Size = Vector3.new(0.5, 100, 0.5)
    beam.Position = position + Vector3.new(0, 50, 0)
    beam.Anchored = true
    beam.CanCollide = false
    beam.Material = Enum.Material.Neon
    beam.BrickColor = BrickColor.new("Cyan")
    beam.Transparency = 0.5
    beam.Parent = marker
    
    spawn(function()
        while marker and marker.Parent do
            marker.CFrame = marker.CFrame * CFrame.Angles(0, math.rad(4), 0)
            wait(0.03)
        end
    end)
end

createButton("SAVE POSITION", UDim2.new(0, 20, 0, 60), function()
    if character and rootPart then
        savedPosition = rootPart.CFrame
        createMarker(rootPart.Position)
    end
end)

createButton("TELEPORT", UDim2.new(0, 20, 0, 115), function()
    if savedPosition and character and rootPart then
        rootPart.CFrame = savedPosition
    end
end)

createToggle("NOCLIP", UDim2.new(0, 20, 0, 170), function(state)
    noclipEnabled = state
end)

createToggle("CLICK TP (CTRL + LMB)", UDim2.new(0, 20, 0, 225), function(state)
    clickTpEnabled = state
end)

closeButton.MouseButton1Click:Connect(function()
    if marker then
        marker:Destroy()
    end
    screenGui:Destroy()
end)

RunService.Stepped:Connect(function()
    if noclipEnabled and character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

mouse.Button1Down:Connect(function()
    if clickTpEnabled and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        if mouse.Target and character and rootPart then
            rootPart.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.F then
            if savedPosition and character and rootPart then
                rootPart.CFrame = savedPosition
            end
        elseif input.KeyCode == Enum.KeyCode.G then
            if character and rootPart then
                savedPosition = rootPart.CFrame
                createMarker(rootPart.Position)
            end
        elseif input.KeyCode == Enum.KeyCode.H then
            mainFrame.Visible = not mainFrame.Visible
        end
    end
end)

player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
end)
