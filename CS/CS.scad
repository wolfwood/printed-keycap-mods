use <../trackpoint_notch.scad>;
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

module invert_offset(x=true, y=true, z=false) {
  if (is_undef($stem_offset)) {
    children();
  } else {
    temp = [$stem_offset.x * (x ? -1 : 1), $stem_offset.y * (y ? -1 : 1), $stem_offset.z * (z ? -1 : 1)];
    //echo("whut ", temp, $stem_offset, is_undef($stem_offset),  ($stem_offset * -1));
    children($stem_offset = temp );
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
    invert_offset() sculpted_key(type);
  } else if (type == "R2L"){
    mirror([1,0,0]) invert_offset(y=false) thumb_key("R2L");
  } else if( type == "R4R") {
    mirror([1,0,0]) invert_offset(x=false) thumb_key("R2L");
  } else if (type == "R3L" || type == "R3L-homing"){
    // smoother feel if you don't print with the curved side at the top
    rotate([0,0,180])
      invert_offset()
      thumb_key("R3L", homing = type == "R3L-homing");
  } else if (type == "R3R") {
    // smoother feel if you don't print with the curved side at the top
    rotate([0,0,180])
      thumb_key("R3L");
  } else if (type == "R4L") {
    // smoother feel if you don't print with the curved side at the top
    rotate([0,0,180]) invert_offset() thumb_key("R2L");
  } else if (type == "R2R") {
    // smoother feel if you don't print with the curved side at the top
    rotate([0,0,180]) thumb_key("R2L");
  } else if (type == "T1L") {
    // smoother feel if you don't print with the curved side at the top
    rotate([0,0,180]) invert_offset() thumb_key("T1");
  } else if (type == "T1R") {
    mirror([1,0,0]) invert_offset(x=false) thumb_key("T1");
  } else if (type == "T0L") {
    // smoother feel if you don't print with the curved side at the top
    invert_offset() thumb_key("T0");
  } else if (type == "T0R") {
    mirror([1,0,0]) invert_offset(x=false) thumb_key("T0");
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

function sculpt_compensate(type) =
  name2id_scuplt(type) >= 0 ? lookup_sculpted_sculpt(type) * (type == "R2" ? -1 : 1) :
  name2id_thumb(type) >= 0 ? lookup_sculpted_thumb(type) :
  type == "R2R" || type == "R4L" ? -lookup_sculpted_thumb("R2L") :
  type == "R4R" ? lookup_sculpted_thumb("R2L") :
  type == "R3R" ? -lookup_sculpted_thumb("R3L") :
  type == "T1R" ? lookup_sculpted_thumb("T1") :
  type == "T1L" ? -lookup_sculpted_thumb("T1") :
  type == "T0R" ? lookup_sculpted_thumb("T0") :
  type == "T0L" ? -lookup_sculpted_thumb("T0") :
  name2id_convex(type) >= 0 ? lookup_sculpted_convex(type) :
  assert(false, str("invalid CS key type: ", type));

module printable(type, other=false, trim=true, reverse_sculpt=false) {
  difference(){
    rotate([0,0,(other ? -45 : 135) + (fans_on_left ? -90 : 0)])
      rotate([0,(other ? 1 : -1)*45,0])
      rotate([sculpt_compensation() ? sculpt_compensate(type) * (reverse_sculpt ? -1 : 1) : 0, 0, 0])
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

index = false;
lateral=true;
// for laterals, the notch facing up fives a cleaner notch,
// but notch facing down gives a cleaner lateral chrording edge
notch_up = false;

if (is_undef(keycap)) {
  let(x_spacing = is_list(grid_spacing) ? grid_spacing.x : grid_spacing, y_spacing = is_list(grid_spacing) ? grid_spacing.y : grid_spacing, stagger = is_undef(grid_stagger) ? 0 : grid_stagger ? y_spacing/2 : 0) {
    if (!index) { // middle
      if (is_undef(tpkey) || tpkey == "R3-homing")
        let (tpkey =  homing_dots() ? "R3-homing" : "R3")
          printable(tpkey)
          trackpoint_notch(far=true) CS(tpkey);
      if (is_undef(tpkey) || tpkey == "R2-near")
        translate(is_undef(tpkey) ? [0,y_spacing,0] : [0,0,0])
          let (tpkey = "R2R")
          printable(tpkey)
          trackpoint_notch(far=false) CS(tpkey);
      if (is_undef(tpkey) || tpkey == "R3")
        translate(is_undef(tpkey) ? [x_spacing,stagger,0] : [0,0,0])
          let (tpkey = "R3R")
          printable(tpkey, other=true)
          mirror([1,0,0])
          trackpoint_notch(far=false, index=true) CS(tpkey);
      if (is_undef(tpkey) || tpkey == "R2-far")
        translate(is_undef(tpkey) ? [x_spacing,stagger+y_spacing,0] : [0,0,0])
          let (tpkey = "R2")
          printable(tpkey, other=true)
          mirror([1,0,0])
          trackpoint_notch(far=true, index=true) CS(tpkey);

    } else { // index
      if (!lateral) {
        if (is_undef(tpkey) || tpkey == "R3-homing")
          let (tpkey =  homing_dots() ? "R3-homing" : "R3")
            printable(tpkey, other=true)
            trackpoint_notch($x=-1,$y=1,far=false, index=true)
            CS(tpkey);
        if (is_undef(tpkey) || tpkey == "R2-far")
          translate(is_undef(tpkey) ? [0,y_spacing,0] : [0,0,0])
            let (tpkey = "R2")
            printable(tpkey, other=true)
            trackpoint_notch($x=-1,$y=-1,far=true)
            CS(tpkey);
        if (is_undef(tpkey) || tpkey == "R3")
          translate(is_undef(tpkey) ? [x_spacing,stagger,0] : [0,0,0])
            let (tpkey = "R3")
            printable(tpkey)
            trackpoint_notch($x=1,$y=1,far=true) CS(tpkey);
        if (is_undef(tpkey) || tpkey == "R2-near")
          translate(is_undef(tpkey) ? [x_spacing,stagger+y_spacing,0] : [0,0,0])
            let (tpkey = "R2")
            printable(tpkey)
            trackpoint_notch($x=1,$y=-1,far=false) CS(tpkey);
      } else {
        if (is_undef(tpkey) || tpkey == "R3-homing")
          let (tpkey =  /*homing_dots() ? "R3L-homing" :*/ "R3R")
            printable(tpkey, other=notch_up)
            trackpoint_notch($x=-1,$y=1,far=false) CS("R3R");
        if (is_undef(tpkey) || tpkey == "R2-far")
          translate(is_undef(tpkey) ? [0,y_spacing,0] : [0,0,0])
            let (tpkey = "R2R")
            printable(tpkey, other=notch_up)
            trackpoint_notch($x=-1,$y=-1, far=true) CS(tpkey);
        if (is_undef(tpkey) || tpkey == "R3")
          translate(is_undef(tpkey) ? [x_spacing,stagger,0] : [0,0,0])
            let (tpkey = "R3L")
            printable(tpkey, other=!notch_up)
            trackpoint_notch($x=1,$y=1,far=true) rotate([0,0,180]) CS("R3L");
        if (is_undef(tpkey) || tpkey == "R2-near")
          translate(is_undef(tpkey) ? [x_spacing,stagger+y_spacing,0] : [0,0,0])
            let (tpkey = "R2L")
            printable(tpkey, other=!notch_up, reverse_sculpt=true)
            trackpoint_notch($x=1,$y=-1,far=false) rotate([0,0,180]) CS(tpkey);
      }
    }
  }
} else {
  printable(keycap) CS(keycap);
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
