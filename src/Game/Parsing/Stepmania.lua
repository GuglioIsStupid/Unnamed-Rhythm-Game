local Stepmania = {}

local state = States.Screens.Game

function Stepmania:cache(data, filename, path, ogPath, diffName)
    print(filename, path, ogPath, diffName)
    local title = "Unknown"
    local artist = "Unknown"
    local source = "Unknown"
    local tags = "Unknown"
    local creator = "Unknown"
    local diff_name = "Unknown"
    local preview_time = 0
    
    local audioPath = "Unknown"

    local mode = 4
    
    local game_mode = "Mania"
    local hitobj_count = 0
    local ln_count = 0
    local length = 0
    local notes = {}
    local difficulty, nps = 0, 0

    -- data is a text string, go through each line
    local inBPMS = false
    local inNotes = false
    local noteIndex = 0
    local currentBPM = 0
    local measureIndex = 0
    local measureSize = nil
    local storedBPMS = {}
    local didNotesMeta = false
    local metaIndex = 0
    local inDanceSingle = false
    local inCorrectDifficulty = false
    for i, line in ipairs(data:split("\n")) do
        -- if line starts with #
        if line:sub(1, 1) == "#" then
            inBPMS = false
            inNotes = false
            line = line:sub(2)
            local split = line:split(":")
            local key = split[1]
            local value = split[2]:gsub(";", "")
            if key == "TITLE" then
                title = value
            elseif key == "ARTIST" then
                artist = value
            elseif key == "SOURCE" then
                source = value
            elseif key == "TAGS" then
                tags = value
            elseif key == "CREATOR" then
                creator = value
            elseif key == "MUSIC" then
                audioPath = value
            elseif key == "BPMS" then
                inBPMS = true
            elseif key == "NOTES" then
                inNotes = true
                metaIndex = 0
                noteIndex = 0
                measureIndex = 0
            end
        end

        if inBPMS then
            local split = (line:gsub("BPMS:", ""):gsub(";", "")):split("=")
            local time = tonumber(split[1])
            local bpm = tonumber(split[2])
            if time and bpm then
                if currentBPM == 0 then
                    currentBPM = bpm
                end
                storedBPMS[time] = bpm
                print("BPM: " .. bpm .. " at " .. time)
            end
        end

        -- if in notes, and chart type is dance-single
        -- CAN'T BE DANCE-DOUBLE!
        if inNotes then
            --[[
            #NOTES:
                dance-single:
                Blank:
                Challenge:
                11:
                0.775,0.344,0.884,0.334,0.851:
                // measure 1
                1000
            ]]
            if not didNotesMeta then
                line = line:trim():gsub(":", "")
                if metaIndex == 1 then
                    if line == "dance-single" then
                        inDanceSingle = true
                    end
                elseif metaIndex == 2 then
                    -- idk what this one is
                elseif metaIndex == 3 then
                    diff_name = line:gsub(":", "")

                    if diffName and diffName == diff_name then
                        inCorrectDifficulty = true
                    end
                elseif metaIndex == 4 then
                    -- idk what this one is
                elseif metaIndex == 5 then
                    -- idk what this one is

                    didNotesMeta = true
                end

                metaIndex = metaIndex + 1
            else
                if not inDanceSingle or not inCorrectDifficulty then
                    print(inDanceSingle, inCorrectDifficulty, diffName, diff_name)
                    return nil
                end

                if not measureSize then
                    -- calculate our measure size
                    -- until the first ,
                    for i, line in ipairs(data:split("\n")) do
                        local inNotes = false
                        local metaIndex = 0
                        local didNotesMeta = false
                        if line:sub(1, 1) == "#" then
                            line = line:sub(2)
                            local split = line:split(":")
                            local key = split[1]
                            local value = split[2]:gsub(";", "")
                            if key == "NOTES" then
                                inNotes = true
                                metaIndex = 0
                            end
                        end

                        if inNotes then
                            if not didNotesMeta then
                                line = line:trim():gsub(":", "")
                                if metaIndex == 1 then
                                    if line == "dance-single" then
                                        inDanceSingle = true
                                    end
                                elseif metaIndex == 2 then
                                    -- idk what this one is
                                elseif metaIndex == 3 then
                                    diff_name = line:gsub(":", "")

                                    if diffName and diffName == diff_name then
                                        inCorrectDifficulty = true
                                    end
                                elseif metaIndex == 4 then
                                    -- idk what this one is
                                elseif metaIndex == 5 then
                                    -- idk what this one is

                                    didNotesMeta = true
                                end

                                metaIndex = metaIndex + 1
                            else
                                if not inDanceSingle or not inCorrectDifficulty then
                                    
                                    return nil
                                end

                                if not measureSize then
                                    if not line:find(",") then
                                        measureSize = (measureSize or 0) + 1
                                    end
                                end
                            end
                        end
                    end
                end

                if line:find(",") then
                    measureIndex = measureIndex + 1
                    noteIndex = 0
                end

                local lane = 0
                for note in line:gmatch("%d") do
                    lane = lane + 1
                    noteIndex = noteIndex + 1
                    --float noteRow = (measureIndex * 192) + (lengthInRows * rowIndex);
                    local lengthInRows = 192 / (measureSize or 16)
                    local noteRow = (measureIndex * 192) + (lengthInRows * noteIndex)
                    local beat = noteRow / 48
                    if note == "1" then
                        local time = beat * 60000 / currentBPM
                        local noteData = {
                            Lane = lane,
                            StartTime = time,
                        }
                        length = math.max(length, time)
                        hitobj_count = hitobj_count + 1
                        table.insert(notes, noteData)
                    end
                end

                noteIndex = noteIndex + 1
            end
        end
    end

    difficulty, nps = DifficultyCalculator.Mania:calculate(notes, 4)

    local songData = {
        title = title,
        artist = artist,
        source = source,
        tags = tags,
        creator = creator,
        diff_name = diff_name,
        description = "",
        filename = filename,
        path = path,
        audio_path = audioPath,
        preview_time = preview_time,
        mapset_id = love.math.random(1, 100000),
        map_id = love.math.random(1, 100000),
        mode = mode,
        game_mode = game_mode,
        hitobj_count = hitobj_count,
        ln_count = ln_count,
        length = length,
        metaType = 4,
        map_type = "Stepmania",
        bg_path = "Unknown",
        difficulty = difficulty,
        nps = nps
    }

    return songData
end

function Stepmania:parse(path, folderPath)
    local data = love.filesystem.read(path)
    local title = "Unknown"
    local artist = "Unknown"
    local source = "Unknown"
    local tags = "Unknown"
    local creator = "Unknown"
    local diff_name = "Unknown"
    local preview_time = 0
    
    local audioPath = "Unknown"

    local mode = 4
    
    local game_mode = "Mania"
    local hitobj_count = 0
    local ln_count = 0
    local length = 0
    local notes = {}
    local difficulty, nps = 0, 0

    -- data is a text string, go through each line
    local inBPMS = false
    local inNotes = false
    local noteIndex = 0
    local currentBPM = 0
    local measureIndex = 0
    local measureSize = nil
    local storedBPMS = {}
    local didNotesMeta = false
    local metaIndex = 0
    local inDanceSingle = false
    local inCorrectDifficulty = false
    for i, line in ipairs(data:split("\n")) do
        if line:startsWith("//") then
            goto continue
        end
        -- if line starts with #
        if line:sub(1, 1) == "#" then
            inBPMS = false
            inNotes = false
            line = line:sub(2)
            local split = line:split(":")
            local key = split[1]
            local value = split[2]:gsub(";", "")
            if key == "TITLE" then
                title = value
            elseif key == "ARTIST" then
                artist = value
            elseif key == "SOURCE" then
                source = value
            elseif key == "TAGS" then
                tags = value
            elseif key == "CREATOR" then
                creator = value
            elseif key == "MUSIC" then
                audioPath = value
            elseif key == "BPMS" then
                inBPMS = true
            elseif key == "NOTES" then
                inNotes = true
                metaIndex = 0
                noteIndex = 0
                measureIndex = 0
            end
        end

        if inBPMS then
            local split = (line:gsub("BPMS:", ""):gsub(";", "")):split("=")
            local time = tonumber(split[1])
            local bpm = tonumber(split[2])
            
            if time and bpm then
                if currentBPM == 0 then
                    currentBPM = bpm
                end
                storedBPMS[time] = bpm
                print("BPM: " .. bpm .. " at " .. time)
            end
        end

        -- if in notes, and chart type is dance-single
        -- CAN'T BE DANCE-DOUBLE!
        if inNotes then
            --[[
            #NOTES:
                dance-single:
                Blank:
                Challenge:
                11:
                0.775,0.344,0.884,0.334,0.851:
                // measure 1
                1000
            ]]
            if not didNotesMeta then
                line = line:trim():gsub(":", "")
                if metaIndex == 1 then
                    if line == "dance-single" then
                        inDanceSingle = true
                    end
                elseif metaIndex == 2 then
                    -- idk what this one is
                elseif metaIndex == 3 then
                    diff_name = line:gsub(":", "")
                elseif metaIndex == 4 then
                    -- idk what this one is
                elseif metaIndex == 5 then
                    -- idk what this one is

                    didNotesMeta = true
                end

                metaIndex = metaIndex + 1
            else
                if not inDanceSingle then
                    return nil
                end

                if not measureSize then
                    -- calculate our measure size
                    -- until the first ,
                    for i, line in ipairs(data:split("\n")) do
                        local inNotes = false
                        local metaIndex = 0
                        local didNotesMeta = false
                        if line:sub(1, 1) == "#" then
                            line = line:sub(2)
                            local split = line:split(":")
                            local key = split[1]
                            local value = split[2]:gsub(";", "")
                            if key == "NOTES" then
                                inNotes = true
                                metaIndex = 0
                            end
                        end

                        if inNotes then
                            if not didNotesMeta then
                                line = line:trim():gsub(":", "")
                                if metaIndex == 1 then
                                    if line == "dance-single" then
                                        inDanceSingle = true
                                    end
                                elseif metaIndex == 2 then
                                    -- idk what this one is
                                elseif metaIndex == 3 then
                                    diff_name = line:gsub(":", "")
                                elseif metaIndex == 4 then
                                    -- idk what this one is
                                elseif metaIndex == 5 then
                                    -- idk what this one is

                                    didNotesMeta = true
                                end

                                metaIndex = metaIndex + 1
                            else
                                if not inDanceSingle then
                                    return nil
                                end

                                if not measureSize then
                                    if not line:find(",") then
                                        measureSize = (measureSize or 16) + 1
                                    end
                                end
                            end
                        end
                    end
                end

                if line:find(",") then
                    measureIndex = measureIndex + 1
                    noteIndex = 0
                end

                local lane = 0
                for note in line:gmatch("%d") do
                    lane = lane + 1
                    noteIndex = noteIndex + 1
                    --float noteRow = (measureIndex * 192) + (lengthInRows * rowIndex);
                    local lengthInRows = 192 / (measureSize or 16)
                    local noteRow = (measureIndex * 192) + (lengthInRows * noteIndex)
                    local beat = noteRow / 48
                    if note == "1" then
                        local time = beat * 60000 / currentBPM
                        local note = UnspawnObject(time, time, lane)
                        length = math.max(length, time)
                        hitobj_count = hitobj_count + 1
                        table.insert(state.instance.data.hitObjects, note)
                    end
                end
            end
        end

        ::continue::
    end

    -- remove notes that have the exact same StartTime
    for i, note in ipairs(state.instance.data.hitObjects) do
        for j, note2 in ipairs(state.instance.data.hitObjects) do
            if note.StartTime == note2.StartTime and i ~= j then
                table.remove(state.instance.data.hitObjects, j)
            end
        end
    end

    state.instance.data.initialSV = 1
    state.instance.data.song = love.sound.newSoundData(folderPath .. audioPath:trim())
    state.instance.data.noteCount = hitobj_count
    state.instance.data.length = length
    state.instance.data.mode = mode
end

function Stepmania:getAllDifficulties(data)
    local difficulties = {}
    local inNotes = false
    local metaIndex = 0
    local didNotesMeta = false

    for i, line in ipairs(data:split("\n")) do
        if line:sub(1, 1) == "#" then
            inNotes = false
            line = line:sub(2)
            local split = line:split(":")
            local key = split[1]
            local value = split[2]:gsub(";", "")
            if key == "NOTES" then
                inNotes = true
                metaIndex = 0
            end
        end

        -- meta index needs to be 3
        if inNotes then
            if not didNotesMeta then
                line = line:trim():gsub(":", "")
                if metaIndex == 1 then
                    if line == "dance-single" then
                        inDanceSingle = true
                    end
                elseif metaIndex == 2 then
                    -- idk what this one is
                elseif metaIndex == 3 then
                    diff_name = line
                    table.insert(difficulties, diff_name)
                elseif metaIndex == 4 then
                    -- idk what this one is
                elseif metaIndex == 5 then
                    -- idk what this one is

                    didNotesMeta = true
                end

                metaIndex = metaIndex + 1
            end
        end
    end
        
    return difficulties
end

return Stepmania