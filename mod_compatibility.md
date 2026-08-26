## Ensuring mod is loaded
To test if the Cat Guy mod has been loaded, perform a nil check on the global `CatGuy` object:
```lua
if CatGuy then
   --- do stuff
end
```

If `CatGuy` doesn't exist, you can add a callback to `"CAT_GUY_POST_LOAD"`, which will be called once the Cat Guy mod has loaded.
```lua
yourMod:AddCallback("CAT_GUY_POST_LOAD", function(_)
  --- do stuff
end)
```

## TempoDefs
To make a modded/replaced vanilla song work with the mod, you will have to add a "tempo definition" for said mod. A tempo definition, or `TempoDef`, is an object with the following fields:

```lua
---@class TempoDef
---@field bpm number - initial tempo in BPM.
---@field bpms? table<integer, integer> - time indices (in milliseconds) of tempo changes (in BPM)
---
---@field offset? integer - offset of first beat in milliseconds. Defaults to 0 ms.
---@field intro? integer - length of intro in milliseconds. Defaults to 0 ms. Only necessary if there's BPM/time signature changes in the looping section.
---@field length? integer - length of looping section in milliseconds. Only necessary if there's BPM/time signature changes in the looping section.
---
---@field timeSig? integer - initial time signature in beats per bar. Defaults to 4. -1 disables time signature stuff.
---@field timeSigs? table<integer, integer> - beat indices of time signature changes (in beats per bar)
---@field triplet? boolean - true if song is initially in triplet time. Affects fire delay.
---@field triplets? table<integer, boolean> - beat indices of triplet time changes. 

---@field priority? number - Higher priority tempo defs override lower or equal priority tempo defs for the same music. Defaults to 0.
```

To add a `TempoDef`, call `CatGuy.TempoManager:RegisterTempoDef` as follows:
```lua
CatGuy.TempoManager:RegisterTempoDef(Music.MUSIC_BASEMENT, {bpm = 140}) -- or with any other music ID
```

To add multiple definitions at once, call `CatGuy.TempoManager:RegisterTempoDefs` as follows:
```lua
CatGuy.TempoManager:RegisterTempoDefs({
   [Music.MUSIC_BASEMENT] = {bpm = 140},
   [Music.MUSIC_CELLAR]   = {bpm = 140, offset = 64}
})
```

## Relevant Issues
- https://github.com/TeamREPENTOGON/REPENTOGON/issues/910
- https://github.com/TeamREPENTOGON/REPENTOGON/issues/364
