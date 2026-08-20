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
            eid:addDescriptionModifier("cat_guy_collectible_"..itemId, function(descObj)
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
                    for _, itemId1 in pairs(itemId0) do
                        self:AddSynergy(eid, itemId, itemId1, synergy)
                    end
                else
                    self:AddSynergy(eid, itemId, itemId0, synergy)
                end
            end
        end
    end

    for trinketType, trinketEid in pairs(defs.trinkets) do
        if trinketEid.description then
            for lang, desc in pairs(trinketEid.description) do
                eid:addTrinket(trinketType, desc, nil, lang)
            end
        end
        if trinketEid.modifier then
            eid:addDescriptionModifier("cat_guy_trinket_"..trinketType, function(descObj)
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
    end
end

---@param eid any
---@param itemId1 CollectibleType
---@param itemId2 CollectibleType
---@param synergy langStrings
function EIDCompat:AddSynergy(eid, itemId1, itemId2, synergy)
    self:AddUnilateralSynergy(eid, itemId1, itemId2, synergy)
    self:AddUnilateralSynergy(eid, itemId2, itemId1, synergy)
end

---@param eid any
---@param itemIdPedestal CollectibleType
---@param itemIdPossessed CollectibleType
---@param synergy langStrings
function EIDCompat:AddUnilateralSynergy(eid, itemIdPedestal, itemIdPossessed, synergy)
    eid:addDescriptionModifier("cat_guy_synergy_"..itemIdPedestal.."_"..itemIdPossessed, function(descObj) ---@param descObj DescObj
        if descObj.ObjType == EntityType.ENTITY_PICKUP
        and descObj.ObjVariant == PickupVariant.PICKUP_COLLECTIBLE 
        and descObj.ObjSubType == itemIdPedestal then
            local player = eid:ClosestPlayerTo(descObj.Entity) ---@type EntityPlayer
            return player:HasCollectible(itemIdPossessed)
        end
        return false
    end, function(descObj)
        eid:appendToDescription(descObj, "#{{Collectible"..itemIdPossessed.."}} "..synergy["en_us"])
        return descObj
    end)
end

return EIDCompat