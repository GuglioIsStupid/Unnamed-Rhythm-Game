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
local json = require("json")
local os = require("os")

print("Checking for updates...")

local gitApiURL = "https://api.github.com/"
local repo = "AGORI-Studios/Rit"

-- get latest release (PRE-RELEASES INCLUDED)
local releaseURL = gitApiURL .. "repos/" .. repo .. "/releases"
print("Requesting latest release from GitHub", releaseURL)
local _, data = https.request(releaseURL, {
    headers = {
        ["User-Agent"] = "git-launcher-rit"
    }
})

-- go through it until "Nightly" is in the name
local latestRelease = nil
for _, release in ipairs(json.decode(data)) do
    if string.find(release.name, "Nightly") then
        latestRelease = release
        break
    end
end

if not latestRelease then
    print("No latest release found!")
    return
end

print("Latest release found:", latestRelease.tag_name, latestRelease.name)

-- usually the name is :  Rit Nightly Release 20241105 (commit: fb430cbe8ca74aeea570237612ae973f23613511)
local commit = string.match(latestRelease.name, "commit: ([%w]+)")
print("Latest Commit:", commit)

local currentCommit = love.filesystem.getInfo("commit.txt") and love.filesystem.read("commit.txt") or "0"
print("Current Commit:", currentCommit)

if commit == currentCommit then
    print("Already up to date!")
    -- Launch game
    os.execute(love.filesystem.getSaveDirectory() .. "/game_install/Rit.exe")

    return love.event.quit()
end

print("Downloading latest release...")

local filename = "Rit-win64.zip"
local url = ""
for _, asset in ipairs(latestRelease.assets) do
    if asset.name == filename then
        url = asset.browser_download_url
        break
    end
end

if url == "" then
    print("No download found!")
    return love.event.quit()
end

print("Downloading from", url)

local _, data = https.request(url)
love.filesystem.write(filename, data)

print("Extracting...")

love.filesystem.createDirectory("game_install")
love.filesystem.mount(filename, "temp")
local files = love.filesystem.getDirectoryItems("temp")

local function copyFolder(from, to)
    love.filesystem.createDirectory(to)
    local files = love.filesystem.getDirectoryItems(from)
    for _, file in ipairs(files) do
        if love.filesystem.getInfo(from .. "/" .. file).type == "file" then
            love.filesystem.write(to .. "/" .. file, love.filesystem.read(from .. "/" .. file))
        else
            copyFolder(from .. "/" .. file, to .. "/" .. file)
        end
    end
end

for _, file in ipairs(files) do
    if love.filesystem.getInfo("temp/" .. file).type == "file" then
        love.filesystem.write("game_install/" .. file, love.filesystem.read("temp/" .. file))
    else
        copyFolder("temp/" .. file, "game_install/" .. file)
    end
end

love.filesystem.unmount("temp")

print("Cleaning up...")

print("Saving commit...")
love.filesystem.write("commit.txt", commit)

print("Launching game...")
os.execute(love.filesystem.getSaveDirectory() .. "/game_install/Rit.exe")

return love.event.quit()