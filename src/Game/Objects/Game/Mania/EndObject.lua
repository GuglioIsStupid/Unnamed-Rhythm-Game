---@diagnostic disable: need-check-nil
---@class EndObject : Sprite
local EndObject = Sprite:extend("EndObject")

function EndObject:new(endTime, lane, count, parent)
    if not Skin._noteAssets[count] then
        Skin._noteAssets[count] = Skin._noteAssets[1]
    end
    if not Skin._noteAssets[count][lane] then
        Skin._noteAssets[count][lane] = Skin._noteAssets[count][1]
    end
    Sprite.new(self, Skin._noteAssets[count][lane]["End"], 0, 0, false)
    self.parent = parent
    self:centerOrigin()

    self.endTime = endTime
end

function EndObject:update(dt) 
    Sprite.update(self, dt)
end

function EndObject:hit(time)
    debug.log("TODO: Finish EndObject:hit()")
end

return EndObject
