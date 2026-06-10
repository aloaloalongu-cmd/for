local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local BLOCK_KEY = Enum.KeyCode.Q -- Nút đỡ đòn trong Forsaken
local ACTIVATION_DISTANCE = 15   -- Khoảng cách an toàn để kích hoạt

print("--- [Forsaken PC] Auto Block phím Q an toàn đã bật! ---")

-- Hàm giả lập nhấn phím Q một cách tự nhiên giống người thật bấm
local function SafeQBlock()
    VirtualInputManager:SendKeyEvent(true, BLOCK_KEY, false, game) -- Bấm giữ Q
    task.wait(math.random(5, 8) / 100) -- Giữ nút ngẫu nhiên từ 0.05 đến 0.08 giây để qua mặt anti-cheat
    VirtualInputManager:SendKeyEvent(false, BLOCK_KEY, false, game) -- Thả Q
end

-- Vòng lặp quét an toàn, không can thiệp vào đường truyền kỹ năng của bạn
RunService.Heartbeat:Connect(function()
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    local myHRP = myChar.HumanoidRootPart

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local killerChar = player.Character
            local killerHRP = killerChar.HumanoidRootPart
            local killerHumanoid = killerChar:FindFirstChildOfClass("Humanoid")
            
            local distance = (myHRP.Position - killerHRP.Position).Magnitude
            
            -- Kiểm tra khoảng cách nguy hiểm
            if distance <= ACTIVATION_DISTANCE then
                local isAttacking = false
                
                -- Check Attributes của Killer
                if killerChar:GetAttribute("Attacking") == true or 
                   killerChar:GetAttribute("IsAttacking") == true or 
                   killerChar:GetAttribute("Swinging") == true then
                    isAttacking = true
                end
                
                -- Dự phòng: Check hoạt ảnh vung tay của Killer
                if not isAttacking and killerHumanoid then
                    local playingAnims = killerHumanoid:GetPlayingAnimationTracks()
                    for _, anim in ipairs(playingAnims) do
                        local animName = anim.Name:lower()
                        if animName:find("attack") or animName:find("slash") or animName:find("swing") then
                            isAttacking = true
                            break
                        end
                    end
                end
                
                -- Kích hoạt đỡ đòn
                if isAttacking then
                    SafeQBlock()
                    task.wait(0.6) -- Thời gian nghỉ giữa các lần đỡ để bạn tự bấm nút thoải mái
                    break
                end
            end
        end
    end
end)
