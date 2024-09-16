---@class Drawable
local Drawable = Class:extend("Drawable")

---@param x number
---@param y number
---@param w number
---@param h number
function Drawable:new(x, y, w, h)
    -- a drawable is an object that rescales itself based on the screen size

    self.x = x
    self.y = y 
    self.drawX = x
    self.drawY = y
    self.width = w
    self.height = h
    self.baseWidth = w
    self.baseHeight = h
    self.scale = {x = 1, y = 1}

    self.blendMode = "alpha"
    self.blendModeAlpha = "alphamultiply"

    self.colour = {1, 1, 1}
    self.alpha = 1

    self.scalingType = ScalingTypes.ASPECT_FIXED

    self.windowScale = {x = 1, y = 1}
    self.angle = 0 -- 0-360, uses math.rad in runtime
    self.origin = {x = 0, y = 0}
    self.offset = {x = 0, y = 0}
    self.addOrigin = true

    self:resize(Game._windowWidth, Game._windowHeight)
end

function Drawable:centerOrigin()
    self.origin.x = self.width / 2
    self.origin.y = self.height / 2
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
    end
end

function Drawable:draw()
    love.graphics.push()
        local lastBlendMode, lastBlendModeAlpha = love.graphics.getBlendMode()
        local lastColour = {love.graphics.getColor()}
        -- we have to convert with love.graphics.rotate
        love.graphics.translate(self.drawX + self.width / 2, self.drawY + self.height / 2)
        love.graphics.rotate(math.rad(self.angle))
        love.graphics.translate(-self.drawX - self.width / 2, -self.drawY - self.height / 2)
        love.graphics.setBlendMode(self.blendMode, self.blendModeAlpha)
        love.graphics.setColor(self.colour[1], self.colour[2], self.colour[3], self.alpha)

        love.graphics.rectangle("fill", self.drawX, self.drawY, self.width, self.height)

        love.graphics.setColor(lastColour)
        love.graphics.setBlendMode(lastBlendMode, lastBlendModeAlpha)

        if Game.debug then
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
                love.graphics.print("x: " .. math.floor(self.drawX) .. " y: " .. math.floor(self.drawY), self.drawX + x, self.drawY + y)
                love.graphics.print("w: " .. math.floor(self.width*self.scale.x) .. " h: " .. math.floor(self.height*self.scale.y), self.drawX + x, self.drawY + y + 10)
            end
        end
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("x: " .. math.floor(self.drawX) .. " y: " .. math.floor(self.drawY), self.drawX, self.drawY)
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