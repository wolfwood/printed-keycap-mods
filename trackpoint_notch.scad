include <settings.scad>

module trackpoint_notch(far=false, index=false) {
  if (keyboard == "santoku") {
    _key_spacing = 19;
    _column_offset = 1;
    trackpoint_notch_helper(far=far, index=index, key_spacing=_key_spacing, column_offset=_column_offset) children();
  } else if(keyboard == "ortho-mx") {
    _key_spacing = 19.05;
    _column_offset = 0;
    trackpoint_notch_helper(far=far, index=index, key_spacing=_key_spacing, column_offset=_column_offset) children();
  } else if(keyboard == "ortho-choc") {
    _key_spacing = [18, 17];
    _column_offset = 0;
    trackpoint_notch_helper(far=far, index=index, key_spacing=_key_spacing, column_offset=_column_offset) children();
  }
}

module trackpoint_notch_helper(far=false, index=false, key_spacing, column_offset, dia=10) {
  let(dia = is_undef($dia) ? dia : $dia, key_spacing = is_list(key_spacing) ? keyspacing : [key_spacing, key_spacing]) {

    difference(){
      children();
      translate([key_spacing.x/2,
		 (xor(!index,far) ? -1 : 1) * ( key_spacing.y/2 + ((far?1:-1) * column_offset) ),
		 0])
	cylinder($fn=120, d=dia, h=20, center=true);
    }
  }
}
