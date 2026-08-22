---@class EIDDefs
local EIDDefs = {}

---@class DescObj
---@field ObjType EntityType
---@field ObjVariant integer
---@field ObjSubType integer
---@field fullItemString string
---@field Name string
---@field Description string
---@field Transformation any
---@field ModName? string
---@field Quality? integer
---@field Icon? any
---@field Entity? Entity
---@field ShowWhenUnidentified? boolean

---@alias langStrings table<string, string>

---@class PlayerEID
---@field name? langStrings
---@field description? langStrings
---@field birthright? langStrings

---@type table<PlayerType, PlayerEID>
EIDDefs.players = {
    [CatGuy.PlayerType.PERCY] = {
        name = {
            ["en_us"] = "Percy"
        },
        birthright = {
            ["en_us"] = "{{Collectible"..CatGuy.CollectibleType.MOMS_HEADPHONES.."}} Regain Mom's Headphones if lost"..
                "#{{Tears}} Tear Rate fixed at tempo of song"..
                "#↑ {{Damage}} If tear rate decreases, damage is increased to compensate for lost DPS"
        }
    },
    [CatGuy.PlayerType.PERCY_B] = {
        name = {
            ["en_us"] = "Tainted Percy"
        },
        description = {
            ["en_us"] = "Flight"..
                "#Spectral tears"..
                "#{{Warning}} No health"..
                "#{{Collectible"..CollectibleType.COLLECTIBLE_1UP.."}} Health ups grant lives"..
                "#{{Collectible"..CollectibleType.COLLECTIBLE_1UP.."}} +1 life per Red Heart container"..
                "#{{Warning}} Limit of 9 lives from health ups"
        },
        birthright = {
            ["en_us"] = "{{Collectible"..CollectibleType.COLLECTIBLE_1UP.."}} Lives gained from health ups are doubled"..
                "#{{Collectible"..CollectibleType.COLLECTIBLE_1UP.."}} +2 lives"
        }
    }
}

local MOMS_HEADPHONES_CONTINUOUS = {
    ["en_us"] = "Can fire continually"
}
local MOMS_HEADPHONES_CONTACT = {
    ["en_us"] = "Damage varies with beat"
}
local MOMS_HEADPHONES_RELEASE = {
    ["en_us"] = "Deals more damage if released onbeat"
}

---@class CollectibleEID
---@field description? langStrings
---@field synergies? table<CollectibleType|CollectibleType[], langStrings>
---@field modifierCondition? fun(eid: any, descObj: DescObj, player: EntityPlayer): boolean
---@field modifier? fun(eid: any, descObj: DescObj, player: EntityPlayer): DescObj

---@type table<CollectibleType, CollectibleEID>
EIDDefs.collectibles = {
    [CatGuy.CollectibleType.MOMS_HEADPHONES] = {
        description = {
            ["en_us"] = "#{{Tears}} Shoots 1 tear for each shooting input"..
                "#{{Tears}} Tear Rate set to closest one that matches tempo of song x2^N"..
                "#{{Damage}} Firing faster than fire rate deals significantly less damage"..
                "#↑ {{Damage}} Shots do x2.0 damage if shot perfectly onbeat"..
                "#↓ {{Damage}} Shots do x0.75 damage if shot perfectly offbeat"
        },
        modifier = function(eid, descObj, player)
            local pickup = descObj.Entity and descObj.Entity:ToPickup()
            if pickup and not pickup.Touched and not player:HasTrinket(CatGuy.TrinketType.TOY_METRONOME) then
                eid:appendToDescription(descObj, "#{{Trinket"..CatGuy.TrinketType.TOY_METRONOME.."}} Spawns a Toy Metronome")
            end
            return descObj
        end,
        synergies = {
            [CollectibleType.COLLECTIBLE_SOY_MILK] = MOMS_HEADPHONES_CONTINUOUS,
            [CollectibleType.COLLECTIBLE_MARKED] = MOMS_HEADPHONES_CONTINUOUS,
            [CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE] = MOMS_HEADPHONES_CONTACT,
            [ {CollectibleType.COLLECTIBLE_BRIMSTONE, CollectibleType.COLLECTIBLE_SOY_MILK} ] = MOMS_HEADPHONES_CONTACT,
            [CollectibleType.COLLECTIBLE_TECHNOLOGY_2] = MOMS_HEADPHONES_CONTACT,
            [CollectibleType.COLLECTIBLE_BRIMSTONE] = MOMS_HEADPHONES_RELEASE,
            [CollectibleType.COLLECTIBLE_TECH_X] = MOMS_HEADPHONES_RELEASE,
            [CollectibleType.COLLECTIBLE_CHOCOLATE_MILK] = MOMS_HEADPHONES_RELEASE,
            [CollectibleType.COLLECTIBLE_CURSED_EYE] = MOMS_HEADPHONES_RELEASE,
            [CollectibleType.COLLECTIBLE_MONSTROS_LUNG] = MOMS_HEADPHONES_RELEASE,
            [CollectibleType.COLLECTIBLE_C_SECTION] = {
                ["en_us"] = "First fetus takes 1 beat x2^N to fire depending on tear rate"
            },
            [CollectibleType.COLLECTIBLE_MOMS_KNIFE] = {
                ["en_us"] = "While held: Damage varies with beat"..
                    "#When fired: Deals more damage if released onbeat"
            },
            [CollectibleType.COLLECTIBLE_SPRINKLER] = {
                ["en_us"] = "No effect"
            }
        }
    },
    [CatGuy.CollectibleType.UNDERHANDS] = {
        description = {
            ["en_us"] = "#{{Collectible"..CollectibleType.COLLECTIBLE_1UP.."}} +3 lives on pickup"
        },
        modifier = function(eid, descObj, player)
            if player:GetHealthType() ~= HealthType.LOST then
                eid:appendToDescription(descObj, "#{{Warning}} Isaac respawns with 1 heart container on death")
            end
            eid:appendToDescription(descObj,
                "#{{Collectible"..CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS.."}} On use, grants a 3 second shield"..
                "#{{Timer}} for the room, dying revives in the room and grants a 3 second shield")
            return descObj
        end
    }
}

if CAT_GUY_REWORKED_TOOTH_AND_NAIL then
    EIDDefs.collectibles[CatGuy.CollectibleType.MOMS_HEADPHONES].synergies[CollectibleType.COLLECTIBLE_TOOTH_AND_NAIL] = {
        ["en_us"] = "Invincibility occurs every 1 or 2 measures"
    }
end

---@class TrinketEID
---@field description? langStrings
---@field modifierCondition? fun(eid: any, descObj: DescObj, player: EntityPlayer): boolean
---@field modifier? fun(eid: any, descObj: DescObj, player: EntityPlayer): DescObj

---@type table<TrinketType, TrinketEID>
EIDDefs.trinkets = {
    [CatGuy.TrinketType.TOY_METRONOME] = {
        description = {
            ["en_us"] = "#Ticks to the beat of the music"..
                "#{{Collectible"..CollectibleType.COLLECTIBLE_METRONOME.."}} On active use,tiny chance to also use Metronome"..
                "#{{Collectible"..CollectibleType.COLLECTIBLE_METRONOME.."}} Chance depends on charge time of used active"
        },
        modifier = function(eid, descObj, player)
            local added = {} ---@type table<CollectibleType, boolean>
            for i = 0, ActiveSlot.SLOT_POCKET2 do
                local itemId = player:GetActiveItem(i)
                if not added[itemId] and itemId ~= CollectibleType.COLLECTIBLE_NULL then
                    local charge
                    local item = Isaac.GetItemConfig():GetCollectible(itemId)
                    if item and item.ChargeType == ChargeType.NORMAL then
                        charge = item.MaxCharges
                    else
                        charge = 0
                    end
                    eid:appendToDescription(descObj, "#{{Collectible"..itemId.."}} "..(charge * 0.1).."% chance")
                    added[itemId] = true
                end
            end
            return descObj
        end
    }
}

return EIDDefs