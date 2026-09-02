-- If you're having issues with Steam overriding changes made here,
-- you can make a copy of this file named "cat_guy_config_user.lua"
-- and put configs there instead.

-- To reload without restarting the game, (with debug console enabled)
-- press ` to open debug console and enter "luamod cat_guy".

---@type CatGuyConfig
local catGuyConfig = {

    ------------ GAMEPLAY ------------ 

    -- Whether or not Mom's Headphones make a metronome play, even without the Toy Metronome trinket.
    -- In case you need the metronome, but don't want to waste a trinket slot on the Toy Metronome.
    -- true  = Enabled.
    -- false = Disabled.
    -- Default: false
    MomsHeadphonesHaveMetronome = false,

    -- Whether or not Tainted Percy starts with Mom's Headphones. In case you want to try his gimmick
    -- without also having to play with regular Percy's gimmick.
    -- true  = Enabled.
    -- false = Disabled.
    -- Default: true
    PercyBHasMomsHeadphones = true,

    -- Whether or not to display OGG Player controls whenever it is picked up.
    -- true  = Enabled.
    -- false = Disabled.
    -- Default: true
    OGGPlayerTutorial = true,

    -- Keybind for restarting the music, in case of desync.
    -- Key names can be found here: https://wofsauge.github.io/IsaacDocs/rep/enums/Keyboard.html
    -- Default: Keyboard.KEY_SLASH
    ControlsRestartMusic = Keyboard.KEY_SLASH,

    -- Controller button for restarting the music, in case of desync.
    -- Default: -1
    ControlsRestartMusicController = -1,


    --------- INPUT LATENCY --------- 

    -- KEYBOARD --

    -- Offset of inputs to accommodate for audio/controls latency, in milliseconds.
    -- Default: 0
    OffsetTrigger = 0,

    -- Offset of released inputs to accommodate for audio/controls latency, in milliseconds.
    -- Set to "nil" to make it match OffsetTrigger.
    -- Default: nil
    OffsetRelease = nil,

    -- Offset of inputs *for specifically Mom's Headphones + C Section* to accommodate for audio/controls latency, in milliseconds.
    -- Set to "nil" to make it match OffsetTrigger.
    -- Default: 95 
    -- (this is based on my own latency. You'll likely want to change this.)
    OffsetCSection = 95,


    -- CONTROLLER --

    -- Offset of inputs to accommodate for audio/controls latency, in milliseconds.
    -- Set to "nil" to make it match OffsetTrigger (keyboard).
    -- Default: nil
    OffsetTriggerController = nil,

    -- Offset of released inputs to accommodate for audio/controls latency, in milliseconds.
    -- Set to "nil" to make it match OffsetTriggerController.
    -- Default: nil
    OffsetReleaseController = nil,

    -- Offset of inputs *for specifically Mom's Headphones + C Section* to accommodate for audio/controls latency, in milliseconds.
    -- Set to "nil" to make it match OffsetTriggerController.
    -- Default: 120
    -- (this is based on my own latency. You'll likely want to change this.)
    OffsetCSectionController = 120,


    -- LATENCY TESTING --

    -- Keybind for entering/exiting "latency testing mode", where you can determine appropriate latency settings.
    -- Key names can be found here: https://wofsauge.github.io/IsaacDocs/rep/enums/Keyboard.html
    -- Default: Keyboard.KEY_BACKSLASH
    ControlsLatencyTestEnter = Keyboard.KEY_BACKSLASH,

    -- Controller button for entering/exiting "latency testing mode", where you can determine appropriate latency settings.
    -- Default: -1
    ControlsLatencyTestEnterController = -1,

    -- Keybind used to test latency.
    -- Key names can be found here: https://wofsauge.github.io/IsaacDocs/rep/enums/Keyboard.html
    -- Default: Keyboard.KEY_B
    ControlsLatencyTest = Keyboard.KEY_B,

    -- Controller button used to test latency.
    -- Default: -1
    ControlsLatencyTestController = -1,



    ----- SONG-SPECIFIC SETTINGS -----

    -- Enable rhythm-related mod features for individual songs in the game. Intended for if an
    -- individual song is replaced by another mod that doesn't provide compatibility with this mod. 
    -- Can add additional vanilla songs using their internal IDs, or modded songs using their names.
    -- true  = Enabled for song.
    -- false = Disabled for song. (treated as if no music is playing.)
    TempoEnabled = {
        [Music.MUSIC_BASEMENT]            = true,
        [Music.MUSIC_CAVES]               = true,
        [Music.MUSIC_DEPTHS]              = true,
        [Music.MUSIC_CELLAR]              = true,
        [Music.MUSIC_CATACOMBS]           = true,
        [Music.MUSIC_NECROPOLIS]          = true,
        [Music.MUSIC_WOMB_UTERO]          = true, -- Just Womb floor music, not Utero
        [Music.MUSIC_GAME_OVER]           = true,
        [Music.MUSIC_BOSS]                = true,
        [Music.MUSIC_CATHEDRAL]           = true,
        [Music.MUSIC_SHEOL]               = true,
        [Music.MUSIC_DARK_ROOM]           = true,
        [Music.MUSIC_CHEST]               = true,
        [Music.MUSIC_BURNING_BASEMENT]    = true,
        [Music.MUSIC_FLOODED_CAVES]       = true,
        [Music.MUSIC_DANK_DEPTHS]         = true,
        [Music.MUSIC_SCARRED_WOMB]        = true,
        [Music.MUSIC_BLUE_WOMB]           = true, -- ??? floor music
        [Music.MUSIC_UTERO]               = true,
        [Music.MUSIC_MOM_BOSS]            = true,
        [Music.MUSIC_MOMS_HEART_BOSS]     = true,
        [Music.MUSIC_ISAAC_BOSS]          = true,
        [Music.MUSIC_SATAN_BOSS]          = true,
        [Music.MUSIC_DARKROOM_BOSS]       = true, -- The Lamb fight music
        [Music.MUSIC_BLUEBABY_BOSS]       = true,
        [Music.MUSIC_BOSS2]               = true,
        [Music.MUSIC_HUSH_BOSS]           = true,
        [Music.MUSIC_ULTRAGREED_BOSS]     = true,
        [Music.MUSIC_LIBRARY_ROOM]        = true,
        [Music.MUSIC_SECRET_ROOM]         = true, -- Regular Secret Room music
        [Music.MUSIC_SECRET_ROOM2]        = true, -- Super Secret Room music
        [Music.MUSIC_ANGEL_ROOM]          = true,
        [Music.MUSIC_SHOP_ROOM]           = true,
        [Music.MUSIC_ARCADE_ROOM]         = true,
        [Music.MUSIC_BOSS_OVER]           = true, -- Calm music after boss fights
        [Music.MUSIC_CHALLENGE_FIGHT]     = true, -- Miniboss/Challenge room music
        [Music.MUSIC_BOSS_RUSH]           = true,
        [Music.MUSIC_BOSS3]               = true,
        [Music.MUSIC_MOTHER_BOSS]         = true,
        [Music.MUSIC_DOGMA_BOSS]          = true,
        [Music.MUSIC_BEAST_BOSS]          = true,
        [Music.MUSIC_PLANETARIUM]         = true,
        [Music.MUSIC_SECRET_ROOM_ALT_ALT] = true, -- Ultra Secret Room music
        [Music.MUSIC_BOSS_OVER_TWISTED]   = true,
        [Music.MUSIC_VOID]                = true,
        [Music.MUSIC_VOID_BOSS]           = true, -- Delirium fight music
        [Music.MUSIC_DOWNPOUR]            = true,
        [Music.MUSIC_MINES]               = true,
        [Music.MUSIC_MAUSOLEUM]           = true,
        [Music.MUSIC_CORPSE]              = true,
        [Music.MUSIC_DROSS]               = true,
        [Music.MUSIC_ASHPIT]              = true,
        [Music.MUSIC_GEHENNA]             = true,
        [Music.MUSIC_ISAACS_HOUSE]        = true,
        [Music.MUSIC_DOWNPOUR_REVERSE]    = true,
        [Music.MUSIC_DROSS_REVERSE]       = true,
        [Music.MUSIC_MINESHAFT_ESCAPE]    = true,
        [Music.MUSIC_REVERSE_GENESIS]     = true, -- Ascent Sequence Music
    }
}
return catGuyConfig