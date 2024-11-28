---@diagnostic disable: inject-field
local Vector2 = {}
local ffi = require("ffi")

ffi.cdef[[
typedef struct {
    float x;
    float y;
} Vector2;
]]

function Vector2:new(x, y)
    local vec = ffi.new("Vector2")
    vec.x = x or 0
    vec.y = y or 0
    local mt = setmetatable({
        x = vec.x,
        y = vec.y
    }, Vector2)
    return mt
end

function Vector2:__add(other)
    if type(other) == "number" then
        return Vector2(self.x + other, self.y + other)
    else
        return Vector2(self.x + other.x, self.y + other.y)
    end
end

function Vector2:__sub(other)
    if type(other) == "number" then
        return Vector2(self.x - other, self.y - other)
    else
        return Vector2(self.x - other.x, self.y - other.y)
    end
end

function Vector2:__mul(other)
    if type(other) == "number" then
        return Vector2(self.x * other, self.y * other)
    else
        return Vector2(self.x * other.x, self.y * other.y)
    end
end

function Vector2:__div(other)
    if type(other) == "number" then
        return Vector2(self.x / other, self.y / other)
    else
        return Vector2(self.x / other.x, self.y / other.y)
    end
end

function Vector2:__eq(other)
    if type(other) == "number" then
        return self.x == other and self.y == other
    else
        return self.x == other.x and self.y == other.y
    end
end

function Vector2:__tostring()
    return "Vec2(" .. self.x .. ", " .. self.y .. ")"
end

function Vector2:__index(key)
    if key == "magnitude" then
        return math.sqrt(self.x * self.x + self.y * self.y)
    elseif key == "normalized" then
        return self / self.magnitude
    end
end

function Vector2:dot(other)
    return self.x * other.x + self.y * other.y
end

function Vector2:cross(other)
    return self.x * other.y - self.y * other.x
end

function Vector2:angle(other)
    return math.acos(self:dot(other) / (self.magnitude * other.magnitude))
end

function Vector2:lerp(other, alpha)
    return self * (1 - alpha) + other * alpha
end

function Vector2:rotate(angle)
    local x = self.x * math.cos(angle) - self.y * math.sin(angle)
    local y = self.x * math.sin(angle) + self.y * math.cos(angle)
    return Vector2(x, y)
end

function Vector2:unpack()
    return self.x, self.y
end


setmetatable(Vector2, {
    __call = function(_, ...) return Vector2:new(...) end
})

return Vector2