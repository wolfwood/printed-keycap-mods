use <../trackpoint_notch.scad>;
include <../settings.scad>;
use <../util/printable.scad>;
use <../util/key-table.scad>;

use <DES-bindings/unsculpted.scad>;
use <DES-bindings/chord.scad>;


// only deviations need to be listed
key_table = [
             // type       mirror rotate  flip  base
             //["R2L",     true,  false, true,  ""],
             ["R2R",       true,  false, false, "R2L"],
             ["R3R",       true,  false, false, "R3L"],
             ["R4R",       true,  false, false, "R4L"],
             ];


module DES(type="R3"){
  $fn=60;

  base = base_key(type, key_table);
  homing = is_homing_key(type, key_table);

  rotate([0,0, rotate_key(type, key_table) && !raw() ? 180 : 0])
    mirror([mirror_key(type, key_table) ? 1 : 0, 0, 0]) {
    if (name2id_chord(base) != -1) {
      chord_key(base, homing=homing);
    } else if (name2id_unsculpted(base) != -1) {
      unsculpted_key(base, homing=homing);
    } else {
      assert(false, str("unrecognized DES uLP keycap type: ", type, " base: ", base));
    }
  }
}

function lookup_sculpt(type) =
  let(invert = rotate_key(type, key_table) ? -1 : 1,
      type = base_key(type, key_table))
  name2id_unsculpted(type) >= 0 ? invert * lookup_unsculpted_sculpt(type):
  name2id_chord(type) >= 0 ? invert * lookup_chord_sculpt(type) :
  assert(false, str("invalid DES-uLP key type: ", type));

function lookup_width(type) =
  let(type = base_key(type, key_table))
  name2id_unsculpted(type) >= 0 ? lookup_unsculpted_width(type) :
  name2id_chord(type) >= 0 ? lookup_chord_width(type) :
  assert(false, str("invalid CS key type: ", type));

module printable(type, trim=true, noop=false, flip) {
  _printable_choc(
                  // anywhere between 45 and 60 is reasonable, but I was happiest with 50 or 55
                  angle = 50,
                  surface_contact = 1.5,
                  surface_contact_stem = .75,
                  // add .89 for some reason?
                  width = lookup_width(type) + 0.89,
                  stem_depth = 1.4,
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

// for trackpoint keys, the notch facing up gives a cleaner notch,
// but notch facing down gives a cleaner lateral chording edge
// prioritize keycap surface over notch
function notch_up(key, table) =
  let(left_notch = $x < 0)
  !is_lateral_key(key, table)
  ? left_notch
  : flip_key(key, table);

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
        printable(keycap, noop=raw(), flip = notch_up(keycap, key_table)) trackpoint_notch() DES(keycap);

    if (is_undef(tpkey) || tpkey == "R3-homing")
      let(keycap = tp_caps[1], $x=1,$y=1)
        printable(keycap, noop=raw(), flip = notch_up(keycap, key_table)) trackpoint_notch() DES(keycap);

    if (is_undef(tpkey) || tpkey == "R2-far")
      let(keycap = tp_caps[2], $x=-1,$y=-1)
        translate(is_undef(tpkey) ? [x_spacing,stagger+y_spacing,0] : [0, 0, 0])
        printable(keycap, noop=raw(), flip = notch_up(keycap, key_table)) trackpoint_notch() DES(keycap);

    if (is_undef(tpkey) || tpkey == "R3")
      let(keycap = tp_caps[3], $x=-1,$y=1)
        translate(is_undef(tpkey) ? [x_spacing,stagger,0] : [0, 0, 0])
        printable(keycap, noop=raw(), flip = notch_up(keycap, key_table)) trackpoint_notch() DES(keycap);
  }
} else {
  if(is_trackpoint_key(keycap, key_table)) {
    let($x=trackpoint_key_x(keycap, key_table), $y=trackpoint_key_y(keycap, key_table))
      printable(keycap, noop=raw(), flip=notch_up(keycap, key_table))
      trackpoint_notch()
      DES(keycap);
  } else {
    printable(keycap, noop=raw())
      DES(keycap);
  }
}
