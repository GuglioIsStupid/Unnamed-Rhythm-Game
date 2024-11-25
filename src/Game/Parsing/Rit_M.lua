local RitM = {}

local currentSection = ""
local curData = {}
local noteCount = 0

local state = States.Screens.Game

function RitM:parse(path, folderPath)
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
            end
        end
    end

    state.instance.data.initialSV = curData.InitialSV or 1
    state.instance.data.song = love.sound.newSoundData(folderPath .. "/" .. curData.AudioFile)
    state.instance.data.noteCount = noteCount
    state.instance.data.length = 10000
end

function RitM:cache(data, filename, path)
    local pathToFile = path
    data = data:gsub("\r\n", "\n")

    currentSection = ""
    curData = {}
    noteCount = 0

    local lines = data:split("\n")
    curData = {
        noteCount = 0,
        lnCount = 0,
        length = 0
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
            end
        end
        ::continue::
    end

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
        game_mode = "mobile",
        hitobj_count = curData.noteCount,
        ln_count = curData.lnCount,
        length = curData.length,
        metaType = 3,
        map_type = "RitM",
        bg_path = curData.BackgroundFile
    }

    return songData
end

function RitM:parseMetadata(line)
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
        curData.Keys = -1 -- Unused
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

function RitM:parseNoteObjects(line, isCache)
    if isCache then
        noteCount = noteCount + 1
        return
    end
    --type:tileIndex:start_time:end_time:hitsounds:params,separated,by,commas
    --e.g.: TAP:1:500:-1:_:2,0,0,0
    -- There are 12 tiles in total.
    local type, lane, startTime, endTime, hitsounds, params = line:match("^(.-):(.-):(.-):(.-):(.-):(.+)$")
    print(type, lane, startTime, endTime, hitsounds, params, line)
    local params = params:split(",")
    -- if width_by_tiles + lane > 12, then it clamps the width automatically
    -- params layout:
    --[[
    TAP:
        1: width_by_tiles (1-12)
    SLIDE:
        1: width_by_tiles (1-12)
        2: end_width_by_tiles (1-12)
        (optional...) (... = continuous)
        i: time:width_by_tiles -- slides are polygons, allowing us to change the width at any time
    FLICK:
        1: width_by_tiles (1-12)
    CATCH:
        1: width_by_tiles (1-12)
    ]]
    print(type, lane, startTime, endTime, hitsounds, params)

    if type == "TAP" then
        -- tap note
        local width = tonumber(params[1])
        -- check if width is valid
        if width < 1 or width > 12 then
            return
        end

        -- now we check if width goes over the lane limit
        if width + lane > 12 then
            width = 12 - lane
        end

        -- create note
        local tapNote = UnspawnTap(
            lane,
            startTime,
            width,
            hitsounds,
            "TAP"
        )

        state.instance.data.hitObjects[#state.instance.data.hitObjects + 1] = tapNote
    elseif type == "SLIDE" then
        -- slide note
        local width = tonumber(params[1])
        local endWidth = tonumber(params[2])
        -- check if width is valid
        if width < 1 or width > 12 then
            return
        end
        if endWidth < 1 or endWidth > 12 then
            return
        end

        -- now we check if width goes over the lane limit
        if width + lane > 12 then
            width = 12 - lane
        end
        if endWidth + lane > 12 then
            endWidth = 12 - lane
        end

        -- get extra data
        local data = {}
        for i = 3, #params, 2 do
            data[#data + 1] = {
                time = tonumber(params[i]),
                width = tonumber(params[i + 1])
            }
        end

        -- create note
        local slideNote = UnspawnSlide(
            lane,
            startTime,
            endTime,
            width,
            endWidth,
            hitsounds,
            "SLIDE",
            data
        )

        state.instance.data.hitObjects[#state.instance.data.hitObjects + 1] = slideNote
    elseif type == "FLICK" then
        -- flick note
    elseif type == "CATCH" then
        -- catch note
    end
end

return RitM
