---@diagnostic disable: need-check-nil
---@class HoldObject : VertexSprite
local HoldObject = VertexSprite:extend("HoldObject")

function HoldObject:new(endTime, lane, count, parent)
    if not Skin._noteAssets[count] then
        Skin._noteAssets[count] = Skin._noteAssets[1]
    end
    if not Skin._noteAssets[count][lane] then
        Skin._noteAssets[count][lane] = Skin._noteAssets[count][1]
    end
    VertexSprite.new(self, Skin._noteAssets[count][lane]["Hold"], 0, 0, 16)
    self.parent = parent
    self.child = EndObject(endTime, lane, count, self)
    self:centerOrigin()
    self.forcedDimensions = false

    self.endTime = endTime
    self.lane = lane
    self.length = 0
    self.currentY = self.y
end

function HoldObject:update(dt, endY)
    self.origin.y = 0

    local nendY = endY

    nendY = nendY + self.offset.y

    if self.addOrigin then
        nendY = nendY + self.origin.x
        nendY = nendY + self.origin.y
    end

    nendY = Game._windowHeight * (nendY / Game._gameHeight) + 100

    local scaleY = (nendY - self.parent.drawY - self.child.height) / self.height
    self.scale.y = scaleY

    if self.child then
        self.child.x = self.x
        self.child.y = endY + 125
        if self.child.flip.y then
            self.child.scale.y = -1
        end

        self.child:update(dt)
    end
    VertexSprite.update(self, dt)
end

function HoldObject:hit(time)
    debug.log("TODO: Finish HoldObject:hit()")
end

function HoldObject:resize(w, h)
    VertexSprite.resize(self, w, h)
    if not self.child then return end
    self.child:resize(w, h)
end

function HoldObject:draw()
    VertexSprite.draw(self)
    if not self.child then return end
    self.child:draw()
end

return HoldObject
