local BLINK_COLOR = Color(1, 1, 1, 1, 0.5, 0.5, 0.5, 0.5)
BLINK_COLOR:SetColorize(1, 1, 1, 1)

local TIMER_MAX = 180 * 2
local TICK_DURATION = 15 * 2
local EFFECT_DURATION = 30 * 2

local TICK_TIME_1 = TIMER_MAX - EFFECT_DURATION - TICK_DURATION * 3
local TICK_TIME_2 = TIMER_MAX - EFFECT_DURATION - TICK_DURATION * 2
local TICK_TIME_3 = TIMER_MAX - EFFECT_DURATION - TICK_DURATION
local EFFECT_TIME = TIMER_MAX - EFFECT_DURATION

local tickVolume = {0.4, 0.6, 0.8}
local tickPitch = {1.7, 1.4, 1.7}

local timers = {} ---@type table<Pointer, integer>
local needsRemoved = {} ---@type table<Pointer, boolean>

local beatEffected = nil ---@type integer?
local successfulTick = 0
local wasPaused = false

---@type CollectibleCallbacks
local toothAndNail = {}

---@param player EntityPlayer
local function blink(player)
    player:SetColor(BLINK_COLOR, 2, 1, false, true)
end

---@param player EntityPlayer
---@param i integer
local function tick(player, i)
    SFXManager():Play(SoundEffect.SOUND_BUTTON_PRESS, tickVolume[i], 2, false, tickPitch[i])
    blink(player)
end

---@param player EntityPlayer
local function effect(player)
    if not player:GetEffects():HasNullEffect(NullItemID.ID_TOOTH_AND_NAIL) then
        player:GetEffects():AddNullEffect(NullItemID.ID_TOOTH_AND_NAIL)
    end
    SFXManager():Play(SoundEffect.SOUND_GOOATTACH0, 1.0, 2, false, 1.0)
    blink(player)
end

---@param player EntityPlayer
local function revert(player)
    player:GetEffects():RemoveNullEffect(NullItemID.ID_TOOTH_AND_NAIL)
    blink(player)
end

function toothAndNail.PostPlayerUpdate(player)
    local p = GetPtrHash(player)
    if needsRemoved[p] and (not CatGuy.TempoManager.tempoDef or not (player:HasCollectible(CollectibleType.COLLECTIBLE_TOOTH_AND_NAIL) and player:HasCollectible(CatGuy.CollectibleType.MOMS_HEADPHONES))) then
        if player:GetEffects():HasNullEffect(NullItemID.ID_TOOTH_AND_NAIL) then
            if player:HasCollectible(CollectibleType.COLLECTIBLE_TOOTH_AND_NAIL) then
                timers[p] = EFFECT_TIME + 1
            else
                revert(player)
            end
        end
        needsRemoved[p] = nil
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_TOOTH_AND_NAIL)
    or (player:HasCollectible(CatGuy.CollectibleType.MOMS_HEADPHONES) and CatGuy.TempoManager.tempoDef) then
        if timers[p] then
            if player:GetEffects():HasNullEffect(NullItemID.ID_TOOTH_AND_NAIL) then
                revert(player)
            end
            timers[p] = nil
        end
        return
    end

    local timer = timers[p] or 0

    if timer == TICK_TIME_1 then
        tick(player, 1)
    elseif timer == TICK_TIME_2 then
        tick(player, 2)
    elseif timer == TICK_TIME_3 then
        tick(player, 3)
    elseif timer == EFFECT_TIME then
        effect(player)
    elseif timer >= TIMER_MAX then
        revert(player)
        timer = 0
    end

    timers[p] = timer + 1
end

---@param func fun(player: EntityPlayer, i: integer?)
local function forEachToothAndNailer(func)
    CatGuy.PlayerUtils.ForEachPlayer(function(player, i)
        if player:HasCollectible(CollectibleType.COLLECTIBLE_TOOTH_AND_NAIL) and player:HasCollectible(CatGuy.CollectibleType.MOMS_HEADPHONES) then
            func(player, i)
        end
    end)
end

---@param i integer
local function tickBeat(i)
    if Game():IsPauseMenuOpen() or i > successfulTick + 1 then
        return
    end
    forEachToothAndNailer(function(player)
        tick(player, i)
    end)
    successfulTick = successfulTick + 1
end

local function effectBeat()
    if Game():IsPaused() or successfulTick < 2 then
        return
    end
    successfulTick = 0
    beatEffected = math.floor(CatGuy.TempoManager.beat)
    forEachToothAndNailer(function(player)
        effect(player)
        needsRemoved[GetPtrHash(player)] = true
    end)
end

local function revertBeat()
    if Game():IsPauseMenuOpen() then
        return
    end
    forEachToothAndNailer(function(player)
        revert(player)
        needsRemoved[GetPtrHash(player)] = nil
    end)
end

function toothAndNail.Tick(tempoManager)
    if not CatGuy.PlayerUtils.AnyPlayer(function(player) return
    player:HasCollectible(CollectibleType.COLLECTIBLE_TOOTH_AND_NAIL)
    and player:HasCollectible(CatGuy.CollectibleType.MOMS_HEADPHONES) end) then
        successfulTick = 0
        return
    end

    local firstMeasure = tempoManager.timeSig >= 6 or (tempoManager.measure % 2) == 0
    local secondMeasure = tempoManager.timeSig >= 6 or (tempoManager.measure % 2) == 1

    if secondMeasure and tempoManager.timeSigCount == 2 then
        tickBeat(1)
    elseif secondMeasure and tempoManager.timeSigCount == 1 then
        tickBeat(2)
    elseif secondMeasure and tempoManager.timeSigCount == 0 then
        tickBeat(3)
    elseif firstMeasure and tempoManager.timeSigCount == tempoManager.timeSig - 1 then
        effectBeat()
    end
    if math.floor(tempoManager.beat) - 2 == beatEffected then
        revertBeat()
    end
end

function toothAndNail.PostRender()
    local paused = Game():IsPaused()
    if wasPaused and not paused then
        forEachToothAndNailer(function(player)
            if player:GetEffects():HasNullEffect(NullItemID.ID_TOOTH_AND_NAIL) then
                revert(player)
            end
            needsRemoved[GetPtrHash(player)] = nil
        end)
    end
    wasPaused = paused
end

return toothAndNail