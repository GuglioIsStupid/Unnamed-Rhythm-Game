---@diagnostic disable: need-check-nil
---@class HitObject : Sprite
local HitObject = Sprite:extend("HitObject")

function HitObject:new(data, count)
    if not Skin._noteAssets[count] then
        Skin._noteAssets[count] = Skin._noteAssets[1]
    end
    if not Skin._noteAssets[count][data.Lane] then
        Skin._noteAssets[count][data.Lane] = Skin._noteAssets[count][1]
    end
    Sprite.new(self, Skin._noteAssets[count][data.Lane]["Note"], 0, 0, false)

    self:centerOrigin()

    self.Data = data
    if data.EndTime ~= 0 and data.EndTime > data.StartTime then
        self.holdSprite = HoldObject(data.EndTime, data.Lane, count, self)
    end
    self.endY = data.EndTime
    self.moveWithScroll = true
end

function HitObject:update(dt)
    Sprite.update(self, dt)

    if self.holdSprite then
        self.holdSprite.x = self.x
        self.holdSprite.y = self.y + self.baseHeight/2

        self.holdSprite:update(dt, self.endY)
    end
end

function HitObject:hit(time)
    States.Screens.Game.instance.judgement:hit(time)

    if self.Data.Hitsounds ~= "" then
        if self.Data.Hitsounds:find("Whistle") then
            States.Screens.Game.instance.GameManager.whistleSound:clone():play()
        elseif self.Data.Hitsounds:find("Finish") then
            States.Screens.Game.instance.GameManager.finishSound:clone():play()
        elseif self.Data.Hitsounds:find("Clap") then
            States.Screens.Game.instance.GameManager.clapSound:clone():play()
        else
            States.Screens.Game.instance.GameManager.hitSound:clone():play()
        end
    end
end

function HitObject:resize(w, h)
    Sprite.resize(self, w, h)

    if self.holdSprite then
        self.holdSprite:resize(w, h)
    end
end

function HitObject:draw()
    if self.holdSprite then
        self.holdSprite:draw()
    end
    Sprite.draw(self)
end

return HitObject
