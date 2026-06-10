local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager") -- Dùng để giả lập nhấn phím

local LocalPlayer = Players.LocalPlayer
local BLOCK_KEY = Enum.KeyCode.Q -- Thay đổi phím F nếu game dùng phím khác để đỡ
local MAX_DISTANCE = 15 -- Khoảng cách an toàn để kích hoạt block (tính bằng Studs)

-- Hàm giả lập nhấn phím đỡ đòn
local function TriggerBlock()
    VirtualInputManager:SendKeyEvent(true, BLOCK_KEY, false, game) -- Nhấn xuống
    task.wait(0.1) -- Giữ phím một chút
    VirtualInputManager:SendKeyEvent(false, BLOCK_KEY, false, game) -- Thả ra
end

-- Hàm tìm Killer trong trận đấu
local function GetKiller()
    -- Trong game Forsaken, bạn cần tìm người chơi đang đóng vai Killer.
    -- Đoạn này kiểm tra dựa trên khoảng cách, bạn có thể tối ưu thêm nếu biết thuộc tính phân biệt Killer của game.
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            -- Mẹo: Thường Killer sẽ có một công cụ (Tool) vũ khí hoặc một trạng thái đặc biệt
            local character = player.Character
            local hasWeapon = character:FindFirstChildOfClass("Tool") or character:FindFirstChild("Weapon")
            
            if hasWeapon then
                return player
            end
        end
    end
    return nil
end

-- Vòng lặp quét liên tục theo thời gian thực
RunService.Heartbeat:Connect(function()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local myHRP = character.HumanoidRootPart
    local killer = GetKiller()
    
    if killer and killer.Character and killer.Character:FindFirstChild("HumanoidRootPart") then
        local killerHRP = killer.Character.HumanoidRootPart
        local killerHumanoid = killer.Character:FindFirstChildOfClass("Humanoid")
        
        -- Tính khoảng cách giữa bạn và Killer
        local distance = (myHRP.Position - killerHRP.Position).Magnitude
        
        if distance <= MAX_DISTANCE then
            -- Kiểm tra xem Killer có đang tung đòn đánh (chạy Animation tấn công) hay không
            if killerHumanoid then
                local playingAnims = killerHumanoid:GetPlayingAnimationTracks()
                for _, anim in ipairs(playingAnims) do
                    -- Kiểm tra tên Animation có chứa các từ khóa tấn công hay không
                    local animName = anim.Name:lower()
                    if animName:find("attack") or animName:find("slash") or animName:find("swing") or animName:find("hit") then
                        -- Nếu Killer đang chém và ở trong tầm, tự động đỡ đòn!
                        TriggerBlock()
                        task.wait(0.5) -- Tránh spam phím quá nhanh gây lỗi
                        break
                    end
                end
            end
        end
    end
end)
