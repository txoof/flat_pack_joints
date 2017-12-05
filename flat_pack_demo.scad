use <./flat_pack.scad>

module finger_testing(size, finger, material) {
  difference() {
    color("blue")
      square([size[0], size[1]]);
      outside_cuts(length=size[0], finger=finger, material=material, center=false);
  }

  rotate([180, 0, 0])
  difference() {
    color("red")
      square([size[0], size[2]]);
      inside_cuts(length=size[0], finger=finger, material=material, center=false);
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

curved_test();
//finger_testing([102, 40, 50], 10, 10);
