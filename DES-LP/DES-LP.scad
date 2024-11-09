use <../trackpoint_notch.scad>;
include <../settings.scad>;

use <DES-bindings/sculpted.scad>;

module DES(type="R3"){
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

module printable(type, other=false, trim=true) {
  difference(){
    rotate([0,0,(other ? -45 : 135) + (fans_on_left ? -90 : 0)])
      rotate([0,(other ? 1 : -1)*45,0])
      rotate([sculpt_compensation() ? -lookup_sculpted_sculpt(type) : 0, 0, 0])
      children();

    if(trim){
      // nip off the edge so the keycap sticks better to the print bed
      h=5;
      // for R3, 5.6 is minimally invasive, but not as effective
      cut_distance = lookup_sculpted_sculpt(type) != 0 && sculpt_compensation() ? 5.5 : 4.9;
      translate([0,0,-h/2 - cut_distance]) cube([40,40,h], center=true);
      if (trim_both_sides())
        rotate([90,0,-45])
          translate([0,0,-h/2 - cut_distance]) cube([40,40,h], center=true);
    }
  }
}


keycap = "R4";

if (is_undef(keycap)) {
  let(x_spacing = is_list(grid_spacing) ? grid_spacing.x : grid_spacing, y_spacing = is_list(grid_spacing) ? grid_spacing.y : grid_spacing, stagger = is_undef(grid_stagger) ? 0 : grid_stagger ? y_spacing/2 : 0) {
    *translate([0,y_spacing,0]) trackpoint_notch($x=1,$y=-1) DES("R2");
    trackpoint_notch($x=1,$y=1) DES("R3");
    *translate([x_spacing,stagger+y_spacing,0]) trackpoint_notch($x=-1,$y=-1) DES("R2R");
    *translate([x_spacing,stagger,0]) trackpoint_notch($x=-1,$y=1) DES("R3R");
  }
  } else {
  printable(keycap)
    DES(keycap);
}
