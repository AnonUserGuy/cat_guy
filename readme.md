<!-- This file is converted to the steam workshop description automatically. Be careful to not use elements that steam markup doesn't support. -->
<!-- All headers are downgraded by 1, anchor links are removed, inline code blocks are replaced with quoted text, and html comments are removed. -->

#### This mod requires **REPENTOGON** to work! Visit https://steamcommunity.com/sharedfiles/filedetails/?id=3127536138 for more information!

***NOTE: This mod currently isn't compatible with most music mods (see [Compatibility](#compatibility) section below). Check for compatibility before playing with any music mods!***

# Percy: The Musical Cat! [WIP]
Percy (AKA Cat Guy) is a character with stats similar to Cain (2 red hearts, higher speed, lower range) but lacking the high base damage and multiplier. Instead to deal damage, Percy has a starting item unique to the mod: Mom's Headphones!

### Mom's Headphones
A passive item from treasure rooms, Mom's Headphones completely change tear shooting mechanics. Instead of being able to hold a fire button to shoot continuously, now the fire button must be pressed for each shot. The button can be mashed to shoot tons of tears, but they will do significantly less damage if you shoot faster than your tear rate would normally allow. So, instead of mashing you should...

#### Shoot to the Beat!
With Mom's Headphones, if you shoot on-beat to the music, your tears will do more damage!
- Tears shot *perfectly* on-beat will do x2.0 damage!
- Tears shot *perfectly* off-beat will do x0.75 damage.

There's more bias towards decreasing your damage (only ~33% of shots do more than x1.0 damage), so you'll have to be precise if you want Mom's Headphones to be a damage up rather than a damage down.

Given these mechanics, its more beneficial to receive damage ups than tears ups. While getting a high enough tear rate will allow you to shoot over twice per beat without encountering the tear rate damage down, it's pretty hard to maintain consistent rhythm at those speeds.

#### Synergies
Mom's Headphones have lots of synergies, including:
- **Soy Milk/Marked** - Tears go back to being fired continually again. Damage up for on-beat tears still applies.
- **Brimstone/Chocolate Milk/other charged shots** - Damage up for releasing shots on-beat.
- **Ludovico Technique** - Damage varies with beat of music.
- **C Section** - Damage up for firing fetuses on-beat. First fetus takes 0.5/1/2 beats to fire depending on your tear rate.
- **Tooth and Nail** - Isaac turns to stone every 1/2/4 measures instead of every 6 seconds. 


## Tainted Percy
Instead of leaning into musical mechanics, Tainted Percy more-so leans into cat themed mechanics. Tainted Percy is a ghost, like the Lost or Tainted Lost. They have no mantle, instead starting with 3 extra lives. When taking HP ups, they will gain extra lives proportional to the amount of red heart containers gained. They also start with a pocket active unique to the mod: Underhands.

### Underhands
The Underhands are a 6 charge active item found in devil and curse rooms that, upon first picking up, grants Isaac 3 extra lives. If Isaac dies and spends one of these lives, they will revive with only one heart container (assuming they have health).

When used, Isaac receives a 3-second shield. For the remainder of the current room, dying will revive Isaac in that room rather than outside of it. While the Underhands are not too useful for most characters, they are a boon for the Lost or Tainted Percy. 

## Configuration
This mod supports configuration through [Mod Config Menu](https://steamcommunity.com/sharedfiles/filedetails/?id=3701683951). 

Alternatively, configuration can be changed by editing `cat_guy_config.lua`.

You'll likely want to adjust input latency (default values are provided based on my own input latency and will probably not work great for you) and set a key to restart the game's music (defaults to `/`, useful if rhythm tracking desyncs with the music).

## Compatibility
This mod currently supports:
- Some music mods
  - [Antibirth Music++](https://steamcommunity.com/sharedfiles/filedetails/?id=1547034524)
  - [Antibirth Music+++](https://steamcommunity.com/sharedfiles/filedetails/?id=2837511713)
  - Unsupported mods that *directly replace* the game's music **will likely cause issues**. 
    - EX: [Sacrilege Soundtrack](https://steamcommunity.com/sharedfiles/filedetails/?id=3727170471)
  - Unsupported mods that add new music in addition to the vanilla music should be fine, rhythm mechanics will just be disabled while the modded music is playing. 
    - EX: [Specialist Dance for Good Items](https://steamcommunity.com/sharedfiles/filedetails/?id=2575911103), [Soundtrack Menu](https://steamcommunity.com/sharedfiles/filedetails/?id=2491006386)
- [External Item Descriptions](https://steamcommunity.com/sharedfiles/filedetails/?id=836319872)
- [Mod Config Menu](https://steamcommunity.com/workshop/filedetails/?id=3701683951)

## Todo
- Add support for important music mods. (Flash music, [Soundtrack Menu](https://steamcommunity.com/sharedfiles/filedetails/?id=1933285222))
- Add animations for using, and being revived by, Underhands.
- Add more character costumes for Percy and Tainted Percy.
- Add unlock method for Percy and Tainted Percy.
- Add completion mark unlocks for Percy and Tainted Percy.

## Links
- Steam - https://steamcommunity.com/sharedfiles/filedetails/?id=3790558949
- GitHub - https://github.com/AnonUserGuy/cat_guy
