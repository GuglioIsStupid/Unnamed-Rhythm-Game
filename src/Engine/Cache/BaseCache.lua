---@class BaseCache
local BaseCache = Class:extend("BaseCache")

function BaseCache:new()
    self._cache = {}
end

---@param path string
function BaseCache:get(path)
    debug.warn("BaseCache:get(path) is not implemented.")
end

function BaseCache:clear()
    for path, asset in pairs(self._cache) do
        asset:release()
        self._cache[path] = nil
    end
end 

return BaseCache
