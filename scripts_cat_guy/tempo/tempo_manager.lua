local MILLISECONDS_PER_MINUTE = 60000

---@class TempoManager
---@field tempoDefs table<Music, TempoDef>
local TempoManager = {}

---@param tempoDefs table<Music, TempoDef>
---@return TempoManager
function TempoManager:New(tempoDefs)
    local instance = setmetatable({}, self)
    self.__index = self

    instance.tempoDefs = tempoDefs
    instance.tempoDef = nil
    instance.time = 0
    instance.beat = 0
    instance.bpmIndex = 0
    instance.timeSigCount = 0
    instance.timeSigCurrent = 0
    instance.lastSysTime = Isaac.GetTime()

    return instance
end

---@param music MusicManager
function TempoManager:PreMusicPlay(music)
    self.tempoDef = self.tempoDefs[music] ---@type TempoDef?
    if self.tempoDef and self.tempoDef.bpm then
        self:PrepareTempoDef(self.tempoDef)
        self.time = 0
        self.beat = -(self.tempoDef.offset and (self.tempoDef.offset * self.tempoDef.bpm / MILLISECONDS_PER_MINUTE) or 0.000001)
        self.bpmIndex = 0
        self.timeSigCurrent = self.tempoDef.timeSig or (self.tempoDef.timeSigs and (self.tempoDef.timeSigs[0] or -1)) or 4
        self.timeSigCount = (self.tempoDef.timeSigs and not self.tempoDef.timeSigs[0] and -1) or 0
        self.lastSysTime = Isaac.GetTime()
    end
end

---@param timeDelta integer time passed since last frame in milliseconds
function TempoManager:Update(timeDelta)
    if not (self.tempoDef and self.tempoDef.bpm) then
        return
    end
    timeDelta = timeDelta * MusicManager():GetCurrentPitch()

    local lastBeat = self.beat

    local beatDelta = 0.0
    if self.tempoDef.bpmIndices then
        while self.tempoDef.bpmIndices[self.bpmIndex + 1] and (self.time + timeDelta) > self.tempoDef.bpmIndices[self.bpmIndex + 1] do
            local nextBpmChange = self.tempoDef.bpmIndices[self.bpmIndex + 1]
            local timeTilBpmChange = nextBpmChange - self.time
            timeDelta = timeDelta - timeTilBpmChange

            self.time = nextBpmChange
            beatDelta = beatDelta + timeTilBpmChange * (self.tempoDef.bpms[self.tempoDef.bpmIndices[self.bpmIndex]] or self.tempoDef.bpm) / MILLISECONDS_PER_MINUTE

            self.bpmIndex = self.bpmIndex + 1
        end
        beatDelta = beatDelta + timeDelta * (self.tempoDef.bpms[self.tempoDef.bpmIndices[self.bpmIndex]] or self.tempoDef.bpm) / MILLISECONDS_PER_MINUTE
    else
        beatDelta = timeDelta * self.tempoDef.bpm / MILLISECONDS_PER_MINUTE
    end

    self.beat = self.beat + beatDelta
    self.time = self.time + timeDelta

    local j = math.floor(self.beat) - math.floor(lastBeat)
    while j > 0 do
        j = j - 1
        local beatInt = math.floor(self.beat) - j
        if self.tempoDef.timeSigs and self.tempoDef.timeSigs[beatInt] then
            self.timeSigCurrent = self.tempoDef.timeSigs[beatInt]
            self.timeSigCount = 0
        end
        if self.timeSigCount == 0 then
            Isaac.RunCallback("CAT_GUY_TICK", true)
            self.timeSigCount = self.timeSigCurrent
        else
            Isaac.RunCallback("CAT_GUY_TICK", false)
        end
        self.timeSigCount = self.timeSigCount - 1
    end
end

function TempoManager:PostRender()
    local sysTime = Isaac.GetTime()
    self:Update(sysTime - self.lastSysTime)
    self.lastSysTime = sysTime
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

---@param tempoDef TempoDef
function TempoManager:PrepareTempoDef(tempoDef)
    if tempoDef.bpms and not tempoDef.bpmIndices then
        tempoDef.bpmIndices = getTableKeys(tempoDef.bpms)
    end
end

return TempoManager