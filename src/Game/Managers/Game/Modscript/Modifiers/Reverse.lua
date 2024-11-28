local Reverse = BaseModifier:extend()
Reverse.name = "Reverse"
Reverse.percents = {0} -- add more with each playfield
Reverse.submods = {}
Reverse.parent = nil
Reverse.active = false

local function scale(x, l1, h1, l2, h2)
    return ((x - l1) * (h2 - l2) / (h1 - l1) + l2)
end

function Reverse:getReverseValue(dir, playfield)
    local suffix = ""
    local receptors = States.Screens.Game.instance.GameManager.receptorsGroup
    local kNum = #States.Screens.Game.instance.GameManager.receptorsGroup.objects
    local val = 0

    if dir > kNum/2 then
        val = val - self:getSubmodValue("Split", playfield)
    end

    if dir % 2 == 0 then
        val = val + self:getSubmodValue("Alternate", playfield)
    end

    val = val + self:getValue(playfield) + self:getSubmodValue("Reverse" .. dir, playfield)
    
    return val
end

function Reverse:getPos(time, visualDiff, timeDiff, beat, pos, data, playfield, obj)
    local perc = self:getReverseValue(data, playfield)
    local shift = scale(perc, 0, 1, 50, 825)
    local mult = scale(perc, 0, 1, 1, -1)
    shift = scale(self:getSubmodValue("Centered", playfield), 0, 1, shift, 1080/2 - 100)

    pos.y = shift + (visualDiff * mult)

    return pos
end

function Reverse:getSubmods()
    local subMods = {"Cross", "Split", "Alternate", "ReverseScroll", "CrossScroll", "SplitScroll", "AlternateScroll", "Centered", "UnboundedReverse"}

    for i = 1, #States.Screens.Game.instance.GameManager.receptorsGroup.objects do
        table.insert(subMods, "Reverse" .. i)
    end

    return subMods
end

return Reverse