---@class PPDManager

local PPDManager = Group:extend("PPDManager")
local GAME = States.Screens.Game

function PPDManager:new(instance)
    Group.new(self)
end

return PPDManager