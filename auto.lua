local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local ACTIVATION_DISTANCE = 15 -- Khoảng cách tự động đỡ (Studs)

-- Thông báo lên màn hình điện thoại để bạn biết script ĐÃ CHẠY
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Forsaken Mobile",
    Text = "Auto Block đã kích hoạt thành công!",
    Duration = 5
})

-- Hàm tìm các nút bấm hoặc sự kiện Block trong game
local function TriggerMobileBlock()
    local character = LocalPlayer.Character
    if not character then return end

    -- Cách 1: Kích hoạt thông qua RemoteEvent của game (Nếu game dùng Remote để xử lý đỡ đòn)
    -- Script sẽ tìm các tín hiệu gửi về server có tên liên quan đến Block/Parry
    local replicatedStorage = game:GetService("ReplicatedStorage")
    if replicatedStorage:FindFirstChild("Events") or replicatedStorage:FindFirstChild("Remotes") then
        for _, v in ipairs(replicatedStorage:GetDescendants()) do
            if v:IsA("RemoteEvent") and (v.Name:lower():find("block") or v.Name:lower():find("parry") or v.Name:lower():find("defend")) then
                v:FireServer(true) -- Gửi tín hiệu đỡ đòn lên server
                task.wait(0.2)
                v:FireServer(false) -- Thả đỡ đòn
                return
            end
        end
    end

    -- Cách 2: Giả lập chạm trực tiếp vào nút Đỡ đòn trên giao diện Mobile của bạn
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if playerGui then
        for _, gui in ipairs(playerGui:GetDescendants()) do
            -- Tìm nút bấm trên màn hình điện thoại có chữ "Block", "Parry", "F" hoặc hình cái khiên
            if gui:IsA("TextButton") or gui:IsA("ImageButton") then
                local btnName = gui.Name:lower()
                local btnText = (gui:IsA("TextButton") and gui.Text:lower()) or ""
                
                if btnName:find("block") or btnName:find("parry") or btnText:find("block") or btnText:find("f") then
                    -- Giả lập hành động ngón tay chạm vào nút trên màn hình
                    local guiService = game:GetService("GuiService")
                    gui:Activate() 
                    return
                end
            end
        end
    end
end

-- Vòng lặp quét Killer xung quanh
RunService.Heartbeat:Connect(function()
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    local myHRP = myChar.HumanoidRootPart

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local killerChar = player.Character
            local killerHRP = killerChar.HumanoidRootPart
            
            local distance = (myHRP.Position - killerHRP.Position).Magnitude
            
            if distance <= ACTIVATION_DISTANCE then
                -- Kiểm tra nếu Killer đang vung đòn (Attributes)
                if killerChar:GetAttribute("Attacking") == true or killerChar:GetAttribute("IsAttacking") == true or killerChar:GetAttribute("Swinging") == true then
                    TriggerMobileBlock()
                    task.wait(0.5) -- Cooldown để không bị lỗi spam
                    break
                end
            end
        end
    end
end)
