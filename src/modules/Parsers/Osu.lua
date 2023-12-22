local osuLoader = {}
local currentBlockName = ""
local folderPath

function osuLoader.load(chart, folderPath_, forDiff)
    curChart = "osu!"
    folderPath = folderPath_

    local chart = love.filesystem.read(chart)
    bpm = 120
    crochet = (60/bpm)*1000
    stepCrochet = crochet/4

    for _, line in ipairs(chart:split("\n")) do
        osuLoader.processLine(line)
    end
end

function osuLoader.processLine(line)
    if line:find("^%[") then
        local _currentBlockName, lineEnd = line:match("^%[(.+)%](.*)$")
        currentBlockName = _currentBlockName
        osuLoader.processLine(lineEnd)
    else
        local currentBlockName = currentBlockName:trim()
        local trimmed = line:trim()
        if trimmed == "" then
            -- empty line
        elseif currentBlockName == "General" then
            osuLoader.processGeneral(line)
        elseif currentBlockName == "Events" then
            -- events
        elseif currentBlockName == "TimingPoints" then
            osuLoader.addTimingPoint(line)
        elseif currentBlockName == "HitObjects" then
            osuLoader.addHitObject(line)
        elseif currentBlockName == "Metadata" then
            osuLoader.processMetadata(line)
        elseif currentBlockName == "Difficulty" then
            osuLoader.processDifficulty(line)
        end
    end
end

function osuLoader.processDifficulty(line)
    local key, value = line:match("^(%a+):%s?(.*)")
    if key == "CircleSize" then
        states.game.Gameplay.mode = tonumber(value)
    end
end

function osuLoader.processGeneral(line)
    local key, value = line:match("^(%a+):%s?(.*)")
    if key == "AudioFilename" then
        local value = value:trim()
        --audioFile = love.audio.newSource(folderPath .. "/" .. value, "stream")
        states.game.Gameplay.soundManager:newSound("music", folderPath .. "/" .. value, 1, true, "stream")
    end
end
function osuLoader.addTimingPoint(line)
    local split = line:split(",")
    local tp = {}

    tp.offset = tonumber(split[1]) or 0
    tp.beatLength = tonumber(split[2]) or 0
    tp.timingSignature = math.max(0, math.min(8, tonumber(split[3]) or 4)) or 4
    tp.sampleSetId = tonumber(split[4]) or 0
    tp.customSampleIndex = tonumber(split[5]) or 0
    tp.sampleVolume = tonumber(split[6]) or 0
    tp.timingChange = tonumber(split[7]) or 1
    tp.kiaiTimeActive = tonumber(split[8]) or 0

    if tp.timingSignature == 0 then
        tp.timingSignature = 4
    end

    if tp.beatLength >= 0 then
        -- beat shit
    else -- slider velocity (what we care about)
        tp.velocity = math.min(math.max(0.1, math.abs(-100 / tp.beatLength)), 10)
    end

    if tp.velocity then
        local velocity = {
            startTime = tp.offset,
            multiplier = tp.velocity
        }
        table.insert(states.game.Gameplay.sliderVelocities, velocity)
    end
end
function osuLoader.processMetadata(line)
    local key, value = line:match("^(%a+):%s?(.*)")
    if key == "Title" then
        __title = value
    elseif key == "Artist" then
        __artist = value
    elseif key == "Creator" then
        __creator = value
    elseif key == "Version" then
        __diffName = value
    end
end

function osuLoader.addHitObject(line)
    local split = line:split(",")
    local note = {}
    local addition
    note.x = tonumber(split[1]) or 0
    note.y = tonumber(split[2]) or 0
    note.startTime = tonumber(split[3]) or 0
    note.data = math.max(1, math.min(states.game.Gameplay.mode, math.floor(note.x/512*states.game.Gameplay.mode+1))) or 1

    if split[6] then
        note.endTime = tonumber(split[6]:split(":")[1]) or 0
    end

    local ho = HitObject(note.startTime, note.data, note.endTime)
    table.insert(states.game.Gameplay.unspawnNotes, ho)
end

return osuLoader