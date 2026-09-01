---@class EIDCompat
local EIDCompat = {}

---@param eid any
---@param defs EIDDefs
function EIDCompat:Init(eid, defs)
    for playerType, playerEid in pairs(defs.players) do
        local playerConfig = EntityConfig.GetPlayer(playerType)
        if playerConfig then
            local coopSprite = playerConfig:GetModdedCoopMenuSprite()
            if coopSprite then
                local sprite = Sprite()
                local name = playerConfig:GetName()
                sprite:Load(coopSprite:GetFilename())
                sprite:Play(name, true)
                sprite:GetLayer(0):SetSize(Vector.One * 0.7)
                eid:addIcon("Player"..playerType, name, 0, 16, 16, 7.5, 5, sprite)
            end
        end
        if playerEid.description then
            for lang, desc in pairs(playerEid.description) do
                eid:addCharacterInfo(playerType, desc, playerEid.name and (playerEid.name[lang] or playerEid.name["en_us"]), lang)
            end
        end
        if playerEid.birthright then
            for lang, desc in pairs(playerEid.birthright) do
                eid:addBirthright(playerType, desc, playerEid.name and (playerEid.name[lang] or playerEid.name["en_us"]), lang)
            end
        end
    end

    for itemId, collectibleEid in pairs(defs.collectibles) do
        if collectibleEid.description then
            for lang, desc in pairs(collectibleEid.description) do
                eid:addCollectible(itemId, desc, nil, lang)
            end
        end

        if collectibleEid.modifier then
            eid:addDescriptionModifier("cat_guy_c"..itemId, function(descObj)
                if descObj.ObjType == EntityType.ENTITY_PICKUP
                and descObj.ObjVariant == PickupVariant.PICKUP_COLLECTIBLE
                and descObj.ObjSubType == itemId then
                    if collectibleEid.modifierCondition then
                        return collectibleEid.modifierCondition(eid, descObj, eid:ClosestPlayerTo(descObj.Entity))
                    else
                        return true
                    end
                end
                return false
            end, function(descObj)
                return collectibleEid.modifier(eid, descObj, eid:ClosestPlayerTo(descObj.Entity))
            end)
        end

        if collectibleEid.synergies then
            for itemId0, synergy in pairs(collectibleEid.synergies) do
                if type(itemId0) == "table" then
                    self:AddSynergy(eid, synergy, itemId, table.unpack(itemId0))
                else
                    self:AddSynergy(eid, synergy, itemId, itemId0)
                end
            end
        end

        if collectibleEid.trinketSynergies then
            for trinketType, synergy in pairs(collectibleEid.trinketSynergies) do
                self:AddCollectibleTrinketSynergy(eid, synergy, itemId, trinketType)
            end
        end

        if collectibleEid.duplicate then
            self:AddSelfSynergy(eid, collectibleEid.duplicate, itemId)
        end
    end

    for trinketType, trinketEid in pairs(defs.trinkets) do
        if trinketEid.description then
            for lang, desc in pairs(trinketEid.description) do
                eid:addTrinket(trinketType, desc, nil, lang)
            end
        end
        if trinketEid.modifier then
            eid:addDescriptionModifier("cat_guy_t"..trinketType, function(descObj)
                if descObj.ObjType == EntityType.ENTITY_PICKUP
                and descObj.ObjVariant == PickupVariant.PICKUP_TRINKET
                and descObj.ObjSubType == trinketType then
                    if trinketEid.modifierCondition then
                        return trinketEid.modifierCondition(eid, descObj, eid:ClosestPlayerTo(descObj.Entity))
                    else
                        return true
                    end
                end
                return false
            end, function(descObj)
                return trinketEid.modifier(eid, descObj, eid:ClosestPlayerTo(descObj.Entity))
            end)
        end
        if trinketEid.collectibleSynergies then
            for itemId, synergy in pairs(trinketEid.collectibleSynergies) do
                self:AddCollectibleTrinketSynergy(eid, synergy, itemId, trinketType)
            end
        end
    end
end

---@param eid any
---@param synergy langStrings
---@param ... CollectibleType
function EIDCompat:AddSynergy(eid, synergy, ...)
    for i, itemId in ipairs({...}) do
        local args = {...}
        table.remove(args, i)
        self:AddUnilateralSynergy(eid, synergy, itemId, args)
    end
end

---@param eid any
---@param synergy langStrings
---@param itemIdPedestal CollectibleType
---@param itemIdsOwned CollectibleType|CollectibleType[]
---@param pedestalOnly? boolean
function EIDCompat:AddUnilateralSynergy(eid, synergy, itemIdPedestal, itemIdsOwned, pedestalOnly)
    if type(itemIdsOwned) ~= "table" then
        itemIdsOwned =  {itemIdsOwned}
    end
    local name = "cat_guy_c"..itemIdPedestal
    local icon = "#"
    for _, itemId in ipairs(itemIdsOwned) do
        name = name.."_c"..itemId
        icon = icon.."{{Collectible"..itemId.."}} "
    end

    local desc = synergy["en_us"]
    desc = string.gsub(desc, "#", icon)
    desc = icon..desc
    eid:addDescriptionModifier(name, function(descObj) ---@param descObj DescObj
        if descObj.ObjType == EntityType.ENTITY_PICKUP
        and descObj.ObjVariant == PickupVariant.PICKUP_COLLECTIBLE
        and descObj.ObjSubType == itemIdPedestal
        and (not pedestalOnly or descObj.Entity) then
            local player = eid:ClosestPlayerTo(descObj.Entity) ---@type EntityPlayer
            for _, itemId in ipairs(itemIdsOwned) do
                if not player:HasCollectible(itemId) then
                    return false
                end
            end
            return true
        end
        return false
    end, function(descObj)
        eid:appendToDescription(descObj, desc)
        return descObj
    end)
end

---@param eid any
---@param synergy langStrings
---@param itemId CollectibleType
function EIDCompat:AddSelfSynergy(eid, synergy, itemId)
    local desc = synergy["en_us"]
    desc = string.gsub(desc, "#", "#{{Collectible"..itemId.."}} ")
    desc = "#{{Collectible"..itemId.."}} "..desc
    eid:addDescriptionModifier("cat_guy_c"..itemId.."_c"..itemId, function(descObj) ---@param descObj DescObj
        if descObj.ObjType == EntityType.ENTITY_PICKUP
        and descObj.ObjVariant == PickupVariant.PICKUP_COLLECTIBLE
        and descObj.ObjSubType == itemId then
            local player = eid:ClosestPlayerTo(descObj.Entity) ---@type EntityPlayer
            if (descObj.Entity and player:HasCollectible(itemId))
            or player:GetCollectibleNum(itemId) > 1 then
                return true
            end
        end
        return false
    end, function(descObj)
        eid:appendToDescription(descObj, desc)
        return descObj
    end)
    self:AddUnilateralSynergy(eid, synergy, itemId, CollectibleType.COLLECTIBLE_DIPLOPIA, true)
    self:AddUnilateralSynergy(eid, synergy, itemId, CollectibleType.COLLECTIBLE_CROOKED_PENNY, true)
end

---@param eid any
---@param synergy langStrings
---@param itemId CollectibleType
---@param trinketType TrinketType
function EIDCompat:AddCollectibleTrinketSynergy(eid, synergy, itemId, trinketType)
    eid:addDescriptionModifier("cat_guy_c"..itemId.."_t"..trinketType, function(descObj) ---@param descObj DescObj
        if descObj.ObjType == EntityType.ENTITY_PICKUP
        and descObj.ObjVariant == PickupVariant.PICKUP_COLLECTIBLE
        and descObj.ObjSubType == itemId then
            local player = eid:ClosestPlayerTo(descObj.Entity) ---@type EntityPlayer
            return player:HasTrinket(trinketType)
        end
        return false
    end, function(descObj)
        eid:appendToDescription(descObj, "#{{Trinket"..trinketType.."}} "..synergy["en_us"])
        return descObj
    end)
    eid:addDescriptionModifier("cat_guy_t"..trinketType.."_c"..itemId, function(descObj) ---@param descObj DescObj
        if descObj.ObjType == EntityType.ENTITY_PICKUP
        and descObj.ObjVariant == PickupVariant.PICKUP_TRINKET
        and descObj.ObjSubType == trinketType then
            local player = eid:ClosestPlayerTo(descObj.Entity) ---@type EntityPlayer
            return player:HasCollectible(itemId)
        end
        return false
    end, function(descObj)
        eid:appendToDescription(descObj, "#{{Collectible"..itemId.."}} "..synergy["en_us"])
        return descObj
    end)
end

return EIDCompat