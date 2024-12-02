local path = ... .. "."

Key = require(path .. "Key")
MouseButton = require(path .. "MouseButton")

Keyboard = require(path .. "Keyboard")
Mouse = require(path .. "Mouse")
InputClass = require(path .. "Input")

if love.system.isMobile() then
    VirtualPad = require(path .. "VirtualPad")

    VirtualPad.MenuPad = VirtualPad({
        {
            key = "return",
            size = {256, 256},
            position = {1920 - 256, 1080 - 256},
            color = {0, 0.5, 0},
            alpha = 0.25,
            downAlpha = 0.5,
            border = true
        },
        {
            key = "down",
            size = {128, 128},
            position = {128, 1080 - 256},
            color = {1, 1, 1},
            alpha = 0.25,
            downAlpha = 0.5,
            border = true
        },
        {
            key = "up",
            size = {128, 128},
            position = {128, 1080 - 384},
            color = {1, 1, 1},
            alpha = 0.25,
            downAlpha = 0.5,
            border = true
        },
        {
            key = "escape",
            size = {128, 128},
            position = {0, 1080 - 256},
            color = {1, 0, 0},
            alpha = 0.25,
            downAlpha = 0.5,
            border = true
        }
    })

    VirtualPad.GameplayPad = VirtualPad({
        {
        }
    })

    VirtualPad._CURRENT = VirtualPad.MenuPad
end

function splitInputChars(str)
    local t = {}
    for i = 1, #str do
        t[i] = str:sub(i, i)
        if t[i] == " " then
            t[i] = "space"
        end
    end
    return t
end

GameplayBinds = {
    " ",
    "fj",
    "f j",
    "dfjk",
    "df jk",
    "sdfjkl",
    "sdf jkl",
    "asdfjkl;",
    "asdf jkl;",
    "asdfvnjkl;"
}

local _splittedBinds = {}
for i = 1, #GameplayBinds do
    _splittedBinds[i] = splitInputChars(GameplayBinds[i])
end

local controlsTbl = {
    MenuDown = {
        Key("down"),
    },
    MenuUp = {
        Key("up"),
    },
    MenuBack = {
        Key("escape"),
    },
    MenuConfirm = {
        Key("return")
    },
    MenuSearch = {
        Key("\\")
    }
}

for i = 1, #GameplayBinds do
    for j = 1, i do
        controlsTbl[i .. "k" .. j] = {Key(_splittedBinds[i][j])}
    end
end
--[[ controlsTbl["26k"] ]]
local k26 = splitInputChars("qwertyuiopasdfghjklzxcvbnm,.")
for i = 1, #k26 do
    controlsTbl["26k" .. i] = {Key(k26[i])}
end

Input = InputClass(controlsTbl)
