local Quaver = {}

local state = States.Screens.Game

function Quaver:parse(path, folderPath)
    local data = love.filesystem.read(path)
    data = Yaml.parse(data)
    local noteCount = 0

    for _, note in ipairs(data["HitObjects"]) do
        noteCount = noteCount + 1
        table.insert(
            state.instance.data.hitObjects,
            UnspawnObject(note.StartTime, note.EndTime, note.Lane)
        )
    end

    for _, sv in ipairs(data["SliderVelocities"]) do
        table.insert(
            state.instance.data.scrollVelocities,
            {StartTime = sv.StartTime, Multiplier = sv.Multiplier or 0}
        )
    end
    
    state.instance.data.initialSV = data["InitialScrollVelocity"] or 1

    state.instance.data.song = love.sound.newSoundData(folderPath .. "/" .. data["AudioFile"])
    state.instance.data.mode = data.Mode:gsub("Keys", "")
    state.instance.data.mode = tonumber(state.instance.data.mode)
    state.instance.data.noteCount = noteCount
    state.instance.data.bgFile = folderPath .. "/" .. data["BackgroundFile"]
end

---@param data string
function Quaver:cache(data, filename, path)
    local pathToFile = path
    data = data:gsub("\r\n", "\n")

    data = data:gsub("SliderVelocities(.-)HitObjects", "HitObjects")
    data = Yaml.parse(data)

    local title = data["Title"] or "Unknown"
    local artist = data["Artist"] or "Unknown"
    local source = data["Source"] or "Unknown"
    local tags = data["Tags"] or "Unknown"
    local creator = data["Creator"] or "Unknown"
    local diff_name = data["DifficultyName"] or "Unknown"
    local description = data["Description"] or "Unknown"
    local filename = filename
    local audio_path = data["AudioFile"] or "Unknown"
    local preview_time = data["PreviewTime"] or 0
    local mapset_id = data["MapSetId"] or 0
    local map_id = data["MapId"] or 0
    local mode = data["Mode"]:gsub("Keys", "") or 4
    local bg_path = data["BackgroundFile"] or "Unknown"
    ---@diagnostic disable-next-line: cast-local-type
    mode = tonumber(mode)
    local game_mode = "Mania"
    local hitobj_count = 0
    local ln_count = 0
    local length = 0 -- found from hit objects
    local notes = {}
    local difficulty, nps = 0, 0

    for _, note in ipairs(data["HitObjects"]) do
        hitobj_count = hitobj_count + 1 -- jas StartTime and EndTime (can be nil)
        table.insert(notes, note)
        if note["EndTime"] then
            length = math.max(length, note["EndTime"] > (note["StartTime"] or 0) and note["EndTime"] or note["StartTime"] or 0)
            if note["EndTime"] or 0 > note["StartTime"] or 0 then
                ln_count = ln_count + 1
            end
        else
            length = math.max(length, note["StartTime"] or 0)
        end
    end

    difficulty, nps = DifficultyCalculator:calculate(notes, mode)

    local songData = {
        title = title,
        artist = artist,
        source = source,
        tags = tags,
        creator = creator,
        diff_name = diff_name,
        description = description,
        filename = filename,
        path = pathToFile,
        audio_path = audio_path,
        preview_time = preview_time,
        mapset_id = mapset_id,
        map_id = map_id,
        mode = mode,
        game_mode = game_mode,
        hitobj_count = hitobj_count,
        ln_count = ln_count,
        length = length,
        metaType = 4,
        map_type = "Quaver",
        bg_path = bg_path,
        difficulty = difficulty,
        nps = nps
    }

    SongCache:createCache(songData, filename, ".qua")

    return songData
end

return Quaver
