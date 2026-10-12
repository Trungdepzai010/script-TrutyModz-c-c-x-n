local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local isTuned = false
local addHPVal = 10000
local addRPMVal = 5000
local gear1Mult = 1.0
local gearOthersMult = 1.0

local isAutoWheelieOn = false
local isAutoThrottleOn = false

local currentCar = nil
local activeItems = {}
local currentIndex = 1
local highlight = nil

local frontSuspVal = 2.0
local rearSuspVal = 2.0

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Drag Drive Simulator | by TrungDZ",
   LoadingTitle = "Đang tải hệ thống...",
   LoadingSubtitle = "by TrutyModz",
   ConfigurationSaving = {
      Enabled = false,
   },
   KeySystem = true,
   KeySettings = {
      Title = "Xác Thực Key",
      Subtitle = "Nhập Key Script",
      Note = "Key mặc định: DELTA2026",
      FileName = "DragTunerKey",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"DELTA2026"}
   }
})

local TuneTab = Window:CreateTab("Tune Car", 4483362458)
local SuspensionTab = Window:CreateTab("Suspension Tuner", 4483362458)
local FarmTab = Window:CreateTab("Auto Wheelie EXP Farm", 4483362458)
local DismantleTab = Window:CreateTab("Vehicle Dismantler", 4483362458)
local MusicTab = Window:CreateTab("Boombox Music IDs", 4483362458)
local InfoTab = Window:CreateTab("Thông Tin", 4483362458)

TuneTab:CreateSection("Cài đặt thông số xe")

TuneTab:CreateInput({
   Name = "Sức mạnh (HP)",
   PlaceholderText = "10000",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      addHPVal = tonumber(Text) or 10000
   end,
})

TuneTab:CreateInput({
   Name = "Max RPM",
   PlaceholderText = "5000",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      addRPMVal = tonumber(Text) or 5000
   end,
})

TuneTab:CreateInput({
   Name = "Hệ số Gear 1",
   PlaceholderText = "1.0",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      gear1Mult = tonumber(Text) or 1.0
   end,
})

TuneTab:CreateInput({
   Name = "Gear sau Gear 1",
   PlaceholderText = "1.0",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      gearOthersMult = tonumber(Text) or 1.0
   end,
})

TuneTab:CreateButton({
   Name = "Áp dụng Tuning",
   Callback = function()
      isTuned = true
      Rayfield:Notify({Title = "Thành công", Content = "Đã áp dụng thông số xe!", Duration = 2})
   end,
})

TuneTab:CreateButton({
   Name = "OFF / Reset Xe Zin",
   Callback = function()
      isTuned = false
      Rayfield:Notify({Title = "Reset", Content = "Đã đưa xe về zin!", Duration = 2})
   end,
})

SuspensionTab:CreateSection("Truck & Car Suspension Settings")

SuspensionTab:CreateInput({
   Name = "Front Suspension Length",
   PlaceholderText = "2.0",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      frontSuspVal = tonumber(Text) or 2.0
   end,
})

SuspensionTab:CreateButton({
   Name = "Apply Front Suspension",
   Callback = function()
      local char = LocalPlayer.Character
      if char and char:FindFirstChildOfClass("Humanoid") then
         local seat = char.Humanoid.SeatPart
         if seat and seat:IsA("VehicleSeat") then
            local model = seat:FindFirstAncestorOfClass("Model")
            if model then
               for _, v in ipairs(model:GetDescendants()) do
                  if v:IsA("SpringConstraint") then
                     local pName = v.Parent and string.upper(v.Parent.Name) or ""
                     local name = string.upper(v.Name)
                     if pName == "FL" or pName == "FR" or name == "FSUSPENSION" or string.find(name, "FRONT") then
                        v.FreeLength = frontSuspVal
                        v.MinLength = math.clamp(frontSuspVal - 1, 0, frontSuspVal)
                        v.MaxLength = frontSuspVal + 2
                     end
                  end
               end
               Rayfield:Notify({Title = "Thành công", Content = "Đã chỉnh phuộc trước!", Duration = 2})
            end
         end
      end
   end,
})

SuspensionTab:CreateInput({
   Name = "Rear Suspension Length",
   PlaceholderText = "2.0",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      rearSuspVal = tonumber(Text) or 2.0
   end,
})

SuspensionTab:CreateButton({
   Name = "Apply Rear Suspension",
   Callback = function()
      local char = LocalPlayer.Character
      if char and char:FindFirstChildOfClass("Humanoid") then
         local seat = char.Humanoid.SeatPart
         if seat and seat:IsA("VehicleSeat") then
            local model = seat:FindFirstAncestorOfClass("Model")
            if model then
               for _, v in ipairs(model:GetDescendants()) do
                  if v:IsA("SpringConstraint") then
                     local pName = v.Parent and string.upper(v.Parent.Name) or ""
                     local name = string.upper(v.Name)
                     if pName == "RL" or pName == "RR" or name == "RSUSPENSION" or string.find(name, "REAR") then
                        v.FreeLength = rearSuspVal
                        v.MinLength = math.clamp(rearSuspVal - 1, 0, rearSuspVal)
                        v.MaxLength = rearSuspVal + 2
                     end
                  end
               end
               Rayfield:Notify({Title = "Thành công", Content = "Đã chỉnh phuộc sau!", Duration = 2})
            end
         end
      end
   end,
})

MusicTab:CreateSection("Auto Updated Music List (GitHub)")

local githubRawUrl = "https://raw.githubusercontent.com/Trungdepzai010/script-TrutyModz-c-c-x-n/main/songs.json"

local success, response = pcall(function()
    return game:HttpGet(githubRawUrl)
end)

if success and response then
    local jsonSuccess, songList = pcall(function()
        return HttpService:JSONDecode(response)
    end)
    if jsonSuccess and type(songList) == "table" then
        Rayfield:Notify({Title = "Thành công", Content = "Đã tải " .. #songList .. " bài hát!", Duration = 3})
        for _, song in ipairs(songList) do
            MusicTab:CreateButton({
               Name = "Copy ID: " .. tostring(song.Name) .. " (" .. tostring(song.ID) .. ")",
               Callback = function()
                  if setclipboard then
                     setclipboard(tostring(song.ID))
                     Rayfield:Notify({Title = "Copied", Content = "Copied ID: " .. tostring(song.ID), Duration = 2})
                  end
               end,
            })
        end
    else
        Rayfield:Notify({Title = "Lỗi JSON", Content = "File songs.json sai định dạng!", Duration = 4})
    end
else
    Rayfield:Notify({Title = "Lỗi kết nối", Content = "Không thể tải file từ GitHub!", Duration = 4})
end

MusicTab:CreateSection("Play Custom Music")

MusicTab:CreateInput({
   Name = "Play Custom Music ID",
   PlaceholderText = "Enter audio ID...",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      local id = tonumber(Text)
      if id then
         local char = LocalPlayer.Character
         if char then
            local tool = char:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
            if tool then
               for _, d in ipairs(tool:GetDescendants()) do
                  if d:IsA("Sound") then
                     d.SoundId = "rbxassetid://" .. tostring(id)
                     d:Play()
                     Rayfield:Notify({Title = "Success", Content = "Playing ID: " .. id, Duration = 2})
                     return
                  end
               end
            end
            Rayfield:Notify({Title = "Notice", Content = "Please equip a Boombox/Radio first!", Duration = 2})
         end
      end
   end,
})

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoDriveWheelieGui"
screenGui.ResetOnSpawn = false

if LocalPlayer:FindFirstChild("PlayerGui") then
    local old = LocalPlayer.PlayerGui:FindFirstChild("AutoDriveWheelieGui")
    if old then old:Destroy() end
    screenGui.Parent = LocalPlayer.PlayerGui
end

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 170, 0, 110)
mainFrame.Position = UDim2.new(0.8, 0, 0.4, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
mainFrame.Active = true
mainFrame.Visible = false
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(45, 45, 55)
frameStroke.Thickness = 1.5
frameStroke.Parent = mainFrame

local throttleBtn = Instance.new("TextButton")
throttleBtn.Size = UDim2.new(1, -12, 0, 44)
throttleBtn.Position = UDim2.new(0, 6, 0, 6)
throttleBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
throttleBtn.Text = "AUTO GA: OFF"
throttleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
throttleBtn.Font = Enum.Font.SourceSansBold
throttleBtn.TextSize = 13
throttleBtn.Parent = mainFrame

local throttleCorner = Instance.new("UICorner")
throttleCorner.CornerRadius = UDim.new(0, 6)
throttleCorner.Parent = throttleBtn

local wheelieBtn = Instance.new("TextButton")
wheelieBtn.Size = UDim2.new(1, -12, 0, 44)
wheelieBtn.Position = UDim2.new(0, 6, 0, 56)
wheelieBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
wheelieBtn.Text = "AUTO BỐC ĐẦU: OFF"
wheelieBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
wheelieBtn.Font = Enum.Font.SourceSansBold
wheelieBtn.TextSize = 13
wheelieBtn.Parent = mainFrame

local wheelieCorner = Instance.new("UICorner")
wheelieCorner.CornerRadius = UDim.new(0, 6)
wheelieCorner.Parent = wheelieBtn

local dragging, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = mainFrame.Position
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input) dragging = false end)

local function toggleButtonState(buttonObj, isStart, keywordList)
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not pGui then return end

    for _, obj in ipairs(pGui:GetDescendants()) do
        if (obj:IsA("TextButton") or obj:IsA("ImageButton")) and obj ~= throttleBtn and obj ~= wheelieBtn then
            local n = obj.Name:lower()
            local matched = false
            for _, kw in ipairs(keywordList) do
                if n:find(kw) then
                    matched = true
                    break
                end
            end

            if matched and getconnections then
                if isStart then
                    for _, conn in ipairs(getconnections(obj.InputBegan)) do
                        pcall(function() conn:Fire({UserInputType = Enum.UserInputType.Touch, UserInputState = Enum.UserInputState.Begin}) end)
                    end
                    for _, conn in ipairs(getconnections(obj.MouseButton1Down)) do
                        pcall(function() conn:Fire() end)
                    end
                else
                    for _, conn in ipairs(getconnections(obj.InputEnded)) do
                        pcall(function() conn:Fire({UserInputType = Enum.UserInputType.Touch, UserInputState = Enum.UserInputState.End}) end)
                    end
                    for _, conn in ipairs(getconnections(obj.MouseButton1Up)) do
                        pcall(function() conn:Fire() end)
                    end
                end
            end
        end
    end
end

throttleBtn.MouseButton1Click:Connect(function()
    isAutoThrottleOn = not isAutoThrottleOn
    if isAutoThrottleOn then
        throttleBtn.Text = "AUTO GA: ON"
        throttleBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
        toggleButtonState(throttleBtn, true, {"gas", "throttle", "accelerate", "forward", "up", "drive"})
    else
        throttleBtn.Text = "AUTO GA: OFF"
        throttleBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        toggleButtonState(throttleBtn, false, {"gas", "throttle", "accelerate", "forward", "up", "drive"})
    end
end)

wheelieBtn.MouseButton1Click:Connect(function()
    isAutoWheelieOn = not isAutoWheelieOn
    if isAutoWheelieOn then
        wheelieBtn.Text = "AUTO BỐC ĐẦU: ON"
        wheelieBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
        toggleButtonState(wheelieBtn, true, {"wheelie", "wheeliesit", "wheeliestep", "bocdau"})
    else
        wheelieBtn.Text = "AUTO BỐC ĐẦU: OFF"
        wheelieBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        toggleButtonState(wheelieBtn, false, {"wheelie", "wheeliesit", "wheeliestep", "bocdau"})
    end
end)

FarmTab:CreateSection("Auto Wheelie Panel")

FarmTab:CreateToggle({
   Name = "Enable Floating Farm Buttons",
   CurrentValue = false,
   Flag = "WheelieFarmToggle",
   Callback = function(Value)
      mainFrame.Visible = Value
      if not Value then
          if isAutoThrottleOn then
              isAutoThrottleOn = false
              throttleBtn.Text = "AUTO GA: OFF"
              throttleBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
              toggleButtonState(throttleBtn, false, {"gas", "throttle", "accelerate", "forward", "up", "drive"})
          end
          if isAutoWheelieOn then
              isAutoWheelieOn = false
              wheelieBtn.Text = "AUTO BỐC ĐẦU: OFF"
              wheelieBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
              toggleButtonState(wheelieBtn, false, {"wheelie", "wheeliesit", "wheeliestep", "bocdau"})
          end
      end
   end,
})

local dismantleFrame = Instance.new("Frame")
dismantleFrame.Size = UDim2.new(0, 240, 0, 220)
dismantleFrame.Position = UDim2.new(0.05, 0, 0.35, 0)
dismantleFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
dismantleFrame.Active = true
dismantleFrame.Visible = false
dismantleFrame.Parent = screenGui

local disCorner = Instance.new("UICorner")
disCorner.CornerRadius = UDim.new(0, 8)
disCorner.Parent = dismantleFrame

local disStroke = Instance.new("UIStroke")
disStroke.Color = Color3.fromRGB(45, 45, 60)
disStroke.Thickness = 1.5
disStroke.Parent = dismantleFrame

local disTitle = Instance.new("TextLabel")
disTitle.Size = UDim2.new(1, 0, 0, 30)
disTitle.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
disTitle.TextColor3 = Color3.fromRGB(0, 255, 170)
disTitle.TextSize = 13
disTitle.Font = Enum.Font.SourceSansBold
disTitle.Text = "DISMANTLE CAR PANEL"
disTitle.Parent = dismantleFrame
Instance.new("UICorner", disTitle).CornerRadius = UDim.new(0, 8)

local scanBtn = Instance.new("TextButton")
scanBtn.Size = UDim2.new(0.9, 0, 0, 30)
scanBtn.Position = UDim2.new(0.05, 0, 0, 36)
scanBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
scanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
scanBtn.TextSize = 12
scanBtn.Font = Enum.Font.SourceSansBold
scanBtn.Text = "QUÉT XE (SCAN OBJECTS)"
scanBtn.Parent = dismantleFrame
Instance.new("UICorner", scanBtn).CornerRadius = UDim.new(0, 6)

local folderScroll = Instance.new("ScrollingFrame")
folderScroll.Size = UDim2.new(0.9, 0, 0, 60)
folderScroll.Position = UDim2.new(0.05, 0, 0, 72)
folderScroll.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
folderScroll.BorderSizePixel = 0
folderScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
folderScroll.ScrollBarThickness = 3
folderScroll.Parent = dismantleFrame
Instance.new("UICorner", folderScroll).CornerRadius = UDim.new(0, 4)

local folderLayout = Instance.new("UIListLayout")
folderLayout.Parent = folderScroll

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(0.9, 0, 0, 24)
infoLabel.Position = UDim2.new(0.05, 0, 0, 136)
infoLabel.BackgroundTransparency = 1
infoLabel.TextColor3 = Color3.fromRGB(255, 220, 0)
infoLabel.TextSize = 11
infoLabel.Font = Enum.Font.SourceSans
infoLabel.Text = "Hãy ngồi lên xe & Quét Xe"
infoLabel.Parent = dismantleFrame

local prevBtn = Instance.new("TextButton")
prevBtn.Size = UDim2.new(0.26, 0, 0, 32)
prevBtn.Position = UDim2.new(0.05, 0, 0, 166)
prevBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
prevBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
prevBtn.TextSize = 12
prevBtn.Font = Enum.Font.SourceSansBold
prevBtn.Text = "< Trái"
prevBtn.Parent = dismantleFrame
Instance.new("UICorner", prevBtn).CornerRadius = UDim.new(0, 6)

local deleteBtn = Instance.new("TextButton")
deleteBtn.Size = UDim2.new(0.34, 0, 0, 32)
deleteBtn.Position = UDim2.new(0.33, 0, 0, 166)
deleteBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
deleteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
deleteBtn.TextSize = 12
deleteBtn.Font = Enum.Font.SourceSansBold
deleteBtn.Text = "XÓA ITEM"
deleteBtn.Parent = dismantleFrame
Instance.new("UICorner", deleteBtn).CornerRadius = UDim.new(0, 6)

local nextBtn = Instance.new("TextButton")
nextBtn.Size = UDim2.new(0.26, 0, 0, 32)
nextBtn.Position = UDim2.new(0.69, 0, 0, 166)
nextBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
nextBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
nextBtn.TextSize = 12
nextBtn.Font = Enum.Font.SourceSansBold
nextBtn.Text = "Phải >"
nextBtn.Parent = dismantleFrame
Instance.new("UICorner", nextBtn).CornerRadius = UDim.new(0, 6)

local disDragging, disDragStart, disStartPos
dismantleFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        disDragging = true; disDragStart = input.Position; disStartPos = dismantleFrame.Position
    end
end)

dismantleFrame.InputChanged:Connect(function(input)
    if disDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - disDragStart
        dismantleFrame.Position = UDim2.new(disStartPos.X.Scale, disStartPos.X.Offset + delta.X, disStartPos.Y.Scale, disStartPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input) disDragging = false end)

local function clearHighlight()
	if highlight then
		highlight:Destroy()
		highlight = nil
	end
end

local function cleanInvalidItems()
	local valid = {}
	for _, obj in ipairs(activeItems) do
		if obj and obj.Parent then
			table.insert(valid, obj)
		end
	end
	activeItems = valid
end

local function updateHighlight()
	cleanInvalidItems()

	if #activeItems == 0 then
		clearHighlight()
		infoLabel.Text = "Danh sách rỗng!"
		return
	end

	if currentIndex < 1 then currentIndex = #activeItems end
	if currentIndex > #activeItems then currentIndex = 1 end

	local targetObj = activeItems[currentIndex]

	if targetObj:IsA("BasePart") then
		if not highlight then
			highlight = Instance.new("Highlight")
			highlight.FillColor = Color3.fromRGB(255, 255, 0)
			highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
			highlight.FillTransparency = 0.3
		end
		highlight.Adornee = targetObj
		highlight.Parent = targetObj
	else
		clearHighlight()
	end

	infoLabel.Text = "[" .. targetObj.ClassName .. "]: " .. targetObj.Name .. " (" .. currentIndex .. "/" .. #activeItems .. ")"
end

local function clearFolderScroll()
	for _, v in ipairs(folderScroll:GetChildren()) do
		if v:IsA("TextButton") then v:Destroy() end
	end
end

local function loadContainerItems(containerObj)
	activeItems = {}
	currentIndex = 1

	if containerObj == currentCar then
		for _, obj in ipairs(currentCar:GetDescendants()) do
			table.insert(activeItems, obj)
		end
	else
		for _, obj in ipairs(containerObj:GetDescendants()) do
			table.insert(activeItems, obj)
		end
		table.insert(activeItems, containerObj)
	end

	updateHighlight()
end

scanBtn.MouseButton1Click:Connect(function()
	clearFolderScroll()
	activeItems = {}
	clearHighlight()

	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hum or not hum.SeatPart then
		infoLabel.Text = "Hãy ngồi lên ghế lái xe trước!"
		return
	end

	currentCar = hum.SeatPart:FindFirstAncestorOfClass("Model")
	if not currentCar then
		infoLabel.Text = "Không tìm thấy Model xe!"
		return
	end

	local allDescendants = currentCar:GetDescendants()
	infoLabel.Text = "Tổng: " .. #allDescendants .. " vật thể."

	local allBtn = Instance.new("TextButton")
	allBtn.Size = UDim2.new(1, 0, 0, 22)
	allBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
	allBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	allBtn.TextSize = 10
	allBtn.Font = Enum.Font.SourceSansBold
	allBtn.Text = "🌐 TẤT CẢ VẬT THỂ (" .. #allDescendants .. ")"
	allBtn.Parent = folderScroll

	allBtn.MouseButton1Click:Connect(function()
		infoLabel.Text = "Đang chọn: TẤT CẢ VẬT THỂ XE"
		loadContainerItems(currentCar)
	end)

	for _, child in ipairs(currentCar:GetChildren()) do
		local count = #child:GetDescendants()
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, 22)
		btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
		btn.TextColor3 = Color3.fromRGB(100, 200, 255)
		btn.TextSize = 10
		btn.Text = "📁 " .. child.Name .. " (" .. count .. ")"
		btn.Parent = folderScroll

		btn.MouseButton1Click:Connect(function()
			infoLabel.Text = "Đang chọn: " .. child.Name
			loadContainerItems(child)
		end)
	end

	folderScroll.CanvasSize = UDim2.new(0, 0, 0, folderLayout.AbsoluteContentSize.Y)
end)

prevBtn.MouseButton1Click:Connect(function()
	if #activeItems > 0 then
		currentIndex = currentIndex - 1
		updateHighlight()
	end
end)

nextBtn.MouseButton1Click:Connect(function()
	if #activeItems > 0 then
		currentIndex = currentIndex + 1
		updateHighlight()
	end
end)

deleteBtn.MouseButton1Click:Connect(function()
	if #activeItems > 0 and activeItems[currentIndex] then
		local targetObj = activeItems[currentIndex]
		
		clearHighlight()
		targetObj:Destroy()
		table.remove(activeItems, currentIndex)

		updateHighlight()
	end
end)

DismantleTab:CreateSection("Vehicle Dismantler Panel")

DismantleTab:CreateToggle({
   Name = "Enable Dismantle Floating Buttons",
   CurrentValue = false,
   Flag = "DismantleToggle",
   Callback = function(Value)
      dismantleFrame.Visible = Value
      if not Value then
         clearHighlight()
      end
   end,
})

InfoTab:CreateSection("Hướng dẫn")
InfoTab:CreateParagraph({Title = "Cách dùng", Content = "1. Nhập key: DELTA2026\n2. Lên xe cần tune/rã/chỉnh phuộc\n3. Dùng các tab tương ứng trên menu."})

local function applyTuneToCurrentVehicle()
   if not isTuned then return end

   local char = LocalPlayer.Character
   if not char then return end
   local hum = char:FindFirstChildOfClass("Humanoid")
   if not hum or not hum.SeatPart then return end

   local carModel = hum.SeatPart:FindFirstAncestorOfClass("Model")
   if not carModel then return end

   for _, obj in ipairs(carModel:GetDescendants()) do
      if obj:IsA("ModuleScript") then
         local nameLower = obj.Name:lower()
         if nameLower:find("tune") or nameLower:find("tuner") or nameLower:find("config") then
            local success, tuneTable = pcall(function() return require(obj) end)
            if success and type(tuneTable) == "table" then
               if not tuneTable._OriginalHP then tuneTable._OriginalHP = tuneTable.Horsepower or 200 end
               if not tuneTable._OriginalRPM then tuneTable._OriginalRPM = tuneTable.PeakRPM or 8000 end

               tuneTable.Horsepower = tuneTable._OriginalHP + addHPVal
               tuneTable.PeakRPM = tuneTable._OriginalRPM + addRPMVal
               tuneTable.Torque = tuneTable.Horsepower * 2.5
               tuneTable.PeakTorque = tuneTable.Horsepower * 2.5
               if tuneTable.Redline then tuneTable.Redline = tuneTable.PeakRPM + 3000 end

               if tuneTable.Ratios then
                  if not tuneTable._OriginalRatios then
                     tuneTable._OriginalRatios = {}
                     for k, v in pairs(tuneTable.Ratios) do
                        tuneTable._OriginalRatios[k] = v
                     end
                  end

                  for idx, origRatio in pairs(tuneTable._OriginalRatios) do
                     if type(idx) == "number" or tonumber(idx) then
                        local numIdx = tonumber(idx)
                        if numIdx == 1 then
                           tuneTable.Ratios[idx] = origRatio * gear1Mult
                        elseif numIdx > 1 then
                           tuneTable.Ratios[idx] = origRatio * gearOthersMult
                        end
                     end
                  end
               end
            end
         end
      end
   end
end

RunService.RenderStepped:Connect(function()
   applyTuneToCurrentVehicle()
end)
