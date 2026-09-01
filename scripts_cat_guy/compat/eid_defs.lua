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
EIDDefs.players = {}
EIDDefs.players[CatGuy.PlayerType.PERCY] = {
    name = {
        ["en_us"] = "Percy"
    },
    description = {
        ["en_us"] = "#↑ {{Speed}} 0.3 speed"..
            "#{{Speed}} x0.7 speed changes"
    },
    birthright = {
        ["en_us"] = "{{Collectible"..CatGuy.CollectibleType.MOMS_HEADPHONES.."}} Regain Mom's Headphones if lost"..
            "#{{Tears}} Tear Rate fixed at tempo of song"..
            "#↑ {{Damage}} If tear rate decreases, damage is increased to compensate for lost DPS"
    }
}
EIDDefs.players[CatGuy.PlayerType.PERCY_B] = {
    name = {
        ["en_us"] = "Tainted Percy"
    },
    description = {
        ["en_us"] = "#↑ {{Speed}} 0.3 speed"..
            "#{{Speed}} x0.7 speed changes"..
            "Flight"..
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




---@class CollectibleEID
---@field description? langStrings
---@field synergies? table<CollectibleType|CollectibleType[], langStrings>
---@field trinketSynergies? table<TrinketType, langStrings>
---@field duplicate? langStrings
---@field modifierCondition? fun(eid: any, descObj: DescObj, player: EntityPlayer): boolean
---@field modifier? fun(eid: any, descObj: DescObj, player: EntityPlayer): DescObj

---@type table<CollectibleType, CollectibleEID>
EIDDefs.collectibles = {}

local MOMS_HEADPHONES_CONTINUOUS = {
    ["en_us"] = "Can fire continually"
}
local MOMS_HEADPHONES_CONTACT = {
    ["en_us"] = "Damage varies with beat"
}
local MOMS_HEADPHONES_RELEASE = {
    ["en_us"] = "Deals more damage if released onbeat"
}
local MOMS_HEADPHONES_TECH_FAMILIAR = {
    ["en_us"] = "No effect on familiars"
}
EIDDefs.collectibles[CatGuy.CollectibleType.MOMS_HEADPHONES] = {
    description = {
        ["en_us"] = "#{{Tears}} Shoots 1 tear for each shooting input"..
            "#↑ {{Damage}} x2.0 damage if shot perfectly onbeat"..
            "#↓ {{Damage}} x0.75 damage if shot perfectly offbeat"..
            "#{{Tears}} Tear Rate set to closest one that matches tempo of song x2^N"..
            "#{{Damage}} Firing faster than fire rate deals significantly less damage"
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
        [CollectibleType.COLLECTIBLE_BRIMSTONE] = MOMS_HEADPHONES_RELEASE,
        [CollectibleType.COLLECTIBLE_TECH_X] = MOMS_HEADPHONES_RELEASE,
        [CollectibleType.COLLECTIBLE_CHOCOLATE_MILK] = MOMS_HEADPHONES_RELEASE,
        [CollectibleType.COLLECTIBLE_CURSED_EYE] = MOMS_HEADPHONES_RELEASE,
        [CollectibleType.COLLECTIBLE_MONSTROS_LUNG] = MOMS_HEADPHONES_RELEASE,
        [CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE] = MOMS_HEADPHONES_CONTACT,
        [ {CollectibleType.COLLECTIBLE_BRIMSTONE, CollectibleType.COLLECTIBLE_SOY_MILK} ] = MOMS_HEADPHONES_CONTACT,
        [CollectibleType.COLLECTIBLE_TECHNOLOGY_2] = MOMS_HEADPHONES_CONTACT,
        [CollectibleType.COLLECTIBLE_TECH_5] = {
            ["en_us"] = "Affects tear delay damage reduction"
        },
        [CollectibleType.COLLECTIBLE_C_SECTION] = {
            ["en_us"] = "First fetus takes 1 beat x2^N to fire depending on tear rate"
        },
        [CollectibleType.COLLECTIBLE_MOMS_KNIFE] = {
            ["en_us"] = "While held: Damage varies with beat"..
                "#When fired: Deals more damage if released onbeat"
        },
        [CollectibleType.COLLECTIBLE_SPRINKLER] = {
            ["en_us"] = "No effect"
        },
        [CollectibleType.COLLECTIBLE_TOOTH_AND_NAIL] = {
            ["en_us"] = "Invincibility occurs every 1 or 2 measures"
        }
    }
}
local FAMILIAR_ITEMS = {
    CollectibleType.COLLECTIBLE_INCUBUS,
    CollectibleType.COLLECTIBLE_TWISTED_PAIR,
    CollectibleType.COLLECTIBLE_SUMPTORIUM,
    CollectibleType.COLLECTIBLE_GELLO
}
local TECHNOLOGY_ITEMS = {
    CollectibleType.COLLECTIBLE_TECHNOLOGY,
    CollectibleType.COLLECTIBLE_TECHNOLOGY_2,
    CollectibleType.COLLECTIBLE_TECH_5
}
for _, tech in ipairs(TECHNOLOGY_ITEMS) do
    for _, familiar in ipairs(FAMILIAR_ITEMS) do
        EIDDefs.collectibles[CatGuy.CollectibleType.MOMS_HEADPHONES].synergies[{tech, familiar}] = MOMS_HEADPHONES_TECH_FAMILIAR
    end
end

local UNDERHANDS_CHANGE_REVIVE = {
    ["en_us"] = "In-room revives don't cause character changes"
}
EIDDefs.collectibles[CatGuy.CollectibleType.UNDERHANDS] = {
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
    end,
    synergies = {
        [CollectibleType.COLLECTIBLE_LAZARUS_RAGS] = UNDERHANDS_CHANGE_REVIVE,
        [CollectibleType.COLLECTIBLE_ANKH] = UNDERHANDS_CHANGE_REVIVE,
        [CollectibleType.COLLECTIBLE_JUDAS_SHADOW] = UNDERHANDS_CHANGE_REVIVE,
        [CollectibleType.COLLECTIBLE_GUPPYS_COLLAR] = {
            ["en_us"] = "50% chance to revive in room"..
                "#25% chance to revive out of room"
        }
    },
    trinketSynergies = {
        [TrinketType.TRINKET_MISSING_POSTER] = UNDERHANDS_CHANGE_REVIVE,
        [TrinketType.TRINKET_BROKEN_ANKH] = {
            ["en_us"] = "22% chance to revive in room without character change"..
                "#17% chance to revive out of room as ??? (Blue Baby)"
        }
    }
}

local TRIPLET_SWING_DUPLICATE = {
    ["en_us"] = "Isaac fires 1 more tear#No additional stat decrease"
}
EIDDefs.collectibles[CatGuy.CollectibleType.TRIPLET_SWING] = {
    description = {
        ["en_us"] = "#{{Collectible"..CollectibleType.COLLECTIBLE_INNER_EYE.."}} Grant's copy of Inner Eye:"..
            "#{{Collectible"..CollectibleType.COLLECTIBLE_INNER_EYE.."}} {{Tears}} x0.51 Fire rate multiplier"..
            "#{{Collectible"..CollectibleType.COLLECTIBLE_INNER_EYE.."}} Isaac shoots 3 tears at once"..
            "#{{Collectible"..CollectibleType.COLLECTIBLE_BROKEN_WATCH.."}} Getting hit makes music \"swung\" for 8 seconds"..
            "#{{Collectible"..CollectibleType.COLLECTIBLE_BROKEN_WATCH.."}} Swung music makes game speed rapidly alternate between fast and slow"
    },
    synergies = {
        [CollectibleType.COLLECTIBLE_INNER_EYE] = TRIPLET_SWING_DUPLICATE
    },
    duplicate = TRIPLET_SWING_DUPLICATE,
}

EIDDefs.collectibles[CatGuy.CollectibleType.FORTE] = {
    description = {
        ["en_us"] = "# For every extra music layer playing:"..
            "#↑ {{Speed}} +0.3 Speed#↑ {{Tears}} +0.2 Tears#↑ {{Damage}} +0.3 Damage#↑ {{Range}} +1.5 Range"..
            "#Being in a boss fight counts for 1 layer"
    },
    duplicate = {
        ["en_us"] = "Each additional copy counts for 1 layer"
    }
}



---@class TrinketEID
---@field description? langStrings
---@field collectibleSynergies? table<CollectibleType, langStrings>
---@field modifierCondition? fun(eid: any, descObj: DescObj, player: EntityPlayer): boolean
---@field modifier? fun(eid: any, descObj: DescObj, player: EntityPlayer): DescObj

---@type table<TrinketType, TrinketEID>
EIDDefs.trinkets = {}
EIDDefs.trinkets[CatGuy.TrinketType.TOY_METRONOME] = {
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
EIDDefs.trinkets[CatGuy.TrinketType.BROKEN_HEADPHONES] = {
    description = {
        ["en_us"] = "#Every song is randomized before played"..
            "#Getting hit plays a new song"
    },
    modifier = function(eid, descObj, player)
        if player:HasCollectible(CatGuy.CollectibleType.MOMS_HEADPHONES) then
            eid:appendToDescription(descObj, "#{{Collectible"..CatGuy.CollectibleType.MOMS_HEADPHONES.."}} Only music that works with Mom's Headphones")
        end
        return descObj
    end
}

return EIDDefs