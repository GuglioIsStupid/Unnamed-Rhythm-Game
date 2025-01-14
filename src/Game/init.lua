local path = ... .. "."

require(path .. "External")
require(path .. "States")
require(path .. "Substates")
require(path .. "Managers")
Database = require(path .. "Database")
Database:getDBs()
require(path .. "Objects")
require(path .. "Cache")
require(path .. "Threads")
Parsers = require(path .. "Parsing")

require(path .. "Difficulty")

local function setupFolders()
    love.filesystem.createDirectory("CacheData")
    --[[ love.filesystem.createDirectory("CacheData/Beatmaps") ]]
    -- create a .db file for Beatmaps
    
    love.filesystem.createDirectory("Data")
    love.filesystem.createDirectory("Beatmaps")
    love.filesystem.createDirectory("FTPacks")

    love.filesystem.write("readme.txt", [[
Folder structure:
- CacheData: Contains cached data for the game. Deleting this folder will cause the game to regenerate the cache, causing longer load times.
- Data: Contains data for the game. This folder is used for storing settings and other data.
- Beatmaps: Contains parsed beatmaps for the game. This folder for storing your beatmaps.
]])

    love.filesystem.write("FTPacks/readme.txt", [[
Folder structure:
- SongPack
    - mod_pv_db.txt
    - sound/
        - song/
            - pv_id{_ext}.ogg
    - script/
        - song/
            - pv_id.dsc

This layout is strict.
]])

    FTCache:parseFTPacks("FTPacks")
    SongCache:loadSongsPath("Assets/IncludedSongs")
    SongCache:loadSongsPath("Beatmaps")
end

Game.fonts = {}

function Game:initialize()
    setupFolders()

    --[[ Skin = love.filesystem.load("Assets/IncludedSkins/Circle Default/Skin.lua")() ]]
    Skin:loadSkin("Assets/IncludedSkins/Circle Default/Skin.lua")

    -- wooo fonts
    local fonts = love.filesystem.load("Assets/Data/Fonts.lua")()
    for _, font in ipairs(fonts) do
    --[[ FontCache:get("Assets/Fonts/" .. font.path, font.size, false, font.name )]]
        Game.fonts[font.name] = love.graphics.newFont("Assets/Fonts/" .. font.path, font.size)
    end
end

function Game:toggleFullscreen()
    local fullscreen = not love.window.getFullscreen()
    love.window.setFullscreen(fullscreen)
    return fullscreen
end

function Game:kill()
    Game.super.kill(self)

    love.thread.getChannel("thread.font"):push({path = "exit"})
    love.thread.getChannel("thread.image"):push("exit")
    love.thread.getChannel("thread.audio"):push("exit")

    love.thread.getChannel("thread.font.out"):clear()
    love.thread.getChannel("thread.image.out"):clear()
    love.thread.getChannel("thread.audio.out"):clear()

    if DiscordRPC then
        DiscordRPC.shutdown()
    end
end

Game:initialize()

SongManager:loadSongList()

Game:SwitchState(Skin:getSkinnedState("TitleMenu"))
--Game:SwitchState(States.Screens.Editor.MapEditor)