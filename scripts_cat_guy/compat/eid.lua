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

        if collectibleEid.synergies then
            for itemId0, synergy in pairs(collectibleEid.synergies) do
                for lang, desc in pairs(synergy) do
                    eid:addSynergyCondition(itemId, itemId0, desc, nil, lang)
                end
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

return EIDCompat