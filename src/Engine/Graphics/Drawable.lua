---@class Drawable
local Drawable = Class:extend("Drawable")

---@param x number|nil
---@param y number|nil
---@param w number|nil
---@param h number|nil
function Drawable:new(x, y, w, h)
    -- a drawable is an object that rescales itself based on the screen size
    self.x = x or 0
    self.y = y or 0
    self.drawX = x
    self.drawY = y
    self.width = w or 1
    self.height = h or 1
    self.baseWidth = self.width
    self.baseHeight = self.height
    self.scale = {x = 1, y = 1}
    self.forcedDimensions = false
    self.dimensions = {w, h}
    self.rounding = 0
    self.roundingX = 0
    self.roundingY = 0

    self.blendMode = "alpha"
    self.blendModeAlpha = "alphamultiply"

    self.colour = {1, 1, 1}
    self.alpha = 1

    self.scalingType = ScalingTypes.ASPECT_FIXED

    self.windowScale = {x = 1, y = 1}
    self.angle = 0 -- 0-360, uses math.rad in runtime
    self.origin = {x = 0, y = 0}
    self.offset = {x = 0, y = 0}
    self.shear = {x = 0, y = 0}
    self.addOrigin = true

    self.visible = true

    self.zorder = 0
    self.debug = true

    self:resize(Game._windowWidth, Game._windowHeight)
end

function Drawable:getWidth()
    if self.forcedDimensions then
        return self.dimensions[1]
    end
    return self.baseWidth
end

function Drawable:getHeight()
    if self.forcedDimensions then
        return self.dimensions[2]
    end
    return self.baseHeight
end

function Drawable:centerOrigin()
    self.origin.x = self.baseWidth / 2
    self.origin.y = self.baseHeight / 2
    if self.threadedAsset then
        self.memoryCenterOrigin = true
    end
end

function Drawable:screenCenter(axes)
    if axes:find("X") then
        self.x = Game._gameWidth / 2 - self.baseWidth / 2
    end
    if axes:find("Y") then
        self.y = Game._gameHeight / 2 - self.baseHeight / 2
    end
end

function Drawable:update(dt)
    if self.scalingType ~= ScalingTypes.STRETCH and self.scalingType ~= ScalingTypes.WINDOW_STRETCH then
        local drawX, drawY = self.x, self.y

        drawX = drawX + self.offset.x
        drawY = drawY + self.offset.y

        if self.addOrigin then
            drawX = drawX + self.origin.x
            drawY = drawY + self.origin.y
        end

        self.drawX = Game._windowWidth * (drawX / Game._gameWidth)
        self.drawY = Game._windowHeight * (drawY / Game._gameHeight)
    end
end

---@param w number
---@param h number
function Drawable:resize(w, h)
    if self.scalingType == ScalingTypes.STRETCH then
        self.width = w
        self.height = h
        self.windowScale.x = w / self.baseWidth
        self.windowScale.y = h / self.baseHeight
    elseif self.scalingType == ScalingTypes.ASPECT_FIXED then
        local scale = math.min(w / Game._gameWidth, h / Game._gameHeight)
        self.windowScale.x, self.windowScale.y = scale, scale
        self.width = self.baseWidth * scale
        self.height = self.baseHeight * scale
    elseif self.scalingType == ScalingTypes.WINDOW_FIXED then
        local scale = math.min(w / self.baseWidth, h / self.baseHeight)
        self.windowScale.x, self.windowScale.y = scale, scale
        self.width = self.baseWidth * scale
        self.height = self.baseHeight * scale
    elseif self.scalingType == ScalingTypes.WINDOW_STRETCH then
        -- Stretches the image to the window size
        self.width = w
        self.height = h

        self.windowScale.x = w / self.baseWidth
        self.windowScale.y = h / self.baseHeight

        self.drawX = self.origin.x * self.windowScale.x
        self.drawY = self.origin.y * self.windowScale.y
    elseif self.scalingType == ScalingTypes.STRETCH_Y then
        self.width = w
        self.height = self.baseHeight * self.windowScale.y

        self.windowScale.x = w / self.baseWidth
        self.windowScale.y = h / self.baseHeight

        self.drawX = self.origin.x * self.windowScale.x
        self.drawY = self.origin.y * self.windowScale.y
    elseif self.scalingType == ScalingTypes.STRETCH_X then
        self.width = self.baseWidth * self.windowScale.x
        self.height = h

        self.windowScale.x = w / self.baseWidth
        self.windowScale.y = h / self.baseHeight

        self.drawX = self.origin.x * self.windowScale.x
        self.drawY = self.origin.y * self.windowScale.y
    elseif self.scalingType == ScalingTypes.WINDOW_LARGEST then
        local scale = math.max(w / self.baseWidth, h / self.baseHeight)
        self.windowScale.x, self.windowScale.y = scale, scale
        self.width = self.baseWidth * scale
        self.height = self.baseHeight * scale

        -- center the object to middle of the screen
        self.x = w / 2 - self.width / 2
        self.y = h / 2 - self.height / 2
    end

    if self.memoryCenterOrigin then
        self:centerOrigin()
        self.memoryCenterOrigin = false
    end
end

function Drawable:checkCollision(x, y, w, h)
    -- self.drawX - (self.origin.x * self.windowScale.x) -- this gets the real x of the object
    w, h = w or 1, h or 1
    local realX, realY = self.drawX - (self.origin.x * self.windowScale.x) - 15, self.drawY - (self.origin.y * self.windowScale.y) - 15
    local realEndX, realEndY = realX + self.width+30, realY + self.height+30
    return x >= realX and x <= realEndX and y >= realY and y <= realEndY
end

function Drawable:globalToLocal(x, y)
    -- converts mouse coords to game coords
    return (x - self.drawX) / self.windowScale.x, (y - self.drawY) / self.windowScale.y
end

function Drawable:draw()
    if not self.visible then return end
    love.graphics.push()
        local lastBlendMode, lastBlendModeAlpha = love.graphics.getBlendMode()
        local lastColour = {love.graphics.getColor()}
        -- we have to convert with love.graphics.rotate
        love.graphics.translate(self.drawX + self.width / 2, self.drawY + self.height / 2)
        love.graphics.shear(self.shear.x, self.shear.y)
        love.graphics.rotate(math.rad(self.angle))
        love.graphics.translate(-self.drawX - self.width / 2, -self.drawY - self.height / 2)

        love.graphics.setBlendMode(self.blendMode, self.blendModeAlpha)
        love.graphics.setColor(self.colour[1], self.colour[2], self.colour[3], self.alpha)

        love.graphics.rectangle("fill", self.drawX, self.drawY, self.width*self.scale.x, self.height*self.scale.y, self.roundingX + self.rounding, self.roundingY + self.rounding)

        love.graphics.setColor(lastColour)
        love.graphics.setBlendMode(lastBlendMode, lastBlendModeAlpha)

        if Game.objectDebug and self.debug then
            self:__debugDraw()
        end
    love.graphics.pop()
end

function Drawable:__debugDraw()
    love.graphics.push()
        love.graphics.setColor(1, 0, 0)
        love.graphics.rectangle("line", self.drawX, self.drawY, self.width*self.scale.x, self.height*self.scale.y)
        love.graphics.setColor(0, 0, 0)
        for x = -1, 1 do
            for y = -1, 1 do
                love.graphics.print("x: " .. math.floor(self.drawX - (self.origin.x * self.windowScale.x)) .. " y: " .. math.floor(self.drawY - (self.origin.y * self.windowScale.y)), self.drawX + x, self.drawY + y)
                love.graphics.print("w: " .. math.floor(self.width*self.scale.x) .. " h: " .. math.floor(self.height*self.scale.y), self.drawX + x, self.drawY + y + 10)
            end
        end
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("x: " .. math.floor(self.drawX - (self.origin.x * self.windowScale.x)) .. " y: " .. math.floor(self.drawY - (self.origin.y * self.windowScale.y)), self.drawX, self.drawY)
        love.graphics.print("w: " .. math.floor(self.width*self.scale.x) .. " h: " .. math.floor(self.height*self.scale.y), self.drawX, self.drawY + 10)
    love.graphics.pop()
end

function Drawable:move(x, y)
    self.x = x
    self.y = y
end

function Drawable:setScale(x, y)
    self.scale.x = x or 1
    self.scale.y = y or x or 1
end

function Drawable:destroy()
    self:kill()
end

function Drawable:kill()
    self = nil
end

return Drawable
