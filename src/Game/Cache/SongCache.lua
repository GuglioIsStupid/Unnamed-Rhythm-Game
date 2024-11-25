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

function SongCache:createCache(songData, filename, fileExt, ogPath)
    local db = Database.BeatmapDB
    
    local data = SongCacheFormat
    for k, v in pairs(songData) do
        data[k] = v
    end

    data.filename = filename
    data.ogpath = ogPath
    data.fileext = fileExt

    db:exec(
        'INSERT INTO Beatmaps VALUES ("' .. 
        data.filename .. '", "' .. 
        data.ogpath .. '", "' .. 
        data.fileext .. '", "' .. 
        data.title:safe() .. '", "' .. 
        data.artist:safe() .. '", "' .. 
        data.source:safe() .. '", "' .. 
        data.tags:safe() .. '", "' .. 
        data.creator:safe() .. '", "' .. 
        data.diff_name:safe() .. '", "' .. 
        data.description:safe() .. '", "' .. 
        data.path .. '", "' .. 
        data.audio_path .. '", "' .. 
        data.bg_path .. '", ' .. 
        data.preview_time .. ', ' .. 
        data.mapset_id .. ', ' .. 
        data.map_id .. ', ' .. 
        data.mode .. ', "' .. 
        data.game_mode .. '", "' .. 
        data.map_type .. '", ' .. 
        data.hitobj_count .. ', ' .. 
        data.ln_count .. ', ' .. 
        data.length .. ', ' .. 
        data.metaType .. ', ' .. 
        data.difficulty .. ', ' .. 
        data.nps .. 
        ')'
    )

    return data
end


function SongCache:loadCache(filename, ogPath, fileExt)
    local db = Database.BeatmapDB
    local data = db:exec([[SELECT * FROM Beatmaps WHERE filename=="]] .. filename .. [[" AND ogpath=="]] .. ogPath .. [[" AND fileext=="]] .. fileExt .. [["]])

    if data then
        return data
    end

    if fileExt == ".qua" then
        local data = love.filesystem.read(ogPath)
        local songData = Parsers.Quaver:cache(data, filename, ogPath)
        songData.metaType = 4
        songData.game_mode = "Mania"
        return self:createCache(songData, filename, fileExt, ogPath)
    elseif fileExt == ".osu" then
        local data = love.filesystem.read(ogPath)
        local songData = Parsers.Osu:cache(data, filename, ogPath)
        songData.metaType = 4
        songData.game_mode = "Mania"
        return self:createCache(songData, filename, fileExt, ogPath)
    elseif fileExt == ".ritc" then
        local data = love.filesystem.read(ogPath)
        local songData = Parsers.Rit:cache(data, filename, ogPath)
        songData.metaType = 3
        songData.game_mode = "Mania"
        return self:createCache(songData, filename, fileExt, ogPath)
    elseif fileExt == ".fsc" then
        local data = love.filesystem.read(ogPath)
        local songData = Parsers.Fluxis:cache(data, filename, ogPath)
        songData.metaType = 4
        songData.game_mode = "Mania"
        return self:createCache(songData, filename, fileExt, ogPath)
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
