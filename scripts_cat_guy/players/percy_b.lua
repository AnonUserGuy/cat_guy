local PLAYER_TYPE_PERCY_B = Isaac.GetPlayerTypeByName("Percy", true)
local ITEM_ID_UNDERHANDS = Isaac.GetItemIdByName("Underhands")
local ITEM_ID_MOMS_HEADPHONES = Isaac.GetItemIdByName("Mom's Headphones")

---@type PlayerCallbacks
local percyB = {}

function percyB.PostPlayerInit_player(player)
    player:SetPocketActiveItem(ITEM_ID_UNDERHANDS, ActiveSlot.SLOT_POCKET, false)
    player:AddCollectible(ITEM_ID_MOMS_HEADPHONES)
end

---@param player EntityPlayer
function percyB.PostPlayerUpdate(player)
    if player:GetPlayerType() == PLAYER_TYPE_PERCY_B then
        if player:GetInnateCollectibleCount(CollectibleType.COLLECTIBLE_OUIJA_BOARD, "percy_b") == 0 then
            player:AddInnateCollectible(CollectibleType.COLLECTIBLE_OUIJA_BOARD, 1, "percy_b", 0, false)
            player:AddInnateCollectible(CollectibleType.COLLECTIBLE_TRANSCENDENCE, 1, "percy_b", 0, false)
        end
    else
        if player:GetInnateCollectibleCount(CollectibleType.COLLECTIBLE_OUIJA_BOARD, "percy_b") ~= 0 then
            player:RemoveInnateCollectible(CollectibleType.COLLECTIBLE_OUIJA_BOARD, 99, "percy_b")
            player:RemoveInnateCollectible(CollectibleType.COLLECTIBLE_TRANSCENDENCE, 99, "percy_b")
        end
    end
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

function percyB.PostPlayerRender_player(player)
    CatGuy.PlayerUtils.ApplyShader(player, "shaders/coloroffset_percy_b")
end

--[[ percyB.EvaluateCache = {}
percyB.EvaluateCache[CacheFlag.CACHE_DAMAGE] = function(player)
    if player:GetPlayerType() == PLAYER_TYPE_PERCY_B then
        player.Damage = player.Damage * 0.75
    end
end ]]

return percyB