local PLAYER_TYPE_PERCY = Isaac.GetPlayerTypeByName("Percy")
local TRINKET_ID_TOY_METRONOME = Isaac.GetTrinketIdByName("Toy Metronome")

---@type PlayerUtils
local util = include("scripts_cat_guy.players.player_utils")

---@param player EntityPlayer 
local function giveTrinket(player)
    local spawnPos = Game():GetRoom():FindFreePickupSpawnPosition(player.Position, 40, true)
    Game():Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, spawnPos, Vector(0, 0), nil,
        TRINKET_ID_TOY_METRONOME, Game():GetRoom():GetSpawnSeed())
end

---@type PlayerCallbacks
local percy = {}

function percy.PostGameStarted(continued)
    if not continued then
        util.ForEachPlayer(function(player)
            if player:GetPlayerType() == PLAYER_TYPE_PERCY then
                giveTrinket(player)
            end
        end)
    end
end

function percy.PostPlayerInit_player(player)
    if Game():GetRoom() then
        giveTrinket(player)
    end
end

return percy
