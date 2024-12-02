local ResultsScreen = State:extend("ResultsScreen")

function ResultsScreen:new(data)
    State.new(self)

    print(data.score)
    self.score = data.score
    self.accuracy = data.accuracy
    self.performance = data.performance
    self.maxCombo = data.maxCombo
    self.judgement = data.judgement
    self.hitTimes = data.hitTimes

    -- Text() Args are: txt, x, y,nil, nil, font (Game.fonts["menuBold"]), nil, nil, nil, nil, nil
    self.scoreTxt = Text("Score: " .. math.floor(self.score), 0, 0, nil, nil, Game.fonts["menuBold"])
    self.accuracyTxt = Text("Accuracy: " .. string.format("%.2f", self.accuracy*100) .. "%", 0, 0, nil, nil, Game.fonts["menuBold"])
    self.performanceTxt = Text("Performance: " .. string.format("%.2f", self.performance*100), 0, 0, nil, nil, Game.fonts["menuBold"])
    self.maxComboTxt = Text("Max Combo: " .. self.maxCombo, 0, 0, nil, nil, Game.fonts["menuBold"])
    
    self.scoreTxt.x = 1920/2 - self.scoreTxt.width/2
    self.accuracyTxt.x = 1920/2 - self.accuracyTxt.width/2
    self.performanceTxt.x = 1920/2 - self.performanceTxt.width/2
    self.maxComboTxt.x = 1920/2 - self.maxComboTxt.width/2
    
    self.scoreTxt.y = 1080/2 - self.scoreTxt.height/2
    self.accuracyTxt.y = 1080/2 - self.accuracyTxt.height/2 + 64
    self.performanceTxt.y = 1080/2 - self.performanceTxt.height/2 + 128
    self.maxComboTxt.y = 1080/2 - self.maxComboTxt.height/2 + 192

    self:add(self.scoreTxt)
    self:add(self.accuracyTxt)
    self:add(self.performanceTxt)
    self:add(self.maxComboTxt)
end

return ResultsScreen