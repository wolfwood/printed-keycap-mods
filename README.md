# Modify Keycaps to Fit Around Trackpoint
This code takes open source, 3D printable key caps, such as LPX and Chicago Steno and cuts notches to make room for a trackpoint's rubber dome. It does this for the Santoku keyboard, or ortholinear keyboards with MX or choc spacing. but it could be modified to accommodate any column-staggered or ortholinear keyboard.

It also positions the keycaps for printing, using Lev Popov's suggestions for FDM printing keycaps.

# Placement
Two trackpoint placements are supported. The upper left corner of the home key, "index" or *index=true*, and the upper right corner of the home key, "middle" or *index=false*.

# Profiles
Since LPX is a symmetrical, flat profile, right now only a single keycap is generated. This is one that sits nearer to the trackpoint in the columns on either side of it.  The keycap that sits farther away can be used without cutting a notch. Suppor tfor a homing key could be added.

For Chicago Steno, an array of 4 keycaps is rendered, with the appropriate notch depending on *index* or *middle* placement. The keycaps are R3 homing, R3 and two R2s.

# Usage
Keycaps can be rendered using `make`. first edit `settings.scad` to set the keyboard, and optionally the grid spacing (only used by Chicago Steno for now). If run without arguments, `make` will render all profiles and positions for a given board. To save render time you can invoke a specific target such as `make lpx-index` or `make cs-middle`.

# Suggestions Welcome!
Please open an issue to request support for new keycaps, keyboards, etc. I'd like to expand this tool to accommodate as many uses as possible.
