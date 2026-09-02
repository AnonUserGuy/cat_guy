---@class CatGuyConfig
---@field MomsHeadphonesHaveMetronome boolean
---@field PercyBHasMomsHeadphones boolean
---@field ControlsRestartMusic Keyboard
---@field OffsetTrigger integer
---@field OffsetRelease nil|integer
---@field OffsetCSection nil|integer
---@field ControlsLatencyTestEnter Keyboard
---@field ControlsLatencyTest Keyboard
----@field NudgeEnabled boolean
----@field NudgeAmount integer
----@field ControlsNudgeForward Keyboard
----@field ControlsNudgeBackward Keyboard
---@field TempoEnabled table<Music|string, boolean>

-- ignore this
--[[     ------------ NUDGING ------------

    -- Whether or not nudging is enabled.
    -- true  = Enabled.
    -- false = Disabled.
    -- Default: false
    NudgeEnabled = false,

    -- How far to nudge per input, in milliseconds.
    -- Default: 16
    NudgeAmount = 16,

    -- Keybind for nudging forward in time.
    -- Key names can be found here: https://wofsauge.github.io/IsaacDocs/rep/enums/Keyboard.html
    -- Default: Keyboard.KEY_RIGHT_BRACKET
    ControlsNudgeForward = Keyboard.KEY_RIGHT_BRACKET,

    -- Keybind for nudging backward in time.
    -- Key names can be found here: https://wofsauge.github.io/IsaacDocs/rep/enums/Keyboard.html
    -- Default: Keyboard.KEY_LEFT_BRACKET
    ControlsNudgeBackward = Keyboard.KEY_LEFT_BRACKET, ]]