local f = CatGuy.GetMusicIdByNames

---@enum _ppp
local newMusic = {
	ULTRAGREED_BOSS_TRUE    = f("True Ultra Greed"),
	SHOP_ALT                = f("Shop Alt"),
	BOSS_MMC                = f("Boss MMC"),
	UTERO_MMC               = f("Utero MMC"),
	SATAN_BOSS_MMC          = f("Boss (Sheol - Satan) MMC"),
	BOSS3_MMC               = f("Boss (alternate alternate) MMC"),
	JINGLE_MOTHER_OVER_MMC  = f("Boss Mother Death (jingle) MMC"),
	PLANETARIUM_MMC         = f("Planetarium MMC"),
	DOWNPOUR_MMC            = f("Downpour MMC"),
	MINES_MMC               = f("Mines MMC"),
	MAUSOLEUM_MMC           = f("Mausoleum MMC"),
	CORPSE_MMC              = f("Corpse MMC"),
	DROSS_MMC               = f("Dross MMC"),
	ASHPIT_MMC              = f("Ashpit MMC"),
	GEHENNA_MMC             = f("Gehenna MMC"),
	DROSS_OG                = f("Night Soil"),
	DROSS_REVERSE_OG        = f("Night Soil (reversed)"),
	ASHPIT_OG               = f("Absentia"),
	GEHENNA_OG              = f("Morning Star")
}

---@type TempoDefs
local tempoDefs = {
    [Music.MUSIC_UTERO]                         = {bpm = 140, offset=107},
    [Music.MUSIC_BOSS_RUSH]                     = {bpm = 138, offset=19, triplet=true},
    [Music.MUSIC_DROSS]                         = {bpm = 170, offset=13},
    [Music.MUSIC_ASHPIT]                        = {bpm = 140},
    [Music.MUSIC_GEHENNA]                       = {bpm = 145, offset=100},
    [Music.MUSIC_DROSS_REVERSE]                 = {bpm = 170, offset=-33},

    [newMusic.SHOP_ALT]                         = {bpm = 184, triplet=true},

}

---@type table<Music, string|string[]>
local names = {
    [Music.MUSIC_UTERO]                         = "Dystension (Womb)",
    [Music.MUSIC_BOSS_RUSH]                     = "A Baleful Circus (Boss Rush)",
    [Music.MUSIC_DROSS]                         = {"Hallowed Ground (Arrange)", "Kwonunn"},
    [Music.MUSIC_ASHPIT]                        = {"Fault Lines (Arrange)", "Kwonunn"},
    [Music.MUSIC_GEHENNA]                       = {"Machine in the Walls (Arrange)", "Kwonunn"},
    [Music.MUSIC_DROSS_REVERSE]                 = {nil, "Kwonunn"},

    [newMusic.SHOP_ALT]                         = {"Greed", "Danny Baranowsky"},
}

CatGuy:ApplyNameArtistToTempoDefs(tempoDefs, names, "mudeth")

tempoDefs[newMusic.ULTRAGREED_BOSS_TRUE]             = CatGuy.TempoDefs.AntibirthPP[Music.MUSIC_ULTRAGREED_BOSS]

tempoDefs[newMusic.BOSS_MMC]                         = CatGuy.TempoDefs.AntibirthPP[Music.MUSIC_BOSS]
tempoDefs[newMusic.UTERO_MMC]                        = CatGuy.TempoDefs.AntibirthPP[Music.MUSIC_UTERO]
tempoDefs[newMusic.SATAN_BOSS_MMC]                   = CatGuy.TempoDefs.AntibirthPP[Music.MUSIC_SATAN_BOSS]
tempoDefs[newMusic.BOSS3_MMC]                        = CatGuy.TempoDefs.AntibirthPP[Music.MUSIC_BOSS3]
tempoDefs[newMusic.JINGLE_MOTHER_OVER_MMC]           = CatGuy.TempoDefs.AntibirthPP[Music.MUSIC_JINGLE_MOTHER_OVER]
tempoDefs[newMusic.PLANETARIUM_MMC]                  = CatGuy.TempoDefs.AntibirthPP[Music.MUSIC_PLANETARIUM]
tempoDefs[newMusic.DOWNPOUR_MMC]                     = CatGuy.TempoDefs.AntibirthPP[Music.MUSIC_DOWNPOUR]
tempoDefs[newMusic.MINES_MMC]                        = CatGuy.TempoDefs.AntibirthPP[Music.MUSIC_MINES]
tempoDefs[newMusic.MAUSOLEUM_MMC]                    = CatGuy.TempoDefs.AntibirthPP[Music.MUSIC_MAUSOLEUM]
tempoDefs[newMusic.CORPSE_MMC]                       = CatGuy.TempoDefs.AntibirthPP[Music.MUSIC_CORPSE]
tempoDefs[newMusic.DROSS_MMC]                        = tempoDefs[Music.MUSIC_DROSS]
tempoDefs[newMusic.ASHPIT_MMC]                       = tempoDefs[Music.MUSIC_ASHPIT]
tempoDefs[newMusic.GEHENNA_MMC]                      = tempoDefs[Music.MUSIC_GEHENNA]

tempoDefs[newMusic.DROSS_OG]                         = CatGuy.TempoDefs.Vanilla[Music.MUSIC_DROSS]
tempoDefs[newMusic.DROSS_REVERSE_OG]                 = CatGuy.TempoDefs.Vanilla[Music.MUSIC_DROSS_REVERSE]
tempoDefs[newMusic.ASHPIT_OG]                        = CatGuy.TempoDefs.Vanilla[Music.MUSIC_ASHPIT]
tempoDefs[newMusic.GEHENNA_OG]                       = CatGuy.TempoDefs.Vanilla[Music.MUSIC_GEHENNA]

return tempoDefs