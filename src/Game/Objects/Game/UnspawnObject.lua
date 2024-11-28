---@class UnspawnObject
local UnspawnObject = Class:extend("UnspawnObject")

function UnspawnObject:new(startTime, endTime, lane, hitsounds)
    self.StartTime = startTime or 0
    self.EndTime = endTime or 0
    self.Lane = lane or 1
    self.Hitsounds = hitsounds or ""
end

return UnspawnObject
