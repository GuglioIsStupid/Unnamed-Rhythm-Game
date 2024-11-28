---@class BezierPathTween : Tween
local BezierPathTween = Tween:extend("BezierPathTween")

function BezierPathTween:new(Options, manager)
    Tween.new(self, Options, manager)
end

function BezierPathTween:tween(object, properties, duration)
    if object == nil then
        error("Cannot tween variables of an object that is nil.")
    elseif properties == nil then
        error("Cannot tween nil properties.")
    end

    self._object = object
    self._properties = properties
    self._propertyInfos = {}
    self.duration = duration
    self:start()
    self:initializeVars()
    return self
end

function BezierPathTween:update(dt)
    local delay = (self.executions > 0) and self.loopDelay or self.startDelay

    if self._secondsSinceStart < delay then
        Tween.update(self, dt)
    else
        if math.isNan(self._propertyInfos[1].startValue) then
            self:setStartValues()
        end

        Tween.update(self, dt)

        if self.active then
            for _, info in ipairs(self._propertyInfos) do
                if #info.points < 3 then
                    info.object[info.field] = info.startValue + info.range * self.scale
                else
                    info.object[info.field] = self:bezierPath(self.scale, info.points)
                end
            end
        end
    end
end

function BezierPathTween:initializeVars()
    local fieldPaths = {}
    if type(self._properties) == "table" then
        fieldPaths = self._properties
    else
        debug.warn("Invalid properties for BezierPathTween")
    end

    for _, fieldPath in ipairs(fieldPaths) do
        local target = self._object
        local path = fieldPath:split(".")
        local field = table.pop(path)
        for _, component in ipairs(path) do
            target = target[component]
        end
        local propFieldValues = self._properties[fieldPath]

        local arr = {
            object = target,
            field = field,
            startValue = math.nan,
            points = propFieldValues.points,
            range = propFieldValues[#propFieldValues]
        }

        table.insert(self._propertyInfos, arr)
    end
end

function BezierPathTween:setStartValues()
    for _, info in ipairs(self._propertyInfos) do
        if info.object[info.field] == nil then
            debug.warn('The object does not have the property "' .. info.field .. '"')
        end
        if math.isNan(info.points[1]) then
            local value = info.object[info.field]
            if math.isNan(value) then
                debug.warn('The property "' .. info.field .. '" is NaN')
            end
            info.startValue = value
            info.points[1] = value
            info.range = info.points[#info.points] - value
        else
            info.startValue = info.points[1]
            info.range = info.points[#info.points] - info.points[1]
        end
    end
end

function BezierPathTween:bezierPath(t, points)
    local n = #points
    local curve = 0

    for i = 1, n do
        local c = 1
        for j = 1, i do
            c = c * (n - j) / (j + 1)
        end

        curve = curve + c * math.pow(1 - t, n - i) * math.pow(t, i) * points[i]
    end

    return curve
end