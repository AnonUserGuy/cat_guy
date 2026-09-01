local ONE_THIRD = 1/3
---@diagnostic disable-next-line: undefined-field, assign-type-mismatch
local MUSIC_MAX_ID = tonumber(XMLData.GetEntryByOrder(XMLNode.MUSIC, XMLData.GetNumEntries(XMLNode.MUSIC)).id - 1) + 1 ---@type integer

local locked = false

local font = Font()
font:Load("font/terminus8.fnt")

local icon = Sprite()
icon:Load("gfx/ui/hud_oggplayericons.anm2", true)

---@param x number
local function funkyColorChannel(x)
    x = (x % 1) * 6
    return math.min(math.max(x,0), math.max(4-x,0), 1)
end

---@param music Music
---@param n integer
local function IncrementMusic(music, n)
    if n > 0 then
        while n > 0 do
            music = music + 1
            while not XMLData.GetEntryById(XMLNode.MUSIC, music) do
                if music > MUSIC_MAX_ID then
                    music = Music.MUSIC_BASEMENT
                else
                    music = music + 1
                end
            end
            n = n - 1
        end
    else
        while n < 0 do
            music = music - 1
            while not XMLData.GetEntryById(XMLNode.MUSIC, music) do
                if music < Music.MUSIC_BASEMENT then
                    music = MUSIC_MAX_ID
                else
                    music = music - 1
                end
            end
            n = n + 1
        end
    end
    return music
end

local function isLocked()
    return locked and CatGuy.PlayerUtils.AnyPlayer(function(player) return player:HasTrinket(CatGuy.TrinketType.OGG_PLAYER) end)
end

---@type TrinketCallbacks
local oggPlayer = {}
oggPlayer.Priority = {}
oggPlayer.Priority[CallbackPriority.IMPORTANT] = {}

oggPlayer.Priority[CallbackPriority.IMPORTANT].PreMusicPlay = function()
    if isLocked() then
        return false
    end
end

function oggPlayer.PostGameStarted()
    locked = false
end

local function playMusic(music)
    local realLocked = locked
    locked = false
    MusicManager():Play(music, 0)
    MusicManager():UpdateVolume()
    locked = realLocked
end

function oggPlayer.PostPlayerUpdate(player)
    if not player:HasTrinket(CatGuy.TrinketType.OGG_PLAYER) or not Input.IsActionPressed(ButtonAction.ACTION_MAP, player.ControllerIndex) then
        return
    end

    local id = MusicManager():GetCurrentMusicID()
    if Input.IsActionTriggered(ButtonAction.ACTION_SHOOTRIGHT, player.ControllerIndex) then
        playMusic(IncrementMusic(id, 1))
    elseif Input.IsActionTriggered(ButtonAction.ACTION_SHOOTLEFT, player.ControllerIndex) then
        playMusic(IncrementMusic(id, -1))
    elseif Input.IsActionTriggered(ButtonAction.ACTION_SHOOTDOWN, player.ControllerIndex) then
        locked = not locked
    end
end

function oggPlayer.PostHUDRender()
    if not CatGuy.PlayerUtils.AnyPlayer(function(player) return player:HasTrinket(CatGuy.TrinketType.OGG_PLAYER) end) then
        locked = false
        return
    end

    local id = MusicManager():GetCurrentMusicID()
    local node = XMLData.GetEntryById(XMLNode.MUSIC, id) ---@type MusicXMLNode?
    local str = "Now playing: "..tostring(id)
    if node then
        str = str.." - "..node.name
    else
        str = str.." - ???"
    end

    local x = Game():GetFrameCount() / 60
    local r = funkyColorChannel(x + ONE_THIRD)
    local g = funkyColorChannel(x)
    local b = funkyColorChannel(x - ONE_THIRD)
    icon.Color = Color(r, g, b, 1)

    font:DrawString(str, 0, Isaac.GetScreenHeight() - 40, KColor(r, g, b, 1), Isaac.GetScreenWidth(), true)
    if locked then
        icon:Play("Locked")
        icon:Render(Vector(Isaac.GetScreenWidth() / 2, Isaac.GetScreenHeight() - 20))
    end
end

return oggPlayer