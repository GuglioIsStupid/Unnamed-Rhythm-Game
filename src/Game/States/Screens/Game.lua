---@diagnostic disable: duplicate-set-field, inject-field
---@class GameScreen : State
local GameScreen = State:extend("GameScreen")

function GameScreen:new(data)
    State.new(self)
    GameScreen.instance = self

    local folderPath = data.path:match("(.+)/[^/]+$") .. "/"

    self.data = {
        filepath = data.path,
        folderpath = folderPath,
        mapType = data.map_type,
        length = data.length,
        path = "",
        folder = "",
        noteCount = 0,
        gameMode = data.game_mode,
        hitObjects = {},
        scrollVelocities = {},
        rating = tonumber(data.difficulty),
    }

    print(self.data.gameMode)

    if self.data.gameMode == "Mania" then
        self.GameManager = ManiaManager(self)
    elseif self.data.gameMode == "FT" then
        self.GameManager = FTManager(self)
    end

    Parsers[self.data.mapType]:parse(self.data.filepath, folderPath)

    self.song = love.audio.newSource(self.data.song, "static")
    --[[ print(self.song:getDuration())
    self.song:setPitch(2) ]]
    if self.song:getChannelCount() == 4 then
        self.song:setPitch(2)
    end
    if self.data.gameMode == "Mania" then
        self.GameManager.hitObjects = self.data.hitObjects
        self.GameManager.scrollVelocities = self.data.scrollVelocities
        self.GameManager:initSVMarks()

        table.sort(self.GameManager.hitObjects, function(a, b) return a.StartTime < b.StartTime end)
        self.GameManager.scorePerNote = 1000000 / #self.data.hitObjects
        self.totalNotes = #self.data.hitObjects
    elseif self.data.gameMode == "FT" then
        self.GameManager.notes = self.data.hitObjects

        table.sort(self.GameManager.notes, function(a, b) return a.StartTime < b.StartTime end)
        self.GameManager.scorePerNote = 1000000 / #self.GameManager.notes
        self.totalNotes = #self.GameManager.notes
    end

    if self.data.gameMode == "Mania" then
        self.GameManager:createReceptors(self.data.mode)
        Script:reset(self.GameManager.receptorsGroup.objects)
        Script:load(folderPath .. "script/script.lua")
    end

    Script:call("Load")

    self.BG = Background(self.data.bgFile)
    self.BG.zorder = -10
    self:add(self.BG)
    self.BG.scalingType = ScalingTypes.WINDOW_LARGEST

    self:add(self.GameManager)

    self.HUD = HUD(self)
    self:add(self.HUD)

    self.score = 0
    self.accuracy = 0
    self.combo = 0
    self.maxCombo = 0
    self.rated = 0
    self.performance = 0

    self.lerpedScore = 0
    self.lerpedAccuracy = 0
    self.lerpedPerformance = 0

    self.judgement = Judgement()
    self.judgement.zorder = 999
    self.comboDisplay = Combo()
    self.comboDisplay.zorder = 1000
    self:add(self.judgement)
    self:add(self.comboDisplay)
end

function GameScreen:update(dt)
    State.update(self, dt)

    if not self.calculateManiaRating then
        return
    end

    if self.data.gameMode == "Mania" then
        self:calculateManiaAccuracy()
        self:calculateManiaScore()
        self:calculateManiaRating()
    end
    
    self.lerpedScore = math.fpsLerp(self.lerpedScore, self.score or 0, 25, dt)
    self.lerpedAccuracy = math.fpsLerp(self.lerpedAccuracy, self.accuracy or 1, 25, dt)
    self.lerpedPerformance = math.fpsLerp(self.lerpedPerformance, self.rating or 0, 25, dt)
    if tostring(self.lerpedScore):match("nan") then
        self.lerpedScore = 0
    end
    if tostring(self.lerpedAccuracy):match("nan") then
        self.lerpedAccuracy = 0
    end
    if tostring(self.lerpedPerformance):match("nan") then
        self.lerpedPerformance = 0
    end
end

--- Use judgecount and total notes hit to calculate accuracy
function GameScreen:calculateManiaAccuracy()
    local judgeCount = self.GameManager.judgeCounts
    local totalNotesHit = judgeCount["marvellous"] +
        judgeCount["perfect"] +
        judgeCount["great"] +
        judgeCount["good"] +
        judgeCount["bad"] +
        judgeCount["miss"]

    self.rated = (
        judgeCount["marvellous"] * 1 +
        judgeCount["perfect"] * 0.98 +
        judgeCount["great"] * 0.85 +
        judgeCount["good"] * 0.67 +
        judgeCount["bad"] * 0.5
    ) / totalNotesHit
    
    self.accuracy = self.rated
end

--- Calculates the score based on both the accuracy and the combo
--- 
--- 85% of the score is accuracy-based
--- 
--- 15% of the score is combo-based
function GameScreen:calculateManiaScore()
    local leMax = 1000000 * ModifierManager:getScoreMultiplier()

    local accScore = self.rated / self.totalNotes * (leMax * 0.85)
    local comboScore = self.maxCombo / self.totalNotes * (leMax * 0.15)

    self.score = accScore + comboScore
end

function GameScreen:calculateManiaRating()
    self.rating = self.data.rating * math.pow(self.accuracy / (95/100), 4.75)
end

function GameScreen:kill()
    State.kill(self)
    self = nil
    if VirtualPad then
        VirtualPad._CURRENT = VirtualPad.MenuPad
    end
end

return GameScreen
