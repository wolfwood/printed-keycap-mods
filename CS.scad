include <util.scad>;
include <trackpoint_notch.scad>;
include <settings.scad>;

use <CS-bindings/sculpted.scad>;
use <CS-bindings/thumb.scad>;
use <CS-bindings/convex.scad>;

prerendered=true;

module CS(type="R3") {
  if (prerendered) {
    CS_prerendered(type);
  } else {
    CS_from_source(type);
  }
}

module CS_from_source(type="R3") {
  if (type == "R3") {
    sculpted_key(type);
  } else if (type == "R3-homing") {
    sculpted_key("R3", homing=true);
  } else if (type == "R2") {
    sculpted_key(type);
  } else if (type == "R4") {
    mirror([0,1,0]) sculpted_key("R2");
  } else if (type == "R2L" || type == "R4R") {
    mirror([1,0,0]) thumb_key(type);
  } else if (type == "R3L" || type == "R3R") {
    // smoother feel if you don't print with the curved side at the top
    rotate([0,0,180]) thumb_key(type);
  } else if (type == "R4L" || type == "R2R") {
    // smoother feel if you don't print with the curved side at the top
    rotate([0,0,180]) thumb_key("R2L");
  } else if (type == "T1L") {
    thumb_key("T1");
  } else if (type == "T1R") {
    mirror([1,0,0]) thumb_key("T1");
  } else if (type == "R3x") {
    convex_key(type);
  } else {
    assert(false, str("unrecognized Chicago Steno keycap type: ", type));
  }
}

module CS_prerendered(type="R3") {
  if (type == "R3") {
    import("levs-CS/r3-middle-row.stl");
  } else if (type == "R3-homing") {
    import("levs-CS/r3-homing.stl");
  } else if (type == "R2") {
    rotate([0,0, 180]) import("levs-CS/r2r4-topbottom-rows.stl");
  } else if (type == "R4") {
    import("levs-CS/r2r4-topbottom-rows.stl");
  } else if (type == "R2L") {
    import("levs-CS/r2r4-side-columns.stl");
  } else if (type == "R3L") {
    //rotate([0,0, 180])
      import("levs-CS/r3-side-columns.stl");
  } else if (type == "R4L") {
    mirror([0,1,0]) import("levs-CS/r2r4-side-columns.stl");
  } else if (type == "T1L") {
    rotate([0,0, 180]) mirror([1,0,0]) import("levs-CS/thumb-1u.stl");
  } else if (type == "T1R") {
    import("levs-CS/thumb-1u.stl");
  } else {
    assert(false, str("unrecognized Chicago Steno keycap type: ", type));
  }
}

module printable(other=false) {
  difference(){
    rotate([0,0,other ? -45 : 135])
      rotate([0,(other ? 1 : -1)*45,0]) children();

    // nip off the edge so the keycap sticks better to the print bed
    h=5;
    cut_distance=4.9; // 5.6 is minimally invasive, but not as effective
    translate([0,0,-h/2 - cut_distance]) cube([40,40,h], center=true);
    rotate([0,90,-45])
      translate([0,0,-h/2 - cut_distance]) cube([40,40,h], center=true);
  }
}

index = false;

if (is_undef(keycap)) {
  let(x_spacing = is_list(grid_spacing) ? grid_spacing.x : grid_spacing, y_spacing = is_list(grid_spacing) ? grid_spacing.y : grid_spacing, stagger = is_undef(grid_stagger) ? 0 : grid_stagger ? y_spacing/2 : 0) {
    if (!index) { // middle
      printable() trackpoint_notch(far=true) CS("R3-homing");
      translate([0,y_spacing,0]) printable() trackpoint_notch(far=false) CS("R2");
      translate([x_spacing,stagger,0]) printable(true) mirror([1,0,0]) trackpoint_notch(far=false, index=true) CS("R3");
      translate([x_spacing,stagger+y_spacing,0]) printable(true) mirror([1,0,0]) trackpoint_notch(far=true, index=true) CS("R2");
    } else { // index
      printable(true) mirror([1,0,0]) trackpoint_notch(far=false, index=true) CS("R3-homing");
      translate([0,y_spacing,0]) printable(true) mirror([1,0,0]) trackpoint_notch(far=true, index=true) CS("R2");
      translate([x_spacing,stagger,0]) printable() trackpoint_notch(far=true, index=false) CS("R3");
      translate([x_spacing,stagger+y_spacing,0]) printable() trackpoint_notch(far=false, index=false) CS("R2");
    }
  }
} else {
  printable() CS(keycap);
}

if (debug_orientation) {
  grid_stagger = false;
  !let(x_spacing = is_list(grid_spacing) ? grid_spacing.x : grid_spacing, y_spacing = is_list(grid_spacing) ? grid_spacing.y : grid_spacing, stagger = is_undef(grid_stagger) ? 0 : grid_stagger ? y_spacing/2 : 0) {
    one = "T1L";
    two= "T1R";
    CS_from_source(two);
    translate([0,y_spacing,0]) CS_from_source(one);
    translate([x_spacing,stagger,0]) printable() CS_from_source(two);
    translate([x_spacing,stagger+y_spacing,0]) printable() CS_prerendered(one);
    translate([2*x_spacing,stagger,0]) printable() CS_prerendered(two);
    translate([2*x_spacing,stagger+y_spacing,0]) printable() CS_prerendered(one);
    translate([3*x_spacing,stagger,0]) CS_prerendered(two);
    translate([3*x_spacing,stagger+y_spacing,0]) CS_prerendered(one);
  }
}
