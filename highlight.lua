-- Henry Games Auto Highlight Pro + Notification & Sound Edition
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer
local TargetGui = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

-- Eski GUI varsa temizle
if TargetGui:FindFirstChild("HenryGamesHighlightGUI") then
    TargetGui.HenryGamesHighlightGUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HenryGamesHighlightGUI"
ScreenGui.Parent = TargetGui
ScreenGui.ResetOnSpawn = false

-------------------------------------------------------------------------
-- 1. SAĞ ÜST BİLDİRİM VE SES SİSTEMİ (STACKABLE NOTIFICATION SYSTEM)
-------------------------------------------------------------------------

local NotificationContainer = Instance.new("Frame")
NotificationContainer.Name = "NotificationContainer"
NotificationContainer.Size = UDim2.new(0, 260, 0, 400)
NotificationContainer.Position = UDim2.new(1, -270, 0, 15)
NotificationContainer.BackgroundTransparency = 1
NotificationContainer.Parent = ScreenGui

local NotifLayout = Instance.new("UIListLayout")
NotifLayout.Parent = NotificationContainer
NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifLayout.Padding = UDim.new(0, 8)
NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Top

-- Uyarı Sesi (Roblox'un varsayılan temiz bildirim seslerinden biri)
local NotifSound = Instance.new("Sound")
NotifSound.SoundId = "rbxassetid://4590657391" -- Uyarı ping sesi
NotifSound.Volume = 1
NotifSound.Parent = SoundService

local function sendNotification(text)
    -- Ses Çal
    pcall(function() NotifSound:Play() end)

    -- Bildirim Kartı Oluştur
    local NotifFrame = Instance.new("Frame")
    NotifFrame.Size = UDim2.new(1, 0, 0, 45)
    NotifFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    NotifFrame.BorderSizePixel = 0
    NotifFrame.BackgroundTransparency = 1 -- Animasyon için
    NotifFrame.Parent = NotificationContainer

    local NotifCorner = Instance.new("UICorner")
    NotifCorner.CornerRadius = UDim.new(0, 6)
    NotifCorner.Parent = NotifFrame

    -- Sol tarafa şık bir renk şeridi
    local AccentStrip = Instance.new("Frame")
    AccentStrip.Size = UDim2.new(0, 4, 1, 0)
    AccentStrip.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    AccentStrip.BorderSizePixel = 0
    AccentStrip.Parent = NotifFrame
    Instance.new("UICorner", AccentStrip).CornerRadius = UDim.new(0, 6)

    local NotifLabel = Instance.new("TextLabel")
    NotifLabel.Size = UDim2.new(1, -15, 1, 0)
    NotifLabel.Position = UDim2.new(0, 12, 0, 0)
    NotifLabel.BackgroundTransparency = 1
    NotifLabel.Text = text
    NotifLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    NotifLabel.TextSize = 14
    NotifLabel.Font = Enum.Font.SourceSansBold
    NotifLabel.TextXAlignment = Enum.TextXAlignment.Left
    NotifLabel.TextWrapped = true
    NotifLabel.TextTransparency = 1 -- Animasyon için
    NotifLabel.Parent = NotifFrame

    -- Görünme Animasyonu (Fade In)
    NotifFrame:TweenSizeAndPosition(UDim2.new(1, 0, 0, 45), NotifFrame.Position, "Out", "Quad", 0.3, true)
    for i = 1, 0, -0.1 do
        NotifFrame.BackgroundTransparency = i * 0.15 -- Son hali 0.15 transparanlık
        NotifLabel.TextTransparency = i
        task.wait(0.02)
    end
    NotifFrame.BackgroundTransparency = 0.15
    NotifLabel.TextTransparency = 0

    -- 4 Saniye ekranda tut, sonra sil
    task.delay(4, function()
        if not NotifFrame or not NotifFrame.Parent then return end
        for i = 0, 1, 0.1 do
            NotifFrame.BackgroundTransparency = i
            NotifLabel.TextTransparency = i
            task.wait(0.02)
        end
        NotifFrame:Destroy()
    end)
end

-------------------------------------------------------------------------
-- 2. ANA PANEL VE KONTROLLER
-------------------------------------------------------------------------

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 650, 0, 420)
MainFrame.Position = UDim2.new(0.5, -325, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- Başlık
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -270, 0, 40)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "Henry Games Auto Highlight Pro"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, 0, 1, -40)
ContentFrame.Position = UDim2.new(0, 0, 0, 40)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Minimize Butonu
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -40, 0, 5)
MinimizeButton.Text = "−"
MinimizeButton.TextSize = 20
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
MinimizeButton.Font = Enum.Font.SourceSansBold
MinimizeButton.Parent = MainFrame
Instance.new("UICorner", MinimizeButton).CornerRadius = UDim.new(0, 6)

local isMinimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        ContentFrame.Visible = false
        MainFrame:TweenSize(UDim2.new(0, 650, 0, 40), "Out", "Quad", 0.2, true)
        MinimizeButton.Text = "+"
    else
        MainFrame:TweenSize(UDim2.new(0, 650, 0, 420), "Out", "Quad", 0.2, true, function()
            ContentFrame.Visible = true
        end)
        MinimizeButton.Text = "−"
    end
end)

-- SAVE & LOAD BUTONLARI
local GlobalSaveButton = Instance.new("TextButton")
GlobalSaveButton.Size = UDim2.new(0, 70, 0, 30)
GlobalSaveButton.Position = UDim2.new(1, -190, 0, 5)
GlobalSaveButton.Text = "SAVE"
GlobalSaveButton.TextSize = 14
GlobalSaveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
GlobalSaveButton.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
GlobalSaveButton.Font = Enum.Font.SourceSansBold
GlobalSaveButton.Parent = MainFrame
Instance.new("UICorner", GlobalSaveButton).CornerRadius = UDim.new(0, 6)

local GlobalLoadButton = Instance.new("TextButton")
GlobalLoadButton.Size = UDim2.new(0, 70, 0, 30)
GlobalLoadButton.Position = UDim2.new(1, -115, 0, 5)
GlobalLoadButton.Text = "LOAD"
GlobalLoadButton.TextSize = 14
GlobalLoadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
GlobalLoadButton.BackgroundColor3 = Color3.fromRGB(0, 150, 150)
GlobalLoadButton.Font = Enum.Font.SourceSansBold
GlobalLoadButton.Parent = MainFrame
Instance.new("UICorner", GlobalLoadButton).CornerRadius = UDim.new(0, 6)

-- Ekle (+) Butonu
local AddButton = Instance.new("TextButton")
AddButton.Size = UDim2.new(0, 30, 0, 30)
AddButton.Position = UDim2.new(1, -230, 0, 5)
AddButton.Text = "+"
AddButton.TextSize = 24
AddButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AddButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
AddButton.Font = Enum.Font.SourceSansBold
AddButton.Parent = MainFrame
Instance.new("UICorner", AddButton).CornerRadius = UDim.new(0, 6)

-- Kaydırılabilir Alan
local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, -20, 1, -20)
Container.Position = UDim2.new(0, 10, 0, 10)
Container.BackgroundTransparency = 1
Container.BorderSizePixel = 0
Container.CanvasSize = UDim2.new(0, 0, 0, 0)
Container.ScrollBarThickness = 6
Container.Parent = ContentFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = Container
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)

UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Container.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
end)

local ActiveTrackers = {}

-- Küçük Toggle Oluşturucu
local function createToggle(parent, pos, text, default, isCheckboxStyle)
    local state = default
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 14, 0, 14)
    btn.Position = pos
    btn.BackgroundColor3 = state and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(70, 70, 75)
    btn.Text = isCheckboxStyle and (state and "✓" or "") or ""
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 11
    btn.Font = Enum.Font.SourceSansBold
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 3)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 80, 0, 14)
    lbl.Position = pos + UDim2.new(0, 18, 0, 0)
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    lbl.TextSize = 11
    lbl.Font = Enum.Font.SourceSans
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.BackgroundTransparency = 1
    lbl.Parent = parent

    return btn, function(callback)
        btn.MouseButton1Click:Connect(function()
            state = not state
            btn.BackgroundColor3 = state and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(70, 70, 75)
            if isCheckboxStyle then
                btn.Text = state and "✓" or ""
            end
            callback(state)
        end)
    end
end

local function parsePath(pathStr)
    if pathStr == "" then return nil end
    local cleanPath = pathStr:gsub("^game%.", ""):gsub("^Workspace%.", "workspace.")
    local success, result = pcall(function()
        local current = game
        for segment in cleanPath:gmatch("[^%.]+") do
            current = current:WaitForChild(segment, 2) or current[segment]
        end
        return current
    end)
    return success and result or nil
end

-------------------------------------------------------------------------
-- 3. HIGHLIGHT VE TAKİP SİSTEMİ
-------------------------------------------------------------------------

local function startTracking(cardData)
    local connections = {}
    local activeVisuals = {}

    local function applyESP(object)
        local targetObject = object
        if object:IsA("BasePart") and object.Parent and object.Parent:IsA("Model") then
            targetObject = object.Parent
        end

        if not targetObject:IsA("Model") and not targetObject:IsA("BasePart") then return end
        if activeVisuals[targetObject] then return end

        -- EĞER NOTIFICATION (BİLDİRİM) AÇIKSA, SESLİ BİLDİRİM GÖNDER
        if cardData.Config.Notify then
            sendNotification(targetObject.Name .. " Highlighted!")
        end

        local highlight = Instance.new("Highlight")
        highlight.Parent = targetObject
        highlight.FillColor = cardData.Color
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = cardData.Transparency

        local bgui = Instance.new("BillboardGui")
        bgui.Size = UDim2.new(0, 250, 0, 80)
        bgui.AlwaysOnTop = true
        bgui.Adornee = targetObject
        bgui.Parent = targetObject

        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.TextColor3 = cardData.Color
        textLabel.TextStrokeTransparency = 0
        textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        textLabel.TextSize = cardData.FontSize
        textLabel.Font = Enum.Font.SourceSansBold
        textLabel.Parent = bgui

        activeVisuals[targetObject] = {highlight = highlight, bgui = bgui, label = textLabel}

        local rootPart = targetObject:IsA("Model") and (targetObject.PrimaryPart or targetObject:FindFirstChildWhichIsA("BasePart")) or targetObject
        if not rootPart then return end

        local lastPos = rootPart.Position
        local lastTime = os.clock()

        local renderConn
        renderConn = RunService.RenderStepped:Connect(function()
            if not targetObject:IsDescendantOf(Workspace) or not rootPart or not rootPart.Parent then
                if activeVisuals[targetObject] then
                    pcall(function() activeVisuals[targetObject].highlight:Destroy() end)
                    pcall(function() activeVisuals[targetObject].bgui:Destroy() end)
                    activeVisuals[targetObject] = nil
                end
                renderConn:Disconnect()
                return
            end

            highlight.Enabled = cardData.Config.Visibility
            highlight.FillTransparency = cardData.Transparency
            textLabel.TextSize = cardData.FontSize
            bgui.Enabled = (cardData.Config.Name or cardData.Config.Dist or cardData.Config.SPS)

            local currentPos = rootPart.Position
            local currentTime = os.clock()
            
            local distance = 0
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                distance = math.floor((currentPos - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
            end

            local deltaTime = currentTime - lastTime
            local sps = 0
            if deltaTime > 0 and deltaTime < 1 then
                local deltaDist = (currentPos - lastPos).Magnitude
                sps = math.floor(deltaDist / deltaTime)
            end

            local content = {}
            if cardData.Config.Name then table.insert(content, targetObject.Name) end
            if cardData.Config.Dist then table.insert(content, string.format("Dist: %d studs", distance)) end
            if cardData.Config.SPS then table.insert(content, string.format("Speed: %d SPS", sps)) end
            
            textLabel.Text = table.concat(content, "\n")
            textLabel.TextColor3 = cardData.Color

            lastPos = currentPos
            lastTime = currentTime
        end)
        
        table.insert(connections, renderConn)
    end

    local function checkMatch(child)
        if cardData.Config.CheckAllInside and cardData.InsideName ~= "" then
            local parentFolder = parsePath(cardData.RawPath)
            if parentFolder and child:IsDescendantOf(parentFolder) then
                if string.lower(child.Name) == string.lower(cardData.InsideName) then
                    applyESP(child)
                end
            end
        else
            local targetName = cardData.TargetName
            if child.Name == targetName then
                applyESP(child)
            end
        end
    end

    for _, desc in ipairs(Workspace:GetDescendants()) do checkMatch(desc) end
    
    local descAddedConn = Workspace.DescendantAdded:Connect(function(desc)
        task.wait(0.1)
        checkMatch(desc)
    end)
    table.insert(connections, descAddedConn)

    cardData.Disconnect = function()
        for _, conn in ipairs(connections) do if conn.Connected then conn:Disconnect() end end
        for obj, visuals in pairs(activeVisuals) do
            pcall(function() visuals.highlight:Destroy() end)
            pcall(function() visuals.bgui:Destroy() end)
        end
        table.clear(activeVisuals)
    end
end

-------------------------------------------------------------------------
-- 4. KART VE UI OLUŞTURUCU
-------------------------------------------------------------------------

local function createTrackerCard(loadedData)
    local cardId = tostring(math.random(100000, 999999))
    
    local cardData = {
        RawPath = loadedData and loadedData.RawPath or "",
        TargetName = loadedData and loadedData.TargetName or "",
        InsideName = loadedData and loadedData.InsideName or "",
        Color = loadedData and Color3.new(loadedData.Color[1], loadedData.Color[2], loadedData.Color[3]) or Color3.fromRGB(255, 0, 0),
        Transparency = loadedData and loadedData.Transparency or 0.4,
        FontSize = loadedData and loadedData.FontSize or 14,
        Disconnect = nil,
        Config = {
            SPS = loadedData and loadedData.Config.SPS or true,
            Dist = loadedData and loadedData.Config.Dist or true,
            Name = loadedData and loadedData.Config.Name or true,
            Visibility = loadedData and loadedData.Config.Visibility or true,
            CheckAllInside = loadedData and loadedData.Config.CheckAllInside or false,
            Notify = loadedData and loadedData.Config.Notify or false -- Başlangıçta UNCHECKED (false) gelir
        }
    }

    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, -10, 0, 85)
    Card.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    Card.BorderSizePixel = 0
    Card.Parent = Container

    local CardCorner = Instance.new("UICorner")
    CardCorner.CornerRadius = UDim.new(0, 6)
    CardCorner.Parent = Card

    -- Girdiler
    local TextBox = Instance.new("TextBox")
    TextBox.Size = UDim2.new(0, 180, 0, 26)
    TextBox.Position = UDim2.new(0, 10, 0, 10)
    TextBox.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextBox.PlaceholderText = "Yol (game.Workspace.CurrentRooms)"
    TextBox.Text = cardData.RawPath
    TextBox.Font = Enum.Font.SourceSans
    TextBox.TextSize = 12
    TextBox.ClearTextOnFocus = false
    TextBox.Parent = Card
    Instance.new("UICorner", TextBox).CornerRadius = UDim.new(0, 4)

    local InsideBox = Instance.new("TextBox")
    InsideBox.Size = UDim2.new(0, 180, 0, 26)
    InsideBox.Position = UDim2.new(0, 10, 0, 44)
    InsideBox.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    InsideBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    InsideBox.PlaceholderText = "Model/Parça Adı (örn: RushNew)"
    InsideBox.Text = cardData.InsideName
    InsideBox.Font = Enum.Font.SourceSans
    InsideBox.TextSize = 12
    InsideBox.Visible = cardData.Config.CheckAllInside
    InsideBox.ClearTextOnFocus = false
    InsideBox.Parent = Card
    Instance.new("UICorner", InsideBox).CornerRadius = UDim.new(0, 4)

    local TransBox = Instance.new("TextBox")
    TransBox.Size = UDim2.new(0, 45, 0, 26)
    TransBox.Position = UDim2.new(0, 196, 0, 10)
    TransBox.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    TransBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    TransBox.PlaceholderText = "Şef."
    TransBox.Text = tostring(cardData.Transparency)
    TransBox.Font = Enum.Font.SourceSans
    TransBox.TextSize = 12
    TransBox.Parent = Card
    Instance.new("UICorner", TransBox).CornerRadius = UDim.new(0, 4)

    local SizeBox = Instance.new("TextBox")
    SizeBox.Size = UDim2.new(0, 45, 0, 26)
    SizeBox.Position = UDim2.new(0, 196, 0, 44)
    SizeBox.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    SizeBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    SizeBox.PlaceholderText = "Boyut"
    SizeBox.Text = tostring(cardData.FontSize)
    SizeBox.Font = Enum.Font.SourceSans
    SizeBox.TextSize = 12
    SizeBox.Parent = Card
    Instance.new("UICorner", SizeBox).CornerRadius = UDim.new(0, 4)

    local ColorButton = Instance.new("TextButton")
    ColorButton.Size = UDim2.new(0, 26, 0, 60)
    ColorButton.Position = UDim2.new(0, 248, 0, 10)
    ColorButton.BackgroundColor3 = cardData.Color
    ColorButton.Text = ""
    ColorButton.Parent = Card
    Instance.new("UICorner", ColorButton).CornerRadius = UDim.new(0, 4)

    -- Toggles
    local _, toggleSPS = createToggle(Card, UDim2.new(0, 290, 0, 15), "Show SPS", cardData.Config.SPS)
    local _, toggleDist = createToggle(Card, UDim2.new(0, 380, 0, 15), "Show Dist", cardData.Config.Dist)
    local _, toggleName = createToggle(Card, UDim2.new(0, 290, 0, 45), "Show Name", cardData.Config.Name)
    local _, toggleVis = createToggle(Card, UDim2.new(0, 380, 0, 45), "Part Visibility", cardData.Config.Visibility)
    local _, toggleInside = createToggle(Card, UDim2.new(0, 470, 0, 15), "Check All Inside", cardData.Config.CheckAllInside)
    
    -- YENİ: NOTIFY CHECKBOX (Başlangıçta uncheckli gelir, checklenirse ses ve bildirim atar)
    local _, toggleNotify = createToggle(Card, UDim2.new(0, 470, 0, 45), "Notify", cardData.Config.Notify, true)

    local DeleteButton = Instance.new("TextButton")
    DeleteButton.Size = UDim2.new(0, 26, 0, 26)
    DeleteButton.Position = UDim2.new(1, -36, 0, 10)
    DeleteButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    DeleteButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    DeleteButton.Text = "X"
    DeleteButton.Font = Enum.Font.SourceSansBold
    DeleteButton.Parent = Card
    Instance.new("UICorner", DeleteButton).CornerRadius = UDim.new(0, 4)

    local function restart()
        if cardData.RawPath ~= "" then
            if cardData.Disconnect then cardData.Disconnect() end
            startTracking(cardData)
        end
    end

    TextBox.FocusLost:Connect(function()
        if TextBox.Text ~= "" then
            cardData.RawPath = TextBox.Text
            cardData.TargetName = TextBox.Text:match("[^%.]+$") or TextBox.Text
            restart()
        end
    end)

    InsideBox.FocusLost:Connect(function()
        cardData.InsideName = InsideBox.Text
        restart()
    end)

    TransBox.FocusLost:Connect(function()
        local val = tonumber(TransBox.Text)
        if val then cardData.Transparency = math.clamp(val, 0, 1) end
    end)

    SizeBox.FocusLost:Connect(function()
        local val = tonumber(SizeBox.Text)
        if val then cardData.FontSize = math.clamp(val, 6, 36) end
    end)

    toggleSPS(function(v) cardData.Config.SPS = v end)
    toggleDist(function(v) cardData.Config.Dist = v end)
    toggleName(function(v) cardData.Config.Name = v end)
    toggleVis(function(v) cardData.Config.Visibility = v end)
    toggleInside(function(v) 
        cardData.Config.CheckAllInside = v
        InsideBox.Visible = v
        restart()
    end)
    
    -- Notify Tetikleyicisi
    toggleNotify(function(v)
        cardData.Config.Notify = v
    end)

    local colors = {Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 255, 0), Color3.fromRGB(0, 150, 255), Color3.fromRGB(255, 255, 0), Color3.fromRGB(255, 0, 255)}
    local currentColorIndex = 1
    ColorButton.MouseButton1Click:Connect(function()
        currentColorIndex = currentColorIndex % #colors + 1
        cardData.Color = colors[currentColorIndex]
        ColorButton.BackgroundColor3 = cardData.Color
    end)

    DeleteButton.MouseButton1Click:Connect(function()
        if cardData.Disconnect then cardData.Disconnect() end
        ActiveTrackers[cardId] = nil
        Card:Destroy()
    end)

    ActiveTrackers[cardId] = cardData
    if cardData.RawPath ~= "" then restart() end
end

local function clearAllTrackers()
    for id, card in pairs(ActiveTrackers) do
        if card.Disconnect then card.Disconnect() end
    end
    table.clear(ActiveTrackers)
    Container:ClearAllChildren()
    
    UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = Container
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 8)
    UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Container.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
    end)
end

local function saveConfigToFile()
    if writefile then
        local dataToSave = {}
        for id, card in pairs(ActiveTrackers) do
            table.insert(dataToSave, {
                RawPath = card.RawPath,
                TargetName = card.TargetName,
                InsideName = card.InsideName,
                Color = {card.Color.R, card.Color.G, card.Color.B},
                Transparency = card.Transparency,
                FontSize = card.FontSize,
                Config = card.Config
            })
        end
        local json = HttpService:JSONEncode(dataToSave)
        writefile("HenryGamesConfig.json", json)
    end
end

local function loadConfigFromFile()
    if readfile and isfile and isfile("HenryGamesConfig.json") then
        local json = readfile("HenryGamesConfig.json")
        local success, decoded = pcall(function() return HttpService:JSONDecode(json) end)
        if success and decoded then
            clearAllTrackers()
            for _, cardData in ipairs(decoded) do
                createTrackerCard(cardData)
            end
            return true
        end
    end
    return false
end

GlobalSaveButton.MouseButton1Click:Connect(saveConfigToFile)
GlobalLoadButton.MouseButton1Click:Connect(loadConfigFromFile)

AddButton.MouseButton1Click:Connect(function()
    createTrackerCard()                                         
end)

local hasLoaded = loadConfigFromFile()
if not hasLoaded then
    createTrackerCard()
end
