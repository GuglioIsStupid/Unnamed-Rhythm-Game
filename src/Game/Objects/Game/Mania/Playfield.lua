local Playfield = Group:extend("Playfield")

function Playfield:new(underlay, receptors)
    Group.new(self)

    self.notes = {}

    self:add(underlay)
    self:add(receptors)
end

function Playfield:add(obj)
    if obj:isInstanceOf(HitObject) then
        table.insert(self.notes, obj)
    end

    Group.add(self, obj)
end

function Playfield:remove(obj)
    if obj:isInstanceOf(HitObject) then
        for i, note in ipairs(self.notes) do
            if note == obj then
                table.remove(self.notes, i)
                break
            end
        end
    end

    Group.remove(self, obj)
end

return Playfield