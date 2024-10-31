---@diagnostic disable: duplicate-set-field

local disabledModules = {
    "os"
}
local o_require = require
function require(path)
    for _, module in ipairs(disabledModules) do
        if path:find(module) then
            print("Not allowed to load module: " .. module)
            return nil
        end
    end

    local success, result = pcall(o_require, path)
    if success then
        return result
    else
        print("Error loading module: " .. path)
        print(result)
        return nil
    end
end

local defaultGlobals = {}
for k, _ in pairs(_G) do
    table.insert(defaultGlobals, k)
end
jit.on()
jit.opt.start(4,
    "hotloop=1", "hotexit=2", "loopunroll=8", "-sink",
    "-fold", "-cse", "-fuse", "-abc", "-dse", "-loop"
)
love.audio.setVolume(0.25)

require("Engine")
require("Game")

local GENERATE_GLOBALS_LIST = false
local SERVER_URL, PORT = "server.rit.agori.dev", 1337

function love.load(args)
    if args then
        --[[ if (args[1] or "") == "-globals" then
            GENERATE_GLOBALS_LIST = true
        end
        if (args[2] or "") == "-localhost" then
            SERVER_URL = "localhost"
        end ]]
        if table.find(args, "-globals") then
            GENERATE_GLOBALS_LIST = true
        end

        if table.find(args, "-localhost") then
            SERVER_URL = "localhost"
        end
    end

    NetworkingClientThread:start(SERVER_URL, PORT)

    os.execute = function() print("os.execute is disabled") end
    os.exit = function() print("os.exit is disabled") end
    os.remove = function() print("os.remove is disabled") end
    os.rename = function() print("os.rename is disabled") end
    os.setlocale = function() print("os.setlocale is disabled") end

    ImGUI.love.Init("RGBA32")
end

function love.update(dt)
    ImGUI.love.Update(dt)
    ImGUI.NewFrame()
    
    Input:update()
    Cache:update()
    Game:update(dt)

    if DiscordRPC then
        DiscordRPC.timer = DiscordRPC.timer + dt
        if DiscordRPC.timer >= DiscordRPC.maxTimer then
            DiscordRPC.timer = 0

            DiscordRPC.runCallbacks()
        end
    end

    local msg = NetworkingClient:getMessage()
    if msg then
        if msg.action == "gotServers" then
            print(table.format(msg))
        end
    end
end

function love.resize(w, h)
    Game:resize(w, h)
    Game._windowWidth = w
    Game._windowHeight = h
end

function love.keypressed(key, scancode, isrepeat)
    ImGUI.love.KeyPressed(key)
    if ImGUI.love.GetWantCaptureKeyboard() then
        return
    end
    Input:keypressed(key)
    Game:keypressed(key, scancode, isrepeat)
end

function love.keyreleased(key, scancode)
    ImGUI.love.KeyReleased(key)
    if ImGUI.love.GetWantCaptureKeyboard() then
        return
    end
    Input:keyreleased(key)
    Game:keyreleased(key, scancode)
end

function love.mousepressed(x, y, button, istouch, presses)
    ImGUI.love.MousePressed(button)
    if ImGUI.love.GetWantCaptureMouse() then
        return
    end
    local ok = true
    for _, substate in ipairs(Game._substates) do
        if substate:mousepressed(x, y, button) then
            ok = false
            break
        end
    end
    if ok then
        Game:mousepressed(x, y, button, istouch, presses)
    end
    Input:mousepressed(button)

    if VirtualPad and VirtualPad._CURRENT and not istouch then
        VirtualPad._CURRENT:mousepressed(x, y, button)
    end
end

function love.mousereleased(x, y, button, istouch, presses)
    ImGUI.love.MouseReleased(button)
    if ImGUI.love.GetWantCaptureMouse() then
        return
    end
    Game:mousereleased(x, y, button, istouch, presses)
    Input:mousereleased(button)

    if VirtualPad and VirtualPad._CURRENT and not istouch then
        VirtualPad._CURRENT:mousereleased(x, y, button)
    end
end

function love.wheelmoved(x, y)
    ImGUI.love.WheelMoved(x, y)
    if ImGUI.love.GetWantCaptureMouse() then
        return
    end
    Game:wheelmoved(x, y)
end

function love.mousemoved(x, y, dx, dy, istouch)
    ImGUI.love.MouseMoved(x, y)
    if ImGUI.love.GetWantCaptureMouse() then
        return
    end
    Game:mousemoved(x, y, dx, dy, istouch)

    if VirtualPad and VirtualPad._CURRENT and not istouch then
        VirtualPad._CURRENT:mousemoved(x, y, dx, dy, istouch)
    end
end

function love.textinput(t)
    ImGUI.love.TextInput(t)
    if ImGUI.love.GetWantCaptureKeyboard() then
        return
    end
    Game:textinput(t)
end

function love.draw()
    Game:draw()

    if not love.system.isMobile() then
        love.graphics.push()
        love.graphics.scale(Game._windowWidth / Game._gameWidth, Game._windowHeight / Game._gameHeight)
        if VirtualPad and VirtualPad._CURRENT then
            VirtualPad._CURRENT:draw()
        end
        love.graphics.pop()
    end

    Game:renderImGUI()

    ImGUI.Render()
    ImGUI.love.RenderDrawLists()
end

function love.quit()
    if GENERATE_GLOBALS_LIST then
        local globalList = {}
        for k, _ in pairs(_G) do
            table.insert(globalList, k)
        end
        -- remove the default globals
        for _, v in ipairs(defaultGlobals) do
            table.remove(globalList, table.findID(globalList, v))
        end
        table.sort(globalList)

        print("Writing global list to file")

        love.filesystem.write("globalList.txt", table.concat(globalList, "\n"))
    end

    Game:quit()
end
