local MapEditor = State:extend("MapEditor")

function MapEditor:new()
    State.new(self, "MapEditor")

    self._mapName = "New Map"
end

function MapEditor:renderImGUI()
    
end

return MapEditor