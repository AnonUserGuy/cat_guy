local json = require("json")

---@class ConfigManager
---@field Mod ModReference
---@field Config CatGuyConfig
---@field Data table?
---@field LastLoad integer
local configManager = {}

---@param mod ModReference
---@param config CatGuyConfig
---@param userConfig? CatGuyConfig|string
function configManager:New(mod, config, userConfig)
    local instance = setmetatable({}, self)
    self.__index = self

    instance.Mod = mod
    instance.LastLoad = 0
    instance.Config = config
    if type(userConfig) == "table" then
        instance:Copy(userConfig, CatGuy.Config)
    end

    return instance
end

---@param input table<string|number, any>
function configManager:PreEncodeJSON(input)
    local output = {}
    for key, value in pairs(input) do
        if type(key) == "number" then
            key = tostring(key)
        elseif type(key) == "string" then
            key = "_"..key
        end
        if type(value) == "table" then
            value = self:PreEncodeJSON(value)
        end
        output[key] = value
    end
    return output
end

---@param input table<string|number, any>
function configManager:PostDecodeJSON(input)
    local output = {}
    for key, value in pairs(input) do
        local num = tonumber(key)
        if num then
            key = num
        else
            key = key:sub(2)
        end
        if type(value) == "table" then
            value = self:PostDecodeJSON(value)
        end
        output[key] = value
    end
    return output
end

function configManager:Save()
    self.Mod:SaveData(json.encode(self:PreEncodeJSON(self.Data)))
end

---@param lazy? boolean
---@return boolean loaded
function configManager:Load(lazy)
    local load = Isaac.GetFrameCount()
    if lazy and load <= self.LastLoad + 1 then
        self.LastLoad = load
        return false
    end
    self.LastLoad = load

    if not self.Mod:HasData() then
        self.Data = {}
    else
        self.Data = self:PostDecodeJSON(json.decode(self.Mod:LoadData()))
    end
    self.Data.Config = self.Data.Config or {}
    self.Data.ConfigDefault = self.Data.ConfigDefault or {}
    if self:Check(self.Config, self.Data.Config, self.Data.ConfigDefault) then
        print("Configs have been changed in cat_guy_config.lua, which have overwritten ones made in-game")
        self:Save()
    end
    return true
end

---@param src table<any, any>
---@param dest table<any, any>
function configManager:Copy(src, dest)
    for key, val in pairs(src) do
        if type(val) ~= "table" then
            dest[key] = val
        else
            self:Copy(val, dest[key])
        end
    end
end

---@param tableConfig table<string, any>
---@param tableSave table<string, any>
---@param tableSaveDefault table<string, any>
function configManager:Check(tableConfig, tableSave, tableSaveDefault)
    local changed = false
    for key, val in pairs(tableSaveDefault) do
        if type(val) ~= "table" then
            if tableConfig[key] ~= val then
                tableSave[key] = nil
                tableSaveDefault[key] = nil
                changed = true
            end
        elseif type(tableConfig[key]) == "table" and type(tableSave[key]) == "table" then
            if self:Check(tableConfig[key], tableSave[key], val) then
                changed = true
            end
        end
    end
    return changed
end

---@param configName string
---@param value any
function configManager:Set(configName, value)
    self.Data.Config[configName] = value
    self.Data.ConfigDefault[configName] = self.Config[configName]
    self:Save()
end

---@param configName string
---@return any
function configManager:Get(configName)
    if self.Data and self.Data.Config and self.Data.Config[configName] ~= nil then
        return self.Data.Config[configName]
    end
    return self.Config[configName]
end

---@param music Music|string
---@param value boolean
function configManager:SetTempoEnabled(music, value)
    if type(music) == "number" and music >= Music.NUM_MUSIC then
        local node = XMLData.GetEntryById(XMLNode.MUSIC, music) ---@type MusicXMLNode
        if node then
            music = node.name
        end
    end
    self.Data.Config.TempoEnabled = self.Data.Config.TempoEnabled or {}
    self.Data.Config.TempoEnabled[music] = value
    self.Data.ConfigDefault.TempoEnabled = self.Data.ConfigDefault.TempoEnabled or {}
    self.Data.ConfigDefault.TempoEnabled[music] = self.Config.TempoEnabled[music]
    self:Save()
end

---@param music Music|string
---@return boolean?
function configManager:GetTempoEnabled(music)
    if self.Data and self.Data.Config and self.Data.Config.TempoEnabled and self.Data.Config.TempoEnabled[music] ~= nil then
        return self.Data.Config.TempoEnabled[music]
    end
    if self.Config.TempoEnabled[music] ~= nil then
        return self.Config.TempoEnabled[music]
    end
    if type(music) == "number" then
        local node = XMLData.GetEntryById(XMLNode.MUSIC, music) ---@type MusicXMLNode
        if node then
            return self:GetTempoEnabled(node.name)
        end
    end
    return true
end

function configManager:IsButtonTriggered(configName)
    return Input.IsButtonTriggered(CatGuy.Config:Get(configName), 0) or CatGuy.PlayerUtils.AnyPlayer(function(player)
        return Input.IsButtonTriggered(CatGuy.Config:Get(configName.."Controller"), player.ControllerIndex) end)
end

function configManager:IsButtonPressed(configName)
    return Input.IsButtonPressed(CatGuy.Config:Get(configName), 0) or CatGuy.PlayerUtils.AnyPlayer(function(player)
        return Input.IsButtonPressed(CatGuy.Config:Get(configName.."Controller"), player.ControllerIndex) end)
end

return configManager