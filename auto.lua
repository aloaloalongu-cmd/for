local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local ACTIVATION_DISTANCE = 16 -- Khoảng cách tự động kích hoạt

print("--- [Forsaken Ultimate Bypass] Khởi chạy bộ quét Remote ---")

-- Hàm tìm kiếm và kích hoạt hành động đỡ đòn qua hệ thống mạng của game
local function ForceParry()
    -- Cách 1: Quét và kích hoạt trực tiếp các Sự kiện (RemoteEvents) trong ReplicatedStorage
    -- Game Forsaken bắt buộc phải gửi tín hiệu lên Server khi bạn bấm Q để người khác thấy bạn đang đỡ/lướt
    for _, child in ipairs(ReplicatedStorage:GetDescendants()) do
        if child:IsA("RemoteEvent") then
            local name = child.Name:lower()
            -- Quét các từ khóa liên quan đến cơ chế phòng thủ/kỹ năng trong game
            if name:find("block") or name:find("parry") or name:find("dash") or name:find("ability") or name:find("skill") then
                child:FireServer(true)
                task.wait(0.1)
                child:FireServer(false)
                return
            end
        end
    end

    -- Cách 2: Nếu game giấu Remote trong nhân vật, quét trực tiếp trong Tool/Character của bạn
    local myChar = LocalPlayer.Character
    if myChar then
        for _, child in ipairs(myChar:GetDescendants()) do
            if child:IsA("RemoteEvent") then
                child:FireServer()
            end
        end
    end
end

-- Vòng lặp quét dựa trên vị trí tuyệt đối (Bỏ qua việc check Attributes của Killer phòng trường hợp game giấu thuộc tính)
RunService.RenderStepped:Connect(function()
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    local myHRP = myChar.HumanoidRootPart

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local killerChar = player.Character
            local killerHRP = killerChar.HumanoidRootPart
            local killerHumanoid = killerChar:FindFirstChildOfClass("Humanoid")
            
            local distance = (myHRP.Position - killerHRP.Position).Magnitude
            
            -- Vì không thể dò chính xác tên thuộc tính "Attacking" bị nhà phát triển ẩn đi,
            -- script này sẽ tự động kích hoạt Đỡ đòn ngay khi Killer bước vào phạm vi nguy hiểm và đang di chuyển lao vào bạn.
            if distance <= ACTIVATION_DISTANCE then
                if killerHumanoid and killerHumanoid.MoveDirection.Magnitude > 0 then
                    ForceParry()
                    task.wait(0.4) -- Khóa thời gian chờ tránh spam gây lỗi game
                    break
                end
            end
        end
    end
end)
