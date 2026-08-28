---@class MusicXMLNode 
---@field name string
---@field intro? string
---@field path? string
---@field sourceid? string
---@field id? string
---@field loop? string

--- Repentance (not Repentance+) music XML as an importable lua table. keyed by ids, layer subnodes in a list called "layers".
--- Not used anymore.
---@type table<Music, MusicXMLNode>
local vanillaMusicXML = {
	[Music.MUSIC_BASEMENT]         				= {name="Basement", intro="Diptera Sonata Intro.ogg", path="Diptera Sonata(Basement).ogg", layerintro="Diptera Layer Intro.ogg", layer="Diptera Layer.ogg", loop="true"},
	[Music.MUSIC_CAVES]            				= {name="Caves", intro="The Caves Intro.ogg", path="The Caves.ogg", layerintro="The Caves Layer Intro.ogg", layer="The Caves Layer.ogg", loop="true"},
	[Music.MUSIC_DEPTHS]           				= {name="Depths", intro="The Depths Intro.ogg", path="The Depths.ogg", layerintro="The Depths Layer Intro.ogg", layer="The Depths Layer.ogg", loop="true"},
	[Music.MUSIC_CELLAR]           				= {name="Cellar", intro="The Cellar Alt Intro.ogg", path="The Cellar Alt.ogg", layerintro="The Cellar Layer Intro.ogg", layer="The Cellar Layer.ogg", loop="true"},
	[Music.MUSIC_CATACOMBS]        				= {name="Catacombs", intro="Catacombs Intro.ogg", path="Catacombs.ogg", layerintro="Catacombs Layer Intro.ogg", layer="Catacombs Layer.ogg", loop="true"},
	[Music.MUSIC_NECROPOLIS]       				= {name="Necropolis", intro="Necropolis Intro.ogg", path="Necropolis.ogg", layerintro="Necropolis Layer Intro.ogg", layer="Necropolis Layer.ogg", loop="true"},
	[Music.MUSIC_WOMB_UTERO]       				= {name="Womb", intro="The Womb Chapter Four Intro.ogg", path="The Womb Chapter Four.ogg", layerintro="The Womb Layer Intro.ogg", layer="The Womb Layer.ogg", loop="true"},
	[Music.MUSIC_GAME_OVER]        				= {name="Game Over", path="You Died.ogg", loop="true"},
	[Music.MUSIC_BOSS]             				= {name="Boss", path="Fight Ogg/Basic Boss Fight.ogg", loop="true"},
	[Music.MUSIC_CATHEDRAL]        				= {name="Cathedral", intro="Cathedral Intro.ogg", path="Cathedral Chant.ogg", layerintro="Cathedral Layer Intro.ogg", layer="Cathedral Layer.ogg", loop="true"},
	[Music.MUSIC_SHEOL]            				= {name="Sheol", intro="Sheol Intro.ogg", path="Sheol.ogg", layerintro="Sheol Layer Intro.ogg", layer="Sheol Layer.ogg", loop="true"},
	[Music.MUSIC_DARK_ROOM]        				= {name="Dark Room", intro="Dark Room Alt Chapter 6 intro.ogg", path="Dark Room Alt Chapter 6.ogg", loop="true"},
	[Music.MUSIC_CHEST]            				= {name="Chest", intro="Chest Room Intro.ogg", path="Chest Room Chapter 6.ogg", layerintro="Chest Layer Intro.ogg", layer="Chest Layer.ogg", loop="true"},
	[Music.MUSIC_BURNING_BASEMENT] 				= {name="Burning Basement", intro="Afterbirth/burning basement Intro.ogg", path="Afterbirth/burning basement Loop.ogg", layerintro="Afterbirth/burning basement Intro silent.ogg", layer="Afterbirth/Burning Basement GUitar Layer_04.ogg", loop="true"},
	[Music.MUSIC_FLOODED_CAVES]    				= {name="Flooded Caves", intro="Afterbirth/Kave Diluvii (Flooded Caves)Intro.ogg", path="Afterbirth/Kave Diluvii (Flooded Caves) loop.ogg", layerintro="Afterbirth/Kave Diluvii (Flooded Caves)Intro silent.ogg", layer="Afterbirth/Kave Diluvii (Flooded Caves) Layer.ogg", loop="true"},
	[Music.MUSIC_DANK_DEPTHS]      				= {name="Dank Depths", intro="Afterbirth/Pulso Profundum (dank Depths ) intro.ogg", path="Afterbirth/Pulso Profundum (dank Depths ) Loop.ogg", layerintro="Afterbirth/Pulso Profundum (dank Depths ) intro silent.ogg", layer="Afterbirth/Pulso Profundum (dank Depths ) Layer.ogg", loop="true"},
	[Music.MUSIC_SCARRED_WOMB]     				= {name="Scarred Womb", intro="Afterbirth/Cicatrix (Scarred Womb) Intro.ogg", path="Afterbirth/Cicatrix (Scarred Womb) Loop.ogg", layerintro="Afterbirth/Cicatrix (Scarred Womb) Intro silent.ogg", layer="Afterbirth/Cicatrix (Scarred Womb) Layer.ogg", loop="true"},
	[Music.MUSIC_BLUE_WOMB]        				= {name="Blue Womb", intro="Afterbirth/Nativitate  (Dead Womb Floor) Intro.ogg", path="Afterbirth/Nativitate (Dead Womb Floor) Loop.ogg", layerintro="Afterbirth/Nativitate  (Dead Womb Floor) Intro silence.ogg", layer="Afterbirth/Nativitate (Dead Womb Floor) Layer.ogg", loop="true"},
	[Music.MUSIC_UTERO]            				= {name="Utero", path="Utero.ogg", layer="Utero Heavy.ogg", loop="true", layermode="2", layerfadespeed="0.005"},
	[Music.MUSIC_MOM_BOSS]         				= {name="Boss (Depths - Mom)", path="Fight Ogg/Mom Fight.ogg", loop="true"},
	[Music.MUSIC_MOMS_HEART_BOSS]  				= {name="Boss (Womb - Mom's Heart)", path="Fight Ogg/Womb Fight.ogg", loop="true"},
	[Music.MUSIC_ISAAC_BOSS]       				= {name="Boss (Cathedral - Isaac)", path="Fight Ogg/Isaac Fight.ogg", loop="true"},
	[Music.MUSIC_SATAN_BOSS]       				= {name="Boss (Sheol - Satan)", path="Fight Ogg/Satan Fight.ogg", loop="true"},
	[Music.MUSIC_DARKROOM_BOSS]    				= {name="Boss (Dark Room)", path="Fight Ogg/Dark Room Fight.ogg", loop="true"},
	[Music.MUSIC_BLUEBABY_BOSS]    				= {name="Boss (Chest - ???)", path="Fight Ogg/Chest Fight.ogg", loop="true"},
	[Music.MUSIC_BOSS2]            				= {name="Boss (alternate)", intro="Afterbirth/Cerebrum Dispersio (boss alt ) intro.ogg", path="Afterbirth/Cerebrum Dispersio (boss alt) Loop.ogg", loop="true"},
	[Music.MUSIC_HUSH_BOSS]        				= {name="Boss (Blue Womb - Hush)", intro="Afterbirth/Morituros (dead womb boss) intro.ogg", path="Afterbirth/Morituros (dead womb boss) Loop.ogg", loop="true"},
	[Music.MUSIC_ULTRAGREED_BOSS]  				= {name="Boss (Ultra Greed)", intro="Afterbirth/Chorus Mortis (Punk Credit) Intro.ogg", path="Afterbirth/Chorus Mortis (Punk Credit) Loop.ogg", loop="true"},
	[Music.MUSIC_LIBRARY_ROOM]     				= {name="Library Room", intro="Library Intro.ogg", path="Library.ogg", loop="true"},
	[Music.MUSIC_SECRET_ROOM]      				= {name="Secret Room", intro="Secret to Everyone Intro.ogg", path="Secret to Everyone.ogg", loop="true"},
	[Music.MUSIC_SECRET_ROOM2]     				= {name="Secret Room Alt", path="Secret Room ALT.ogg", loop="true"},
	[Music.MUSIC_DEVIL_ROOM]       				= {name="Devil Room", path="Deal With the Devil.ogg", loop="true"},
	[Music.MUSIC_ANGEL_ROOM]              		= {name="Angel Room", intro="Angel Room intro.ogg", path="Angel Room.ogg", loop="true"},
	[Music.MUSIC_SHOP_ROOM]               		= {name="Shop Room", intro="Store Loop Intro.ogg", path="Store Loop.ogg", loop="true"},
	[Music.MUSIC_ARCADE_ROOM]             		= {name="Arcade Room", intro="Retro Beats Intro 8-6-14.ogg", path="Retro Beats 8-6-14.ogg", loop="true"},
	[Music.MUSIC_BOSS_OVER]               		= {name="Boss Room (empty)", intro="The Calm intro.ogg", path="The Calm.ogg", loop="true"},
	[Music.MUSIC_CHALLENGE_FIGHT]         		= {name="Challenge Room (fight)", path="Ambush.ogg", loop="true"},
	[Music.MUSIC_BOSS_RUSH]               		= {name="Boss Rush", path="Boss Rush.ogg", loop="true"},
	[Music.MUSIC_JINGLE_BOSS_RUSH_OUTRO]  		= {name="Boss Rush (jingle)", path="JINGLE OGG/Ambush Jinle outro V3_04.ogg", loop="false"},
-- REPENTANCE BEGIN --
	[Music.MUSIC_BOSS3]                			= {name="Boss (alternate alternate)", path="Repentance/Boss ALT.ogg", loop="true"},
	[Music.MUSIC_JINGLE_BOSS_OVER3]    			= {name="Boss Death Alternate Alternate (jingle)", path="Repentance/Alt Boss Track Jingle.ogg", loop="false", mul="2.2"},

	[Music.MUSIC_MOTHER_BOSS]     				= {name="Boss (Mother)", path="Repentance/MOTHER_BOSS_V6.ogg", loop="true", mul="1.25"},
	[Music.MUSIC_DOGMA_BOSS]      				= {name="Boss (Dogma)", path="Repentance/Static Boss Light V2.ogg", loop="true", layermode="2", layerfadespeed="0.008", layers = {
		{path="Repentance/Static Boss V2 with Preachers V3.ogg", mul="1.2"},
		{path="Repentance/Static.ogg", mul="1"},
	}},
	[Music.MUSIC_BEAST_BOSS]      				= {name="Boss (Beast)", path="Repentance/The_End_FAMINE.ogg", loop="true", layermode="2", layerfadespeed="0.01", mul="1.5", layers = {
		{path="Repentance/The_End_PESTILENCE.ogg", mul="1.5"},
		{path="Repentance/The_End_WAR.ogg", mul="1.5"},
		{path="Repentance/The_End_DEATH.ogg", mul="1.5"},
		{path="Repentance/The_End_BEAST.ogg", mul="2"},
	}},

	[Music.MUSIC_JINGLE_MOTHER_OVER]   			= {name="Boss Mother Death (jingle)", path="Repentance/Alt Boss Track Jingle.ogg", loop="false", mul="2.2"},
	[Music.MUSIC_JINGLE_DOGMA_OVER]    			= {name="Boss Dogma Death (jingle)", path="Repentance/Static Boss Light V2 Jingle.ogg", loop="false", mul="1.5"},
	[Music.MUSIC_JINGLE_BEAST_OVER]    			= {name="Boss Beast Death (jingle)", path="Repentance/Alt Boss Track Jingle.ogg", loop="false", mul="2.2"},

	[Music.MUSIC_PLANETARIUM]           		= {name="Planetarium", path="Repentance/Planetarium.ogg", loop="true"},
	[Music.MUSIC_SECRET_ROOM_ALT_ALT]   		= {name="Secret Room Alt Alt", intro="Repentance/Super Secret Room Intro.ogg", path="Repentance/Super Secret Room Loop.ogg", loop="true"},
	[Music.MUSIC_BOSS_OVER_TWISTED]     		= {name="Boss Room (empty, twisted)", intro="Repentance/The Calm Twisted V4 Intro.ogg", path="Repentance/The Calm Twisted V4 Loop.ogg", loop="true", mul="1.2"},
-- REPENTANCE END --	

	[Music.MUSIC_CREDITS]             			= {name="Credits", path="Credits Roll.ogg", loop="true"},
	[Music.MUSIC_TITLE]               			= {name="Title Screen", intro="Title Screen Intro.ogg", path="Title Screen.ogg", loop="true"},
	[Music.MUSIC_TITLE_AFTERBIRTH]    			= {name="Title Screen (Afterbirth)", intro="Afterbirth/ReGenesis V3 intro.ogg", path="Afterbirth/ReGenesis (loop) V3.ogg", loop="true"},

-- REPENTANCE BEGIN --	
	[Music.MUSIC_TITLE_REPENTANCE]       		= {name="Title Screen (Repentance)", intro="Repentance/Genesis Retake Light Intro.ogg", path="Repentance/Genesis Retake Light Loop.ogg", layerintro="Repentance/Genesis Retake Twisted Intro.ogg", layer="Repentance/Genesis Retake Twisted Loop.ogg", loop="true", layermode="2", layerfadespeed="0.01"},
	[Music.MUSIC_JINGLE_GAME_START_ALT]  		= {name="Game start (jingle, twisted)", path="Repentance/Title Screen Stinger MB.ogg", loop="false"},
	[Music.MUSIC_JINGLE_NIGHTMARE_ALT]   		= {name="Nightmare (alt)", path="Repentance/Nightmare_V4.ogg", loop="false"},
	[Music.MUSIC_MOTHERS_SHADOW_INTRO]   		= {name="Mom's Shadow Intro", path="Repentance/Moms_Shadow_Cut_Scene.ogg", loop="false"},
	[Music.MUSIC_DOGMA_INTRO]            		= {name="Dogma Intro", path="Repentance/Dogma_static_Cut_Scene_V5.ogg", loop="false", mul="1.5"},
	[Music.MUSIC_STRANGE_DOOR_JINGLE]    		= {name="Strange Door (jingle)", path="Repentance/Genesis_SFX_Jingle.ogg", loop="false"},
	[Music.MUSIC_DARK_CLOSET]            		= {name="Echoes Reverse", path="Repentance/Echoes Reverse.ogg", loop="true"},
-- REPENTANCE END --	

	[Music.MUSIC_CREDITS_ALT]  					= {name="Credits Alt", path="Jesus Loves Uke.ogg", loop="false"},
-- REPENTANCE BEGIN --	
	[Music.MUSIC_CREDITS_ALT_FINAL] 			= {name="Credits Alt Final", path="Repentance/Jesus Loves Viggo V3.ogg", loop="false", mul="1.9"},
-- REPENTANCE END --

	[Music.MUSIC_JINGLE_BOSS]                 	= {name="Boss (jingle)", path="JINGLE OGG/Boss Fight intro jingle V2.1.ogg", loop="false"},
	[Music.MUSIC_JINGLE_BOSS_OVER]            	= {name="Boss Death (jingle)", path="JINGLE OGG/Boss FIght jingle OUTRO v2_12.ogg", loop="false"},
	[Music.MUSIC_JINGLE_HOLYROOM_FIND]        	= {name="Holy Room Find (jingle)", path="JINGLE OGG/Angel Room Appear V2_07.ogg", loop="false"},
	[Music.MUSIC_JINGLE_SECRETROOM_FIND]      	= {name="Secret Room Find (jingle)", path="JINGLE OGG/secret room find v2_07.ogg", loop="false"},
	[Music.MUSIC_JINGLE_TREASUREROOM_ENTRY_0] 	= {name="Treasure Room Entry (jingle) 1", path="JINGLE OGG/treasure room discoverA.ogg", loop="false"},
	[Music.MUSIC_JINGLE_TREASUREROOM_ENTRY_1] 	= {name="Treasure Room Entry (jingle) 2", path="JINGLE OGG/treasure room discoverB.ogg", loop="false"},
	[Music.MUSIC_JINGLE_TREASUREROOM_ENTRY_2] 	= {name="Treasure Room Entry (jingle) 3", path="JINGLE OGG/treasure room discoverC.ogg", loop="false"},
	[Music.MUSIC_JINGLE_TREASUREROOM_ENTRY_3] 	= {name="Treasure Room Entry (jingle) 4", path="JINGLE OGG/treasure room discover_03.ogg", loop="false"},
	[Music.MUSIC_JINGLE_CHALLENGE_ENTRY]      	= {name="Challenge Room Entry (jingle)", path="JINGLE OGG/Ambush jingle.V2_01.ogg", loop="false"},
	[Music.MUSIC_JINGLE_CHALLENGE_OUTRO]      	= {name="Challenge Room Outro (jingle)", path="JINGLE OGG/Ambush Jinle outro V3_04.ogg", loop="false"},
	[Music.MUSIC_JINGLE_GAME_OVER]            	= {name="Game Over (jingle)", path="JINGLE OGG/Isaac Died_02.ogg", loop="false"},
	[Music.MUSIC_JINGLE_DEVILROOM_FIND]       	= {name="Devil Room appear (jingle)", path="JINGLE OGG/Satan Room Appear V2_01.ogg", loop="false"},
	[Music.MUSIC_JINGLE_GAME_START]           	= {name="Game start (jingle)", path="JINGLE OGG/Title Screen jingle V1_01.ogg", loop="false"},
	[Music.MUSIC_JINGLE_NIGHTMARE]            	= {name="Nightmare", path="JINGLE OGG/boss fight intro jingle_01.ogg", loop="false"},
	[Music.MUSIC_JINGLE_BOSS_OVER2]           	= {name="Boss Death Alternate (jingle)", path="Afterbirth/Cerebrum Dispersio (boss alt) end.ogg", loop="false"},
	[Music.MUSIC_JINGLE_HUSH_OVER]            	= {name="Boss Hush Death (jingle)", path="Afterbirth/Morituros (dead womb boss) outro.ogg", loop="false"},
	[Music.MUSIC_INTRO_VOICEOVER]             	= {name="Intro Voiceover", path="IntroVoiceover.ogg", loop="false"},
	[Music.MUSIC_EPILOGUE_VOICEOVER]          	= {name="Epilogue Voiceover", path="Epilogue_01m.ogg", loop="false"},
	[Music.MUSIC_VOID]                        	= {name="Void", path="Void.ogg", loop="true"},
	[Music.MUSIC_VOID_BOSS]                   	= {name="Boss (Void)", path="Fight Ogg/Delirium Fight.ogg", loop="true"},
-- REPENTANCE BEGIN --
	[Music.MUSIC_DOWNPOUR]            			= {name="Downpour", path="Repentance/Downpour.ogg", layer="Repentance/Downpour Heavy.ogg", loop="true", layermode="2", layerfadespeed="0.005"},
	[Music.MUSIC_MINES]               			= {name="Mines", path="Repentance/Mines.ogg", layer="Repentance/Mines Heavy.ogg", loop="true", layermode="2", mul="1.15", layermul="1.35", layerfadespeed="0.005"},
	[Music.MUSIC_MAUSOLEUM]           			= {name="Mausoleum", path="Repentance/Mausoleum.ogg", layer="Repentance/Mausoleum Heavy.ogg", loop="true", layermode="2", layermul="1.2", layerfadespeed="0.005"},
	[Music.MUSIC_CORPSE]              			= {name="Corpse", path="Repentance/Corpse.ogg", layer="Repentance/Corpse Layer.ogg", loop="true", layerfadespeed="0.005"},
	[Music.MUSIC_DROSS]               			= {name="Dross", path="Repentance/Sewer.ogg", layer="Repentance/Sewer Heavy.ogg", loop="true", layermode="2", layerfadespeed="0.005"},
	[Music.MUSIC_ASHPIT]              			= {name="Ashpit", intro="Repentance/Ash Pit Intro.ogg", path="Repentance/Ash Pit.ogg", layerintro="Repentance/Ash Pit Heavy Intro.ogg", layer="Repentance/Ash Pit Heavy.ogg", loop="true", layermode="2", mul="1.55", layermul="1.75", layerfadespeed="0.005"},
	[Music.MUSIC_GEHENNA]             			= {name="Gehenna", path="Repentance/Gehenna.ogg", layer="Repentance/Gehenna Heavy.ogg", loop="true", layermode="2", layerfadespeed="0.005", mul="1.5", layermul="2.1"},
	[Music.MUSIC_MORTIS]              			= {name="not done", intro="The Womb Chapter Four Intro.ogg", path="The Womb Chapter Four.ogg", layerintro="The Womb Layer Intro.ogg", layer="The Womb Layer.ogg", loop="true", layerfadespeed="0.005"},
	[Music.MUSIC_ISAACS_HOUSE]        			= {name="Home", path="Repentance/Echoes Of Mom.ogg", layer="Repentance/Echoes of Mom Twisted V2.ogg", loop="true", layerfadespeed="0.005", layermode="2"},
	[Music.MUSIC_FINAL_VOICEOVER]     			= {name="Final Voiceover", path="Repentance/End End End VO.ogg", loop="false"},
	[Music.MUSIC_DOWNPOUR_REVERSE]    			= {name="Downpour (reversed)", path="Repentance/Downpour Reverse.ogg", loop="true"},
	[Music.MUSIC_DROSS_REVERSE]       			= {name="Dross (reversed)", path="Repentance/Dross Reverse.ogg", loop="true", mul="1.2"},
	[Music.MUSIC_MINESHAFT_AMBIENT]   			= {name="Abandoned Mineshaft", path="Repentance/Vast Empty Chasm.ogg", loop="true"},
	[Music.MUSIC_MINESHAFT_ESCAPE]    			= {name="Mineshaft Escape", path="Repentance/Chased By Death V3.ogg", loop="true"},
	[Music.MUSIC_REVERSE_GENESIS]     			= {name="Genesis (reversed)", path="Repentance/backwards/Genesis ii Reverse Main Loop.ogg", loop="true", mul="1.2", layers={
		{path="Repentance/backwards/Genesis ii Reverse Basement Layer (Drums).ogg", mul="1.2"},
		{path="Repentance/backwards/Genesis ii Reverse Caves Layer (Bass).ogg", mul="1.2"},
		{path="Repentance/backwards/Genesis ii Reverse Depths Layer (Guitar).ogg", mul="1.2"},
		{path="Repentance/backwards/Genesis ii Reverse Downpour Layer (Guitar).ogg", mul="1.2"},
		{path="Repentance/backwards/Genesis ii Reverse Mines Layer (Drumz).ogg", mul="1.2"},
		{path="Repentance/backwards/Genesis ii Reverse Mausoleum Layer (Bass).ogg", mul="1.2"},
	}}
-- REPENTANCE END --
}

return vanillaMusicXML