local path = ... .. "."

zfft = require(path .. "zorgfft.zfft")
love.audio.newAdvancedSource = require(path .. "asl.asl")
tryExcept(function()
    Steam = require(path .. "sworks.main")
end)

if Steam then
    if not Steam.init() or not Steam.isRunning() then
        Steam = nil
        print("Steam failed to initialize!")
    else
        Steam.USER = Steam.getUser()
        Steam.USER_ID = Steam.getUserId()
        Steam.USERNAME = Steam.USER:getName()
    end
end

MD5 = require(path .. "md5")

ImGUI = require(path .. "cimgui")