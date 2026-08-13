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
---     - Make scale with damage somehow?
--- 
--- - Spirit Sword
---     - Deal more damage if swung on beat
---     - Make scale with damage somehow?
---     - Make charge attack also respect rhythm?
--- 
--- - Forgotten's Bone Club
---     - Deal more damage if swung on beat
---     - Unlimited firing, but firing faster than fire rate does significantly less damage
---     - Make scale with damage somehow?
---     - Make charge attack also respect rhythm?
--- 
--- - Notched Axe
---     - Deal more damage if swung on beat
---     - Unlimited firing, but firing faster than fire rate does significantly less damage
---         - Charge bar indicates normal fire rate
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
--- - Tainted Lilith's Gello + various
--- - Tech.5?
---     - I can't figure out a way to detect it as opposed to Technology lasers
--- - Epic Fetus?
---     - Maybe missile lands in 1 measure?
--- - Neputus?
--- - Tooth and Nail?
---     - Make turn to stone every 1 to 2 measures
--- - Epiphoria?

local TRINKET_ID_TOY_METRONOME = Isaac.GetTrinketIdByName("Toy Metronome")
local ITEM_ID_MOMS_HEADPHONES = Isaac.GetItemIdByName("Mom's Headphones")

local DAMAGE_MULT_MAX = 2.0
local DAMAGE_MULT_MIN = 0.75
local DAMAGE_MULT_EXP = 4.0

local lastBeat = 0.0

local debugstring = ""

---@type table<integer, number>
local needsTrinket = {}

---@type table<integer, Direction>
local lastFireDirection = {}

---@type table<integer, integer>
local lastTimeFired = {}

---@type table<integer, number>
local iWantToHaveABaby = {}

---@type table<integer, number>
local tempoDamageMultiplier = {}

---@type table<integer, EntityLaser>
local technology2Laser = {}

---@param time number
local function getTempoDamageEqn(time)
    return (2 ^ DAMAGE_MULT_EXP) * (DAMAGE_MULT_MAX - DAMAGE_MULT_MIN) * ((time - 0.5) ^ DAMAGE_MULT_EXP) +
        DAMAGE_MULT_MIN
end

local function getTempoDamageMultiplier()
    local tempoManager = CatGuy.TempoManager
    if tempoManager and tempoManager.tempoDef and tempoManager.tempoDef.bpm then
        return getTempoDamageEqn(tempoManager.beat % 1.0)
    else
        return 1.0
    end
end

---@param player EntityPlayer
local function updateTempoDamageMultiplier(player)
    local p = GetPtrHash(player)
    tempoDamageMultiplier[p] = getTempoDamageMultiplier()
end

---@param player EntityPlayer
local function getFireDelayDamageMultiplier(player)
    local p = GetPtrHash(player)
    local time = Game():GetFrameCount()
    local delta = time - (lastTimeFired[p] or 0)

    local fireDelay = player.MaxFireDelay

    if delta > 0 and delta < fireDelay then
        return delta / fireDelay
    end
    return 1.0
end

---@param familiar EntityFamiliar
function GetFireDelayDamageMultiplierFamiliar(familiar)
    local f = GetPtrHash(familiar)
    local time = Game():GetFrameCount()
    local delta = time - (lastTimeFired[f] or 0)

    local fireDelay = familiar.Player.MaxFireDelay

    if delta > 0 and delta < fireDelay then
        return delta / fireDelay
    end
    return 1.0
end

---@param player EntityPlayer
---@param onlyPostPlayerUpdate? boolean
---@param ignoreModifiers? integer|WeaponModifier
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
    return not weapon or (weapon:GetModifiers() & modifiers & ~ignoreModifiers) == 0
end

---@param delay number
local function getRhythmicFireDelayFactor(delay)
    local tempoManager = CatGuy.TempoManager
    if tempoManager and tempoManager.tempoDef then
        local gameTicksPerBeat = 30 * 60 / tempoManager:GetCurrentBPM()
        return 2 ^ math.floor(math.log((delay - 1) / gameTicksPerBeat, 2))
    else
        return 1.0
    end
end

---@param delay number
local function getRhythmicFireDelay(delay)
    local tempoManager = CatGuy.TempoManager
    if tempoManager and tempoManager.tempoDef then
        local gameTicksPerBeat = 30 * 60 / tempoManager:GetCurrentBPM()
        return (2 ^ math.floor(math.log((delay + 1) / gameTicksPerBeat, 2))) * gameTicksPerBeat - 1
    else
        return delay
    end
end

local function getFetalDelay()
    local tempoManager = CatGuy.TempoManager
    if tempoManager and tempoManager.tempoDef then
        lastBeat = tempoManager.beat
        return tempoManager.beat
    else
        return 1.0
    end
end

---@param player EntityPlayer
---@param weapon Weapon
local function fetalUpdate(player, weapon)
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
        local q = getRhythmicFireDelayFactor(player.MaxFireDelay * 3)
        weapon:SetCharge((beat - iWantToHaveABaby[p]) / q * weapon:GetMaxCharge())
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
            updateTempoDamageMultiplier(player)
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
    --print(modifiers..", "..weapon:GetWeaponType())
    if (modifiers & WeaponModifier.SOY_MILK) ~= 0 then
        player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
        player:EvaluateItems()
    end

    if (player:GetPlayerType() == PlayerType.PLAYER_LILITH_B) then
        player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
        player:EvaluateItems()
    elseif (modifiers & WeaponModifier.C_SECTION) ~= 0 then
        fetalUpdate(player, weapon)
    elseif (modifiers & WeaponModifier.LUDOVICO_TECHNIQUE) ~= 0 then
        local tear = weapon:GetMainEntity() and weapon:GetMainEntity():ToTear()
        if tear then
            local multiplier = getTempoDamageMultiplier()
            tear.CollisionDamage = player.Damage * multiplier
            tear.Scale = 1.5 * (tear.CollisionDamage ^ 0.25)
            return
        end

        local laser = weapon:GetMainEntity() and weapon:GetMainEntity():ToLaser()
        if laser then
            local multiplier = getTempoDamageMultiplier()
            laser.CollisionDamage = player.Damage * multiplier
            laser:SetScale(multiplier ^ 0.5)
        end
    elseif (modifiers & (WeaponModifier.BRIMSTONE | WeaponModifier.SOY_MILK)) == (WeaponModifier.BRIMSTONE | WeaponModifier.SOY_MILK) then
        local laser = weapon:GetMainEntity() and weapon:GetMainEntity():ToLaser()
        if laser then
            local multiplier = getTempoDamageMultiplier()
            laser:SetDamageMultiplier(multiplier)
            laser:SetScale(multiplier ^ 0.5)
        end
    elseif (modifiers & WeaponModifier.CHOCOLATE_MILK) ~= 0 then
    elseif (modifiers & WeaponModifier.CURSED_EYE) ~= 0 then
    elseif (modifiers & WeaponModifier.BRIMSTONE) ~= 0 then
    elseif (modifiers & WeaponModifier.MONSTROS_LUNG) ~= 0 then
    elseif (type == WeaponType.WEAPON_TECH_X) then
    elseif (type == WeaponType.WEAPON_KNIFE) then
        local knife = weapon:GetMainEntity() and weapon:GetMainEntity():ToKnife()
        if knife then
            if not knife:IsFlying() then
                updateTempoDamageMultiplier(player)
            end
        end
    elseif (type == WeaponType.WEAPON_BONE) then
    elseif (type == WeaponType.WEAPON_SPIRIT_SWORD) then
    elseif (modifiers & WeaponModifier.SOY_MILK) ~= 0 then
    else
        weapon:SetModifiers(WeaponModifier.NEPTUNUS)
        weapon:SetCharge(getFireDelayDamageMultiplier(player) * weapon:GetMaxCharge())
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
    if not player or not player:HasCollectible(ITEM_ID_MOMS_HEADPHONES) then
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

    local fireDelayDamageMultiplier = doFireDelay(player) and (getFireDelayDamageMultiplier(player) ^ 2) or 1.0
    local multiplier = fireDelayDamageMultiplier * (tempoDamageMultiplier[p] or 1.0)
    lastTimeFired[p] = Game():GetFrameCount()
    iWantToHaveABaby[p] = nil

    laser.CollisionDamage = laser.CollisionDamage * multiplier
    laser:SetScale(laser:GetScale() * (multiplier ^ 0.5))
    debugstring = tostring(laser.CollisionDamage)
end

--- only fires for robobabies??
--[[ function headphones.PostFamiliarFireTechLaser(laser)
    local familiar = laser.SpawnerEntity:ToFamiliar()
    if not familiar or not familiar.Player or not familiar.Player:HasCollectible(ITEM_ID_MOMS_HEADPHONES) then
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
    if not player or not player:HasCollectible(ITEM_ID_MOMS_HEADPHONES) then
        return
    end

    updateTempoDamageMultiplier(player)

    local p = GetPtrHash(player)
    local multiplier = tempoDamageMultiplier[p] or 1.0
    laser:SetDamageMultiplier(laser:GetDamageMultiplier() * multiplier)
    laser:SetScale(laser:GetScale() * (multiplier ^ 0.5))
    debugstring = tostring(laser:GetDamageMultiplier())
end

function headphones.PostFireTechXLaser(laser)
    local player = GetSpawnerPlayer(laser)
    if not player or not player:HasCollectible(ITEM_ID_MOMS_HEADPHONES) then
        return
    end

    updateTempoDamageMultiplier(player)

    local p = GetPtrHash(player)
    local multiplier = tempoDamageMultiplier[p] or 1.0
    laser:SetDamageMultiplier(laser:GetDamageMultiplier() * multiplier)
    laser:SetScale(laser:GetScale() * (multiplier ^ 0.5))
    debugstring = tostring(laser:GetDamageMultiplier())
end

function headphones.PostFireKnife(knife)
    local player = GetSpawnerPlayer(knife)
    if not player or not player:HasCollectible(ITEM_ID_MOMS_HEADPHONES) then
        return
    end
    updateTempoDamageMultiplier(player)
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
        or weaponType == WeaponType.WEAPON_BONE
        or weaponType == WeaponType.WEAPON_BOMBS
        or weaponType == WeaponType.WEAPON_FETUS
    then
        if doFireDelay(player) then
            weapon:SetFireDelay(999)
        end

        local f = GetPtrHash(familiar)
        local fireDelayDamageMultiplier = doFireDelay(player) and (GetFireDelayDamageMultiplierFamiliar(familiar) ^ 2) or 1.0
        local multiplier = fireDelayDamageMultiplier * (tempoDamageMultiplier[p] or 1.0)
        lastTimeFired[f] = Game():GetFrameCount()

        params.TearDamage = params.TearDamage * multiplier
        params.TearScale = params.TearScale * (multiplier ^ 0.5)
        debugstring = tostring(params.TearDamage)
    elseif weaponType == WeaponType.WEAPON_KNIFE or weaponType == WeaponType.WEAPON_SPIRIT_SWORD then
        local multiplier = tempoDamageMultiplier[p] or 1.0
        params.TearDamage = params.TearDamage * multiplier
        params.TearScale = params.TearScale * (multiplier ^ 0.5)
        debugstring = tostring(params.TearDamage)
    end
end

function headphones.EvaluateTearHitParams(player, params, weaponType, _, _, source)
    if not player:HasCollectible(ITEM_ID_MOMS_HEADPHONES) then
        return
    end

    local p = GetPtrHash(player)
    if source and p ~= GetPtrHash(source) then
        local familiar = source:ToFamiliar()
        if familiar then
            evaluateTearHitParamsFamiliar(familiar, params, weaponType)
        end
        return
    end

    if weaponType == WeaponType.WEAPON_TEARS
        or weaponType == WeaponType.WEAPON_BONE
        or weaponType == WeaponType.WEAPON_BOMBS
        or weaponType == WeaponType.WEAPON_FETUS
    then
        if doFireDelay(player) then
            player.FireDelay = 999
        else
            updateTempoDamageMultiplier(player)
        end

        local fireDelayDamageMultiplier = doFireDelay(player) and (getFireDelayDamageMultiplier(player) ^ 2) or 1.0
        local multiplier = fireDelayDamageMultiplier * (tempoDamageMultiplier[p] or 1.0)
        lastTimeFired[p] = Game():GetFrameCount()
        if player:GetPlayerType() ~= PlayerType.PLAYER_LILITH_B then
            iWantToHaveABaby[p] = nil
        end

        params.TearDamage = params.TearDamage * multiplier
        params.TearScale = params.TearScale * (multiplier ^ 0.5)
        debugstring = tostring(params.TearDamage)
    elseif weaponType == WeaponType.WEAPON_KNIFE or weaponType == WeaponType.WEAPON_SPIRIT_SWORD then
        local multiplier = tempoDamageMultiplier[p] or 1.0
        params.TearDamage = params.TearDamage * multiplier
        params.TearScale = params.TearScale * (multiplier ^ 0.5)
        debugstring = tostring(params.TearDamage)
    end
end

function headphones.PreFamiliarUpdate(familiar)
    local player = familiar.Player
    if not player or not player:HasCollectible(ITEM_ID_MOMS_HEADPHONES) then
        return
    end

    local weapon = familiar:GetWeapon()
    if not weapon then
        return
    end

    local playerWeapon = player:GetWeapon(1)
    if not playerWeapon then
        return
    end

    if familiar.Variant == FamiliarVariant.UMBILICAL_BABY and player:GetPlayerType() == PlayerType.PLAYER_LILITH_B then
        if (playerWeapon:GetModifiers() & WeaponModifier.C_SECTION) ~= 0 then
            fetalUpdate(player, weapon)
        end
        return
    end
    
    if doFireDelay(player) and player.FireDelay < 0 and playerWeapon:GetWeaponType() ~= WeaponType.WEAPON_LASER then
        weapon:SetFireDelay(player.FireDelay)
    end

    if (playerWeapon:GetModifiers() & WeaponModifier.NEPTUNUS) ~= 0 then
        weapon:SetCharge(playerWeapon:GetCharge())
    elseif (playerWeapon:GetModifiers() & WeaponModifier.C_SECTION) ~= 0 then
        if playerWeapon:GetCharge() > weapon:GetCharge() then
            weapon:SetCharge(playerWeapon:GetCharge())
        end
    end
end

headphones.EvaluateCache = {}
headphones.EvaluateCache[CacheFlag.CACHE_FIREDELAY] = function(player)
    if not player:HasCollectible(ITEM_ID_MOMS_HEADPHONES) then
        return
    end
    local weapon = player:GetWeapon(1)
    if (weapon and (weapon:GetModifiers() & WeaponModifier.SOY_MILK) ~= 0)
        or (player:GetPlayerType() == PlayerType.PLAYER_LILITH_B and (not weapon or (weapon:GetModifiers() & WeaponModifier.C_SECTION) == 0))
    then
        player.MaxFireDelay = getRhythmicFireDelay(player.MaxFireDelay)
    end
end

function headphones.PostPlayerRender(player)
    for i = 0, 4 do
        local weapon = player:GetWeapon(i)
        Isaac.RenderText(tostring(weapon and weapon:GetWeaponType() .. ", " .. weapon:GetModifiers()), 10, 20 + i * 20, 1,
            1, 1, 1)
    end
    Isaac.RenderText(debugstring, 140, 20, 1, 1, 1, 1)
end

return headphones
