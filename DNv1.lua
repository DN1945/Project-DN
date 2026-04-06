-- [[ DELTA YIELD V23.2 - CRISTAL COORDS UPDATE ]] --
local players = game:GetService("Players")
local plr = players.LocalPlayer
local RunService = game:GetService("RunService")

-- Global Variables
local flying = false
local tpwalking = false
local noclip = false
local flySpeed = 50 
local tpSpeed = 1

-- [[ UI CORE SETUP ]] --
local ScreenGui = Instance.new("ScreenGui", plr:WaitForChild("PlayerGui"))
ScreenGui.Name = "DeltaYield_V23_2"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.Position = UDim2.new(0.5, -200, 0.4, -125)
MainFrame.Size = UDim2.new(0, 400, 0, 270)
MainFrame.Active = true; MainFrame.Draggable = true

-- Title Bar
local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0, 30); TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)

local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.new(0, 30, 0, 25); CloseBtn.Position = UDim2.new(1, -35, 0, 2)
CloseBtn.Text = "X"; CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50); CloseBtn.TextColor3 = Color3.new(1, 1, 1)

local MiniBtn = Instance.new("TextButton", TitleBar)
MiniBtn.Size = UDim2.new(0, 30, 0, 25); MiniBtn.Position = UDim2.new(1, -70, 0, 2)
MiniBtn.Text = "_"; MiniBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70); MiniBtn.TextColor3 = Color3.new(1, 1, 1)

-- Tab Sidebar
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Position = UDim2.new(0, 0, 0, 30); Sidebar.Size = UDim2.new(0, 100, 1, -30); Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Instance.new("UIListLayout", Sidebar).Padding = UDim.new(0, 2)

local Content = Instance.new("Frame", MainFrame)
Content.Position = UDim2.new(0, 105, 0, 35); Content.Size = UDim2.new(1, -110, 1, -40); Content.BackgroundTransparency = 1

local PlayerTab = Instance.new("ScrollingFrame", Content)
PlayerTab.Size = UDim2.new(1, 0, 1, 0); PlayerTab.BackgroundTransparency = 1; PlayerTab.Visible = true

local TeleportTab = Instance.new("ScrollingFrame", Content)
TeleportTab.Size = UDim2.new(1, 0, 1, 0); TeleportTab.BackgroundTransparency = 1; TeleportTab.Visible = false

Instance.new("UIListLayout", PlayerTab).Padding = UDim.new(0, 5)
Instance.new("UIListLayout", TeleportTab).Padding = UDim.new(0, 5)

-- [[ ENGINE: V3 FLY LOGIC (DIRECTIONAL) ]] --
local function startFlyV3()
    local char = plr.Character or plr.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")

    local bv = Instance.new("BodyVelocity", hrp)
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.new(0, 0, 0)
    
    local bg = Instance.new("BodyGyro", hrp)
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P = 10000
    
    task.spawn(function()
        while flying do
            RunService.RenderStepped:Wait()
            bg.CFrame = workspace.CurrentCamera.CFrame
            hum.PlatformStand = true
            
            local moveDir = hum.MoveDirection
            if moveDir.Magnitude > 0 then
                -- Terbang mengikuti arah kamera (LookVector)
                bv.Velocity = workspace.CurrentCamera.CFrame.LookVector * flySpeed
            else
                -- Diam di udara
                bv.Velocity = Vector3.new(0, 0, 0)
            end
        end
        bv:Destroy(); bg:Destroy()
        hum.PlatformStand = false
    end)
end

-- [[ UTILITIES ]] --
local function toggleNoclip()
    noclip = not noclip
    task.spawn(function()
        while noclip do RunService.Stepped:Wait()
            if plr.Character then
                for _, v in pairs(plr.Character:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
            end
        end
    end)
    return noclip
end

-- UI Helpers
local function AddTab(name)
    local b = Instance.new("TextButton", Sidebar)
    b.Size = UDim2.new(1, 0, 0, 35); b.Text = name; b.TextColor3 = Color3.new(1, 1, 1); b.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    b.MouseButton1Click:Connect(function() PlayerTab.Visible = (name == "Player"); TeleportTab.Visible = (name == "Teleport") end)
end

local function AddRow(parent, text, hasInp, def, onT, onV)
    local f = Instance.new("Frame", parent); f.Size = UDim2.new(1, -5, 0, 35); f.BackgroundTransparency = 1
    local b = Instance.new("TextButton", f); b.Size = hasInp and UDim2.new(0.7, -5, 1, 0) or UDim2.new(1, 0, 1, 0)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 50); b.Text = text; b.TextColor3 = Color3.new(1, 1, 1)
    if hasInp then
        local i = Instance.new("TextBox", f); i.Size = UDim2.new(0.3, 0, 1, 0); i.Position = UDim2.new(0.7, 0, 0, 0)
        i.Text = tostring(def); i.FocusLost:Connect(function() onV(tonumber(i.Text) or def) end)
    end
    b.MouseButton1Click:Connect(function() 
        local s = onT()
        b.BackgroundColor3 = s and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 50) 
    end)
end

AddTab("Player"); AddTab("Teleport")

-- [[ PLAYER TAB CONTENT ]] --
AddRow(PlayerTab, "FLY (V3 Engine)", true, 50, function() 
    flying = not flying
    if flying then startFlyV3() end
    return flying 
end, function(v) flySpeed = v end)

AddRow(PlayerTab, "TP WALK", true, 1, function() 
    tpwalking = not tpwalking
    task.spawn(function()
        while tpwalking do task.wait()
            if plr.Character and plr.Character.Humanoid.MoveDirection.Magnitude > 0 then
                plr.Character.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame + (plr.Character.Humanoid.MoveDirection * tpSpeed)
            end
        end
    end)
    return tpwalking
end, function(v) tpSpeed = v end)

AddRow(PlayerTab, "NO CLIP", false, nil, toggleNoclip)

-- [[ TELEPORT TAB CONTENT ]] --
local function AddTP(txt, cb)
    local b = Instance.new("TextButton", TeleportTab); b.Size = UDim2.new(1, -5, 0, 35); b.BackgroundColor3 = Color3.fromRGB(35, 35, 45); b.Text = txt; b.TextColor3 = Color3.new(1,1,1); b.MouseButton1Click:Connect(cb)
end

AddTP("TO MY BUNKER", function()
    local bName = plr:GetAttribute("AssignedBunkerName")
    local bFolder = workspace:FindFirstChild("Bunkers")
    if bFolder and bFolder:FindFirstChild(bName) then
        plr.Character.HumanoidRootPart.CFrame = bFolder[bName]:FindFirstChild("SpawnLocation").CFrame
    end
end)
AddTP("TO MARKET", function() plr.Character.HumanoidRootPart.CFrame = CFrame.new(143, 5, -118) end)
AddTP("TO CRISTAL", function() plr.Character.HumanoidRootPart.CFrame = CFrame.new(-4671, 7, 254) end) -- Update Koordinat
AddTP("RESET CHAR", function() plr.Character:BreakJoints() end)

-- Restore Button
local OpenBtn = Instance.new("TextButton", ScreenGui); OpenBtn.Size = UDim2.new(0, 60, 0, 30); OpenBtn.Position = UDim2.new(0, 10, 0.9, 0); OpenBtn.Text = "OPEN"; OpenBtn.Visible = false; OpenBtn.Draggable = true
MiniBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; OpenBtn.Visible = true end)
OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = true; OpenBtn.Visible = false end)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy(); flying = false; noclip = false; tpwalking = false end)
