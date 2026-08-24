local ITEM_NAME_3_STRIKEOUT_LAYER_ID = 16

local livesFont = Font()
livesFont:Load("font/pftempestasevencondensed.fnt")

---@type PlayerCallbacks
local percyB = {}

function percyB.PostPlayerInit_player(player)
    player:SetPocketActiveItem(CatGuy.CollectibleType.UNDERHANDS, ActiveSlot.SLOT_POCKET, false)
    if CatGuy:GetConfig("PercyBHasMomsHeadphones") ~= false then
        player:AddCollectible(CatGuy.CollectibleType.MOMS_HEADPHONES)
    end
end

---@param player EntityPlayer
function percyB.PostPlayerUpdate(player)
    if player:GetPlayerType() == CatGuy.PlayerType.PERCY_B and not player:HasCollectible(CollectibleType.COLLECTIBLE_DEAD_DOVE, false, true) then
        if player:GetInnateCollectibleCount(CollectibleType.COLLECTIBLE_DEAD_DOVE, "percy_b") == 0 then
            player:AddInnateCollectible(CollectibleType.COLLECTIBLE_DEAD_DOVE, 1, "percy_b", 0, false)
        end
    else
        if player:GetInnateCollectibleCount(CollectibleType.COLLECTIBLE_DEAD_DOVE, "percy_b") ~= 0 then
            player:RemoveInnateCollectible(CollectibleType.COLLECTIBLE_DEAD_DOVE, 99, "percy_b")
        end
    end
end

function percyB.PostPlayerUpdate_player(player)
    if player:IsDead() then
        player:GetEffects():RemoveNullEffect(CatGuy.NullItemID.PERCY_ETERNAL_HEART, -1)
        if not player:GetEffects():HasNullEffect(NullItemID.ID_LOST_CURSE) then
            player:AddNullItemEffect(NullItemID.ID_LOST_CURSE)
        end
    end
end

function percyB.PostNewRoom()
    CatGuy.PlayerUtils.ForEachPlayer(function(player)
        if player:GetPlayerType() == CatGuy.PlayerType.PERCY_B then
            player:GetEffects():RemoveNullEffect(NullItemID.ID_LOST_CURSE, -1)
        end
    end)
end

---@param player EntityPlayer
local function checkEternalHearts(player)
    if player:GetEffects():HasNullEffect(CatGuy.NullItemID.PERCY_ETERNAL_HEART) then
        player:GetEffects():RemoveNullEffect(CatGuy.NullItemID.PERCY_ETERNAL_HEART, -1)
        ItemOverlay.Show(Giantbook.ETERNAL_HEART, 3, player)
        player:AddMaxHearts(2)
        return true
    else
        return false
    end
end

function percyB.PostNewLevel()
    CatGuy.PlayerUtils.ForEachPlayer(function(player)
        if player:GetPlayerType() == CatGuy.PlayerType.PERCY_B then
            checkEternalHearts(player)
        end
    end)
end

function percyB.PreTriggerPlayerDeath_player(player)
    player:GetEffects():RemoveNullEffect(NullItemID.ID_LOST_CURSE, -1)
end

function percyB.PostAddBirthright_player(_, _, _, _, _, player)
    player:AddMaxHearts(2)
end

function percyB.PrePlayerAddMaxHearts_player(player, amount)
    local util = CatGuy.PlayerUtils
    if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and amount > 0 then
        util.AddPercyLives(player, amount)
    else
        util.AddPercyLives(player, amount // 2)
    end
end

function percyB.PrePlayerAddEternalHearts_player(player, amount)
    for _ = 1, amount do
        if not checkEternalHearts(player) then
            player:GetEffects():AddNullEffect(CatGuy.NullItemID.PERCY_ETERNAL_HEART)
        end
    end
end

function percyB.PostPlayerRender_player(player)
    CatGuy.PlayerUtils.ApplyShader(player, "shaders/coloroffset_percy_b")
end

function percyB.PostPlayerHUDRenderHearts_player(_, sprite, position, _, player)
    if Game():GetLevel() and (Game():GetLevel():GetCurses() & LevelCurse.CURSE_OF_THE_UNKNOWN) ~= 0 then
        return
    end

    if player:GetEffects():HasNullEffect(CatGuy.NullItemID.PERCY_ETERNAL_HEART) then
        sprite:Play("WhiteHeartOverlay")
        sprite:Render(Vector(position.X - 8, position.Y))
    end

    local lives = player:GetExtraLives()
    if lives > 0 then
        local width = math.ceil(math.log(lives + 1, 10)) + 1
        local maxLives = lives - CatGuy.PlayerUtils.GetPercyLifeCount(player) + 9
        livesFont:DrawString("/"..maxLives, position.X + 5 * width, position.Y - 8, KColor(0.718, 0.718, 0.718,1))
    end
end

function percyB.PreRenderCharacterSelectPage_player(_, _, _, sprite)
    if not sprite then
        return
    end
    local strikeoutLayer = sprite:GetAllLayers()[ITEM_NAME_3_STRIKEOUT_LAYER_ID + 1]
    if not strikeoutLayer then
        return
    end
    CatGuy:CatGuyLoad(true)
    strikeoutLayer:SetVisible(not CatGuy:GetConfig("PercyBHasMomsHeadphones"))
end

return percyB