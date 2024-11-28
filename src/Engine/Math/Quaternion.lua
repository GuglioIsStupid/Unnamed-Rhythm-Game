---@diagnostic disable: inject-field
local Quaternion = {}
local ffi = require("ffi")

ffi.cdef[[
typedef struct {
    float x;
    float y;
    float z;
    float w;
} Quaternion;
]]

function Quaternion:new(x, y, z, w)
    local quat = ffi.new("Quaternion")
    quat.x = x or 0
    quat.y = y or 0
    quat.z = z or 0
    quat.w = w or 0
    local mt = setmetatable({
        x = quat.x,
        y = quat.y,
        z = quat.z,
        w = quat.w
    }, Quaternion)
    return mt
end

function Quaternion:__add(other)
    if type(other) == "number" then
        return Quaternion(self.x + other, self.y + other, self.z + other, self.w + other)
    else
        return Quaternion(self.x + other.x, self.y + other.y, self.z + other.z, self.w + other.w)
    end
end

function Quaternion:__sub(other)
    if type(other) == "number" then
        return Quaternion(self.x - other, self.y - other, self.z - other, self.w - other)
    else
        return Quaternion(self.x - other.x, self.y - other.y, self.z - other.z, self.w - other.w)
    end
end

function Quaternion:__mul(other)
    if type(other) == "number" then
        return Quaternion(self.x * other, self.y * other, self.z * other, self.w * other)
    else
        local x = self.w * other.x + self.x * other.w + self.y * other.z - self.z * other.y
        local y = self.w * other.y - self.x * other.z + self.y * other.w + self.z * other.x
        local z = self.w * other.z + self.x * other.y - self.y * other.x + self.z * other.w
        local w = self.w * other.w - self.x * other.x - self.y * other.y - self.z * other.z
        return Quaternion(x, y, z, w)
    end
end

function Quaternion:__div(other)
    if type(other) == "number" then
        return Quaternion(self.x / other, self.y / other, self.z / other, self.w / other)
    else
        return self * other:inverse()
    end
end

function Quaternion:__eq(other)
    return self.x == other.x and self.y == other.y and self.z == other.z and self.w == other.w
end

function Quaternion:__tostring()
    return "Quat(" .. self.x .. ", " .. self.y .. ", " .. self.z .. ", " .. self.w .. ")"
end

function Quaternion:__index(key)
    if key == "magnitude" then
        return math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z + self.w * self.w)
    elseif key == "normalized" then
        return self / self.magnitude
    end
end

function Quaternion:conjugate()
    return Quaternion(-self.x, -self.y, -self.z, self.w)
end

function Quaternion:inverse()
    return self:conjugate() / (self.magnitude * self.magnitude)
end

function Quaternion:dot(other)
    return self.x * other.x + self.y * other.y + self.z * other.z + self.w * other.w
end

function Quaternion:fromEuler(x, y, z)
    local c1 = math.cos(x / 2)
    local c2 = math.cos(y / 2)
    local c3 = math.cos(z / 2)
    local s1 = math.sin(x / 2)
    local s2 = math.sin(y / 2)
    local s3 = math.sin(z / 2)

    local x = s1 * c2 * c3 + c1 * s2 * s3
    local y = c1 * s2 * c3 - s1 * c2 * s3
    local z = c1 * c2 * s3 + s1 * s2 * c3
    local w = c1 * c2 * c3 - s1 * s2 * s3

    return Quaternion(x, y, z, w)
end

function Quaternion:toEuler()
    local x = math.atan2(2 * (self.w * self.x + self.y * self.z), 1 - 2 * (self.x * self.x + self.y * self.y))
    local y = math.asin(2 * (self.w * self.y - self.z * self.x))
    local z = math.atan2(2 * (self.w * self.z + self.x * self.y), 1 - 2 * (self.y * self.y + self.z * self.z))

    return x, y, z
end

setmetatable(Quaternion, {
    __call = function(_, ...) return Quaternion:new(...) end
})

return Quaternion