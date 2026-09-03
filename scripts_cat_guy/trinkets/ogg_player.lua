local ONE_THIRD = 1/3

local ICON_SPACE_WIDTH = 6
local ICON_SHUFFLE_WIDTH = 14
local ICON_LOCKED_WIDTH = 11

---@param n integer
local function s(n) return 2 ^ (n / 12) end
local NUMBER_PITCHES = {s(-1-5), s(0-5), s(2-5), s(4-5), s(5-5), s(7-5), s(9-5), s(11-5), s(12-5)}
NUMBER_PITCHES[0] = s(14-5)

local TIMER_MAX = 120
local TIMER_FUNKY = 90
local TIMER_FADED = 60
local SHUFFLE_LIST_MAX = 100

local timer = 0
CatGuyShuffle = false
local shuffleListIndex = 0
local shuffleList = {} ---@type Music[]
CatGuyLocked = false
local tutorial = 2
local typing = 0

local text = nil ---@type string?

local font = Font()
font:Load("font/terminus8.fnt")

local icon = Sprite()
icon:Load("gfx/ui/hud_oggplayericons.anm2", true)

---@param x number
local function funkyColorChannel(x)
    x = (x % 1) * 6
    return math.min(math.max(x,0), math.max(4-x,0), 1)
end

--[[ ---@param haystack string
---@param needle string
---@return integer?
local function findLast(haystack, needle)
    local i=haystack:match(".*"..needle.."()")
    if i==nil then return nil else return i-1 end
end ]]

local function getText()
    local id = MusicManager():GetCurrentMusicID()

    local str = tostring(id).." - "
    local artist
    local name

    local tempoDef = CatGuy.TempoManager.tempoDefs[id]
    if tempoDef then
        artist = tempoDef.artist
        name = tempoDef.name
    end

    if not artist or not name then
        local node = XMLData.GetEntryById(XMLNode.MUSIC, id) ---@type MusicXMLNode?
        if node then
            if not name then
                name = node.name
                --[[ local backslash = findLast(node.path, "/")
                if backslash then
                    name = string.sub(node.path, backslash + 1)
                else
                    name = node.path
                end ]]
            end
            
            if not artist then
                local mod = XMLData.GetModById(node.sourceid)
                if mod then
                    artist = mod.directory
                else
                    artist = node.sourceid
                end
            end
        end
    end

    return str..(artist or "???").." - "..(name or "???")
end

---@type TrinketCallbacks
local oggPlayer = {}
oggPlayer.Priority = {}
oggPlayer.Priority[CallbackPriority.IMPORTANT] = {}

oggPlayer.Priority[CallbackPriority.IMPORTANT].PreMusicPlay = function(music)
    if not CatGuy:IsValidMusic(music) then
        return
    end

    if Isaac.IsInGame() then
        if CatGuy.PlayerUtils.AnyPlayer(function(player) return player:HasTrinket(CatGuy.TrinketType.OGG_PLAYER) end) then
            if CatGuyLocked and music ~= MusicManager():GetCurrentMusicID() then
                return false
            end
            timer = TIMER_MAX
        end
    else
        if CatGuyLocked then
            CatGuyLocked = false
            return false
        end
    end
    text = nil
end

function oggPlayer.PostGameStarted()
    CatGuyLocked = false
    CatGuyShuffle = false
end

---@param pitch? number
local function chirp(pitch)
    SFXManager():Play(CatGuy.SoundEffect.OGG_PLAYER_CHIRP, 0.25, 2, false, pitch or 1.0)
end

local function playMusic(music)
    local realLocked = CatGuyLocked
    CatGuyLocked = false
    MusicManager():Play(music, 0)
    MusicManager():UpdateVolume()
    CatGuyLocked = realLocked
end

---@param rng RNG
local function nextSong(rng)
    local id = MusicManager():GetCurrentMusicID()
    if CatGuyShuffle then
        shuffleListIndex = (shuffleListIndex % SHUFFLE_LIST_MAX) + 1
        shuffleList[shuffleListIndex] = id
        id = CatGuy:RandomMusic(rng, function(newId) return newId ~= id end)
    else
        id = CatGuy:IncrementMusic(id, 1)
    end
    playMusic(id)
end

local function previousSong()
    local id
    if CatGuyShuffle then
        id = shuffleList[shuffleListIndex]
        if id then
            shuffleList[shuffleListIndex] = nil
            shuffleListIndex = (shuffleListIndex - 2) % SHUFFLE_LIST_MAX + 1
        else
            id = MusicManager():GetCurrentMusicID()
        end
    else
        id = CatGuy:IncrementMusic(MusicManager():GetCurrentMusicID(), -1)
    end
    playMusic(id)
end

function oggPlayer.PreAddTrinket_trinket()
    tutorial = 2
    timer = TIMER_MAX
end

function oggPlayer.PostPlayerUpdate(player)
    if not player:HasTrinket(CatGuy.TrinketType.OGG_PLAYER) or not Input.IsActionPressed(ButtonAction.ACTION_MAP, player.ControllerIndex) then
        return
    end

    if Input.IsActionTriggered(ButtonAction.ACTION_SHOOTRIGHT, player.ControllerIndex) then
        chirp()
        nextSong(player:GetTrinketRNG(CatGuy.TrinketType.OGG_PLAYER))
        timer = TIMER_MAX
        if tutorial == 2 then
            tutorial = 1
        end
    elseif Input.IsActionTriggered(ButtonAction.ACTION_SHOOTLEFT, player.ControllerIndex) then
        chirp()
        previousSong()
        timer = TIMER_MAX
        if tutorial == 2 then
            tutorial = 1
        end
    elseif Input.IsButtonTriggered(Keyboard.KEY_BACKSPACE, player.ControllerIndex)
    or Input.IsButtonTriggered(Keyboard.KEY_KP_DECIMAL, player.ControllerIndex) then
        chirp()
        typing = typing // 10
    else
        for i = 0, 9 do
            if Input.IsButtonTriggered(i + Keyboard.KEY_0, player.ControllerIndex)
            or Input.IsButtonTriggered(i + Keyboard.KEY_KP_0, player.ControllerIndex) then
                chirp(NUMBER_PITCHES[i])
                typing = typing * 10 + i
                while typing > CatGuy.MUSIC_MAX_ID do
                    typing = math.floor(typing // 100 * 10 + i)
                end
                break
            end
        end
    end

    if Input.IsActionTriggered(ButtonAction.ACTION_SHOOTDOWN, player.ControllerIndex) then
        chirp()
        CatGuyLocked = not CatGuyLocked
        if tutorial == 1 then
            tutorial = 0
        end
    end
    if Input.IsActionTriggered(ButtonAction.ACTION_SHOOTUP, player.ControllerIndex) then
        chirp()
        CatGuyShuffle = not CatGuyShuffle
        if tutorial == 1 then
            tutorial = 0
        end
    end
    if timer < TIMER_FUNKY then
        timer = TIMER_FUNKY
    end
end

function oggPlayer.PostUpdate()
    if timer > 0 then
        local state = Minimap.GetState()
        if timer > TIMER_FUNKY or state == MinimapState.NORMAL or (state == MinimapState.EXPANDED_OPAQUE and timer > TIMER_FADED) then
            timer = timer - 1
        end
    end

    if typing > 0 then
        if not CatGuy.PlayerUtils.AnyPlayer(function(player) return player:HasTrinket(CatGuy.TrinketType.OGG_PLAYER)
        and Input.IsActionPressed(ButtonAction.ACTION_MAP, player.ControllerIndex) end) then
            chirp()
            if XMLData.GetEntryById(XMLNode.MUSIC, typing) then
                playMusic(typing)
            end
            typing = 0
        end
    end
end

function oggPlayer.PostHUDRender()
    if timer <= 0 or not CatGuy.PlayerUtils.AnyPlayer(function(player) return player:HasTrinket(CatGuy.TrinketType.OGG_PLAYER) end) then
        timer = 0
        return
    end

    if not text then
        text = getText()
    end

    local r
    local g
    local b
    local a

    if timer > TIMER_FUNKY then
        r = 0.75
        g = 1.0
        b = 0.25
        a = 1.0
    else
        local x = Game():GetFrameCount() / 60
        r = funkyColorChannel(x + ONE_THIRD)
        g = funkyColorChannel(x)
        b = funkyColorChannel(x - ONE_THIRD)
        a = (timer / TIMER_FUNKY) ^ 2
    end

    local str = "Now playing: "..(typing > 0 and tostring(typing) or text)
    local width = font:GetStringWidth(str)
    local boxWidth = Isaac.GetScreenWidth()
    if CatGuyShuffle or CatGuyLocked then
        icon.Color = Color(r, g, b, a)
        local iconsWidth = ICON_SPACE_WIDTH
        boxWidth = boxWidth - ICON_SPACE_WIDTH
        if CatGuyShuffle then
            boxWidth = boxWidth - ICON_SHUFFLE_WIDTH
        end
        if CatGuyLocked then
            boxWidth = boxWidth - ICON_LOCKED_WIDTH
        end

        if CatGuyShuffle then
            icon:Play("Shuffle")
            icon:Render(Vector(math.min((width + boxWidth) / 2, boxWidth) + iconsWidth, Isaac.GetScreenHeight() - 40))
            iconsWidth = iconsWidth + ICON_SHUFFLE_WIDTH
        end
        if CatGuyLocked then
            icon:Play("Locked")
            icon:Render(Vector(math.min((width + boxWidth) / 2, boxWidth) + iconsWidth, Isaac.GetScreenHeight() - 40))
        end
    end

    --Isaac.DrawLine(Vector(0, Isaac.GetScreenHeight() - 40), Vector(boxWidth, Isaac.GetScreenHeight() - 40), KColor(r, g, b, a), KColor(r, g, b, a), 2)
    if width > boxWidth then
        font:DrawStringScaled(str, 0, Isaac.GetScreenHeight() - 40, boxWidth / width, 1.0, KColor(r, g, b, a), boxWidth, true)
    else
        font:DrawString(str, 0, Isaac.GetScreenHeight() - 40, KColor(r, g, b, a), boxWidth, true)
    end
    
    if CatGuy.Config:Get("OGGPlayerTutorial") and Game():GetRoom():GetAliveBossesCount() <= 0 then
        if tutorial == 2 then
            font:DrawStringScaled("Hold [Tab] and press [Left] / [Right] to seek!", 0, Isaac.GetScreenHeight() - 25, 0.8, 0.8, KColor(r * 0.8, g * 0.8, b * 0.8, a), boxWidth, true)
        elseif tutorial == 1 then
            font:DrawStringScaled("Hold [Tab] and press [Up] / [Down] to shuffle / lock!", 0, Isaac.GetScreenHeight() - 25, 0.8, 0.8, KColor(r * 0.8, g * 0.8, b * 0.8, a), boxWidth, true)
        end
    end
end

function oggPlayer.PreGameExit()
    if CatGuyLocked and not CatGuy.PlayerUtils.AnyPlayer(function(player) return player:HasTrinket(CatGuy.TrinketType.OGG_PLAYER) end) then
        CatGuyLocked = false
    end
end

return oggPlayer