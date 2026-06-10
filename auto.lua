local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local BLOCK_KEY = Enum.KeyCode.Q
local ACTIVATION_DISTANCE = 16 

print("--- [Forsaken PC] Auto Block V3 (Modern Scan) đã bật! ---")

local function SafeQBlock()
    print("⚠️ ĐÃ PHÁT HIỆN ĐÒN CHÉM! Đang tự động bấm Q...")
    VirtualInputManager:SendKeyEvent(true, BLOCK_KEY, false, game)
    task.wait(0.05) 
    VirtualInputManager:SendKeyEvent(false, BLOCK_KEY, false, game)
end

RunService.RenderStepped:Connect(function()
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    local myHRP = myChar.HumanoidRootPart

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local killerChar = player.Character
            local killerHRP = killerChar.HumanoidRootPart
            local humanoid = killerChar:FindFirstChildOfClass("Humanoid")
            
            local distance = (myHRP.Position - killerHRP.Position).Magnitude
            
            if distance <= ACTIVATION_DISTANCE then
                local isAttacking = false
                
                -- 1. Quét theo chuẩn Roblox mới (Animator)
                if humanoid then
                    local animator = humanoid:FindFirstChildOfClass("Animator")
                    if animator then
                        for _, anim in ipairs(animator:GetPlayingAnimationTracks()) do
                            local animName = anim.Name:lower()
                            -- Quét rộng hơn các từ khóa liên quan đến kỹ năng
                            if animName:find("attack") or animName:find("slash") or animName:find("swing") or animName:find("hit") or animName:find("m1") or animName:find("combat") then
                                isAttacking = true
                                break
                            end
                        end
                    end
                end
                
                -- 2. Quét công cụ (Tool) trên tay Killer xem có đang được kích hoạt không
                local tool = killerChar:FindFirstChildOfClass("Tool")
                if tool and tool:GetAttribute("Attacking") then
                    isAttacking = true
                end

                -- 3. Quét trạng thái Attributes (Dự phòng)
                if killerChar:GetAttribute("Attacking") or killerChar:GetAttribute("IsSwinging") then
                    isAttacking = true
                end
                
                if isAttacking then
                    SafeQBlock()
                    task.wait(0.6) -- Cooldown
                    break
                end
            end
        end
    end
end)
