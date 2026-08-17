---@class CatGuyMod: ModReference
CatGuy = RegisterMod("cat_guy", 1)

if not REPENTOGON then
    return
end

CatGuy.PlayerType = {
    PERCY           = Isaac.GetPlayerTypeByName("Percy"),
    PERCY_B         = Isaac.GetPlayerTypeByName("Percy", true)
}

CatGuy.CollectibleType = {
    MOMS_HEADPHONES = Isaac.GetItemIdByName("Mom's Headphones"),
    UNDERHANDS      = Isaac.GetItemIdByName("Underhands")
}

CatGuy.TrinketType = {
    TOY_METRONOME   = Isaac.GetTrinketIdByName("Toy Metronome")
}

CatGuy.PlayerUtils = include("scripts_cat_guy.players.player_utils") ---@type PlayerUtils

local TempoManager = include("scripts_cat_guy.tempo.tempo_manager") ---@type TempoManager
local tempoDefs = include("scripts_cat_guy.tempo.tempo_defs") ---@type table<Music, TempoDef>
CatGuy.TempoManager = TempoManager:New(tempoDefs)

CatGuy.PlayerCallbacks = {} ---@type table<PlayerType, PlayerCallbacks>
CatGuy.PlayerCallbacks[CatGuy.PlayerType.PERCY]                         = include("scripts_cat_guy.players.percy")
CatGuy.PlayerCallbacks[CatGuy.PlayerType.PERCY_B]                       = include("scripts_cat_guy.players.percy_b")

CatGuy.CollectibleCallbacks = {} ---@type table<CollectibleType, CollectibleCallbacks>
CatGuy.CollectibleCallbacks[CatGuy.CollectibleType.MOMS_HEADPHONES]     = include("scripts_cat_guy.collectibles.moms_headphones")
CatGuy.CollectibleCallbacks[CatGuy.CollectibleType.UNDERHANDS]          = include("scripts_cat_guy.collectibles.underhands")

CatGuy.TrinketCallbacks = {} ---@type table<TrinketType, TrinketCallbacks>
CatGuy.TrinketCallbacks[CatGuy.TrinketType.TOY_METRONOME]               = include("scripts_cat_guy.trinkets.toy_metronome")


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
        self:AddPriorityCallback("CAT_GUY_TICK", priority, function(_, measure)
            return callbacks.Tick(measure)
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

CatGuy:AddCallback(ModCallbacks.MC_POST_RENDER, function(_)
    CatGuy.TempoManager:PostRender()
end)

CatGuy.TempoManager:RestartMusic()


CatGuy.Compat = {}
CatGuy.Compat.EID       = include("scripts_cat_guy.compat.eid") ---@type EIDCompat
CatGuy.Compat.EIDDefs   = include("scripts_cat_guy.compat.eid_defs") ---@type EIDDefs

function CatGuy:TryAddEID()
    if EID then
        CatGuy.Compat.EID:Init(EID, CatGuy.Compat.EIDDefs)
    end
end

if EID then
    CatGuy:TryAddEID()
else
    CatGuy:AddCallback("EID_POST_LOAD", CatGuy.TryAddEID)
end