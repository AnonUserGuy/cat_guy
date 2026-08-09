local ITEM_ID_UNDERHANDS = Isaac.GetItemIdByName("Underhands")

---@type PlayerCallbacks
local percyB = {}

function percyB.PostPlayerInit_player(player)
    player:AddInnateCollectible(CollectibleType.COLLECTIBLE_OUIJA_BOARD, 1, "percyB", -1, false)
    player:AddInnateCollectible(CollectibleType.COLLECTIBLE_TRANSCENDENCE, 1, "percyB", -1, false)
    player:SetPocketActiveItem(ITEM_ID_UNDERHANDS, ActiveSlot.SLOT_POCKET, false)
end

function percyB.PostPlayerUpdate_player(player)
    if player:IsDead() and not player:GetEffects():HasNullEffect(NullItemID.ID_LOST_CURSE) then
        player:AddNullItemEffect(NullItemID.ID_LOST_CURSE)
    end
end

function percyB.PreTriggerPlayerDeath_player(player)
    player:GetEffects():RemoveNullEffect(NullItemID.ID_LOST_CURSE, -1)
end

function percyB.PostAddBirthright_player(_, _, _, _, _, player)
    player:AddMaxHearts(2)
end

function percyB.PrePlayerAddMaxHearts_player(player, amount)
    local util = CatGuy.PlayerUtils
    if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and amount > 0 then
        util.AddPercyLives(player, amount)
    else
        util.AddPercyLives(player, amount // 2)
    end
end

return percyB