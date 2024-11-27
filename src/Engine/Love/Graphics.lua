function love.graphics.printWithTrimmed(text, x, y, limit, sx, sy, kx, ky)
    local font = love.graphics.getFont()
    local width = font:getWidth(text)
    if width > limit then
        local trimmed = text
        while font:getWidth(trimmed .. "...") > limit do
            trimmed = trimmed:sub(1, #trimmed - 1)
        end
        text = trimmed .. "..."
    end
    love.graphics.print(text, x, y, 0, sx, sy, 0, 0, kx, ky)
end

local o_graphics_print = love.graphics.print
local o_graphics_printf = love.graphics.printf

function love.graphics.print(txt, ...)
    o_graphics_print(txt:unsafe(), ...)
end

function love.graphics.printf(txt, ...)
    o_graphics_printf(txt:unsafe(), ...)
end