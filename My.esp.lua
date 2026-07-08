local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

local espEnabled = false
local espConnections = {}
local espHighlights = {}

local function createESP(player)
    if player == localPlayer then return end
    
    local character = player.Character
    if not character then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Wallhack"
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0
    highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee = character
    highlight.Parent = character
    
    espHighlights[player] = highlight
    
    local function updateColor()
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            local healthPercent = humanoid.Health / humanoid.MaxHealth
            if healthPercent > 0.5 then
                highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
            elseif healthPercent > 0.25 then
                highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
            else
                highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
            end
        end
    end
    
    updateColor()
    
    local conn = character:WaitForChild("Humanoid"):GetPropertyChangedSignal("Health"):Connect(updateColor)
    table.insert(espConnections, conn)
end

local function clearESP()
    for _, conn in pairs(espConnections) do
        pcall(function() conn:Disconnect() end)
    end
    espConnections = {}
    
    for _, highlight in pairs(espHighlights) do
        pcall(function() highlight:Destroy() end)
    end
    espHighlights = {}
end

local function enableESP()
    if espEnabled then return end
    espEnabled = true
    
    for _, player in pairs(Players:GetPlayers()) do
        createESP(player)
    end
    
    local playerAddedConn = Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function()
            createESP(player)
        end)
    end)
    table.insert(espConnections, playerAddedConn)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            local charAddedConn = player.CharacterAdded:Connect(function()
                createESP(player)
            end)
            table.insert(espConnections, charAddedConn)
        end
    end
end

local function disableESP()
    if not espEnabled then return end
    espEnabled = false
    clearESP()
end

enableESP()
