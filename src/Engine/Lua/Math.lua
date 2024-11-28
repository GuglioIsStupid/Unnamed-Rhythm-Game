function math.lerp(a, b, t)
    return a + (b - a) * t
end

function math.fpsLerp(a, b, t, dt)
    return a + (b - a) * (1 - math.exp(-t * dt))
end

function math.inverseLerp(a, b, x)
    return (x - a) / (b - a)
end

function math.remap(x, a, b, c, d)
    return c + (d - c) * (x - a) / (b - a)
end

function math.remapClamped(x, a, b, c, d)
    return math.clamp(math.remap(x, a, b, c, d), math.min(c, d), math.max(c, d))
end

function math.distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

function math.angle(x1, y1, x2, y2)
    return math.atan2(y2 - y1, x2 - x1)
end

function math.clamp(x, min, max)
    return x < min and min or (x > max and max or x)
end

function math.sign(x)
    return x > 0 and 1 or (x < 0 and -1 or 0)
end

function math.round(x)
    return math.floor(x + 0.5)
end

function math.roundTo(x, n)
    return math.floor(x / n + 0.5) * n
end

local storageUnit = {
    B = 1,
    KB = 1024,
    MB = 1024^2,
    GB = 1024^3,
    TB = 1024^4,
    PB = 1024^5,
    EB = 1024^6,
    ZB = 1024^7,
    YB = 1024^8
}

function math.formatStorage(size)
    size = tonumber(size or 0) or 0
    -- automatically choose the best unit
    local unit = "B"
    local unitSize = storageUnit[unit] or 1
    while (size or 0) >= 1024 and (unitSize or 1) < storageUnit.YB do
        size = size / 1024
        unit = next(storageUnit, unit)
        unitSize = storageUnit[unit]
    end

    return string.format("%.2f %s", size, unit)
end

function math.isNan(x)
    return tostring(x) == "nan"
end

function math.isInf(x)
    return tostring(x) == "inf" or tostring(x) == "-inf"
end

math.nan = 0 / 0
math.inf = 1 / 0