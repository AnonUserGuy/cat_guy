local BLINK_COLOR = Color(1, 1, 1, 1, 0.5, 0.5, 0.5, 0.5)
BLINK_COLOR:SetColorize(1, 1, 1, 1)

local tickVolume = {0.4, 0.6, 0.8}
local tickPitch = {1.7, 1.4, 1.7}

local blocked = {} ---@type table<Pointer, boolean>
local effected = {} ---@type table<Pointer, boolean>

local beatEffected = nil ---@type integer?
local successfulTick = 0
local wasPaused = false

---@type CollectibleCallbacks
local toothAndNail = {}

---@param player EntityPlayer
local function hasSynergy(player)
    return player:HasCollectible(CollectibleType.COLLECTIBLE_TOOTH_AND_NAIL, false, true) and player:HasCollectible(CatGuy.CollectibleType.MOMS_HEADPHONES)
end

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
    if not CatGuy.TempoManager.lastBpm or not hasSynergy(player) then
        if blocked[p] then
            if effected[p] then
                if player:GetEffects():HasNullEffect(NullItemID.ID_TOOTH_AND_NAIL) then
                    revert(player)
                end
                effected[p] = nil
            end
            if player:IsCollectibleBlocked(CollectibleType.COLLECTIBLE_TOOTH_AND_NAIL) then
                player:UnblockCollectible(CollectibleType.COLLECTIBLE_TOOTH_AND_NAIL)
            end
            blocked[p] = nil
        end
    else
        if not blocked[p] then
            if player:GetEffects():HasNullEffect(NullItemID.ID_TOOTH_AND_NAIL) then
                revert(player)
            end
        end
        if not player:IsCollectibleBlocked(CollectibleType.COLLECTIBLE_TOOTH_AND_NAIL) then
            player:BlockCollectible(CollectibleType.COLLECTIBLE_TOOTH_AND_NAIL)
        end
        blocked[p] = true
    end
end

---@param func fun(player: EntityPlayer, i: integer?)
local function forEachToothAndNailer(func)
    CatGuy.PlayerUtils.ForEachPlayer(function(player, i)
        if hasSynergy(player) then
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
        effected[GetPtrHash(player)] = true
    end)
end

local function revertBeat()
    if Game():IsPauseMenuOpen() then
        return
    end
    forEachToothAndNailer(function(player)
        revert(player)
        effected[GetPtrHash(player)] = nil
    end)
end

function toothAndNail.Tick(tempoManager)
    if not CatGuy.PlayerUtils.AnyPlayer(function(player) return hasSynergy(player) end) then
        successfulTick = 0
        return
    end

    local measureDuration = math.ceil(2 ^ math.floor(math.log(12 / tempoManager.timeSig, 2)))
    local firstMeasure = (tempoManager.measure % measureDuration) == 0
    local lastMeasure = (tempoManager.measure % measureDuration) == (measureDuration - 1)

    if lastMeasure and tempoManager.timeSigCount == 2 then
        tickBeat(1)
    elseif lastMeasure and tempoManager.timeSigCount == 1 then
        tickBeat(2)
    elseif lastMeasure and tempoManager.timeSigCount == 0 then
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
            effected[GetPtrHash(player)] = nil
        end)
    end
    wasPaused = paused
end

return toothAndNail