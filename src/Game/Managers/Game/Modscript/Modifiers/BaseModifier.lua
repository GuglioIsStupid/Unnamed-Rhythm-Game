local Modifier = Class:extend("Modifier")
Modifier.name = "Base"
Modifier.percents = {0} -- add more with each playfield
Modifier.submods = {}
Modifier.parent = nil
Modifier.active = false
Modifier.type = "Mod"

function Modifier:new(parent)
    self.percents = {0} -- add more with each playfield
    self.submods = {}
    self.parent = nil
    self.active = false
    self.parent = parent
    for _, submod in ipairs(self:getSubmods()) do
        self.submods[submod] = BaseSubModifier(submod, self)
    end
end

function Modifier:getOrder()
    return 1
end

function Modifier:getValue(playfield)
    local playfield = playfield or 1
    if self.percents[playfield] == nil then self.percents[playfield] = 0 end
    return self.percents[playfield]
end

function Modifier:getPercent(playfield)
    if not self.percents[playfield] then self.percents[playfield] = 0 end
    return self.percents[playfield] * 100
end

function Modifier:setValue(value, playfield)
    if playfield < 1 then
        -- do all of them
        for i = 1, #self.percents do
            self.percents[i] = value
        end
    else
        if not self.percents[playfield] then self.percents[playfield] = 0 end
        self.percents[playfield] = value
    end
end

function Modifier:setPercent(percent, playfield)
    self:setValue(percent * 0.01, playfield)
end

function Modifier:getSubmods()
    return {}
end

function Modifier:getSubmodPercent(modName, playfield)
    if self.submods[modName] then
        return self.submods[modName]:getPercent(playfield)
    end

    return 0
end

function Modifier:getSubmodValue(modName, playfield)
    if self.submods[modName] then
        return self.submods[modName]:getValue(playfield)
    end

    return 0
end

function Modifier:setSubmodPercent(modName, endPercent, playfield)
    if self.submods[modName] then
        self.submods[modName]:setPercent(endPercent, playfield)
    end
end

function Modifier:setSubmodValue(modName, endValue, playfield)
    if self.submods[modName] then
        self.submods[modName]:setValue(endValue, playfield)
    end
end

function Modifier:updateReceptor()
end

function Modifier:updateNote()
end

function Modifier:getPos(time, visualDiff, timeDiff, beat, pos, data, playfield, obj)
    return pos
end

function Modifier:update()
end

return Modifier