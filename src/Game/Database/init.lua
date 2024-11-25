local Database = {} 
function Database:getDBs()
    if not love.filesystem.getInfo(love.filesystem.getSaveDirectory() .. "/CacheData/BeatmapsList.db") then
        self.BeatmapDB = Sqlite3.open(love.filesystem.getSaveDirectory() .. "/CacheData/BeatmapsList.db")
        -- setup
        self.BeatmapDB:exec(
            [[CREATE TABLE IF NOT EXISTS Beatmaps (
                filename TEXT PRIMARY KEY,
                ogpath TEXT,
                fileext TEXT,

                title TEXT,
                artist TEXT,
                source TEXT,
                tags TEXT,
                creator TEXT,
                diff_name TEXT,
                description TEXT,
                path TEXT,
                audio_path TEXT,
                bg_path TEXT,
                preview_time INTEGER,
                mapset_id INTEGER,
                map_id INTEGER,
                mode INTEGER,
                game_mode TEXT,
                map_type TEXT,
                hitobj_count INTEGER,
                ln_count INTEGER,
                length INTEGER,
                metaType INTEGER,
                difficulty REAL,
                nps REAL
            )]]
        )
    else
        self.BeatmapDB = Sqlite3.open(love.filesystem.getSaveDirectory() .. "/CacheData/BeatmapsList.db")
    end

    print(self.BeatmapDB)
end

function Database:closeDBs()
    if self.BeatmapDB then
        self.BeatmapDB:close()
    end
end

return Database