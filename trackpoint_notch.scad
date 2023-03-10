include <settings.scad>
use <util/chord.scad>;
use <util/logic.scad>;

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
  } else if(keyboard == "ortho-lpx") {
    _key_spacing = [16.5, 15.5];
    _column_offset = 0;
    trackpoint_notch_helper(far=far, index=index, key_spacing=_key_spacing, column_offset=_column_offset) children();
  } else if(keyboard == "cylindrical-lpx") {
    _key_spacing = 16.5;
    _chord = [14.4,0,30];
    _column_offset = 0;
    rotational_trackpoint_notch_helper(far=far, index=index, key_spacing=_key_spacing, chord=_chord, column_offset=_column_offset) children();
  }
}

module trackpoint_notch_helper(far=false, index=false, key_spacing, column_offset, dia=9.7) {
  let(dia = is_undef($dia) ? dia : $dia, key_spacing = is_list(key_spacing) ? keyspacing : [key_spacing, key_spacing]) {

    difference(){
      children();
      translate([key_spacing.x/2,
		 (xor(!index,far) ? -1 : 1) * ( key_spacing.y/2 + ((far?1:-1) * column_offset) ),
		 0])
	cylinder($fn=60, d=dia, h=20, center=true);
    }
  }
}

module rotational_trackpoint_notch_helper(far=false, index=false, key_spacing, chord, column_offset=0, dia=9.7) {
  let(dia = is_undef($dia) ? dia : $dia,  key_spacing = is_list(key_spacing) ? keyspacing : [key_spacing, key_spacing],
      chord=normalize_chord(chord)) {
    difference(){
      children();

      translate([0,0,chord[1]])
	rotate([(far?1:-1)*chord[2]/2,0,0])
	  translate([key_spacing.x/2,
		   0,//(xor(!index,far) ? -1 : 1) * ( key_spacing.y/2 + ((far?1:-1) * column_offset) ),
		   -chord[1]])
	cylinder($fn=60, d=dia, h=20, center=true);
    }
  }
}
