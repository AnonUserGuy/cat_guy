if not REPENTOGON then
    return
end

---@type table<PlayerType, PlayerCallbacks>
local playerCallbacks = {}
playerCallbacks[Isaac.GetPlayerTypeByName("Percy", true)] = include("scripts_cat_guy.players.percy_b")

---@type UnderhandCallbacks
local underhands = include("scripts_cat_guy.collectibles.underhands")

---@type table<CollectibleType, CollectibleCallbacks>
local collectibleCallbacks = {}
collectibleCallbacks[Isaac.GetItemIdByName("Underhands")] = underhands


---@class ModCatGuy: ModReference
local mod = RegisterMod("cat_guy", 1)

function mod:PostNewRoom()
    underhands.PostNewRoom()
end

---@param player EntityPlayer
function mod:PostPlayerInit(player)
    local callbacks = playerCallbacks[player:GetPlayerType()]
    if callbacks and callbacks.PostPlayerInit then
        return callbacks.PostPlayerInit(player)
    end
end

---@param player EntityPlayer
function mod:PostPlayerUpdate(player)
    local callbacks = playerCallbacks[player:GetPlayerType()]
    if callbacks and callbacks.PostPlayerUpdate then
        return callbacks.PostPlayerUpdate(player)
    end
end

---@param player EntityPlayer
function mod:PostAddBirthright(ype, charge, firstTime, slot, varData, player)
    local callbacks = playerCallbacks[player:GetPlayerType()]
    if callbacks and callbacks.PostAddBirthright then
        return callbacks.PostAddBirthright(ype, charge, firstTime, slot, varData, player)
    end
end

---@param player EntityPlayer
function mod:PreTriggerPlayerDeath(player)
    local callbacks = playerCallbacks[player:GetPlayerType()]
    if callbacks and callbacks.PreTriggerPlayerDeath then
        callbacks.PreTriggerPlayerDeath(player)
    end
    underhands.PreTriggerPlayerDeath(player)
end

---@param player EntityPlayer
---@param amount integer
function mod:PrePlayerAddMaxHearts(player, amount)
    local callbacks = playerCallbacks[player:GetPlayerType()]
    if callbacks and callbacks.PrePlayerAddMaxHearts then
        return callbacks.PrePlayerAddMaxHearts(player, amount)
    end
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.PostNewRoom)
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.PostPlayerInit, PlayerVariant.PLAYER)
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.PostPlayerUpdate, PlayerVariant.PLAYER)
mod:AddCallback(ModCallbacks.MC_PRE_TRIGGER_PLAYER_DEATH, mod.PreTriggerPlayerDeath)
mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_ADD_HEARTS, mod.PrePlayerAddMaxHearts, AddHealthType.MAX)
mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, mod.PostAddBirthright, CollectibleType.COLLECTIBLE_BIRTHRIGHT)

for itemId, callbacks in pairs(collectibleCallbacks) do
    if callbacks.PostAddCollectible then
        mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, function(_, type, charge, firstTime, slot, varData, player)
            return callbacks.PostAddCollectible(type, charge, firstTime, slot, varData, player)
        end, itemId)
    end
    if callbacks.UseItem then
        mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, itemId, rng, player, flags, slot, custonVarData)
            return callbacks.UseItem(itemId, rng, player, flags, slot, custonVarData)
        end, itemId)
    end
end