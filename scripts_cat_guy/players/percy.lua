local PLAYER_TYPE_PERCY = Isaac.GetPlayerTypeByName("Percy")
local TRINKET_ID_TOY_METRONOME = Isaac.GetTrinketIdByName("Toy Metronome")

---@type table<integer, number>
local needsTrinket = {}

---@type PlayerCallbacks
local percy = {}

function percy.PostGameStarted(continued)
    if continued then
        CatGuy.PlayerUtils.ForEachPlayer(function(player)
            if player:GetPlayerType() == PLAYER_TYPE_PERCY then
                needsTrinket[GetPtrHash(player)] = 0
            end
        end)
    end
end

function percy.PostPlayerInit_player(player)
    needsTrinket[GetPtrHash(player)] = 2
end

function percy.PostPlayerUpdate_player(player)
    if needsTrinket[GetPtrHash(player)] then
        local p = GetPtrHash(player)
        if needsTrinket[p] == 1 then
            local spawnPos = Game():GetRoom():FindFreePickupSpawnPosition(player.Position, 40, true)
            Game():Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, spawnPos, Vector(0, 0), nil,
                TRINKET_ID_TOY_METRONOME, Game():GetRoom():GetSpawnSeed())
        end
        needsTrinket[p] = needsTrinket[p] - 1
    end
end

local function ApplyShader(player)
    local shader = "shaders/coloroffset_percy"

    -- Base player sprite
    player:GetSprite():SetCustomShader(shader)

    -- Costume sprites
    for _, costume in ipairs(player:GetCostumeSpriteDescs()) do
        costume:GetSprite():SetCustomShader(shader)
    end
end

function percy.PostPlayerRender_player(player)
    ApplyShader(player)
end

return percy
