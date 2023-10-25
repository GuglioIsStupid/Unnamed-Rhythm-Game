--[[----------------------------------------------------------------------------

This file is apart of Rit; a free and open sourced rhythm game made with LÖVE.

Copyright (C) 2023 GuglioIsStupid

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.

------------------------------------------------------------------------------]]

--@name string.split
--@description Splits a string into a table
--@param sep string
--@return table
function string.split(self, sep)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    self:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end

--@name string.splitAllCharacters
--@description Splits a string into a table of all characters
--@return table
function string.splitAllCharacters(self)
    local fields = {}
    for c in self:gmatch(".") do
        fields[#fields+1] = c
    end
    return fields
end

--@name string.trim
--@description Trims whitespace from the beginning and end of a string
--@return string
function string.trim(self)
    return self:gsub("^%s*(.-)%s*$", "%1")
end

--@name string.startsWith
--@description Checks if a string starts with another string
--@param start string
--@return boolean
function string.startsWith(self, start)
    return self:sub(1, #start) == start
end

--@name string.endsWith
--@description Checks if a string ends with another string
--@param ending string
--@return boolean
function string.endsWith(self, ending)
    return ending == "" or self:sub(-#ending) == ending
end

--@name string.contains
--@description Checks if a string contains another string
--@param str string
--@return boolean
function string.contains(self, str)
    return self:find(str) ~= nil
end

--@name string.count
--@description Counts the number of times a string appears in another string
--@param str string
--@return number
function string.count(self, str)
    local count = 0
    for _ in self:gmatch(str) do
        count = count + 1
    end
    return count
end

--@name string.replace
--@description Replaces all instances of a string with another string
--@param search string
--@param replace string
--@return string
function string.replace(self, search, replace)
    return self:gsub(search, replace)
end

--@name string.reverse
--@description Reverses a string
--@return string
function string.reverse(self)
    return self:splitAllCharacters():reverse():concat()
end

--@name string.capitalize
--@description Capitalizes the first letter of a string
--@return string
function string.capitalize(self)
    return self:sub(1, 1):upper() .. self:sub(2)
end

--@name string.toTable
--@description Converts a string to a table of all characters
--@return tables
function string.toTable(self)
    local t = {}
    for c in self:gmatch(".") do
        t[#t+1] = c
    end
    return t
end

--@name string.fromTable
--@description Converts a table of all characters to a string
--@param t table
--@return string
function string.fromTable(self, t)
    return table.concat(t)
end

--@name string.random
--@description Generates a random string
--@param length number
--@return string
function string.random(length)
    local length = length or 16
    local str = ""
    for i = 1, length do
        str = str .. string.char(love.math.random(32, 126))
    end
    return str
end
