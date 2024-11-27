-- Skin (not) automatically generated using Rit's skin editor
Skin.Name = "Circle Default"
Skin.Creator = "Getsaa"
Skin.Description = "Rit's default skin"

Skin.HUD = {
    TopLeft = {
        members = {
            {
                type = "Text",
                x = 0,
                y = 0,
                
                format = "{math.floor(%d)}",
                value = "lerpedScore",
                font = nil,
                size = 24,
                color = {1, 1, 1, 1},
                printf = true,
                align = "right"
            },
            {
                type = "Text",
                x = 0,
                y = 28,

                format = "{string.format('%.2f', %d * 100)}%",
                value = "lerpedAccuracy",
                font = nil,
                size = 24,
                color = {1, 1, 1, 1},
                printf = true,
                align = "right"
            },
            {
                type = "Text",
                x = 0,
                y = 56,

                format = "{string.format('%.2f', %d)}",
                value = "lerpedPerformance",
                font = nil,
                size = 24,
                color = {1, 1, 1, 1},
                printf = true,
                align = "right"
            },
            --[[ {
                type = "Sprite",
                x = 1500,
                y = 0,
                path = "Game:Assets/Textures/test.png", -- when prefixed with "Game:", it will look for the file in the game's directory instead of the skin's directory
                scale = 0.15 -- scale can be a number or a table with x and y values
            } ]]
        }
    }
}

Skin.Notes = {}

for laneCount = 1, 10 do
    Skin.Notes[laneCount] = {}
    for curLane = 1, laneCount do
        Skin.Notes[laneCount][curLane] = {
            ["Note"] = "notes/" .. laneCount .. "K/note" .. curLane .. ".png",
            ["Hold"] = "notes/" .. laneCount .. "K/note" .. curLane .. "-hold.png",
            ["End"] = "notes/" .. laneCount .. "K/note" .. curLane .. "-end.png",

            ["Pressed"] = "notes/" .. laneCount .. "K/receptor" .. curLane .. "-pressed.png",
            ["Unpressed"] = "notes/" .. laneCount .. "K/receptor" .. curLane .. "-unpressed.png",
        }
    end
end

Skin.Combo = {}

for i = 0, 9 do
    Skin.Combo[i] = "combo/COMBO" .. i .. ".png"
end

Skin.Judgements = {
    ["miss"] = "judgements/MISS.png",
    ["bad"] = "judgements/BAD.png",
    ["good"] = "judgements/GOOD.png",
    ["great"] = "judgements/GREAT.png",
    ["perfect"] = "judgements/PERFECT.png",
    ["marvellous"] = "judgements/MARVELLOUS.png",
}

Skin.Sounds = {
    Hit = {
        ["hit"] = "sounds/sound-hit.wav",
        ["hitclap"] = "sounds/sound-hitclap.wav",
        ["hitwhistle"] = "sounds/sound-hitwhistle.wav",
        ["hitfinish"] = "sounds/sound-hitfinish.wav",
    }
}

Skin.Scripts = {}

Skin.Scripts.States = {
    TitleMenu = "scripts/states/TitleMenu.lua",
    SongListMenu = "scripts/states/SongListMenu.lua",
}
