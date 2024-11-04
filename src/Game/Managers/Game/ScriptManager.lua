---@class Script
local Script = {}

function Script:loadScript(path)
    self.script = nil
    print("Loading script: " .. path)
    if not love.filesystem.getInfo(path) then
        return
    end
    self.script = love.filesystem.load(path)
    -- private environment for the script
    -- why? because we don't want the script to have access to the global environment & potential malicious code
    self.env = {
        print = print
    }
    setfenv(self.script, self.env)
    self.script()
end

function Script:call(name, ...)
    if not self.script then
        return
    end
    if self.env[name] then
        --[[ return self.env[name](...) ]]
        local ok, err = pcall(self.env[name], ...)
        if not ok then
            print("Error calling function " .. name, err)
        end
    end
end

return Script