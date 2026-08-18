local MILLISECONDS_PER_MINUTE = 60000
local TWO_THIRDS = 2/3

---@class TempoManager
---@field tempoDefs table<Music, TempoDef>
---@field beat number strictly increasing beat number
---@field beatMusic number beat number relative to music
local TempoManager = {}

---@param tempoDefs? table<Music, TempoDef>
---@param vanillaMusicXML? table<Music, MusicXMLNode>
---@return TempoManager
function TempoManager:New(tempoDefs, vanillaMusicXML)
    local instance = setmetatable({}, self)
    self.__index = self

    instance.tempoDefs = {}
    if tempoDefs then
        if vanillaMusicXML then
            tempoDefs = instance:ValidateTempoDefs(tempoDefs, vanillaMusicXML)
        end
        instance:RegisterTempoDefs(tempoDefs)
    end

    instance.tempoDef = nil

    instance.time = 0
    instance.bpmIndex = 0

    instance.beat = 0
    instance.beatMusic = 0
    instance.timeSigCount = 0
    instance.timeSigCurrent = 0
    instance.triplet = false

    instance.lastSysTime = Isaac.GetTime()

    return instance
end

---@param music Music
---@param tempoDef TempoDef
function TempoManager:RegisterTempoDef(music, tempoDef)
    if not self.tempoDefs[music] or (self.tempoDefs[music].priority or 0.0) <= (tempoDef.priority or 0.0) then
        self.tempoDefs[music] = tempoDef
    end
end

---@param tempoDefs table<Music, TempoDef>
function TempoManager:RegisterTempoDefs(tempoDefs)
    for music, tempoDef in pairs(tempoDefs) do
        self:RegisterTempoDef(music, tempoDef)
    end
end

--- TODO: add various music mods compatibility (probably stuff like OG isaac music or antibirth music)
--- 
--- Creates a new tempoDefs table, does not modify original tempoDefs table
---@param tempoDefs table<Music, TempoDef>
---@param vanillaMusicXML table<Music, MusicXMLNode>
function TempoManager:ValidateTempoDefs(tempoDefs, vanillaMusicXML)
    local out = {} ---@type table<Music, TempoDef>
    for music, tempoDef in pairs(tempoDefs) do
        local vanillaMusicXMLNode = vanillaMusicXML[music]
        local musicXMLNode = XMLData.GetEntryById(XMLNode.MUSIC, music) ---@type MusicXMLNode
        if vanillaMusicXMLNode and musicXMLNode then
            if musicXMLNode.path == vanillaMusicXMLNode.path
            and musicXMLNode.intro == vanillaMusicXMLNode.intro then
                print(music.." valid!")
                out[music] = tempoDef
            else
                print(music.." replaced!")
            end
        else
            out[music] = tempoDef
        end
    end
    return out
end

---@param music Music
function TempoManager:PreMusicPlay(music)
    local def = self.tempoDefs[music] ---@type TempoDef?
    if def and def.bpm then
        self.tempoDef = def
        self:PrepareTempoDef(def)
        self.time = 0
        self.beat = -(def.beatOffset or 0.000001)
        self.beatMusic = self.beat
        self.bpmIndex = 0
        self.timeSigCurrent = def.timeSig or (def.timeSigs and (def.timeSigs[0] or -1)) or 4
        self.timeSigCount = (def.timeSigs and not def.timeSigs[0] and -1) or 0
        if self.beatMusic > 0 then
            self.timeSigCount = self.timeSigCurrent - 1
        end
        self.triplet = def.triplet
        self.lastSysTime = Isaac.GetTime()
    else
        self.tempoDef = nil
    end
end

---@param timeDelta integer time passed since last frame in milliseconds
function TempoManager:Update(timeDelta)
    if not (self.tempoDef and self.tempoDef.bpm) then
        return
    end
    timeDelta = timeDelta * MusicManager():GetCurrentPitch()

    local lastBeat = self.beat

    local def = self.tempoDef
    while true do
        if (def.bpmIndices and def.bpmIndices[self.bpmIndex + 1] and (self.time + timeDelta) > def.bpmIndices[self.bpmIndex + 1]) then
            local nextBpmChange = def.bpmIndices[self.bpmIndex + 1]
            local timeTilBpmChange = nextBpmChange - self.time
            timeDelta = timeDelta - timeTilBpmChange

            self.time = nextBpmChange
            local beatDelta = timeTilBpmChange * (def.bpms[def.bpmIndices[self.bpmIndex]] or def.bpm) / MILLISECONDS_PER_MINUTE
            self.beat = self.beat + beatDelta
            self.beatMusic = self.beatMusic + beatDelta

            self.bpmIndex = self.bpmIndex + 1
        elseif (def.length and (self.time + timeDelta) > (def.length + (def.intro or 0))) then
            local songEnd = def.length + (def.intro or 0)
            local timeTilEnd = songEnd - self.time
            timeDelta = timeDelta - timeTilEnd

            self.time = def.intro or 0
            local beatDelta = timeTilEnd * (def.bpmIndices and def.bpms[def.bpmIndices[self.bpmIndex]] or def.bpm) / MILLISECONDS_PER_MINUTE
            self.beat = self.beat + beatDelta
            self.beatMusic = def.beatIntro or 0.0
            
            if def.bpmIndices then
                for i, time0 in ipairs(def.bpmIndices) do
                    if time0 > self.time then
                        self.bpmIndex = i - 1
                        break
                    end
                end
            end
        else
            break
        end
    end
    local beatDelta = timeDelta * (def.bpmIndices and def.bpms[def.bpmIndices[self.bpmIndex]] or def.bpm) / MILLISECONDS_PER_MINUTE
    self.beat = self.beat + beatDelta
    self.beatMusic = self.beatMusic + beatDelta


    self.time = self.time + timeDelta

    local j = math.floor(self.beat) - math.floor(lastBeat)
    while j > 0 do
        j = j - 1
        local beatInt = math.floor(self.beatMusic) - j
        if def.timeSigs and def.timeSigs[beatInt] then
            self.timeSigCurrent = def.timeSigs[beatInt]
            self.timeSigCount = 0
        end
        if self.timeSigCount == 0 then
            Isaac.RunCallback("CAT_GUY_TICK", true)
            self.timeSigCount = self.timeSigCurrent
        else
            Isaac.RunCallback("CAT_GUY_TICK", false)
        end
        self.timeSigCount = self.timeSigCount - 1

        if def.triplets and def.triplets[beatInt] ~= nil then
            self.triplet = def.triplets[beatInt]
        end
    end
end

function TempoManager:PostRender()
    local sysTime = Isaac.GetTime()
    self:Update(sysTime - self.lastSysTime)
    self.lastSysTime = sysTime
end

function TempoManager:GetCurrentBPM()
    if self.tempoDef.bpmIndices then
        return (self.tempoDef.bpms[self.tempoDef.bpmIndices[self.bpmIndex]] or self.tempoDef.bpm) * MusicManager():GetCurrentPitch()
    else
        return self.tempoDef.bpm * MusicManager():GetCurrentPitch()
    end
end

local function rhythmicFireDelayEqn(delay, gameTicksPerBeat)
    return 2 ^ math.floor(math.log((delay + 1) / gameTicksPerBeat, 2) + 0.25)
end

---@param delay number
function TempoManager:GetRhythmicFireDelayFactor(delay)
    if self.tempoDef then
        local gameTicksPerBeat = 30 * 60 / self:GetCurrentBPM()
        local j = rhythmicFireDelayEqn(delay, gameTicksPerBeat)
        if self.triplet and j < 1 then
            return TWO_THIRDS * rhythmicFireDelayEqn(delay, gameTicksPerBeat * TWO_THIRDS)
        else
            return j
        end
    else
        return 1.0
    end
end

---@param delay number
function TempoManager:GetRhythmicFireDelay(delay)
    if self.tempoDef then
        local gameTicksPerBeat = 30 * 60 / self:GetCurrentBPM()
        local j = rhythmicFireDelayEqn(delay, gameTicksPerBeat)
        if self.triplet and j < 1 then
            return TWO_THIRDS * rhythmicFireDelayEqn(delay, gameTicksPerBeat * TWO_THIRDS) * gameTicksPerBeat - 1
        else
            return j * gameTicksPerBeat - 1
        end
    else
        return delay
    end
end

---@generic T
---@param tab table<T, any>
---@return table<integer, T>
local function getTableKeys(tab)
    local keys = {}
    for key, _ in pairs(tab) do
        table.insert(keys, key)
    end
    return keys
end

---@param def TempoDef
---@param timeDelta integer time in milliseconds
function TempoManager:GetArbitraryBeatNumber(def, timeDelta)
    local bpmIndex = 0
    local time = 0
    local beatMusic = 0

    while true do
        if (def.bpmIndices and def.bpmIndices[bpmIndex + 1] and (time + timeDelta) > def.bpmIndices[bpmIndex + 1]) then
            local nextBpmChange = def.bpmIndices[bpmIndex + 1]
            local timeTilBpmChange = nextBpmChange - time
            timeDelta = timeDelta - timeTilBpmChange

            time = nextBpmChange
            local beatDelta = timeTilBpmChange * (def.bpms[def.bpmIndices[bpmIndex]] or def.bpm) / MILLISECONDS_PER_MINUTE
            beatMusic = beatMusic + beatDelta

            bpmIndex = bpmIndex + 1
        elseif (def.length and (time + timeDelta) > (def.length + (def.intro or 0))) then
            local songEnd = def.length + (def.intro or 0)
            local timeTilEnd = songEnd - time
            timeDelta = timeDelta - timeTilEnd

            time = def.intro or 0
            --local beatDelta = timeTilEnd * (def.bpmIndices and def.bpms[def.bpmIndices[bpmIndex]] or def.bpm) / MILLISECONDS_PER_MINUTE
            beatMusic = def.beatIntro or 0.0

            if def.bpmIndices then
                for i, time0 in ipairs(def.bpmIndices) do
                    if time0 > time then
                        bpmIndex = i - 1
                        break
                    end
                end
            end
        else
            break
        end
    end
    local beatDelta = timeDelta * (def.bpmIndices and def.bpms[def.bpmIndices[bpmIndex]] or def.bpm) / MILLISECONDS_PER_MINUTE
    beatMusic = beatMusic + beatDelta

    return beatMusic
end

---@param tempoDef TempoDef
function TempoManager:PrepareTempoDef(tempoDef)
    if tempoDef.bpms and not tempoDef.bpmIndices then
        tempoDef.bpmIndices = getTableKeys(tempoDef.bpms)
    end

    if tempoDef.intro and not tempoDef.beatIntro then
        tempoDef.beatIntro = TempoManager:GetArbitraryBeatNumber(tempoDef, tempoDef.intro)
    end

    if tempoDef.offset and not tempoDef.beatOffset then
        tempoDef.beatOffset = TempoManager:GetArbitraryBeatNumber(tempoDef, tempoDef.offset)
    end
end

function TempoManager:RestartMusic()
    local room = Game():GetRoom()
    if room then
        MusicManager():Play(Music.MUSIC_TITLE, 1)
        room:PlayMusic()
    end
end

return TempoManager