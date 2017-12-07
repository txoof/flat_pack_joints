include <flat_pack.scad>;

/*
 * A finger-jointed lasercut box maker OpenSCAD library.
 *
 * Inspired by http://boxdesigner.connectionlab.org/
 */
module box_2d(box_inner, thickness, fingers, margin=2) {
  layout_2d(box_inner, thickness) {
    side_xy_top(box_inner, thickness, fingers);
    side_xy(box_inner, thickness, fingers);
    side_yz(box_inner, thickness, fingers);
    side_yz(box_inner, thickness, fingers);
    side_xz(box_inner, thickness, fingers);
    side_xz(box_inner, thickness, fingers);
  }
}

// An assembled version of the box for previewing.
module box_3d(box_inner, thickness, fingers) {
  layout_3d(box_inner, thickness) {
    side_xy_top(box_inner, thickness, fingers);
    side_xy(box_inner, thickness, fingers);
    side_yz(box_inner, thickness, fingers);
    side_yz(box_inner, thickness, fingers);
    side_xz(box_inner, thickness, fingers);
    side_xz(box_inner, thickness, fingers);
  }
}

// lasercut layout
module layout_2d(inner, thickness, margin=2) {
  spacing_horizontal = inner[0] + thickness * 2 + margin;
  spacing_both = thickness * 2 + margin;

  // top
  children(0);
  // bottom
  translate([spacing_horizontal, 0, 0])
    children(1);
  // left
  translate([spacing_horizontal * 2, inner[1], 0])
    rotate([0, 0, -90])
      children(2);
  // left
  translate([spacing_horizontal * 2 + inner[2] + spacing_both, inner[1], 0])
    rotate([0, 0, -90])
      children(3);
  // front
  translate([0, inner[1] + spacing_both, 0])
    children(4);
  // back
  translate([inner[0] + spacing_both, inner[1] + spacing_both, 0])
    children(5);
}

// An assembled version of the box for previewing.
module layout_3d(box_inner, thickness) {
  color("red") {
    // top
    translate([0, 0, box_inner[2]])
      linear_extrude(height=thickness)
        children(0);

    // bottom
    translate([0, box_inner[1], 0])
      rotate([180, 0, 0])
        linear_extrude(height=thickness)
          children(1);
  }

  color("green") {
    // left
    translate([0, box_inner[1], 0])
      rotate([90, 0, -90])
        linear_extrude(height=thickness)
          children(2);

    // right
    translate([box_inner[0], 0, 0])
      rotate([90, 0, 90])
        linear_extrude(height=thickness)
          children(3);
  }

  // front
  color("blue") {
    translate([0, 0, 0])
      rotate([90, 0, 0])
        linear_extrude(height=thickness)
          children(4);

    // back
    translate([box_inner[0], box_inner[1], 0])
      rotate([90, 0, 180])
        linear_extrude(height=thickness)
          children(5);
  }
}

module side_xy_top(inner, thickness, fingers) {
  side([inner[0], inner[1]],
       thickness,
       [fingers[3], fingers[4], fingers[3], fingers[4]],
       [0, 0, 0, 0]);
}

module side_xy(inner, thickness, fingers) {
  side([inner[0], inner[1]],
       thickness,
       [fingers[0], fingers[1], fingers[0], fingers[1]],
       [0, 0, 0, 0]);
}

// left/right
module side_yz(inner, thickness, fingers) {
  side([inner[1], inner[2]],
       thickness,
       [fingers[4], fingers[2], fingers[1], fingers[2]],
       [1, 0, 1, 0]);
}

// front/back
module side_xz(inner, thickness, fingers) {
  side([inner[0], inner[2]],
       thickness,
       [fingers[3], fingers[2], fingers[0], fingers[2]],
       [1, 1, 1, 1]);
}

module side(inner, thickness, fingers, polarity) {
  SMIDGE = 0.1;
  x = inner[0] + thickness * 2;
  y = inner[1] + thickness * 2;

  translate([-thickness, -thickness])
    difference() {
      square([x, y]);

      // bottom
      if (fingers[2] > 0)
        translate([0, -SMIDGE, 0])
          edge_cuts(x, fingers[2], thickness + SMIDGE, polarity[2]);

      // top
      if (fingers[0] > 0)
        translate([0, y - thickness, 0])
          edge_cuts(x, fingers[0], thickness + SMIDGE, polarity[0]);

      rotate([0, 0, -90]) {
        translate([-y, 0, 0]) {
          // left
          if (fingers[3] > 0)
            translate([0, -SMIDGE, 0])
              edge_cuts(y, fingers[3], thickness + SMIDGE, polarity[3]);

          // right
          if (fingers[1] > 0)
            translate([0, x - thickness, 0])
              edge_cuts(y, fingers[1], thickness + SMIDGE, polarity[1]);
          }
        }
    }
}

module edge_cuts(length, finger_width, cut_depth, polarity) {
  if (polarity == 0) {
    outside_cuts(length, finger_width, cut_depth);
  } else {
    inside_cuts(length, finger_width, cut_depth);
  }
}

// Used if you don't want a given side.
module empty() {}
