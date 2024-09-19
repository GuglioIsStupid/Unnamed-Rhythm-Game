local path = ... .. "."

require(path .. "External")
require(path .. "States")
require(path .. "Managers")
require(path .. "Objects")
require(path .. "Cache")
require(path .. "Threads")
Parsers = require(path .. "Parsing")

local function setupFolders()
    love.filesystem.createDirectory("CacheData")
    love.filesystem.createDirectory("CacheData/Beatmaps")
    love.filesystem.createDirectory("Data")
    love.filesystem.createDirectory("Beatmaps")

        love.filesystem.write("readme.txt", [[
Folder structure:
- CacheData: Contains cached data for the game. Deleting this folder will cause the game to regenerate the cache, causing longer load times.
- Data: Contains data for the game. This folder is used for storing settings and other data.
- Beatmaps: Contains parsed beatmaps for the game. This folder for storing your beatmaps.
]])

    SongCache:loadSongsPath("Assets/IncludedSongs")
    SongCache:loadSongsPath("Beatmaps")
end

function Game:initialize()
    setupFolders()

    --[[ Skin = love.filesystem.load("Assets/IncludedSkins/Circle Default/Skin.lua")() ]]
    Skin:loadSkin("Assets/IncludedSkins/Circle Default/Skin.lua")
end

function Game:kill()
    Game.super.kill(self)

    love.thread.getChannel("thread.font"):push({path = "exit"})
    love.thread.getChannel("thread.image"):push("exit")
    love.thread.getChannel("thread.audio"):push("exit")

    love.thread.getChannel("thread.font.out"):clear()
    love.thread.getChannel("thread.image.out"):clear()
    love.thread.getChannel("thread.audio.out"):clear()
end

Game:initialize()

SongManager:loadSongList()

Game:SwitchState(Skin:getSkinnedState("TitleMenu"))