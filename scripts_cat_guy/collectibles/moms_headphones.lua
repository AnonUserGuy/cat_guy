local TRINKET_ID_TOY_METRONOME = Isaac.GetTrinketIdByName("Toy Metronome")
local ITEM_ID_MOMS_HEADPHONES = Isaac.GetItemIdByName("Mom's Headphones")

local DAMAGE_MULT_MAX = 2
local DAMAGE_MULT_MIN = 0.95
local DAMAGE_MULT_EXP = 4

local debugstring = ""

---@type table<integer, number>
local needsTrinket = {}

---@type table<integer, Direction>
local lastFireDirection = {}

---@type table<integer, integer>
local lastTimeFired = {}

---@type table<integer, number>
local tempoDamageMultiplier = {}

---@param time number
local function getTempoDamageMultiplier(time)
    return (2 ^ DAMAGE_MULT_EXP) * (DAMAGE_MULT_MAX - DAMAGE_MULT_MIN) * ((time - 0.5) ^ DAMAGE_MULT_EXP) + DAMAGE_MULT_MIN
end

---@param player EntityPlayer
local function getFireDelayDamageMultiplier(player)
    local p = GetPtrHash(player)
    local time = Game():GetFrameCount()
    local delta = time - (lastTimeFired[p] or 0)
    

    if delta > 0 and delta < player.MaxFireDelay then
        return delta / player.MaxFireDelay
    end
    return 1.0
end

local function updateFire(player)
    local p = GetPtrHash(player)
    local dir = player:GetFireDirection()

    if lastFireDirection[p] ~= dir then
        lastFireDirection[p] = dir
        if player.FireDelay < 999 then
            player.FireDelay = -1
        end
        if dir ~= Direction.NO_DIRECTION then
            local tempoManager = CatGuy.TempoManager
            if tempoManager and tempoManager.tempoDef and tempoManager.tempoDef.bpm then
                tempoDamageMultiplier[p] = getTempoDamageMultiplier(tempoManager.beat % 1.0)
            else
                tempoDamageMultiplier[p] = 1.0
            end
        end
    end
end

---@type CollectibleCallbacks
local headphones = {}

function headphones.PostGameStarted(continued)
    if continued then
        CatGuy.PlayerUtils.ForEachPlayer(function(player)
            if player:HasCollectible(ITEM_ID_MOMS_HEADPHONES) then
                needsTrinket[GetPtrHash(player)] = 0
            end
        end)
    end
end

function headphones.PostAddCollectible_item(_, _, firstTime, _, _, player)
    if firstTime then
        needsTrinket[GetPtrHash(player)] = 2
    end
--[[     player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
    player:EvaluateItems() ]]
end

function headphones.PostPlayerUpdate(player)
    if needsTrinket[GetPtrHash(player)] then
        local p = GetPtrHash(player)
        if needsTrinket[p] == 1 then
            local spawnPos = Game():GetRoom():FindFreePickupSpawnPosition(player.Position, 40, true)
            Game():Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, spawnPos, Vector(0, 0), nil,
                TRINKET_ID_TOY_METRONOME, Game():GetRoom():GetSpawnSeed())
        end
        needsTrinket[p] = needsTrinket[p] - 1
    end
    if not player:HasCollectible(ITEM_ID_MOMS_HEADPHONES) then
        return
    end

    updateFire(player)

    local weapon = player:GetWeapon(1)
    if weapon then
        weapon:SetModifiers(WeaponModifier.NEPTUNUS)
        weapon:SetCharge(getFireDelayDamageMultiplier(player) * weapon:GetMaxCharge())

    end
end

function headphones.PostFireTear(tear)
    local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
    if not player or not player:HasCollectible(ITEM_ID_MOMS_HEADPHONES) then
        return
    end

    updateFire(player)
    player.FireDelay = 999
    local p = GetPtrHash(player)
    local multiplier = getFireDelayDamageMultiplier(player) * (tempoDamageMultiplier[p] or 1.0)
    lastTimeFired[p] = Game():GetFrameCount()

    tear.CollisionDamage = tear.CollisionDamage * multiplier
    tear.Scale = tear.Scale * multiplier
    debugstring = tostring(tear.CollisionDamage)
end

function headphones.PostPlayerRender(player)
    Isaac.RenderText(debugstring, 20, 20, 1, 1, 1, 1)
end

--[[ headphones.EvaluateCache = {}
headphones.EvaluateCache[CacheFlag.CACHE_FIREDELAY] = function(player)
    if player:HasCollectible(ITEM_ID_MOMS_HEADPHONES) then
        player.MaxFireDelay = player.MaxFireDelay * 0.01
    end
end ]]

return headphones