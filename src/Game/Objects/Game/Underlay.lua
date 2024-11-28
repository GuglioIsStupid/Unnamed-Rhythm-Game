local Underlay = Drawable:extend("Underlay")

function Underlay:new(receptorCount)
    self.count = receptorCount

    Drawable.new(self, 0, 0, 200*receptorCount, 1080*5) -- lol
    self.colour = {0, 0, 0}

    self.x = 1920/2 - self.baseWidth/2
end

function Underlay:updateCount(count, lastX, lastWidth)
    self.count = count
    self.width = lastX + lastWidth
    self.baseHeight = 3000
    self.height = 3000 * self.windowScale.y

    self.x = 1920/2 - self.baseWidth/2
end

return Underlay