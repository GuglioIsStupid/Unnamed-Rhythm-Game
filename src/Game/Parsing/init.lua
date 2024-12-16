local path = ... .. "."

local Parsers = {}

Parsers.Quaver = require(path .. "Quaver")
Parsers.Rit = require(path .. "Rit")
Parsers.Osu = require(path .. "Osu")
Parsers.Fluxis = require(path .. "Fluxis")
Parsers.Stepmania = require(path .. "Stepmania")

return Parsers
