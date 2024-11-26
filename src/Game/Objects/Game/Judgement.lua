local Judgement = Sprite:extend("Judgement")

Judgement.data = {
    {
        name = "marvellous", img = nil,
        time = 23, forLN = true, colour = {1, 1, 1}
    },
    {
        name = "perfect", img = nil,
        time = 40, forLN = true, colour = {1, 1, 1}
    },
    {
        name = "great", img = nil,
        time = 74, forLN = true, colour = {1, 1, 1}
    },
    {
        name = "good", img = nil,
        time = 103, forLN = false, colour = {1, 1, 1}
    },
    {
        name = "bad", img = nil,
        time = 127, forLN = false, colour = {1, 1, 1}
    },
    {
        name = "miss", img = nil,
        time = 160, forLN = false, colour = {1, 1, 1}
    },
}

function Judgement:new()
    Sprite.new(self, nil, 0, 0, false)

    self.visible = false

    self:screenCenter("XY")
    self.zorder = 1000

    -- setup judgement img's
    for _, data in ipairs(Judgement.data) do
        data.img = Skin._judgementAssets[data.name]
    end
    self.timer = 1
end

function Judgement:hit(time)
    local absTime = math.abs(time)
    local judgename = "miss"
    self.image = nil
    self:setImage(Skin._judgementAssets["miss"])
    for _, data in ipairs(Judgement.data) do
        if absTime < data.time then
            self:setImage(data.img)
            judgename = data.name
            break
        end
    end

    self:screenCenter("XY")
    self:centerOrigin()
    self.visible = true
    self.alpha = 1
    self.timer = 0.5
    self.scale.x, self.scale.y = 1.1, 1.1
    self.y = self.y - 75

    if judgename == "miss" then
        States.Screens.Game.instance.combo = 0
    else
        States.Screens.Game.instance.combo = States.Screens.Game.instance.combo + 1
        States.Screens.Game.instance.maxCombo = math.max(States.Screens.Game.instance.maxCombo, States.Screens.Game.instance.combo)
    end

    States.Screens.Game.instance.GameManager.judgeCounts[judgename] = States.Screens.Game.instance.GameManager.judgeCounts[judgename] + 1
end

function Judgement:update(dt)
    if self.scale.x > 1 then
        self.scale.x = self.scale.x - 1 * dt
        self.scale.y = self.scale.x
    end
    self.timer = self.timer - 1 * dt
    if self.timer <= 0 then
        self.alpha = self.alpha - 1 * dt
    end

    Sprite.update(self, dt)
end

function Judgement:getJudgementData()
    local cur
    for i, data in ipairs(Judgement.data) do
        if self.image == data.img then
            cur = data
            break
        end
    end

    return cur
end

return Judgement
