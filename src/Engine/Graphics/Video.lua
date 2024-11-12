local Video = Sprite:extend("Video")

function Video:new(video, x, y)
    Sprite.new(self, nil, x, y)
    if not DLL_Video then
        debug.warn("Video not supported on this platform")

        return self
    end

    if not video then return self, debug.warn("Video path not provided") end
    video = love.filesystem.newFileData(video)
    local vid = DLL_Video.open(video:getPointer(), video:getSize())
    if not vid then return self, debug.warn("Video not loaded") end

    self.video = vid
    self.filedata = video
    self.imageData = love.image.newImageData(self.video:getDimensions())
    self.image = love.graphics.newImage(self.imageData)

    self.baseWidth = self.image:getWidth()
    self.baseHeight = self.image:getHeight()

    self.playing = false
    self.time = 0
    self.previousFrameTime = 0
end

function Video:update(dt)
    Drawable.update(self, dt)

    if self.playing then
        self.time = self.time + dt
        tryExcept(function()
            while self.time >= self.video:tell() do
                if not self.video:read(self.imageData:getPointer()) then
                    self.playing = false
                    break
                end
            end
            self.image:replacePixels(self.imageData)
        end)
        self.previousFrameTime = love.timer.getTime()
    end
end

function Video:play()
    if not self.playing then
        self.playing = true
        self.previousFrameTime = love.timer.getTime()
    end
end

function Video:draw()
    if not self.visible or not self.image then return end
    love.graphics.push()
        love.graphics.setBlendMode(self.blendMode, self.blendModeAlpha)
        love.graphics.setColor(self.colour[1], self.colour[2], self.colour[3], self.alpha)
        
        -- determine new scale
        local sx, sy = self.scale.x * self.windowScale.x, self.scale.y * self.windowScale.y
        if self.forcedDimensions then
            sx = self.dimensions[1] / self.baseWidth * self.windowScale.x
            sy = self.dimensions[2] / self.baseHeight * self.windowScale.y
        end

        love.graphics.draw(self.image, self.drawX, self.drawY, math.rad(self.angle), sx, sy, self.origin.x, self.origin.y)

        if Game.objectDebug and self.debug then
            love.graphics.translate(self.drawX, self.drawY)
            love.graphics.rotate(math.rad(self.angle))
            love.graphics.translate(-self.drawX, -self.drawY)
            love.graphics.translate(-self.origin.x * self.windowScale.x * self.scale.x, -self.origin.y * self.windowScale.y * self.scale.y)
            self:__debugDraw()
        end
    love.graphics.pop()
end

return Video