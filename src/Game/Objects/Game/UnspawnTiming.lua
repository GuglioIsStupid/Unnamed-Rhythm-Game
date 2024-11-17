---@class UnspawnTiming
local UnspawnTiming = Class:extend("UnspawnTiming")

function UnspawnTiming:new(startTime)
    self.StartTime = startTime or 0
end

return UnspawnTiming