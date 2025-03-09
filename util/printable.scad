include <../settings.scad>;

module _printable_choc(angle, surface_contact, surface_contact_stem, width, sculpt_compensate,
                       stem_width = 5.7, stem_thickness=1.05, stem_depth=1.1,
                  type, flip=false, trim=true, noop=false) {
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
      if(trim){
        h=2*surface_contact;

        translate([flipper*(width/2 - surface_contact*cos(angle)),0,0])
          rotate([0,flipper*-angle,0]) translate([0,0,-h/2]) cube([2*h,60,h], center=true);
        if (trim_both_sides())
          translate([flipper*-(width/2 - surface_contact*cos(angle)),0,0])
            rotate([0,flipper*angle,0]) translate([0,0,-h/2]) cube([2*h,60,h], center=true);

        if (true) {
          h=2*surface_contact_stem;

          translate([flipper*(stem_width/2 + stem_thickness/2 - surface_contact_stem*cos(angle)), 0, -stem_depth])
            rotate([0,flipper*-angle,0]) translate([0,0,-h/2]) cube([2*h,4,h], center=true);

          translate([flipper*-(stem_width/2 - stem_thickness/2 + surface_contact_stem*cos(angle)), 0, -stem_depth])
            rotate([0, flipper*-angle,0]) translate([0,0,-h/2]) cube([2*h,4,h], center=true);
        }
      }
    }
  }
}
