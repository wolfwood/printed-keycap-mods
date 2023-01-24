key_spacing = 19;
column_offset = 2;

module trackpoint_notch(far=false, index=false) {
  dia = 10;

  difference(){
    children();
    translate([key_spacing/2,
    (xor(!index,far) ? -1 : 1) * ( key_spacing/2 + ((far?1:-1) * column_offset) ),
      0])
    cylinder($fn=120, d=dia, h=20, center=true);
  }
}
