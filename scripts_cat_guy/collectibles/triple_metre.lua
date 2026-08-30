---@type CollectibleCallbacks
local triple = {}

local HURT_TIME_MAX = 60
local hurtTime = -1
local needsCancel = false

local basePitch = nil ---@type number?

---@param x number
local function getSwingRatio(x)
    return 0.1667 * (x / HURT_TIME_MAX) + 0.5
end

local function anybodyHurt()
    return CatGuy.PlayerUtils.AnyPlayer(function(player) return player:GetEffects():HasNullEffect(CatGuy.NullItemID.TRIPLE_METRE_HURT) end)
end

---@param player EntityPlayer
local function resetHurtTimer(player)
    local tempoManager = CatGuy.TempoManager
    if anybodyHurt() and tempoManager.tempoDef and not tempoManager.triplet then
        tempoManager:ScheduleRestartMusic()
    end
    player:AddNullItemEffect(CatGuy.NullItemID.TRIPLE_METRE_HURT, true, 240, false)
end

function triple.PostTriggerCollectibleAdded_item(player, _, firstTime)
    if firstTime then
        resetHurtTimer(player)
    end
end

function triple.PostUpdate()
    if not anybodyHurt() then
        if needsCancel then
            needsCancel = false
            Game():GetRoom():SetBrokenWatchState(0)
        end
        return
    end
    needsCancel = true

    if not basePitch then
        basePitch = MusicManager():GetCurrentPitch()
    end

    local tempoManager = CatGuy.TempoManager
    if not tempoManager.tempoDef or tempoManager.triplet then
        Game():GetRoom():SetBrokenWatchState(0)
    else
        if (tempoManager.beat % 1) < 0.5 then
            Game():GetRoom():SetBrokenWatchState(1)
        else
            Game():GetRoom():SetBrokenWatchState(2)
        end
    end
end

function triple.PreRender()
    if anybodyHurt() then
        hurtTime = HURT_TIME_MAX
    elseif hurtTime < 0 then
        return
    elseif hurtTime == 0 then
        local tempoManager = CatGuy.TempoManager
        if tempoManager.tempoDef and not tempoManager.triplet then
            CatGuy.TempoManager:ScheduleRestartMusic()
            MusicManager():ResetPitch()
        end
        basePitch = nil
        hurtTime = -1
        return
    else
        hurtTime = hurtTime - 1
    end

    if not basePitch then
        basePitch = MusicManager():GetCurrentPitch()
    end

    local pitch
    local tempoManager = CatGuy.TempoManager
    if not tempoManager.tempoDef or tempoManager.triplet then
        pitch = 1.0000001
    else
        local swingRatio = getSwingRatio(hurtTime)
        if (tempoManager.beat % 1) < 0.5 then
            pitch = 1 / (2 * swingRatio)
        else
            pitch = 1 / (2 * (1 - swingRatio))
        end
    end
    MusicManager():SetCurrentPitch(pitch * (basePitch or 1.0))
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

function triple.PlayerTakeDamage(player, _, flags)
    if (flags & DamageFlag.DAMAGE_NO_PENALTIES) ~= 0 or not player:HasCollectible(CatGuy.CollectibleType.TRIPLE_METRE) then
        return
    end
    resetHurtTimer(player)
end

return triple