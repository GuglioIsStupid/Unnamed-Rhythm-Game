local platfroms = {
    desktop = {"Windows", "Linux", "OS X"},
    mobile = {"Android", "iOS"}
}

local currentOS = love.system.getOS()
local arch = jit.arch
local isDesktop = false
local isMobile = false
local isUnknown = true

for i = 1, #platfroms.desktop do
    if currentOS == platfroms.desktop[i] then
        isDesktop = true
        break
    end
end

for i = 1, #platfroms.mobile do
    if currentOS == platfroms.mobile[i] then
        isMobile = true
        break
    end
end

if isDesktop or isMobile then
    isUnknown = false
else
    debug.warn("UNKNOWN PLATFORM " .. jit.os)
end

function love.system.isDesktop()
    return isDesktop
end

function love.system.isMobile()
    return isMobile
end

function love.system.isUnknown()
    return isUnknown
end

function love.system.getOS(jitOS)
    if jitOS then
        return jitOS
    end
    return currentOS
end

function love.system.getArch()
    return arch
end