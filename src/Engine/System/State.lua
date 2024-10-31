---@class State : Group
local State = Group:extend("State")

function State:__tostring()
    return "State<" .. self._NAME ..  "> (" .. #self.objects .. " objects)"
end

function State:renderImGUI()
    for _, object in ipairs(self.objects) do
        if object.renderImGUI then
            object:renderImGUI()
        end
    end
end

return State
