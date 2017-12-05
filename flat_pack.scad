//openscad flat-pack joint library
/*
##module: outside_cuts
Create a set of finger-joint cuts that result in two larger cuts taken at the outside
edge
  ###parameters:
    *length* (real)         length of edge
    *finger* (real)         length of each individual finger
    *material* (real)       thickness of material - sets cut depth
    *center* (boolean)         center the set of fingers with respect to origin
*/

module outside_cuts(length=6, finger=1, material=1, center=false) {
  // overage to ensure that all cuts are completed
  overage = 0.0001;


  //maximum possible divisions for this length
  max_divisions = floor(length/finger);
  //number of usable divisions that fall completely within the edge
  //for this implentation the number of divisions must be odd
  usable_divisions = max_divisions%2==0 ? max_divisions-3 : max_divisions-2;

  // number of "female cuts"
  num_cuts = floor(usable_divisions/2);

  //length of cut at either end
  end_cut_length = (length-usable_divisions*finger)/2;

  padding = end_cut_length + finger;

  //set position relative to origin
  x_translation = center==false ? 0 : -(num_cuts*2+1)*finger/2-end_cut_length;
  y_translation = center==false ? 0 : -material/2;


  translate([x_translation, y_translation]) {

    // make both endcuts here
    for (j = [0, 1]) {
      translate([(length-end_cut_length)*j, -overage/2])
        square([end_cut_length, material+overage]);
        if (type == "curved") {
          //very inelegant solution here
          translate([end_cut_length-finger+(length-2*end_cut_length+finger)*j, -overage/2])
            curved_finger([finger, material+overage]);
        }
    }


    //make all the "normal" finger cuts here
    for (i = [0 : num_cuts-1]) {
      translate([i*finger*2+padding, -overage/2]) //move cuts slightly in y plane
        if (type == "curved") {
          curved_finger([finger, material+overage]);
        } else {
          square([finger, material+overage]);
        }
    }
  }

} //end outside_cuts


/*
##module: inside_cuts
Create a set of finger-joint cuts all of the same size

###parameters:
    *length* (real)         length of edge
    *finger* (real)         length of each individual finger
    *material* (real)       thickness of material - sets cut depth
    *center* (boolean)         center the set of fingers with respect to origin
*/

module inside_cuts(length=6, finger=1, material=1, center=false) {
  // overage to ensure that all cuts are completed
  overage = 0.0001;

  //maximum possible divisions for this length
  max_divisions = floor(length/finger);
  //number of usable divisions that fall completely within the edge
  //for this implementation the number of divisions must be odd
  usable_divisions = max_divisions%2==0 ? max_divisions-3 : max_divisions-2;

  //add padding to align the teeth
  end_cut_length = (length-usable_divisions*finger)/2;
  padding = end_cut_length;

  // number of "female cuts"
  num_cuts = ceil(usable_divisions/2);

  //set position relative to origin
  x_translation = center==false ? padding : -usable_divisions*finger/2;
  y_translation = center==false ? 0 : -material/2;

  translate([x_translation, y_translation]) {
    for (i = [0 : num_cuts-1]) {
      translate([i*finger*2, -overage/2, 0]) //move the cuts slightly in y plane for complete cuts
      if (type == "curved") {
        curved_finger([finger, material+overage]);
      } else {
        square([finger, material+overage]); //add a small amount to ensure complete cuts
      }
    }
  }

} //end inside_cuts



module curved_finger(size, quality=24) {
  //curve quality
  $fn = quality;

  //radius - use the X dimension if the Y dimension is larger
  r = size[0] > size[1] ? size[1] : size[0]/2;
  x_trans = size[0]/2;
  y_trans = -size[1]/2+r/2;

  //generate a quarater of a square differenced with an inscribed circle
  //polarity  [-1, 1]   left or right of origin
  module quarter(polarity=-1) {
    translate([polarity*r/2, 0]) {
      difference() {
        square(r, center = true);
        translate([polarity*r/2, r/2])
          circle(r=r);
      }
    }
  }
  //position the finger so it is set in the same orientation as a square()
  translate([size[0]/2, size[1]/2]) {
    //add quarter square to finger
    union() {
      square(size=size, center=true);
      for (i = [-1, 1]) {
        translate([(x_trans)*i, y_trans])
          quarter(polarity=i);
      }
    }
  }

}


/*
##module: intside_cuts_debug
Create a set of finger-joint cuts all of the same size
  ###parameters:
    *length*      (real)           length of edge
    *finger*      (real)           length of each individual finger
    *material*    (real)           thickness of material - sets cut depth
    *center*      (boolean)        center the set of fingers with respect to origin
    *font*        (string)         name of font
*/


module inside_cuts_debug(length=6, finger=1, material=1, center=false, font="Liberation Sans") {

  x_translation = center==false ? length/2 : 0;
  y_translation = center==false ? material*1.5 : material;

  inside_cuts(length=length, finger=finger, material=material, center=center);

  debugText = finger>=length/3 ? "ERR: finger>1/3 length" : "inside cuts";

  translate([x_translation, y_translation,  0])
  text(text=debugText, size = length*.1, halign = "center", font = font);


} // end inside debug


/*
##module: outside_cuts_debug
Create a set of finger-joint cuts that result in two larger cuts taken at the i
inside edge with debugging text
  ###parameters:
    *length*      (real)           length of edge
    *finger*      (real)           length of each individual finger
    *material*    (real)           thickness of material - sets cut depth
    *center*      (boolean)        center the set of fingers with respect to origin
    *font*        (string)         name of font
*/

module outside_cuts_debug(length=6, finger=1, material=1, center=false, font="Liberation Sans") {

  x_translation = center==false ? length/2 : 0;
  y_translation = center==false ? material*1.5 : material;

  outside_cuts(length=length, finger=finger, material=material, center=center);

  debugText = finger>=length/3 ? "ERR: finger>1/3 length" : "outside cuts";

  translate([x_translation, y_translation,  0])
  text(text=debugText, size = length*.1, halign = "center", font = font);


} // end outside debug


module t_slot(diameter=false, length, material, help=false, tolerance=0.25,
              node=0) {
  //vector containing parameters for metric nut and bolt sizes
  metric_fastener = [
  ["name", "thread diameter", "hex head thickess", "hex head & nut size",
  "socket head diameter", "socket head thickness", "socket tool size",
  "nut thickness,", "pitch", "washer thickness", "washer diameter",
  "button thickness", "hex head and nut diameter"] ,
  // M0 - field descriptors place holder in array
  ["M1 - UNDEFINED"], // M1
  ["M2 Bolt, Nut & Washer", 2, 2, 4, 3.5, 2, 1.5, 1.6, 0.4, 0.3, 5.5, .90, 4.62], // M2
  ["M3 Bolt, Nut & Washer", 3, 2, 5.5, 5.5, 3, 2.5, 2.4, 0.5, 0.5, 7, 1.04, 6.35], // M3
  ["M4 Bolt, Nut & Washer", 4, 2.8, 7, 7, 4, 3, 3.2, 0.7, 0.8, 9, 1.3, 8.08], // M4
  ["M5 Bolt, Nut & Washer", 5, 3.5, 8, 8.5, 5, 4, 4, 0.8, 0.9, 10, 2.75, 9.24],
  ["M6 Bolt, Nut & Washer", 6, 4, 10, 10, 6, 5, 5, 1, 1.6, 12, 2.08, 11.55],
  ["M7 - UNDEFINED"],
  ["M8 Bolt, Nut & Washer", 8, 5.5, 13, 13, 8, 6, 6.5, 1.25, 2, 17, 2.6, 15.01],
  ["M9 - UNDEFINED"],
  ["M10 Bolt, Nut & Washer", 10, 7, 17, 16, 10, 8, 8, 1.5, 2, 21, 19.63]
];

  nut_flats = diameter != false ? metric_fastener[diameter][3] + tolerance : 1;
  nut_thickness = diameter != false ? metric_fastener[diameter][7] + tolerance : 1;


  //display help if needed
  if (help == true) {
    list_types(metric_fastener, diameter);
  }

  //create the t slot
  union() {
    translate([length-material-nut_thickness*1.5, 0, 0])
      //square([nut_thickness, nut_flats], center = true);
      nut();
    translate([0, -diameter/2, 0])
      square([length-material, diameter]);



  }

  // draw a silouette fo a nut (across the flats) with nodes to prevent cracking
  // in polycarbonate
  module nut() {
    $fn = 36;
    union() {
      square([nut_thickness, nut_flats], center = true);
      if (node > 0) {
        for (i = [-1, 1]) {
          translate([-nut_thickness/2, nut_flats/2*i])
            circle(r=nut_thickness*node);
        }
      }
    }
  }

  module list_types(array, item = false) {
    // list available fastener types stored and index values for programming refference
    descriptor = array[0];
    // only display all of the information if no item is passed
    if (!item) {
      echo("**displays contents of descriptor array**");
      echo("array_index[X] - X = value to be called for that fastener type.");
      echo("     [Y] description: Z - Y = sub array index, Z = value stored");
    }

    //range = !item ? [1:len(array-1)] :

    low = !item ? 1 : item;

    high = !item ? len(array)-1 : item;

    //for (i = [1:len(array)-1]) {
    for (i = [low:high]) {
      for (j = [ 0:len(array[i])-1 ] ) {
	if (j == 0) {
	  echo(str(descriptor[j], ": ", array[i][j]));
	  echo(str("array_index[", i,"]"));
	} else { // end if
	  echo(str("     [", j, "] ", descriptor[j], ": ", array[i][j]));
	} // end else
      } // end for j
      echo("===============================");

    } // end for i
  } // end list types

} // end t_slot

t_slot(help=true, diameter=3, length=10, material=3, node=0.7);
//!curved_finger(size=[5, 2]);
