---@diagnostic disable: inject-field
local Vector3 = {}
local ffi = require("ffi")

ffi.cdef[[
typedef struct {
    float x;
    float y;
    float z;
} Vector3;
]]

function Vector3:new(x, y, z)
    local vec = ffi.new("Vector3")
    vec.x = x or 0
    vec.y = y or 0
    vec.z = z or 0
    local mt = setmetatable({
        x = vec.x,
        y = vec.y,
        z = vec.z
    }, Vector3)
    return mt
end

function Vector3:__add(other)
    if type(other) == "number" then
        return Vector3(self.x + other, self.y + other, self.z + other)
    else
        return Vector3(self.x + other.x, self.y + other.y, self.z + other.z)
    end
end

function Vector3:__sub(other)
    if type(other) == "number" then
        return Vector3(self.x - other, self.y - other, self.z - other)
    else
        return Vector3(self.x - other.x, self.y - other.y, self.z - other.z)
    end
end

function Vector3:__mul(other)
    if type(other) == "number" then
        return Vector3(self.x * other, self.y * other, self.z * other)
    else
        return Vector3(self.x * other.x, self.y * other.y, self.z * other.z)
    end
end

function Vector3:__div(other)
    if type(other) == "number" then
        return Vector3(self.x / other, self.y / other, self.z / other)
    else
        return Vector3(self.x / other.x, self.y / other.y, self.z / other.z)
    end
end

function Vector3:__eq(other)
    if type(other) == "number" then
        return self.x == other and self.y == other and self.z == other
    else
        return self.x == other.x and self.y == other.y and self.z == other.z
    end
end

function Vector3:__tostring()
    return "Vec3(" .. self.x .. ", " .. self.y .. ", " .. self.z .. ")"
end

function Vector3:__index(key)
    if key == "magnitude" then
        return math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z)
    elseif key == "normalized" then
        return self / self.magnitude
    end
end

function Vector3:dot(other)
    return self.x * other.x + self.y * other.y + self.z * other.z
end

function Vector3:cross(other)
    return Vector3(
        self.y * other.z - self.z * other.y,
        self.z * other.x - self.x * other.z,
        self.x * other.y - self.y * other.x
    )
end

function Vector3:angle(other)
    return math.acos(self:dot(other) / (self.magnitude * other.magnitude))
end

function Vector3:lerp(other, t)
    return self + (other - self) * t
end

function Vector3:rotate(angle, axis)
    local sinHalfAngle = math.sin(angle / 2)
    local cosHalfAngle = math.cos(angle / 2)

    local rX = axis.x * sinHalfAngle
    local rY = axis.y * sinHalfAngle
    local rZ = axis.z * sinHalfAngle
    local rW = cosHalfAngle

    local rotation = Quaternion(rX, rY, rZ, rW)
    local conjugate = rotation:conjugate()
    local w = rotation * self * conjugate

    return Vector3(w.x, w.y, w.z)
end

function Vector3:unpack()
    return self.x, self.y, self.z
end

setmetatable(Vector3, {
    __call = function(_, ...) return Vector3:new(...) end
})

return Vector3