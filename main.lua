---@class CatGuyMod: ModReference
CatGuy = RegisterMod("cat_guy", 1)

if not REPENTOGON then
    return
end

local json = require("json")

CatGuy.PlayerType = {
    PERCY               = Isaac.GetPlayerTypeByName("Percy"),
    PERCY_B             = Isaac.GetPlayerTypeByName("Percy", true)
}

CatGuy.CollectibleType = {
    MOMS_HEADPHONES     = Isaac.GetItemIdByName("Mom's Headphones"),
    TRIPLE_METRE        = Isaac.GetItemIdByName("Triple Metre"),
    UNDERHANDS          = Isaac.GetItemIdByName("Underhands")
}

CatGuy.TrinketType = {
    TOY_METRONOME       = Isaac.GetTrinketIdByName("Toy Metronome")
}

CatGuy.NullItemID = {
    PERCY_REVIVE        = Isaac.GetNullItemIdByName("Percy Revive"),
    DEAD_CAT_REVIVE     = Isaac.GetNullItemIdByName("Dead Cat Revive"),
    TRIPLE_METRE_HURT   = Isaac.GetNullItemIdByName("Triple Metre Hurt")
}

---@param input table<string|number, any>
function CatGuy:PreEncodeJSON(input)
    local output = {}
    for key, value in pairs(input) do
        if type(key) == "number" then
            key = tostring(key)
        end
        if type(value) == "table" then
            value = CatGuy:PreEncodeJSON(value)
        end
        output[key] = value
    end
    return output
end

---@param input table<string|number, any>
function CatGuy:PostDecodeJSON(input)
    local output = {}
    for key, value in pairs(input) do
        local num = tonumber(key)
        if num then
            key = num
        end
        if type(value) == "table" then
            value = CatGuy:PostDecodeJSON(value)
        end
        output[key] = value
    end
    return output
end

function CatGuy:CatGuySave()
    CatGuy:SaveData(json.encode(CatGuy:PreEncodeJSON(CatGuy.Save)))
end

function CatGuy:CatGuyLoad()
    if not CatGuy:HasData() then
        CatGuy.Save = {}
    else
        CatGuy.Save = CatGuy:PostDecodeJSON(json.decode(CatGuy:LoadData()))
    end
    CatGuy.Save.Config = CatGuy.Save.Config or {}
    CatGuy.Save.ConfigDefault = CatGuy.Save.ConfigDefault or {}
    if CatGuy:CheckConfig(CatGuy.Config, CatGuy.Save.Config, CatGuy.Save.ConfigDefault) then
        print("Configs have been changed in cat_guy_config.lua, which have overwritten ones made in-game")
        CatGuy:CatGuySave()
    end
end

---@param tableConfig table<string, any>
---@param tableSave table<string, any>
---@param tableSaveDefault table<string, any>
function CatGuy:CheckConfig(tableConfig, tableSave, tableSaveDefault)
    local changed = false
    for key, val in pairs(tableSaveDefault) do
        if val == nil then
        elseif type(val) ~= "table" then
            if tableConfig[key] ~= val then
                tableSave[key] = nil
                tableSaveDefault[key] = nil
                changed = true
            end
        elseif type(tableConfig[key]) == "table" and type(tableSave[key]) == "table" then
            if self:CheckConfig(tableConfig[key], tableSave[key], val) then
                changed = true
            end
        end
    end
    return changed
end

---@param configName string
---@param value any
function CatGuy:SetConfig(configName, value)
    CatGuy.Save.Config[configName] = value
    CatGuy.Save.ConfigDefault[configName] = CatGuy.Config[configName]
    CatGuy:CatGuySave()
end

---@param configName string
---@return any
function CatGuy:GetConfig(configName)
    if CatGuy.Save and CatGuy.Save.Config and CatGuy.Save.Config[configName] ~= nil then
        return CatGuy.Save.Config[configName]
    end
    return CatGuy.Config[configName]
end

---@param music Music|string
---@param value boolean
function CatGuy:SetTempoEnabled(music, value)
    if type(music) == "number" and music >= Music.NUM_MUSIC then
        local node = XMLData.GetEntryById(XMLNode.MUSIC, music) ---@type MusicXMLNode
        if node then
            music = node.name
        end
    end
    CatGuy.Save.Config.TempoEnabled = CatGuy.Save.Config.TempoEnabled or {}
    CatGuy.Save.Config.TempoEnabled[music] = value
    CatGuy.Save.ConfigDefault.TempoEnabled = CatGuy.Save.ConfigDefault.TempoEnabled or {}
    CatGuy.Save.ConfigDefault.TempoEnabled[music] = CatGuy.Config.TempoEnabled[music]
    CatGuy:CatGuySave()
end

---@param music Music|string
---@return boolean?
function CatGuy:GetTempoEnabled(music)
    if CatGuy.Save and CatGuy.Save.Config and CatGuy.Save.Config.TempoEnabled and CatGuy.Save.Config.TempoEnabled[music] ~= nil then
        return CatGuy.Save.Config.TempoEnabled[music]
    end
    if CatGuy.Config.TempoEnabled[music] ~= nil then
        return CatGuy.Config.TempoEnabled[music]
    end
    if type(music) == "number" then
        local node = XMLData.GetEntryById(XMLNode.MUSIC, music) ---@type MusicXMLNode
        if node then
            return self:GetTempoEnabled(node.name)
        end
    end
    return true
end

CatGuy.XML = XMLData.GetModById(XMLData.GetEntryById(XMLNode.ITEM, CatGuy.CollectibleType.MOMS_HEADPHONES).sourceid)

CatGuy.Config = include("cat_guy_config") ---@type CatGuyConfig
CatGuy:CatGuyLoad()

CatGuy.PlayerUtils = include("scripts_cat_guy.players.player_utils") ---@type PlayerUtils

local TempoManager = include("scripts_cat_guy.tempo.tempo_manager") ---@type TempoManager
local tempoDefs = include("scripts_cat_guy.tempo.tempo_defs") ---@type table<Music, TempoDef>
CatGuy.TempoManager = TempoManager:New(tempoDefs)

CatGuy.PlayerCallbacks = {} ---@type table<PlayerType, PlayerCallbacks>
CatGuy.PlayerCallbacks[CatGuy.PlayerType.PERCY]                         = include("scripts_cat_guy.players.percy")
CatGuy.PlayerCallbacks[CatGuy.PlayerType.PERCY_B]                       = include("scripts_cat_guy.players.percy_b")

CatGuy.CollectibleCallbacks = {} ---@type table<CollectibleType, CollectibleCallbacks>
CatGuy.CollectibleCallbacks[CatGuy.CollectibleType.MOMS_HEADPHONES]     = include("scripts_cat_guy.collectibles.moms_headphones")
CatGuy.CollectibleCallbacks[CatGuy.CollectibleType.TRIPLE_METRE]        = include("scripts_cat_guy.collectibles.triple_metre")
CatGuy.CollectibleCallbacks[CatGuy.CollectibleType.UNDERHANDS]          = include("scripts_cat_guy.collectibles.underhands")

CatGuy.TrinketCallbacks = {} ---@type table<TrinketType, TrinketCallbacks>
CatGuy.TrinketCallbacks[CatGuy.TrinketType.TOY_METRONOME]               = include("scripts_cat_guy.trinkets.toy_metronome")

if Isaac.GetFrameCount() < 1 and CatGuy:GetConfig("ReworkToothAndNail") then
    CAT_GUY_REWORKED_TOOTH_AND_NAIL = true
    Isaac.ReworkCollectible(CollectibleType.COLLECTIBLE_TOOTH_AND_NAIL)
end
if CAT_GUY_REWORKED_TOOTH_AND_NAIL then
    CatGuy.CollectibleCallbacks[CollectibleType.COLLECTIBLE_TOOTH_AND_NAIL] = include("scripts_cat_guy.collectibles.tooth_and_nail")
end

---@param player EntityPlayer
function CatGuy:PostPlayerInit(player)
    local callbacks = self.PlayerCallbacks[player:GetPlayerType()]
    if callbacks and callbacks.PostPlayerInit_player then
        return callbacks.PostPlayerInit_player(player)
    end
end

---@param player EntityPlayer
function CatGuy:PostPlayerUpdate(player)
    local callbacks = self.PlayerCallbacks[player:GetPlayerType()]
    if callbacks and callbacks.PostPlayerUpdate_player then
        return callbacks.PostPlayerUpdate_player(player)
    end
end

---@param player EntityPlayer
---@param renderOffset Vector
function CatGuy:PostPlayerRender(player, renderOffset)
    local callbacks = self.PlayerCallbacks[player:GetPlayerType()]
    if callbacks and callbacks.PostPlayerRender_player then
        return callbacks.PostPlayerRender_player(player, renderOffset)
    end
end

---@param player EntityPlayer
function CatGuy:PostAddBirthright(type, charge, firstTime, slot, varData, player)
    local callbacks = self.PlayerCallbacks[player:GetPlayerType()]
    if callbacks and callbacks.PostAddBirthright_player then
        return callbacks.PostAddBirthright_player(type, charge, firstTime, slot, varData, player)
    end
end

---@param player EntityPlayer
function CatGuy:PreTriggerPlayerDeath(player)
    local callbacks = self.PlayerCallbacks[player:GetPlayerType()]
    if callbacks and callbacks.PreTriggerPlayerDeath_player then
        return callbacks.PreTriggerPlayerDeath_player(player)
    end
end

---@param player EntityPlayer
---@param amount integer
function CatGuy:PrePlayerAddMaxHearts(player, amount)
    local callbacks = self.PlayerCallbacks[player:GetPlayerType()]
    if callbacks and callbacks.PrePlayerAddMaxHearts_player then
        return callbacks.PrePlayerAddMaxHearts_player(player, amount)
    end
end

---@param slot integer
---@param position Vector
---@param scale number
---@param player EntityPlayer
---@param cropOffset Vector
function CatGuy:PrePlayerHUDTrinketRender(slot, position, scale, player, cropOffset)
    local callbacks = self.TrinketCallbacks[player:GetTrinket(slot)]
    if callbacks and callbacks.PrePlayerHUDTrinketRender_trinket then
        return callbacks.PrePlayerHUDTrinketRender_trinket(slot, position, scale, player, cropOffset)
    end
end

CatGuy:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, CatGuy.PostPlayerInit, PlayerVariant.PLAYER)
CatGuy:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, CatGuy.PostPlayerUpdate, PlayerVariant.PLAYER)
CatGuy:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, CatGuy.PostPlayerRender, PlayerVariant.PLAYER)
CatGuy:AddCallback(ModCallbacks.MC_PRE_TRIGGER_PLAYER_DEATH, CatGuy.PreTriggerPlayerDeath)
CatGuy:AddCallback(ModCallbacks.MC_PRE_PLAYER_ADD_HEARTS, CatGuy.PrePlayerAddMaxHearts, AddHealthType.MAX)
CatGuy:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, CatGuy.PostAddBirthright, CollectibleType.COLLECTIBLE_BIRTHRIGHT)
CatGuy:AddCallback(ModCallbacks.MC_PRE_PLAYERHUD_TRINKET_RENDER, CatGuy.PrePlayerHUDTrinketRender)


---@param callbacks Callbacks
---@param priority? CallbackPriority
function CatGuy:AddCallbacks(callbacks, priority)
    priority = priority or CallbackPriority.DEFAULT

    if callbacks.InputAction then
        self:AddPriorityCallback(ModCallbacks.MC_INPUT_ACTION, priority, function(_, entity, inputHook, buttonAction)
            return callbacks.InputAction(entity, inputHook, buttonAction)
        end)
    end
    if callbacks.PostUpdate then
        self:AddPriorityCallback(ModCallbacks.MC_POST_UPDATE, priority, function(_)
            return callbacks.PostUpdate()
        end)
    end
    if callbacks.PreRender then
        self:AddPriorityCallback(ModCallbacks.MC_PRE_RENDER, priority, function(_)
            return callbacks.PreRender()
        end)
    end
    if callbacks.PostRender then
        self:AddPriorityCallback(ModCallbacks.MC_POST_RENDER, priority, function(_)
            return callbacks.PostRender()
        end)
    end
    if callbacks.PostNewRoom then
        self:AddPriorityCallback(ModCallbacks.MC_POST_NEW_ROOM, priority, function(_)
            return callbacks.PostNewRoom()
        end)
    end
    if callbacks.PostGameStarted then
        self:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED, priority, function(_, continued)
            return callbacks.PostGameStarted(continued)
        end)
    end
    if callbacks.PostPlayerUpdate then
        self:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, priority, function(_, player)
            return callbacks.PostPlayerUpdate(player)
        end, PlayerVariant.PLAYER)
    end
    if callbacks.PostPlayerRender then
        self:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_RENDER, priority, function(_, player)
            return callbacks.PostPlayerRender(player)
        end, PlayerVariant.PLAYER)
    end
    if callbacks.PlayerTakeDamage then
        self:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, priority, function(_, entity, amount, damageFlags, source, countdownFrames)
            local player = entity:ToPlayer()
            if player then
                return callbacks.PlayerTakeDamage(player, amount, damageFlags, source, countdownFrames)
            end
        end)
    end
    if callbacks.PreTriggerPlayerDeath then
        self:AddPriorityCallback(ModCallbacks.MC_PRE_TRIGGER_PLAYER_DEATH, priority, function(_, player)
            return callbacks.PreTriggerPlayerDeath(player)
        end)
    end
    if callbacks.EvaluateTearHitParams then
        self:AddPriorityCallback(ModCallbacks.MC_EVALUATE_TEAR_HIT_PARAMS, priority, function(_, player, params, weaponType, damageScale, tearDisplacement, source)
            return callbacks.EvaluateTearHitParams(player, params, weaponType, damageScale, tearDisplacement, source)
        end)
    end
    if callbacks.PostFireTear then
        self:AddPriorityCallback(ModCallbacks.MC_POST_FIRE_TEAR, priority, function(_, tear)
            return callbacks.PostFireTear(tear)
        end)
    end
    if callbacks.PostFireBrimstone then
        self:AddPriorityCallback(ModCallbacks.MC_POST_FIRE_BRIMSTONE, priority, function(_, laser)
            return callbacks.PostFireBrimstone(laser)
        end)
    end
    if callbacks.PostFireTechLaser then
        self:AddPriorityCallback(ModCallbacks.MC_POST_FIRE_TECH_LASER, priority, function(_, laser)
            return callbacks.PostFireTechLaser(laser)
        end)
    end
    if callbacks.PostFireTechXLaser then
        self:AddPriorityCallback(ModCallbacks.MC_POST_FIRE_TECH_X_LASER, priority, function(_, laser)
            return callbacks.PostFireTechXLaser(laser)
        end)
    end
    if callbacks.PostFireKnife then
        self:AddPriorityCallback(ModCallbacks.MC_POST_FIRE_KNIFE, priority, function(_, knife)
            return callbacks.PostFireKnife(knife)
        end)
    end
    if callbacks.UseItem then
        self:AddPriorityCallback(ModCallbacks.MC_USE_ITEM, priority, function(_, itemId, rng, player, flags, slot, custonVarData)
            return callbacks.UseItem(itemId, rng, player, flags, slot, custonVarData)
        end)
    end
    if callbacks.PreFamiliarUpdate then
        self:AddPriorityCallback(ModCallbacks.MC_PRE_FAMILIAR_UPDATE, priority, function(_, familiar)
            return callbacks.PreFamiliarUpdate(familiar)
        end)
    end
    if callbacks.PostFamiliarUpdate then
        self:AddPriorityCallback(ModCallbacks.MC_FAMILIAR_UPDATE, priority, function(_, familiar)
            return callbacks.PostFamiliarUpdate(familiar)
        end)
    end
    if callbacks.PostFamiliarFireTechLaser then
        self:AddPriorityCallback(ModCallbacks.MC_POST_FAMILIAR_FIRE_TECH_LASER, priority, function(_, laser)
            return callbacks.PostFamiliarFireTechLaser(laser)
        end)
    end
    if callbacks.Tick then
        self:AddPriorityCallback("CAT_GUY_TICK", priority, function(_, tempoManager)
            return callbacks.Tick(tempoManager)
        end)
    end
    if callbacks.EvaluateCache then
        for flag, func in pairs(callbacks.EvaluateCache) do
            if flag == CacheFlag.CACHE_ALL then
                self:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, priority, function(_, player, flag0)
                    return func(player, flag0)
                end)
            else
                self:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, priority, function(_, player, flag0)
                    return func(player, flag0)
                end, flag)
            end
        end
    end

    if callbacks.Priority then
        for priority0, callbacks0 in pairs(callbacks.Priority) do
            self:AddCallbacks(callbacks0, priority0)
        end
    end
end

---@param itemId CollectibleType
---@param callbacks CollectibleCallbacks
---@param priority? CallbackPriority
function CatGuy:AddCollectibleCallbacks(itemId, callbacks, priority)
    priority = priority or CallbackPriority.DEFAULT

    self:AddCallbacks(callbacks, priority)
    if callbacks.PostAddCollectible_item then
        self:AddPriorityCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, priority, function(_, type, charge, firstTime, slot, varData, player)
            return callbacks.PostAddCollectible_item(type, charge, firstTime, slot, varData, player)
        end, itemId)
    end
    if callbacks.UseItem_item then
        self:AddPriorityCallback(ModCallbacks.MC_USE_ITEM, priority, function(_, itemId, rng, player, flags, slot, custonVarData)
            return callbacks.UseItem_item(itemId, rng, player, flags, slot, custonVarData)
        end, itemId)
    end

    if callbacks.Priority_item then
        for priority0, callbacks0 in pairs(callbacks.Priority_item) do
            self:AddCollectibleCallbacks(itemId, callbacks0, priority0)
        end
    end
end

for itemId, callbacks in pairs(CatGuy.CollectibleCallbacks) do
    CatGuy:AddCollectibleCallbacks(itemId, callbacks)
end

for _, callbacks in pairs(CatGuy.PlayerCallbacks) do
    CatGuy:AddCallbacks(callbacks)
end

for _, callbacks in pairs(CatGuy.TrinketCallbacks) do
    CatGuy:AddCallbacks(callbacks)
end

CatGuy:AddPriorityCallback(ModCallbacks.MC_PRE_MUSIC_PLAY, CallbackPriority.LATE, function(_, music, _, _)
    CatGuy.TempoManager:PreMusicPlay(music)
end)

CatGuy:AddPriorityCallback(ModCallbacks.MC_POST_RENDER, CallbackPriority.LATE, function(_)
    CatGuy.TempoManager:PostRender()
end)

function CatGuy:PostGameStarted()
    CatGuy:CatGuyLoad()
    if ModConfigMenu then
        CatGuy.Compat.ModConfigMenu:Init(ModConfigMenu, InputHelper, tempoDefs)
    end
end
CatGuy:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, CatGuy.PostGameStarted)

---@param modId string
---@return boolean
function CatGuy:HasMod(modId)
    local metadata = XMLData.GetModById(modId)
    return metadata ~= nil and metadata.enabled
end

CatGuy.Compat = {}
CatGuy.Compat.EID               = include("scripts_cat_guy.compat.eid") ---@type EIDCompat
CatGuy.Compat.EIDDefs           = include("scripts_cat_guy.compat.eid_defs") ---@type EIDDefs
CatGuy.Compat.ModConfigMenu     = include("scripts_cat_guy.compat.mcm") ---@type MCMCompat

if EID then
    CatGuy.Compat.EID:Init(EID, CatGuy.Compat.EIDDefs)
else
    CatGuy:AddCallback("EID_POST_LOAD", function(_)
        CatGuy.Compat.EID:Init(EID, CatGuy.Compat.EIDDefs)
    end)
end

if Isaac.IsInGame() then
    CatGuy.TempoManager:RestartMusic()
    CatGuy:PostGameStarted()
end

Isaac.RunCallback("CAT_GUY_POST_LOAD")