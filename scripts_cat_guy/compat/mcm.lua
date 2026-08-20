local MOD_NAME = CatGuy.XML.name
local VERSION = CatGuy.XML.version

---@enum ConfigTab
local configTab = {
    INFO = "Info",
    GAMEPLAY = "Gameplay",
    INPUT_LATENCY = "Latency",
    NUDGING = "Nudging",
    SONG_SPECIFIC_SETTINGS = "Songs"
}
---@class MCMCompat
local mcmCompat = {}

mcmCompat.inited = false

---@param mcm any
---@param inputHelper any
---@param tempoDefs table<Music, TempoDef>
function mcmCompat:Init(mcm, inputHelper, tempoDefs)
    if mcmCompat.inited then
        return
    end
    mcmCompat.inited = true
    mcm.RemoveCategory(MOD_NAME)

    mcm.AddSpace(MOD_NAME, configTab.INFO)
    mcm.AddText(MOD_NAME, configTab.INFO, function() return MOD_NAME end)
    mcm.AddSpace(MOD_NAME, configTab.INFO)
    mcm.AddText(MOD_NAME, configTab.INFO, function() return "Version " .. VERSION end)

    self:AddBoolean(mcm, "MomsHeadphonesHaveMetronome", configTab.GAMEPLAY, "Mom's Headphones have Metronome", {"Whether or not Mom's Headphones make a metronome play, even without the Toy Metronome trinket.", "In case you don't want to waste a trinket slot."})
    self:AddBoolean(mcm, "PercyBHasMomsHeadphones", configTab.GAMEPLAY, "Tainted Percy has Mom's Headphones", {"Whether or not Tainted Percy starts with Mom's Headphones.", "In case you want to try his gimmick without also having to play with regular Percy's gimmick."})

    self:AddInteger(mcm, "OffsetTrigger", configTab.INPUT_LATENCY, "Offset (Trigger)", "ms", {"Offset of inputs to accommodate for audio/controls latency, in milliseconds."})
    self:AddIntegerWithDefault(mcm, "OffsetRelease", "OffsetTrigger", configTab.INPUT_LATENCY, "Offset (Release)", "Offset (Trigger)", "ms", {"Offset of released inputs to accommodate for audio/controls latency, in milliseconds."})
    self:AddIntegerWithDefault(mcm, "OffsetCSection", "OffsetTrigger", configTab.INPUT_LATENCY, "Offset (C Section)", "Offset (Trigger)", "ms", {"Offset of inputs *for specifically Mom's Headphones + C Section* to accommodate for audio/controls latency, in milliseconds."})
    mcm.AddSpace(MOD_NAME, configTab.INPUT_LATENCY)
    self:AddKeybind(mcm, inputHelper, "ControlsLatencyTestEnter", configTab.INPUT_LATENCY, "Enable/Disable Latency Test", {"Keybind for entering/exiting \"latency testing mode\", where you can determine appropriate latency settings."})
    self:AddKeybind(mcm, inputHelper, "ControlsLatencyTest", configTab.INPUT_LATENCY, "Latency Test Key", {"Keybind used to test latency."})

    self:AddBoolean(mcm, "NudgeEnabled", configTab.NUDGING, "Nudging Enabled", {"Whether or not nudging is enabled."})
    self:AddInteger(mcm, "NudgeAmount", configTab.NUDGING, "Nudge Amount", "ms", {"How far to nudge per input, in milliseconds."})
    self:AddKeybind(mcm, inputHelper, "ControlsNudgeForward", configTab.NUDGING, "Nudge Forward", {"Keybind for nudging forward in time."})
    self:AddKeybind(mcm, inputHelper, "ControlsNudgeBackward", configTab.NUDGING, "Nudge Backward", {"Keybind for nudging backward in time."})

    self:UpdateTempos(mcm, tempoDefs)
end

---@param tempoDefs table<Music, TempoDef>
function mcmCompat:UpdateTempos(mcm, tempoDefs)
    mcm.RemoveSubcategory(MOD_NAME, configTab.SONG_SPECIFIC_SETTINGS)
    mcm.AddText(MOD_NAME, configTab.SONG_SPECIFIC_SETTINGS, function() return "Enable rhythm-related features per song" end)
    mcm.AddText(MOD_NAME, configTab.SONG_SPECIFIC_SETTINGS, function() return "(for if a song gets replaced by another mod)" end)

    local CurrentInfo = {"Enable/Disable for specifically the playing track."}
    mcm.AddSetting(MOD_NAME, configTab.SONG_SPECIFIC_SETTINGS, {
        Type = mcm.OptionType.BOOLEAN,
        Attribute = "Current Track",
        CurrentSetting = function()
            local music = MusicManager():GetCurrentMusicID()
            if music then
                return CatGuy:GetTempoEnabled(music)
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
                    current = (CatGuy:GetTempoEnabled(music) and "on" or "off")
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
            CatGuy:SetTempoEnabled(music, b)
            MusicManager():Play(music, 0)
            MusicManager():UpdateVolume()
        end,
        Info = CurrentInfo
    })

    for music, _ in pairs(tempoDefs) do
        local node = XMLData.GetEntryById(XMLNode.MUSIC, music) ---@type MusicXMLNode
        if not node then
            self:AddTempoEnabled(mcm, music, configTab.SONG_SPECIFIC_SETTINGS, music.." - Unknown Track")
        else
            local j = {"Path: \""..node.path.."\""}
            if node.intro then
                table.insert(j, 1, "Intro: \""..node.intro.."\"")
            end
            self:AddTempoEnabled(mcm, music, configTab.SONG_SPECIFIC_SETTINGS, music.." - "..node.name, j)
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
            return CatGuy:GetConfig(configName)
        end,
        Display = function()
            return attribute..": "..(CatGuy:GetConfig(configName) and "on" or "off")
        end,
        OnChange = function(b)
            CatGuy:SetConfig(configName, b)
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
            return CatGuy:GetTempoEnabled(music)
        end,
        Display = function()
            return attribute..": "..(CatGuy:GetTempoEnabled(music) and "on" or "off")
        end,
        OnChange = function(b)
            CatGuy:SetTempoEnabled(music, b)
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
            return CatGuy:GetConfig(configName) or 0
        end,
        Display = function()
            return attribute..": "..(CatGuy:GetConfig(configName) or 0)..(unit and (" "..unit) or "")
        end,
        OnChange = function(b)
            CatGuy:SetConfig(configName, b)
        end,
        Info = info or {}
    })
end

---@param mcm any
---@param tab ConfigTab
---@param attribute string
---@param attributeDefault string
---@param configName string
---@param configNameDefault string
---@param unit? string
---@param info? string[]
function mcmCompat:AddIntegerWithDefault(mcm, configName, configNameDefault, tab, attribute, attributeDefault, unit, info)
    mcm.AddSetting(MOD_NAME, tab, {
        Type = mcm.OptionType.NUMBER,
        Attribute = attribute,
        CurrentSetting = function()
            return CatGuy:GetConfig(configName) or CatGuy:GetConfig(configNameDefault)
        end,
        Display = function()
            return attribute..": "..(CatGuy:GetConfig(configName) or CatGuy:GetConfig(configNameDefault))..(unit and (" "..unit) or "")
        end,
        OnChange = function(b)
            CatGuy:SetConfig(configName, b)
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
            if CatGuy:GetConfig(configName) then
                return "!-- Reset "..attribute.." --!"
            end
            return "-- Reset "..attribute.." --"
        end,
        OnChange = function(b)
            CatGuy:SetConfig(configName, nil)
        end,
        Info = {"Reset \""..attribute.."\" to match \""..attributeDefault.."\""}
    })
end

---@param mcm any
---@param inputHelper any
---@param tab ConfigTab
---@param attribute string
---@param configName string
---@param info? string[]
function mcmCompat:AddKeybind(mcm, inputHelper, configName, tab, attribute, info)
    local deviceString = "keyboard"
    local backString = "ESCAPE"
    mcm.AddSetting(MOD_NAME, tab, {
        Type = mcm.OptionType.KEYBIND_KEYBOARD,
        Attribute = attribute,
        CurrentSetting = function()
            return self:GetKeyName(inputHelper, CatGuy:GetConfig(configName))
        end,
        Display = function()
            return attribute..": "..tostring(self:GetKeyName(inputHelper, CatGuy:GetConfig(configName)))
        end,
        OnChange = function(b)
            CatGuy:SetConfig(configName, b)
        end,
        PopupGfx = mcm.PopupGfx.WIDE_SMALL,
		PopupWidth = 280,
		Popup = function()
            local currentValue = CatGuy:GetConfig(configName)
            local keepSettingString = ""
            if currentValue > -1 then
                local currentSettingString = self:GetKeyName(inputHelper, CatGuy:GetConfig(configName))
                keepSettingString = "This setting is currently set to \"" .. currentSettingString .. "\".$newlinePress this button to keep it unchanged.$newline$newline"
            end
            return "Press a button on your "..deviceString.." to change this setting.$newline$newline" .. keepSettingString .. "Press "..backString.." to go back and clear this setting."
        end,
        Info = info or {}
    })
end

---@param inputHelper any
---@param key Keyboard
function mcmCompat:GetKeyName(inputHelper, key)
    return inputHelper and inputHelper.KeyboardToString and inputHelper.KeyboardToString[key] or key
end

return mcmCompat
