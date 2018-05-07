# Civ Viewer

I'm playing around with the Godot game engine. This might become a map view / UI for [Otda3](https://github.com/midnightfreddie/otda3), or it may just remain a broken toy. I suppose it might be an intermediate viewer or tool for Civ3 graphics mods, but I don't know if that's a real use.

While not the primary point, at the beginning I'm seeing if Godot can read and display graphics from the game Civilization III.

- Godot doesn't natively read pcx
- Godot can load indexed png files, but the classes only expose the 32-bit color resulting image
- Tried writing some gdscript to read pcx files and succeeded
- substituted colors for transparency in the palette and alpha-keyed the civ colors
- Made a civ-color shader that rotates the alhpa-keyed civ color
- Used regions and sprites and displayed individual popheads
- Toying with using Civ3 terrain graphics as tilesets in Godot
