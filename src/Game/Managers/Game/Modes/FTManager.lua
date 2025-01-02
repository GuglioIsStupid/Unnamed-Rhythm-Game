---@class FTManager

local FTManager = Group:extend("FTManager")
local GAME = States.Screens.Game

function FTManager:new(instance)
    Group.new(self)

    self.notes = {}

    self.screen = instance

    self.musicTime = -15000
    self.started = false
    self.currentTFT = 750

    self.judgeCounts = {
        ["marvellous"] = 0,
        ["perfect"] = 0,
        ["great"] = 0,
        ["good"] = 0,
        ["bad"] = 0,
        ["miss"] = 0
    }

    self.bpmEvents = {}
    self.exactBeat = 0
    self.currentBPM = 100
    self.currentBeat = 0
    self.currentBPMInterval = 60000 / self.currentBPM
    self.currentBPMTime = 0
    self.onBeat = false

    self.drawables = Group()
    self:add(self.drawables)

    self.previousFrameTime = nil
end

function FTManager:updateTime(dt)
    self.musicTime = self.musicTime + (self.previousFrameTime and (love.timer.getTime() - self.previousFrameTime) or 0) * 100000
    self.previousFrameTime = love.timer.getTime()
    if self.musicTime >= 0 and not self.started then
        self.started = true
        GAME.instance.song:play()
        Script:call("OnSongStart")
    end
end

function FTManager:update(dt)
    self.onBeat = false
    self:updateTime(dt)

    if self.musicTime >= 0 then
        if #self.bpmEvents > 0 and (self.musicTime/100) >= (self.bpmEvents[1][1] or math.inf) then
            self.currentBPM = self.bpmEvents[1][2]
            self.currentBPMInterval = 60000 / self.currentBPM
            self.currentBPMTime = 0
            table.remove(self.bpmEvents, 1)
        end
        self.currentBPMTime = self.currentBPMTime + dt * 1000
        if self.currentBPMTime >= self.currentBPMInterval then
            self.currentBeat = self.currentBeat + 1
            self.currentBPMTime = self.currentBPMTime - self.currentBPMInterval
            self.onBeat = true
        end
        self.exactBeat = (self.musicTime/100) / (60000 / self.currentBPM)
    end
    
    for i, event in ipairs(self.notes) do
        if event.StartTime < self.musicTime then
            if event.Ver == "TARGET" then
                local target = FTTarget(event, self)
                self.drawables:add(target)
                --print("Added target at: ", target.x, target.y, #self.drawables.objects, event.StartTime, self.musicTime)
            elseif event.Ver == "TARGET_FLYING_TIME" then
                self.currentTFT = event.TFT
                self.currentBPM = 240000 / self.currentTFT
                self.currentBPMInterval = 60000 / self.currentBPM
                self.currentBPMTime = 0
            end

            table.remove(self.notes, i)
        end
    end

    Group.update(self, dt)
end

return FTManager