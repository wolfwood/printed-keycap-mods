# Modify Keycaps to Fit Around Trackpoint
This code takes open source, 3D printable key caps, such as LPX and Chicago Steno and cuts notches to make room for a trackpoint's rubber dome. It does this for the Santoku keyboard, or ortholinear keyboards with MX or choc spacing. However, it could be modified to accommodate any column-staggered or ortholinear keyboard.

It also positions the keycaps for printing, using Lev Popov's suggestions for FDM printing keycaps in [the LPX repo](https://github.com/levpopov/LPX) and in [his printables for Chicago Steno](https://www.printables.com/model/158865-chicago-steno-low-profile-keycaps-kailh-choc).

# Profiles
Since LPX is a symmetrical, non-sculpted profile, right now only two trackpoint-modded keycaps are generated. Support for a homing key could be added. No unmodified keycap is generated. Use the source *.stl* file.

For Chicago Steno, an array of 4 keycaps is rendered (or optionally, files for individual keycaps), with the appropriate notches depending on *index* or *middle* placement. The keycaps are R3 homing, R3 and two R2s (near and far).

# Placement
Two trackpoint placements are supported. The upper left corner of the home key, "index" or *index=true*, and the upper right corner of the home key, "middle" or *index=false*.

# Usage
This repository relies on submodules to include keycaps where possible. Either clone it with the command `git clone --recurse-submodules --remote-submodules` to automatically fetch submodules, or run `git submodule update --init --recursive` in an already cloned repo before using.

Keycaps can be rendered using `make`. first edit `settings.scad` to set the keyboard, and optionally the grid spacing (only used by Chicago Steno for now). If run without arguments, `make` will render all profiles and positions for a given board. To save render time you can invoke a specific target such as `make lpx` or `make cs-middle`. A set of unmodified Chicago Steno keycaps can be generated with `make cs`. The targets `cs-middle-solo` and `cs-index-solo` generate modified keycaps in individual *.stl*s rather than arrays.

I strongly recommend downloading [a development snapshot of OpenSCAD](https://openscad.org/downloads.html#snapshots) and replacing the `OPENSCAD=openscad` line at the begining of the Makefile with the path to the downloaded build (don't forget to `chmod +x` if using an AppImage), and enabling the `fast-csg` feature. I currently use `OPENSCAD=$(HOME)/downloads/OpenSCAD-2023.02.23.ai13670-x86_64.AppImage --enable=fast-csg --enable=lazy-union --enable=sort-stl` (sort-stl will probably be slower, but it's useful for detecting changes).

# FDM Printing Suggestions
Parts are positioned with a 45 degree Y and Z rotation. These recommendations come from @levpopov. The Y rotation produces a smoother surface than printing flat. The Z rotation slows the print head and gets maximum cooling on the top surface.

If using a keycap array *.stl*, split the model to objects in your slicer, then enable *complete individual objects*.

The main issue I've had has been with the bottom edge of the keycap partially or full detaching during the print. The support tweaks are meant to address this issue, along with the model modifications to flatten the edges the keycap rests on while printing.

  - *layer height* - I'm currently using 0.07 mm but 0.1 mm is also good. 0.15 is acceptable and definitely where you should start your testing before trying to print multiple keycaps.
  - *0% infill* - Lev said this helps with surface smoothness. also faster.
  - *enable supports* this thing is gonna tip over if you don't support it! the following are for traditional supports. tree supports are not effective. the whole model benefits from a solid support structure.
    - *Top contact Z distance* = 0.10 - get supports closer to the part
	- *Pattern spacing* = 1.5 - more supportive
  - *Complete individual objects* prints parts one at a time so there isn't stringing between keycaps ruining the top surface. you also need to split models with multiple keycaps, if using.

# SLA Printing Suggestions
??? Someone with a resin printer please tell us.

# Suggestions Welcome!
Please open an issue to request support for new keycaps, new keyboards, flexibility in selecting row variants, etc. I'd like to expand this tool to accommodate as many uses as possible.

# TODO
  - [x] fix orientation of 'from source' CS keycaps
  - [x] check if LPX needs 2 different notches now that santoku offset is corrected
  - [ ] reorg related keycap code into directories
  - [ ] means to specify arbitrary arrays of keycaps (in settings/from render command)
    - [ ] split array generation off from main keycap files (can be generic? or per-profile?)
  - [x] means to generate individual trackpoint notched keycaps, not in an array
    - [ ] communicate trackpoint notch location in a more clear and universal manner
  - [ ] way to add sprues to keycap arrays for commercial 3D printing? what about shrinkage?
