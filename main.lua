if not REPENTOGON then
    return
end

---@type table<PlayerType, PlayerCallbacks>
local playerCallbacks = {}
playerCallbacks[Isaac.GetPlayerTypeByName("Percy")]         = include("scripts_cat_guy.players.percy")
playerCallbacks[Isaac.GetPlayerTypeByName("Percy", true)]   = include("scripts_cat_guy.players.percy_b")

---@type table<CollectibleType, CollectibleCallbacks>
local collectibleCallbacks = {}
collectibleCallbacks[Isaac.GetItemIdByName("Underhands")]   = include("scripts_cat_guy.collectibles.underhands")


---@type TempoManager
local tempoManager = include("scripts_cat_guy.tempo.tempo_manager")


---@class ModCatGuy: ModReference
local mod = RegisterMod("cat_guy", 1)

---@param player EntityPlayer
function mod:PostPlayerInit(player)
    local callbacks = playerCallbacks[player:GetPlayerType()]
    if callbacks and callbacks.PostPlayerInit_player then
        return callbacks.PostPlayerInit_player(player)
    end
end

---@param player EntityPlayer
function mod:PostPlayerUpdate(player)
    local callbacks = playerCallbacks[player:GetPlayerType()]
    if callbacks and callbacks.PostPlayerUpdate_player then
        return callbacks.PostPlayerUpdate_player(player)
    end
end

---@param player EntityPlayer
function mod:PostAddBirthright(ype, charge, firstTime, slot, varData, player)
    local callbacks = playerCallbacks[player:GetPlayerType()]
    if callbacks and callbacks.PostAddBirthright_player then
        return callbacks.PostAddBirthright_player(ype, charge, firstTime, slot, varData, player)
    end
end

---@param player EntityPlayer
function mod:PreTriggerPlayerDeath(player)
    local callbacks = playerCallbacks[player:GetPlayerType()]
    if callbacks and callbacks.PreTriggerPlayerDeath_player then
        callbacks.PreTriggerPlayerDeath_player(player)
    end
end

---@param player EntityPlayer
---@param amount integer
function mod:PrePlayerAddMaxHearts(player, amount)
    local callbacks = playerCallbacks[player:GetPlayerType()]
    if callbacks and callbacks.PrePlayerAddMaxHearts_player then
        return callbacks.PrePlayerAddMaxHearts_player(player, amount)
    end
end

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.PostPlayerInit, PlayerVariant.PLAYER)
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.PostPlayerUpdate, PlayerVariant.PLAYER)
mod:AddCallback(ModCallbacks.MC_PRE_TRIGGER_PLAYER_DEATH, mod.PreTriggerPlayerDeath)
mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_ADD_HEARTS, mod.PrePlayerAddMaxHearts, AddHealthType.MAX)
mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, mod.PostAddBirthright, CollectibleType.COLLECTIBLE_BIRTHRIGHT)

---@param callbacks Callbacks
function mod:AddCallbacks(callbacks)
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
    if callbacks.PreTriggerPlayerDeath then
        self:AddCallback(ModCallbacks.MC_PRE_TRIGGER_PLAYER_DEATH, function(_, player)
            return callbacks.PreTriggerPlayerDeath(player)
        end)
    end
end

---@param itemId CollectibleType
---@param callbacks CollectibleCallbacks
function mod:AddCollectibleCallbacks(itemId, callbacks)
    self:AddCallbacks(callbacks)
    if callbacks.PostAddCollectible then
        self:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, function(_, type, charge, firstTime, slot, varData, player)
            return callbacks.PostAddCollectible(type, charge, firstTime, slot, varData, player)
        end, itemId)
    end
    if callbacks.UseItem then
        self:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, itemId, rng, player, flags, slot, custonVarData)
            return callbacks.UseItem(itemId, rng, player, flags, slot, custonVarData)
        end, itemId)
    end
end

for itemId, callbacks in pairs(collectibleCallbacks) do
    mod:AddCollectibleCallbacks(itemId, callbacks)
end

for _, callbacks in pairs(playerCallbacks) do
    mod:AddCallbacks(callbacks)
end



mod:AddCallback(ModCallbacks.MC_PRE_MUSIC_PLAY, function(_, music, volume, isFade)
    tempoManager.PreMusicPlay(music, volume, isFade)
end)

mod:AddCallback(ModCallbacks.MC_POST_RENDER, function(_)
    tempoManager.PostRender()
end)