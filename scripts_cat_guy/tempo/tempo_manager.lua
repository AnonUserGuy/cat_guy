local MILLISECONDS_PER_MINUTE = 60000
local MILLISECONDS_OFFSET = 90

local SFX_ID_RIMSHOT = Isaac.GetSoundIdByName("Rimshot")

local TRINKET_ID_TOY_METRONOME = Isaac.GetTrinketIdByName("Toy Metronome")

---@type PlayerUtils
local util = include("scripts_cat_guy.players.player_utils")

---@type table<Music, TempoDef>
local tempoDefs = include("scripts_cat_guy.tempo.tempo_defs")

---@class TempoManager
local tempoManager = {}

---@type TempoDef?
local tempoDef = nil

local lastTime = Isaac.GetTime()
local beat = 0.0
local timeSigCount = 0
local timeSigCurrent = 0
local offset = MILLISECONDS_OFFSET

---@param music MusicManager
---@param volume number
---@param isFade boolean
function tempoManager.PreMusicPlay(music, volume, isFade)
    tempoDef = tempoDefs[music]
    if tempoDef then
        beat = -0.0000001
        offset = MILLISECONDS_OFFSET + (tempoDef.offset or 0)
        timeSigCurrent = tempoDef.timeSig or (tempoDef.timeSigs and (tempoDef.timeSigs[0] or -1)) or 4
        timeSigCount = (tempoDef.timeSigs and not tempoDef.timeSigs[0] and -1) or 0
    end
end

---@param timeDelta integer time passed since last frame in milliseconds
function tempoManager.update(timeDelta)
    if not tempoDef then
        return
    end
    if offset > 0 then
        offset = offset - timeDelta
        if offset > 0 then
            return
        end
        timeDelta = timeDelta + offset
    end
    local beatDelta = timeDelta / MILLISECONDS_PER_MINUTE * tempoDef.bpm * MusicManager():GetCurrentPitch()

    local lastBeat = beat
    beat = beat + beatDelta
    if math.floor(beat) > math.floor(lastBeat) then
        local beatInt = math.floor(beat)
        if tempoDef.timeSigs and tempoDef.timeSigs[beatInt] then
            timeSigCurrent = tempoDef.timeSigs[beatInt]
            timeSigCount = 0
        end
        if timeSigCount == 0 then
            tempoManager.Tick(true)
            timeSigCount = timeSigCurrent
        else
            tempoManager.Tick()
        end
        timeSigCount = timeSigCount - 1
    end


end

function tempoManager.PostRender()
    local time = Isaac.GetTime()
    tempoManager.update(time - lastTime)
    lastTime = time
end

---@param measure? boolean
function tempoManager.Tick(measure)
    
    if util.AnyPlayer(function(player) return player:HasTrinket(TRINKET_ID_TOY_METRONOME) end) then
        SFXManager():Play(SFX_ID_RIMSHOT, 1, 2, false, measure and 1.25 or 1)
    end
end


return tempoManager