---@diagnostic disable: redundant-parameter
local threadEvent = love.thread.newThread("Engine/Threads/EventThread.lua")

local channel_event = love.thread.getChannel("thread.event")
local channel_active = love.thread.getChannel("thread.event.active")

local drawCur, drawFPS = 0, 0

love._framerate = 1000

function love.run()
    local g_origin, g_clear, g_present = love.graphics.origin, love.graphics.clear, love.graphics.present
    local g_active, g_getBGColour = love.graphics.isActive, love.graphics.getBackgroundColor
    local e_pump, e_poll, t, n = love.event.pump, love.event.poll, {}, 0
    local t_step = love.timer.step
    local t_getTime = love.timer.getTime
    local t_sleep = love.timer.sleep
    local a, b
    local dt = 0
    local love = love
    local love_load, love_update, love_draw = love.load, love.update, love.draw
    local love_quit, a_parseGameArguments = love.quit, love.arg.parseGameArguments
    local collectgarbage = collectgarbage
    local love_handlers = love.handlers

	love_load(a_parseGameArguments(arg), arg)

	t_step()
    t_step()
    collectgarbage()

    ---@diagnostic disable-next-line: redefined-local
    local function event(name, a, ...)
        if name == "quit" and not love_quit() then
            channel_event:clear()
            channel_active:clear()
            channel_active:push(0)
            return a or 0, ...
        end

        return love_handlers[name](a, ...)
    end

    local lastFrame = 0

	return function()
		if threadEvent:isRunning() then
            channel_active:clear()
            channel_active:push(1)
            a = channel_event:pop()

            while a do
                b = channel_event:demand()
                for i =  1, b do
                    t[i] = channel_event:demand()
                end
                n, a, b = b, event(a, unpack(t, 1, b))
                if a then
                    e_pump()
                    return a, b
                end
                a = channel_event:pop()
            end
        end

        e_pump()

        ---@diagnostic disable-next-line: redefined-local
        for name, a, b, c, d, e, f in e_poll() do
           a, b = event(name, a, b, c, d, e, f)
           if a then return a, b end
        end

        dt = t_step()
        drawCur = drawCur + dt

        love_update(dt)

        while t_getTime() - lastFrame < 1 / love._framerate do
            t_sleep(0.0005)
        end

        lastFrame = t_getTime()
        if g_active() then
            drawFPS = 1 / drawCur
            drawCur = 0
            g_origin()
            g_clear(g_getBGColour())
            love_draw()
            g_present()
        end

        collectgarbage("step")
    end
end

local o_timer_getFPS = love.timer.getFPS
function love.timer.getFPS()
    return o_timer_getFPS(), math.floor(drawFPS)
end