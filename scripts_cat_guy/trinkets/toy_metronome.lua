local SFX_ID_RIMSHOT = Isaac.GetSoundIdByName("Rimshot")

local CROP_CENTER  = 32
local CROP_LEFT    = 64
local CROP_RIGHT   = 96
local CROP_INVALID = 128

local preventTrigger = false

local lastBeatValid = true
local lastBeat = 0.0
local ticked = false
local left = true

local function update()
    if not Game():IsPauseMenuOpen() then
        local tempoManager = CatGuy.TempoManager
        if not (tempoManager and tempoManager.tempoDef and tempoManager.tempoDef.bpm) then
            lastBeatValid = false
        else
            lastBeatValid = true
            lastBeat = tempoManager.beat
        end
    end

    if not lastBeatValid then
        return CROP_INVALID
    else
        if ticked then
            if lastBeat % 1 < 0.5 then
                return CROP_CENTER
            else
                left = not left
                ticked = false
            end
        end
        if left then
            return CROP_LEFT
        else
            return CROP_RIGHT
        end
    end
end

---@type TrinketCallbacks
local toyMetronome = {}

function toyMetronome.UseItem(itemId, _, player, _, _, _)
    if player:HasTrinket(CatGuy.TrinketType.TOY_METRONOME) and not preventTrigger then
        local item = Isaac.GetItemConfig():GetCollectible(itemId)
        if item and item.ChargeType == 0 and player:GetTrinketRNG(CatGuy.TrinketType.TOY_METRONOME):RandomFloat() < (item.MaxCharges * 0.001) then
            preventTrigger = true
            player:UseActiveItem(CollectibleType.COLLECTIBLE_METRONOME)
            preventTrigger = false
        end
    end
end

function toyMetronome.Tick(tempoManager)
    if not tempoManager.tempoDef or Game():IsPauseMenuOpen() then
        return
    end
    ticked = true
    if Options.SFXVolume > 0.0001 and (CatGuy.PlayerUtils.AnyPlayer(function(player) return player:HasTrinket(CatGuy.TrinketType.TOY_METRONOME) end)
    or (CatGuy:GetConfig("MomsHeadphonesHaveMetronome") and CatGuy.PlayerUtils.AnyPlayer(function(player) return player:HasCollectible(CatGuy.CollectibleType.MOMS_HEADPHONES) end))) then
        SFXManager():Play(SFX_ID_RIMSHOT,
            math.max(Options.MusicVolume / Options.SFXVolume, 1), 2,
            false, tempoManager.timeSigCount == tempoManager.timeSig - 1 and 1.25 or 1)
    end
end

function toyMetronome.PrePlayerHUDTrinketRender_trinket()
    return {CropOffset = Vector(update(), 0)}
end



return toyMetronome