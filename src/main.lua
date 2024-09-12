require("Engine")
require("Game")


function love.load()
    for i = 1, 10 do
        print("Hello World!", i)
    end
end

function love.update(dt)
    Input:update()
    Game:update(dt)

    --[[ if DiscordRPC then
        DiscordRPC.timer = DiscordRPC.timer + dt
        if DiscordRPC.timer >= DiscordRPC.maxTimer then
            DiscordRPC.timer = 0

            DiscordRPC:runCallbacks()
        end
    end ]]
end

function love.resize(w, h)
    Game:resize(w, h)
    Game._windowWidth = w
    Game._windowHeight = h
end

function love.keypressed(key, scancode, isrepeat)
    Input:keypressed(key)
    Game:keypressed(key, scancode, isrepeat)
end

function love.keyreleased(key, scancode)
    Input:keyreleased(key)
    Game:keyreleased(key, scancode)
end

function love.mousepressed(x, y, button, istouch, presses)
    Game:mousepressed(x, y, button, istouch, presses)
end

function love.mousereleased(x, y, button, istouch, presses)
    Game:mousereleased(x, y, button, istouch, presses)
end

function love.wheelmoved(x, y)
    Game:wheelmoved(x, y)
end

function love.mousemoved(x, y, dx, dy, istouch)
    Game:mousemoved(x, y, dx, dy, istouch)
end

function love.draw()
    Game:draw()

    Game:__printDebug()

    if Input:isDown("MenuPress") then
        love.graphics.print("Menu Pressed", 10, 50)
    end
end
