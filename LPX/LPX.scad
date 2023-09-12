include <../settings.scad>
use <../trackpoint_notch.scad>

module LPX() {
  translate([-1.605/*+.037*/,-29.001/*-28.96958*/,-9.02 + 2.7644 +.001])
    rotate([48.5,0,90]) import("../includes/LPX/LPX.stl");
}

leg_cube = [7.2, 3.2, 6];
leg_cube_position = [0, 0, -leg_cube.z/2 + 1.3];

module LPX_legs() {
  intersection(){
    LPX();
    translate(leg_cube_position) cube(leg_cube, center=true);
  }
}
module LPX_shell() {
  difference() {
    LPX();
    translate(leg_cube_position-[0, 0, .001]) cube(leg_cube, center=true);
  }
}

module offset_LPX(pos=[0,1,0]) {
  if (pos == [0,0,0]) {
    LPX();
  } else {
    LPX_shell();
    translate(pos) LPX_legs();
    translate([-7,-7.1,0]) cube([.8,1,1.4]+2*pos);
  }
}

module chording() {
  difference() {
    union()
      children();

    //let (r = 1.5, y = 13.75 - 1.5*r, x=r*2, a=11) {
    let (r = 2.5, y = 13.75 +.59- 1.5*r, x=r*2, a=11) {
      translate([-6.35+.4,0,4-r]) rotate([0,a,0]) difference() {
	translate([-x,-y/2-3*r/4,0]) cube([x,y+1.5*r,x]);
	rotate([-90,0,0]) cylinder($fn=120,r=r,h=y,center=true);
	translate([0,y/2,0]) sphere($fn=120,r=r);
	translate([0,-y/2,0]) sphere($fn=120,r=r);
      }
    }
  }
}

module printable() {
  rotate([0,0,-135 + (fans_on_left ? -90 : 0)]) rotate([-48.5,0,0]) rotate([0,0,-90]) children();
}

// LPX is symmetrical so the notch on lower right is the same as upper left
//  also its a very small footprint, so the far (small) notch keycaps don't need to be cut to fit around the trackpoint

far = false;
index = false;

if (!is_undef(offset)) {
  printable() offset_LPX([0,offset,0]);
} else {
  printable() trackpoint_notch(far=far, index=index) LPX();
}
