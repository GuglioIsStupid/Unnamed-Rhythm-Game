local Playfield = Group:extend("Playfield")

function Playfield:new(underlay, receptors)
    Group.new(self)

    self:add(underlay)
    self:add(receptors)
end

return Playfield