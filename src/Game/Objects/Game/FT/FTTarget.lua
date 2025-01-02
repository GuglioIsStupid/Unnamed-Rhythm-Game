---@diagnostic disable: need-check-nil
---@class FTTarget : Drawable
local FTTarget = Drawable:extend("FTTarget")

function FTTarget:new(data, instance)
    self.child = Drawable(0, 0, 25, 25)
    Drawable.new(self, 0, 0, 25, 25)
    self:centerOrigin()
    self.colour = {0.5, 0.5, 0.5, 1}
    self.type = "TARGET"
    self.instance = instance

    self.Data = data
    ---@diagnostic disable-next-line: inject-field
    self.Data.TFT = instance.currentTFT
    print(self.Data.TFT)

    local type = self.Data.Type
    if type == 0 or type == 4 or type == 8 or type == 18 then
        self.child.colour = {0, 1, 0, 1}
    elseif type == 1 or type == 5 or type == 0 or type == 19 then
        self.child.colour = {1, 0, 0, 1}
    elseif type == 2 or type == 6 or type == 10 or type == 20 then
        self.child.colour = {0, 0, 1, 1}
    elseif type == 3 or type == 7 or type == 11 or type == 21 then
        self.child.colour = {1, 0, 1, 1}
    elseif type == 12 then
        self.child.colour = {1, 0.5, 0, 1}
    elseif type == 13 then
        self.child.colour = {1, 0.5, 0.5, 1}
    elseif type == 15 then
        self.child.colour = {1, 0.5, 0, 1}
    elseif type == 16 then
        self.child.colour = {1, 0.5, 0.5, 1}
    end

    self.x, self.y = self.Data.X, self.Data.Y

    self.child.x = (self.x + math.sin((self.Data.Angle/1000) * math.pi / 180) * (self.Data.Distance/500))
    self.child.y = (self.y - math.cos((self.Data.Angle/1000) * math.pi / 180) * (self.Data.Distance/500))
    self.child.parent = self

    local distanceX = self.child.x - self.x
    local distanceY = self.child.y - self.y
    local duration = self.Data.TFT / 1000
    
    self.child.velocityX = distanceX / duration
    self.child.velocityY = distanceY / duration
    self.child.duration = duration

    self.hitTime = self.Data.StartTime + self.Data.TFT * 100
    self.shrinkTime = self.Data.StartTime + self.Data.TFT * 100 + self.Data.TS * 100
end

function FTTarget:update(dt)
    Drawable.update(self, dt)
    local instance = self.instance

    self.child.x = self.child.x - self.child.velocityX * dt
    self.child.y = self.child.y - self.child.velocityY * dt

    local elapsed = instance.musicTime - self.Data.StartTime
    local duration = self.hitTime - self.Data.StartTime

    if instance.musicTime > self.Data.StartTime then
        local remaining = self.shrinkTime - instance.musicTime
        local totalShrinkDuration = self.shrinkTime - self.hitTime

        local scale = math.max(0, remaining / totalShrinkDuration)
        scale = math.min(1, scale)

        self.child:setScale(scale, scale)

    end

    self.child:update(dt)
end

function FTTarget:resize(w, h)
    Drawable.resize(self, w, h)
    self.child:resize(w, h)
end

function FTTarget:draw()
    Drawable.draw(self)
    self.child:draw()
end

return FTTarget