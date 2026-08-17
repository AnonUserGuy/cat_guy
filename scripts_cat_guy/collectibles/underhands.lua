local PERCY_LIVES_INIT = 3
local BOOK_OF_SHADOWS_DURATION = 90

---@type CollectibleCallbacks
local underhands = {}

function underhands.PostNewRoom()
    local util = CatGuy.PlayerUtils
    util.AnimatePercies()
    util.RevivePercies()
end

function underhands.PreTriggerPlayerDeath(player)
    local util = CatGuy.PlayerUtils
    if util.GetExtraLivesEX(player) > 0 then
        if player:GetEffects():HasCollectibleEffect(CatGuy.CollectibleType.UNDERHANDS) then
            player:AddCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS, true, BOOK_OF_SHADOWS_DURATION)
            util.ReviveInRoom(player)
        else
            util.ReviveOutOfRoom(player)
        end
    elseif not util.AnyPlayerAlive() then
        util.RevivePercies(true)
    end
end

function underhands.PostAddCollectible_item(_, _, firstTime, _, _, player)
    local util = CatGuy.PlayerUtils
    if firstTime then
        util.AddPercyLives(player, PERCY_LIVES_INIT)
    end
end

function underhands.UseItem_item(_, _, player, _, _, _)
    player:AddCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS, true, BOOK_OF_SHADOWS_DURATION)
    return true
end


return underhands