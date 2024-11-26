local osu = {}

local currentSection = ""
local curData = {}
local noteCount = 0

local state = States.Screens.Game

function osu:parse(path, folderPath)
    local data = love.filesystem.read(path)
    currentSection = ""
    curData = {}
    noteCount = 0

    local lines = data:split("\n")

    for _, line in ipairs(lines) do
        line = line:trim()
        if line:match("^%[.*%]$") then
            currentSection = line:sub(2, -2)
        else
            if currentSection == "General" then
                self:parseGeneral(line)
            elseif currentSection == "Metadata" then
                self:parseMetadata(line)
            elseif currentSection == "Difficulty" then
                self:parseDifficulty(line)
            elseif currentSection == "Events" then
                self:parseEvents(line)
            elseif currentSection == "TimingPoints" then
                self:parseTimingPoints(line)
            elseif currentSection == "HitObjects" then
                self:parseHitObjects(line)
            end
        end
    end

    state.instance.data.initialSV = 1
    state.instance.data.song = love.sound.newSoundData(folderPath .. "/" .. curData.AudioFilename)
    
    math.randomseed(curData.BeatmapID)

    --[[ state.instance.data.mode = 1
    for i, note in ipairs(curData.HitObjects) do
        local normalLane = math.floor(note.X / (512/state.instance.data.mode) + 1)
        local targetLaneCount = 1
        local newLane = love.math.random(1, targetLaneCount)
        table.insert(
            state.instance.data.hitObjects,
            UnspawnObject(note.Time, note.EndTime, newLane)
        )
        for j = 1, 5 do
            local try = 0
            local last = state.instance.data.hitObjects[#state.instance.data.hitObjects - i] or {Lane = -10000, StartTime = -10000}
            while math.abs(last.Lane - newLane) < 2 and math.abs(last.StartTime - note.Time) < 50 do
                newLane = love.math.random(1, targetLaneCount)
                try = try + 1
                if try > 5 then
                    table.remove(state.instance.data.hitObjects, #state.instance.data.hitObjects)
                end
            end
        end
    end

    -- remove overlapping notes
    for i = 1, #state.instance.data.hitObjects do
        local note = state.instance.data.hitObjects[i]
        for j = i + 1, #state.instance.data.hitObjects do
            local other = state.instance.data.hitObjects[j] or {Lane = -10000, StartTime = -10000}
            if note.StartTime == other.StartTime and note.Lane == other.Lane then
                table.remove(state.instance.data.hitObjects, j)
            end
        end
    end ]]
    -- TODO: Add above into seperate Modifiers manager
    for i, note in ipairs(curData.HitObjects) do
        table.insert(
            state.instance.data.hitObjects,
            UnspawnObject(note.Time, note.EndTime, math.floor(note.X / (512/curData.CircleSize) + 1))
        )
    end
end

function osu:cache(data, filename, path)
    local isMania = false
    local matched = data:match("Mode: 3")
    if matched then
        isMania = true
    end
    if not isMania then
        return
    end
    local pathToFile = path
    currentSection = ""
    curData = {
        noteCount = 0,
        lnCount = 0,
        length = 0,
        notes = {}
    }

    local lines = data:split("\n")

    for _, line in ipairs(lines) do
        line = line:trim()
        if line:match("^%[.*%]$") then
            currentSection = line:sub(2, -2)
        else
            if currentSection == "General" then
                self:parseGeneral(line)
            elseif currentSection == "Metadata" then
                self:parseMetadata(line)
            elseif currentSection == "Difficulty" then
                self:parseDifficulty(line)
            elseif currentSection == "Events" then
                self:parseEvents(line)
            elseif currentSection == "TimingPoints" then
                self:parseTimingPoints(line, true)
            elseif currentSection == "HitObjects" then
                self:parseHitObjects(line, true)
            end
        end
    end

    local difficulty, nps = DifficultyCalculator.Mania:calculate(curData.notes, curData.mode)

    local songData = {
        title = curData.Title,
        artist = curData.Artist,
        source = "",
        tags = "",
        creator = curData.Creator,
        diff_name = curData.Version,
        description = "",
        filename = filename,
        path = pathToFile,
        audio_path = curData.AudioFilename,
        preview_time = curData.PreviewTime,
        mapset_id = curData.BeatmapSetID,
        map_id = curData.BeatmapID,
        mode = curData.CircleSize,
        game_mode = "Mania",
        hitobj_count = curData.noteCount,
        ln_count = curData.lnCount,
        length = curData.length,
        metaType = 4,
        map_type = "Osu",
        bg_path = curData.Background,
        video_path = "",
        difficulty = difficulty,
        nps = nps,
    }

    return songData
end

function osu:parseGeneral(line)
    local trimmed = line:trim()
    local key, value = trimmed:match("([^:]+):(.+)")
    if not key or not value then
        return
    end

    if key == "AudioFilename" then
        curData.AudioFilename = value:trim()
    elseif key == "PreviewTime" then
        curData.PreviewTime = tonumber(value:trim())
    end
end

function osu:parseMetadata(line)
    local trimmed = line:trim()
    local key, value = trimmed:match("([^:]+):(.+)")
    if not key or not value then
        return
    end

    if key == "Title" then
        curData.Title = value:trim()
    elseif key == "Artist" then
        curData.Artist = value:trim()
    elseif key == "Creator" then
        curData.Creator = value:trim()
    elseif key == "Version" then
        curData.Version = value:trim()
    elseif key == "BeatmapID" then
        curData.BeatmapID = tonumber(value:trim())
    elseif key == "BeatmapSetID" then
        curData.BeatmapSetID = tonumber(value:trim())
    end
end

function osu:parseDifficulty(line)
    local trimmed = line:trim()
    local key, value = trimmed:match("([^:]+):(.+)")
    if not key or not value then
        return
    end

    if key == "CircleSize" then
        curData.CircleSize = tonumber(value:trim())
        if state.instance and state.instance.data then
            state.instance.data.mode = curData.CircleSize or 4
            state.instance.data.mode = tonumber(state.instance.data.mode)
        else
            curData.mode = curData.CircleSize or 4
        end
    elseif key == "OverallDifficulty" then
        curData.OverallDifficulty = tonumber(value:trim())
    elseif key == "ApproachRate" then
        curData.ApproachRate = tonumber(value:trim())
    elseif key == "HPDrainRate" then
        curData.HPDrainRate = tonumber(value:trim())
    end
end

function osu:parseEvents(line)
    local trimmed = line:trim()
    if line:startsWith("//") then
        return
    end
   --0,0,"IMG_9619.jpg",0,0
   local split = trimmed:split(",")

    if split[1] == "0" and split[2] == "0" then
       curData.Background = split[3]:gsub("\"", "")
   end
end

function osu:parseTimingPoints(line, inParse)
    if not inParse then
        if not curData.TimingPoints then
            curData.TimingPoints = {}
        end
    else
        return
    end
    local trimmed = line:trim()
    local split = trimmed:split(",")
    if #split < 8 then
        return
    end

    local time = tonumber(split[1])
    local msPerBeat = tonumber(split[1])
    local meter = tonumber(split[2])
    local sampleSet = tonumber(split[3])
    local sampleIndex = tonumber(split[4])
    local volume = tonumber(split[5])
    local inherited = tonumber(split[6])
    local kiai = tonumber(split[7])

    table.insert(curData.TimingPoints, {
        Time = time,
        MsPerBeat = msPerBeat,
        Meter = meter,
        SampleSet = sampleSet,
        SampleIndex = sampleIndex,
        Volume = volume,
        Inherited = inherited,
        Kiai = kiai
    })
end

function osu:parseHitObjects(line, inParse)
    if not inParse then
        if not curData.HitObjects then
            curData.HitObjects = {}
        end
    end

    local trimmed = line:trim()
    local split = trimmed:split(",")
    if #split < 5 then
        return
    end

    -- x, n/a, startTime, type, hitsound, params (colon separated)
    -- type is a 8-bit flag
    local x = tonumber(split[1])
    local y = tonumber(split[2])
    local time = tonumber(split[3])
    local type = tonumber(bit.band(tonumber(split[4]), 0x0F))
    local hitSound = tonumber(split[5])
    local params = split[6]:split(":")
    local endTime = tonumber(params[1]) or 0

    if not inParse then
        noteCount = noteCount + 1
        table.insert(curData.HitObjects, {
            X = x,
            Y = y,
            Time = time,
            Type = type,
            HitSound = hitSound,
            EndTime = endTime
        })
    else
        if type == 7 then
            curData.lnCount = curData.lnCount + 1
        end
        curData.noteCount = curData.noteCount + 1
        table.insert(curData.notes, {
            Lane = math.floor(x * (512/curData.mode) + 1),
            StartTime = time,
        })
        curData.length = math.max(curData.length, endTime > time and endTime or time)
    end
end

return osu
