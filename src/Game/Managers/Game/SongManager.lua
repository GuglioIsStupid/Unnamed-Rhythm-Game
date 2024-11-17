---@class SongManager
local SongManager = {}
SongManager.songCache = {}

function SongManager:getSongList()
    if not self.songCache or #self.songCache == 0 then
        self:loadSongList()
    end

    return self.songCache
end

function SongManager:loadSongList()
    self.songCache = {}

    local index = 1
    local diffIndexes = {}
    local songList = love.filesystem.getDirectoryItems("CacheData/Beatmaps/")

    for _, v in ipairs(songList) do
        -- if file is .scache, delete it    
        if v:endsWith(".scache") then
            love.filesystem.remove("CacheData/Beatmaps/" .. v)
            goto continue
        end
        local songData = self:loadCache(v, "CacheData/Beatmaps/" .. v, ".rsc")
        if not self.songCache[songData.mapset_id or 0] then
            diffIndexes[songData.mapset_id or 0] = 1
            self.songCache[songData.mapset_id or 0] = {
                title = songData.title or "Unknown",
                artist = songData.artist or "Unknown",
                creator = songData.creator or "Unknown",
                mapType = songData.map_type or "Unknown",
                tags = songData.tags or "Unknown",
                difficulties = {},
                index = index
            }

            index = index + 1
        end
        songData.index = diffIndexes[songData.mapset_id or 0]
        self.songCache[songData.mapset_id or 0].difficulties[songData.map_id or 0] = songData
        diffIndexes[songData.mapset_id or 0] = diffIndexes[songData.mapset_id or 0] + 1
        ::continue::
    end

    local sortedList = {}
    for _, v in pairs(self.songCache) do
        table.insert(sortedList, v)
    end
    table.sort(sortedList, function(a, b)
        return a.title < b.title
    end)

    self.songCache = {}
    for i, v in ipairs(sortedList) do
        v.index = i
        table.insert(self.songCache, v)
    end

    -- now sort difficulties based off difficulty
    for _, v in pairs(self.songCache) do
        local sortedDiffs = {}
        for _, diff in pairs(v.difficulties) do
            table.insert(sortedDiffs, diff)
        end
        table.sort(sortedDiffs, function(a, b)
            return a.difficulty < b.difficulty
        end)

        v.difficulties = {}
        for i, diff in ipairs(sortedDiffs) do
            diff.index = i
            table.insert(v.difficulties, diff)
        end
    end

    return self.songCache
end

function SongManager:loadCache(filename, ogPath, fileExt)
    if love.filesystem.getInfo("CacheData/Beatmaps/" .. filename) then
        local data = love.filesystem.read("CacheData/Beatmaps/" .. filename)
        local songData = {}
        for line in data:gmatch("[^\n]+") do
            local key, value = line:match("([^:]+):(.+)")
            if not key or not value then
                goto continue
            end
            songData[key] = value

            ::continue::
        end
        return songData
    end

    debug.warn("Failed to load cache for " .. filename)
end

return SongManager
