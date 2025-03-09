use <../trackpoint_notch.scad>;
include <../settings.scad>;
use <../util/printable.scad>;
use <../util/key-table.scad>;
use <../util/logic.scad>;

use <CS-bindings/sculpted.scad>;
use <CS-bindings/thumb.scad>;
use <CS-bindings/convex.scad>;

prerendered=false;


// only deviations need to be listed
key_table = [
             // type       mirror rotate  other  base
             ["R2",        false, true, false,  "R4"],

             //["R3-homing", false, false, false],
             //["R2L",       false, false, true, ""],
             //["R3L",       false, false, true],
             //["R4L",       false, false, true],

             ["R3R",       true,  false, false, "R3L"],
             ["R2R",       false, true,  false, "R4L"],
             ["R4R",       true,  false, false, "R4L"],
             ["R2L",       true,  true,  true,  "R4L"],

             ["T1R",       true,  false, false, "T1L"],
             ["T15R",      true,  false, false, "T15L"],

             ["T0R",       true,  false, false, "T0L"],
             ["T015R",     true,  false, false, "T015L"],
             ["T0175R",    true,  false, false, "T0175L"],
             ["T02R",      true,  false, false, "T02L"],

             ["TW15R",     true,  false, false, "TW15L"],
             ["TW015R",    true,  false, false, "TW015L"],
             ];


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

  base = base_key(type, key_table);
  r = rotate_key(type, key_table);
  m = mirror_key(type, key_table);
  homing = homing_key(type, key_table);

  rotate([0,0, r ? 180 : 0])
    mirror([m ? 1 : 0, 0, 0])
    invert_offset(x = xor(r,m), y = r){
    if (name2id_thumb(base) != -1) {
      thumb_key(base, homing=homing);
    } else if (name2id_sculpted(base) != -1) {
      sculpted_key(base, homing=homing);
    } else if (name2id_convex(base) != -1) {
      convex_key(base, homing=homing);
    } else {
      assert(false, str("unrecognized CS keycap type: ", type, " base: ", base));
    }
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

function lookup_sculpt(type) =
  let(invert = rotate_key(type, key_table) ? -1 : 1,
      type = base_key(type, key_table))
  name2id_sculpted(type) >= 0 ? invert * lookup_sculpted_sculpt(type) :
  name2id_thumb(type) >= 0 ? invert * lookup_thumb_sculpt(type) :
  name2id_convex(type) >= 0 ? invert * lookup_convex_sculpt(type) :
  assert(false, str("invalid CS key type: ", type));

module printable(type, trim=true, reverse_sculpt=false, noop=false, flip) {
  _printable_choc(angle = 55,
                  surface_contact = 1.5,
                  surface_contact_stem = 1,
                  width = (type == "T015R" || type == "T0175R" || type == "T02R" ||  type == "T015L" || type == "T0175L" || type == "T02L" || type == "T15R" || type == "T15L") ? 15.65 /*15.923*/ : 17.2,
                  sculpt_compensate = lookup_sculpt(type),
                  type = type,
                  flip = is_undef(flip) ? flip_key(type, key_table) : flip,
                  trim = trim,
                  noop = noop)
    children();
}


//keycap = "R4R";

index = true;
lateral = true;
// for laterals, the notch facing up gives a cleaner notch,
// but notch facing down gives a cleaner lateral chording edge
notch_up = lateral && index ? false : true;

function notch_up(x) =
  let(x = is_undef(x) ? $x : x)
  x > 0 ? !notch_up : notch_up;

function raw() = !is_undef(raw) && raw;

tp_caps = lateral ? index
  ? ["R2L", "R3L", "R2R", "R3R"]
  : ["R2R", "R3R", "R2", "R3"]
  : ["R2", "R3", "R2", "R3"];


if (is_undef(keycap)) {
  let(x_spacing = is_list(grid_spacing) ? grid_spacing.x : grid_spacing,
      y_spacing = is_list(grid_spacing) ? grid_spacing.y : grid_spacing,
      stagger = is_undef(grid_stagger) ? 0 : grid_stagger ? y_spacing/2 : 0) {

    if (is_undef(tpkey) || tpkey == "R2-near")
      let(keycap = tp_caps[0], $x=1,$y=-1)
        translate(is_undef(tpkey) ? [0,y_spacing,0] : [0, 0, 0])
        printable(keycap, noop=raw(), flip = notch_up()) trackpoint_notch() CS(keycap);

    if (is_undef(tpkey) || tpkey == "R3-homing")
      let(keycap = tp_caps[1], $x=1,$y=1)
        printable(keycap, noop=raw(), flip = notch_up()) trackpoint_notch() CS(keycap);

    if (is_undef(tpkey) || tpkey == "R2-far")
      let(keycap = tp_caps[2], $x=-1,$y=-1)
        translate(is_undef(tpkey) ? [x_spacing,stagger+y_spacing,0] : [0, 0, 0])
        printable(keycap, noop=raw(), flip = notch_up()) trackpoint_notch() CS(keycap);

    if (is_undef(tpkey) || tpkey == "R3")
      let(keycap = tp_caps[3], $x=-1,$y=1)
        translate(is_undef(tpkey) ? [x_spacing,stagger,0] : [0, 0, 0])
        printable(keycap, noop=raw(), flip = notch_up()) trackpoint_notch() CS(keycap);
  }
} else {
  printable(keycap, noop=raw()) CS(keycap);
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
