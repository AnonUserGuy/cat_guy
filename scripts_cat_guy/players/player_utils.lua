---@class PlayerUtils
local playerUtils = {}

---@param player EntityPlayer
---@return integer
function playerUtils.GetExtraLivesEX(player)
    return player:GetExtraLives()
        + (player:GetCard(0) == Card.CARD_SOUL_LAZARUS and 1 or 0)
        + (player:GetCard(1) == Card.CARD_SOUL_LAZARUS and 1 or 0)
        + (player:HasTrinket(TrinketType.TRINKET_BROKEN_ANKH) and 1 or 0)
        + (player:HasTrinket(TrinketType.TRINKET_MISSING_POSTER) and 1 or 0)
        + (player:GetPlayerType() == PlayerType.PLAYER_LAZARUS and 1 or 0)
end

---@param func fun(player: EntityPlayer, i: integer)
function playerUtils.ForEachPlayer(func)
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
function playerUtils.AnyPlayer(func)
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
function playerUtils.AnyPlayerAlive()
    return playerUtils.AnyPlayer(function(player)
        return not player:IsDead() and not player:IsCoopGhost()
    end)
end

return playerUtils