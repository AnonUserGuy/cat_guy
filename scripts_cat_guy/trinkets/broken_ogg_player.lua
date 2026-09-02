---@type TrinketCallbacks
local oggPlayer = {}

local lastRNG = nil ---@type RNG?
local isRandomizing = false

---@param rng RNG
local function randomizeMusic(rng)
    isRandomizing = true
    if rng:GetSeed() == 0 then
        Isaac.DebugString("RNG was 0")
        rng = RNG()
    end
    local playerHasHeadphones = CatGuy.PlayerUtils.AnyPlayer(function(player) return player:HasCollectible(CatGuy.CollectibleType.MOMS_HEADPHONES) end)
    local id = CatGuy:RandomMusic(rng, function(newId, node) return node.loop ~= "false"
        and (not playerHasHeadphones or #CatGuy.TempoManager.tempoDefs <= 0 or CatGuy.TempoManager:GetValidTempoDef(newId)) end)
    MusicManager():Play(id, 0)
    MusicManager():UpdateVolume()
    isRandomizing = false
end

function oggPlayer.PreAddTrinket_trinket(player)
    randomizeMusic(player:GetTrinketRNG(CatGuy.TrinketType.BROKEN_OGG_PLAYER))
end

function oggPlayer.PreMusicPlay(music)
    if isRandomizing or music == MusicManager():GetCurrentMusicID() then
        return
    end

    if Isaac.IsInGame() then
        local player = CatGuy.PlayerUtils.AnyPlayer(function(player) return player:HasTrinket(CatGuy.TrinketType.BROKEN_OGG_PLAYER) and player end)
        if not player then
            lastRNG = nil
            return
        end
        lastRNG = player:GetTrinketRNG(CatGuy.TrinketType.BROKEN_OGG_PLAYER)

        randomizeMusic(lastRNG)
        return false
    else
        if lastRNG == nil then
            return
        end

        randomizeMusic(lastRNG)
        lastRNG = nil
        return false
    end
end

function oggPlayer.PlayerTakeDamage(player)
    if not player:HasTrinket(CatGuy.TrinketType.BROKEN_OGG_PLAYER) then
        return
    end
    randomizeMusic(player:GetTrinketRNG(CatGuy.TrinketType.BROKEN_OGG_PLAYER))
end

return oggPlayer