--[[----------------------------------------------------------------------------

This file is apart of Rit; a free and open sourced rhythm game made with LÖVE.

Copyright (C) 2023 GuglioIsStupid

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.

------------------------------------------------------------------------------]]
function tryExcept(func, except)
    local status, err = pcall(func)
    if not status then
        except(err)
    end
end

if not love.filesystem.isFused() then
    __DEBUG__ = true
else
    __DEBUG__ = false
    function print() return end -- disable print
end

function loadSongs()
    -- get all .qp files in songs/
    if not love.filesystem.getInfo("songs") then
        love.filesystem.createDirectory("songs")
        love.window.showMessageBox("Songs folder created!",
        "songs folder has been created at " .. love.filesystem.getSaveDirectory() .. "/songs", "info")
    end
    if not love.filesystem.getInfo("songs/packs") then
        love.filesystem.createDirectory("songs/packs")
    end
    if love.filesystem.getInfo("songs/quaver") or love.filesystem.getInfo("songs/osu") or love.filesystem.getInfo("songs/fnf") or
        love.filesystem.getInfo("songs/quaverExtracted") or love.filesystem.getInfo("songs/osuExtracted") then
        love.window.showMessageBox("Songs folder structure outdated!",
            "songs folder structure is outdated, please move all songs to the songs folder and delete the old folders",
            "error")
    end

    songList = {}
    packs = {}
    -- gross song loading... i know... i'm sorry...
    for i, v in ipairs(love.filesystem.getDirectoryItems("songs")) do
        -- check if the file is a directory
        if love.filesystem.getInfo("songs/" .. v).type == "directory" then
            -- check if it has a .qua, .osu, or .json file
            for k, j in ipairs(love.filesystem.getDirectoryItems("songs/" .. v)) do
                if love.filesystem.getInfo("songs/" .. v .. "/" .. j).type == "file" then
                    if j:sub(-4) == ".qua" then
                        local title = love.filesystem.read("songs/" .. v .. "/" .. j):match("Title:(.-)\r?\n")
                        local difficultyName = love.filesystem.read("songs/" .. v .. "/" .. j):match(
                        "DifficultyName:(.-)\r?\n")
                        local BackgroundFile = love.filesystem.read("songs/" .. v .. "/" .. j):match(
                        "BackgroundFile:(.-)\r?\n")
                        songList[#songList + 1] = {
                            filename = v,
                            title = title,
                            difficultyName = difficultyName or "???",
                            BackgroundFile = BackgroundFile:sub(2),
                            path = "songs/" .. v .. "/" .. j,
                            folderPath = "songs/" .. v,
                            type = "Quaver",
                        }
                    elseif j:sub(-4) == ".osu" then
                        local title = love.filesystem.read("songs/" .. v .. "/" .. j):match("Title:(.-)\r?\n")
                        local difficultyName = love.filesystem.read("songs/" .. v .. "/" .. j):match("Version:(.-)\r?\n")
                        songList[#songList + 1] = {
                            filename = v,
                            title = title,
                            difficultyName = difficultyName or "???",
                            path = "songs/" .. v .. "/" .. j,
                            folderPath = "songs/" .. v,
                            type = "osu!"
                        }
                    elseif j:sub(-5) == ".json" then
                        gsubbedFile = j:gsub(".json", "")
                        local difficultyName = gsubbedFile:match("-(.*)")
                        songList[#songList + 1] = {
                            filename = j,
                            title = json.decode(love.filesystem.read("songs/" .. v .. "/" .. j)).song.song,
                            difficultyName = difficultyName or "normal",
                            BackgroundFile = "None",
                            path = "songs/" .. v .. "/" .. j,
                            folderPath = "songs/" .. v,
                            type = "FNF"
                        }
                    end
                end
            end
        else
            print("songs/" .. v .. " is not a directory")
            -- check if it is a .qp or .osz file
            if v:sub(-3) == ".qp" then
                love.filesystem.mount("songs/" .. v, "qp")
                for k, j in ipairs(love.filesystem.getDirectoryItems("qp")) do
                    if love.filesystem.getInfo("qp/" .. j).type == "file" then
                        if j:sub(-4) == ".qua" then
                            local title = love.filesystem.read("qp/" .. j):match("Title:(.-)\r?\n")
                            local difficultyName = love.filesystem.read("qp/" .. j):match("DifficultyName:(.-)\r?\n")
                            local BackgroundFile = love.filesystem.read("qp/" .. j):match("BackgroundFile:(.-)\r?\n")
                            songList[#songList + 1] = {
                                filename = v,
                                title = title,
                                difficultyName = difficultyName or "???",
                                BackgroundFile = BackgroundFile:sub(2),
                                path = "qp/" .. j,
                                folderPath = "qp",
                                type = "Quaver",
                            }
                        end
                    end
                end
                love.filesystem.unmount("qp")
            elseif v:sub(-4) == ".osz" then
                love.filesystem.mount("songs/" .. v, "osz")
                for k, j in ipairs(love.filesystem.getDirectoryItems("osz")) do
                    if love.filesystem.getInfo("osz/" .. j).type == "file" then
                        if j:sub(-4) == ".osu" then
                            local title = love.filesystem.read("osz/" .. j):match("Title:(.-)\r?\n")
                            local difficultyName = love.filesystem.read("osz/" .. j):match("Version:(.-)\r?\n")
                            songList[#songList + 1] = {
                                filename = v,
                                title = title,
                                difficultyName = difficultyName or "???",
                                path = "osz/" .. j,
                                folderPath = "osz",
                                type = "osu!"
                            }
                        end
                    end
                end
                love.filesystem.unmount("osz")
            end
        end
    end

    -- go through all songs, if it starts with " " then remove it
    for i, v in ipairs(songList) do
        if v.title:sub(1, 1) == " " then
            v.title = v.title:sub(2)
        end
        -- if first letter is lowercase, then make it uppercase
        if v.title:sub(1, 1):lower() == v.title:sub(1, 1) then
            v.title = v.title:sub(1, 1):upper() .. v.title:sub(2)
        end
    end
    -- sort the song list by title a-z
    table.sort(songList, function(a, b)
        return a.title < b.title
    end)
end

local desktopWidth, desktopHeight = love.window.getDesktopDimensions()
fnfMomentShiz = {
    true, false
}
songSelectScrollOffset = 0
-- love.filesystem.isFused() and
if (love.system.getOS() == "Windows" or love.system.getOS() == "OS X") then
    discordRPC = require "lib.discordRPC"
    nextPresenceUpdate = 0
end
function love.load()
    require "modules.overrides"
    require "modules.debug"
    DiffCalc = require "modules.DiffCalc"
    input = (require "lib.baton").new({
        controls = {
            -- 4K inputs

            one4 = { "axis:triggerleft+", "axis:leftx-", "axis:rightx-", "button:dpleft", "button:x", "key:d" },
            two4 = { "axis:lefty+", "axis:righty+", "button:leftshoulder", "button:dpdown", "button:a", "key:f" },
            three4 = { "axis:lefty-", "axis:righty-", "button:rightshoulder", "button:dpup", "button:y", "key:j" },
            four4 = { "axis:triggerright+", "axis:leftx+", "axis:rightx+", "button:dpright", "button:b", "key:k" },
            -- 7K inputs

            one7 = { "key:s" },
            two7 = { "key:d" },
            three7 = { "key:f" },
            four7 = { "key:space" },
            five7 = { "key:j" },
            six7 = { "key:k" },
            seven7 = { "key:l" },
            -- UI

            up = { "key:up", "button:dpup", "axis:lefty-" },
            down = { "key:down", "button:dpdown", "axis:lefty+" },
            left = { "key:left", "button:dpleft", "axis:leftx-" },
            right = { "key:right", "button:dpright", "axis:leftx+" },
            confirm = { "key:return", "button:a" },
            pause = { "key:return", "button:start" },
            restart = { "key:r", "button:b" },
            extB = { "button:back" },
            volUp = { "button:rightshoulder" },
            volDown = { "button:leftshoulder" },
            quit = { "key:escape", "button:back" }
        },
        joystick = love.joystick.getJoysticks()[1]
    })
    graphics = require "modules.graphics"

    ini = require "lib.ini"
    xml = require "lib.xml".parse
    if discordRPC then
        discordRPC.initialize("785717724906913843", true)
    end
    settingsIni = require "settings"
    settingsIni.loadSettings()

    function round(num)
        return math.floor(num + 0.5)
    end

    speed = settings.scrollspeed or 1
    autoplay = settings.autoplay or false

    quaverLoader = require "parsers.quaverLoader"
    osuLoader = require "parsers.osuLoader"
    stepmaniaLoader = require "parsers.stepmaniaLoader"
    fnfLoader = require "parsers.fnfLoader"

    receptors = {}

    state = require "modules.state"
    beatHandler = require "modules.beatHandler"
    -- Modchart handlers
    modifiers = require "modules.modifier"
    modscript = require "modules.modscriptAPI"

    game = require "states.game"
    songSelect = require "states.songSelect"
    skinSelect = require "states.skinSelect"
    resultsScreen = require "states.resultsScreen"
    audioOffsetter = require "states.audioOffset"

    push = require "lib.push"
    Timer = require "lib.timer"
    charthits = {}
    for i = 1, 4 do
        charthits[i] = {}
    end
    curSongSelected = 1
    font = love.graphics.newFont("fonts/Dosis-SemiBold.ttf", 16)
    scoreFont = love.graphics.newFont("fonts/Dosis-SemiBold.ttf", 64)
    accuracyFont = love.graphics.newFont("fonts/Dosis-SemiBold.ttf", 48)
    love.graphics.setFont(font)
    love.graphics.setDefaultFilter("nearest", "nearest")

    musicTimeDo = false
    health = 1

    love.window.setMode(settings.width, settings.height,
    { resizable = true, vsync = settings.vsync, fullscreen = settings.fullscreen })
    push.setupScreen(1920, 1080, { upscale = "normal" })

    fnfMomentSelected = 1

    if not love.filesystem.getInfo("fnf-note.blacklist") then
        love.filesystem.write("fnf-note.blacklist", "# Add the note types you want to chart generator to ignore.\n")
    end

    fnfBlacklist = {}
    for line in love.filesystem.lines("fnf-note.blacklist") do
        if line:sub(1, 1) ~= "#" then
            table.insert(fnfBlacklist, line)
        end
    end

    loadSongs()
    state.switch(skinSelect)

    -- scissorScale is meant for 720p
    scissorScale = 1

    audioVol = 50
    love.audio.setVolume(audioVol / 100)
    volFade = 0

    -- Get rid of all of OS funcs except os.time
    for k, v in pairs(os) do
        if k ~= "time" and k ~= "date" then
            os[k] = nil
        end
    end
end

function love.resize(w, h)
    push.resize(w, h)

    state.resize(w, h)

    scissorScale = h / 720
end

function love.update(dt)
    Timer.update(dt)
    state.update(dt)
    if __DEBUG__ then debug.update(dt) end
    if discordRPC then
        if love.timer.getTime() or 0 > nextPresenceUpdate then
            if presence then
                discordRPC.updatePresence(presence)
            end
            nextPresenceUpdate = love.timer.getTime() + 2.0
        end
        discordRPC.runCallbacks()
    end

    if input:getActiveDevice() == "joy" then
        if input:down("extB") then
            if input:pressed("volUp") then
                audioVol = audioVol + 5
            elseif input:pressed("volDown") then
                audioVol = audioVol - 5
            end

            -- apply volume
            if audioVol > 100 then audioVol = 100 end
            if audioVol < 0 then audioVol = 0 end
            if audioVol == 0 then
                love.audio.setVolume(0)
            else
                love.audio.setVolume(audioVol / 100)
            end
            volFade = 1
        end
    end

    input:update(dt)
end

function love.wheelmoved(x, y)
    if state.wheelmoved then
        state.wheelmoved(x, y)
    end

    if love.keyboard.isDown("lalt") then
        if y > 0 then
            audioVol = audioVol + 5
        elseif y < 0 then
            audioVol = audioVol - 5
        end

        -- apply volume
        if audioVol > 100 then audioVol = 100 end
        if audioVol < 0 then audioVol = 0 end
        if audioVol == 0 then
            love.audio.setVolume(0)
        else
            love.audio.setVolume(audioVol / 100)
        end

        volFade = 1
    end
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
    if state.keypressed then
        state.keypressed(key)
    end
    if key == "k" and (choosingSong or choosingSkin) then
        love.system.openURL("https://ko-fi.com/A0A8GRXMX")
    end

    if key == "o" then
        --[[
        if choosingSkin or choosingSong then -- currently unused
            state.switch(audioOffsetter)
        end
        --]]
    end

    --[[
    if key == "7" then
        scoring = {score=love.math.random(200000,1000000), ratingPercentLerp = love.math.randomFloat(0, 1),}
        combo=200
        state.switch(resultsScreen, scoring, {"Balls", "HARD"}, false, {{},{},{},{}}, {
            hits={{0, 100}, {20, 300}, {40,600}, {100, 1000}, {160, 20000}},
            songLength=200
        })
    end
    --]]
    if key == "f11" then
        __DEBUG__ = not __DEBUG__
    end
end

function love.draw()
    push.start()
    state:draw()
    if choosingSong or choosingSkin then
        -- set x and y to bottom left corner of screen
        love.graphics.print("Press K to open my Ko-fi page!\nPress R to open the replays menu", 1545, 1035, 0, 2, 2)
    end

    if volFade > 0 then
        volFade = volFade - 1 * love.timer.getDelta()
        -- draw vol slider in bottom right
        love.graphics.setColor(0, 0, 0, volFade - 0.4)
        love.graphics.rectangle("fill", 1800, 1020, 120, 60)
        love.graphics.setColor(1, 1, 1, volFade)
        -- set width based on audioVol
        love.graphics.rectangle("fill", 1800, 1020, audioVol * 1.2, 60)
        love.graphics.print(audioVol, 1820 - 2, 1030, 0, 2, 2)
        love.graphics.print(audioVol, 1820 + 2, 1030, 0, 2, 2)
        love.graphics.print(audioVol, 1820, 1030 - 2, 0, 2, 2)
        love.graphics.print(audioVol, 1820, 1030 + 2, 0, 2, 2)
        love.graphics.setColor(0, 0, 0, volFade)
        love.graphics.print(audioVol, 1820, 1030, 0, 2, 2)
        love.graphics.setColor(1, 1, 1, 1)
    end
    push.finish()

    if __DEBUG__ then debug.draw() end
end

function love.focus(f)
    state.focus(f)
end

function love.quit()
    if discordRPC then
        discordRPC.shutdown()
    end
end
