include <util.scad>;
include <trackpoint_notch.scad>;
include <settings.scad>;

module CS(type="R3") {
  if (type == "R3") {
    import("levs-CS/r3-middle-row.stl");
  } else if (type == "homing") {
    import("levs-CS/r3-homing.stl");
  } else if (type == "R2") {
    rotate([0,0, 180]) import("levs-CS/r2r4-topbottom-rows.stl");
  }
}

module printable(other=false) {
  rotate([0,0,other ? -45 : 135])
    rotate([0,(other ? 1 : -1)*45,0]) children();
}

index = false;

if (!index) { // middle
  printable() trackpoint_notch(far=true) CS("homing");
  translate([0,grid_spacing,0]) printable() trackpoint_notch(far=false) CS("R2");
  translate([grid_spacing,0,0]) printable(true) mirror([1,0,0]) trackpoint_notch(far=false, index=true) CS("R3");
  translate([grid_spacing,grid_spacing,0]) printable(true) mirror([1,0,0]) trackpoint_notch(far=true, index=true) CS("R2");
 } else { // index
  printable(true) mirror([1,0,0]) trackpoint_notch(far=false, index=true) CS("homing");
  translate([0,grid_spacing,0]) printable(true) mirror([1,0,0]) trackpoint_notch(far=true, index=true) CS("R2");
  translate([grid_spacing,0,0]) printable() trackpoint_notch(far=true, index=false) CS("R3");
  translate([grid_spacing,grid_spacing,0]) printable() trackpoint_notch(far=false, index=false) CS("R2");
}
