<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bộ Chuyển Đổi Loadstring</title>
    <style>
        body { font-family: Arial, sans-serif; padding: 20px; background-color: #121212; color: #fff; }
        textarea { width: 100%; height: 200px; background: #222; color: #fff; border: 1px solid #444; border-radius: 5px; padding: 10px; box-sizing: border-box; }
        button { width: 100%; padding: 12px; background: #27ae60; border: none; color: white; font-weight: bold; margin-top: 10px; border-radius: 5px; cursor: pointer; }
        input { width: 100%; padding: 10px; background: #333; color: #00ff00; border: 1px solid #555; border-radius: 5px; margin-top: 10px; box-sizing: border-box; }
        label { font-weight: bold; display: block; margin-top: 15px; }
    </style>
</head>
<body>
    <h2>🤖 Tạo Link Loadstring Siêu Ngắn</h2>
    
    <label>1. Dán đoạn Code ROBLOX dài vào đây:</label>
    <textarea id="sourceCode" placeholder="Dán code lua của bạn vào đây..."></textarea>
    
    <button onclick="generateLoadstring()">BẮT ĐẦU GÁN LINK</button>
    
    <label>2. Kết quả nhận được (Copy gửi Zalo):</label>
    <input type="text" id="resultLink" readonly placeholder="Link loadstring sẽ xuất hiện tại đây..." onclick="this.select()">

    <script>
        async function generateLoadstring() {
            const code = document.getElementById("sourceCode").value;
            const resultInput = document.getElementById("resultLink");
            
            if(!code.trim()) {
                alert("Vui lòng dán code trước đã bạn ơi!");
                return;
            }
            
            resultInput.value = "Đang xử lý, vui lòng đợi...";

            try {
                // Sử dụng API trung gian miễn phí để đẩy code lên Pastebin bảo mật
                const response = await fetch("https://api.allorigins.win/get?url=" + encodeURIComponent("https://pastebin.com/api/api_post.php"), {
                    method: "POST",
                    headers: { "Content-Type": "application/x-www-form-urlencoded" },
                    body: new URLSearchParams({
                        api_dev_key: "0fed619b05c5da07da4cf4142f1fe5e3", // API Key công cộng dùng chung
                        api_option: "paste",
                        api_paste_code: code,
                        api_paste_private: "1", // Chế độ Unlisted để không bị xóa bậy
                        api_paste_name: "AutoBlock_Guest1337"
                    })
                });

                const data = await response.json();
                if(data.contents && data.contents.includes("pastebin.com")) {
                    // Chuyển đổi link thường thành link RAW
                    const rawLink = data.contents.replace("pastebin.com/", "pastebin.com/raw/");
                    resultInput.value = `loadstring(game:HttpGet("${rawLink.trim()}"))()`;
                } else {
                    // Dự phòng nếu Pastebin quá tải, chuyển sang hệ thống txt.is
                    const backupResponse = await fetch("https://txt.is/api/v1/paste", {
                        method: "POST",
                        headers: { "Content-Type": "application/json" },
                        body: JSON.stringify({ content: code })
                    });
                    const backupData = await backupResponse.json();
                    resultInput.value = `loadstring(game:HttpGet("${backupData.raw_url}"))()`;
                }
            } catch (err) {
                resultInput.value = "Lỗi kết nối! Thử lại sau ít phút.";
            }
        }
    </script>
</body>
</html>
