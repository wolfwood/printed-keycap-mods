keyboard = "santoku";

grid_spacing = [54,66];
grid_stagger = true;


// original code was for a prusa MK3 with the print cooling fan duct on the right of the extruder
// MK4 has fan ducts on the left (and front)
fans_on_left=true;


// use a chamfered notch rather than a hole that accommodates the entire trackpoint cap
// chamfer makes a lot of polygons and can fail to preview / consume a lot of RAM and CPU when rendering
function tp_chamfer() = $preview ? false : true;

// less than .05 requires more than 8 GB of RAM if rendered in the gui
// not sure if there's a size that lets previews work
function tp_chamfer_steps() = .05;
