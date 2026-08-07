---@class TempoDef
---@field offset? integer offset of music playback in milliseconds
---@field bpm number initial tempo in bpm 
---@field timeSig? integer initial time signature of song in beats per bar 
---@field timeSigs? table<integer, integer>

---@type table<Music, TempoDef>
local tempoDefs = {
    [Music.MUSIC_BASEMENT]              = {bpm = 140},
    [Music.MUSIC_CAVES]                 = {bpm = 120},
    [Music.MUSIC_DEPTHS]                = {bpm = 95},
    [Music.MUSIC_CELLAR]                = {bpm = 140},
    [Music.MUSIC_CATACOMBS]             = {bpm = 120},
    [Music.MUSIC_NECROPOLIS]            = {bpm = 120},
    [Music.MUSIC_WOMB_UTERO]            = {bpm = 90},
    [Music.MUSIC_GAME_OVER]             = {bpm = 85, timeSig = 3},
    [Music.MUSIC_BURNING_BASEMENT]      = {bpm = 140, timeSigs = {[2] = 4}},
}

return tempoDefs