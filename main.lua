---@class CatGuyMod: ModReference
CatGuy = RegisterMod("cat_guy", 1)

if not REPENTOGON then
    return
end

---@type PlayerUtils
CatGuy.PlayerUtils = include("scripts_cat_guy.players.player_utils")

---@type TempoManager
local TempoManager = include("scripts_cat_guy.tempo.tempo_manager")
---@type table<Music, TempoDef>
local tempoDefs = include("scripts_cat_guy.tempo.tempo_defs")
CatGuy.TempoManager = TempoManager:New(tempoDefs)

---@type table<PlayerType, PlayerCallbacks>
CatGuy.PlayerCallbacks = {}
CatGuy.PlayerCallbacks[Isaac.GetPlayerTypeByName("Percy")]              = include("scripts_cat_guy.players.percy")
CatGuy.PlayerCallbacks[Isaac.GetPlayerTypeByName("Percy", true)]        = include("scripts_cat_guy.players.percy_b")

---@type table<CollectibleType, CollectibleCallbacks>
CatGuy.CollectibleCallbacks = {}
CatGuy.CollectibleCallbacks[Isaac.GetItemIdByName("Mom's Headphones")]  = include("scripts_cat_guy.collectibles.moms_headphones")
CatGuy.CollectibleCallbacks[Isaac.GetItemIdByName("Underhands")]        = include("scripts_cat_guy.collectibles.underhands")

---@type table<TrinketType, TrinketCallbacks>
CatGuy.TrinketCallbacks = {}
CatGuy.TrinketCallbacks[Isaac.GetTrinketIdByName("Toy Metronome")]      = include("scripts_cat_guy.trinkets.toy_metronome")


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
function CatGuy:AddCallbacks(callbacks)
    if callbacks.PostNewRoom then
        self:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function(_)
            return callbacks.PostNewRoom()
        end)
    end
    if callbacks.PostGameStarted then
        self:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function(_, continued)
            return callbacks.PostGameStarted(continued)
        end)
    end
    if callbacks.PostPlayerUpdate then
        self:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
            return callbacks.PostPlayerUpdate(player)
        end)
    end
    if callbacks.PostPlayerRender then
        self:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, function(_, player)
            return callbacks.PostPlayerRender(player)
        end)
    end
    if callbacks.PreTriggerPlayerDeath then
        self:AddCallback(ModCallbacks.MC_PRE_TRIGGER_PLAYER_DEATH, function(_, player)
            return callbacks.PreTriggerPlayerDeath(player)
        end)
    end
    if callbacks.EvaluateTearHitParams then
        self:AddCallback(ModCallbacks.MC_EVALUATE_TEAR_HIT_PARAMS, function(_, player, params, weaponType, damageScale, tearDisplacement, source)
            --Isaac.DebugString(params.TearDamage..", "..params.TearScale)
            return callbacks.EvaluateTearHitParams(player, params, weaponType, damageScale, tearDisplacement, source)
        end)
    end
    if callbacks.PostFireTear then
        self:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, function(_, tear)
            return callbacks.PostFireTear(tear)
        end)
    end
    if callbacks.PostFireBrimstone then
        self:AddCallback(ModCallbacks.MC_POST_FIRE_BRIMSTONE, function(_, laser)
            return callbacks.PostFireBrimstone(laser)
        end)
    end
    if callbacks.PostFireTechLaser then
        self:AddCallback(ModCallbacks.MC_POST_FIRE_TECH_LASER, function(_, laser)
            return callbacks.PostFireTechLaser(laser)
        end)
    end
    if callbacks.PostFireTechXLaser then
        self:AddCallback(ModCallbacks.MC_POST_FIRE_TECH_X_LASER, function(_, laser)
            return callbacks.PostFireTechXLaser(laser)
        end)
    end
    if callbacks.PostFireKnife then
        self:AddCallback(ModCallbacks.MC_POST_FIRE_TECH_X_LASER, function(_, knife)
            return callbacks.PostFireKnife(knife)
        end)
    end
    if callbacks.UseItem then
        self:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, itemId, rng, player, flags, slot, custonVarData)
            return callbacks.UseItem(itemId, rng, player, flags, slot, custonVarData)
        end)
    end
    if callbacks.PreFamiliarUpdate then
        self:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_UPDATE, function(_, familiar)
            return callbacks.PreFamiliarUpdate(familiar)
        end)
    end
    if callbacks.PostFamiliarUpdate then
        self:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, familiar)
            return callbacks.PostFamiliarUpdate(familiar)
        end)
    end
    if callbacks.PostFamiliarFireTechLaser then
        self:AddCallback(ModCallbacks.MC_POST_FAMILIAR_FIRE_TECH_LASER, function(_, laser)
            return callbacks.PostFamiliarFireTechLaser(laser)
        end)
    end
    if callbacks.Tick then
        self:AddCallback("CAT_GUY_TICK", function(_, measure)
            return callbacks.Tick(measure)
        end)
    end
    if callbacks.EvaluateCache then
        for flag, func in pairs(callbacks.EvaluateCache) do
            if flag == CacheFlag.CACHE_ALL then
                self:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, flag0)
                    return func(player, flag0)
                end)
            else
                self:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, flag0)
                    return func(player, flag0)
                end, flag)
            end
        end
    end
end

---@param itemId CollectibleType
---@param callbacks CollectibleCallbacks
function CatGuy:AddCollectibleCallbacks(itemId, callbacks)
    self:AddCallbacks(callbacks)
    if callbacks.PostAddCollectible_item then
        self:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, function(_, type, charge, firstTime, slot, varData, player)
            return callbacks.PostAddCollectible_item(type, charge, firstTime, slot, varData, player)
        end, itemId)
    end
    if callbacks.UseItem_item then
        self:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, itemId, rng, player, flags, slot, custonVarData)
            return callbacks.UseItem_item(itemId, rng, player, flags, slot, custonVarData)
        end, itemId)
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



CatGuy:AddCallback(ModCallbacks.MC_PRE_MUSIC_PLAY, function(_, music, _, _)
    CatGuy.TempoManager:PreMusicPlay(music)
end)

CatGuy:AddCallback(ModCallbacks.MC_POST_RENDER, function(_)
    CatGuy.TempoManager:PostRender()
end)

CatGuy.TempoManager:RestartMusic()