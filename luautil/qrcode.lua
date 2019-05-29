local qrcode = {}

-- logo的地址
local defaultURL = "http://home.cn-jfqp.nbigame.com/download/file/ICON-76.png"

-- 将 URL 转为二维码
function qrcode:convertURL2QRCode(url, okCallback,fileName)
    if url == "" or url == nil then
        return false
    end
    local obj = {}
    local areaId = game.service.LocalPlayerService.getInstance():getArea()
    obj.url = url
    obj.width = 250
    obj.format = "PNG"
    obj.logo = MultiArea:getChanelInfo().logoUrl or defaultURL
    obj.areaId = areaId
    obj.stime = math.floor(kod.util.Time.now() * 1000)
    --FYD
    obj.sign = loho.md5(loho.md5(obj.areaId .. obj.format .. obj.logo .. obj.url .. obj.width) .. obj.stime)

    --测试url
    -- local url = "http://test.outside.qrcodeserver.majiang01.com/barcode/v1/add"
    -- local url = "http://172.16.2.125:9955/barcode/v1/add"
    --正式url
    local url = "http://outside.qrcodeserver.majiang01.com/barcode/v1/add"
    local xhr = cc.XMLHttpRequest:new()

    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xhr.timeout = 0
    xhr:open("POST", url)
    xhr:setRequestHeader("Content-Type", "application/json");
    local formData = json.encode(obj)
    xhr:registerScriptHandler(function()
        self:writeQRCode(xhr,okCallback,fileName,obj.url)
    end)
    Logger.debug(formData)
    xhr:send(formData)
end

local QRCodeFileName = "dimpump.png"

-- 把二维码写入到本地
function qrcode:writeQRCode(xhr, okCallback,fileName,url)
    local response = xhr.response
    local readyState = xhr.readyState
    local status = xhr.status
    if readyState == 4 and (status >= 200 and status < 207) and string.len(response) > 1000 then
        local filename = fileName or QRCodeFileName
        local imgPath = cc.FileUtils:getInstance():getAppDataPath() .. filename
        local file = io.open(imgPath, "wb")
        file:write(response)
        file:close()
        if okCallback then
            okCallback(imgPath)
        end
        return true
    else
        local qrencode = require("app.kod.util.qrencode")
        qrencode.generalQrcode(url,function(path) 
            local file = io.open(path,"rb")
            local content = file:read("*a")
            file:close()
            local filename = fileName or QRCodeFileName
            local imgPath = cc.FileUtils:getInstance():getAppDataPath() .. filename
            local file = io.open(imgPath, "wb")
            file:write(content)
            file:close()
            if okCallback then
                okCallback(imgPath)
            end
            return true
        end)
    end
end
 

return qrcode