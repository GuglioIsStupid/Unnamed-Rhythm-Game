local Rit = {}

local currentSection = ""
local curData = {}
local noteCount = 0

local state = States.Screens.Game

function Rit:parse(path, folderPath)
    currentSection = ""
    curData = {}
    noteCount = 0

    local data = love.filesystem.read(path)
    local lines = data:split("\n")

    for _, line in ipairs(lines) do
        line = line:trim()
        if line:match("^%[.*%]$") then
            currentSection = line:sub(2, -2)
        else
            if currentSection == "Metadata" then
                self:parseMetadata(line)
            elseif currentSection == "HitObjects" then
                self:parseNoteObjects(line, false)
            elseif currentSection == "TimingPoints" then
                self:parseTimingPoints(line, false)
            end
        end
    end

    state.instance.data.initialSV = curData.InitialSV or 1
    state.instance.data.song = love.sound.newSoundData(folderPath .. "/" .. curData.AudioFile)
    state.instance.data.noteCount = noteCount
    state.instance.data.length = curData.length
    state.instance.data.mode = curData.Keys
end

function Rit:cache(data, filename, path)
    local pathToFile = path
    data = data:gsub("\r\n", "\n")

    currentSection = ""
    curData = {}
    noteCount = 0

    local lines = data:split("\n")
    curData = {
        noteCount = 0,
        lnCount = 0,
        length = 0,
        notes = {}
    }

    for _, line in ipairs(lines) do
        line = line:trim()
        if line == "" then
            goto continue
        end
        if line:match("^%[.*%]$") then
            currentSection = line:sub(2, -2)
        else
            if currentSection == "Metadata" then
                self:parseMetadata(line)
            elseif currentSection == "HitObjects" then
                self:parseNoteObjects(line, true)
            elseif currentSection == "TimingPoints" then
                self:parseTimingPoints(line, true)
            end
        end
        ::continue::
    end

    local difficulty, nps = DifficultyCalculator:calculate(curData.notes, curData.Keys)

    local songData = {
        title = curData.Title,
        artist = curData.Artist,
        source = "",
        tags = "",
        creator = curData.Creator,
        diff_name = curData.DifficultyName or "Unknown",
        description = "",
        filename = filename,
        path = pathToFile,
        audio_path = curData.AudioFile,
        preview_time = 0,
        mapset_id = curData.MapSetID,
        map_id = curData.MapID,
        mode = curData.Keys,
        game_mode = "Mania",
        hitobj_count = curData.noteCount,
        ln_count = curData.lnCount,
        length = curData.length,
        metaType = 4,
        map_type = "Rit",
        bg_path = curData.BackgroundFile,
        difficulty = difficulty,
        nps = nps
    }

    SongCache:createCache(songData, filename, ".Rit")

    return songData
end

function Rit:parseMetadata(line)
    local key, value = line:match("^(.-): (.+)$")
    if key == "Title" then
        curData.Title = value
    elseif key == "DifficultyName" then
        curData.DifficultyName = value
    elseif key == "Artist" then
        curData.Artist = value
    elseif key == "Creator" then
        curData.Creator = value
    elseif key == "AudioFile" then
        curData.AudioFile = value
    elseif key == "BackgroundFile" then
        curData.BackgroundFile = value
    elseif key == "Keys" then
        curData.Keys = tonumber(value)
    elseif key == "MapSetID" then
        curData.MapSetID = value
    elseif key == "MapID" then
        curData.MapID = value
    elseif key == "InitialSV" then
        curData.InitialSV = value
    elseif key == "GameMode" then
        -- 1 = Mania, 2 = Mobile, TODO: More modes
        curData.GameMode = value
        if state.instance and state.instance.data then
            state.instance.data.gameMode = value
        end
    end
end

function Rit:parseTimingPoints(line, isCache)
    if isCache then return end

    local type, time, value = line:match("^(.-):(.-):(.+)$")
    if type == "SV" then
        table.insert(state.instance.data.scrollVelocities, {StartTime = tonumber(time), Multiplier = tonumber(value)})
    end
end

function Rit:parseNoteObjects(line, isCache)
    local type, lane, startTime, endTime, hitsounds = line:match("^(.-):(.-):(.-):(.-):(.-)$")
    if isCache then
        noteCount = noteCount + 1
        local hasEndtime = tonumber(endTime or 0) > tonumber(startTime or 0)
        if hasEndtime then
            curData.length = math.max(curData.length, tonumber(endTime))
            curData.lnCount = curData.lnCount + 1
        else
            curData.length = math.max(curData.length, tonumber(startTime))
        end

        local note = {
            Lane = tonumber(lane),
            StartTime = tonumber(startTime),
        }
        table.insert(curData.notes, note)
    end

    if type == "HIT" and not isCache then
        local note = UnspawnObject(tonumber(startTime), tonumber(endTime), tonumber(lane))
        table.insert(state.instance.data.hitObjects, note)
    end
end

return Rit
