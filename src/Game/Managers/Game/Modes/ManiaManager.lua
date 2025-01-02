---@class ManiaManager
local ManiaManager = Group:extend("ManiaManager")
local GAME = States.Screens.Game

function ManiaManager:new(instance)
    Group.new(self)

    self.receptorsGroup = TypedGroup(Receptor)
    self.underlay = Underlay(4)

    self.hitObjects = {}
    self.drawableHitObjects = {}
    self.scrollVelocities = {}
    self.scrollVelocityMarks = {}
    self.musicTime = -1500
    self.currentTime = 0

    self.svIndex = 1
    self.STRUM_Y_DOWN = 1080-225
    self.STRUM_Y_UP = 25

    self.screen = instance
    self.scorePerNote = 0
    self.accuracy = 1

    self.started = false

    self.initialSV = 1
    self.length = self.screen.data.length

    self.data = {
        mode = 4
    }

    self.hasModscript = false

    self.judgeCounts = {
        ["marvellous"] = 0,
        ["perfect"] = 0,
        ["great"] = 0,
        ["good"] = 0,
        ["bad"] = 0,
        ["miss"] = 0
    }

    self.hitSound = love.audio.newSource(Skin:getPath(Skin.Sounds.Hit["hit"]), "static")
    self.hitSound:setVolume(SettingsManager:getSetting("Audio", "Effects"))
    self.whistleSound = love.audio.newSource(Skin:getPath(Skin.Sounds.Hit["hitwhistle"]), "static")
    self.whistleSound:setVolume(SettingsManager:getSetting("Audio", "Effects"))
    self.finishSound = love.audio.newSource(Skin:getPath(Skin.Sounds.Hit["hitfinish"]), "static")
    self.finishSound:setVolume(SettingsManager:getSetting("Audio", "Effects"))
    self.clapSound = love.audio.newSource(Skin:getPath(Skin.Sounds.Hit["hitclap"]), "static")
    self.clapSound:setVolume(SettingsManager:getSetting("Audio", "Effects"))

    self.playfields = {}
        
    self.playfields[1] = ManiaPlayfield(self, self.underlay, self.receptorsGroup)

    for i = 1, #self.playfields do
        self:add(self.playfields[i])
    end

    self.bpmEvents = {}
    self.exactBeat = 0
    self.currentBPM = 100
    self.currentBeat = 0
    self.currentBPMInterval = 60000 / self.currentBPM
    self.currentBPMTime = 0
    self.onBeat = false

    self.previousFrameTime = nil

    local curkeylist = GameplayBinds[self.data.mode]
    if love.system.isMobile() then
        local keys = {}
        for i, key in ipairs(string.splitAllChars(curkeylist)) do
            -- calculate size and position for the mobile button (1920 width, at bottom of screen)
            local size = {1920 / #curkeylist, 1080 / 2}
            local position = {(i - 1) * size[1], 1080 - size[2]}
            local color = {1, 1, 1}
            local alpha = 0.25
            local downAlpha = 0.5
            local border = true
            
            table.insert(keys, {
                key = key,
                size = size,
                position = position,
                color = color,
                alpha = alpha,
                downAlpha = downAlpha,
                border = border
            })
        end

        VirtualPad.GameplayPad = VirtualPad(keys)
        VirtualPad._CURRENT = VirtualPad.GameplayPad
    end
end

local midX = 1920/2.45

function ManiaManager:createReceptors(count)
    self.data = {mode = 4}
    self.data.mode = count
    local lastX, lastWidth = 0, 0
    local dir = SettingsManager:getSetting("Game", "ScrollDirection")
    for i = 1, self.data.mode do
        local receptor = Receptor(i, count)
        --receptor.y = self.STRUM_Y
        if not self.hasModscript then
            receptor.y = dir == "Down" and self.STRUM_Y_DOWN or self.STRUM_Y_UP
            if dir == "Split" then
                receptor.y = i <= math.ceil(self.data.mode/2) and self.STRUM_Y_DOWN or self.STRUM_Y_UP
            elseif dir == "Alternate" then
                receptor.y = i % 2 == 0 and self.STRUM_Y_DOWN or self.STRUM_Y_UP
            end
        else
            receptor.y = Script.downscroll and self.STRUM_Y_DOWN or self.STRUM_Y_UP
        end
        receptor.x = midX + (i - (self.data.mode/2)) * 200
        lastX = receptor.x
        lastWidth = receptor.width
        self.receptorsGroup:add(receptor)
    end

    self.underlay:updateCount(count, lastX, lastWidth)
    self.underlay:resize(Game._windowWidth, Game._windowHeight)

    self:resortReceptors()
end

function ManiaManager:resortReceptors()
    -- sometimes positions get messed up
    local dir = SettingsManager:getSetting("Game", "ScrollDirection")
    for i = 1, self.data.mode do
        -- sort based off of underlay width and pos
        local receptor = self.receptorsGroup.objects[i]
        receptor.x = self.underlay.x + ((i-1) * 200)
        if not self.hasModscript then
            receptor.y = dir == "Down" and self.STRUM_Y_DOWN or self.STRUM_Y_UP
            if dir == "Split" then
                receptor.y = i <= math.ceil(self.data.mode/2) and self.STRUM_Y_DOWN or self.STRUM_Y_UP
            elseif dir == "Alternate" then
                receptor.y = i % 2 == 0 and self.STRUM_Y_DOWN or self.STRUM_Y_UP
            end
        else
            receptor.y = Script.downscroll and self.STRUM_Y_DOWN or self.STRUM_Y_UP
        end
        receptor:update(love.timer.getDelta())
    end
end

function ManiaManager:isOnScreen(time, lane)
    return self:getNotePosition(self:getPositionFromTime(time), lane, true) >= -500
end

function ManiaManager:initSVMarks()
    if #self.scrollVelocities < 1 then
        return
    end

    local first = self.scrollVelocities[1]

    local time = first.StartTime
    table.insert(self.scrollVelocityMarks, time)

    for i = 2, #self.scrollVelocities do
        local prev = self.scrollVelocities[i - 1]
        local current = self.scrollVelocities[i]

        time = time + (current.StartTime - prev.StartTime) * prev.Multiplier
        table.insert(self.scrollVelocityMarks, time)
    end
end

function ManiaManager:getPositionFromTime(time, index)
    index = index or -1

    if index == -1 then
        for i = 1, #self.scrollVelocities do
            if time < self.scrollVelocities[i].StartTime then
                index = i
                break
            else
                index = 1
            end
        end
    end

    if index == 1 then
        return time * self.initialSV
    end
    
    local previous = self.scrollVelocities[index-1] or ScrollVelocity(0, 1)

    local pos = self.scrollVelocityMarks[index-1] or 0
    pos = pos + (time - previous.StartTime) * previous.Multiplier

    return pos
end

function ManiaManager:getNotePosition(time, lane, moveWithScroll)
    local dir = SettingsManager:getSetting("Game", "ScrollDirection")
    if not self.hasModscript then
        if not moveWithScroll then
            if dir == "Split" then
                if lane <= math.ceil(self.data.mode/2) then
                    return self.STRUM_Y_DOWN, true
                else
                    return self.STRUM_Y_UP, false
                end
            elseif dir == "Alternate" then
                if lane % 2 == 0 then
                    return self.STRUM_Y_DOWN, true
                else
                    return self.STRUM_Y_UP, false
                end
            elseif dir == "Down" then
                return self.STRUM_Y_DOWN, true
            elseif dir == "Up" then
                return self.STRUM_Y_UP, false
            end
        end
        if dir == "Down" then
            return self.STRUM_Y_DOWN - (time - self.currentTime) * SettingsManager:getSetting("Game", "ScrollSpeed"), true
        elseif dir == "Up" then
            return self.STRUM_Y_UP + (time - self.currentTime) * SettingsManager:getSetting("Game", "ScrollSpeed"), false
        elseif dir == "Split" then
            if lane <= math.ceil(self.data.mode/2) then
                return self.STRUM_Y_DOWN - (time - self.currentTime) * SettingsManager:getSetting("Game", "ScrollSpeed"), true
            else
                return self.STRUM_Y_UP + (time - self.currentTime) * SettingsManager:getSetting("Game", "ScrollSpeed"), false
            end
        elseif dir == "Alternate" then
            if lane % 2 == 0 then
                return self.STRUM_Y_DOWN - (time - self.currentTime) * SettingsManager:getSetting("Game", "ScrollSpeed"), true
            else
                return self.STRUM_Y_UP + (time - self.currentTime) * SettingsManager:getSetting("Game", "ScrollSpeed"), false
            end
        end
    else
        if not moveWithScroll then
            if Script.downscroll then
                return self.STRUM_Y_DOWN, true
            else
                return self.STRUM_Y_UP, false
            end
        else
            if Script.downscroll then
                return self.STRUM_Y_DOWN - (time - self.currentTime) * SettingsManager:getSetting("Game", "ScrollSpeed"), true
            else
                return self.STRUM_Y_UP + (time - self.currentTime) * SettingsManager:getSetting("Game", "ScrollSpeed"), false
            end
        end
    end
end 

function ManiaManager:updateTime(dt)
    self.musicTime = self.musicTime + (self.previousFrameTime and (love.timer.getTime() - self.previousFrameTime) or 0) * 1000
    self.previousFrameTime = love.timer.getTime()
    if self.musicTime >= 0 and not self.started then
        self.started = true
        GAME.instance.song:play()
        Script:call("OnSongStart")
    end

    while (self.svIndex <= #self.scrollVelocities and self.musicTime >= self.scrollVelocities[self.svIndex].StartTime) do
        self.svIndex = self.svIndex + 1
    end

    self.currentTime = self:getPositionFromTime(self.musicTime, self.svIndex)
end

function ManiaManager:resize(w, h)
    Group.resize(self, w, h)
    self:resortReceptors()
end

function ManiaManager:update(dt)
    self.onBeat = false
    self:updateTime(dt)

    for _, receptor in ipairs(self.receptorsGroup.objects) do
        local dir = SettingsManager:getSetting("Game", "ScrollDirection")
        if not self.hasModscript then
            receptor.y = dir == "Down" and self.STRUM_Y_DOWN or self.STRUM_Y_UP
            if dir == "Split" then
                receptor.y = i <= math.ceil(self.data.mode/2) and self.STRUM_Y_DOWN or self.STRUM_Y_UP
            elseif dir == "Alternate" then
                receptor.y = i % 2 == 0 and self.STRUM_Y_DOWN or self.STRUM_Y_UP
            end
        else
            receptor.y = Script.downscroll and self.STRUM_Y_DOWN or self.STRUM_Y_UP
        end
        receptor:update(love.timer.getDelta())
    end

    if self.musicTime >= 0 then
        if #self.bpmEvents > 0 and self.musicTime >= (self.bpmEvents[1][1] or math.inf) then
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
        self.exactBeat = self.musicTime / (60000 / self.currentBPM)

        --[[ if self.onBeat and self.currentBeat % 4 == 0 then
            print(string.format("Beat modulo 4, %s, %s, %s", self.currentBeat, self.currentBPM, self.exactBeat))
        end ]]
    end

    while #self.hitObjects > 0 and self:isOnScreen(self.hitObjects[1].StartTime, self.hitObjects[1].Lane) do
        local hitObject = self.hitObjects[1]
        local drawableHitObject = HitObject(hitObject, self.data.mode)

        drawableHitObject.x = self.receptorsGroup.objects[hitObject.Lane].x
        drawableHitObject.initialSVTime = self:getPositionFromTime(hitObject.StartTime)
        drawableHitObject.endSVTime = self:getPositionFromTime(hitObject.EndTime)
        drawableHitObject.y = self:getNotePosition(drawableHitObject.initialSVTime, drawableHitObject.Data.Lane, drawableHitObject.moveWithScroll)
        drawableHitObject:resize(Game._windowWidth, Game._windowHeight)
        
        for i = 1, #self.playfields do
            self.playfields[i]:add(drawableHitObject, false)
        end

        table.insert(self.drawableHitObjects, drawableHitObject)
        table.remove(self.hitObjects, 1)
    end

    for _, hitObject in ipairs(self.drawableHitObjects) do
        hitObject.y = self:getNotePosition(hitObject.initialSVTime, hitObject.Data.Lane, hitObject.moveWithScroll)
        local goinDown = false
        hitObject.endY, goinDown = self:getNotePosition(hitObject.Data.EndTime, hitObject.Data.Lane, true)
        if goinDown and hitObject.holdSprite then
            hitObject.holdSprite.child.flip.y = true
        end

        if self.musicTime > hitObject.Data.StartTime+150 and hitObject.moveWithScroll then
            for i = 1, #self.playfields do
                self.playfields[i]:remove(hitObject)
            end
            hitObject:destroy()
            table.remove(self.drawableHitObjects, table.findID(self.drawableHitObjects, hitObject))
            self.screen.judgement:hit(1000)
        end
    end

    for i = 1, self.data.mode do
        if Input:wasPressed(self.data.mode .. "k" .. i) then
            Script:call("OnPress", i, self.musicTime)
            if not self.receptorsGroup.objects[i] then return end
            self.receptorsGroup.objects[i].down = true
            local note = nil
            for _, hitObject in ipairs(self.drawableHitObjects) do
                local abs = math.abs(self.musicTime - hitObject.Data.StartTime)
                if abs < 360 and hitObject.Data.Lane == i then
                    note = hitObject
                    break
                end
            end

            if note then
                note:hit(self.musicTime - note.Data.StartTime)
                Script:call("OnHit", i, self.musicTime, note, self.screen.combo)
                if not note.holdSprite then
                    for i = 1, #self.playfields do
                        self.playfields[i]:remove(note)
                    end
                    note:destroy()
                    table.remove(self.drawableHitObjects, table.findID(self.drawableHitObjects, note))
                else
                    note.moveWithScroll = false
                end
            else
                self.hitSound:clone():play()
            end
        end
        if Input:isDown(self.data.mode .. "k" .. i) then
            for _, hitObject in ipairs(self.drawableHitObjects) do
                if hitObject.Data.Lane == i and hitObject.holdSprite and hitObject.holdSprite.endTime - self.musicTime <= 50 then
                    for i = 1, #self.playfields do
                        self.playfields[i]:remove(hitObject)
                    end
                    hitObject:destroy()
                    table.remove(self.drawableHitObjects, table.findID(self.drawableHitObjects, hitObject))
                end
            end
        end
        if Input:wasReleased(self.data.mode .. "k" .. i) then
            if not self.receptorsGroup.objects[i] then return end
            self.receptorsGroup.objects[i].down = false

            for _, hitObject in ipairs(self.drawableHitObjects) do
                if hitObject.Data.Lane == i then
                    if not hitObject.moveWithScroll then
                        for i = 1, #self.playfields do
                            self.playfields[i]:remove(hitObject)
                        end
                        hitObject:destroy()
                        table.remove(self.drawableHitObjects, table.findID(self.drawableHitObjects, hitObject))
                    end
                end
            end
        end
    end

    Script:call("OnUpdate", dt, self.musicTime)

    if (self.musicTime or 0) > ((self.length or 1000)+500) then
        Script:call("OnSongEnd")
        Game:SwitchState(Skin:getSkinnedState("ResultsScreen"), {
            score = self.screen.score,
            accuracy = self.screen.accuracy,
            performance = self.screen.performance,
            maxCombo = self.screen.maxCombo,
            judgement = {
                self.judgeCounts["marvellous"],
                self.judgeCounts["perfect"],
                self.judgeCounts["great"],
                self.judgeCounts["good"],
                self.judgeCounts["bad"],
                self.judgeCounts["miss"]
            },
            hitTimes = {} -- TODO: Add hit times
        })
    end
    Group.update(self, dt)
end

return ManiaManager
