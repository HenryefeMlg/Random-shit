
-- Henry Games | Part Route Controller
-- StarterPlayer > StarterPlayerScripts > LocalScript
-- Kendi Roblox Studio oyununun test ortamı için.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local running = false
local cards = {}
local cardCounter = 0
local visited = {}
local currentTween = nil
local flying = false

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "HenryRouteController"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(340, 460)
main.Position = UDim2.new(0, 20, 0.5, -230)
main.BackgroundColor3 = Color3.fromRGB(30, 32, 39)
main.BorderSizePixel = 0
main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 35)
title.Position = UDim2.fromOffset(10, 5)
title.BackgroundTransparency = 1
title.Text = "Henry Games | Part Routes"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = main

local function makeBox(parent, placeholder, value, position)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -20, 0, 32)
    box.Position = position
    box.BackgroundColor3 = Color3.fromRGB(45, 48, 58)
    box.TextColor3 = Color3.new(1, 1, 1)
    box.PlaceholderText = placeholder
    box.Text = value
    box.Font = Enum.Font.Gotham
    box.TextSize = 13
    box.ClearTextOnFocus = false
    box.Parent = parent
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
    return box
end

local interval = makeBox(
    main, "Hedefler arası süre (saniye)", "3",
    UDim2.fromOffset(10, 43)
)

local flySpeed = makeBox(
    main, "Uçuş hızı (stud/s)", "45",
    UDim2.fromOffset(10, 81)
)

local flyButton = Instance.new("TextButton")
flyButton.Size = UDim2.new(1, -20, 0, 32)
flyButton.Position = UDim2.fromOffset(10, 119)
flyButton.BackgroundColor3 = Color3.fromRGB(55, 58, 69)
flyButton.TextColor3 = Color3.new(1, 1, 1)
flyButton.Text = "Uçarak git: KAPALI"
flyButton.Font = Enum.Font.Gotham
flyButton.TextSize = 13
flyButton.Parent = main
Instance.new("UICorner", flyButton).CornerRadius = UDim.new(0, 6)

flyButton.MouseButton1Click:Connect(function()
    flying = not flying
    flyButton.Text = flying and "Uçarak git: AÇIK" or "Uçarak git: KAPALI"
    flyButton.BackgroundColor3 = flying
        and Color3.fromRGB(35, 130, 100)
        or Color3.fromRGB(55, 58, 69)
end)

local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, -20, 1, -252)
list.Position = UDim2.fromOffset(10, 159)
list.BackgroundColor3 = Color3.fromRGB(24, 26, 32)
list.BorderSizePixel = 0
list.ScrollBarThickness = 5
list.CanvasSize = UDim2.new()
list.Parent = main
Instance.new("UICorner", list).CornerRadius = UDim.new(0, 6)

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = list

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    list.CanvasSize = UDim2.fromOffset(
        0, layout.AbsoluteContentSize.Y + 8
    )
end)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 22)
status.Position = UDim2.new(0, 10, 1, -78)
status.BackgroundTransparency = 1
status.Text = "Durum: Hazır"
status.TextColor3 = Color3.fromRGB(180, 190, 200)
status.TextSize = 12
status.Font = Enum.Font.Gotham
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = main

local function addCard(defaultName)
    cardCounter += 1

    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -8, 0, 62)
    card.BackgroundColor3 = Color3.fromRGB(42, 45, 54)
    card.BorderSizePixel = 0
    card.LayoutOrder = cardCounter
    card.Parent = list
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)

    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -48, 0, 34)
    input.Position = UDim2.fromOffset(6, 6)
    input.BackgroundColor3 = Color3.fromRGB(56, 60, 71)
    input.TextColor3 = Color3.new(1, 1, 1)
    input.PlaceholderText = "Workspace Part adı"
    input.Text = defaultName or ""
    input.ClearTextOnFocus = false
    input.Font = Enum.Font.Gotham
    input.TextSize = 12
    input.Parent = card
    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 5)

    local remove = Instance.new("TextButton")
    remove.Size = UDim2.fromOffset(30, 30)
    remove.Position = UDim2.new(1, -36, 0, 8)
    remove.BackgroundColor3 = Color3.fromRGB(150, 55, 60)
    remove.Text = "X"
    remove.TextColor3 = Color3.new(1, 1, 1)
    remove.Font = Enum.Font.GothamBold
    remove.TextSize = 13
    remove.Parent = card
    Instance.new("UICorner", remove).CornerRadius = UDim.new(0, 5)

    local number = Instance.new("TextLabel")
    number.Size = UDim2.new(1, -12, 0, 16)
    number.Position = UDim2.fromOffset(6, 43)
    number.BackgroundTransparency = 1
    number.Text = "Hedef #" .. cardCounter
    number.TextColor3 = Color3.fromRGB(175, 185, 200)
    number.TextXAlignment = Enum.TextXAlignment.Left
    number.Font = Enum.Font.Gotham
    number.TextSize = 10
    number.Parent = card

    local entry = {
        frame = card,
        input = input,
        removed = false,
    }

    table.insert(cards, entry)

    remove.MouseButton1Click:Connect(function()
        if running then
            status.Text = "Kart silmek için önce döngüyü durdur."
            return
        end

        entry.removed = true
        card:Destroy()
    end)
end

local addButton = Instance.new("TextButton")
addButton.Size = UDim2.fromOffset(38, 32)
addButton.Position = UDim2.new(1, -48, 1, -40)
addButton.BackgroundColor3 = Color3.fromRGB(55, 125, 100)
addButton.Text = "+"
addButton.TextColor3 = Color3.new(1, 1, 1)
addButton.Font = Enum.Font.GothamBold
addButton.TextSize = 23
addButton.Parent = main
Instance.new("UICorner", addButton).CornerRadius = UDim.new(0, 6)

addButton.MouseButton1Click:Connect(function()
    if not running then
        addCard()
    end
end)

local startButton = Instance.new("TextButton")
startButton.Size = UDim2.new(1, -66, 0, 32)
startButton.Position = UDim2.new(0, 10, 1, -40)
startButton.BackgroundColor3 = Color3.fromRGB(40, 145, 95)
startButton.Text = "Döngüyü başlat"
startButton.TextColor3 = Color3.new(1, 1, 1)
startButton.Font = Enum.Font.GothamBold
startButton.TextSize = 13
startButton.Parent = main
Instance.new("UICorner", startButton).CornerRadius = UDim.new(0, 6)

local function getRoot()
    local character = player.Character
    if not character then return nil end
    return character:FindFirstChild("HumanoidRootPart")
end

local function findPart(name)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == name then
            return obj
        end
    end
    return nil
end

local function waitInterruptible(seconds)
    local finish = os.clock() + seconds

    while running and os.clock() < finish do
        task.wait(0.05)
    end
end

local function moveToPart(part, useFlight)
    local root = getRoot()

    if not root or not part:IsDescendantOf(workspace) then
        return false
    end

    if not useFlight then
        root.CFrame = part.CFrame + Vector3.new(0, 4, 0)
        return true
    end

    local speed = math.clamp(
        tonumber(flySpeed.Text) or 45, 1, 1000
    )

    local distance = (root.Position - part.Position).Magnitude
    local duration = math.max(distance / speed, 0.1)
    local destination = part.CFrame + Vector3.new(0, 4, 0)

    currentTween = TweenService:Create(
        root,
        TweenInfo.new(duration, Enum.EasingStyle.Linear),
        {CFrame = destination}
    )

    currentTween:Play()

    local completed = false
    local connection = currentTween.Completed:Connect(function()
        completed = true
    end)

    while running and not completed do
        if not part:IsDescendantOf(workspace) then
            currentTween:Cancel()
            break
        end
        task.wait(0.05)
    end

    connection:Disconnect()
    currentTween = nil

    return running and completed
end

startButton.MouseButton1Click:Connect(function()
    if running then
        running = false

        if currentTween then
            currentTween:Cancel()
            currentTween = nil
        end

        startButton.Text = "Döngüyü başlat"
        startButton.BackgroundColor3 = Color3.fromRGB(40, 145, 95)
        status.Text = "Durum: Durduruldu"
        return
    end

    local targets = {}
    local unique = {}

    for _, card in ipairs(cards) do
        if not card.removed then
            local name = card.input.Text
                :gsub("^%s+", "")
                :gsub("%s+$", "")

            if name ~= "" then
                if unique[name] then
                    status.Text = "Aynı Part adı iki kez girilmiş."
                    return
                end

                unique[name] = true
                local part = findPart(name)

                if not part then
                    status.Text = "Part bulunamadı: " .. name
                    return
                end

                table.insert(targets, part)
            end
        end
    end

    if #targets == 0 then
        status.Text = "Önce en az bir Part ekle."
        return
    end

    local seconds = tonumber(interval.Text)

    if not seconds or seconds < 0 then
        status.Text = "Geçerli bir süre gir."
        return
    end

    local speed = tonumber(flySpeed.Text)

    if not speed or speed <= 0 then
        status.Text = "Uçuş hızı 0'dan büyük olmalı."
        return
    end

    visited = {}
    running = true

    startButton.Text = "Döngüyü durdur"
    startButton.BackgroundColor3 = Color3.fromRGB(170, 60, 60)

    task.spawn(function()
        for _, part in ipairs(targets) do
            if not running then break end

            if not visited[part] then
                status.Text = "Hedef: " .. part.Name

                if moveToPart(part, flying) then
                    visited[part] = true
                    waitInterruptible(seconds)
                else
                    if running then
                        status.Text = "Hedefe ulaşılamadı."
                    end
                    break
                end
            end
        end

        if running then
            status.Text = "Bütün hedefler tamamlandı."
        end

        running = false
        startButton.Text = "Döngüyü başlat"
        startButton.BackgroundColor3 = Color3.fromRGB(40, 145, 95)
    end)
end)

addCard("Part1")
addCard("Part2")
