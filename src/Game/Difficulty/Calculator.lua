local DifficultyCalculator = {}

-- VSRG Difficulty Calculator based off of note-density (and what Lane its in (Lane))

function DifficultyCalculator:calculate(notes, laneCount)
    local leftHand, rightHand = {}, {}
    local countForLeft = math.floor(laneCount/2)
    local countForRight = laneCount - countForLeft
    -- determine how many fingers are used for each hand
    local leftHandFingers = {}
    for i = 1, countForLeft do
        leftHandFingers[i] = {}
    end
    local rightHandFingers = {}
    for i = 1, countForRight do
        rightHandFingers[i] = {}
    end

    local scale = 3 * 1.8

    if not notes then return 0 end
    if #notes == 0 then return 0 end

    local firstTime = notes[1].StartTime or 0
    local lastTime = notes[#notes].StartTime or 0

    for i, note in ipairs(notes) do
        if not note.StartTime then
            note.StartTime = note.time or 0
        end
        note.Lane = note.Lane or note.lane or 1
        note.StartTime = (note.StartTime - firstTime) * 2
    end

    for i, note in ipairs(notes) do
        if note.Lane <= countForLeft then
            table.insert(leftHand, note)
        else
            table.insert(rightHand, note)
        end
    end

    for _, note in ipairs(leftHand) do
        table.insert(leftHandFingers[note.Lane], note)
    end

    for _, note in ipairs(rightHand) do
        if rightHandFingers[note.Lane - countForLeft] ~= nil then
            table.insert(rightHandFingers[note.Lane - countForLeft], note)
        end
    end

    local length = ((notes[#notes].StartTime / 1000) / 0.5)+1
    
    local segmentsOne = {}
    for i = 1, length do
        segmentsOne[i] = {}
    end

    local segmentsTwo = {}
    for i = 1, length do
        segmentsTwo[i] = {}
    end

    for _, note in ipairs(leftHand) do
        local index = math.floor((((note.StartTime*2) / 1000)))+1
        if index > length then
            goto continue
        end
        table.insert(segmentsOne[index], note)
        ::continue::
    end

    for _, note in ipairs(rightHand) do
        local index = math.floor((((note.StartTime*2) / 1000)))+1
        if index > length then
            goto continue
        end
        table.insert(segmentsTwo[index], note)
        ::continue::
    end

    local leftHandNPS = {}
    local rightHandNPS = {}

    for _, note in ipairs(segmentsOne) do
        table.insert(leftHandNPS, #note * scale * 1.6)
    end

    for _, note in ipairs(segmentsTwo) do
        table.insert(rightHandNPS, #note * scale * 1.6)
    end

    local leftHandDiff = {}
    local rightHandDiff = {}

    for i = 1, #segmentsOne do
        local ve = segmentsOne[i]
        local fys = {}

        for i = 1, countForLeft do
            fys[i] = {}
        end
        for _, note in ipairs(ve) do
            table.insert(fys[note.Lane], note)
        end

        local c = {}
        for j = 1, countForLeft do
            c[j] = self:calculateFinger(fys[j], leftHandFingers[j])
        end

        local bigf = 0
        for j = 1, countForLeft do
            if c[j] > bigf then
                bigf = c[j]
            end
        end

        bigf = ((bigf * 8) + (leftHandNPS[i] / scale) * 5) / 13 * scale
        
        table.insert(leftHandDiff, bigf)
    end

    for i = 1, #segmentsTwo do
        local ve = segmentsTwo[i]
        local fys = {}

        for i = 1, countForRight do
            fys[i] = {}
        end
        for _, note in ipairs(ve) do
            if fys[note.Lane - countForLeft] ~= nil then
                table.insert(fys[note.Lane - countForLeft], note)
            end
        end

        local c = {}
        for j = 1, countForRight do
            c[j] = self:calculateFinger(fys[j], rightHandFingers[j])
        end

        local bigf = 0
        for j = 1, countForRight do
            if c[j] > bigf then
                bigf = c[j]
            end
        end

        bigf = ((bigf * 8) + (rightHandNPS[i] / scale) * 5) / 13 * scale
        
        table.insert(rightHandDiff, bigf)
    end

    for _ = 1, laneCount do
        self:smooth(leftHandNPS, 0)
        self:smooth(rightHandNPS, 0)

        self:smoothen(leftHandDiff)
        self:smoothen(rightHandDiff)
    end

    local npsLeftPoint = {}
    local npsRightPoint = {}

    for _, note in ipairs(segmentsOne) do
        table.insert(npsLeftPoint, #note)
    end

    for _, note in ipairs(segmentsTwo) do
        table.insert(npsRightPoint, #note)
    end

    local maxPoints = 0

    for  _, i in ipairs(npsLeftPoint) do
        maxPoints = maxPoints + i
    end

    for _, i in ipairs(npsRightPoint) do
        maxPoints = maxPoints + i
    end

    local res = self:chisel(leftHandDiff, rightHandDiff, npsLeftPoint, npsRightPoint, maxPoints) * 5
    local nps = #notes / (lastTime / 1000)
    return res, nps
end

function DifficultyCalculator:chisel(leftHandDiff, rightHandDiff, npsLeftPoint, npsRightPoint, maxPoints)
    local lower = 0
    local upper = 100

    while (upper - lower > 0.01) do
        local average = (upper + lower) / 2
        local amtOfPoints = self:calculatePoint(average, leftHandDiff, npsLeftPoint) + self:calculatePoint(average, rightHandDiff, npsRightPoint)
        if (amtOfPoints / maxPoints < 0.935) then
            lower = average
        else
            upper = average
        end
    end

    return upper
end

function DifficultyCalculator:calculatePoint(mid, diff, points)
    local out = 0
    for i, diff in ipairs(diff) do
        if mid > diff then
            out = out + (points[i] or 0)
        else
            out = out + (points[i] or 0) * math.pow(mid / diff, 1.2)
        end
    end

    return out
end

function DifficultyCalculator:find(time, tbl)
    for i = 1, #tbl do
        if tbl[i] == time then
            return i
        end
    end

    return -1
end

function DifficultyCalculator:calculateFinger(notes, columns)
    local sum = 0
    if #notes == 0 then
        return 0
    end
    local start = self:find(notes[1].StartTime, columns)
    if start == -1 then 
        return 0
    end

    for _, _ in ipairs(notes) do
        sum = sum + (columns[start+1] or columns[start]) - columns[start]
        start = start + 1
    end

    if sum == 0 then
        return 0
    end

    return (1375 * (#notes)) / sum
end

function DifficultyCalculator:smooth(nps, start)
    local f1, f2 = start, start

    for i, res in ipairs(nps) do
        local chunk = f1
        f1 = f2
        f2 = res

        nps[i] = (chunk + f1 + f2) / 3
    end
end

function DifficultyCalculator:smoothen(diff)
    local z = 0

    for i, res in ipairs(diff) do
        local f = z
        z = res
        diff[i] = (f + z) / 2
    end
end

return DifficultyCalculator