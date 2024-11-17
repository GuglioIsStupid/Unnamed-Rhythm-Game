---@class Group
local Group = Class:extend("Group")

---@param size? number
function Group:new(size)
    self.objects = {}
    self.size = size or 0
    self.zorder = 0
end

---@param object any
function Group:add(object, reorder, pos)
    local pos = pos or #self.objects + 1
    if type(reorder) == "number" then
        pos = reorder
        reorder = true
    end

    reorder = reorder == nil and true or false
    if self.size > 0 and #self.objects >= self.size then
        debug.warn("Group is full (" .. #self.objects .. "/" .. self.size .. ")")
        return
    end

    table.insert(self.objects, pos, object)

    -- sort by zorder
    if reorder then
        self:reorder()
    end
end

function Group:reorder()
    table.sort(self.objects, function(a, b)
        return (a.zorder or -1000) < (b.zorder or -1000)
    end)
end

function Group:remove(object)
    for i, obj in ipairs(self.objects) do
        if obj == object then
            table.remove(self.objects, i)
            break
        end
    end
end

function Group:clear()
    self.objects = {}
end

-- I Should probably just use a metatable for this

---@param dt number
function Group:update(dt)
    for _, obj in ipairs(self.objects) do
        if obj.update then
            obj:update(dt)
        end
    end
end

function Group:draw()
    for _, obj in ipairs(self.objects) do
        if obj.draw then
            obj:draw()
        end
    end
end

---@param w number
---@param h number
function Group:resize(w, h)
    for _, obj in ipairs(self.objects) do
        if obj.resize then
            obj:resize(w, h)
        end
    end
end

---@param key string
---@param scancode string
---@param isrepeat boolean
function Group:keypressed(key, scancode, isrepeat)
    for _, obj in ipairs(self.objects) do
        if obj.keypressed then
            obj:keypressed(key, scancode, isrepeat)
        end
    end
end

---@param key string
---@param scancode string
function Group:keyreleased(key, scancode)
    for _, obj in ipairs(self.objects) do
        if obj.keyreleased then
            obj:keyreleased(key, scancode)
        end
    end
end

---@param x number
---@param y number
---@param button number
---@param istouch boolean
---@param presses number
function Group:mousepressed(x, y, button, istouch, presses)
    for _, obj in ipairs(self.objects) do
        if obj.mousepressed then
            obj:mousepressed(x, y, button, istouch, presses)
        end
    end
end

---@param x number
---@param y number
---@param button number
---@param istouch boolean
---@param presses number
function Group:mousereleased(x, y, button, istouch, presses)
    for _, obj in ipairs(self.objects) do
        if obj.mousereleased then
            obj:mousereleased(x, y, button, istouch, presses)
        end
    end
end

---@param x number
---@param y number
---@param dx number
---@param dy number
---@param istouch boolean
function Group:mousemoved(x, y, dx, dy, istouch)
    for _, obj in ipairs(self.objects) do
        if obj.mousemoved then
            obj:mousemoved(x, y, dx, dy, istouch)
        end
    end
end

---@param x number
---@param y number
function Group:wheelmoved(x, y)
    for _, obj in ipairs(self.objects) do
        if obj.wheelmoved then
            obj:wheelmoved(x, y)
        end
    end
end

---@param text string
function Group:textinput(text)
    for _, obj in ipairs(self.objects) do
        if obj.textinput then
            obj:textinput(text)
        end
    end
end

function Group:__tostring()
    if #self.objects == 0 then
        return "Group (empty)"
    elseif self.size > 0 then
        return "Group (" .. #self.objects .. "/" .. self.size .. " objects)"
    else
        return "Group (" .. #self.objects .. " objects)"
    end
end

function Group:kill()
    for _, obj in ipairs(self.objects) do
        if obj.kill and (obj.deleteOnClear or obj.deleteOnClear == nil) then
            obj:kill()
        end
    end

    self:clear()
end

return Group
