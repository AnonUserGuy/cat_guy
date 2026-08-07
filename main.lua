if not REPENTOGON then
    return
end

local PLAYER_TYPE_PERCY_B = Isaac.GetPlayerTypeByName("Percy", true)
local NULL_ID_PERCY_REVIVE = Isaac.GetNullItemIdByName("Percy Revive")
local NULL_ID_DEAD_CAT_REVIVE = Isaac.GetNullItemIdByName("Dead Cat Revive")
local ITEM_ID_UNDERHANDS = Isaac.GetItemIdByName("Underhands")

local PERCY_LIVES_INIT = 3
local PERCY_LIVES_MAX = 9

---@type table<integer, EntityPlayer>
local animatePercy = {}

---@type EntityPlayer?
local animateDeadCat = nil

---@class Mod
---@field AddCallback fun(self: Mod, callback: ModCallbacks, func: fun(), ...)
local Mod = RegisterMod("cat_guy", 1)

---comment
function Mod:PostNewRoom()
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

    Mod.RevivePercies()
end

---comment
---@param player EntityPlayer
function Mod:PostPlayerInit(player)
    if player:GetPlayerType() ~= PLAYER_TYPE_PERCY_B then
        return
    end

    player:AddInnateCollectible(CollectibleType.COLLECTIBLE_OUIJA_BOARD, 1, "", -1, false)
    player:AddInnateCollectible(CollectibleType.COLLECTIBLE_TRANSCENDENCE, 1, "", -1, false)
    player:SetPocketActiveItem(ITEM_ID_UNDERHANDS, ActiveSlot.SLOT_POCKET, false)
end

---comment
---@param player EntityPlayer
function Mod:PostPlayerUpdate(player)
    if player:GetPlayerType() ~= PLAYER_TYPE_PERCY_B then
        return
    end

    if player:IsDead() and not player:GetEffects():HasNullEffect(NullItemID.ID_LOST_CURSE) then
        player:AddNullItemEffect(NullItemID.ID_LOST_CURSE)
    end
end

---comment
---@param firstTime boolean
---@param player EntityPlayer
function Mod:PostAddUnderhands(_, _, firstTime, _, _, player)
    if firstTime then
        Mod.AddPercyLives(player, PERCY_LIVES_INIT)
    end
end

---comment
---@param player EntityPlayer
---@return boolean
function Mod:UseUnderhands(_, _, player, _, _, _)
    player:AddCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS, true, 90)
    return true
end

---comment
---@param player EntityPlayer
function Mod:PostAddBirthright(_, _, _, _, _, player)
    if player:GetPlayerType() == PLAYER_TYPE_PERCY_B then
        player:AddMaxHearts(2)
    end
end

---comment
---@param player EntityPlayer
function Mod:PreTriggerPlayerDeath(player)
    if player:GetPlayerType() == PLAYER_TYPE_PERCY_B then
        player:GetEffects():RemoveNullEffect(NullItemID.ID_LOST_CURSE, -1)
    end
    
    if Mod.GetExtraLivesEX(player) > 0 then
        if player:GetEffects():HasCollectibleEffect(ITEM_ID_UNDERHANDS) then
            player:AddCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS, true, 90)
            Mod.ReviveInRoom(player)
        else
            Mod.ReviveOutOfRoom(player)
        end
    elseif not Mod.AnyPlayerAlive() then
        Mod.RevivePercies(true)
    end
end

---comment
---@param player EntityPlayer
function Mod.ReviveOutOfRoom(player)
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


    elseif (Mod.GetPercyLifeCount(player) > 0) then
        if not Mod:AnyPlayerAlive() then
            local level = Game():GetLevel()
            local previousRoom = level:GetPreviousRoomIndex()
            Game():StartRoomTransition(previousRoom, Direction.NO_DIRECTION, RoomTransitionAnim.WALK, player)
            table.insert(animatePercy, player)

            Mod.AddPercyLives(player, -1)
            player:Revive()

            if (player:GetHealthType() ~= HealthType.LOST) then
                player:AddMaxHearts(2 - player:GetMaxHearts())
                player:SetFullHearts()
            end
        end
    end
end

---comment
---@param player EntityPlayer
---@return boolean didntRevive true if game will revive in room itself
function Mod.ReviveInRoom(player)
    if (player:GetCard(0) == Card.CARD_SOUL_LAZARUS or player:GetCard(1) == Card.CARD_SOUL_LAZARUS) then
        return true
    elseif (player:HasCollectible(CollectibleType.COLLECTIBLE_1UP)) then
        Mod.ReviveConsumeCollectible(player, CollectibleType.COLLECTIBLE_1UP)
        player:SetFullHearts()
        SFXManager():Play(SoundEffect.SOUND_1UP)
    elseif (player:GetPlayerType() == PlayerType.PLAYER_LAZARUS) then
        return true
    elseif (player:HasCollectible(CollectibleType.COLLECTIBLE_DEAD_CAT)) then
        Mod.ReviveConsumeCollectible(player, CollectibleType.COLLECTIBLE_DEAD_CAT)
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
    elseif (Mod.GetPercyLifeCount(player) > 0) then
        player:AnimatePitfallOut()
        Mod.AddPercyLives(player, -1)
        player:Revive()
        if (player:GetHealthType() ~= HealthType.LOST) then
            player:AddMaxHearts(2 - player:GetMaxHearts())
            player:SetFullHearts()
        end
    elseif (Mod.RollGuppysCollar(player)) then
        player:AnimateCollectible(CollectibleType.COLLECTIBLE_GUPPYS_COLLAR)
        player:Revive()
    elseif (player:HasCollectible(CollectibleType.COLLECTIBLE_LAZARUS_RAGS)) then
        Mod.ReviveConsumeCollectible(player, CollectibleType.COLLECTIBLE_LAZARUS_RAGS)
        -- would already revive in place, but it being the only revive that changes characters would be weird
    elseif (player:HasCollectible(CollectibleType.COLLECTIBLE_ANKH)) then
        Mod.ReviveConsumeCollectible(player, CollectibleType.COLLECTIBLE_ANKH)
    elseif (Mod.RollBrokenAnkh(player)) then
        player:AnimateTrinket(TrinketType.TRINKET_BROKEN_ANKH)
        player:Revive()
    elseif (player:HasCollectible(CollectibleType.COLLECTIBLE_JUDAS_SHADOW)) then
        Mod.ReviveConsumeCollectible(player, CollectibleType.COLLECTIBLE_JUDAS_SHADOW)
    elseif (player:HasTrinket(TrinketType.TRINKET_MISSING_POSTER)) then
        Mod.ReviveConsumeTrinket(player, TrinketType.TRINKET_MISSING_POSTER)
    elseif (player:GetPlayerType() == PlayerType.PLAYER_THELOST_B and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)) then
        return true
    else
        for itemId, count in pairs(player:GetCollectiblesList()) do
            if count > 0 then
                local config = Isaac.GetItemConfig():GetCollectible(itemId)
                if config and config:HasCustomTag("revive") then
                    Mod.ReviveConsumeCollectible(player, itemId)
                    return false
                end
            end
        end
    end
    return false
end

---comment
---@param player EntityPlayer
---@param itemId CollectibleType
function Mod.ReviveConsumeCollectible(player, itemId)
    player:AnimateCollectible(itemId)
    player:RemoveCollectible(itemId)
    player:Revive()
end

---comment
---@param player EntityPlayer
---@param trinketId TrinketType
function Mod.ReviveConsumeTrinket(player, trinketId)
    player:AnimateTrinket(trinketId)
    if (not player:TryRemoveTrinket(trinketId)) then
        player:TryRemoveSmeltedTrinket(trinketId)
    end
    player:Revive()
end

---comment
---@param player EntityPlayer
---@return boolean
function Mod.RollGuppysCollar(player)
    local num = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_GUPPYS_COLLAR)
    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_GUPPYS_COLLAR)
    for _ = 1, num do
        if rng:RandomFloat() < 0.5 then
            return true
        end
    end
    return false
end

---comment
---@param player EntityPlayer
---@return boolean
function Mod.RollBrokenAnkh(player)
    return player:HasTrinket(TrinketType.TRINKET_BROKEN_ANKH)
        and player:GetTrinketRNG(TrinketType.TRINKET_BROKEN_ANKH):RandomFloat() < 0.2222
end

---comment
---@param player EntityPlayer
---@return integer
function Mod.GetExtraLivesEX(player)
    return player:GetExtraLives()
        + (player:GetCard(0) == Card.CARD_SOUL_LAZARUS and 1 or 0)
        + (player:GetCard(1) == Card.CARD_SOUL_LAZARUS and 1 or 0)
        + (player:HasTrinket(TrinketType.TRINKET_BROKEN_ANKH) and 1 or 0)
        + (player:HasTrinket(TrinketType.TRINKET_MISSING_POSTER) and 1 or 0)
        + (player:GetPlayerType() == PlayerType.PLAYER_LAZARUS and 1 or 0)
end

---comment
---@param player EntityPlayer
---@param amount integer
function Mod:PrePlayerAddMaxHearts(player, amount)
    if player:GetPlayerType() ~= PLAYER_TYPE_PERCY_B then
        return
    end

    if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and amount > 0 then
        Mod.AddPercyLives(player, amount)
    else
        Mod.AddPercyLives(player, amount // 2)
    end
end

---comment
---@param player EntityPlayer
---@param count integer
---@return integer remaining
function Mod.AddPercyLives(player, count)
    local effects = player:GetEffects()
    if count > 0 then
        local currCount = Mod.GetPercyLifeCount(player)
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

---comment
---@param player EntityPlayer
---@return integer
function Mod.GetPercyLifeCount(player)
    return player:GetEffects():GetNullEffectNum(NULL_ID_PERCY_REVIVE)
end

---comment
---@param prevRoom boolean?
function Mod.RevivePercies(prevRoom)
    Mod.ForEachPlayer(function(player)
        if player:GetPlayerType() == PLAYER_TYPE_PERCY_B and (player:IsDead() or player:IsCoopGhost()) and Mod.GetPercyLifeCount(player) > 0 then
            Mod.AddPercyLives(player, -1)
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

---comment
---@param func fun(player: EntityPlayer, i: integer)
function Mod.ForEachPlayer(func)
    local numPlayers = Game():GetNumPlayers()
    for i = 0, numPlayers - 1 do
        local player = Game():GetPlayer(i)
        if player then
            func(player, i)
        end
    end
end

---comment
---@param func fun(player: EntityPlayer, i: integer): boolean|any
---@return boolean|any
function Mod.AnyPlayer(func)
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

---comment
---@return boolean
function Mod.AnyPlayerAlive()
    return Mod.AnyPlayer(function(player)
        return not player:IsDead() and not player:IsCoopGhost()
    end)
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Mod.PostNewRoom)
Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, Mod.PostPlayerInit, PlayerVariant.PLAYER)
Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Mod.PostPlayerUpdate, PlayerVariant.PLAYER)
Mod:AddCallback(ModCallbacks.MC_PRE_TRIGGER_PLAYER_DEATH, Mod.PreTriggerPlayerDeath)
Mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_ADD_HEARTS, Mod.PrePlayerAddMaxHearts, AddHealthType.MAX)
Mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, Mod.PostAddUnderhands, ITEM_ID_UNDERHANDS)
Mod:AddCallback(ModCallbacks.MC_USE_ITEM, Mod.UseUnderhands, ITEM_ID_UNDERHANDS)
Mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, Mod.PostAddBirthright, CollectibleType.COLLECTIBLE_BIRTHRIGHT)