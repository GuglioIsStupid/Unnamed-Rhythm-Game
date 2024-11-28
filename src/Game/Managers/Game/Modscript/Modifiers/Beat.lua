local Beat = BaseModifier:extend()
Beat.name = "Beat"
Beat.percents = {0} -- add more with each playfield
Beat.submods = {}
Beat.parent = nil
Beat.active = false

local function scale(x, l1, h1, l2, h2)
    return ((x - l1) * (h2 - l2) / (h1 - l1) + l2)
end

function Beat:getPos(time, visualDiff, timeDiff, beat, pos, data, playfield, obj)
    if self:getValue(playfield) == 0 then return pos end

    local accelTime = 0.3
    local totalTime = 0.7

    local beat = states.game.Gameplay.soundManager:getDecBeat("music") + accelTime
    local evenBeat = beat % 2 ~= 0

    if beat < 0 then return pos end

    beat = beat - math.floor(beat) + 1
    beat = beat - math.floor(beat)
    if beat >= totalTime then return pos end

    local amount = 0
    if beat < accelTime then
        amount = scale(beat, 0, accelTime, 1, 0)
        amount = amount * amount
    else
        amount = scale(beat, accelTime, totalTime, 1, 0)
        amount = 1 - (1 - amount) * (1 - amount)
    end
    if evenBeat then amount = amount * -1 end

    local shift = 40 * amount * math.sin((visualDiff / 30) + math.pi)
    pos.x = pos.x + self:getValue(playfield) * shift

    return pos
end

return Beat