-- DELTA GUI AUTO JOB MAXGEN (AUTO-DETECTION VERSION)
-- Owner: brukontop

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

---------------------------------------------------------
-- 1. GUI SETUP (COREGUI OVERLAY)
---------------------------------------------------------
if CoreGui:FindFirstChild("BrukOntop_FloatingGUI") then
    CoreGui["BrukOntop_FloatingGUI"]:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BrukOntop_FloatingGUI"

local success = pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not success then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Position = UDim2.new(0.1, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 180, 0, 110)
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

local OwnerLabel = Instance.new("TextLabel")
OwnerLabel.Parent = MainFrame
OwnerLabel.Text = "OWNER: BRUKONTOP"
OwnerLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
OwnerLabel.Size = UDim2.new(1, 0, 0, 30)
OwnerLabel.Font = Enum.Font.SourceSansBold
OwnerLabel.TextSize = 12

local BtnAutoJob = Instance.new("TextButton")
BtnAutoJob.Parent = MainFrame
BtnAutoJob.Text = "AUTO JOB MAXGEN"
BtnAutoJob.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
BtnAutoJob.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnAutoJob.Position = UDim2.new(0.1, 0, 0.4, 0)
BtnAutoJob.Size = UDim2.new(0.8, 0, 0.45, 0)
BtnAutoJob.Font = Enum.Font.SourceSansBold
BtnAutoJob.TextSize = 11

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = BtnAutoJob

---------------------------------------------------------
-- 2. LOGIKA OTOMATISASI DAN MOVEMENT
---------------------------------------------------------
local isRunning = false

local function applyNoclip(targetModel)
    if not targetModel then return end
    for _, part in pairs(targetModel:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

local function smoothMove(modelOrPart, targetCFrame, speed)
    local rootPart = modelOrPart:IsA("Model") and (modelOrPart.PrimaryPart or modelOrPart:FindFirstChild("HumanoidRootPart") or modelOrPart:FindFirstChildWhichIsA("BasePart")) or modelOrPart
    if not rootPart then return end
    
    applyNoclip(modelOrPart)
    
    local distance = (rootPart.Position - targetCFrame.Position).Magnitude
    local duration = distance / (speed or 40)
    
    local tween = TweenService:Create(rootPart, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
    tween:Play()
    tween.Completed:Wait()
end

local function getPlayerVehicle()
    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        local seat = char.Humanoid.SeatPart
        if seat and seat.Parent then
            return seat.Parent
        end
    end
    return nil
end

-- Mencari objek terdekat di Workspace yang mengandung kata kunci (misal: "Job", "Target", "Point", "Yellow")
local function findClosestTarget(keywords)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    
    local closestObj = nil
    local shortestDistance = math.huge
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            for _, kw in pairs(keywords) do
                if string.find(string.lower(obj.Name), string.lower(kw)) then
                    local pos = obj:IsA("Model") and (obj.PrimaryPart and obj.PrimaryPart.Position or obj:GetPivot().Position) or obj.Position
                    local dist = (char.HumanoidRootPart.Position - pos).Magnitude
                    if dist < shortestDistance then
                        shortestDistance = dist
                        closestObj = obj
                    end
                end
            end
        end
    end
    return closestObj
end

local function startAutoJobLoop()
    task.spawn(function()
        while isRunning do
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            
            -- 1. Cari & Pindah ke Pendaftaran Job Terdekat
            local jobStartObj = findClosestTarget({"Job", "Start", "Register", "Mulai"})
            if jobStartObj then
                local targetCF = jobStartObj:IsA("Model") and jobStartObj:GetPivot() or jobStartObj.CFrame
                smoothMove(char, targetCF, 30)
                task.wait(1.5)
            end
            
            -- 2. Cek Kendaraan
            local vehicle = getPlayerVehicle()
            
            -- 3. Cari & Pindah ke Tanda Tujuan (Kuning / Checkpoint)
            local targetYellow = findClosestTarget({"Yellow", "Target", "Checkpoint", "Deliver", "Kuning", "Finish"})
            if targetYellow then
                local targetCF = targetYellow:IsA("Model") and targetYellow:GetPivot() or targetYellow.CFrame
                
                if vehicle then
                    smoothMove(vehicle, targetCF + Vector3.new(0, 3, 0), 45)
                else
                    smoothMove(char, targetCF, 30)
                end
                
                task.wait(2)
            end
            
            task.wait(1)
        end
    end)
end

BtnAutoJob.MouseButton1Click:Connect(function()
    isRunning = not isRunning
    if isRunning then
        BtnAutoJob.BackgroundColor3 = Color3.fromRGB(40, 180, 40)
        BtnAutoJob.Text = "STATUS: ON"
        startAutoJobLoop()
    else
        BtnAutoJob.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        BtnAutoJob.Text = "AUTO JOB MAXGEN"
    end
end)
