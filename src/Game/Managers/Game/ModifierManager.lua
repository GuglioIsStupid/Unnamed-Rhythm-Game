local ModifierManager = Class:extend("ModifierManager")

ModifierManager.Modifiers = {
    -- {Name, Description, ScoreMultAddition, Shorthand}
    {
        "No LN", "Disables Long Notes", -0.25, -- applies if the map has long notes
        "NLN"
    },
    {
        "No SV", "Disables Scroll Velocity", -0.25, -- applies if the map has a scroll velocity
        "NSV"
    },
    {
        "Fade Out", "Notes fade out as they approach the receptors", 0.1,
        "FO"
    },
    {
        "Fade In", "Notes fade in as they approach the receptors", 0.1,
        "FI"
    },
    -- if both fade in and fade out are enabled, then multiplier goes up .3
    {
        "Mirror", "Notes are mirrored (Left -> Right, Up -> Down)", 0,
        "M"
    }
}

ModifierManager.ActiveModifiers = {
}

function ModifierManager:getModifier(name)
    for _, mod in ipairs(self.Modifiers) do
        if mod[1] == name then
            return mod
        end
    end
end

function ModifierManager:getShortHandFromName(name)
    for _, mod in ipairs(self.Modifiers) do
        if mod[1] == name then
            return mod[4]
        end
    end
end

function ModifierManager:getNameFromShorthand(shorthand)
    for _, mod in ipairs(self.Modifiers) do
        if mod[4] == shorthand then
            return mod[1]
        end
    end
end

--- Calculates the score multiplier based off the currently enabled modifiers
--- 
--- Only calculates the score multipliers if it is applicable to the map
---@return number mult The score multiplier
function ModifierManager:getScoreMultiplier()
    local mult = 1

    if States.Screens.Game.LongNotes and table.contains(self.ActiveModifiers, "No LN") then
        mult = mult + self:getModifier("No LN")[3]
    end

    if States.Screens.Game.ScrollVelocity and table.contains(self.ActiveModifiers, "No SV") then
        mult = mult + self:getModifier("No SV")[3]
    end

    if table.contains(self.ActiveModifiers, "Fade Out") and table.contains(self.ActiveModifiers, "Fade In") then
        mult = mult + 0.1
    end

    for _, mod in ipairs(self.ActiveModifiers) do
        if mod == "Fade Out" or mod == "Fade In" then
            goto continue
        end
        mult = mult + self:getModifier(mod)[3]

        ::continue::
    end

    return mult
end

return ModifierManager
