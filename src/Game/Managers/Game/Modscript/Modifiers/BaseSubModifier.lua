local SubModifier = BaseModifier:extend()
SubModifier.type = "SubMod"

function SubModifier:getOrder()
    return 2
end

function SubModifier:new(name, parent)
    BaseModifier.new(self, parent)
    self.name = name

    return self
end

return SubModifier