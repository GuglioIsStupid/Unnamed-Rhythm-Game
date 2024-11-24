local path = ... .. "."

local Parsers = {}

Parsers.Quaver = require(path .. "Quaver")
Parsers.Rit = require(path .. "Rit")
-- Parsers.RitM = require(path .. "Rit_M")
Parsers.Osu = require(path .. "Osu")
Parsers.Fluxis = require(path .. "Fluxis")

return Parsers
