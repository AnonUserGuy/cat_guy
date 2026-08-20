---@type table<Pointer, integer>
local baseFireDelay = {}

---@type PlayerCallbacks
local percy = {}

function percy.PostPlayerInit_player(player)
    player:AddCollectible(CatGuy.CollectibleType.MOMS_HEADPHONES)
end

function percy.PostPlayerRender_player(player)
    CatGuy.PlayerUtils.ApplyShader(player, "shaders/coloroffset_percy")
end

function percy.PostPlayerUpdate(player)
    if player:GetPlayerType() == CatGuy.PlayerType.PERCY and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
        if player:GetInnateCollectibleCount(CatGuy.CollectibleType.MOMS_HEADPHONES, "percybr") == 0 then
            player:AddInnateCollectible(CatGuy.CollectibleType.MOMS_HEADPHONES, 1, "percybr")
        end
    else
        if player:GetInnateCollectibleCount(CatGuy.CollectibleType.MOMS_HEADPHONES, "percybr") ~= 0 then
            player:RemoveInnateCollectible(CatGuy.CollectibleType.MOMS_HEADPHONES, 99, "percybr")
        end
    end
end

function percy.PostAddBirthright_player(_, _, _, _, _, player)
    player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_DAMAGE)
    player:EvaluateItems()
end

local function BirthrightFireRate()
    if CatGuy.TempoManager and CatGuy.TempoManager.tempoDef then
        return 30 * 60 / CatGuy.TempoManager:GetCurrentBPM() - 1
    else
        return 10.0
    end
end

percy.EvaluateCache = {}
percy.EvaluateCache[CacheFlag.CACHE_DAMAGE] = function(player)
    if player:GetPlayerType() ~= CatGuy.PlayerType.PERCY or not player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
        return
    end

    local p = GetPtrHash(player)
    if baseFireDelay[p] then
        local diff = BirthrightFireRate() / baseFireDelay[p]
        if diff > 1.0 then
            player.Damage = player.Damage * diff
        end
    end
end
percy.EvaluateCache[CacheFlag.CACHE_FIREDELAY] = function(player)
    if player:GetPlayerType() ~= CatGuy.PlayerType.PERCY or not player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
        return
    end
    
    local p = GetPtrHash(player)
    baseFireDelay[p] = player.MaxFireDelay

    player.MaxFireDelay = BirthrightFireRate()
    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
end

return percy