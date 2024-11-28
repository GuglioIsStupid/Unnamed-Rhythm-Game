local Confusion = BaseModifier:extend()
Confusion.name = "Confusion"
Confusion.percents = {0} -- add more with each playfield
Confusion.submods = {}
Confusion.parent = nil
Confusion.active = false

function Confusion:updateNote(beat, note, pos, playfield)
    local playfield = playfield or 1
    note.angle = self:getValue(playfield) + self:getSubmodValue("Confusion" .. note.data, playfield) + 
        self:getSubmodValue("Note" .. note.data .. "Angle")
end

function Confusion:updateReceptor(beat, receptor, pos, playfield)
    receptor.angle = self:getValue(playfield) + self:getSubmodValue("Confusion" .. receptor.data, playfield) + 
    self:getSubmodValue("Receptor" .. receptor.data .. "Angle")
end

function Confusion:getSubmods()
    local subMods = {"NoteAngle", "ReceptorAngle"}

    for i = 1, states.game.Gameplay.mode do
        table.insert(subMods, "Note" .. i .. "Angle")
        table.insert(subMods, "Receptor" .. i .. "Angle")
        table.insert(subMods, "Confusion" .. i)
    end

    return subMods
end

return Confusion