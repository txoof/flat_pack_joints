use <./flat_pack.scad>

module finger_testing() {
  difference() {
    color("blue")
      square([110, 40]);
      #outside_cuts(length=110, finger=5, material=10, center=false);
  }

  rotate([180, 0, 0])
  translate([0, 0])
  difference() {
    color("red")
      square([110, 50]);
      translate([0, 0])
      #inside_cuts(length=110, finger=5, material=10, center=false);
  }
}


finger_testing();
