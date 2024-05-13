-- Painful way of adding all required inputs for the game

local k4Binds = Settings.options["General"]["k4Binds"]:splitAllCharacters()

input = (require "lib.baton").new({
    controls = {
        ["1k_game1"] = {"key:space"},

        ["2k_game1"] = { "key:f" },
        ["2k_game2"] = { "key:j" },

        ["3k_game1"] = { "key:d" },
        ["3k_game2"] = { "key:space" },
        ["3k_game3"] = { "key:j" },

        ["4k_game1"] = { "key:" .. string.lower(k4Binds[1]) },
        ["4k_game2"] = { "key:" .. string.lower(k4Binds[2]) },
        ["4k_game3"] = { "key:" .. string.lower(k4Binds[3]) },
        ["4k_game4"] = { "key:" .. string.lower(k4Binds[4]) },

        ["5k_game1"] = { "key:d" },
        ["5k_game2"] = { "key:f" },
        ["5k_game3"] = { "key:space" },
        ["5k_game4"] = { "key:j" },
        ["5k_game5"] = { "key:k" },

        ["6k_game1"] = { "key:s" },
        ["6k_game2"] = { "key:d" },
        ["6k_game3"] = { "key:f" },
        ["6k_game4"] = { "key:j" },
        ["6k_game5"] = { "key:k" },
        ["6k_game6"] = { "key:l" },

        ["7k_game1"] = { "key:s" },
        ["7k_game2"] = { "key:d" },
        ["7k_game3"] = { "key:f" },
        ["7k_game4"] = { "key:space" },
        ["7k_game5"] = { "key:j" },
        ["7k_game6"] = { "key:k" },
        ["7k_game7"] = { "key:l" },

        ["8k_game1"] = { "key:a" },
        ["8k_game2"] = { "key:s" },
        ["8k_game3"] = { "key:d" },
        ["8k_game4"] = { "key:f" },
        ["8k_game5"] = { "key:j" },
        ["8k_game6"] = { "key:k" },
        ["8k_game7"] = { "key:l" },
        ["8k_game8"] = { "key:;" },

        ["9k_game1"] = { "key:a" },
        ["9k_game2"] = { "key:s" },
        ["9k_game3"] = { "key:d" },
        ["9k_game4"] = { "key:f" },
        ["9k_game5"] = { "key:space" },
        ["9k_game6"] = { "key:j" },
        ["9k_game7"] = { "key:k" },
        ["9k_game8"] = { "key:l" },
        ["9k_game9"] = { "key:;" },

        ["10k_game1"] = { "key:a" },
        ["10k_game2"] = { "key:s" },
        ["10k_game3"] = { "key:d" },
        ["10k_game4"] = { "key:f" },
        ["10k_game5"] = { "key:v" },
        ["10k_game6"] = { "key:n" },
        ["10k_game7"] = { "key:j" },
        ["10k_game8"] = { "key:k" },
        ["10k_game9"] = { "key:l" },
        ["10k_game10"] = { "key:;" },

        -- UI
        up = { "key:up", "button:dpup", "axis:lefty-" },
        down = { "key:down", "button:dpdown", "axis:lefty+" },
        left = { "key:left", "button:dpleft", "axis:leftx-" },
        right = { "key:right", "button:dpright", "axis:leftx+" },

        confirm = { "key:return", "button:a" },
        back = { "key:escape", "button:back" },

        pause = { "key:return", "button:start" },
        --restart = { "key:r", "button:b" },

        -- Misc
        extB = { "button:back" },
        volUp = { "button:rightshoulder" },
        volDown = { "button:leftshoulder" },

        quit = { "key:escape", "button:back" },

        Skip_Key = { "key:space" }
    },
    joystick = love.joystick.getJoysticks()[1]
})

local defaultBinds = {
    ["1k"] = {
        input1 = "space"
    },
    ["2k"] = {
        input1 = "f",
        input2 = "j"
    },
    ["3k"] = {
        input1 = "d",
        input2 = "space",
        input3 = "j",
    },
    ["4k"] = {
        input1 = "d",
        input2 = "f",
        input3 = "j",
        input4 = "k",
    },
    ["5k"] = {
        input1 = "d",
        input2 = "f",
        input3 = "space",
        input4 = "j",
        input5 = "k",
    },
    ["6k"] = {
        input1 = "s",
        input2 = "d",
        input3 = "f",
        input4 = "j",
        input5 = "k",
        input6 = "l",
    },
    ["7k"] = {
        input1 = "s",
        input2 = "d",
        input3 = "f",
        input4 = "space",
        input5 = "j",
        input6 = "k",
        input7 = "l",
    },
    ["8k"] = {
        input1 = "a",
        input2 = "s",
        input3 = "d",
        input4 = "f",
        input5 = "j",
        input6 = "k",
        input7 = "l",
        input8 = ";",
    },
    ["9k"] = {
        input1 = "a",
        input2 = "s",
        input3 = "d",
        input4 = "f",
        input5 = "space",
        input6 = "j",
        input7 = "k",
        input8 = "l",
        input9 = ";",
    },
    ["10k"] = {
        input1 = "a",
        input2 = "s",
        input3 = "d",
        input4 = "f",
        input5 = "v",
        input6 = "n",
        input7 = "j",
        input8 = "k",
        input9 = "l",
        input10 = ";",
    },
}