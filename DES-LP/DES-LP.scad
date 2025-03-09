use <../trackpoint_notch.scad>;
include <../settings.scad>;
use <../util/printable.scad>;
use <../util/key-table.scad>;

use <DES-bindings/sculpted.scad>;


// only deviations need to be listed
key_table = [
             ];


module DES(type="R3"){
  $fn=60;

  base = base_key(type, key_table);
  homing = homing_key(type, key_table);

  rotate([0,0, rotate_key(type, key_table) && !raw() ? 180 : 0])
    mirror([mirror_key(type, key_table) ? 1 : 0, 0, 0]) {
    if (name2id_sculpted(base) != -1) {
      sculpted_key(base, homing=homing);
    } else {
      assert(false, str("unrecognized DES LP keycap type: ", type, " base: ", base));
    }
  }
}

module printable(type, trim=true, noop=false, flip) {
  invert = rotate_key(type, key_table) ? -1 : 1;
  type = base_key(type, key_table);

  _printable_choc(angle = 50,
                  surface_contact = 1.5,
                  surface_contact_stem = .75,
                  width = 17.16 + 0.89,
                  stem_depth = 1.4,
                  sculpt_compensate =  invert * -lookup_sculpted_sculpt(type),
                  type = type,
                  flip = is_undef(flip) ? flip_key(type, key_table) : flip,
                  trim = trim,
                  noop = noop)
    children();
}


//keycap = "R4";

notch_up = true;

function notch_up(x) =
  let(x = is_undef(x) ? $x : x)
  x > 0 ? !notch_up : notch_up;

function raw() = !is_undef(raw) && raw;

tp_caps = ["R2", "R3", "R2", "R3"];


if (is_undef(keycap)) {
  let(x_spacing = is_list(grid_spacing) ? grid_spacing.x : grid_spacing,
      y_spacing = is_list(grid_spacing) ? grid_spacing.y : grid_spacing,
      stagger = is_undef(grid_stagger) ? 0 : grid_stagger ? y_spacing/2 : 0) {

    if (is_undef(tpkey) || tpkey == "R2-near")
      let(keycap = tp_caps[0], $x=1,$y=-1)
        translate(is_undef(tpkey) ? [0,y_spacing,0] : [0, 0, 0])
        printable(keycap, noop=raw(), flip = notch_up()) trackpoint_notch() DES(keycap);

    if (is_undef(tpkey) || tpkey == "R3-homing")
      let(keycap = tp_caps[1], $x=1,$y=1)
        printable(keycap, noop=raw(), flip = notch_up()) trackpoint_notch() DES(keycap);

    if (is_undef(tpkey) || tpkey == "R2-far")
      let(keycap = tp_caps[2], $x=-1,$y=-1)
        translate(is_undef(tpkey) ? [x_spacing,stagger+y_spacing,0] : [0, 0, 0])
        printable(keycap, noop=raw(), flip = notch_up()) trackpoint_notch() DES(keycap);

    if (is_undef(tpkey) || tpkey == "R3")
      let(keycap = tp_caps[3], $x=-1,$y=1)
        translate(is_undef(tpkey) ? [x_spacing,stagger,0] : [0, 0, 0])
        printable(keycap, noop=raw(), flip = notch_up()) trackpoint_notch() DES(keycap);
  }
} else {
  printable(keycap, noop=raw())
    DES(keycap);
}
