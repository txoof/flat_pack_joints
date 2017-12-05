use <./flat_pack.scad>

module finger_testing() {
  difference() {
    color("blue")
      square([110, 40]);
      outside_cuts(length=110, finger=5, material=10, center=false);
  }

  rotate([180, 0, 0])
  translate([0, 0])
  difference() {
    color("red")
      square([110, 50]);
      translate([0, 0])
      inside_cuts(length=110, finger=5, material=10, center=false);
  }
}

//finger_testing();

module curved_test(dim=[100, 50, 45]) {
  translate() {
    //faceXY
    difference() {
      square([dim[0], dim[1]]);
      outside_cuts(length=dim[0], finger=5, material=10, type = "curved");
      translate([dim[0]/2, dim[1]/2])
        text(text="faceXY", size=dim[0]*.1, halign="center");
    }
  }
  //faceXZ
  translate([0, -dim[1]]) {
    difference() {
      square(size=[dim[0], dim[1]]);
      translate([dim[0]/2, dim[1]-5])
        rotate([0, 0, 180])
        inside_cuts(length=dim[0], finger=5, material=10, type="curved", center=true);
    }
  }
}

//curved_test();
t_slot(help=true, diameter=3, length=30, material=3, node=0.25);
