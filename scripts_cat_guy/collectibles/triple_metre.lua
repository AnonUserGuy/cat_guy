---@type CollectibleCallbacks
local triple = {}

local HURT_TIME_MAX = 60
local hurtTime = -1

---@param x number
local function getSwingRatio(x)
    return 0.1667 * (x / HURT_TIME_MAX) + 0.5
end

local function anybodyHurt()
    return CatGuy.PlayerUtils.AnyPlayer(function(player) return player:GetEffects():HasNullEffect(CatGuy.NullItemID.TRIPLE_METRE_HURT) end)
end

---@param player EntityPlayer
local function resetHurtTimer(player)
    if anybodyHurt() and CatGuy.TempoManager.tempoDef then
        CatGuy.TempoManager:ScheduleRestartMusic()
    end
    player:AddNullItemEffect(CatGuy.NullItemID.TRIPLE_METRE_HURT, true, 240, false)
end

function triple.PostAddCollectible_item(_, _, firstTime, _, _, player)
    if firstTime then
        resetHurtTimer(player)
    end
end

function triple.PostRender()
    if anybodyHurt() then
        hurtTime = HURT_TIME_MAX
    elseif hurtTime < 0 then
        return
    elseif hurtTime == 0 then
        CatGuy.TempoManager:ScheduleRestartMusic()
        hurtTime = -1
        return
    else
        hurtTime = hurtTime - 1
    end
    
    local tempoManager = CatGuy.TempoManager
    if not tempoManager.tempoDef or tempoManager.triplet then
        return
    end

    local swingRatio = getSwingRatio(hurtTime)
    if (tempoManager.beat % 1) < 0.5 then
        MusicManager():SetCurrentPitch(1 / (2 * (1 - swingRatio)))
    else
        MusicManager():SetCurrentPitch(1 / (2 * swingRatio))
    end
end

function triple.PostPlayerUpdate(player)
    local diff = player:GetCollectibleNum(CatGuy.CollectibleType.TRIPLE_METRE) - player:GetInnateCollectibleCount(CollectibleType.COLLECTIBLE_INNER_EYE, "triple_metre")
    if diff ~= 0 then
        if diff > 0 then
            player:AddInnateCollectible(CollectibleType.COLLECTIBLE_INNER_EYE, diff, "triple_metre")
        else
            player:RemoveInnateCollectible(CollectibleType.COLLECTIBLE_INNER_EYE, -diff, "triple_metre")
        end
    end
end

function triple.PlayerTakeDamage(player)
    if not player:HasCollectible(CatGuy.CollectibleType.TRIPLE_METRE) then
        return
    end
    resetHurtTimer(player)
end

return triple