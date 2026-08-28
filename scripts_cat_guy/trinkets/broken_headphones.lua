---@type TrinketCallbacks
local headphones = {}

local MUSIC_XML_COUNT = XMLData.GetNumEntries(XMLNode.MUSIC)

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
    while true do
        local node = XMLData.GetEntryByOrder(XMLNode.MUSIC, rng:RandomInt(MUSIC_XML_COUNT)) ---@type MusicXMLNode?
        if node and node.loop ~= "false" then
            local id = tonumber(node.id)
            if id and (not playerHasHeadphones or #CatGuy.TempoManager.tempoDefs <= 0 or CatGuy.TempoManager.tempoDefs[tonumber(node.id)]) then
                MusicManager():Play(id, 0)
                MusicManager():UpdateVolume()
                break
            end
        end
    end
    isRandomizing = false
end

function headphones.PreAddTrinket_trinket(player)
    randomizeMusic(player:GetTrinketRNG(CatGuy.TrinketType.BROKEN_HEADPHONES))
end

function headphones.PreMusicPlay()
    if isRandomizing then
        return
    end

    if Isaac.IsInGame() then
        local player = CatGuy.PlayerUtils.AnyPlayer(function(player) return player:HasTrinket(CatGuy.TrinketType.BROKEN_HEADPHONES) and player end) ---@type EntityPlayer?
        if not player then
            lastRNG = nil
            return
        end
        lastRNG = player:GetTrinketRNG(CatGuy.TrinketType.BROKEN_HEADPHONES)

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

function headphones.PlayerTakeDamage(player)
    if not player:HasTrinket(CatGuy.TrinketType.BROKEN_HEADPHONES) then
        return
    end
    randomizeMusic(player:GetTrinketRNG(CatGuy.TrinketType.BROKEN_HEADPHONES))
end

return headphones