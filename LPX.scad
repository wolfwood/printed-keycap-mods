include <util.scad>
include <trackpoint_notch.scad>

module LPX() {
  translate([-1.605,-29.001/*-28.96958*/,-9.02 + 2.7644])
    rotate([48.5,0,90]) import("LPX/LPX.stl");
}

module printable() {
  rotate([0,0,-135]) rotate([-48.5,0,0]) rotate([0,0,-90]) children();
}

// LPX is symmetrical so the notch on lower right is the same as upper left
//  also its a very small footprint, so the far (small) notch keycaps don't need to be cut to fit around the trackpoint

far = false;
index = false;

printable() trackpoint_notch(far=far, index=index) LPX();
