local TRINKET_ID_TOY_METRONOME = Isaac.GetTrinketIdByName("Toy Metronome")
local ITEM_ID_MOMS_HEADPHONES = Isaac.GetItemIdByName("Mom's Headphones")

local DAMAGE_MULT_MAX = 2
local DAMAGE_MULT_MIN = 0.75
local DAMAGE_MULT_EXP = 4

local FETAL_DELAY = 2

local debugstring = ""

---@type table<integer, number>
local needsTrinket = {}

---@type table<integer, Direction>
local lastFireDirection = {}

---@type table<integer, integer>
local lastTimeFired = {}

---@type table<integer, integer>
local iWantToHaveABaby = {}

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

    local fireDelay = player.MaxFireDelay
    if player:HasCollectible(CollectibleType.COLLECTIBLE_C_SECTION) then
        fireDelay = fireDelay * 3
    end

    if delta > 0 and delta < fireDelay then
        return delta / fireDelay
    end
    return 1.0
end

---@param player EntityPlayer
local function updateTempoDamage(player)
    local p = GetPtrHash(player)
    local tempoManager = CatGuy.TempoManager
    if tempoManager and tempoManager.tempoDef and tempoManager.tempoDef.bpm then
        tempoDamageMultiplier[p] = getTempoDamageMultiplier(tempoManager.beat % 1.0)
    else
        tempoDamageMultiplier[p] = 1.0
    end
end

---@param player EntityPlayer
local function doFireDelay(player)
    local weapon = player:GetWeapon(1)
    return not weapon or (weapon:GetModifiers() & (
        WeaponModifier.CHOCOLATE_MILK
        | WeaponModifier.CURSED_EYE
        | WeaponModifier.BRIMSTONE
        | WeaponModifier.MONSTROS_LUNG
        | WeaponModifier.LUDOVICO_TECHNIQUE
        | WeaponModifier.SOY_MILK
    )) == 0
end

---@param player EntityPlayer
local function updateFire(player)
    local p = GetPtrHash(player)
    local dir = player:GetFireDirection()

    if lastFireDirection[p] ~= dir then
        lastFireDirection[p] = dir
        if player.FireDelay < 999 then
            player.FireDelay = -1
        end
        if dir ~= Direction.NO_DIRECTION then
            updateTempoDamage(player)
            return true
        end
    end
    return false
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
    if firstTime and not player:HasTrinket(TRINKET_ID_TOY_METRONOME) then
        needsTrinket[GetPtrHash(player)] = 2
    end
end

function headphones.PostPlayerUpdate(player)
    local p = GetPtrHash(player)
    if needsTrinket[p] then
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


    if doFireDelay(player) and updateFire(player) then
        iWantToHaveABaby[p] = FETAL_DELAY
    end
    
    local weapon = player:GetWeapon(1)
    if weapon then
        local modifiers = weapon:GetModifiers()
        if (modifiers & WeaponModifier.LUDOVICO_TECHNIQUE) ~= 0 then
            local tear = weapon:GetMainEntity() and weapon:GetMainEntity():ToTear()
            if tear then
                updateTempoDamage(player)
                
                local multiplier = tempoDamageMultiplier[p] or 1.0
                tear.CollisionDamage = player.Damage * (multiplier or 1.0)
                tear.Scale = 1.5 * (tear.CollisionDamage ^ 0.25)
                return
            end

            local laser = weapon:GetMainEntity() and weapon:GetMainEntity():ToLaser()
            if laser then
                updateTempoDamage(player)
                local multiplier = tempoDamageMultiplier[p] or 1.0
                laser.CollisionDamage = player.Damage * (multiplier or 1.0)
                laser:SetScale(multiplier ^ 0.5)
            end
        elseif (modifiers & (WeaponModifier.BRIMSTONE | WeaponModifier.SOY_MILK)) == (WeaponModifier.BRIMSTONE | WeaponModifier.SOY_MILK) then
            local laser = weapon:GetMainEntity() and weapon:GetMainEntity():ToLaser()
            if laser then
                updateTempoDamage(player)
                local multiplier = tempoDamageMultiplier[p] or 1.0
                laser:SetDamageMultiplier(multiplier)
                laser:SetScale(multiplier ^ 0.5)
            end
        elseif (modifiers & WeaponModifier.CHOCOLATE_MILK) ~= 0 then
        elseif (modifiers & WeaponModifier.CURSED_EYE) ~= 0 then
        elseif (modifiers & WeaponModifier.BRIMSTONE) ~= 0 then
        elseif (modifiers & WeaponModifier.MONSTROS_LUNG) ~= 0 then
        elseif (modifiers & WeaponModifier.C_SECTION) ~= 0 then
            if not iWantToHaveABaby[p] then
                weapon:SetCharge(getFireDelayDamageMultiplier(player) * weapon:GetMaxCharge() - FETAL_DELAY)
            else
                weapon:SetCharge(weapon:GetMaxCharge() - iWantToHaveABaby[p])
                iWantToHaveABaby[p] = iWantToHaveABaby[p] - 1
            end
        elseif (modifiers & WeaponModifier.BONE) ~= 0 then
        else
            weapon:SetModifiers(weapon:GetModifiers() | WeaponModifier.NEPTUNUS)
            weapon:SetCharge(getFireDelayDamageMultiplier(player) * weapon:GetMaxCharge())
        end
    end
end

function headphones.PostFireTear(tear)
    local player = tear.SpawnerEntity:ToPlayer()
    if not player or not player:HasCollectible(ITEM_ID_MOMS_HEADPHONES) then
        return
    end

    if doFireDelay(player) then
        player.FireDelay = 999
    else
        updateTempoDamage(player)
    end
    
    local p = GetPtrHash(player)
    local fireDelayDamageMultiplier = doFireDelay(player) and (getFireDelayDamageMultiplier(player) ^ 2) or 1.0
    local multiplier = fireDelayDamageMultiplier * (tempoDamageMultiplier[p] or 1.0)
    lastTimeFired[p] = Game():GetFrameCount()
    iWantToHaveABaby[p] = nil

    tear.CollisionDamage = tear.CollisionDamage * multiplier
    tear.Scale = tear.Scale * (multiplier ^ 0.5)
    debugstring = tostring(tear.CollisionDamage)
end

function headphones.PostFireBrimstone(laser)
    local player = laser.SpawnerEntity:ToPlayer()
    if not player or not player:HasCollectible(ITEM_ID_MOMS_HEADPHONES) then
        return
    end

    updateTempoDamage(player)

    local p = GetPtrHash(player)
    local multiplier = tempoDamageMultiplier[p] or 1.0
    laser:SetDamageMultiplier(laser:GetDamageMultiplier() * multiplier)
    laser:SetScale(laser:GetScale() * (multiplier ^ 0.5))
    debugstring = tostring(laser:GetDamageMultiplier())
end

function headphones.PostPlayerRender(player)
    Isaac.RenderText(debugstring, 20, 20, 1, 1, 1, 1)
end

return headphones