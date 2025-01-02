---@class FTFlyingTime
local FTFlyingTime = Class:extend("FTFlyingTime")

function FTFlyingTime:new(TFT, time)
    self.Ver = "TARGET_FLYING_TIME"
    self.StartTime = time or 0
    self.TFT = TFT
end

return FTFlyingTime