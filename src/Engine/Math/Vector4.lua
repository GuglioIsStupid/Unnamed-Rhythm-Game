---@diagnostic disable: inject-field
local Vector4 = {}
local ffi = require("ffi")

ffi.cdef[[
typedef struct {
    float x;
    float y;
    float z;
    float w;
} Vector4;
]]

function Vector4:new(x, y, z, w)
    local vec = ffi.new("Vector4")
    vec.x = x or 0
    vec.y = y or 0
    vec.z = z or 0
    vec.w = w or 0
    local mt = setmetatable({
        x = vec.x,
        y = vec.y,
        z = vec.z,
        w = vec.w
    }, Vector4)
    return mt
end

function Vector4:__add(other)
    if type(other) == "number" then
        return Vector4(self.x + other, self.y + other, self.z + other, self.w + other)
    else
        return Vector4(self.x + other.x, self.y + other.y, self.z + other.z, self.w + other.w)
    end
end

function Vector4:__sub(other)
    if type(other) == "number" then
        return Vector4(self.x - other, self.y - other, self.z - other, self.w - other)
    else
        return Vector4(self.x - other.x, self.y - other.y, self.z - other.z, self.w - other.w)
    end
end

function Vector4:__mul(other)
    if type(other) == "number" then
        return Vector4(self.x * other, self.y * other, self.z * other, self.w * other)
    else
        return Vector4(self.x * other.x, self.y * other.y, self.z * other.z, self.w * other.w)
    end
end

function Vector4:__div(other)
    if type(other) == "number" then
        return Vector4(self.x / other, self.y / other, self.z / other, self.w / other)
    else
        return Vector4(self.x / other.x, self.y / other.y, self.z / other.z, self.w / other.w)
    end
end

function Vector4:__eq(other)
    if type(other) == "number" then
        return self.x == other and self.y == other and self.z == other and self.w == other
    else
        return self.x == other.x and self.y == other.y and self.z == other.z and self.w == other.w
    end
end

function Vector4:__tostring()
    return "Vec4(" .. self.x .. ", " .. self.y .. ", " .. self.z .. ", " .. self.w .. ")"
end

function Vector4:dot(other)
    return self.x * other.x + self.y * other.y + self.z * other.z + self.w * other.w
end

function Vector4:cross(other)
    local x = self.y * other.z - self.z * other.y
    local y = self.z * other.x - self.x * other.z
    local z = self.x * other.y - self.y * other.x
    local w = 0 
    return Vector4(x, y, z, w)
end

function Vector4:angle(other)
    local dot = self:dot(other)
    return math.acos(dot / (self:length() * other:length()))
end

function Vector4:lerp(other, alpha)
    return self * (1 - alpha) + other * alpha
end

function Vector4:rotate(angle)
    local x = self.x * math.cos(angle) - self.y * math.sin(angle)
    local y = self.x * math.sin(angle) + self.y * math.cos(angle)
    local z = self.z * math.cos(angle) - self.w * math.sin(angle)
    local w = self.z * math.sin(angle) + self.w * math.cos(angle)
    return Vector4(x, y, z, w)
end

function Vector4:unpack()
    return self.x, self.y, self.z, self.w
end

setmetatable(Vector4, {
    __call = function(_, ...) return Vector4:new(...) end
})

return Vector4