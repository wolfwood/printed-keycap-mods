use <../trackpoint_notch.scad>;
include <../settings.scad>;
use <../util/printable.scad>;

use <DES-bindings/unsculpted.scad>;
use <DES-bindings/chord.scad>;

function raw() = !is_undef(raw) && raw;

module DES(type="R3"){
  $fn=60;

  if (type == "R2L" || type == "R3L" || type == "R4L") {
    rotate([0,0, !raw() ? 180 : 0]) chord_key(type);
  } else if (type == "R2R") {
    mirror([1,0,0]) chord_key("R2L");
  } else if (type == "R3R") {
    mirror([1,0,0]) chord_key("R3L");
  } else if (type == "R4R") {
    mirror([1,0,0]) chord_key("R4L");
  } else {
    unsculpted_key(type);
  }
}

function sculpt_compensate(type) =
  name2id_unsculpted(type) >= 0 ? lookup_unsculpted_sculpt(type):
  name2id_chord(type) >= 0 ? lookup_chord_sculpt(type) :
  type == "R2R" || type == "R4L" ? lookup_chord_sculpt("R2L") :
  type == "R4R" ? lookup_chord_sculpt("R2L") :
  type == "R3R" ? lookup_chord_sculpt("R3L") :
  assert(false, str("invalid CS key type: ", type));

module printable(type, other=false, trim=true, noop=false) {
  _printable_choc(
                  // anywhere between 45 and 60 is reasonable, but I was happiest with 50 or 55
                  angle = 50,
                  surface_contact = 1.5,
                  surface_contact_stem = .75,
                   // XXX won't work for wide keys
                  // lookup keycap width (and add .89 for some reason?) instead of hardcoding
                  width = 17.16 + 0.89,
                  stem_depth = 1.4,
                  sculpt_compensate = sculpt_compensate(type),
                  type=type,
                  other=other,
                  trim=trim,
                  noop=noop)
    children();
}


module xxprintable(type, other=false, trim=true) {
  // anywhere between 45 and 60 is reasonable, but I was happiest with 50 or 55
  angle = 50;
  surface_contact = 1.5;

  // XXX won't work for wide keys
  // lookup keycap width (and add .89 for some reason?) instead of hardcoding
  width = 17.16 + .89;

  flip = other ? 1 : -1;

  // R2L gets rough bubbles on the upper part when facing the fan head on
  rotate([0,0,(other ? 180 : 0) + fan_rotation /*+ (type == "R2L" ? 15 : type == "R2R" ? -15 :
                                                  type == "R4L" ? -5 : type == "R4R" ?   5 :
                                                  0)*/])

  rotate([0,flip*angle,0])
    difference(){

    rotate([sculpt_compensation() ? sculpt_compensate(type) : 0, 0, 0])
      children();

    // nip off the edge so the keycap sticks better to the print bed
    if(trim){
      h=2*surface_contact;

      translate([flip*(width/2 - surface_contact*cos(angle)),0,0])
        rotate([0,flip*-angle,0]) translate([0,0,-h/2]) cube([2*h,60,h], center=true);
      if (trim_both_sides())
        translate([flip*-(width/2 - surface_contact*cos(angle)),0,0])
          rotate([0,flip*angle,0]) translate([0,0,-h/2]) cube([2*h,60,h], center=true);

      if (true) {
        surface_contact_stem = .75;
        h=2*surface_contact_stem;

        translate([flip*(5.7/2 +  1.05/2 - surface_contact_stem*cos(angle)), 0, -1.4])
          rotate([0,flip*-angle,0]) translate([0,0,-h/2]) cube([2*h,4,h], center=true);

        translate([flip*-(5.7/2 -  1.05/2 + surface_contact_stem*cos(angle)), 0, -1.4])
          rotate([0, flip*-angle,0]) translate([0,0,-h/2]) cube([2*h,4,h], center=true);

        // centered cut but not fixed width
        *translate([-5.7/2, 0, -1.4]) rotate([0,flip*-angle,0])
          translate([0,0,-1]) cube([6.5,4,2], center=true);
        *translate([5.7/2, 0, -1.4]) rotate([0, flip*-angle,0])
          translate([0,0,-1]) cube([6.5,4,2], center=true);
      }
    }
  }
}

//keycap = "R4R";
tp_caps = ["R2L", "R3L", "R2R", "R3R"];


if (is_undef(keycap)) {
  let(x_spacing = is_list(grid_spacing) ? grid_spacing.x : grid_spacing, y_spacing = is_list(grid_spacing) ? grid_spacing.y : grid_spacing, stagger = is_undef(grid_stagger) ? 0 : grid_stagger ? y_spacing/2 : 0) {
    let(keycap = tp_caps[0])
      translate([0,y_spacing,0]) printable(keycap, noop=raw()) trackpoint_notch($x=-1,$y=1) DES(keycap);
    let(keycap = tp_caps[1])
      printable(keycap, noop=raw()) trackpoint_notch($x=-1,$y=-1) DES(keycap);
    let(keycap = tp_caps[2])
      translate([x_spacing,stagger+y_spacing,0]) printable(keycap, noop=raw()) trackpoint_notch($x=-1,$y=-1) DES(keycap);
    let(keycap = tp_caps[3])
      translate([x_spacing,stagger,0]) printable(keycap, noop=raw()) trackpoint_notch($x=-1,$y=1) DES(keycap);
  }
} else {
  printable(keycap, noop=raw())
    DES(keycap);
}
