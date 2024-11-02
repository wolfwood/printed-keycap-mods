use <../trackpoint_notch.scad>;
include <../settings.scad>;

use <LC-bindings/sculpted.scad>;

module LC(type="R3"){
  $fn=60;

  if (type == "R2L") {
    mirror([1,0,0]) sculpted_key("R2R");
  } else if (type == "R3L") {
    mirror([1,0,0]) sculpted_key("R3R");
  } else if (type == "R4L") {
    mirror([1,0,0]) sculpted_key("R4R");
  } else {
    sculpted_key(type);
  }
}

if (is_undef(keycap)) {
  let(x_spacing = is_list(grid_spacing) ? grid_spacing.x : grid_spacing, y_spacing = is_list(grid_spacing) ? grid_spacing.y : grid_spacing, stagger = is_undef(grid_stagger) ? 0 : grid_stagger ? y_spacing/2 : 0) {
    *translate([0,y_spacing,0]) trackpoint_notch($x=1,$y=-1) LC("R2L");
    trackpoint_notch($x=1,$y=1) LC("R3L");
    *translate([x_spacing,stagger+y_spacing,0]) trackpoint_notch($x=-1,$y=-1) LC("R2R");
    *translate([x_spacing,stagger,0]) trackpoint_notch($x=-1,$y=1) LC("R3R");
  }
  } else {
  //printable()
    LC(keycap);
}
