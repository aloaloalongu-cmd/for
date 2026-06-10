local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local BLOCK_KEY = Enum.KeyCode.F -- Phím đỡ đòn mặc định
local ACTIVATION_DISTANCE = 14 -- Khoảng cách an toàn để kích hoạt block (đơn vị Studs)

-- In thông báo để bạn biết script đã chạy thành công
print("--- [Forsaken Auto Block] Đã kích hoạt thành công! ---")

-- Hàm giả lập nhấn phím F cực nhanh (Frame-perfect)
local function PerformBlock()
    VirtualInputManager:SendKeyEvent(true, BLOCK_KEY, false, game)
    task.wait(0.05) -- Thời gian giữ phím siêu ngắn để tối ưu parry
    VirtualInputManager:SendKeyEvent(false, BLOCK_KEY, false, game)
end

-- Vòng lặp quét liên tục mỗi khung hình (RenderStepped) để đảm bảo không bỏ sót đòn chém nào
RunService.RenderStepped:Connect(function()
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    local myHRP = myChar.HumanoidRootPart

    -- Cách 1: Quét nhanh các Part (Hitbox) xuất hiện đột ngột xung quanh nhân vật
    -- Các game đối kháng thường tạo ra một khối vùng đánh (Hitbox Region) khi chém
    local partsAround = workspace:GetPartBoundsInBox(myHRP.CFrame, Vector3.new(15, 15, 15))
    for _, part in ipairs(partsAround) do
        -- Kiểm tra xem xung quanh bạn có Part nào tên là "Hitbox", "Damage", "Swing", hoặc "Slash" của Killer không
        local nameLower = part.Name:lower()
        if nameLower:find("hitbox") or nameLower:find("attack") or nameLower:find("damage") then
            PerformBlock()
            task.wait(0.4) -- Thời gian chờ hồi chiêu (cooldown) tránh spam lỗi
            return
        end
    end

    -- Cách 2: Quét khoảng cách trực tiếp với Killer (Dự phòng nếu game giấu kín Hitbox)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local killerChar = player.Character
            local killerHRP = killerChar.HumanoidRootPart
            
            -- Tính khoảng cách
            local distance = (myHRP.Position - killerHRP.Position).Magnitude
            
            if distance <= ACTIVATION_DISTANCE then
                -- Kiểm tra xem Killer có đổi trạng thái (Attributes) sang tấn công không
                -- Forsaken thường dùng Attributes để quản lý như: "Attacking" = true hoặc "IsSwinging" = true
                if killerChar:GetAttribute("Attacking") == true or killerChar:GetAttribute("IsAttacking") == true or killerChar:GetAttribute("Swinging") == true then
                    PerformBlock()
                    task.wait(0.4)
                    break
                end
            end
        end
    end
end)
