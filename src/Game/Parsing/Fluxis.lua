local Fluxis = {}

local state = States.Screens.Game

function Fluxis:parse(path, folderPath)
    local data = love.filesystem.read(path)
    data = Json.decode(data)

    local noteCount = 0

    local hitObjects = data["hitObjects"] or data["HitObjects"]

    local mode = 4

    for _, note in ipairs(hitObjects) do
        noteCount = noteCount + 1
        table.insert(
            state.instance.data.hitObjects,
            UnspawnObject(note.time, note.time + (note.holdtime or 0), note.lane)
        )
        mode = math.max(mode, note.lane)
    end

    --[[ for _, sv in ipairs(data["scrollVelocities"] or data["ScrollVelocities"]) do
        table.insert(
            state.instance.data.scrollVelocities,
            {startTime = sv.time, multiplier = sv.multiplier or 0}
        )
    end ]]

    state.instance.data.song = love.sound.newSoundData(folderPath .. "/" .. (data["audioFile"] or data["AudioFile"]))
    state.instance.data.mode = mode
    state.instance.data.noteCount = noteCount
    state.instance.data.bgFile = folderPath .. "/" .. (data["backgroundFile"] or data["BackgroundFile"] or "")
end

function Fluxis:cache(data, filename, path)
    data = Json.decode(data)

    local meta = data["metadata"] or data["Metadata"]

    local title = meta["title"] or meta["Title"] or "Unknown"
    local artist = meta["artist"] or meta["Artist"] or "Unknown"
    local source = meta["source"] or meta["Source"] or "Unknown"
    local tags = meta["tags"] or meta["Tags"] or "Unknown"
    local creator = meta["mapper"] or meta["Mapper"] or "Unknown"
    local diff_name = meta["difficulty"] or meta["Difficulty"] or "Unknown"
    local preview_time = meta["preview"] or meta["PreviewTime"] or 0

    local audioPath = data["audioFile"] or data["AudioFile"] or "Unknown"

    local mode = 4 -- kinda irelevant for fluxis....

    local game_mode = "Mania"
    local hitobj_count = 0
    local ln_count = 0
    local length = 0
    local notes = {}
    local difficulty, nps = 0, 0

    local hitObjects = data["hitObjects"] or data["HitObjects"]

    for _, note in ipairs(hitObjects) do
        hitobj_count = hitobj_count + 1
        mode = math.max(mode, note["lane"] or 4)

        local type = note["type"] or 0
        if type ~= 0 then
            goto continue
        end

        table.insert(notes, note)
        if note["endTime"] then
            length = math.max(length, note["time"] + note["holdtime"])
        else
            length = math.max(length, note["time"])
        end

        ::continue::
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
        map_type = "Fluxis",
        bg_path = "Unknown",
        difficulty = difficulty,
        nps = nps
    }

    return songData
end

return Fluxis