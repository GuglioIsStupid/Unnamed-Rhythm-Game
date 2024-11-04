---@class Input
Input = Class:extend("Input")

---@param controls table
function Input:new(controls)
    self.controls = controls
    --[[
    Layout:
    {
        name = {"bind1", "bind2", "bind3"}
    }
    ]]
    
    self.keyboardControls = {}
    self.mouseControls = {}

    for control, key in pairs(controls) do
        self.keyboardControls[control] = {}
        self.mouseControls[control] = {}
        for i, k in ipairs(key) do
            if k:find("mouse") then
                -- mouse controls
                table.insert(self.mouseControls[control], k:sub(6))
            elseif k:find("joy") then
                -- joystick controls
            elseif k:find("kb") then
                table.insert(self.keyboardControls[control], k:sub(3))
            end
        end
    end

    self.keyboardBase = Keyboard(self.keyboardControls)
    self.mouseBase = Mouse(self.mouseControls)
end

function Input:replaceInput(name, new)
    self.keyboardControls[name] = {}
    self.mouseControls[name] = {}
    for i, k in ipairs(new) do
        if k:find("mouse") then
            -- mouse controls
            table.insert(self.mouseControls[name], k:sub(6))
        elseif k:find("joy") then
            -- joystick controls
        elseif k:find("kb") then
            table.insert(self.keyboardControls[name], k:sub(3))
        end
    end
end

function Input:update()
    self.keyboardBase:update()
    self.mouseBase:update()
end

function Input:keypressed(key)
    self.keyboardBase:keypressed(key)
end

function Input:keyreleased(key)
    self.keyboardBase:keyreleased(key)
end

function Input:mousepressed(key)
    self.mouseBase:mousepressed(key)
end

function Input:mousereleased(key)
    self.mouseBase:mousereleased(key)
end

---@param control string
function Input:isDown(control)
    if self.keyboardControls[control] and self.keyboardBase:isDown(control) then
        return true
    end
    if self.mouseControls[control] and self.mouseBase:isDown(control) then
        return true
    end

    return false
end

---@param control string
function Input:wasPressed(control)
    if self.keyboardControls[control] and self.keyboardBase:wasPressed(control) then
        print(control)
        return true
    end
    if self.mouseControls[control] and self.mouseBase:wasPressed(control) then
        return true
    end

    return false
end

---@param control string
function Input:wasReleased(control)
    if self.keyboardControls[control] and self.keyboardBase:wasReleased(control) then
        return true
    end
    if self.mouseControls[control] and self.mouseBase:wasReleased(control) then
        return true
    end

    return false
end

return Input