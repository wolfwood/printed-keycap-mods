use <LPX.scad>
include <../includes/KeyV2/src/stems.scad>;


module mx_stem(stem_h=4, slop=.1) {
  angle= [0,48.5,0];
  total = stem_h + slop;
  difference() {
    translate([0,0,1.3-stem_h]) stem("cherry",total, 0.35);

    translate([0,0,-stem_h]) {
      let (x=3, z=-6.2) {
	rotate(angle)
	  translate([-x,0,z])
	  cube([5,10,10], center=true);

	rotate(-angle)
	  translate([x,0,z])
	  cube([5,10,10], center=true);
      }

      let (x=.5, z=-3.345) {
	rotate(angle)
	  translate([-x,0,z])
	  cube([1.5,10,10], center=true);

	rotate(-angle)
	  translate([x,0,z])
	  cube([1.5,10,10], center=true);
      }
    }
  }
}

// stem_h = 4 for most switches, 3.5 for speed switches
module LPxMX(stem_h=4, pos=[0,0,0], slop=.1) {
  union(){
    LPX_shell();
    translate(pos) mx_stem(stem_h=stem_h, slop=slop);
  }
}

speed = true;
offset=0;
printable() LPxMX(stem_h=speed ? 3.5 : 4, pos=[0,offset,0]);
