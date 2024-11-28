local Drunk = BaseModifier:extend()
Drunk.name = "Drunk"
Drunk.percents = {0} -- add more with each playfield
Drunk.submods = {}
Drunk.parent = nil
Drunk.active = false

function Drunk:updateNote(beat, note, pos, playfield)

end

function Drunk:updateReceptor(beat, receptor, pos, playfield)

end

function Drunk:getPos(time, visualDiff, timeDiff, beat, pos, data, playfield, obj)
    local drunkPerc = self:getValue(playfield) or 0
    local tipsyPerc = self:getSubmodValue("Tipsy", playfield)
    local bumpPerc = self:getSubmodValue("Bumpy", playfield)
    local tipZPerc = self:getSubmodValue("TipZ", playfield)

    local time = musicTime / 1000

    if drunkPerc ~= 0 then
        local speed = self:getSubmodValue("DrunkSpeed", playfield)
        local period = self:getSubmodValue("DrunkPeriod", playfield)
        local offset = self:getSubmodValue("DrunkOffset", playfield)

        local angle = time * (1 + speed) + data * ((offset * 0.2) + 0.2) + visualDiff * ((period * 10) + 10) / 1080
        pos.x = pos.x + drunkPerc * (math.cos(angle) * 100)
    end

    if tipsyPerc ~= 0 then
        local speed = self:getSubmodValue("TipsySpeed", playfield)
        local offset = self:getSubmodValue("TipsyOffset", playfield)

        pos.y = pos.y + tipsyPerc * (math.cos((time * ((speed * 1.2) + 1.2) + data * ((offset * 1.8) + 1.8))) * 80)
    end

    if tipZPerc ~= 0 then
        local speed = self:getSubmodValue("TipZSpeed", playfield)
        local offset = self:getSubmodValue("TipZOffset", playfield)

        pos.z = pos.z + tipZPerc * (math.cos((time * ((speed * 1.2) + 1.2) + data * ((offset * 1.8) + 3.2))) * 0.15)
    end

    if bumpPerc ~= 0 then
        local period = self:getSubmodValue("BumpyPeriod", playfield)
        local offset = self:getSubmodValue("BumpyOffset", playfield)
        local angle = (visualDiff + (100 * offset)) / ((period * 16) + 16)

        pos.z = pos.z + (bumpPerc * 40 * math.sin(angle)) / 250
    end

    return pos
end

function Drunk:getSubmods()
    return {
        "Tipsy",
        "Bumpy",
        "DrunkSpeed",
        "DrunkOffset",
        "DrunkPeriod",
        "TipsySpeed",
        "TipsyOffset",
        "BumpyOffset",
        "BumpyPeriod",

        "TipZ",
        "TipZSpeed",
        "TipZOffset",

        "DrunkZ",
        "DrunkZSpeed",
        "DrunkZOffset",
        "DrunkZPeriod"
    }
end

return Drunk