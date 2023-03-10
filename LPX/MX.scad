use <LPX.scad>
include <../includes/KeyV2/src/stems.scad>;

// stem_h = 4 for most switches, 3.5 for speed switches
module LPxMX(stem_h=4, pos=[0,0,0], damper=0, slop=.1) {
  union(){
    LPX_shell();
    total = stem_h + damper+slop;
    translate([0,0,1.3-stem_h]+pos) stem("cherry",total, 0.35);
  }
}

speed = true;
offset=0;
printable() LPxMX(stem_h=speed ? 3.5 : 4, pos=[0,offset,0]);
