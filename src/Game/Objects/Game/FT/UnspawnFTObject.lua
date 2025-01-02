---@class UnspawnFTObject
local UnspawnFTObject = Class:extend("UnspawnFTObject")

function UnspawnFTObject:new(type, lane, holdTimer, holdEnd, x, y, angle, waveCount, distance, amplitude, tft, ts, time)
    self.Ver = type or "TARGET"
    self.Type = lane or 1
    self.HoldTimer = holdTimer or 0
    self.HoldEnd = holdEnd or 0
    self.X = x or 0
    self.Y = y or 0
    self.X = self.X * 0.004
    self.Y = self.Y * 0.004
    self.Angle = angle or 0
    self.WaveCount = waveCount or 0
    self.Distance = distance or 0
    self.Amplitude = amplitude or 0
    self.TFT = tft or 0
    self.TS = ts or 0
    self.StartTime = time or 0
end

return UnspawnFTObject