---@type table<string, Music>
local newMusic = {
	CHALLENGE_FIGHT_FULL    = Isaac.GetMusicIdByName("Ambush (Full)") or -1,
    MOM_BOSS_TRUE           = Isaac.GetMusicIdByName("True Mom") or -1,
	MOM_BOSS                = Isaac.GetMusicIdByName("Mom") or -1,
	MOMS_HEART_BOSS_TRUE    = Isaac.GetMusicIdByName("True Mom's Heart") or -1,
	MOMS_HEART_BOSS         = Isaac.GetMusicIdByName("Mom's Heart") or -1,
	ISAAC_BOSS_TRUE         = Isaac.GetMusicIdByName("True Isaac") or -1,
	ISAAC_BOSS              = Isaac.GetMusicIdByName("Isaac") or -1,
	MOTHER_BOSS_TRUE        = Isaac.GetMusicIdByName("True Mother") or -1,
	MOTHER_BOSS             = Isaac.GetMusicIdByName("Mother") or -1,
	BLUEBABY_BOSS_TRUE      = Isaac.GetMusicIdByName("True Blue Baby") or -1,
	BLUEBABY_BOSS           = Isaac.GetMusicIdByName("Blue Baby") or -1,
	DARKROOM_BOSS_TRUE      = Isaac.GetMusicIdByName("True Lamb") or -1,
	DARKROOM_BOSS           = Isaac.GetMusicIdByName("Lamb") or -1,
	VOID_BOSS_TRUE          = Isaac.GetMusicIdByName("True Delirium") or -1,
	VOID_BOSS               = Isaac.GetMusicIdByName("Delirium") or -1,
	ULTRAGREED_BOSS_TRUE    = Isaac.GetMusicIdByName("True Ultra Greed") or -1,
	ULTRAGREED_BOSS         = Isaac.GetMusicIdByName("Ultra Greed") or -1,
	MEGASATAN_BOSS          = Isaac.GetMusicIdByName("Mega Satan") or -1,
	SATAN_BOSS              = Isaac.GetMusicIdByName("Satan") or -1,
	ARCADE_ALT              = Isaac.GetMusicIdByName("Arcade Alt") or -1,
	SHOP_ALT                = Isaac.GetMusicIdByName("Shop Alt") or -1,
	VOID_0                  = Isaac.GetMusicIdByName("The Void 0") or -1,
	VOID_1                  = Isaac.GetMusicIdByName("The Void 1") or -1,
	VOID_2                  = Isaac.GetMusicIdByName("The Void 2") or -1,
	VOID_3                  = Isaac.GetMusicIdByName("The Void 3") or -1,
	VOID_4                  = Isaac.GetMusicIdByName("The Void 4") or -1,
	VOID_5                  = Isaac.GetMusicIdByName("The Void 5") or -1,
	VOID_6                  = Isaac.GetMusicIdByName("The Void 6") or -1,
	VOID_7                  = Isaac.GetMusicIdByName("The Void 7") or -1,
	VOID_BOSS_1             = Isaac.GetMusicIdByName("The Void Boss 1") or -1,
	VOID_BOSS_2             = Isaac.GetMusicIdByName("The Void Boss 2") or -1,
	VOID_BOSS_3             = Isaac.GetMusicIdByName("The Void Boss 3") or -1,
	VOID_BOSS_4             = Isaac.GetMusicIdByName("The Void Boss 4") or -1,
	VOID_BOSS_5             = Isaac.GetMusicIdByName("The Void Boss 5") or -1,
	BLANK                   = Isaac.GetMusicIdByName("blank") or -1, -- my favorite song
	BOSS_MMC                = Isaac.GetMusicIdByName("Boss MMC") or -1,
	UTERO_MMC               = Isaac.GetMusicIdByName("Utero MMC") or -1,
	SATAN_BOSS_MMC          = Isaac.GetMusicIdByName("Boss (Sheol - Satan) MMC") or -1,
	BOSS3_MMC               = Isaac.GetMusicIdByName("Boss (alternate alternate) MMC") or -1,
	JINGLE_MOTHER_OVER_MMC  = Isaac.GetMusicIdByName("Boss Mother Death (jingle) MMC") or -1,
	PLANETARIUM_MMC         = Isaac.GetMusicIdByName("Planetarium MMC") or -1,
	DOWNPOUR_MMC            = Isaac.GetMusicIdByName("Downpour MMC") or -1,
	MINES_MMC               = Isaac.GetMusicIdByName("Mines MMC") or -1,
	MAUSOLEUM_MMC           = Isaac.GetMusicIdByName("Mausoleum MMC") or -1,
	CORPSE_MMC              = Isaac.GetMusicIdByName("Corpse MMC") or -1,
	DROSS_MMC               = Isaac.GetMusicIdByName("Dross MMC") or -1,
	ASHPIT_MMC              = Isaac.GetMusicIdByName("Ashpit MMC") or -1,
	GEHENNA_MMC             = Isaac.GetMusicIdByName("Gehenna MMC") or -1,
	DROSS_OG                = Isaac.GetMusicIdByName("Night Soil") or -1,
	DROSS_REVERSE_OG        = Isaac.GetMusicIdByName("Night Soil (reversed)") or -1,
	ASHPIT_OG               = Isaac.GetMusicIdByName("Absentia") or -1,
	GEHENNA_OG              = Isaac.GetMusicIdByName("Morning Star") or -1,
}

---@type table<Music, TempoDef>
local tempoDefs = {
    [Music.MUSIC_BASEMENT]                      = {bpm = 120, offset=192},
    [Music.MUSIC_CAVES]                         = {bpm = 130, offset=171},
    [Music.MUSIC_DEPTHS]                        = {bpm = 90, offset=124},
    [Music.MUSIC_CELLAR]                        = {bpm = 160, offset=184},
    [Music.MUSIC_CATACOMBS]                     = {bpm = 120, offset=136},
    [Music.MUSIC_NECROPOLIS]                    = {bpm = 126, offset=165},
    [Music.MUSIC_WOMB_UTERO]                    = {bpm = 140, offset=114},
    [Music.MUSIC_GAME_OVER]                     = {bpm = 120},
    [Music.MUSIC_BOSS]                          = {bpm = 140, triplet=true, timeSigs={[2]=4}},
    [Music.MUSIC_CATHEDRAL]                     = {bpm = 90},
    [Music.MUSIC_SHEOL]                         = {bpm = 92, timeSigs={[1]=4}},
    [Music.MUSIC_DARK_ROOM]                     = {bpm = 140, offset=19},
    [Music.MUSIC_CHEST]                         = {bpm = 142, offset=241, triplets={[2]=true, [4]=false}},
    [Music.MUSIC_BURNING_BASEMENT]              = {bpm = 130, offset=731, timeSig=3},
    [Music.MUSIC_FLOODED_CAVES]                 = {bpm = 133, timeSig=3},
    [Music.MUSIC_DANK_DEPTHS]                   = {bpm = 89, offset=315},
    [Music.MUSIC_SCARRED_WOMB]                  = {bpm = 100, timeSigs={[2]=4}},
    [Music.MUSIC_BLUE_WOMB]                     = {bpm = 75, offset=317},
    [Music.MUSIC_UTERO]                         = {bpm = 140, offset=107},
    [newMusic.MOM_BOSS_TRUE]                    = {bpm = 151, timeSigs={[2]=4}},
    [Music.MUSIC_MOM_BOSS]                      = {bpm = 151},
    [newMusic.MOMS_HEART_BOSS_TRUE]             = {bpm = 145, offset=120},
    [Music.MUSIC_MOMS_HEART_BOSS]               = {bpm = 145},
    [newMusic.ISAAC_BOSS_TRUE]                  = {bpm = 168, offset=55, timeSig=3},
    [Music.MUSIC_ISAAC_BOSS]                    = {bpm = 168, timeSig=3},
    [Music.MUSIC_SATAN_BOSS]                    = {bpm = 100, triplet=true},
    [Music.MUSIC_DARKROOM_BOSS]                 = {bpm = 163},
    [Music.MUSIC_BLUEBABY_BOSS]                 = {bpm = 140},
    [Music.MUSIC_BOSS2]                         = {bpm = 150, intro=2795, length=118400, timeSigs={[0]=7,[7]=6,[79]=7,[107]=6,[251]=7,[279]=6}},
    [Music.MUSIC_HUSH_BOSS]                     = {bpm = 169, intro=6391, length=177515, timeSigs={[2]=4,[18]=7,[46]=4,[138]=7,[166]=8,[174]=7,[202]=4,[394]=7,[422]=4}},
    [Music.MUSIC_ULTRAGREED_BOSS]               = {bpm = 139},
    [Music.MUSIC_LIBRARY_ROOM]                  = {bpm = 110, offset=7, intro=78, length=104704, bpms={[104189]=101.180}},
    [Music.MUSIC_SECRET_ROOM]                   = {bpm = 130, offset=78, timeSig=3},
    [Music.MUSIC_SECRET_ROOM2]                  = {bpm = 130, timeSig=3},
    [Music.MUSIC_DEVIL_ROOM]                    = {bpm = 30, length=125393, bpms={[112000]=35.84}},
    [Music.MUSIC_ANGEL_ROOM]                    = {bpm = 89, timeSigs={[2]=4}},
    [Music.MUSIC_SHOP_ROOM]                     = {bpm = 90, offset=212},
    [Music.MUSIC_ARCADE_ROOM]                   = {bpm = 120},
    [Music.MUSIC_BOSS_OVER]                     = {bpm = 60, offset=500, intro=4500, length=142000, timeSigs={[4]=4}},
    [newMusic.CHALLENGE_FIGHT_FULL]             = {bpm = 138, triplet=true, timeSigs={[2]=4}},
    [Music.MUSIC_CHALLENGE_FIGHT]               = {bpm = 138, triplet=true},
    [Music.MUSIC_BOSS_RUSH]                     = {bpm = 138, offset=19, triplet=true},
    [Music.MUSIC_JINGLE_BOSS_RUSH_OUTRO]        = {},
    [Music.MUSIC_BOSS3]                         = {bpm = 150, intro=2795, length=118400, timeSigs={[0]=7,[7]=6,[151]=7,[179]=6,[275]=7}},
    [Music.MUSIC_JINGLE_BOSS_OVER3]             = {},
    [newMusic.MOTHER_BOSS_TRUE]                 = {bpm = 158, offset=382},
    [Music.MUSIC_MOTHER_BOSS]                   = {bpm = 158},
    ----[Music.MUSIC_DOGMA_BOSS]                    = {}, -- same as vanilla
    ----[Music.MUSIC_BEAST_BOSS]                    = {}, -- same as vanilla
    [Music.MUSIC_JINGLE_MOTHER_OVER]            = {},
    ----[Music.MUSIC_JINGLE_DOGMA_OVER]             = {},
    [Music.MUSIC_JINGLE_BEAST_OVER]             = {},
    [Music.MUSIC_PLANETARIUM]                   = {bpm = 120, offset=500},
    [Music.MUSIC_SECRET_ROOM_ALT_ALT]           = {bpm = 130, offset=150, timeSig=3},
    [Music.MUSIC_BOSS_OVER_TWISTED]             = {bpm = 60, offset=132, timeSigs={[2]=4}},
    [Music.MUSIC_CREDITS]                       = {},
    ----[Music.MUSIC_TITLE]                         = {},
    [Music.MUSIC_TITLE_AFTERBIRTH]              = {},
    [Music.MUSIC_TITLE_REPENTANCE]              = {},
    [Music.MUSIC_JINGLE_GAME_START_ALT]         = {},
    ----[Music.MUSIC_JINGLE_NIGHTMARE_ALT]          = {},
    ----[Music.MUSIC_MOTHERS_SHADOW_INTRO]          = {},
    ----[Music.MUSIC_DOGMA_INTRO]                   = {},
    ----[Music.MUSIC_STRANGE_DOOR_JINGLE]           = {},
    ----[Music.MUSIC_DARK_CLOSET]                   = {},
    [Music.MUSIC_CREDITS_ALT]                   = {},
    [Music.MUSIC_CREDITS_ALT_FINAL]             = {},
    ----[Music.MUSIC_JINGLE_BOSS]                   = {},
    [Music.MUSIC_JINGLE_BOSS_OVER]              = {},
    ----[Music.MUSIC_JINGLE_HOLYROOM_FIND]          = {},
    [Music.MUSIC_JINGLE_SECRETROOM_FIND]        = {},
    [Music.MUSIC_JINGLE_TREASUREROOM_ENTRY_0]   = {},
    [Music.MUSIC_JINGLE_TREASUREROOM_ENTRY_1]   = {},
    [Music.MUSIC_JINGLE_TREASUREROOM_ENTRY_2]   = {},
    [Music.MUSIC_JINGLE_TREASUREROOM_ENTRY_3]   = {},
    ----[Music.MUSIC_JINGLE_CHALLENGE_ENTRY]        = {},
    [Music.MUSIC_JINGLE_CHALLENGE_OUTRO]        = {},
    [Music.MUSIC_JINGLE_GAME_OVER]              = {},
    ----[Music.MUSIC_JINGLE_DEVILROOM_FIND]         = {},
    [Music.MUSIC_JINGLE_GAME_START]             = {},
    ----[Music.MUSIC_JINGLE_NIGHTMARE]              = {},
    [Music.MUSIC_JINGLE_BOSS_OVER2]             = {},
    [Music.MUSIC_JINGLE_HUSH_OVER]              = {},
    ----[Music.MUSIC_INTRO_VOICEOVER]               = {},
    ----[Music.MUSIC_EPILOGUE_VOICEOVER]            = {},
    ----[Music.MUSIC_VOID]                          = {}, -- has "true" version
    [Music.MUSIC_VOID_BOSS]                     = {bpm = 153},
    [Music.MUSIC_DOWNPOUR]                      = {bpm = 170, offset=128},
    [Music.MUSIC_MINES]                         = {bpm = 140},
    [Music.MUSIC_MAUSOLEUM]                     = {bpm = 145, offset=100},
    [Music.MUSIC_CORPSE]                        = {bpm = 111},
    [Music.MUSIC_DROSS]                         = {bpm = 170, offset=13},
    [Music.MUSIC_ASHPIT]                        = {bpm = 140},
    [Music.MUSIC_GEHENNA]                       = {bpm = 145, offset=100},
    [Music.MUSIC_MORTIS]                        = {bpm = 140, offset=114},
    ----[Music.MUSIC_ISAACS_HOUSE]                  = {}, -- same as vanilla
    ----[Music.MUSIC_FINAL_VOICEOVER]               = {},
    [Music.MUSIC_DOWNPOUR_REVERSE]              = {bpm = 170, offset=-33},
    [Music.MUSIC_DROSS_REVERSE]                 = {bpm = 170, offset=-33},
    ----[Music.MUSIC_MINESHAFT_AMBIENT]             = {},
    ----[Music.MUSIC_MINESHAFT_ESCAPE]              = {}, -- same as vanilla
    ----[Music.MUSIC_REVERSE_GENESIS]               = {}, -- same as vanilla

    [newMusic.MEGASATAN_BOSS]                   = {bpm = 140, offset=-360, triplet=true},
    [newMusic.ARCADE_ALT]                       = {bpm = 166, offset=60},
    [newMusic.SHOP_ALT]                         = {bpm = 184, triplet=true},
    [newMusic.VOID_0]                           = {},
    [newMusic.VOID_1]                           = {},
    [newMusic.VOID_2]                           = {},
    [newMusic.VOID_3]                           = {},
    [newMusic.VOID_4]                           = {},
    [newMusic.VOID_5]                           = {},
    [newMusic.VOID_6]                           = {},
    [newMusic.VOID_7]                           = {},
    [newMusic.VOID_BOSS_1]                      = {},
    [newMusic.VOID_BOSS_2]                      = {},
    [newMusic.VOID_BOSS_3]                      = {},
    [newMusic.VOID_BOSS_4]                      = {},
    [newMusic.VOID_BOSS_5]                      = {},
    [newMusic.BLANK]                            = {},
    [newMusic.DROSS_OG]                         = {bpm = 120, offset = 237},
    [newMusic.DROSS_REVERSE_OG]                 = {bpm = 120},
    [newMusic.ASHPIT_OG]                        = {bpm = 106, timeSigs = {[3] = 4}},
    [newMusic.GEHENNA_OG]                       = {bpm = 110},
}

---https://docs.google.com/document/d/19049NXcudS0LmyQG6S3X4MdHwnR3J9DK1PwtB0tASmY/
---@type table<Music, string|string[]>
local names = {
    [Music.MUSIC_BASEMENT]                      = "Innocence Glitched (Basement)",
    [Music.MUSIC_CAVES]                         = "Subterranean Homesick Malign (Caves)",
    [Music.MUSIC_DEPTHS]                        = "Innocence Mangled (Depths)",
    [Music.MUSIC_CELLAR]                        = "Outside the Fold (Cellar)",
    [Music.MUSIC_CATACOMBS]                     = "Marble Forest (Catacombs)",
    [Music.MUSIC_NECROPOLIS]                    = "The Hammer of Pompeii (Necropolis)",
    [Music.MUSIC_WOMB_UTERO]                    = "Dystension (Womb)",
    [Music.MUSIC_GAME_OVER]                     = "Journey from a Jar to the Sky",
    [Music.MUSIC_BOSS]                          = "Invictus (Boss Fight)",
    [Music.MUSIC_CATHEDRAL]                     = "The Thief (Cathedral)",
    [Music.MUSIC_SHEOL]                         = "Shadowdance (Sheol)",
    [Music.MUSIC_DARK_ROOM]                     = "Morphine (Dark Room)",
    [Music.MUSIC_CHEST]                         = "Ultimort (Chest)",
    [Music.MUSIC_BURNING_BASEMENT]              = "Flashpoint (Burning Basement)",
    [Music.MUSIC_FLOODED_CAVES]                 = "Foreigner in Zeal (Flooded Caves)",
    [Music.MUSIC_DANK_DEPTHS]                   = "Mithraeum (Dank Depths)",
    [Music.MUSIC_SCARRED_WOMB]                  = "Lethe (Scarred Womb)",
    [Music.MUSIC_BLUE_WOMB]                     = "An Armistice (Blue Womb)",
    [Music.MUSIC_UTERO]                         = "Dystension (Womb)",
    [newMusic.MOM_BOSS_TRUE]                    = "The Turn (Mom fight)",
    [Music.MUSIC_MOM_BOSS]                      = "The Turn (Mom fight)",
    [newMusic.MOMS_HEART_BOSS_TRUE]             = "Gloria Filio (Mom's Heart)",
    [Music.MUSIC_MOMS_HEART_BOSS]               = "Gloria Filio (Mom's Heart)",
    [newMusic.ISAAC_BOSS_TRUE]                  = "Misericorde (Isaac Fight)",
    [Music.MUSIC_ISAAC_BOSS]                    = "Misericorde (Isaac Fight)",
    [Music.MUSIC_SATAN_BOSS]                    = "Spectrum of Sin (Satan fight)",
    [Music.MUSIC_DARKROOM_BOSS]                 = "Fitnah (Lamb Fight)",
    [Music.MUSIC_BLUEBABY_BOSS]                 = "Rapturepunk (BB fight)",
    [Music.MUSIC_BOSS2]                         = "Tandava (Boss)",
    [Music.MUSIC_HUSH_BOSS]                     = "Howl (Hush Fight)",
    [Music.MUSIC_ULTRAGREED_BOSS]               = "Non Funkible Token (Ultra Greed)",
    [Music.MUSIC_LIBRARY_ROOM]                  = "Lucidate (Library)",
    [Music.MUSIC_SECRET_ROOM]                   = "Forgotten Lullaby (Secret Room)",
    [Music.MUSIC_SECRET_ROOM2]                  = "Forgotten Lullaby (Secret Room)",
    [Music.MUSIC_DEVIL_ROOM]                    = "Blackpath (Devil room)",
    [Music.MUSIC_ANGEL_ROOM]                    = "Whitepath (Angel room)",
    [Music.MUSIC_SHOP_ROOM]                     = "Depression Shop",
    [Music.MUSIC_ARCADE_ROOM]                   = "Esc (Arcade)",
    [Music.MUSIC_BOSS_OVER]                     = "Spinning Out of Orbit (Boss Beaten)",
    [newMusic.CHALLENGE_FIGHT_FULL]             = "A Baleful Circus (Boss Rush)",
    [Music.MUSIC_CHALLENGE_FIGHT]               = "A Baleful Circus (Boss Rush)",
    [Music.MUSIC_BOSS_RUSH]                     = "A Baleful Circus (Boss Rush)",
    [Music.MUSIC_BOSS3]                         = "Tandava (Boss)",
    [newMusic.MOTHER_BOSS_TRUE]                 = "Memento Mori",
    [Music.MUSIC_MOTHER_BOSS]                   = "Memento Mori",
    [Music.MUSIC_PLANETARIUM]                   = "Journey from a Jar to the Sky",
    [Music.MUSIC_SECRET_ROOM_ALT_ALT]           = {"Forgotten Lullaby (with reverb)", "andboy"},
    [Music.MUSIC_BOSS_OVER_TWISTED]             = "Spinning Intensifies (Boss Beaten + ?)",
    [Music.MUSIC_CREDITS]                       = "Underscore (Credits)",
    [Music.MUSIC_TITLE_AFTERBIRTH]              = "Descent (Title)",
    [Music.MUSIC_TITLE_REPENTANCE]              = "Descent (Title)",
    [Music.MUSIC_CREDITS_ALT]                   = "Take Me Back Home", -- https://twitter.com/htedum/status/1402159446336307200
    ----[Music.MUSIC_CREDITS_ALT_FINAL]         = "", -- idk
    ----[Music.MUSIC_VOID]                      = "Allnoise (The Void)",
    [Music.MUSIC_VOID_BOSS]                     = "Terminal Lucidity (Delirium)",
    [Music.MUSIC_DOWNPOUR]                      = "Hallowed Ground",
    [Music.MUSIC_MINES]                         = "Fault Lines",
    [Music.MUSIC_MAUSOLEUM]                     = "Machine in the Walls",
    [Music.MUSIC_CORPSE]                        = "Drowning",
    [Music.MUSIC_DROSS]                         = {"Hallowed Ground (Arrange)", "Kwonunn"},
    [Music.MUSIC_ASHPIT]                        = {"Fault Lines (Arrange)", "Kwonunn"},
    [Music.MUSIC_GEHENNA]                       = {"Machine in the Walls (Arrange)", "Kwonunn"},
    [Music.MUSIC_MORTIS]                        = "[Unfinished area theme]",
    [Music.MUSIC_DROSS_REVERSE]                 = {nil, "Kwonunn"},

    [newMusic.MEGASATAN_BOSS]                   = "The Flagbearer",
    [newMusic.ARCADE_ALT]                       = {"$4cR1f1c14|_", "Danny Baranowsky"},
    [newMusic.SHOP_ALT]                         = {"Greed", "Danny Baranowsky"},
    --[newMusic.VOID_0]                           = "",
    --[newMusic.VOID_1]                           = "",
    --[newMusic.VOID_2]                           = "",
    --[newMusic.VOID_3]                           = "",
    --[newMusic.VOID_4]                           = "",
    --[newMusic.VOID_5]                           = "",
    --[newMusic.VOID_6]                           = "",
    --[newMusic.VOID_7]                           = "",
    --[newMusic.VOID_BOSS_1]                      = "",
    --[newMusic.VOID_BOSS_2]                      = "",
    --[newMusic.VOID_BOSS_3]                      = "",
    --[newMusic.VOID_BOSS_4]                      = "",
    --[newMusic.VOID_BOSS_5]                      = "",
    [newMusic.BLANK]                            = {"", ""},
    [newMusic.DROSS_OG]                         = {"Night Soil (Dross)", "Ridiculon"},
    [newMusic.DROSS_REVERSE_OG]                 = {nil, "Ridiculon"},
    [newMusic.ASHPIT_OG]                        = {"Absentia (Ashpit)", "Ridiculon"},
    [newMusic.GEHENNA_OG]                       = {"Morning Star (Gehenna)", "Ridiculon"},
}

for music, def in pairs(tempoDefs) do
    local name = names[music]
    if name then
        if type(name) == "table" then
            def.name = def.name or name[1] or nil
            def.artist = def.artist or name[2] or "mudeth"
        else
            def.name = def.name or name or nil
            def.artist = def.artist or "mudeth"
        end
    else
        def.artist = def.artist or "mudeth"
    end
end

tempoDefs[newMusic.MOM_BOSS]                         = tempoDefs[Music.MUSIC_MOM_BOSS]
tempoDefs[newMusic.MOMS_HEART_BOSS]                  = tempoDefs[Music.MUSIC_MOMS_HEART_BOSS]
tempoDefs[newMusic.ISAAC_BOSS]                       = tempoDefs[Music.MUSIC_ISAAC_BOSS]
tempoDefs[newMusic.MOTHER_BOSS]                      = tempoDefs[Music.MUSIC_MOTHER_BOSS]
tempoDefs[newMusic.BLUEBABY_BOSS_TRUE]               = tempoDefs[Music.MUSIC_BLUEBABY_BOSS]
tempoDefs[newMusic.BLUEBABY_BOSS]                    = tempoDefs[Music.MUSIC_BLUEBABY_BOSS]
tempoDefs[newMusic.DARKROOM_BOSS_TRUE]               = tempoDefs[Music.MUSIC_DARKROOM_BOSS]
tempoDefs[newMusic.DARKROOM_BOSS]                    = tempoDefs[Music.MUSIC_DARKROOM_BOSS]
tempoDefs[newMusic.VOID_BOSS_TRUE]                   = tempoDefs[Music.MUSIC_VOID_BOSS]
tempoDefs[newMusic.VOID_BOSS]                        = tempoDefs[Music.MUSIC_VOID_BOSS]
tempoDefs[newMusic.ULTRAGREED_BOSS_TRUE]             = tempoDefs[Music.MUSIC_ULTRAGREED_BOSS]
tempoDefs[newMusic.ULTRAGREED_BOSS]                  = tempoDefs[Music.MUSIC_ULTRAGREED_BOSS]
tempoDefs[newMusic.SATAN_BOSS]                       = tempoDefs[Music.MUSIC_SATAN_BOSS]
tempoDefs[newMusic.BOSS_MMC]                         = tempoDefs[Music.MUSIC_BOSS]
tempoDefs[newMusic.UTERO_MMC]                        = tempoDefs[Music.MUSIC_UTERO]
tempoDefs[newMusic.SATAN_BOSS_MMC]                   = tempoDefs[Music.MUSIC_SATAN_BOSS]
tempoDefs[newMusic.BOSS3_MMC]                        = tempoDefs[Music.MUSIC_BOSS3]
tempoDefs[newMusic.JINGLE_MOTHER_OVER_MMC]           = tempoDefs[Music.MUSIC_JINGLE_MOTHER_OVER]
tempoDefs[newMusic.PLANETARIUM_MMC]                  = tempoDefs[Music.MUSIC_PLANETARIUM]
tempoDefs[newMusic.DOWNPOUR_MMC]                     = tempoDefs[Music.MUSIC_DOWNPOUR]
tempoDefs[newMusic.MINES_MMC]                        = tempoDefs[Music.MUSIC_MINES]
tempoDefs[newMusic.MAUSOLEUM_MMC]                    = tempoDefs[Music.MUSIC_MAUSOLEUM]
tempoDefs[newMusic.CORPSE_MMC]                       = tempoDefs[Music.MUSIC_CORPSE]
tempoDefs[newMusic.DROSS_MMC]                        = tempoDefs[Music.MUSIC_DROSS]
tempoDefs[newMusic.ASHPIT_MMC]                       = tempoDefs[Music.MUSIC_ASHPIT]
tempoDefs[newMusic.GEHENNA_MMC]                      = tempoDefs[Music.MUSIC_GEHENNA]

return tempoDefs