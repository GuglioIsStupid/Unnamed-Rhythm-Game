local path = (... .. "/"):gsub('%.', '/')

LoadAudio = love.thread.newThread(path .. "LoadAudio.lua")

NetworkingClientThread = love.thread.newThread(path .. "Networking/Client.lua")
