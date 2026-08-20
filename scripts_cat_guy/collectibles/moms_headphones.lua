--- Synergies done:
--- - Default Tears
---     - Can no longer hold to fire continually
---     - Deal more damage if fired on beat
---     - Unlimited firing, but firing faster than fire rate does significantly less damage
---         - Charge bar indicates normal fire rate
---
--- - Soy Milk
---     - Tear rate set to tear rate closest to song's tempo * 2^N
---     - Deal more damage if fired on beat
--- 
--- - Marked
---     - Tear rate set to tear rate closest to song's tempo * 2^N
---     - Deal more damage if fired on beat
---
--- - C Section
---     - First fetus takes 1/2/0.5 beats to fire depending on tear rate
---     - Fetuses deal more damage if fired on beat
---
--- - Ludovico Technique
---     - Damage and size is highest on downbeats, lowest on upbeats
---
--- - Brimstone
---     - Deals more damage if released on beat
---
--- - Brimstone + Soy Milk
---     - Damage and size is highest on downbeats, lowest on upbeats
---
--- - Tech X
---     - Deals more damage if released on beat
---
--- - Technology
---     - Can no longer hold to fire continually
---     - Deal more damage if fired on beat
---     - Unlimited firing, but firing faster than fire rate does significantly less damage
---     - Basically just same as normal tears
---
--- - Technology 2
---     - Damage and size is highest on downbeats, lowest on upbeats
---
--- - Chocolate Milk, Cursed Eye, Monstro's Lung
---     - Deals more damage if released on beat
---
--- - Mom's Knife
---     - While held: damage is highest on downbeats, lowest on upbeats
---     - When fired: deals more damage if released on beat
---
--- - Spirit Sword
---     - Deal more damage if swung on beat
---
--- - Forgotten's Bone Club
---     - Deal more damage if swung on beat
---
--- - Notched Axe
---     - Deal more damage if swung on beat
---
--- - Incubus/Twisted Pair
---     - Works same as player
---
--- - Gello
---     - Releasing Gello: Deals more damage if released on beat
---     - Released Gello: Works same as player
---
--- - Tainted Lilith's Gello
---     - Releasing Gello: Deals more damage if released on beat
---     - Released Gello: Functions as usual
---         - Tear rate set to tear rate closest to song's tempo * 2^N
---
--- - Tainted Lilith's Gello + C Section
---     - Releasing Gello: Deals more damage if released on beat
---     - Released Gello: Works same as player (with C Section and that's not Tainted Lilith)
---
--- - Incubus/Twisted Pair/Gello + Technology's
---     - Doesn't work due to REPENTOGON bug
---     - Their technology's function as usual
---
---
--- Synergies to do:
--- - Broken Stopwatch/I'm Excited/I'm Drowsy
---     - tear rate stuff
--- - Paralysis
---     - should stop bouncing
--- - Tainted Lilith's Gello + various
--- - Tech.5?
---     - I can't figure out a way to detect it as opposed to Technology lasers
--- - Epic Fetus?
---     - Maybe missile lands in 1 measure?
--- - Neputus?
--- - Tooth and Nail?
---     - Make turn to stone every 1 to 2 measures
--- - Epiphoria?

local FAMILIAR_DAMAGE_MULTIPLIER = {
    [FamiliarVariant.INCUBUS] = 0.75,
    [FamiliarVariant.TWISTED_BABY] = 0.375,
    [FamiliarVariant.UMBILICAL_BABY] = 0.75
}

local FAMILIAR_DAMAGE_MULTIPLIER_LILITH = {
    [FamiliarVariant.INCUBUS] = 1.0,
    [FamiliarVariant.TWISTED_BABY] = 0.5,
    [FamiliarVariant.UMBILICAL_BABY] = 1.0
}

local DAMAGE_MULT_MAX = 2.0
local DAMAGE_MULT_MIN = 0.75
local DAMAGE_MULT_EXP = 4.0

local lastBeat = 0.0

local debugstring = ""

local needsTrinket = {} ---@type table<Pointer, number>
local lastFireDirection = {} ---@type table<Pointer, Direction>
local lastTimeFired = {} ---@type table<Pointer, integer>
local iWantToHaveABaby = {} ---@type table<Pointer, number>
local tempoDamageMultiplier = {} ---@type table<Pointer, number>
local fireDelayDamageMultiplier = {} ---@type table<Pointer, number>
local technology2Laser = {} ---@type table<Pointer, EntityLaser>

---@param beat number
local function getTempoDamageEqn(beat)
    return (2 ^ DAMAGE_MULT_EXP) * (DAMAGE_MULT_MAX - DAMAGE_MULT_MIN) * ((beat - 0.5) ^ DAMAGE_MULT_EXP) +
        DAMAGE_MULT_MIN
end

---@param latencyAdjusted? boolean
---@param release? boolean
local function getTempoDamageMultiplier(latencyAdjusted, release)
    local tempoManager = CatGuy.TempoManager
    if tempoManager and tempoManager.tempoDef then
        return getTempoDamageEqn((latencyAdjusted and tempoManager:GetLatencyAdjustedBeat(release) or tempoManager.beat) % 1.0)
    else
        return 1.0
    end
end

---@param player EntityPlayer
---@param latencyAdjusted? boolean
---@param release? boolean
local function updateTempoDamageMultiplier(player, latencyAdjusted, release)
    local p = GetPtrHash(player)
    tempoDamageMultiplier[p] = getTempoDamageMultiplier(latencyAdjusted, release)
end

---@param player EntityPlayer
---@param updateLastFire boolean?
local function getFireDelayDamageMultiplier(player, updateLastFire)
    local p = GetPtrHash(player)
    local time = Game():GetFrameCount()
    local delta = time - (lastTimeFired[p] or 0)

    local fireDelay = player.MaxFireDelay

    if delta > 0 then
        if delta < fireDelay then
            fireDelayDamageMultiplier[p] = delta / fireDelay
        else
            fireDelayDamageMultiplier[p] = 1.0
        end
    end
    if updateLastFire then
        lastTimeFired[p] = time
    end
    return fireDelayDamageMultiplier[p] or 1.0
end

---@param familiar EntityFamiliar
---@param updateLastFire boolean?
function GetFireDelayDamageMultiplierFamiliar(familiar, updateLastFire)
    local f = GetPtrHash(familiar)
    local time = Game():GetFrameCount()
    local delta = time - (lastTimeFired[f] or 0)

    local fireDelay = familiar.Player.MaxFireDelay

    if delta > 0 then
        if delta < fireDelay then
            fireDelayDamageMultiplier[f] = delta / fireDelay
        else
            fireDelayDamageMultiplier[f] = 1.0
        end
    end
    if updateLastFire then
        lastTimeFired[f] = time
    end
    return fireDelayDamageMultiplier[f] or 1.0
end

---@param player EntityPlayer
---@param onlyPostPlayerUpdate? boolean
---@param ignoreModifiers? WeaponModifier|integer
local function doFireDelay(player, onlyPostPlayerUpdate, ignoreModifiers)
    ignoreModifiers = ignoreModifiers or 0
    local weapon = player:GetWeapon(1)
    local modifiers = not onlyPostPlayerUpdate and (
        WeaponModifier.CHOCOLATE_MILK
        | WeaponModifier.CURSED_EYE
        | WeaponModifier.BRIMSTONE
        | WeaponModifier.MONSTROS_LUNG
        | WeaponModifier.LUDOVICO_TECHNIQUE
        | WeaponModifier.SOY_MILK
        | WeaponModifier.C_SECTION
    ) or (
        WeaponModifier.BRIMSTONE
        | WeaponModifier.SOY_MILK
    )
    return weapon and (weapon:GetModifiers() & modifiers & ~ignoreModifiers) == 0
        and weapon:GetWeaponType() ~= WeaponType.WEAPON_BONE
        and (not player:GetWeapon(0) or player:GetWeapon(0):GetWeaponType() ~= WeaponType.WEAPON_NOTCHED_AXE)
        and not player:HasCollectible(CollectibleType.COLLECTIBLE_MARKED)
end

local function getFetalDelay()
    local tempoManager = CatGuy.TempoManager
    if tempoManager and tempoManager.tempoDef then
        local beat = tempoManager:GetLatencyAdjustedBeatCSection()
        lastBeat = beat
        return beat
    else
        return 1.0
    end
end

---@param player EntityPlayer
local function updateFire(player)
    local p = GetPtrHash(player)
    local dir = player:GetFireDirection()

    if lastFireDirection[p] ~= dir then
        if player.FireDelay < 999 then
            player.FireDelay = -1
        end
        if dir ~= Direction.NO_DIRECTION then
            updateTempoDamageMultiplier(player, true)
            if lastFireDirection[p] == Direction.NO_DIRECTION then
                iWantToHaveABaby[p] = getFetalDelay()
            end
        else
            iWantToHaveABaby[p] = nil
        end
        lastFireDirection[p] = dir
    end
end

---@type CollectibleCallbacks
local headphones = {}

function headphones.PostGameStarted(continued)
    if continued then
        CatGuy.PlayerUtils.ForEachPlayer(function(player)
            if player:HasCollectible(CatGuy.CollectibleType.MOMS_HEADPHONES) then
                needsTrinket[GetPtrHash(player)] = 0
            end
        end)
    end
end

function headphones.PostAddCollectible_item(_, _, firstTime, _, _, player)
    if firstTime and not player:HasTrinket(CatGuy.TrinketType.TOY_METRONOME) then
        needsTrinket[GetPtrHash(player)] = 2
    end
end

---@param player EntityPlayer
---@param weapon Weapon
local function updateFetus(player, weapon)
    local p = GetPtrHash(player)
    if iWantToHaveABaby[p] then
        local tempoManager = CatGuy.TempoManager
        if not tempoManager or not tempoManager.tempoDef then
            iWantToHaveABaby[p] = nil
            return
        end
        local beat = tempoManager.beat
        if beat < lastBeat then
            iWantToHaveABaby[p] = nil
            return
        end
        lastBeat = beat
        local q = CatGuy.TempoManager:GetRhythmicFireDelayFactor(player.MaxFireDelay * 3)
        weapon:SetCharge((beat - iWantToHaveABaby[p]) / q * weapon:GetMaxCharge())
    end
end

---@param player EntityPlayer
---@param weapon Weapon
---@param familiarMultiplier number?
local function updateLudo(player, weapon, familiarMultiplier)
    familiarMultiplier = familiarMultiplier or 1.0
    local tempoMultiplier = getTempoDamageMultiplier()

    local mainEntity = weapon:GetMainEntity()
    if not mainEntity then
        return
    end

    local tear = mainEntity:ToTear()
    if tear then
        tear.CollisionDamage = player.Damage * tempoMultiplier * familiarMultiplier
        tear.Scale = 1.5 * (tear.CollisionDamage ^ 0.25 * familiarMultiplier)
        return
    end

    local laser = mainEntity:ToLaser()
    if laser then
        laser.CollisionDamage = player.Damage * tempoMultiplier * familiarMultiplier
        laser:SetScale(tempoMultiplier ^ 0.5 * familiarMultiplier)
        return
    end

    local knife = mainEntity:ToKnife()
    if knife then
        local multiplier = tempoMultiplier ^ 0.25 * familiarMultiplier
        knife:GetSprite().Scale = Vector(multiplier, multiplier)
        return
    end
end

---@param player EntityPlayer
---@param weapon Weapon
---@param familiarMultiplier number?
local function updateSoyBrim(player, weapon, familiarMultiplier)
    familiarMultiplier = familiarMultiplier or 1.0
    local laser = weapon:GetMainEntity() and weapon:GetMainEntity():ToLaser()
    if laser then
        local tempoMultiplier = getTempoDamageMultiplier()
        laser:SetDamageMultiplier(tempoMultiplier * familiarMultiplier)
        laser:SetScale(tempoMultiplier ^ 0.5 * familiarMultiplier)
    end
end

---@param player EntityPlayer
---@param weapon Weapon
---@param familiarMultiplier number?
local function updateKnife(player, weapon, familiarMultiplier)
    familiarMultiplier = familiarMultiplier or 1.0
    local knife = weapon:GetMainEntity() and weapon:GetMainEntity():ToKnife()
    if knife then
        local p = GetPtrHash(player)
        if not knife:IsFlying() then
            updateTempoDamageMultiplier(player)
        end
        local multiplier = tempoDamageMultiplier[p] ^ 0.25 * familiarMultiplier
        knife:GetSprite().Scale = Vector(multiplier, multiplier)
    end
end

function headphones.PostPlayerUpdate(player)
    local p = GetPtrHash(player)
    if needsTrinket[p] then
        if needsTrinket[p] == 1 then
            local spawnPos = Game():GetRoom():FindFreePickupSpawnPosition(player.Position, 40, true)
            Game():Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, spawnPos, Vector(0, 0), nil,
                CatGuy.TrinketType.TOY_METRONOME, Game():GetRoom():GetSpawnSeed())
        end
        needsTrinket[p] = needsTrinket[p] - 1
    end
    if not player:HasCollectible(CatGuy.CollectibleType.MOMS_HEADPHONES) then
        return
    end

    if doFireDelay(player, true) then
        updateFire(player)
    end

    if technology2Laser[p] then
        local multiplier = getTempoDamageMultiplier()
        technology2Laser[p]:SetDamageMultiplier(multiplier * 0.13)
        technology2Laser[p]:SetScale(multiplier ^ 0.5)
    end

    local weapon = player:GetWeapon(1)
    if not weapon then
        return
    end

    local modifiers = weapon:GetModifiers()
    local type = weapon:GetWeaponType()
    --print(modifiers..", "..type)
    player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
    player:EvaluateItems()

    if (type == WeaponType.WEAPON_TEARS) then
        if (player:GetPlayerType() == PlayerType.PLAYER_LILITH_B) then
        elseif (modifiers & WeaponModifier.CHOCOLATE_MILK) ~= 0 then
        elseif (modifiers & WeaponModifier.CURSED_EYE) ~= 0 then
        elseif (modifiers & WeaponModifier.BRIMSTONE) ~= 0 then
        elseif (modifiers & WeaponModifier.MONSTROS_LUNG) ~= 0 then
        elseif (modifiers & WeaponModifier.SOY_MILK) ~= 0 then
        elseif (player:HasCollectible(CollectibleType.COLLECTIBLE_MARKED)) then
        elseif (player:GetWeapon(0)) then
        else
            weapon:SetModifiers(WeaponModifier.NEPTUNUS)
            weapon:SetCharge(getFireDelayDamageMultiplier(player) * weapon:GetMaxCharge())
        end
    elseif (type == WeaponType.WEAPON_BRIMSTONE) then
        if (modifiers & (WeaponModifier.SOY_MILK)) ~= 0 then
            updateSoyBrim(player, weapon)
        end
        if (modifiers & (WeaponModifier.LUDOVICO_TECHNIQUE)) ~= 0 then
            updateLudo(player, weapon)
        end
    elseif (type == WeaponType.WEAPON_LASER) then
        if (modifiers & (WeaponModifier.LUDOVICO_TECHNIQUE)) ~= 0 then
            updateLudo(player, weapon)
        end
    elseif (type == WeaponType.WEAPON_KNIFE) then
        updateKnife(player, weapon)
    elseif (type == WeaponType.WEAPON_LUDOVICO_TECHNIQUE) then
        updateLudo(player, weapon)
    elseif (type == WeaponType.WEAPON_FETUS) then
        updateFetus(player, weapon)
    end

    if not player:IsDead() then
        local squish = getTempoDamageMultiplier() ^ 0.10
        player:GetSprite().Scale = Vector(player:GetSprite().Scale.X * squish, player:GetSprite().Scale.Y / squish)

        for _, costume in ipairs(player:GetCostumeSpriteDescs()) do
            costume:GetSprite().Scale = Vector(costume:GetSprite().Scale.X * squish, costume:GetSprite().Scale.Y / squish)
        end
    end
end

function headphones.PostFamiliarUpdate(familiar)
    local player = familiar.Player
    if not player or not player:HasCollectible(CatGuy.CollectibleType.MOMS_HEADPHONES) then
        return
    end

    local weapon = familiar:GetWeapon()
    if not weapon then
        return
    end
    local familiarDamageMultiplier = (((player:GetPlayerType() == PlayerType.PLAYER_LILITH or player:GetPlayerType() == PlayerType.PLAYER_LILITH_B)
        and FAMILIAR_DAMAGE_MULTIPLIER_LILITH or FAMILIAR_DAMAGE_MULTIPLIER)[familiar.Variant] or 1.0) *
    familiar:GetMultiplier()

    local playerWeapon = player:GetWeapon(1)
    if not playerWeapon then
        return
    end

    local modifiers = playerWeapon:GetModifiers()
    local type = playerWeapon:GetWeaponType()

    if (type == WeaponType.WEAPON_TEARS) then
        if familiar.Variant == FamiliarVariant.UMBILICAL_BABY and player:GetPlayerType() == PlayerType.PLAYER_LILITH_B then
            return
        end
        if doFireDelay(player) and player.FireDelay < 0 then
            weapon:SetFireDelay(player.FireDelay)
        end
        if (modifiers & WeaponModifier.NEPTUNUS) ~= 0 then
            weapon:SetCharge(playerWeapon:GetCharge())
        end
    elseif (type == WeaponType.WEAPON_BRIMSTONE) then
        if (modifiers & (WeaponModifier.SOY_MILK)) ~= 0 then
            updateSoyBrim(player, weapon, familiarDamageMultiplier)
        end
        if (modifiers & (WeaponModifier.LUDOVICO_TECHNIQUE)) ~= 0 then
            updateLudo(player, weapon, familiarDamageMultiplier)
        end
    elseif (type == WeaponType.WEAPON_LASER) then
        if (modifiers & (WeaponModifier.LUDOVICO_TECHNIQUE)) ~= 0 then
            updateLudo(player, weapon, familiarDamageMultiplier)
        end
    elseif (type == WeaponType.WEAPON_KNIFE) then
        updateKnife(player, weapon, familiarDamageMultiplier)
    elseif (type == WeaponType.WEAPON_LUDOVICO_TECHNIQUE) then
        updateLudo(player, weapon, familiarDamageMultiplier)
    elseif (type == WeaponType.WEAPON_FETUS) then
        if familiar.Variant == FamiliarVariant.UMBILICAL_BABY and player:GetPlayerType() == PlayerType.PLAYER_LILITH_B then
            updateFetus(player, weapon)
            return
        end
        if playerWeapon:GetCharge() > weapon:GetCharge() then
            weapon:SetCharge(playerWeapon:GetCharge())
        end
    end
end

---@param entity Entity
---@return EntityPlayer?
local function GetSpawnerPlayer(entity)
    local player = entity.SpawnerEntity:ToPlayer()
    if player then
        return player
    end
    local familiar = entity.SpawnerEntity:ToFamiliar()
    if familiar then
        if familiar:GetWeapon() then
            return familiar.Player
        end
    end
    return nil
end

-- Note: only fires for player, NOT incubuses
function headphones.PostFireTechLaser(laser)
    local player = GetSpawnerPlayer(laser)
    if not player or not player:HasCollectible(CatGuy.CollectibleType.MOMS_HEADPHONES) then
        return
    end

    local p = GetPtrHash(player)
    if not laser.OneHit then
        technology2Laser[p] = laser
        return
    end

    if doFireDelay(player) then
        player.FireDelay = 999
    else
        updateTempoDamageMultiplier(player)
    end

    local fireDelayDamageMultiplier0 = doFireDelay(player) and (getFireDelayDamageMultiplier(player, true) ^ 2) or 1.0
    local multiplier = fireDelayDamageMultiplier0 * (tempoDamageMultiplier[p] or 1.0)
    iWantToHaveABaby[p] = nil

    laser.CollisionDamage = laser.CollisionDamage * multiplier
    laser:SetScale(laser:GetScale() * (multiplier ^ 0.5))
    --debugstring = tostring(laser.CollisionDamage)
end

--- only fires for robobabies??
--[[ function headphones.PostFamiliarFireTechLaser(laser)
    local familiar = laser.SpawnerEntity:ToFamiliar()
    if not familiar or not familiar.Player or not familiar.Player:HasCollectible(CatGuy.CollectibleType.MOMS_HEADPHONES) then
        return
    end

    if not laser.OneHit then
        return
    end

    local weapon = familiar:GetWeapon()
    if not weapon then
        return
    end

    local player = familiar.Player
    local p = GetPtrHash(player)
    if doFireDelay(player) then
        weapon:SetFireDelay(999)
        if not player:CanShoot() then
            player.FireDelay = 999
        end
    end

    local f = GetPtrHash(familiar)
    local fireDelayDamageMultiplier = doFireDelay(player) and (GetFireDelayDamageMultiplierFamiliar(familiar) ^ 2) or 1.0
    local multiplier = fireDelayDamageMultiplier * (tempoDamageMultiplier[p] or 1.0)
    lastTimeFired[f] = Game():GetFrameCount()

    laser.CollisionDamage = laser.CollisionDamage * multiplier
    laser:SetScale(laser:GetScale() * (multiplier ^ 0.5))
    debugstring = tostring(laser.CollisionDamage)
end ]]

-- Note: fires for both player AND incubuses
function headphones.PostFireBrimstone(laser)
    local player = GetSpawnerPlayer(laser)
    if not player or not player:HasCollectible(CatGuy.CollectibleType.MOMS_HEADPHONES) then
        return
    end

    updateTempoDamageMultiplier(player, true, true)

    local p = GetPtrHash(player)
    local multiplier = tempoDamageMultiplier[p] or 1.0
    laser:SetDamageMultiplier(laser:GetDamageMultiplier() * multiplier)
    laser:SetScale(laser:GetScale() * (multiplier ^ 0.5))
    --debugstring = tostring(laser:GetDamageMultiplier())
end

function headphones.PostFireTechXLaser(laser)
    local player = GetSpawnerPlayer(laser)
    if not player or not player:HasCollectible(CatGuy.CollectibleType.MOMS_HEADPHONES) then
        return
    end

    updateTempoDamageMultiplier(player, true, true)

    local p = GetPtrHash(player)
    local multiplier = tempoDamageMultiplier[p] or 1.0
    laser:SetDamageMultiplier(laser:GetDamageMultiplier() * multiplier)
    laser:SetScale(laser:GetScale() * (multiplier ^ 0.5))
    --debugstring = tostring(laser:GetDamageMultiplier())
end

function headphones.PostFireKnife(knife)
    local player = GetSpawnerPlayer(knife)
    if not player or not player:HasCollectible(CatGuy.CollectibleType.MOMS_HEADPHONES) then
        return
    end
    updateTempoDamageMultiplier(player, true, true)
end

---@param familiar EntityFamiliar
---@param params TearParams
---@param weaponType WeaponType
local function evaluateTearHitParamsFamiliar(familiar, params, weaponType)
    local weapon = familiar:GetWeapon()
    if not weapon then
        return
    end
    local player = familiar.Player
    local p = GetPtrHash(player)
    if familiar.Variant == FamiliarVariant.UMBILICAL_BABY and player:GetPlayerType() == PlayerType.PLAYER_LILITH_B then
        if weaponType == WeaponType.WEAPON_FETUS then
            if not doFireDelay(player) then
                updateTempoDamageMultiplier(player)
            end
            iWantToHaveABaby[p] = nil
        else
            return
        end
    end

    if weaponType == WeaponType.WEAPON_TEARS
    or weaponType == WeaponType.WEAPON_BOMBS
    or weaponType == WeaponType.WEAPON_FETUS then
        if doFireDelay(player) then
            weapon:SetFireDelay(999)
            if not player:CanShoot() or player:GetPlayerType() == PlayerType.PLAYER_LILITH_B then
                player.FireDelay = 999
            end
        end

        local fireDelayDamageMultiplier0 = doFireDelay(player) and
        (GetFireDelayDamageMultiplierFamiliar(familiar, true) ^ 2) or 1.0
        local multiplier = fireDelayDamageMultiplier0 * (tempoDamageMultiplier[p] or 1.0)

        params.TearDamage = params.TearDamage * multiplier
        params.TearScale = params.TearScale * (multiplier ^ 0.5)
        --debugstring = tostring(params.TearDamage)

    elseif weaponType == WeaponType.WEAPON_KNIFE then
        local multiplier = tempoDamageMultiplier[p] or 1.0
        params.TearDamage = params.TearDamage * multiplier
        params.TearScale = params.TearScale * (multiplier ^ 0.5)
        --debugstring = tostring(params.TearDamage)

    elseif weaponType == WeaponType.WEAPON_BONE
    or weaponType == WeaponType.WEAPON_NOTCHED_AXE
    or weaponType == WeaponType.WEAPON_SPIRIT_SWORD then
        local multiplier = getTempoDamageMultiplier(true)
        params.TearDamage = params.TearDamage * multiplier
        params.TearScale = params.TearScale * (multiplier ^ 0.5)
        --debugstring = tostring(params.TearDamage)
    end
end

function headphones.EvaluateTearHitParams(player, params, weaponType, _, _, source)
    if not player:HasCollectible(CatGuy.CollectibleType.MOMS_HEADPHONES) then
        return
    end

    local p = GetPtrHash(player)
    if not source then
        --- sprinkler
        return
    elseif p ~= GetPtrHash(source) then
        local familiar = source:ToFamiliar()
        if familiar then
            evaluateTearHitParamsFamiliar(familiar, params, weaponType)
        end
        return
    end

    if weaponType == WeaponType.WEAPON_TEARS
    or weaponType == WeaponType.WEAPON_BOMBS
    or weaponType == WeaponType.WEAPON_FETUS then
        if doFireDelay(player) then
            player.FireDelay = 999
        else
            updateTempoDamageMultiplier(player)
        end

        local fireDelayDamageMultiplier0 = doFireDelay(player) and (getFireDelayDamageMultiplier(player, true) ^ 2) or 1.0
        local multiplier = fireDelayDamageMultiplier0 * (tempoDamageMultiplier[p] or 1.0)
        if player:GetPlayerType() ~= PlayerType.PLAYER_LILITH_B then
            iWantToHaveABaby[p] = nil
        end

        params.TearDamage = params.TearDamage * multiplier
        params.TearScale = params.TearScale * (multiplier ^ 0.5)
        --debugstring = tostring(params.TearDamage)

    elseif weaponType == WeaponType.WEAPON_KNIFE then
        local multiplier = tempoDamageMultiplier[p] or 1.0
        params.TearDamage = params.TearDamage * multiplier
        params.TearScale = params.TearScale * (multiplier ^ 0.5)
        --debugstring = tostring(params.TearDamage)

    elseif weaponType == WeaponType.WEAPON_BONE
    or weaponType == WeaponType.WEAPON_NOTCHED_AXE
    or weaponType == WeaponType.WEAPON_SPIRIT_SWORD then
        local multiplier = getTempoDamageMultiplier(true)
        params.TearDamage = params.TearDamage * multiplier
        params.TearScale = params.TearScale * (multiplier ^ 0.5)
        --debugstring = tostring(params.TearDamage)
    end
end

headphones.Priority = {}
headphones.Priority[CallbackPriority.LATE] = {}
headphones.Priority[CallbackPriority.LATE].EvaluateCache = {}
headphones.Priority[CallbackPriority.LATE].EvaluateCache[CacheFlag.CACHE_FIREDELAY] = function(player)
    if not player:HasCollectible(CatGuy.CollectibleType.MOMS_HEADPHONES) then
        return
    end
    player.MaxFireDelay = CatGuy.TempoManager:GetRhythmicFireDelay(player.MaxFireDelay)
end

--[[ function headphones.PostPlayerRender(player)
    if not player:HasCollectible(CatGuy.CollectibleType.MOMS_HEADPHONES) then
        return
    end

    for i = 0, 4 do
        local weapon = player:GetWeapon(i)
        Isaac.RenderText(tostring(weapon and weapon:GetWeaponType() .. ", " .. weapon:GetModifiers()), 10, 20 + i * 20, 1,
            1, 1, 1)
    end
    Isaac.RenderText(tostring(CatGuy.TempoManager.beat.."\n"..CatGuy.TempoManager.beatMusic - CatGuy.TempoManager.beat.."\n"..CatGuy.TempoManager.time.."\n"..tostring(CatGuy.TempoManager.triplet)), 140, 20, 1, 1, 1, 1)
end ]]

return headphones
