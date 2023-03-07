include <../trackpoint_notch.scad>;
include <../settings.scad>;

use <CS-bindings/sculpted.scad>;
use <CS-bindings/thumb.scad>;
use <CS-bindings/convex.scad>;

prerendered=false;

module CS(type="R3") {
  if (prerendered) {
    CS_prerendered(type);
  } else {
    CS_from_source(type);
  }
}

module CS_from_source(type="R3") {
  $fn=60;

  if (type == "R3") {
    sculpted_key(type);
  } else if (type == "R3-homing") {
    sculpted_key("R3", homing=true);
  } else if (type == "R2") {
    mirror([0,1,0]) sculpted_key("R4");
  } else if (type == "R4") {
    sculpted_key(type);
  } else if (type == "R2L" || type == "R4R") {
    mirror([1,0,0]) thumb_key("R2L");
  } else if (type == "R3L" || type == "R3R") {
    // smoother feel if you don't print with the curved side at the top
    rotate([0,0,180]) thumb_key("R3L");
  } else if (type == "R4L" || type == "R2R") {
    // smoother feel if you don't print with the curved side at the top
    rotate([0,0,180]) thumb_key("R2L");
  } else if (type == "T1L") {
    // smoother feel if you don't print with the curved side at the top
    rotate([0,0,180]) thumb_key("T1");
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
  } else if (type == "R2L" || type == "R4R") {
    import("levs-CS/r2r4L-side-columns.stl");
  } else if (type == "R3L" || type == "R3R") {
    //rotate([0,0, 180])
      import("levs-CS/r3L-side-columns.stl");
  } else if (type == "R4L" || type == "R2R") {
    mirror([0,1,0]) import("levs-CS/r2r4L-side-columns.stl");
  } else if (type == "T1L") {
    rotate([0,0,180])
      mirror([1,0,0]) import("levs-CS/thumb-1u.stl");
  } else if (type == "T1R") {
    import("levs-CS/thumb-1u.stl");
  } else if (type == "R3x") {
    import("levs-CS/convex-1u-for-thumbs-or-inner-index-column.stl");
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
      if (is_undef(tpkey) || tpkey == "R3-homing") printable() trackpoint_notch(far=true) CS("R3-homing");
      if (is_undef(tpkey) || tpkey == "R2-near") translate(is_undef(tpkey) ? [0,y_spacing,0] : [0,0,0]) printable() trackpoint_notch(far=false) CS("R2");
      if (is_undef(tpkey) || tpkey == "R3") translate(is_undef(tpkey) ? [x_spacing,stagger,0] : [0,0,0]) printable(other=true) mirror([1,0,0]) trackpoint_notch(far=false, index=true) CS("R3");
      if (is_undef(tpkey) || tpkey == "R2-far") translate(is_undef(tpkey) ? [x_spacing,stagger+y_spacing,0] : [0,0,0]) printable(other=true) mirror([1,0,0]) trackpoint_notch(far=true, index=true) CS("R2");
    } else { // index
      if (is_undef(tpkey) || tpkey == "R3-homing") printable(true) mirror([1,0,0]) trackpoint_notch(far=false, index=true) CS("R3-homing");
      if (is_undef(tpkey) || tpkey == "R2-far") translate(is_undef(tpkey) ? [0,y_spacing,0] : [0,0,0]) printable(other=true) mirror([1,0,0]) trackpoint_notch(far=true, index=true) CS("R2");
      // if (is_undef(tpkey) || tpkey == "R3") translate([x_spacing,stagger,0] : [0,0,0]) printable() trackpoint_notch(far=true, index=false) CS("R3");
      //f (is_undef(tpkey) || tpkey == "R2-near") translate([x_spacing,stagger+y_spacing,0] : [0,0,0]) printable() trackpoint_notch(far=false, index=false) CS("R2");
       if (is_undef(tpkey) || tpkey == "R3") translate(is_undef(tpkey) ? [x_spacing,stagger,0] : [0,0,0]) printable(other=true) trackpoint_notch(far=true, index=false) rotate([0,0,180]) CS("R3L");
      if (is_undef(tpkey) || tpkey == "R2-near") translate(is_undef(tpkey) ? [x_spacing,stagger+y_spacing,0] : [0,0,0]) printable(other=true) trackpoint_notch(far=false, index=false) rotate([0,0,180]) CS("R2L");
    }
  }
} else {
  printable() CS(keycap);
}

debug_orientation=false;

if (debug_orientation) {
  grid_stagger = false;
  !let(x_spacing = is_list(grid_spacing) ? grid_spacing.x : grid_spacing, y_spacing = is_list(grid_spacing) ? grid_spacing.y : grid_spacing, stagger = is_undef(grid_stagger) ? 0 : grid_stagger ? y_spacing/2 : 0) {
    one = "T1L";
    two= "T1R";

    if (!is_undef(two)) CS_from_source(two);
    translate([0,y_spacing,0]) CS_from_source(one);
    if (!is_undef(two)) translate([x_spacing,stagger,0]) printable(two) CS_from_source(two);
    translate([x_spacing,stagger+y_spacing,0]) printable(one) CS_from_source(one);
    if (!is_undef(two)) translate([2*x_spacing,stagger,0]) printable(two) CS_prerendered(two);
    translate([2*x_spacing,stagger+y_spacing,0]) printable(one) CS_prerendered(one);
    if (!is_undef(two)) translate([3*x_spacing,stagger,0]) CS_prerendered(two);
    translate([3*x_spacing,stagger+y_spacing,0]) CS_prerendered(one);
  }
}
