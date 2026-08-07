local NULL_ID_PERCY_REVIVE = Isaac.GetNullItemIdByName("Percy Revive")
local NULL_ID_DEAD_CAT_REVIVE = Isaac.GetNullItemIdByName("Dead Cat Revive")
local ITEM_ID_UNDERHANDS = Isaac.GetItemIdByName("Underhands")

---@type PlayerUtils
local playerUtils = include("scripts_cat_guy.players.player_utils")

---@class UnderhandCallbacks: CollectibleCallbacks
local underhands = {}

underhands.PERCY_LIVES_MAX = 9
underhands.PERCY_LIVES_INIT = 3
underhands.BOOK_OF_SHADOWS_DURATION = 90

---@type table<integer, EntityPlayer>
underhands.animatePercy = {}

---@type EntityPlayer?
underhands.animateDeadCat = nil

function underhands.PostNewRoom()
    if #underhands.animatePercy > 0 then
        for i = 1, #underhands.animatePercy do
            underhands.animatePercy[i]:AnimatePitfallOut()
        end
        underhands.animatePercy = {}
    end
    if underhands.animateDeadCat then
        underhands.animateDeadCat:AnimateCollectible(CollectibleType.COLLECTIBLE_DEAD_CAT)
        underhands.animateDeadCat = nil
    end

    underhands.RevivePercies()
end

---@param player EntityPlayer
function underhands.PreTriggerPlayerDeath(player)
    if playerUtils.GetExtraLivesEX(player) > 0 then
        if player:GetEffects():HasCollectibleEffect(ITEM_ID_UNDERHANDS) then
            player:AddCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS, true, underhands.BOOK_OF_SHADOWS_DURATION)
            underhands.ReviveInRoom(player)
        else
            underhands.ReviveOutOfRoom(player)
        end
    elseif not playerUtils.AnyPlayerAlive() then
        underhands.RevivePercies(true)
    end
end

---@param player EntityPlayer
---@return integer percyLifeCount
function underhands.GetPercyLifeCount(player)
    return player:GetEffects():GetNullEffectNum(NULL_ID_PERCY_REVIVE)
end

---@param player EntityPlayer
---@param count integer
---@return integer countAdded
function underhands.AddPercyLives(player, count)
    local effects = player:GetEffects()
    if count > 0 then
        local currCount = underhands.GetPercyLifeCount(player)
        if currCount + count > underhands.PERCY_LIVES_MAX then
            local x = underhands.PERCY_LIVES_MAX - currCount
            effects:AddNullEffect(NULL_ID_PERCY_REVIVE, false, x)
            return x
        else
            effects:AddNullEffect(NULL_ID_PERCY_REVIVE, false, count)
        end
    elseif count < 0 then
        effects:RemoveNullEffect(NULL_ID_PERCY_REVIVE, count * -1)
    end
    return count
end

---@param player EntityPlayer
function underhands.ReviveOutOfRoom(player)
    if (player:GetCard(0) == Card.CARD_SOUL_LAZARUS or player:GetCard(1) == Card.CARD_SOUL_LAZARUS) then
    elseif (player:HasCollectible(CollectibleType.COLLECTIBLE_1UP)) then
    elseif (player:GetPlayerType() == PlayerType.PLAYER_LAZARUS) then
    elseif (player:HasCollectible(CollectibleType.COLLECTIBLE_DEAD_CAT)) then


    elseif (player:GetEffects():HasNullEffect(NULL_ID_DEAD_CAT_REVIVE)) then
        local level = Game():GetLevel()
        local previousRoom = level:GetPreviousRoomIndex()
        Game():StartRoomTransition(previousRoom, Direction.NO_DIRECTION, RoomTransitionAnim.WALK, player)
        underhands.animateDeadCat = player

        player:GetEffects():RemoveNullEffect(NULL_ID_DEAD_CAT_REVIVE)
        player:Revive()

        if (player:GetHealthType() ~= HealthType.LOST) then
            player:AddMaxHearts(2 - player:GetMaxHearts())
            player:SetFullHearts()
        end
    elseif (player:HasCollectible(CollectibleType.COLLECTIBLE_INNER_CHILD)) then


    elseif (underhands.GetPercyLifeCount(player) > 0) then
        if not playerUtils.AnyPlayerAlive() then
            local level = Game():GetLevel()
            local previousRoom = level:GetPreviousRoomIndex()
            Game():StartRoomTransition(previousRoom, Direction.NO_DIRECTION, RoomTransitionAnim.WALK, player)
            table.insert(underhands.animatePercy, player)

            underhands.AddPercyLives(player, -1)
            player:Revive()

            if (player:GetHealthType() ~= HealthType.LOST) then
                player:AddMaxHearts(2 - player:GetMaxHearts())
                player:SetFullHearts()
            end
        end
    end
end

---@param player EntityPlayer
---@return boolean didntRevive true if game will revive in room itself
function underhands.ReviveInRoom(player)
    if (player:GetCard(0) == Card.CARD_SOUL_LAZARUS or player:GetCard(1) == Card.CARD_SOUL_LAZARUS) then
        return true
    elseif (player:HasCollectible(CollectibleType.COLLECTIBLE_1UP)) then
        underhands.ReviveConsumeCollectible(player, CollectibleType.COLLECTIBLE_1UP)
        player:SetFullHearts()
        SFXManager():Play(SoundEffect.SOUND_1UP)
    elseif (player:GetPlayerType() == PlayerType.PLAYER_LAZARUS) then
        return true
    elseif (player:HasCollectible(CollectibleType.COLLECTIBLE_DEAD_CAT)) then
        underhands.ReviveConsumeCollectible(player, CollectibleType.COLLECTIBLE_DEAD_CAT)
        player:GetEffects():AddNullEffect(NULL_ID_DEAD_CAT_REVIVE, false, 8)
        if (player:GetHealthType() ~= HealthType.LOST) then
            player:AddMaxHearts(2 - player:GetMaxHearts())
            player:SetFullHearts()
        end
    elseif (player:GetEffects():HasNullEffect(NULL_ID_DEAD_CAT_REVIVE)) then
        player:AnimateCollectible(CollectibleType.COLLECTIBLE_DEAD_CAT)
        player:GetEffects():RemoveNullEffect(NULL_ID_DEAD_CAT_REVIVE)
        player:Revive()
        if (player:GetHealthType() ~= HealthType.LOST) then
            player:AddMaxHearts(2 - player:GetMaxHearts())
            player:SetFullHearts()
        end
    elseif (player:HasCollectible(CollectibleType.COLLECTIBLE_INNER_CHILD)) then
        return true
    elseif (underhands.GetPercyLifeCount(player) > 0) then
        player:AnimatePitfallOut()
        underhands.AddPercyLives(player, -1)
        player:Revive()
        if (player:GetHealthType() ~= HealthType.LOST) then
            player:AddMaxHearts(2 - player:GetMaxHearts())
            player:SetFullHearts()
        end
    elseif (underhands.RollGuppysCollar(player)) then
        player:AnimateCollectible(CollectibleType.COLLECTIBLE_GUPPYS_COLLAR)
        player:Revive()
    elseif (player:HasCollectible(CollectibleType.COLLECTIBLE_LAZARUS_RAGS)) then
        underhands.ReviveConsumeCollectible(player, CollectibleType.COLLECTIBLE_LAZARUS_RAGS)
        -- would already revive in place, but it being the only revive that changes characters would be weird
    elseif (player:HasCollectible(CollectibleType.COLLECTIBLE_ANKH)) then
        underhands.ReviveConsumeCollectible(player, CollectibleType.COLLECTIBLE_ANKH)
    elseif (underhands.RollBrokenAnkh(player)) then
        player:AnimateTrinket(TrinketType.TRINKET_BROKEN_ANKH)
        player:Revive()
    elseif (player:HasCollectible(CollectibleType.COLLECTIBLE_JUDAS_SHADOW)) then
        underhands.ReviveConsumeCollectible(player, CollectibleType.COLLECTIBLE_JUDAS_SHADOW)
    elseif (player:HasTrinket(TrinketType.TRINKET_MISSING_POSTER)) then
        underhands.ReviveConsumeTrinket(player, TrinketType.TRINKET_MISSING_POSTER)
    elseif (player:GetPlayerType() == PlayerType.PLAYER_THELOST_B and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)) then
        return true
    else
        for itemId, count in pairs(player:GetCollectiblesList()) do
            if count > 0 then
                local config = Isaac.GetItemConfig():GetCollectible(itemId)
                if config and config:HasCustomTag("revive") then
                    underhands.ReviveConsumeCollectible(player, itemId)
                    return false
                end
            end
        end
    end
    return false
end

---@param player EntityPlayer
---@param itemId CollectibleType
function underhands.ReviveConsumeCollectible(player, itemId)
    player:AnimateCollectible(itemId)
    player:RemoveCollectible(itemId)
    player:Revive()
end


---@param player EntityPlayer
---@param trinketId TrinketType
function underhands.ReviveConsumeTrinket(player, trinketId)
    player:AnimateTrinket(trinketId)
    if (not player:TryRemoveTrinket(trinketId)) then
        player:TryRemoveSmeltedTrinket(trinketId)
    end
    player:Revive()
end


---@param player EntityPlayer
---@return boolean
function underhands.RollGuppysCollar(player)
    local num = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_GUPPYS_COLLAR)
    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_GUPPYS_COLLAR)
    for _ = 1, num do
        if rng:RandomFloat() < 0.5 then
            return true
        end
    end
    return false
end


---@param player EntityPlayer
---@return boolean
function underhands.RollBrokenAnkh(player)
    return player:HasTrinket(TrinketType.TRINKET_BROKEN_ANKH)
        and player:GetTrinketRNG(TrinketType.TRINKET_BROKEN_ANKH):RandomFloat() < 0.2222
end

---@param prevRoom boolean?
function underhands.RevivePercies(prevRoom)
    playerUtils.ForEachPlayer(function(player)
        if (player:IsDead() or player:IsCoopGhost()) and underhands.GetPercyLifeCount(player) > 0 then
            underhands.AddPercyLives(player, -1)
            if player:IsCoopGhost() then
                player:ReviveCoopGhost()
            else
                player:Revive()
            end

            if (player:GetHealthType() ~= HealthType.LOST) then
                player:AddMaxHearts(2 - player:GetMaxHearts())
                player:SetFullHearts()
            end
            if prevRoom then
                table.insert(underhands.animatePercy, player)
            else
                player:AnimatePitfallOut()
            end
        end
    end)
    if prevRoom and #underhands.animatePercy > 0 then
        local level = Game():GetLevel()
        local previousRoom = level:GetPreviousRoomIndex()
        Game():StartRoomTransition(previousRoom, Direction.NO_DIRECTION, RoomTransitionAnim.WALK, underhands.animatePercy[1])
    end
end

function underhands.PostAddCollectible(_, _, firstTime, _, _, player)
    if firstTime then
        underhands.AddPercyLives(player, underhands.PERCY_LIVES_INIT)
    end
end

function underhands.UseItem(_, _, player, _, _, _)
    player:AddCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS, true, underhands.BOOK_OF_SHADOWS_DURATION)
    return true
end

return underhands