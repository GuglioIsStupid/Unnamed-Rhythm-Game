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
    local db = Database.BeatmapDB
    self.songCache = {}

    local index = 1
    local diffIndexes = {}
    local songList = db:exec([[SELECT * FROM Beatmaps]])
    local count = #songList[1]

    local filenames = songList[1]
    local ogpaths = songList[2]
    local fileexts = songList[3]
    local titles = songList[4]
    local artists = songList[5]
    local sources = songList[6]
    local tags = songList[7]
    local creators = songList[8]
    local diff_names = songList[9]
    local descriptions = songList[10]
    local paths = songList[11]
    local audio_paths = songList[12]
    local bg_paths = songList[13]
    local preview_times = songList[14]
    local mapset_ids = songList[15]
    local map_ids = songList[16]
    local modes = songList[17]
    local game_modes = songList[18]
    local map_types = songList[19]
    local hitobj_counts = songList[20]
    local ln_counts = songList[21]
    local lengths = songList[22]
    local metaTypes = songList[23]
    local difficulties = songList[24]
    local npses = songList[25]

    for i = 1, count do
        -- convert the luajit number to a normal lua number for mapset_id
        mapset_ids[i] = tonumber(mapset_ids[i])
        if not self.songCache[mapset_ids[i]] then
            diffIndexes[mapset_ids[i]] = 1
            self.songCache[mapset_ids[i]] = {
                title = titles[i] or "Unknown",
                artist = artists[i] or "Unknown",
                creator = creators[i] or "Unknown",
                mapType = map_types[i] or "Unknown",
                tags = tags[i] or "Unknown",
                difficulties = {},
                index = index
            }

            index = index + 1
        end
        local songData = {
            title = titles[i],
            artist = artists[i],
            source = sources[i],
            tags = tags[i],
            creator = creators[i],
            diff_name = diff_names[i] or "Unknown",
            description = descriptions[i],
            filename = filenames[i],
            path = paths[i],
            audio_path = audio_paths[i],
            preview_time = preview_times[i],
            mapset_id = mapset_ids[i],
            map_id = map_ids[i],
            mode = modes[i],
            game_mode = game_modes[i],
            hitobj_count = hitobj_counts[i],
            ln_count = ln_counts[i],
            length = lengths[i],
            metaType = metaTypes[i],
            map_type = map_types[i],
            bg_path = bg_paths[i],
            difficulty = difficulties[i],
            nps = npses[i]
        }
        songData.index = diffIndexes[mapset_ids[i]]
        self.songCache[mapset_ids[i]].difficulties[map_ids[i]] = songData
        diffIndexes[mapset_ids[i]] = diffIndexes[mapset_ids[i]] + 1
    end

    --[[ for _, v in ipairs(songList) do
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
    end ]]

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
