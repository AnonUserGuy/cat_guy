local TRINKET_ID_TOY_METRONOME = Isaac.GetTrinketIdByName("Toy Metronome")
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

local function getCropOffset()
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
    elseif lastBeat % 1 < 0.5 then
        ticked = true
        return CROP_CENTER
    else
        if ticked then
            left = not left
            ticked = false
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
    if player:HasTrinket(TRINKET_ID_TOY_METRONOME) and not preventTrigger then
        local item = Isaac.GetItemConfig():GetCollectible(itemId)
        if item and item.ChargeType == 0 and player:GetTrinketRNG(TRINKET_ID_TOY_METRONOME):RandomFloat() < (item.MaxCharges * 0.01) then
            preventTrigger = true
            player:UseActiveItem(CollectibleType.COLLECTIBLE_METRONOME, UseFlag.USE_NOANIM)
            preventTrigger = false
        end
    end
end

function toyMetronome.Tick(measure)
    if Game():IsPauseMenuOpen() then
        return
    end
    local util = CatGuy.PlayerUtils
    if Options.SFXVolume > 0.0001 and util.AnyPlayer(function(player) return player:HasTrinket(TRINKET_ID_TOY_METRONOME) end) then
        SFXManager():Play(SFX_ID_RIMSHOT,
            math.max(Options.MusicVolume / Options.SFXVolume, 1), 2,
            false, measure and 1.25 or 1)
    end
end

function toyMetronome.PrePlayerHUDTrinketRender_trinket(_, position, scale)
    return {CropOffset = Vector(getCropOffset(), 0)}
end



return toyMetronome