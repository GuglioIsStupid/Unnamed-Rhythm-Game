local path = ... .. "."
-- replace all . with / 
path = string.gsub(path, "%.", "/")
local os = love.system.getOS()
local arch = jit.arch

if not love.filesystem.getInfo("DLL") then
    love.filesystem.createDirectory("DLL")
end

if os == "Windows" then
    if arch == "x64" then
        -- copy all files in ./Win64 to DLL/
        local files = love.filesystem.getDirectoryItems(path .. "Win64")
        for _, file in ipairs(files) do
            if not love.filesystem.getInfo(file) then
                love.filesystem.write(file, love.filesystem.read(path .. "Win64/" .. file))
            end
        end
    else
        debug.warn("UNSUPPORTED ARCHITECTURE! " .. arch)
    end
elseif os == "OS X" then
    if arch == "x64" then
        -- copy all files in ./Mac64 to DLL/
        local files = love.filesystem.getDirectoryItems(path .. "Mac64")
        for _, file in ipairs(files) do
            if not love.filesystem.getInfo(file) then
                love.filesystem.write(file, love.filesystem.read(path .. "Mac64/" .. file))
            end
        end
    else
        debug.warn("UNSUPPORTED ARCHITECTURE! " .. arch)
    end
elseif os == "Linux" then
    if arch == "x64" then
        -- copy all files in ./Linux64 to DLL/
        local files = love.filesystem.getDirectoryItems(path .. "Linux64")
        for _, file in ipairs(files) do
            if not love.filesystem.getInfo(file) then
                love.filesystem.write(file, love.filesystem.read(path .. "Linux64/" .. file))
            end
        end
    else
        debug.warn("UNSUPPORTED ARCHITECTURE! " .. arch)
    end
else
    debug.warn("UNSUPPORTED OS! " .. os)
end

tryExcept(function()
    DLL_Video = require("video")
end)

tryExcept(function()
    if os ~= "Windows" then
        return
    end
    DLL_Https = require("https")
end)
