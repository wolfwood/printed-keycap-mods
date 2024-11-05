keyboard = "santoku";

grid_spacing = [54,66];
grid_stagger = true;


// original code was for a prusa MK3 with the print cooling fan duct on the right of the extruder
// MK4 has fan ducts on the left (and front)
fans_on_left=true;


// === Aesthetics ===

// unnecessary, but you might prefer symmetrical sides, or you might prefer one side to be unblemished
function trim_both_sides() = false;

// by default, the layer lines on sculpted keycaps do not run north-south. this corrects this at the
// expense of trimmed edges that run at an angle. if the look of this bothers you, disable here
function sculpt_compensation() = true;


// === Trackpoint ===

// whether to add bumps to index finger home row keys for tp keys
function homing_dots() = false;

// use a chamfered notch rather than a hole that accommodates the entire trackpoint cap
// chamfer makes a lot of polygons and can fail to preview / consume a lot of RAM and CPU when rendering
function tp_chamfer() = $preview ? false : true;

// less than .05 requires more than 8 GB of RAM if rendered in the gui
// not sure if there's a size that lets previews work
function tp_chamfer_steps() = .05;

// === Experimental ===

// an alternative version of the self-leveling trackpoint notch cutter that doesn't remove material
// from parts of the keycap that sit lower than the necessary clearance. the down side is that the
// resulting notch is not circular. also it uses significantly more CPU and memory.
function tp_uniform_depth() = false;

// the uniform depth algorithm samples the cross section of the keycap, setting the trackpoint cap as
// the origin and sweeping across the corner of the keycap (the angle could be increased for offset
// trackpoints). this is the number of degrees between samples, ideally a number that divides 90
// evenly. compution does not scale linearly with this as expected, but larger numbers risk missing
// sharp keycap features.
function tp_rotational_steps() = 10;
