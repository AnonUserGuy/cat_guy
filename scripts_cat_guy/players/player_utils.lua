local NULL_ID_DEAD_CAT_REVIVE = Isaac.GetNullItemIdByName("Dead Cat Revive")
local NULL_ID_PERCY_REVIVE = Isaac.GetNullItemIdByName("Percy Revive")
local PERCY_LIVES_MAX = 9

---@type EntityPlayer[]
local animatePercy = {}

---@type EntityPlayer?
local animateDeadCat = nil

---@class PlayerUtils
local util = {}

---@param player EntityPlayer
---@return integer
function util.GetExtraLivesEX(player)
    return player:GetExtraLives()
        + (player:GetCard(0) == Card.CARD_SOUL_LAZARUS and 1 or 0)
        + (player:GetCard(1) == Card.CARD_SOUL_LAZARUS and 1 or 0)
        + (player:HasTrinket(TrinketType.TRINKET_BROKEN_ANKH) and 1 or 0)
        + (player:HasTrinket(TrinketType.TRINKET_MISSING_POSTER) and 1 or 0)
        + (player:GetPlayerType() == PlayerType.PLAYER_LAZARUS and 1 or 0)
end

---@param func fun(player: EntityPlayer, i: integer)
function util.ForEachPlayer(func)
    local numPlayers = Game():GetNumPlayers()
    for i = 0, numPlayers - 1 do
        local player = Game():GetPlayer(i)
        if player then
            func(player, i)
        end
    end
end


---@param func fun(player: EntityPlayer, i: integer): boolean|any
---@return boolean|any
function util.AnyPlayer(func)
    local numPlayers = Game():GetNumPlayers()
    for i = 0, numPlayers - 1 do
        local player = Game():GetPlayer(i)
        if player then
            local res = func(player, i)
            if res then
                return res
            end
        end
    end
    return false
end


---@return boolean
function util.AnyPlayerAlive()
    return util.AnyPlayer(function(player)
        return not player:IsDead() and not player:IsCoopGhost()
    end)
end

---@param player EntityPlayer
---@return integer percyLifeCount
function util.GetPercyLifeCount(player)
    return player:GetEffects():GetNullEffectNum(NULL_ID_PERCY_REVIVE)
end


---@param player EntityPlayer
---@param count integer
---@return integer countAdded
function util.AddPercyLives(player, count)
    local effects = player:GetEffects()
    if count > 0 then
        local currCount = util.GetPercyLifeCount(player)
        if currCount + count > PERCY_LIVES_MAX then
            local x = PERCY_LIVES_MAX - currCount
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
---@param itemId CollectibleType
function util.ReviveConsumeCollectible(player, itemId)
    player:AnimateCollectible(itemId)
    player:RemoveCollectible(itemId)
    player:Revive()
end

---@param player EntityPlayer
---@param trinketId TrinketType
function util.ReviveConsumeTrinket(player, trinketId)
    player:AnimateTrinket(trinketId)
    if (not player:TryRemoveTrinket(trinketId)) then
        player:TryRemoveSmeltedTrinket(trinketId)
    end
    player:Revive()
end

---@param player EntityPlayer
---@return boolean
function util.RollGuppysCollar(player)
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
function util.RollBrokenAnkh(player)
    return player:HasTrinket(TrinketType.TRINKET_BROKEN_ANKH)
        and player:GetTrinketRNG(TrinketType.TRINKET_BROKEN_ANKH):RandomFloat() < 0.2222
end


---@param player EntityPlayer
function util.ReviveOutOfRoom(player)
    if (player:GetCard(0) == Card.CARD_SOUL_LAZARUS or player:GetCard(1) == Card.CARD_SOUL_LAZARUS) then
    elseif (player:HasCollectible(CollectibleType.COLLECTIBLE_1UP)) then
    elseif (player:GetPlayerType() == PlayerType.PLAYER_LAZARUS) then
    elseif (player:HasCollectible(CollectibleType.COLLECTIBLE_DEAD_CAT)) then


    elseif (player:GetEffects():HasNullEffect(NULL_ID_DEAD_CAT_REVIVE)) then
        local level = Game():GetLevel()
        local previousRoom = level:GetPreviousRoomIndex()
        Game():StartRoomTransition(previousRoom, Direction.NO_DIRECTION, RoomTransitionAnim.WALK, player)
        animateDeadCat = player

        player:GetEffects():RemoveNullEffect(NULL_ID_DEAD_CAT_REVIVE)
        player:Revive()

        if (player:GetHealthType() ~= HealthType.LOST) then
            player:AddMaxHearts(2 - player:GetMaxHearts())
            player:SetFullHearts()
        end
    elseif (player:HasCollectible(CollectibleType.COLLECTIBLE_INNER_CHILD)) then


    elseif (util.GetPercyLifeCount(player) > 0) then
        if not util.AnyPlayerAlive() then
            local level = Game():GetLevel()
            local previousRoom = level:GetPreviousRoomIndex()
            Game():StartRoomTransition(previousRoom, Direction.NO_DIRECTION, RoomTransitionAnim.WALK, player)
            table.insert(animatePercy, player)

            util.AddPercyLives(player, -1)
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
function util.ReviveInRoom(player)
    if (player:GetCard(0) == Card.CARD_SOUL_LAZARUS or player:GetCard(1) == Card.CARD_SOUL_LAZARUS) then
        return true
    elseif (player:HasCollectible(CollectibleType.COLLECTIBLE_1UP)) then
        util.ReviveConsumeCollectible(player, CollectibleType.COLLECTIBLE_1UP)
        player:SetFullHearts()
        SFXManager():Play(SoundEffect.SOUND_1UP)
    elseif (player:GetPlayerType() == PlayerType.PLAYER_LAZARUS) then
        return true
    elseif (player:HasCollectible(CollectibleType.COLLECTIBLE_DEAD_CAT)) then
        util.ReviveConsumeCollectible(player, CollectibleType.COLLECTIBLE_DEAD_CAT)
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
    elseif (util.GetPercyLifeCount(player) > 0) then
        player:AnimatePitfallOut()
        util.AddPercyLives(player, -1)
        player:Revive()
        if (player:GetHealthType() ~= HealthType.LOST) then
            player:AddMaxHearts(2 - player:GetMaxHearts())
            player:SetFullHearts()
        end
    elseif (util.RollGuppysCollar(player)) then
        player:AnimateCollectible(CollectibleType.COLLECTIBLE_GUPPYS_COLLAR)
        player:Revive()
    elseif (player:HasCollectible(CollectibleType.COLLECTIBLE_LAZARUS_RAGS)) then
        util.ReviveConsumeCollectible(player, CollectibleType.COLLECTIBLE_LAZARUS_RAGS)
        -- would already revive in place, but it being the only revive that changes characters would be weird
    elseif (player:HasCollectible(CollectibleType.COLLECTIBLE_ANKH)) then
        util.ReviveConsumeCollectible(player, CollectibleType.COLLECTIBLE_ANKH)
    elseif (util.RollBrokenAnkh(player)) then
        player:AnimateTrinket(TrinketType.TRINKET_BROKEN_ANKH)
        player:Revive()
    elseif (player:HasCollectible(CollectibleType.COLLECTIBLE_JUDAS_SHADOW)) then
        util.ReviveConsumeCollectible(player, CollectibleType.COLLECTIBLE_JUDAS_SHADOW)
    elseif (player:HasTrinket(TrinketType.TRINKET_MISSING_POSTER)) then
        util.ReviveConsumeTrinket(player, TrinketType.TRINKET_MISSING_POSTER)
    elseif (player:GetPlayerType() == PlayerType.PLAYER_THELOST_B and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)) then
        return true
    else
        for itemId, count in pairs(player:GetCollectiblesList()) do
            if count > 0 then
                local config = Isaac.GetItemConfig():GetCollectible(itemId)
                if config and config:HasCustomTag("revive") then
                    util.ReviveConsumeCollectible(player, itemId)
                    return false
                end
            end
        end
    end
    return false
end

---@param prevRoom boolean?
function util.RevivePercies(prevRoom)
    util.ForEachPlayer(function(player)
        if (player:IsDead() or player:IsCoopGhost()) and util.GetPercyLifeCount(player) > 0 then
            util.AddPercyLives(player, -1)
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
                table.insert(animatePercy, player)
            else
                player:AnimatePitfallOut()
            end
        end
    end)
    if prevRoom and #animatePercy > 0 then
        local level = Game():GetLevel()
        local previousRoom = level:GetPreviousRoomIndex()
        Game():StartRoomTransition(previousRoom, Direction.NO_DIRECTION, RoomTransitionAnim.WALK, animatePercy[1])
    end
end

function util.AnimatePercies()
    if #animatePercy > 0 then
        for i = 1, #animatePercy do
            animatePercy[i]:AnimatePitfallOut()
        end
        animatePercy = {}
    end
    if animateDeadCat then
        animateDeadCat:AnimateCollectible(CollectibleType.COLLECTIBLE_DEAD_CAT)
        animateDeadCat = nil
    end
end

---@param player EntityPlayer
---@param shader string
function util.ApplyShader(player, shader)
    -- Base player sprite
    player:GetSprite():SetCustomShader(shader)

    -- Costume sprites
    for _, costume in ipairs(player:GetCostumeSpriteDescs()) do
        costume:GetSprite():SetCustomShader(shader)
    end
end

return util