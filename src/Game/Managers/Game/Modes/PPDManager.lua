---@class FTManager

local FTManager = Group:extend("FTManager")
local GAME = States.Screens.Game

function FTManager:new(instance)
    Group.new(self)
end

return FTManager