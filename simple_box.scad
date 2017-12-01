use <lib/boxmaker.scad>;

// Inner Dimensions: Length (mm)
x = 100;
// Inner Dimensions: Width (mm)
y = 70;
// Inner Dimensions: Height (mm)
z = 50;

// Material thickness (mm)
thickness = 3;

// Lid?
lid = 1; // [0:Closed box,1:Box with lid]

// Render type
show_3d = 0; // [0:2D for cutting,1:3D preview]

/////////////////////////////////////////////////////////////////////

/* [Hidden] */

box_inner = [x, y, z];

// Finger width (mm)
finger_width = thickness * 2;

  // Finger width (X, Y, Z, TopX, TopY) (mm)
fingers = [finger_width, finger_width, finger_width, finger_width, finger_width];

// Finger width (X, Y, Z, TopX, TopY) (mm)
fingers_with_lid = [finger_width, finger_width, finger_width,
                 box_inner[0] / 3, box_inner[1] / 3];

if (show_3d) {
  if (lid) {
    box_3d(box_inner, thickness, fingers_with_lid);
  } else {
    box_3d(box_inner, thickness, fingers);
  }
} else {
  if (lid) {
    box_2d(box_inner, thickness, fingers_with_lid);
  } else {
    box_2d(box_inner, thickness, fingers);
  }
}
