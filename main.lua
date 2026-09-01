---@class CatGuyMod: ModReference
CatGuy = RegisterMod("cat_guy", 1)

if not REPENTOGON then
    return
end

local json = require("json")

CatGuy.ModCallbacks = {
    TICK                = "CAT_GUY_TICK",
    POST_BPM_CHANGE     = "CAT_GUY_POST_BPM_CHANGE",
    POST_LOAD           = "CAT_GUY_POST_LOAD"
}

CatGuy.PlayerType = {
    PERCY                   = Isaac.GetPlayerTypeByName("Percy"),
    PERCY_B                 = Isaac.GetPlayerTypeByName("Percy", true)
}

CatGuy.CollectibleType = {
    MOMS_HEADPHONES         = Isaac.GetItemIdByName("Mom's Headphones"),
    TRIPLET_SWING           = Isaac.GetItemIdByName("Triplet Swing"),
    FORTE                   = Isaac.GetItemIdByName("Forte"),
    UNDERHANDS              = Isaac.GetItemIdByName("Underhands")
}

CatGuy.TrinketType = {
    TOY_METRONOME           = Isaac.GetTrinketIdByName("Toy Metronome"),
    BROKEN_HEADPHONES       = Isaac.GetTrinketIdByName("Broken Headphones")
}

CatGuy.NullItemID = {
    PERCY_REVIVE            = Isaac.GetNullItemIdByName("Percy Revive"),
    DEAD_CAT_REVIVE         = Isaac.GetNullItemIdByName("Dead Cat Revive"),
    PERCY_ETERNAL_HEART     = Isaac.GetNullItemIdByName("Percy Eternal Heart"),
    TRIPLET_SWING_HURT      = Isaac.GetNullItemIdByName("Triplet Swing Hurt"),
    TRIPLET_SWING_ANNOYED   = Isaac.GetNullItemIdByName("Triplet Swing Annoyed"),
    FORTE_SCARED            = Isaac.GetNullItemIdByName("Forte Scared")
}

local FAMILIAR_DAMAGE_MULTIPLIER_LILITH = {
    [FamiliarVariant.INCUBUS] = 1.0,
    [FamiliarVariant.TWISTED_BABY] = 0.5, -- twisted pair
    [FamiliarVariant.UMBILICAL_BABY] = 1.0 -- gello
}

---Keyed by Player Type, Familiar Variant, and (optionally) Familiar SubType
---@type table<PlayerType, table<FamiliarVariant, number|table<integer, number>>>
CatGuy.FamiliarVariantDamageMultipliers = {
    [-1] = { -- default
        [FamiliarVariant.TWISTED_BABY] = 0.375, -- twisted pair
        [FamiliarVariant.BLOOD_BABY] = { -- sumptorium clot
            [-1] = 0.35, -- default
            [2] = 0.43, -- black clot
            [3] = 0.52, -- eternal clot
        }
    },
    [PlayerType.PLAYER_LILITH] = FAMILIAR_DAMAGE_MULTIPLIER_LILITH,
    [PlayerType.PLAYER_LILITH_B] = FAMILIAR_DAMAGE_MULTIPLIER_LILITH
}

---@param familiar EntityFamiliar
function CatGuy.GetFamiliarVariantDamageMultiplier(familiar)
    local multipliers = CatGuy.FamiliarVariantDamageMultipliers[familiar.Player:GetPlayerType()]
    local val = (multipliers and multipliers[familiar.Variant])
        or CatGuy.FamiliarVariantDamageMultipliers[-1][familiar.Variant]
    if type(val) == "table" then
        val = val[familiar.SubType] or val[-1]
    end
    return val or (multipliers and multipliers[-1]) or 0.75
end

---@param input table<string|number, any>
function CatGuy:PreEncodeJSON(input)
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
function CatGuy:PostDecodeJSON(input)
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

function CatGuy:CatGuySave()
    self:SaveData(json.encode(self:PreEncodeJSON(self.Save)))
end

CatGuy.LastLoad = 0

---@param lazy? boolean
---@return boolean loaded
function CatGuy:CatGuyLoad(lazy)
    local load = Isaac.GetFrameCount()
    if lazy and load <= self.LastLoad + 1 then
        self.LastLoad = load
        return false
    end
    self.LastLoad = load

    if not self:HasData() then
        self.Save = {}
    else
        self.Save = self:PostDecodeJSON(json.decode(self:LoadData()))
    end
    self.Save.Config = self.Save.Config or {}
    self.Save.ConfigDefault = self.Save.ConfigDefault or {}
    if self:CheckConfig(self.Config, self.Save.Config, self.Save.ConfigDefault) then
        print("Configs have been changed in cat_guy_config.lua, which have overwritten ones made in-game")
        self:CatGuySave()
    end
    return true
end

---@param src table<any, any>
---@param dest table<any, any>
function CatGuy:CopyConfig(src, dest)
    for key, val in pairs(src) do
        if type(val) ~= "table" then
            dest[key] = val
        else
            self:CopyConfig(val, dest[key])
        end
    end
end

---@param tableConfig table<string, any>
---@param tableSave table<string, any>
---@param tableSaveDefault table<string, any>
function CatGuy:CheckConfig(tableConfig, tableSave, tableSaveDefault)
    local changed = false
    for key, val in pairs(tableSaveDefault) do
        if type(val) ~= "table" then
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
    self.Save.Config[configName] = value
    self.Save.ConfigDefault[configName] = self.Config[configName]
    self:CatGuySave()
end

---@param configName string
---@return any
function CatGuy:GetConfig(configName)
    if self.Save and self.Save.Config and self.Save.Config[configName] ~= nil then
        return self.Save.Config[configName]
    end
    return self.Config[configName]
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
    self.Save.Config.TempoEnabled = self.Save.Config.TempoEnabled or {}
    self.Save.Config.TempoEnabled[music] = value
    self.Save.ConfigDefault.TempoEnabled = self.Save.ConfigDefault.TempoEnabled or {}
    self.Save.ConfigDefault.TempoEnabled[music] = self.Config.TempoEnabled[music]
    self:CatGuySave()
end

---@param music Music|string
---@return boolean?
function CatGuy:GetTempoEnabled(music)
    if self.Save and self.Save.Config and self.Save.Config.TempoEnabled and self.Save.Config.TempoEnabled[music] ~= nil then
        return self.Save.Config.TempoEnabled[music]
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

CatGuy.ID = "3790558949"
CatGuy.XML = XMLData.GetModById(CatGuy.ID)

CatGuy.Config = include("cat_guy_config") ---@type CatGuyConfig
local userConfig = include("cat_guy_config_user")
if type(userConfig) == "table" then
    CatGuy:CopyConfig(userConfig, CatGuy.Config)
end
CatGuy:CatGuyLoad()

CatGuy.PlayerUtils = include("scripts_cat_guy.players.player_utils") ---@type PlayerUtils

local TempoManager = include("scripts_cat_guy.tempo.tempo_manager") ---@type TempoManager
local tempoDefs = include("scripts_cat_guy.tempo.tempo_defs") ---@type table<Music, TempoDef>
CatGuy.TempoManager = TempoManager:New(tempoDefs)

CatGuy.PlayerCallbacks = { ---@type table<PlayerType, PlayerCallbacks>
    [CatGuy.PlayerType.PERCY]                   = include("scripts_cat_guy.players.percy"),
    [CatGuy.PlayerType.PERCY_B]                 = include("scripts_cat_guy.players.percy_b"),
}

CatGuy.CollectibleCallbacks = { ---@type table<CollectibleType, CollectibleCallbacks>
    [CatGuy.CollectibleType.MOMS_HEADPHONES]    = include("scripts_cat_guy.collectibles.moms_headphones"),
    [CatGuy.CollectibleType.TRIPLET_SWING]      = include("scripts_cat_guy.collectibles.triplet_swing"),
    [CatGuy.CollectibleType.FORTE]              = include("scripts_cat_guy.collectibles.forte"),
    [CatGuy.CollectibleType.UNDERHANDS]         = include("scripts_cat_guy.collectibles.underhands"),
    [CollectibleType.COLLECTIBLE_TOOTH_AND_NAIL]= include("scripts_cat_guy.collectibles.tooth_and_nail")
}

CatGuy.TrinketCallbacks = { ---@type table<TrinketType, TrinketCallbacks>
    [CatGuy.TrinketType.TOY_METRONOME]          = include("scripts_cat_guy.trinkets.toy_metronome"),
    [CatGuy.TrinketType.BROKEN_HEADPHONES]      = include("scripts_cat_guy.trinkets.broken_headphones")
}

---@param player EntityPlayer
function CatGuy:PostPlayerInit(player)
    local callbacks = self.PlayerCallbacks[player:GetPlayerType()]
    if callbacks and callbacks.PostPlayerInit_player then
        return callbacks.PostPlayerInit_player(player)
    end
end
CatGuy:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, CatGuy.PostPlayerInit, PlayerVariant.PLAYER)

---@param player EntityPlayer
function CatGuy:PostPlayerUpdate(player)
    local callbacks = self.PlayerCallbacks[player:GetPlayerType()]
    if callbacks and callbacks.PostPlayerUpdate_player then
        return callbacks.PostPlayerUpdate_player(player)
    end
end
CatGuy:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, CatGuy.PostPlayerUpdate, PlayerVariant.PLAYER)

---@param this CatGuyMod
CatGuy:AddCallback(ModCallbacks.MC_PRE_PLAYER_RENDER, function(this, player, renderOffset)
    local callbacks = this.PlayerCallbacks[player:GetPlayerType()]
    if callbacks and callbacks.PrePlayerRender_player then
        return callbacks.PrePlayerRender_player(player, renderOffset)
    end
end, PlayerVariant.PLAYER)

--[[ ---@param this CatGuyMod
CatGuy:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, function(this, player, renderOffset)
    local callbacks = this.PlayerCallbacks[player:GetPlayerType()]
    if callbacks and callbacks.PostPlayerRender_player then
        return callbacks.PostPlayerRender_player(player, renderOffset)
    end
end, PlayerVariant.PLAYER) ]]

---@param this CatGuyMod
CatGuy:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_ADDED, function(this, player, type, firstTime, wispOrInnate)
    local callbacks = this.PlayerCallbacks[player:GetPlayerType()]
    if callbacks and callbacks.PostTriggerBirthrightAdded_player then
        return callbacks.PostTriggerBirthrightAdded_player(player, type, firstTime, wispOrInnate)
    end
end, CollectibleType.COLLECTIBLE_BIRTHRIGHT)

---@param this CatGuyMod
CatGuy:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, function(this, player, type, removeFromPlayerForm, wispOrInnate)
    local callbacks = this.PlayerCallbacks[player:GetPlayerType()]
    if callbacks and callbacks.PostTriggerBirthrightRemoved_player then
        return callbacks.PostTriggerBirthrightRemoved_player(player, type, removeFromPlayerForm, wispOrInnate)
    end
end, CollectibleType.COLLECTIBLE_BIRTHRIGHT)

---@param player EntityPlayer
function CatGuy:PreTriggerPlayerDeath(player)
    local callbacks = self.PlayerCallbacks[player:GetPlayerType()]
    if callbacks and callbacks.PreTriggerPlayerDeath_player then
        return callbacks.PreTriggerPlayerDeath_player(player)
    end
end
CatGuy:AddCallback(ModCallbacks.MC_PRE_TRIGGER_PLAYER_DEATH, CatGuy.PreTriggerPlayerDeath)


---@param player EntityPlayer
---@param amount integer
function CatGuy:PrePlayerAddMaxHearts(player, amount)
    local callbacks = self.PlayerCallbacks[player:GetPlayerType()]
    if callbacks and callbacks.PrePlayerAddMaxHearts_player then
        return callbacks.PrePlayerAddMaxHearts_player(player, amount)
    end
end
CatGuy:AddCallback(ModCallbacks.MC_PRE_PLAYER_ADD_HEARTS, CatGuy.PrePlayerAddMaxHearts, AddHealthType.MAX)

---@param player EntityPlayer
---@param amount integer
function CatGuy:PrePlayerAddEternalHearts(player, amount)
    local callbacks = self.PlayerCallbacks[player:GetPlayerType()]
    if callbacks and callbacks.PrePlayerAddEternalHearts_player then
        return callbacks.PrePlayerAddEternalHearts_player(player, amount)
    end
end
CatGuy:AddCallback(ModCallbacks.MC_PRE_PLAYER_ADD_HEARTS, CatGuy.PrePlayerAddEternalHearts, AddHealthType.ETERNAL)

---@param this CatGuyMod
CatGuy:AddCallback(ModCallbacks.MC_POST_PLAYERHUD_RENDER_HEARTS, function(this, offset, heartsSprite, position, spriteScale, player)
    local callbacks = this.PlayerCallbacks[player:GetPlayerType()]
    if callbacks and callbacks.PostPlayerHUDRenderHearts_player then
        return callbacks.PostPlayerHUDRenderHearts_player(offset, heartsSprite, position, spriteScale, player)
    end
end)

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
    if callbacks.PostNewLevel then
        self:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, priority, function(_)
            return callbacks.PostNewLevel()
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
        end, EntityType.ENTITY_PLAYER)
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
        ---@param tempoManager TempoManager
        self:AddPriorityCallback(self.ModCallbacks.TICK, priority, function(_, tempoManager)
            return callbacks.Tick(tempoManager)
        end)
    end
    if callbacks.PostBPMChange then
        ---@param tempoManager TempoManager
        self:AddPriorityCallback(self.ModCallbacks.POST_BPM_CHANGE, priority, function(_, tempoManager)
            return callbacks.PostBPMChange(tempoManager)
        end)
    end
    if callbacks.PreMusicPlay then
        self:AddPriorityCallback(ModCallbacks.MC_PRE_MUSIC_PLAY, priority, function(_, music, volume, isFade)
            return callbacks.PreMusicPlay(music, volume, isFade)
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
    if callbacks.EvaluateStat then
        for stage, func in pairs(callbacks.EvaluateStat) do
            self:AddPriorityCallback(ModCallbacks.MC_EVALUATE_STAT, priority, function(_, player, stage0, value)
                return func(player, stage0, value)
            end, stage)
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
    if callbacks.PostTriggerCollectibleAdded_item then
        self:AddPriorityCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_ADDED, priority, function(_, player, type, firstTime, wispOrInnate)
            return callbacks.PostTriggerCollectibleAdded_item(player, type, firstTime, wispOrInnate)
        end, itemId)
    end
    if callbacks.PostTriggerCollectibleRemoved_item then
        self:AddPriorityCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, priority, function(_, player, type, removeFromPlayerForm, wispOrInnate)
            return callbacks.PostTriggerCollectibleRemoved_item(player, type, removeFromPlayerForm, wispOrInnate)
        end, itemId)
    end

    if callbacks.UseItem_item then
        self:AddPriorityCallback(ModCallbacks.MC_USE_ITEM, priority, function(_, type, rng, player, flags, slot, custonVarData)
            return callbacks.UseItem_item(type, rng, player, flags, slot, custonVarData)
        end, itemId)
    end

    if callbacks.Priority_item then
        for priority0, callbacks0 in pairs(callbacks.Priority_item) do
            self:AddCollectibleCallbacks(itemId, callbacks0, priority0)
        end
    end
end

---@param playerType PlayerType
---@param callbacks PlayerCallbacks
---@param priority? CallbackPriority
function CatGuy:AddPlayerCallbacks(playerType, callbacks, priority)
    priority = priority or CallbackPriority.DEFAULT

    self:AddCallbacks(callbacks, priority)

    if callbacks.PreRenderCharacterSelectPage_player then
        self:AddPriorityCallback(ModCallbacks.MC_PRE_RENDER_CHARACTER_SELECT_PAGE, priority, function(_, type, renderPos, defaultSprite, moddedSprite, hasCustomBackground)
            return callbacks.PreRenderCharacterSelectPage_player(type, renderPos, defaultSprite, moddedSprite, hasCustomBackground)
        end, playerType)
    end

    if callbacks.Priority_player then
        for priority0, callbacks0 in pairs(callbacks.Priority_player) do
            self:AddPlayerCallbacks(playerType, callbacks0, priority0)
        end
    end
end

---@param trinketType TrinketType
---@param callbacks TrinketCallbacks
---@param priority? CallbackPriority
function CatGuy:AddTrinketCallbacks(trinketType, callbacks, priority)
    priority = priority or CallbackPriority.DEFAULT

    self:AddCallbacks(callbacks, priority)

    if callbacks.PreAddTrinket_trinket then
        self:AddPriorityCallback(ModCallbacks.MC_PRE_ADD_TRINKET, priority, function(_, player, trinketType0, firstTime)
            return callbacks.PreAddTrinket_trinket(player, trinketType0, firstTime)
        end, trinketType)
    end

    if callbacks.Priority_trinket then
        for priority0, callbacks0 in pairs(callbacks.Priority_trinket) do
            self:AddTrinketCallbacks(trinketType, callbacks0, priority0)
        end
    end
end

for itemId, callbacks in pairs(CatGuy.CollectibleCallbacks) do
    CatGuy:AddCollectibleCallbacks(itemId, callbacks)
end

for playerType, callbacks in pairs(CatGuy.PlayerCallbacks) do
    CatGuy:AddPlayerCallbacks(playerType, callbacks)
end

for trinketType, callbacks in pairs(CatGuy.TrinketCallbacks) do
    CatGuy:AddTrinketCallbacks(trinketType, callbacks)
end

CatGuy:AddPriorityCallback(ModCallbacks.MC_PRE_MUSIC_PLAY, CallbackPriority.LATE, function(_, music, _, _)
    CatGuy.TempoManager:PreMusicPlay(music)
end)

CatGuy:AddPriorityCallback(ModCallbacks.MC_POST_RENDER, CallbackPriority.LATE, function(_)
    CatGuy.TempoManager:PostRender()
end)

function CatGuy:PostGameStarted()
    self:CatGuyLoad()
    if ModConfigMenu then
        self.Compat.ModConfigMenu:Init(ModConfigMenu, InputHelper, tempoDefs)
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

Isaac.RunCallback(CatGuy.ModCallbacks.POST_LOAD)