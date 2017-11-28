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


finger_testing([102, 40, 50], 10, 10);
