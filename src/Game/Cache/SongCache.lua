local SongCacheFormat = {
    title = "",
    artist = "",
    source = "",
    tags = "",
    creator = "",
    diff_name = "",
    description = "",
    path = "",
    audio_path = "",
    bg_path = "",
    preview_time = 0,
    mapset_id = 0,
    map_id = 0,
    mode = 4,
    game_mode = "Mania",
    map_type = "Quaver",
    hitobj_count = 0,
    ln_count = 0,
    length = 0,
    metaType = 4,
    difficulty = 0,
    nps = 0,
}

local SongCache = Class:extend("SongCache")
SongCache.songs = {}

function SongCache:createCache(songData, filename, fileExt)
    local strOut = ""
    for key, _ in pairs(SongCacheFormat) do
        strOut = strOut .. key .. ":" .. (songData[key] or 0) .. "\n"
    end

    love.filesystem.write("CacheData/Beatmaps/" .. filename .. ".rsc", strOut)

    return SongCacheFormat
end
 
function SongCache:loadCache(filename, ogPath, fileExt)
    if love.filesystem.getInfo("CacheData/Beatmaps/" .. filename .. ".rsc") then
        local data = love.filesystem.read("CacheData/Beatmaps/" .. filename .. ".rsc")
        local songData = {}
        for line in data:gmatch("[^\n]+") do
            local key, value = line:match("([^:]+):(.+)")
            if not key or not value then
                goto continue
            end
            songData[key] = value

            ::continue::
        end
        songData["difficulty"] = tonumber(string.format("%.2f", tonumber(songData["difficulty"] or 0) or 0)) or 0
        if tonumber(songData["metaType"]) ~= 4 then
            -- delete the cache file and reload the song
            love.filesystem.remove("CacheData/Beatmaps/" .. filename .. ".rsc")
            return self:loadCache(filename, ogPath, fileExt)
        end
        return songData
    else
        if fileExt == ".qua" then
            local data = love.filesystem.read(ogPath)
            local songData = Parsers.Quaver:cache(data, filename, ogPath)
            songData.metaType = 4
            songData.game_mode = "Mania"
            return songData
        elseif fileExt == ".osu" then
            local data = love.filesystem.read(ogPath)
            local songData = Parsers.Osu:cache(data, filename, ogPath)
            songData.metaType = 4
            songData.game_mode = "Mania"
            return songData
        elseif fileExt == ".ritc" then
            local data = love.filesystem.read(ogPath)
            local songData = Parsers.Rit:cache(data, filename, ogPath)
            songData.metaType = 3
            songData.game_mode = "Mania"
            return songData
        elseif fileExt == ".fsc" then
            local data = love.filesystem.read(ogPath)
            local songData = Parsers.Fluxis:cache(data, filename, ogPath)
            songData.metaType = 4
            songData.game_mode = "Mania"
            return songData
        end
    end
end

function SongCache:loadSongsPath(path)
    local files = love.filesystem.getDirectoryItems(path)
    for _, file in ipairs(files) do
        local fileType = love.filesystem.getInfo(path .. "/" .. file).type
        if fileType == "directory" then
            for _, song in ipairs(love.filesystem.getDirectoryItems(path .. "/" .. file)) do
                if song:endsWith(".qua") then
                    local filename = song:gsub(".qua$", "")
                    local fullPath = path .. "/" .. file .. "/" .. song
                    local fileExt = ".qua"
                    
                    self:loadCache(filename, fullPath, fileExt)
                elseif song:endsWith(".osu") then
                    local filename = song:gsub(".osu$", "")
                    local fullPath = path .. "/" .. file .. "/" .. song
                    local fileExt = ".osu"
                    
                    self:loadCache(filename, fullPath, fileExt)
                elseif song:endsWith(".ritc") then
                    local filename = song:gsub(".rit$", "")
                    local fullPath = path .. "/" .. file .. "/" .. song
                    local fileExt = ".ritc"
                    
                    self:loadCache(filename, fullPath, fileExt)
                elseif song:endsWith(".fsc") then
                    local filename = song:gsub(".fsc$", "")
                    local fullPath = path .. "/" .. file .. "/" .. song
                    local fileExt = ".fsc"
                    
                    self:loadCache(filename, fullPath, fileExt)
                end
            end
        elseif fileType == "file" then
            if file:endsWith(".qp") then
                love.filesystem.mount(path .. "/" .. file, "song")
                
                for _, song in ipairs(love.filesystem.getDirectoryItems("song")) do
                    if song:endsWith(".qua") then
                        local filename = file:gsub(".qp$", "")
                        local fullPath = "song/" .. song
                        local fileExt = ".qua"
                        
                        self:loadCache(filename, fullPath, fileExt)
                    end
                end

                love.filesystem.unmount("song")
            end
        end
    end
end

return SongCache
