use <logic.scad>;
use <debug.scad>;

// ways to mark the orientation and row number for a keycap

module id_marks(marks=1, width, d=1, a=8, z=0, left=true, noop=false, pips=true, deboss=true, debug=false) {
  if (noop) {
    children();
  } else if (pips) {
    _pins(marks=marks, width=width, d=d, a=a, z=z, left=left, deboss=deboss, debug=debug)
      children();
  } else {
    _marks(marks=marks, width=width, d=d, z=z, left=left, debug=debug)
      children();
  }
}

module _marks(marks=1, width, d=1, z=0, left=true,debug=false) {
  debug(debug)
    for(i=[0:marks-1])
      translate([(width-d/2) * (left ? -1 : 1), i*d*2, d+z]) sphere($fn=60, d=d);
  children();
}

module _pips(marks=1, width, d=1, a=5, z=0, left=true, deboss=true, debug=false) {
  pos = [(width-d/2) * (left ? -1 : 1), 1.5*d, d+z];
  spacing = d*2;

  debug(debug) translate(pos) rotate([0, a * (left ? 1 : -1), 0]){
    if (marks != 1 && marks != 3)
      translate([0, 0, 0])
        _pip(d=d);

    if (marks != 1 && marks != 2)
      translate([0, spacing, 0])
        _pip(d=d);

    if (marks != 2 && marks != 4)
      translate([0, spacing/2, spacing/2])
        _pip(d=d);

    if (marks != 1 && marks != 2)
      translate([0, 0, spacing])
        _pip(d=d);

    if (marks != 1 && marks != 3)
      translate([0, spacing, spacing])
        _pip(d=d);
  }

  children();
}

module _pip(d=1) {
  sphere($fn=60, d=d);
}


module _pins(marks=1, width, d=1, a=5, z=0, left=true, deboss=true, debug=false) {
  pos = [(width-d/2) * (left ? -1 : 1), 1.5*d, d+z];
  spacing = d*2;

  difference() {
    if (deboss)
      children();

    debug(debug) translate(pos) rotate([0, a * (left ? 1 : -1), 0]){
      if (marks != 1 && marks != 3)
        translate([0, 0, 0])
          _pin(d=d, xor(left, !deboss));

      if (marks != 1 && marks != 2)
        translate([0, spacing, 0])
          _pin(d=d, xor(left, !deboss));

      if (marks != 2 && marks != 4)
        translate([0, spacing/2, spacing/2])
          _pin(d=d, xor(left, !deboss));

      if (marks != 1 && marks != 2)
        translate([0, 0, spacing])
          _pin(d=d, xor(left, !deboss));

      if (marks != 1 && marks != 3)
        translate([0, spacing, spacing])
          _pin(d=d, xor(left, !deboss));
    }
  }

  if (!deboss)
    children();
}

module _pin(d=1, left) {
  scale([0.5, 1, 1]) sphere($fn=60, d=d);
  rotate([0, 90 * (left ? 1 : -1), 0]) cylinder($fn=60, h = d/2, d=d);
}

_pips(5,0);
