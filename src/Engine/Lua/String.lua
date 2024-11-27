function string:split(sep)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    self:gsub(pattern, function(c) fields[#fields + 1] = c end)
    return fields
end

function string:trim()
    return self:match("^%s*(.-)%s*$")
end

function string:startsWith(str)
    return self:sub(1, #str) == str
end

function string:endsWith(str)
    return self:sub(-#str) == str
end

function string:contains(str)
    return self:find(str) ~= nil
end

function string:toNumber()
    return tonumber(self)
end

function string:toBoolean()
    return self:lower() == "true"
end

function string:__tostring()
    return self
end

function string:capitalize()
    return self:sub(1, 1):upper()..self:sub(2)
end

function string:uncapitalize()
    return self:sub(1, 1):lower()..self:sub(2)
end

function string:insert(index, value)
    return self:sub(1, index - 1)..value..self:sub(index)
end

function string:remove(index)
    return self:sub(1, index - 1)..self:sub(index + 1)
end

function string:splitAllChars()
    local t = {}
    for i = 1, #self do
        t[i] = self:sub(i, i)
        if t[i] == " " then
            t[i] = "space"
        end
    end
    return t
end

local replacementChars = {
    -- actually dont use html stuffs
    ["\'"] = "&#39|",
    ["\""] = "&quot|",
    ["<"] = "&lt|",
    [">"] = "&gt|",
    ["&"] = "&amp|",
    [";"] = "&semi|"
}

function string:safe()
    for k, v in pairs(replacementChars) do
        self = self:gsub(k, v)
    end

    return self
end

function string:unsafe()
    for k, v in pairs(replacementChars) do
        self = self:gsub(v, k)
    end

    return self
end

return string
