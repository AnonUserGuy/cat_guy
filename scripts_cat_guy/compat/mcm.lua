local MOD_NAME = "Percy: Musical Cat"

---@enum ConfigTab
local configTab = {
    INFO = "Info",
    GENERAL = "General",
    INPUT_LATENCY = "Latency",
    --NUDGING = "Nudging",
    SONG_SPECIFIC_SETTINGS = "Songs"
}
---@class MCMCompat
local mcmCompat = {}

mcmCompat.inited = false

---@param mcm any
---@param inputHelper any
---@param tempoDefs TempoDefs
function mcmCompat:Init(mcm, inputHelper, tempoDefs)
    if mcmCompat.inited then
        return
    end
    mcmCompat.inited = true
    mcm.RemoveCategory(MOD_NAME)

    mcm.AddSpace(MOD_NAME, configTab.INFO)
    mcm.AddText(MOD_NAME, configTab.INFO, function() return CatGuy.XML.name end)
    mcm.AddText(MOD_NAME, configTab.INFO, function() return "AKA \"Cat Guy\"" end)
    mcm.AddSpace(MOD_NAME, configTab.INFO)
    mcm.AddText(MOD_NAME, configTab.INFO, function() return "Version " .. CatGuy.XML.version end)

    self:AddBoolean(mcm, "MomsHeadphonesHaveMetronome", configTab.GENERAL, "Mom's Headphones have Metronome", {"Whether or not Mom's Headphones make a metronome play, even without the Toy Metronome trinket.", "In case you don't want to waste a trinket slot."})
    self:AddBoolean(mcm, "PercyBHasMomsHeadphones", configTab.GENERAL, "Tainted Percy has Mom's Headphones", {"Whether or not Tainted Percy starts with Mom's Headphones.", "In case you want to try his gimmick without also having to play with regular Percy's gimmick."})
    self:AddBoolean(mcm, "OGGPlayerTutorial", configTab.GENERAL, "Display OGG Player tutorial", {"Whether or not to display OGG Player controls whenever it is picked up."})
    mcm.AddSpace(MOD_NAME, configTab.GENERAL)
    self:AddKeybind(mcm, inputHelper, "ControlsRestartMusic", configTab.GENERAL, "Restart Music (Keyboard)", {"Keybind for restarting the music, in case of desync."})
    self:AddKeybind(mcm, inputHelper, "ControlsRestartMusicController", configTab.GENERAL, "Restart Music (Controller)", {"Controller button for restarting the music, in case of desync."}, true)

    --[[mcm.AddSpace(MOD_NAME, configTab.GAMEPLAY)
    mcm.AddText(MOD_NAME, configTab.GAMEPLAY, function() return "The following only work on save file 1," end)
    mcm.AddText(MOD_NAME, configTab.GAMEPLAY, function() return "and require a restart to take effect!" end)
    self:AddBoolean(mcm, "ReworkToothAndNail", configTab.GAMEPLAY, "Rework Tooth and Nail", {"Whether or not to rework Tooth and Nail so it can have its synergy with Mom's Headphones. May be necessary to disable if another mod tries to rework Tooth and Nail."})
    ]]

    mcm.AddText(MOD_NAME, configTab.INPUT_LATENCY, function() return "Keyboard" end)
    self:AddInteger(mcm, "OffsetTrigger", configTab.INPUT_LATENCY, "Offset (Trigger)", "ms", {"Offset of inputs to accommodate for audio/controls latency, in milliseconds."})
    self:AddIntegerWithDefault(mcm, "OffsetRelease", {"OffsetTrigger"}, configTab.INPUT_LATENCY, "Offset (Release)", "\"Offset (Trigger)\"", "ms", {"Offset of released inputs to accommodate for audio/controls latency, in milliseconds."})
    self:AddIntegerWithDefault(mcm, "OffsetCSection", {"OffsetTrigger"}, configTab.INPUT_LATENCY, "Offset (C Section)", "\"Offset (Trigger)\"", "ms", {"Offset of inputs *for specifically Mom's Headphones + C Section* to accommodate for audio/controls latency, in milliseconds."})
    mcm.AddSpace(MOD_NAME, configTab.INPUT_LATENCY)

    mcm.AddText(MOD_NAME, configTab.INPUT_LATENCY, function() return "Controller" end)
    self:AddIntegerWithDefault(mcm, "OffsetTriggerController", {"OffsetTrigger"}, configTab.INPUT_LATENCY, "Offset (Trigger)", "keyboard setting", "ms", {"Offset of inputs to accommodate for audio/controls latency, in milliseconds."})
    self:AddIntegerWithDefault(mcm, "OffsetReleaseController", {"OffsetTriggerController", "OffsetRelease", "OffsetTrigger"}, configTab.INPUT_LATENCY, "Offset (Release)", "\"Offset (Trigger)\"$newlineor keyboard setting", "ms", {"Offset of released inputs to accommodate for audio/controls latency, in milliseconds."})
    self:AddIntegerWithDefault(mcm, "OffsetCSectionController", {"OffsetTriggerController", "OffsetCSection", "OffsetTrigger"}, configTab.INPUT_LATENCY, "Offset (C Section)", "\"Offset (Trigger)\"$newlineor keyboard setting", "ms", {"Offset of inputs *for specifically Mom's Headphones + C Section* to accommodate for audio/controls latency, in milliseconds."})
    mcm.AddSpace(MOD_NAME, configTab.INPUT_LATENCY)

    mcm.AddText(MOD_NAME, configTab.INPUT_LATENCY, function() return "Latency Testing" end)
    self:AddKeybind(mcm, inputHelper, "ControlsLatencyTestEnter", configTab.INPUT_LATENCY, "Toggle Latency Test (Keyboard)", {"Keybind for entering/exiting \"latency testing mode\", where you can determine appropriate latency settings."})
    self:AddKeybind(mcm, inputHelper, "ControlsLatencyTestEnterController", configTab.INPUT_LATENCY, "Toggle Latency Test (Controller)", {"Controller button for entering/exiting \"latency testing mode\", where you can determine appropriate latency settings."}, true)
    self:AddKeybind(mcm, inputHelper, "ControlsLatencyTest", configTab.INPUT_LATENCY, "Latency Test (Keyboard)", {"Keybind used to test latency."})
    self:AddKeybind(mcm, inputHelper, "ControlsLatencyTestController", configTab.INPUT_LATENCY, "Latency Test (Controller)", {"Controller button used to test latency."}, true)

    --[[self:AddBoolean(mcm, "NudgeEnabled", configTab.NUDGING, "Nudging Enabled", {"Whether or not nudging is enabled."})
    self:AddInteger(mcm, "NudgeAmount", configTab.NUDGING, "Nudge Amount", "ms", {"How far to nudge per input, in milliseconds."})
    self:AddKeybind(mcm, inputHelper, "ControlsNudgeForward", configTab.NUDGING, "Nudge Forward", {"Keybind for nudging forward in time."})
    self:AddKeybind(mcm, inputHelper, "ControlsNudgeBackward", configTab.NUDGING, "Nudge Backward", {"Keybind for nudging backward in time."}) 
    ]]
    
    self:UpdateTempos(mcm, tempoDefs)
end

---@param tempoDefs TempoDefs
function mcmCompat:UpdateTempos(mcm, tempoDefs)
    mcm.RemoveSubcategory(MOD_NAME, configTab.SONG_SPECIFIC_SETTINGS)
    mcm.AddText(MOD_NAME, configTab.SONG_SPECIFIC_SETTINGS, function() return "Enable rhythm-related features per song" end)
    mcm.AddText(MOD_NAME, configTab.SONG_SPECIFIC_SETTINGS, function() return "(for if a song gets replaced by another mod)" end)

    mcm.AddSpace(MOD_NAME, configTab.SONG_SPECIFIC_SETTINGS)
    mcm.AddText(MOD_NAME, configTab.SONG_SPECIFIC_SETTINGS, function() return "Currently Playing" end)
    local CurrentInfo = {"Enable/Disable for specifically the playing track."}
    mcm.AddSetting(MOD_NAME, configTab.SONG_SPECIFIC_SETTINGS, {
        Type = mcm.OptionType.BOOLEAN,
        Attribute = "Current Track",
        CurrentSetting = function()
            local music = MusicManager():GetCurrentMusicID()
            if music then
                return CatGuy.Config:GetTempoEnabled(music)
            end
            return false
        end,
        Display = function()
            local music = MusicManager():GetCurrentMusicID()
            if music then
                local name
                local node = XMLData.GetEntryById(XMLNode.MUSIC, music) ---@type MusicXMLNode
                if node then
                    name = node.name
                    if node.intro then
                        CurrentInfo[2] = "Intro: \""..node.intro.."\""
                        CurrentInfo[3] = "Path: \""..node.path.."\""
                    else
                        CurrentInfo[2] = "Path: \""..node.path.."\""
                        CurrentInfo[3] = nil
                    end
                else
                    name = "Unknown Track"
                    CurrentInfo[2] = nil
                    CurrentInfo[3] = nil
                end
                local current
                if not tempoDefs[music] then
                    current = "N/A"
                else
                    current = (CatGuy.Config:GetTempoEnabled(music) and "on" or "off")
                end
                return "**"..music.." - "..name..": "..current.."**"
            else
                CurrentInfo[2] = nil
                CurrentInfo[3] = nil
            end
            return "**None**"
        end,
        OnChange = function(b)
            local music = MusicManager():GetCurrentMusicID()
            if not music or not tempoDefs[music] then
                return
            end
            CatGuy.Config:SetTempoEnabled(music, b)
            MusicManager():Play(music, 0)
            MusicManager():UpdateVolume()
        end,
        Info = CurrentInfo
    })

    local lastMod = nil ---@type string?
    for music, val in pairs(tempoDefs) do
        if val.bpm then
            local node = XMLData.GetEntryById(XMLNode.MUSIC, music) ---@type MusicXMLNode
            if not node then
                self:AddTempoEnabled(mcm, music, configTab.SONG_SPECIFIC_SETTINGS, music.." - Unknown Track")
            else
                if lastMod ~= node.sourceid then
                    lastMod = node.sourceid
                    local name = XMLData.GetModById(node.sourceid) and XMLData.GetModById(node.sourceid).directory or node.sourceid
                    mcm.AddSpace(MOD_NAME, configTab.SONG_SPECIFIC_SETTINGS)
                    mcm.AddText(MOD_NAME, configTab.SONG_SPECIFIC_SETTINGS, function() return name end)
                end
                local j = {"Path: \""..node.path.."\""}
                if node.intro then
                    table.insert(j, 1, "Intro: \""..node.intro.."\"")
                end
                self:AddTempoEnabled(mcm, music, configTab.SONG_SPECIFIC_SETTINGS, music.." - "..node.name, j)
            end
        end
    end
end

---@param mcm any
---@param tab ConfigTab
---@param attribute string
---@param configName string
---@param info? string[]
function mcmCompat:AddBoolean(mcm, configName, tab, attribute, info)
    mcm.AddSetting(MOD_NAME, tab, {
        Type = mcm.OptionType.BOOLEAN,
        Attribute = attribute,
        CurrentSetting = function()
            return CatGuy.Config:Get(configName)
        end,
        Display = function()
            return attribute..": "..(CatGuy.Config:Get(configName) and "on" or "off")
        end,
        OnChange = function(b)
            CatGuy.Config:Set(configName, b)
        end,
        Info = info or {}
    })
end

---@param mcm any
---@param tab ConfigTab
---@param attribute string
---@param music Music
---@param info? string[]
function mcmCompat:AddTempoEnabled(mcm, music, tab, attribute, info)
    mcm.AddSetting(MOD_NAME, tab, {
        Type = mcm.OptionType.BOOLEAN,
        Attribute = attribute,
        CurrentSetting = function()
            return CatGuy.Config:GetTempoEnabled(music)
        end,
        Display = function()
            return attribute..": "..(CatGuy.Config:GetTempoEnabled(music) and "on" or "off")
        end,
        OnChange = function(b)
            CatGuy.Config:SetTempoEnabled(music, b)
            if music == MusicManager():GetCurrentMusicID() then
                MusicManager():Play(music, 0)
                MusicManager():UpdateVolume()
            end
        end,
        Info = info or {}
    })
end

---@param mcm any
---@param tab ConfigTab
---@param attribute string
---@param configName string
---@param unit? string
---@param info? string[]
function mcmCompat:AddInteger(mcm, configName, tab, attribute, unit, info)
    mcm.AddSetting(MOD_NAME, tab, {
        Type = mcm.OptionType.NUMBER,
        Attribute = attribute,
        CurrentSetting = function()
            return CatGuy.Config:Get(configName) or 0
        end,
        Display = function()
            return attribute..": "..(CatGuy.Config:Get(configName) or 0)..(unit and (" "..unit) or "")
        end,
        OnChange = function(b)
            CatGuy.Config:Set(configName, b)
        end,
        Info = info or {}
    })
end

---@param configName string
---@param configNameDefault string[]
local function configGetWithDefault(configName, configNameDefault)
    local val = CatGuy.Config:Get(configName)
    if val then
        return val
    end
    for _, name in ipairs(configNameDefault) do
        val = CatGuy.Config:Get(name)
        if val then
            return val
        end
    end
    return nil
end

---@param mcm any
---@param tab ConfigTab
---@param attribute string
---@param attributeDefault string
---@param configName string
---@param configNameDefault string[]
---@param unit? string
---@param info? string[]
function mcmCompat:AddIntegerWithDefault(mcm, configName, configNameDefault, tab, attribute, attributeDefault, unit, info)
    mcm.AddSetting(MOD_NAME, tab, {
        Type = mcm.OptionType.NUMBER,
        Attribute = attribute,
        CurrentSetting = function()
            return configGetWithDefault(configName, configNameDefault) or 0
        end,
        Display = function()
            return attribute..": "..(configGetWithDefault(configName, configNameDefault) or "None")..(unit and (" "..unit) or "")
        end,
        OnChange = function(b)
            CatGuy.Config:Set(configName, b)
        end,
        Info = info or {}
    })
    mcm.AddSetting(MOD_NAME, tab, {
        Type = mcm.OptionType.BOOLEAN,
        Attribute = attribute,
        CurrentSetting = function()
            return true
        end,
        Display = function()
            if CatGuy.Config:Get(configName) then
                return "!-- Reset "..attribute.." --!"
            end
            return "-- Reset "..attribute.." --"
        end,
        OnChange = function()
            CatGuy.Config:Set(configName, nil)
        end,
        Info = {"Reset \""..attribute.."\" to match "..attributeDefault}
    })
end

--- largely adapted from https://github.com/wofsauge/External-Item-Descriptions/blob/master/features/eid_mcm.lua
---@param mcm any
---@param inputHelper any
---@param tab ConfigTab
---@param attribute string
---@param configName string
---@param info? string[]
---@param isController? boolean
function mcmCompat:AddKeybind(mcm, inputHelper, configName, tab, attribute, info, isController)
	local optionType = mcm.OptionType.KEYBIND_KEYBOARD
	local hotkeyToString = inputHelper.KeyboardToString
	local deviceString = "keyboard"
	local backString = "ESCAPE"
	if isController then
		optionType = mcm.OptionType.KEYBIND_CONTROLLER
		hotkeyToString = inputHelper.ControllerToString
		deviceString = "controller"
		backString = "BACK"
	end
    mcm.AddSetting(MOD_NAME, tab, {
        Type = optionType,
        Attribute = attribute,
        CurrentSetting = function()
            return CatGuy.Config:Get(configName)
        end,
        Display = function()
            return attribute.. ": "..tostring(hotkeyToString[CatGuy.Config:Get(configName)] or "None")
        end,
        OnChange = function(b)
            CatGuy.Config:Set(configName, b)
        end,
        PopupGfx = mcm.PopupGfx.WIDE_SMALL,
		PopupWidth = 280,
		Popup = function()
            local currentValue = CatGuy.Config:Get(configName)
            local keepSettingString = ""
            if currentValue > -1 then
                local currentSettingString = hotkeyToString[currentValue]
                keepSettingString = "This setting is currently set to \"" .. currentSettingString .. "\".$newlinePress this button to keep it unchanged.$newline$newline"
            end
            return "Press a button on your "..deviceString.." to change this setting.$newline$newline" .. keepSettingString .. "Press "..backString.." to go back and clear this setting."
        end,
        Info = info or {}
    })
end

return mcmCompat
