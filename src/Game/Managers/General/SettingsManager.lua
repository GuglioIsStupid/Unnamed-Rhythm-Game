local SettingsManager = {}

local settingsFilePath = "CacheData/User/Settings.rs"
local tempSettingsFilePath = "CacheData/User/SettingsTemp.rs"

love.filesystem.createDirectory("CacheData/User")

local SettingsDefault = {
    Game = {
        ScrollSpeed = 70,
        ScrollDirection = "Down",
        keybinds = {
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
    },
    Audio = {
        Master = 1,
        Effects = 0.65,
        Music = 1,
    }
}

function SettingsManager:loadSettings()
    local exists = love.filesystem.getInfo(tempSettingsFilePath)
    if exists then
        self._settings = Json.decode(love.filesystem.read(tempSettingsFilePath))

        for category, settings in pairs(SettingsDefault) do
            for setting, value in pairs(settings) do
                if self._settings[category][setting] == nil then
                    self._settings[category][setting] = value
                end
            end
        end
    else
        FileHandler:writeEncryptedFile(settingsFilePath, Json.encode(SettingsDefault))
        love.filesystem.write(tempSettingsFilePath, Json.encode(SettingsDefault))

        self._settings = SettingsDefault
    end

    -- Apply keybinds
    for i, v in ipairs(self._settings.Game.keybinds) do
        local new = splitInputChars(v)
        for j, k in ipairs(new) do
            Input:replaceInput(i .. "k" .. j, {Key(k)})
        end
    end
end

function SettingsManager:getSetting(category, setting)
    if category == "Game" and setting == "ScrollSpeed" then
        local speed = self._settings[category][setting]
        -- the base game height is 1080
        -- the scrollspeed is made with 1080 in mind
        -- convert it properly to the current window height
        return (speed/10) / 5 * (1080/Game._windowHeight)
    else
        return self._settings[category][setting]
    end
end

return SettingsManager