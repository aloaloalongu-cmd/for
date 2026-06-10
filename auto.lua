local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local ACTIVATION_DISTANCE = 15

-- Các biến lưu trữ dữ liệu bảo mật đã "học" được từ bạn
local SavedRemote = nil
local SavedArgs = nil
local HasLearned = false

print("--- [Hệ thống Auto-Learn Forsaken đã bật] ---")
print("BẮT BUỘC: Hãy nhấn phím Q thủ công 1 lần trong trận để script học mã khóa!")

-- 1. Bộ lọc lắng nghe để tự động học mã khóa khi bạn nhấn Q
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    -- Nếu bạn bấm nút và game gửi tín hiệu Đỡ/Kỹ năng lên server
    if method == "FireServer" and self:IsA("RemoteEvent") and not HasLearned then
        local name = self.Name:lower()
        if name:find("block") or name:find("parry") or name:find("dash") or name:find("ability") or name:find("combat") then
            SavedRemote = self
            SavedArgs = args
            HasLearned = true
            warn("🎉 Đã học được mã khóa bảo mật thành công! Hệ thống Auto Block sẵn sàng.")
        end
    end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

-- 2. Vòng lặp tự động đỡ đòn sử dụng mã khóa đã học
RunService.RenderStepped:Connect(function()
    if not HasLearned or not SavedRemote then return end
    
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    local myHRP = myChar.HumanoidRootPart

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local killerChar = player.Character
            local killerHRP = killerChar.HumanoidRootPart
            
            local distance = (myHRP.Position - killerHRP.Position).Magnitude
            
            if distance <= ACTIVATION_DISTANCE then
                -- Kiểm tra trạng thái tấn công của Killer
                if killerChar:GetAttribute("Attacking") == true or killerChar:GetAttribute("Swinging") == true then
                    
                    -- "Nhái" lại chính xác cuộc gọi kèm theo string và table đã lưu
                    SavedRemote:FireServer(unpack(SavedArgs))
                    
                    task.wait(0.6) -- Cooldown
                    break
                end
            end
        end
    end
end)
