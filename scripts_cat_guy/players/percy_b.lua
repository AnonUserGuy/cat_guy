---@type PlayerCallbacks
local percyB = {}

function percyB.PostPlayerInit_player(player)
    player:SetPocketActiveItem(CatGuy.CollectibleType.UNDERHANDS, ActiveSlot.SLOT_POCKET, false)
    if CatGuy:GetConfig("PercyBHasMomsHeadphones") ~= false then
        player:AddCollectible(CatGuy.CollectibleType.MOMS_HEADPHONES)
    end
end

---@param player EntityPlayer
function percyB.PostPlayerUpdate(player)
    if player:GetPlayerType() == CatGuy.PlayerType.PERCY_B and not player:HasCollectible(CollectibleType.COLLECTIBLE_DEAD_DOVE, false, true) then
        if player:GetInnateCollectibleCount(CollectibleType.COLLECTIBLE_DEAD_DOVE, "percy_b") == 0 then
            player:AddInnateCollectible(CollectibleType.COLLECTIBLE_DEAD_DOVE, 1, "percy_b", 0, false)
        end
    else
        if player:GetInnateCollectibleCount(CollectibleType.COLLECTIBLE_DEAD_DOVE, "percy_b") ~= 0 then
            player:RemoveInnateCollectible(CollectibleType.COLLECTIBLE_DEAD_DOVE, 99, "percy_b")
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

return percyB