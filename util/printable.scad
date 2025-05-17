include <../settings.scad>;
use <debug.scad>;


 module _printable(angle, surface_contact, surface_contact_stem, width, sculpt_compensate,
                  cuts=0,
                  stem_width = 5.7, stem_thickness=1.05, stem_depth=1.1,
                  type, flip=false, trim=true, noop=false, debug=false) {
  flipper = flip ? 1 : -1;

  if (noop) {
    children();
  } else {
    rotate([0,0,(flip ? 180 : 0) +  fan_rotation])
      rotate([0,flipper*angle,0])
      difference(){
      rotate([sculpt_compensation() ? sculpt_compensate : 0, 0, 0])
        children();

      // nip off the edge so the keycap sticks better to the print bed
      debug(debug) if(trim){
        h=2*surface_contact;

        translate([flipper*(width/2 - surface_contact*cos(angle)),0,0])
          rotate([0,flipper*-angle,0]) translate([0,0,-h/2]) cube([2*h,60,h], center=true);
        if (trim_both_sides())
          translate([flipper*-(width/2 - surface_contact*cos(angle)),0,0])
            rotate([0,flipper*angle,0]) translate([0,0,-h/2]) cube([2*h,60,h], center=true);

        if (cuts == 2) {
          h=2*surface_contact_stem;

          translate([flipper*(stem_width/2 + stem_thickness/2 - surface_contact_stem*cos(angle)), 0, -stem_depth])
            rotate([0,flipper*-angle,0]) translate([0,0,-h/2]) cube([2*h,8,h], center=true);

          translate([flipper*-(stem_width/2 - stem_thickness/2 + surface_contact_stem*cos(angle)), 0, -stem_depth])
            rotate([0, flipper*-angle,0]) translate([0,0,-h/2]) cube([2*h,8,h], center=true);
        } else if (cuts == 1) {
          h=2*surface_contact_stem;

          translate([flipper*(stem_thickness/2 - surface_contact_stem*cos(angle)), 0, -stem_depth])
            rotate([0,flipper*-angle,0]) translate([0,0,-h/2]) cube([2*h,6,h], center=true);
        } else if (cuts == 4) {
          h=1.5*surface_contact_stem;

          translate([flipper*(stem_width/2 + stem_thickness/2 - surface_contact_stem*cos(angle)), 0, -stem_depth])
            rotate([0,flipper*-angle,0]) translate([0,0,-h/2]) cube([2*h,8,h], center=true);

          translate([flipper*-(stem_width/2 - stem_thickness/2 + surface_contact_stem*cos(angle)), 0, -stem_depth])
            rotate([0, flipper*-angle,0]) translate([0,0,-h/2]) cube([2*h,8,h], center=true);

          translate([flipper*(stem_width/2 - stem_thickness/2 + surface_contact_stem*cos(90-angle)), 0, -stem_depth])
            rotate([0,flipper*(90-angle),0]) translate([0,0,-h/2]) cube([2*h,8,h], center=true);

          translate([flipper*-(stem_width/2 + stem_thickness/2 - surface_contact_stem*cos(90-angle)), 0, -stem_depth])
            rotate([0, flipper*(90-angle),0]) translate([0,0,-h/2]) cube([2*h,8,h], center=true);
        }
      }
    }
  }
}

module _printable_choc(angle, surface_contact, surface_contact_stem, width, sculpt_compensate,
                  stem_width = 5.7, stem_thickness=1.05, stem_depth=1.1,
                  type, flip=false, trim=true, noop=false, debug=false) {
  _printable(cuts = 2,
             angle = angle, surface_contact = surface_contact,
             surface_contact_stem = surface_contact_stem, width = width,
             sculpt_compensate = sculpt_compensate, stem_width = stem_width,
             stem_thickness = stem_thickness, stem_depth = stem_depth, type = type,
             flip = flip, trim = trim, noop = noop, debug = debug)
    children();
}

module _printable_mx(angle, surface_contact, surface_contact_stem, width, sculpt_compensate,
                  stem_thickness=5.5, stem_depth=1.1,
                  type, flip=false, trim=true, noop=false, debug=false) {
  _printable(cuts = 1,
             angle = angle, surface_contact = surface_contact,
             surface_contact_stem = surface_contact_stem, width = width,
             sculpt_compensate = sculpt_compensate,
             stem_thickness = stem_thickness, stem_depth = stem_depth, type = type,
             flip = flip, trim = trim, noop = noop, debug = debug)
    children();
}

