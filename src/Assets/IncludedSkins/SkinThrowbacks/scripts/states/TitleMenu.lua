local TitleMenu = State:extend("TitleMenu")

local curLogoScale = 0.65
local bpm = 100 -- to be determined when we have a song lol
local curBeat = 0
local beatTime = 60 / bpm

function TitleMenu:new()
    State.new(self)

    self.bg = Sprite("Assets/Textures/Menu/PlayBG.png", 0, 0, true)
    self.bg.scalingType = ScalingTypes.WINDOW_LARGEST
    self.bg:resize(Game._windowWidth, Game._windowHeight)
    self.bg.zorder = -1
    self:add(self.bg)

    self.BGBubbles = BGBubbles:get()
    self.BGBubbles.zorder = 0
    self:add(self.BGBubbles)

    self.logo = VertexSprite("Assets/Textures/Menu/Logo.png", 50, 150, 4)
    self.logo:centerOrigin()
    self.logo:setScale(curLogoScale, curLogoScale)
    self.logo.zorder = 1

    self:add(self.logo)

    self.buttonsGroup = TypedGroup(TitleButton)
    self.buttonsGroup.zorder = 2
    self:add(self.buttonsGroup)

    self.playButton = TitleButton("Play", "Assets/Textures/Menu/Buttons/PlayBtn.png", "Assets/Textures/Menu/Buttons/BigBtnBorder.png", 1250, 300, function()
        Game:SwitchState(Skin:getSkinnedState("SongListMenu"))
    end)
    self.playButton:setScale(1.35, 1.35)
    self.ohButton = TitleButton("Online\nHub", "Assets/Textures/Menu/Buttons/OhBtn.png", "Assets/Textures/Menu/Buttons/BigBtnBorder.png", 1550, 300, function()
        debug.warn("Online Hub is not currently implemented")
    end)
    self.ohButton:setScale(1.35, 1.35)

    self.buttonsGroup:add(self.playButton)
    self.buttonsGroup:add(self.ohButton)

    self:add(Header)

    if DiscordRPC then
        DiscordRPC.presence = {
            details = "In the menu",
            state = "",
            largeImageKey = "totallyreallogo",
            largeImageText = "Rit" .. (Game.debug and " - Debug" or ""),
        }
        DiscordRPC.updatePresence()
    end
end

local lastMX, lastMY = 0, 0
function TitleMenu:update(dt)

    local mx, my = love.mouse.getPosition()
    local paralaxStrength = 100
    local pmx, pmy = mx - lastMX, my - lastMY
    self.logo.x, self.logo.y = self.logo.x + -pmx / paralaxStrength, self.logo.y + -pmy / paralaxStrength
    State.update(self, dt)

    curBeat = curBeat + dt
    if curBeat >= beatTime then
        curBeat = 0
        curLogoScale = 0.7
    end
    self.logo:setScale(curLogoScale, curLogoScale)

    if curLogoScale > 0.65 then
        curLogoScale = math.fpsLerp(curLogoScale, 0.65, 5, dt)
    end

    lastMX, lastMY = mx, my
end

function TitleMenu:mousemoved(x, y, dx, dy, istouch)
    State.mousemoved(self, x, y, dx, dy, istouch)
end

return TitleMenu
