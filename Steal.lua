local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

local playerSpawnPosition = nil
local noclipEnabled = false
local clickTpEnabled = false
local lockPart = nil
local returnPosition = nil
local fastInteractEnabled = false
local teleportReturnPos = nil
local espEnabled = false
local espLabels = {}
local npcPositions = {}
local proximityPrompts = {}
local trackedNPCs = {}
local grabTeleportEnabled = false
local grabPosition = nil

local noclipExcludeList = {
    ["upperflooring"] = true,
    ["Part"] = true,
    ["RiverThings"] = true,
    ["Layer4"] = true,
    ["Ground"] = true,
    ["flooring"] = true
}

local ignoredNPCs = {
    ["67"] = true,
    ["41"] = true,
    ["Ness"] = true,
    ["Scene Femboy"] = true,
    ["Cat Femboy"] = true,
    ["Noob Femboy"] = true,
    ["Bunny Femboy"] = true,
    ["Femboy Developer"] = true,
    ["Ruka"] = true,
    ["Venti"] = true,
    ["Saika"] = true,
    ["Haku"] = true,
    ["Hideri"] = true,
    ["Felix"] = true,
    ["Chihiro Fujisaki"] = true,
    ["Employed Femboy"] = true,
    ["Empl*yed Femboy"] = true,
    ["Roommate"] = true,
    ["Casual Astolfo"] = true,
    ["Gasper"] = true,
    ["billytheguyNEW"] = true
}

local rarityColors = {
    ["Divine"] = Color3.fromRGB(255, 107, 236),
    ["Special"] = Color3.fromRGB(0, 255, 0),
    ["Goldy"] = Color3.fromRGB(100, 150, 255)
}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = game.CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 445)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -222.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.ClipsDescendants = true
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
titleLabel.Text = "Steal a Femboy"
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

local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 30, 0, 30)
minimizeButton.Position = UDim2.new(1, -76, 0, 7.5)
minimizeButton.BackgroundColor3 = Color3.fromRGB(255, 180, 60)
minimizeButton.BorderSizePixel = 0
minimizeButton.Text = "_"
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.TextSize = 18
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.Parent = titleLabel

local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(0, 8)
minimizeCorner.Parent = minimizeButton

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

local function createButton(text, position, callback, rightClickCallback)
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
    
    if rightClickCallback then
        button.MouseButton2Click:Connect(rightClickCallback)
    end
    
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


local function getNPCRarity(npcModel)
    for _, obj in pairs(npcModel:GetDescendants()) do
        if obj:IsA("StringValue") and obj.Name == "Rarity" then
            return obj.Value
        end
    end
    
    if npcModel:GetAttribute("Rarity") then
        return npcModel:GetAttribute("Rarity")
    end
    
    local config = npcModel:FindFirstChild("Configuration") or npcModel:FindFirstChild("Config")
    if config then
        local rarity = config:FindFirstChild("Rarity")
        if rarity and rarity:IsA("StringValue") then
            return rarity.Value
        end
    end
    
    return nil
end

local function isNPCStationary(npcModel)
    local humanoid = npcModel:FindFirstChild("Humanoid")
    if humanoid then
        local rootPart = npcModel:FindFirstChild("HumanoidRootPart") or npcModel:FindFirstChild("Torso")
        if rootPart then
            if not npcPositions[npcModel] then
                npcPositions[npcModel] = rootPart.Position
                return false
            end
            
            local lastPos = npcPositions[npcModel]
            local currentPos = rootPart.Position
            local distance = (currentPos - lastPos).Magnitude
            
            npcPositions[npcModel] = currentPos
            
            return distance < 0.5
        end
    end
    return false
end

local function createESP(npcModel)
    if ignoredNPCs[npcModel.Name] then return end
    if not npcModel:FindFirstChild("HumanoidRootPart") and not npcModel:FindFirstChild("Head") then return end
    if espLabels[npcModel] then return end
    
    local targetPart = npcModel:FindFirstChild("HumanoidRootPart") or npcModel:FindFirstChild("Head")
    
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "NPCEsp"
    billboardGui.AlwaysOnTop = true
    billboardGui.Size = UDim2.new(0, 120, 0, 40)
    billboardGui.StudsOffset = Vector3.new(0, 2, 0)
    billboardGui.Parent = targetPart
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 0.5, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = npcModel.Name
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    textLabel.TextStrokeTransparency = 0
    textLabel.TextSize = 16
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Parent = billboardGui
    
    local rarityLabel = Instance.new("TextLabel")
    rarityLabel.Size = UDim2.new(1, 0, 0.5, 0)
    rarityLabel.Position = UDim2.new(0, 0, 0.5, 0)
    rarityLabel.BackgroundTransparency = 1
    rarityLabel.Text = ""
    rarityLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    rarityLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    rarityLabel.TextStrokeTransparency = 0
    rarityLabel.TextSize = 14
    rarityLabel.Font = Enum.Font.GothamBold
    rarityLabel.Parent = billboardGui
    
    local rarity = getNPCRarity(npcModel)
    if rarity and rarityColors[rarity] then
        rarityLabel.Text = rarity
        rarityLabel.TextColor3 = rarityColors[rarity]
    end
    
    espLabels[npcModel] = {gui = billboardGui, rarityLabel = rarityLabel, part = targetPart}
end

local function removeESP(npcModel)
    if espLabels[npcModel] then
        if espLabels[npcModel].gui then
            espLabels[npcModel].gui:Destroy()
        end
        espLabels[npcModel] = nil
    end
end

local function checkNPC(npcModel)
    if ignoredNPCs[npcModel.Name] then return end
    if not npcModel:FindFirstChild("Humanoid") then return end
    if Players:GetPlayerFromCharacter(npcModel) then return end
    
    if not trackedNPCs[npcModel] then
        trackedNPCs[npcModel] = {checked = false, stationary = false}
        isNPCStationary(npcModel)
        task.wait(2)
        if npcModel.Parent then
            local stationary = isNPCStationary(npcModel)
            trackedNPCs[npcModel] = {checked = true, stationary = stationary}
            if stationary and espEnabled then
                createESP(npcModel)
            end
        end
    end
end

local function setupNPCTracking()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
            task.spawn(checkNPC, obj)
        end
    end
    
    workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("Model") then
            task.wait(0.1)
            if obj:FindFirstChild("Humanoid") then
                task.spawn(checkNPC, obj)
            end
        elseif obj.Name == "Humanoid" and obj.Parent:IsA("Model") then
            task.spawn(checkNPC, obj.Parent)
        end
    end)
    
    workspace.DescendantRemoving:Connect(function(obj)
        if obj:IsA("Model") then
            if espLabels[obj] then
                removeESP(obj)
            end
            if trackedNPCs[obj] then
                trackedNPCs[obj] = nil
            end
            if npcPositions[obj] then
                npcPositions[obj] = nil
            end
        end
    end)
end

local function clearAllESP()
    for npcModel, _ in pairs(espLabels) do
        removeESP(npcModel)
    end
end

local function modifyProximityPrompt(prompt)
    if not fastInteractEnabled then return end
    pcall(function()
        prompt.HoldDuration = 0
        prompt.RequiresLineOfSight = false
    end)
end

local function setupPromptGrabTeleport(prompt)
    prompt.Triggered:Connect(function()
        if not grabTeleportEnabled then return end
        if not playerSpawnPosition then return end
        if not character or not rootPart then return end
        
        local shouldSkip = false
        
        if prompt.ObjectText then
            local lowerText = string.lower(prompt.ObjectText)
            if string.sub(lowerText, 1, 4) == "sell" or string.sub(lowerText, 1, 8) == "purchase" then
                shouldSkip = true
            end
        end
        
        if not shouldSkip and prompt.ActionText then
            local lowerText = string.lower(prompt.ActionText)
            if string.sub(lowerText, 1, 4) == "sell" or string.sub(lowerText, 1, 8) == "purchase" then
                shouldSkip = true
            end
        end
        
        if not shouldSkip and prompt.Name then
            local lowerText = string.lower(prompt.Name)
            if string.sub(lowerText, 1, 4) == "sell" or string.sub(lowerText, 1, 8) == "purchase" then
                shouldSkip = true
            end
        end
        
        if shouldSkip then return end
        
        grabPosition = rootPart.CFrame
        task.wait(0.5)
        rootPart.CFrame = playerSpawnPosition
        task.wait(0.15)
        if grabPosition and rootPart then
            rootPart.CFrame = grabPosition
            grabPosition = nil
        end
    end)
end

local function setupProximityPrompts()
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            proximityPrompts[v] = true
            if fastInteractEnabled then
                modifyProximityPrompt(v)
            end
            setupPromptGrabTeleport(v)
        end
    end
    
    game.DescendantAdded:Connect(function(v)
        if v:IsA("ProximityPrompt") then
            proximityPrompts[v] = true
            if fastInteractEnabled then
                modifyProximityPrompt(v)
            end
            setupPromptGrabTeleport(v)
        end
    end)
    
    game.DescendantRemoving:Connect(function(v)
        if v:IsA("ProximityPrompt") then
            proximityPrompts[v] = nil
        end
    end)
end

local function applyFastInteract()
    for prompt, _ in pairs(proximityPrompts) do
        if prompt and prompt.Parent then
            modifyProximityPrompt(prompt)
        end
    end
end

local noclipConnection = nil

local function enableNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
    end
    
    noclipConnection = RunService.Stepped:Connect(function()
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function disableNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    if character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

createButton("TELEPORT TO BASE", UDim2.new(0, 20, 0, 60), 
    function()
        if playerSpawnPosition and character and rootPart then
            rootPart.CFrame = playerSpawnPosition
        end
    end,
    function()
        if playerSpawnPosition and character and rootPart then
            teleportReturnPos = rootPart.CFrame
            rootPart.CFrame = playerSpawnPosition
            wait(0.5)
            if teleportReturnPos then
                rootPart.CFrame = teleportReturnPos
                teleportReturnPos = nil
            end
        end
    end
)

createButton("LOCK BASE", UDim2.new(0, 20, 0, 115), function()
    if lockPart and character and rootPart then
        returnPosition = rootPart.CFrame
        rootPart.CFrame = CFrame.new(lockPart.Position + Vector3.new(0, 5, 0))
        wait(0.1)
        if returnPosition then
            rootPart.CFrame = returnPosition
        end
    end
end)

createToggle("NOCLIP", UDim2.new(0, 20, 0, 170), function(state)
    noclipEnabled = state
    if state then
        enableNoclip()
    else
        disableNoclip()
    end
end)

createToggle("CLICK TP (CTRL + LMB)", UDim2.new(0, 20, 0, 225), function(state)
    clickTpEnabled = state
end)

createToggle("INSTANT INTERACT", UDim2.new(0, 20, 0, 280), function(state)
    fastInteractEnabled = state
    if state then
        applyFastInteract()
    end
end)

createToggle("NPC ESP", UDim2.new(0, 20, 0, 335), function(state)
    espEnabled = state
    if state then
        for npcModel, data in pairs(trackedNPCs) do
            if npcModel and npcModel.Parent and data.checked and data.stationary then
                createESP(npcModel)
            end
        end
    else
        clearAllESP()
    end
end)

createToggle("GRAB TELEPORT", UDim2.new(0, 20, 0, 390), function(state)
    grabTeleportEnabled = state
end)


minimizeButton.MouseButton1Click:Connect(function()
    local isMinimized = mainFrame.Size.Y.Offset <= 45
    if isMinimized then
        mainFrame:TweenSize(UDim2.new(0, 320, 0, 445), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
        minimizeButton.Text = "_"
    else
        mainFrame:TweenSize(UDim2.new(0, 320, 0, 45), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
        minimizeButton.Text = "+"
    end
end)

closeButton.MouseButton1Click:Connect(function()
    noclipEnabled = false
    disableNoclip()
    clickTpEnabled = false
    fastInteractEnabled = false
    grabTeleportEnabled = false
    espEnabled = false
    clearAllESP()
    
    screenGui:Destroy()
end)

RunService.Heartbeat:Connect(function()
    if noclipEnabled and rootPart and character then
        local rayParams = RaycastParams.new()
        rayParams.FilterDescendantsInstances = {character}
        rayParams.FilterType = Enum.RaycastFilterType.Blacklist
        
        local raycastResult = workspace:Raycast(rootPart.Position, Vector3.new(0, -10, 0), rayParams)
        
        if raycastResult and raycastResult.Instance then
            if noclipExcludeList[raycastResult.Instance.Name] then
                raycastResult.Instance.CanCollide = true
            end
        end
        
        for _, obj in pairs(workspace:GetPartBoundsInRadius(rootPart.Position, 15)) do
            if noclipExcludeList[obj.Name] then
                obj.CanCollide = true
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


player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
end)

local function getSpawnLocation()
    local ownerPart = nil
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "Owner" and obj:IsA("BasePart") then
            local foundName = false
            for _, child in pairs(obj:GetDescendants()) do
                if child:IsA("TextLabel") then
                    if child.Text == player.DisplayName then
                        ownerPart = obj
                        foundName = true
                        break
                    end
                end
            end
            if foundName then break end
        end
    end
    
    if ownerPart then
        local ownerPosition = ownerPart.Position
        
        local closestLock = nil
        local closestLockDistance = math.huge
        
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name == "Lock" and obj:IsA("BasePart") then
                local distance = (obj.Position - ownerPosition).Magnitude
                if distance < closestLockDistance then
                    closestLockDistance = distance
                    closestLock = obj
                end
            end
        end
        
        if closestLock then
            lockPart = closestLock
        end
        
        local closestHitbox = nil
        local closestHitboxDistance = math.huge
        
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name == "CollectZoneHitbox" and obj:IsA("BasePart") then
                local distance = (obj.Position - ownerPosition).Magnitude
                if distance < closestHitboxDistance then
                    closestHitboxDistance = distance
                    closestHitbox = obj
                end
            end
        end
        
        if closestHitbox then
            playerSpawnPosition = CFrame.new(closestHitbox.Position + Vector3.new(0, 3, 0))
        end
    end
    
    if not playerSpawnPosition then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("SpawnLocation") then
                playerSpawnPosition = CFrame.new(obj.Position + Vector3.new(0, 3, 0))
                break
            end
        end
    end
end

getSpawnLocation()

setupProximityPrompts()
setupNPCTracking()
