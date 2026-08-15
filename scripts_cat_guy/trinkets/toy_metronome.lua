local TRINKET_ID_TOY_METRONOME = Isaac.GetTrinketIdByName("Toy Metronome")
local SFX_ID_RIMSHOT = Isaac.GetSoundIdByName("Rimshot")

local CROP_CENTER  = 32
local CROP_LEFT    = 64
local CROP_RIGHT   = 96
local CROP_INVALID = 128

local preventTrigger = false

local function getCropOffset()
    local tempoManager = CatGuy.TempoManager
    if not (tempoManager and tempoManager.tempoDef and tempoManager.tempoDef.bpm) then
        return CROP_INVALID
    elseif tempoManager.beat % 1 < 0.5 then
        return CROP_CENTER
    elseif tempoManager.beat % 2 < 1 then
        return CROP_LEFT
    else
        return CROP_RIGHT
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