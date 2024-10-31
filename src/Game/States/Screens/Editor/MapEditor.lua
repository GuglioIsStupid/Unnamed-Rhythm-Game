local MapEditor = State:extend("MapEditor")
local ffi = require("ffi")

function MapEditor:new()
    State.new(self, "MapEditor")

    self._mapName = "New Map"
end

function MapEditor:renderImGUI()
    -- Map Metadata ImGUI window
    if ImGUI.Begin("Map Metadata", nil, ImGUI.ImGuiWindowFlags_MenuBar) then
        if ImGUI.BeginMenuBar() then
            
            if ImGUI.InputText("Name", ffi.cast("char*", self._mapName), 256, ImGUI.ImGuiInputTextFlags_EnterReturnsTrue) then
                self._mapName = ffi.string(ImGUI.GetInputTextResult())
                print("Map Name: " .. self._mapName)
            end

            ImGUI.EndMenuBar()
        end
    end

    ImGUI.End()
end

return MapEditor