--local PLAYER_TYPE_PERCY = Isaac.GetPlayerTypeByName("Percy")
local ITEM_ID_MOMS_HEADPHONES = Isaac.GetItemIdByName("Mom's Headphones")

---@type PlayerCallbacks
local percy = {}

function percy.PostPlayerInit_player(player)
    player:AddCollectible(ITEM_ID_MOMS_HEADPHONES)
end

function percy.PostPlayerRender_player(player)
    CatGuy.PlayerUtils.ApplyShader(player, "shaders/coloroffset_percy")
end

--[[ percy.EvaluateCache = {}
percy.EvaluateCache[CacheFlag.CACHE_DAMAGE] = function(player)
    if player:GetPlayerType() == PLAYER_TYPE_PERCY then
        player.Damage = player.Damage * 0.75
    end
end ]]

return percy