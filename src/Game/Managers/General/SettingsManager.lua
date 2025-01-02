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
        Effects = 0.15,
        Music = 1,
    },
    Metadata = {
        SettingsVersion = 1
    }
}

function SettingsManager:migrate__ver0__settings(settings)
    -- Scrollspeed update
    -- update old scrollspeed system, to ms on screen
    local speed = settings.Game.ScrollSpeed
    local pixelsPerMS = (speed/10) / 5
    local msOnScreen = Game._windowHeight / pixelsPerMS

    settings.Game.ScrollSpeed = msOnScreen
    settings.Metadata.SettingsVersion = 1
end

function SettingsManager:checkVersion(ver)
    if ver then
        if ver < SettingsDefault.Metadata.SettingsVersion then
            return false
        end
    else
        return false
    end

    return true
end

function SettingsManager:loadSettings()
    local exists = love.filesystem.getInfo(tempSettingsFilePath)
    if exists then
        self._settings = Json.decode(love.filesystem.read(tempSettingsFilePath))

        local version = self._settings.Metadata and self._settings.Metadata.SettingsVersion or 0

        for category, settings in pairs(SettingsDefault) do
            for setting, value in pairs(settings) do
                if not self._settings[category] then
                    self._settings[category] = {}
                end
                if self._settings[category][setting] == nil then
                    self._settings[category][setting] = value
                end
            end
        end

        if not self:checkVersion(version) then
            -- version not correct. Update version from which one
            if version == 0 then
                self:migrate__ver0__settings(self._settings)
            end

            FileHandler:writeEncryptedFile(settingsFilePath, Json.encode(self._settings))
            love.filesystem.write(tempSettingsFilePath, Json.encode(self._settings))
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
        -- convert ms on screen to pixelsPerMS
        local speed = self._settings[category][setting]
        local pixelsPerMS = Game._windowHeight / speed
        return pixelsPerMS
    else
        return self._settings[category][setting]
    end
end

return SettingsManager