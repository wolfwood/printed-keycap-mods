include <settings.scad>
use <util/chord.scad>;
use <util/logic.scad>;

// if the columns the trackpoint sits between are staggered (and the
// trackpoint is centered), far controls if the notch is for a keycap
// nearer or farther from the trackpoint.
//
// index (indicating the trackpoint is between the index finger
// columns, not between index and middle fingers) is used for
// symmetrical, uniform profile keycaps to determine notch placement.
//
// for sculpted profiles, notch placement is indicated by setting $x
// and $y to 1 or -1, indicating which quadrant of the XY plane the
// notch lies in. $x=1, $y=1 indicates upper right, x=-1, $y=-1 lower
// left.
module trackpoint_notch(far=false, index=false) {
  if (keyboard == "santoku") {
    _key_spacing = 19;
    _column_offset = 1;
    trackpoint_helper_dispatch(far=far, index=index, key_spacing=_key_spacing, column_offset=_column_offset) children();
  } else if(keyboard == "ortho-mx") {
    _key_spacing = 19.05;
    _column_offset = 0;
    trackpoint_helper_dispatch(far=far, index=index, key_spacing=_key_spacing, column_offset=_column_offset) children();
  } else if(keyboard == "ortho-choc") {
    _key_spacing = [18, 17];
    _column_offset = 0;
    trackpoint_helper_dispatch(far=far, index=index, key_spacing=_key_spacing, column_offset=_column_offset) children();
  } else if(keyboard == "ortho-lpx") {
    _key_spacing = [16.5, 15.5];
    _column_offset = 0;
    trackpoint_helper_dispatch(far=far, index=index, key_spacing=_key_spacing, column_offset=_column_offset) children();
  } else if(keyboard == "ortho-lc") {
    _key_spacing = [16, 16];
    _column_offset = 0;
    trackpoint_helper_dispatch(far=far, index=index, key_spacing=_key_spacing, column_offset=_column_offset) children();
  } else if(keyboard == "cylindrical-lpx") {
    _key_spacing = 16.5;
    _chord = [14.4,0,30];
    _column_offset = 0;
    rotational_trackpoint_notch_helper(far=far, index=index, key_spacing=_key_spacing, chord=_chord, column_offset=_column_offset) children();
  }
}

module trackpoint_helper_dispatch(far, index, key_spacing, column_offset) {
  if(tp_chamfer()) {
    trackpoint_chamfer_helper(far=far, index=index, key_spacing=key_spacing, column_offset=column_offset) children();
  } else {
    trackpoint_notch_helper(far=far, index=index, key_spacing=key_spacing, column_offset=column_offset) children();
  }
}


// this module adds a dynamic chamfer, and a smaller notch, to a keycap
//
//  we could use a cone to cut the chamfer, but this would require
//  manually tuning the height of the cone for each keycap cluster and
//  is unbounded in how far it can intrude into the middle of the
//  keycap, affecting feel. it also would remove tall keycap edges on
//  aggressively dished profiles much farther away from trackpoint,
//  where interference isn't an issue
//
//  we could use a cone with a limited diameter and a cylinder on top,
//  but this would leave a sharp edge that would feel unpleasant to
//  type on.
//
//  instead the dynamic chamfer cuts the keycap with its own top
//  surface, lowered by increasing amounts. different points along the
//  circumference will be at different heights based on the keycap
//  shape, unlike with a cone. the downsides are that the depth of the
//  trackpoint is limited by the tallest features of the cap, so the
//  chamfer may need to be a bit steeper, and complexity of both the
//  computation and the resulting model. But the advantages are that
//  we get a smooth, continuous surface when printed that blends into
//  the typing surface, and that we don't need to know the height of
//  the keycap, only how deep we want the trackpoint.
//
//  The actual surface is stepped like an auditorium, but by reducing
//  the step size the slicer will approximate a smooth surface.
//
//  exporting as .3mf or binary .stl is recommended to reduce file size
module trackpoint_chamfer_helper(far=false, index=false, key_spacing, column_offset) {
  // matches laptop keyboards
  chamfer_dia = 14;

  // dimensions from the cap supplied with an SK8702
  rim_dia = 9;
  _base_dia = 7;

  // if you want cap to sit lower or higher, adjust rim_depth
  //  1 mm is the height of the rim ignoring the domed part. 1.75 is the total height
  rim_depth = 1;

  base_clearance = .5;
  base_dia = _base_dia + 2*base_clearance;// add to either side for clearance
  rim_clearance = [rim_dia + .7, 0, rim_depth + .2];

  // horizontal distance of the chamfer
  chamfer_d = (chamfer_dia-base_dia)/2;

  // check both vertical and radial clearance
  chamfer_angle= max( atan(rim_clearance.z/((chamfer_dia-rim_dia)/2)), atan(rim_depth/((chamfer_dia-rim_clearance.x)/2)) );

  echo(str("Chamfer Angle: ", chamfer_angle));

  key_spacing = is_list(key_spacing) ? key_spacing : [key_spacing, key_spacing];

  // its easier to displace the keycap and keep trackpoint at the origin
  module decenter_keycap(reverse=false) {
    translate([(reverse ? -1 : 1) * -key_spacing.x/2 * (is_undef($x) ? 1 : $x),
	       (reverse ? -1 : 1) * -(is_undef($y) ? xor(!index,far) ? -1 : 1 : $y) * ( key_spacing.y/2 + ((far?1:-1) * column_offset) ),
	     0])
      children();
  }

  module cylindrical_corner(dia=chamfer_dia) {
    intersection(){
      decenter_keycap() children();
      cylinder($fn=60, d=dia, h=20, center=true);
    }
  }

  module stepped_corner(step=tp_chamfer_steps()){
    for(i=[step:step:chamfer_d]){
      difference(){
	//translate([step, -step,.1]) cylindrical_corner(chamfer_dia-(i*2)) children();
	cylinder($fn=60, d=chamfer_dia-(i*2), h=20, center=true);
	translate([0,0,-i*tan(chamfer_angle)]) cylindrical_corner() children();
      }
    }
  }

  // put the keycap back when done
  decenter_keycap(reverse=true) {
    // model trackpoint
    if($preview) {
      #let(h=3) {
	cylinder($fn=60,h=h+.1,d=5.75);
	translate([0,0,h]) cylinder($fn=60,h=1,d=rim_dia);
      }
    }

    difference() {
      decenter_keycap() children();

      // chamfer
      stepped_corner() children();

      // notch
      cylinder($fn=60, d=base_dia,h=50,center=true);
    }
  }
}


module trackpoint_notch_helper(far=false, index=false, key_spacing, column_offset, dia=9.7) {
  let(dia = is_undef($dia) ? dia : $dia, key_spacing = is_list(key_spacing) ? key_spacing : [key_spacing, key_spacing]) {

    difference(){
      children();
      translate([key_spacing.x/2 * (is_undef($x) ? 1 : $x),
		 (is_undef($y) ? xor(!index,far) ? -1 : 1 : $y) * ( key_spacing.y/2 + ((far?1:-1) * column_offset) ),
		 0])
	cylinder($fn=60, d=dia, h=20, center=true);
    }
  }
}


module rotational_trackpoint_notch_helper(far=false, index=false, key_spacing, chord, column_offset=0, dia=9.7) {
  let(dia = is_undef($dia) ? dia : $dia,  key_spacing = is_list(key_spacing) ? key_spacing : [key_spacing, key_spacing],
      chord=normalize_chord(chord)) {
    difference(){
      children();

      translate([0,0,chord[1]])
	rotate([(is_undef($y) ? far?1:-1 : $y)*chord[2]/2,0,0])
	  translate([key_spacing.x/2 * (is_undef($x) ? 1 : $x),
		   0,//(xor(!index,far) ? -1 : 1) * ( key_spacing.y/2 + ((far?1:-1) * column_offset) ),
		   -chord[1]])
	cylinder($fn=60, d=dia, h=20, center=true);
    }
  }
}
