local Move = BaseModifier:extend()
Move.name = "MoveX"
Move.percents = {0} -- add more with each playfield
Move.submods = {}
Move.parent = nil
Move.active = false

function Move:getPos(time, visualDiff, timeDiff, beat, pos, data, playfield, obj)
    local moveXPert = self:getValue(playfield)

    -- Define the boundaries
    local leftSide = -475
    local rightSide = 475

    local convertedPos = moveXPert * (rightSide - leftSide) / 2

    --[[ pos.x = pos.x + convertedPos ]]
    local p = states.game.Gameplay.playfields[playfield]
    p.offset.x = convertedPos

    return pos
end

function Move:getSubmods()
    local subMods = {"MoveY"}

    for i = 1, states.game.Gameplay.mode do
        table.insert(subMods, "AMove" .. i .. "X")
        table.insert(subMods, "AMove" .. i .. "Y")
    end

    return subMods
end

return Move