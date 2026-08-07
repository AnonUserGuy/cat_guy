local ITEM_ID_UNDERHANDS = Isaac.GetItemIdByName("Underhands")

---@type UnderhandCallbacks
local underhandCallbacks = include("scripts_cat_guy.collectibles.underhands")

---@class PercyBCallbacks: PlayerCallbacks
local percyB = {}

function percyB.PostPlayerInit(player)
    player:AddInnateCollectible(CollectibleType.COLLECTIBLE_OUIJA_BOARD, 1, "percyB", -1, false)
    player:AddInnateCollectible(CollectibleType.COLLECTIBLE_TRANSCENDENCE, 1, "percyB", -1, false)
    player:SetPocketActiveItem(ITEM_ID_UNDERHANDS, ActiveSlot.SLOT_POCKET, false)
end

function percyB.PostPlayerUpdate(player)
    if player:IsDead() and not player:GetEffects():HasNullEffect(NullItemID.ID_LOST_CURSE) then
        player:AddNullItemEffect(NullItemID.ID_LOST_CURSE)
    end
end

function percyB.PreTriggerPlayerDeath(player)
    player:GetEffects():RemoveNullEffect(NullItemID.ID_LOST_CURSE, -1)
end

function percyB.PostAddBirthright(_, _, _, _, _, player)
    player:AddMaxHearts(2)
end

function percyB.PrePlayerAddMaxHearts(player, amount)
    if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and amount > 0 then
        underhandCallbacks.AddPercyLives(player, amount)
    else
        underhandCallbacks.AddPercyLives(player, amount // 2)
    end
end

return percyB