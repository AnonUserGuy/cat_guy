
local DAMAGE_UP = 0.3
local TEARS_UP = 0.2
local RANGE_UP = 1.5
local SPEED_UP = 0.3

local BOSS_BONUS_ROOM = {
    [RoomType.ROOM_BOSS] = true,
    [RoomType.ROOM_ANGEL] = true,
    [RoomType.ROOM_MINIBOSS] = true,
    [RoomType.ROOM_CHALLENGE] = true,
    [RoomType.ROOM_BOSSRUSH] = true
}

local BOSS_BONUS_BACKDROP = {
    [BackdropType.DUNGEON_ROTGUT] = true,
    [BackdropType.DOGMA] = true,
    [BackdropType.DUNGEON_BEAST] = true
}

local lastBonus = 0

---@type CollectibleCallbacks
local forte = {}

---@param music Music
local function getLayerCount(music)
    local node = XMLData.GetEntryById(XMLNode.MUSIC, music) ---@type MusicXMLNode
    if not node then
        return -1
    end
    if not node.layer then
        return 0
    end
    if type(node.layer) == "table" then
        return #node.layer
    end
    return 1
end

local function getActiveLayerCount()
    local res = 0
    local layerCount = getLayerCount(MusicManager():GetCurrentMusicID())
    for i = 0, layerCount - 1 do
        if MusicManager():IsLayerEnabled(i) then
            res = res + 1
        end
    end
    return res
end

local function hasBossBonus()
    local room = Game():GetRoom()
    if not room then
        return false
    end
    if room:GetAliveBossesCount() > 0 then
        local type = room:GetType()
        if BOSS_BONUS_ROOM[type] then
            return true
        end
        local backdrop = room:GetBackdropType()
        if BOSS_BONUS_BACKDROP[backdrop] then
            return true
        end
    end

    return false
end

local function getBonus()
    local num = getActiveLayerCount()
    if hasBossBonus() then
        num = num + 1
    end
    return num
end

---@param player EntityPlayer
local function getPlayerBonus(player)
    return lastBonus + player:GetCollectibleNum(CatGuy.CollectibleType.FORTE) - 1
end

---@param player EntityPlayer
local function evaluateItems(player)
    if getPlayerBonus(player) > 0 then
        player:AddNullCostume(CatGuy.NullItemID.FORTE_SCARED)
    else
        player:TryRemoveNullCostume(CatGuy.NullItemID.FORTE_SCARED)
    end
    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE
        | CacheFlag.CACHE_FIREDELAY
        | CacheFlag.CACHE_RANGE
        | CacheFlag.CACHE_SPEED)
    player:EvaluateItems()
end
forte.PostTriggerCollectibleAdded_item = evaluateItems
forte.PostTriggerCollectibleRemoved_item = evaluateItems


function forte.PostUpdate()
    local bonus = getBonus()
    if lastBonus ~= bonus then
        lastBonus = bonus
        CatGuy.PlayerUtils.ForEachPlayer(function(player)
            if player:HasCollectible(CatGuy.CollectibleType.FORTE) then
                evaluateItems(player)
            end
        end)
    end
end

forte.EvaluateStat = {}
forte.EvaluateStat[EvaluateStatStage.DAMAGE_UP] = function(player, _, value)
    if player:HasCollectible(CatGuy.CollectibleType.FORTE) then
        return value + DAMAGE_UP * getPlayerBonus(player)
    end
end
forte.EvaluateStat[EvaluateStatStage.TEARS_UP] = function(player, _, value)
    if player:HasCollectible(CatGuy.CollectibleType.FORTE) then
        return value + TEARS_UP * getPlayerBonus(player)
    end
end
forte.EvaluateCache = {}
forte.EvaluateCache[CacheFlag.CACHE_RANGE] = function(player)
    if player:HasCollectible(CatGuy.CollectibleType.FORTE) then
        player.TearRange = player.TearRange + RANGE_UP * getPlayerBonus(player)
    end
end
forte.EvaluateCache[CacheFlag.CACHE_SPEED] = function(player)
    if player:HasCollectible(CatGuy.CollectibleType.FORTE) then
        player.MoveSpeed = player.MoveSpeed + SPEED_UP * getPlayerBonus(player)
    end
end

return forte