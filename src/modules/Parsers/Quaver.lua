local quaverLoader = {}

function quaverLoader.load(chart, folderPath, forDiff)
    curChart = "Quaver"

    local chart = tinyyaml.parse(love.filesystem.read(chart):gsub("\r\n", "\n"))
    
    local meta = {
        format = "Quaver",
        title = chart.Title,
        artist = chart.Artist,
        source = chart.Source,
        tags = chart.Tags,
        name = chart.DifficultyName,
        creator = chart.Creator,
        audioPath = chart.AudioFile,
        backgroundFile = chart.BackgroundFile,
        previewTime = chart.PreviewTime or 0,
        noteCount = 0,
        length = 0,
        bpm = 0,
        inputMode = chart.Mode:gsub("Keys", ""),
    }
    states.game.Gameplay.mode = meta.inputMode

    --audioFile = love.audio.newSource(folderPath .. "/" .. meta.audioPath, "stream")
    --audioFile = love.audio.newSource(folderPath .. "/" .. meta.audioPath, "stream")
    states.game.Gameplay.soundManager:newSound("music", folderPath .. "/" .. meta.audioPath, 1, true, "stream")

    for i = 1, #chart.TimingPoints do
        -- if its the first one, set meta.bpm to the bpm of the first timing point
        local timingPoint = chart.TimingPoints[i]
        if i == 1 then
            meta.bpm = timingPoint.Bpm
            bpm = meta.bpm
            crochet = (60/bpm)*1000
            stepCrochet = crochet/4
        end
    end
    states.game.Gameplay.soundManager:setBPM("music", bpm)

    states.game.Gameplay.initialScrollVelocity = chart.InitialScrollVelocity or 1

    if love.filesystem.getInfo(folderPath .. "/" .. meta.backgroundFile) then
        states.game.Gameplay.background = love.graphics.newImage(folderPath .. "/" .. meta.backgroundFile)
    end

    for i = 1, #chart.SliderVelocities do
        local sliderVelocity = chart.SliderVelocities[i]
        local startTime = sliderVelocity.StartTime
        local multiplier = sliderVelocity.Multiplier
        if not startTime then goto continue end
        table.insert(states.game.Gameplay.sliderVelocities, {startTime = startTime, multiplier = multiplier or 0})
        ::continue::
    end

    for i = 1, #chart.HitObjects do
        local hitObject = chart.HitObjects[i]
        local startTime = hitObject.StartTime
        local endTime = hitObject.EndTime or 0
        local lane = hitObject.Lane

        if not startTime then goto continue end

        local ho = HitObject(startTime, lane, endTime)
        table.insert(states.game.Gameplay.unspawnNotes, ho)
        ::continue::
    end

    __title = meta.title
    __diffName = meta.name
end

return quaverLoader