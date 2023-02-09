# Modify Keycaps to Fit Around Trackpoint
This code takes open source, 3D printable key caps, such as LPX and Chicago Steno and cuts notches to make room for a trackpoint's rubber dome. It does this for the Santoku keyboard, or ortholinear keyboards with MX or choc spacing. However, it could be modified to accommodate any column-staggered or ortholinear keyboard.

It also positions the keycaps for printing, using Lev Popov's suggestions for FDM printing keycaps.

# Profiles
Since LPX is a symmetrical, flat profile, right now only a single keycap is generated. This is one that sits nearer to the trackpoint in the columns on either side of it.  The keycap that sits farther away can be used without cutting a notch. Support for a homing key could be added.

For Chicago Steno, an array of 4 keycaps is rendered, with the appropriate notches depending on *index* or *middle* placement. The keycaps are R3 homing, R3 and two R2s.

# Placement
Two trackpoint placements are supported. The upper left corner of the home key, "index" or *index=true*, and the upper right corner of the home key, "middle" or *index=false*.

# Usage
This repository relies on submodules to include keycaps where possible. Either clone it with the command `git clone --recurse-submodules --remote-submodules` to automatically fetch submodules, or run `git submodule update --init --recursive` in an already cloned repo before using.

Keycaps can be rendered using `make`. first edit `settings.scad` to set the keyboard, and optionally the grid spacing (only used by Chicago Steno for now). If run without arguments, `make` will render all profiles and positions for a given board. To save render time you can invoke a specific target such as `make lpx` or `make cs-middle`.

# FDM Printing Suggestions
Parts are positioned with a 45 degree Y and Z rotation. These recommendations come from @levpopov. The Y rotation produces a smoother surface than printing flat. The Z rotation slows the print head and gets maximum cooling on the top surface.

If using a keycap array .stl, split the model to objects in your slicer, then enable *complete individual objects*.

The main issue I've had has been with the bottom edge of the keycap partially or full detaching during the print. The support tweaks are meant to address this issue, along with the model modifications to flatten the edges the keycap rests on while printing.

  - *0% infill* - Lev said this helps with surface smoothness
  - *Outer perimeters first* - helps keep the surface smooth? I've done this for better dimensional accuracy elsewhere but haven't done a good AB test here.
  - *enable supports* this thing is gonna tip over if you don't! the following are for traditional supports. tree supports are not effective. the whole model benefits from a solid support structure.
    - *Top contact Z distance* = 0.10 - get supports closer to the part
	- *Pattern spacing* = 1.5 - more supportive
  - *Complete individual objects* prints parts one at a time so there isn't stringing between keycaps ruining the top surface. you also need to split models with multiple keycaps, if using.

# SLA Printing Suggestions
??? Someone with a resin printer please tell us.

# Suggestions Welcome!
Please open an issue to request support for new keycaps, new keyboards, flexibility in selecting row variants, etc. I'd like to expand this tool to accommodate as many uses as possible.
