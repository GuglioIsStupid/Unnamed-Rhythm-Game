local https = require("https")

-- replace all . with / 
local os = love.system.getOS()
local arch = jit.arch

print("OS: " .. os .. arch)

love.filesystem.createDirectory("DLL")

if os == "Windows" then
    if arch == "x64" then
        -- copy all files in ./Win64 to DLL/
        local files = love.filesystem.getDirectoryItems("DLL/Win64")
        for _, file in ipairs(files) do
            if not love.filesystem.getInfo("DLL/" .. file) then
                love.filesystem.write("DLL/" .. file, love.filesystem.read("DLL/Win64/" .. file))
            end
        end
    else
        print("UNSUPPORTED ARCHITECTURE! " .. arch)
    end
elseif os == "OS X" then
    print("MAC OS X NOT CURRENTLY SUPPORTED FOR UPDATES!")
elseif os == "Linux" then
    print("LINUX NOT CURRENTLY SUPPORTED FOR UPDATES!")
else
    print("UNSUPPORTED OS FOR UPDATES! " .. os)
end

local savepath = love.filesystem.getSaveDirectory()
package.cpath = package.cpath .. ";" .. savepath .. "/DLL/?.dll"

local https = require("https")

print("Checking for updates...")

local gitApiURL = "https://api.github.com/"
local repo = "AGORI-Studios/Rit"