local MAX_OFFSET_SAMPLES = 10

local MILLISECONDS_PER_MINUTE = 60000
local TWO_THIRDS = 2/3

---@class TempoManager
---@field lastMusic Music?
---@field lastPitch number
---@field tempoDefs TempoDefs
---@field tempoDef TempoDef?
---@field beat number strictly increasing beat number
---@field beatMusic number beat number relative to music
---@field measure integer
---@field measuresSinceTimeSigChange integer
---@field latencyTestEnabled boolean
---@field buttonPressed boolean
---@field offsetsTriggerIndex integer
---@field offsetsTrigger integer[]
---@field offsetsReleaseIndex integer
---@field offsetsRelease integer[]
---@field musicRestartBeat nil|number
local TempoManager = {}

---@param tempoDefs? TempoDefs
---@return TempoManager
function TempoManager:New(tempoDefs)
    local instance = setmetatable({}, self)
    self.__index = self

    instance.tempoDefs = {}
    if tempoDefs then
        instance:RegisterTempoDefs(tempoDefs)
    end

    instance.lastPitch = 1.0
    instance.tempoDef = nil

    instance.time = 0
    instance.bpmIndex = 0
    instance.lastBpm = 0

    instance.beat = 0
    instance.beatMusic = 0
    instance.measure = 0
    instance.measuresSinceTimeSigChange = 0
    instance.timeSigCount = 0
    instance.timeSig = 0
    instance.triplet = false
    instance.musicRestartBeat = nil

    instance.lastMusic = nil
    instance.lastSysTime = Isaac.GetTime()

    instance.latencyTestEnabled = false

    return instance
end

---@param music Music
---@param tempoDef TempoDef
function TempoManager:RegisterTempoDef_internal(music, tempoDef)
    if music > 0 and (not self.tempoDefs[music] or (self.tempoDefs[music].priority or 0.0) <= (tempoDef.priority or 0.0)) then
        self.tempoDefs[music] = tempoDef
    end
end

---@param music Music
---@param tempoDef TempoDef
function TempoManager:RegisterTempoDef(music, tempoDef)
    self:RegisterTempoDef_internal(music, tempoDef)
    self:UpdateConfig()
end

---@param tempoDefs TempoDefs
function TempoManager:RegisterTempoDefs(tempoDefs)
    for music, tempoDef in pairs(tempoDefs) do
        self:RegisterTempoDef_internal(music, tempoDef)
    end
    self:UpdateConfig()
end

function TempoManager:UpdateConfig()
    if CatGuy.Compat and CatGuy.Compat.ModConfigMenu and ModConfigMenu then
        CatGuy.Compat.ModConfigMenu:UpdateTempos(ModConfigMenu, self.tempoDefs)
    end
end

--[[ ---@param music Music
---@param source? string
function TempoManager:IsSourceValid(music, source)
    source = source or "BaseGame"
    local musicXMLNode = XMLData.GetEntryById(XMLNode.MUSIC, music) ---@type MusicXMLNode?
    print(musicXMLNode.sourceid)
    if musicXMLNode and musicXMLNode.sourceid == source then
        return true
    end
    return false
end

---@param tempoDefs TempoDefs
---@param source? string
function TempoManager:RegisterTempoDefsIfValid(tempoDefs, source)
    source = source or "BaseGame"
    for music, tempoDef in pairs(tempoDefs) do
        if self:IsSourceValid(music, source) then
            self:RegisterTempoDef_internal(music, tempoDef)
        end
    end
    self:UpdateConfig()
end

--- Creates a new tempoDefs table, does not modify original tempoDefs table
---@param tempoDefs TempoDefs
---@param source? string
function TempoManager:ValidateTempoDefs(tempoDefs, source)
    source = source or "BaseGame"
    local out = {} ---@type TempoDefs
    for music, tempoDef in pairs(tempoDefs) do
        if self:IsSourceValid(music, source) then
            out[music] = tempoDef
        end
    end
    return out
end ]]

---@param music? Music
---@return TempoDef?
function TempoManager:GetValidTempoDef(music)
    local def = self.tempoDefs[music]
    return def and def.bpm and def
end

---@param music Music
function TempoManager:PreMusicPlay(music)
    if not CatGuy:IsValidMusic(music) then
        return
    end

    self.lastMusic = music
    local def = self.tempoDefs[music] ---@type TempoDef
    if def and def.bpm and CatGuy.Config:GetTempoEnabled(music) ~= false then
        self.tempoDef = def
        self:PrepareTempoDef(def)
        self.time = 0
        self.beat = -(def.beatOffset or 0.000001)
        self.measure = -1
        self.measuresSinceTimeSigChange = -1
        self.beatMusic = self.beat
        self.bpmIndex = 0
        self.timeSig = def.timeSig or (def.timeSigs and (def.timeSigs[0] or -1)) or 4
        self.timeSigCount = (def.timeSigs and not def.timeSigs[0] and -1) or 0
        if self.beatMusic > 0 then
            self.measure = self.measure + 1
            self.measuresSinceTimeSigChange = self.measuresSinceTimeSigChange + 1
            self.timeSigCount = self.timeSig - 1
        end
        self.triplet = def.triplet
        self.lastSysTime = Isaac.GetTime()
    else
        self.tempoDef = nil
        self.time = 0
    end
    self.musicRestartBeat = nil
end

---@param timeDelta integer time passed since last frame in milliseconds
function TempoManager:Update(timeDelta)
    local lastBeat = self.beat
    timeDelta = timeDelta * self.lastPitch
    self.lastPitch = MusicManager():GetCurrentPitch() or 1.0

    local def = self.tempoDef
    if not (def and def.bpm) then
        self.time = self.time + timeDelta
        if self.lastBpm ~= 0 then
            local beatDelta = timeDelta * self.lastBpm / MILLISECONDS_PER_MINUTE
            self.beat = self.beat + beatDelta
        end
    else
        while true do
            if (def.bpmIndices and def.bpmIndices[self.bpmIndex + 1] and (self.time + timeDelta) > def.bpmIndices[self.bpmIndex + 1]) then
                local nextBpmChange = def.bpmIndices[self.bpmIndex + 1]
                local timeTilBpmChange = nextBpmChange - self.time
                timeDelta = timeDelta - timeTilBpmChange

                self.time = nextBpmChange
                self.lastBpm = def.bpms[def.bpmIndices[self.bpmIndex]] or def.bpm
                local beatDelta = timeTilBpmChange * self.lastBpm / MILLISECONDS_PER_MINUTE
                self.beat = self.beat + beatDelta
                self.beatMusic = self.beatMusic + beatDelta

                self.bpmIndex = self.bpmIndex + 1
            elseif (def.length and (self.time + timeDelta) > (def.length + (def.intro or 0))) then
                local songEnd = def.length + (def.intro or 0)
                local timeTilEnd = songEnd - self.time
                timeDelta = timeDelta - timeTilEnd

                self.time = def.intro or 0
                self.lastBpm = def.bpmIndices and def.bpms[def.bpmIndices[self.bpmIndex]] or def.bpm
                local beatDelta = timeTilEnd * self.lastBpm / MILLISECONDS_PER_MINUTE
                self.beatMusic = def.beatIntro or 0.0
                self.beat = ((self.beat + beatDelta + 0.5) // 1) + ((self.beatMusic + 0.5) % 1) - 0.5

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
        self.lastBpm = def.bpmIndices and def.bpms[def.bpmIndices[self.bpmIndex]] or def.bpm
        local beatDelta = timeDelta * self.lastBpm / MILLISECONDS_PER_MINUTE
        self.beat = self.beat + beatDelta
        self.beatMusic = self.beatMusic + beatDelta

        self.time = self.time + timeDelta
    end

    local j = math.floor(self.beat) - math.floor(lastBeat)
    while j > 0 do
        j = j - 1
        local beatInt = math.floor(self.beatMusic) - j
        if def and def.timeSigs and def.timeSigs[beatInt] then
            self.measuresSinceTimeSigChange = -1
            self.timeSig = def.timeSigs[beatInt]
            self.timeSigCount = 0
        end
        if self.timeSigCount == 0 then
            self.measure = self.measure + 1
            self.measuresSinceTimeSigChange = self.measuresSinceTimeSigChange + 1
            self.timeSigCount = self.timeSig
        end
        self.timeSigCount = self.timeSigCount - 1
        if def and def.triplets and def.triplets[beatInt] ~= nil then
            self.triplet = def.triplets[beatInt]
        end
        Isaac.RunCallback(CatGuy.ModCallbacks.TICK, self)
    end
end

function TempoManager:PostRender()
    local bpm = self.lastBpm
    local pitch = self.lastPitch

    local music = MusicManager():GetCurrentMusicID()
    if music ~= self.lastMusic then
        print(music)
        -- music update suppressed by early return on MC_PRE_MUSIC_PLAY
        self:PreMusicPlay(music)
    end
    local sysTime = Isaac.GetTime()
    self:Update(sysTime - self.lastSysTime)
    self.lastSysTime = sysTime

    if self.lastBpm ~= bpm or self.lastPitch ~= pitch then
        Isaac.RunCallback(CatGuy.ModCallbacks.POST_BPM_CHANGE, self, self.lastBpm ~= bpm, self.lastPitch ~= pitch)
    end

    self:LatencyTest()
    if self.musicRestartBeat and self.beat > self.musicRestartBeat then
        self:RestartMusic()
    end
    
    if CatGuy.Config:IsButtonTriggered("ControlsRestartMusic") then
        self:RestartMusic()
    end
end

--[[ function TempoManager:GetNudge()
    if not CatGuy:GetConfig("NudgeEnabled") then
        return 0
    elseif Input.IsButtonTriggered(CatGuy:GetConfig("ControlsNudgeForward"), 0) then
        return CatGuy:GetConfig("NudgeAmount")
    elseif Input.IsButtonTriggered(CatGuy:GetConfig("ControlsNudgeBackward"), 0) then
        return -CatGuy:GetConfig("NudgeAmount")
    else
        return 0
    end
end ]]

---@param arr number[]
---@return number
local function averageValues(arr)
    local sum = 0.0
    local div = 0
    for _, val in ipairs(arr) do
        sum = sum + val
        div = div + 1
    end
    return div ~= 0 and (sum / div) or sum
end

function TempoManager:ResetLatencyTest()
    self.buttonPressed = false
    self.offsetsTriggerIndex = 1
    self.offsetsTrigger = {}
    self.offsetsReleaseIndex = 1
    self.offsetsRelease = {}
end

function TempoManager:LatencyTest()
    if (ModConfigMenu and ModConfigMenu.IsVisible) then
        self.latencyTestEnabled = false
        return
    end
    if CatGuy.Config:IsButtonTriggered("ControlsLatencyTestEnter") then
        self.latencyTestEnabled = not self.latencyTestEnabled
        self:ResetLatencyTest()
    end
    if not self.latencyTestEnabled then
        return
    end

    local buttonPressed = CatGuy.Config:IsButtonPressed("ControlsLatencyTest")

    if buttonPressed ~= self.buttonPressed then
        self:RecordLatencyTestSample(buttonPressed)
        self.buttonPressed = buttonPressed
    end

    Isaac.RenderText("You are now testing your latency."
        .."\nPress \"B\" to the beat of the current music,"
        .."\nand use these values in your configs:"
        .."\nOffsetTrigger: "..math.floor(averageValues(self.offsetsTrigger)).." ms"
        .."\nOffsetRelease: "..math.floor(averageValues(self.offsetsRelease)).." ms", 140, 20, 1, 1, 1, 1)

    Isaac.RenderText(buttonPressed and ":O" or ":|", 30, 230, 1, 1, 1, 1)
end

---@param triggered boolean
function TempoManager:RecordLatencyTestSample(triggered)
    local offset = ((self.beat + 0.5) % 1.0 - 0.5) / self:GetCurrentBPM() * MILLISECONDS_PER_MINUTE
    if triggered then
        self.offsetsTrigger[self.offsetsTriggerIndex] = offset
        self.offsetsTriggerIndex = self.offsetsTriggerIndex % MAX_OFFSET_SAMPLES + 1
    else
        self.offsetsRelease[self.offsetsReleaseIndex] = offset
        self.offsetsReleaseIndex = self.offsetsReleaseIndex % MAX_OFFSET_SAMPLES + 1
    end
end

---@return number
function TempoManager:GetCurrentBPM()
    return self.lastBpm * MusicManager():GetCurrentPitch()
end

---@param controller? boolean
---@param release? boolean
function TempoManager:GetLatencyAdjustedBeat(controller, release)
    local offset =
        (release
            and (controller
                and CatGuy.Config:Get("OffsetReleaseController")
                or CatGuy.Config:Get("OffsetTriggerController"))
            or CatGuy.Config:Get("OffsetRelease"))
        or (controller
            and CatGuy.Config:Get("OffsetTriggerController"))
        or CatGuy.Config:Get("OffsetTrigger")
    
    return self.beat - offset * self:GetCurrentBPM() / MILLISECONDS_PER_MINUTE
end

---@param controller? boolean
function TempoManager:GetLatencyAdjustedBeatCSection(controller)
    local offset =
        (controller
            and CatGuy.Config:Get("OffsetCSectionController")
            or CatGuy.Config:Get("OffsetTriggerController"))
        or CatGuy.Config:Get("OffsetCSection")
        or CatGuy.Config:Get("OffsetTrigger")
    return self.beat - offset * self:GetCurrentBPM() / MILLISECONDS_PER_MINUTE
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
---@return T[]
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
        tempoDef.beatIntro = self:GetArbitraryBeatNumber(tempoDef, tempoDef.intro)
    end

    if tempoDef.offset and not tempoDef.beatOffset then
        tempoDef.beatOffset = self:GetArbitraryBeatNumber(tempoDef, tempoDef.offset)
    end
end

function TempoManager:RestartMusic()
    local id = MusicManager():GetCurrentMusicID()
    if id then
        MusicManager():Play(id, 0)
        MusicManager():UpdateVolume()
    end
end

function TempoManager:ScheduleRestartMusic()
    if not self.tempoDef then
        self:RestartMusic()
        return
    end
    local beatOffset = self.tempoDef.beatOffset or 0
    self.musicRestartBeat = math.floor(self.beat + beatOffset + 1) - beatOffset
end

return TempoManager