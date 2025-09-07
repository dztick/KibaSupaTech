--// Kiba Tech & Supa Tech Toggle Script
--// Default: Supa Tech (S) aktif
--// Toggle R -> ganti mode (K = Kiba Tech, S = Supa Tech)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

-- Remote Events (ganti sesuai game)
local DashRemote = ReplicatedStorage:WaitForChild("DashRemote")
local UppercutRemote = ReplicatedStorage:WaitForChild("UppercutRemote")

-- Config
local detectRadius = 12
local kibaOffset = 10 -- tinggi dash Kiba Tech

-- State
local mode = "S" -- default Supa Tech
local lastHitTarget = nil
local uppercutReady = false

-- GUI kecil
local function showLetter(letter, duration)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = player:WaitForChild("PlayerGui")
    screenGui.IgnoreGuiInset = true

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0,20,0,20)
    label.Position = UDim2.new(0,5,1,-25)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(0,255,0)
    label.TextScaled = true
    label.Text = letter
    label.Parent = screenGui

    task.delay(duration or 1.5, function()
        screenGui:Destroy()
    end)
end

-- Cari target terdekat
local function getTarget()
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = otherPlayer.Character.HumanoidRootPart
            local dist = (root.Position - hrp.Position).Magnitude
            if dist <= detectRadius then
                return hrp
            end
        end
    end
end

-- Supa Tech Dash
local function SupaTechDash(target)
    if target then
        DashRemote:FireServer(target.Position, 1)
    end
end

-- Kiba Tech Dash
local function KibaTechDash(target)
    if target then
        local dashPos = target.Position + Vector3.new(0, kibaOffset, 0)
        DashRemote:FireServer(dashPos, 1)
    end
end

-- Input handler
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end

    if input.KeyCode == Enum.KeyCode.R then
        -- Toggle mode
        if mode == "S" then
            mode = "K"
        else
            mode = "S"
        end
        showLetter(mode, 1.5)
    end

    if input.KeyCode == Enum.KeyCode.Q then
        local target = getTarget()
        if target then
            if mode == "K" and uppercutReady then
                KibaTechDash(target)
                uppercutReady = false
            elseif mode == "S" and uppercutReady then
                SupaTechDash(target)
                uppercutReady = false
            else
                -- normal dash
                DashRemote:FireServer(root.Position + root.CFrame.LookVector * 10, 1)
            end
        else
            -- normal dash
            DashRemote:FireServer(root.Position + root.CFrame.LookVector * 10, 1)
        end
    end
end)

-- Hook uppercut (contoh, mungkin harus disesuaikan tergantung remote)
UppercutRemote.OnClientEvent:Connect(function()
    local target = getTarget()
    if target then
        lastHitTarget = target
        uppercutReady = true
    end
end)

-- Notifikasi STARTED saat run
showLetter("STARTED", 2)
