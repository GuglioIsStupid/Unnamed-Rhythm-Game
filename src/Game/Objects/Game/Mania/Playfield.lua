local Playfield = Group:extend("Playfield")

function Playfield:new(instance, underlay, receptors, x, y)
    Group.new(self)

    self.instance = instance
    self.notes = {}
    self.receptors = receptors

    self.x, self.y = x, y
    self.lanes = {}
    self.mods = {}
    self.offset = {x = 0, y = 0, scale = {x = 1, y = 1}}
    self.alpha = 1
    self.id = #instance.playfields + 1

    if not instance.hasModscript then
        self.underlay = underlay
    end
    self:add(self.receptors)
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

function Playfield:update(dt)
    Group.update(self, dt)
    for _, note in ipairs(self.notes) do
        note:update(dt)
    end
    for _, receptor in ipairs(self.receptors.objects) do
        receptor:update(dt)
    end
    if self.underlay then
        self.underlay:update(dt)
    end
end

function Playfield:resize(w, h)
    Group.resize(self, w, h)
    for _, note in ipairs(self.notes) do
        note:resize(w, h)
    end
    for _, receptor in ipairs(self.receptors.objects) do
        receptor:resize(w, h)
    end
    if self.underlay then
        self.underlay:resize(w, h)
    end
end

function Playfield:draw()
    if self.underlay then
        self.underlay:draw()
    end
    love.graphics.push()
        love.graphics.translate(Game._windowWidth/2, Game._windowHeight/2)
        love.graphics.scale(self.scale, self.scale)
        love.graphics.translate(-Game._windowWidth/2, -Game._windowHeight/2)

        love.graphics.push()
            for _, receptor in ipairs(self.receptors.objects) do
                if self.instance.hasModscript then
                    local pos = Script:getPos(0, 0, 0, self.instance.exactBeat, receptor.Lane, self.id, receptor, {})
                    Script:updateObject(self.instance.exactBeat, receptor, pos, self.id)
                    receptor.x, receptor.y = pos.x, pos.y
                    receptor:resize(Game._windowWidth, Game._windowHeight)
                    receptor.z = pos.z * 200
                end

                receptor:draw()
            end

            for _, note in ipairs(self.notes) do
                if self.instance.hasModscript then
                    if note.Data.StartTime - self.instance.musicTime > 15000 then
                        break
                    end
                    local vis = -((self.instance.musicTime - note.Data.StartTime) * SettingsManager:getSetting("Game", "ScrollSpeed"))
                    if not note.moveWithScroll then
                        vis = 0
                    end
                    local pos = Script:getPos(
                        note.Data.StartTime, vis, note.Data.StartTime - self.instance.musicTime,
                        self.instance.exactBeat, note.Data.Lane, self.id, note, {}, Vector2()
                    )
                    Script:updateObject(self.instance.exactBeat, note, pos, self.id)
                    note.x, note.y = pos.x, pos.y
                    note:resize(Game._windowWidth, Game._windowHeight)
                    note.z = pos.z * 200
                end

                note:draw()
            end
        love.graphics.pop()
    love.graphics.pop()
end

return Playfield