-- [[ DELTA YIELD BRANDED EDITION - UPDATED V26.9 ]] --
local players = game:GetService("Players")
local plr = players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local workspace = game:GetService("Workspace")

-- [[ GLOBAL VARIABLES & CONFIG ]] --
local flying, tpwalking, noclip, lampu = false, false, false, false
local flySpeed, tpSpeed = 50, 1
local loopActive = false
local backpackLoop = false
local savedCoords = nil     
local selectedFurniture = "None"
local displayFurnitureName = "None" 

-- Config Backpack (V81)
local backpackPos1 = Vector3.new(239, 6, 399) 
local backpackPos2 = Vector3.new(403, 6, -419)
local MaxCapacity = 30
local AllowedItems = {"food", "bush", "stick", "apple", "berry", "wood", "plant"}
local c1_A, c1_B = Vector3.new(337, 0, 229), Vector3.new(392, 0, 165)
local c2_A, c2_B = Vector3.new(336, 0, -147), Vector3.new(404, 0, -193)

local MinHeight = 0 
local MaxHeight = 25

local ZonaLantai = {
    Pos1 = Vector3.new(68, 2, 151),
    Pos2 = Vector3.new(-267, 20, -141) -- UPDATED: Sesuai permintaan
}
local NamaPreset = {
    ["Chair1"] = "Kursi Bulat",
    ["Chair2"]   = "Kursi Besi Putih",
    ["Table2"] = "Meja Kaca Besi",
    ["Table3"] = "Meja Kotak Putih",
    ["Table4"] = "Meja Kayu Panjang",
    ["Bed1"] = "Ranjang Besar",
    ["BangBed1"] = "Ranjang Tingkat",
    ["Palette2"] = "Kayu Palet",
    ["Sofa2"] = "Sofa Kayu",
    ["Wardrobe1"] = "Lemari Besar",
    ["Shelf2"] = "Lemari Kecil",
    ["Shelf1"] = "Lemari Rak Tinggi",
    ["Shelf3"] = "Rak Kayu Siku",
    ["Lamp1"] = "Lamu Meja",
    ["Lamp2"] = "Lampu Neon",
    ["Lamp3"] = "Lampu Bohlam Kuning",
    
}

-- Events
local PickupEvent = ReplicatedStorage:FindFirstChild("PickupItemEvent")
local DropEvent = ReplicatedStorage:FindFirstChild("DropItemEvent")

-- [[ UI CORE SETUP ]] --
local ScreenGui = Instance.new("ScreenGui", plr:WaitForChild("PlayerGui"))
ScreenGui.Name = "DeltaYield_Integrated"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.Position = UDim2.new(0.5, -200, 0.4, -125)
MainFrame.Size = UDim2.new(0, 420, 0, 320)
MainFrame.Active = true; MainFrame.Draggable = true

-- Title Bar
local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0, 30); TitleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 55)

local AppTitle = Instance.new("TextLabel", TitleBar)
AppTitle.Size = UDim2.new(0.5, 0, 1, 0); AppTitle.Position = UDim2.new(0, 10, 0, 0)
AppTitle.Text = "DN kmkawa"; AppTitle.TextColor3 = Color3.new(1, 1, 1)
AppTitle.Font = Enum.Font.SourceSansBold; AppTitle.TextSize = 18; AppTitle.TextXAlignment = Enum.TextXAlignment.Left; AppTitle.BackgroundTransparency = 1

local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.new(0, 30, 0, 25); CloseBtn.Position = UDim2.new(1, -35, 0, 2)
CloseBtn.Text = "X"; CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0); CloseBtn.TextColor3 = Color3.new(1, 1, 1)

local MiniBtn = Instance.new("TextButton", TitleBar)
MiniBtn.Size = UDim2.new(0, 30, 0, 25); MiniBtn.Position = UDim2.new(1, -70, 0, 2)
MiniBtn.Text = "_"; MiniBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70); MiniBtn.TextColor3 = Color3.new(1, 1, 1)

local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 70, 0, 35); OpenBtn.Position = UDim2.new(0, 10, 0.9, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55); OpenBtn.Text = "OPEN"; OpenBtn.TextColor3 = Color3.new(1, 1, 1)
OpenBtn.Font = Enum.Font.SourceSansBold; OpenBtn.TextSize = 16; OpenBtn.Visible = false; OpenBtn.Draggable = true

-- Tab System Setup
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Position = UDim2.new(0, 0, 0, 30); Sidebar.Size = UDim2.new(0, 100, 1, -30); Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Instance.new("UIListLayout", Sidebar).Padding = UDim.new(0, 2)

local Content = Instance.new("Frame", MainFrame)
Content.Position = UDim2.new(0, 105, 0, 35); Content.Size = UDim2.new(1, -110, 1, -40); Content.BackgroundTransparency = 1

local HomeTab = Instance.new("ScrollingFrame", Content)
local TeleportTab = Instance.new("ScrollingFrame", Content)
local ToPlayerTab = Instance.new("ScrollingFrame", Content)
local AutoFarmTab = Instance.new("ScrollingFrame", Content)
local BackpackTab = Instance.new("ScrollingFrame", Content)

for _, tab in pairs({HomeTab, TeleportTab, ToPlayerTab, AutoFarmTab, BackpackTab}) do
    tab.Size = UDim2.new(1, 0, 1, 0); tab.BackgroundTransparency = 1; tab.Visible = false
    tab.ScrollBarThickness = 3; tab.CanvasSize = UDim2.new(0, 0, 2, 0)
    Instance.new("UIListLayout", tab).Padding = UDim.new(0, 5)
end
HomeTab.Visible = true

-- [[ LOGIC HELPERS ]] --
local function refreshToPlayerList()
    for _, child in pairs(ToPlayerTab:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    for _, p in pairs(players:GetPlayers()) do
        if p ~= plr then
            local btn = Instance.new("TextButton", ToPlayerTab)
            btn.Size = UDim2.new(1, -10, 0, 38); btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            btn.Text = p.DisplayName; btn.TextColor3 = Color3.new(1, 1, 1); btn.Font = Enum.Font.SourceSansBold
            btn.TextSize = 16; btn.BorderSizePixel = 0
            btn.MouseButton1Click:Connect(function()
                if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local targetHrp = p.Character.HumanoidRootPart
                    local safeCFrame = targetHrp.CFrame * CFrame.new(0, 0, 5) 
                    plr.Character.HumanoidRootPart.CFrame = safeCFrame
                end
            end)
        end
    end
end

-- [[ AUTO FARM LOGIC ]] --
local minX, maxX = math.min(ZonaLantai.Pos1.X, ZonaLantai.Pos2.X), math.max(ZonaLantai.Pos1.X, ZonaLantai.Pos2.X)
local minY, maxY = math.min(ZonaLantai.Pos1.Y, ZonaLantai.Pos2.Y), math.max(ZonaLantai.Pos1.Y, ZonaLantai.Pos2.Y)
local minZ, maxZ = math.min(ZonaLantai.Pos1.Z, ZonaLantai.Pos2.Z), math.max(ZonaLantai.Pos1.Z, ZonaLantai.Pos2.Z)

local function isInsideZone(pos)
    return (pos.X >= minX and pos.X <= maxX) and (pos.Y >= minY and pos.Y <= maxY) and (pos.Z >= minZ and pos.Z <= maxZ)
end

-- [[ BACKPACK LOGIC (V81) ]] --
local function IsInCave(pos, pA, pB)
    local cxMin, cxMax = math.min(pA.X, pB.X), math.max(pA.X, pB.X)
    local czMin, czMax = math.min(pA.Z, pB.Z), math.max(pA.Z, pB.Z)
    return pos.X >= cxMin and pos.X <= cxMax and pos.Z >= czMin and pos.Z <= czMax
end

local function IsInBackpackArea(pos)
    local bMinX, bMaxX = math.min(backpackPos1.X, backpackPos2.X), math.max(backpackPos1.X, backpackPos2.X)
    local bMinZ, bMaxZ = math.min(backpackPos1.Z, backpackPos2.Z), math.max(backpackPos1.Z, backpackPos2.Z)
    local inWorkZone = pos.X >= bMinX and pos.X <= bMaxX and pos.Z >= bMinZ and pos.Z <= bMaxZ
    local heightCheck = pos.Y >= MinHeight and pos.Y <= MaxHeight
    return inWorkZone and heightCheck and not IsInCave(pos, c1_A, c1_B) and not IsInCave(pos, c2_A, c2_B)
end

local function GetInventoryCount()
    local count = 0
    for _, item in pairs(plr.Backpack:GetChildren()) do if item:IsA("Tool") then count = count + 1 end end
    if plr.Character then
        for _, item in pairs(plr.Character:GetChildren()) do if item:IsA("Tool") then count = count + 1 end end
    end
    return count
end

local function IsAllowed(name)
    name = name:lower()
    for _, word in pairs(AllowedItems) do if name:find(word) then return true end end
    return false
end

-- [[ UI ENGINE BUILDERS ]] --
local function AddTab(name, targetTab)
    local b = Instance.new("TextButton", Sidebar)
    b.Size = UDim2.new(1, 0, 0, 35); b.Text = name; b.TextColor3 = Color3.new(1, 1, 1); b.BackgroundColor3 = Color3.fromRGB(30, 30, 40); b.BorderSizePixel = 0
    b.MouseButton1Click:Connect(function() 
        HomeTab.Visible = false; TeleportTab.Visible = false; ToPlayerTab.Visible = false; AutoFarmTab.Visible = false; BackpackTab.Visible = false
        targetTab.Visible = true
        if targetTab == ToPlayerTab then refreshToPlayerList() end
    end)
end

local function AddRow(parent, text, hasInp, def, onT, onV)
    local f = Instance.new("Frame", parent); f.Size = UDim2.new(1, -5, 0, 35); f.BackgroundTransparency = 1
    local b = Instance.new("TextButton", f); b.Size = hasInp and UDim2.new(0.7, -5, 1, 0) or UDim2.new(1, 0, 1, 0)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 50); b.Text = text; b.TextColor3 = Color3.new(1, 1, 1); b.Font = Enum.Font.SourceSansBold; b.TextSize = 16; b.BorderSizePixel = 0
    if hasInp then
        local i = Instance.new("TextBox", f); i.Size = UDim2.new(0.3, 0, 1, 0); i.Position = UDim2.new(0.7, 0, 0, 0)
        i.Text = tostring(def); i.BackgroundColor3 = Color3.fromRGB(25, 25, 30); i.TextColor3 = Color3.new(1,1,1); i.BorderSizePixel = 0
        i.FocusLost:Connect(function() onV(tonumber(i.Text) or def) end)
    end
    b.MouseButton1Click:Connect(function() b.BackgroundColor3 = onT() and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 50) end)
end

-- [[ SETUP TABS ]] --
AddTab("Home", HomeTab); AddTab("Teleport", TeleportTab); AddTab("To Player", ToPlayerTab); AddTab("Auto Farm", AutoFarmTab); AddTab("Backpack", BackpackTab)

-- [[ HOME TAB CONTENT ]] --
AddRow(HomeTab, "FLY", true, 50, function() 
    flying = not flying
    if flying then
        local char = plr.Character or plr.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        local hum = char:WaitForChild("Humanoid")
        local bv = Instance.new("BodyVelocity", hrp); bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        local bg = Instance.new("BodyGyro", hrp); bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge); bg.P = 10000
        task.spawn(function()
            while flying do RunService.RenderStepped:Wait()
                bg.CFrame = workspace.CurrentCamera.CFrame
                hum.PlatformStand = true
                bv.Velocity = (hum.MoveDirection.Magnitude > 0) and (workspace.CurrentCamera.CFrame.LookVector * flySpeed) or Vector3.new(0,0,0)
            end
            bv:Destroy(); bg:Destroy(); hum.PlatformStand = false
        end)
    end
    return flying
end, function(v) flySpeed = v end)

AddRow(HomeTab, "TP WALK", true, 1, function() 
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

AddRow(HomeTab, "NO CLIP", false, nil, function() 
    noclip = not noclip
    RunService.Stepped:Connect(function()
        if noclip and plr.Character then
            for _, v in pairs(plr.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
        end
    end)
    return noclip
end)

AddRow(HomeTab, "LAMPU", false, nil, function()
    lampu = not lampu
    local char = plr.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        local light = hrp:FindFirstChild("AvatarLight")
        if lampu then
            if not light then
                light = Instance.new("PointLight", hrp)
                light.Name = "AvatarLight"
                light.Range = 40
                light.Brightness = 1
                light.Shadows = false
            end
        else
            if light then light:Destroy() end
        end
    end
    return lampu
end)

-- [[ TELEPORT TAB CONTENT ]] --
local function AddLoc(txt, cf)
    local b = Instance.new("TextButton", TeleportTab); b.Size = UDim2.new(1, -5, 0, 35); b.Text = txt; b.BackgroundColor3 = Color3.fromRGB(35, 35, 45); b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.SourceSansBold; b.TextSize = 16; b.BorderSizePixel = 0
    b.MouseButton1Click:Connect(function() plr.Character.HumanoidRootPart.CFrame = cf end)
end

AddLoc("MY BUNKER", (function() 
    local bName = plr:GetAttribute("AssignedBunkerName")
    local bFolder = workspace:FindFirstChild("Bunkers")
    if bFolder and bFolder:FindFirstChild(bName) then return bFolder[bName].SpawnLocation.CFrame end
    return CFrame.new(0, 100, 0)
end)())

AddLoc("MARKET", CFrame.new(143, 5, -118))
AddLoc("TO GL", CFrame.new(213, 7, -24))
AddLoc("CRISTAL", CFrame.new(-4683, 6, 245))

-- [[ AUTO FARM TAB CONTENT ]] --
local SetLocBtn = Instance.new("TextButton", AutoFarmTab); SetLocBtn.Size = UDim2.new(1, -5, 0, 40); SetLocBtn.Text = "1. SET DROP POINT"; SetLocBtn.BackgroundColor3 = Color3.fromRGB(40, 80, 40); SetLocBtn.TextColor3 = Color3.new(1,1,1); SetLocBtn.Font = Enum.Font.SourceSansBold; SetLocBtn.TextSize = 16
SetLocBtn.MouseButton1Click:Connect(function()
    savedCoords = plr.Character.HumanoidRootPart.CFrame
    SetLocBtn.Text = "DROP POINT SET ✓"; task.delay(1, function() SetLocBtn.Text = "1. SET DROP POINT" end)
end)

local DropdownBtn = Instance.new("TextButton", AutoFarmTab); DropdownBtn.Size = UDim2.new(1, -5, 0, 40); DropdownBtn.Text = "PILIH BARANG ▼"; DropdownBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45); DropdownBtn.TextColor3 = Color3.new(1,1,1); DropdownBtn.Font = Enum.Font.SourceSansBold; DropdownBtn.TextSize = 16

local DropArea = Instance.new("Frame", AutoFarmTab); DropArea.Size = UDim2.new(1, -5, 0, 120); DropArea.BackgroundColor3 = Color3.fromRGB(25, 25, 30); DropArea.Visible = false
local SearchBox = Instance.new("TextBox", DropArea); SearchBox.Size = UDim2.new(1, -10, 0, 30); SearchBox.Position = UDim2.new(0, 5, 0, 5); SearchBox.PlaceholderText = "Cari..."; SearchBox.BackgroundColor3 = Color3.fromRGB(45, 45, 55); SearchBox.TextColor3 = Color3.new(1,1,1); SearchBox.Text = ""; SearchBox.Font = Enum.Font.SourceSansBold; SearchBox.TextSize = 16

local DropList = Instance.new("ScrollingFrame", DropArea); DropList.Size = UDim2.new(1, -10, 1, -45); DropList.Position = UDim2.new(0, 5, 0, 40); DropList.BackgroundTransparency = 1; DropList.ScrollBarThickness = 2
DropList.AutomaticCanvasSize = Enum.AutomaticSize.Y
DropList.CanvasSize = UDim2.new(0, 0, 0, 0)
Instance.new("UIListLayout", DropList)

local function updateList(filter)
    filter = filter:lower()
    for _, v in pairs(DropList:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    local folder = workspace:FindFirstChild("Wyposazenie") or workspace:FindFirstChild("Furniture")
    if not folder then return end
    local seen = {}
    for _, item in pairs(folder:GetDescendants()) do
        if item:IsA("Model") then
            local prim = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
            if prim and isInsideZone(prim.Position) and not seen[item.Name] then
                local displayName = NamaPreset[item.Name] or item.Name
                if item.Name:lower():find(filter) or displayName:lower():find(filter) then
                    seen[item.Name] = true
                    local b = Instance.new("TextButton", DropList)
                    b.Size = UDim2.new(1, 0, 0, 30); b.Text = displayName; b.BackgroundColor3 = Color3.fromRGB(45, 45, 55); b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.SourceSansBold; b.TextSize = 16
                    b.MouseButton1Click:Connect(function()
                        selectedFurniture = item.Name; displayFurnitureName = displayName
                        DropdownBtn.Text = "TARGET: " .. displayName; DropArea.Visible = false
                    end)
                end
            end
        end
    end
end

DropdownBtn.MouseButton1Click:Connect(function() DropArea.Visible = not DropArea.Visible; if DropArea.Visible then updateList(SearchBox.Text) end end)
SearchBox:GetPropertyChangedSignal("Text"):Connect(function() updateList(SearchBox.Text) end)

local ToggleLoopBtn = Instance.new("TextButton", AutoFarmTab); ToggleLoopBtn.Size = UDim2.new(1, -5, 0, 50); ToggleLoopBtn.Text = "START FULL AUTO"; ToggleLoopBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0); ToggleLoopBtn.TextColor3 = Color3.new(1,1,1); ToggleLoopBtn.Font = Enum.Font.SourceSansBold; ToggleLoopBtn.TextSize = 16

ToggleLoopBtn.MouseButton1Click:Connect(function()
    loopActive = not loopActive
    ToggleLoopBtn.Text = loopActive and ("STOP ["..displayFurnitureName.."]") or "START FULL AUTO"
    ToggleLoopBtn.BackgroundColor3 = loopActive and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(0, 120, 0)
    if loopActive then
        task.spawn(function()
            while loopActive do
                local folder = workspace:FindFirstChild("Wyposazenie") or workspace:FindFirstChild("Furniture")
                if folder and savedCoords then
                    for _, item in pairs(folder:GetDescendants()) do
                        if not loopActive then break end
                        if item.Name == selectedFurniture then
                            local prim = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
                            if prim and isInsideZone(prim.Position) then
                                plr.Character.HumanoidRootPart.CFrame = prim.CFrame
                                task.wait(0.4); if PickupEvent then PickupEvent:FireServer(item) end; task.wait(0.5)
                                plr.Character.HumanoidRootPart.CFrame = savedCoords
                                task.wait(0.5); if DropEvent then DropEvent:FireServer() end; task.wait(1.2)
                            end
                        end
                    end
                end
                task.wait(1)
            end
        end)
    end
end)

-- [[ BACKPACK TAB CONTENT (V81) ]] --
local CollectBtn = Instance.new("TextButton", BackpackTab)
CollectBtn.Size = UDim2.new(1, -5, 0, 50)
CollectBtn.Text = "COLLECT ITEM"
CollectBtn.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
CollectBtn.TextColor3 = Color3.new(1, 1, 1)
CollectBtn.Font = Enum.Font.SourceSansBold
CollectBtn.TextSize = 16

CollectBtn.MouseButton1Click:Connect(function()
    backpackLoop = not backpackLoop
    CollectBtn.Text = backpackLoop and "STOP COLLECTING..." or "COLLECT ITEM"
    CollectBtn.BackgroundColor3 = backpackLoop and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(40, 80, 40)
    
    if backpackLoop then
        task.spawn(function()
            local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then backpackLoop = false return end

            for _, obj in pairs(workspace:GetDescendants()) do
                if not backpackLoop or GetInventoryCount() >= MaxCapacity then break end
                if obj:IsA("ProximityPrompt") then
                    local parent = obj.Parent
                    local pName = parent.Name:lower()
                    if IsAllowed(pName) or parent:IsA("Tool") or (parent.Parent and parent.Parent:IsA("Tool")) then
                        local targetPos = (parent:IsA("BasePart") and parent.Position) or (parent:IsA("Model") and parent:GetModelCFrame().p)
                        if targetPos and IsInBackpackArea(targetPos) then
                            hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 4, 0))
                            task.wait(0.6) 
                            fireproximityprompt(obj)
                            obj:InputHoldBegin(); task.wait(0.1); obj:InputHoldEnd()
                            task.wait(0.4)
                        end
                    end
                end
            end
            backpackLoop = false
            CollectBtn.Text = "COLLECT ITEM"
            CollectBtn.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
        end)
    end
end)

-- [[ WINDOW CONTROLS ]] --
MiniBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; OpenBtn.Visible = true end)
OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = true; OpenBtn.Visible = false end)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy(); flying = false; noclip = false; tpwalking = false; loopActive = false; backpackLoop = false end)
