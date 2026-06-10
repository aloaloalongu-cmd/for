local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local BLOCK_KEY = Enum.KeyCode.Q -- Đã chuyển đổi hoàn toàn sang phím Q
local ACTIVATION_DISTANCE = 15 -- Khoảng cách quét tính bằng Studs (Có thể chỉnh lên 16-18 nếu mạng ping cao)

-- Thông báo hiển thị trong bảng điều khiển F9 để kiểm tra
print("--- [Forsaken PC Q-Block] Đã kích hoạt thành công! ---")

-- Hàm giả lập nhấn phím Q trên bàn phím PC
local function PerformQBlock()
    VirtualInputManager:SendKeyEvent(true, BLOCK_KEY, false, game) -- Nhấn giữ phím Q
    task.wait(0.05) -- Giữ phím trong 0.05 giây (Frame-perfect cho parry)
    VirtualInputManager:SendKeyEvent(false, BLOCK_KEY, false, game) -- Thả phím Q
end

-- Vòng lặp quét liên tục mỗi khung hình để không bỏ sót đòn đánh nào
RunService.RenderStepped:Connect(function()
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    local myHRP = myChar.HumanoidRootPart

    -- Quét danh sách người chơi để tìm Killer
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local killerChar = player.Character
            local killerHRP = killerChar.HumanoidRootPart
            local killerHumanoid = killerChar:FindFirstChildOfClass("Humanoid")
            
            -- Tính khoảng cách giữa bạn và Killer
            local distance = (myHRP.Position - killerHRP.Position).Magnitude
            
            if distance <= ACTIVATION_DISTANCE then
                local shouldBlock = false
                
                -- Điều kiện 1: Quét trạng thái Attributes ẩn của game Forsaken
                if killerChar:GetAttribute("Attacking") == true or 
                   killerChar:GetAttribute("IsAttacking") == true or 
                   killerChar:GetAttribute("Swinging") == true then
                    shouldBlock = true
                end
                
                -- Điều kiện 2: Dự phòng quét hoạt ảnh (Animation) vung vũ khí của Killer
                if not shouldBlock and killerHumanoid then
                    local playingAnims = killerHumanoid:GetPlayingAnimationTracks()
                    for _, anim in ipairs(playingAnims) do
                        local animName = anim.Name:lower()
                        if animName:find("attack") or animName:find("slash") or animName:find("swing") or animName:find("hit") then
                            shouldBlock = true
                            break
                        end
                    end
                end
                
                -- Thực hiện đỡ đòn nếu thỏa mãn điều kiện
                if shouldBlock then
                    PerformQBlock()
                    task.wait(0.5) -- Thời gian chờ hồi chiêu chống spam lỗi đơ nút
                    break
                end
            end
        end
    end
end)
