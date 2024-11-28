local Transform = BaseModifier:extend()
Transform.name = "Transform"
Transform.percents = {0} -- add more with each playfield
Transform.submods = {}
Transform.parent = nil
Transform.active = false

function Transform:getPos(time, visualDiff, timeDiff, beat, pos, data, playfield, obj)
    pos.x = pos.x + self:getValue(playfield) + self:getSubmodValue("transformX-a", playfield)
    pos.y = pos.y + self:getSubmodValue("TransformY", playfield) + self:getSubmodValue("TransformY-a", playfield)
    pos.z = pos.z + self:getSubmodValue("TransformZ", playfield) + self:getSubmodValue("TransformZ-a", playfield)

    pos.x = pos.x + self:getSubmodValue("Transform" .. data .. "X", playfield) + self:getSubmodValue("Transform" .. data .. "X-a", playfield)
    pos.y = pos.y + self:getSubmodValue("Transform" .. data .. "Y", playfield) + self:getSubmodValue("Transform" .. data .. "Y-a", playfield)
    pos.z = pos.z + self:getSubmodValue("Transform" .. data .. "Z", playfield) + self:getSubmodValue("Transform" .. data .. "Z-a", playfield)

    return pos
end

function Transform:getSubmods()
    local subMods = {"TransformY", "TransformZ", "TransformX-a", "TransformY-a", "TransformZ-a"}

    for i = 1, states.game.Gameplay.mode do
        table.insert(subMods, "Transform" .. i .. "X")
        table.insert(subMods, "Transform" .. i .. "Y")
        table.insert(subMods, "Transform" .. i .. "Z")
        table.insert(subMods, "Transform" .. i .. "X-a")
        table.insert(subMods, "Transform" .. i .. "Y-a")
        table.insert(subMods, "Transform" .. i .. "Z-a")
    end

    return subMods
end

return Transform