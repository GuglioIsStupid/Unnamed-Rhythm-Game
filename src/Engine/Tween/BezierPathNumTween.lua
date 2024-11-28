---@class BezierPathNumTween : Tween
local BezierPathNumTween = Tween:extend("BezierPathNumTween")

function BezierPathNumTween:new(options, manager)
    Tween.new(self, options, manager)
    self._tweenFunction = function() end
    self._points = {}
    self.value = 0
end

function BezierPathNumTween:destroy()
    Tween.destroy(self)
    self._tweenFunction = nil
end

function BezierPathNumTween:tween(points, duration, tweenFunction)
    self._tweenFunction = tweenFunction
    self._points = points
    self.value = points[1]
    self.duration = duration
    self:start()

    return self
end

function BezierPathNumTween:update(dt)
    Tween.update(self, dt)
    local value = BezierPathNumTween:bezierPath(self.scale, self._points)
    
    if self._tweenFunction then
        ---@diagnostic disable-next-line: redundant-parameter
        self._tweenFunction(value)
    end
end

function BezierPathNumTween:bezierPath(t, points)
    local n = #points
    local curve = 0
    for i = 1, n do
        local c = 1
        for j = 1, n do
            if j ~= i then
                c = c *  (n - j) / (j + 1)
            end
        end

        curve = curve + c * math.pow(1 - t, n - 1) * math.pow(t, n - 1) * points[i]
    end

    return curve
end