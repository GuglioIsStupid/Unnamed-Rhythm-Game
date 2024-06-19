local SaveUserData = {}

local compressionAlgorithm = "zlib"

local defaultUserDataModal = {
    allRatings = {},

    OverallRating = 0,
    averageAccuracy = 0, -- actually stored as an altogether accuracy of ALL plays. We calculate the average on the fly
    totalScore = 0,
    plays = 0,
    totalHits = 0,
        
    wins = 0,
    losses = 0
}

function SaveUserData.SaveData(data, path)
    local path = path or "data/userdata.dat"
    local data = json.encode(data)
    local compressedData = love.data.compress("string", compressionAlgorithm, data, 9)
    love.filesystem.write(path, compressedData)
end

function SaveUserData.LoadData(path)
    local ok, v = Try(
        function()
            local path = path or "data/userdata.dat"
            local compressedData = love.filesystem.read(path)
            local data = love.data.decompress("string", compressionAlgorithm, compressedData)

            local data = json.decode(data)

            for k, v in pairs(defaultUserDataModal) do
                if data[k] == nil then
                    data[k] = v
                end
            end

            for k, v in pairs(defaultUserDataModal) do
                if type(data[k]) ~= type(v) then
                    data[k] = v
                end
            end

            data.OverallRating = 0
            for i, v in ipairs(data.allRatings) do
                data.OverallRating = data.OverallRating + v * math.pow(0.9, i - 1)
            end

            return data
        end,
        function()
            SaveUserData.SaveData(defaultUserDataModal)
            --print("No user data found, creating new one")

            return SaveUserData.LoadData()
        end
    )

    return v
end

return SaveUserData